<!-- tradingview-pine-id: PUB;70de3a1107a9454d8bcef00543c8a45e -->
<!-- tradingviewscripts-format: 1 -->
# Range Oscillator (Zeiierman)

Source: https://www.tradingview.com/script/mlL8CpJq-Range-Oscillator-Zeiierman/

## Description

█ Overview
Range Oscillator (Zeiierman) is a dynamic market oscillator designed to visualize how far the price is trading relative to its equilibrium range. Instead of relying on traditional overbought/oversold thresholds, it uses adaptive range detection and heatmap coloring to reveal where price is trading within a volatility-adjusted band.

The oscillator maps market movement as a heat zone, highlighting when the price approaches the upper or lower range boundaries and signaling potential breakout or mean-reversion conditions.
[image]https://www.tradingview.com/x/fw8WthmX/ [/image]
Highlights

[*]Adaptive range detection based on ATR and weighted price movement.
[*]Heatmap-driven coloring that visualizes volatility pressure and directional bias.
[*]Clear transition zones for detecting trend shifts and equilibrium points.

█ How It Works

⚪ Range Detection
The indicator identifies a dynamic price range using two main parameters:

[*]Minimum Range Length: The number of bars required to confirm that a valid range exists.
[*]Range Width Multiplier: Expands or contracts the detected range proportionally to the ATR (Average True Range).

This approach ensures that the oscillator automatically adapts to both trending and ranging markets without manual recalibration.

⚪ Weighted Mean Calculation
Instead of a simple moving average, the script calculates a weighted equilibrium mean based on the size of consecutive candle movements:

[*]Larger price changes are given greater weight, emphasizing recent volatility.

⚪ Oscillator Formula
Once the range and equilibrium mean are defined, the oscillator computes:
[pine]Osc = 100 * (Close - Mean) / RangeATR[/pine]
This normalizes price distance relative to the dynamic range size — producing consistent readings across volatile and quiet periods.

█ Heatmap Logic

The Range Oscillator includes a built-in heatmap engine that color-codes each oscillator value based on recent price interaction intensity:

[*]Strong Bullish Zones: Bright green — price faces little resistance upward.
[*]Weak Bullish Zones: Muted green — uptrend continuation but with minor hesitation.
[*]Transition Zones: Blue — areas of uncertainty or trend shift.
[*]Weak Bearish Zones: Maroon — downtrend pressure but soft momentum.
[*]Strong Bearish Zones: Bright red — strong downside continuation with low resistance.

Each color band adapts dynamically using:

[*]Number of Heat Levels: Controls granularity of the heatmap.
[*]Minimum Touches per Level: Defines how reactive or “sensitive” each color zone is.

█ How to Use

⚪ Trend & Momentum Confirmation
When the oscillator stays above +0 with green coloring, it suggests sustained bullish pressure.
[image]https://www.tradingview.com/x/peWSgkNu/ [/image]
Similarly, readings below –0 with red coloring, it suggests sustained bearish pressure.
[image]https://www.tradingview.com/x/YEvbITP0/ [/image]
⚪ Range Breakouts
When the oscillator line breaks above +100 or below –100, the price is exceeding its normal volatility range, often signaling breakout potential or exhaustion extremes.
[image]https://www.tradingview.com/x/nc7PaELd/[/image]
⚪ Mean Reversion Trades
Look for the oscillator to cross back toward zero after reaching an extreme. These transitions (often marked by blue tones) can identify early reversals or range resets.
[image]https://www.tradingview.com/x/77Oq9xJ6/ [/image]
⚪ Divergence
Use oscillator peaks and troughs relative to price action to spot hidden strength or weakness before the next move.
[image]https://www.tradingview.com/x/4rQ6G7K3/[/image]

█ Settings

[*]Minimum Range Length: Number of bars needed to confirm a valid range.
[*]Range Width Multiplier: Expands or contracts range width based on ATR.
[*]Number of Heat Levels: Number of gradient bands used in the oscillator.
[*]Minimum Touches per Level: Sensitivity threshold for when a zone becomes “hot.”

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator('Range Oscillator (Zeiierman)', overlay = false, precision = 1)
//~~}

// ~~ Tooltips {
var string t1 = 'The minimum number of bars required to qualify a range box. A higher value ensures the range is well-established, but may reduce responsiveness.'
var string t2 = 'Multiplier that adjusts the vertical size of the range box based on ATR. Larger values create wider boxes and accommodate higher volatility.'
var string t4 = 'Number of horizontal levels (bands) used in the heatmap. More levels give finer granularity but may introduce noise.'
var string t5 = 'Defines how many bars must touch a level to consider it \'hot\'. Lower values make the heatmap more reactive.'
var string t6 = 'Color for strong bullish zones. Highlights areas where price faces less resistance in uptrends.'
var string t7 = 'Color for strong bearish zones. Highlights areas where price faces less resistance in downtrends.'
var string t8 = 'Color for weak bearish zones. Highlights pressure zones in downtrends.'
var string t9 = 'Color for weak bullish zones. Highlights pressure zones in uptrends.'
var string t10 = 'Color used during trend transitions or when no valid heatmap color is available.'
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
length = input.int(50, minval = 1, step = 1, title = 'Minimum Range Length', tooltip = t1, group = 'Range Oscillator')
mult   = input.float(2.0, minval = 0.1, step = 0.1, title = 'Range Width Multiplier', tooltip = t2, group = 'Range Oscillator')

levelsInp  = input.int(2, title = 'Number of Heat Levels', minval = 2, maxval = 100, group = 'Heat-map', tooltip = t4)
heatThresh = input.int(1, title = 'Minimum Touches per Level', minval = 1, group = 'Heat-map', tooltip = t5)

strongbullish  = input.color(#09ff00, title = 'Strong Bullish Color', group = 'Style', inline = 'c', tooltip = t6)
strongbearish  = input.color(color.rgb(255, 0, 0), title = 'Strong Bearish Color', group = 'Style', inline = 'c1', tooltip = t7)
weakbearish    = input.color(color.maroon, title = 'Weak Bearish Color', group = 'Style', inline = 'c1', tooltip = t7 + ' ' + ' ' + t8)
weakbullish    = input.color(color.green, title = 'Weak Bullish Color', group = 'Style', inline = 'c', tooltip = t6 + ' ' + ' ' + t9)
transitionzone = input.color(color.blue, title = 'Transition Color', group = 'Style', inline = 'c2', tooltip = t10)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Heatmap Function {
getHeatColor(float val, int trendDir, int levelsInp, int heatThresh, color weakbullish, color strongbullish, color weakbearish, color strongbearish, series float high_ser = high, series float low_ser = low, bool pointMode = false) =>
    series float source = high_ser
    float hi = ta.highest(pointMode ? source : high_ser, 100)
    float lo = ta.lowest(pointMode ? source : low_ser, 100)
    float rng = hi - lo
    float step = rng > 0 ? rng / levelsInp : na

    color coldTrendCol = trendDir == 1 ? weakbullish : weakbearish
    color hotTrendCol = trendDir == 1 ? weakbullish : weakbearish

    var array<float> levelVals = array.new<float>(101, na)
    var array<color> levelColors = array.new<color>(101, na)
    var array<int> levelCounts = array.new<int>(101, na)

    if na(step) or step == 0
        na
    else
        for i = 0 to levelsInp - 1 by 1
            float lvl = lo + step * i
            if pointMode
                lvl := lo + step * (i + 0.5)
                lvl
            int cnt = 0
            for j = 0 to 100 - 1 by 1
                bool touch = false
                if pointMode
                    touch := source[j] >= lvl - step / 2 and source[j] < lvl + step / 2
                    touch
                else
                    touch := high_ser[j] >= lvl and low_ser[j] <= lvl
                    touch
                if touch
                    cnt := cnt + 1
                    cnt
            color col = color.from_gradient(cnt, heatThresh, heatThresh + 10, color.new(coldTrendCol, 80 - cnt), hotTrendCol)
            array.set(levelVals, i, lvl)
            array.set(levelColors, i, col)
            array.set(levelCounts, i, cnt)

        for i = levelsInp to 100 by 1
            array.set(levelVals, i, na)
            array.set(levelColors, i, na)
            array.set(levelCounts, i, na)

        float minD = 1e10
        color best = na
        for k = 0 to levelsInp - 1 by 1
            float lvl = array.get(levelVals, k)
            if not na(lvl)
                float d = math.abs(val - lvl)
                if d < minD
                    minD := d
                    best := array.get(levelColors, k)
                    best
        best
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Calculations {
atrRaw   = nz(ta.atr(2000), ta.atr(200))
rangeATR = atrRaw * mult

sumWeightedClose = 0.0
sumWeights = 0.0
for i = 0 to length - 1 by 1
    delta = math.abs(close[i] - close[i + 1])
    w = delta / close[i + 1]
    sumWeightedClose := sumWeightedClose + close[i] * w
    sumWeights := sumWeights + w
    sumWeights
ma = sumWeights != 0 ? sumWeightedClose / sumWeights : na

distances = array.new_float(length)
for i = 0 to length - 1 by 1
    array.set(distances, i, math.abs(close[i] - ma))
maxDist = array.max(distances)
inRange = maxDist <= rangeATR
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Trend Direction for Heatmap {
var int trendDir = 0
trendDir := close > ma ? 1 : close < ma ? -1 : nz(trendDir[1])
noColorOnFlip = trendDir != trendDir[1]
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Oscillator {
osc = rangeATR != 0 ? 100 * (close - ma) / rangeATR : na

blue = transitionzone
green = strongbullish
red = strongbearish
heatColor = getHeatColor(osc, trendDir, levelsInp, heatThresh, weakbullish, strongbullish, weakbearish, strongbearish, osc, osc, true)
oscColor = na(heatColor) or noColorOnFlip ? blue : heatColor

breakUp = close > ma + rangeATR
breakDn = close < ma - rangeATR
oscColor := breakUp ? green : breakDn ? red : oscColor

osc_ = plot(osc, 'Range Oscillator', color = oscColor, linewidth = 2)
hline(100, 'Upper Bound', color = color.gray, linestyle = hline.style_dotted)
hline(0, 'Zero', color = color.gray, linestyle = hline.style_dotted)
hline(-100, 'Lower Bound', color = color.gray, linestyle = hline.style_dotted)
zero_ = plot(0, '', display = display.none, editable = false)
fill(osc_, zero_, ta.highest(osc, 100), 0, oscColor, color(na))
fill(osc_, zero_, 0, ta.lowest(osc, 100), color(na), oscColor)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
