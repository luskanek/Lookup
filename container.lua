local _G = getfenv(0)

local function SearchBoxTextChanged()
	local query = this:GetText()
	if query and query ~= 'Search' then
		local first = 0
		local last = NUM_BAG_SLOTS
		if BankFrame:IsVisible() then
			first = -1
			last = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
		end

		for bag = first, last do
			local size = GetContainerNumSlots(bag)
			for slot = 1, size do
				local item = _G['ContainerFrame' .. (bag + 1) .. 'Item' .. ((size - slot) + 1)] or _G['BankFrameItem' .. slot]
				local texture = _G[item:GetName() .. 'IconTexture']
				local _, count = GetContainerItemInfo(bag, slot)
				if count then
					item:SetAlpha(0.3)
					texture:SetDesaturated(1)

					local link = GetContainerItemLink(bag, slot)
					local _, _, id = string.find(link, 'item:(%d+):(%d*):(%d*):(%d*)')
					local _, _, rarity, _, type = GetItemInfo(tonumber(id))

					local name = string.sub(link, string.find(link, '%[') + 1, string.find(link, '%]') - 1)
					if string.find(string.lower(name), string.lower(string.gsub(query, '([^%w])', '%%%1'))) then
						item:SetAlpha(1)
						texture:SetDesaturated(0)
					end
		
					if strlower(query) == strlower(_G['ITEM_QUALITY' .. rarity .. '_DESC']) then
						item:SetAlpha(1)
						texture:SetDesaturated(0)
					end

					if strupper(type) == strupper(query) then
						item:SetAlpha(1)
						texture:SetDesaturated(0)
					end
				end
			end
		end
	else
		this:SetText('Search')

		local first = 0
		local last = NUM_BAG_SLOTS
		if BankFrame:IsVisible() then
			first = -1
			last = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
		end

		for bag = first, last do
			for slot = 1, GetContainerNumSlots(bag) do
				local item = _G['ContainerFrame' .. (bag + 1) .. 'Item' .. slot] or _G['BankFrameItem' .. slot]
				local texture = _G[item:GetName() .. 'IconTexture']
				
				item:SetAlpha(1)
				texture:SetDesaturated(0)
			end
		end
	end
end

-- create search edit box
local searchbox = CreateFrame('EditBox', 'BackpackSearchBox', ContainerFrame1, 'SearchBoxTemplate')
searchbox:SetPoint('TOPLEFT', ContainerFrame1, 'TOPLEFT', 50, 83)
searchbox:SetPoint('BOTTOMRIGHT', ContainerFrame1, 'BOTTOMRIGHT', -10, 80)
searchbox:SetText('Search')
searchbox:SetTextColor(0.5, 0.5, 0.5, 1.0)
searchbox:SetScript('OnTextChanged', SearchBoxTextChanged)

local previous = ContainerFrame1:GetScript('OnShow')
ContainerFrame1:SetScript('OnShow',
	function()
		previous()

		if this:GetID() == 0 then searchbox:Show() else searchbox:Hide() end
	end
)