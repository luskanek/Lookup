local _G = getfenv(0)

local function SearchBoxTextChanged()
   local query = strlower(this:GetText())
   if query and query ~= 'Search' and strlen(query) > 2 then
      local found = false

      for i = 2, 8 do
         local current, total = SpellBook_GetCurrentPage()
         for j = current, total do
            for k = 1, 12 do
               local button = _G['SpellButton' .. k]
               if button and button:IsEnabled() then
                  local spell = _G[button:GetName() .. 'SpellName']:GetText()
                  if spell and spell ~= '' then
                     if strfind(strlower(spell), query) then
                        found = true
                        return
                     end
                  end
               end
            end

            SpellBookNextPageButton:Click()
         end

         if not found then
            local current = SpellBook_GetCurrentPage()
            for j = current, 1, -1 do
               SpellBookPrevPageButton:Click()
            end
         end

         _G['SpellBookSkillLineTab' .. i]:Click()
      end

      if not found then
         SpellBookSkillLineTab1:Click()
      end
   end
end

local searchbox = CreateFrame('EditBox', 'SpellBookSearchBox', SpellBookFrame, 'SearchBoxTemplate')
searchbox:SetWidth(250)
searchbox:SetHeight(20)
searchbox:SetPoint('TOPLEFT', SpellBookFrame, 84, -46)
searchbox:SetText('Search')
searchbox:SetTextColor(0.5, 0.5, 0.5, 1)
searchbox:SetScript('OnTextChanged', SearchBoxTextChanged)