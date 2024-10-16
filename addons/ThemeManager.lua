local httpService = game:GetService('HttpService')

local ThemeManager = {} do
    ThemeManager.Folder = 'LinoriaLibSettings'
    -- if not isfolder(ThemeManager.Folder) then makefolder(ThemeManager.Folder) end

    ThemeManager.Library = nil
    ThemeManager.CurrentThemeIndex = 1  -- Keep track of the current theme index
    ThemeManager.DefaultTheme = 'Mint'   -- Set the new 'Mint' theme as the default
    ThemeManager.BuiltInThemes = {
        ['Hey']             = { 1, httpService:JSONDecode('{"FontColor":"c1c1c1","MainColor":"050505","AccentColor":"bd00ff","BackgroundColor":"131313","OutlineColor":"3f3b3b"}') }, -- New theme
        ['Default']         = { 2, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
        ['BBot']            = { 3, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
        ['Fatality']        = { 4, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}') },
        ['Jester']          = { 5, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
        ['Mint']            = { 6, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
        ['Tokyo Night']     = { 7, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BackgroundColor":"141414","OutlineColor":"323232"}') },
        ['Ubuntu']          = { 8, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}') },
        ['Quartz']          = { 9, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
        ['Clean']           = { 10, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232323","AccentColor":"ffffff","BackgroundColor":"232323","OutlineColor":"232323"}') }, -- New "Clean" theme
    }

    function ThemeManager:ApplyTheme(theme)
        local data = self.BuiltInThemes[theme]

        if not data then return end

        local scheme = data[2]
        for idx, col in next, scheme do
            self.Library[idx] = Color3.fromHex(col)
            
            if Options[idx] then
                Options[idx]:SetValueRGB(Color3.fromHex(col))
            end
        end

        self:ThemeUpdate()
    end

    function ThemeManager:ThemeUpdate()
        local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
        for i, field in next, options do
            if Options and Options[field] then
                self.Library[field] = Options[field].Value
            end
        end

        self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
        self.Library:UpdateColorsUsingRegistry()
    end

    function ThemeManager:LoadDefault()		
        local theme = self.DefaultTheme
        local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

        local isDefault = true
        if content then
            if self.BuiltInThemes[content] then
                theme = content
            end
        elseif self.BuiltInThemes[self.DefaultTheme] then
            theme = self.DefaultTheme
        end

        if isDefault then
            Options.ThemeManager_ThemeList:SetValue(theme)
        else
            self:ApplyTheme(theme)
        end
    end

    function ThemeManager:SaveDefault(theme)
        writefile(self.Folder .. '/themes/default.txt', theme)
    end

    function ThemeManager:CreateThemeManager(groupbox)
        groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
        groupbox:AddLabel('Main color'):AddColorPicker('MainColor', { Default = self.Library.MainColor });
        groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
        groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
        groupbox:AddLabel('Font color'):AddColorPicker('FontColor', { Default = self.Library.FontColor });

        local ThemesArray = {}
        for Name, Theme in next, self.BuiltInThemes do
            table.insert(ThemesArray, Name)
        end

        table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

        groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })

        groupbox:AddButton('Set as default', function()
            self:SaveDefault(Options.ThemeManager_ThemeList.Value)
            self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value))
        end)

        Options.ThemeManager_ThemeList:OnChanged(function()
            self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
        end)

        ThemeManager:LoadDefault()

        local function UpdateTheme()
            self:ThemeUpdate()
        end

        Options.BackgroundColor:OnChanged(UpdateTheme)
        Options.MainColor:OnChanged(UpdateTheme)
        Options.AccentColor:OnChanged(UpdateTheme)
        Options.OutlineColor:OnChanged(UpdateTheme)
        Options.FontColor:OnChanged(UpdateTheme)

        -- Create Next and Previous buttons
        groupbox:AddButton('Previous Theme', function()
            self.CurrentThemeIndex = (self.CurrentThemeIndex - 1) < 1 and #ThemesArray or (self.CurrentThemeIndex - 1)
            local previousTheme = ThemesArray[self.CurrentThemeIndex]
            Options.ThemeManager_ThemeList:SetValue(previousTheme)
            self:ApplyTheme(previousTheme)
        end)

        groupbox:AddButton('Next Theme', function()
            self.CurrentThemeIndex = (self.CurrentThemeIndex + 1) > #ThemesArray and 1 or (self.CurrentThemeIndex + 1)
            local nextTheme = ThemesArray[self.CurrentThemeIndex]
            Options.ThemeManager_ThemeList:SetValue(nextTheme)
            self:ApplyTheme(nextTheme)
        end)

        -- Custom cursor management
        local cursor = Instance.new("ImageLabel")
        cursor.Size = UDim2.new(0, 32, 0, 32)  -- Set cursor size
        cursor.Image = "rbxassetid://872415672"  -- Replace with your custom cursor image ID
        cursor.Visible = false  -- Initially set the cursor to be invisible
        cursor.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")  -- Parent the cursor to PlayerGui

        -- Function to show/hide the cursor
        local function ToggleCursorVisibility(show)
            cursor.Visible = show
            if show then
                cursor.Position = UDim2.new(0, mouse.X, 0, mouse.Y)  -- Set cursor position to mouse position
            end
        end

        -- Connect the GUI open/close events to toggle cursor visibility
        -- Example of how to connect it to your GUI events:
        -- GUIOpened:Connect(function() ToggleCursorVisibility(true) end)
        -- GUIClose:Connect(function() ToggleCursorVisibility(false) end)

    end

    function ThemeManager:SetLibrary(lib)
        self.Library = lib
    end

    function ThemeManager:BuildFolderTree()
        local paths = {}

        local parts = self.Folder:split('/')
        for idx = 1, #parts do
            paths[#paths + 1] = table.concat(parts, '/', 1, idx)
        end

        table.insert(paths, self.Folder .. '/themes')
        table.insert(paths, self.Folder .. '/settings')

        for i = 1, #paths do
            local str = paths[i]
            if not isfolder(str) then
                makefolder(str)
            end
        end
    end

    function ThemeManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function ThemeManager:CreateGroupBox(tab)
        assert(self.Library, 'Must set ThemeManager.Library first!')
        return tab:AddLeftGroupbox('Themes')
    end

    function ThemeManager:ApplyToTab(tab)
        assert(self.Library, 'Must set ThemeManager.Library first!')

        local groupbox = self:CreateGroupBox(tab)
        self:CreateThemeManager(groupbox)
    end
end

return ThemeManager
