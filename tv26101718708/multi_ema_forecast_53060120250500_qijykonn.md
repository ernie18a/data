# Multi EMA + Forecast (5,30,60,120,250,500)

- url: https://www.tradingview.com/script/qijYKonN-Multi-EMA-Forecast-5-30-60-120-250-500/
- type: indicator
- pine_id: PUB;b91518456f8d495ca65180299d5f27f4
- version: 1.0

## Description

Multi-Timeframe (MTF) EMA Group
Overview
The Multi-Timeframe (MTF) EMA Group is a powerful trend-following indicator designed to give traders a clearer perspective on market direction by projecting higher-timeframe data onto their current chart. By combining a cluster of Exponential Moving Averages (EMAs) with Multi-Timeframe capabilities, this tool helps you filter out market noise and align your entries with the macro trend.

Whether you are a scalper looking for higher-timeframe context or a swing trader managing dynamic support and resistance, this indicator provides a clean, customizable visual ribbon to guide your bias.

Key Features
Multi-Timeframe (MTF) Selection: Plot EMAs from any timeframe (e.g., 1-Hour, 4-Hour, Daily) onto your current working chart (e.g., 5-Minute, 15-Minute).

Customizable EMA Cluster: Includes multiple EMA inputs (e.g., 5, 9, 20, 50, 100, 200) allowing you to build a dense "ribbon" or a simple two-line crossover system.

Trend Visualizer: When the shorter EMAs are stacked above the longer EMAs, the ribbon indicates a bullish trend. When the order is reversed, it indicates a bearish trend. The widening of the group signifies trend strength, while a pinching or twisting group warns of consolidation or a potential reversal.

Non-Repainting MTF Data: Built using standard TradingView MTF protocols to ensure the data is accurate and does not repaint once the higher timeframe candle closes.

How to Use It in Your Trading
Trend Alignment: Avoid trading against the dominant trend. For example, if you are trading on a 15-minute chart, set the indicator's timeframe to 1-Hour or 4-Hour. Only take long setups when the price is above the higher-timeframe EMA group, and short setups when it is below.

Dynamic Support & Resistance: A tightly clustered group of EMAs often acts as a strong zone of dynamic support in an uptrend or resistance in a downtrend. Look for price to pull back into the EMA "value area" for optimal trade entries.

Crossovers & Reversals: Watch for the shortest EMA in the group to cross through the longer EMAs as an early warning sign that the macro trend might be shifting.

Customization Options
Resolution/Timeframe: Easily toggle the timeframe drop-down in the settings to pull data from your desired chart interval.

Lengths: Fully adjustable lengths for every EMA in the group to suit your specific trading style.

Colors & Styling: Customize the thickness and color gradients of the lines to make the ribbon visually intuitive on both dark and light chart themes.

Disclaimer: This indicator is for educational and analytical purposes only. Past performance does not guarantee future results. Always combine moving averages with other forms of technical analysis, such as price action and volume, before making trading decisions.

## Source Code

````pine
//@version=6
indicator('Multi EMA + Forecast (5,30,60,120,250,500)', shorttitle = 'MultiEMA+FC', overlay = true)

// ── Timeframe Selection ──────────────────────────────────────────────────
tf_input = input.timeframe('', 'EMA Timeframe (leave blank = chart tf)', group = 'Timeframe Settings')
string tf = tf_input == '' ? timeframe.period : tf_input

// ── EMA Lengths ──────────────────────────────────────────────────────────
len1 = input.int(5, 'EMA 5 Length', minval = 1, group = 'EMA Settings')
len2 = input.int(30, 'EMA 30 Length', minval = 1, group = 'EMA Settings')
len3 = input.int(60, 'EMA 60 Length', minval = 1, group = 'EMA Settings')
len4 = input.int(120, 'EMA 120 Length', minval = 1, group = 'EMA Settings')
len5 = input.int(250, 'EMA 250 Length', minval = 1, group = 'EMA Settings')
len6 = input.int(500, 'EMA 500 Length', minval = 1, group = 'EMA Settings')

// ── Line Width (controls ALL lines - historical + forecasts) ─────────────
int lineWidth = input.int(1, 'Line Width (all lines)', minval = 1, maxval = 5, group = 'Style Settings')

// ── Historical EMA Colors (editable) ─────────────────────────────────────
color color1 = input.color(color.red, 'EMA 5 Color', group = 'EMA Colors')
color color2 = input.color(color.blue, 'EMA 30 Color', group = 'EMA Colors')
color color3 = input.color(color.aqua, 'EMA 60 Color', group = 'EMA Colors')
color color4 = input.color(color.green, 'EMA 120 Color', group = 'EMA Colors')
color color5 = input.color(color.purple, 'EMA 250 Color', group = 'EMA Colors')
color color6 = input.color(color.new(#0D47A1, 0), 'EMA 500 Color', group = 'EMA Colors')

// ── Transparentcy ─────────────────────────────────────
transp = input.int(50, 'Transparency', group = 'ENA Color')

// ── Forecast Settings ────────────────────────────────────────────────────
barsAhead = input.int(10, 'Forecast bars ahead', minval = 1, maxval = 50, group = 'Forecast Settings')

// ── Forecast Transparency (separate for each) ────────────────────────────
int fcTrans1 = input.int(65, 'EMA5 Forecast Transparency %', minval = 0, maxval = 100, group = 'Forecast Transparency')
int fcTrans2 = input.int(65, 'EMA30 Forecast Transparency %', minval = 0, maxval = 100, group = 'Forecast Transparency')
int fcTrans3 = input.int(65, 'EMA60 Forecast Transparency %', minval = 0, maxval = 100, group = 'Forecast Transparency')
int fcTrans4 = input.int(65, 'EMA120 Forecast Transparency %', minval = 0, maxval = 100, group = 'Forecast Transparency')
int fcTrans5 = input.int(70, 'EMA250 Forecast Transparency %', minval = 0, maxval = 100, group = 'Forecast Transparency')
int fcTrans6 = input.int(75, 'EMA500 Forecast Transparency %', minval = 0, maxval = 100, group = 'Forecast Transparency')

// ── Forecast Colors (matching historical by default) ─────────────────────
color fcColor1 = input.color(color.red, 'EMA5 Forecast Color', group = 'Forecast Colors')
color fcColor2 = input.color(color.blue, 'EMA30 Forecast Color', group = 'Forecast Colors')
color fcColor3 = input.color(color.aqua, 'EMA60 Forecast Color', group = 'Forecast Colors')
color fcColor4 = input.color(color.green, 'EMA120 Forecast Color', group = 'Forecast Colors')
color fcColor5 = input.color(color.purple, 'EMA250 Forecast Color', group = 'Forecast Colors')
color fcColor6 = input.color(color.new(#0D47A1, 0), 'EMA500 Forecast Color', group = 'Forecast Colors')

// ── Calculate EMAs on selected timeframe ─────────────────────────────────
e1 = request.security(syminfo.tickerid, tf, ta.ema(close, len1), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
e2 = request.security(syminfo.tickerid, tf, ta.ema(close, len2), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
e3 = request.security(syminfo.tickerid, tf, ta.ema(close, len3), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
e4 = request.security(syminfo.tickerid, tf, ta.ema(close, len4), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
e5 = request.security(syminfo.tickerid, tf, ta.ema(close, len5), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
e6 = request.security(syminfo.tickerid, tf, ta.ema(close, len6), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

// ── Plot historical EMAs with shared width ────────────────────────────────
plot(e1, 'EMA 5', color = color1, linewidth = math.max(1, lineWidth))
plot(e2, 'EMA 30', color = color2, linewidth = math.max(1, lineWidth))
plot(e3, 'EMA 60', color = color3, linewidth = math.max(1, lineWidth))
plot(e4, 'EMA 120', color = color4, linewidth = math.max(1, lineWidth))
plot(e5, 'EMA 250', color = color5, linewidth = math.max(1, lineWidth))
plot(e6, 'EMA 500', color = color6, linewidth = math.max(1, lineWidth))

// ── Reusable forecast line arrays ────────────────────────────────────────
var array<line> linesE1 = array.new<line>(barsAhead)
var array<line> linesE2 = array.new<line>(barsAhead)
var array<line> linesE3 = array.new<line>(barsAhead)
var array<line> linesE4 = array.new<line>(barsAhead)
var array<line> linesE5 = array.new<line>(barsAhead)
var array<line> linesE6 = array.new<line>(barsAhead)

// ── Initialize lines once ────────────────────────────────────────────────
if barstate.isfirst
    for i = 0 to barsAhead - 1 by 1
        array.set(linesE1, i, line.new(na, na, na, na))
        array.set(linesE2, i, line.new(na, na, na, na))
        array.set(linesE3, i, line.new(na, na, na, na))
        array.set(linesE4, i, line.new(na, na, na, na))
        array.set(linesE5, i, line.new(na, na, na, na))
        array.set(linesE6, i, line.new(na, na, na, na))

// ── Update forecast on last bar ──────────────────────────────────────────
if barstate.islast
    float lastClose = close
    int currX = bar_index

    // EMA 5 forecast - chained lines
    float prevY1 = e1
    int prevX1 = currX
    float a1 = 2.0 / (len1 + 1)
    for i = 0 to barsAhead - 1 by 1
        float nextY = a1 * lastClose + (1 - a1) * prevY1
        int nextX = prevX1 + 1
        line ln = array.get(linesE1, i)
        line.set_xy1(ln, prevX1, prevY1)
        line.set_xy2(ln, nextX, nextY)
        line.set_color(ln, color.new(fcColor1, fcTrans1))
        line.set_width(ln, lineWidth)
        line.set_style(ln, line.style_dashed)
        prevY1 := nextY
        prevX1 := nextX
        prevX1

    // EMA 30 forecast - chained lines
    float prevY2 = e2
    int prevX2 = currX
    float a2 = 2.0 / (len2 + 1)
    for i = 0 to barsAhead - 1 by 1
        float nextY = a2 * lastClose + (1 - a2) * prevY2
        int nextX = prevX2 + 1
        line ln = array.get(linesE2, i)
        line.set_xy1(ln, prevX2, prevY2)
        line.set_xy2(ln, nextX, nextY)
        line.set_color(ln, color.new(fcColor2, fcTrans2))
        line.set_width(ln, lineWidth)
        line.set_style(ln, line.style_dashed)
        prevY2 := nextY
        prevX2 := nextX
        prevX2

    // EMA 60 forecast - chained lines
    float prevY3 = e3
    int prevX3 = currX
    float a3 = 2.0 / (len3 + 1)
    for i = 0 to barsAhead - 1 by 1
        float nextY = a3 * lastClose + (1 - a3) * prevY3
        int nextX = prevX3 + 1
        line ln = array.get(linesE3, i)
        line.set_xy1(ln, prevX3, prevY3)
        line.set_xy2(ln, nextX, nextY)
        line.set_color(ln, color.new(fcColor3, fcTrans3))
        line.set_width(ln, lineWidth)
        line.set_style(ln, line.style_dashed)
        prevY3 := nextY
        prevX3 := nextX
        prevX3

    // EMA 120 forecast - chained lines
    float prevY4 = e4
    int prevX4 = currX
    float a4 = 2.0 / (len4 + 1)
    for i = 0 to barsAhead - 1 by 1
        float nextY = a4 * lastClose + (1 - a4) * prevY4
        int nextX = prevX4 + 1
        line ln = array.get(linesE4, i)
        line.set_xy1(ln, prevX4, prevY4)
        line.set_xy2(ln, nextX, nextY)
        line.set_color(ln, color.new(fcColor4, fcTrans4))
        line.set_width(ln, lineWidth)
        line.set_style(ln, line.style_dashed)
        prevY4 := nextY
        prevX4 := nextX
        prevX4

    // EMA 250 forecast - chained lines
    float prevY5 = e5
    int prevX5 = currX
    float a5 = 2.0 / (len5 + 1)
    for i = 0 to barsAhead - 1 by 1
        float nextY = a5 * lastClose + (1 - a5) * prevY5
        int nextX = prevX5 + 1
        line ln = array.get(linesE5, i)
        line.set_xy1(ln, prevX5, prevY5)
        line.set_xy2(ln, nextX, nextY)
        line.set_color(ln, color.new(fcColor5, fcTrans5))
        line.set_width(ln, lineWidth)
        line.set_style(ln, line.style_dashed)
        prevY5 := nextY
        prevX5 := nextX
        prevX5

    // EMA 500 forecast - chained lines
    float prevY6 = e6
    int prevX6 = currX
    float a6 = 2.0 / (len6 + 1)
    for i = 0 to barsAhead - 1 by 1
        float nextY = a6 * lastClose + (1 - a6) * prevY6
        int nextX = prevX6 + 1
        line ln = array.get(linesE6, i)
        line.set_xy1(ln, prevX6, prevY6)
        line.set_xy2(ln, nextX, nextY)
        line.set_color(ln, color.new(fcColor6, fcTrans6))
        line.set_width(ln, lineWidth)
        line.set_style(ln, line.style_dashed)
        prevY6 := nextY
        prevX6 := nextX
        prevX6
````
