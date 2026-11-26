# Crown Structure Ledger [JOAT]

- url: https://www.tradingview.com/script/00USOnhb-Crown-Structure-Ledger-JOAT/
- type: indicator
- pine_id: PUB;0ee90af831c24db496b7de6701a4a4e2
- version: 1.0

## Description

[b]Crown Structure Ledger [JOAT][/b]

[b]Introduction[/b]

Crown Structure Ledger is an open-source market structure ledger built to classify price through three structural horizons at the same time: short-term, intermediate-term, and primary-term.

Instead of reducing structure to a single swing model, this script maintains separate rails for each horizon so users can see where local repricing, intermediate repricing, and larger campaign structure are currently positioned.

The indicator is designed to solve a common chart-reading problem:

Traders often know price is moving, but they do not know whether the move is merely a short-term impulse inside a larger range, an intermediate continuation, or a genuine primary expansion.

Crown Structure Ledger addresses that by combining:

[list]
[*]confirmed pivot structure
[*]active break state tracking
[*]adaptive ATR corridors
[*]EMA trend context
[*]volume-pressure bias scoring
[*]state-based candle coloring
[*]forward structure projection
[*]a top-right institutional dashboard
[/list]

The output is intentionally visual but restrained.

Instead of cluttering the chart with excessive markers, the script emphasizes live structural rails, shaded corridors, confirmed state transitions, and a dashboard that summarizes the current condition of each structural layer.

[image]https://www.tradingview.com/x/IkK4NECx[/image]

[b]Core Concepts[/b]

[b]1. Three-Horizon Structure Mapping[/b]

The script confirms three separate pivot systems using different left/right lengths.

This creates a short-term layer for local impulse, an intermediate layer for swing control, and a primary layer for broader directional structure.

Each confirmed pivot updates its own active rail instead of overwriting the other layers.

[b]2. Confirmed Break Logic[/b]

Break states are only recognized on confirmed bars.

This means the script does not react to intrabar spikes through a level.

A structural state changes only when price closes through a live rail beyond a small corridor allowance.

[b]3. Adaptive Structure Corridors[/b]

Every rail is wrapped in an ATR-based corridor.

When adaptive depth is enabled, the corridor expands or contracts according to volatility conditions so the structure model stays usable across slow and fast environments.

[b]4. Pressure-Weighted Bias[/b]

The indicator includes a directional pressure score based on up-volume versus down-volume across a configurable window.

That pressure score is combined with EMA orientation and structure state to create a bias color system rather than a binary trend flag.

[b]5. Forward Projection[/b]

Current structural rails can be extended forward so the user can see where the next important structural interaction is likely to occur without manually drawing continuation levels.

[image]https://www.tradingview.com/x/mCF4O1EH/[/image]

[b]Features[/b]

[list]
[*][b]Three structure horizons:[/b] short, intermediate, and primary rails tracked independently
[*][b]Adaptive structure corridors:[/b] live ATR-based zones around active rails
[*][b]Confirmed structural transitions:[/b] break states only update on confirmed bars
[*][b]Break labels:[/b] optional state labels appear when a new structural expansion or compression is confirmed
[*][b]EMA trend filter:[/b] fast and slow EMA alignment supports the structure interpretation
[*][b]Volume-pressure bias model:[/b] directional pressure is estimated from relative up-volume and down-volume
[*][b]Bias cloud:[/b] optional background cloud reflects broader directional control
[*][b]Candle coloring:[/b] bars can be colored from bearish to bullish using a gradient-like bias response
[*][b]Forward corridor projection:[/b] active rails can extend to the right edge of the chart
[*][b]Institutional dashboard:[/b] top-right summary of structure state, bias, pressure, and live rail context
[/list]

[b]Input Parameters[/b]

[b]Structure Engine[/b]
[list]
[*]Short Pivot Length
[*]Intermediate Pivot Length
[*]Primary Pivot Length
[*]Structure Corridor ATR
[*]Adaptive Corridor Depth
[*]ATR Length
[/list]

[b]Bias Filter[/b]
[list]
[*]Fast EMA
[*]Slow EMA
[*]Pressure Window
[*]Color Candles
[*]Show Structure Cloud
[*]Show Structure Rails
[*]Show Break Labels
[/list]

[b]Visual System[/b]
[list]
[*]Show Short Term
[*]Show Intermediate Term
[*]Show Primary Term
[*]Show Forward Corridor
[*]Forward Corridor Bars
[*]Dashboard Position
[*]Dashboard Size
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Three States Separately[/b]

Start by checking whether short-term, intermediate-term, and primary-term structure agree.

When all three align, the chart is in a cleaner directional condition.

When they diverge, the market is often transitioning or rotating.

[b]Step 2: Watch the Active Rails[/b]

The live rails mark the current structural boundaries that still matter.

These are the levels price must reclaim or lose to produce a confirmed structural update.

[b]Step 3: Use the Corridors, Not Just the Line[/b]

The corridor around a rail is intentional.

It helps avoid overreacting to shallow level breaches in noisy conditions.

[b]Step 4: Read the Bias Cloud and Candle Tone Together[/b]

If candle color, pressure bias, and the structure cloud all point in the same direction, the chart context is stronger than a single rail break by itself.

[b]Step 5: Use the Dashboard as a Summary, Not a Shortcut[/b]

The dashboard is there to reduce scanning time.

It is best used as a summary of what the rails are already showing visually.

[b]Indicator Limitations[/b]

[list]
[*]Pivot-based structure confirms after the configured right-side bars complete, so signals are intentionally delayed for non-repainting behavior
[*]Very aggressive settings can make the short-term layer overly sensitive on low-quality markets
[*]In prolonged compression, structure may appear stable while directional follow-through remains weak
[*]The indicator explains current structure; it does not guarantee continuation after a break
[/list]

[b]Originality Statement[/b]

Crown Structure Ledger is built around a layered structure ledger rather than a single swing map.

Its distinguishing value comes from maintaining three live structure horizons with adaptive corridors, pressure-aware bias scoring, forward projection, and a dashboard that keeps the chart readable while still exposing the full state of the engine.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It is not financial advice and should not be treated as a recommendation to buy or sell any financial instrument.

All structural readings are derived from historical price and volume data and can fail in abnormal market conditions.

Always use independent judgment and risk management.

## Source Code

````pine
//@version=6
indicator("Crown Structure Ledger [JOAT]", shorttitle = "CSL[JOAT]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 200, max_bars_back = 1000)

//==================================================================================================
// Crown Structure Ledger [JOAT]
//--------------------------------------------------------------------------------------------------
// Purpose:
// Track short-, intermediate-, and primary-term structure with non-repainting pivot confirmation.
// The script maintains active structure rails, structure state, bias shading, candle coloring,
// extension corridors, and a compact institutional dashboard.
//==================================================================================================

//==================================================================================================
// Palette
//==================================================================================================
color BULL_CORE     = #12B981
color BEAR_CORE     = #F05D5E
color NEUTRAL_CORE  = #7C8799
color ACCENT_CORE   = #6FA8FF
color GOLD_CORE     = #D9B15A
color PANEL_BG      = #0F1722
color PANEL_EDGE    = #223247
color PANEL_TEXT    = #D7DFEA
color PANEL_MUTE    = #7D8CA1
color CLOUD_BULL    = color.new(BULL_CORE, 86)
color CLOUD_BEAR    = color.new(BEAR_CORE, 86)

//==================================================================================================
// Inputs
//==================================================================================================
string GROUP_ENGINE = "Structure Engine"
int shortLenInput   = input.int(5, "Short Pivot Length", minval = 2, group = GROUP_ENGINE)
int mediumLenInput  = input.int(13, "Intermediate Pivot Length", minval = 3, group = GROUP_ENGINE)
int longLenInput    = input.int(34, "Primary Pivot Length", minval = 5, group = GROUP_ENGINE)
float atrBandInput  = input.float(0.45, "Structure Corridor ATR", minval = 0.05, step = 0.05, group = GROUP_ENGINE)
bool adaptiveInput  = input.bool(true, "Adaptive Corridor Depth", group = GROUP_ENGINE)
int atrLenInput     = input.int(55, "ATR Length", minval = 5, group = GROUP_ENGINE)

string GROUP_FILTER = "Bias Filter"
int trendFastInput  = input.int(21, "Fast EMA", minval = 2, group = GROUP_FILTER)
int trendSlowInput  = input.int(55, "Slow EMA", minval = 5, group = GROUP_FILTER)
int pressureLenInput = input.int(34, "Pressure Window", minval = 5, group = GROUP_FILTER)
bool colorBarsInput  = input.bool(true, "Color Candles", group = GROUP_FILTER)
bool showCloudInput  = input.bool(true, "Show Structure Cloud", group = GROUP_FILTER)
bool showRailInput   = input.bool(true, "Show Structure Rails", group = GROUP_FILTER)
bool showBosInput    = input.bool(true, "Show Break Labels", group = GROUP_FILTER)

string GROUP_VISUAL = "Visual System"
bool showMicroInput   = input.bool(true, "Show Short Term", group = GROUP_VISUAL)
bool showMedianInput  = input.bool(true, "Show Intermediate Term", group = GROUP_VISUAL)
bool showMacroInput   = input.bool(true, "Show Primary Term", group = GROUP_VISUAL)
bool showProjectionInput = input.bool(true, "Show Forward Corridor", group = GROUP_VISUAL)
int projectionBarsInput  = input.int(20, "Forward Corridor Bars", minval = 5, maxval = 100, group = GROUP_VISUAL)
string dashboardPositionInput = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Bottom Left"], group = GROUP_VISUAL)
string dashboardSizeInput     = input.string("Medium", "Dashboard Size", options = ["Tiny", "Small", "Medium", "Large"], group = GROUP_VISUAL)

//==================================================================================================
// Types
//==================================================================================================
type RailState
    float level = na
    int startIndex = na
    line rail = na
    box corridor = na
    label stateLabel = na
    bool bullish = false
    string term = ""

//==================================================================================================
// Helpers
//==================================================================================================
f_panel_position(string pos) =>
    switch pos
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_panel_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Medium" => size.normal
        => size.large

f_pressure_score(int lookback) =>
    float upVol = 0.0
    float dnVol = 0.0
    for i = 0 to lookback - 1
        if close[i] >= open[i]
            upVol += volume[i]
        else
            dnVol += volume[i]
    float totalVol = math.max(upVol + dnVol, 1.0)
    ((upVol - dnVol) / totalVol) * 100.0

f_bias_color(float biasValue) =>
    biasValue >= 0 ? color.from_gradient(math.min(biasValue, 100.0), 0.0, 100.0, NEUTRAL_CORE, BULL_CORE) : color.from_gradient(math.max(biasValue, -100.0), -100.0, 0.0, BEAR_CORE, NEUTRAL_CORE)

f_make_label(int x, float y, string txt, color txtColor, bool above) =>
    label.new(x, y, txt, style = above ? label.style_label_down : label.style_label_up, color = color.new(PANEL_BG, 0), textcolor = txtColor, size = size.small)

f_update_rail(RailState state, int x1, float y1, int x2, float corridorWidth, color railColor, bool activeVisible) =>
    if activeVisible
        if na(state.rail)
            state.rail := line.new(x1, y1, x2, y1, color = railColor, width = 2)
        else
            state.rail.set_xy1(x1, y1)
            state.rail.set_xy2(x2, y1)
            state.rail.set_color(railColor)

        if na(state.corridor)
            state.corridor := box.new(x1, y1 + corridorWidth, x2, y1 - corridorWidth, bgcolor = color.new(railColor, 88), border_color = color.new(railColor, 65))
        else
            state.corridor.set_left(x1)
            state.corridor.set_right(x2)
            state.corridor.set_top(y1 + corridorWidth)
            state.corridor.set_bottom(y1 - corridorWidth)
            state.corridor.set_bgcolor(color.new(railColor, 88))
            state.corridor.set_border_color(color.new(railColor, 65))
    else
        if not na(state.rail)
            line.delete(state.rail)
            state.rail := na
        if not na(state.corridor)
            box.delete(state.corridor)
            state.corridor := na
    state

f_clear_label(RailState state) =>
    if not na(state.stateLabel)
        label.delete(state.stateLabel)
        state.stateLabel := na
    state

f_term_enabled(string termName) =>
    termName == "Short" ? showMicroInput : termName == "Intermediate" ? showMedianInput : showMacroInput

//==================================================================================================
// Core Calculations
//==================================================================================================
float atrValue = ta.atr(atrLenInput)
float adaptiveAtr = adaptiveInput ? atrValue * math.max(0.65, ta.ema(atrValue / math.max(ta.sma(atrValue, atrLenInput), syminfo.mintick), 13)) : atrValue
float corridorWidth = adaptiveAtr * atrBandInput

float emaFast = ta.ema(close, trendFastInput)
float emaSlow = ta.ema(close, trendSlowInput)
float pressureScore = f_pressure_score(pressureLenInput)
float trendSlope = ta.linreg(emaFast, 5, 0) - ta.linreg(emaFast, 5, 1)

float phShort = ta.pivothigh(high, shortLenInput, shortLenInput)
float plShort = ta.pivotlow(low, shortLenInput, shortLenInput)
float phMedium = ta.pivothigh(high, mediumLenInput, mediumLenInput)
float plMedium = ta.pivotlow(low, mediumLenInput, mediumLenInput)
float phLong = ta.pivothigh(high, longLenInput, longLenInput)
float plLong = ta.pivotlow(low, longLenInput, longLenInput)

var RailState shortHigh = RailState.new()
var RailState shortLow = RailState.new()
var RailState mediumHigh = RailState.new()
var RailState mediumLow = RailState.new()
var RailState longHigh = RailState.new()
var RailState longLow = RailState.new()

var string shortState = "Neutral"
var string mediumState = "Neutral"
var string longState = "Neutral"
var int shortBosCount = 0
var int mediumBosCount = 0
var int longBosCount = 0

if not na(phShort)
    shortHigh.level := phShort
    shortHigh.startIndex := bar_index - shortLenInput
    shortHigh.bullish := false
    shortHigh.term := "Short"
    shortHigh := f_clear_label(shortHigh)

if not na(plShort)
    shortLow.level := plShort
    shortLow.startIndex := bar_index - shortLenInput
    shortLow.bullish := true
    shortLow.term := "Short"
    shortLow := f_clear_label(shortLow)

if not na(phMedium)
    mediumHigh.level := phMedium
    mediumHigh.startIndex := bar_index - mediumLenInput
    mediumHigh.bullish := false
    mediumHigh.term := "Intermediate"
    mediumHigh := f_clear_label(mediumHigh)

if not na(plMedium)
    mediumLow.level := plMedium
    mediumLow.startIndex := bar_index - mediumLenInput
    mediumLow.bullish := true
    mediumLow.term := "Intermediate"
    mediumLow := f_clear_label(mediumLow)

if not na(phLong)
    longHigh.level := phLong
    longHigh.startIndex := bar_index - longLenInput
    longHigh.bullish := false
    longHigh.term := "Primary"
    longHigh := f_clear_label(longHigh)

if not na(plLong)
    longLow.level := plLong
    longLow.startIndex := bar_index - longLenInput
    longLow.bullish := true
    longLow.term := "Primary"
    longLow := f_clear_label(longLow)

shortHigh := f_update_rail(shortHigh, nz(shortHigh.startIndex, bar_index), nz(shortHigh.level, high), bar_index + (showProjectionInput ? projectionBarsInput : 0), corridorWidth, color.new(BEAR_CORE, 0), showRailInput and showMicroInput and not na(shortHigh.level))
shortLow  := f_update_rail(shortLow, nz(shortLow.startIndex, bar_index), nz(shortLow.level, low), bar_index + (showProjectionInput ? projectionBarsInput : 0), corridorWidth, color.new(BULL_CORE, 0), showRailInput and showMicroInput and not na(shortLow.level))
mediumHigh := f_update_rail(mediumHigh, nz(mediumHigh.startIndex, bar_index), nz(mediumHigh.level, high), bar_index + (showProjectionInput ? projectionBarsInput : 0), corridorWidth * 1.15, color.new(BEAR_CORE, 15), showRailInput and showMedianInput and not na(mediumHigh.level))
mediumLow  := f_update_rail(mediumLow, nz(mediumLow.startIndex, bar_index), nz(mediumLow.level, low), bar_index + (showProjectionInput ? projectionBarsInput : 0), corridorWidth * 1.15, color.new(BULL_CORE, 15), showRailInput and showMedianInput and not na(mediumLow.level))
longHigh := f_update_rail(longHigh, nz(longHigh.startIndex, bar_index), nz(longHigh.level, high), bar_index + (showProjectionInput ? projectionBarsInput : 0), corridorWidth * 1.35, color.new(BEAR_CORE, 35), showRailInput and showMacroInput and not na(longHigh.level))
longLow  := f_update_rail(longLow, nz(longLow.startIndex, bar_index), nz(longLow.level, low), bar_index + (showProjectionInput ? projectionBarsInput : 0), corridorWidth * 1.35, color.new(BULL_CORE, 35), showRailInput and showMacroInput and not na(longLow.level))

bool shortBullBreak = barstate.isconfirmed and not na(shortHigh.level) and close > shortHigh.level + corridorWidth * 0.15
bool shortBearBreak = barstate.isconfirmed and not na(shortLow.level) and close < shortLow.level - corridorWidth * 0.15
bool mediumBullBreak = barstate.isconfirmed and not na(mediumHigh.level) and close > mediumHigh.level + corridorWidth * 0.20
bool mediumBearBreak = barstate.isconfirmed and not na(mediumLow.level) and close < mediumLow.level - corridorWidth * 0.20
bool longBullBreak = barstate.isconfirmed and not na(longHigh.level) and close > longHigh.level + corridorWidth * 0.25
bool longBearBreak = barstate.isconfirmed and not na(longLow.level) and close < longLow.level - corridorWidth * 0.25

if shortBullBreak and shortState != "Bullish"
    shortState := "Bullish"
    shortBosCount += 1
    if showBosInput and showMicroInput
        shortHigh := f_clear_label(shortHigh)
        shortHigh.stateLabel := f_make_label(bar_index, shortHigh.level, "Short Expansion", BULL_CORE, true)

if shortBearBreak and shortState != "Bearish"
    shortState := "Bearish"
    shortBosCount += 1
    if showBosInput and showMicroInput
        shortLow := f_clear_label(shortLow)
        shortLow.stateLabel := f_make_label(bar_index, shortLow.level, "Short Compression", BEAR_CORE, false)

if mediumBullBreak and mediumState != "Bullish"
    mediumState := "Bullish"
    mediumBosCount += 1
    if showBosInput and showMedianInput
        mediumHigh := f_clear_label(mediumHigh)
        mediumHigh.stateLabel := f_make_label(bar_index, mediumHigh.level, "Intermediate Expansion", BULL_CORE, true)

if mediumBearBreak and mediumState != "Bearish"
    mediumState := "Bearish"
    mediumBosCount += 1
    if showBosInput and showMedianInput
        mediumLow := f_clear_label(mediumLow)
        mediumLow.stateLabel := f_make_label(bar_index, mediumLow.level, "Intermediate Compression", BEAR_CORE, false)

if longBullBreak and longState != "Bullish"
    longState := "Bullish"
    longBosCount += 1
    if showBosInput and showMacroInput
        longHigh := f_clear_label(longHigh)
        longHigh.stateLabel := f_make_label(bar_index, longHigh.level, "Primary Expansion", BULL_CORE, true)

if longBearBreak and longState != "Bearish"
    longState := "Bearish"
    longBosCount += 1
    if showBosInput and showMacroInput
        longLow := f_clear_label(longLow)
        longLow.stateLabel := f_make_label(bar_index, longLow.level, "Primary Compression", BEAR_CORE, false)

float structureHigh = showMacroInput and not na(longHigh.level) ? longHigh.level : showMedianInput and not na(mediumHigh.level) ? mediumHigh.level : shortHigh.level
float structureLow = showMacroInput and not na(longLow.level) ? longLow.level : showMedianInput and not na(mediumLow.level) ? mediumLow.level : shortLow.level
float structureMid = na(structureHigh) or na(structureLow) ? na : (structureHigh + structureLow) * 0.5
float structureRange = na(structureHigh) or na(structureLow) ? na : math.max(structureHigh - structureLow, syminfo.mintick)
float locationScore = na(structureMid) ? 0.0 : ((close - structureMid) / structureRange) * 200.0
float compositeBias = (emaFast > emaSlow ? 35.0 : -35.0) + pressureScore * 0.35 + locationScore * 0.45 + trendSlope / math.max(atrValue, syminfo.mintick) * 20.0
float clippedBias = math.max(-100.0, math.min(100.0, compositeBias))

//==================================================================================================
// Visual Layer
//==================================================================================================
plotFast = plot(emaFast, "Fast EMA", color = color.new(ACCENT_CORE, 25), linewidth = 2)
plotSlow = plot(emaSlow, "Slow EMA", color = color.new(GOLD_CORE, 35), linewidth = 2)
plotTop = plot(showCloudInput ? structureHigh : na, "Structure Ceiling", color = color.new(BEAR_CORE, 100), linewidth = 1)
plotBottom = plot(showCloudInput ? structureLow : na, "Structure Floor", color = color.new(BULL_CORE, 100), linewidth = 1)
fill(plotTop, plotBottom, color = clippedBias >= 0 ? CLOUD_BULL : CLOUD_BEAR, title = "Structure Cloud")

barcolor(colorBarsInput ? f_bias_color(clippedBias) : na)

float bandUpper = na(structureMid) ? na : structureMid + corridorWidth * 0.85
float bandLower = na(structureMid) ? na : structureMid - corridorWidth * 0.85
plot(showCloudInput ? bandUpper : na, "Equilibrium Upper", color = color.new(ACCENT_CORE, 70), linewidth = 1, style = plot.style_linebr)
plot(showCloudInput ? bandLower : na, "Equilibrium Lower", color = color.new(ACCENT_CORE, 70), linewidth = 1, style = plot.style_linebr)

//==================================================================================================
// Dashboard
//==================================================================================================
var dashPosition = f_panel_position(dashboardPositionInput)
var dashSize = f_panel_size(dashboardSizeInput)
var table dash = table.new(dashPosition, 2, 9, bgcolor = PANEL_BG, frame_color = PANEL_EDGE, frame_width = 1)

f_dash_cell(int c, int r, string txt, color txtColor, color bgColor, alignMode) =>
    table.cell(dash, c, r, txt, text_color = txtColor, bgcolor = bgColor, text_halign = alignMode, text_size = dashSize)

if barstate.islast
    f_dash_cell(0, 0, "Crown Structure Ledger", PANEL_TEXT, PANEL_EDGE, text.align_left)
    f_dash_cell(1, 0, "CSL", PANEL_TEXT, PANEL_EDGE, text.align_right)

    f_dash_cell(0, 1, "Primary State", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 1, longState, longState == "Bullish" ? BULL_CORE : longState == "Bearish" ? BEAR_CORE : PANEL_TEXT, PANEL_BG, text.align_right)

    f_dash_cell(0, 2, "Intermediate State", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 2, mediumState, mediumState == "Bullish" ? BULL_CORE : mediumState == "Bearish" ? BEAR_CORE : PANEL_TEXT, PANEL_BG, text.align_right)

    f_dash_cell(0, 3, "Short State", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 3, shortState, shortState == "Bullish" ? BULL_CORE : shortState == "Bearish" ? BEAR_CORE : PANEL_TEXT, PANEL_BG, text.align_right)

    f_dash_cell(0, 4, "Bias Score", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 4, str.tostring(clippedBias, "#.0"), f_bias_color(clippedBias), PANEL_BG, text.align_right)

    f_dash_cell(0, 5, "Pressure", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 5, str.tostring(pressureScore, "#.0") + "%", pressureScore >= 0 ? BULL_CORE : BEAR_CORE, PANEL_BG, text.align_right)

    f_dash_cell(0, 6, "Primary Rail", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 6, na(structureHigh) or na(structureLow) ? "Unseeded" : str.tostring(structureLow, format.mintick) + " / " + str.tostring(structureHigh, format.mintick), PANEL_TEXT, PANEL_BG, text.align_right)

    f_dash_cell(0, 7, "BOS Count", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 7, str.tostring(shortBosCount + mediumBosCount + longBosCount), GOLD_CORE, PANEL_BG, text.align_right)

    string trendText = emaFast > emaSlow ? "Aligned Higher" : emaFast < emaSlow ? "Aligned Lower" : "Balanced"
    f_dash_cell(0, 8, "Trend Stack", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 8, trendText, emaFast > emaSlow ? BULL_CORE : emaFast < emaSlow ? BEAR_CORE : PANEL_TEXT, PANEL_BG, text.align_right)

//==================================================================================================
// Alerts
//==================================================================================================
alertcondition(longBullBreak, "Primary Bullish Expansion", "Crown Structure Ledger [JOAT] detected a primary bullish expansion.")
alertcondition(longBearBreak, "Primary Bearish Compression", "Crown Structure Ledger [JOAT] detected a primary bearish compression.")
alertcondition(mediumBullBreak or shortBullBreak, "Tactical Bullish Break", "Crown Structure Ledger [JOAT] detected a tactical bullish break.")
alertcondition(mediumBearBreak or shortBearBreak, "Tactical Bearish Break", "Crown Structure Ledger [JOAT] detected a tactical bearish break.")
````
