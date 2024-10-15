local HttpService = game:GetService('HttpService')

local ThemeManager = {}
ThemeManager.Folder = 'LinoriaLibSettings'
-- if not isfolder(ThemeManager.Folder) then makefolder(ThemeManager.Folder) end

ThemeManager.Library = nil
ThemeManager.BuiltInThemes = {
	['Default']       = { 1, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
	['BBot']          = { 2, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
	['Fatality']      = { 3, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}') },
	['Jester']        = { 4, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
	['Mint']          = { 5, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
	['Tokyo Night']   = { 6, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BackgroundColor":"141414","OutlineColor":"323232"}') },
	['Ubuntu']        = { 7, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}') },
	['Quartz']        = { 8, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
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
	for _, field in next, options do
		if Options and Options[field] then
			self.Library[field] = Options[field].Value
		end
	end

	self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor)
	self.Library:UpdateColorsUsingRegistry()
end

function ThemeManager:LoadDefault()		
	local theme = 'Default'
	local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

	if content and self.BuiltInThemes[content] then
		theme = content
	end

	Options.ThemeManager_ThemeList:SetValue(theme)
	self:ApplyTheme(theme)
end

function ThemeManager:CreateThemeManager(groupbox)
	groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor })
	groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor })
	groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor })
	groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor })
	groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor })

	local ThemesArray = {}
	for Name, Theme in next, self.BuiltInThemes do
		table.insert(ThemesArray, Name)
	end

	table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

	groupbox:AddDivider()
	groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })

	groupbox:AddButton('Set as default', function()
		writefile(self.Folder .. '/themes/default.txt', Options.ThemeManager_ThemeList.Value)
		self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value))
	end)

	Options.ThemeManager_ThemeList:OnChanged(function()
		self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
	end)

	groupbox:AddDivider()
	ThemeManager:LoadDefault()

	local function UpdateTheme()
		self:ThemeUpdate()
	end

	Options.BackgroundColor:OnChanged(UpdateTheme)
	Options.MainColor:OnChanged(UpdateTheme)
	Options.AccentColor:OnChanged(UpdateTheme)
	Options.OutlineColor:OnChanged(UpdateTheme)
	Options.FontColor:OnChanged(UpdateTheme)
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

	for _, str in ipairs(paths) do
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

function ThemeManager:ApplyToGroupbox(groupbox)
	assert(self.Library, 'Must set ThemeManager.Library first!')
	self:CreateThemeManager(groupbox)
end

ThemeManager:BuildFolderTree()

return ThemeManager
