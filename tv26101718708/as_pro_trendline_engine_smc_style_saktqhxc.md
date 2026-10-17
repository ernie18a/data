# AS PRO Trendline Engine (SMC Style)

- url: https://www.tradingview.com/script/sAKtQhXc/
- type: indicator
- pine_id: PUB;09eef4e5464c41ac943a9abb8ad36b5f
- version: 1.0

## Description

🧠 1. Trend Detection (SMA 9 + Candle Coloring)
The script calculates a 9-period Simple Moving Average (SMA 9).
Candles are colored based on price position:
Green → price above SMA (bullish trend)
Red → price below SMA (bearish trend)

👉 This acts as a basic trend filter.

⚡ 2. SMA 9 Cross Alerts
Generates signals when price:
Crosses above SMA 9 → potential bullish signal
Crosses below SMA 9 → potential bearish signal

👉 These are fast signals, but can be noisy without confirmation.

🧱 3. Market Structure (Pivots + Trendlines)
Detects:
Swing highs (pivot highs)
Swing lows (pivot lows)
Connects them to form:
Downtrend lines (high → high)
Uptrend lines (low → low)
Optionally draws parallel channels

👉 This represents market structure / price action geometry.

💥 4. Breakout Detection
Checks whether price breaks:
Above a trendline → bullish breakout
Below a trendline → bearish breakout

👉 Used for trend continuation or reversal signals.

📊 5. RSI Momentum Logic
Uses RSI (14) to detect:
Overbought → potential bearish reversal
Oversold → potential bullish reversal

👉 Mainly used for exit signals or momentum filtering.

🧬 6. EMA + SMA 200 (Higher-Timeframe Bias)
Includes:
EMA (short-term trend)
SMA 200 (long-term trend)
Generates signals when they cross.

👉 This acts as a macro trend filter.

🟩 7. Fair Value Gaps (FVG – SMC Core)
Detects inefficiencies between candles:
Bullish FVG → potential support zone
Bearish FVG → potential resistance zone
Tracks:
Creation of FVGs
Mitigation (when price fills the gap)

👉 This is the Smart Money / liquidity component of the script.

🚨 8. Alert System

The script includes alerts for:

SMA crosses
Trendline breakouts
RSI signals
EMA/SMA cross signals
FVG creation and mitigation

👉 However, each alert works independently, without a unified decision system.

🧩 What the Script Does Overall

It combines four key layers of analysis:

1. Trend
SMA 9
SMA 200
2. Momentum
RSI
3. Structure
Pivot-based trendlines
4. Liquidity
Fair Value Gaps (FVG)
⚠️ Key Limitation

The script produces many individual signals, but:

It does not prioritize them
It does not combine them
It does not generate a single high-quality trade decision

👉 In other words:

It’s a signal generator, not a decision engine.

## Source Code

````pine
//@version=6
indicator("AS PRO Trendline Engine (SMC Style)", overlay=true, max_lines_count=50)

//────────────────────
// INPUTS
//────────────────────
pivotLen = input.int(5, "Pivot Length")
minBars  = input.int(10, "Min distance")
extendLines = input.bool(true, "Extend lines")
showChannel = input.bool(true, "Show channel")

//────────────────────
len9 = input.int(9, minval=1, title="Length")
src = input(close, title="Source")
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display=display.none)
//────────────────────
//────────────────────
// CORE
//────────────────────
out = ta.sma(src, len9)
plot(out, color=color.rgb(135, 135, 135, 68), style=plot.style_stepline, title="MA", offset=offset)

//────────────────────
// SMA 9 CROSS ALERTS (FIX)
//────────────────────
crossUpSMA9   = ta.crossover(close, out)
crossDownSMA9 = ta.crossunder(close, out)

//────────────────────
// TREND COLORING (CANDLES)
//────────────────────
trendBull = close > out
trendBear = close < out

candleColor =
     trendBull ? color.new(#00fc50, 0) :
     trendBear ? color.new(#e70000, 0) :
     color.new(color.gray, 40)

barcolor(candleColor)
//────────────────────
// PIVOTS
//────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

// przechowywanie pivotów
var float lastHigh = na
var float prevHigh = na
var int lastHighIdx = na
var int prevHighIdx = na

var float lastLow = na
var float prevLow = na
var int lastLowIdx = na
var int prevLowIdx = na

// HIGH pivots
if not na(ph)
    prevHigh := lastHigh
    prevHighIdx := lastHighIdx
    lastHigh := ph
    lastHighIdx := bar_index - pivotLen

// LOW pivots
if not na(pl)
    prevLow := lastLow
    prevLowIdx := lastLowIdx
    lastLow := pl
    lastLowIdx := bar_index - pivotLen

//────────────────────
// TRENDLINES
//────────────────────
var line highLine = na
var line lowLine  = na
var line highChannel = na
var line lowChannel  = na

// HIGH → downtrend
if not na(prevHigh) and not na(lastHigh)
    if lastHighIdx > prevHighIdx + minBars
        line.delete(highLine)
        highLine := line.new(
            prevHighIdx, prevHigh,
            lastHighIdx, lastHigh,
            color=color.rgb(0, 150, 2, 37),
            width=1,
            extend=extendLines ? extend.right : extend.none
        )

        // kanał (przez ostatni low)
        if showChannel and not na(lastLow)
            line.delete(highChannel)
            slope = (lastHigh - prevHigh) / (lastHighIdx - prevHighIdx)
            y = lastLow
            x = lastLowIdx
            y2 = y + slope * (lastHighIdx - x)

            highChannel := line.new(
                x, y,
                lastHighIdx, y2,
                color=color.new(#009514, 34),
                width=1,
                extend=extendLines ? extend.right : extend.none
            )

// LOW → uptrend
if not na(prevLow) and not na(lastLow)
    if lastLowIdx > prevLowIdx + minBars
        line.delete(lowLine)
        lowLine := line.new(
            prevLowIdx, prevLow,
            lastLowIdx, lastLow,
            color=color.rgb(184, 0, 0, 22),
            width=1,
            extend=extendLines ? extend.right : extend.none
        )

        // kanał (przez ostatni high)
        if showChannel and not na(lastHigh)
            line.delete(lowChannel)
            slope = (lastLow - prevLow) / (lastLowIdx - prevLowIdx)
            y = lastHigh
            x = lastHighIdx
            y2 = y + slope * (lastLowIdx - x)

            lowChannel := line.new(
                x, y,
                lastLowIdx, y2,
                color=color.new(#e60000, 29),
                width=1,
                extend=extendLines ? extend.right : extend.none
            )

//────────────────────
// BREAKOUT ALERTS
//────────────────────
breakUp = not na(highLine) and close > line.get_price(highLine, bar_index)
breakDown = not na(lowLine) and close < line.get_price(lowLine, bar_index)

ema_value = input(20)
sma_value = input(200)
ema1 = ta.ema(close, ema_value)
sma2 = ta.sma(close, sma_value)
rs = ta.rsi(close, 14)

iff_1 = high < sma2 ? color.rgb(255, 82, 82, 63) : color.yellow
iff_2 = low > sma2 ? color.rgb(0, 230, 119, 48) : iff_1
mycolor = rs >= 85 or rs <= 15 ? color.yellow : iff_2

hl = input.int(80, title = 'Overbought limit of RSI', step = 1)
ll = input.int(20, title = 'Oversold limit of RSI', step = 1)

buyexit = ta.crossunder(rs, hl)
sellexit = ta.crossover(rs, ll)

plot(sma2, title = 'Long SMA', color = mycolor, style = plot.style_circles, linewidth = 1)

plotshape(buyexit, title = 'RSI alert Bearish', style = shape.triangledown, location = location.abovebar, color = color.new(color.teal, 0), text = '↓\n ↓')
plotshape(sellexit, title = 'RSI alert Bullish', style = shape.triangleup, location = location.belowbar, color = color.new(color.teal, 0), text = '↑ \n ↑')

sellcall = ta.crossover(sma2, ema1) and open > close
buycall = ta.crossunder(sma2, ema1) and high > sma2

plotshape(buycall, title = 'BuyShape', style = shape.labelup, location = location.belowbar, color = color.new(color.aqua, 0))
plotshape(sellcall, title = 'SellShape', style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 20))

alertcondition(buyexit or sellexit, title = 'Reversal', message = 'Possible Reversal on Swing Signal Alert')
alertcondition(buycall or sellcall, title = 'Buy/Sale Swing Signal', message = 'Swing Signal Entry Alert')

emas_value = input(9)
smas_value = input(20)
emas1 = ta.ema(close, emas_value)
smas2 = ta.sma(close, smas_value)
rss = ta.rsi(close, 14)

iff_1s = high < smas2 ? color.rgb(255, 82, 82, 50) : color.yellow
iff_2s = low > smas2 ? color.rgb(0, 230, 119, 50) : iff_1s
mycolors = rss >= 85 or rs <= 15 ? color.yellow : iff_2s

hls = input.int(80, title = 'Overbought limit of RSI', step = 1)
lls = input.int(20, title = 'Oversold limit of RSI', step = 1)

buyexits = ta.crossunder(rss, hls)
sellexits = ta.crossover(rss, lls)

plot(smas2, title = 'Long SMA', color = mycolor,style = plot.style_circles, linewidth = 1)
plotshape(buyexit, title = 'RSI alert Bearish', style = shape.triangledown, location = location.abovebar, color = color.new(color.teal, 0), text = '↓\n ↓')
plotshape(sellexit, title = 'RSI alert Bullish', style = shape.triangleup, location = location.belowbar, color = color.new(color.teal, 0), text = '↑ \n ↑')

sellcalls = ta.crossover(smas2, emas1) and open > close
buycalls = ta.crossunder(smas2, emas1) and high > smas2

plotshape(buycall, title = 'BuyShape', style = shape.labelup, location = location.belowbar, color = color.new(color.aqua, 0))
plotshape(sellcall, title = 'SellShape', style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 20))

//Settings
//-----------------------------------------------------------------------------{
thresholdPer = input.float(0, 'Threshold %', minval = 0, maxval = 100, step = .1, inline = 'threshold')
auto = input(false, 'Auto', inline = 'threshold')

showLast = input.int(0, 'Unmitigated Levels', minval = 0)
mitigationLevels = input.bool(false, 'Mitigation Levels')

tf = input.timeframe('', 'Timeframe')

//Style
extend = input.int(20, 'Extend', minval = 0, inline = 'extend', group = 'Style')
dynamic = input(false, 'Dynamic', inline = 'extend', group = 'Style')

bullCss = input.color(color.new(#089981, 70), 'Bullish FVG', group = 'Style')
bearCss = input.color(color.new(#f23645, 70), 'Bearish FVG', group = 'Style')

//Dashboard
showDash = input(false, 'Show Dashboard', group = 'Dashboard')
dashLoc = input.string('Top Right', 'Location', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = 'Dashboard')
textSize = input.string('Small', 'Size', options = ['Tiny', 'Small', 'Normal'], group = 'Dashboard')

//-----------------------------------------------------------------------------}
//UDT's
//-----------------------------------------------------------------------------{
type fvg
	float max
	float min
	bool isbull
	int t = time

//-----------------------------------------------------------------------------}
//Methods/Functions
//-----------------------------------------------------------------------------{
n = bar_index

method tosolid(color id) =>
    color.rgb(color.r(id), color.g(id), color.b(id))

detect() =>
    var new_fvg = fvg.new(na, na, bool(na), na)
    threshold = auto ? ta.cum((high - low) / low) / bar_index : thresholdPer / 100

    bull_fvg = low > high[2] and close[1] > high[2] and (low - high[2]) / high[2] > threshold
    bear_fvg = high < low[2] and close[1] < low[2] and (low[2] - high) / high > threshold

    if bull_fvg
        new_fvg := fvg.new(low, high[2], true)
        new_fvg
    else if bear_fvg
        new_fvg := fvg.new(low[2], high, false)
        new_fvg

    [bull_fvg, bear_fvg, new_fvg]

//-----------------------------------------------------------------------------}
//FVG's detection/display
//-----------------------------------------------------------------------------{
var float max_bull_fvg = na
var float min_bull_fvg = na
var bull_count = 0
var bull_mitigated = 0
var float max_bear_fvg = na
var float min_bear_fvg = na
var bear_count = 0
var bear_mitigated = 0
var t = 0

var fvg_records = array.new<fvg>(0)
var fvg_areas = array.new<box>(0)

[bull_fvg, bear_fvg, new_fvg] = request.security(syminfo.tickerid, tf, detect())

//Bull FVG's
if bull_fvg and new_fvg.t != t
    if dynamic
        max_bull_fvg := new_fvg.max
        min_bull_fvg := new_fvg.min
        min_bull_fvg

    //Populate FVG array
    if not dynamic
        fvg_areas.unshift(box.new(n - 2, new_fvg.max, n + extend, new_fvg.min, na, bgcolor = bullCss))
    fvg_records.unshift(new_fvg)

    bull_count := bull_count + 1
    t := new_fvg.t
    t
else if dynamic
    max_bull_fvg := math.max(math.min(close, max_bull_fvg), min_bull_fvg)
    max_bull_fvg

//Bear FVG's
if bear_fvg and new_fvg.t != t
    if dynamic
        max_bear_fvg := new_fvg.max
        min_bear_fvg := new_fvg.min
        min_bear_fvg

    //Populate FVG array
    if not dynamic
        fvg_areas.unshift(box.new(n - 2, new_fvg.max, n + extend, new_fvg.min, na, bgcolor = bearCss))
    fvg_records.unshift(new_fvg)

    bear_count := bear_count + 1
    t := new_fvg.t
    t
else if dynamic
    min_bear_fvg := math.min(math.max(close, min_bear_fvg), max_bear_fvg)
    min_bear_fvg

//-----------------------------------------------------------------------------}
//Unmitigated/Mitigated lines
//-----------------------------------------------------------------------------{
//Test for mitigation
if fvg_records.size() > 0
    for i = fvg_records.size() - 1 to 0 by 1
        get = fvg_records.get(i)

        if get.isbull
            if close < get.min
                //Display line if mitigated
                if mitigationLevels
                    line.new(get.t, get.min, time, get.min, xloc.bar_time, color = bullCss, style = line.style_dashed)

                //Delete box
                if not dynamic
                    area = fvg_areas.remove(i)
                    area.delete()

                fvg_records.remove(i)
                bull_mitigated := bull_mitigated + 1
                bull_mitigated
        else if close > get.max
            //Display line if mitigated
            if mitigationLevels
                line.new(get.t, get.max, time, get.max, xloc.bar_time, color = bearCss, style = line.style_dashed)

            //Delete box
            if not dynamic
                area = fvg_areas.remove(i)
                area.delete()

            fvg_records.remove(i)
            bear_mitigated := bear_mitigated + 1
            bear_mitigated

//Unmitigated lines
var unmitigated = array.new<line>(0)

//Remove umitigated lines 
if barstate.islast and showLast > 0 and fvg_records.size() > 0
    if unmitigated.size() > 0
        for element in unmitigated
            element.delete()
        unmitigated.clear()

    for i = 0 to math.min(showLast - 1, fvg_records.size() - 1) by 1
        get = fvg_records.get(i)

        unmitigated.push(line.new(get.t, get.isbull ? get.min : get.max, time, get.isbull ? get.min : get.max, xloc.bar_time, color = get.isbull ? bullCss : bearCss))

//-----------------------------------------------------------------------------}
//Plots
//-----------------------------------------------------------------------------{
//Dynamic Bull FVG
max_bull_plot = plot(max_bull_fvg, color = na)
min_bull_plot = plot(min_bull_fvg, color = na)
fill(max_bull_plot, min_bull_plot, color = bullCss)

//Dynamic Bear FVG
max_bear_plot = plot(max_bear_fvg, color = na)
min_bear_plot = plot(min_bear_fvg, color = na)
fill(max_bear_plot, min_bear_plot, color = bearCss)

//-----------------------------------------------------------------------------}
//Alerts
//-----------------------------------------------------------------------------{
alertcondition(crossUpSMA9, title="SMA 9 Cross UP", message="Price crossed ABOVE SMA 9")
alertcondition(crossDownSMA9, title="SMA 9 Cross DOWN", message="Price crossed BELOW SMA 9")
alertcondition(crossUpSMA9 or crossDownSMA9, title="SMA 9 Cross ANY", message="Price crossed SMA 9")

alertcondition(breakUp, "Break Up", "Price broke DOWN trendline (bullish)")
alertcondition(breakDown, "Break Down", "Price broke UP trendline (bearish)")
alertcondition(breakDown or breakUp, "Break ", "Price broke trendline )")

alertcondition(bull_count > bull_count[1], 'Bullish FVG', 'Bullish FVG detected')
alertcondition(bear_count > bear_count[1], 'Bearish FVG', 'Bearish FVG detected')

alertcondition(bull_mitigated > bull_mitigated[1], 'Bullish FVG Mitigation', 'Bullish FVG mitigated')
alertcondition(bear_mitigated > bear_mitigated[1], 'Bearish FVG Mitigation', 'Bearish FVG mitigated')
alertcondition(bear_mitigated > bear_mitigated[1] or bull_mitigated > bull_mitigated[1] or bull_count > bull_count[1] or bear_count > bear_count[1] or crossUpSMA9 or crossDownSMA9, '!')

//-----------------------------------------------------------------------------}
````
