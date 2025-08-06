local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local logger = require(script.Parent.logger)

local dataservice = require(ReplicatedStorage.Packages.dataservice)
local networker = require(ReplicatedStorage.Packages.networker)
local observers = require(ReplicatedStorage.Packages.observers)
local promise = require(ReplicatedStorage.Packages.promise)
local signal = require(ReplicatedStorage.Packages.signal)

local log = logger.new("MARKETPLACE", true)

-- gets the universe id from the place id of an experience

local marketplace = {
	GAMEPASSES = HttpService:JSONDecode(
		HttpService:GetAsync(`https://games.roproxy.com/v1/games/{game.GameId}/game-passes?limit=100&sortOrder=Asc`)
	),
	CALLBACKS = {},
	GLOBAL_CALLBACKS = {},
	NETWORK = {} :: networker.Server,
	PREMIUM_CHANGES_SIGNALS = {},
	NOTIFICATION_CALLBACK = function(plr: Player, text: string, boolean: boolean)
		log:print("Sent a notification to: " .. plr.Name .. " , status: " .. tostring(boolean))
	end,
}

export type ProcessReceipt = {
	PurchaseId: number,
	PlayerId: number,
	ProductId: number,
}

-- ON COMPLETION FUNCTIONS --

MarketplaceService.ProcessReceipt = function(receiptInfo: ProcessReceipt)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if player and player.Parent == Players then
		local local_callback = marketplace.CALLBACKS[receiptInfo.ProductId][player]
		if local_callback then
			local_callback(player, true)
		else
			local global_callback = marketplace.GLOBAL_CALLBACKS[receiptInfo.ProductId]
			if global_callback then
				global_callback(player, true)
			end
		end

		marketplace.NOTIFICATION_CALLBACK(player, "THANKS FOR PURCHASING", true)

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, gamepassId, isPurchased)
	if isPurchased then
		dataservice.server:set(plr, { "Gamepasses", gamepassId }, true)
	end

	marketplace.NETWORK:fire(plr, "hide")
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(playerId, productId)
	marketplace.NETWORK:fire(Players:GetPlayerByUserId(playerId), "hide")
end)

-- Sets a callback to when a gift is received by any server to the player
dataservice.server:addGlobalCallback(
	"gift",
	function(player: Player, info: { id: number, gifter: number, gamepass: boolean })
		if not info.gamepass then
			marketplace.GLOBAL_CALLBACKS[info.id](player, true)
		else
			dataservice.server:set(player, { "Gamepasses", info.id }, true)
		end

		marketplace.NOTIFICATION_CALLBACK(
			player,
			"YOU HAVE RECEIVED A GIFT FROM: " .. string.upper(Players:GetNameFromUserIdAsync(info.gifter)),
			true
		)
	end
)

-- SHARED FUNCTIONS --

function marketplace.PromptPurchase(plr, productId: number, IsGamepass: boolean?)
	if IsGamepass then
		if dataservice.server:get(plr, "Gamepasses")[productId] then
			log:warn("Player already owns the gamepass")
			return
		end

		MarketplaceService:PromptGamePassPurchase(plr, productId)
	else
		MarketplaceService:PromptProductPurchase(plr, productId)
	end
	marketplace.NETWORK:fire(plr, "show")
end

-- Returns the current player status for premium and
function marketplace.OwnsPremium(player: Player): (boolean, signal.Signal<>)
	return player.MembershipType == Enum.MembershipType.Premium, marketplace.PREMIUM_CHANGES_SIGNALS[player]
end

-- SERVER HANDLED FUNCTIONS --

function marketplace.CallbackToPurchase(
	self: marketplace,
	productId: number | { [number]: (plr: Player, status: boolean) -> () },
	callback: (plr: Player, status: boolean) -> (),
	player: Player?,
	promptOnCallback: boolean?
)
	log:assert(productId, "product id not provided")
	log:assert(typeof(productId) == "number" and player, "cannot provide table when player is provided")
	log:assert(promptOnCallback and player, "cannot prompt on callback when initializing global callbacks")

	if player then
		if not self.CALLBACKS[productId] then
			self.CALLBACKS[productId] = {}
		end

		self.CALLBACKS[productId][player] = function(status)
			log:print(player, "has finished purchasing product with id:", productId)
			self.CALLBACKS[player] = nil
			callback(player, status)
		end

		if promptOnCallback then
			marketplace.PromptPurchase(player, productId, false)
		end
	else
		if typeof(productId) == "table" then
			for id, callback in productId do
				self.GLOBAL_CALLBACKS[id] = callback
			end
		else
			self.GLOBAL_CALLBACKS[productId] = callback
		end
	end
end

--[[
    Prompts the player with a purchase of the gift id given, when the player buys it a gift will be prompted to any server,
    if the player is in the server than the callback will be played on that player
]]
function marketplace.Gift(self: marketplace, giftId, player: Player, receiverId: number, isGamepass: boolean?)
	marketplace:CallbackToPurchase(giftId, function(player, status)
		if status then
			for _, plr in Players:GetPlayers() do
				if plr.UserId == receiverId then
					self.GLOBAL_CALLBACKS[giftId](plr, true)
					return
				end
			end

			dataservice.server:sendGlobalMessage("gift", receiverId, {
				id = giftId,
				gifter = player.UserId,
				gamepass = isGamepass,
			})
		end
	end, player, true)
end

function marketplace.CheckForMissingGamepasses(self: marketplace, player)
	for _, data in self.GAMEPASSES do
		local productId = data.ProductId :: number
		log:print(data) -- prints the data to debug
		if productId and MarketplaceService:UserOwnsGamePassAsync(player.UserId, productId) then
			dataservice.server:update(player, { "Gamepasses", productId }, function(old)
				return true
			end)
		end
	end
end

-- INITIALIZATION --

function marketplace.SetNotification(createNotificationCallback)
	if createNotificationCallback then
		marketplace.NOTIFICATION_CALLBACK = createNotificationCallback
	end
end

observers.observePlayer(function(plr)
	if not dataservice.server:get(plr, "Gamepasses") then
		dataservice.server:set(plr, "Gamepasses", {})
		marketplace.PREMIUM_CHANGES_SIGNALS[plr] = signal.new()
		marketplace:CheckForMissingGamepasses(plr)
	end
end)

marketplace.NETWORK = networker.server.new("marketplace", marketplace, {
	marketplace.Gift,
	marketplace.PromptPurchase,
})
export type marketplace = typeof(marketplace) & {}

return marketplace
