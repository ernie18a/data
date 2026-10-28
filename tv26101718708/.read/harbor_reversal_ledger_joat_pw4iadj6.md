# Harbor Reversal Ledger [JOAT]

- url: https://www.tradingview.com/script/Pw4Iadj6-Harbor-Reversal-Ledger-JOAT/
- type: indicator
- pine_id: PUB;f18044dd324d40a3b3e0763fcd4ae7a0
- version: 1.0

## Description

[b]Harbor Reversal Ledger [JOAT][/b]

[b]Introduction[/b]

Harbor Reversal Ledger is an open-source reversal timing indicator that combines completed higher-timeframe candle context with confirmed local RSI divergence.

The objective is not to predict turning points early.

The objective is to wait for enough evidence that a reversal thesis is becoming structurally credible.

Many reversal tools repaint because they depend on unfinished higher-timeframe candles or unconfirmed pivot comparisons.

Harbor Reversal Ledger avoids that by:

[list]
[*]requesting completed higher-timeframe candles only
[*]confirming RSI pivots before evaluating divergence
[*]scoring confluence from multiple independent ingredients
[*]projecting higher-timeframe structure onto the execution chart
[*]rendering a timing ledger in its own pane
[/list]

[image]https://www.tradingview.com/x/MzQ4QiVd/[/image]

[b]Core Concepts[/b]

[b]1. Completed Higher-Timeframe Context[/b]

The script requests prior higher-timeframe candles rather than reading the currently forming candle.

This keeps the higher-timeframe pattern engine stable and non-repainting.

[b]2. Candle Pattern Recognition[/b]

Bullish and bearish engulfing patterns can be enabled, and pin-bar style rejection patterns can also be used.

These patterns contribute directional context, not automatic entries.

[b]3. Confirmed RSI Divergence[/b]

Local price and RSI pivots are both confirmed using left/right pivot logic.

Only after the pivots are locked does the script compare price progression against RSI progression to determine bullish or bearish divergence.

[b]4. Distance-to-Extreme Scoring[/b]

Reversal evidence becomes more meaningful when price is still close to a recent extreme.

The confluence engine therefore includes distance-based scoring relative to a configurable lookback.

[b]5. Projection and Confluence Zones[/b]

Completed higher-timeframe candles can be projected forward on the execution chart, while divergence events can create local confluence zones when the evidence stack is strong enough.

[image]https://www.tradingview.com/x/gGlhQz99/[/image]

[b]Features[/b]

[list]
[*][b]Completed HTF candle projection:[/b] prior higher-timeframe range and body projected onto the chart
[*][b]HTF pattern engine:[/b] bullish and bearish engulfing and pin-bar style patterns
[*][b]Confirmed RSI divergence:[/b] bullish and bearish divergence using pivot confirmation
[*][b]Dual-pane logic:[/b] overlay objects explain price context while the pane acts as a reversal timing ledger
[*][b]Confluence scoring:[/b] combines HTF pattern, local divergence, and distance-to-extreme logic
[*][b]Premium/discount context:[/b] position of price relative to the HTF midpoint is plotted
[*][b]Confluence zones:[/b] optional chart zones highlight stronger bullish or bearish reversal regions
[*][b]State-based RSI coloring:[/b] RSI line color reflects the current net confluence
[*][b]Top-right dashboard:[/b] summarizes pattern state, divergence state, confluence, and location context
[*][b]Non-repainting design:[/b] no unfinished HTF candles and no unconfirmed pivot divergence
[/list]

[b]Input Parameters[/b]

[b]Higher Timeframe Context[/b]
[list]
[*]HTF Candle Source
[*]Enable Engulfing Patterns
[*]Enable Pin Bar Patterns
[*]Project Completed HTF Candle
[*]Projection Offset Bars
[*]Projection Width Bars
[/list]

[b]Execution Divergence[/b]
[list]
[*]RSI Length
[*]Pivot Left
[*]Pivot Right
[*]Show Divergence Lines
[*]Show Confluence Zones
[/list]

[b]Confluence Engine[/b]
[list]
[*]Distance Lookback
[*]Distance Weight
[*]Pattern Weight
[*]Divergence Weight
[/list]

[b]Display[/b]
[list]
[*]Show RSI State Fill
[*]Dashboard Position
[*]Dashboard Size
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Start With the Higher-Timeframe Projection[/b]

Use the projected completed candle to understand whether the larger reference bar is signaling rejection, acceptance, or neutrality.

[b]Step 2: Wait for Local Divergence Confirmation[/b]

The script intentionally waits for confirmed pivots.

That delay is a feature, not a flaw.

[b]Step 3: Read the Net Confluence, Not Just RSI[/b]

The pane is not meant to be treated like a normal RSI oscillator.

Its color and context matter because they reflect the broader reversal evidence stack.

[b]Step 4: Use Confluence Zones as Areas of Interest[/b]

Zones identify places where the higher-timeframe context and local divergence align.

They are not guaranteed turning points.

[b]Step 5: Respect the Directional Imbalance[/b]

If the higher-timeframe candle context is strongly bearish, a minor bullish divergence alone may not be enough to justify a reversal thesis, and vice versa.

[b]Indicator Limitations[/b]

[list]
[*]Confirmed divergence necessarily appears after the pivot forms, which introduces intentional timing delay
[*]Higher-timeframe pattern quality depends on the selected timeframe and instrument behavior
[*]RSI divergence can persist without immediate reversal in strong directional markets
[*]Projection objects are context tools, not price targets
[/list]

[b]Originality Statement[/b]

Harbor Reversal Ledger is designed as a confluence ledger rather than a single-pattern reversal marker.

Its distinguishing structure comes from pairing completed higher-timeframe candle analysis, confirmed divergence, distance scoring, projected context, and pane-based confluence visualization into one disciplined, non-repainting timing framework.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It is not financial advice and should not be used as a standalone reason to enter or exit a market.

All reversal readings are based on historical chart data and can fail, especially in strongly trending or event-driven conditions.

Use proper risk management and independent judgment.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Harbor Reversal Ledger [JOAT]", shorttitle = "HRL[JOAT]", overlay = false, max_labels_count = 500, max_boxes_count = 300, max_lines_count = 500)

//==================================================================================================
// Palette
//==================================================================================================
color REV_BULL   = #14B77D
color REV_BEAR   = #EE6467
color REV_NEUTRAL= #7E8AA0
color REV_GOLD   = #D7B15A
color REV_BLUE   = #72A8FF
color PANEL_BG   = #0F1722
color PANEL_EDGE = #223247
color PANEL_TEXT = #D7DFEA
color PANEL_MUTE = #8090A6

//==================================================================================================
// Inputs
//==================================================================================================
string GROUP_HTF = "Higher Timeframe Context"
string htfInput  = input.timeframe("60", "HTF Candle Source", group = GROUP_HTF)
bool showEngulfingInput = input.bool(true, "Enable Engulfing Patterns", group = GROUP_HTF)
bool showPinBarInput    = input.bool(true, "Enable Pin Bar Patterns", group = GROUP_HTF)
bool showProjectionInput = input.bool(true, "Project Completed HTF Candle", group = GROUP_HTF)
int projectionOffsetInput = input.int(14, "Projection Offset Bars", minval = 5, maxval = 60, group = GROUP_HTF)
int projectionWidthInput  = input.int(6, "Projection Width Bars", minval = 3, maxval = 20, group = GROUP_HTF)

string GROUP_DIVERGENCE = "Execution Divergence"
int rsiLenInput   = input.int(14, "RSI Length", minval = 2, group = GROUP_DIVERGENCE)
int pivotLeftInput = input.int(5, "Pivot Left", minval = 1, group = GROUP_DIVERGENCE)
int pivotRightInput = input.int(5, "Pivot Right", minval = 1, group = GROUP_DIVERGENCE)
bool showRsiLinesInput = input.bool(true, "Show Divergence Lines", group = GROUP_DIVERGENCE)
bool showConfluenceZonesInput = input.bool(true, "Show Confluence Zones", group = GROUP_DIVERGENCE)

string GROUP_SCORING = "Confluence Engine"
int distanceLookbackInput = input.int(55, "Distance Lookback", minval = 10, group = GROUP_SCORING)
float distanceWeightInput = input.float(25.0, "Distance Weight", minval = 0.0, step = 1.0, group = GROUP_SCORING)
float patternWeightInput  = input.float(45.0, "Pattern Weight", minval = 0.0, step = 1.0, group = GROUP_SCORING)
float divergenceWeightInput = input.float(30.0, "Divergence Weight", minval = 0.0, step = 1.0, group = GROUP_SCORING)

string GROUP_DISPLAY = "Display"
bool showPanelFillInput = input.bool(true, "Show RSI State Fill", group = GROUP_DISPLAY)
string dashboardPositionInput = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Bottom Left"], group = GROUP_DISPLAY)
string dashboardSizeInput = input.string("Medium", "Dashboard Size", options = ["Tiny", "Small", "Medium", "Large"], group = GROUP_DISPLAY)

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

f_htf_label(string patternName, int xLoc, float yLoc, color txtColor, bool below) =>
    label.new(xLoc, yLoc, patternName, style = below ? label.style_label_up : label.style_label_down, color = color.new(PANEL_BG, 0), textcolor = txtColor, size = size.small, force_overlay = true)

f_score_to_color(float score) =>
    score >= 0 ? color.from_gradient(math.min(score, 100.0), 0.0, 100.0, REV_NEUTRAL, REV_BULL) : color.from_gradient(math.max(score, -100.0), -100.0, 0.0, REV_BEAR, REV_NEUTRAL)

//==================================================================================================
// Higher Timeframe Request Block
//==================================================================================================
[hOpen, hHigh, hLow, hClose, hPrevOpen, hPrevClose, hTime, hTimeClose] =
     request.security(syminfo.tickerid, htfInput, [open[1], high[1], low[1], close[1], open[2], close[2], time[1], time_close[1]])

bool newCompletedHtf = ta.change(time(htfInput)) != 0
float hRange = math.max(hHigh - hLow, syminfo.mintick)

bool bullEngulfing = showEngulfingInput and hClose > hOpen and hPrevClose < hPrevOpen and hClose >= hPrevOpen and hOpen <= hPrevClose
bool bearEngulfing = showEngulfingInput and hClose < hOpen and hPrevClose > hPrevOpen and hClose <= hPrevOpen and hOpen >= hPrevClose
bool bullPin = showPinBarInput and (math.min(hOpen, hClose) - hLow) > hRange * 0.58 and math.abs(hClose - hOpen) < hRange * 0.28
bool bearPin = showPinBarInput and (hHigh - math.max(hOpen, hClose)) > hRange * 0.58 and math.abs(hClose - hOpen) < hRange * 0.28

bool htfBullPattern = bullEngulfing or bullPin
bool htfBearPattern = bearEngulfing or bearPin
float htfBias = htfBullPattern ? 100.0 : htfBearPattern ? -100.0 : hClose > hOpen ? 35.0 : hClose < hOpen ? -35.0 : 0.0
float htfMidpoint = (hHigh + hLow) * 0.5
float htfBodyMidpoint = (hOpen + hClose) * 0.5

//==================================================================================================
// Local Divergence Engine
//==================================================================================================
float rsiValue = ta.rsi(close, rsiLenInput)
float rsiPivotHigh = ta.pivothigh(rsiValue, pivotLeftInput, pivotRightInput)
float rsiPivotLow = ta.pivotlow(rsiValue, pivotLeftInput, pivotRightInput)

var float previousPriceLow = na
var float previousRsiLow = na
var int previousLowIndex = na
var float previousPriceHigh = na
var float previousRsiHigh = na
var int previousHighIndex = na

bool bullishDivergence = false
bool bearishDivergence = false

if not na(rsiPivotLow)
    float currentPriceLow = low[pivotRightInput]
    float currentRsiLow = rsiValue[pivotRightInput]
    int currentIndex = bar_index - pivotRightInput
    bullishDivergence := not na(previousPriceLow) and currentPriceLow < previousPriceLow and currentRsiLow > previousRsiLow
    if bullishDivergence and showRsiLinesInput
        line.new(previousLowIndex, previousPriceLow, currentIndex, currentPriceLow, color = REV_BULL, width = 2, force_overlay = true)
        line.new(previousLowIndex, previousRsiLow, currentIndex, currentRsiLow, color = REV_BULL, width = 2)
        label.new(currentIndex, currentPriceLow, "Bullish Divergence", style = label.style_label_up, color = color.new(PANEL_BG, 0), textcolor = REV_BULL, size = size.small, force_overlay = true)
    previousPriceLow := currentPriceLow
    previousRsiLow := currentRsiLow
    previousLowIndex := currentIndex

if not na(rsiPivotHigh)
    float currentPriceHigh = high[pivotRightInput]
    float currentRsiHigh = rsiValue[pivotRightInput]
    int currentIndex = bar_index - pivotRightInput
    bearishDivergence := not na(previousPriceHigh) and currentPriceHigh > previousPriceHigh and currentRsiHigh < previousRsiHigh
    if bearishDivergence and showRsiLinesInput
        line.new(previousHighIndex, previousPriceHigh, currentIndex, currentPriceHigh, color = REV_BEAR, width = 2, force_overlay = true)
        line.new(previousHighIndex, previousRsiHigh, currentIndex, currentRsiHigh, color = REV_BEAR, width = 2)
        label.new(currentIndex, currentPriceHigh, "Bearish Divergence", style = label.style_label_down, color = color.new(PANEL_BG, 0), textcolor = REV_BEAR, size = size.small, force_overlay = true)
    previousPriceHigh := currentPriceHigh
    previousRsiHigh := currentRsiHigh
    previousHighIndex := currentIndex

//==================================================================================================
// Confluence Scoring
//==================================================================================================
float distanceLow = low - ta.lowest(low, distanceLookbackInput)
float distanceHigh = ta.highest(high, distanceLookbackInput) - high
float distanceBullScore = math.max(0.0, 1.0 - distanceLow / math.max(ta.atr(21) * 4.0, syminfo.mintick)) * distanceWeightInput
float distanceBearScore = math.max(0.0, 1.0 - distanceHigh / math.max(ta.atr(21) * 4.0, syminfo.mintick)) * distanceWeightInput

float bullishConfluence = (htfBullPattern ? patternWeightInput : 0.0) + (bullishDivergence ? divergenceWeightInput : 0.0) + distanceBullScore
float bearishConfluence = (htfBearPattern ? patternWeightInput : 0.0) + (bearishDivergence ? divergenceWeightInput : 0.0) + distanceBearScore
float netConfluence = bullishConfluence - bearishConfluence
float localPremiumDiscount = ((close - htfMidpoint) / math.max(hRange, syminfo.mintick)) * 100.0

//==================================================================================================
// Projection Objects
//==================================================================================================
var box projectedBody = na
var box projectedRange = na
var line projectedWick = na
var label projectedTag = na
var box bullishZone = na
var box bearishZone = na
var line midpointLine = na
var line bodyMidpointLine = na

if barstate.islast and showProjectionInput and not na(hOpen)
    int leftEdge = last_bar_index + projectionOffsetInput
    int rightEdge = leftEdge + projectionWidthInput
    int midEdge = math.round((leftEdge + rightEdge) * 0.5)
    color candleColor = hClose >= hOpen ? REV_BULL : REV_BEAR

    if not na(projectedRange)
        box.delete(projectedRange)
    if not na(projectedBody)
        box.delete(projectedBody)
    if not na(projectedWick)
        line.delete(projectedWick)
    if not na(projectedTag)
        label.delete(projectedTag)
    if not na(midpointLine)
        line.delete(midpointLine)
    if not na(bodyMidpointLine)
        line.delete(bodyMidpointLine)

    projectedRange := box.new(leftEdge, hHigh, rightEdge, hLow, bgcolor = color.new(candleColor, 92), border_color = color.new(candleColor, 72), force_overlay = true)
    projectedBody := box.new(leftEdge, math.max(hOpen, hClose), rightEdge, math.min(hOpen, hClose), bgcolor = color.new(candleColor, 55), border_color = color.new(candleColor, 25), force_overlay = true)
    projectedWick := line.new(midEdge, hHigh, midEdge, hLow, color = color.new(candleColor, 10), width = 2, force_overlay = true)
    projectedTag := label.new(midEdge, hHigh, str.upper(htfInput) + " Completed Candle", style = label.style_label_down, color = color.new(PANEL_BG, 0), textcolor = candleColor, size = size.small, force_overlay = true)
    midpointLine := line.new(leftEdge, htfMidpoint, rightEdge, htfMidpoint, color = color.new(REV_BLUE, 35), style = line.style_dashed, width = 1, force_overlay = true)
    bodyMidpointLine := line.new(leftEdge, htfBodyMidpoint, rightEdge, htfBodyMidpoint, color = color.new(REV_GOLD, 25), style = line.style_dotted, width = 1, force_overlay = true)

//==================================================================================================
// Confluence Zones
//==================================================================================================
if showConfluenceZonesInput
    if bullishDivergence and bullishConfluence >= bearishConfluence
        if not na(bullishZone)
            box.delete(bullishZone)
        bullishZone := box.new(bar_index - pivotRightInput, low[pivotRightInput] + ta.atr(21) * 0.4, bar_index + 8, low[pivotRightInput] - ta.atr(21) * 0.25, bgcolor = color.new(REV_BULL, 88), border_color = color.new(REV_BULL, 55), force_overlay = true)
    if bearishDivergence and bearishConfluence >= bullishConfluence
        if not na(bearishZone)
            box.delete(bearishZone)
        bearishZone := box.new(bar_index - pivotRightInput, high[pivotRightInput] + ta.atr(21) * 0.25, bar_index + 8, high[pivotRightInput] - ta.atr(21) * 0.4, bgcolor = color.new(REV_BEAR, 88), border_color = color.new(REV_BEAR, 55), force_overlay = true)

//==================================================================================================
// HTF Pattern Labels
//==================================================================================================
if newCompletedHtf and htfBullPattern
    f_htf_label(bullEngulfing ? "HTF Bull Engulfing" : "HTF Bull Pin", bar_index, low, REV_BULL, true)

if newCompletedHtf and htfBearPattern
    f_htf_label(bearEngulfing ? "HTF Bear Engulfing" : "HTF Bear Pin", bar_index, high, REV_BEAR, false)

//==================================================================================================
// RSI Panel
//==================================================================================================
// The RSI panel functions as the timing ledger. The plotted value is familiar, but the color and
// fill are driven by confluence so traders can see when reversal evidence is strengthening.
plotRsi = plot(rsiValue, "RSI", color = f_score_to_color(netConfluence), linewidth = 2)
plotMid = plot(50, "Mid", color = color.new(REV_NEUTRAL, 70), linewidth = 1)
plotOB = plot(70, "OB", color = color.new(REV_BEAR, 75), linewidth = 1)
plotOS = plot(30, "OS", color = color.new(REV_BULL, 75), linewidth = 1)
fill(plotRsi, plotMid, color = showPanelFillInput ? color.new(netConfluence >= 0 ? REV_BULL : REV_BEAR, 90) : na, title = "RSI State Fill")
plot(localPremiumDiscount, "Premium Discount Position", color = color.new(REV_BLUE, 40), linewidth = 1)

//==================================================================================================
// Dashboard
//==================================================================================================
var table dash = table.new(f_panel_position(dashboardPositionInput), 2, 8, bgcolor = PANEL_BG, frame_color = PANEL_EDGE, frame_width = 1)
var dashSize = f_panel_size(dashboardSizeInput)

f_dash_cell(int c, int r, string txt, color txtColor, color bgColor, alignMode) =>
    table.cell(dash, c, r, txt, text_color = txtColor, bgcolor = bgColor, text_halign = alignMode, text_size = dashSize)

if barstate.islast
    f_dash_cell(0, 0, "Harbor Reversal Ledger", PANEL_TEXT, PANEL_EDGE, text.align_left)
    f_dash_cell(1, 0, "HRL", PANEL_TEXT, PANEL_EDGE, text.align_right)

    string patternText = htfBullPattern ? "Bullish HTF Pattern" : htfBearPattern ? "Bearish HTF Pattern" : "No HTF Trigger"
    f_dash_cell(0, 1, "HTF Pattern", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 1, patternText, htfBullPattern ? REV_BULL : htfBearPattern ? REV_BEAR : PANEL_TEXT, PANEL_BG, text.align_right)

    f_dash_cell(0, 2, "RSI", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 2, str.tostring(rsiValue, "#.0"), rsiValue >= 50 ? REV_BULL : REV_BEAR, PANEL_BG, text.align_right)

    string divergenceText = bullishDivergence ? "Bullish Divergence" : bearishDivergence ? "Bearish Divergence" : "Stable"
    f_dash_cell(0, 3, "Divergence", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 3, divergenceText, bullishDivergence ? REV_BULL : bearishDivergence ? REV_BEAR : PANEL_TEXT, PANEL_BG, text.align_right)

    f_dash_cell(0, 4, "Bull Score", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 4, str.tostring(bullishConfluence, "#.0"), REV_BULL, PANEL_BG, text.align_right)

    f_dash_cell(0, 5, "Bear Score", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 5, str.tostring(bearishConfluence, "#.0"), REV_BEAR, PANEL_BG, text.align_right)

    f_dash_cell(0, 6, "Net Score", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 6, str.tostring(netConfluence, "#.0"), f_score_to_color(netConfluence), PANEL_BG, text.align_right)

    string htfState = htfBias > 0 ? "Bullish Context" : htfBias < 0 ? "Bearish Context" : "Balanced"
    f_dash_cell(0, 7, "HTF Context", PANEL_MUTE, PANEL_BG, text.align_left)
    f_dash_cell(1, 7, htfState, htfBias > 0 ? REV_BULL : htfBias < 0 ? REV_BEAR : PANEL_TEXT, PANEL_BG, text.align_right)

//==================================================================================================
// Alerts
//==================================================================================================
alertcondition(newCompletedHtf and htfBullPattern, "HTF Bullish Pattern", "Harbor Reversal Ledger [JOAT] confirmed a bullish higher-timeframe reversal pattern.")
alertcondition(newCompletedHtf and htfBearPattern, "HTF Bearish Pattern", "Harbor Reversal Ledger [JOAT] confirmed a bearish higher-timeframe reversal pattern.")
alertcondition(bullishDivergence, "Bullish Divergence", "Harbor Reversal Ledger [JOAT] confirmed bullish RSI divergence.")
alertcondition(bearishDivergence, "Bearish Divergence", "Harbor Reversal Ledger [JOAT] confirmed bearish RSI divergence.")
````
