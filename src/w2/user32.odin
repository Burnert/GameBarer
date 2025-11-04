// Additional bindings for User32.lib that are not *currently* present in the Odin core library

#+build windows
package windows2

import w "core:sys/windows"

foreign import user32 "system:User32.lib"

@(default_calling_convention="system")
foreign user32 {
	GetDisplayConfigBufferSizes :: proc(
		flags: w.UINT32,
		numPathArrayElements,
		numModeInfoArrayElements: ^w.UINT32,
	) -> w.LONG ---

	QueryDisplayConfig :: proc(
		flags: w.UINT32,
		numPathArrayElements: ^w.UINT32,
		pathArray: [^]DISPLAYCONFIG_PATH_INFO,
		numModeInfoArrayElements: ^w.UINT32,
		modeInfoArray: [^]DISPLAYCONFIG_MODE_INFO,
		currentTopologyId: ^DISPLAYCONFIG_TOPOLOGY_ID,
	) -> w.LONG ---

	DisplayConfigGetDeviceInfo :: proc(requestPacket: ^DISPLAYCONFIG_DEVICE_INFO_HEADER) -> w.LONG ---
	DisplayConfigSetDeviceInfo :: proc(setPacket: ^DISPLAYCONFIG_DEVICE_INFO_HEADER) -> w.LONG ---
}

DISPLAYCONFIG_TOPOLOGY_ID :: enum w.UINT32 {
  INTERNAL = 0x00000001,
  CLONE = 0x00000002,
  EXTEND = 0x00000004,
  EXTERNAL = 0x00000008,
  FORCE_UINT32 = 0xFFFFFFFF,
}

DISPLAYCONFIG_VIDEO_OUTPUT_TECHNOLOGY :: enum w.UINT32 {
	OTHER = w.UINT32(-1),
	HD15 = 0,
	SVIDEO = 1,
	COMPOSITE_VIDEO = 2,
	COMPONENT_VIDEO = 3,
	DVI = 4,
	HDMI = 5,
	LVDS = 6,
	D_JPN = 8,
	SDI = 9,
	DISPLAYPORT_EXTERNAL = 10,
	DISPLAYPORT_EMBEDDED = 11,
	UDI_EXTERNAL = 12,
	UDI_EMBEDDED = 13,
	SDTVDONGLE = 14,
	MIRACAST = 15,
	INDIRECT_WIRED = 16,
	INDIRECT_VIRTUAL = 17,
	DISPLAYPORT_USB_TUNNEL,
	INTERNAL = 0x80000000,
	FORCE_UINT32 = 0xFFFFFFFF,
}

DISPLAYCONFIG_ROTATION :: enum w.UINT32 {
	IDENTITY = 1,
	ROTATE90 = 2,
	ROTATE180 = 3,
	ROTATE270 = 4,
	FORCE_UINT32 = 0xFFFFFFFF,
}

DISPLAYCONFIG_SCALING :: enum w.UINT32 {
	IDENTITY = 1,
	CENTERED = 2,
	STRETCHED = 3,
	ASPECTRATIOCENTEREDMAX = 4,
	CUSTOM = 5,
	PREFERRED = 128,
	FORCE_UINT32 = 0xFFFFFFFF,
}

DISPLAYCONFIG_RATIONAL :: struct {
	Numerator: w.UINT32,
	Denominator: w.UINT32,
}

DISPLAYCONFIG_SCANLINE_ORDERING :: enum w.UINT32 {
	UNSPECIFIED = 0,
	PROGRESSIVE = 1,
	INTERLACED = 2,
	INTERLACED_UPPERFIELDFIRST,
	INTERLACED_LOWERFIELDFIRST = 3,
	FORCE_UINT32 = 0xFFFFFFFF,
}

DISPLAYCONFIG_PATH_TARGET_INFO :: struct {
	adapterId: w.LUID,
	id: w.UINT32,
	using DUMMYUNIONNAME: struct #raw_union {
		modeInfoIdx: w.UINT32,
		using DUMMYSTRUCTNAME: bit_field w.UINT32 {
			desktopModeInfoIdx: w.UINT32 | 16,
			targetModeInfoIdx: w.UINT32  | 16,
		},
	},
	outputTechnology: DISPLAYCONFIG_VIDEO_OUTPUT_TECHNOLOGY,
	rotation: DISPLAYCONFIG_ROTATION,
	scaling: DISPLAYCONFIG_SCALING,
	refreshRate: DISPLAYCONFIG_RATIONAL,
	scanLineOrdering: DISPLAYCONFIG_SCANLINE_ORDERING,
	targetAvailable: w.BOOL,
	statusFlags: w.UINT32,
}

DISPLAYCONFIG_PATH_SOURCE_INFO :: struct {
	adapterId: w.LUID,
	id: w.UINT32,
	using DUMMYUNIONNAME: struct #raw_union {
		modeInfoIdx: w.UINT32,
		using DUMMYSTRUCTNAME: bit_field w.UINT32 {
			cloneGroupId: w.UINT32      | 16,
			sourceModeInfoIdx: w.UINT32 | 16,
		},
	},
	statusFlags: w.UINT32,
}

DISPLAYCONFIG_PATH_INFO :: struct {
	sourceInfo: DISPLAYCONFIG_PATH_SOURCE_INFO,
	targetInfo: DISPLAYCONFIG_PATH_TARGET_INFO,
	flags: w.UINT32,
}

DISPLAYCONFIG_MODE_INFO_TYPE :: enum w.UINT32 {
	SOURCE = 1,
	TARGET = 2,
	DESKTOP_IMAGE = 3,
	FORCE_UINT32 = 0xFFFFFFFF,
}

DISPLAYCONFIG_2DREGION :: struct {
	cx: w.UINT32,
	cy: w.UINT32,
}

DISPLAYCONFIG_VIDEO_SIGNAL_INFO :: struct {
	pixelRate: w.UINT64,
	hSyncFreq: DISPLAYCONFIG_RATIONAL,
	vSyncFreq: DISPLAYCONFIG_RATIONAL,
	activeSize: DISPLAYCONFIG_2DREGION,
	totalSize: DISPLAYCONFIG_2DREGION,
	using DUMMYUNIONNAME: struct #raw_union {
		AdditionalSignalInfo: bit_field w.UINT32 {
			videoStandard: w.UINT32    | 16,
			vSyncFreqDivider: w.UINT32 | 6,
			reserved: w.UINT32         | 10,
		},
		videoStandard: w.UINT32,
	},
	scanLineOrdering: DISPLAYCONFIG_SCANLINE_ORDERING,
}

DISPLAYCONFIG_TARGET_MODE :: struct {
	targetVideoSignalInfo: DISPLAYCONFIG_VIDEO_SIGNAL_INFO,
}

POINTL :: struct {
	x: w.LONG,
	y: w.LONG,
}

DISPLAYCONFIG_PIXELFORMAT :: enum w.UINT32 {
  _8BPP = 1,
  _16BPP = 2,
  _24BPP = 3,
  _32BPP = 4,
  NONGDI = 5,
  FORCE_UINT32 = 0xFFFFFFFF,
}

DISPLAYCONFIG_SOURCE_MODE :: struct {
	width: w.UINT32,
	height: w.UINT32,
	pixelFormat: DISPLAYCONFIG_PIXELFORMAT,
	position: POINTL,
}

RECTL :: struct {
	left: w.LONG,
	top: w.LONG,
	right: w.LONG,
	bottom: w.LONG,
}

DISPLAYCONFIG_DESKTOP_IMAGE_INFO :: struct {
	PathSourceSize: POINTL,
	DesktopImageRegion: RECTL,
	DesktopImageClip: RECTL,
}

DISPLAYCONFIG_MODE_INFO :: struct {
	infoType: DISPLAYCONFIG_MODE_INFO_TYPE,
	id: w.UINT32,
	adapterId: w.LUID,
	using DUMMYUNIONNAME: struct #raw_union {
		targetMode: DISPLAYCONFIG_TARGET_MODE,
		sourceMode: DISPLAYCONFIG_SOURCE_MODE,
		desktopImageInfo: DISPLAYCONFIG_DESKTOP_IMAGE_INFO,
	},
}

QDC_ALL_PATHS                               : w.UINT32 : 0x00000001
QDC_ONLY_ACTIVE_PATHS                       : w.UINT32 : 0x00000002
QDC_DATABASE_CURRENT                        : w.UINT32 : 0x00000004
QDC_VIRTUAL_MODE_AWARE                      : w.UINT32 : 0x00000010
QDC_INCLUDE_HMD                             : w.UINT32 : 0x00000020
QDC_VIRTUAL_REFRESH_RATE_AWARE              : w.UINT32 : 0x00000040

DISPLAYCONFIG_DEVICE_INFO_TYPE :: enum w.UINT32 {
	GET_SOURCE_NAME = 1,
	GET_TARGET_NAME = 2,
	GET_TARGET_PREFERRED_MODE = 3,
	GET_ADAPTER_NAME = 4,
	SET_TARGET_PERSISTENCE = 5,
	GET_TARGET_BASE_TYPE = 6,
	GET_SUPPORT_VIRTUAL_RESOLUTION = 7,
	SET_SUPPORT_VIRTUAL_RESOLUTION = 8,
	GET_ADVANCED_COLOR_INFO = 9,
	SET_ADVANCED_COLOR_STATE = 10,
	GET_SDR_WHITE_LEVEL = 11,
	GET_MONITOR_SPECIALIZATION,
	SET_MONITOR_SPECIALIZATION,
	SET_RESERVED1,
	GET_ADVANCED_COLOR_INFO_2,
	SET_HDR_STATE,
	SET_WCG_STATE,
	FORCE_UINT32 = 0xFFFFFFFF,
}

DISPLAYCONFIG_DEVICE_INFO_HEADER :: struct {
	type: DISPLAYCONFIG_DEVICE_INFO_TYPE,
	size: w.UINT32,
	adapterId: w.LUID,
	id: w.UINT32,
}

DISPLAYCONFIG_COLOR_ENCODING :: enum w.UINT32 {
	RGB           = 0,
	YCBCR444      = 1,
	YCBCR422      = 2,
	YCBCR420      = 3,
	INTENSITY     = 4,
	FORCE_UINT32  = 0xFFFFFFFF,
}

DISPLAYCONFIG_GET_ADVANCED_COLOR_INFO :: struct {
	header: DISPLAYCONFIG_DEVICE_INFO_HEADER,
	using DUMMYUNIONNAME: struct #raw_union {
		using DUMMYSTRUCTNAME: bit_field w.UINT32 {
			advancedColorSupported: w.UINT32        | 1,    // A type of advanced color is supported
			advancedColorEnabled: w.UINT32          | 1,    // A type of advanced color is enabled
			wideColorEnforced: w.UINT32             | 1,    // Wide color gamut is enabled
			advancedColorForceDisabled: w.UINT32    | 1,    // Advanced color is force disabled due to system/OS policy
			reserved: w.UINT32                      | 28,
		},
		value: w.UINT32,
	},
	colorEncoding: DISPLAYCONFIG_COLOR_ENCODING,
	bitsPerColorChannel: w.UINT32,
}

DISPLAYCONFIG_SET_ADVANCED_COLOR_STATE :: struct {
	header: DISPLAYCONFIG_DEVICE_INFO_HEADER,
	using DUMMYUNIONNAME: struct #raw_union {
		using DUMMYSTRUCTNAME: bit_field w.UINT32 {
			enableAdvancedColor: w.UINT32  | 1,
			reserved: w.UINT32             | 31,
		},
		value: w.UINT32,
	},
}
