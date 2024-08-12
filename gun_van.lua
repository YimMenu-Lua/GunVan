-- TO-DO: Find out a way to permanently equip the Bottom Dollar Livery for Stungun

local gun_van_tab = gui.get_tab("Gun Van")

local van_locations = {
	"Paleto Bay - 1",
	"Grapeseed - 2",
	"Sandy Shores - 3",
	"Grand Senora - 4",
	"Vinewood Hills - 5",
	"Chumash - 6",
	"Paleto Forest - 7",
	"Zancudo River - 8",
	"Power Station - 9",
	"Lago Zancudo - 10",
	"Grand Senora - 11",
	"El Burro Heights - 12",
	"Murrieta Heights - 13",
	"Elysian Island - 14",
	"Tataviam - 15",
	"La Mesa - 16",
	"Terminal - 17",
	"La Puerta - 18",
	"La Mesa - 19",
	"Del Perro - 20",
	"Magellan Ave - 21",
	"West Vinewood - 22",
	"Downtown Vinewood - 23",
	"Pillbox Hill - 24",
	"Little Seoul - 25",
	"Alamo Sea - 26",
	"North Chumash - 27",
	"Mount Chiliad - 28",
	"Mirror Park - 29",
	"Davis - 30"
}

-- func_203, gunclub_shop
local allowed_weapons = {
	"WEAPON_KNIFE",
	"WEAPON_NIGHTSTICK",
	"WEAPON_HAMMER",
	"WEAPON_BOTTLE",
	"WEAPON_DAGGER",
	"WEAPON_KNUCKLE",
	"WEAPON_MACHETE",
	"WEAPON_FLASHLIGHT",
	"WEAPON_SWITCHBLADE",
	"WEAPON_BATTLEAXE",
	"WEAPON_POOLCUE",
	"WEAPON_WRENCH",
	"WEAPON_HATCHET",
	"WEAPON_BAT",
	"WEAPON_CROWBAR",
	"WEAPON_STUNROD",
	"WEAPON_PISTOL",
	"WEAPON_PISTOL_MK2",
	"WEAPON_COMBATPISTOL",
	"WEAPON_APPISTOL",
	"WEAPON_PISTOL50",
	"WEAPON_SNSPISTOL",
	"WEAPON_SNSPISTOL_MK2",
	"WEAPON_HEAVYPISTOL",
	"WEAPON_VINTAGEPISTOL",
	"WEAPON_FLAREGUN",
	"WEAPON_MARKSMANPISTOL",
	"WEAPON_REVOLVER",
	"WEAPON_REVOLVER_MK2",
	"WEAPON_DOUBLEACTION",
	"WEAPON_RAYPISTOL",
	"WEAPON_CERAMICPISTOL",
	"WEAPON_NAVYREVOLVER",
	"WEAPON_GADGETPISTOL",
	"WEAPON_STUNGUN_MP",
	"WEAPON_MICROSMG",
	"WEAPON_SMG",
	"WEAPON_SMG_MK2",
	"WEAPON_ASSAULTSMG",
	"WEAPON_COMBATPDW",
	"WEAPON_MACHINEPISTOL",
	"WEAPON_MINISMG",
	"WEAPON_MG",
	"WEAPON_COMBATMG",
	"WEAPON_COMBATMG_MK2",
	"WEAPON_GUSENBERG",
	"WEAPON_RAYCARBINE",
	"WEAPON_ASSAULTRIFLE",
	"WEAPON_ASSAULTRIFLE_MK2",
	"WEAPON_CARBINERIFLE",
	"WEAPON_CARBINERIFLE_MK2",
	"WEAPON_ADVANCEDRIFLE",
	"WEAPON_SPECIALCARBINE",
	"WEAPON_SPECIALCARBINE_MK2",
	"WEAPON_BULLPUPRIFLE",
	"WEAPON_BULLPUPRIFLE_MK2",
	"WEAPON_COMPACTRIFLE",
	"WEAPON_MILITARYRIFLE",
	"WEAPON_HEAVYRIFLE",
	"WEAPON_TACTICALRIFLE",
	"WEAPON_PUMPSHOTGUN",
	"WEAPON_PUMPSHOTGUN_MK2",
	"WEAPON_SAWNOFFSHOTGUN",
	"WEAPON_ASSAULTSHOTGUN",
	"WEAPON_BULLPUPSHOTGUN",
	"WEAPON_MUSKET",
	"WEAPON_HEAVYSHOTGUN",
	"WEAPON_DBSHOTGUN",
	"WEAPON_AUTOSHOTGUN",
	"WEAPON_COMBATSHOTGUN",
	"WEAPON_SNIPERRIFLE",
	"WEAPON_HEAVYSNIPER",
	"WEAPON_HEAVYSNIPER_MK2",
	"WEAPON_MARKSMANRIFLE",
	"WEAPON_MARKSMANRIFLE_MK2",
	"WEAPON_PRECISIONRIFLE",
	"WEAPON_GRENADELAUNCHER",
	"WEAPON_RPG",
	"WEAPON_MINIGUN",
	"WEAPON_HOMINGLAUNCHER",
	"WEAPON_COMPACTLAUNCHER",
	"WEAPON_RAYMINIGUN",
	"WEAPON_EMPLAUNCHER",
	"WEAPON_RAILGUNXM3",
	"WEAPON_TECPISTOL",
	"WEAPON_FIREWORK",
	"WEAPON_BATTLERIFLE",
	"WEAPON_SNOWLAUNCHER"
}

local selected_loc        = 0
local selected_slot       = 0
local is_typing           = false
local weapon_skins        = false
local gta_plus_blip       = false
local weapon_editor_popup = false
local filter_text         = ""
local weapon_name         = ""

local gun_van_loc = 0

local function help_marker(text)
    ImGui.SameLine()
    ImGui.TextDisabled("(?)")
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35)
        ImGui.TextUnformatted(text)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

local function render_weapon_editor()
	ImGui.SetNextWindowSize(700, 420)
	ImGui.OpenPopup("Weapon Editor")

	if ImGui.BeginPopupModal("Weapon Editor", weapon_editor_popup, ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.NoMove | ImGuiWindowFlags.Modal) then
		selected_slot = ImGui.Combo("Select Slot", selected_slot, { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, 10)

		filter_text = ImGui.InputText("Weapon Name", filter_text, 100)
		if ImGui.IsItemActive() then
			is_typing = true
		else
			is_typing = false
		end

		if ImGui.BeginListBox("##weapons", 450, 200) then
			for index, item in ipairs(allowed_weapons) do
				local display_name = weapons.get_weapon_display_name(item)
				if string.find(display_name:lower(), filter_text:lower()) then
					if ImGui.Selectable(display_name) then
						filter_text = display_name
						weapon_name = item
					end
				end
			end
			ImGui.EndListBox()
		end

		if ImGui.Button("Set Weapon") then
			local is_weapon_valid = weapons.get_weapon_display_name(weapon_name) ~= ""

			if is_weapon_valid then
				tunables.set_int("XM22_GUN_VAN_SLOT_WEAPON_TYPE_" .. selected_slot, joaat(weapon_name))
			else
				gui.show_error("Gun Van", "Invalid weapon.")
			end
		end

		ImGui.SameLine()

		if ImGui.Button("Remove Weapon") then
			tunables.set_int("XM22_GUN_VAN_SLOT_WEAPON_TYPE_" .. selected_slot, 0)
		end

		if ImGui.Button("Close") then
			selected_slot       = 0
			filter_text         = ""
			weapon_name         = ""
			weapon_editor_popup = false
			ImGui.CloseCurrentPopup()
		end

		ImGui.EndPopup()
	end
end

script.register_looped("Gun Van", function()
	gun_van_loc = globals.get_int(2652592 + 2671)

	if is_typing then
		PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
	end

	if weapon_skins then
		tunables.set_bool(1490225691, false)
	end

	if gta_plus_blip then
		local gun_van_sprite = HUD.GET_FIRST_BLIP_INFO_ID(844)

		tunables.set_float(15999531, 10000.0)
		if HUD.DOES_BLIP_EXIST(gun_van_sprite) then
			HUD.SET_BLIP_AS_SHORT_RANGE(gun_van_sprite, false)
		end
	end
end)

gun_van_tab:add_imgui(function()
    if weapon_editor_popup then
        render_weapon_editor()
    end

    ImGui.Text("Current Location: " .. (gun_van_loc ~= -1 and gun_van_loc + 1 or "N/A"))

    ImGui.SetNextItemWidth(265)
    selected_loc = ImGui.Combo("##selected_loc", selected_loc, van_locations, 30)

    ImGui.SameLine()

    if ImGui.Button("Set Location") then
        globals.set_int(2652592 + 2671, selected_loc)
    end

    ImGui.SameLine()

    if ImGui.Button("Teleport") then
        script.run_in_fiber(function()
            local coords = scr_function.call_script_function("freemode", "GGVC", "2D 00 02 00 00 74 61 ? ? ? 32", "vector3", {})
            PED.SET_PED_COORDS_KEEP_VEHICLE(self.get_ped(), coords.x, coords.y, coords.z)
        end)
    end

    weapon_skins, on_tick = ImGui.Checkbox("Weapon Skins", weapon_skins)
    help_marker("Enables the special liveries for Knife and Baseball Bat.")

    if on_tick then
        if not weapon_skins then
            tunables.set_bool(1490225691, true)
        end
    end

    gta_plus_blip, on_tick = ImGui.Checkbox("Blip Always Visible", gta_plus_blip)
    help_marker("Makes Gun Van always blipped on the map just like in GTA+.")

    if on_tick then
        if not gta_plus_blip then
            tunables.set_float(15999531, 500.0)
        end
    end

    ImGui.Separator()

    if ImGui.TreeNode("Weapons") then
        for i = 0, 9 do
            local weapon_hash = tunables.get_int("XM22_GUN_VAN_SLOT_WEAPON_TYPE_" .. i)

            if weapon_hash ~= 0 then
                local weapon_name = weapons.get_weapon_display_name(weapon_hash)
                local weapon_discount = math.floor(tunables.get_float("XM22_GUN_VAN_SLOT_WEAPON_DISCOUNT_" .. i) * 100.0)

                ImGui.Text(i + 1 .. " - " .. weapon_name .. " (" .. weapon_discount .. "%)")
            end
        end

        if ImGui.Button("Edit Weapons") then
            weapon_editor_popup = true
        end

        ImGui.Separator()
        ImGui.TreePop()
    end

    if ImGui.TreeNode("Throwables") then
        for i = 0, 2 do
            local throwable_hash = tunables.get_int("XM22_GUN_VAN_SLOT_THROWABLE_TYPE_" .. i)

            if throwable_hash ~= 0 then
                local throwable_name = weapons.get_weapon_display_name(throwable_hash)
                local throwable_discount = math.floor(tunables.get_float("XM22_GUN_VAN_SLOT_THROWABLE_DISCOUNT_" .. i) * 100.0)

                ImGui.Text(i + 1 .. " - " .. throwable_name .. " (" .. throwable_discount .. "%)")
            end
        end

        ImGui.Separator()
        ImGui.TreePop()
    end

    if ImGui.TreeNode("Body Armor") then
        local armour_discounts = {}

        for i = 0, 4 do
            armour_discounts[i + 1] = math.floor(tunables.get_float("XM22_GUN_VAN_SLOT_ARMOUR_DISCOUNT_" .. i) * 100.0)
        end

        ImGui.Text("Super Light Armor (" .. armour_discounts[1] .. "%)")
        ImGui.Text("Light Armor (" .. armour_discounts[2] .. "%)")
        ImGui.Text("Standard Armor (" .. armour_discounts[3] .. "%)")
        ImGui.Text("Heavy Armor (" .. armour_discounts[4] .. "%)")
        ImGui.Text("Super Heavy Armor (" .. armour_discounts[5] .. "%)")

        ImGui.TreePop()
    end
end)