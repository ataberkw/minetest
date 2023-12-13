-- Minetest
-- Copyright (C) 2014 sapier
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
mt_color_grey = "#AAAAAA"
mt_color_blue = "#6389FF"
mt_color_lightblue = "#99CCFF"
mt_color_green = "#72FF63"
mt_color_dark_green = "#25C191"
mt_color_orange = "#FF8800"
mt_color_red = "#FF3300"

PRIMARY_TEXT_COLOR = "#181425"
PRIMARY_COLOR = "#272B44"
NEGATIVE_COLOR = "#FF0144"
POSITIVE_COLOR = "#39AA48"

local menupath = core.get_mainmenu_path()
local basepath = core.get_builtin_path()
defaulttexturedir = core.get_texturepath_share() .. DIR_DELIM .. "base" .. DIR_DELIM .. "pack" .. DIR_DELIM
defaultguitexturedir =
    core.get_texturepath_share() .. DIR_DELIM .. "base" .. DIR_DELIM .. "pack" .. DIR_DELIM .. "gui" .. DIR_DELIM

dofile(menupath .. DIR_DELIM .. "misc.lua")

dofile(basepath .. "common" .. DIR_DELIM .. "styles.lua")
dofile(basepath .. "common" .. DIR_DELIM .. "filterlist.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "buttonbar.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "dialog.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "tabview.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "tabview2.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "ui.lua")
dofile(menupath .. DIR_DELIM .. "async_event.lua")
dofile(menupath .. DIR_DELIM .. "common.lua")
dofile(menupath .. DIR_DELIM .. "serverlistmgr.lua")
dofile(menupath .. DIR_DELIM .. "game_theme.lua")
dofile(menupath .. DIR_DELIM .. "content" .. DIR_DELIM .. "init.lua")

dofile(menupath .. DIR_DELIM .. "dlg_config_world.lua")
dofile(menupath .. DIR_DELIM .. "settings" .. DIR_DELIM .. "init.lua")
dofile(menupath .. DIR_DELIM .. "dlg_create_world.lua")
dofile(menupath .. DIR_DELIM .. "dlg_delete_content.lua")
dofile(menupath .. DIR_DELIM .. "dlg_delete_world.lua")
dofile(menupath .. DIR_DELIM .. "dlg_register.lua")
dofile(menupath .. DIR_DELIM .. "dlg_rename_modpack.lua")
dofile(menupath .. DIR_DELIM .. "dlg_version_info.lua")
dofile(menupath .. DIR_DELIM .. "dlg_reinstall_mtg.lua")

local tabs = {
    content = dofile(menupath .. DIR_DELIM .. "tab_content.lua"),
    about = dofile(menupath .. DIR_DELIM .. "tab_about.lua"),
    local_game = dofile(menupath .. DIR_DELIM .. "tab_local.lua"),
    play_online = dofile(menupath .. DIR_DELIM .. "tab_online.lua"),
    play = dofile(menupath .. DIR_DELIM .. "tab_play.lua")
}

--------------------------------------------------------------------------------
local function main_event_handler(tabview, event)
    if event == "MenuQuit" then
        core.close()
    end
    return true
end

--------------------------------------------------------------------------------
local function toggle_tabs()
    local tv_main = ui.find_by_name("maintab")
    local init_dialog = ui.find_by_name("init_dialog")
    if tv_main.hidden then
        tv_main:show()
        init_dialog:hide()
    else
        ui.set_default("maintab")
        tv_main:hide()
        init_dialog:show()
    end
end

local function create_about_dlg()
    local dlg = dialog_create("dlg_about", function(tabview, name, tabdata)
        return "size[15.5,7.1]" .. tabs.about.cbf_formspec(tabview, name, tabdata) .. "button[11,6;4.5,1.1;btn_close_about;" .. fgettext("Back") .. "]"
    end, tabs.about.cbf_button_handler, tabs.about.on_change)

    return dlg
end

--------------------------------------------------------------------------------
local function handle_buttons(this, fields)
    if fields["btn_play"] ~= nil then
        toggle_tabs()
        return true
    end

    if fields["btn_settings"] ~= nil then
        local dlg = create_settings_dlg()
        dlg:set_parent(this)
        this:hide()
        dlg:show()
        return true
    end

    if fields["btn_about"] ~= nil then
        local dlg = create_about_dlg()
        dlg:set_parent(this)
        this:hide()
        dlg:show()
        return true
    end

    return false
end

--------------------------------------------------------------------------------
local function init_globals()
    -- Init gamedata
    gamedata.worldindex = 0

    menudata.worldlist = filterlist.create(core.get_worlds, compare_worlds, -- Unique id comparison function
    function(element, uid)
        return element.name == uid
    end, -- Filter function
    function(element, gameid)
        return element.gameid == gameid
    end)

    menudata.worldlist:add_sort_mechanism("alphabetic", sort_worlds_alphabetic)
    menudata.worldlist:set_sortmode("alphabetic")

    mm_game_theme.init()
    mm_game_theme.set_engine() -- This is just a fallback.
    -- Create main tabview
    local tv_main = tabview_create("maintab", {
        x = 20,
        y = 10
    }, {
        x = 0,
        y = 0
    })

    tv_main:set_autosave_tab(true)
    tv_main:add(tabs.play)
    -- tv_main:add(tabs.local_game)
    tv_main:add(tabs.play_online)
    --[[tv_main:add(tabs.content)
    tv_main:add(tabs.about) ]]

    tv_main:set_global_event_handler(main_event_handler)
    tv_main:set_fixed_size(false)

    local last_tab = core.settings:get("maintab_LAST")
    if last_tab and tv_main.current_tab ~= last_tab then
        tv_main:set_tab(last_tab)
    end

    tv_main:set_end_button({
        icon = defaultguitexturedir .. "gui_close.png",
        label = fgettext("Settings"),
        name = "open_settings",
        on_click = function(tabview)
            toggle_tabs()
            return true
        end
    })

    -- tv_main:hide_tab_header()

    -- We init here to run game. Else, we needed to move game initializing to here.
    -- Didn't wanna change the code that much.
    ui.set_default("maintab")
    tv_main:show()
    ui.update()

    local main_dialog = dialog_create('init_dialog', function()
        return ([[
            formspec_version[3]
            size[20,10]
            bgcolor[;neither;]
            %s
            button[7,4;6,1.5;btn_play;%s]
            %s
            button[7,6;6,1.5;btn_settings;%s]
            %s
            button[15.5,8.3;4.5,1.1;btn_about;© %s]
        ]]):format(primary_btn_style("btn_play"), fgettext("Play"), primary_btn_style("btn_settings"),
            fgettext("Settings"), primary_btn_style("btn_about"), fgettext("About"))
    end, handle_buttons, nil);

    ui.set_default("init_dialog")
    main_dialog:show()
    tv_main:hide()
    ui.update()
    check_reinstall_mtg()
    --[[ check_new_version() ]]
end
init_globals()
