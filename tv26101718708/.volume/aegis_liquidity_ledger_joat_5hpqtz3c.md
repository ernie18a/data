# Aegis Liquidity Ledger [JOAT]

- url: https://www.tradingview.com/script/5HpqTZ3C-Aegis-Liquidity-Ledger-JOAT/
- type: indicator
- pine_id: PUB;272deb8c618846249302b61c3bc462a4
- version: 1.0

## Description

[b]Aegis Liquidity Ledger [JOAT][/b]

[b]Introduction[/b]

Aegis Liquidity Ledger is an open-source liquidity pressure indicator built to answer a specific execution question:

Where is directional pressure being sourced, and where has that pressure already left behind a meaningful area of interest?

The script approaches that problem through two linked components:

[list]
[*]a volatility-normalized pressure oscillator
[*]shelf detection and origin-zone mapping
[/list]

The oscillator explains whether participation is pushing in a bullish or bearish direction.

The shelf and origin logic explains where that pressure emerged from.

This separation is intentional.

It gives traders both the why and the where without forcing everything into a single overlay object.

[image]https://www.tradingview.com/x/tkeifB5B/[/image]

[b]Core Concepts[/b]

[b]1. Composite Pressure Engine[/b]

The script blends multiple rate-of-change windows into one composite pressure signal.

Short-term impulse and slower campaign participation are both included so the output does not depend on a single lookback length.

[b]2. Volatility-Normalized Thresholds[/b]

The pressure signal is measured against its own recent standard deviation rather than a fixed threshold.

This allows the expansion bands to adapt to the instrument and timeframe being viewed.

[b]3. Shelf Detection[/b]

The script scans for repeated upper and lower interactions using body extremes and wick touches.

That makes the shelf logic more sensitive to areas where liquidity may have repeatedly rested.

[b]4. Expansion Origin Zones[/b]

When pressure transitions through an adaptive bound on a confirmed bar, the script creates a source zone around the origin candle that preceded the release.

This zone remains relevant until price fully accepts through it.

[b]5. Mitigation Logic[/b]

Shelves are not removed immediately.

They remain live until price fully accepts through the opposite side of the zone, after which they are visually de-emphasized as mitigated.

[image]https://www.tradingview.com/x/XaBZRETJ/[/image]

[b]Features[/b]

[list]
[*][b]Four-window pressure model:[/b] fast, medium, slow, and macro ROC blended together
[*][b]Pressure smoothing:[/b] EMA smoothing controls oscillator responsiveness
[*][b]Adaptive expansion thresholds:[/b] thresholds scale with recent pressure volatility
[*][b]Normalized oscillator:[/b] pane output compresses pressure into an interpretable range
[*][b]Demand and supply shelves:[/b] persistent shelf zones are drawn directly on the chart
[*][b]Origin-zone logic:[/b] shelf creation is tied to confirmed expansion events
[*][b]Touch and intensity tracking:[/b] shelf labels summarize interaction count and density
[*][b]Mitigation state:[/b] zones are visually softened after full acceptance through them
[*][b]Pressure-based candle coloring:[/b] optional chart bars reflect dominant liquidity pressure
[*][b]Institutional dashboard:[/b] dashboard summarizes pressure, compression, shelf dominance, and state
[/list]

[b]Input Parameters[/b]

[b]Pressure Engine[/b]
[list]
[*]Fast ROC
[*]Medium ROC
[*]Slow ROC
[*]Macro ROC
[*]Pressure Smoothing
[*]Expansion Threshold Multiplier
[/list]

[b]Liquidity Shelves[/b]
[list]
[*]Shelf Window
[*]Shelf Width ATR
[*]Max Live Shelves Per Side
[*]Show Expansion Origin Zones
[*]Show Shelf Labels
[/list]

[b]Display[/b]
[list]
[*]Show Pressure Fill
[*]Show Expansion Glow
[*]Show Zero Line
[*]Color Candles By Pressure
[*]Dashboard Position
[*]Dashboard Size
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read Pressure Before Reading Shelves[/b]

Start in the pane.

If the pressure engine is neutral or compressed, shelf interactions are more likely to behave as reaction zones than true continuation sources.

[b]Step 2: Watch for Confirmed Expansion[/b]

New shelves matter most when they are created by a confirmed expansion through the adaptive threshold.

That is the moment the script treats the move as meaningful enough to register an origin.

[b]Step 3: Distinguish Live From Mitigated Zones[/b]

Fresh shelves are stronger contextual references than mitigated shelves.

Once a zone has been fully accepted through, it should be treated as reduced context rather than untouched inventory.

[b]Step 4: Compare Upper and Lower Density[/b]

The interaction counts and intensity values help frame whether the instrument has built more meaningful supply or demand shelves in the current environment.

[b]Step 5: Combine With Structure[/b]

Aegis Liquidity Ledger is not a standalone regime classifier.

It works best beside structure or session tools that explain the broader context around the pressure source.

[b]Indicator Limitations[/b]

[list]
[*]Liquidity shelves are inferred from price behavior, not from direct order book or market-by-order data
[*]Aggressive settings can create more shelves than slower traders may want to track
[*]Pressure normalization adapts to the instrument, but abrupt volatility shocks can still distort thresholds temporarily
[*]A shelf is an area of contextual interest, not a guarantee of reversal or continuation
[/list]

[b]Originality Statement[/b]

Aegis Liquidity Ledger is structured around the relationship between a normalized pressure oscillator and persistent source-zone shelves.

Its design emphasizes where pressure comes from, how dense liquidity has been on each side of price, and whether a prior source has been mitigated, rather than simply plotting another momentum line.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It is not a recommendation to trade and should not be interpreted as financial advice.

All shelf and pressure readings are model-based interpretations of chart data and can fail under changing market conditions.

Always use independent analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Aegis Liquidity Ledger [JOAT]", shorttitle = "ALL[JOAT]", overlay = false, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 300)

//==================================================================================================
// Aegis Liquidity Ledger [JOAT]
//--------------------------------------------------------------------------------------------------
// Purpose:
// Measure directional liquidity pressure, identify dense upper/lower liquidity shelves, and map the
// origin zones created when pressure expands from compression into acceptance.
//==================================================================================================

//==================================================================================================
// Engineering Notes
//--------------------------------------------------------------------------------------------------
// 1. The pressure engine is normalized by its own recent volatility so that the threshold adapts
//    to the instrument rather than assuming a fixed oscillator amplitude.
// 2. Shelf detection uses body-versus-wick separation because repeated wick interaction is often a
//    stronger proxy for resting liquidity than raw close clustering alone.
// 3. Expansion shelves are only created on confirmed pressure transitions through adaptive bounds.
// 4. Once a shelf is created, it remains live until price fully accepts through the opposite side of
//    the zone, at which point it becomes mitigated and is visually de-emphasized.
// 5. The pane output and chart overlay are intentionally separate: the oscillator explains why a
//    shelf matters, while the shelf object explains where that pressure originated.
// 6. This script is designed to complement, not replace, the structure and range tools in the rest
//    of the suite. It should answer “where is pressure being sourced?” rather than “what regime are
//    we in?” or “which session level is active?”
//==================================================================================================

//==================================================================================================
// Palette
//==================================================================================================
color LIQ_BULL   = #15B97D
color LIQ_BEAR   = #EF6468
color LIQ_NEUTRAL= #8594A8
color LIQ_GLOW   = #63A6FF
color LIQ_GOLD   = #D7B15B
color PANEL_BG   = #0F1722
color PANEL_EDGE = #223247
color PANEL_TEXT = #D7DFEA
color PANEL_MUTE = #8190A5

//==================================================================================================
// Inputs
//==================================================================================================
string GROUP_MOMENTUM = "Pressure Engine"
int rocFastInput      = input.int(5, "Fast ROC", minval = 1, group = GROUP_MOMENTUM)
int rocMediumInput    = input.int(13, "Medium ROC", minval = 1, group = GROUP_MOMENTUM)
int rocSlowInput      = input.int(21, "Slow ROC", minval = 1, group = GROUP_MOMENTUM)
int rocMacroInput     = input.int(34, "Macro ROC", minval = 1, group = GROUP_MOMENTUM)
int smoothInput       = input.int(5, "Pressure Smoothing", minval = 1, group = GROUP_MOMENTUM)
float thresholdInput  = input.float(2.0, "Expansion Threshold Multiplier", minval = 0.2, step = 0.1, group = GROUP_MOMENTUM)

string GROUP_CLUSTER = "Liquidity Shelves"
int clusterLookbackInput = input.int(20, "Shelf Window", minval = 5, group = GROUP_CLUSTER)
float shelfAtrWidthInput = input.float(0.18, "Shelf Width ATR", minval = 0.05, step = 0.01, group = GROUP_CLUSTER)
int shelfLimitInput      = input.int(3, "Max Live Shelves Per Side", minval = 1, maxval = 8, group = GROUP_CLUSTER)
bool showOriginInput     = input.bool(true, "Show Expansion Origin Zones", group = GROUP_CLUSTER)
bool showShelfLabelsInput = input.bool(true, "Show Shelf Labels", group = GROUP_CLUSTER)

string GROUP_VISUAL = "Display"
bool showBaseFillInput = input.bool(true, "Show Pressure Fill", group = GROUP_VISUAL)
bool showThresholdGlowInput = input.bool(true, "Show Expansion Glow", group = GROUP_VISUAL)
bool showZeroLineInput = input.bool(true, "Show Zero Line", group = GROUP_VISUAL)
bool colorBarsInput = input.bool(true, "Color Candles By Pressure", group = GROUP_VISUAL)
string dashboardPositionInput = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Bottom Left"], group = GROUP_VISUAL)
string dashboardSizeInput = input.string("Medium", "Dashboard Size", options = ["Tiny", "Small", "Medium", "Large"], group = GROUP_VISUAL)

//==================================================================================================
// Types
//==================================================================================================
type ShelfZone
    float top = na
    float bottom = na
    float base = na
    int startTime = na
    bool bullish = false
    bool mitigated = false
    int touches = 0
    float intensity = 0.0
    box zoneBox = na
    label zoneLabel = na

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

f_compact(float value) =>
    float absValue = math.abs(value)
    absValue >= 1000000 ? str.tostring(value / 1000000, "#.##") + "M" : absValue >= 1000 ? str.tostring(value / 1000, "#.##") + "K" : str.tostring(value, "#.##")

f_update_shelf(ShelfZone shelf, color zoneColor, int xRight) =>
    if na(shelf.zoneBox)
        shelf.zoneBox := box.new(shelf.startTime, shelf.top, xRight, shelf.bottom, xloc = xloc.bar_time, bgcolor = color.new(zoneColor, 84), border_color = color.new(zoneColor, 55), force_overlay = true)
    else
        shelf.zoneBox.set_left(shelf.startTime)
        shelf.zoneBox.set_right(xRight)
        shelf.zoneBox.set_top(shelf.top)
        shelf.zoneBox.set_bottom(shelf.bottom)
        shelf.zoneBox.set_bgcolor(color.new(zoneColor, shelf.mitigated ? 92 : 84))
        shelf.zoneBox.set_border_color(color.new(zoneColor, shelf.mitigated ? 75 : 55))

    if showShelfLabelsInput
        string labelText = (shelf.bullish ? "Demand Shelf" : "Supply Shelf") + "\nTouches: " + str.tostring(shelf.touches) + "\nIntensity: " + str.tostring(shelf.intensity, "#.0")
        if na(shelf.zoneLabel)
            shelf.zoneLabel := label.new(xRight, shelf.base, labelText, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(PANEL_BG, 0), textcolor = zoneColor, size = size.small, force_overlay = true)
        else
            shelf.zoneLabel.set_x(xRight)
            shelf.zoneLabel.set_y(shelf.base)
            shelf.zoneLabel.set_text(labelText)
    shelf

f_clear_removed(ShelfZone shelf) =>
    if not na(shelf.zoneBox)
        box.delete(shelf.zoneBox)
    if not na(shelf.zoneLabel)
        label.delete(shelf.zoneLabel)

//==================================================================================================
// Pressure and Shelf Calculations
//==================================================================================================
// The composite pressure model blends four ROC windows so shorter impulse and slower campaign
// participation influence the same normalized oscillator.
float rocFast = ta.roc(close, rocFastInput)
float rocMedium = ta.roc(close, rocMediumInput)
float rocSlow = ta.roc(close, rocSlowInput)
float rocMacro = ta.roc(close, rocMacroInput)
float compositePressure = (rocFast + rocMedium + rocSlow + rocMacro) * 0.25
float smoothedPressure = ta.ema(compositePressure, smoothInput)
float pressureVolatility = math.max(ta.stdev(smoothedPressure, 100), syminfo.mintick)
float upperThreshold = pressureVolatility * thresholdInput
float lowerThreshold = -pressureVolatility * thresholdInput
float normalizedPressure = math.max(-100.0, math.min(100.0, smoothedPressure / math.max(upperThreshold, syminfo.mintick) * 100.0))

float bodyHigh = math.max(open, close)
float bodyLow = math.min(open, close)
float maxBody = ta.highest(bodyHigh, clusterLookbackInput)
float minBody = ta.lowest(bodyLow, clusterLookbackInput)

float upperAnchor = na
float lowerAnchor = na
for i = 0 to clusterLookbackInput - 1
    if high[i] >= maxBody
        upperAnchor := na(upperAnchor) ? high[i] : math.min(upperAnchor, high[i])
    if low[i] <= minBody
        lowerAnchor := na(lowerAnchor) ? low[i] : math.max(lowerAnchor, low[i])

int upperTouches = 0
int lowerTouches = 0
for i = 0 to clusterLookbackInput - 1
    upperTouches += not na(upperAnchor) and high[i] >= upperAnchor ? 1 : 0
    lowerTouches += not na(lowerAnchor) and low[i] <= lowerAnchor ? 1 : 0

float atrValue = ta.atr(21)
float shelfWidth = atrValue * shelfAtrWidthInput
float upperIntensity = upperTouches / math.max(clusterLookbackInput, 1) * 100.0
float lowerIntensity = lowerTouches / math.max(clusterLookbackInput, 1) * 100.0
float dominanceSpread = lowerIntensity - upperIntensity
float compressionGauge = 100.0 - math.min(100.0, math.abs(normalizedPressure))

bool bullExpansion = barstate.isconfirmed and smoothedPressure > upperThreshold and smoothedPressure[1] <= upperThreshold[1]
bool bearExpansion = barstate.isconfirmed and smoothedPressure < lowerThreshold and smoothedPressure[1] >= lowerThreshold[1]
bool bullCompressionRelease = barstate.isconfirmed and smoothedPressure > 0 and smoothedPressure[1] <= 0
bool bearCompressionRelease = barstate.isconfirmed and smoothedPressure < 0 and smoothedPressure[1] >= 0

var ShelfZone[] bullShelves = array.new<ShelfZone>()
var ShelfZone[] bearShelves = array.new<ShelfZone>()

if bullExpansion and showOriginInput
    int originOffset = 1
    for i = 1 to 5
        if close[i] < open[i]
            originOffset := i
            break
    ShelfZone newShelf = ShelfZone.new(high[originOffset] + shelfWidth, low[originOffset] - shelfWidth, hl2[originOffset], time[originOffset], true, false, lowerTouches, lowerIntensity, na, na)
    array.unshift(bullShelves, newShelf)
    if array.size(bullShelves) > shelfLimitInput
        ShelfZone removed = array.pop(bullShelves)
        f_clear_removed(removed)

if bearExpansion and showOriginInput
    int originOffset = 1
    for i = 1 to 5
        if close[i] > open[i]
            originOffset := i
            break
    ShelfZone newShelf = ShelfZone.new(high[originOffset] + shelfWidth, low[originOffset] - shelfWidth, hl2[originOffset], time[originOffset], false, false, upperTouches, upperIntensity, na, na)
    array.unshift(bearShelves, newShelf)
    if array.size(bearShelves) > shelfLimitInput
        ShelfZone removed = array.pop(bearShelves)
        f_clear_removed(removed)

if array.size(bullShelves) > 0
    for i = array.size(bullShelves) - 1 to 0
        ShelfZone shelf = array.get(bullShelves, i)
        if not shelf.mitigated
            if low <= shelf.top and high >= shelf.bottom
                shelf.touches += 1
            if close < shelf.bottom
                shelf.mitigated := true
            shelf := f_update_shelf(shelf, LIQ_BULL, time)
            array.set(bullShelves, i, shelf)

if array.size(bearShelves) > 0
    for i = array.size(bearShelves) - 1 to 0
        ShelfZone shelf = array.get(bearShelves, i)
        if not shelf.mitigated
            if high >= shelf.bottom and low <= shelf.top
                shelf.touches += 1
            if close > shelf.top
                shelf.mitigated := true
            shelf := f_update_shelf(shelf, LIQ_BEAR, time)
            array.set(bearShelves, i, shelf)

//==================================================================================================
// Visual Layer
//==================================================================================================
// The pane view shows both direction and amplitude. Thresholds describe acceptance while the
// auxiliary amplitude plot provides a quick read on whether current motion is expanding or fading.
plotZero = plot(showZeroLineInput ? 0 : na, "Zero Line", color = color.new(LIQ_NEUTRAL, 70), linewidth = 1, style = plot.style_linebr)
plotUpper = plot(upperThreshold, "Upper Threshold", color = color.new(LIQ_BULL, 70), linewidth = 1, style = plot.style_linebr)
plotLower = plot(lowerThreshold, "Lower Threshold", color = color.new(LIQ_BEAR, 70), linewidth = 1, style = plot.style_linebr)
plotPressure = plot(smoothedPressure, "Smoothed Pressure", color = normalizedPressure >= 0 ? color.from_gradient(normalizedPressure, 0.0, 100.0, LIQ_NEUTRAL, LIQ_BULL) : color.from_gradient(normalizedPressure, -100.0, 0.0, LIQ_BEAR, LIQ_NEUTRAL), linewidth = 2)

fill(plotPressure, plotZero, color = showBaseFillInput ? color.new(normalizedPressure >= 0 ? LIQ_BULL : LIQ_BEAR, 88) : na, title = "Pressure Fill")
fill(plotPressure, plotUpper, color = showThresholdGlowInput and smoothedPressure > upperThreshold ? color.new(LIQ_GLOW, 82) : na, title = "Upper Expansion Glow")
fill(plotPressure, plotLower, color = showThresholdGlowInput and smoothedPressure < lowerThreshold ? color.new(LIQ_GLOW, 82) : na, title = "Lower Expansion Glow")

float pressureBand = ta.ema(math.abs(smoothedPressure), 8)
plot(pressureBand, "Pressure Amplitude", color = color.new(LIQ_GOLD, 30), linewidth = 1)
plot(dominanceSpread, "Shelf Dominance Spread", color = color.new(LIQ_GLOW, 35), linewidth = 1)
plot(compressionGauge, "Compression Gauge", color = color.new(LIQ_NEUTRAL, 65), linewidth = 1)

barcolor(colorBarsInput ? (normalizedPressure >= 0 ? color.from_gradient(normalizedPressure, 0.0, 100.0, LIQ_NEUTRAL, LIQ_BULL) : color.from_gradient(normalizedPressure, -100.0, 0.0, LIQ_BEAR, LIQ_NEUTRAL)) : na)

//==================================================================================================
// Dashboard
//==================================================================================================
var table dash = table.new(f_panel_position(dashboardPositionInput), 2, 8, bgcolor = PANEL_BG, frame_color = PANEL_EDGE, frame_width = 1)
var dashSize = f_panel_size(dashboardSizeInput)

f_dash_cell(int c, int r, string txt, color txtColor, color bgColor, alignMode) =>
    table.cell(dash, c, r, txt, text_color = txtColor, bgcolor = bgColor, text_halign = alignMode, text_size = dashSize)

int liveBullShelves = 0
int liveBearShelves = 0
if array.size(bullShelves) > 0
    for i = 0 to array.size(bullShelves) - 1
        ShelfZone shelf = array.get(bullShelves, i)
        liveBullShelves += shelf.mitigated ? 0 : 1
if array.size(bearShelves) > 0
    for i = 0 to array.size(bearShelves) - 1
        ShelfZone shelf = array.get(bearShelves, i)
        liveBearShelves += shelf.mitigated ? 0 : 1

if barstate.islast
    f_dash_cell(0, 0, "Aegis Liquidity Ledger", PANEL_TEXT, PANEL_EDGE, text.align_left)
    f_dash_cell(1, 0, "ALL", PANEL_TEXT, PANEL_EDGE, text.align_right)

    string pressureState = smoothedPressure > upperThreshold ? "Bull Expansion" : smoothedPressure < lowerThreshold ? "Bear Expansion" : smoothedPressure > 0 ? "Bull Acceptance" : smoothedPressure < 0 ? "Bear Acceptance" : "Balanced"
    f_dash_cell(0, 1, "Pressure State", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 1, pressureState, normalizedPressure >= 0 ? LIQ_BULL : LIQ_BEAR, PANEL_BG, text.align_right)

    f_dash_cell(0, 2, "Pressure Score", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 2, str.tostring(normalizedPressure, "#.0"), normalizedPressure >= 0 ? LIQ_BULL : LIQ_BEAR, PANEL_BG, text.align_right)

    f_dash_cell(0, 3, "Upper Shelf Intensity", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 3, str.tostring(upperIntensity, "#.0") + "%", LIQ_BEAR, PANEL_BG, text.align_right)

    f_dash_cell(0, 4, "Lower Shelf Intensity", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 4, str.tostring(lowerIntensity, "#.0") + "%", LIQ_BULL, PANEL_BG, text.align_right)

    f_dash_cell(0, 5, "Live Shelves", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 5, str.tostring(liveBullShelves) + " / " + str.tostring(liveBearShelves), PANEL_TEXT, PANEL_BG, text.align_right)

    f_dash_cell(0, 6, "Relative Volume", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 6, f_compact(volume / math.max(ta.sma(volume, 20), 1.0)) + "x", LIQ_GOLD, PANEL_BG, text.align_right)

    string releaseState = bullCompressionRelease ? "Bull Release" : bearCompressionRelease ? "Bear Release" : "Dormant"
    f_dash_cell(0, 7, "Compression Exit", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 7, releaseState, bullCompressionRelease ? LIQ_BULL : bearCompressionRelease ? LIQ_BEAR : PANEL_TEXT, PANEL_BG, text.align_right)

//==================================================================================================
// Integration Notes
//--------------------------------------------------------------------------------------------------
// The strongest use of this script is as a context filter:
// - Bullish expansions are best respected when demand shelves remain unmitigated.
// - Bearish expansions are best respected when supply shelves remain unmitigated.
// - Compression-release events matter more when structure and regime tools already agree.
// - Shelf dominance spread is a useful secondary ranking field when multiple instruments are being
//   reviewed side by side.
// - This script intentionally avoids placing execution arrows or trade markers because its role is
//   contextual inventory, not standalone trade issuance.
//==================================================================================================

//==================================================================================================
// Alerts
//==================================================================================================
alertcondition(bullExpansion, "Bullish Expansion Shelf", "Aegis Liquidity Ledger [JOAT] confirmed a bullish liquidity expansion.")
alertcondition(bearExpansion, "Bearish Expansion Shelf", "Aegis Liquidity Ledger [JOAT] confirmed a bearish liquidity expansion.")
alertcondition(bullCompressionRelease, "Bullish Compression Release", "Aegis Liquidity Ledger [JOAT] confirmed a bullish compression release.")
alertcondition(bearCompressionRelease, "Bearish Compression Release", "Aegis Liquidity Ledger [JOAT] confirmed a bearish compression release.")
````
