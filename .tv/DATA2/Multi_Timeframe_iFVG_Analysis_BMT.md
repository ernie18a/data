<!-- tradingview-pine-id: PUB;09d972942d72410da7c96717aeefb0e0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi Timeframe (i)FVG Analysis [BMT]

Source: https://www.tradingview.com/script/37l2XoT9-Multi-Timeframe-i-FVG-Analysis-BMT/

## Description

Multi Timeframe (i)FVG Analysis [BMT]

Fair value gaps and inverted fair value gaps on the chart timeframe and up to three higher timeframes, with a lifecycle per gap, relevance filters so a higher-timeframe view does not bury the chart, a directional bias that filters what you see and hear, and alerts.

WHAT IT DRAWS

A fair value gap (FVG) is a three-bar imbalance: a bullish FVG is the space between bar one's high and bar three's low when bar three's low is above bar one's high and bar two closed above it; a bearish FVG is the mirror. Each gap is a box from the bar that formed it, with an optional dotted midpoint line.

Every gap has three states, tracked separately on every enabled timeframe:

[*] FVG: live, price has not closed through it.
[*] iFVG (inverted): price has closed through the far side. A bullish FVG that fails becomes a bearish iFVG and is redrawn in the iFVG color; a bearish FVG that fails becomes a bullish iFVG. The inverted level is drawn brighter than a plain FVG because it is the more actionable one.
[*] Mitigated: price has closed back through an iFVG, and it is removed.

The mitigation test can be the close (default) or the high and low.

TIMEFRAMES

One row per timeframe: the chart timeframe plus H1, H2 and H3. Each row has its own timeframe, a Both / FVG / iFVG / Off switch, and a display filter. Off skips that timeframe entirely, including its data request. "auto" picks a higher timeframe paired to the chart timeframe (1 to 15, 5 to 60, 15 to 240, 60 to daily, and so on).

The defaults draw the chart timeframe only. Turn a higher timeframe on from its Off switch; the rows come preset to 15 minutes, 1 hour and 4 hours.

FILTERS

Three per timeframe. 

[*] All draws every live box. 
[*] N draws the newest N per side.
[*] ATR draws only boxes within N ATRs of the current price, measured with that timeframe's own ATR(14) rather than the chart's, so "within 1 ATR" means the same thing on a 4-hour box and a 5-minute one. 

The lookback is settable (300 bars by default). Boxes run a settable number of bars from where they formed, measured in chart bars by default so a higher-timeframe box does not take over a low-timeframe chart, or in the box's own timeframe if you prefer the longer projection. Extend Boxes runs every live box to the right edge, capped at a settable number of bars past the last bar.

BIAS

Neutral, Bullish or Bearish. It filters what is drawn and which alerts fire; every gap is still tracked underneath, because a gap against your bias is the one that may invert your way.

Bullish: bullish FVGs and bullish iFVGs drawn normally, bearish FVGs dimmed as inversion candidates, bearish iFVGs hidden. Alerts fire for a bullish FVG forming, a bearish FVG inverting, and price entering a bullish FVG. Bearish is the mirror. Neutral shows everything.

ALERTS

Six conditions in the alert dialog, each covering any enabled timeframe:

[*] bullish FVG formed, 
[*] bearish FVG formed, 
[*] bullish FVG inverted, 
[*] bearish FVG inverted,
[*] price entered a bullish FVG, 
[*] price entered a bearish FVG.

"Entered" fires the first time the chart bar trades inside a live gap.

Turn on "Send alert() messages" and choose "Any alert() function call" to get one message per event that names the symbol, the timeframe and the gap's levels. Events fire on every tracked gap whether or not the display filter is currently showing it. Without "Wait for bar close", a chart-timeframe gap is reported as soon as it appears intra-bar and can be withdrawn if the bar closes back over it.

THEME

Auto reads the chart background and picks light or dark. Light is the traditional green and red. Dark is built for a dark canvas: fills sit a little above the background so they do not fight the candles, and the two sides are matched in brightness rather than in transparency. Custom exposes the six colors, the border, and the counter-bias dim as inputs, since box colors are not on the Style tab.

STATUS TABLE

Optional, hidden by default. One row per timeframe with the filter in use and live counts of FVGs and iFVGs per side, plus the chart ATR.

NOTES

Every higher timeframe is one request.security call. A gap on a higher timeframe is detected when that timeframe's bar prints it, not on close, unless "Wait for bar close" is on.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © matt_spinola

// TODO
// Add dealing range (Dealing range is a range that took out buyside liquidity (swing highs) AND then took out the sell side liquidity (swing lows))
// Add premium and discount zones
// mitigate iFVGs based on H/L instead of close

// version v0.3.0, 2026-09-13
// Alerts: six alertcondition entries (FVG formed, inverted, first touch, per side, any
// enabled timeframe) plus optional alert() messages naming the timeframe and levels.
// Bias: the input is live. It filters drawing (counter-bias FVGs dimmed, counter-bias
// iFVGs hidden) and alerts; tracking stays bias-blind.
// Theme: a Custom option with its own colour group, since box colours are not on the
// Style tab.
// Release defaults: the chart timeframe only (H1-H3 ship Off, their timeframes kept at
// 15 / 1H / 4H so switching one on lands somewhere useful), HTF box length on the
// chart-TF basis, session-open highlight off.

//@version=6
indicator("Multi Timeframe (i)FVG Analysis [BMT]", "MTF (i)FVG [BMT]", behind_chart=true, explicit_plot_zorder=true, overlay=true, max_bars_back=1000, max_lines_count=500, max_boxes_count=500)

// --------------------- Theme { ----------------------------- \\
// The chart's own background picks the palette — the same relative-luminance test the
// NPF scripts and the moving-average script use.
//
// Light is the traditional green/red scheme, unchanged.
//
// Dark is built against the ES1! chart theme rather than invented: the bull and bear
// fills ARE that theme's long and short zone colours, so an FVG reads as the same
// class of object as a setup zone. Two of the theme's rules govern the numbers.
// Rule 2, fills sit only ~12 luma above the #16191F canvas, because a brighter fill
// collides with the candle bodies. Rule 3, the two sides match each other in LUMA and
// not in transparency, since red and green need different alphas to feel equal.
//
//   dark canvas  24.8      down body  82.7      up body 104.9      axis text 145.5
//   bull FVG     37.2      bear FVG   38.0      <- matched, 12-13 off canvas
//   bull iFVG    44.7      bear iFVG  44.9      <- matched, deliberately the stronger pair
//
// iFVGs sit ~8 luma above FVGs because an inverted level is the more actionable one,
// and both pairs still clear the darkest candle body by ~38.
color noColor = color.new(color.black, 100)

var g_color = "Theme"
themeInput = input.string("Auto (chart)", group=g_color, title="Theme", options=["Auto (chart)", "Dark", "Light", "Custom"],
     tooltip="Auto reads the chart background. Light is the traditional green/red scheme. Dark uses the ES1! chart theme's zone colors. Custom uses the colors in the Custom Colors group below; boxes are not on the Style tab, so this is the only way to recolor them.")

chartLuma = 0.2126 * color.r(chart.bg_color) + 0.7152 * color.g(chart.bg_color) + 0.0722 * color.b(chart.bg_color)
bool isCustom = themeInput == "Custom"
// Custom still needs a light/dark answer for the status table chrome, which has no
// colour input of its own, so it reads the chart background the way Auto does.
bool isDark = themeInput == "Dark" or ((themeInput == "Auto (chart)" or isCustom) and chartLuma <= 128)

// Custom — seeded from the light palette so switching to it is a starting point, not a
// blank. Six colours plus one number: the counter-bias dim is derived from the FVG
// colours by adding transparency rather than chosen separately, so the two sides stay
// tied to their live fills. The deleted-box colour comes from the label colour, since
// it only shows under the debug toggle.
var g_custom = "Custom Colors"
customBullFvgInput   = input.color(color.new(#00e676, 90), group=g_custom, title="FVG",    inline="c_fvg",    active=isCustom)
customBearFvgInput   = input.color(color.new(#f23645, 90), group=g_custom, title="",       inline="c_fvg",    active=isCustom)
customBullIfvgInput  = input.color(color.new(#6e95ff, 90), group=g_custom, title="iFVG",   inline="c_ifvg",   active=isCustom)
customBearIfvgInput  = input.color(color.new(#ffbf00, 90), group=g_custom, title="",       inline="c_ifvg",   active=isCustom)
customBorderInput    = input.color(color.new(#000000, 100), group=g_custom, title="Border", inline="c_border", active=isCustom,
     tooltip="Bullish then bearish on each row. A fully transparent border means none.")
customBorderWidthInput = input.int(1, group=g_custom, title="width", minval=0, maxval=3, inline="c_border", active=isCustom)
customLabelInput     = input.color(color.black, group=g_custom, title="Label", active=isCustom)
customDimInput       = input.int(4, group=g_custom, title="Counter-bias dim (extra transparency)", minval=0, maxval=50, active=isCustom,
     tooltip="Added to the FVG colors' transparency for boxes that run against the Bias input.")

// Light — traditional, as it was
color lightBullFvgColor    = color.new(#00e676, 90)
color lightBearFvgColor    = color.new(#f23645, 90)
color lightBullIfvgColor   = color.new(#6e95ff, 90)
color lightBearIfvgColor   = color.new(#ffbf00, 90)
color lightFvgBorderColor  = noColor
color lightIfvgBorderColor = noColor
int   lightFvgBorderWidth  = 0
int   lightIfvgBorderWidth = 0
color lightLabelColor      = color.black
color lightMfvgColor       = color.new(#b8b8b8, 80)
color lightDimBullColor    = color.new(#00e676, 94)   // counter-bias FVG, an inversion candidate
color lightDimBearColor    = color.new(#f23645, 94)

// Dark — ES1! chart theme
color darkBullFvgColor     = color.new(#66B97C, 91)   // theme long zone  -> luma 37.2
color darkBearFvgColor     = color.new(#B26767, 86)   // theme short zone -> luma 38.0
color darkBullIfvgColor    = color.new(#5B8DD6, 82)   // -> luma 44.7
color darkBearIfvgColor    = color.new(#D9A441, 86)   // -> luma 44.9
color darkFvgBorderColor   = #383C45                  // luma 59.8, 22 over the fill
color darkIfvgBorderColor  = #383C45
int   darkFvgBorderWidth   = 1
int   darkIfvgBorderWidth  = 1
color darkLabelColor       = #8B92A0                  // theme axis text
color darkMfvgColor        = color.new(#9AA0AC, 91)   // -> luma 36.9
color darkDimBullColor     = color.new(#66B97C, 93)   // counter-bias FVG, a step under the live fill
color darkDimBearColor     = color.new(#B26767, 89)   // alpha differs so the two sides match in luma

// Custom, derived
color customDimBullColor   = color.new(customBullFvgInput, math.min(100, color.t(customBullFvgInput) + customDimInput))
color customDimBearColor   = color.new(customBearFvgInput, math.min(100, color.t(customBearFvgInput) + customDimInput))
color customMfvgColor      = color.new(customLabelInput, 91)
bool  customHasBorder      = color.t(customBorderInput) < 100 and customBorderWidthInput > 0

// Resolved once, shared by every timeframe
color themeBullColor       = isCustom ? customBullFvgInput  : isDark ? darkBullFvgColor    : lightBullFvgColor
color themeBearColor       = isCustom ? customBearFvgInput  : isDark ? darkBearFvgColor    : lightBearFvgColor
color themeBullIfvgColor   = isCustom ? customBullIfvgInput : isDark ? darkBullIfvgColor   : lightBullIfvgColor
color themeBearIfvgColor   = isCustom ? customBearIfvgInput : isDark ? darkBearIfvgColor   : lightBearIfvgColor
color themeFvgBorderColor  = isCustom ? customBorderInput   : isDark ? darkFvgBorderColor  : lightFvgBorderColor
color themeIfvgBorderColor = isCustom ? customBorderInput   : isDark ? darkIfvgBorderColor : lightIfvgBorderColor
int   themeFvgBorderWidth  = isCustom ? (customHasBorder ? customBorderWidthInput : 0) : isDark ? darkFvgBorderWidth  : lightFvgBorderWidth
int   themeIfvgBorderWidth = isCustom ? (customHasBorder ? customBorderWidthInput : 0) : isDark ? darkIfvgBorderWidth : lightIfvgBorderWidth
color themeLabelColor      = isCustom ? customLabelInput    : isDark ? darkLabelColor      : lightLabelColor
color themeMfvgColor       = isCustom ? customMfvgColor     : isDark ? darkMfvgColor       : lightMfvgColor
color themeDimBullColor    = isCustom ? customDimBullColor  : isDark ? darkDimBullColor    : lightDimBullColor
color themeDimBearColor    = isCustom ? customDimBearColor  : isDark ? darkDimBearColor    : lightDimBearColor
string themeFvgBorderStyle  = line.style_solid
string themeIfvgBorderStyle = line.style_solid
//}

// --------------------- User Defined Types { ----------------------------- \\
enum HtfBiasType
    Neutral  = "Neutral"
    Bullish  = "Bullish"
    Bearish = "Bearish"

enum FvgFillType
    fvgFillClose  = "Close"
    fvgFillWick = "High/Low"

enum FvgDisplayType
    all = "All"
    mostRecentN = "Most Recent N"
    atr = "Within N ATR(s)"

type LabelConfigType
    bool showLabels = true
    string size = "auto"
    string hAlignment = "right"

type BoxConfigType
    int boxLength = 10
    color bullColor = na
    color bearColor = na
    color bullIfvgColor = na
    color bearIfvgColor = na
    color fvgBorderColor = na
    color ifvgBorderColor = na
    color mfvgColor = na
    color dimBullColor = na
    color dimBearColor = na
    bool useMitigatedIfvgColor = true
    int fvgBorderWidth = 0
    string fvgBorderStyle = na
    int ifvgBorderWidth = 0
    string ifvgBorderStyle = na
    int borderTransparency = 50

type FvgType
    int id
    float max
    float min
    bool isBullish
    int startTime = time
    int endTime = time
    bool isInversed = false
    bool isMitigated = false
    int t = time
    line midpoint = na
    int barCreated = bar_index
    bool touched = false

type TfFvgType
    LabelConfigType labelConfig
    BoxConfigType boxConfig
    array<FvgType> fvgArray
    array<box> fvgBoxArray
    array<box> mfvgBoxArray
    array<FvgType> ifvgArray
    array<box> ifvgBoxArray
    array<float> filteredLow
    array<float> filteredHigh
    array<float> filteredClose
    array<int> filteredRequestTime
    float fvgDisplayNAtrs = 0.0
    int fvgDisplayNClosest = 0
    int bullFvgCount = 0
    int bullIfvgCount = 0
    int bullMfvgCount = 0
    int bearFvgCount = 0
    int bearIfvgCount = 0
    int bearMfvgCount = 0
    int t = 0
    string name = ""
    string tfPeriod = ""
    int tfSeconds = 0
    bool waitForClose = false
    FvgFillType fillFvgType
    FvgDisplayType fvgDisplayType
    bool showFvg = false
    bool showIfvg = false
    bool showMfvg = false
    bool extendFvg = false
    int idCount = 0
    float atr = na
    // Per-bar alert events, cleared at the top of each bar by clearEvents. The alert
    // block at the bottom reads these at global scope, which is where alertcondition
    // has to live. Levels ride along so the alert() message can name them.
    bool evNewBull = false
    bool evNewBear = false
    bool evInvBull = false
    bool evInvBear = false
    bool evTouchBull = false
    bool evTouchBear = false
    float evNewTop = na
    float evNewBottom = na
    float evInvTop = na
    float evInvBottom = na
    float evTouchTop = na
    float evTouchBottom = na
//}

// --------------------- User Inputs { ----------------------------- \\
var g_bias = "Bias Settings"
biasInput = input.enum(HtfBiasType.Neutral, group=g_bias, title="Bias",
     tooltip="Filters what is drawn and which alerts fire; every box is still tracked underneath, since a counter-bias FVG is the one that may invert your way.\n\nBullish: bullish FVGs and bullish iFVGs drawn normally, bearish FVGs dimmed as inversion candidates, bearish iFVGs hidden. Alerts: bullish FVG formed, bearish FVG inverted, price entered bullish FVG.\n\nBearish: the mirror.\n\nNeutral: everything. The alert dialog always lists all six conditions; bias just keeps the wrong-way ones from firing.")
// Direction of interest, read by the two display passes and the alert block. Detection
// and mitigation never look at it.
bool biasBull = biasInput == HtfBiasType.Bullish
bool biasBear = biasInput == HtfBiasType.Bearish

var g_tf = "Timeframe Settings"
ltfOnlyInput = input.bool(false, "Show LTF Only", group=g_tf,
     tooltip="Enable to ignore HTFs.\n\nEach row below reads: timeframe, which box types to draw, the display filter, then N. Off on the second dropdown skips that timeframe entirely, including its data request.\n\nFilter — All: every box. N: the newest N per side. ATR: only boxes within N ATRs of the current price, measured with that timeframe's own ATR(14).")

ltf1TfInput = input.string("chart", group=g_tf, title="L1", options=["chart", "30S", "1", "2", "3", "5", "7", "10", "15", "30", "45", "90", "1H", "2H", "3H", "4H", "1D", "1W"], inline="ltf1_timeframe_settings")
ltf1ShowInput = input.string("Both", group=g_tf, title="", options=["Both", "FVG", "iFVG", "Off"], inline="ltf1_timeframe_settings")
ltf1FilterModeInput = input.string("All", group=g_tf, title="", options=["All", "N", "ATR"], inline="ltf1_timeframe_settings")
ltf1FvgNFilterInput = input.float(10, "", group=g_tf, minval=0, maxval=100, step=0.5, inline="ltf1_timeframe_settings")
ltf1ShowFvgsInput = ltf1ShowInput == "Both" or ltf1ShowInput == "FVG"
ltf1ShowIfvgsInput = ltf1ShowInput == "Both" or ltf1ShowInput == "iFVG"
ltf1EnableInput = ltf1ShowFvgsInput or ltf1ShowIfvgsInput

htf1TfInput = input.string("15", group=g_tf, title="H1", options=["auto", "chart", "1", "2", "15", "1H", "2H", "4H", "1D", "1W", "1M"], inline="htf1_timeframe_settings", active=not ltfOnlyInput)
htf1ShowInput = input.string("Off", group=g_tf, title="", options=["Both", "FVG", "iFVG", "Off"], inline="htf1_timeframe_settings", active=not ltfOnlyInput)
htf1FilterModeInput = input.string("N", group=g_tf, title="", options=["All", "N", "ATR"], inline="htf1_timeframe_settings", active=not ltfOnlyInput)
htf1FvgNFilterInput = input.float(2, "", group=g_tf, minval=0, maxval=100, step=0.5, inline="htf1_timeframe_settings", active=not ltfOnlyInput)
htf1ShowFvgsInput = htf1ShowInput == "Both" or htf1ShowInput == "FVG"
htf1ShowIfvgsInput = htf1ShowInput == "Both" or htf1ShowInput == "iFVG"
htf1EnableInput = not ltfOnlyInput and (htf1ShowFvgsInput or htf1ShowIfvgsInput)

htf2TfInput = input.string("1H", group=g_tf, title="H2", options=["auto", "chart", "1", "2", "15", "1H", "2H", "4H", "1D", "1W", "1M"], inline="htf2_timeframe_settings", active=not ltfOnlyInput)
htf2ShowInput = input.string("Off", group=g_tf, title="", options=["Both", "FVG", "iFVG", "Off"], inline="htf2_timeframe_settings", active=not ltfOnlyInput)
htf2FilterModeInput = input.string("N", group=g_tf, title="", options=["All", "N", "ATR"], inline="htf2_timeframe_settings", active=not ltfOnlyInput)
htf2FvgNFilterInput = input.float(2, "", group=g_tf, minval=0, maxval=100, step=0.5, inline="htf2_timeframe_settings", active=not ltfOnlyInput)
htf2ShowFvgsInput = htf2ShowInput == "Both" or htf2ShowInput == "FVG"
htf2ShowIfvgsInput = htf2ShowInput == "Both" or htf2ShowInput == "iFVG"
htf2EnableInput = not ltfOnlyInput and (htf2ShowFvgsInput or htf2ShowIfvgsInput)

htf3TfInput = input.string("4H", group=g_tf, title="H3", options=["auto", "chart", "1", "2", "15", "1H", "2H", "4H", "1D", "1W", "1M"], inline="htf3_timeframe_settings", active=not ltfOnlyInput)
htf3ShowInput = input.string("Off", group=g_tf, title="", options=["Both", "FVG", "iFVG", "Off"], inline="htf3_timeframe_settings", active=not ltfOnlyInput)
htf3FilterModeInput = input.string("N", group=g_tf, title="", options=["All", "N", "ATR"], inline="htf3_timeframe_settings", active=not ltfOnlyInput)
htf3FvgNFilterInput = input.float(1, "", group=g_tf, minval=0, maxval=100, step=0.5, inline="htf3_timeframe_settings", active=not ltfOnlyInput)
htf3ShowFvgsInput = htf3ShowInput == "Both" or htf3ShowInput == "FVG"
htf3ShowIfvgsInput = htf3ShowInput == "Both" or htf3ShowInput == "iFVG"
htf3EnableInput = not ltfOnlyInput and (htf3ShowFvgsInput or htf3ShowIfvgsInput)

hideLowerThanChartTfBoxes = input.bool(false, group=g_tf, title="Hide boxes lower than chart timeframe.", tooltip="Useful when looking at big picture context on a high TF", active=not ltfOnlyInput)
favorLtfOverHtfWhenEqualTfsInput = input.bool(true, group=g_tf, title="Favor LTF boxes over identical HTF", tooltip="Enable to display LTF boxes and ingnore HTF boxes when the LTF and a HTF have identical TFs.", active=not ltfOnlyInput)

var g_box = "______________ Box Settings ______________"
ltfExtendFvgBoxesInput = input.bool(false, group=g_box, title="Extend LTF Boxes", inline="extend")
ltfShowFvgMidLineInput = input.bool(true, group=g_box, title="Show LTF FVG midpoint lines", inline="midline")
ltfShowBoxLabelsInput = input.bool(false, group=g_box, title="Show LTF labels", inline="ltf_label")
ltfLabelSizeOption = input.string("small", group=g_box, title="size:", options=["tiny", "small", "auto", "normal", "large", "huge"], inline="ltf_label")
ltfLabelAlignmentOption = input.string("right", group=g_box, title="alignment:", options=["left", "center", "right"], inline="ltf_label")

htfExtendFvgBoxesInput = input.bool(false, group=g_box, title="Extend HTF Boxes", inline="extend", active=not ltfOnlyInput)
htfShowFvgMidLineInput = input.bool(true, group=g_box, title="Show HTF FVG midpoint lines", inline="midline", active=not ltfOnlyInput)
htfShowBoxLabelsInput = input.bool(true, group=g_box, title="Show HTF labels", inline="htf_label", active=not ltfOnlyInput)
maxBarsPastLastBarInput = input.int(10, group=g_box, title="Max bars a box may run past the last bar", minval=0, maxval=500,
     tooltip="Caps how far any box projects into the future, and is how far the Extend Boxes options run.")
htfLabelSizeOption = input.string("small", group=g_box, title="size:", options=["tiny", "small", "auto", "normal", "large", "huge"], inline="htf_label", active=not ltfOnlyInput)
htfLabelAlignmentOption = input.string("right", group=g_box, title="alignment:", options=["left", "center", "right"], inline="htf_label", active=not ltfOnlyInput)

var g_fvg = "______________ FVG Settings ______________"
maxBarHistoryInput = input.int(300, group=g_fvg, minval=1, maxval=2000, title="Max historical bars to search for FVGs")
fillFvgTypeInput = input.enum(FvgFillType.fvgFillClose, group=g_fvg, title="FVG Mitigation Type")
ltfBoxLengthInput = input.int(20, group=g_fvg, title="LTF Box Length", inline="initial_box")
htfBoxLengthInput = input.int(20, group=g_fvg, title="HTF Box Length", inline="initial_box", active=not ltfOnlyInput)
// Chart-TF basis by default (v0.2.1). Measured in the HTF's own bars, a 4H box at
// length 20 ran 960 bars across a 5-minute chart and owned the screen; measured in
// chart bars it is the same 20 bars whatever the source timeframe.
baseHtfBoxLengthOnChartTfInput = input.bool(true, group=g_fvg, title="Box length based on the visible chart's TF instead of the FVG's TF.", tooltip="When enabled HTF box length is based on the chart's TF. When disabled the box length is based on the HTF resulting in a longer box", active=not ltfOnlyInput)
waitForCloseInput = input.bool(false, group=g_fvg, title="Wait for bar close to identify FVG")

var g_weeklySession = "Weekly Session Highlight"
isSunday = dayofweek(time(timeframe.period)) == dayofweek.sunday
isInHighlightRange = hour(time(timeframe.period, "America/New_York")) == (syminfo.root == "GC" ? 19 : 17)
highlightWeekOpenInput = input.bool(false, group=g_weeklySession, title="Highlight Weekly Session Open")
highlightColor = input.color(color.new(#2aa198, 95), group=g_weeklySession, title="Highlight Color")
weeklySessionOpenColor = isSunday and isInHighlightRange and highlightWeekOpenInput ? highlightColor : na
bgcolor(weeklySessionOpenColor)

var g_sts = "Status Table Settings"
showPrimaryStatsInput = ltf1ShowFvgsInput or htf1ShowFvgsInput or htf2ShowFvgsInput or htf3ShowFvgsInput //input.bool(true, group=g_sts, title="Show LTF iFVG and HTF FVG count")
showSecondaryStatsInput = ltf1ShowIfvgsInput or htf1ShowIfvgsInput or htf2ShowIfvgsInput or htf3ShowIfvgsInput //input.bool(true, group=g_sts, title="Show LTF FVG and HTF iFVG count")
showMitigatedStatsInput = input.bool(false, group=g_sts, title="Show deleted count")
statusTableLocationInput = input.string("hidden", group=g_sts, title="Location of status table on the chart", options=["hidden", "top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"])
statusTableFontSizeOption = input.string("tiny", group=g_sts, title="Status table font size", options=["tiny", "small", "normal", "auto", "large", "huge"])

var g_alerts = "Alerts"
alertMessagesInput = input.bool(false, group=g_alerts, title="Send alert() messages naming the timeframe and levels",
     tooltip="The alert dialog's condition list (Bullish FVG, Bearish FVG, inversions, first touch) always works and fires for any enabled timeframe. Turn this on and pick 'Any alert() function call' instead to get one message per event that names the timeframe and the box levels. Events fire on every tracked box, whether or not the display filter is currently showing it. Without 'Wait for bar close' a chart-timeframe FVG is reported as soon as it appears intra-bar and can be withdrawn if the bar closes back over it.")

var g_debug = "Developer Debug Settings"
ltfShowMfvgInput = input.bool(false, group=g_debug, title="Show LTF deleted FVGs")
htfShowMfvgInput = input.bool(false, group=g_debug, title="Show HTF deleted FVGs")
useMitigatedIfvgColorInput = input.bool(true, group=g_debug, title="Uncheck to use bull/bear iFVG colors for mitigated FVGs.")
//}

// --------------------- Generic Helpers { ----------------------------- \\
toDisplayType(string mode) =>
    switch mode
        "N"   => FvgDisplayType.mostRecentN
        "ATR" => FvgDisplayType.atr
        => FvgDisplayType.all

// @function Given a LTF timeframe string return its HTF timeframe pair
// @param tfPeriod LTF string to pair with a HTF
// @returns HTF pair of the input LTF
getHtfPeriodPairFromLtfPeriod(string ltfPeriod=timeframe.period) =>
    string htfPeriod = switch ltfPeriod
        "30S" => "5"
        "1" => "15"
        "2" => "15"
        "3" => "15"
        "5" => "60"
        "6" => "60"
        "7" => "60"
        "8" => "120"
        "9" => "120"
        "10" => "120"
        "15" => "240"
        "20" => "240"
        "30" => "240"
        "45" => "240"
        "60" => "1D"
        "90" => "1D"
        "120" => "1D"
        "180" => "1D"
        "240" => "1W"
        "1D" => "1W"
        "1W" => "1M"
        "1M" => "1M"
        => na
    htfPeriod

parseHtfInput(string tfStr, string ltfPeriod=timeframe.period) =>
    string tf = tfStr
    if tfStr == "auto"
        tf := getHtfPeriodPairFromLtfPeriod(ltfPeriod)
    else if tfStr == "chart"
        tf := timeframe.period
    else
        tf := switch tfStr
            // convert our input of hours to TradingView's hour convention of being in minutes (ie there is no 1H timeframe it is 60
            "1H" => "60"
            "2H" => "120"
            "4H" => "240"
            => tf
    tf

htfIsMinutes(string tfStr, string ltfPeriod=timeframe.period) =>
    bool isMinutes = false
    if tfStr == "auto"
        isMinutes := switch ltfPeriod
            "30S" => true // 5 Min
            "1" => true // 15 Min
            "2" => true // 15 Min
            "3" => true // 15 Min
            "4" => true // 15 Min
            "5" => true // 60 Min
            "6" => true // 60 Min
            "7" => true // 60 Min
            "8" => true // 120 Min
            "9" => true // 120 Min
            "10" => true // 120 Min
            "15" => true // 240 Min
            "20" => true // 240 Min
            "30" => true // 240 Min
            "45" => true // 240 Min
            "60" => false
            "D" => false
            "W" => false
            => false
    isMinutes

// Parsed rather than looked up. The switch this replaces had no case for 1S, 5S, 10S,
// 15S, 3D, 2W, 3M and friends and returned 0 for them, which then divided by zero in
// ltfIntervalsInHtf and dropped every HTF box with no error shown. A bare "D"/"W"/"M"
// with no multiplier is treated as 1, which is what TradingView means by it.
tfInSeconds(string tfStr) =>
    int result = 0
    if not na(tfStr) and str.length(tfStr) > 0
        string unit = str.substring(tfStr, str.length(tfStr) - 1)
        float mult = str.tonumber(str.substring(tfStr, 0, str.length(tfStr) - 1))
        float m = na(mult) ? 1 : mult
        if unit == "S"
            result := int(m)
        else if unit == "D"
            result := int(m * 86400)
        else if unit == "W"
            result := int(m * 604800)
        else if unit == "M"
            result := int(m * 2592000)
        else
            // no unit suffix means minutes
            float mins = str.tonumber(tfStr)
            result := int(na(mins) ? 0 : mins * 60)
    result

parseTimeframe(string tfPeriod) =>
    retStr = tfPeriod
    tfPeriodArray = str.split(tfPeriod, '')
    lastChar = array.get(tfPeriodArray, tfPeriodArray.size() - 1)
    if (lastChar != "S" and lastChar != "D" and lastChar != "W" and lastChar != "M")
        // minutes
        multiplier = str.tonumber(tfPeriod)
        if multiplier % 60 == 0
            retStr := str.tostring(multiplier / 60) + "H"
        else
            retStr := tfPeriod + "m"
    retStr

toSolid(color id, int transparency=0) =>
    returnColor = color.new(color.rgb(color.r(id), color.g(id), color.b(id)), transparency)

createBox(FvgType fvg, string labelStr, LabelConfigType labelCfg, color boxColor, color borderColor, int borderWidth, string borderStyle, bool useMidLine, color textColor) =>
    if useMidLine
        middleY = (fvg.max + fvg.min) / 2
        fvg.midpoint := line.new(x1=fvg.startTime, y1=middleY, x2=fvg.endTime, y2=middleY, color=borderColor, width=borderWidth, style=line.style_dotted, xloc=xloc.bar_time)

    box.new(left=fvg.startTime, top=fvg.max, right=fvg.endTime, bottom=fvg.min, xloc=xloc.bar_time,
         text=labelStr, text_color=textColor, text_halign=labelCfg.hAlignment, text_valign=text.align_center, text_size=labelCfg.size,
         border_color=borderColor, border_width=borderWidth, border_style=borderStyle, bgcolor=boxColor)

getLastNaValues(int series, int n) =>
    int[] lastNonNaValues = array.new_int(0)
    int nonNaCount = 0

    for i = 0 to math.min(bar_index, 500)
        if not na(series[i])
            array.push(lastNonNaValues, series[i])
            nonNaCount += 1
            if nonNaCount == n
                break
    lastNonNaValues

getLastNaValues(float series, int n) =>
    float[] lastNonNaValues = array.new_float(0)
    int nonNaCount = 0

    for i = 0 to math.min(bar_index, 500)
        if not na(series[i])
            array.push(lastNonNaValues, series[i])
            nonNaCount += 1
            if nonNaCount == n
                break
    lastNonNaValues
//}

// --------------------- FVG Helpers { ----------------------------- \\
// ATR length, shared by the status table and the "N x ATR" display filter.
int ATR_LENGTH = 14

// Deleted-FVG boxes are only drawn by the debug toggle and were never cleaned up, so
// they marched toward max_boxes_count. Oldest is dropped past this.
int MAX_MFVG_BOXES = 50

// Insertion sort on startTime. The previous version sorted a parallel array of times
// and mapped back with array.indexof, which returns the FIRST match — so two FVGs
// sharing a start time yielded one duplicate and silently dropped the other.
sort(array<FvgType> fvgArray, sortOrder=order.descending) =>
    sorted = array.new<FvgType>(0)
    for element in fvgArray
        int pos = sorted.size()
        if sorted.size() > 0
            for i = 0 to sorted.size() - 1
                other = sorted.get(i)
                bool goesFirst = sortOrder == order.ascending ? element.startTime < other.startTime : element.startTime > other.startTime
                if goesFirst
                    pos := i
                    break
        sorted.insert(pos, element)
    sorted

// Distance from the current price to a box, in multiples of that timeframe's own ATR.
// Price sitting inside the box counts as zero. An unusable ATR — na or zero, which is
// what the first bars of a request return — disables the filter rather than blanking
// the chart.
withinAtrs(FvgType fvg, float atr, float nAtrs) =>
    bool result = true
    if not na(atr) and atr > 0
        float dist = close < fvg.min ? fvg.min - close : close > fvg.max ? close - fvg.max : 0.0
        result := dist <= nAtrs * atr
    result

isMitigated(TfFvgType tfData, FvgType fvg, FvgFillType mitigationType) =>
    bool mitigated = false
    bool inversed = false
    float tfHigh = 0
    float tfLow = 0
    float tfClose = 0
    if tfData.filteredHigh.size() > 0 and tfData.filteredLow.size() > 0 and tfData.filteredClose.size() > 0
        tfHigh := tfData.filteredHigh.get(0)
        tfLow := tfData.filteredLow.get(0)
        tfClose := tfData.filteredClose.get(0)
    if mitigationType == FvgFillType.fvgFillClose
        if fvg.isBullish
            if fvg.isInversed and tfClose >= fvg.max
                mitigated := true
            if tfClose <= fvg.min
                inversed := true
        else
            if fvg.isInversed and tfClose <= fvg.min
                mitigated := true
            if tfClose >= fvg.max
                inversed := true
    else
        if fvg.isBullish
            if fvg.isInversed and tfHigh >= fvg.max
                mitigated := true
            if tfLow <= fvg.min
                inversed := true
        else
            if fvg.isInversed and tfLow <= fvg.min
                mitigated := true
            if tfHigh >= fvg.max
                inversed := true
    [mitigated, inversed]

displaySelectFvgBoxes(TfFvgType tfData, int chartTfSeconds, bool useMidLine=false, bool showFvgId=false) =>
    arrSize = tfData.fvgArray.size()
    if arrSize > 0
        for i = 0 to arrSize - 1
            fvg = tfData.fvgArray.get(i)
            fvg.midpoint.delete()
            fvg.midpoint := na

    arrSize := tfData.fvgBoxArray.size()
    if arrSize > 0
        for i = 0 to arrSize - 1
            fvgBox = tfData.fvgBoxArray.shift()
            fvgBox.delete()

    bullishCount = 0
    bearishCount = 0

    displayAll = tfData.fvgDisplayType == FvgDisplayType.all
    displayN = tfData.fvgDisplayType == FvgDisplayType.mostRecentN
    displayAtr = tfData.fvgDisplayType == FvgDisplayType.atr
    if tfData.showFvg and (displayAll or displayN or displayAtr)
        sortedFvgArray = array.new<FvgType>(0)
        if tfData.fvgArray.size() > 0
            sortedFvgArray := sort(tfData.fvgArray)
        if sortedFvgArray.size() > 0
            for i = 0 to sortedFvgArray.size() - 1
                fvg = sortedFvgArray.get(i)
                if not fvg.isInversed and not fvg.isMitigated
                    // Re-clamped on every bar, not just at detection. last_bar_time moves
                    // as a live session adds bars, so a box whose right edge was fixed at
                    // detection would drift further and further behind the current bar.
                    int rightLimit = last_bar_time + (maxBarsPastLastBarInput * chartTfSeconds * 1000)
                    fvg.endTime := tfData.extendFvg ? rightLimit : math.min(fvg.endTime, rightLimit)
                    bool nearPrice = displayAtr and withinAtrs(fvg, tfData.atr, tfData.fvgDisplayNAtrs)
                    labelStr = tfData.labelConfig.showLabels ? tfData.name + (showFvgId ? " " + str.tostring(fvg.id) + " " : "") + " FVG" : ""
                    borderColor = tfData.boxConfig.fvgBorderColor
                    // A counter-bias FVG is the inversion candidate the bias is waiting
                    // on, so it dims instead of disappearing.
                    color bullFill = biasBear ? tfData.boxConfig.dimBullColor : tfData.boxConfig.bullColor
                    color bearFill = biasBull ? tfData.boxConfig.dimBearColor : tfData.boxConfig.bearColor
                    if fvg.isBullish and (displayAll or nearPrice or (displayN and bullishCount < tfData.fvgDisplayNClosest))
                        bullishCount += 1
                        tfData.fvgBoxArray.unshift(createBox(fvg, labelStr, tfData.labelConfig, bullFill, borderColor, tfData.boxConfig.fvgBorderWidth, tfData.boxConfig.fvgBorderStyle, useMidLine, themeLabelColor))
                    else if not fvg.isBullish and (displayAll or nearPrice or (displayN and bearishCount < tfData.fvgDisplayNClosest))
                        bearishCount += 1
                        tfData.fvgBoxArray.unshift(createBox(fvg, labelStr, tfData.labelConfig, bearFill, borderColor, tfData.boxConfig.fvgBorderWidth, tfData.boxConfig.fvgBorderStyle, useMidLine, themeLabelColor))
    tfData

displaySelectIfvgBoxes(TfFvgType tfData, bool showFvgId=false) =>
    arrSize = tfData.ifvgBoxArray.size()
    if arrSize > 0
        for i = 0 to arrSize - 1
            fvgBox = tfData.ifvgBoxArray.shift()
            fvgBox.delete()

    bullishCount = 0
    bearishCount = 0

    displayAll = tfData.fvgDisplayType == FvgDisplayType.all
    displayN = tfData.fvgDisplayType == FvgDisplayType.mostRecentN
    displayAtr = tfData.fvgDisplayType == FvgDisplayType.atr
    if tfData.showIfvg and (displayAll or displayN or displayAtr)
        sortedFvgArray = array.new<FvgType>(0)
        if tfData.ifvgArray.size() > 0
            // descending, same as the FVG pass: "most recent N" must mean the newest N
            sortedFvgArray := sort(tfData.ifvgArray)
        if sortedFvgArray.size() > 0
            for i = 0 to sortedFvgArray.size() - 1
                ifvg = sortedFvgArray.get(i)
                // isBullish is the ORIGINAL gap's direction: a bullish FVG that inverted
                // is now a bearish iFVG, which a bullish bias does not want to see.
                bool counterBias = (biasBull and ifvg.isBullish) or (biasBear and not ifvg.isBullish)
                if not ifvg.isMitigated and not counterBias
                    bool nearPrice = displayAtr and withinAtrs(ifvg, tfData.atr, tfData.fvgDisplayNAtrs)
                    ifvgColor = ifvg.isBullish ? tfData.boxConfig.bearIfvgColor : tfData.boxConfig.bullIfvgColor
                    labelStr = tfData.labelConfig.showLabels ? tfData.name + (showFvgId ? " " + str.tostring(ifvg.id) + " " : "") + " iFVG" : ""
                    borderColor = tfData.boxConfig.ifvgBorderColor
                    if ifvg.isBullish and (displayAll or nearPrice or (displayN and bullishCount < tfData.fvgDisplayNClosest))
                        bullishCount += 1
                        tfData.ifvgBoxArray.unshift(createBox(ifvg, labelStr, tfData.labelConfig, ifvgColor, borderColor, tfData.boxConfig.ifvgBorderWidth, tfData.boxConfig.ifvgBorderStyle, false, themeLabelColor))
                    if not ifvg.isBullish and (displayAll or nearPrice or (displayN and bearishCount < tfData.fvgDisplayNClosest))
                        bearishCount += 1
                        tfData.ifvgBoxArray.unshift(createBox(ifvg, labelStr, tfData.labelConfig, ifvgColor, borderColor, tfData.boxConfig.ifvgBorderWidth, tfData.boxConfig.ifvgBorderStyle, false, themeLabelColor))

detect(bool waitForClose, float[] filteredLow, float[] filteredHigh, float[] filteredClose, float threshold=0.00001) =>
    FvgType newFvg = na
    if filteredLow.size() > 2 and filteredHigh.size() > 2 and filteredClose.size() > 2
        bullFvg = false
        bearFvg = false

        curLow = filteredLow.get(0)
        prevPrevLow = filteredLow.get(2)
        curHigh = filteredHigh.get(0)
        prevPrevHigh = filteredHigh.get(2)
        prevClose = filteredClose.get(1)
        if (not waitForClose or (waitForClose and barstate.isconfirmed))
            bullFvg := curLow > prevPrevHigh and prevClose > prevPrevHigh and math.abs(curLow - prevPrevHigh) / prevPrevHigh > threshold
            bearFvg := curHigh < prevPrevLow and prevClose < prevPrevLow and math.abs(prevPrevLow - curHigh) / curHigh > threshold

            if bullFvg
                newFvg := FvgType.new(na, curLow, prevPrevHigh, true)
            else if bearFvg
                newFvg := FvgType.new(na, prevPrevLow, curHigh, false)
    newFvg

findFvgs(TfFvgType tfData, int chartTfSeconds) =>
    if tfData.filteredLow.size() > 2 and tfData.filteredHigh.size() > 2 and tfData.filteredClose.size() > 2 and tfData.filteredRequestTime.size() > 0
        securityRequestTime = tfData.filteredRequestTime.get(0)
        newFvg = detect(tfData.waitForClose, tfData.filteredLow, tfData.filteredHigh, tfData.filteredClose)
        if not na(newFvg)
            newFvg.id := tfData.idCount
            newFvg.t := securityRequestTime
            newFvg.startTime := securityRequestTime - (2 * tfData.tfSeconds * 1000)
            // One chart bar is chartTfSeconds * 1000 ms. The old code multiplied by 2000
            // and called the result "Msec", which is two bars, not the 2000 the name
            // claimed — so "Extend Boxes" reached two bars past the last one, and the
            // math.min below truncated every ordinary box that came near the right edge.
            int maxMsecPastLastBar = maxBarsPastLastBarInput * chartTfSeconds * 1000
            boxLengthTimeReference = baseHtfBoxLengthOnChartTfInput ? chartTfSeconds : tfData.tfSeconds
            newFvg.endTime := tfData.extendFvg ? last_bar_time + maxMsecPastLastBar : newFvg.startTime + (tfData.boxConfig.boxLength * boxLengthTimeReference * 1000)
            newFvg.endTime := math.min(last_bar_time + maxMsecPastLastBar, newFvg.endTime)
            if newFvg.t != tfData.t
                tfData.idCount += 1
                tfData.t := newFvg.t
                tfData.fvgArray.unshift(newFvg)
                if newFvg.isBullish
                    tfData.bullFvgCount += 1
                    tfData.evNewBull := true
                else if not newFvg.isBullish
                    tfData.bearFvgCount += 1
                    tfData.evNewBear := true
                tfData.evNewTop := newFvg.max
                tfData.evNewBottom := newFvg.min
    tfData

mitigateFvgs(TfFvgType tfData, bool showIds=false) =>
    fillFvgType = tfData.fillFvgType
    if tfData.fvgArray.size() > 0
        for i = tfData.fvgArray.size() - 1 to 0 by 1
            fvg = tfData.fvgArray.get(i)
            [_mitigated, _inversed] = isMitigated(tfData, fvg, fillFvgType)
            if _inversed
                tfData.fvgArray.remove(i)
                fvg.isInversed := true
                fvg.endTime := time
                fvg.midpoint.delete()
                fvg.midpoint := na

                tfData.ifvgArray.unshift(fvg)
                if fvg.isBullish
                    tfData.bullFvgCount -= 1
                else
                    tfData.bearFvgCount -= 1
                // No box deletion here. fvgBoxArray is built in SORTED order by
                // displaySelectFvgBoxes while fvgArray is in insertion order, so index i
                // pointed at an unrelated box. That pass clears and rebuilds every box
                // immediately after this one runs, so it is also unnecessary.

                if fvg.isBullish
                    tfData.bullIfvgCount += 1
                    tfData.evInvBull := true
                else
                    tfData.bearIfvgCount += 1
                    tfData.evInvBear := true
                tfData.evInvTop := fvg.max
                tfData.evInvBottom := fvg.min

    if tfData.ifvgArray.size() > 0
        for i = tfData.ifvgArray.size() - 1 to 0 by 1
            ifvg = tfData.ifvgArray.get(i)
            [_mitigated, _inversed] = isMitigated(tfData, ifvg, fillFvgType)
            if _mitigated
                tfData.ifvgArray.remove(i)
                ifvg.isMitigated := true

                // Same as above: displaySelectIfvgBoxes rebuilds these from scratch,
                // and index i does not address the box this ifvg drew.

                if ifvg.isBullish
                    tfData.bullIfvgCount -= 1
                else
                    tfData.bearIfvgCount -= 1

                if ifvg.isBullish
                    tfData.bullMfvgCount += 1
                else
                    tfData.bearMfvgCount += 1
                if tfData.showMfvg
                    labelStr = tfData.labelConfig.showLabels ? tfData.name + (showIds ? " " + str.tostring(ifvg.id) + " " : "") + " mFVG" : ""
                    mitigatedColor = tfData.boxConfig.useMitigatedIfvgColor ? tfData.boxConfig.mfvgColor : (ifvg.isBullish ? tfData.boxConfig.bearIfvgColor : tfData.boxConfig.bullIfvgColor)
                    tfData.mfvgBoxArray.unshift(createBox(ifvg, labelStr, tfData.labelConfig, mitigatedColor, toSolid(mitigatedColor, tfData.boxConfig.borderTransparency), 0, tfData.boxConfig.fvgBorderStyle, false, themeLabelColor))
                    if tfData.mfvgBoxArray.size() > MAX_MFVG_BOXES
                        oldestMfvgBox = tfData.mfvgBoxArray.pop()
                        oldestMfvgBox.delete()
    tfData

clearEvents(TfFvgType tfData) =>
    tfData.evNewBull := false
    tfData.evNewBear := false
    tfData.evInvBull := false
    tfData.evInvBear := false
    tfData.evTouchBull := false
    tfData.evTouchBear := false
    tfData

// First time the chart bar trades INSIDE a live FVG. Strict inequalities on purpose:
// the bar that forms a bullish gap has its low sitting exactly on the box top, and
// the same for a bearish gap's high on the box bottom, so <= would fire on the
// forming bar itself. The barCreated guard covers HTF boxes for the same reason.
touchFvgs(TfFvgType tfData) =>
    if tfData.fvgArray.size() > 0
        for i = 0 to tfData.fvgArray.size() - 1
            fvg = tfData.fvgArray.get(i)
            if not fvg.touched and bar_index > fvg.barCreated and low < fvg.max and high > fvg.min
                fvg.touched := true
                if fvg.isBullish
                    tfData.evTouchBull := true
                else
                    tfData.evTouchBear := true
                tfData.evTouchTop := fvg.max
                tfData.evTouchBottom := fvg.min
    tfData
//}

// --------------------- Timeframe Parsing { ----------------------------- \\
chartTfSeconds = tfInSeconds(timeframe.period)
htf1TfSeconds = tfInSeconds(parseHtfInput(htf1TfInput))
htf2TfSeconds = tfInSeconds(parseHtfInput(htf2TfInput))
htf3TfSeconds = tfInSeconds(parseHtfInput(htf3TfInput))
maxHtfTfSeconds = math.max(htf1TfSeconds, htf2TfSeconds, htf3TfSeconds)
ltfIntervalsInHtf = math.ceil(maxHtfTfSeconds / math.max(chartTfSeconds, 1))
int htfLookbackLengthInLtfBars = maxBarHistoryInput * ltfIntervalsInHtf // looks back HTF period * maxBarHistory
int htfStartBarIndex = last_bar_index - htfLookbackLengthInLtfBars
//}

// --------------------- Data { ----------------------------- \\
initLtfTfFvgTypeData(string name, string tfInput, FvgDisplayType displayType, float nFilter, bool _showFvg, bool _showIfvg) =>
    TfFvgType tfFvg = TfFvgType.new(
         name = "",
         labelConfig = LabelConfigType.new(
             showLabels = ltfShowBoxLabelsInput,
             size = ltfLabelSizeOption,
             hAlignment = ltfLabelAlignmentOption),
         boxConfig = BoxConfigType.new(
             boxLength = ltfBoxLengthInput,
             bullColor = themeBullColor,
             bearColor = themeBearColor,
             bullIfvgColor = themeBullIfvgColor,
             bearIfvgColor = themeBearIfvgColor,
             mfvgColor = themeMfvgColor,
             dimBullColor = themeDimBullColor,
             dimBearColor = themeDimBearColor,
             useMitigatedIfvgColor = useMitigatedIfvgColorInput,
             fvgBorderColor = themeFvgBorderColor,
             fvgBorderWidth = themeFvgBorderWidth,
             fvgBorderStyle = themeFvgBorderStyle,
             ifvgBorderColor = themeIfvgBorderColor,
             ifvgBorderWidth = themeIfvgBorderWidth,
             ifvgBorderStyle = themeIfvgBorderStyle),
         fvgArray = array.new<FvgType>(0),
         fvgBoxArray = array.new<box>(0),
         mfvgBoxArray = array.new<box>(0),
         ifvgArray = array.new<FvgType>(0),
         ifvgBoxArray = array.new<box>(0),
         filteredLow = array.new_float(0),
         filteredHigh = array.new_float(0),
         filteredClose = array.new_float(0),
         filteredRequestTime = array.new_int(0),
         fillFvgType = fillFvgTypeInput,
         bullFvgCount = 0,
         bullIfvgCount = 0,
         bullMfvgCount = 0,
         bearFvgCount = 0,
         bearIfvgCount = 0,
         bearMfvgCount = 0,
         t = 0,
         waitForClose = waitForCloseInput,
         fvgDisplayType = displayType,
         fvgDisplayNClosest = int(nFilter),
         fvgDisplayNAtrs = nFilter,
         showFvg = _showFvg,
         showIfvg = _showIfvg,
         showMfvg = ltfShowMfvgInput,
         extendFvg = ltfExtendFvgBoxesInput,
         idCount = 0)

    tfFvg.tfPeriod := tfInput == "chart" ? timeframe.period : tfInput == "1H" ? "60" : tfInput
    tfFvg.tfSeconds := tfInput == "chart" ? timeframe.in_seconds() : tfInSeconds(tfFvg.tfPeriod)
    tfFvg.waitForClose := waitForCloseInput and tfInput == "chart"
    tfFvg.name := name +  parseTimeframe(tfFvg.tfPeriod)
    tfFvg

initHtfTfFvgTypeData(string name, string tfInput, BoxConfigType _boxConfig, FvgDisplayType displayType, float nFilter, bool _showFvg, bool _showIfvg) =>
    TfFvgType tfFvg = TfFvgType.new(
         name = "",
         labelConfig = LabelConfigType.new(
             showLabels = htfShowBoxLabelsInput,
             size = htfLabelSizeOption,
             hAlignment = htfLabelAlignmentOption),
         boxConfig = _boxConfig,
         fvgArray = array.new<FvgType>(0),
         fvgBoxArray = array.new<box>(0),
         mfvgBoxArray = array.new<box>(0),
         ifvgArray = array.new<FvgType>(0),
         ifvgBoxArray = array.new<box>(0),
         filteredLow = array.new_float(0),
         filteredHigh = array.new_float(0),
         filteredClose = array.new_float(0),
         filteredRequestTime = array.new_int(0),
         fillFvgType = fillFvgTypeInput,
         bullFvgCount = 0,
         bullIfvgCount = 0,
         bullMfvgCount = 0,
         bearFvgCount = 0,
         bearIfvgCount = 0,
         bearMfvgCount = 0,
         t = 0,
         waitForClose = waitForCloseInput,
         fvgDisplayType = displayType,
         fvgDisplayNClosest = int(nFilter),
         fvgDisplayNAtrs = nFilter,
         showFvg = _showFvg,
         showIfvg = _showIfvg,
         showMfvg = htfShowMfvgInput,
         extendFvg = htfExtendFvgBoxesInput,
         idCount = 0)

    tfFvg.tfPeriod := tfInput == "chart" ? timeframe.period : tfInput == "1H" ? "60" : tfInput
    tfFvg.tfSeconds := tfInput == "chart" ? timeframe.in_seconds() : tfInSeconds(tfFvg.tfPeriod)
    tfFvg.waitForClose := waitForCloseInput and tfInput == "chart"
    tfFvg.name := name +  parseTimeframe(tfFvg.tfPeriod)
    tfFvg

// One box config per HTF. They are identical now that the palette is theme-driven,
// but each timeframe keeps its own so a per-TF override stays a one-line change.
makeHtfBoxConfig() =>
    BoxConfigType.new(
         boxLength = htfBoxLengthInput,
         bullColor = themeBullColor,
         bearColor = themeBearColor,
         bullIfvgColor = themeBullIfvgColor,
         bearIfvgColor = themeBearIfvgColor,
         mfvgColor = themeMfvgColor,
         dimBullColor = themeDimBullColor,
         dimBearColor = themeDimBearColor,
         useMitigatedIfvgColor = useMitigatedIfvgColorInput,
         fvgBorderColor = themeFvgBorderColor,
         fvgBorderWidth = themeFvgBorderWidth,
         fvgBorderStyle = themeFvgBorderStyle,
         ifvgBorderColor = themeIfvgBorderColor,
         ifvgBorderWidth = themeIfvgBorderWidth,
         ifvgBorderStyle = themeIfvgBorderStyle)

bool tfInLabels = false
displayType = toDisplayType(ltf1FilterModeInput)
var ltf1 = initLtfTfFvgTypeData(tfInLabels ? "LTF " : "", ltf1TfInput, displayType, ltf1FvgNFilterInput, ltf1ShowFvgsInput, ltf1ShowIfvgsInput)

displayType := toDisplayType(htf1FilterModeInput)
var htf1BoxConfig = makeHtfBoxConfig()
var htf1 = initHtfTfFvgTypeData(tfInLabels ? "HTF " : "", parseHtfInput(htf1TfInput), htf1BoxConfig, displayType, htf1FvgNFilterInput, htf1ShowFvgsInput, htf1ShowIfvgsInput)

displayType := toDisplayType(htf2FilterModeInput)
var htf2BoxConfig = makeHtfBoxConfig()
var htf2 = initHtfTfFvgTypeData(tfInLabels ? "HTF2 " : "", parseHtfInput(htf2TfInput), htf2BoxConfig, displayType, htf2FvgNFilterInput, htf2ShowFvgsInput, htf2ShowIfvgsInput)

displayType := toDisplayType(htf3FilterModeInput)
var htf3BoxConfig = makeHtfBoxConfig()
var htf3 = initHtfTfFvgTypeData(tfInLabels ? "HTF3 " : "", parseHtfInput(htf3TfInput), htf3BoxConfig, displayType, htf3FvgNFilterInput, htf3ShowFvgsInput, htf3ShowIfvgsInput)
//}

// Calculate max bar index for different timeframes
withinLtfMaxBarIndexHistory = bar_index >= (last_bar_index - maxBarHistoryInput)
withinHtfMaxBarIndexHistory = bar_index >= htfStartBarIndex

float chartAtr = ta.atr(ATR_LENGTH)

// --------------------- Collect TF Data { ----------------------------- \\
ltfDuplicatesHtf = ltf1.tfSeconds == htf1.tfSeconds or ltf1.tfSeconds == htf2.tfSeconds or ltf1.tfSeconds == htf3.tfSeconds
ltf1Enable = ltf1EnableInput and (not hideLowerThanChartTfBoxes or (hideLowerThanChartTfBoxes and ltf1.tfSeconds >= chartTfSeconds))
ltf1Enable := ltf1Enable and (favorLtfOverHtfWhenEqualTfsInput or ltfOnlyInput or (not favorLtfOverHtfWhenEqualTfsInput and not ltfDuplicatesHtf))
if ltf1Enable
    [ltf1Low, ltf1High, ltf1Close, ltf1SecurityRequestTime, ltf1AtrSeries] = request.security(syminfo.tickerid, ltf1.tfPeriod, [low, high, close, time, ta.atr(ATR_LENGTH)], gaps=barmerge.gaps_on)
    ltf1.filteredLow := getLastNaValues(ltf1Low, 3)
    ltf1.filteredHigh := getLastNaValues(ltf1High, 3)
    ltf1.filteredClose := getLastNaValues(ltf1Close, 3)
    ltf1.filteredRequestTime := getLastNaValues(ltf1SecurityRequestTime, 3)
    ltf1AtrValues = getLastNaValues(ltf1AtrSeries, 1)
    ltf1.atr := ltf1AtrValues.size() > 0 ? ltf1AtrValues.get(0) : na

htf1Enable = htf1EnableInput and (not hideLowerThanChartTfBoxes or (hideLowerThanChartTfBoxes and htf1.tfSeconds >= chartTfSeconds))
htf1DuplicatesLtf1 = htf1.tfSeconds == ltf1.tfSeconds
htf1Enable := htf1Enable and (not favorLtfOverHtfWhenEqualTfsInput or (favorLtfOverHtfWhenEqualTfsInput and not htf1DuplicatesLtf1))
if htf1Enable
    [htf1Low, htf1High, htf1Close, htf1SecurityRequestTime, htf1AtrSeries] = request.security(syminfo.tickerid, htf1.tfPeriod, [low, high, close, time, ta.atr(ATR_LENGTH)], gaps=barmerge.gaps_on)
    htf1.filteredLow := getLastNaValues(htf1Low, 3)
    htf1.filteredHigh := getLastNaValues(htf1High, 3)
    htf1.filteredClose := getLastNaValues(htf1Close, 3)
    htf1.filteredRequestTime := getLastNaValues(htf1SecurityRequestTime, 3)
    htf1AtrValues = getLastNaValues(htf1AtrSeries, 1)
    htf1.atr := htf1AtrValues.size() > 0 ? htf1AtrValues.get(0) : na

htf2Enable = htf2EnableInput and (not hideLowerThanChartTfBoxes or (hideLowerThanChartTfBoxes and htf2.tfSeconds >= chartTfSeconds))
htf2DuplicatesLtf1 = htf2.tfSeconds == ltf1.tfSeconds
htf2Enable := htf2Enable and (not favorLtfOverHtfWhenEqualTfsInput or (favorLtfOverHtfWhenEqualTfsInput and not htf2DuplicatesLtf1))
if htf2Enable
    [htf2Low, htf2High, htf2Close, htf2SecurityRequestTime, htf2AtrSeries] = request.security(syminfo.tickerid, htf2.tfPeriod, [low, high, close, time, ta.atr(ATR_LENGTH)], gaps=barmerge.gaps_on)
    htf2.filteredLow := getLastNaValues(htf2Low, 3)
    htf2.filteredHigh := getLastNaValues(htf2High, 3)
    htf2.filteredClose := getLastNaValues(htf2Close, 3)
    htf2.filteredRequestTime := getLastNaValues(htf2SecurityRequestTime, 3)
    htf2AtrValues = getLastNaValues(htf2AtrSeries, 1)
    htf2.atr := htf2AtrValues.size() > 0 ? htf2AtrValues.get(0) : na

htf3Enable = htf3EnableInput and (not hideLowerThanChartTfBoxes or (hideLowerThanChartTfBoxes and htf3.tfSeconds >= chartTfSeconds))
htf3DuplicatesLtf1 = htf3.tfSeconds == ltf1.tfSeconds
htf3Enable := htf3Enable and (not favorLtfOverHtfWhenEqualTfsInput or (favorLtfOverHtfWhenEqualTfsInput and not htf3DuplicatesLtf1))
if htf3Enable
    [htf3Low, htf3High, htf3Close, htf3SecurityRequestTime, htf3AtrSeries] = request.security(syminfo.tickerid, htf3.tfPeriod, [low, high, close, time, ta.atr(ATR_LENGTH)], gaps=barmerge.gaps_on)
    htf3.filteredLow := getLastNaValues(htf3Low, 3)
    htf3.filteredHigh := getLastNaValues(htf3High, 3)
    htf3.filteredClose := getLastNaValues(htf3Close, 3)
    htf3.filteredRequestTime := getLastNaValues(htf3SecurityRequestTime, 3)
    htf3AtrValues = getLastNaValues(htf3AtrSeries, 1)
    htf3.atr := htf3AtrValues.size() > 0 ? htf3AtrValues.get(0) : na
//}

bool showBoxIds = false
clearEvents(ltf1)
if withinLtfMaxBarIndexHistory and ltf1Enable
    findFvgs(ltf1, chartTfSeconds)
    mitigateFvgs(ltf1, showBoxIds)
    touchFvgs(ltf1)
    displaySelectFvgBoxes(ltf1, chartTfSeconds, ltfShowFvgMidLineInput, showBoxIds)
    displaySelectIfvgBoxes(ltf1, showBoxIds)

clearEvents(htf1)
if withinHtfMaxBarIndexHistory and htf1Enable
    findFvgs(htf1, chartTfSeconds)
    mitigateFvgs(htf1, showBoxIds)
    touchFvgs(htf1)
    displaySelectFvgBoxes(htf1, chartTfSeconds, htfShowFvgMidLineInput, showBoxIds)
    displaySelectIfvgBoxes(htf1, showBoxIds)

clearEvents(htf2)
if withinHtfMaxBarIndexHistory and htf2Enable
    findFvgs(htf2, chartTfSeconds)
    mitigateFvgs(htf2, showBoxIds)
    touchFvgs(htf2)
    displaySelectFvgBoxes(htf2, chartTfSeconds, htfShowFvgMidLineInput, showBoxIds)
    displaySelectIfvgBoxes(htf2, showBoxIds)

clearEvents(htf3)
if withinHtfMaxBarIndexHistory and htf3Enable
    findFvgs(htf3, chartTfSeconds)
    mitigateFvgs(htf3, showBoxIds)
    touchFvgs(htf3)
    displaySelectFvgBoxes(htf3,  chartTfSeconds, htfShowFvgMidLineInput, showBoxIds)
    displaySelectIfvgBoxes(htf3, showBoxIds)

// --------------------- Update Status Table { ----------------------------- \\
fillStatusTableCell(table _table, int _col, int _row, string _text, color _bgcolor=color.white, color _txtcolor=color.black, string _text_size=size.auto) =>
    table.cell(_table, _col, _row, _text, bgcolor=_bgcolor, text_color=_txtcolor, text_size=_text_size)

getDisplayTypeStr(string mode, float n) =>
    mode == "All" ? "-" : mode == "ATR" ? str.tostring(n) + "a" : str.tostring(int(n))

if statusTableLocationInput != "hidden"
    statusTableRows = 15
    statusTableCols = 9
    bgColor = isDark ? color.new(color.black, 100) : color.white
    textColor = isDark ? color.white : color.black
    frameColor = isDark ? #383C45 : color.black
    var table statusTable = table.new(statusTableLocationInput, statusTableCols, statusTableRows, border_width=1, force_overlay=true)
    statusTable.set_border_color(frameColor)
    statusTable.set_frame_color(frameColor)
    statusTable.set_frame_width(1)
    row = 0
    col = 2 + (showPrimaryStatsInput ? 2 : 0) + (showSecondaryStatsInput ? 2 : 0) + (showMitigatedStatsInput ? 2 : 0)
    table.merge_cells(statusTable, 0, row, col, row)
    biasColor = biasInput == HtfBiasType.Neutral ? color.new(color.gray, 90) : biasInput == HtfBiasType.Bullish ? ltf1.boxConfig.bullColor : ltf1.boxConfig.bearColor
    fillStatusTableCell(statusTable, 0, row, "Bias: " + str.tostring(biasInput), biasColor, textColor, statusTableFontSizeOption)
    row += 1
    fillStatusTableCell(statusTable, 0, row, "atr: " + str.tostring(math.round_to_mintick(chartAtr)), bgColor, textColor, "tiny")
    fillStatusTableCell(statusTable, 1, row, "TF", bgColor, textColor, statusTableFontSizeOption)
    fillStatusTableCell(statusTable, 2, row, "Filter", bgColor, textColor, statusTableFontSizeOption)
    col := 3
    if showPrimaryStatsInput
        table.merge_cells(statusTable, col, row, col+1, row)
        fillStatusTableCell(statusTable, col, row, "FVG", bgColor, textColor, statusTableFontSizeOption)
        col += 2
    if showSecondaryStatsInput
        table.merge_cells(statusTable, col, row, col+1, row)
        fillStatusTableCell(statusTable, col, row, "iFVG", bgColor, textColor, statusTableFontSizeOption)
        col += 2
    if showMitigatedStatsInput
        table.merge_cells(statusTable, col, row, col+1, row)
        fillStatusTableCell(statusTable, col, row, "mFVG", bgColor, textColor, statusTableFontSizeOption)
    row += 1

    if barstate.islast
        if ltf1EnableInput
            ltf1Str = ltf1TfInput //== "chart" ? timeframe.period + (timeframe.isminutes ? " min" : "") : ltf1TfInput
            fillStatusTableCell(statusTable, 0, row, "LTF 1", bgColor, textColor, statusTableFontSizeOption)
            fillStatusTableCell(statusTable, 1, row, ltf1Str, bgColor, textColor, statusTableFontSizeOption)
            fillStatusTableCell(statusTable, 2, row, getDisplayTypeStr(ltf1FilterModeInput, ltf1FvgNFilterInput), bgColor, textColor, statusTableFontSizeOption)
            col := 3
            if showPrimaryStatsInput
                if ltf1ShowFvgsInput
                    fillStatusTableCell(statusTable, col, row, str.tostring(ltf1.bullFvgCount), ltf1.boxConfig.bullColor, textColor, statusTableFontSizeOption)
                    fillStatusTableCell(statusTable, col+1, row, str.tostring(ltf1.bearFvgCount), ltf1.boxConfig.bearColor, textColor, statusTableFontSizeOption)
                col += 2
            if showSecondaryStatsInput
                if ltf1ShowIfvgsInput
                    fillStatusTableCell(statusTable, col, row, str.tostring(ltf1.bullIfvgCount), ltf1.boxConfig.bearIfvgColor, textColor, statusTableFontSizeOption)
                    fillStatusTableCell(statusTable, col+1, row, str.tostring(ltf1.bearIfvgCount), ltf1.boxConfig.bullIfvgColor, textColor, statusTableFontSizeOption)
                col += 2
            if showMitigatedStatsInput
                fillStatusTableCell(statusTable, col, row, str.tostring(ltf1.bullMfvgCount), ltf1.boxConfig.mfvgColor, textColor, statusTableFontSizeOption)
                fillStatusTableCell(statusTable, col+1, row, str.tostring(ltf1.bearMfvgCount), ltf1.boxConfig.mfvgColor, textColor, statusTableFontSizeOption)
            row += 1

        if htf1EnableInput
            htf1Str = htf1TfInput == "auto" ? str.tostring(htf1.tfPeriod) : htf1TfInput == "chart" ? timeframe.period + (timeframe.isminutes ? " min" : "") : htf1TfInput
            fillStatusTableCell(statusTable, 0, row, (htf1TfInput == "auto" ? "auto\n" : "") + "HTF 1", bgColor, textColor, statusTableFontSizeOption)
            fillStatusTableCell(statusTable, 1, row, htf1Str, bgColor, textColor, statusTableFontSizeOption)
            fillStatusTableCell(statusTable, 2, row, getDisplayTypeStr(htf1FilterModeInput, htf1FvgNFilterInput), bgColor, textColor, statusTableFontSizeOption)
            col := 3
            if showPrimaryStatsInput
                if htf1ShowFvgsInput
                    fillStatusTableCell(statusTable, col, row, str.tostring(htf1.bullFvgCount), htf1.boxConfig.bullColor, textColor, statusTableFontSizeOption)
                    fillStatusTableCell(statusTable, col+1, row, str.tostring(htf1.bearFvgCount), htf1.boxConfig.bearColor, textColor, statusTableFontSizeOption)
                col += 2
            if showSecondaryStatsInput
                if htf1ShowIfvgsInput
                    fillStatusTableCell(statusTable, col, row, str.tostring(htf1.bullIfvgCount), htf1.boxConfig.bearIfvgColor, textColor, statusTableFontSizeOption)
                    fillStatusTableCell(statusTable, col+1, row, str.tostring(htf1.bearIfvgCount), htf1.boxConfig.bullIfvgColor, textColor, statusTableFontSizeOption)
                col += 2
            if showMitigatedStatsInput
                fillStatusTableCell(statusTable, col, row, str.tostring(htf1.bullMfvgCount), htf1.boxConfig.mfvgColor, textColor, statusTableFontSizeOption)
                fillStatusTableCell(statusTable, col+1, row, str.tostring(htf1.bearMfvgCount), htf1.boxConfig.mfvgColor, textColor, statusTableFontSizeOption)
            row += 1

        if htf2EnableInput
            htf2Str = htf2TfInput == "auto" ? str.tostring(htf2.tfPeriod) + (htfIsMinutes(htf2TfInput) ? " min" : "") : htf2TfInput == "chart" ? timeframe.period + (timeframe.isminutes ? " min" : "") : htf2TfInput
            fillStatusTableCell(statusTable, 0, row, (htf2TfInput == "auto" ? "auto\n" : "") + "HTF 2", bgColor, textColor, statusTableFontSizeOption)
            fillStatusTableCell(statusTable, 1, row, htf2Str, bgColor, textColor, statusTableFontSizeOption)
            fillStatusTableCell(statusTable, 2, row, getDisplayTypeStr(htf2FilterModeInput, htf2FvgNFilterInput), bgColor, textColor, statusTableFontSizeOption)
            col := 3
            if showPrimaryStatsInput
                if htf2ShowFvgsInput
                    fillStatusTableCell(statusTable, col, row, str.tostring(htf2.bullFvgCount), htf2.boxConfig.bullColor, textColor, statusTableFontSizeOption)
                    fillStatusTableCell(statusTable, col+1, row, str.tostring(htf2.bearFvgCount), htf2.boxConfig.bearColor, textColor, statusTableFontSizeOption)
                col += 2
            if showSecondaryStatsInput
                if htf2ShowIfvgsInput
                    fillStatusTableCell(statusTable, col, row, str.tostring(htf2.bullIfvgCount), htf2.boxConfig.bearIfvgColor, textColor, statusTableFontSizeOption)
                    fillStatusTableCell(statusTable, col+1, row, str.tostring(htf2.bearIfvgCount), htf2.boxConfig.bullIfvgColor, textColor, statusTableFontSizeOption)
                col += 2
            if showMitigatedStatsInput
                fillStatusTableCell(statusTable, col, row, str.tostring(htf2.bullMfvgCount), htf2.boxConfig.mfvgColor, textColor, statusTableFontSizeOption)
                fillStatusTableCell(statusTable, col+1, row, str.tostring(htf2.bearMfvgCount), htf2.boxConfig.mfvgColor, textColor, statusTableFontSizeOption)
            row += 1

        if htf3EnableInput
            htf3Str = htf3TfInput == "auto" ? str.tostring(htf3.tfPeriod) + (htfIsMinutes(htf3TfInput) ? " min" : "") : htf3TfInput == "chart" ? timeframe.period + (timeframe.isminutes ? " min" : "") : htf3TfInput
            fillStatusTableCell(statusTable, 0, row, (htf3TfInput == "auto" ? "auto\n" : "") + "HTF 3", bgColor, textColor, statusTableFontSizeOption)
            fillStatusTableCell(statusTable, 1, row, htf3Str, bgColor, textColor, statusTableFontSizeOption)
            fillStatusTableCell(statusTable, 2, row, getDisplayTypeStr(htf3FilterModeInput, htf3FvgNFilterInput), bgColor, textColor, statusTableFontSizeOption)
            col := 3
            if showPrimaryStatsInput
                if htf3ShowFvgsInput
                    fillStatusTableCell(statusTable, col, row, str.tostring(htf3.bullFvgCount), htf3.boxConfig.bullColor, textColor, statusTableFontSizeOption)
                    fillStatusTableCell(statusTable, col+1, row, str.tostring(htf3.bearFvgCount), htf3.boxConfig.bearColor, textColor, statusTableFontSizeOption)
                col += 2
            if showSecondaryStatsInput
                if htf3ShowIfvgsInput
                    fillStatusTableCell(statusTable, col, row, str.tostring(htf3.bullIfvgCount), htf3.boxConfig.bearIfvgColor, textColor, statusTableFontSizeOption)
                    fillStatusTableCell(statusTable, col+1, row, str.tostring(htf3.bearIfvgCount), htf3.boxConfig.bullIfvgColor, textColor, statusTableFontSizeOption)
                col += 2
            if showMitigatedStatsInput
                fillStatusTableCell(statusTable, col, row, str.tostring(htf3.bullMfvgCount), htf3.boxConfig.mfvgColor, textColor, statusTableFontSizeOption)
                fillStatusTableCell(statusTable, col+1, row, str.tostring(htf3.bearMfvgCount), htf3.boxConfig.mfvgColor, textColor, statusTableFontSizeOption)
//}

// --------------------- Alerts { ----------------------------- \\
// Six conditions for the alert dialog, each "any enabled timeframe". alertcondition
// messages are constants, so they cannot name the timeframe; the alert() calls
// below can, behind the input, for users who pick "Any alert() function call".
// Bias gates: a bullish bias wants bullish gaps forming and being entered, and BEARISH
// gaps inverting (into bullish iFVGs). The evInv flags carry the original direction.
bool wantBullGap = not biasBear
bool wantBearGap = not biasBull
bool anyNewBull   = wantBullGap and ((ltf1Enable and ltf1.evNewBull)   or (htf1Enable and htf1.evNewBull)   or (htf2Enable and htf2.evNewBull)   or (htf3Enable and htf3.evNewBull))
bool anyNewBear   = wantBearGap and ((ltf1Enable and ltf1.evNewBear)   or (htf1Enable and htf1.evNewBear)   or (htf2Enable and htf2.evNewBear)   or (htf3Enable and htf3.evNewBear))
bool anyInvBull   = wantBearGap and ((ltf1Enable and ltf1.evInvBull)   or (htf1Enable and htf1.evInvBull)   or (htf2Enable and htf2.evInvBull)   or (htf3Enable and htf3.evInvBull))
bool anyInvBear   = wantBullGap and ((ltf1Enable and ltf1.evInvBear)   or (htf1Enable and htf1.evInvBear)   or (htf2Enable and htf2.evInvBear)   or (htf3Enable and htf3.evInvBear))
bool anyTouchBull = wantBullGap and ((ltf1Enable and ltf1.evTouchBull) or (htf1Enable and htf1.evTouchBull) or (htf2Enable and htf2.evTouchBull) or (htf3Enable and htf3.evTouchBull))
bool anyTouchBear = wantBearGap and ((ltf1Enable and ltf1.evTouchBear) or (htf1Enable and htf1.evTouchBear) or (htf2Enable and htf2.evTouchBear) or (htf3Enable and htf3.evTouchBear))

alertcondition(anyNewBull,   "Bullish FVG formed",          "{{ticker}}: bullish FVG formed")
alertcondition(anyNewBear,   "Bearish FVG formed",          "{{ticker}}: bearish FVG formed")
alertcondition(anyInvBull,   "Bullish FVG inverted",        "{{ticker}}: bullish FVG closed through, now a bearish iFVG")
alertcondition(anyInvBear,   "Bearish FVG inverted",        "{{ticker}}: bearish FVG closed through, now a bullish iFVG")
alertcondition(anyTouchBull, "Price entered bullish FVG",   "{{ticker}}: price trading inside a bullish FVG")
alertcondition(anyTouchBear, "Price entered bearish FVG",   "{{ticker}}: price trading inside a bearish FVG")

levelsStr(float top, float bottom) =>
    str.tostring(math.round_to_mintick(bottom)) + " to " + str.tostring(math.round_to_mintick(top))

fireAlerts(TfFvgType tfData, bool enabled) =>
    if enabled
        string prefix = syminfo.ticker + " " + tfData.name + ": "
        if tfData.evNewBull and wantBullGap
            alert(prefix + "bullish FVG formed, " + levelsStr(tfData.evNewTop, tfData.evNewBottom), alert.freq_once_per_bar)
        if tfData.evNewBear and wantBearGap
            alert(prefix + "bearish FVG formed, " + levelsStr(tfData.evNewTop, tfData.evNewBottom), alert.freq_once_per_bar)
        if tfData.evInvBull and wantBearGap
            alert(prefix + "bullish FVG inverted to bearish iFVG, " + levelsStr(tfData.evInvTop, tfData.evInvBottom), alert.freq_once_per_bar)
        if tfData.evInvBear and wantBullGap
            alert(prefix + "bearish FVG inverted to bullish iFVG, " + levelsStr(tfData.evInvTop, tfData.evInvBottom), alert.freq_once_per_bar)
        if tfData.evTouchBull and wantBullGap
            alert(prefix + "price entered bullish FVG, " + levelsStr(tfData.evTouchTop, tfData.evTouchBottom), alert.freq_once_per_bar)
        if tfData.evTouchBear and wantBearGap
            alert(prefix + "price entered bearish FVG, " + levelsStr(tfData.evTouchTop, tfData.evTouchBottom), alert.freq_once_per_bar)

if alertMessagesInput
    fireAlerts(ltf1, ltf1Enable)
    fireAlerts(htf1, htf1Enable)
    fireAlerts(htf2, htf2Enable)
    fireAlerts(htf3, htf3Enable)
//}
````
