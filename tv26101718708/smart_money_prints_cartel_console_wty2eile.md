# Smart Money Prints [Cartel Console]

- url: https://www.tradingview.com/script/WtY2EILe-Smart-Money-Prints-Cartel-Console/
- type: indicator
- pine_id: PUB;7438f8e6a44d405c9f68f85f3fc7eea4
- version: 1.0

## Description

The Smart Money Prints [Cartel Console] is a volume-based oscillator designed to analyze market sentiment by comparing "informed" and "uninformed" volume flows. By utilizing modified versions of the Positive Volume Index (PVI) and Negative Volume Index (NVI), this tool helps traders identify where volume interest lies relative to price action.

 How it Works:
1. Volume Segmentation: The script calculates PVI (tracking price action on high-volume bars) and NVI (tracking price action on low-volume bars). Theoretically, NVI often represents "informed" positioning during quiet periods, while PVI can represent "uninformed" or retail activity during high-volatility spikes.
2. Normalization: These indices are processed through an RSI-based calculation and normalized to a scale of -100 to 100, allowing for consistent overbought and oversold analysis across different assets.
3. Market Structure Shifts (MSS): The indicator includes a built-in structure detection logic. It identifies swing highs and lows and plots "MSS" labels when a structural break occurs, provided the volume sentiment (Net Index) aligns with the direction of the break.

### Visual Modes:
- Net Mode: Displays a central histogram showing the net difference between buy and sell volume interest. 
- Compare Mode: Overlays two separate lines to visualize the independent trajectories of buying vs. selling pressure.

 Key Settings:
- Index Period: Adjusts the summation lookback for volume interest.
- MSS Swing Length: Controls the sensitivity of the market structure detection.
- Normalization Period: Sets the lookback for the peak value calculation to keep the oscillator scaled.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CartelConsole

//@version=6
indicator("Smart Money Prints [Cartel Console]", shorttitle = "Smart money Prints", overlay = false, explicit_plot_zorder = true, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mode        = input.string("Net", "Display Mode", options = ["Compare", "Net"], group = "Settings", tooltip = "Choose between comparing Buy/Sell interest or viewing the Net value.")
x           = input.int(25, "Index Period", minval = 1, group = "Settings", tooltip = "The period used for the summation of volume interest.")
rr          = input.int(14, "Volume Flow Period", minval = 1, group = "Settings", tooltip = "The RSI period applied to the volume indices.")
peakslen    = input.int(500, "Normalization Period", minval = 1, group = "Settings", tooltip = "The lookback period used to find the highest value for normalization.")
mssLen      = input.int(9, "MSS Swing Length", minval = 2, group = "MSS", tooltip = "The length used to detect swing highs and lows for Market Structure Shifts.")

bullColor   = input.color(#ffe600, "Bullish Color", group = "Colors", tooltip = "Color for bullish signals and histogram bars.")
bearColor   = input.color(color.rgb(2, 52, 189), "Bearish Color", group = "Colors", tooltip = "Color for bearish signals and histogram bars.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SMART MONEY FORMULA (PVI / NVI)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Manual calculation of PVI and NVI as they are not built-in variables in Pine Script v6
var float pvi = 100.0
var float nvi = 100.0

if not na(volume) and not na(volume[1])
    pvi := volume > volume[1] ? pvi + ((close - close[1]) / close[1]) * pvi : pvi
    nvi := volume < volume[1] ? nvi + ((close - close[1]) / close[1]) * nvi : nvi

// Logic for calculating the index based on PVI (Informed) and NVI (Uninformed)
informedIndex   = nvi - ta.ema(nvi, 255)
uninformedIndex = pvi - ta.ema(pvi, 255)

drsi = ta.rsi(uninformedIndex, rr)
srsi = ta.rsi(informedIndex, rr)

r_buy  = srsi / drsi
r_sell = (100 - srsi) / (100 - drsi)

sums_buy  = math.sum(r_buy, x)
sums_sell = math.sum(r_sell, x)

peak = ta.highest(math.max(sums_buy, sums_sell), peakslen)

index_buy  = sums_buy / peak
index_sell = sums_sell / peak

net_index = index_buy - index_sell

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCALE TO 100
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
scaled_net = net_index * 100

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OB/OS VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
zeroLine = plot(0, "Zero Line", color = color.gray)

top  = plot(100, "Top Limit", display = display.none)
low_ = plot(-100, "Bottom Limit", display = display.none)

thresh_up1 = plot(20, "Threshold Up 1", display = display.none)
thresh_up2 = plot(60, "Threshold Up 2", display = display.none)
thresh_up3 = plot(100, "Threshold Up 3", display = display.none)

thresh_down1 = plot(-20, "Threshold Down 1", display = display.none)
thresh_down2 = plot(-60, "Threshold Down 2", display = display.none)
thresh_down3 = plot(-100, "Threshold Down 3", display = display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
top_active1 = scaled_net > 20
top_active2 = scaled_net > 60
top_active3 = scaled_net > 100

bot_active1 = scaled_net < -20
bot_active2 = scaled_net < -60
bot_active3 = scaled_net < -100

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OB/OS FILLS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fill(thresh_up1, top, 100, 20, top_active1 ? color.new(bullColor, 92) : color.new(bullColor, 97), top_active1 ? color.new(bullColor, 85) : color.new(bullColor, 95), title = "Fill Up 1")
fill(thresh_up2, top, 100, 60, top_active2 ? color.new(bullColor, 88) : color.new(bullColor, 96), top_active2 ? color.new(bullColor, 80) : color.new(bullColor, 93), title = "Fill Up 2")
fill(thresh_up3, top, 120, 100, top_active3 ? color.new(bullColor, 82) : color.new(bullColor, 94), top_active3 ? color.new(bullColor, 75) : color.new(bullColor, 90), title = "Fill Up 3")

fill(thresh_down1, low_, -20, -100, bot_active1 ? color.new(bearColor, 92) : color.new(bearColor, 97), bot_active1 ? color.new(bearColor, 85) : color.new(bearColor, 95), title = "Fill Down 1")
fill(thresh_down2, low_, -60, -100, bot_active2 ? color.new(bearColor, 88) : color.new(bearColor, 96), bot_active2 ? color.new(bearColor, 80) : color.new(bearColor, 93), title = "Fill Down 2")
fill(thresh_down3, low_, -100, -120, bot_active3 ? color.new(bearColor, 82) : color.new(bearColor, 94), bot_active3 ? color.new(bearColor, 75) : color.new(bearColor, 90), title = "Fill Down 3")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTOGRAM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(mode == "Net" ? scaled_net : na, title = "Net Histogram", color = scaled_net >= 0 ? bullColor : bearColor, style = plot.style_histogram, linewidth = 3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPARE MODE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
compare_buy  = mode == "Compare" ? index_buy * 100 : na
compare_sell = mode == "Compare" ? -(index_sell * 100) : na

plot(compare_buy, title = "Buy Interest", color = bullColor, linewidth = 2)
plot(compare_sell, title = "Sell Interest", color = bearColor, linewidth = 2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MSS LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var array<float> highVal = array.new_float()
var array<float> lowVal  = array.new_float()

var bool drawUp    = false
var bool drawDown  = false
var string lastState = na
var int trend      = 1

to_up   = high[mssLen] >= ta.highest(high, mssLen)
to_down = low[mssLen]  <= ta.lowest(low, mssLen)

trend := trend == 1 and to_down ? -1 : trend == -1 and to_up ? 1 : trend

if ta.change(trend) != 0 and trend == 1
    array.push(highVal, high[mssLen])
    drawUp := false

if ta.change(trend) != 0 and trend == -1
    array.push(lowVal, low[mssLen])
    drawDown := false

bullishCondition = mode == "Compare" ? compare_buy > math.abs(compare_sell) : scaled_net > 0
bearishCondition = mode == "Compare" ? math.abs(compare_sell) > compare_buy : scaled_net < 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BULLISH MSS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if array.size(highVal) > 0 and not drawUp
    lastHigh = array.get(highVal, array.size(highVal) - 1)

    if close > lastHigh
        chochBull = na(lastState) or lastState == "down"

        if chochBull and bullishCondition
            label.new(bar_index, 100, "MSS", style = label.style_label_up, color = bullColor, textcolor = color.black, size = size.small)

        drawUp    := true
        lastState := "up"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BEARISH MSS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if array.size(lowVal) > 0 and not drawDown
    lastLow = array.get(lowVal, array.size(lowVal) - 1)

    if close < lastLow
        chochBear = na(lastState) or lastState == "up"

        if chochBear and bearishCondition
            label.new(bar_index, -100, "MSS", style = label.style_label_down, color = bearColor, textcolor = color.white, size = size.small)

        drawDown  := true
        lastState := "down"
````
