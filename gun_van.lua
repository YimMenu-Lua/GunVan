local gun_van_tab = gui.get_tab("Gun Van")

local van_coordinates = {
	vec3:new(-34.37, 6439.51, 31.44),
	vec3:new(1706.32, 4824.61, 42.02),
	vec3:new(1796.32, 3892.97, 34.21),
	vec3:new(1335.34, 2752.96, 51.51),
	vec3:new(799.10, 1216.43, 340.23),
	vec3:new(-3190.18, 1081.97, 20.86),
	vec3:new(-796.34, 5402.29, 34.13),
	vec3:new(-19.44, 3045.60, 41.00),
	vec3:new(2672.42, 1470.23, 24.50),
	vec3:new(-1450.93, 2671.63, 3.55),
	vec3:new(2345.21, 3051.81, 48.15),
	vec3:new(1514.95, -2146.75, 77.20),
	vec3:new(1142.62, -1358.91, 34.63),
	vec3:new(-57.17, -2654.37, 6.00),
	vec3:new(1909.82, 562.92, 175.72),
	vec3:new(968.97, -1718.30, 30.42),
	vec3:new(778.93, -3272.28, 6.01),
	vec3:new(-583.03, -1639.34, 19.58),
	vec3:new(728.72, -736.59, 26.21),
	vec3:new(-1691.50, -449.29, 40.98),
	vec3:new(-1325.46, -1164.10, 4.63),
	vec3:new(-511.62, 49.19, 52.58),
	vec3:new(317.99, 53.98, 91.33),
	vec3:new(252.43, -767.82, 30.78),
	vec3:new(-476.58, -721.91, 32.98),
	vec3:new(900.15, 3603.80, 32.81),
	vec3:new(-2164.85, 4284.01, 48.96),
	vec3:new(1461.09, 6551.58, 14.35),
	vec3:new(1095.81, -338.27, 67.22),
	vec3:new(152.31, -1659.56, 29.29)
}

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

local selected_loc        = 0
local selected_slot       = 0
local weapon_name         = ""
local is_typing           = false
local gta_plus_blip       = false
local weapon_skins        = false
local weapon_editor_popup = false

local gun_van_loc = 0

function render_weapon_editor()
	ImGui.SetNextWindowSize(700, 250)
	ImGui.OpenPopup("Weapon Editor")

	if ImGui.BeginPopupModal("Weapon Editor", weapon_editor_popup, ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoMove) then
		selected_slot = ImGui.Combo("Select Slot", selected_slot, { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, 10)
		
		weapon_name = ImGui.InputText("Weapon Name", weapon_name, 100)
		if ImGui.IsItemActive() then
			is_typing = true
		else
			is_typing = false
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
			weapon_name         = ""
			weapon_editor_popup = false
			ImGui.CloseCurrentPopup()
		end

		ImGui.EndPopup()
	end
end

function set_blip_always_visible()
	local gun_van_sprite = HUD.GET_FIRST_BLIP_INFO_ID(844)

	tunables.set_float(15999531, 10000.0)
	if HUD.DOES_BLIP_EXIST(gun_van_sprite) then
		HUD.SET_BLIP_AS_SHORT_RANGE(gun_van_sprite, false)
	end
end

script.register_looped("Gun Van", function()
	gun_van_loc = globals.get_int(2652572 + 2650)

	if is_typing then
		PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
	end
	if gta_plus_blip then
		set_blip_always_visible()
	end
	if weapon_skins then
		tunables.set_bool(1490225691, false)
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
		globals.set_int(2652572 + 2650, selected_loc)
	end

	ImGui.SameLine()

	if ImGui.Button("Teleport") then
		script.run_in_fiber(function()
			local coords = van_coordinates[selected_loc + 1]
			PED.SET_PED_COORDS_KEEP_VEHICLE(self.get_ped(), coords.x, coords.y, coords.z)
		end)
	end

	gta_plus_blip, on_tick = ImGui.Checkbox("Blip Always Visible", gta_plus_blip)

	if on_tick then
		if not gta_plus_blip then
			tunables.set_float(15999531, 500.0)
		end
	end

	weapon_skins, on_tick = ImGui.Checkbox("Weapon Skins", weapon_skins)

	if on_tick then
		if not weapon_skins then
			tunables.set_bool(1490225691, true)
		end
	end

	ImGui.Separator()

	if ImGui.TreeNode("Weapons") then
		for i = 0, 9 do
			local weapon_hash = tunables.get_int("XM22_GUN_VAN_SLOT_WEAPON_TYPE_" .. i)

			if weapon_hash ~= 0 then
				local weapon_name     = weapons.get_weapon_display_name(weapon_hash)
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
				local throwable_name     = weapons.get_weapon_display_name(throwable_hash)
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