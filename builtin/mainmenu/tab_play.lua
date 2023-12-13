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
local current_game, singleplayer_refresh_gamebar
local valid_disabled_settings = {
    ["enable_damage"] = true,
    ["creative_mode"] = true,
    ["enable_server"] = true
}

local editing_world_index = nil
local editing_world_creative = false
local editing_world_damage = false
local editing_world_server = false
local main_width = 19

-- Name and port stored to persist when updating the formspec
local current_name = core.settings:get("name")
local current_port = core.settings:get("port")

-- Currently chosen game in gamebar for theming and filtering
function current_game()
    local gameid = core.settings:get("menu_last_game")
    local game = gameid and pkgmgr.find_by_gameid(gameid)
    -- Fall back to first game installed if one exists.
    if not game and #pkgmgr.games > 0 then

        -- If devtest is the first game in the list and there is another
        -- game available, pick the other game instead.
        local picked_game
        if pkgmgr.games[1].id == "devtest" and #pkgmgr.games > 1 then
            picked_game = 2
        else
            picked_game = 1
        end

        game = pkgmgr.games[picked_game]
        gameid = game.id
        core.settings:set("menu_last_game", gameid)
    end

    return game
end

-- Apply menu changes from given game
function apply_game(game)
    core.settings:set("menu_last_game", game.id)
    menudata.worldlist:set_filtercriteria(game.id)

    mm_game_theme.set_game(game)

    local index = filterlist.get_current_index(menudata.worldlist,
        tonumber(core.settings:get("mainmenu_last_selected_world")))
    if not index or index < 1 then
        local selected = core.get_textlist_index("sp_worlds")
        if selected ~= nil and selected < #menudata.worldlist:get_list() then
            index = selected
        else
            index = #menudata.worldlist:get_list()
        end
    end
    menu_worldmt_legacy(index)
end

function singleplayer_refresh_gamebar()

    local old_bar = ui.find_by_name("game_button_bar")
    if old_bar ~= nil then
        old_bar:delete()
    end

    -- Hide gamebar if no games are installed
    if #pkgmgr.games == 0 then
        return false
    end

    local function game_buttonbar_button_handler(fields)
        for _, game in ipairs(pkgmgr.games) do
            if fields["game_btnbar_" .. game.id] then
                apply_game(game)
                return true
            end
        end
    end

    local btnbar = buttonbar_create("game_button_bar", TOUCHSCREEN_GUI and {
        x = 0,
        y = 7.25
    } or {
        x = 0,
        y = 7.475
    }, {
        x = 15.5,
        y = 1.25
    }, "#000000", game_buttonbar_button_handler)

    for _, game in ipairs(pkgmgr.games) do
        local btn_name = "game_btnbar_" .. game.id

        local image = nil
        local text = nil
        local tooltip = core.formspec_escape(game.title)

        if (game.menuicon_path or "") ~= "" then
            image = core.formspec_escape(game.menuicon_path)
        else
            local part1 = game.id:sub(1, 5)
            local part2 = game.id:sub(6, 10)
            local part3 = game.id:sub(11)

            text = part1 .. "\n" .. part2
            if part3 ~= "" then
                text = text .. "\n" .. part3
            end
        end
        btnbar:add_button(btn_name, text, image, tooltip)
    end

    local plus_image = core.formspec_escape(defaulttexturedir .. "plus.png")
    btnbar:add_button("game_open_cdb", "", plus_image, fgettext("Install games from ContentDB"))
    return true
end

local function get_disabled_settings(game)
    if not game then
        return {}
    end

    local gameconfig = Settings(game.path .. "/game.conf")
    local disabled_settings = {}
    if gameconfig then
        local disabled_settings_str = (gameconfig:get("disabled_settings") or ""):split()
        for _, value in pairs(disabled_settings_str) do
            local state = false
            value = value:trim()
            if string.sub(value, 1, 1) == "!" then
                state = true
                value = string.sub(value, 2)
            end
            if valid_disabled_settings[value] then
                disabled_settings[value] = state
            else
                core.log("error", "Invalid disabled setting in game.conf: " .. tostring(value))
            end
        end
    end
    return disabled_settings
end

local function create_list_formspec(x, y, height, width)
    local formspec = primary_btn_style("world_create") .. "button[.2,0;18.6,1.5;world_create;" .. fgettext("New") .. "]"
    formspec = formspec .. "scroll_container[" .. x .. "," .. y .. ";" .. width .. "," .. height ..
                   ";world_scroll;vertical;0.1]"

    -- Liste öğeleri (örnek olarak 5 satır)

    local current_worldlist = menudata.worldlist:get_list()

    local item_height = 1.5
    local index = 0
    for k, world in ipairs(current_worldlist) do
        local world_conf = Settings(world.path .. DIR_DELIM .. "world.mt")

        local is_creative = world_conf:get_bool("creative_mode")
        local is_god = world_conf:get_bool("enable_damage")
        local is_server_enabled = world_conf:get_bool("enable_server")
        local y_position = index * item_height

        local world_image = is_creative and "server_favorite.png" or "heart.png"
        local world_type_text = is_creative and fgettext("Creative") or fgettext("Survival")

        formspec = formspec .. btn_style("world_bg", "world_start" .. index, nil, 16)
        formspec = formspec .. "button[.2," .. y_position + .1 .. ";" .. width - 1.4 .. ",1.4;" .. "world_start" ..
                       index .. ";" .. "]"

        formspec = formspec .. "label[1.6," .. y_position + 0.6 .. ";" .. minetest.colorize("#000", world.name) .. "]"
        formspec =
            formspec .. "label[1.6," .. y_position + 1 .. ";" .. minetest.colorize("#00000090", world_type_text) .. "]"
        formspec = formspec .. "image[.6," .. y_position + 0.4 .. ";.75,.75;" .. defaulttexturedir .. world_image .. "]"
        local ui_index = index + 1

        local button_edit = primary_btn_style("world_edit_" .. index) .. "image_button[" .. width - 4.2 .. "," ..
                                y_position .. ";1.5,1.5;;world_edit_" .. index .. ";;false;false]" .. "image[" .. width -
                                4.2 + 0.25 .. "," .. y_position + 0.3 .. ";.9,.9;" .. defaultguitexturedir ..
                                "edit_button.png]"

        local button_delete = primary_btn_style("world_delete_" .. index, "red") .. "image_button[" .. width - 2.7 ..
                                  "," .. y_position .. ";1.5,1.5;;world_delete_" .. index .. ";;false;false]" ..
                                  "image[" .. width - 2.7 + 0.25 .. "," .. y_position + 0.3 .. ";.9,.9;" ..
                                  defaultguitexturedir .. "trash_bin.png]"
        if editing_world_index ~= ui_index then
            formspec = formspec .. button_edit
        end
        formspec = formspec .. button_delete

        index = index + 1
    end

    local total_y = #current_worldlist * item_height
    local ttt = scrollbar_style("world_scroll")
    local max = total_y / 0.1 - height / 0.1
    formspec = formspec .. "scroll_container_end[]scrollbaroptions[arrows=show;max=" .. max .. "]" .. ttt ..
    "scrollbar[" .. width - .8 .. ",1.6;.8," .. height - .1 .. ";vertical;world_scroll;0]"
    
    return formspec
end

local function get_edit_world_panel(x, y, height, width)
    if editing_world_index == nil then
        return ""
    end
    local game = current_game()

    local creative, damage, host = "", "", ""

    local height = 6.5
    local width = 5.5
    -- Y offsets for game settings checkboxes
    local local_y = 0.6
    local yo = 0.5625
    local world_name = core.formspec_escape(menudata.worldlist:get_raw_element(editing_world_index).name)
    local label = "style_type[label;font_size=16]label[0," .. local_y .. ";" .. fgettext("World Settings") .. "]";
    local_y = local_y + yo + .3 -- .3 for bigger font size

    local disabled_settings = get_disabled_settings(game_obj)

    if disabled_settings["creative_mode"] == nil then
        creative = "checkbox[0" .. "," .. local_y .. ";cb_creative_mode;" .. fgettext("Creative Mode") .. ";" ..
                       dump(editing_world_creative) .. "]"
        local_y = local_y + yo
    end
    if disabled_settings["enable_damage"] == nil then
        damage = "checkbox[0" .. "," .. local_y .. ";cb_enable_damage;" .. fgettext("Enable Damage") .. ";" ..
                     dump(editing_world_damage) .. "]"
        local_y = local_y + yo
    end
    if disabled_settings["enable_server"] == nil then
        host = "checkbox[0" .. "," .. local_y .. ";cb_server;" .. fgettext("Host Server") .. ";" ..
                   dump(editing_world_server) .. "]"
        local_y = local_y + yo
    end

    local host_server = ""

    local save_button = primary_btn_style("world_edit_save", "green") .. "button[" .. main_width - 6 .. "," .. 5.7 ..
                            ";" .. 5 .. ",1;world_edit_save;" .. fgettext("Save") .. "]" .. "image[" .. main_width - 5.7 ..
                            "," .. 5.9 .. ";.5,.5;" .. defaultguitexturedir .. "verified.png]"
    local cancel_button = primary_btn_style("world_edit_cancel", "red") .. "button[0" .. "," .. 5.7 .. ";" .. 5 ..
                              ",1;world_edit_cancel;" .. fgettext("Cancel") .. "]" .. "image[0.2," .. 5.9 .. ";.5,.5;" ..
                              defaultguitexturedir .. "wrong.png]"
    local world_edit_actions = save_button .. cancel_button

    if editing_world_server then
        local_y = 0.2
        host_server = host_server .. "container[" .. (19 / 3) .. ",0.4]" .. "checkbox[0," .. local_y ..
                          ";cb_server_announce;" .. fgettext("Announce Server") .. ";" ..
                          dump(core.settings:get_bool("server_announce")) .. "]"

        -- Reset y so that the text fields always start at the same position,
        -- regardless of whether some of the checkboxes are hidden.
        local_y = local_y + 0.9 * yo + 0.35

        host_server = host_server .. "field[0," .. local_y .. ";4.5,0.75;te_playername;" .. fgettext("Name") .. ";" ..
                          core.formspec_escape(current_name) .. "]"

        local_y = local_y + 1.15 + 0.25

        host_server = host_server .. "pwdfield[0," .. local_y .. ";4.5,0.75;te_passwd;" .. fgettext("Password") .. "]"

        local_y = local_y + 1.15 + 0.25

        local bind_addr = core.settings:get("bind_address")
        if bind_addr ~= nil and bind_addr ~= "" then
            host_server =
                host_server .. "field[0," .. local_y .. ";3,0.75;te_serveraddr;" .. fgettext("Bind Address") .. ";" ..
                    core.formspec_escape(core.settings:get("bind_address")) .. "]" .. "field[3.25," .. local_y ..
                    ";1.25,0.75;te_serverport;" .. fgettext("Port") .. ";" .. core.formspec_escape(current_port) .. "]"
        else
            host_server =
                host_server .. "field[0," .. local_y .. ";4.5,0.75;te_serverport;" .. fgettext("Server Port") .. ";" ..
                    core.formspec_escape(current_port) .. "]"
        end

        host_server = host_server .. "container_end[]"
    end

    return
        "container[" .. x - 0.5 .. ",0]" .. label .. creative .. damage .. host .. host_server .. world_edit_actions ..
            "container_end[]"
end

local function get_formspec(tabview, name, tabdata)
    -- Point the player to ContentDB when no games are found
    if #pkgmgr.games == 0 then
        return table.concat({"style[label_button;border=false]", "button[2.75,1.5;10,1;label_button;",
                             fgettext("You have no games installed."), "]", "button[5.25,3.5;5,1.2;game_open_cdb;",
                             fgettext("Install a game"), "]"})
    end

    local retval = background(0, 1.3, 20, 8)

    local panel_height = 5.46
    local panel_width = main_width - .4

    local world_list = create_list_formspec(.2, 1.6, panel_height, panel_width)
    local edit_world = get_edit_world_panel(1, 1.6, panel_height, panel_width)

    retval = retval .. "formspec_version[6]" .. "container[10.25,8]" .. primary_btn_style("world_configure") ..
                 "container_end[]"

    retval = retval .. "container[.5,1.85]" .. (editing_world_index == nil and world_list or edit_world) ..
                 "container_end[]"
    return retval
end

local function start_world(index)
    local selected = index
    gamedata.selected_world = menudata.worldlist:get_raw_index(selected)

    if selected == nil or gamedata.selected_world == 0 then
        gamedata.errormessage = fgettext_ne("No world created or selected!")
        return true
    end

    -- Update last game
    local world = menudata.worldlist:get_raw_element(gamedata.selected_world)
    local game_obj
    if world then
        game_obj = pkgmgr.find_by_gameid(world.gameid)
        core.settings:set("menu_last_game", game_obj.id)
    end

    local disabled_settings = get_disabled_settings(game_obj)
    for k, _ in pairs(valid_disabled_settings) do
        local v = disabled_settings[k]
        if v ~= nil then
            if k == "enable_server" and v == true then
                error("Setting 'enable_server' cannot be force-enabled! The game.conf needs to be fixed.")
            end
            core.settings:set_bool(k, disabled_settings[k])
        end
    end

    if core.settings:get_bool("enable_server") then
        gamedata.playername = fields["te_playername"]
        gamedata.password = fields["te_passwd"]
        gamedata.port = fields["te_serverport"]
        gamedata.address = ""

        core.settings:set("port", gamedata.port)
        if fields["te_serveraddr"] ~= nil then
            core.settings:set("bind_address", fields["te_serveraddr"])
        end
    else
        gamedata.singleplayer = true
    end

    core.start()
end

local function is_action(field, action)
    --  return true if action matches with the field.
    -- example field is world_create_44 and action is world_create
    return string.sub(field, 1, #action) == action
end

local function main_button_handler(this, fields, name, tabdata)

    assert(name == "play")

    if fields.game_open_cdb then
        local maintab = ui.find_by_name("maintab")
        local dlg = create_store_dlg("game")
        dlg:set_parent(maintab)
        maintab:hide()
        dlg:show()
        return true
    end

    if this.dlg_create_world_closed_at == nil then
        this.dlg_create_world_closed_at = 0
    end

    local world_doubleclick = false

    if fields["te_playername"] then
        current_name = fields["te_playername"]
    end

    if fields["te_serverport"] then
        current_port = fields["te_serverport"]
    end

    if fields["sp_worlds"] ~= nil then
        local event = core.explode_textlist_event(fields["sp_worlds"])
        local selected = core.get_textlist_index("sp_worlds")

        menu_worldmt_legacy(selected)

        if event.type == "DCL" then
            world_doubleclick = true
        end

        if event.type == "CHG" and selected ~= nil then
            core.settings:set("mainmenu_last_selected_world", menudata.worldlist:get_raw_index(selected))
            return true
        end
    end

    if menu_handle_key_up_down(fields, "sp_worlds", "mainmenu_last_selected_world") then
        return true
    end

    if fields["cb_creative_mode"] then
        editing_world_creative = not editing_world_creative
        return true
    end

    if fields["cb_enable_damage"] then
        editing_world_damage = not editing_world_damage
        return true
    end

    if fields["cb_server"] then
        editing_world_server = not editing_world_server

        return true
    end

    if fields["cb_server_announce"] then
        core.settings:set("server_announce", fields["cb_server_announce"])
        local selected = core.get_textlist_index("srv_worlds")
        menu_worldmt(selected, "server_announce", fields["cb_server_announce"])

        return true
    end

    if fields["play"] ~= nil or world_doubleclick or fields["key_enter"] then
        local enter_key_duration = core.get_us_time() - this.dlg_create_world_closed_at
        if world_doubleclick and enter_key_duration <= 200000 then -- 200 ms
            this.dlg_create_world_closed_at = 0
            return true
        end

        local selected = core.get_textlist_index("sp_worlds")
        start_world(selected)
        return true
    end

    if fields["world_create"] ~= nil then
        this.dlg_create_world_closed_at = 0
        local create_world_dlg = create_create_world_dlg()
        create_world_dlg:set_parent(this)
        this:hide()
        create_world_dlg:show()
        return true
    end

    if fields["world_delete"] ~= nil then
        local selected = core.get_textlist_index("sp_worlds")
        if selected ~= nil and selected <= menudata.worldlist:size() then
            local world = menudata.worldlist:get_list()[selected]
            if world ~= nil and world.name ~= nil and world.name ~= "" then
                local index = menudata.worldlist:get_raw_index(selected)
                local delete_world_dlg = create_delete_world_dlg(world.name, index)
                delete_world_dlg:set_parent(this)
                this:hide()
                delete_world_dlg:show()
            end
        end

        return true
    end

    if fields["world_configure"] ~= nil then
        local selected = core.get_textlist_index("sp_worlds")
        if selected ~= nil then
            local configdialog = create_configure_world_dlg(menudata.worldlist:get_raw_index(selected))

            if (configdialog ~= nil) then
                configdialog:set_parent(this)
                this:hide()
                configdialog:show()
            end
        end

        return true
    end

    if fields["world_edit_save"] then
        local world = menudata.worldlist:get_list()[editing_world_index]
        local world_conf = Settings(world.path .. DIR_DELIM .. "world.mt")
        world_conf:set_bool("creative_mode", editing_world_creative)
        world_conf:set_bool("enable_damage", editing_world_damage)
        world_conf:set_bool("enable_server", editing_world_server)
        world_conf:write()

        editing_world_index = nil

        editing_world_creative = nil
        editing_world_damage = nil
        editing_world_server = nil
        return true
    end

    if fields["world_edit_cancel"] then
        local edit_world_dlg = confirmbox("warning", fgettext("Are you sure you want to discard changes?"), function()
            editing_world_index = nil

            editing_world_creative = nil
            editing_world_damage = nil
            editing_world_server = nil
        end)
        edit_world_dlg:set_parent(this)
        this:hide()
        edit_world_dlg:show()

        return true
    end

    local item_handlers = {} -- Boş bir dizi oluşturun

    for field, value in pairs(fields) do
        -- continue if there is no number in field
        local has_number = string.find(field, "%d+$")
        if has_number then
            -- Get number after last underscore example world_create_44, world_delete_2, world_edit_31
            local world_number = tonumber(string.sub(field, string.find(field, "%d+$"))) + 1
            if is_action(field, 'world_start') then
                start_world(world_number)
                return true
            elseif is_action(field, 'world_delete') then
                local world = menudata.worldlist:get_list()[world_number]
                local raw_index = menudata.worldlist:get_raw_index(world_number)
                local edit_world_dlg = confirmbox("warning", fgettext("Delete World \"$1\"?", world.name), function()
                    core.delete_world(raw_index)
                    menudata.worldlist:refresh()
                end)
                edit_world_dlg:set_parent(this)
                this:hide()
                edit_world_dlg:show()

                return true
            elseif is_action(field, 'world_edit') then
                editing_world_index = world_number
                local world = menudata.worldlist:get_list()[world_number]
                local world_conf = Settings(world.path .. DIR_DELIM .. "world.mt")
                editing_world_creative = world_conf:get_bool("creative_mode")
                editing_world_damage = world_conf:get_bool("enable_damage")
                editing_world_server = world_conf:get_bool("enable_server")
                return true
            end
            return true
        end

    end
end

local function on_change(type)
    if type == "ENTER" then
        local game = current_game()
        if game then
            apply_game(game)
        else
            mm_game_theme.set_engine()
        end

        -- Hides bottom game selection
        --[[ if singleplayer_refresh_gamebar() then
			ui.find_by_name("game_button_bar"):show()
		end ]]
    elseif type == "LEAVE" then
        menudata.worldlist:set_filtercriteria(nil)
        local gamebar = ui.find_by_name("game_button_bar")
        if gamebar then
            gamebar:hide()
        end
    end
end

--------------------------------------------------------------------------------
return {
    name = "play",
    caption = fgettext("Worlds"),
    cbf_formspec = get_formspec,
    cbf_button_handler = main_button_handler,
    on_change = on_change
}
