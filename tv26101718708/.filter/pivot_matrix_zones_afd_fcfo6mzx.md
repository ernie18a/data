# Pivot Matrix + Zones [AFD]

- url: https://www.tradingview.com/script/fCFO6mZX-Pivot-Matrix-Zones-AFD/
- type: indicator
- pine_id: PUB;242e964170e04ce281c71a624fcc324d
- version: 3.0

## Description

[b]Overview[/b]
Pivot Matrix + Zones [AFD] brings up to three independently configured pivot systems into one coordinated overlay. It combines exact pivot ladders, standard Central Pivot Range (CPR), ATR- or tick-scaled reaction zones, formula-aware cross-pack confluence, retained untested levels, a compact context dashboard, and seven bar-close alert conditions.
Each pack can use a different formula and anchor, allowing combinations such as Daily Traditional, Daily Camarilla, and Weekly Fibonacci to be compared without merging their identities.

The script is designed for descriptive market context. It does not produce trade recommendations, forecasts, performance statistics, or automated orders.

[b]What makes it different[/b]
The script's original contribution is its identity-aware coordination of the three packs rather than a simple stack of pivot lines. Each pack has its own formula, anchor, tier ceiling, formula-pivot and CPR visibility, labels, R/S color, and line style. One shared lifecycle model freezes reaction width at origin, carries formula and anchor provenance into retained levels and alerts, and keeps dashboard and drawing state aligned.

[image]https://www.tradingview.com/x/5AacNlbF/[/image]

Confluence requires overlapping reaction zones from at least two distinct enabled packs. Multiple levels or historical origins from only one pack do not create confluence, and duplicate canonical levels do not inflate the displayed pack count. Exact formula-and-anchor duplicates are marked inactive instead of drawing the same configuration twice.

The implementation and lifecycle logic are original. The named pivot methods use standard published calculations identified below; no third-party indicator source code is reused.

[b]Pivot formulas and anchors[/b]
The three packs can use Traditional, Floor Pivots, Fibonacci, Woodie, Classic, DM, Camarilla, Frank Dilernia, Shadow Trader, or ACD Method calculations. Traditional, Fibonacci, Woodie, Classic, DM, and Camarilla use the formulas documented for TradingView Pivot Points Standard. Floor Pivots uses the standard prior-period high, low, and close ladder through R3/S3; those levels match Traditional through the third tier, while Traditional retains its additional R4/R5 extensions. 

Available anchors are Auto, Daily, Weekly, Monthly, Quarterly, and Yearly. Auto uses Daily pivots on chart resolutions through 15 minutes, Weekly pivots above 15 minutes and below one day, and Monthly pivots on daily-or-higher charts.

Each formula stops at its documented native tier. The Through Rn/Sn controls do not create unsupported extension levels. Camarilla calculations use the standard R/S equations and display H/L aliases alongside those names.

[b]Data and session handling[/b]
Use daily-based values to request anchor data from the selected symbol context. Exchange default, RTH, and ETH choices are available. For futures, ETH uses the exchange-default electronic context, while RTH uses the named subsession entered in the settings. The default futures RTH name is us_regular, but valid names are symbol-specific.

On intraday charts, turning daily-based values off builds anchor values from the chart feed. This may reflect a visible session more closely, but Quarterly or Yearly anchors can have insufficient intraday history. On daily-or-higher charts, the script continues to use daily-based anchor data.

Most formulas use completed prior-anchor values. Woodie also uses the fixed open of the active anchor. The optional developing next CPR uses the active anchor's changing high, low, and close; it is visually separated and never enters confluence, retained history, or alerts.

[b]CPR and reaction zones[/b]
[image]https://www.tradingview.com/x/cfGUIWCG/[/image]

CPR always uses the standard floor-pivot calculation from the completed period's high, low, and close. Its chart labels identify the center as PP, the lower Bottom Central boundary as Lower (BC), and the upper Top Central boundary as Upper (TC). This CPR pivot remains separate from a formula pivot when methods such as Woodie or DM produce a different value.
Reaction zones are symmetric bands around exact pivot prices. Their half-width can use confirmed Daily ATR, completed anchor ATR, or a fixed number of minimum ticks. The width is frozen when an anchor's geometry is created, so an existing zone does not drift as ATR changes inside that anchor. The exact pivot remains the center line; the surrounding fill is a configurable context band.

[b]How to read the chart[/b]
Exact center lines are the calculated PP, resistance, support, or CPR levels. Soft surrounding fills show the configured interaction distance; they are not additional pivot levels or predictive outputs.

By default, formula PP lines and matching fills are yellow, Pack A R/S lines and fills are blue, and CPR boundaries and the central range are purple. Active labels identify Formula + Level, while CPR labels distinguish PP, Lower (BC), and Upper (TC). Price text is optional and hidden by default.

[b]Confluence and retained levels[/b]
When eligible reaction zones from at least two distinct packs overlap, the script merges the overlap transitively into a confluence band. Each label names the unique contributing formulas and then shows the number of distinct packs represented, such as Traditional + Fibonacci x2. Enable confluence is the master control and is on by default. Turning it off removes confluence zones and labels and suppresses Confluence Touch events while the pivot packs, dashboard, retained-level lifecycle, and other alerts continue. When enabled, confluence color, text color, and projection change the display only, not the overlap or alert identity.

At an anchor rollover, eligible pivot zones that were not touched during their active period can be retained as Untested. A later confirmed wick overlap changes the record to TESTED, freezes and fades its drawing for 20 chart bars, and removes it afterward. Retained drawings are off by default, but lifecycle tracking, dashboard counts, confluence eligibility, and fill alerts continue while the drawings are hidden.

[b]Dashboard[/b]
The compact dashboard shows only enabled packs with their selected pivot formula and any non-active status. It then classifies the two-period CPR relationship, reports whether the active-anchor open is above, below, or inside CPR, and shows the nearest retained untested level with the live count across all packs. CPR context follows the first enabled pack in A/B/C order.

[b]Display controls[/b]
Active geometry can end at a finite current-bar offset, at the anchor end, or extend right. Confluence has its own finite current-bar, finite label-offset, and extend-right choices. Show confluence only hides non-confluence drawings while confluence is enabled; turning the master control off restores the normal layers. Calculations, the dashboard, lifecycle processing, and all enabled alerts continue.

Formula PP, CPR, labels, displayed prices, label size, line width, reaction shading, tier depth, and retained-level styling can be adjusted independently. Formula PP lines and fills default to yellow, Pack A R/S lines and fills default to blue, and CPR boundaries and the central range default to purple. The Inputs tab follows a numbered workflow and dims controls that do not apply without disabling calculations that still use their state. Prices are hidden by default, and chart labels identify formula and level without A/B/C prefixes; dashboard and alert provenance retain pack identity. Duplicate formula-and-anchor pack configurations are rejected rather than drawn twice.

[b]Suggested setup workflow[/b]
Configure Pack A as the primary context, then enable Pack B or C when a second formula, anchor, or both are needed for comparison. Choose the highest native R/S tier, session basis, reaction-width method, and projection for the chart being reviewed. Use the dashboard and labels for identity, Show confluence only to isolate cross-pack overlaps, and retained-level drawings when the untested lifecycle should remain visible.

Create alerts only after the symbol, timeframe, sessions, pack settings, and reaction-width inputs are finalized, because those chart settings define the levels and events being monitored.

[b]Alerts[/b]
Seven fixed conditions are available: Active Level Touch, Cross Up, Cross Down, CPR Enter, CPR Exit, Untested Level Filled, and Confluence Touch. Events confirm at chart-bar close. Optional dynamic messages aggregate supported events from the same confirmed bar and include available pack, formula, anchor, level, origin, and price context. TradingView running alerts retain the script inputs saved when they were created, so delete and recreate an alert after changing Enable confluence or another input.

[b]Limitations[/b]
Pivot values and rollover timing depend on the selected symbol, data feed, anchor, session context, and available history. Daily and intraday feeds can differ because of extended hours, futures settlements, and feed construction. An invalid futures subsession name can fall back to the exchange default, so confirm the requested name in Inputs and compare the resulting pivots with the intended session.

Reaction zones and confluence visualize proximity; they do not predict a response. Untested means the configured zone was not touched during its tracked active period; it does not imply that price must revisit or react to it.

Use a standard time-based chart when evaluating touches, crosses, and alerts because those events use the chart's OHLC bars. Alerts still depend on TradingView alert creation, chart settings, feed updates, and bar-close processing.

The script keeps bounded histories of up to 30 live untested levels and 20 fading tested markers, with older retained records removed as those limits are reached. Confluence display is capped at 20 zones.

This is a public open-source Pine Script v6 indicator with a Mozilla Public License 2.0 source header. TradingView's open-source reuse rules apply on-platform before the license terms. It is an educational charting tool and is not financial advice.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0.
// If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
// © Auction Foundry

//@version=6
indicator(
     title = "Pivot Matrix + Zones [AFD]",
     shorttitle = "PMZ [AFD]",
     overlay = true,
     max_lines_count = 200,
     max_boxes_count = 150,
     max_labels_count = 150,
     dynamic_requests = true)

// Constants

const string FORMULA_FLOOR_PIVOTS = "Floor Pivots"
const string FORMULA_FIBONACCI = "Fibonacci"
const string FORMULA_WOODIE = "Woodie"
const string FORMULA_CLASSIC = "Classic"
const string FORMULA_DM = "DM"
const string FORMULA_CAMARILLA = "Camarilla"
const string FORMULA_FRANK_DILERNIA = "Frank Dilernia"
const string FORMULA_SHADOW_TRADER = "Shadow Trader"
const string FORMULA_ACD_METHOD = "ACD Method"

const string ANCHOR_AUTO = "Auto"
const string ANCHOR_DAILY = "Daily"
const string ANCHOR_WEEKLY = "Weekly"
const string ANCHOR_MONTHLY = "Monthly"
const string ANCHOR_QUARTERLY = "Quarterly"
const string ANCHOR_YEARLY = "Yearly"

const string ZONE_DAILY_ATR = "Daily ATR"
const string ZONE_ANCHOR_ATR = "Anchor ATR"
const string ZONE_TICKS = "Ticks"

const string SESSION_EXCHANGE_DEFAULT = "Exchange default"
const string SESSION_RTH = "RTH"
const string SESSION_ETH = "ETH"

const string PROJECTION_CURRENT_OFFSET = "Current + offset"
const string PROJECTION_ANCHOR_END = "Anchor end"
const string PROJECTION_EXTEND_RIGHT = "Extend right"

const string CONFLUENCE_CURRENT_BAR = "Current bar"
const string CONFLUENCE_LABEL_OFFSET = "At label offset"
const string CONFLUENCE_EXTEND_RIGHT = "Extend right"

const string TIER_1 = "Through R1/S1"
const string TIER_2 = "Through R2/S2"
const string TIER_3 = "Through R3/S3"
const string TIER_4 = "Through R4/S4"
const string TIER_5 = "Through R5/S5"

const string PRESET_SIMPLE = "Simple"
const string PRESET_FULL = "Full"

const string SCOPE_CORE = "Core"
const string SCOPE_ENABLED = "All enabled levels"
const string SCOPE_VISIBLE = "All visible levels"

const int MAX_UNTESTED = 30
const int MAX_TESTED = 20
const int MAX_CONFLUENCE = 20
const int STATUS_LABEL_LANES = 8
const int STATUS_LABEL_LANE_BARS = 12

const string GROUP_GENERAL = "00 · Chart"
const string GROUP_DATA = "01 · Data & Sessions"
const string GROUP_PACK_A = "02 · Pack A — Primary"
const string GROUP_PACK_B = "03 · Pack B — Optional"
const string GROUP_PACK_C = "04 · Pack C — Optional"
const string GROUP_LEVELS = "05 · Active Levels & Labels"
const string GROUP_ZONES = "06 · Reaction Zones"
const string GROUP_CONTEXT = "07 · Context & Confluence"
const string GROUP_UNTESTED = "08 · Level Test Status"
const string GROUP_ALERTS = "09 · Alerts"

const string INLINE_PACK_A_VISIBILITY = "pack_a_visibility"
const string INLINE_PACK_A_APPEARANCE = "pack_a_appearance"
const string INLINE_PACK_B_VISIBILITY = "pack_b_visibility"
const string INLINE_PACK_B_APPEARANCE = "pack_b_appearance"
const string INLINE_PACK_C_VISIBILITY = "pack_c_visibility"
const string INLINE_PACK_C_APPEARANCE = "pack_c_appearance"
const string INLINE_CORE_COLORS = "core_colors"
const string INLINE_ATR_SETTINGS = "atr_settings"
const string INLINE_DASHBOARD = "dashboard"
const string INLINE_CONFLUENCE_COLORS = "confluence_colors"
const string INLINE_STATUS_COLORS = "status_colors"
const string INLINE_STATUS_STYLES = "status_styles"

const string PRESET_TOOLTIP = "• Simple: shows CPR, PP, and R1/S1 only for a clean default chart.\n• Full: shows every tier each pack selects.\n• Does not change pivot math, tracking, or alerts."
const string TIERS_TOOLTIP = "• Sets the highest R/S tier drawn for this pack.\n• Includes every lower tier.\n• Stops at the formula's native maximum."
const string SESSION_TOOLTIP = "• Exchange default: standard symbol session.\n• RTH: regular-session context.\n• ETH: extended/electronic context.\n• Applies only to daily-based values; chart-derived mode follows the chart feed."
const string FUTURES_RTH_TOOLTIP = "• Names the TradingView subsession used for futures RTH.\n• Default: us_regular.\n• Verify per symbol; an invalid name can fall back to Exchange default."
const string PROJECTION_TOOLTIP = "• Current + offset: finite edge at the label offset.\n• Anchor end: finite edge at the pivot-period close.\n• Extend right: no finite edge.\n• Applies to active pivots, CPR, labels, and fills; confluence uses its own setting."
const string CONFLUENCE_TOOLTIP = "• On: builds overlaps from at least two distinct enabled packs.\n• Labels list unique formulas in Pack A–C order.\n• Left edge marks when all active/retained contributors existed; newer overlaps appear shorter.\n• Off: removes confluence drawings and touch events; pivots, dashboard, retained tracking, and other alerts continue.\n• Recreate active TradingView alerts after changing this input."
const string ENABLE_PACK_TOOLTIP = "• On: includes this pack in drawings, dashboard context, retained tracking, confluence, and alerts.\n• Off: excludes the pack from those features."
const string FORMULA_TOOLTIP = "• Selects this pack's pivot ladder.\n• With the dashboard shown, hover the selected formula for equations.\n• Hidden PP still drives R/S calculations."
const string ANCHOR_TOOLTIP = "• Selects the completed period that supplies pivot data.\n• Auto follows TradingView Pivot Points Standard's chart-timeframe mapping."
const string PACK_VISIBILITY_TOOLTIP = "• PP: toggles the formula pivot in drawings, signals, confluence, and retained tracking; R/S math stays active.\n• CPR: toggles its independent PP, Lower (BC), and Upper (TC) drawings only; pack A's CPR Enter and CPR Exit alerts keep firing while it is hidden.\n• Labels: toggles active labels; global price and size settings still apply."
const string PACK_APPEARANCE_TOOLTIP = "• Color: base R/S lines, labels, and fills.\n• Style: base PP, R/S, and CPR line style.\n• Test-status colors and styles override these when enabled."
const string CORE_COLORS_TOOLTIP = "• PP: base formula PP and distinct CPR PP color.\n• CPR range: base Lower/Upper color.\n• Test-status colors override both when enabled."
const string ATR_SETTINGS_TOOLTIP = "• ATR length: Wilder lookback for Daily ATR and Anchor ATR.\n• Width per side: ATR fraction above and below each level; 0.05 = 5%.\n• Does not change pivot prices."
const string DASHBOARD_TOOLTIP = "• Show dashboard: toggles the table only.\n• Text size: Tiny, Small, or Normal for the table.\n• Calculations, tracking, and alerts continue while hidden."
const string CONFLUENCE_COLORS_TOOLTIP = "• Zone: base box and label color.\n• Text: confluence label text color.\n• Test-status color/style overrides the zone only."
const string STATUS_COLORS_TOOLTIP = "• Untested: before the first confirmed wick touch.\n• Tested: after that touch.\n• Applies to eligible lines, fills, and labels only."
const string STATUS_STYLES_TOOLTIP = "• Sets the line or border style for each status.\n• Does not change prices, touch geometry, or alerts."

// Inputs

string chartPresetInput = input.string(
     PRESET_SIMPLE,
     "Chart preset",
     options = [PRESET_SIMPLE, PRESET_FULL],
     tooltip = PRESET_TOOLTIP,
     group = GROUP_GENERAL,
     display = display.none)
bool useDailyBasedInput = input.bool(
     true,
     "Use daily-based values",
     tooltip = "• On: requests completed standard-symbol anchor data for the selected session.\n• Off: intraday charts aggregate anchor OHLC from the chart feed.\n• Daily-or-higher charts remain daily-based.",
     group = GROUP_DATA,
     display = display.none)
string sessionBasisInput = input.string(
     SESSION_EXCHANGE_DEFAULT,
     "Session basis",
     options = [SESSION_EXCHANGE_DEFAULT, SESSION_RTH, SESSION_ETH],
     tooltip = SESSION_TOOLTIP,
     group = GROUP_DATA,
     display = display.none,
     active = useDailyBasedInput)
string futuresRthSessionInput = input.string(
     "us_regular",
     "Futures RTH session name",
     tooltip = FUTURES_RTH_TOOLTIP,
     group = GROUP_DATA,
     display = display.none,
     active = useDailyBasedInput and sessionBasisInput == SESSION_RTH)

bool packAEnabledInput = input.bool(
     true,
     "Enable pack A",
     tooltip = ENABLE_PACK_TOOLTIP,
     group = GROUP_PACK_A,
     display = display.none)
string packAFormulaInput = input.string(
     FORMULA_SHADOW_TRADER,
     "Formula",
     options = [FORMULA_FLOOR_PIVOTS, FORMULA_FIBONACCI, FORMULA_WOODIE, FORMULA_CLASSIC, FORMULA_DM, FORMULA_CAMARILLA, FORMULA_FRANK_DILERNIA, FORMULA_SHADOW_TRADER, FORMULA_ACD_METHOD],
     tooltip = FORMULA_TOOLTIP,
     group = GROUP_PACK_A,
     display = display.none,
     active = packAEnabledInput)
string packAAnchorInput = input.string(
     ANCHOR_AUTO,
     "Anchor",
     options = [ANCHOR_AUTO, ANCHOR_DAILY, ANCHOR_WEEKLY, ANCHOR_MONTHLY, ANCHOR_QUARTERLY, ANCHOR_YEARLY],
     tooltip = ANCHOR_TOOLTIP,
     group = GROUP_PACK_A,
     display = display.none,
     active = packAEnabledInput)
string packATierChoiceInput = input.string(
     TIER_3,
     "Highest R/S tier",
     options = [TIER_1, TIER_2, TIER_3, TIER_4, TIER_5],
     tooltip = TIERS_TOOLTIP,
     group = GROUP_PACK_A,
     display = display.none,
     active = packAEnabledInput)
bool packAShowFormulaPpInput = input.bool(
     true,
     "Show PP",
     tooltip = PACK_VISIBILITY_TOOLTIP,
     inline = INLINE_PACK_A_VISIBILITY,
     group = GROUP_PACK_A,
     display = display.none,
     active = packAEnabledInput)
bool packAShowCprInput = input.bool(
     true,
     "CPR",
     tooltip = PACK_VISIBILITY_TOOLTIP,
     inline = INLINE_PACK_A_VISIBILITY,
     group = GROUP_PACK_A,
     display = display.none,
     active = packAEnabledInput)
bool packAShowLabelsInput = input.bool(
     true,
     "Labels",
     tooltip = PACK_VISIBILITY_TOOLTIP,
     inline = INLINE_PACK_A_VISIBILITY,
     group = GROUP_PACK_A,
     display = display.none,
     active = packAEnabledInput)
color packAColorInput = input.color(
     color.blue,
     "R/S color",
     tooltip = PACK_APPEARANCE_TOOLTIP,
     inline = INLINE_PACK_A_APPEARANCE,
     group = GROUP_PACK_A,
     display = display.none,
     active = packAEnabledInput)
string packAStyleInput = input.string(
     "Solid",
     "Style",
     options = ["Solid", "Dashed", "Dotted"],
     tooltip = PACK_APPEARANCE_TOOLTIP,
     inline = INLINE_PACK_A_APPEARANCE,
     group = GROUP_PACK_A,
     display = display.none,
     active = packAEnabledInput)

bool packBEnabledInput = input.bool(
     false,
     "Enable pack B",
     tooltip = ENABLE_PACK_TOOLTIP,
     group = GROUP_PACK_B,
     display = display.none)
string packBFormulaInput = input.string(
     FORMULA_CAMARILLA,
     "Formula",
     options = [FORMULA_FLOOR_PIVOTS, FORMULA_FIBONACCI, FORMULA_WOODIE, FORMULA_CLASSIC, FORMULA_DM, FORMULA_CAMARILLA, FORMULA_FRANK_DILERNIA, FORMULA_SHADOW_TRADER, FORMULA_ACD_METHOD],
     tooltip = FORMULA_TOOLTIP,
     group = GROUP_PACK_B,
     display = display.none,
     active = packBEnabledInput)
string packBAnchorInput = input.string(
     ANCHOR_AUTO,
     "Anchor",
     options = [ANCHOR_AUTO, ANCHOR_DAILY, ANCHOR_WEEKLY, ANCHOR_MONTHLY, ANCHOR_QUARTERLY, ANCHOR_YEARLY],
     tooltip = ANCHOR_TOOLTIP,
     group = GROUP_PACK_B,
     display = display.none,
     active = packBEnabledInput)
string packBTierChoiceInput = input.string(
     TIER_4,
     "Highest R/S tier",
     options = [TIER_1, TIER_2, TIER_3, TIER_4, TIER_5],
     tooltip = TIERS_TOOLTIP,
     group = GROUP_PACK_B,
     display = display.none,
     active = packBEnabledInput)
bool packBShowFormulaPpInput = input.bool(
     true,
     "Show PP",
     tooltip = PACK_VISIBILITY_TOOLTIP,
     inline = INLINE_PACK_B_VISIBILITY,
     group = GROUP_PACK_B,
     display = display.none,
     active = packBEnabledInput)
bool packBShowCprInput = input.bool(
     false,
     "CPR",
     tooltip = PACK_VISIBILITY_TOOLTIP,
     inline = INLINE_PACK_B_VISIBILITY,
     group = GROUP_PACK_B,
     display = display.none,
     active = packBEnabledInput)
bool packBShowLabelsInput = input.bool(
     false,
     "Labels",
     tooltip = PACK_VISIBILITY_TOOLTIP,
     inline = INLINE_PACK_B_VISIBILITY,
     group = GROUP_PACK_B,
     display = display.none,
     active = packBEnabledInput)
color packBColorInput = input.color(
     color.rgb(255, 152, 0),
     "R/S color",
     tooltip = PACK_APPEARANCE_TOOLTIP,
     inline = INLINE_PACK_B_APPEARANCE,
     group = GROUP_PACK_B,
     display = display.none,
     active = packBEnabledInput)
string packBStyleInput = input.string(
     "Dashed",
     "Style",
     options = ["Solid", "Dashed", "Dotted"],
     tooltip = PACK_APPEARANCE_TOOLTIP,
     inline = INLINE_PACK_B_APPEARANCE,
     group = GROUP_PACK_B,
     display = display.none,
     active = packBEnabledInput)

bool packCEnabledInput = input.bool(
     false,
     "Enable pack C",
     tooltip = ENABLE_PACK_TOOLTIP,
     group = GROUP_PACK_C,
     display = display.none)
string packCFormulaInput = input.string(
     FORMULA_FIBONACCI,
     "Formula",
     options = [FORMULA_FLOOR_PIVOTS, FORMULA_FIBONACCI, FORMULA_WOODIE, FORMULA_CLASSIC, FORMULA_DM, FORMULA_CAMARILLA, FORMULA_FRANK_DILERNIA, FORMULA_SHADOW_TRADER, FORMULA_ACD_METHOD],
     tooltip = FORMULA_TOOLTIP,
     group = GROUP_PACK_C,
     display = display.none,
     active = packCEnabledInput)
string packCAnchorInput = input.string(
     ANCHOR_WEEKLY,
     "Anchor",
     options = [ANCHOR_AUTO, ANCHOR_DAILY, ANCHOR_WEEKLY, ANCHOR_MONTHLY, ANCHOR_QUARTERLY, ANCHOR_YEARLY],
     tooltip = ANCHOR_TOOLTIP,
     group = GROUP_PACK_C,
     display = display.none,
     active = packCEnabledInput)
string packCTierChoiceInput = input.string(
     TIER_3,
     "Highest R/S tier",
     options = [TIER_1, TIER_2, TIER_3, TIER_4, TIER_5],
     tooltip = TIERS_TOOLTIP,
     group = GROUP_PACK_C,
     display = display.none,
     active = packCEnabledInput)
bool packCShowFormulaPpInput = input.bool(
     true,
     "Show PP",
     tooltip = PACK_VISIBILITY_TOOLTIP,
     inline = INLINE_PACK_C_VISIBILITY,
     group = GROUP_PACK_C,
     display = display.none,
     active = packCEnabledInput)
bool packCShowCprInput = input.bool(
     false,
     "CPR",
     tooltip = PACK_VISIBILITY_TOOLTIP,
     inline = INLINE_PACK_C_VISIBILITY,
     group = GROUP_PACK_C,
     display = display.none,
     active = packCEnabledInput)
bool packCShowLabelsInput = input.bool(
     false,
     "Labels",
     tooltip = PACK_VISIBILITY_TOOLTIP,
     inline = INLINE_PACK_C_VISIBILITY,
     group = GROUP_PACK_C,
     display = display.none,
     active = packCEnabledInput)
color packCColorInput = input.color(
     color.rgb(156, 39, 176),
     "R/S color",
     tooltip = PACK_APPEARANCE_TOOLTIP,
     inline = INLINE_PACK_C_APPEARANCE,
     group = GROUP_PACK_C,
     display = display.none,
     active = packCEnabledInput)
string packCStyleInput = input.string(
     "Dotted",
     "Style",
     options = ["Solid", "Dashed", "Dotted"],
     tooltip = PACK_APPEARANCE_TOOLTIP,
     inline = INLINE_PACK_C_APPEARANCE,
     group = GROUP_PACK_C,
     display = display.none,
     active = packCEnabledInput)

color ppColorInput = input.color(
     color.yellow,
     "PP color",
     tooltip = CORE_COLORS_TOOLTIP,
     inline = INLINE_CORE_COLORS,
     group = GROUP_LEVELS,
     display = display.none)
color cprRangeColorInput = input.color(
     color.rgb(156, 39, 176),
     "CPR range",
     tooltip = CORE_COLORS_TOOLTIP,
     inline = INLINE_CORE_COLORS,
     group = GROUP_LEVELS,
     display = display.none)
int lineWidthInput = input.int(
     1,
     "Pivot line width",
     minval = 1,
     maxval = 4,
     tooltip = "• Sets exact active and retained center-line width.\n• Does not change zone width or level prices.",
     group = GROUP_LEVELS,
     display = display.none)
string activeProjectionInput = input.string(
     PROJECTION_CURRENT_OFFSET,
     "Active line projection",
     options = [PROJECTION_CURRENT_OFFSET, PROJECTION_ANCHOR_END, PROJECTION_EXTEND_RIGHT],
     tooltip = PROJECTION_TOOLTIP,
     group = GROUP_LEVELS,
     display = display.none)
int labelOffsetBarsInput = input.int(
     20,
     "Label offset",
     minval = 0,
     maxval = 100,
     tooltip = "• Sets active labels this many future chart bars ahead.\n• Also sets finite offset edges and confluence label placement when selected.",
     group = GROUP_LEVELS,
     display = display.none)
bool showPricesInLabelsInput = input.bool(
     false,
     "Show prices in labels",
     tooltip = "• On: appends formatted prices to active and retained labels.\n• Off: keeps labels shorter.\n• Does not change calculations or visibility.",
     group = GROUP_LEVELS,
     display = display.none)
string labelTextSizeInput = input.string(
     "Small",
     "Label text size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip = "• Sets chart-label text size.\n• Dashboard text uses its own setting.",
     group = GROUP_LEVELS,
     display = display.none)

bool showReactionZonesInput = input.bool(
     true,
     "Show active zone fills",
     tooltip = "• On: shows borderless fills around eligible exact levels.\n• Off: hides fills only.\n• Frozen zone geometry still drives touch, confluence, and retained tracking.",
     group = GROUP_ZONES,
     display = display.none)
string zoneModeInput = input.string(
     ZONE_DAILY_ATR,
     "Zone width basis",
     options = [ZONE_DAILY_ATR, ZONE_ANCHOR_ATR, ZONE_TICKS],
     tooltip = "• Daily ATR: one daily volatility basis.\n• Anchor ATR: each pack's pivot-period volatility.\n• Ticks: fixed instrument-specific width.\n• Changes zone geometry only; pivot prices stay fixed.",
     group = GROUP_ZONES,
     display = display.none)
int atrLengthInput = input.int(
     14,
     "ATR length",
     minval = 1,
     maxval = 100,
     tooltip = ATR_SETTINGS_TOOLTIP,
     inline = INLINE_ATR_SETTINGS,
     group = GROUP_ZONES,
     display = display.none,
     active = zoneModeInput != ZONE_TICKS)
float atrMultiplierInput = input.float(
     0.05,
     "Width per side",
     minval = 0.0,
     maxval = 2.0,
     step = 0.01,
     tooltip = ATR_SETTINGS_TOOLTIP,
     inline = INLINE_ATR_SETTINGS,
     group = GROUP_ZONES,
     display = display.none,
     active = zoneModeInput != ZONE_TICKS)
int fixedTicksInput = input.int(
     4,
     "Fixed / fallback ticks",
     minval = 1,
     maxval = 1000,
     tooltip = "• Sets the half-width in Ticks mode.\n• Also used when ATR is unavailable or non-positive.\n• Applies above and below the exact level.",
     group = GROUP_ZONES,
     display = display.none)
int zoneTransparencyInput = input.int(
     88,
     "Zone fill transparency",
     minval = 0,
     maxval = 100,
     tooltip = "• Sets active, confluence, and retained fill transparency.\n• Higher values are lighter.\n• Visual only.",
     group = GROUP_ZONES,
     display = display.none)

bool showDashboardInput = input.bool(
     true,
     "Show dashboard",
     tooltip = DASHBOARD_TOOLTIP,
     inline = INLINE_DASHBOARD,
     group = GROUP_CONTEXT,
     display = display.none)
string dashboardSizeInput = input.string(
     "Small",
     "Text size",
     options = ["Tiny", "Small", "Normal"],
     tooltip = DASHBOARD_TOOLTIP,
     inline = INLINE_DASHBOARD,
     group = GROUP_CONTEXT,
     display = display.none,
     active = showDashboardInput)
bool showDevelopingCprInput = input.bool(
     false,
     "Show Pack A developing CPR",
     tooltip = "• Shows Pack A's next CPR from the active anchor's changing H/L/C.\n• Provisional only.\n• Excluded from history, confluence, dashboard, and alerts.",
     group = GROUP_CONTEXT,
     display = display.none,
     active = packAEnabledInput)
bool enableConfluenceInput = input.bool(
     true,
     "Enable confluence",
     tooltip = CONFLUENCE_TOOLTIP,
     group = GROUP_CONTEXT,
     display = display.none)
color confluenceColorInput = input.color(
     color.yellow,
     "Zone color",
     tooltip = CONFLUENCE_COLORS_TOOLTIP,
     inline = INLINE_CONFLUENCE_COLORS,
     group = GROUP_CONTEXT,
     display = display.none,
     active = enableConfluenceInput)
color confluenceTextColorInput = input.color(
     color.white,
     "Text color",
     tooltip = CONFLUENCE_COLORS_TOOLTIP,
     inline = INLINE_CONFLUENCE_COLORS,
     group = GROUP_CONTEXT,
     display = display.none,
     active = enableConfluenceInput)
string confluenceProjectionInput = input.string(
     CONFLUENCE_CURRENT_BAR,
     "Confluence projection",
     options = [CONFLUENCE_CURRENT_BAR, CONFLUENCE_LABEL_OFFSET, CONFLUENCE_EXTEND_RIGHT],
     tooltip = "• Current bar: finite live edge.\n• At label offset: shared future-bar edge.\n• Extend right: no finite edge.\n• Drawings only; overlap identity and alerts do not change.",
     group = GROUP_CONTEXT,
     display = display.none,
     active = enableConfluenceInput)
bool confluenceOnlyInput = input.bool(
     false,
     "Show confluence only",
     tooltip = "• On: hides non-confluence drawings.\n• Calculations, dashboard, retained tracking, cleanup, and alerts continue.\n• Applies only while confluence is enabled.",
     group = GROUP_CONTEXT,
     display = display.none,
     active = enableConfluenceInput)

string untestedScopeInput = input.string(
     SCOPE_CORE,
     "Tracking scope",
     options = [SCOPE_CORE, SCOPE_ENABLED, SCOPE_VISIBLE],
     tooltip = "• Core: CPR, PP, R1/S1; Camarilla uses H3/L3/H4/L4.\n• All enabled: CPR, PP, and every native R/S tier.\n• All visible: shown CPR/PP and R/S through the selected tier.\n• Show PP still gates PP; tracking and fill alerts continue while drawings are hidden.",
     group = GROUP_UNTESTED,
     display = display.none)
bool colorByStatusInput = input.bool(
     false,
     "Color levels by test status",
     tooltip = "• Recolors eligible pivot, CPR, and current confluence drawings.\n• A confirmed wick touch changes Untested to Tested.\n• Works with Pack A alone; tracking and alerts always continue.",
     group = GROUP_UNTESTED,
     display = display.none)
bool showStatusHistoryInput = input.bool(
     true,
     "Show status history",
     tooltip = "• Shows prior pivot and CPR status lines.\n• Untested lines extend until a later touch; tested lines stop at the period or touch.\n• Keeps 30 untested and 20 tested records.",
     group = GROUP_UNTESTED,
     display = display.none,
     active = colorByStatusInput)
bool showStatusLabelsInput = input.bool(
     false,
     "Show status labels",
     tooltip = "• Adds Untested or Tested to eligible labels.\n• Labels stay right of price and stagger horizontally when zones overlap.\n• If all eight lanes are occupied, the extra label stays hidden.",
     group = GROUP_UNTESTED,
     display = display.none,
     active = colorByStatusInput)
color untestedColorInput = input.color(
     color.rgb(96, 125, 139),
     "Untested color",
     tooltip = STATUS_COLORS_TOOLTIP,
     inline = INLINE_STATUS_COLORS,
     group = GROUP_UNTESTED,
     display = display.none,
     active = colorByStatusInput)
color testedColorInput = input.color(
     color.gray,
     "Tested color",
     tooltip = STATUS_COLORS_TOOLTIP,
     inline = INLINE_STATUS_COLORS,
     group = GROUP_UNTESTED,
     display = display.none,
     active = colorByStatusInput)
string untestedStyleInput = input.string(
     "Dashed",
     "Untested style",
     options = ["Solid", "Dashed", "Dotted"],
     tooltip = STATUS_STYLES_TOOLTIP,
     inline = INLINE_STATUS_STYLES,
     group = GROUP_UNTESTED,
     display = display.none,
     active = colorByStatusInput)
string testedStyleInput = input.string(
     "Solid",
     "Tested style",
     options = ["Solid", "Dashed", "Dotted"],
     tooltip = STATUS_STYLES_TOOLTIP,
     inline = INLINE_STATUS_STYLES,
     group = GROUP_UNTESTED,
     display = display.none,
     active = colorByStatusInput)
bool showStatusHistoryFillsInput = input.bool(
     false,
     "Fill status history",
     tooltip = "• Adds frozen reaction fills to historical status lines.\n• Active and confluence fills keep their own visibility controls.\n• Testing and alerts do not change.",
     group = GROUP_UNTESTED,
     display = display.none,
     active = colorByStatusInput and showStatusHistoryInput)

bool dynamicAlertsInput = input.bool(
     true,
     "Send detailed dynamic messages",
     tooltip = "• On: Any alert() receives one combined detail message per confirmed bar.\n• The seven fixed alert conditions remain available when off.",
     group = GROUP_ALERTS,
     display = display.none)

// Data structures

// Pivot ladder plus independent floor-pivot CPR.
type PivotSet
    float p
    float cprP
    float bc
    float tc
    float r1
    float s1
    float r2
    float s2
    float r3
    float s3
    float r4
    float s4
    float r5
    float s5

// Completed and developing anchor data.
type AnchorData
    float previousOpen
    float previousHigh
    float previousLow
    float previousClose
    float currentOpen
    float currentHigh
    float currentLow
    float currentClose
    float anchorAtr
    int activeStart
    int periodStart
    int periodEnd
    bool newPeriod

// Retained level state and optional drawings.
type StoredLevel
    float bottom
    float top
    float center
    string levelName
    string packName
    string formula
    string anchor
    int originTime
    int endTime
    int testedBar
    line levelLineID
    box zoneBoxID

// Calculation helpers

// Empty pivot set for state initialization.
emptyPivotSet() =>
    PivotSet.new(
         na, na, na, na,
         na, na, na, na, na, na, na, na, na, na)

// Auto anchor matches TradingView Pivot Points Standard.
resolveAnchor(string anchorChoice) =>
    float chartSeconds = timeframe.in_seconds()
    string resolved = switch anchorChoice
        ANCHOR_DAILY => "1D"
        ANCHOR_WEEKLY => "1W"
        ANCHOR_MONTHLY => "1M"
        ANCHOR_QUARTERLY => "3M"
        ANCHOR_YEARLY => "12M"
        =>
            if not na(chartSeconds) and chartSeconds <= 15.0 * 60.0
                "1D"
            else if not na(chartSeconds) and chartSeconds < 24.0 * 60.0 * 60.0
                "1W"
            else
                "1M"
    resolved

// Blocks anchors below the chart timeframe.
isAnchorValid(string anchorTimeframe) =>
    float chartSeconds = timeframe.in_seconds()
    float anchorSeconds = timeframe.in_seconds(anchorTimeframe)
    bool valid = not na(chartSeconds) and not na(anchorSeconds) and anchorSeconds >= chartSeconds
    valid

// Maps the public style to a Pine line style.
lineStyleFromInput(string styleChoice) =>
    switch styleChoice
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// Maps the tier label to a numeric ceiling.
tiersFromChoice(string tierChoice) =>
    int tiers = switch tierChoice
        TIER_1 => 1
        TIER_2 => 2
        TIER_3 => 3
        TIER_4 => 4
        TIER_5 => 5
        => 1
    tiers

// Uses bar close as the finite edge, or bar open when close is unavailable.
currentChartBarRightTime() =>
    int currentRight = not na(time_close) ? time_close : time
    currentRight

// Finds the future label edge on the chart's trading calendar.
labelOffsetTime() =>
    int currentRight = currentChartBarRightTime()
    int futureRight = time_close("", bars_back = -labelOffsetBarsInput)
    int resolvedRight = not na(futureRight) ? futureRight : currentRight
    resolvedRight

statusLabelTime(int lane) =>
    int futureBars = math.min(500, labelOffsetBarsInput + lane * STATUS_LABEL_LANE_BARS)
    int futureRight = time_close("", bars_back = -futureBars)
    int resolvedRight = not na(futureRight) ? futureRight : labelOffsetTime()
    resolvedRight

statusName(bool tested) =>
    tested ? "Tested" : "Untested"

statusColor(color baseColor, bool eligible, bool tested) =>
    color resolvedColor = colorByStatusInput and eligible ?
         (tested ? testedColorInput : untestedColorInput) :
         baseColor
    resolvedColor

statusStyle(string baseStyle, bool eligible, bool tested) =>
    string resolvedStyle = colorByStatusInput and eligible ?
         (tested ? testedStyleInput : untestedStyleInput) :
         baseStyle
    resolvedStyle

reserveStatusLabelLane(
     float bottom,
     float top,
     array<float> labelBottomsArray,
     array<float> labelTopsArray,
     array<int> labelLanesArray) =>
    float normalizedBottom = math.min(bottom, top)
    float normalizedTop = math.max(bottom, top)
    int reservedLane = -1
    int candidateLane = 0
    while candidateLane < STATUS_LABEL_LANES and reservedLane < 0
        bool occupied = false
        int labelCount = array.size(labelBottomsArray)
        if labelCount > 0
            for labelIndex = 0 to labelCount - 1
                bool sameLane = array.get(labelLanesArray, labelIndex) == candidateLane
                bool overlaps =
                     normalizedTop >= array.get(labelBottomsArray, labelIndex) and
                     normalizedBottom <= array.get(labelTopsArray, labelIndex)
                if sameLane and overlaps
                    occupied := true
        if not occupied
            reservedLane := candidateLane
        candidateLane += 1
    if reservedLane >= 0
        array.push(labelBottomsArray, normalizedBottom)
        array.push(labelTopsArray, normalizedTop)
        array.push(labelLanesArray, reservedLane)
    reservedLane

// Uses time coordinates so long anchors keep their full history.
activeRightTime(int anchorEnd) =>
    activeProjectionInput == PROJECTION_ANCHOR_END ? anchorEnd : labelOffsetTime()

// Only Extend right uses indefinite projection.
activeExtendsRight() =>
    activeProjectionInput == PROJECTION_EXTEND_RIGHT

activeLevelLabel(string formula, string levelName) =>
    string displayLevel = levelName == "P" ? "PP" : levelName
    formula + " · " + displayLevel

cprLevelLabel(string levelName) =>
    string displayLevel =
         levelName == "BC" ? "Lower (BC)" :
         levelName == "TC" ? "Upper (TC)" :
         levelName
    "CPR · " + displayLevel

levelLabelText(string levelName, float value) =>
    showPricesInLabelsInput ?
         levelName + "  " + str.tostring(value, format.mintick) :
         levelName

chartLabelTextSize() =>
    switch labelTextSizeInput
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.small

// Native R/S tier count for each formula.
formulaTierCount(string formula) =>
    int tierCount = switch formula
        FORMULA_FLOOR_PIVOTS => 3
        FORMULA_FIBONACCI => 3
        FORMULA_WOODIE => 4
        FORMULA_CLASSIC => 4
        FORMULA_DM => 1
        FORMULA_CAMARILLA => 5
        FORMULA_FRANK_DILERNIA => 3
        FORMULA_SHADOW_TRADER => 3
        FORMULA_ACD_METHOD => 1
        => 0
    tierCount

// Shadow Trader's ladder is arithmetically identical to Floor Pivots, so two
// packs holding both names on one anchor are one ladder twice, not two opinions.
ladderIdentity(string formula) =>
    formula == FORMULA_SHADOW_TRADER ? FORMULA_FLOOR_PIVOTS : formula

// Keeps CPR PP when formula PP is hidden; suppresses only visible duplicates.
showSeparateCprP(bool showFormulaPp, PivotSet pivotSet) =>
    not showFormulaPp or math.abs(pivotSet.cprP - pivotSet.p) > syminfo.mintick * 0.5

// Uses confirmed prior anchor values; developing H/L/C stays separate.
requestedAnchorData(string tickerID, string anchorTimeframe, int atrLength) =>
    [requestedCurrentOpen, requestedAnchorStart, requestedAnchorEnd] =
         request.security(
             tickerID,
             anchorTimeframe,
             [open, time, time_close],
             gaps = barmerge.gaps_off,
             lookahead = barmerge.lookahead_on)
    [requestedPreviousOpen, requestedPreviousHigh, requestedPreviousLow, requestedPreviousClose, requestedAnchorAtr] =
         request.security(
             tickerID,
             anchorTimeframe,
             [open[1], high[1], low[1], close[1], ta.atr(atrLength)[1]],
             gaps = barmerge.gaps_off,
             lookahead = barmerge.lookahead_on)
    [developingHigh, developingLow, developingClose] =
         request.security(
             tickerID,
             anchorTimeframe,
             [high, low, close],
             gaps = barmerge.gaps_off,
             lookahead = barmerge.lookahead_off)
    int requestedSessionBarTime = request.security(
         tickerID,
         timeframe.period,
         time,
         gaps = barmerge.gaps_on,
         lookahead = barmerge.lookahead_off)
    bool anchorChanged = ta.change(requestedAnchorStart) != 0
    bool sessionBarInAnchor =
         not na(requestedSessionBarTime) and
         not na(requestedAnchorStart) and
         not na(requestedAnchorEnd) and
         requestedSessionBarTime >= requestedAnchorStart and
         requestedSessionBarTime < requestedAnchorEnd
    var int requestedActiveStart = na
    if anchorChanged
        requestedActiveStart := na
    if na(requestedActiveStart) and sessionBarInAnchor
        requestedActiveStart := requestedSessionBarTime
    AnchorData.new(
         requestedPreviousOpen,
         requestedPreviousHigh,
         requestedPreviousLow,
         requestedPreviousClose,
         requestedCurrentOpen,
         developingHigh,
         developingLow,
         developingClose,
         requestedAnchorAtr,
         requestedActiveStart,
         requestedAnchorStart,
         requestedAnchorEnd,
         anchorChanged)

// Builds chart-feed OHLC and ATR independently for each pack.
chartAnchorData(string anchorTimeframe, int atrLength) =>
    int anchorStart = time(anchorTimeframe)
    int anchorEnd = time_close(anchorTimeframe)
    bool anchorChanged = ta.change(anchorStart) != 0
    var int chartActiveStart = na
    if anchorChanged or na(chartActiveStart)
        chartActiveStart := time

    var float aggregateOpen = na
    var float aggregateHigh = na
    var float aggregateLow = na
    var float aggregateClose = na
    var float previousOpen = na
    var float previousHigh = na
    var float previousLow = na
    var float previousClose = na
    var float lastCompletedClose = na
    var float chartAtr = na
    var array<float> atrSeedArray = array.new_float()

    if na(aggregateOpen)
        aggregateOpen := open
        aggregateHigh := high
        aggregateLow := low
        aggregateClose := close
    else if anchorChanged
        previousOpen := aggregateOpen
        previousHigh := aggregateHigh
        previousLow := aggregateLow
        previousClose := aggregateClose

        float completedTrueRange = na(lastCompletedClose) ?
             aggregateHigh - aggregateLow :
             math.max(
                 aggregateHigh - aggregateLow,
                 math.max(math.abs(aggregateHigh - lastCompletedClose), math.abs(aggregateLow - lastCompletedClose)))
        lastCompletedClose := aggregateClose

        if array.size(atrSeedArray) < atrLength
            array.push(atrSeedArray, completedTrueRange)
            if array.size(atrSeedArray) == atrLength
                chartAtr := array.avg(atrSeedArray)
        else
            chartAtr := (chartAtr * (atrLength - 1) + completedTrueRange) / atrLength

        aggregateOpen := open
        aggregateHigh := high
        aggregateLow := low
        aggregateClose := close
    else
        aggregateHigh := math.max(aggregateHigh, high)
        aggregateLow := math.min(aggregateLow, low)
        aggregateClose := close

    AnchorData.new(
         previousOpen,
         previousHigh,
         previousLow,
         previousClose,
         aggregateOpen,
         aggregateHigh,
         aggregateLow,
         aggregateClose,
         chartAtr,
         chartActiveStart,
         anchorStart,
         anchorEnd,
         anchorChanged)

// Selects requested or chart-derived data as one complete anchor set.
selectAnchorData(AnchorData requestedData, AnchorData chartData, bool useRequested) =>
    AnchorData.new(
         useRequested ? requestedData.previousOpen : chartData.previousOpen,
         useRequested ? requestedData.previousHigh : chartData.previousHigh,
         useRequested ? requestedData.previousLow : chartData.previousLow,
         useRequested ? requestedData.previousClose : chartData.previousClose,
         useRequested ? requestedData.currentOpen : chartData.currentOpen,
         useRequested ? requestedData.currentHigh : chartData.currentHigh,
         useRequested ? requestedData.currentLow : chartData.currentLow,
         useRequested ? requestedData.currentClose : chartData.currentClose,
         useRequested ? requestedData.anchorAtr : chartData.anchorAtr,
         useRequested ? requestedData.activeStart : chartData.activeStart,
         useRequested ? requestedData.periodStart : chartData.periodStart,
         useRequested ? requestedData.periodEnd : chartData.periodEnd,
         useRequested ? requestedData.newPeriod : chartData.newPeriod)

// Calculates all nine pivot ladders; CPR always uses prior-H/L/C floor math.
calculatePivotSet(
     string formula,
     float previousOpen,
     float previousHigh,
     float previousLow,
     float previousClose,
     float currentAnchorOpen) =>
    float pivot = na
    float r1 = na
    float s1 = na
    float r2 = na
    float s2 = na
    float r3 = na
    float s3 = na
    float r4 = na
    float s4 = na
    float r5 = na
    float s5 = na
    float priceRange = previousHigh - previousLow

    switch formula
        FORMULA_FLOOR_PIVOTS =>
            pivot := (previousHigh + previousLow + previousClose) / 3.0
            r1 := 2.0 * pivot - previousLow
            s1 := 2.0 * pivot - previousHigh
            r2 := pivot + priceRange
            s2 := pivot - priceRange
            r3 := 2.0 * pivot + previousHigh - 2.0 * previousLow
            s3 := 2.0 * pivot - 2.0 * previousHigh + previousLow
        FORMULA_FIBONACCI =>
            pivot := (previousHigh + previousLow + previousClose) / 3.0
            r1 := pivot + 0.382 * priceRange
            s1 := pivot - 0.382 * priceRange
            r2 := pivot + 0.618 * priceRange
            s2 := pivot - 0.618 * priceRange
            r3 := pivot + priceRange
            s3 := pivot - priceRange
        FORMULA_WOODIE =>
            pivot := (previousHigh + previousLow + 2.0 * currentAnchorOpen) / 4.0
            r1 := 2.0 * pivot - previousLow
            s1 := 2.0 * pivot - previousHigh
            r2 := pivot + priceRange
            s2 := pivot - priceRange
            r3 := previousHigh + 2.0 * (pivot - previousLow)
            s3 := previousLow - 2.0 * (previousHigh - pivot)
            r4 := r3 + priceRange
            s4 := s3 - priceRange
        FORMULA_CLASSIC =>
            pivot := (previousHigh + previousLow + previousClose) / 3.0
            r1 := 2.0 * pivot - previousLow
            s1 := 2.0 * pivot - previousHigh
            r2 := pivot + priceRange
            s2 := pivot - priceRange
            r3 := pivot + 2.0 * priceRange
            s3 := pivot - 2.0 * priceRange
            r4 := pivot + 3.0 * priceRange
            s4 := pivot - 3.0 * priceRange
        FORMULA_DM =>
            float x = previousOpen == previousClose ?
                 previousHigh + previousLow + 2.0 * previousClose :
                 previousClose > previousOpen ?
                 2.0 * previousHigh + previousLow + previousClose :
                 2.0 * previousLow + previousHigh + previousClose
            pivot := x / 4.0
            r1 := x / 2.0 - previousLow
            s1 := x / 2.0 - previousHigh
        FORMULA_CAMARILLA =>
            pivot := (previousHigh + previousLow + previousClose) / 3.0
            r1 := previousClose + 1.1 * priceRange / 12.0
            s1 := previousClose - 1.1 * priceRange / 12.0
            r2 := previousClose + 1.1 * priceRange / 6.0
            s2 := previousClose - 1.1 * priceRange / 6.0
            r3 := previousClose + 1.1 * priceRange / 4.0
            s3 := previousClose - 1.1 * priceRange / 4.0
            r4 := previousClose + 1.1 * priceRange / 2.0
            s4 := previousClose - 1.1 * priceRange / 2.0
            if previousLow != 0.0
                r5 := previousHigh / previousLow * previousClose
                s5 := previousClose - (r5 - previousClose)
        FORMULA_FRANK_DILERNIA =>
            pivot := (previousHigh + previousLow + previousClose) / 3.0
            r1 := pivot + priceRange / 2.0
            s1 := pivot - priceRange / 2.0
            r2 := pivot + 0.618 * priceRange
            s2 := pivot - 0.618 * priceRange
            r3 := pivot + priceRange
            s3 := pivot - priceRange
        FORMULA_SHADOW_TRADER =>
            pivot := (previousHigh + previousLow + previousClose) / 3.0
            r1 := 2.0 * pivot - previousLow
            s1 := 2.0 * pivot - previousHigh
            r2 := pivot + (r1 - s1)
            s2 := pivot - (r1 - s1)
            r3 := previousHigh + 2.0 * (pivot - previousLow)
            s3 := previousLow - 2.0 * (previousHigh - pivot)
        FORMULA_ACD_METHOD =>
            pivot := (previousHigh + previousLow + previousClose) / 3.0
            float acdOffset = math.abs((previousHigh + previousLow) / 2.0 - pivot)
            r1 := pivot + acdOffset
            s1 := pivot - acdOffset
        =>
            pivot := na

    float floorPivot = (previousHigh + previousLow + previousClose) / 3.0
    float rawBc = (previousHigh + previousLow) / 2.0
    float rawTc = 2.0 * floorPivot - rawBc
    float cprBottom = math.min(rawBc, rawTc)
    float cprTop = math.max(rawBc, rawTc)
    PivotSet.new(
         pivot,
         floorPivot,
         cprBottom,
         cprTop,
         r1,
         s1,
         r2,
         s2,
         r3,
         s3,
         r4,
         s4,
         r5,
         s5)

// Candidate map: 0 CPR, 1 P, then R/S pairs.
pivotValue(PivotSet pivotSet, int candidateIndex) =>
    float value = switch candidateIndex
        1 => pivotSet.p
        2 => pivotSet.r1
        3 => pivotSet.s1
        4 => pivotSet.r2
        5 => pivotSet.s2
        6 => pivotSet.r3
        7 => pivotSet.s3
        8 => pivotSet.r4
        9 => pivotSet.s4
        10 => pivotSet.r5
        11 => pivotSet.s5
        => na
    value

// Camarilla displays H/L names with TradingView R/S aliases.
pivotLevelName(string formula, int candidateIndex) =>
    string levelName = switch candidateIndex
        1 => "P"
        2 => formula == FORMULA_CAMARILLA ? "H1 (R1)" : "R1"
        3 => formula == FORMULA_CAMARILLA ? "L1 (S1)" : "S1"
        4 => formula == FORMULA_CAMARILLA ? "H2 (R2)" : "R2"
        5 => formula == FORMULA_CAMARILLA ? "L2 (S2)" : "S2"
        6 => formula == FORMULA_CAMARILLA ? "H3 (R3)" : "R3"
        7 => formula == FORMULA_CAMARILLA ? "L3 (S3)" : "S3"
        8 => formula == FORMULA_CAMARILLA ? "H4 (R4)" : "R4"
        9 => formula == FORMULA_CAMARILLA ? "L4 (S4)" : "S4"
        10 => formula == FORMULA_CAMARILLA ? "H5 (R5)" : "R5"
        11 => formula == FORMULA_CAMARILLA ? "L5 (S5)" : "S5"
        => "CPR"
    levelName

zoneAtrBasis(float dailyAtr, float anchorAtr) =>
    float atrBasis =
         zoneModeInput == ZONE_DAILY_ATR ? dailyAtr :
         zoneModeInput == ZONE_ANCHOR_ATR ? anchorAtr :
         na
    atrBasis

// Falls back to ticks and enforces at least one tick.
zoneHalfWidth(float dailyAtr, float anchorAtr) =>
    float atrBasis = zoneAtrBasis(dailyAtr, anchorAtr)
    float atrWidth = atrBasis * atrMultiplierInput
    float tickWidth = syminfo.mintick * fixedTicksInput
    float width = zoneModeInput == ZONE_TICKS or na(atrWidth) or atrWidth <= 0.0 ? tickWidth : atrWidth
    math.max(width, syminfo.mintick)

// Returns level geometry; CPR is one origin-frozen band.
candidateGeometry(PivotSet pivotSet, int candidateIndex, float halfWidth) =>
    float center = candidateIndex == 0 ? pivotSet.cprP : pivotValue(pivotSet, candidateIndex)
    float bottom = candidateIndex == 0 ? pivotSet.bc - halfWidth : center - halfWidth
    float top = candidateIndex == 0 ? pivotSet.tc + halfWidth : center + halfWidth
    bool available = not na(center) and not na(bottom) and not na(top)
    [bottom, top, center, available]

// Applies retained-level scope without changing R/S math.
trackCandidate(
     string scope,
     string formula,
     int candidateIndex,
     int visibleTiers,
     bool showFormulaPp,
     bool showCpr) =>
    int supportedTiers = formulaTierCount(formula)
    int candidateTier = candidateIndex <= 1 ? 0 : int(math.ceil((candidateIndex - 1) / 2.0))
    bool baseSelected = false
    if scope == SCOPE_CORE
        // CPR and PP are core under every formula; only the R/S pair changes.
        // Camarilla's tier 1 hugs the prior close, so its pair is H3/L3 and H4/L4.
        bool corePair = formula == FORMULA_CAMARILLA ?
             (candidateIndex >= 6 and candidateIndex <= 9) :
             (candidateIndex == 2 or candidateIndex == 3)
        baseSelected := candidateIndex == 0 or candidateIndex == 1 or corePair
    else if scope == SCOPE_ENABLED
        baseSelected := candidateIndex == 0 or candidateIndex == 1 or candidateTier <= supportedTiers
    else
        baseSelected := (candidateIndex == 0 and showCpr) or candidateIndex == 1 or candidateTier <= math.min(visibleTiers, supportedTiers)
    bool selected = baseSelected and (candidateIndex != 1 or showFormulaPp)
    selected

// Dashboard status for one pack.
packStatus(
     bool enabled,
     bool duplicate,
     bool anchorValid,
     bool dataReady,
     bool atrReady) =>
    string status = if not enabled
        "OFF"
    else if duplicate
        "DUPLICATE"
    else if not anchorValid
        "INVALID ANCHOR"
    else if not dataReady
        "NO DATA"
    else if not atrReady
        "ATR UNAVAILABLE"
    else
        "ACTIVE"
    status

stringArrayContains(array<string> valuesArray, string targetValue) =>
    bool containsValue = false
    int valueCount = array.size(valuesArray)
    if valueCount > 0
        for valueIndex = 0 to valueCount - 1
            if array.get(valuesArray, valueIndex) == targetValue
                containsValue := true
    containsValue

copyStringArray(array<string> targetArray, array<string> sourceArray) =>
    array.clear(targetArray)
    int sourceCount = array.size(sourceArray)
    if sourceCount > 0
        for sourceIndex = 0 to sourceCount - 1
            array.push(targetArray, array.get(sourceArray, sourceIndex))

// Builds a stable ID for one confluence zone.
confluenceIdentity(
     float bottom,
     float top,
     int originTime,
     string contextMembers,
     string canonicalMembers) =>
    str.tostring(originTime) + "," +
     str.tostring(bottom, format.mintick) + "," +
     str.tostring(top, format.mintick) + "," +
     contextMembers + "," +
     canonicalMembers

// Drawing helpers

clearLines(array<line> linesArray) =>
    while array.size(linesArray) > 0
        line lineID = array.pop(linesArray)
        line.delete(lineID)

clearBoxes(array<box> boxesArray) =>
    while array.size(boxesArray) > 0
        box boxID = array.pop(boxesArray)
        box.delete(boxID)

clearLabels(array<label> labelsArray) =>
    while array.size(labelsArray) > 0
        label labelID = array.pop(labelsArray)
        label.delete(labelID)

drawLevel(
     int leftTime,
     int rightTime,
     float value,
     string levelName,
     color levelColor,
     string styleChoice,
     bool extendRight,
     bool showLabel,
     array<line> linesArray,
     array<label> labelsArray) =>
    if not na(value) and not na(leftTime) and not na(rightTime)
        line levelLineID = line.new(
             x1 = leftTime,
             y1 = value,
             x2 = rightTime,
             y2 = value,
             xloc = xloc.bar_time,
             extend = extendRight ? extend.right : extend.none,
             color = levelColor,
             style = lineStyleFromInput(styleChoice),
             width = lineWidthInput)
        array.push(linesArray, levelLineID)
        if showLabel
            label levelLabelID = label.new(
                 x = rightTime,
                 y = value,
                 text = levelLabelText(levelName, value),
                 xloc = xloc.bar_time,
                 style = label.style_label_left,
                 color = color.new(levelColor, 72),
                 textcolor = color.white,
                 size = chartLabelTextSize())
            array.push(labelsArray, levelLabelID)

drawStatusLevel(
     int leftTime,
     int rightTime,
     float value,
     float zoneBottom,
     float zoneTop,
     string levelName,
     color baseColor,
     string baseStyle,
     bool tested,
     bool showBaseLabel,
     bool extendRight,
     array<float> labelBottomsArray,
     array<float> labelTopsArray,
     array<int> labelLanesArray,
     array<line> linesArray,
     array<label> labelsArray) =>
    if not na(value) and not na(leftTime) and not na(rightTime)
        color levelColor = statusColor(baseColor, true, tested)
        string styleChoice = statusStyle(baseStyle, true, tested)
        line levelLineID = line.new(
             x1 = leftTime,
             y1 = value,
             x2 = rightTime,
             y2 = value,
             xloc = xloc.bar_time,
             extend = extendRight ? extend.right : extend.none,
             color = levelColor,
             style = lineStyleFromInput(styleChoice),
             width = lineWidthInput)
        array.push(linesArray, levelLineID)

        bool statusLabelRequested = colorByStatusInput and showStatusLabelsInput
        bool showResolvedLabel = showBaseLabel or statusLabelRequested
        int labelTime = rightTime
        string labelName = levelName
        if statusLabelRequested
            int labelLane = reserveStatusLabelLane(
                 zoneBottom,
                 zoneTop,
                 labelBottomsArray,
                 labelTopsArray,
                 labelLanesArray)
            showResolvedLabel := labelLane >= 0
            if labelLane >= 0
                labelTime := statusLabelTime(labelLane)
                labelName := statusName(tested) + " · " + levelName
        if showResolvedLabel
            label levelLabelID = label.new(
                 x = labelTime,
                 y = value,
                 text = levelLabelText(labelName, value),
                 xloc = xloc.bar_time,
                 style = label.style_label_left,
                 color = color.new(levelColor, 72),
                 textcolor = color.white,
                 size = chartLabelTextSize())
            array.push(labelsArray, levelLabelID)

drawReactionBand(
     int leftTime,
     int rightTime,
     float center,
     float halfWidth,
     color bandColor,
     bool extendRight,
     array<box> boxesArray) =>
    if showReactionZonesInput and not na(center) and not na(leftTime) and not na(rightTime)
        box bandBoxID = box.new(
             left = leftTime,
             top = center + halfWidth,
             right = rightTime,
             bottom = center - halfWidth,
             xloc = xloc.bar_time,
             extend = extendRight ? extend.right : extend.none,
             border_color = color.new(bandColor, 100),
             bgcolor = color.new(bandColor, zoneTransparencyInput))
        array.push(boxesArray, bandBoxID)

drawPack(
     bool operational,
     string formula,
     int visibleTiers,
     bool showFormulaPp,
     bool showCpr,
     bool showLabels,
     color packColor,
     string styleChoice,
     PivotSet pivotSet,
     float halfWidth,
     int activeStart,
     int periodEnd,
     array<bool> touchedArray,
     array<float> labelBottomsArray,
     array<float> labelTopsArray,
     array<int> labelLanesArray,
     array<line> linesArray,
     array<box> boxesArray,
     array<label> labelsArray) =>
    if operational and not na(activeStart)
        int rightTime = activeRightTime(periodEnd)
        bool extendRight = activeExtendsRight()
        if showFormulaPp
            bool ppTested = array.get(touchedArray, 1)
            color ppVisualColor = statusColor(ppColorInput, true, ppTested)
            drawStatusLevel(
                 activeStart,
                 rightTime,
                 pivotSet.p,
                 pivotSet.p - halfWidth,
                 pivotSet.p + halfWidth,
                 activeLevelLabel(formula, "P"),
                 ppColorInput,
                 styleChoice,
                 ppTested,
                 showLabels,
                 extendRight,
                 labelBottomsArray,
                 labelTopsArray,
                 labelLanesArray,
                 linesArray,
                 labelsArray)
            drawReactionBand(activeStart, rightTime, pivotSet.p, halfWidth, ppVisualColor, extendRight, boxesArray)

        int supportedTiers = formulaTierCount(formula)
        int tiersToDraw = math.min(visibleTiers, supportedTiers)
        if tiersToDraw > 0
            for tier = 1 to tiersToDraw
                int resistanceIndex = tier * 2
                int supportIndex = resistanceIndex + 1
                float resistance = pivotValue(pivotSet, resistanceIndex)
                float support = pivotValue(pivotSet, supportIndex)
                string resistanceName = pivotLevelName(formula, resistanceIndex)
                string supportName = pivotLevelName(formula, supportIndex)
                bool resistanceTested = array.get(touchedArray, resistanceIndex)
                bool supportTested = array.get(touchedArray, supportIndex)
                color resistanceColor = statusColor(packColor, true, resistanceTested)
                color supportColor = statusColor(packColor, true, supportTested)
                drawStatusLevel(
                     activeStart,
                     rightTime,
                     resistance,
                     resistance - halfWidth,
                     resistance + halfWidth,
                     activeLevelLabel(formula, resistanceName),
                     packColor,
                     styleChoice,
                     resistanceTested,
                     showLabels,
                     extendRight,
                     labelBottomsArray,
                     labelTopsArray,
                     labelLanesArray,
                     linesArray,
                     labelsArray)
                drawStatusLevel(
                     activeStart,
                     rightTime,
                     support,
                     support - halfWidth,
                     support + halfWidth,
                     activeLevelLabel(formula, supportName),
                     packColor,
                     styleChoice,
                     supportTested,
                     showLabels,
                     extendRight,
                     labelBottomsArray,
                     labelTopsArray,
                     labelLanesArray,
                     linesArray,
                     labelsArray)
                drawReactionBand(activeStart, rightTime, resistance, halfWidth, resistanceColor, extendRight, boxesArray)
                drawReactionBand(activeStart, rightTime, support, halfWidth, supportColor, extendRight, boxesArray)

        if showCpr and not na(pivotSet.bc) and not na(pivotSet.tc)
            bool cprTested = array.get(touchedArray, 0)
            color cprVisualColor = statusColor(cprRangeColorInput, true, cprTested)
            color cprPVisualColor = statusColor(ppColorInput, true, cprTested)
            string cprVisualStyle = statusStyle(styleChoice, true, cprTested)
            bool hasCprWidth = math.abs(pivotSet.tc - pivotSet.bc) > syminfo.mintick * 0.5
            if hasCprWidth
                box cprBoxID = box.new(
                     left = activeStart,
                     top = pivotSet.tc,
                     right = rightTime,
                     bottom = pivotSet.bc,
                     xloc = xloc.bar_time,
                     extend = extendRight ? extend.right : extend.none,
                     border_color = color.new(cprVisualColor, 58),
                     border_style = lineStyleFromInput(cprVisualStyle),
                     bgcolor = color.new(cprVisualColor, 88))
                array.push(boxesArray, cprBoxID)
                drawStatusLevel(
                     activeStart,
                     rightTime,
                     pivotSet.bc,
                     pivotSet.bc - halfWidth,
                     pivotSet.bc + halfWidth,
                     cprLevelLabel("BC"),
                     cprRangeColorInput,
                     styleChoice,
                     cprTested,
                     showLabels,
                     extendRight,
                     labelBottomsArray,
                     labelTopsArray,
                     labelLanesArray,
                     linesArray,
                     labelsArray)
                drawStatusLevel(
                     activeStart,
                     rightTime,
                     pivotSet.tc,
                     pivotSet.tc - halfWidth,
                     pivotSet.tc + halfWidth,
                     cprLevelLabel("TC"),
                     cprRangeColorInput,
                     styleChoice,
                     cprTested,
                     showLabels,
                     extendRight,
                     labelBottomsArray,
                     labelTopsArray,
                     labelLanesArray,
                     linesArray,
                     labelsArray)
            if showSeparateCprP(showFormulaPp, pivotSet)
                drawStatusLevel(
                     activeStart,
                     rightTime,
                     pivotSet.cprP,
                     pivotSet.cprP - halfWidth,
                     pivotSet.cprP + halfWidth,
                     cprLevelLabel("PP"),
                     ppColorInput,
                     styleChoice,
                     cprTested,
                     showLabels,
                     extendRight,
                     labelBottomsArray,
                     labelTopsArray,
                     labelLanesArray,
                     linesArray,
                     labelsArray)
                drawReactionBand(activeStart, rightTime, pivotSet.cprP, halfWidth, cprPVisualColor, extendRight, boxesArray)

drawDevelopingCpr(
     bool operational,
     AnchorData anchorData,
     array<line> linesArray,
     array<label> labelsArray) =>
    bool developingReady =
         operational and
         showDevelopingCprInput and
         not na(anchorData.activeStart) and
         not na(anchorData.currentHigh) and
         not na(anchorData.currentLow) and
         not na(anchorData.currentClose)
    if developingReady
        int rightTime = activeRightTime(anchorData.periodEnd)
        bool extendRight = activeExtendsRight()
        float developingPivot = (anchorData.currentHigh + anchorData.currentLow + anchorData.currentClose) / 3.0
        float developingRawBc = (anchorData.currentHigh + anchorData.currentLow) / 2.0
        float developingRawTc = 2.0 * developingPivot - developingRawBc
        float developingBottom = math.min(developingRawBc, developingRawTc)
        float developingTop = math.max(developingRawBc, developingRawTc)
        drawLevel(
             anchorData.activeStart,
             rightTime,
             developingPivot,
             "Developing · PP",
             color.gray,
             "Dashed",
             extendRight,
             false,
             linesArray,
             labelsArray)
        bool hasDevelopingWidth = math.abs(developingTop - developingBottom) > syminfo.mintick * 0.5
        if hasDevelopingWidth
            drawLevel(
                 anchorData.activeStart,
                 rightTime,
                 developingBottom,
                 "Developing · BC",
                 color.gray,
                 "Dashed",
                 extendRight,
                 false,
                 linesArray,
                 labelsArray)
            drawLevel(
                 anchorData.activeStart,
                 rightTime,
                 developingTop,
                 "Developing · TC",
                 color.gray,
                 "Dashed",
                 extendRight,
                 false,
                 linesArray,
                 labelsArray)

// Test-status lifecycle helpers

deleteStoredDrawing(StoredLevel storedLevel) =>
    if not na(storedLevel.levelLineID)
        line.delete(storedLevel.levelLineID)
    if not na(storedLevel.zoneBoxID)
        box.delete(storedLevel.zoneBoxID)

isStoredDuplicate(
     array<StoredLevel> storedArray,
     string anchor,
     int originTime,
     string levelName,
     float center) =>
    bool duplicate = false
    int storedCount = array.size(storedArray)
    if storedCount > 0
        for storedIndex = 0 to storedCount - 1
            StoredLevel storedLevel = array.get(storedArray, storedIndex)
            bool sameContext =
                 storedLevel.anchor == anchor and
                 storedLevel.originTime == originTime and
                 storedLevel.levelName == levelName
            bool samePrice = math.abs(storedLevel.center - center) <= syminfo.mintick * 0.5
            if sameContext and samePrice
                duplicate := true
    duplicate

archiveCandidate(
     array<StoredLevel> untestedArray,
     array<StoredLevel> testedArray,
     float bottom,
     float top,
     float center,
     string levelName,
     string packName,
     string formula,
     string anchor,
     int originTime,
     int endTime,
     bool wasTouched) =>
    bool duplicate =
         isStoredDuplicate(untestedArray, anchor, originTime, levelName, center) or
         isStoredDuplicate(testedArray, anchor, originTime, levelName, center)
    if not duplicate and not na(bottom) and not na(top) and not na(center)
        line levelLineID = na
        box zoneBoxID = na
        int resolvedEnd = not na(endTime) ? endTime : time
        color levelColor = wasTouched ? testedColorInput : untestedColorInput
        string levelStyle = wasTouched ? testedStyleInput : untestedStyleInput
        if colorByStatusInput and showStatusHistoryInput and not (enableConfluenceInput and confluenceOnlyInput)
            levelLineID := line.new(
                 x1 = originTime,
                 y1 = center,
                 x2 = wasTouched ? resolvedEnd : time,
                 y2 = center,
                 xloc = xloc.bar_time,
                 extend = wasTouched ? extend.none : extend.right,
                 color = levelColor,
                 style = lineStyleFromInput(levelStyle),
                 width = lineWidthInput)
            if showStatusHistoryFillsInput
                zoneBoxID := box.new(
                     left = originTime,
                     top = top,
                     right = wasTouched ? resolvedEnd : time,
                     bottom = bottom,
                     xloc = xloc.bar_time,
                     extend = wasTouched ? extend.none : extend.right,
                     border_color = color.new(levelColor, 100),
                     bgcolor = color.new(levelColor, zoneTransparencyInput))
        StoredLevel storedLevel = StoredLevel.new(
             bottom,
             top,
             center,
             levelName,
             packName,
             formula,
             anchor,
             originTime,
             resolvedEnd,
             wasTouched ? bar_index : -1,
             levelLineID,
             zoneBoxID)
        if wasTouched
            array.push(testedArray, storedLevel)
            if array.size(testedArray) > MAX_TESTED
                StoredLevel removedTested = array.shift(testedArray)
                deleteStoredDrawing(removedTested)
        else
            array.push(untestedArray, storedLevel)
            if array.size(untestedArray) > MAX_UNTESTED
                StoredLevel removedUntested = array.shift(untestedArray)
                deleteStoredDrawing(removedUntested)

archivePack(
     array<StoredLevel> untestedArray,
     array<StoredLevel> testedArray,
     array<bool> touchedArray,
     bool archiveEnabled,
     PivotSet previousSet,
     float frozenHalfWidth,
     string packName,
     string formula,
     string anchor,
     int visibleTiers,
     bool showFormulaPp,
     bool showCpr,
     int originTime,
     int endTime) =>
    if archiveEnabled
        for candidateIndex = 0 to 11
            bool selected = trackCandidate(
                 untestedScopeInput,
                 formula,
                 candidateIndex,
                 visibleTiers,
                 showFormulaPp,
                 showCpr)
            bool wasTouched = array.get(touchedArray, candidateIndex)
            [bottom, top, center, available] = candidateGeometry(previousSet, candidateIndex, frozenHalfWidth)
            if selected and available
                string levelName = candidateIndex == 0 ? "CPR" : pivotLevelName(formula, candidateIndex)
                archiveCandidate(
                     untestedArray,
                     testedArray,
                     bottom,
                     top,
                     center,
                     levelName,
                     packName,
                     formula,
                     anchor,
                     originTime,
                     endTime,
                     wasTouched)

updateTouchedState(
     array<bool> touchedArray,
     bool operational,
     bool showFormulaPp,
     PivotSet pivotSet,
     float halfWidth) =>
    if operational
        for candidateIndex = 0 to 11
            [bottom, top, center, available] = candidateGeometry(pivotSet, candidateIndex, halfWidth)
            bool candidateEnabled = candidateIndex != 1 or showFormulaPp
            bool overlaps = candidateEnabled and available and high >= bottom and low <= top
            if overlaps
                array.set(touchedArray, candidateIndex, true)

resetTouchedState(array<bool> touchedArray) =>
    array.fill(touchedArray, false)

// Lets the first new-anchor bar test a level archived at rollover.
processUntested(
     array<StoredLevel> untestedArray,
     array<StoredLevel> testedArray) =>
    bool filled = false
    string fillDetail = ""
    int untestedIndex = array.size(untestedArray) - 1
    while untestedIndex >= 0
        StoredLevel storedLevel = array.get(untestedArray, untestedIndex)
        bool overlaps = barstate.isconfirmed and high >= storedLevel.bottom and low <= storedLevel.top
        if overlaps
            storedLevel.testedBar := bar_index
            storedLevel.endTime := time
            if not na(storedLevel.levelLineID)
                line.set_extend(storedLevel.levelLineID, extend.none)
                line.set_x2(storedLevel.levelLineID, time)
                line.set_color(storedLevel.levelLineID, testedColorInput)
                line.set_style(storedLevel.levelLineID, lineStyleFromInput(testedStyleInput))
            if not na(storedLevel.zoneBoxID)
                box.set_extend(storedLevel.zoneBoxID, extend.none)
                box.set_right(storedLevel.zoneBoxID, time)
                box.set_bgcolor(storedLevel.zoneBoxID, color.new(testedColorInput, zoneTransparencyInput))
                box.set_border_color(storedLevel.zoneBoxID, color.new(testedColorInput, 100))
            array.remove(untestedArray, untestedIndex)
            array.push(testedArray, storedLevel)
            if array.size(testedArray) > MAX_TESTED
                StoredLevel removedTested = array.shift(testedArray)
                deleteStoredDrawing(removedTested)
            string eventDetail =
                 "pack=" + storedLevel.packName +
                 ",formula=" + storedLevel.formula +
                 ",anchor=" + storedLevel.anchor +
                 ",level=" + storedLevel.levelName +
                 ",origin=" + str.tostring(storedLevel.originTime)
            fillDetail := str.length(fillDetail) == 0 ? eventDetail : fillDetail + ";" + eventDetail
            filled := true
        untestedIndex -= 1
    [filled, fillDetail]

drawStoredStatusLabels(
     array<StoredLevel> storedArray,
     bool tested,
     array<float> labelBottomsArray,
     array<float> labelTopsArray,
     array<int> labelLanesArray,
     array<label> labelsArray) =>
    int storedCount = array.size(storedArray)
    if storedCount > 0
        for storedIndex = 0 to storedCount - 1
            StoredLevel storedLevel = array.get(storedArray, storedIndex)
            int labelLane = reserveStatusLabelLane(
                 storedLevel.bottom,
                 storedLevel.top,
                 labelBottomsArray,
                 labelTopsArray,
                 labelLanesArray)
            if labelLane >= 0
                color labelColor = tested ? testedColorInput : untestedColorInput
                string labelName =
                     statusName(tested) + " · " +
                     activeLevelLabel(storedLevel.formula, storedLevel.levelName)
                label levelLabelID = label.new(
                     x = statusLabelTime(labelLane),
                     y = storedLevel.center,
                     text = levelLabelText(labelName, storedLevel.center),
                     xloc = xloc.bar_time,
                     style = label.style_label_left,
                     color = color.new(labelColor, 72),
                     textcolor = color.white,
                     size = chartLabelTextSize())
                array.push(labelsArray, levelLabelID)

// Candidate and confluence helpers

addCandidate(
     array<float> bottomsArray,
     array<float> topsArray,
     array<float> centersArray,
     array<string> packsArray,
     array<string> formulasArray,
     array<string> anchorsArray,
     array<string> levelsArray,
     array<int> originsArray,
     array<string> contextsArray,
     array<string> canonicalArray,
     float bottom,
     float top,
     float center,
     string packName,
     string formula,
     string anchor,
     string levelName,
     int originTime,
     string contextKey,
     string canonicalKey) =>
    bool duplicateCanonical = false
    int canonicalCount = array.size(canonicalArray)
    if canonicalCount > 0
        for canonicalIndex = 0 to canonicalCount - 1
            if array.get(canonicalArray, canonicalIndex) == canonicalKey
                duplicateCanonical := true
    if not duplicateCanonical and not na(bottom) and not na(top) and not na(center)
        array.push(bottomsArray, bottom)
        array.push(topsArray, top)
        array.push(centersArray, center)
        array.push(packsArray, packName)
        array.push(formulasArray, formula)
        array.push(anchorsArray, anchor)
        array.push(levelsArray, levelName)
        array.push(originsArray, originTime)
        array.push(contextsArray, contextKey)
        array.push(canonicalArray, canonicalKey)

addPackCandidates(
     array<float> bottomsArray,
     array<float> topsArray,
     array<float> centersArray,
     array<string> packsArray,
     array<string> formulasArray,
     array<string> anchorsArray,
     array<string> levelsArray,
     array<int> originsArray,
     array<string> contextsArray,
     array<string> canonicalArray,
     bool operational,
     string packName,
     string formula,
     string anchor,
     int visibleTiers,
     bool showFormulaPp,
     bool showCpr,
     PivotSet pivotSet,
     float halfWidth,
     int originTime) =>
    if operational
        string baseContext = packName + "," + formula + "," + anchor + "," + str.tostring(originTime)
        if showFormulaPp
            [pBottom, pTop, pCenter, pAvailable] = candidateGeometry(pivotSet, 1, halfWidth)
            if pAvailable
                string pCanonical = anchor + "," + str.tostring(originTime) + ",P," + str.tostring(pCenter, format.mintick)
                addCandidate(
                     bottomsArray, topsArray, centersArray, packsArray, formulasArray, anchorsArray,
                     levelsArray, originsArray, contextsArray, canonicalArray,
                     pBottom, pTop, pCenter, packName, formula, anchor, "P", originTime, baseContext, pCanonical)

        int tiersToUse = math.min(visibleTiers, formulaTierCount(formula))
        if tiersToUse > 0
            for tier = 1 to tiersToUse
                int resistanceIndex = tier * 2
                int supportIndex = resistanceIndex + 1
                [rBottom, rTop, rCenter, rAvailable] = candidateGeometry(pivotSet, resistanceIndex, halfWidth)
                [sBottom, sTop, sCenter, sAvailable] = candidateGeometry(pivotSet, supportIndex, halfWidth)
                if rAvailable
                    string resistanceName = pivotLevelName(formula, resistanceIndex)
                    string resistanceCanonical =
                         anchor + "," + str.tostring(originTime) + "," + resistanceName + "," + str.tostring(rCenter, format.mintick)
                    addCandidate(
                         bottomsArray, topsArray, centersArray, packsArray, formulasArray, anchorsArray,
                         levelsArray, originsArray, contextsArray, canonicalArray,
                         rBottom, rTop, rCenter, packName, formula, anchor, resistanceName, originTime, baseContext, resistanceCanonical)
                if sAvailable
                    string supportName = pivotLevelName(formula, supportIndex)
                    string supportCanonical =
                         anchor + "," + str.tostring(originTime) + "," + supportName + "," + str.tostring(sCenter, format.mintick)
                    addCandidate(
                         bottomsArray, topsArray, centersArray, packsArray, formulasArray, anchorsArray,
                         levelsArray, originsArray, contextsArray, canonicalArray,
                         sBottom, sTop, sCenter, packName, formula, anchor, supportName, originTime, baseContext, supportCanonical)

        if showCpr
            float bcBottom = pivotSet.bc - halfWidth
            float bcTop = pivotSet.bc + halfWidth
            float tcBottom = pivotSet.tc - halfWidth
            float tcTop = pivotSet.tc + halfWidth
            if not na(pivotSet.bc)
                addCandidate(
                     bottomsArray, topsArray, centersArray, packsArray, formulasArray, anchorsArray,
                     levelsArray, originsArray, contextsArray, canonicalArray,
                     bcBottom, bcTop, pivotSet.bc, packName, formula, anchor, "BC", originTime, baseContext,
                     anchor + "," + str.tostring(originTime) + ",BC," + str.tostring(pivotSet.bc, format.mintick))
            if not na(pivotSet.tc) and math.abs(pivotSet.tc - pivotSet.bc) > syminfo.mintick * 0.5
                addCandidate(
                     bottomsArray, topsArray, centersArray, packsArray, formulasArray, anchorsArray,
                     levelsArray, originsArray, contextsArray, canonicalArray,
                     tcBottom, tcTop, pivotSet.tc, packName, formula, anchor, "TC", originTime, baseContext,
                     anchor + "," + str.tostring(originTime) + ",TC," + str.tostring(pivotSet.tc, format.mintick))
            if not na(pivotSet.cprP) and showSeparateCprP(showFormulaPp, pivotSet)
                addCandidate(
                     bottomsArray, topsArray, centersArray, packsArray, formulasArray, anchorsArray,
                     levelsArray, originsArray, contextsArray, canonicalArray,
                     pivotSet.cprP - halfWidth,
                     pivotSet.cprP + halfWidth,
                     pivotSet.cprP,
                     packName,
                     formula,
                     anchor,
                     "CPR P",
                     originTime,
                     baseContext,
                     anchor + "," + str.tostring(originTime) + ",CPRP," + str.tostring(pivotSet.cprP, format.mintick))

addUntestedCandidates(
     array<float> bottomsArray,
     array<float> topsArray,
     array<float> centersArray,
     array<string> packsArray,
     array<string> formulasArray,
     array<string> anchorsArray,
     array<string> levelsArray,
     array<int> originsArray,
     array<string> contextsArray,
     array<string> canonicalArray,
     array<StoredLevel> untestedArray) =>
    int untestedCount = array.size(untestedArray)
    if untestedCount > 0
        for untestedIndex = 0 to untestedCount - 1
            StoredLevel storedLevel = array.get(untestedArray, untestedIndex)
            string contextKey =
                 storedLevel.packName + "," +
                 storedLevel.formula + "," +
                 storedLevel.anchor + "," +
                 str.tostring(storedLevel.originTime)
            string canonicalKey =
                 storedLevel.anchor + "," +
                 str.tostring(storedLevel.originTime) + "," +
                 storedLevel.levelName + "," +
                 str.tostring(storedLevel.center, format.mintick)
            addCandidate(
                 bottomsArray, topsArray, centersArray, packsArray, formulasArray, anchorsArray,
                 levelsArray, originsArray, contextsArray, canonicalArray,
                 storedLevel.bottom,
                 storedLevel.top,
                 storedLevel.center,
                 storedLevel.packName,
                 storedLevel.formula,
                 storedLevel.anchor,
                 storedLevel.levelName,
                 storedLevel.originTime,
                 contextKey,
                 canonicalKey)

swapCandidate(
     array<float> bottomsArray,
     array<float> topsArray,
     array<float> centersArray,
     array<string> packsArray,
     array<string> formulasArray,
     array<string> anchorsArray,
     array<string> levelsArray,
     array<int> originsArray,
     array<string> contextsArray,
     array<string> canonicalArray,
     int firstIndex,
     int secondIndex) =>
    float firstBottom = array.get(bottomsArray, firstIndex)
    array.set(bottomsArray, firstIndex, array.get(bottomsArray, secondIndex))
    array.set(bottomsArray, secondIndex, firstBottom)

    float firstTop = array.get(topsArray, firstIndex)
    array.set(topsArray, firstIndex, array.get(topsArray, secondIndex))
    array.set(topsArray, secondIndex, firstTop)

    float firstCenter = array.get(centersArray, firstIndex)
    array.set(centersArray, firstIndex, array.get(centersArray, secondIndex))
    array.set(centersArray, secondIndex, firstCenter)

    string firstPack = array.get(packsArray, firstIndex)
    array.set(packsArray, firstIndex, array.get(packsArray, secondIndex))
    array.set(packsArray, secondIndex, firstPack)

    string firstFormula = array.get(formulasArray, firstIndex)
    array.set(formulasArray, firstIndex, array.get(formulasArray, secondIndex))
    array.set(formulasArray, secondIndex, firstFormula)

    string firstAnchor = array.get(anchorsArray, firstIndex)
    array.set(anchorsArray, firstIndex, array.get(anchorsArray, secondIndex))
    array.set(anchorsArray, secondIndex, firstAnchor)

    string firstLevel = array.get(levelsArray, firstIndex)
    array.set(levelsArray, firstIndex, array.get(levelsArray, secondIndex))
    array.set(levelsArray, secondIndex, firstLevel)

    int firstOrigin = array.get(originsArray, firstIndex)
    array.set(originsArray, firstIndex, array.get(originsArray, secondIndex))
    array.set(originsArray, secondIndex, firstOrigin)

    string firstContext = array.get(contextsArray, firstIndex)
    array.set(contextsArray, firstIndex, array.get(contextsArray, secondIndex))
    array.set(contextsArray, secondIndex, firstContext)

    string firstCanonical = array.get(canonicalArray, firstIndex)
    array.set(canonicalArray, firstIndex, array.get(canonicalArray, secondIndex))
    array.set(canonicalArray, secondIndex, firstCanonical)

sortCandidates(
     array<float> bottomsArray,
     array<float> topsArray,
     array<float> centersArray,
     array<string> packsArray,
     array<string> formulasArray,
     array<string> anchorsArray,
     array<string> levelsArray,
     array<int> originsArray,
     array<string> contextsArray,
     array<string> canonicalArray) =>
    int candidateCount = array.size(bottomsArray)
    if candidateCount > 1
        for outerIndex = 1 to candidateCount - 1
            int innerIndex = outerIndex
            while innerIndex > 0 and array.get(bottomsArray, innerIndex) < array.get(bottomsArray, innerIndex - 1)
                swapCandidate(
                     bottomsArray, topsArray, centersArray, packsArray, formulasArray, anchorsArray,
                     levelsArray, originsArray, contextsArray, canonicalArray,
                     innerIndex, innerIndex - 1)
                innerIndex -= 1

formulaLabelInPackOrder(string formulaA, string formulaB, string formulaC) =>
    string labelText = ""
    string formulaMembers = "|"
    if str.length(formulaA) > 0
        labelText := formulaA
        formulaMembers += formulaA + "|"
    if str.length(formulaB) > 0 and not str.contains(formulaMembers, "|" + formulaB + "|")
        labelText := str.length(labelText) == 0 ? formulaB : labelText + " + " + formulaB
        formulaMembers += formulaB + "|"
    if str.length(formulaC) > 0 and not str.contains(formulaMembers, "|" + formulaC + "|")
        labelText := str.length(labelText) == 0 ? formulaC : labelText + " + " + formulaC
    labelText

buildConfluence(
     array<float> bottomsArray,
     array<float> topsArray,
     array<string> packsArray,
     array<string> formulasArray,
     array<int> originsArray,
     array<string> contextsArray,
     array<string> canonicalArray,
     array<float> clusterBottomsArray,
     array<float> clusterTopsArray,
     array<int> clusterCountsArray,
     array<int> clusterOriginsArray,
     array<string> clusterMembersArray,
     array<string> clusterFormulasArray,
     array<string> clusterDetailsArray) =>
    array.clear(clusterBottomsArray)
    array.clear(clusterTopsArray)
    array.clear(clusterCountsArray)
    array.clear(clusterOriginsArray)
    array.clear(clusterMembersArray)
    array.clear(clusterFormulasArray)
    array.clear(clusterDetailsArray)

    int candidateCount = array.size(bottomsArray)
    if candidateCount > 0
        float runningBottom = array.get(bottomsArray, 0)
        float runningTop = array.get(topsArray, 0)
        int runningOrigin = array.get(originsArray, 0)
        string firstPack = array.get(packsArray, 0)
        string firstFormula = array.get(formulasArray, 0)
        string firstContext = array.get(contextsArray, 0)
        string runningPackMembers = "|" + firstPack + "|"
        string runningFormulaA = firstPack == "A" ? firstFormula : ""
        string runningFormulaB = firstPack == "B" ? firstFormula : ""
        string runningFormulaC = firstPack == "C" ? firstFormula : ""
        string runningMembers = "|" + firstContext + "|"
        string runningCanonicalMembers = "|" + array.get(canonicalArray, 0) + "|"
        int runningPackCount = 1

        if candidateCount > 1
            for candidateIndex = 1 to candidateCount - 1
                float candidateBottom = array.get(bottomsArray, candidateIndex)
                float candidateTop = array.get(topsArray, candidateIndex)
                int candidateOrigin = array.get(originsArray, candidateIndex)
                string candidatePack = array.get(packsArray, candidateIndex)
                string candidateFormula = array.get(formulasArray, candidateIndex)
                string candidateContext = array.get(contextsArray, candidateIndex)
                bool overlaps = candidateBottom <= runningTop and candidateTop >= runningBottom
                if overlaps
                    runningBottom := math.min(runningBottom, candidateBottom)
                    runningTop := math.max(runningTop, candidateTop)
                    // A zone starts only when its latest contributor exists.
                    runningOrigin := math.max(runningOrigin, candidateOrigin)
                    bool newPack = not str.contains(runningPackMembers, "|" + candidatePack + "|")
                    if newPack
                        runningPackMembers += candidatePack + "|"
                        runningPackCount += 1
                    if candidatePack == "A"
                        runningFormulaA := candidateFormula
                    else if candidatePack == "B"
                        runningFormulaB := candidateFormula
                    else if candidatePack == "C"
                        runningFormulaC := candidateFormula
                    bool newContext = not str.contains(runningMembers, "|" + candidateContext + "|")
                    if newContext
                        runningMembers += candidateContext + "|"
                    string candidateCanonical = array.get(canonicalArray, candidateIndex)
                    bool newCanonical =
                         not str.contains(runningCanonicalMembers, "|" + candidateCanonical + "|")
                    if newCanonical
                        runningCanonicalMembers += candidateCanonical + "|"
                else
                    array.push(clusterBottomsArray, runningBottom)
                    array.push(clusterTopsArray, runningTop)
                    array.push(clusterCountsArray, runningPackCount)
                    array.push(clusterOriginsArray, runningOrigin)
                    array.push(clusterMembersArray, runningMembers)
                    array.push(
                         clusterFormulasArray,
                         formulaLabelInPackOrder(runningFormulaA, runningFormulaB, runningFormulaC))
                    array.push(clusterDetailsArray, runningCanonicalMembers)

                    runningBottom := candidateBottom
                    runningTop := candidateTop
                    runningOrigin := candidateOrigin
                    runningPackMembers := "|" + candidatePack + "|"
                    runningFormulaA := candidatePack == "A" ? candidateFormula : ""
                    runningFormulaB := candidatePack == "B" ? candidateFormula : ""
                    runningFormulaC := candidatePack == "C" ? candidateFormula : ""
                    runningMembers := "|" + candidateContext + "|"
                    runningCanonicalMembers := "|" + array.get(canonicalArray, candidateIndex) + "|"
                    runningPackCount := 1

        array.push(clusterBottomsArray, runningBottom)
        array.push(clusterTopsArray, runningTop)
        array.push(clusterCountsArray, runningPackCount)
        array.push(clusterOriginsArray, runningOrigin)
        array.push(clusterMembersArray, runningMembers)
        array.push(
             clusterFormulasArray,
             formulaLabelInPackOrder(runningFormulaA, runningFormulaB, runningFormulaC))
        array.push(clusterDetailsArray, runningCanonicalMembers)

retainConfluenceStatusKeys(
     array<string> testedKeysArray,
     array<float> clusterBottomsArray,
     array<float> clusterTopsArray,
     array<int> clusterCountsArray,
     array<int> clusterOriginsArray,
     array<string> clusterMembersArray,
     array<string> clusterDetailsArray) =>
    int testedIndex = array.size(testedKeysArray) - 1
    while testedIndex >= 0
        string testedKey = array.get(testedKeysArray, testedIndex)
        bool stillCurrent = false
        int clusterCount = array.size(clusterBottomsArray)
        if clusterCount > 0
            for clusterIndex = 0 to clusterCount - 1
                if array.get(clusterCountsArray, clusterIndex) >= 2
                    string clusterKey = confluenceIdentity(
                         array.get(clusterBottomsArray, clusterIndex),
                         array.get(clusterTopsArray, clusterIndex),
                         array.get(clusterOriginsArray, clusterIndex),
                         array.get(clusterMembersArray, clusterIndex),
                         array.get(clusterDetailsArray, clusterIndex))
                    if clusterKey == testedKey
                        stillCurrent := true
        if not stillCurrent
            array.remove(testedKeysArray, testedIndex)
        testedIndex -= 1

drawConfluence(
     array<float> clusterBottomsArray,
     array<float> clusterTopsArray,
     array<int> clusterCountsArray,
     array<int> clusterOriginsArray,
     array<string> clusterFormulasArray,
     array<bool> clusterTestedArray,
     array<float> labelBottomsArray,
     array<float> labelTopsArray,
     array<int> labelLanesArray,
     array<box> boxesArray,
     array<label> labelsArray) =>
    if enableConfluenceInput
        int currentRight = currentChartBarRightTime()
        int offsetRight = labelOffsetTime()
        bool extendRight = confluenceProjectionInput == CONFLUENCE_EXTEND_RIGHT
        int rightTime =
             confluenceProjectionInput == CONFLUENCE_LABEL_OFFSET ?
             offsetRight :
             currentRight
        int labelTime = extendRight ? offsetRight : rightTime
        int clusterCount = array.size(clusterBottomsArray)
        int rendered = 0
        int clusterIndex = 0
        while clusterIndex < clusterCount and rendered < MAX_CONFLUENCE
            int packCount = array.get(clusterCountsArray, clusterIndex)
            if packCount >= 2
                float clusterBottom = array.get(clusterBottomsArray, clusterIndex)
                float clusterTop = array.get(clusterTopsArray, clusterIndex)
                int clusterOrigin = array.get(clusterOriginsArray, clusterIndex)
                string formulaText = array.get(clusterFormulasArray, clusterIndex)
                bool tested =
                     clusterIndex < array.size(clusterTestedArray) and
                     array.get(clusterTestedArray, clusterIndex)
                color clusterColor = statusColor(confluenceColorInput, true, tested)
                string clusterStyle = statusStyle("Solid", true, tested)
                box clusterBoxID = box.new(
                     left = clusterOrigin,
                     top = clusterTop,
                     right = rightTime,
                     bottom = clusterBottom,
                     xloc = xloc.bar_time,
                     extend = extendRight ? extend.right : extend.none,
                     border_color = color.new(clusterColor, 35),
                     border_style = lineStyleFromInput(clusterStyle),
                     bgcolor = color.new(clusterColor, zoneTransparencyInput))
                array.push(boxesArray, clusterBoxID)

                bool showClusterLabel = true
                int resolvedLabelTime = labelTime
                string resolvedFormulaText = formulaText
                if colorByStatusInput and showStatusLabelsInput
                    int labelLane = reserveStatusLabelLane(
                         clusterBottom,
                         clusterTop,
                         labelBottomsArray,
                         labelTopsArray,
                         labelLanesArray)
                    showClusterLabel := labelLane >= 0
                    if labelLane >= 0
                        resolvedLabelTime := statusLabelTime(labelLane)
                        resolvedFormulaText := statusName(tested) + " · " + formulaText
                if showClusterLabel
                    label clusterLabelID = label.new(
                         x = resolvedLabelTime,
                         y = (clusterTop + clusterBottom) / 2.0,
                         text = resolvedFormulaText,
                         xloc = xloc.bar_time,
                         style = label.style_label_left,
                         color = color.new(clusterColor, 72),
                         textcolor = confluenceTextColorInput,
                         size = chartLabelTextSize())
                    array.push(labelsArray, clusterLabelID)
                rendered += 1
            clusterIndex += 1

// Context helpers

cprRelationship(
     float currentBottom,
     float currentTop,
     float previousBottom,
     float previousTop) =>
    float tolerance = syminfo.mintick
    string relationship = if na(currentBottom) or na(currentTop) or na(previousBottom) or na(previousTop)
        "WARMING UP"
    else if math.abs(currentBottom - previousBottom) <= tolerance and math.abs(currentTop - previousTop) <= tolerance
        "Unchanged Value"
    else if currentBottom > previousTop + tolerance
        "Higher Value"
    else if currentTop < previousBottom - tolerance
        "Lower Value"
    else if currentBottom <= previousBottom + tolerance and currentTop >= previousTop - tolerance
        "Outside Value"
    else if currentBottom >= previousBottom - tolerance and currentTop <= previousTop + tolerance
        "Inside Value"
    else if currentTop > previousTop
        "Overlapping Higher Value"
    else
        "Overlapping Lower Value"
    relationship

openLocation(float anchorOpen, float cprBottom, float cprTop) =>
    string location = if na(anchorOpen) or na(cprBottom) or na(cprTop)
        "NO DATA"
    else if anchorOpen > cprTop
        "Above CPR"
    else if anchorOpen < cprBottom
        "Below CPR"
    else
        "Inside CPR"
    location

// Plain-language read: price location vs CPR/R1/S1, plus the prior-period CPR relationship.
chartRead(float priceValue, float cprBottom, float cprTop, float r1Level, float s1Level, string relationship) =>
    string location = if na(priceValue) or na(cprBottom) or na(cprTop) or na(r1Level) or na(s1Level)
        "NO DATA"
    else if priceValue > r1Level
        "Above R1"
    else if priceValue > cprTop
        "Above CPR"
    else if priceValue >= cprBottom
        "Inside CPR"
    else if priceValue >= s1Level
        "Below CPR"
    else
        "Below S1"
    bool hasRelationship = relationship != "" and relationship != "NO DATA" and relationship != "WARMING UP"
    string read = location == "NO DATA" ? "Warming up" : hasRelationship ? location + " · " + relationship : location
    read

// Selected formula equations for dashboard hover.
formulaTooltip(string formula) =>
    string equations = switch formula
        FORMULA_FLOOR_PIVOTS =>
             "• Inputs: prior H, L, C; Range = H − L.\n" +
             "• P = (H + L + C) / 3.\n" +
             "• R1 = 2P − L; S1 = 2P − H.\n" +
             "• R2/S2 = P ± Range.\n" +
             "• R3 = H + 2(P − L); S3 = L − 2(H − P)."
        FORMULA_FIBONACCI =>
             "• Inputs: prior H, L, C; Range = H − L.\n" +
             "• P = (H + L + C) / 3.\n" +
             "• R1/S1 = P ± 0.382 × Range.\n" +
             "• R2/S2 = P ± 0.618 × Range.\n" +
             "• R3/S3 = P ± Range."
        FORMULA_WOODIE =>
             "• Inputs: prior H/L and current anchor open O0; Range = H − L.\n" +
             "• P = (H + L + 2 × O0) / 4.\n" +
             "• R1 = 2P − L; S1 = 2P − H.\n" +
             "• R2/S2 = P ± Range.\n" +
             "• R3 = H + 2(P − L); S3 = L − 2(H − P).\n" +
             "• R4 = R3 + Range; S4 = S3 − Range."
        FORMULA_CLASSIC =>
             "• Inputs: prior H, L, C; Range = H − L.\n" +
             "• P = (H + L + C) / 3.\n" +
             "• R1 = 2P − L; S1 = 2P − H.\n" +
             "• R2/S2 = P ± Range.\n" +
             "• R3/S3 = P ± 2 × Range.\n" +
             "• R4/S4 = P ± 3 × Range."
        FORMULA_DM =>
             "• Inputs: prior O, H, L, C.\n" +
             "• If C = O: X = H + L + 2C.\n" +
             "• If C > O: X = 2H + L + C.\n" +
             "• If C < O: X = 2L + H + C.\n" +
             "• P = X / 4.\n" +
             "• R1 = X / 2 − L; S1 = X / 2 − H."
        FORMULA_CAMARILLA =>
             "• Inputs: prior H, L, C; Range = H − L.\n" +
             "• P = (H + L + C) / 3.\n" +
             "• H1/L1 (R1/S1) = C ± 1.1 × Range / 12.\n" +
             "• H2/L2 (R2/S2) = C ± 1.1 × Range / 6.\n" +
             "• H3/L3 (R3/S3) = C ± 1.1 × Range / 4.\n" +
             "• H4/L4 (R4/S4) = C ± 1.1 × Range / 2.\n" +
             "• If L ≠ 0: H5 = (H / L) × C; L5 = 2C − H5."
        FORMULA_FRANK_DILERNIA =>
             "• Inputs: prior H, L, C; Range = H − L.\n" +
             "• P = (H + L + C) / 3.\n" +
             "• R1/S1 = P ± 0.5 × Range.\n" +
             "• R2/S2 = P ± 0.618 × Range.\n" +
             "• R3/S3 = P ± Range."
        FORMULA_SHADOW_TRADER =>
             "• Inputs: prior H, L, C; Range = H − L.\n" +
             "• P = (H + L + C) / 3.\n" +
             "• R1 = 2P − L; S1 = 2P − H.\n" +
             "• R2/S2 = P ± (R1 − S1) = P ± Range.\n" +
             "• R3 = H + 2(P − L); S3 = L − 2(H − P).\n" +
             "• Matches the classic floor-pivot ladder (same R/S as Floor Pivots)."
        FORMULA_ACD_METHOD =>
             "• Inputs: prior H, L, C.\n" +
             "• P = (H + L + C) / 3.\n" +
             "• Offset = |(H + L) / 2 − P|.\n" +
             "• R1/S1 = P ± Offset."
        =>
             "• Formula details unavailable."
    equations + "\n• CPR uses a separate prior-H/L/C floor pivot."

nearestUntested(array<StoredLevel> untestedArray) =>
    float nearestDistance = na
    float nearestPrice = na
    string nearestName = ""
    int untestedCount = array.size(untestedArray)
    if untestedCount > 0
        for untestedIndex = 0 to untestedCount - 1
            StoredLevel storedLevel = array.get(untestedArray, untestedIndex)
            float distance = math.abs(close - storedLevel.center)
            if na(nearestDistance) or distance < nearestDistance
                nearestDistance := distance
                nearestPrice := storedLevel.center
                nearestName := storedLevel.packName + " " + storedLevel.levelName
    string nearestText =
         untestedCount == 0 ?
         "None" :
         nearestName
    string nearestTooltip =
         untestedCount == 0 ?
         "• No untested levels." :
         "• Closest to price: " + nearestName + " at " + str.tostring(nearestPrice, format.mintick) + ".\n" +
         "• Tested when a confirmed bar's wick overlaps its reaction zone."
    [nearestText, nearestTooltip]

dashboardTextSize(string sizeChoice) =>
    switch sizeChoice
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

dashboardPackValue(string formula, string status) =>
    status == "ACTIVE" ? formula : formula + " · " + status

// Adds one confirmed event to the bar's dynamic alert message.
appendEvent(string currentMessage, bool signal, string eventName, string eventDetail) =>
    string nextMessage = currentMessage
    if signal
        string eventText =
             "event=" + eventName + "," + eventDetail + ",price=" + str.tostring(close, format.mintick)
        nextMessage := str.length(nextMessage) == 0 ? eventText : nextMessage + "\n" + eventText
    nextMessage

// Global calculations and state

string packAAnchor = resolveAnchor(packAAnchorInput)
string packBAnchor = resolveAnchor(packBAnchorInput)
string packCAnchor = resolveAnchor(packCAnchorInput)
// Simple preset caps every pack at R1/S1 for a clean default chart.
int presetTierCap = chartPresetInput == PRESET_SIMPLE ? 1 : 5
int packATiers = math.min(tiersFromChoice(packATierChoiceInput), presetTierCap)
int packBTiers = math.min(tiersFromChoice(packBTierChoiceInput), presetTierCap)
int packCTiers = math.min(tiersFromChoice(packCTierChoiceInput), presetTierCap)

bool packAAnchorValid = isAnchorValid(packAAnchor)
bool packBAnchorValid = isAnchorValid(packBAnchor)
bool packCAnchorValid = isAnchorValid(packCAnchor)

string packALadder = ladderIdentity(packAFormulaInput)
string packBLadder = ladderIdentity(packBFormulaInput)
string packCLadder = ladderIdentity(packCFormulaInput)

bool packADuplicate = false
bool packBDuplicate =
     packBEnabledInput and
     packAEnabledInput and
     packBLadder == packALadder and
     packBAnchor == packAAnchor
bool packCDuplicate =
     packCEnabledInput and
     ((packAEnabledInput and packCLadder == packALadder and packCAnchor == packAAnchor) or
      (packBEnabledInput and not packBDuplicate and packCLadder == packBLadder and packCAnchor == packBAnchor))

string standardTickerID = ticker.standard(syminfo.tickerid)
string chartSessionTickerID = ticker.modify(standardTickerID, session = syminfo.session)
bool futuresSymbol = syminfo.type == "futures"
string rthSessionID = futuresSymbol ? futuresRthSessionInput : session.regular
string ethSessionID = futuresSymbol ? session.regular : session.extended
string selectedSessionID = sessionBasisInput == SESSION_RTH ? rthSessionID : ethSessionID
string requestedTickerID =
     sessionBasisInput == SESSION_EXCHANGE_DEFAULT ?
     standardTickerID :
     ticker.modify(standardTickerID, session = selectedSessionID)
bool useRequestedData = useDailyBasedInput or not timeframe.isintraday
string dailyAtrTickerID = useRequestedData ? requestedTickerID : chartSessionTickerID

// Each pack may request a different bounded anchor.
AnchorData packARequestedData = requestedAnchorData(requestedTickerID, packAAnchor, atrLengthInput)
AnchorData packBRequestedData = requestedAnchorData(requestedTickerID, packBAnchor, atrLengthInput)
AnchorData packCRequestedData = requestedAnchorData(requestedTickerID, packCAnchor, atrLengthInput)

AnchorData packAChartData = chartAnchorData(packAAnchor, atrLengthInput)
AnchorData packBChartData = chartAnchorData(packBAnchor, atrLengthInput)
AnchorData packCChartData = chartAnchorData(packCAnchor, atrLengthInput)

AnchorData packAData = selectAnchorData(packARequestedData, packAChartData, useRequestedData)
AnchorData packBData = selectAnchorData(packBRequestedData, packBChartData, useRequestedData)
AnchorData packCData = selectAnchorData(packCRequestedData, packCChartData, useRequestedData)

float dailyAtr = request.security(
     dailyAtrTickerID,
     "1D",
     ta.atr(atrLengthInput)[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)

PivotSet packASet = calculatePivotSet(
     packAFormulaInput,
     packAData.previousOpen,
     packAData.previousHigh,
     packAData.previousLow,
     packAData.previousClose,
     packAData.currentOpen)
PivotSet packBSet = calculatePivotSet(
     packBFormulaInput,
     packBData.previousOpen,
     packBData.previousHigh,
     packBData.previousLow,
     packBData.previousClose,
     packBData.currentOpen)
PivotSet packCSet = calculatePivotSet(
     packCFormulaInput,
     packCData.previousOpen,
     packCData.previousHigh,
     packCData.previousLow,
     packCData.previousClose,
     packCData.currentOpen)

bool packADataReady = not na(packASet.p) and not na(packASet.cprP)
bool packBDataReady = not na(packBSet.p) and not na(packBSet.cprP)
bool packCDataReady = not na(packCSet.p) and not na(packCSet.cprP)

float packACurrentHalfWidth = zoneHalfWidth(dailyAtr, packAData.anchorAtr)
float packBCurrentHalfWidth = zoneHalfWidth(dailyAtr, packBData.anchorAtr)
float packCCurrentHalfWidth = zoneHalfWidth(dailyAtr, packCData.anchorAtr)

// Keeps each pack's reaction width fixed for its anchor.
var float packAZoneHalfWidth = na
var float packBZoneHalfWidth = na
var float packCZoneHalfWidth = na
if packAData.newPeriod
    packAZoneHalfWidth := na
if packBData.newPeriod
    packBZoneHalfWidth := na
if packCData.newPeriod
    packCZoneHalfWidth := na
if packADataReady and na(packAZoneHalfWidth)
    packAZoneHalfWidth := packACurrentHalfWidth
if packBDataReady and na(packBZoneHalfWidth)
    packBZoneHalfWidth := packBCurrentHalfWidth
if packCDataReady and na(packCZoneHalfWidth)
    packCZoneHalfWidth := packCCurrentHalfWidth

bool packAAtrReady = zoneModeInput == ZONE_TICKS or (zoneModeInput == ZONE_DAILY_ATR ? not na(dailyAtr) : not na(packAData.anchorAtr))
bool packBAtrReady = zoneModeInput == ZONE_TICKS or (zoneModeInput == ZONE_DAILY_ATR ? not na(dailyAtr) : not na(packBData.anchorAtr))
bool packCAtrReady = zoneModeInput == ZONE_TICKS or (zoneModeInput == ZONE_DAILY_ATR ? not na(dailyAtr) : not na(packCData.anchorAtr))

bool packAOperational = packAEnabledInput and not packADuplicate and packAAnchorValid and packADataReady
bool packBOperational = packBEnabledInput and not packBDuplicate and packBAnchorValid and packBDataReady
bool packCOperational = packCEnabledInput and not packCDuplicate and packCAnchorValid and packCDataReady

string packAStatus = packStatus(packAEnabledInput, packADuplicate, packAAnchorValid, packADataReady, packAAtrReady)
string packBStatus = packStatus(packBEnabledInput, packBDuplicate, packBAnchorValid, packBDataReady, packBAtrReady)
string packCStatus = packStatus(packCEnabledInput, packCDuplicate, packCAnchorValid, packCDataReady, packCAtrReady)

bool anyEnabled = packAEnabledInput or packBEnabledInput or packCEnabledInput
bool anyConfiguredValid =
     (packAEnabledInput and packAAnchorValid) or
     (packBEnabledInput and packBAnchorValid and not packBDuplicate) or
     (packCEnabledInput and packCAnchorValid and not packCDuplicate)

if barstate.islast and not anyEnabled
    runtime.error("Pivot Matrix + Zones [AFD]: enable at least one pivot pack.")
if barstate.islast and not useDailyBasedInput and not chart.is_standard
    runtime.error("Pivot Matrix + Zones [AFD]: chart-derived values require a standard time-based chart. Enable daily-based values or change chart type.")
if barstate.islast and anyEnabled and not anyConfiguredValid
    runtime.error("Pivot Matrix + Zones [AFD]: no enabled pack has a valid, non-duplicate anchor. Increase the pivot anchor or change a pack formula.")

var PivotSet lastPackASet = emptyPivotSet()
var PivotSet lastPackBSet = emptyPivotSet()
var PivotSet lastPackCSet = emptyPivotSet()
var bool lastPackAReady = false
var bool lastPackBReady = false
var bool lastPackCReady = false
var float lastPackAZoneHalfWidth = syminfo.mintick
var float lastPackBZoneHalfWidth = syminfo.mintick
var float lastPackCZoneHalfWidth = syminfo.mintick
var int lastPackAPeriodStart = na
var int lastPackBPeriodStart = na
var int lastPackCPeriodStart = na
var int lastPackAPeriodEnd = na
var int lastPackBPeriodEnd = na
var int lastPackCPeriodEnd = na
var bool packAContextComplete = false
var bool packBContextComplete = false
var bool packCContextComplete = false
var float previousPackACprBottom = na
var float previousPackACprTop = na
var float previousPackBCprBottom = na
var float previousPackBCprTop = na
var float previousPackCCprBottom = na
var float previousPackCCprTop = na

var array<bool> packATouchedArray = array.new_bool(12, false)
var array<bool> packBTouchedArray = array.new_bool(12, false)
var array<bool> packCTouchedArray = array.new_bool(12, false)
var array<StoredLevel> untestedArray = array.new<StoredLevel>()
var array<StoredLevel> testedArray = array.new<StoredLevel>()

if barstate.isconfirmed
    // Archive before the new-anchor bar tests retained levels.
    if packAData.newPeriod
        if lastPackAReady
            if packAContextComplete
                archivePack(
                     untestedArray,
                     testedArray,
                     packATouchedArray,
                     packAEnabledInput and packAAnchorValid and not packADuplicate,
                     lastPackASet,
                     lastPackAZoneHalfWidth,
                     "A",
                     packAFormulaInput,
                     packAAnchor,
                     packATiers,
                     packAShowFormulaPpInput,
                     packAShowCprInput,
                     lastPackAPeriodStart,
                     lastPackAPeriodEnd)
            previousPackACprBottom := lastPackASet.bc
            previousPackACprTop := lastPackASet.tc
        resetTouchedState(packATouchedArray)
        packAContextComplete := packAOperational

    if packBData.newPeriod
        if lastPackBReady
            if packBContextComplete
                archivePack(
                     untestedArray,
                     testedArray,
                     packBTouchedArray,
                     packBEnabledInput and packBAnchorValid and not packBDuplicate,
                     lastPackBSet,
                     lastPackBZoneHalfWidth,
                     "B",
                     packBFormulaInput,
                     packBAnchor,
                     packBTiers,
                     packBShowFormulaPpInput,
                     packBShowCprInput,
                     lastPackBPeriodStart,
                     lastPackBPeriodEnd)
            previousPackBCprBottom := lastPackBSet.bc
            previousPackBCprTop := lastPackBSet.tc
        resetTouchedState(packBTouchedArray)
        packBContextComplete := packBOperational

    if packCData.newPeriod
        if lastPackCReady
            if packCContextComplete
                archivePack(
                     untestedArray,
                     testedArray,
                     packCTouchedArray,
                     packCEnabledInput and packCAnchorValid and not packCDuplicate,
                     lastPackCSet,
                     lastPackCZoneHalfWidth,
                     "C",
                     packCFormulaInput,
                     packCAnchor,
                     packCTiers,
                     packCShowFormulaPpInput,
                     packCShowCprInput,
                     lastPackCPeriodStart,
                     lastPackCPeriodEnd)
            previousPackCCprBottom := lastPackCSet.bc
            previousPackCCprTop := lastPackCSet.tc
        resetTouchedState(packCTouchedArray)
        packCContextComplete := packCOperational

[untestedFilledNow, untestedFillDetail] = processUntested(untestedArray, testedArray)

if barstate.isconfirmed
    updateTouchedState(packATouchedArray, packAOperational, packAShowFormulaPpInput, packASet, packAZoneHalfWidth)
    updateTouchedState(packBTouchedArray, packBOperational, packBShowFormulaPpInput, packBSet, packBZoneHalfWidth)
    updateTouchedState(packCTouchedArray, packCOperational, packCShowFormulaPpInput, packCSet, packCZoneHalfWidth)

    // Requested data is ready when its anchor-opening snapshot arrives.
    if useRequestedData and packAOperational
        packAContextComplete := true
    if useRequestedData and packBOperational
        packBContextComplete := true
    if useRequestedData and packCOperational
        packCContextComplete := true

    if packADataReady
        lastPackASet := packASet
        lastPackAReady := true
        lastPackAZoneHalfWidth := packAZoneHalfWidth
        lastPackAPeriodStart := packAData.periodStart
        lastPackAPeriodEnd := packAData.periodEnd
    if packBDataReady
        lastPackBSet := packBSet
        lastPackBReady := true
        lastPackBZoneHalfWidth := packBZoneHalfWidth
        lastPackBPeriodStart := packBData.periodStart
        lastPackBPeriodEnd := packBData.periodEnd
    if packCDataReady
        lastPackCSet := packCSet
        lastPackCReady := true
        lastPackCZoneHalfWidth := packCZoneHalfWidth
        lastPackCPeriodStart := packCData.periodStart
        lastPackCPeriodEnd := packCData.periodEnd

// Duplicate PP prices cannot count as extra confluence packs.
var array<float> candidateBottomsArray = array.new_float()
var array<float> candidateTopsArray = array.new_float()
var array<float> candidateCentersArray = array.new_float()
var array<string> candidatePacksArray = array.new_string()
var array<string> candidateFormulasArray = array.new_string()
var array<string> candidateAnchorsArray = array.new_string()
var array<string> candidateLevelsArray = array.new_string()
var array<int> candidateOriginsArray = array.new_int()
var array<string> candidateContextsArray = array.new_string()
var array<string> candidateCanonicalArray = array.new_string()

array.clear(candidateBottomsArray)
array.clear(candidateTopsArray)
array.clear(candidateCentersArray)
array.clear(candidatePacksArray)
array.clear(candidateFormulasArray)
array.clear(candidateAnchorsArray)
array.clear(candidateLevelsArray)
array.clear(candidateOriginsArray)
array.clear(candidateContextsArray)
array.clear(candidateCanonicalArray)

addPackCandidates(
     candidateBottomsArray, candidateTopsArray, candidateCentersArray,
     candidatePacksArray, candidateFormulasArray, candidateAnchorsArray,
     candidateLevelsArray, candidateOriginsArray, candidateContextsArray, candidateCanonicalArray,
     packAOperational, "A", packAFormulaInput, packAAnchor, packATiers, packAShowFormulaPpInput, packAShowCprInput,
     packASet, packAZoneHalfWidth, packAData.periodStart)
addPackCandidates(
     candidateBottomsArray, candidateTopsArray, candidateCentersArray,
     candidatePacksArray, candidateFormulasArray, candidateAnchorsArray,
     candidateLevelsArray, candidateOriginsArray, candidateContextsArray, candidateCanonicalArray,
     packBOperational, "B", packBFormulaInput, packBAnchor, packBTiers, packBShowFormulaPpInput, packBShowCprInput,
     packBSet, packBZoneHalfWidth, packBData.periodStart)
addPackCandidates(
     candidateBottomsArray, candidateTopsArray, candidateCentersArray,
     candidatePacksArray, candidateFormulasArray, candidateAnchorsArray,
     candidateLevelsArray, candidateOriginsArray, candidateContextsArray, candidateCanonicalArray,
     packCOperational, "C", packCFormulaInput, packCAnchor, packCTiers, packCShowFormulaPpInput, packCShowCprInput,
     packCSet, packCZoneHalfWidth, packCData.periodStart)

int currentCandidateCount = array.size(candidateBottomsArray)

var bool previousPackAOperational = false
var bool previousPackBOperational = false
var bool previousPackCOperational = false
var int previousPackAPeriodStart = na
var int previousPackBPeriodStart = na
var int previousPackCPeriodStart = na

bool packAGeometryChanged =
     packAOperational != previousPackAOperational or
     (packAOperational and (na(previousPackAPeriodStart) or packAData.periodStart != previousPackAPeriodStart))
bool packBGeometryChanged =
     packBOperational != previousPackBOperational or
     (packBOperational and (na(previousPackBPeriodStart) or packBData.periodStart != previousPackBPeriodStart))
bool packCGeometryChanged =
     packCOperational != previousPackCOperational or
     (packCOperational and (na(previousPackCPeriodStart) or packCData.periodStart != previousPackCPeriodStart))

bool activeTouchNow = false
bool crossUpNow = false
bool crossDownNow = false
string activeTouchDetail = ""
string crossUpDetail = ""
string crossDownDetail = ""
var array<string> previousActiveTouchKeysArray = array.new_string()
var array<string> currentActiveTouchKeysArray = array.new_string()
array.clear(currentActiveTouchKeysArray)

if currentCandidateCount > 0
    for candidateIndex = 0 to currentCandidateCount - 1
        float candidateBottom = array.get(candidateBottomsArray, candidateIndex)
        float candidateTop = array.get(candidateTopsArray, candidateIndex)
        float candidateCenter = array.get(candidateCentersArray, candidateIndex)
        string candidatePack = array.get(candidatePacksArray, candidateIndex)
        string candidateKey = array.get(candidateCanonicalArray, candidateIndex)
        string candidateDetail =
             "pack=" + candidatePack +
             ",formula=" + array.get(candidateFormulasArray, candidateIndex) +
             ",anchor=" + array.get(candidateAnchorsArray, candidateIndex) +
             ",level=" + array.get(candidateLevelsArray, candidateIndex) +
             ",origin=" + str.tostring(array.get(candidateOriginsArray, candidateIndex))
        bool candidateTouched = high >= candidateBottom and low <= candidateTop
        bool candidateGeometryChanged = switch candidatePack
            "A" => packAGeometryChanged
            "B" => packBGeometryChanged
            "C" => packCGeometryChanged
            => false
        bool crossedUp = not candidateGeometryChanged and close > candidateCenter and close[1] <= candidateCenter
        bool crossedDown = not candidateGeometryChanged and close < candidateCenter and close[1] >= candidateCenter
        if candidateTouched
            array.push(currentActiveTouchKeysArray, candidateKey)
            bool newCandidateTouch = not stringArrayContains(previousActiveTouchKeysArray, candidateKey)
            if newCandidateTouch and not activeTouchNow
                activeTouchNow := true
                activeTouchDetail := candidateDetail
        if crossedUp and not crossUpNow
            crossUpNow := true
            crossUpDetail := candidateDetail
        if crossedDown and not crossDownNow
            crossDownNow := true
            crossDownDetail := candidateDetail

var array<float> clusterBottomsArray = array.new_float()
var array<float> clusterTopsArray = array.new_float()
var array<int> clusterCountsArray = array.new_int()
var array<int> clusterOriginsArray = array.new_int()
var array<string> clusterMembersArray = array.new_string()
var array<string> clusterFormulasArray = array.new_string()
var array<string> clusterDetailsArray = array.new_string()
var array<string> testedConfluenceKeysArray = array.new_string()
var bool confluenceInitialized = false
bool confluenceGeometryChanged =
     enableConfluenceInput and
     (not confluenceInitialized or
      packAGeometryChanged or
      packBGeometryChanged or
      packCGeometryChanged or
      untestedFilledNow)

if confluenceGeometryChanged
    addUntestedCandidates(
         candidateBottomsArray, candidateTopsArray, candidateCentersArray,
         candidatePacksArray, candidateFormulasArray, candidateAnchorsArray,
         candidateLevelsArray, candidateOriginsArray, candidateContextsArray, candidateCanonicalArray,
         untestedArray)
    sortCandidates(
         candidateBottomsArray, candidateTopsArray, candidateCentersArray,
         candidatePacksArray, candidateFormulasArray, candidateAnchorsArray,
         candidateLevelsArray, candidateOriginsArray, candidateContextsArray, candidateCanonicalArray)
    buildConfluence(
         candidateBottomsArray,
         candidateTopsArray,
         candidatePacksArray,
         candidateFormulasArray,
         candidateOriginsArray,
         candidateContextsArray,
         candidateCanonicalArray,
         clusterBottomsArray,
         clusterTopsArray,
         clusterCountsArray,
         clusterOriginsArray,
         clusterMembersArray,
         clusterFormulasArray,
         clusterDetailsArray)
    retainConfluenceStatusKeys(
         testedConfluenceKeysArray,
         clusterBottomsArray,
         clusterTopsArray,
         clusterCountsArray,
         clusterOriginsArray,
         clusterMembersArray,
         clusterDetailsArray)
    confluenceInitialized := true

bool confluenceTouchNow = false
string confluenceTouchDetail = ""
var array<string> previousConfluenceTouchKeysArray = array.new_string()
var array<string> currentConfluenceTouchKeysArray = array.new_string()
var array<bool> clusterTestedArray = array.new_bool()
array.clear(currentConfluenceTouchKeysArray)
array.clear(clusterTestedArray)
int clusterCountForAlerts = enableConfluenceInput ? array.size(clusterBottomsArray) : 0
int acceptedClusterCount = 0
int alertClusterIndex = 0
while alertClusterIndex < clusterCountForAlerts and acceptedClusterCount < MAX_CONFLUENCE
    int packCount = array.get(clusterCountsArray, alertClusterIndex)
    bool clusterWasTested = false
    if packCount >= 2
        float clusterBottom = array.get(clusterBottomsArray, alertClusterIndex)
        float clusterTop = array.get(clusterTopsArray, alertClusterIndex)
        int clusterOrigin = array.get(clusterOriginsArray, alertClusterIndex)
        string clusterKey = confluenceIdentity(
             clusterBottom,
             clusterTop,
             clusterOrigin,
             array.get(clusterMembersArray, alertClusterIndex),
             array.get(clusterDetailsArray, alertClusterIndex))
        bool clusterTouched = high >= clusterBottom and low <= clusterTop
        clusterWasTested := stringArrayContains(testedConfluenceKeysArray, clusterKey)
        if barstate.isconfirmed and clusterTouched and not clusterWasTested
            array.push(testedConfluenceKeysArray, clusterKey)
            clusterWasTested := true
        if clusterTouched
            array.push(currentConfluenceTouchKeysArray, clusterKey)
            bool newClusterTouch = not stringArrayContains(previousConfluenceTouchKeysArray, clusterKey)
            if newClusterTouch and not confluenceTouchNow
                confluenceTouchNow := true
                confluenceTouchDetail :=
                     "pack=Multiple,formula=Mixed,anchor=Mixed,level=Confluence x" +
                     str.tostring(packCount) +
                     ",origin=" + str.tostring(clusterOrigin)
        acceptedClusterCount += 1
    array.push(clusterTestedArray, clusterWasTested)
    alertClusterIndex += 1

var bool hasCprState = false
var bool wasInsideCpr = false

// The CPR toggle hides drawings; it does not silence these two alerts.
bool insideCprNow =
     packAOperational and
     close >= packASet.bc and
     close <= packASet.tc
bool activeTouchSignal = barstate.isconfirmed and activeTouchNow
bool crossUpSignal = barstate.isconfirmed and crossUpNow
bool crossDownSignal = barstate.isconfirmed and crossDownNow
bool comparableCprState = hasCprState and not packAData.newPeriod
bool cprEnterSignal = barstate.isconfirmed and comparableCprState and insideCprNow and not wasInsideCpr
bool cprExitSignal = barstate.isconfirmed and comparableCprState and not insideCprNow and wasInsideCpr
bool untestedFilledSignal = barstate.isconfirmed and untestedFilledNow
bool confluenceTouchSignal = enableConfluenceInput and barstate.isconfirmed and confluenceTouchNow

if barstate.isconfirmed
    copyStringArray(previousActiveTouchKeysArray, currentActiveTouchKeysArray)
    copyStringArray(previousConfluenceTouchKeysArray, currentConfluenceTouchKeysArray)
    previousPackAOperational := packAOperational
    previousPackBOperational := packBOperational
    previousPackCOperational := packCOperational
    previousPackAPeriodStart := packAData.periodStart
    previousPackBPeriodStart := packBData.periodStart
    previousPackCPeriodStart := packCData.periodStart
    if packAOperational
        wasInsideCpr := insideCprNow
        hasCprState := true
    else
        wasInsideCpr := false
        hasCprState := false

string cprDetail =
     "pack=A,formula=" + packAFormulaInput +
     ",anchor=" + packAAnchor +
     ",level=CPR,origin=" + str.tostring(packAData.periodStart)

string dynamicMessage = ""
dynamicMessage := appendEvent(dynamicMessage, activeTouchSignal, "Active Level Touch", activeTouchDetail)
dynamicMessage := appendEvent(dynamicMessage, crossUpSignal, "Cross Up", crossUpDetail)
dynamicMessage := appendEvent(dynamicMessage, crossDownSignal, "Cross Down", crossDownDetail)
dynamicMessage := appendEvent(dynamicMessage, cprEnterSignal, "CPR Enter", cprDetail)
dynamicMessage := appendEvent(dynamicMessage, cprExitSignal, "CPR Exit", cprDetail)
dynamicMessage := appendEvent(dynamicMessage, untestedFilledSignal, "Untested Level Filled", untestedFillDetail)
dynamicMessage := appendEvent(dynamicMessage, confluenceTouchSignal, "Confluence Touch", confluenceTouchDetail)

if dynamicAlertsInput and barstate.isconfirmed and str.length(dynamicMessage) > 0
    alert(dynamicMessage, alert.freq_once_per_bar_close)

// Visuals

var array<line> activeLinesArray = array.new_line()
var array<box> activeBoxesArray = array.new_box()
var array<label> activeLabelsArray = array.new_label()
var array<float> statusLabelBottomsArray = array.new_float()
var array<float> statusLabelTopsArray = array.new_float()
var array<int> statusLabelLanesArray = array.new_int()
var table dashboard = table.new(
     position.top_right,
     2,
     8,
     bgcolor = color.new(color.rgb(10, 15, 22), 6),
     frame_color = color.new(color.rgb(240, 185, 90), 62),
     frame_width = 1,
     border_color = color.new(color.rgb(70, 88, 112), 68),
     border_width = 1)

if barstate.islast
    clearLines(activeLinesArray)
    clearBoxes(activeBoxesArray)
    clearLabels(activeLabelsArray)
    array.clear(statusLabelBottomsArray)
    array.clear(statusLabelTopsArray)
    array.clear(statusLabelLanesArray)

    if not (enableConfluenceInput and confluenceOnlyInput)
        drawPack(
             packAOperational, packAFormulaInput, packATiers, packAShowFormulaPpInput, packAShowCprInput,
             packAShowLabelsInput, packAColorInput, packAStyleInput, packASet,
             packAZoneHalfWidth, packAData.activeStart, packAData.periodEnd,
             packATouchedArray,
             statusLabelBottomsArray, statusLabelTopsArray, statusLabelLanesArray,
             activeLinesArray, activeBoxesArray, activeLabelsArray)
        drawPack(
             packBOperational, packBFormulaInput, packBTiers, packBShowFormulaPpInput, packBShowCprInput,
             packBShowLabelsInput, packBColorInput, packBStyleInput, packBSet,
             packBZoneHalfWidth, packBData.activeStart, packBData.periodEnd,
             packBTouchedArray,
             statusLabelBottomsArray, statusLabelTopsArray, statusLabelLanesArray,
             activeLinesArray, activeBoxesArray, activeLabelsArray)
        drawPack(
             packCOperational, packCFormulaInput, packCTiers, packCShowFormulaPpInput, packCShowCprInput,
             packCShowLabelsInput, packCColorInput, packCStyleInput, packCSet,
             packCZoneHalfWidth, packCData.activeStart, packCData.periodEnd,
             packCTouchedArray,
             statusLabelBottomsArray, statusLabelTopsArray, statusLabelLanesArray,
             activeLinesArray, activeBoxesArray, activeLabelsArray)

        drawDevelopingCpr(packAOperational, packAData, activeLinesArray, activeLabelsArray)
    drawConfluence(
         clusterBottomsArray,
         clusterTopsArray,
         clusterCountsArray,
         clusterOriginsArray,
         clusterFormulasArray,
         clusterTestedArray,
         statusLabelBottomsArray,
         statusLabelTopsArray,
         statusLabelLanesArray,
         activeBoxesArray,
         activeLabelsArray)

    if colorByStatusInput and showStatusHistoryInput and showStatusLabelsInput and not (enableConfluenceInput and confluenceOnlyInput)
        drawStoredStatusLabels(
             untestedArray,
             false,
             statusLabelBottomsArray,
             statusLabelTopsArray,
             statusLabelLanesArray,
             activeLabelsArray)
        drawStoredStatusLabels(
             testedArray,
             true,
             statusLabelBottomsArray,
             statusLabelTopsArray,
             statusLabelLanesArray,
             activeLabelsArray)

    table.clear(dashboard, 0, 0, 1, 7)
    if showDashboardInput
        // Follow the first OPERATIONAL pack, so an enabled-but-invalid pack A
        // cannot blank the card while B or C draws; else the first enabled one.
        bool anyPackOperational = packAOperational or packBOperational or packCOperational
        bool dashboardUsesPackA = anyPackOperational ? packAOperational : packAEnabledInput
        bool dashboardUsesPackB = not dashboardUsesPackA and (anyPackOperational ? packBOperational : packBEnabledInput)
        bool dashboardUsesPackC = not dashboardUsesPackA and not dashboardUsesPackB and (anyPackOperational ? packCOperational : packCEnabledInput)
        bool dashboardPrimaryOperational =
             dashboardUsesPackA ? packAOperational :
             dashboardUsesPackB ? packBOperational :
             dashboardUsesPackC ? packCOperational :
             false
        float dashboardCprBottom =
             dashboardUsesPackA ? packASet.bc :
             dashboardUsesPackB ? packBSet.bc :
             dashboardUsesPackC ? packCSet.bc :
             na
        float dashboardCprTop =
             dashboardUsesPackA ? packASet.tc :
             dashboardUsesPackB ? packBSet.tc :
             dashboardUsesPackC ? packCSet.tc :
             na
        float dashboardAnchorOpen =
             dashboardUsesPackA ? packAData.currentOpen :
             dashboardUsesPackB ? packBData.currentOpen :
             dashboardUsesPackC ? packCData.currentOpen :
             na
        float dashboardPreviousCprBottom =
             dashboardUsesPackA ? previousPackACprBottom :
             dashboardUsesPackB ? previousPackBCprBottom :
             dashboardUsesPackC ? previousPackCCprBottom :
             na
        float dashboardPreviousCprTop =
             dashboardUsesPackA ? previousPackACprTop :
             dashboardUsesPackB ? previousPackBCprTop :
             dashboardUsesPackC ? previousPackCCprTop :
             na
        float dashboardR1 =
             dashboardUsesPackA ? packASet.r1 :
             dashboardUsesPackB ? packBSet.r1 :
             dashboardUsesPackC ? packCSet.r1 :
             na
        float dashboardS1 =
             dashboardUsesPackA ? packASet.s1 :
             dashboardUsesPackB ? packBSet.s1 :
             dashboardUsesPackC ? packCSet.s1 :
             na
        [nearestUntestedText, nearestUntestedTooltip] = nearestUntested(untestedArray)
        string relationshipText =
             dashboardPrimaryOperational ?
             cprRelationship(dashboardCprBottom, dashboardCprTop, dashboardPreviousCprBottom, dashboardPreviousCprTop) :
             "NO DATA"
        string anchorOpenLocation =
             dashboardPrimaryOperational ?
             openLocation(dashboardAnchorOpen, dashboardCprBottom, dashboardCprTop) :
             "NO DATA"
        string chartReadText =
             dashboardPrimaryOperational ?
             chartRead(close, dashboardCprBottom, dashboardCprTop, dashboardR1, dashboardS1, relationshipText) :
             "Warming up"
        string chartReadTooltip = "• Plain-language location of price vs the CPR and R1/S1, with the prior-period CPR relationship.\n• Descriptive context only — not a signal, target, or forecast."
        string cprRelationshipTooltip = "• Compares this pack's CPR band with the one before it, on whatever anchor the pack uses — two days on a Daily anchor, two weeks on Weekly, and so on.\n• Higher, Lower, Inside, Outside, Overlapping, or Unchanged Value."
        // Slate panel, gold accent: title bar, highlighted Read row, zebra rows.
        color accentColor = color.rgb(240, 185, 90)
        color headerColor = color.rgb(26, 41, 60)
        color readColor = color.new(accentColor, 88)
        color rowEvenColor = color.new(color.rgb(16, 23, 33), 6)
        color rowOddColor = color.new(color.rgb(24, 34, 47), 6)
        color labelColor = color.rgb(148, 165, 188)
        color valueColor = color.rgb(232, 238, 246)
        color cautionColor = color.rgb(238, 158, 88)
        string dashboardSize = dashboardTextSize(dashboardSizeInput)

        table.cell(dashboard, 0, 0, "Pivot Matrix + Zones [AFD]", bgcolor = headerColor, text_color = accentColor, text_size = dashboardSize, text_halign = text.align_left)
        table.cell(dashboard, 1, 0, "Hover", bgcolor = headerColor, text_color = color.new(labelColor, 30), text_size = dashboardSize, text_halign = text.align_right)
        int dashboardRow = 1
        table.cell(dashboard, 0, dashboardRow, "Read", bgcolor = readColor, text_color = accentColor, text_size = dashboardSize, text_halign = text.align_left, tooltip = chartReadTooltip)
        table.cell(dashboard, 1, dashboardRow, chartReadText, bgcolor = readColor, text_color = valueColor, text_size = dashboardSize, text_halign = text.align_right, tooltip = chartReadTooltip)
        dashboardRow += 1
        color rowColor = rowEvenColor
        if packAEnabledInput
            rowColor := dashboardRow % 2 == 0 ? rowEvenColor : rowOddColor
            table.cell(dashboard, 0, dashboardRow, "Pack A", bgcolor = rowColor, text_color = labelColor, text_size = dashboardSize, text_halign = text.align_left)
            table.cell(dashboard, 1, dashboardRow, dashboardPackValue(packAFormulaInput, packAStatus), bgcolor = rowColor, text_color = packAStatus == "ACTIVE" ? valueColor : cautionColor, text_size = dashboardSize, text_halign = text.align_right, tooltip = formulaTooltip(packAFormulaInput))
            dashboardRow += 1
        if packBEnabledInput
            rowColor := dashboardRow % 2 == 0 ? rowEvenColor : rowOddColor
            table.cell(dashboard, 0, dashboardRow, "Pack B", bgcolor = rowColor, text_color = labelColor, text_size = dashboardSize, text_halign = text.align_left)
            table.cell(dashboard, 1, dashboardRow, dashboardPackValue(packBFormulaInput, packBStatus), bgcolor = rowColor, text_color = packBStatus == "ACTIVE" ? valueColor : cautionColor, text_size = dashboardSize, text_halign = text.align_right, tooltip = formulaTooltip(packBFormulaInput))
            dashboardRow += 1
        if packCEnabledInput
            rowColor := dashboardRow % 2 == 0 ? rowEvenColor : rowOddColor
            table.cell(dashboard, 0, dashboardRow, "Pack C", bgcolor = rowColor, text_color = labelColor, text_size = dashboardSize, text_halign = text.align_left)
            table.cell(dashboard, 1, dashboardRow, dashboardPackValue(packCFormulaInput, packCStatus), bgcolor = rowColor, text_color = packCStatus == "ACTIVE" ? valueColor : cautionColor, text_size = dashboardSize, text_halign = text.align_right, tooltip = formulaTooltip(packCFormulaInput))
            dashboardRow += 1
        rowColor := dashboardRow % 2 == 0 ? rowEvenColor : rowOddColor
        table.cell(dashboard, 0, dashboardRow, "CPR vs Prior", bgcolor = rowColor, text_color = labelColor, text_size = dashboardSize, text_halign = text.align_left, tooltip = cprRelationshipTooltip)
        table.cell(dashboard, 1, dashboardRow, relationshipText, bgcolor = rowColor, text_color = relationshipText == "NO DATA" ? cautionColor : valueColor, text_size = dashboardSize, text_halign = text.align_right, tooltip = cprRelationshipTooltip)
        dashboardRow += 1
        rowColor := dashboardRow % 2 == 0 ? rowEvenColor : rowOddColor
        table.cell(dashboard, 0, dashboardRow, "Anchor Open", bgcolor = rowColor, text_color = labelColor, text_size = dashboardSize, text_halign = text.align_left)
        table.cell(dashboard, 1, dashboardRow, anchorOpenLocation, bgcolor = rowColor, text_color = anchorOpenLocation == "NO DATA" ? cautionColor : valueColor, text_size = dashboardSize, text_halign = text.align_right)
        dashboardRow += 1
        rowColor := dashboardRow % 2 == 0 ? rowEvenColor : rowOddColor
        table.cell(dashboard, 0, dashboardRow, "Nearest Untested", bgcolor = rowColor, text_color = labelColor, text_size = dashboardSize, text_halign = text.align_left, tooltip = nearestUntestedTooltip)
        table.cell(dashboard, 1, dashboardRow, nearestUntestedText, bgcolor = rowColor, text_color = valueColor, text_size = dashboardSize, text_halign = text.align_right, tooltip = nearestUntestedTooltip)

// Fixed alerts

alertcondition(
     activeTouchSignal,
     "Pivot Matrix + Zones [AFD] 1 · Active Level Touch",
     "An active pivot reaction zone was touched on a confirmed bar.")
alertcondition(
     crossUpSignal,
     "Pivot Matrix + Zones [AFD] 2 · Cross Up",
     "Price crossed above an active pivot level on a confirmed bar.")
alertcondition(
     crossDownSignal,
     "Pivot Matrix + Zones [AFD] 3 · Cross Down",
     "Price crossed below an active pivot level on a confirmed bar.")
alertcondition(
     cprEnterSignal,
     "Pivot Matrix + Zones [AFD] 4 · CPR Enter",
     "Price entered pack A CPR on a confirmed bar.")
alertcondition(
     cprExitSignal,
     "Pivot Matrix + Zones [AFD] 5 · CPR Exit",
     "Price exited pack A CPR on a confirmed bar.")
alertcondition(
     untestedFilledSignal,
     "Pivot Matrix + Zones [AFD] 6 · Untested Level Filled",
     "A retained untested pivot zone was filled on a confirmed bar.")
alertcondition(
     confluenceTouchSignal,
     "Pivot Matrix + Zones [AFD] 7 · Confluence Touch",
     "A multi-context confluence zone was touched on a confirmed bar.")
````
