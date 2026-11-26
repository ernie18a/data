# LTFM_Projection [LanCrypto]

- url: https://www.tradingview.com/script/HBfF4V9G-LTFM-Projection-LanCrypto/
- type: indicator
- pine_id: PUB;434e8132a6c247db8a37e92b4b4ba755
- version: 1.0

## Description

Indicator Description
The LTF Momentum Projection is a multi-timeframe visualization indicator that projects Lower Timeframe (LTF) price action directly onto your current chart. Instead of constantly switching between timeframes, it allows you to see the granular, structural formations happening "inside" or just ahead of the current bar.

Key Features:

LTF Candle Projection: Renders scaled, synthetic LTF candles to the right of the current price action, giving you a real-time microscopic view of recent market movements.
Momentum Shift Signals: Automatically detects a specific 3-candle reversal pattern (a strong thrust, followed by an exhaustion/shrinking candle, and a confirming reversal candle).
Internal & External Detection: Signals are displayed both on the main chart timeframe (External Signals) and on the projected LTF candles (Internal Signals).
HTF Context Levels: Draws the Open, High, and Low of the current chart's candle across the projected area to serve as immediate support/resistance references.
Usage Guide
Setting the Timeframe: In the settings, ensure the "LTF to Display" is set to a timeframe lower than your current chart (e.g., if you are on a 15m chart, set the LTF to 1m or 3m).
Adjusting the View:
Use "Vertical Scale" to stretch or shrink the projected candles if they look too large or small compared to the main chart.
Use the "Right Offset" to push the projection further to the right to avoid overlapping with current price action.
If the projection is too long, enable "Limit Visible Candles" to only see the most recent LTF formations.
Reading the Signals:
Bullish Shift (▲): Indicates a strong bearish push that exhausted, followed by a bullish engulfing/piercing close. Suggests temporary or structural bottoming.
Bearish Shift (▼): Indicates a strong bullish push that exhausted, followed by a bearish reversal close. Suggests a localized top.
Short Strategy Play: "Micro-Shift Pullback"
This indicator is excellent for fine-tuning entries on higher timeframe trends by waiting for a lower timeframe momentum shift.

The Setup:

Determine Trend: Identify the overall trend on the main chart (e.g., 1-Hour chart is making Higher Highs and Higher Lows).
Wait for a Pullback: Wait for price to retrace into a key Higher Timeframe (HTF) support zone, such as an order block, fair value gap, or a moving average.
Zoom in via Projection: Keep your eyes on the LTF projected candles (e.g., 5-Minute data projected on your 1H chart).
Entry Trigger: Enter a trade when an Internal Bullish Signal (▲) prints on the projected LTF candles exactly as it taps the HTF support. This confirms the lower timeframe sellers have exhausted and buyers are stepping back in.
Stop Loss & Take Profit:
Stop Loss: Placed just below the lowest projected LTF candle wick (the recent micro-swing low).
Take Profit: Target the recent HTF swing high, or scale out at the "HTF High" dotted line provided by the indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/


//@version=6
indicator("LTFMProjection [LanCrypto]", "LTFM Projection [LanCrypto]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
// Constants & Inputs
//---------------------------------------------------------------------------------------------------------------------{
color BULL_COLOR    = #089981
color BEAR_COLOR    = #f23645
color NEUTRAL_COLOR = #787b86

string TF_GROUP       = "Timeframe Settings"
string ltfInput       = input.timeframe("1", "LTF to Display", group = TF_GROUP, tooltip = "The lower timeframe candles to project. Must be lower than the chart timeframe.")
int offsetInput       = input.int(5, "Right Offset (Bars)", minval = 1, group = TF_GROUP)

string LIMIT_GROUP    = "Visibility Settings"
bool useLimitInput    = input.bool(false, "Limit Visible Candles", group = LIMIT_GROUP, tooltip = "Check this to only show a specific number of the most recent LTF candles and collapse the view.")
int limitAmountInput  = input.int(10, "Amount to Show", minval = 1, group = LIMIT_GROUP, tooltip = "The number of most recent LTF candles to display.")

string STYLE_GROUP    = "Visual Style"
color bullColorInput  = input.color(BULL_COLOR, "Bullish Color", inline = "colors", group = STYLE_GROUP)
color bearColorInput  = input.color(BEAR_COLOR, "Bearish Color", inline = "colors", group = STYLE_GROUP)
float verticalScale   = input.float(1.0, "Vertical Scale", minval = 0.01, maxval = 100.0, step = 0.1, group = STYLE_GROUP, tooltip = "Stretches or shrinks the projection vertically.")
int candleGapInput    = input.int(1, "Candle Gap", minval = 0, maxval = 10, group = STYLE_GROUP)

string SIGNAL_GROUP   = "Momentum Signals"
bool showExternal     = input.bool(true, "Show External Signals (Main Chart)", group = SIGNAL_GROUP, tooltip = "Show momentum shift signals on the actual chart candles.")
bool showInternal     = input.bool(true, "Show Internal Signals (Projection)", group = SIGNAL_GROUP, tooltip = "Show momentum shift signals on the projected LTF candles.")

bool showHTFLevels    = input.bool(true, "Show HTF OHL Levels", group = STYLE_GROUP)

//---------------------------------------------------------------------------------------------------------------------}
// External Momentum Shift Logic (Main Chart)
//---------------------------------------------------------------------------------------------------------------------{
bodySize = math.abs(close - open)
volAvg   = ta.sma(volume, 20)

// 1. Thrust: Large body, high volume
// 2. Slowing/Exhaustion: Body shrinks significantly relative to the previous thrust
// 3. Confirmed Shift: Opposite color closing beyond the midpoint of the exhaustion candle
bullExtSignal = showExternal and close[2] < open[2] and close[1] < open[1] and bodySize[1] < bodySize[2] * 0.6 and close > open and close > (open[1] + close[1])/2
bearExtSignal = showExternal and close[2] > open[2] and close[1] > open[1] and bodySize[1] < bodySize[2] * 0.6 and close < open and close < (open[1] + close[1])/2

plotshape(bullExtSignal, "External Bull Shift", shape.triangleup, location.belowbar, bullColorInput, size = size.small)
plotshape(bearExtSignal, "External Bear Shift", shape.triangledown, location.abovebar, bearColorInput, size = size.small)

//---------------------------------------------------------------------------------------------------------------------}
// Calculations
//---------------------------------------------------------------------------------------------------------------------{
// 1. Automatic Context: Use the current chart's OHL as the context
hOpen = open
hHigh = high
hLow  = low

// 2. Fetch Lower Timeframe Data
[ltfO, ltfH, ltfL, ltfC] = request.security_lower_tf(syminfo.tickerid, ltfInput, [open, high, low, close])

//---------------------------------------------------------------------------------------------------------------------}
// Visuals (LTF Projection)
//---------------------------------------------------------------------------------------------------------------------{
var uiBodies  = array.new<box>()
var uiWicks   = array.new<line>()
var uiSignals = array.new<label>()
var line htfOLine = na, var line htfHLine = na, var line htfLLine = na
var label htfOLabel = na, var label htfHLabel = na, var label htfLLabel = na

if barstate.islast
    // Cleanup
    if uiBodies.size() > 0
        for b in uiBodies
            b.delete()
        uiBodies.clear()
    if uiWicks.size() > 0
        for w in uiWicks
            w.delete()
        uiWicks.clear()
    if uiSignals.size() > 0
        for s in uiSignals
            s.delete()
        uiSignals.clear()
    
    if not na(htfOLine)
        htfOLine.delete(), htfHLine.delete(), htfLLine.delete()
        htfOLabel.delete(), htfHLabel.delete(), htfLLabel.delete()

    // Render LTF Candles
    int countTotal = array.size(ltfO)
    int startBase  = last_bar_index + offsetInput

    if countTotal > 0 and not na(hOpen)
        // SYNC: Force last LTF candle accuracy
        array.set(ltfC, countTotal - 1, close)
        array.set(ltfH, countTotal - 1, math.max(array.get(ltfH, countTotal - 1), close))
        array.set(ltfL, countTotal - 1, math.min(array.get(ltfL, countTotal - 1), close))

        float sessionMax = array.max(ltfH)
        float sessionMin = array.min(ltfL)

        // Visibility & Collapse Logic
        int startIndex = useLimitInput ? math.max(0, countTotal - limitAmountInput) : 0
        int visibleCount = countTotal - startIndex

        // Internal Momentum Calculation Loop
        for i = startIndex to countTotal - 1
            float rawO = array.get(ltfO, i)
            float rawH = array.get(ltfH, i)
            float rawL = array.get(ltfL, i)
            float rawC = array.get(ltfC, i)

            // Scale centered at hOpen
            float o = hOpen + (rawO - hOpen) * verticalScale
            float h = hOpen + (rawH - hOpen) * verticalScale
            float l = hOpen + (rawL - hOpen) * verticalScale
            float c = hOpen + (rawC - hOpen) * verticalScale
            
            int relIndex = i - startIndex
            int xStart = startBase + relIndex * (2 + candleGapInput)
            int xEnd   = xStart + 2
            int xMid   = (xStart + xEnd) / 2
            
            color bodyColor = rawC >= rawO ? bullColorInput : bearColorInput
            
            // Draw Wick
            uiWicks.push(line.new(xMid, h, xMid, l, color = bodyColor, width = 1))
            
            // Draw Body
            float bT = math.max(o, c)
            float bB = math.min(o, c)
            if bT == bB
                bT += syminfo.mintick
            
            uiBodies.push(box.new(xStart, bT, xEnd, bB, border_color = bodyColor, bgcolor = bodyColor))

            // Internal Momentum Signals
            if showInternal and i > 2
                float b0Size = math.abs(array.get(ltfC, i) - array.get(ltfO, i))
                float b1Size = math.abs(array.get(ltfC, i-1) - array.get(ltfO, i-1))
                float b2Size = math.abs(array.get(ltfC, i-2) - array.get(ltfO, i-2))

                bool isIntBullShift = array.get(ltfC, i-2) < array.get(ltfO, i-2) and 
                                      array.get(ltfC, i-1) < array.get(ltfO, i-1) and
                                      b2Size > 0 and b1Size < b2Size * 0.6 and
                                      rawC > rawO and rawC > (array.get(ltfO, i-1) + array.get(ltfC, i-1))/2
                
                bool isIntBearShift = array.get(ltfC, i-2) > array.get(ltfO, i-2) and 
                                      array.get(ltfC, i-1) > array.get(ltfO, i-1) and
                                      b2Size > 0 and b1Size < b2Size * 0.6 and
                                      rawC < rawO and rawC < (array.get(ltfO, i-1) + array.get(ltfC, i-1))/2
                
                if isIntBullShift
                    uiSignals.push(label.new(xMid, l, "▲", color = #00000000, textcolor = bullColorInput, style = label.style_label_up, size = size.small))
                if isIntBearShift
                    uiSignals.push(label.new(xMid, h, "▼", color = #00000000, textcolor = bearColorInput, style = label.style_label_down, size = size.small))

        // Render HTF OHL Levels
        if showHTFLevels
            float scaledH = hOpen + (sessionMax - hOpen) * verticalScale
            float scaledL = hOpen + (sessionMin - hOpen) * verticalScale
            
            int finalX = startBase + (visibleCount - 1) * (2 + candleGapInput) + 2

            htfOLine := line.new(startBase, hOpen, finalX, hOpen, color = NEUTRAL_COLOR, style = line.style_dashed)
            htfOLabel := label.new(finalX, hOpen, "HTF Open", color = #00000000, textcolor = NEUTRAL_COLOR, style = label.style_label_left, size = size.small)
            
            htfHLine := line.new(startBase, scaledH, finalX, scaledH, color = bullColorInput, style = line.style_dotted)
            htfHLabel := label.new(finalX, scaledH, "HTF High", color = #00000000, textcolor = bullColorInput, style = label.style_label_left, size = size.small)
            
            htfLLine := line.new(startBase, scaledL, finalX, scaledL, color = bearColorInput, style = line.style_dotted)
            htfLLabel := label.new(finalX, scaledL, "HTF Low", color = #00000000, textcolor = bearColorInput, style = label.style_label_left, size = size.small)

//---------------------------------------------------------------------------------------------------------------------}
````
