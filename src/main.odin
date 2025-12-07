package main

import "core:fmt"
import "core:os"
import "core:time"
import w "core:sys/windows"
import "w2"

// CONFIG/ARGS:
g_all_monitors: bool

is_key_down :: proc(key: w.INT) -> bool {
	return bool(u16(w.GetAsyncKeyState(key)) & 0x8000)
}

bool_to_on_off_string :: proc(b: bool) -> string {
	return "ON" if b else "OFF"
}

is_primary_monitor :: proc(path_info: w2.DISPLAYCONFIG_PATH_INFO) -> bool {
	res: w.LONG

	source_name: w2.DISPLAYCONFIG_SOURCE_DEVICE_NAME
	source_name.header.type = .GET_SOURCE_NAME
	source_name.header.size = size_of(w2.DISPLAYCONFIG_SOURCE_DEVICE_NAME)
	source_name.header.adapterId = path_info.sourceInfo.adapterId
	source_name.header.id = path_info.sourceInfo.id

	if res = w2.DisplayConfigGetDeviceInfo(&source_name.header); res != i32(w.ERROR_SUCCESS) {
		fmt.eprintln("DisplayConfigGetDeviceInfo failed", res)
		return false
	}

	dev_mode: w.DEVMODEW
	dev_mode.dmSize = size_of(w.DEVMODEW)

	if !w.EnumDisplaySettingsW(cstring16(&source_name.viewGdiDeviceName[0]), w.ENUM_CURRENT_SETTINGS, &dev_mode) {
		fmt.eprintln("EnumDisplaySettingsW failed.")
		return false
	}

	return dev_mode.dmPosition.x == 0 && dev_mode.dmPosition.y == 0
}

toggle_hdr_state :: proc() {
	context.allocator = context.temp_allocator

	res: w.LONG

	num_paths, num_modes: u32
	if res = w2.GetDisplayConfigBufferSizes(w2.QDC_ONLY_ACTIVE_PATHS, &num_paths, &num_modes); res != i32(w.ERROR_SUCCESS) {
		fmt.eprintln("GetDisplayConfigBufferSizes failed", res)
		return
	}

	paths := make([]w2.DISPLAYCONFIG_PATH_INFO, num_paths)
	modes := make([]w2.DISPLAYCONFIG_MODE_INFO, num_modes)

	if res = w2.QueryDisplayConfig(w2.QDC_ONLY_ACTIVE_PATHS, &num_paths, &paths[0], &num_modes, &modes[0], nil); res != i32(w.ERROR_SUCCESS) {
		fmt.eprintln("QueryDisplayConfig failed", res)
		return
	}

	// TODO: Either select one of the displays, preferably the current one, or toggle all of them simultaneously into ONE of the states,
	// so there isn't a case when one changes to ON and another one to OFF and then the other way around.
	// There can also be a config file with whitelisted displays.
	for p, i in paths {
		if !g_all_monitors && !is_primary_monitor(p) {
			continue
		}

		color_info: w2.DISPLAYCONFIG_GET_ADVANCED_COLOR_INFO
		color_info.header.type = .GET_ADVANCED_COLOR_INFO
		color_info.header.size = size_of(w2.DISPLAYCONFIG_GET_ADVANCED_COLOR_INFO)
		color_info.header.adapterId = p.targetInfo.adapterId
		color_info.header.id = p.targetInfo.id

		if res = w2.DisplayConfigGetDeviceInfo(&color_info.header); res != i32(w.ERROR_SUCCESS) {
			fmt.eprintln("DisplayConfigGetDeviceInfo failed", res)
			continue
		}

		// Check if HDR is supported
		if color_info.advancedColorSupported == 0 {
			fmt.println("Display", i, "does not support HDR.")
			continue
		}

		hdr_enabled := color_info.advancedColorEnabled == 1
		fmt.printfln("Display %i - HDR state: %s", i, bool_to_on_off_string(hdr_enabled))

		fmt.printfln("Switching HDR state on display %i.", i)

		set_color_state: w2.DISPLAYCONFIG_SET_ADVANCED_COLOR_STATE
		set_color_state.header.type = .SET_ADVANCED_COLOR_STATE
		set_color_state.header.size = size_of(w2.DISPLAYCONFIG_SET_ADVANCED_COLOR_STATE)
		set_color_state.header.adapterId = p.targetInfo.adapterId
		set_color_state.header.id = p.targetInfo.id
		set_color_state.enableAdvancedColor = auto_cast !hdr_enabled
		if res = w2.DisplayConfigSetDeviceInfo(&set_color_state.header); res == i32(w.ERROR_SUCCESS) {
			fmt.printfln("HDR has been set to %s on display %i.", bool_to_on_off_string(!hdr_enabled), i)
		} else {
			fmt.eprintln("Failed to set HDR to %s on display %i.", bool_to_on_off_string(!hdr_enabled), i)
			continue
		}
	}
}

main :: proc() {
	// Parse cmd line args
	if len(os.args) > 1 {
		arg := os.args[1]
		if arg == "-all" {
			g_all_monitors = true
		}
	}

	Keys :: enum {
		LWin,
		LAlt,
		B,
	}
	Key_States :: [Keys]bool
	key_states: Key_States

	fmt.println("Waiting for Win+LAlt+B...")
	for {
		prev_key_states := key_states
		key_states[.LWin] = is_key_down(w.VK_LWIN)
		key_states[.LAlt] = is_key_down(w.VK_LMENU)
		key_states[.B] = is_key_down(w.VK_B)
		if key_states[.LWin] && key_states[.LAlt] {
			if prev_key_states[.B] == false && key_states[.B] == true {
				fmt.println("User triggered an HDR toggle!")
				toggle_hdr_state()
			}
		}

		free_all(context.temp_allocator)
		time.sleep(time.Millisecond)
	}
}
