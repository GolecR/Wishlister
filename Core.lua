-- AceAddon Setup
Wishlister = LibStub("AceAddon-3.0"):NewAddon("Wishlister", "AceConsole-3.0", "AceEvent-3.0")

local buttonPoolIcons = {}
local ADD_ITEM_ICON = 135769
local REMOVE_ITEM_ICON = 135768

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function Wishlister:OnInitialize()
    -- SavedVariables DB Setup
    self.db = LibStub("AceDB-3.0"):New("WishlisterDB")
    if Wishlister.db.char.wishlist == nil then
        Wishlister.db.char.wishlist = {}
    end
    --LibStub("AceConfig-3.0"):RegisterOptionsTable("Wishlister", {}, {"wishlister"})

    -- Secure Func Hooking
    local init
	hooksecurefunc(_G, "EncounterJournal_LoadUI", function()
		if not init then
			EncounterJournal:HookScript("OnUpdate", function()
				Wishlister:UpdateEncounterJournal()
			end)
			init = true
		end
	end)

    -- Blizz Options UI Setup
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Wishlister", "Wishlister")
end

function Wishlister:UpdateEncounterJournal()
    if not EncounterJournalEncounterFrameInfo.LootContainer.ScrollBox or not EncounterJournalEncounterFrameInfo.LootContainer.ScrollBox:IsShown() then
        return
    end

    for name,frame in pairs(buttonPoolIcons) do
		frame:Hide()
	end

    for scrollItemIndex,itemButton in ipairs(EncounterJournalEncounterFrameInfo.LootContainer.ScrollBox:GetFrames()) do

        local wishlistFrameName = "Wishlister_"..scrollItemIndex
        local wishlistFrame = buttonPoolIcons[wishlistFrameName]
        if not wishlistFrame then
            wishlistFrame = CreateFrame("FRAME", wishlistFrameName, itemButton)
            buttonPoolIcons[wishlistFrameName] = wishlistFrame
            wishlistFrame:SetSize(20, 20)
            wishlistFrame.texture = wishlistFrame:CreateTexture()
            wishlistFrame.texture:SetAllPoints(wishlistFrame)
            --print("Wishlister:UpdateEncounterJournal:AddButton:"..scrollItemIndex..":CreateFrame")
        end
        wishlistFrame:Show()
        wishlistFrame:SetParent(itemButton)
        wishlistFrame:ClearAllPoints()
        wishlistFrame:SetPoint("BOTTOMRIGHT", itemButton.name, "TOPLEFT", 264, -10)
        wishlistFrame:Raise()

        
        if Wishlister.db.char.wishlist[itemButton.itemID] == nil or Wishlister.db.char.wishlist[itemButton.itemID] == false then
            wishlistFrame.texture:SetTexture(ADD_ITEM_ICON)
            wishlistFrame:SetScript("OnMouseDown", function () Wishlister:AddItem(itemButton.itemID) end)
        else
            wishlistFrame.texture:SetTexture(REMOVE_ITEM_ICON)
            wishlistFrame:SetScript("OnMouseDown", function () Wishlister:RemoveItem(itemButton.itemID) end)

        end
        --print("Wishlister:UpdateEncounterJournal:AddButton:"..scrollItemIndex..":end")
	end   
end

function Wishlister:AddItem(itemID)
    print("Wishlister:UpdateEncounterJournal:AddItem:"..itemID)
    Wishlister.db.char.wishlist[itemID] = true
end

function Wishlister:RemoveItem(itemID)
    print("Wishlister:UpdateEncounterJournal:RemoveItem:"..itemID)
    Wishlister.db.char.wishlist[itemID] = nil
end