# GFX Multi Timeframe Dashboard

- url: https://www.tradingview.com/script/Sb9VwzT9-GFX-Multi-Timeframe-Dashboard/
- type: indicator
- pine_id: PUB;422c7d95cd9943978f1f7ee78136a24c
- version: 1.0

## Description

This indicator is designed to provide a clear and structured view of market direction across multiple timeframes using key exponential moving averages (EMAs).

The dashboard simplifies decision-making by aligning higher timeframe bias with lower timeframe execution, helping traders stay consistent with trend direction and avoid low-probability setups.

Key Features:

-Multi-timeframe trend overview in one clean dashboard
-Three EMA-based directional bias for accurate trend identification
-Real-time updates for faster decision-making
-Helps filter trades based on higher timeframe confluence
-Clean and minimal design for distraction-free trading

This tool is ideal for traders who focus on precision, discipline, and trading with confirmation rather than guessing market direction.

Use it as a confluence tool alongside your strategy to improve consistency and confidence in your trades.

## Source Code

````pine
//@version=5
indicator("GFX Multi Timeframe Dashboard", shorttitle="Matrix MTF | GÖKTUĞ", overlay=true, max_labels_count=100)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════════════════════════════════════
groupCore = "1. Core Settings"
groupTF   = "2. Timeframes"
groupDash = "3. Dashboard"
groupAlrt = "4. Alerts"

fastLen  = input.int(20, "Fast EMA Length", minval=1, group=groupCore)
slowLen  = input.int(50, "Slow EMA Length", minval=2, group=groupCore)
trendLen = input.int(200, "Trend EMA Length", minval=10, group=groupCore)

tf1 = input.timeframe("15", "Timeframe 1", group=groupTF)
tf2 = input.timeframe("60", "Timeframe 2", group=groupTF)
tf3 = input.timeframe("240", "Timeframe 3", group=groupTF)
tf4 = input.timeframe("D", "Timeframe 4", group=groupTF)

showDashboard = input.bool(true, "Show Dashboard", group=groupDash)
dashboardPos  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)

enableBiasShiftAlerts = input.bool(true, "Enable Bias Shift Alerts", group=groupAlrt)

//══════════════════════════════════════════════════════════════════════════════
// COLORS
//══════════════════════════════════════════════════════════════════════════════
bullColor    = #10b981
bearColor    = #ef4444
neutralColor = #9ca3af
panelBg      = color.new(color.black, 15)

//══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
//══════════════════════════════════════════════════════════════════════════════
BULL = 1
BEAR = -1
NEUTRAL = 0

//══════════════════════════════════════════════════════════════════════════════
// HELPERS
//══════════════════════════════════════════════════════════════════════════════
f_dash_pos(_pos) =>
    _pos == "Top Left" ? position.top_left : _pos == "Bottom Right" ? position.bottom_right : _pos == "Bottom Left" ? position.bottom_left : position.top_right

f_bias_text(_bias) =>
    _bias == BULL ? "Bullish" : _bias == BEAR ? "Bearish" : "Neutral"

f_bias_color(_bias) =>
    _bias == BULL ? bullColor : _bias == BEAR ? bearColor : neutralColor

f_strength_text(_score) =>
    _score >= 4 ? "Very Strong" : _score == 3 ? "Strong" : _score == 2 ? "Balanced" : _score == 1 ? "Weak" : "Very Weak"

//══════════════════════════════════════════════════════════════════════════════
// CURRENT CHART TREND
//══════════════════════════════════════════════════════════════════════════════
fastEMA  = ta.ema(close, fastLen)
slowEMA  = ta.ema(close, slowLen)
trendEMA = ta.ema(close, trendLen)

chartBull = fastEMA > slowEMA and close > trendEMA
chartBear = fastEMA < slowEMA and close < trendEMA
chartBias = chartBull ? BULL : chartBear ? BEAR : NEUTRAL

//══════════════════════════════════════════════════════════════════════════════
// MTF FUNCTION
//══════════════════════════════════════════════════════════════════════════════
f_mtf_bias() =>
    _fast = ta.ema(close, fastLen)
    _slow = ta.ema(close, slowLen)
    _trend = ta.ema(close, trendLen)
    _bull = _fast > _slow and close > _trend
    _bear = _fast < _slow and close < _trend
    _bull ? BULL : _bear ? BEAR : NEUTRAL

bias1 = request.security(syminfo.tickerid, tf1, f_mtf_bias())
bias2 = request.security(syminfo.tickerid, tf2, f_mtf_bias())
bias3 = request.security(syminfo.tickerid, tf3, f_mtf_bias())
bias4 = request.security(syminfo.tickerid, tf4, f_mtf_bias())

//══════════════════════════════════════════════════════════════════════════════
// ALIGNMENT SCORE
//══════════════════════════════════════════════════════════════════════════════
bullCount = (bias1 == BULL ? 1 : 0) + (bias2 == BULL ? 1 : 0) + (bias3 == BULL ? 1 : 0) + (bias4 == BULL ? 1 : 0)
bearCount = (bias1 == BEAR ? 1 : 0) + (bias2 == BEAR ? 1 : 0) + (bias3 == BEAR ? 1 : 0) + (bias4 == BEAR ? 1 : 0)

alignmentBias = bullCount > bearCount ? BULL : bearCount > bullCount ? BEAR : NEUTRAL
alignmentScore = math.max(bullCount, bearCount)
alignmentText = f_strength_text(alignmentScore)

//══════════════════════════════════════════════════════════════════════════════
// ALERT STATES
//══════════════════════════════════════════════════════════════════════════════
tf1BullShift = bias1 == BULL and bias1[1] != BULL
tf1BearShift = bias1 == BEAR and bias1[1] != BEAR

tf2BullShift = bias2 == BULL and bias2[1] != BULL
tf2BearShift = bias2 == BEAR and bias2[1] != BEAR

tf3BullShift = bias3 == BULL and bias3[1] != BULL
tf3BearShift = bias3 == BEAR and bias3[1] != BEAR

tf4BullShift = bias4 == BULL and bias4[1] != BULL
tf4BearShift = bias4 == BEAR and bias4[1] != BEAR

//══════════════════════════════════════════════════════════════════════════════
// VISUAL GUIDE
//══════════════════════════════════════════════════════════════════════════════
plot(fastEMA, "Fast EMA", color=color.new(bullColor, 0), linewidth=2)
plot(slowEMA, "Slow EMA", color=color.new(color.white, 40), linewidth=2)
plot(trendEMA, "Trend EMA", color=color.new(#3b82f6, 0), linewidth=2)

bgcolor(chartBias == BULL ? color.new(bullColor, 94) : chartBias == BEAR ? color.new(bearColor, 94) : na)

//══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
//══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 8, border_width=1)

if barstate.islast
    table.set_position(dash, f_dash_pos(dashboardPos))

    if showDashboard
        table.cell(dash, 0, 0, "Matrix Trading Lab", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(dash, 1, 0, "MTF Dashboard", text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(dash, 0, 1, "Chart Bias", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 1, f_bias_text(chartBias), text_color=f_bias_color(chartBias), bgcolor=panelBg)

        table.cell(dash, 0, 2, tf1 + " Bias", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 2, f_bias_text(bias1), text_color=f_bias_color(bias1), bgcolor=panelBg)

        table.cell(dash, 0, 3, tf2 + " Bias", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 3, f_bias_text(bias2), text_color=f_bias_color(bias2), bgcolor=panelBg)

        table.cell(dash, 0, 4, tf3 + " Bias", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 4, f_bias_text(bias3), text_color=f_bias_color(bias3), bgcolor=panelBg)

        table.cell(dash, 0, 5, tf4 + " Bias", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 5, f_bias_text(bias4), text_color=f_bias_color(bias4), bgcolor=panelBg)

        table.cell(dash, 0, 6, "Alignment", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 6, f_bias_text(alignmentBias), text_color=f_bias_color(alignmentBias), bgcolor=panelBg)

        table.cell(dash, 0, 7, "Strength", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 7, alignmentText, text_color=color.white, bgcolor=panelBg)
    else
        for r = 0 to 7
            table.cell(dash, 0, r, "", bgcolor=color.new(color.black, 100))
            table.cell(dash, 1, r, "", bgcolor=color.new(color.black, 100))

//══════════════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════════════
alertcondition(enableBiasShiftAlerts and tf1BullShift, "TF1 Bullish Shift", "Matrix MTF Dashboard: TF1 turned bullish")
alertcondition(enableBiasShiftAlerts and tf1BearShift, "TF1 Bearish Shift", "Matrix MTF Dashboard: TF1 turned bearish")

alertcondition(enableBiasShiftAlerts and tf2BullShift, "TF2 Bullish Shift", "Matrix MTF Dashboard: TF2 turned bullish")
alertcondition(enableBiasShiftAlerts and tf2BearShift, "TF2 Bearish Shift", "Matrix MTF Dashboard: TF2 turned bearish")

alertcondition(enableBiasShiftAlerts and tf3BullShift, "TF3 Bullish Shift", "Matrix MTF Dashboard: TF3 turned bullish")
alertcondition(enableBiasShiftAlerts and tf3BearShift, "TF3 Bearish Shift", "Matrix MTF Dashboard: TF3 turned bearish")

alertcondition(enableBiasShiftAlerts and tf4BullShift, "TF4 Bullish Shift", "Matrix MTF Dashboard: TF4 turned bullish")
alertcondition(enableBiasShiftAlerts and tf4BearShift, "TF4 Bearish Shift", "Matrix MTF Dashboard: TF4 turned bearish")
````
