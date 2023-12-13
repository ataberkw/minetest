--Minetest
--Copyright (C) 2013 sapier
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU Lesser General Public License as published by
--the Free Software Foundation; either version 2.1 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Lesser General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

-- https://github.com/orgs/minetest/teams/engine/members

local core_developers = {
	"Perttu Ahola (celeron55) <celeron55@gmail.com> [Project founder]",
	"sfan5 <sfan5@live.de>",
	"ShadowNinja <shadowninja@minetest.net>",
	"Nathanaëlle Courant (Nore/Ekdohibs) <nore@mesecons.net>",
	"Loic Blot (nerzhul/nrz) <loic.blot@unix-experience.fr>",
	"Andrew Ward (rubenwardy) <rw@rubenwardy.com>",
	"Krock/SmallJoker <mk939@ymail.com>",
	"Lars Hofhansl <larsh@apache.org>",
	"v-rob <robinsonvincent89@gmail.com>",
	"Desour/DS",
	"srifqi",
	"Gregor Parzefall (grorp)",
}



local about_finecraft_game = {
	"Finecraft is an ultimate block craft & survival game with exciting server play",
	"",
	"The name comes from the game having a Fine Crafting Mechanism. So that's why it's called Finecraft.",
}

local logo_disclaimer = {
	"Logo is created by font generator called TextStudio",
	"=> https://www.textstudio.com/license",
}

local finecraft_disclaimer = {
	"Finecraft is a fork of Minetest, a free and open source infinite-world block sandbox game engine with support for survival and crafting.",
	"=> https://github.com/minetest/minetest/blob/master/LICENSE.txt",
	"Finecraft uses Mineclone2 as the game that is bundled with Minetest.",
	"=> https://git.minetest.land/MineClone2/MineClone2/src/branch/master/LICENSE.txt",
	"",
	"Both Minetest and Mineclone2 are modified to provide a better user experience. ",
	"",
	"No non-free licenses are used anywhere.",
	"The textures, unless otherwise noted, are based on the Pixel Perfection resource pack for Minecraft 1.11, authored by XSSheep. Most textures are verbatim copies, while some textures have been changed or redone from scratch. The glazed terracotta textures have been created by MysticTempest. Source: https://www.planetminecraft.com/texture_pack/131pixel-perfection/ License: CC BY-SA 4.0",
	"Armor trim models were created by Aeonix_Aeon Source: https://www.curseforge.com/minecraft/texture-packs/ozocraft-remix License: CC BY 4.0",
	"The main menu images are released under: CC0",
	"All other files, unless mentioned otherwise, fall under: Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0) http://creativecommons.org/licenses/by-sa/3.0/",
	"",
	"Every labor is listed below. Thanks for their amazing work!",
}

-- currently only https://github.com/orgs/minetest/teams/triagers/members

local core_team = {
	"Zughy [Issue triager]",
	"wsor [Issue triager]",
	"Hugo Locurcio (Calinou) [Issue triager]",
}

-- For updating active/previous contributors, see the script in ./util/gather_git_credits.py

local active_contributors = {
	"Wuzzy [Features, translations, documentation]",
	"numzero [Optimizations, work on OpenGL driver]",
	"ROllerozxa [Bugfixes, Mainmenu]",
	"Lars Müller [Bugfixes]",
	"AFCMS [Documentation]",
	"savilli [Bugfixes]",
	"fluxionary [Bugfixes]",
	"Bradley Pierce (Thresher) [Documentation]",
	"Stvk imension [Android]",
	"JosiahWI [Code cleanups]",
	"OgelGames [UI, Bugfixes]",
	"ndren [Bugfixes]",
	"Abdou-31 [Documentation]",
}

local previous_core_developers = {
	"BlockMen",
	"Maciej Kasatkin (RealBadAngel) [RIP]",
	"Lisa Milne (darkrose) <lisa@ltmnet.com>",
	"proller",
	"Ilya Zhuravlev (xyz) <xyz@minetest.net>",
	"PilzAdam <pilzadam@minetest.net>",
	"est31 <MTest31@outlook.com>",
	"kahrl <kahrl@gmx.net>",
	"Ryan Kwolek (kwolekr) <kwolekr@minetest.net>",
	"sapier",
	"Zeno",
	"Auke Kok (sofar) <sofar@foo-projects.org>",
	"Aaron Suen <warr1024@gmail.com>",
	"paramat",
	"Pierre-Yves Rollo <dev@pyrollo.com>",
	"hecks",
	"Jude Melton-Houghton (TurkeyMcMac) [RIP]",
	"Hugues Ross <hugues.ross@gmail.com>",
	"Dmitry Kostenko (x2048) <codeforsmile@gmail.com>",
}

local previous_contributors = {
	"Nils Dagsson Moskopp (erlehmann) <nils@dieweltistgarnichtso.net> [Minetest logo]",
	"red-001 <red-001@outlook.ie>",
	"Giuseppe Bilotta",
	"HybridDog",
	"ClobberXD",
	"Dániel Juhász (juhdanad) <juhdanad@gmail.com>",
	"MirceaKitsune <mirceakitsune@gmail.com>",
	"Jean-Patrick Guerrero (kilbith)",
	"MoNTE48",
	"Constantin Wenger (SpeedProg)",
	"Ciaran Gultnieks (CiaranG)",
	"Paul Ouellette (pauloue)",
	"stujones11",
	"Rogier <rogier777@gmail.com>",
	"Gregory Currie (gregorycu)",
	"JacobF",
	"Jeija <jeija@mesecons.net>",
}

-- Mineclone credits:

local creators = {
    "Creator of MineClone:",
	"davedevils",
    "Creator of MineClone2:",
	"Wuzzy",
}

local maintainers = {
    "Current Maintainers:",
    "AncientMariner",
    "Nicu",
    "Previous Maintainers:",
    "Fleckenstein",
    "cora",
}

local developers = {
    "Developers:",
	"AFCMS",
	"epCode",
	"chmodsayshello",
	"PrairieWind",
	"MrRar",
	"FossFanatic",
	"SmokeyDope",
    "Past Developers:",
	"jordan4ibanez",
	"iliekprogrammar",
	"kabou",
	"kay27",
	"Faerraven / Michieal",
	"MysticTempest",
	"NO11",
	"SumianVoice",
	
}

local contributors = {
    "Contributors:",
	"RandomLegoBrick",
	"rudzik8",
	"Code-Sploit",
	"aligator",
	"Rootyjr",
	"ryvnf",
	"bzoss",
	"talamh",
	"Laurent Rocher",
	"HimbeerserverDE",
	"TechDudie",
	"Alexander Minges",
	"ArTee3",
	"ZeDique la Ruleta",
	"pitchum",
	"wuniversales",
	"Bu-Gee",
	"David McMackins II",
	"Nicholas Niro",
	"Wouters Dorian",
	"Blue Blancmange",
	"Jared Moody",
	"Li0n",
	"Midgard",
	"Saku Laesvuori",
	"Yukitty",
	"ZedekThePD",
	"aldum",
	"dBeans",
	"nickolas360",
	"yutyo",
	"Tianyang Zhang",
	"j45",
	"Marcin Serwin",
	"erlehmann",
	"E",
	"n_to",
	"debiankaios",
	"Gustavo6046 / wallabra",
	"CableGuy67",
	"Benjamin Schötz",
	"Doloment",
	"Sydney Gems",
	"Emily2255",
	"Emojigit",
	"FinishedFragment",
	"sfan5",
	"Blue Blancmange",
	"Jared Moody",
	"SmallJoker",
	"Sven792",
	"aldum",
	"Dieter44",
	"Pepebotella",
	"Lazerbeak12345",
	"mrminer",
	"Thunder1035",
	"opfromthestart",
	"snowyu",
	"FaceDeer",
	"Herbert West",
	"GuyLiner",
	"3raven",
	"anarquimico",
	"TheOnlyJoeEnderman",
	"Ranko Saotome",
	"Gregor Parzefall",
	"Wbjitscool",
	"b3nderman",
	"CyberMango",
	"gldrk",
	"atomdmac",
	"emptyshore",
	"FlamingRCCars",
	"uqers",
	"Niterux",
	"appgurueu",
	"seventeenthShulker",
}

local music_contributors = {
    "Music Contributors:",
	"Jordach for the jukebox music compilation from Big Freaking Dig",
	"Dark Reaven Music (https://soundcloud.com/dark-reaven-music) for the main menu theme (Calmed Cube) and Traitor (horizonchris96), which is licensed under https://creativecommons.org/licenses/by-sa/3.0/",
	"Jester for helping to finely tune MineClone2 (https://www.youtube.com/@Jester-8-bit). Songs: Hailing Forest, Gift, 0dd BL0ck, Flock of One (License CC BY-SA 4.0)",
	"Exhale & Tim Unwin for some wonderful MineClone2 tracks (https://www.youtube.com/channel/UClFo_JDWoG4NGrPQY0JPD_g). Songs: Valley of Ghosts, Lonely Blossom, Farmer (License CC BY-SA 4.0)",
	"Diminixed for 3 fantastic tracks and remastering and leveling volumes. Songs: Afternoon Lullaby (pianowtune02), Spooled (ambientwip02), Never Grow Up (License CC BY-SA 4.0)",
}

local mod_authors = {
    "Original Mod Authors:",
	"Wuzzy",
	"Fleckenstein",
	"BlockMen",
	"TenPlus1",
	"PilzAdam",
	"ryvnf",
	"stujones11",
	"Arcelmi",
	"celeron55",
	"maikerumine",
	"GunshipPenguin",
	"Qwertymine3",
	"Rochambeau",
	"rubenwardy",
	"stu",
	"4aiman",
	"Kahrl",
	"Krock",
	"UgnilJoZ",
	"lordfingle",
	"22i",
	"bzoss",
	"kilbith",
	"xeranas",
	"kddekadenz",
	"sofar",
	"4Evergreen4",
	"jordan4ibanez",
	"paramat",
	"debian044 / debian44",
	"chmodsayshello",
	"cora",
	"Faerraven / Michieal",
	"PrairieWind",
}

local model_artists = {
    "3D Models:",
	"22i",
	"tobyplowy",
	"epCode",
	"Faerraven / Michieal",
	"SumianVoice",
}

local texture_artists = {
    "Textures:",
	"XSSheep",
	"Wuzzy",
	"kingoscargames",
	"leorockway",
	"xMrVizzy",
	"yutyo",
	"NO11",
	"kay27",
	"MysticTempest",
	"RandomLegoBrick",
	"cora",
	"Faerraven / Michieal",
	"Nicu",
	"Exhale",
	"Aeonix_Aeon",
	"Wbjitscool",
	"SmokeyDope",
}

local translators = {
    "Translators:",
	"Wuzzy",
	"Rocher Laurent",
	"wuniversales",
	"kay27",
	"pitchum",
	"todoporlalibertad",
	"Marcin Serwin",
	"Pepebotella",
	"Emojigit",
	"snowyu",
	"3raven",
	"SakuraRiu",
	"anarquimico",
	"syl",
	"Temak",
	"megustanlosfrijoles",
	"kbundgaard",
}

local funders = {
    "Funders:",
    "40W",
    "bauknecht",
    "Cora",
}

local special_thanks = {
    "Special Thanks:",
	"The Minetest team for making and supporting an engine, and distribution infrastructure that makes this all possible",
	"The workaholics who spent way too much time writing for the Minecraft Wiki. It's an invaluable resource for creating this game",
	"Notch and Jeb for being the major forces behind Minecraft",
}

-- Function to prepare credits with headers and titles
local function prepare_credits_with_heading(dest, title, source)
    table.insert(dest, "\n<big>" .. title .. "</big>\n")
    for _, line in ipairs(source) do
        if line:match(":") then
            table.insert(dest, "<heading>" .. line .. "</heading>\n")
        else
            table.insert(dest, line .. "\n")
        end
    end
    table.insert(dest, "\n")
end

local function prepare_credits(dest, source)
	local string = table.concat(source, "\n") .. "\n"

	local hypertext_escapes = {
		["\\"] = "\\\\",
		["<"] = "\\<",
		[">"] = "\\>",
	}
	string = string:gsub("[\\<>]", hypertext_escapes)
	string = string:gsub("%[.-%]", "<gray>%1</gray>")

	table.insert(dest, string)
end

return {
	name = "about",
	caption = fgettext("About"),

	cbf_formspec = function(tabview, name, tabdata)
		local logofile = defaulttexturedir .. "logo.png"
		local version = core.get_version()

		local hypertext = {
			"<tag name=heading color=#ff0>",
			"<tag name=gray color=#aaa>",
		}

		table.insert_all(hypertext, {
			"<heading>About Finecraft</heading>\n",
		})
		prepare_credits(hypertext, about_finecraft_game)

		table.insert_all(hypertext, {
			"\n",
			"<heading>Logo Disclaimer</heading>\n",
		})
		prepare_credits(hypertext, logo_disclaimer)

		table.insert_all(hypertext, {
			"\n",
			"<heading>Finecraft Disclaimer</heading>\n",
		})
		prepare_credits(hypertext, finecraft_disclaimer)

		table.insert_all(hypertext, {
			"\n<heading>", fgettext_ne("Core Developers"), "</heading>\n",
		})
		prepare_credits(hypertext, core_developers)
		table.insert_all(hypertext, {
			"\n",
			"<heading>", fgettext_ne("Core Team"), "</heading>\n",
		})
		prepare_credits(hypertext, core_team)
		table.insert_all(hypertext, {
			"\n",
			"<heading>", fgettext_ne("Active Contributors"), "</heading>\n",
		})
		prepare_credits(hypertext, active_contributors)
		table.insert_all(hypertext, {
			"\n",
			"<heading>", fgettext_ne("Previous Core Developers"), "</heading>\n",
		})
		prepare_credits(hypertext, previous_core_developers)
		table.insert_all(hypertext, {
			"\n",
			"<heading>", fgettext_ne("Previous Contributors"), "</heading>\n",
		})
		prepare_credits(hypertext, previous_contributors)


		prepare_credits_with_heading(hypertext, "MineClone2 Creators", creators)
    	prepare_credits_with_heading(hypertext, "MineClone2 Maintainers", maintainers)
    	prepare_credits_with_heading(hypertext, "MineClone2 Developers", developers)
		prepare_credits_with_heading(hypertext, "MineClone2 Contributors", contributors)
		prepare_credits_with_heading(hypertext, "MineClone2 Music Contributors", music_contributors)
		prepare_credits_with_heading(hypertext, "MineClone2 Original Mod Authors", mod_authors)
		prepare_credits_with_heading(hypertext, "MineClone2 3D Models", model_artists)
		prepare_credits_with_heading(hypertext, "MineClone2 Textures", texture_artists)
		prepare_credits_with_heading(hypertext, "MineClone2 Translators", translators)
		prepare_credits_with_heading(hypertext, "MineClone2 Funders", funders)
    	prepare_credits_with_heading(hypertext, "MineClone2 Special Thanks", special_thanks)

		hypertext = table.concat(hypertext):sub(1, -2)

		local fs = "image[1.5,0.6;2.5,2.5;" .. core.formspec_escape(logofile) .. "]" ..
			"style[label_button;border=false]" ..
			"button[0.1,3.4;5.3,0.5;label_button;" ..
			"minetest <3]" ..
			"hypertext[5.5,0.25;9.75,6.6;credits;" .. minetest.formspec_escape(hypertext) .. "]"

		-- Render information
		local active_renderer_info = fgettext("Active renderer:") .. " " ..
			core.formspec_escape(core.get_active_renderer())
		fs = fs .. "style[label_button2;border=false]" ..
			"button[0.1,6;5.3,0.5;label_button2;" .. active_renderer_info .. "]"..
			"tooltip[label_button2;" .. active_renderer_info .. "]"

		-- Irrlicht device information
		local irrlicht_device_info = fgettext("Irrlicht device:") .. " " ..
			core.formspec_escape(core.get_active_irrlicht_device())
		fs = fs .. "style[label_button3;border=false]" ..
			"button[0.1,6.5;5.3,0.5;label_button3;" .. irrlicht_device_info .. "]"..
			"tooltip[label_button3;" .. irrlicht_device_info .. "]"

		if PLATFORM == "Android" then
			fs = fs .. "button[0.5,5.1;4.5,0.8;share_debug;" .. fgettext("Share debug log") .. "]"
		else
			fs = fs .. "tooltip[userdata;" ..
					fgettext("Opens the directory that contains user-provided worlds, games, mods,\n" ..
							"and texture packs in a file manager / explorer.") .. "]"
			fs = fs .. "button[0.5,5.1;4.5,0.8;userdata;" .. fgettext("Open User Data Directory") .. "]"
		end

		return fs
	end,

	cbf_button_handler = function(this, fields)
		if fields.homepage then
			core.open_url("https://www.minetest.net")
		end

		if fields.share_debug then
			local path = core.get_user_path() .. DIR_DELIM .. "debug.txt"
			core.share_file(path)
		end

		if fields.btn_close_about then -- Back to main menu
			-- i have no idea how to close this dlg -.- so i just recreate the whole game lol
			-- stop music because init.lua starts it again. Like music, it also creates everything
			-- but i assume not most of users will use this and I don't concern memory leak at this point
			-- This is an urgent page
			mm_game_theme.stop_music()
			dofile(core.get_builtin_path() .. 'init.lua')
		end

		if fields.userdata then
			core.open_dir(core.get_user_path())
		end
	end,

	on_change = function(type)
		if type == "ENTER" then
			mm_game_theme.set_engine()
		end
	end,
}