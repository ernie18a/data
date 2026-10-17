# Market Structure + Swing Levels [AFD]

- url: https://www.tradingview.com/script/K4znRiXf-Market-Structure-Swing-Levels-AFD/
- type: indicator
- pine_id: PUB;595afa36861b44d1b74e94feb91217b4
- version: 1.0

## Description

Market Structure + Swing Levels [AFD] organizes confirmed swing highs and
swing lows into configurable price Zones. Its default ATR mode sizes each
individual Zone from volatility at the Swing origin Bar; Tick, Point, and
Currency modes provide fixed-distance alternatives. It then describes
confirmed continuation Breaks, direction-changing Shifts, and the initial
direction assignment without trade instructions or predictive claims.

https://www.tradingview.com/x/cqsVvX31/

## Publication and license

- Publication type: Open-source.
- Pine version: 6.
- License: Mozilla Public License 2.0 (MPL 2.0).
- The open-source publication setting, this description, and the MPL 2.0
  notice in the Pine source header must remain aligned.

The source is available for inspection and modification under MPL 2.0. This
summary identifies the applicable license; the notice in the Pine source
header remains the authoritative license reference.

## Capabilities

- Confirms Swing Highs and Swing Lows using the same selected strength on both
  sides of the candidate Bar.
- Shows classifications by default: `H`, `HH`, `EH`, and `LH` for highs, and
  `L`, `HL`, `EL`, and `LL` for lows.
- Builds ATR-, Tick-, Point-, or Currency-width Zones around confirmed Swings.
- Merges transitively overlapping same-side Zones into exact-union clusters.
- Evaluates Structure on confirmed Bars using selectable Close or Body
  clearance.
- Lets Zone breaks use that Structure rule or an inclusive High/Low Touch of
  the far edge.
- Retains broken Zones by default with configurable memory and color.
- Reports current direction, latest Structure event, active Zones, and
  nearest-Zone distance in the Dashboard.
- Provides four fixed Structure alert conditions plus an optional combined
  dynamic alert that can include Zone breaks.

## How to use it

1. Select a Preset Profile or choose Custom and set Swing Strength. The default
   Swing profile uses a strength of 7 Bars on each side.
2. Choose the Zone Width Mode and width appropriate for the chart.
3. Choose how Structure confirms a clearance. Close is the default; Body
   requires both the Open and Close to clear the reference.
4. Zone Break Basis follows the Structure rule by default. Touch (High/Low)
   instead breaks a Zone when the wick reaches or passes its far edge.
5. Swing High and Swing Low Zone labels start at the oldest Swing Origin
   represented by each Zone. Select Right Edge when current-Bar alignment is
   preferred.
6. Swing High and Swing Low text have separate color controls. Both default to
   white and also color the matching Swing classification labels. Zone Age,
   Break, Shift, and Dashboard text also start white.
7. The Dashboard starts with all five rows visible. Disable nearest-Zone
   distance when only Direction, Last Event, and Zone counts are needed.
8. Show Broken Zones starts on with a 20-Bar memory. Turn it off for an
   active-Zones-only chart.
9. Zone Age starts off. When enabled, its unit starts in Days.

## How to interpret Zone cluster counts

The `×N` suffix is a cluster membership count. `Swing High ×3` means three
confirmed Swing High Zones are represented by that merged cluster.

It does not mean price tested one exact price three times. Zones merge when
their price bands overlap or meet at an edge. Merging is transitive, so one
connected Zone can bridge two other Zones even when those outer Zones do not
directly overlap each other. The displayed cluster preserves the full union of
those connected bands, and `×N` reports how many confirmed Swing Zones
contributed to it.

https://www.tradingview.com/x/3EphAG8H/

## Broken Zones

Show Broken Zones is the explicit on/off control:

- On by default — the Zone freezes at its break-confirmation Bar, changes to
  Broken Zone Color, and remains visible for the selected Broken Zone Memory.
- Off — a Zone is deleted as soon as it breaks.
- Up to 20 broken Zones are retained. If more accumulate before their memory
  expires, the oldest retained Zone is removed first.

This display choice does not change how Zone breaks are detected and does not
change alert behavior.

## Limitations and evidence

- Swings require the selected number of Bars on both sides, so confirmation
  occurs after the origin Bar.
- ATR Zone width uses volatility from the Swing origin Bar.
- Currency-width mode creates no Zone when the symbol does not provide a valid
  Point Value.
- Active Zones are capped at 40 per side. When the cap is reached, the oldest
  active Zone on that side is removed first.
- Hours and Days shown for Zone Age are timeframe-based approximations and do
  not correct for session gaps.
- Cluster membership describes connected Zone bands, not repeated reactions at
  one exact price.
- Repository checks pass for the working source. TradingView compilation and
  runtime verification of the latest working source have not yet been
  recorded.
- This indicator is educational chart context and does not provide trade
  instructions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AuctionFoundry

//@version=6
indicator(title="Market Structure + Swing Levels [AFD]", shorttitle="MSSL [AFD]", overlay=true,
     max_lines_count=200, max_labels_count=300, max_boxes_count=100)

// ── Constants ──
const int MAX_ZONES_PER_SIDE = 40   // Maximum active Zones retained per side.
const int MAX_SWING_LABELS   = 50   // Maximum Swing classification Labels retained.
const int MAX_EVENT_LABELS   = 60   // Maximum Structure Event Labels retained.
const int MAX_BROKEN_ZONES   = 20   // Maximum retained Broken Zone boxes.
const int MAX_CUSTOM_SWING_STRENGTH = 500 // Keeps dynamic history references inside a bounded buffer.

const color DEFAULT_TEXT_COLOR     = color.white
const color STRUCT_LIVE_LINE_COLOR = color.new(color.gray, 35)

const string GRP_GENERAL       = "⚙️ General"
const string GRP_SWINGS        = "📐 Swing Detection"
const string GRP_STRUCT_DETECT = "🏛️ Structure Detection"
const string GRP_STRUCT_LABELS = "🏷️ Structure Labels"
const string GRP_STRUCT_LINES  = "📏 Structure Lines"
const string GRP_EVENT_LINES   = "🧊 Event-Line History"
const string GRP_ZONE_CALC     = "🧱 Zone Calculation"
const string GRP_ZONE_APPEAR   = "🎨 Zone Appearance"
const string GRP_AGE           = "🕰️ Zone Age"
const string GRP_DASHBOARD     = "📊 Dashboard"
const string GRP_ALERTS        = "🔔 Alerts"

// ── Types ──
type SwingZone
    float  price        // Weighted mean of the Swing prices represented by the Zone.
    float  top
    float  bottom
    int    origin_bar   // Bar where the Zone formed.
    int    dir          // 1 = Swing High Zone; -1 = Swing Low Zone.
    int    merge_count  // Number of confirmed Swings merged into the Zone.
    box    box_obj
    label  label_obj

// Stores a Zone that broke but remains visible while Broken Zone Memory is active.
type BrokenZone
    box box_obj
    int expire_bar

// ── Inputs ──
preset = input.string("Swing", "Preset Profile", group=GRP_GENERAL, options=["Custom", "Scalper", "Intraday", "Swing"],
     tooltip="• Selects a predefined Swing Strength.\n" +
     "• Scalper — 3\n" +
     "• Intraday — 5\n" +
     "• Swing — 7\n" +
     "• Custom — uses the Swing Strength setting.",
     display=display.none)

swing_strength = input.int(5, "Swing Strength", group=GRP_SWINGS, minval=1, maxval=MAX_CUSTOM_SWING_STRENGTH,
     tooltip="• Sets the bars required on each side of a High or Low to confirm a Swing.\n" +
     "• 7–10 — fewer, larger Swings.\n" +
     "• 2–4 — faster, noisier Swings.\n" +
     "• Range — 1 to 500 Bars.\n" +
     "• A Swing confirms this many Bars after its origin.\n" +
     "• Applies only when Preset Profile is Custom.",
     display=display.none, active=preset == "Custom")

show_swing_labels = input.bool(true, "Show Swing Classification Labels", group=GRP_SWINGS,
     tooltip="• Compares each confirmed Swing with the prior Swing of the same type.\n" +
     "• HH — Higher High.\n" +
     "• EH — Equal High.\n" +
     "• LH — Lower High.\n" +
     "• HL — Higher Low.\n" +
     "• EL — Equal Low.\n" +
     "• LL — Lower Low.\n" +
     "• On by default.",
     display=display.none)

structure_enable = input.bool(true, "Enable Structure", group=GRP_STRUCT_DETECT,
     tooltip="• Tracks the latest Swing High and Swing Low.\n" +
     "• Tracks direction, Breaks, and Shifts.\n" +
     "• Off hides Structure Labels and Structure Lines.\n" +
     "• Swing detection and Zones continue when Structure is off.",
     display=display.none)

structure_confirm = input.string("Close", "Structure Confirm", group=GRP_STRUCT_DETECT, options=["Close", "Body"],
     tooltip="• Sets what must clear a level for it to count.\n" +
     "• Close — the Bar closes beyond the level.\n" +
     "• Close — a wick through and back does not count.\n" +
     "• Body — the Open and Close both clear the level.\n" +
     "• Body — stricter and may confirm later.\n" +
     "• Also controls Zones when Zone Break Basis is Same as Structure.",
     display=display.none)

show_break_labels = input.bool(false, "Show Break Labels", group=GRP_STRUCT_LABELS, inline="structlabels",
     display=display.none, active=structure_enable)
show_shift_labels = input.bool(false, "Show Shift Labels", group=GRP_STRUCT_LABELS, inline="structlabels",
     tooltip="• Break Labels mark continuation beyond the latest same-direction Swing.\n" +
     "• Shift Labels mark clearance of the opposite-side Swing.\n" +
     "• Shift Labels identify the Bar where tracked direction changes.",
     display=display.none, active=structure_enable)

event_label_size = input.string("Normal", "Event Label Size", group=GRP_STRUCT_LABELS, options=["Tiny", "Small", "Normal"],
     tooltip="• Controls Break and Shift Label text size.\n" +
     "• Tiny — most subtle.\n" +
     "• Small — compact.\n" +
     "• Normal — largest and most prominent.",
     display=display.none, active=structure_enable and (show_break_labels or show_shift_labels))

show_structure_lines = input.bool(false, "Show Structure Lines", group=GRP_STRUCT_LINES,
     tooltip="• Shows live Swing High and Swing Low reference lines.\n" +
     "• Shows frozen level segments for confirmed Breaks and Shifts.\n" +
     "• Live lines extend to the current Bar.",
     display=display.none, active=structure_enable)

live_line_color = input.color(STRUCT_LIVE_LINE_COLOR, "Live Line Color", group=GRP_STRUCT_LINES, inline="livelinestyle",
     display=display.none, active=structure_enable and show_structure_lines)
live_line_width = input.int(1, "Live Line Width", group=GRP_STRUCT_LINES, inline="livelinestyle", minval=1,
     display=display.none, active=structure_enable and show_structure_lines)
live_line_style = input.string("Solid", "Live Line Style", group=GRP_STRUCT_LINES, inline="livelinestyle",
     options=["Solid", "Dashed", "Dotted"],
     tooltip="• Live Line Color sets both current Swing reference colors.\n" +
     "• Live Line Width sets both current Swing reference widths.\n" +
     "• Live Line Style sets both current Swing reference styles.",
     display=display.none, active=structure_enable and show_structure_lines)

show_shift_trigger = input.bool(false, "Show Shift Trigger Line", group=GRP_STRUCT_LINES,
     tooltip="• Shows the opposite-side Swing that can change tracked direction.\n" +
     "• The trigger updates only from confirmed Swings.\n" +
     "• The trigger is hidden while direction is unset.",
     display=display.none, active=structure_enable)
shift_trigger_color = input.color(color.orange, "Shift Trigger Color", group=GRP_STRUCT_LINES, inline="shifttrig",
     display=display.none, active=structure_enable and show_shift_trigger)
shift_trigger_style = input.string("Dashed", "Shift Trigger Style", group=GRP_STRUCT_LINES, inline="shifttrig",
     options=["Solid", "Dashed", "Dotted"],
     tooltip="• Shift Trigger Color sets the live reversal-reference color.\n" +
     "• Shift Trigger Style sets the live reversal-reference style.",
     display=display.none, active=structure_enable and show_shift_trigger)

break_line_color = input.color(color.yellow, "Break Line Color", group=GRP_EVENT_LINES, inline="structcolor",
     display=display.none, active=structure_enable)
shift_line_color = input.color(color.purple, "Shift Line Color", group=GRP_EVENT_LINES, inline="structcolor",
     tooltip="• Break Line Color sets Break Labels and direction-neutral frozen Break Lines.\n" +
     "• Shift Line Color sets Shift Labels and direction-neutral frozen Shift Lines.",
     display=display.none, active=structure_enable)

frozen_dir_color = input.bool(false, "Color Frozen Lines by Direction", group=GRP_EVENT_LINES,
     tooltip="• Off — uses the Break and Shift Line Colors for both directions.\n" +
     "• On — uses separate Up and Down colors.\n" +
     "• Applies only to frozen event lines.",
     display=display.none, active=structure_enable and show_structure_lines)
break_up_color   = input.color(color.blue,   "Break Up Color",   group=GRP_EVENT_LINES, inline="frozendir1",
     display=display.none, active=structure_enable and show_structure_lines and frozen_dir_color)
break_dn_color   = input.color(color.blue,   "Break Down Color", group=GRP_EVENT_LINES, inline="frozendir1",
     tooltip="• Break Up Color sets frozen upward Break Lines.\n" +
     "• Break Down Color sets frozen downward Break Lines.",
     display=display.none, active=structure_enable and show_structure_lines and frozen_dir_color)
shift_up_color   = input.color(color.purple, "Shift Up Color",   group=GRP_EVENT_LINES, inline="frozendir2",
     display=display.none, active=structure_enable and show_structure_lines and frozen_dir_color)
shift_dn_color   = input.color(color.purple, "Shift Down Color", group=GRP_EVENT_LINES, inline="frozendir2",
     tooltip="• Shift Up Color sets frozen upward Shift Lines.\n" +
     "• Shift Down Color sets frozen downward Shift Lines.",
     display=display.none, active=structure_enable and show_structure_lines and frozen_dir_color)
frozen_line_width = input.int(1, "Frozen Line Width", group=GRP_EVENT_LINES, inline="frozendir3", minval=1,
     display=display.none, active=structure_enable and show_structure_lines)
frozen_line_style = input.string("Dotted", "Frozen Line Style", group=GRP_EVENT_LINES, inline="frozendir3",
     options=["Solid", "Dashed", "Dotted"],
     tooltip="• Frozen Line Width sets confirmed event-segment width.\n" +
     "• Frozen Line Style sets confirmed event-segment style.",
     display=display.none, active=structure_enable and show_structure_lines)

frozen_line_extend = input.string("None", "Frozen Line Extend", group=GRP_EVENT_LINES,
     options=["None", "Left", "Right", "Both"],
     tooltip="• None — keeps the segment between the origin Swing and confirmation Bar.\n" +
     "• Left — extends the segment left.\n" +
     "• Right — extends the segment right.\n" +
     "• Both — extends the segment in both directions.",
     display=display.none, active=structure_enable and show_structure_lines)

frozen_lines_kept = input.int(0, "Previous Frozen Lines Kept", group=GRP_EVENT_LINES, minval=0, maxval=50,
     tooltip="• Sets previous frozen event lines retained per direction.\n" +
     "• 0 — shows only the current frozen line per direction.\n" +
     "• N — shows the current line plus N previous lines per direction.\n" +
     "• Older previous lines delete in first-in, first-out order.",
     display=display.none, active=structure_enable and show_structure_lines)

show_zones = input.bool(true, "Show Zones", group=GRP_ZONE_CALC,
     tooltip="• Draws a band around each confirmed Swing.\n" +
     "• Zone Width Mode and Zone Width control each individual band.\n" +
     "• Overlapping same-side bands merge into exact-union clusters.",
     display=display.none)

zone_width_mode = input.string("ATR", "Zone Width Mode", group=GRP_ZONE_CALC,
     options=["ATR", "Ticks", "Points", "Currency ($)"],
     tooltip="• Sets how Zone Width is measured.\n" +
     "• ATR — uses ATR from the Swing origin Bar.\n" +
     "• Ticks — uses a fixed minimum-tick count.\n" +
     "• Points — uses a fixed chart-price distance.\n" +
     "• Currency ($) — converts currency distance through Point Value.\n" +
     "• Currency ($) — creates no Zone when Point Value is unavailable.",
     display=display.none, active=show_zones)

zone_width_val = input.float(0.5, "Zone Width", group=GRP_ZONE_CALC, minval=0.01,
     tooltip="• Sets the half-width above and below each Swing.\n" +
     "• ATR — 0.5 creates a one-ATR-tall individual band.\n" +
     "• Ticks — uses the entered tick count on each side.\n" +
     "• Points — uses the entered chart-price distance on each side.\n" +
     "• Currency ($) — uses the entered currency distance on each side.",
     display=display.none, active=show_zones)

atr_length = input.int(14, "ATR Length", group=GRP_ZONE_CALC, minval=1,
     tooltip="• Sets ATR history length.\n" +
     "• Uses ATR from each Swing's origin Bar.\n" +
     "• Lower values react faster to volatility.\n" +
     "• Higher values smooth volatility.\n" +
     "• Applies only when Zone Width Mode is ATR.",
     display=display.none, active=show_zones and zone_width_mode == "ATR")

zone_break_basis = input.string("Same as Structure", "Zone Break Basis", group=GRP_ZONE_CALC,
     options=["Same as Structure", "Touch (High/Low)"],
     tooltip="• Sets what removes an active Zone.\n" +
     "• Same as Structure — uses Close or Body clearance beyond the far edge.\n" +
     "• Touch (High/Low) — removes a Zone when a wick reaches or passes the far edge.",
     display=display.none, active=show_zones)

show_broken_zones = input.bool(true, "Show Broken Zones", group=GRP_ZONE_CALC,
     tooltip="• On — freezes and recolors a broken Zone for the selected memory period.\n" +
     "• On by default.\n" +
     "• Off — deletes a Zone as soon as it breaks.\n" +
     "• Does not change Zone break detection or alerts.",
     display=display.none, active=show_zones)

broken_zone_keep_bars = input.int(20, "Broken Zone Memory (bars)", group=GRP_ZONE_CALC, minval=1, maxval=500,
     tooltip="• Sets how long a broken Zone remains visible.\n" +
     "• The broken Zone freezes at its confirmation Bar.\n" +
     "• Up to 20 broken Zones are retained; the oldest deletes first.\n" +
     "• Applies only when Show Broken Zones is on.",
     display=display.none, active=show_zones and show_broken_zones)

show_cluster_labels = input.bool(true, "Show Cluster Labels", group=GRP_ZONE_APPEAR,
     tooltip="• Labels each active Zone.\n" +
     "• A ×N suffix shows confirmed Swings represented by a cluster.\n" +
     "• Cluster bounds preserve the exact union of overlapping member bands.",
     display=display.none, active=show_zones)

cluster_label_position = input.string("Swing Origin", "Swing High/Low Label Position", group=GRP_ZONE_APPEAR,
     options=["Right Edge", "Swing Origin"],
     tooltip="• Swing Origin — anchors each label at the oldest Swing represented by its Zone.\n" +
     "• Swing Origin is the default.\n" +
     "• Right Edge — aligns active Swing High and Swing Low text at each Zone midpoint on the current Bar.\n" +
     "• Right Edge places Zone text to the right and optional Age text to the left.\n" +
     "• Right Edge provides the most consistent horizontal placement.",
     display=display.none, active=show_zones and show_cluster_labels)

zone_hi_color = input.color(color.new(color.red,   85), "Swing High Zone Color", group=GRP_ZONE_APPEAR, inline="zonecolor",
     display=display.none, active=show_zones)
zone_lo_color = input.color(color.new(color.green, 85), "Swing Low Zone Color",  group=GRP_ZONE_APPEAR, inline="zonecolor",
     tooltip="• Swing High Zone Color sets high-Zone fill and borders.\n" +
     "• Swing Low Zone Color sets low-Zone fill and borders.\n" +
     "• Both colors seed compatible Zone Age palettes.",
     display=display.none, active=show_zones)

zone_hi_text_color = input.color(DEFAULT_TEXT_COLOR, "Swing High Text Color", group=GRP_ZONE_APPEAR, inline="zonetextcolor",
     display=display.none, active=(show_zones and show_cluster_labels) or show_swing_labels)
zone_lo_text_color = input.color(DEFAULT_TEXT_COLOR, "Swing Low Text Color", group=GRP_ZONE_APPEAR, inline="zonetextcolor",
     tooltip="• Swing High Text Color sets Swing High Zone and High-classification text.\n" +
     "• Swing Low Text Color sets Swing Low Zone and Low-classification text.\n" +
     "• Both default to white for consistent chart readability.",
     display=display.none, active=(show_zones and show_cluster_labels) or show_swing_labels)

broken_zone_color = input.color(color.new(color.gray, 80), "Broken Zone Color", group=GRP_ZONE_APPEAR,
     tooltip="• Sets retained broken-Zone fill color.\n" +
     "• Sets retained broken-Zone border color.\n" +
     "• Applies only when Show Broken Zones is on.",
     display=display.none, active=show_zones and show_broken_zones)

show_zone_age = input.bool(false, "Show Zone Age", group=GRP_AGE,
     tooltip="• Shows an age label at the right edge of each active Zone.\n" +
     "• A cluster's age begins at its oldest member Swing.",
     display=display.none, active=show_zones)

age_unit = input.string("Days", "Age Unit", group=GRP_AGE, options=["Bars", "Hours", "Days"],
     tooltip="• Sets the unit for the age label.\n" +
     "• Bars — reports chart Bars since the oldest member Swing.\n" +
     "• Hours — converts Bar count through the chart timeframe.\n" +
     "• Days — converts Bar count through the chart timeframe.\n" +
     "• Days is the default.\n" +
     "• Hours and Days are approximate.\n" +
     "• Session gaps are not corrected.",
     display=display.none, active=show_zones and show_zone_age)

age_label_size = input.string("Normal", "Age Label Size", group=GRP_AGE, options=["Tiny", "Small", "Normal"],
     tooltip="• Controls Zone Age Label text size.\n" +
     "• Does not affect Cluster Labels.\n" +
     "• Does not affect Break or Shift Labels.",
     display=display.none, active=show_zones and show_zone_age)

age_color_mode = input.string("Off", "Color Zones by Age", group=GRP_AGE,
     options=["Off", "Auto (Gradient)", "Preset", "Dark", "Contrast", "Warm", "Mono", "Cool", "Pastel", "Subdued"],
     tooltip="• Off — uses fixed Zone colors.\n" +
     "• Auto — fades from the Zone color to Gradient End Color.\n" +
     "• Preset — uses three Zone-color transparency bands.\n" +
     "• Mono — uses a gentler three-band Zone-color fade.\n" +
     "• Dark — uses three gray shades.\n" +
     "• Contrast — uses green, yellow, and red.\n" +
     "• Warm — uses yellow, orange, and red.\n" +
     "• Cool — uses teal, blue, and light blue.\n" +
     "• Pastel — uses light blue, lavender, and pink.\n" +
     "• Subdued — uses desaturated teal, slate, and mauve.\n" +
     "• Fixed-band modes use the Fresh, Mid, and Old thresholds.",
     display=display.none, active=show_zones)

age_opacity = input.int(0, "Extra Color Opacity", group=GRP_AGE, minval=-40, maxval=40,
     tooltip="• 0 — uses palette defaults.\n" +
     "• Positive — makes colors fainter.\n" +
     "• Negative — makes colors stronger.\n" +
     "• Applies to Auto and all fixed-band modes.",
     display=display.none, active=show_zones and age_color_mode != "Off")

age_gradient_bars = input.int(200, "Gradient Range (bars)", group=GRP_AGE, minval=1,
     tooltip="• Sets when a Zone reaches Gradient End Color.\n" +
     "• Measures age in chart Bars.\n" +
     "• Applies only to Auto mode.",
     display=display.none, active=show_zones and age_color_mode == "Auto (Gradient)")

age_gradient_end = input.color(color.new(color.gray, 70), "Gradient End Color", group=GRP_AGE,
     tooltip="• Sets the oldest Zone color in Auto mode.\n" +
     "• Pine interpolates younger Zone colors automatically.\n" +
     "• Applies only to Auto mode.",
     display=display.none, active=show_zones and age_color_mode == "Auto (Gradient)")

age_band1_bars = input.int(20, "Fresh→Mid (bars)", group=GRP_AGE, minval=1,
     tooltip="• Sets the first fixed-band age cutoff.\n" +
     "• Younger Zones are Fresh.\n" +
     "• Applies only to fixed-band modes.",
     display=display.none, active=show_zones and age_color_mode != "Off" and age_color_mode != "Auto (Gradient)")
age_band2_bars = input.int(100, "Mid→Old (bars)", group=GRP_AGE, minval=1,
     tooltip="• Sets the second fixed-band age cutoff.\n" +
     "• Zones between the effective cutoffs are Mid.\n" +
     "• Older Zones are Old.\n" +
     "• The effective Old cutoff is always after Fresh→Mid.\n" +
     "• Applies only to fixed-band modes.",
     display=display.none, active=show_zones and age_color_mode != "Off" and age_color_mode != "Auto (Gradient)")

age_label_color = input.color(DEFAULT_TEXT_COLOR, "Age Label Color", group=GRP_AGE,
     tooltip="• Sets Zone Age Label text color.",
     display=display.none, active=show_zones and show_zone_age)

show_dashboard = input.bool(true, "Show Dashboard", group=GRP_DASHBOARD,
     tooltip="• Shows current tracked direction.\n" +
     "• Shows the latest Structure event.\n" +
     "• Shows active high-Zone and low-Zone counts.",
     display=display.none)
dash_position  = input.string("Top Right", "Dashboard Position", group=GRP_DASHBOARD,
     options=["Top Right", "Bottom Right", "Bottom Left", "Top Left"],
     tooltip="• Sets the Dashboard corner.\n" +
     "• Right-side positions avoid most TradingView chart controls.\n" +
     "• Left-side positions can overlap ticker controls or the chart watermark.",
     display=display.none, active=show_dashboard)
dash_text_size = input.string("Small", "Text Size", group=GRP_DASHBOARD,
     options=["Tiny", "Small", "Normal"],
     tooltip="• Sets Dashboard text size.\n" +
     "• Tiny — most compact.\n" +
     "• Small — balanced.\n" +
     "• Normal — largest.",
     display=display.none, active=show_dashboard)

show_nearest_zone = input.bool(true, "Show Nearest Zone Distance", group=GRP_DASHBOARD,
     tooltip="• On — adds Zone Above and Zone Below.\n" +
     "• On by default, so the Dashboard shows all five rows.\n" +
     "• Off — shows Direction, Last Event, and Zones.\n" +
     "• Distance uses the selected Zone Width Mode unit.\n" +
     "• Forex Tick mode reports pips.",
     display=display.none, active=show_dashboard)

dyn_alerts = input.bool(true, "Dynamic Alert Text", group=GRP_ALERTS,
     tooltip="• Sends one combined alert message per confirmed Bar.\n" +
     "• Includes every Break and Shift confirmed on that Bar.\n" +
     "• Can include Zone breaks when enabled below.\n" +
     "• Use Any alert() function call in TradingView.\n" +
     "• The four fixed alert conditions remain available.",
     display=display.none)

zone_break_alerts = input.bool(true, "Include Zone Breaks in Dynamic Alert", group=GRP_ALERTS,
     tooltip="• Adds each confirmed Zone break to the combined dynamic message.\n" +
     "• Reports the crossed far edge of the broken Zone.\n" +
     "• Can send a dynamic alert when no Structure event occurs.\n" +
     "• Does not change the four fixed alert conditions.",
     display=display.none, active=dyn_alerts and show_zones)

// ── Preset Resolution ──
// Resolve the selected profile to the effective Swing Strength.
int eff_swing = preset == "Scalper" ? 3 : preset == "Intraday" ? 5 : preset == "Swing" ? 7 : swing_strength
int eff_age_old_bars = math.max(age_band2_bars, age_band1_bars + 1)

// ── Per-Bar Reads ──
// Read volatility and pivot candidates once per bar. A pivot is confirmed
// only after eff_swing Bars on each side, which keeps the plotted Swing fixed
// after confirmation.
float atr_val = ta.atr(atr_length)
max_bars_back(atr_val, MAX_CUSTOM_SWING_STRENGTH)
float ph    = ta.pivothigh(high, eff_swing, eff_swing)
float pl    = ta.pivotlow(low,  eff_swing, eff_swing)

// ── Engine State ──
var float last_sh     = na
var int   last_sh_bar = na
var float last_sl     = na
var int   last_sl_bar = na

var int   struct_dir   = 0     // 0 unset; 1 Up; -1 Down.
var float shift_ref_hi = na
var float shift_ref_lo = na
var int   shift_ref_hi_bar = na   // Origin Bar for the current Swing High reference.
var int   shift_ref_lo_bar = na   // Origin Bar for the current Swing Low reference.

var int   brk_count    = 0     // Same-direction Breaks since the last Shift.
var int   brk_up_bar   = na    // Origin Bar of the Swing High that produced the last Up Break.
var int   brk_dn_bar   = na    // Origin Bar of the Swing Low that produced the last Down Break.

var array<label> swing_labels = array.new<label>()
var array<label> event_labels = array.new<label>()
var array<label> age_labels   = array.new<label>()

var line struct_sh_line   = na   // Live Swing High reference line.
var line struct_sl_line   = na   // Live Swing Low reference line.
var line struct_up_frozen = na   // Latest Up-side Break or Shift line.
var line struct_dn_frozen = na   // Latest Down-side Break or Shift line.
var line shift_trigger_line = na // Live Shift Trigger line.

var array<line> frozen_up_hist = array.new<line>()   // Retained Up-side lines in FIFO order.
var array<line> frozen_dn_hist = array.new<line>()   // Retained Down-side lines in FIFO order.

var table  dashboard        = na
var string last_event_label = na   // Most recent Structure Event type.
var int    last_event_dir   = 0    // 1 Up; -1 Down.
var float  last_event_price = na
var int    last_event_bar   = na

var array<SwingZone> zones_hi = array.new<SwingZone>()
var array<SwingZone> zones_lo = array.new<SwingZone>()
var array<BrokenZone> broken_zones = array.new<BrokenZone>()   // Retained Broken Zones awaiting expiry.

// These flags describe events confirmed on the current Bar. They remain at
// script scope so the fixed alert conditions can use the same event state.
bool  brk_up_fired     = false
bool  brk_dn_fired     = false
bool  shift_up_fired   = false
bool  shift_dn_fired   = false
bool  shift_initial    = false
float brk_fire_price   = na
float shift_fire_price = na
int   shift_fire_bar   = na

// ── Zone Helpers ──
// Confirmed Swings create or merge same-side Zones. Overlapping Zones merge
// transitively into one band whose bounds preserve the exact union.
//@function Creates a Zone or merges a confirmed Swing into an existing Zone.
//@param zones Collection of active Zones for one side of the chart.
//@param pivot Confirmed Swing price used as the Zone center.
//@param pivot_atr ATR value from the Swing's origin Bar.
//@param origin_bar Bar where the confirmed Swing formed.
//@param dir 1 for a Swing High Zone; -1 for a Swing Low Zone.
//@param zone_color Base color for the Zone box.
//@param label_prefix Text shown by the Zone Label.
f_zone_upsert(array<SwingZone> zones, float pivot, float pivot_atr, int origin_bar, int dir,
 color zone_color, string label_prefix) =>
    float zone_half = zone_width_mode == "Ticks"        ? zone_width_val * syminfo.mintick   :
     zone_width_mode == "Points"       ? zone_width_val                      :
     zone_width_mode == "Currency ($)" ?
      (not na(syminfo.pointvalue) and syminfo.pointvalue > 0 ? zone_width_val / syminfo.pointvalue : na) :
     pivot_atr * zone_width_val
    // Wait for enough ATR history before creating an ATR-sized Zone.
    if not na(zone_half)
        float merged_top      = pivot + zone_half
        float merged_bottom   = pivot - zone_half
        float weighted_prices = pivot
        int   merged_count    = 1
        int   oldest_bar      = origin_bar
        box   canonical_box   = na
        label canonical_label = na
        int   canonical_bar   = origin_bar
        bool  found_overlap   = true
        // Rescan after every expansion so a bridge band also absorbs Zones
        // encountered earlier in the reverse pass.
        while found_overlap
            found_overlap := false
            if array.size(zones) > 0
                for i = array.size(zones) - 1 to 0
                    SwingZone zscan = array.get(zones, i)
                    if zscan.bottom <= merged_top and zscan.top >= merged_bottom
                        merged_top      := math.max(merged_top, zscan.top)
                        merged_bottom   := math.min(merged_bottom, zscan.bottom)
                        weighted_prices += zscan.price * zscan.merge_count
                        merged_count    += zscan.merge_count
                        oldest_bar      := math.min(oldest_bar, zscan.origin_bar)
                        // Preserve the oldest drawing as the cluster's canonical
                        // object. Recreating it after 10,000+ Bars can violate
                        // TradingView's historical bar_index drawing limit.
                        if na(canonical_box) or zscan.origin_bar < canonical_bar
                            if not na(canonical_box)
                                box.delete(canonical_box)
                            if not na(canonical_label)
                                label.delete(canonical_label)
                            canonical_box   := zscan.box_obj
                            canonical_label := zscan.label_obj
                            canonical_bar   := zscan.origin_bar
                        else
                            box.delete(zscan.box_obj)
                            if not na(zscan.label_obj)
                                label.delete(zscan.label_obj)
                        array.remove(zones, i)
                        found_overlap := true
        if array.size(zones) >= MAX_ZONES_PER_SIDE
            SwingZone evict = array.shift(zones)
            box.delete(evict.box_obj)
            if not na(evict.label_obj)
                label.delete(evict.label_obj)
        float cluster_price = weighted_prices / merged_count
        box new_box = canonical_box
        if na(new_box)
            new_box := box.new(oldest_bar, merged_top, bar_index, merged_bottom,
             bgcolor=zone_color, border_color=zone_color, border_width=1)
        else
            box.set_top(new_box, merged_top)
            box.set_bottom(new_box, merged_bottom)
            box.set_right(new_box, bar_index)
            box.set_bgcolor(new_box, zone_color)
            box.set_border_color(new_box, zone_color)
            box.set_border_width(new_box, 1)
        label new_label = canonical_label
        if show_cluster_labels
            lbl_style = cluster_label_position == "Right Edge" ? label.style_label_left :
             dir == 1 ? label.style_label_down : label.style_label_up
            lbl_y     = cluster_label_position == "Right Edge" ? cluster_price :
             dir == 1 ? merged_top : merged_bottom
            color lbl_text_color = dir == 1 ? zone_hi_text_color : zone_lo_text_color
            string lbl_text = merged_count > 1 ?
             label_prefix + " ×" + str.tostring(merged_count) : label_prefix
            string width_text = zone_width_mode == "Ticks" ? str.tostring(zone_width_val) + " Ticks" :
             zone_width_mode == "Points" ? str.tostring(zone_width_val) + " Points" :
             zone_width_mode == "Currency ($)" ? str.tostring(zone_width_val) + " Currency Units" :
             str.tostring(zone_width_val) + " × ATR(" + str.tostring(atr_length) + ")"
            string lbl_tooltip = "• Side — " + label_prefix + ".\n" +
             "• Confirmed Swings represented — " + str.tostring(merged_count) + ".\n" +
             "• Individual half-width — " + width_text + " on each side.\n" +
             "• Cluster bounds — exact union of all overlapping member bands.\n" +
             "• Cluster age — measured from the oldest member Swing."
            if na(new_label)
                // This fallback is only relevant to state migrated from an
                // unlabeled Zone. Keep any new label inside the history limit.
                int label_bar = cluster_label_position == "Right Edge" ?
                 bar_index : math.max(oldest_bar, bar_index - 9999)
                new_label := label.new(label_bar, lbl_y, lbl_text,
                 style=lbl_style, color=color.new(color.gray, 100),
                 textcolor=lbl_text_color, size=size.normal,
                 tooltip=lbl_tooltip)
            else
                label.set_y(new_label, lbl_y)
                label.set_text(new_label, lbl_text)
                label.set_style(new_label, lbl_style)
                label.set_color(new_label, color.new(color.gray, 100))
                label.set_textcolor(new_label, lbl_text_color)
                label.set_size(new_label, size.normal)
                label.set_tooltip(new_label, lbl_tooltip)
        else if not na(new_label)
            label.delete(new_label)
            new_label := na
        SwingZone new_zone = SwingZone.new(price=cluster_price, top=merged_top, bottom=merged_bottom,
         origin_bar=oldest_bar, dir=dir, merge_count=merged_count,
         box_obj=new_box, label_obj=new_label)
        int insert_at = array.size(zones)
        if array.size(zones) > 0
            for i = 0 to array.size(zones) - 1
                if array.get(zones, i).origin_bar > oldest_bar
                    insert_at := i
                    break
        if insert_at == array.size(zones)
            array.push(zones, new_zone)
        else
            array.insert(zones, insert_at, new_zone)

//@function Removes Zones that crossed their configured break threshold.
//@param zones Collection of active Zones for one side of the chart.
//@param dir 1 for Swing High Zones; -1 for Swing Low Zones.
//@param cross Price used to evaluate the Zone break.
//@param inclusive Whether equality with the far edge counts as a break.
//@returns The number of Zones broken on the current Bar and the farthest crossed edge.
f_zone_lifecycle(array<SwingZone> zones, int dir, float cross, bool inclusive) =>
    int   n_broken   = 0
    float last_price = na
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            SwingZone z = array.get(zones, i)
            bool broken = inclusive ?
             (dir == 1 ? cross >= z.top : cross <= z.bottom) :
             (dir == 1 ? cross > z.top : cross < z.bottom)
            if broken
                array.remove(zones, i)
                n_broken   += 1
                float edge_price = dir == 1 ? z.top : z.bottom
                if na(last_price) or (dir == 1 ? edge_price > last_price : edge_price < last_price)
                    last_price := edge_price
                if show_broken_zones
                    box.set_right(z.box_obj, bar_index)
                    box.set_bgcolor(z.box_obj, broken_zone_color)
                    box.set_border_color(z.box_obj, broken_zone_color)
                    if array.size(broken_zones) >= MAX_BROKEN_ZONES
                        box.delete(array.shift(broken_zones).box_obj)
                    array.push(broken_zones, BrokenZone.new(
                     box_obj=z.box_obj, expire_bar=bar_index + broken_zone_keep_bars))
                else
                    box.delete(z.box_obj)
                if not na(z.label_obj)
                    label.delete(z.label_obj)
            else
                box.set_right(z.box_obj, bar_index)
    [n_broken, last_price]

// ── Dashboard Helpers ──
//@function Converts the Dashboard Position input to a table position.
dash_pos() =>
    dash_position == "Top Right"    ? position.top_right    :
     dash_position == "Top Left"     ? position.top_left     :
     dash_position == "Bottom Right" ? position.bottom_right :
     position.bottom_left

//@function Converts the Dashboard Text Size input to a Pine size constant.
f_dash_text_size() =>
    dash_text_size == "Tiny" ? size.tiny : dash_text_size == "Small" ? size.small : size.normal

//@function Writes a Dashboard row label.
//@param tbl Dashboard table receiving the label.
//@param row Row index receiving the label.
//@param txt Label text.
//@param col Label text color.
//@param sz Dashboard text size.
f_cell_l(table tbl, int row, string txt, color col, string sz) =>
    table.cell(tbl, 0, row, txt, text_color=col, text_size=sz, text_halign=text.align_left)

//@function Writes a Dashboard value and its tooltip.
//@param tbl Dashboard table receiving the value.
//@param row Row index receiving the value.
//@param txt Value text.
//@param col Value text color.
//@param sz Dashboard text size.
//@param tt Tooltip text shown for the value.
f_cell_v(table tbl, int row, string txt, color col, string sz, string tt) =>
    table.cell(tbl, 1, row, txt, text_color=col, text_size=sz, text_halign=text.align_left, tooltip=tt)

//@function Converts a line style input to a Pine line style.
f_line_style(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

//@function Converts a line extension input to a Pine line extension.
f_line_extend(string s) =>
    s == "Left" ? extend.left : s == "Right" ? extend.right : s == "Both" ? extend.both : extend.none

//@function Retains or deletes the previous Frozen Line according to Previous Frozen Lines Kept.
//@param old Previous Frozen Line for the same direction.
//@param hist FIFO history for retained Frozen Lines.
f_retire_frozen(line old, array<line> hist) =>
    if not na(old)
        if frozen_lines_kept > 0
            array.push(hist, old)
            if array.size(hist) > frozen_lines_kept
                line.delete(array.shift(hist))
        else
            line.delete(old)

//@function Converts the Event Label Size input to a Pine size constant.
f_event_label_size() =>
    event_label_size == "Tiny" ? size.tiny : event_label_size == "Normal" ? size.normal : size.small

//@function Finds the nearest active Swing High Zone above a price.
//@param px Price used as the distance origin.
//@returns The distance to the nearest Zone edge and whether price is inside a Zone.
f_zone_above(float px) =>
    float best   = na
    bool  inside = false
    if array.size(zones_hi) > 0
        for i = 0 to array.size(zones_hi) - 1
            SwingZone z = array.get(zones_hi, i)
            if px >= z.bottom and px <= z.top
                inside := true
            else if z.bottom > px
                float d = z.bottom - px
                if na(best) or d < best
                    best := d
    [best, inside]

//@function Finds the nearest active Swing Low Zone below a price.
//@param px Price used as the distance origin.
//@returns The distance to the nearest Zone edge and whether price is inside a Zone.
f_zone_below(float px) =>
    float best   = na
    bool  inside = false
    if array.size(zones_lo) > 0
        for i = 0 to array.size(zones_lo) - 1
            SwingZone z = array.get(zones_lo, i)
            if px >= z.bottom and px <= z.top
                inside := true
            else if z.top < px
                float d = px - z.top
                if na(best) or d < best
                    best := d
    [best, inside]

//@function Formats a Dashboard distance in the selected Zone Width Mode.
//@param d Price distance to the nearest Zone edge.
//@returns A readable distance with its unit. Forex Ticks are shown as Pips.
f_dist_text(float d) =>
    bool is_forex = syminfo.type == "forex"
    float pip_size = syminfo.currency == "JPY" ? 0.01 :
     syminfo.basecurrency == "JPY" ? 0.00001 : 0.0001
    string out = switch zone_width_mode
        "Ticks"        => str.tostring(d / (is_forex ? pip_size : syminfo.mintick), "#.##") +
         (is_forex ? " Pips" : " Ticks")
        "Points"       => str.tostring(d, "#.##") + " Pts"
        "Currency ($)" => not na(syminfo.pointvalue) and syminfo.pointvalue > 0 ?
         "$" + str.tostring(d * syminfo.pointvalue, "#.##") : "Currency Unavailable"
        => na(atr_val) or atr_val == 0 ? str.tostring(d, format.mintick) : str.tostring(d / atr_val, "#.##") + " ATR"
    out

//@function Formats the age of a Zone using Bars, Hours, or Days.
//@param age_bars Number of chart Bars since the Zone formed.
//@returns A readable age with its selected time unit.
f_age_text(int age_bars) =>
    float qty  = age_unit == "Bars"  ? age_bars                                    :
     age_unit == "Hours" ? age_bars * timeframe.in_seconds() / 3600.0  :
     age_bars * timeframe.in_seconds() / 86400.0
    string num = age_unit == "Bars" ? str.tostring(age_bars) : str.tostring(qty, age_unit == "Hours" ? "#.#" : "#.##")
    // Use a singular unit only when the calculated age is exactly one.
    string unit = qty == 1.0 ? str.substring(age_unit, 0, str.length(age_unit) - 1) : age_unit
    num + " " + unit

//@function Converts the Age Label Size input to a Pine size constant.
f_age_label_size() =>
    age_label_size == "Small" ? size.small : age_label_size == "Normal" ? size.normal : size.tiny

//@function Applies the selected age palette and optional opacity adjustment.
//@param base_color Base color for the Zone.
//@param age_bars Number of chart Bars since the Zone formed.
//@returns The Zone color for its current age.
f_age_color(color base_color, int age_bars) =>
    color result = base_color
    if age_color_mode == "Auto (Gradient)"
        result := color.from_gradient(age_bars, 0, age_gradient_bars, base_color, age_gradient_end)
    else if age_color_mode == "Preset"
        result := age_bars < age_band1_bars ? color.new(base_color, 70) :
         age_bars < eff_age_old_bars ? color.new(base_color, 82) :
         color.new(base_color, 92)
    else if age_color_mode == "Dark"
        result := age_bars < age_band1_bars ? color.new(color.gray, 72) :
         age_bars < eff_age_old_bars ? color.new(color.gray, 82) :
         color.new(color.gray, 90)
    else if age_color_mode == "Contrast"
        result := age_bars < age_band1_bars ? color.new(color.green, 55) :
         age_bars < eff_age_old_bars ? color.new(color.yellow, 68) :
         color.new(color.red, 80)
    else if age_color_mode == "Warm"
        result := age_bars < age_band1_bars ? color.new(color.yellow, 62) :
         age_bars < eff_age_old_bars ? color.new(color.orange, 74) :
         color.new(color.red, 85)
    else if age_color_mode == "Mono"
        result := age_bars < age_band1_bars ? color.new(base_color, 75) :
         age_bars < eff_age_old_bars ? color.new(base_color, 85) :
         color.new(base_color, 93)
    else if age_color_mode == "Cool"
        result := age_bars < age_band1_bars ? color.new(color.teal, 65) :
         age_bars < eff_age_old_bars ? color.new(color.blue, 77) :
         color.new(#87CEFA, 87)
    else if age_color_mode == "Pastel"
        result := age_bars < age_band1_bars ? color.new(#ADD8E6, 70) :
         age_bars < eff_age_old_bars ? color.new(#E6E6FA, 80) :
         color.new(#FFD1DC, 90)
    else if age_color_mode == "Subdued"
        result := age_bars < age_band1_bars ? color.new(#5F8A8B, 78) :
         age_bars < eff_age_old_bars ? color.new(#6E7B8B, 84) :
         color.new(#8B7B8B, 90)
    if age_color_mode != "Off" and age_opacity != 0
        result := color.new(result, math.max(0, math.min(100, color.t(result) + age_opacity)))
    result

// ── Engine (confirmed Bars) ──
if barstate.isconfirmed
    // Use the selected confirmation basis for both Structure events and Zone breaks.
    float cross_up = structure_confirm == "Body" ? math.min(open, close) : close
    float cross_dn = structure_confirm == "Body" ? math.max(open, close) : close
    string confirm_up_tip = structure_confirm == "Body" ?
     "• Body confirmation — Open and Close cleared above the level." :
     "• Close confirmation — the Bar closed above the level."
    string confirm_dn_tip = structure_confirm == "Body" ?
     "• Body confirmation — Open and Close cleared below the level." :
     "• Close confirmation — the Bar closed below the level."

    // ── E1: Swing Update and Classification ──
    if not na(ph)
        float prior_sh = last_sh
        last_sh     := ph
        last_sh_bar := bar_index - eff_swing
        // Seed the reversal trigger if unset, then tighten it on each new Lower High.
        if struct_dir == -1 and (na(shift_ref_hi) or ph < shift_ref_hi)
            shift_ref_hi     := ph
            shift_ref_hi_bar := bar_index - eff_swing
        if show_swing_labels
            string sh_txt = na(prior_sh) ? "H" : ph > prior_sh ? "HH" : ph < prior_sh ? "LH" : "EH"
            if array.size(swing_labels) >= MAX_SWING_LABELS
                label.delete(array.shift(swing_labels))
            array.push(swing_labels, label.new(last_sh_bar, ph, sh_txt,
             style=label.style_label_down, color=color.new(color.gray, 100),
             textcolor=zone_hi_text_color, size=size.normal,
             tooltip="• Swing High compared with the previous Swing High.\n" +
             "• HH — Higher High.\n" +
             "• EH — Equal High.\n" +
             "• LH — Lower High.\n" +
             "• The first LH after a run of HHs can precede a Shift."))

    if not na(pl)
        float prior_sl = last_sl
        last_sl     := pl
        last_sl_bar := bar_index - eff_swing
        // Seed the reversal trigger if unset, then tighten it on each new Higher Low.
        if struct_dir == 1 and (na(shift_ref_lo) or pl > shift_ref_lo)
            shift_ref_lo     := pl
            shift_ref_lo_bar := bar_index - eff_swing
        if show_swing_labels
            string sl_txt = na(prior_sl) ? "L" : pl > prior_sl ? "HL" : pl < prior_sl ? "LL" : "EL"
            if array.size(swing_labels) >= MAX_SWING_LABELS
                label.delete(array.shift(swing_labels))
            array.push(swing_labels, label.new(last_sl_bar, pl, sl_txt,
             style=label.style_label_up, color=color.new(color.gray, 100),
             textcolor=zone_lo_text_color, size=size.normal,
             tooltip="• Swing Low compared with the previous Swing Low.\n" +
             "• HL — Higher Low.\n" +
             "• EL — Equal Low.\n" +
             "• LL — Lower Low.\n" +
             "• The first LL after a run of HLs can precede a Shift."))

    // ── E2: Structure State Machine ──
    if structure_enable
        if struct_dir == 0
            // When direction is unset, the first confirmed cross establishes
            // the initial direction rather than recording a continuation Break.
            bool boot_up = not na(last_sh) and cross_up > last_sh
            bool boot_dn = not na(last_sl) and cross_dn < last_sl
            if boot_up and boot_dn
                // If both sides clear on one Bar, use the larger excursion.
                if (cross_up - last_sh) >= (last_sl - cross_dn)
                    struct_dir       := 1
                    shift_ref_lo     := last_sl
                    shift_ref_lo_bar := last_sl_bar
                    shift_up_fired   := true
                    shift_initial    := true
                    shift_fire_price := last_sh
                else
                    struct_dir       := -1
                    shift_ref_hi     := last_sh
                    shift_ref_hi_bar := last_sh_bar
                    shift_dn_fired   := true
                    shift_initial    := true
                    shift_fire_price := last_sl
            else if boot_up
                struct_dir       := 1
                shift_ref_lo     := last_sl
                shift_ref_lo_bar := last_sl_bar
                shift_up_fired   := true
                shift_initial    := true
                shift_fire_price := last_sh
            else if boot_dn
                struct_dir       := -1
                shift_ref_hi     := last_sh
                shift_ref_hi_bar := last_sh_bar
                shift_dn_fired   := true
                shift_initial    := true
                shift_fire_price := last_sl

        else if struct_dir == 1
            // Use Swing identity so a later equal-price Swing can fire independently.
            bool brk_up_ready = not na(last_sh) and (na(brk_up_bar) or brk_up_bar != last_sh_bar)
            if brk_up_ready and cross_up > last_sh
                brk_count      += 1
                shift_ref_lo   := last_sl
                shift_ref_lo_bar := last_sl_bar
                brk_up_fired   := true
                brk_up_bar     := last_sh_bar
                brk_fire_price := last_sh
            // A Shift Down occurs when price clears the Swing Low that defined the Up Trend.
            if not na(shift_ref_lo) and cross_dn < shift_ref_lo
                shift_fire_price := shift_ref_lo
                shift_fire_bar   := shift_ref_lo_bar
                struct_dir       := -1
                brk_count        := 0
                shift_ref_lo     := na
                shift_ref_lo_bar := na
                brk_up_bar       := na   // re-arm the break-up guard on flip
                shift_dn_fired   := true

        else if struct_dir == -1
            // Use Swing identity so a later equal-price Swing can fire independently.
            bool brk_dn_ready = not na(last_sl) and (na(brk_dn_bar) or brk_dn_bar != last_sl_bar)
            if brk_dn_ready and cross_dn < last_sl
                brk_count      += 1
                shift_ref_hi   := last_sh
                shift_ref_hi_bar := last_sh_bar
                brk_dn_fired   := true
                brk_dn_bar     := last_sl_bar
                brk_fire_price := last_sl
            // A Shift Up occurs when price clears the Swing High that defined the Down Trend.
            if not na(shift_ref_hi) and cross_up > shift_ref_hi
                shift_fire_price := shift_ref_hi
                shift_fire_bar   := shift_ref_hi_bar
                struct_dir       := 1
                brk_count        := 0
                shift_ref_hi     := na
                shift_ref_hi_bar := na
                brk_dn_bar       := na   // re-arm the break-down guard on flip
                shift_up_fired   := true

    // ── E3: Structure Event Drawing ──
    if brk_up_fired
        last_event_label := "Break"
        last_event_dir   := 1
        last_event_price := brk_fire_price
        last_event_bar   := bar_index
        if show_structure_lines
            f_retire_frozen(struct_up_frozen, frozen_up_hist)
            struct_up_frozen := line.new(last_sh_bar, brk_fire_price, bar_index, brk_fire_price,
             color=frozen_dir_color ? break_up_color : break_line_color,
             style=f_line_style(frozen_line_style), width=frozen_line_width,
             extend=f_line_extend(frozen_line_extend))
        if show_break_labels
            if array.size(event_labels) >= MAX_EVENT_LABELS
                label.delete(array.shift(event_labels))
            array.push(event_labels, label.new(bar_index, brk_fire_price, "Break",
             style=label.style_label_down, color=break_line_color, textcolor=DEFAULT_TEXT_COLOR,
             size=f_event_label_size(),
             tooltip=confirm_up_tip + "\n" +
             "• Cleared the latest Swing High.\n" +
             "• Continues the current tracked direction.\n" +
             "• Break #" + str.tostring(brk_count) + " since the last Shift."))

    if brk_dn_fired
        last_event_label := "Break"
        last_event_dir   := -1
        last_event_price := brk_fire_price
        last_event_bar   := bar_index
        if show_structure_lines
            f_retire_frozen(struct_dn_frozen, frozen_dn_hist)
            struct_dn_frozen := line.new(last_sl_bar, brk_fire_price, bar_index, brk_fire_price,
             color=frozen_dir_color ? break_dn_color : break_line_color,
             style=f_line_style(frozen_line_style), width=frozen_line_width,
             extend=f_line_extend(frozen_line_extend))
        if show_break_labels
            if array.size(event_labels) >= MAX_EVENT_LABELS
                label.delete(array.shift(event_labels))
            array.push(event_labels, label.new(bar_index, brk_fire_price, "Break",
             style=label.style_label_up, color=break_line_color, textcolor=DEFAULT_TEXT_COLOR,
             size=f_event_label_size(),
             tooltip=confirm_dn_tip + "\n" +
             "• Cleared the latest Swing Low.\n" +
             "• Continues the current tracked direction.\n" +
             "• Break #" + str.tostring(brk_count) + " since the last Shift."))

    if shift_up_fired
        string shift_up_txt = shift_initial ? "Shift (Initial)" : "Shift"
        last_event_label := shift_up_txt
        last_event_dir   := 1
        last_event_price := shift_fire_price
        last_event_bar   := bar_index
        if show_structure_lines and not shift_initial and not na(shift_fire_bar)
            f_retire_frozen(struct_up_frozen, frozen_up_hist)
            struct_up_frozen := line.new(shift_fire_bar, shift_fire_price, bar_index, shift_fire_price,
             color=frozen_dir_color ? shift_up_color : shift_line_color,
             style=f_line_style(frozen_line_style), width=frozen_line_width,
             extend=f_line_extend(frozen_line_extend))
        if show_shift_labels
            if array.size(event_labels) >= MAX_EVENT_LABELS
                label.delete(array.shift(event_labels))
            string shift_up_tip = shift_initial ?
             "• First direction assignment on this chart.\n" +
             "• Earliest confirmed clearance beyond a tracked Swing.\n" +
             "• Not a reversal." :
             confirm_up_tip + "\n" +
             "• Cleared the Swing High held during Down direction.\n" +
             "• Flips direction to Up."
            array.push(event_labels, label.new(bar_index, shift_fire_price, shift_up_txt,
             style=label.style_label_up, color=shift_line_color, textcolor=DEFAULT_TEXT_COLOR,
             size=f_event_label_size(), tooltip=shift_up_tip))

    if shift_dn_fired
        string shift_dn_txt = shift_initial ? "Shift (Initial)" : "Shift"
        last_event_label := shift_dn_txt
        last_event_dir   := -1
        last_event_price := shift_fire_price
        last_event_bar   := bar_index
        if show_structure_lines and not shift_initial and not na(shift_fire_bar)
            f_retire_frozen(struct_dn_frozen, frozen_dn_hist)
            struct_dn_frozen := line.new(shift_fire_bar, shift_fire_price, bar_index, shift_fire_price,
             color=frozen_dir_color ? shift_dn_color : shift_line_color,
             style=f_line_style(frozen_line_style), width=frozen_line_width,
             extend=f_line_extend(frozen_line_extend))
        if show_shift_labels
            if array.size(event_labels) >= MAX_EVENT_LABELS
                label.delete(array.shift(event_labels))
            string shift_dn_tip = shift_initial ?
             "• First direction assignment on this chart.\n" +
             "• Earliest confirmed clearance beyond a tracked Swing.\n" +
             "• Not a reversal." :
             confirm_dn_tip + "\n" +
             "• Cleared the Swing Low held during Up direction.\n" +
             "• Flips direction to Down."
            array.push(event_labels, label.new(bar_index, shift_fire_price, shift_dn_txt,
             style=label.style_label_down, color=shift_line_color, textcolor=DEFAULT_TEXT_COLOR,
             size=f_event_label_size(), tooltip=shift_dn_tip))

    // ── E4: Zone Creation and Cluster Merge ──
    if show_zones and not na(ph)
        f_zone_upsert(zones_hi, ph, atr_val[eff_swing], last_sh_bar, 1, zone_hi_color, "Swing High")

    if show_zones and not na(pl)
        f_zone_upsert(zones_lo, pl, atr_val[eff_swing], last_sl_bar, -1, zone_lo_color, "Swing Low")

    // ── E5: Zone Lifecycle and Breaks ──
    // Zone Break Basis selects either the Structure confirmation rule or a wick touch.
    int   hi_zb_n  = 0
    float hi_zb_px = na
    int   lo_zb_n  = 0
    float lo_zb_px = na
    if show_zones
        bool touch_basis = zone_break_basis == "Touch (High/Low)"
        float zx_up = touch_basis ? high : cross_up
        float zx_dn = touch_basis ? low  : cross_dn
        [hn, hp] = f_zone_lifecycle(zones_hi, 1, zx_up, touch_basis)
        [ln, lp] = f_zone_lifecycle(zones_lo, -1, zx_dn, touch_basis)
        hi_zb_n  := hn
        hi_zb_px := hp
        lo_zb_n  := ln
        lo_zb_px := lp
        if array.size(broken_zones) > 0
            for i = array.size(broken_zones) - 1 to 0
                if bar_index >= array.get(broken_zones, i).expire_bar
                    box.delete(array.get(broken_zones, i).box_obj)
                    array.remove(broken_zones, i)

    // ── E6: Composite Alert ──
    // Combine all confirmed events from the current Bar into one message.
    if dyn_alerts
        string alert_msg = ""
        if brk_up_fired
            alert_msg += "Structure Break Up @ " + str.tostring(brk_fire_price) + "; "
        if brk_dn_fired
            alert_msg += "Structure Break Down @ " + str.tostring(brk_fire_price) + "; "
        if shift_up_fired
            alert_msg += "Structure Shift Up @ " + str.tostring(shift_fire_price) + "; "
        if shift_dn_fired
            alert_msg += "Structure Shift Down @ " + str.tostring(shift_fire_price) + "; "
        if zone_break_alerts
            if hi_zb_n > 0
                alert_msg += hi_zb_n > 1 ?
                 "Swing High Zones Broken ×" + str.tostring(hi_zb_n) + "; Farthest Edge @ " +
                 str.tostring(hi_zb_px) + "; " :
                 "Swing High Zone Broken @ " + str.tostring(hi_zb_px) + "; "
            if lo_zb_n > 0
                alert_msg += lo_zb_n > 1 ?
                 "Swing Low Zones Broken ×" + str.tostring(lo_zb_n) + "; Farthest Edge @ " +
                 str.tostring(lo_zb_px) + "; " :
                 "Swing Low Zone Broken @ " + str.tostring(lo_zb_px) + "; "
        if str.length(alert_msg) > 0
            alert("MSSL " + syminfo.ticker + ": " + alert_msg, alert.freq_once_per_bar)

// ── Draw Pass (latest Bar) ──
// Redraw the live right edge on the current Bar while confirmed Swing values
// and their origin Bars remain unchanged.
if barstate.islast
    if not na(struct_sh_line)
        line.delete(struct_sh_line)
        struct_sh_line := na
    if not na(struct_sl_line)
        line.delete(struct_sl_line)
        struct_sl_line := na
    if not na(shift_trigger_line)
        line.delete(shift_trigger_line)
        shift_trigger_line := na
    if structure_enable and show_structure_lines
        if not na(last_sh)
            struct_sh_line := line.new(last_sh_bar, last_sh, bar_index, last_sh,
             color=live_line_color, style=f_line_style(live_line_style), width=live_line_width)
        if not na(last_sl)
            struct_sl_line := line.new(last_sl_bar, last_sl, bar_index, last_sl,
             color=live_line_color, style=f_line_style(live_line_style), width=live_line_width)
    if structure_enable and show_shift_trigger
        float trig_px   = struct_dir == 1 ? shift_ref_lo : struct_dir == -1 ? shift_ref_hi : na
        int   trig_from = struct_dir == 1 ? shift_ref_lo_bar : struct_dir == -1 ? shift_ref_hi_bar : na
        if not na(trig_px) and not na(trig_from)
            shift_trigger_line := line.new(trig_from, trig_px, bar_index, trig_px,
             color=shift_trigger_color, style=f_line_style(shift_trigger_style), width=1)

    // ── Zone Age: labels and colors ──
    if array.size(age_labels) > 0
        for i = array.size(age_labels) - 1 to 0
            label.delete(array.get(age_labels, i))
        array.clear(age_labels)

    if array.size(zones_hi) > 0
        for i = 0 to array.size(zones_hi) - 1
            SwingZone z = array.get(zones_hi, i)
            int age_bars = bar_index - z.origin_bar
            color c = f_age_color(zone_hi_color, age_bars)
            box.set_bgcolor(z.box_obj, c)
            box.set_border_color(z.box_obj, c)
            if cluster_label_position == "Right Edge" and not na(z.label_obj)
                label.set_x(z.label_obj, bar_index)
            if show_zone_age
                array.push(age_labels, label.new(bar_index, z.price, f_age_text(age_bars),
                 style=cluster_label_position == "Right Edge" and not na(z.label_obj) ?
                  label.style_label_right : label.style_label_left,
                 color=color.new(color.gray, 100),
                 textcolor=age_label_color, size=f_age_label_size(),
                 tooltip="• Age of this Swing High Zone.\n" +
                 "• Cluster age begins at the oldest member Swing.\n" +
                 "• Displayed in the selected Age Unit."))

    if array.size(zones_lo) > 0
        for i = 0 to array.size(zones_lo) - 1
            SwingZone z = array.get(zones_lo, i)
            int age_bars = bar_index - z.origin_bar
            color c = f_age_color(zone_lo_color, age_bars)
            box.set_bgcolor(z.box_obj, c)
            box.set_border_color(z.box_obj, c)
            if cluster_label_position == "Right Edge" and not na(z.label_obj)
                label.set_x(z.label_obj, bar_index)
            if show_zone_age
                array.push(age_labels, label.new(bar_index, z.price, f_age_text(age_bars),
                 style=cluster_label_position == "Right Edge" and not na(z.label_obj) ?
                  label.style_label_right : label.style_label_left,
                 color=color.new(color.gray, 100),
                 textcolor=age_label_color, size=f_age_label_size(),
                 tooltip="• Age of this Swing Low Zone.\n" +
                 "• Cluster age begins at the oldest member Swing.\n" +
                 "• Displayed in the selected Age Unit."))

    // ── Dashboard: Structure and Zone Context ──
    if not na(dashboard)
        table.delete(dashboard)
        dashboard := na
    if show_dashboard
        int dash_rows = show_nearest_zone ? 5 : 3
        dashboard := table.new(dash_pos(), 2, dash_rows,
         bgcolor=color.new(color.black, 13), frame_color=color.new(color.gray, 40), frame_width=1,
         border_color=color.new(color.gray, 70), border_width=1)
        string dsz     = f_dash_text_size()
        color  hdr_col = DEFAULT_TEXT_COLOR

        string dir_txt = struct_dir == 1 ?
         "Up Trend · " + str.tostring(brk_count) + " Break" + (brk_count == 1 ? "" : "s") + " Since Last Shift" :
         struct_dir == -1 ?
         "Down Trend · " + str.tostring(brk_count) + " Break" + (brk_count == 1 ? "" : "s") + " Since Last Shift" :
         "Unset — No Shift Confirmed Yet"
        color  dir_col = DEFAULT_TEXT_COLOR
        f_cell_l(dashboard, 0, "DIRECTION", hdr_col, dsz)
        f_cell_v(dashboard, 0, dir_txt, dir_col, dsz,
         "• Tracked direction and Break count since the last Shift.\n" +
         "• Resets to 0 at each Shift.\n" +
         "• Context, not a signal.")

        string evt_kind = na(last_event_label) ? "" : last_event_label == "Break" ? "Structure Break" : last_event_label
        string evt_txt = na(last_event_label) ? "—" :
         evt_kind + ", " + (last_event_dir == 1 ? "Up" : "Down") + " @ " + str.tostring(last_event_price) +
         " (" + str.tostring(bar_index - last_event_bar) + " Bars Ago)"
        color  evt_col = DEFAULT_TEXT_COLOR
        f_cell_l(dashboard, 1, "LAST EVENT", hdr_col, dsz)
        f_cell_v(dashboard, 1, evt_txt, evt_col, dsz,
         "• Most recent confirmed Break or Shift: type, direction, price, and Bars Since.\n" +
         "• 'Shift (Initial)' = first direction assignment, not a reversal.")

        int cluster_hi = 0
        if array.size(zones_hi) > 0
            for i = 0 to array.size(zones_hi) - 1
                if array.get(zones_hi, i).merge_count > 1
                    cluster_hi += 1
        int cluster_lo = 0
        if array.size(zones_lo) > 0
            for i = 0 to array.size(zones_lo) - 1
                if array.get(zones_lo, i).merge_count > 1
                    cluster_lo += 1
        int    total_clusters = cluster_hi + cluster_lo
        string zones_txt = str.tostring(array.size(zones_hi)) + " High / " +
         str.tostring(array.size(zones_lo)) + " Low" +
         (total_clusters > 0 ? "  (" + str.tostring(total_clusters) + " Cluster" +
         (total_clusters == 1 ? "" : "s") + ")" : "")
        f_cell_l(dashboard, 2, "ZONES", hdr_col, dsz)
        f_cell_v(dashboard, 2, zones_txt, DEFAULT_TEXT_COLOR, dsz,
         "• Active Swing High and Swing Low zones.\n" +
         "• A Cluster = 2 or more confirmed swings merged into the same band.")

        if show_nearest_zone
            [ab_dist, ab_inside] = f_zone_above(close)
            [bl_dist, bl_inside] = f_zone_below(close)
            string ab_txt = ab_inside ? "Inside Swing High Zone" : na(ab_dist) ? "—" : f_dist_text(ab_dist)
            string bl_txt = bl_inside ? "Inside Swing Low Zone"  : na(bl_dist) ? "—" : f_dist_text(bl_dist)
            f_cell_l(dashboard, 3, "ZONE ABOVE", hdr_col, dsz)
            f_cell_v(dashboard, 3, ab_txt, DEFAULT_TEXT_COLOR, dsz,
             "• Distance from current price up to the nearest active Swing High zone edge.\n" +
             "• Reported in the same unit as Zone Width Mode: ATR multiples, Ticks, Points, or Currency.\n" +
             "• Forex under Ticks mode reports Pips.")
            f_cell_l(dashboard, 4, "ZONE BELOW", hdr_col, dsz)
            f_cell_v(dashboard, 4, bl_txt, DEFAULT_TEXT_COLOR, dsz,
             "• Distance from current price down to the nearest active Swing Low zone edge.\n" +
             "• Reported in the same unit as Zone Width Mode: ATR multiples, Ticks, Points, or Currency.\n" +
             "• Forex under Ticks mode reports Pips.")

// ── Alerts ──
alertcondition(brk_up_fired,   "MSSL 1 · Structure Break Up",
     "MSSL: confirmed clearance above the prior swing high — trend continuation")
alertcondition(brk_dn_fired,   "MSSL 2 · Structure Break Down",
     "MSSL: confirmed clearance below the prior swing low — trend continuation")
alertcondition(shift_up_fired, "MSSL 3 · Structure Shift Up",
     "MSSL: confirmed clearance above the swing high held while direction was down — structure flipped up")
alertcondition(shift_dn_fired, "MSSL 4 · Structure Shift Down",
     "MSSL: confirmed clearance below the swing low held while direction was up — structure flipped down")
````
