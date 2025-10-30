-- ╔═══════════════════════════════════════════════════════════════╗
-- ║         CHAIN BUT ORBI - X11 ULTRA EDITION v3.1               ║
-- ║              Professional X11 GUI System                      ║
-- ╚═══════════════════════════════════════════════════════════════╝

local game = game or getgenv().game
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ═══════════════════ X11 UI LIBRARY (EMBEDDED) ═══════════════════
local UILib = {}
UILib.__index = UILib

local ESP_FONTSIZE = 7
local BLACK = Color3.new(0, 0, 0)
local myPlayer = Players.LocalPlayer
local myMouse = myPlayer:GetMouse()

local function clamp(x, a, b)
    if x > b then return b
    elseif x < a then return a
    else return x end
end

local function getMousePos()
    return Vector2.new(myMouse.X, myMouse.Y)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

function UILib._GetTextBounds(str)
    return #str * ESP_FONTSIZE, ESP_FONTSIZE
end

function UILib._IsMouseWithinBounds(origin, size)
    local mousePos = getMousePos()
    return mousePos.x >= origin.x and mousePos.x <= origin.x + size.x and 
           mousePos.y >= origin.y and mousePos.y <= origin.y + size.y
end

function UILib.new(name, size, watermarkActivity)
    repeat wait(1/9999) until isrbxactive()
    
    local self = setmetatable({}, UILib)
    
    -- Input system
    self._inputs = {
        ['m1'] = { id = 0x01, held = false, click = false },
        ['f1'] = { id = 0x70, held = false, click = false },
        ['f2'] = { id = 0x71, held = false, click = false },
        ['f3'] = { id = 0x72, held = false, click = false },
        ['f4'] = { id = 0x73, held = false, click = false },
        ['f5'] = { id = 0x74, held = false, click = false },
        ['f6'] = { id = 0x75, held = false, click = false },
        ['insert'] = { id = 0x2D, held = false, click = false },
    }
    
    self._active_tab = nil
    self._open = true
    self._watermark = true
    self._base_opacity = 0
    self._dragging = false
    self._drag_offset = Vector2.new(0, 0)
    self._watermark_dragging = false
    self._watermark_drag_offset = Vector2.new(0, 0)
    self._tick = os.clock()
    
    -- User settings
    self.identity = name
    self._watermark_activity = watermarkActivity
    self.x = 100
    self.y = 100
    self.w = size and size.x or 520
    self.h = size and size.y or 450
    self.watermark_x = 20
    self.watermark_y = 20
    
    -- Theme colors
    self._color_accent = Color3.fromRGB(255, 127, 0)
    self._color_text = Color3.fromRGB(255, 255, 255)
    self._color_crust = Color3.fromRGB(0, 0, 0)
    self._color_border = Color3.fromRGB(25, 25, 25)
    self._color_surface = Color3.fromRGB(38, 38, 38)
    self._color_overlay = Color3.fromRGB(76, 76, 76)
    
    -- Styling
    self._title_h = 25
    self._tab_h = 20
    self._padding = 6
    
    -- Menu base
    local base = Drawing.new('Square')
    base.Filled = true
    base.Color = self._color_surface
    
    local crust = Drawing.new('Square')
    crust.Filled = false
    crust.Thickness = 1
    crust.Color = self._color_crust
    
    local border = Drawing.new('Square')
    border.Filled = false
    border.Thickness = 1
    border.Color = self._color_border
    
    local navbar = Drawing.new('Square')
    navbar.Filled = true
    navbar.Color = self._color_border
    
    local title = Drawing.new('Text')
    title.Text = self.identity
    title.Outline = true
    title.Color = self._color_text
    
    -- Watermark
    local watermarkBase = Drawing.new('Square')
    watermarkBase.Filled = true
    watermarkBase.Color = self._color_surface
    
    local watermarkCursor = Drawing.new('Square')
    watermarkCursor.Filled = true
    watermarkCursor.Color = self._color_accent
    
    local watermarkCrust = Drawing.new('Square')
    watermarkCrust.Filled = false
    watermarkCrust.Thickness = 1
    watermarkCrust.Color = self._color_crust
    
    local watermarkBorder = Drawing.new('Square')
    watermarkBorder.Filled = false
    watermarkBorder.Thickness = 1
    watermarkBorder.Color = self._color_border
    
    local watermarkText = Drawing.new('Text')
    watermarkText.Text = name
    watermarkText.Outline = true
    watermarkText.Color = self._color_text
    
    self._tree = {
        ['_tabs'] = {},
        ['_drawings'] = { crust, border, base, navbar, title, watermarkBase, watermarkCursor, 
                         watermarkCrust, watermarkBorder, watermarkText }
    }
    
    return self
end

function UILib:ToggleWatermark(state)
    self._watermark = state
end

function UILib:ToggleMenu(state)
    self._open = state
end

function UILib:IsMenuOpen()
    return self._open
end

function UILib:Tab(name)
    local backdrop = Drawing.new('Square')
    backdrop.Color = self._color_border
    backdrop.Filled = true
    
    local cursor = Drawing.new('Square')
    cursor.Color = self._color_accent
    cursor.Filled = true
    
    local text = Drawing.new('Text')
    text.Color = self._color_text
    text.Outline = true
    text.Text = name
    
    table.insert(self._tree['_tabs'], {
        ['name'] = name,
        ['_sections'] = {},
        ['_drawings'] = { backdrop, cursor, text }
    })
    
    if self._active_tab == nil then
        self._active_tab = name
    end
    
    return name
end

function UILib:Section(tabName, name)
    for _, tab in ipairs(self._tree['_tabs']) do
        if tab['name'] == tabName then
            local base = Drawing.new('Square')
            base.Filled = true
            base.Color = self._color_surface
            
            local crust = Drawing.new('Square')
            crust.Filled = false
            crust.Thickness = 1
            crust.Color = self._color_crust
            
            local border = Drawing.new('Square')
            border.Filled = false
            border.Thickness = 1
            border.Color = self._color_overlay
            
            local title = Drawing.new('Text')
            title.Text = name
            title.Outline = true
            title.Color = self._color_text
            
            local section = {
                ['name'] = name,
                ['_items'] = {},
                ['_drawings'] = { base, crust, border, title }
            }
            
            table.insert(tab._sections, section)
            return name
        end
    end
end

function UILib:_AddToSection(tabName, sectionName, itemType, value, callback, drawings, meta)
    for _, tab in pairs(self._tree._tabs) do
        if tab.name == tabName then
            for _, section in pairs(tab._sections) do
                if section.name == sectionName then
                    local item = {
                        ['type'] = itemType,
                        ['value'] = value,
                        ['callback'] = callback,
                        ['_drawings'] = drawings
                    }
                    
                    if meta then
                        for key, val in pairs(meta) do
                            item[key] = val
                        end
                    end
                    
                    table.insert(section._items, item)
                    return
                end
            end
        end
    end
end

function UILib:Checkbox(tabName, sectionName, label, defaultValue, callback)
    local outline = Drawing.new('Square')
    outline.Color = self._color_crust
    outline.Thickness = 1
    outline.Filled = false
    
    local check = Drawing.new('Square')
    check.Color = self._color_accent
    check.Filled = true
    
    local text = Drawing.new('Text')
    text.Color = self._color_text
    text.Outline = true
    text.Text = label
    
    self:_AddToSection(tabName, sectionName, 'checkbox', defaultValue, callback, {
        outline, check, text
    })
end

function UILib:Button(tabName, sectionName, label, callback)
    local outline = Drawing.new('Square')
    outline.Color = self._color_crust
    outline.Thickness = 1
    outline.Filled = false
    
    local fill = Drawing.new('Square')
    fill.Color = self._color_crust
    fill.Filled = true
    
    local text = Drawing.new('Text')
    text.Color = self._color_text
    text.Outline = true
    text.Text = label
    
    self:_AddToSection(tabName, sectionName, 'button', nil, callback, {
        outline, fill, text
    }, { ['label'] = label })
end

function UILib:Label(tabName, sectionName, text)
    local label = Drawing.new('Text')
    label.Color = self._color_text
    label.Outline = true
    label.Text = text
    
    self:_AddToSection(tabName, sectionName, 'label', text, nil, { label })
end

function UILib:Step()
    local deltaTime = math.max(os.clock() - self._tick, 0.0035)
    local mousePos = getMousePos()
    
    -- Update input states
    for keycode, inputData in pairs(self._inputs) do
        local keycodeId = inputData['id']
        local interacted = iskeypressed(keycodeId)
        if isrbxactive() and interacted then
            if inputData['held'] == false and inputData['click'] == false then
                self._inputs[keycode]['click'] = true
            else
                self._inputs[keycode]['click'] = false
            end
            self._inputs[keycode]['held'] = true
        else
            self._inputs[keycode]['held'] = false
        end
    end
    
    local menuOpen = self._open
    local clickFrame = menuOpen and self._inputs['m1'].click
    local m1Held = menuOpen and self._inputs['m1'].held
    
    local baseOpacity = self._base_opacity
    local childrenVisible = baseOpacity > 0.22
    self._base_opacity = clamp(lerp(baseOpacity, menuOpen and 1 or 0, deltaTime * 11), 0, 1)
    
    setrobloxinput(not menuOpen)
    
    -- Draw watermark
    local watermarkBase = self._tree['_drawings'][6]
    local watermarkCursor = self._tree['_drawings'][7]
    local watermarkCrust = self._tree['_drawings'][8]
    local watermarkBorder = self._tree['_drawings'][9]
    local watermarkTitle = self._tree['_drawings'][10]
    
    if self._watermark then
        local watermarkStates = {self.identity}
        if self._watermark_activity then
            for _, activity in ipairs(self._watermark_activity) do
                if type(activity) == 'function' then
                    local activityString = activity()
                    if activityString and #activityString > 0 then
                        table.insert(watermarkStates, activityString)
                    end
                end
            end
        end
        
        local watermarkText = table.concat(watermarkStates, ' | ')
        local watermarkW, watermarkH = self._GetTextBounds(watermarkText)
        local watermarkPosition = Vector2.new(self.watermark_x, self.watermark_y)
        local watermarkSize = Vector2.new(watermarkW + self._padding * 3, watermarkH + self._padding * 3)
        
        watermarkBase.Position = watermarkPosition
        watermarkBase.Size = watermarkSize
        watermarkBase.Visible = true
        watermarkBase.Color = self._color_surface
        
        watermarkCrust.Position = watermarkPosition
        watermarkCrust.Size = watermarkSize
        watermarkCrust.Visible = true
        
        watermarkBorder.Position = watermarkPosition + Vector2.new(1, 1)
        watermarkBorder.Size = watermarkSize + Vector2.new(-2, -2)
        watermarkBorder.Visible = true
        
        watermarkCursor.Position = watermarkPosition + Vector2.new(2, 2)
        watermarkCursor.Size = Vector2.new(watermarkSize.x - 4, 1)
        watermarkCursor.Visible = true
        
        watermarkTitle.Position = watermarkPosition + Vector2.new(2 + self._padding, 2 + self._padding)
        watermarkTitle.Text = watermarkText
        watermarkTitle.Visible = true
        
        -- Watermark dragging
        if self._IsMouseWithinBounds(watermarkPosition, watermarkSize) then
            if clickFrame and not self._dragging then
                self._watermark_dragging = true
                self._watermark_drag_offset = mousePos - watermarkPosition
            end
        end
        
        if self._watermark_dragging then
            if m1Held then
                self.watermark_x = mousePos.x - self._watermark_drag_offset.x
                self.watermark_y = mousePos.y - self._watermark_drag_offset.y
            else
                self._watermark_dragging = false
            end
        end
    else
        watermarkBase.Visible = false
        watermarkCrust.Visible = false
        watermarkBorder.Visible = false
        watermarkCursor.Visible = false
        watermarkTitle.Visible = false
    end
    
    -- Draw menu base
    local uiCrust = self._tree['_drawings'][1]
    local uiBorder = self._tree['_drawings'][2]
    local uiBase = self._tree['_drawings'][3]
    local uiNavbar = self._tree['_drawings'][4]
    local uiTitle = self._tree['_drawings'][5]
    
    uiBase.Position = Vector2.new(self.x, self.y)
    uiBase.Size = Vector2.new(self.w, self.h)
    uiBase.Transparency = baseOpacity
    uiBase.Visible = childrenVisible
    
    uiBorder.Position = Vector2.new(self.x + 1, self.y + 1)
    uiBorder.Size = Vector2.new(self.w - 2, self.h - 2)
    uiBorder.Transparency = baseOpacity
    uiBorder.Visible = childrenVisible
    
    uiCrust.Position = Vector2.new(self.x, self.y)
    uiCrust.Size = Vector2.new(self.w, self.h)
    uiCrust.Transparency = baseOpacity
    uiCrust.Visible = childrenVisible
    
    uiNavbar.Position = Vector2.new(self.x + 2, self.y + 2)
    uiNavbar.Size = Vector2.new(self.w - 4, self._title_h - 4)
    uiNavbar.Transparency = baseOpacity
    uiNavbar.Visible = childrenVisible
    
    local _, titleH = self._GetTextBounds('')
    uiTitle.Position = Vector2.new(self.x + 7, self.y + self._title_h / 2 - titleH + 2)
    uiTitle.Transparency = baseOpacity
    uiTitle.Visible = childrenVisible
    
    -- Menu dragging
    local titleOrigin = Vector2.new(self.x, self.y)
    local titleSize = Vector2.new(self.w, self._title_h)
    
    if self._IsMouseWithinBounds(titleOrigin, titleSize) then
        if clickFrame and not self._watermark_dragging then
            self._dragging = true
            self._drag_offset = mousePos - titleOrigin
        end
    end
    
    if self._dragging then
        if m1Held then
            self.x = mousePos.x - self._drag_offset.x
            self.y = mousePos.y - self._drag_offset.y
        else
            self._dragging = false
        end
        clickFrame = false
    end
    
    -- Draw tabs
    local numTabs = #self._tree['_tabs']
    for tabIndex, tab in ipairs(self._tree['_tabs']) do
        local tabName = tab['name']
        local tabDraws = tab['_drawings']
        local tabOpen = self._active_tab == tabName
        
        local tabBackdrop = tabDraws[1]
        local tabCursor = tabDraws[2]
        local tabText = tabDraws[3]
        
        local tabW = (self.w - self._padding * 2 - (numTabs - 1) * 2) / numTabs
        local tabH = self._tab_h
        local tabPosition = Vector2.new(self.x + self._padding + (tabIndex - 1) * (tabW + 2), 
                                        self.y + self._title_h + self._padding)
        local tabSize = Vector2.new(tabW, tabH)
        
        tabBackdrop.Position = tabPosition
        tabBackdrop.Size = tabSize
        tabBackdrop.Transparency = baseOpacity
        tabBackdrop.Visible = childrenVisible
        
        tabCursor.Position = tabPosition
        tabCursor.Size = Vector2.new(tabW, 1)
        tabCursor.Transparency = baseOpacity
        tabCursor.Visible = tabOpen and childrenVisible
        
        tabText.Position = tabPosition + Vector2.new(4, tabH / 2 - ESP_FONTSIZE / 2)
        tabText.Transparency = baseOpacity
        tabText.Visible = childrenVisible
        
        if clickFrame and self._IsMouseWithinBounds(tabPosition, tabSize) then
            self._active_tab = tabName
        end
        
        -- Draw sections
        if tabOpen then
            local totalSectionH_0 = self._padding
            local totalSectionH_1 = self._padding
            
            for sectionIndex, section in ipairs(tab['_sections']) do
                local sectionDraws = section['_drawings']
                local sectionItems = section['_items']
                
                local sectionY = self._padding * 2
                local opposite = (sectionIndex+1) % 2
                local sectionW = self.w / 2 - self._padding * 1.5
                local sectionPos = Vector2.new(
                    self.x + self._padding + self._padding * opposite + sectionW * opposite,
                    self.y + self._title_h + self._tab_h + self._padding * 2 + 
                    (opposite==1 and totalSectionH_0 or totalSectionH_1)
                )
                
                -- Draw items
                for _, sectionItem in ipairs(sectionItems) do
                    local itemType = sectionItem['type']
                    local itemDraws = sectionItem['_drawings']
                    local itemValue = sectionItem['value']
                    local itemCallback = sectionItem['callback']
                    local itemPosition = sectionPos + Vector2.new(10, sectionY)
                    
                    if itemType == 'checkbox' then
                        local checkboxOutline = itemDraws[1]
                        local checkboxCheck = itemDraws[2]
                        local checkboxLabel = itemDraws[3]
                        
                        local boxSize = Vector2.new(14, 14)
                        checkboxOutline.Position = itemPosition
                        checkboxOutline.Size = boxSize
                        checkboxOutline.Transparency = baseOpacity
                        checkboxOutline.Visible = childrenVisible
                        
                        checkboxCheck.Position = itemPosition + Vector2.new(1, 1)
                        checkboxCheck.Size = boxSize - Vector2.new(2, 2)
                        checkboxCheck.Transparency = baseOpacity
                        checkboxCheck.Visible = itemValue == true and childrenVisible
                        
                        checkboxLabel.Position = itemPosition + Vector2.new(boxSize.x + 8, 0)
                        checkboxLabel.Transparency = baseOpacity
                        checkboxLabel.Visible = childrenVisible
                        
                        if self._IsMouseWithinBounds(itemPosition, boxSize) then
                            checkboxOutline.Color = self._color_accent
                            if clickFrame then
                                sectionItem['value'] = not sectionItem['value']
                                if itemCallback then
                                    itemCallback(sectionItem['value'])
                                end
                            end
                        else
                            checkboxOutline.Color = self._color_crust
                        end
                        
                        sectionY = sectionY + boxSize.y + 8
                        
                    elseif itemType == 'button' then
                        local buttonOutline = itemDraws[1]
                        local buttonFill = itemDraws[2]
                        local buttonLabel = itemDraws[3]
                        
                        local buttonText = sectionItem['label']
                        local buttonTextW, buttonTextH = self._GetTextBounds(buttonText)
                        local buttonBoxSize = Vector2.new(sectionW - self._padding * 3, 22)
                        
                        buttonLabel.Position = itemPosition + Vector2.new(self._padding, 5)
                        buttonLabel.Transparency = baseOpacity
                        buttonLabel.Visible = childrenVisible
                        
                        buttonOutline.Position = itemPosition
                        buttonOutline.Size = buttonBoxSize
                        buttonOutline.Transparency = baseOpacity
                        buttonOutline.Visible = childrenVisible
                        
                        buttonFill.Position = itemPosition + Vector2.new(2, 2)
                        buttonFill.Size = buttonBoxSize - Vector2.new(4, 4)
                        buttonFill.Transparency = baseOpacity
                        buttonFill.Visible = childrenVisible
                        
                        if self._IsMouseWithinBounds(itemPosition, buttonBoxSize) then
                            if clickFrame and itemCallback then
                                itemCallback()
                            end
                            buttonOutline.Color = self._color_accent
                        else
                            buttonOutline.Color = self._color_crust
                        end
                        
                        sectionY = sectionY + 26
                        
                    elseif itemType == 'label' then
                        local label = itemDraws[1]
                        label.Position = itemPosition
                        label.Text = itemValue
                        label.Transparency = baseOpacity
                        label.Visible = childrenVisible
                        
                        -- Bilgi yazıları için daha görünür renk
                        if itemValue == '---' then
                            label.Color = self._color_overlay
                        else
                            label.Color = self._color_text
                        end
                        
                        sectionY = sectionY + ESP_FONTSIZE + 6
                    end
                end
                
                -- Section frame
                local sectionBackdrop = sectionDraws[1]
                local sectionCrust = sectionDraws[2]
                local sectionBorder = sectionDraws[3]
                local sectionTitle = sectionDraws[4]
                
                sectionCrust.Position = sectionPos
                sectionCrust.Size = Vector2.new(sectionW, sectionY)
                sectionCrust.Transparency = baseOpacity
                sectionCrust.Visible = childrenVisible
                
                sectionBorder.Position = sectionPos + Vector2.new(1, 1)
                sectionBorder.Size = Vector2.new(sectionW - 2, sectionY - 2)
                sectionBorder.Transparency = baseOpacity
                sectionBorder.Visible = childrenVisible
                
                local _, sectionTitleH = self._GetTextBounds('')
                sectionTitle.Position = sectionPos + Vector2.new(10, - sectionTitleH / 2)
                sectionTitle.Transparency = baseOpacity
                sectionTitle.Visible = childrenVisible
                
                sectionBackdrop.Visible = false
                
                sectionY = sectionY + self._padding
                if opposite == 1 then
                    totalSectionH_0 = totalSectionH_0 + sectionY
                else
                    totalSectionH_1 = totalSectionH_1 + sectionY
                end
            end
        else
            -- Hide section when tab not active
            for _, section in ipairs(tab['_sections']) do
                for _, drawing in ipairs(section['_drawings']) do
                    drawing.Visible = false
                end
                for _, item in ipairs(section['_items']) do
                    for _, drawing in ipairs(item['_drawings']) do
                        drawing.Visible = false
                    end
                end
            end
        end
    end
    
    self._tick = os.clock()
end

function UILib:Destroy()
    for _, drawing in pairs(self._tree['_drawings']) do
        drawing:Remove()
    end
    
    for _, tab in pairs(self._tree['_tabs']) do
        if tab['_drawings'] then
            for _, drawing in pairs(tab['_drawings']) do
                drawing:Remove()
            end
        end
        if tab._sections then
            for _, section in pairs(tab._sections) do
                for _, drawing in pairs(section['_drawings']) do
                    drawing:Remove()
                end
                if section._items then
                    for _, item in pairs(section._items) do
                        for _, drawing in pairs(item['_drawings']) do
                            drawing:Remove()
                        end
                    end
                end
            end
        end
    end
    
    setrobloxinput(true)
end

-- ═══════════════════ GAME CONFIG ═══════════════════
local cfg = {
    scrap = {
        TELEPORT_OFFSET = 2.5,
        WAIT_BEFORE_CLICK = 0.25,
        WAIT_AFTER_CLICK = 0.35,
        LOOP_WAIT = 2
    }
}

-- ═══════════════════ STATE ═══════════════════
local state = {
    features = {
        infStamina = false,
        clashStrength = false,
        autoFSpam = false,
        scrapCollector = false,
        autoTeleport = false,
        infGas = false
    },
    locationIndex = 1,
    stats = {
        sessionTime = 0,
        featuresUsed = 0,
        teleports = 0,
        scrapCollected = 0
    }
}

-- ═══════════════════ LOCATIONS ═══════════════════
local locations = {
    {name = "Safe House", pos = Vector3.new(162.68, -94.26 + 15, 230.04)},
    {name = "Workshop Out", pos = Vector3.new(130.92, -106.07 + 5, -2.18)},
    {name = "Workshop In", pos = Vector3.new(169.56, -103.65 + 5, -30.01)},
    {name = "Cabin", pos = Vector3.new(-324.80, -88.62 + 5, 290.68)},
    {name = "Shop", pos = Vector3.new(-111.38, -87.21 + 5, 203.52)},
    {name = "Power Station", pos = Vector3.new(-208.30, -110.60 + 5, -120.23)},
    {name = "Warehouse", pos = Vector3.new(314.62, -113.52 + 15, -258.48)},
    {name = "Ritual Site", pos = Vector3.new(-18.60, -107.78 + 5, -229.90)},
    {name = "Leaderboard", pos = Vector3.new(45.66, -97.97 + 15, 352.51)},
    {name = "Radio Tower", pos = Vector3.new(-402.22, -112.37 + 15, 44.17)},
    {name = "Void Edge", pos = Vector3.new(39.06, -99.17 + 5, 574.26)}
}

-- ═══════════════════ UTILITY ═══════════════════
local function getStats()
    return string.format("Time: %ds | Used: %d | TPs: %d | Scrap: %d",
        state.stats.sessionTime,
        state.stats.featuresUsed,
        state.stats.teleports,
        state.stats.scrapCollected
    )
end

-- ═══════════════════ FEATURES ═══════════════════

local function toggleInfStamina(enabled)
    state.features.infStamina = enabled
    if enabled then
        spawn(function()
            while state.features.infStamina do
                pcall(function()
                    local char = player.Character
                    if char and char:FindFirstChild("Stats") then
                        local stats = char.Stats
                        if stats:FindFirstChild("Stamina") then stats.Stamina.Value = 100 end
                        if stats:FindFirstChild("CombatStamina") then stats.CombatStamina.Value = 100 end
                    end
                end)
                wait(0.1)
            end
        end)
        state.stats.featuresUsed = state.stats.featuresUsed + 1
        print("[ORBI] Infinite Stamina ENABLED")
    else
        print("[ORBI] Infinite Stamina DISABLED")
    end
end

local function unlockBlueprints()
    local blueprints = {"CombatKnife", "Deagle", "DoubleBarrel", "M1911", "Machete", "SpellBook", 
                        "CombatKnifeTWO", "Angelica", "Reficul", "XSAW", "MakeshiftAK", "MacheteTWO"}
    pcall(function()
        local bp = player:FindFirstChild("PlayerStats")
        if bp then bp = bp:FindFirstChild("Blueprints")
            if bp then
                for _, name in ipairs(blueprints) do bp:SetAttribute(name, true) end
                state.stats.featuresUsed = state.stats.featuresUsed + 1
                print("[ORBI] All Blueprints Unlocked!")
            end
        end
    end)
end

local function toggleClashStrength(enabled)
    state.features.clashStrength = enabled
    if enabled then
        spawn(function()
            while state.features.clashStrength do
                pcall(function()
                    local char = player.Character
                    if char and char:FindFirstChild("Stats") then
                        local cs = char.Stats:FindFirstChild("ClashStrength")
                        if cs then cs.Value = 100 end
                    end
                end)
                wait(0.1)
            end
        end)
        state.stats.featuresUsed = state.stats.featuresUsed + 1
        print("[ORBI] Max Clash Strength ENABLED")
    else
        print("[ORBI] Max Clash Strength DISABLED")
    end
end

local function toggleAutoFSpam(enabled)
    state.features.autoFSpam = enabled
    if enabled then
        spawn(function()
            while state.features.autoFSpam do
                if iskeypressed(71) then -- G key
                    keypress(70)
                    wait(0.01)
                    keyrelease(70)
                end
                wait(0.05)
            end
        end)
        state.stats.featuresUsed = state.stats.featuresUsed + 1
        print("[ORBI] Auto F Spam ENABLED (Hold G)")
    else
        print("[ORBI] Auto F Spam DISABLED")
    end
end

-- ═══════════════════ INFINITE GAS FEATURE ═══════════════════

local gasSetterRunning = false

local function toggleInfGas(enabled)
    state.features.infGas = enabled
    if enabled then
        gasSetterRunning = true
        spawn(function()
            while gasSetterRunning do
                pcall(function()
                    local char = player.Character
                    if char then
                        local items = char:FindFirstChild("Items")
                        if items then
                            local xsaw = items:FindFirstChild("XSaw")
                            if xsaw then
                                xsaw:SetAttribute("Gas", 9999)
                            end
                        end
                    end
                end)
                wait(0.5)
            end
        end)
        state.stats.featuresUsed = state.stats.featuresUsed + 1
        print("[ORBI] Infinite XSaw Gas ENABLED")
    else
        gasSetterRunning = false
        print("[ORBI] Infinite XSaw Gas DISABLED")
    end
end

-- ═══════════════════ SCRAP COLLECTOR ═══════════════════

local function getScrapPosition(scrap)
    local gearMain = scrap:FindFirstChild("GearMain")
    if gearMain and gearMain:IsA("MeshPart") then
        local pos = gearMain.Position
        return Vector3.new(pos.X, pos.Y + cfg.scrap.TELEPORT_OFFSET, pos.Z)
    end
    
    local gear = scrap:FindFirstChild("Gear")
    if gear and gear:IsA("MeshPart") then
        local pos = gear.Position
        return Vector3.new(pos.X, pos.Y + cfg.scrap.TELEPORT_OFFSET, pos.Z)
    end
    
    if scrap.PrimaryPart then
        local pos = scrap.PrimaryPart.Position
        return Vector3.new(pos.X, pos.Y + cfg.scrap.TELEPORT_OFFSET, pos.Z)
    end
    
    local descendants = scrap:GetDescendants()
    for i = 1, #descendants do
        local desc = descendants[i]
        if desc:IsA("BasePart") or desc:IsA("MeshPart") then
            local pos = desc.Position
            return Vector3.new(pos.X, pos.Y + cfg.scrap.TELEPORT_OFFSET, pos.Z)
        end
    end
    
    return nil
end

local function findProximityPrompt(scrap)
    local prompt = scrap:FindFirstChild("Prompt")
    if prompt then
        local descendants = prompt:GetDescendants()
        for i = 1, #descendants do
            if descendants[i]:IsA("ProximityPrompt") then
                return descendants[i]
            end
        end
    end
    
    local descendants = scrap:GetDescendants()
    for i = 1, #descendants do
        if descendants[i]:IsA("ProximityPrompt") then
            return descendants[i]
        end
    end
    
    return nil
end

local function lookAtScrap(scrapPos)
    local screenPos, onScreen = WorldToScreen(scrapPos)
    if onScreen then
        mousemoveabs(screenPos.X, screenPos.Y)
    end
end

local function teleportAndCollectScrap(scrap)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local scrapPos = getScrapPosition(scrap)
    if not scrapPos then return false end
    
    char.HumanoidRootPart.Position = scrapPos
    wait(0.1)
    
    local targetPos = Vector3.new(scrapPos.X, scrapPos.Y - cfg.scrap.TELEPORT_OFFSET, scrapPos.Z)
    lookAtScrap(targetPos)
    
    wait(cfg.scrap.WAIT_BEFORE_CLICK)
    
    local proximityPrompt = findProximityPrompt(scrap)
    if proximityPrompt then
        keypress(0x45)
        wait(0.05)
        keyrelease(0x45)
        wait(cfg.scrap.WAIT_AFTER_CLICK)
        state.stats.scrapCollected = state.stats.scrapCollected + 1
        return true
    end
    
    return false
end

local function collectAllScraps()
    local MiscFolder = Workspace:FindFirstChild("Misc")
    if not MiscFolder then return end
    
    local ZonesFolder = MiscFolder:FindFirstChild("Zones")
    if not ZonesFolder then return end
    
    local LootingItems = ZonesFolder:FindFirstChild("LootingItems")
    if not LootingItems then return end
    
    local LootFolders = LootingItems:FindFirstChild("Scrap")
    if not LootFolders then return end
    
    local children = LootFolders:GetChildren()
    local successCount = 0
    
    print("[ORBI] Starting scrap collection...")
    
    for i = 1, #children do
        if not state.features.scrapCollector then break end
        
        local scrap = children[i]
        local char = player.Character
        
        if not char or not char.Parent then
            char = player.Character
            while not char do wait(0.3) end
        end
        
        if scrap:IsA("Model") then
            local values = scrap:FindFirstChild("Values")
            local scrapAttr = scrap:GetAttribute("Scrap")
            
            if scrapAttr ~= nil and values then
                local available = values:GetAttribute("Available")
                
                if available == true then
                    local success = teleportAndCollectScrap(scrap)
                    if success then successCount = successCount + 1 end
                end
            end
        end
        
        wait(0.1)
    end
    
    if successCount > 0 then
        print(string.format("[ORBI] Collected %d scraps!", successCount))
    end
end

local function toggleScrapCollector(enabled)
    state.features.scrapCollector = enabled
    if enabled then
        spawn(function()
            while state.features.scrapCollector do
                collectAllScraps()
                wait(cfg.scrap.LOOP_WAIT)
            end
        end)
        state.stats.featuresUsed = state.stats.featuresUsed + 1
        print("[ORBI] Scrap Collector ENABLED")
    else
        print("[ORBI] Scrap Collector DISABLED")
    end
end

local function activateArtifactQuest()
    pcall(function()
        local playerStats = player:FindFirstChild("PlayerStats")
        if playerStats then
            local quests = playerStats:FindFirstChild("Quests")
            if quests then
                quests:SetAttribute("ArtifactQuest", true)
                state.stats.featuresUsed = state.stats.featuresUsed + 1
                print("[ORBI] Artifact Quest Activated!")
            end
        end
    end)
end

local function teleportToLocation()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local loc = locations[state.locationIndex]
            char.HumanoidRootPart.Position = loc.pos
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: " .. loc.name)
            state.locationIndex = (state.locationIndex % #locations) + 1
        end
    end)
end

-- ═══════════════════ CREATE GUI ═══════════════════

local gui = UILib.new('CHAIN BUT ORBI - X11 ULTRA', Vector2.new(520, 480), {getStats})

-- Combat Tab
local combatTab = gui:Tab('Combat')
local combatMain = gui:Section(combatTab, 'Main Features')
gui:Checkbox(combatTab, combatMain, 'Infinite Stamina', false, toggleInfStamina)
gui:Checkbox(combatTab, combatMain, 'Max Clash Strength', false, toggleClashStrength)
gui:Checkbox(combatTab, combatMain, 'Auto F Spam (Hold G)', false, toggleAutoFSpam)
gui:Checkbox(combatTab, combatMain, 'Infinite XSaw Gas', false, toggleInfGas)
gui:Label(combatTab, combatMain, '---')
gui:Label(combatTab, combatMain, 'Combat features for battles')

local combatItems = gui:Section(combatTab, 'Items & Blueprints')
gui:Button(combatTab, combatItems, 'Unlock All Blueprints', unlockBlueprints)
gui:Label(combatTab, combatItems, 'Unlocks all weapons/items')

-- Farming Tab
local farmTab = gui:Tab('Farming')
local farmMain = gui:Section(farmTab, 'Auto Collection')
gui:Checkbox(farmTab, farmMain, 'Scrap Auto Collector', false, toggleScrapCollector)
gui:Label(farmTab, farmMain, 'Auto collects all scraps')
gui:Label(farmTab, farmMain, 'Loops every 2 seconds')

local farmQuests = gui:Section(farmTab, 'Quests')
gui:Button(farmTab, farmQuests, 'Activate Artifact Quest', activateArtifactQuest)
gui:Label(farmTab, farmQuests, 'Enables artifact quest')

-- Teleport Tab
local tpTab = gui:Tab('Teleport')
local tpMain = gui:Section(tpTab, 'Quick Travel')
gui:Button(tpTab, tpMain, 'Teleport [F1] (Cycle)', teleportToLocation)
gui:Label(tpTab, tpMain, 'Press F1 to cycle locations')
gui:Label(tpTab, tpMain, '---')

local tpLocations = gui:Section(tpTab, 'Direct Teleports')
gui:Button(tpTab, tpLocations, 'Safe House', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(162.68, -94.26 + 15, 230.04)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Safe House")
        end
    end)
end)

gui:Button(tpTab, tpLocations, 'Workshop Out', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(130.92, -106.07 + 5, -2.18)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Workshop Out")
        end
    end)
end)

gui:Button(tpTab, tpLocations, 'Workshop In', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(169.56, -103.65 + 5, -30.01)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Workshop In")
        end
    end)
end)

gui:Button(tpTab, tpLocations, 'Cabin', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(-324.80, -88.62 + 5, 290.68)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Cabin")
        end
    end)
end)

gui:Button(tpTab, tpLocations, 'Shop', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(-111.38, -87.21 + 5, 203.52)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Shop")
        end
    end)
end)

gui:Button(tpTab, tpLocations, 'Power Station', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(-208.30, -110.60 + 5, -120.23)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Power Station")
        end
    end)
end)

gui:Button(tpTab, tpLocations, 'Warehouse', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(314.62, -113.52 + 15, -258.48)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Warehouse")
        end
    end)
end)

gui:Button(tpTab, tpLocations, 'Ritual Site', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(-18.60, -107.78 + 5, -229.90)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Ritual Site")
        end
    end)
end)

gui:Button(tpTab, tpLocations, 'Leaderboard', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(45.66, -97.97 + 15, 352.51)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Leaderboard")
        end
    end)
end)

gui:Button(tpTab, tpLocations, 'Radio Tower', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(-402.22, -112.37 + 15, 44.17)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Radio Tower")
        end
    end)
end)

gui:Button(tpTab, tpLocations, 'Void Edge', function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Position = Vector3.new(39.06, -99.17 + 5, 574.26)
            state.stats.teleports = state.stats.teleports + 1
            print("[ORBI] Teleported to: Void Edge")
        end
    end)
end)

-- Settings Tab
local settingsTab = gui:Tab('Settings')
local settingsMain = gui:Section(settingsTab, 'Menu Settings')
gui:Label(settingsTab, settingsMain, 'Press INSERT to toggle GUI')
gui:Checkbox(settingsTab, settingsMain, 'Show Watermark', true, function(state)
    gui:ToggleWatermark(state)
end)
gui:Label(settingsTab, settingsMain, 'Watermark shows live stats')
gui:Label(settingsTab, settingsMain, 'Drag watermark to move it')
gui:Label(settingsTab, settingsMain, '---')

local settingsInfo = gui:Section(settingsTab, 'Information')
gui:Label(settingsTab, settingsInfo, 'CHAIN BUT ORBI')
gui:Label(settingsTab, settingsInfo, 'X11 Ultra Edition v3.1')
gui:Label(settingsTab, settingsInfo, 'Created by: ORBIIII')
gui:Label(settingsTab, settingsInfo, '---')
gui:Label(settingsTab, settingsInfo, 'Features:')
gui:Label(settingsTab, settingsInfo, '- Infinite Stamina')
gui:Label(settingsTab, settingsInfo, '- Max Clash Strength')
gui:Label(settingsTab, settingsInfo, '- Auto F Spam')
gui:Label(settingsTab, settingsInfo, '- Infinite XSaw Gas')
gui:Label(settingsTab, settingsInfo, '- Scrap Collector')
gui:Label(settingsTab, settingsInfo, '- Blueprint Unlocker')
gui:Label(settingsTab, settingsInfo, '- Quest Activator')
gui:Label(settingsTab, settingsInfo, '- 11 Teleport Locations')
gui:Label(settingsTab, settingsInfo, '- F1 Quick Teleport')
gui:Label(settingsTab, settingsInfo, '- Movable Watermark')

-- ═══════════════════ MAIN LOOP ═══════════════════

spawn(function()
    while true do
        state.stats.sessionTime = state.stats.sessionTime + 1
        wait(1)
    end
end)

spawn(function()
    local lastInsertState = false
    while true do
        local insertPressed = iskeypressed(0x2D)
        if insertPressed and not lastInsertState then
            gui:ToggleMenu(not gui:IsMenuOpen())
        end
        lastInsertState = insertPressed
        wait(0.05)
    end
end)

spawn(function()
    local lastF1State = false
    while true do
        local f1Pressed = iskeypressed(0x70)
        if f1Pressed and not lastF1State then
            teleportToLocation()
        end
        lastF1State = f1Pressed
        wait(0.05)
    end
end)

local running = true
while running do
    gui:Step()
    wait(0.0015)
end

gui:Destroy()

print("╔═══════════════════════════════════════════════════════════════╗")
print("║                                                               ║")
print("║      ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗                    ║")
print("║     ██╔════╝██║  ██║██╔══██╗██║████╗  ██║                    ║")
print("║     ██║     ███████║███████║██║██╔██╗ ██║                    ║")
print("║     ██║     ██╔══██║██╔══██║██║██║╚██╗██║                    ║")
print("║     ╚██████╗██║  ██║██║  ██║██║██║ ╚████║                    ║")
print("║      ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝                    ║")
print("║               ██████╗ ██╗   ██╗████████╗                     ║")
print("║               ██╔══██╗██║   ██║╚══██╔══╝                     ║")
print("║               ██████╔╝██║   ██║   ██║                        ║")
print("║               ██╔══██╗██║   ██║   ██║                        ║")
print("║               ██████╔╝╚██████╔╝   ██║                        ║")
print("║               ╚═════╝  ╚═════╝    ╚═╝                        ║")
print("║                ██████╗ ██████╗ ██████╗ ██╗                   ║")
print("║               ██╔═══██╗██╔══██╗██╔══██╗██║                   ║")
print("║               ██║   ██║██████╔╝██████╔╝██║                   ║")
print("║               ██║   ██║██╔══██╗██╔══██╗██║                   ║")
print("║               ╚██████╔╝██║  ██║██████╔╝██║                   ║")
print("║                ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝                   ║")
print("╠═══════════════════════════════════════════════════════════════╣")
print("║              X11 ULTRA EDITION v3.1 - LOADED                 ║")
print("╠═══════════════════════════════════════════════════════════════╣")
print("║  [CONTROLS]                                                   ║")
print("║    INSERT - Toggle GUI                                        ║")
print("║    F1     - Quick Teleport                                    ║")
print("║                                                               ║")
print("║  [NEW FEATURES]                                               ║")
print("║    ✓ F1 Quick Teleport Hotkey                                ║")
print("║    ✓ Watermark Toggle in Settings                            ║")
print("║    ✓ Movable Watermark (Drag & Drop)                         ║")
print("║                                                               ║")
print("║  [FEATURES]                                                   ║")
print("║    • Professional X11 UI System                               ║")
print("║    • Smooth Animations & Transitions                          ║")
print("║    • Watermark with Live Stats                                ║")
print("║    • 4 Organized Tabs                                         ║")
print("║    • Infinite Stamina                                         ║")
print("║    • Max Clash Strength                                       ║")
print("║    • Auto F Spam (Hold G)                                     ║")
print("║    • Infinite XSaw Gas                                        ║")
print("║    • Advanced Scrap Auto-Collector                            ║")
print("║    • Blueprint Unlocker                                       ║")
print("║    • Artifact Quest Activator                                 ║")
print("║    • 11 Teleport Locations                                    ║")
print("║                                                               ║")
print("║  Created by: ORBIIII                                          ║")
print("║  Version: 3.1 X11 ULTRA ENHANCED                              ║")
print("║  Status: FULLY OPERATIONAL                                    ║")
print("╚═══════════════════════════════════════════════════════════════╝")
print("")
print(">> X11 GUI LOADED! Press [INSERT] to open! Press [F1] to teleport! <<")
