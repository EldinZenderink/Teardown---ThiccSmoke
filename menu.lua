-- menu.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Menu generator  {Module}_GetOptionsMenu()

#include "ui.lua"

local _Menu_Toggle_Key_Default = "u"
local _Menu_Toggle_Key = "u"
local _Menu_UI = false
local _Menu_List = {}
local _Menu_MenuActive = 1
local _Menu_SubMenuActive = 1

function Menu_Init(default)
    if default then
        Menu_DefaultSettings()
    else
        Menu_UpdateFromStorage()
    end
    _Menu_UI = false
end

function Menu_AppendMenu(menu)
    table.insert(_Menu_List, menu)
end

function Menu_DefaultSettings()
    _Menu_Toggle_Key = _Menu_Toggle_Key_Default
    DebugPrinter("Menu key default: " .. _Menu_Toggle_Key_Default)
end

function Menu_UpdateFromStorage()
    _Menu_Toggle_Key = GeneralOptions_GetToggleMenuKey()
    DebugPrinter("Menu key stored: " .. _Menu_Toggle_Key_Default)
end

function Menu_GenerateSubMenuOptions(title, options, x, y)
    UiPush()
	    UiTranslate(x, y)
        UiFont("regular.ttf", 44)
        UiText(title)
        UiTranslate(0, 66)

        local module = options["storage_module"]
        local key_prefix = options["storage_prefix_key"]
        -- DebugPrinter("Generate option menu for sub menu " .. title .. " or module " .. module .. " with prefix key " .. key_prefix)
        local count = 1
        local update = false
        for o=1, #options["option_items"] do
            local option = options["option_items"][o]
            local key = option["storage_key"]
            if key_prefix ~= nil then
                key = key_prefix .. "." .. key
            end
            -- DebugPrinter("Generate option item: " .. option["option_type"])
            if option["option_type"] == "text" then
                update = Ui_StringProperty(0 , 44 * (o - 1), option["option_text"], option["option_note"], option["options"], module, key)
            elseif option["option_type"] == "input_key" then
                update = Ui_KeySelector(0 , 44 * (o - 1), option["option_text"], option["option_note"], module, key)
            elseif option["option_type"] == "float" then
                update = Ui_FloatProperty(0, 44 * (o - 1), option["option_text"], option["option_note"], option["min_max"], module, key)
            elseif option["option_type"] == "int" then
                update = Ui_IntProperty(0, 44 * (o - 1), option["option_text"], option["option_note"], option["min_max"], module, key)
            end
            count = o
            if update then
                DebugPrinter("Called update for sub menu " .. title )
                options["update"]()
            end
        end

        if UI_Button(0, 44 * (count ) + 44, "Set to Default") then
            options["default"]()
            DebugPrinter("Called setting to default for sub menu " .. title )
        end
    UiPop()
end

function Menu_GenerateSubMenu(title, submenus, x, y)
    UiPush()
	    UiTranslate(x, y)
        UiFont("regular.ttf", 44)
        UiText(title)
        UiTranslate(0, 66)
        -- Every menu item contains a list of different menus
        -- The menu will be broken in a left section, containing the top level menu buttons
        -- Then the following section will show whatever menu is clicked on in the first section, showing
        -- the list of all available sub menus, which can be clicked on the show the options in that menu
        -- on the most right side. If no sub_menu_title is available, the second section will be used to show
        -- the same.

        local submenu = submenus[_Menu_SubMenuActive]
        for i=1, #submenus do
            submenu = submenus[i]
            if UI_ToggleButton(0, 24 * (i - 1), submenu["sub_menu_title"], 2, i) then
                -- DebugPrinter("Generate option menu for " .. submenu["sub_menu_title"])
                _Menu_SubMenuActive = i
                -- break
            end
        end
        if _Menu_MenuActive > #submenus then
            _Menu_MenuActive = 1
        end
    UiPop()
	-- UiTranslate(-x, -y)
end

function Menu_GenerateMenu()
    -- Setup UI
    UiFont("regular.ttf", 44)
    UiTranslate(66, 100)
    UiText("ThiccSmoke Settings")
    UiFont("regular.ttf", 22)
    -- Every menu item contains a list of different menus
    -- The menu will be broken in a left section, containing the top level menu buttons
    -- Then the following section will show whatever menu is clicked on in the first section, showing
    -- the list of all available sub menus, which can be clicked on the show the options in that menu
    -- on the most right side. If no sub_menu_title is available, the second section will be used to show
    -- the same.
    UiTranslate(0, 66)
    UiPush()
    for i=1, #_Menu_List do
        local menu_item = _Menu_List[i]
        if UI_ToggleButton(0, 24 * (i - 1), menu_item["menu_title"], 1, i) then
            -- DebugPrinter("Generate submenu  for " .. menu_item["menu_title"])
            _Menu_MenuActive = i
            -- break
        end
    end
    UiPop()

    local menu = _Menu_List[_Menu_MenuActive]
    if menu ~= nil then
        Menu_GenerateSubMenu(menu["menu_title"], menu["sub_menus"], 400, -66)
        local submenu = menu["sub_menus"][_Menu_SubMenuActive]
        if menu ~= nil and submenu ~= nil then
            Menu_GenerateSubMenuOptions(submenu["sub_menu_title"], submenu["options"], 800, -66)
        end
    end
end

function Menu_GenerateGameMenu()

    -- DebugPrinter("Toggle menu button: " .. GeneralOptions_GetToggleMenuKey())
    if InputPressed(GeneralOptions_GetToggleMenuKey()) then
		_Menu_UI = not _Menu_UI
		Debug_ClearDebugPrinter()
        DebugPrinter("Toggle menu button clicked")
	end

    if _Menu_UI then
        -- Make ui clickable.
        UiMakeInteractive()

        UiColor(0, 0, 0, 0.5)
        UiRect(UiWidth(), UiHeight())
        UiColor(1, 1, 1)


        UiTranslate(UiWidth() - 200, 66)
        UiTextShadow(0, 0, 0, 0.5, 0.5)
        UiFont("regular.ttf", 22)
        UiText("Press "  .. GeneralOptions_GetToggleMenuKey() .. " to hide!")
        UiTranslate(-UiWidth() + 200, -66)

        Menu_GenerateMenu()
    else
        if GeneralOptions_GetShowUiInGame() == "YES" then
            UiTranslate(UiWidth() - 300, 66)
            UiTextShadow(0, 0, 0, 0.5, 0.5)
            UiFont("regular.ttf", 22)
            UiText("Press "  .. GeneralOptions_GetToggleMenuKey() .. " to show menu!")
            UiTranslate(0, 33)
            UiText("Press "  .. GeneralOptions_GetToggleModKey() .. " to disable or enable!")
            UiTranslate(-UiWidth() + 300, -66)
        end
    end
end