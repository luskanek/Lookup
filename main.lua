local _G = getfenv(0)

-- table of item rarities
local ITEM_RARITY = {
	"POOR GREY GRAY JUNK",
	"COMMON WHITE",
	"UNCOMMON GREEN",
	"RARE BLUE",
	"EPIC PURPLE",
	"LEGENDARY ORANGE"
}

-- helper function to get the key of a table value
local function GetIndex(table, item)
	for key, value in pairs(table) do
		local subs = { }
		string.gsub(value, "(%w+)",
			function(match)
				tinsert(subs, match)
			end
		)
		for _, substring in pairs(subs) do
			if substring == item then
				return key
			end
		end
    end

    return nil
end

-- create search edit box
CreateFrame("EditBox", "BackpackSearchBox", ContainerFrame1, "InputBoxTemplate")
BackpackSearchBox:ClearAllPoints()
BackpackSearchBox:SetPoint("TOPLEFT", ContainerFrame1, "TOPLEFT", 50, 83)
BackpackSearchBox:SetPoint("BOTTOMRIGHT", ContainerFrame1, "BOTTOMRIGHT", -10, 80)
BackpackSearchBox:SetAutoFocus(false)
BackpackSearchBox:SetText("Search")
BackpackSearchBox:SetTextColor(0.5, 0.5, 0.5, 1)
BackpackSearchBox:SetTextInsets(15, 20, 0, 0)
BackpackSearchBox:SetHitRectInsets(15, 20, 0, 0)

-- create a fancy search icon
local icon = CreateFrame('Frame', nil, BackpackSearchBox)
icon:ClearAllPoints()
icon:SetPoint('LEFT', BackpackSearchBox, 1, -2)
icon:SetHeight(14)
icon:SetWidth(14)
icon:SetBackdrop({
	bgFile = "Interface\\AddOns\\Lookup\\assets\\Search",
})
icon:SetBackdropColor(1, 1, 1, 0.6)

-- create a button to clear the text
CreateFrame('Button', "BackpackSearchBoxClearButton", BackpackSearchBox)
BackpackSearchBoxClearButton:ClearAllPoints()
BackpackSearchBoxClearButton:SetPoint('RIGHT', BackpackSearchBox, -3, 0)
BackpackSearchBoxClearButton:SetHeight(14)
BackpackSearchBoxClearButton:SetWidth(14)
BackpackSearchBoxClearButton:SetBackdrop({
	bgFile = "Interface\\AddOns\\Lookup\\assets\\Clear",
})
BackpackSearchBoxClearButton:SetBackdropColor(1, 1, 1, 0.6)

BackpackSearchBox:SetScript("OnTextChanged",
	function()
		local query = this:GetText()
		if query and query ~= "Search" then
			local first = 0
			local last = NUM_BAG_SLOTS
			if BankFrame:IsVisible() then
				first = -1
				last = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
			end

			for bag = first, last do
				local size = GetContainerNumSlots(bag)
				for slot = 1, size do
					local item = _G["ContainerFrame" .. (bag + 1) .. "Item" .. ((size - slot) + 1)] or _G["BankFrameItem" .. slot]
					local texture = _G[item:GetName() .. "IconTexture"]
					local _, count = GetContainerItemInfo(bag, slot)
					if count then
						item:SetAlpha(0.3)
						texture:SetDesaturated(1)

						local link = GetContainerItemLink(bag, slot)
						local _, _, id = string.find(link, 'item:(%d+):(%d*):(%d*):(%d*)')
						local _, _, rarity, _, type = GetItemInfo(tonumber(id))

						-- name
						local name = string.sub(link, string.find(link, "%[") + 1, string.find(link, "%]") - 1)
						if string.find(string.lower(name), string.lower(string.gsub(query, "([^%w])", "%%%1"))) then
							item:SetAlpha(1)
							texture:SetDesaturated(0)
						end
			
						-- rarity
						local index = GetIndex(ITEM_RARITY, string.upper(query))
						if index then
							if rarity == index - 1 then
								item:SetAlpha(1)
								texture:SetDesaturated(0)
							end
						end

						-- type
						if string.upper(type) == string.upper(query) then
							item:SetAlpha(1)
							texture:SetDesaturated(0)
						end
					end
				end
			end
		end
	end
)

local previous = ContainerFrame1:GetScript('OnShow')
ContainerFrame1:SetScript('OnShow',
	function()
		previous()

		if this:GetID() == 0 then BackpackSearchBox:Show() else BackpackSearchBox:Hide() end
	end
)

BackpackSearchBox:SetScript("OnEditFocusGained",
	function()
		this:SetTextColor(1.0, 1.0, 1.0, 1)

		if this:GetText() == "Search" then
			this:SetText("")
		end
	end
)

BackpackSearchBox:SetScript("OnEditFocusLost",
	function()
		this:SetTextColor(0.5, 0.5, 0.5, 1)

		if not string.find(this:GetText(), "%w") then
			this:SetText("Search")

			local first = 0
			local last = NUM_BAG_SLOTS
			if BankFrame:IsVisible() then
				first = -1
				last = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
			end

			for bag = first, last do
				for slot = 1, GetContainerNumSlots(bag) do
					local item = _G["ContainerFrame" .. (bag + 1) .. "Item" .. slot] or _G["BankFrameItem" .. slot]
					local texture = _G[item:GetName() .. "IconTexture"]
					
					item:SetAlpha(1)
					texture:SetDesaturated(0)
				end
			end
		end
	end
)

BackpackSearchBox:SetScript("OnEnterPressed",
	function()
		this:ClearFocus()
	end
)

BackpackSearchBoxClearButton:SetScript("OnClick",
	function()
		BackpackSearchBox:SetText("")
		BackpackSearchBox:SetFocus()
		BackpackSearchBox:ClearFocus()
	end
)

BackpackSearchBoxClearButton:SetScript("OnEnter",
	function()
		this:SetBackdropColor(1, 1, 1, 1)
	end
)

BackpackSearchBoxClearButton:SetScript("OnLeave",
	function()
		this:SetBackdropColor(1, 1, 1, 0.6)
	end
)