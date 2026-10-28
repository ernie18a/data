# Pymander's EZ Regime Filter

- url: https://www.tradingview.com/script/81OAiRqA-Pymander-s-EZ-Regime-Filter/
- type: indicator
- pine_id: PUB;9838b2835fda4bb7af42bc70af129b17
- version: 1.0

## Description

Pymander's EZ Regime Filter—your new best friend for staying on the right side of the market without overthinking it!

We all know the feeling of getting "chopped up" in a sideways market or entering a trade only to realize you're fighting a massive trend on the higher timeframes. This tool is designed to fix exactly that. Here’s the breakdown of how it helps you find those "sweet spot" setups:

The "EZ" Engine: It uses a Zero-Lag EMA paired with a volatility filter. This means it stays glued to the price action but filters out the random noise that usually triggers fakeouts.
Total Alignment: The script looks at 5 different timeframes simultaneously and gives you a weighted "Regime Score." If the higher timeframes are bearish but your chart looks bullish, the filter stays neutral to keep you out of trouble.
Visual Clarity: With the built-in EMA Cloud (50/200) and the real-time MTF Dashboard, you can see the market's health at a single glance. No more clicking through every tab to see what the 1-hour or Daily charts are doing.
Smart Signals: When the price, the volatility bands, and the multi-timeframe score all line up, you get an "EZ" signal on your chart. It's all about trading with the wind at your back!
We’d love to hear how this fits into your strategy! Grab it, play around with the settings, and give us your feedback so we can keep making it better.

Wishing you the best of luck on the charts and many green trades ahead!
-Pymander

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Pymander's EZ Regime Filter", shorttitle="EZ Regime Filter", overlay = true)

// --- Constants ---
color BULL_COLOR      = #089981
color BEAR_COLOR      = #f23645
color NEUTRAL_COLOR   = #787b86

// --- Inputs ---
// Core Logic
length       = input.int(34, "Regime Sensitivity", minval = 1, tooltip = "Lower values increase sensitivity. Optimized at 34 for 3-5m charts.", group = "Main Calculations")
mult         = input.float(1.0, "Volatility Filter", minval = 0, step = 0.1, tooltip = "Controls the 'deadzone' around the MA. Lower values react faster to breakouts.", group = "Main Calculations")

// Visibility Settings
showCloud    = input.bool(true, "Show EMA Cloud", group = "Visibility Settings")
emaFastLen   = input.int(50, "Cloud Fast Length", minval = 1, group = "Visibility Settings", inline = "Cloud")
emaSlowLen   = input.int(200, "Cloud Slow Length", minval = 1, group = "Visibility Settings", inline = "Cloud")
showDash     = input.bool(true, "Show MTF Dashboard", group = "Visibility Settings")

// MTF Settings
t1           = input.timeframe("5", "Time frame 1", group = "Multi-Timeframe Regime")
t2           = input.timeframe("15", "Time frame 2", group = "Multi-Timeframe Regime")
t3           = input.timeframe("60", "Time frame 3", group = "Multi-Timeframe Regime")
t4           = input.timeframe("240", "Time frame 4", group = "Multi-Timeframe Regime")
t5           = input.timeframe("1D", "Time frame 5", group = "Multi-Timeframe Regime")

// Style Settings
bullColor    = input.color(BULL_COLOR, "Bullish Color", group = "Style")
bearColor    = input.color(BEAR_COLOR, "Bearish Color", group = "Style")
neutralColor = input.color(NEUTRAL_COLOR, "Neutral Color", group = "Style")

// --- Calculations ---
// Zero Lag EMA Logic
calcZlema(float src, int len) =>
    int lag = math.floor((len - 1) / 2)
    ta.ema(src + (src - src[lag]), len)

// Encapsulate trend logic for MTF requests
calcRegime() =>
    float z = calcZlema(close, length)
    float v = ta.highest(ta.atr(length), math.floor(length * 1.5)) * mult
    var int trend = 0
    trend := ta.crossover(close, z + v) ? 1 : ta.crossunder(close, z - v) ? -1 : trend
    [z, v, trend]

[zlema, volatility, localTrend] = calcRegime()

// Request MTF Trends
getTrend(string tf) => request.security(syminfo.tickerid, tf, calcRegime(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

[_, _, s1] = getTrend(t1)
[_, _, s2] = getTrend(t2)
[_, _, s3] = getTrend(t3)
[_, _, s4] = getTrend(t4)
[_, _, s5] = getTrend(t5)

// --- Weighted Aggregate Trend Score ---
float weightedScore = (localTrend * 1.0) + (s1 * 1.0) + (s2 * 2.0) + (s3 * 3.0) + (s4 * 4.0) + (s5 * 5.0)

// Final Regime Condition
bool isBullish = close > zlema and weightedScore > 0
bool isBearish = close < zlema and weightedScore < 0
color regimeColor = isBullish ? bullColor : isBearish ? bearColor : neutralColor

// --- EMA Cloud Logic ---
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
color cloudBaseColor = emaFast > emaSlow ? bullColor : bearColor

// --- Visuals ---
// 1. EMA Cloud
ec1 = plot(showCloud ? emaFast : na, "Cloud Fast EMA", color = color.new(cloudBaseColor, 50))
ec2 = plot(showCloud ? emaSlow : na, "Cloud Slow EMA", color = color.new(cloudBaseColor, 50))
fill(ec1, ec2, color.new(cloudBaseColor, 85), "EMA Cloud Fill")

// 2. Main Regime Line
plot(zlema, "EZ Regime Line", color = regimeColor, linewidth = 3)

// 3. Breakout Icons
plotshape(ta.crossover(close, zlema) and isBullish, "Bullish Alignment", shape.triangleup, location.belowbar, bullColor, size = size.small, text = "EZ", textcolor = bullColor)
plotshape(ta.crossunder(close, zlema) and isBearish, "Bearish Alignment", shape.triangledown, location.abovebar, bearColor, size = size.small, text = "EZ", textcolor = bearColor)

// --- Dashboard ---
f_setCell(table tbl, int row, string tf, int val) =>
    color c = val == 1 ? bullColor : val == -1 ? bearColor : neutralColor
    string t = val == 1 ? "BULL" : val == -1 ? "BEAR" : "WAIT"
    table.cell(tbl, 0, row, tf, text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, row, t, bgcolor = color.new(c, 80), text_color = chart.fg_color, text_size = size.small, text_halign = text.align_center)

var table regimeTable = table.new(position.top_right, 2, 7, bgcolor = #151924, border_width = 1, border_color = #363a45)

if barstate.islast
    if showDash
        table.cell(regimeTable, 0, 0, "TIMEFRAME", text_color = #787b86, text_size = size.tiny, text_halign = text.align_left)
        table.cell(regimeTable, 1, 0, "STATUS",    text_color = #787b86, text_size = size.tiny, text_halign = text.align_center)
        f_setCell(regimeTable, 1, "CHART", localTrend)
        f_setCell(regimeTable, 2, t1, s1)
        f_setCell(regimeTable, 3, t2, s2)
        f_setCell(regimeTable, 4, t3, s3)
        f_setCell(regimeTable, 5, t4, s4)
        f_setCell(regimeTable, 6, t5, s5)
    else
        table.clear(regimeTable, 0, 0, 1, 6)

// --- Alerts ---
alertcondition(ta.crossover(weightedScore, 0), "Regime Turned Bullish", "Weighted MTF regime is now positive")
alertcondition(ta.crossunder(weightedScore, 0), "Regime Turned Bearish", "Weighted MTF regime is now negative")
alertcondition(ta.crossover(close, zlema) and isBullish, "Bullish Alignment Signal", "Price broke above MA with positive MTF regime")
alertcondition(ta.crossunder(close, zlema) and isBearish, "Bearish Alignment Signal", "Price broke below MA with negative MTF regime")
````
