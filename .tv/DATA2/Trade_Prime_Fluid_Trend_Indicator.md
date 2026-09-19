<!-- tradingview-pine-id: PUB;0e29d160970f41d6b5b8b109326011dc -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trade Prime - Fluid Trend Indicator

Source: https://www.tradingview.com/script/vYtaQSOp-Trade-Prime-Fluid-Trend-Indicator/

## Description

Overview
Welcome to the official Fluid Trend Indicator (FTI) by Trade Prime. Most retail trend indicators suffer from a fatal flaw: they are either incredibly noisy, resulting in dozens of false signals, or they lag so far behind the price action that the move is over before the signal fires.

The FTI solves this by combining a zero-lag mathematical core with a proprietary Prime Volatility Adjusted Moving Average (PVAMA) smoothing engine. The result is a buttery-smooth, highly accurate Fluid Line surrounded by dynamic volatility ribbons. Furthermore, the FTI features a dynamic visibility engine—it completely hides irrelevant but important calculations to give you an uncluttered, institutional-grade chart based on your use case.

Whether you are a 5-minute scalper or a daily swing trader, the FTI offers a "Two-in-One" architecture to adapt to your exact trading style.

Settings & Customisation

We have engineered the settings to be completely bulletproof. The complex math is hidden under the hood, leaving you with only the parameters that actually matter.

- Trading Mode: The core of the indicator.
- Signal Mode: Hyper-responsive. Designed to catch early pivots for day traders and scalpers.
- Trend Mode: Noise-filtering. Designed to ignore minor chop and ride massive macro trends for swing traders.
- Intensity Level (1, 2, 3): Controls the baseline sensitivity of the indicator. A lower number reacts faster to price changes, while a higher number requires a larger move to shift the trend.
- Smoothness Length (10 - 20): Controls the visual "flow" of the indicator. Locked between 10 and 20 to guarantee the zero-lag mathematical integrity of the aesthetic.
- Visual Toggles: Easily turn the signal arrows and trailing ribbons on or off.

How to Use the FTI

Trend Identification (Trend Mode)
The FTI makes identifying the major trend effortless. Simply look at the color of the central fluid line.
- Bullish: The line turns Pure Green and trades below the price. You should only be looking for long (buy) opportunities.
- Bearish: The line turns Pure Red and trades above the price. You should only be looking for short (sell) opportunities.

Pullback Identification (Trend Mode)
If you want to trade like an institution, you shouldn't buy the tops of breakouts—you should buy the pullbacks.
- The Reload Zone: The FTI will project a shaded volatility ribbon on the active side of the trend. This acts as a highly accurate, dynamic Support/Resistance zone.
- Uptrend Pullbacks: Wait for the price to drop into the Green Lower Ribbon. When price touches this zone and shows rejection (e.g., a bullish pin bar), enter your long entry.
- Downtrend Rallies: Wait for the price to rally into the Red Upper Ribbon. When price touches this zone and shows weakness, enter your short entry.

Trade Signals (Signal Mode)
If your goal is to catch rapid momentum shifts, set the indicator to Signal Mode.
- Entry: Wait for the FTI to flip colors and print a directional arrow.
- Execution: Enter the trade on the close of the candle that generates the arrow.
- Exit: Use the trailing central line as your dynamic stop-loss, exiting the position as soon as the line flips to the opposing color.

Risk Disclaimer: As with all technical analysis tools, the Fluid Trend Indicator is not a crystal ball. It is designed to provide high-probability confluence. Always pair this indicator with strict risk management, proper position sizing, and your own macro market analysis.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Fluid Trend Indicator by Trade Prime

//@version=6
indicator('Trade Prime - Fluid Trend Indicator', shorttitle = 'FTI', overlay = true)

// ========================================================================= //
// 1. USER INPUTS
// ========================================================================= //
const string calcGroup = 'FluidTrend Core Engine'

// Mode Selector (Two Indicators in One)
opMode = input.string('Trend Mode', title = 'Trading Mode', options = ['Signal Mode', 'Trend Mode'], group = calcGroup, tooltip = '\'Signal Mode\' catches early pivots for scalping. \'Trend Mode\' filters noise for macro swing trading.')

// Intensity Level
ampLevel = input.int(1, title = 'Intensity Level', minval = 1, maxval = 3, step = 1, group = calcGroup, tooltip = 'Scales sensitivity. In Signal Mode: 1=1, 2=2, 3=3. In Trend Mode: 1=5, 2=10, 3=15.')

// Dynamic Amplitude Calculation based on selected mode
ampMultiplier = opMode == 'Signal Mode' ? 1 : 5
amplitude = ampLevel * ampMultiplier

// Hardcoded Channel Deviation to prevent user error
channelDeviation = 2

const string smoothGroup = 'Smoothing'
// Smoothing is permanently enabled with strict boundaries to enforce the premium aesthetic
smoothLen = input.int(16, title = 'Smoothness Length', minval = 10, maxval = 20, group = smoothGroup, tooltip = 'Locked between 10 (Fastest) and 20 (Smoothest) for optimal flow.')

const string visualGroup = 'Visuals & Themes'
// NEW: Color Theme Dropdown
themeOpt = input.string('Green & Red', title = 'Color Theme', options = ['Green & Red', 'Aqua & Orange'], group = visualGroup)

// NEW: Label Checkbox
showLabels = input.bool(false, title = 'Show Buy/Sell Labels', group = visualGroup)
showArrows = input.bool(true, title = 'Show Signal Arrows', group = visualGroup)
showChannels = input.bool(true, title = 'Show Trailing Ribbon', group = visualGroup)

// Dynamic Color Assignment based on Theme Selection
colorBull = themeOpt == 'Green & Red' ? color.rgb(0, 255, 0) : color.rgb(131, 238, 255) // Pure Green OR Aqua Blue (#1F51FF)
colorBear = themeOpt == 'Green & Red' ? color.rgb(255, 0, 0) : color.rgb(255, 95, 31) // Pure Red OR Orange (#FF5F1F)

// ========================================================================= //
// 2. HALFTREND CORE ENGINE (The Invisible Math)
// ========================================================================= //
var int trend = 0
var int nextTrend = 0
var float maxLowPrice = nz(low[1], low)
var float minHighPrice = nz(high[1], high)

var float up = 0.0
var float down = 0.0
float atrHighRaw = 0.0
float atrLowRaw = 0.0
float arrowUp = na
float arrowDown = na

atr2 = ta.atr(100) / 2
dev = channelDeviation * atr2

highPrice = high[math.abs(ta.highestbars(amplitude))]
lowPrice = low[math.abs(ta.lowestbars(amplitude))]
highma = ta.sma(high, amplitude)
lowma = ta.sma(low, amplitude)

if nextTrend == 1
    maxLowPrice := math.max(lowPrice, maxLowPrice)
    if highma < maxLowPrice and close < nz(low[1], low)
        trend := 1
        nextTrend := 0
        minHighPrice := highPrice
        minHighPrice
else
    minHighPrice := math.min(highPrice, minHighPrice)
    if lowma > minHighPrice and close > nz(high[1], high)
        trend := 0
        nextTrend := 1
        maxLowPrice := lowPrice
        maxLowPrice

if trend == 0
    if not na(trend[1]) and trend[1] != 0
        up := na(down[1]) ? down : down[1]
        arrowUp := up - atr2
        arrowUp
    else
        up := na(up[1]) ? maxLowPrice : math.max(maxLowPrice, up[1])
        up
    atrHighRaw := up + dev
    atrLowRaw := up - dev
    atrLowRaw
else
    if not na(trend[1]) and trend[1] != 1
        down := na(up[1]) ? up : up[1]
        arrowDown := down + atr2
        arrowDown
    else
        down := na(down[1]) ? minHighPrice : math.min(minHighPrice, down[1])
        down
    atrHighRaw := down + dev
    atrLowRaw := down - dev
    atrLowRaw

htRaw = trend == 0 ? up : down

// ========================================================================= //
// 3. VISUAL SMOOTHING ENGINE (The Trade Prime Aesthetic)
// ========================================================================= //
// Hardcoded: Always route the raw stair-step data through the Hull Moving Average 
htFluid = ta.hma(htRaw, smoothLen)
atrHighFluid = ta.hma(atrHighRaw, smoothLen)
atrLowFluid = ta.hma(atrLowRaw, smoothLen)

// ========================================================================= //
// 4. PLOTTING & VISUALS (Dynamic Visibility Logic)
// ========================================================================= //
// Core Trendline
htColor = trend == 0 ? colorBull : colorBear
htPlot = plot(htFluid, title = 'HalfTrend Center', linewidth = 3, color = htColor)

// Determine which side of the ribbon to show
showUpper = trend == 1 and showChannels // Only true in a Downtrend
showLower = trend == 0 and showChannels // Only true in an Uptrend

// Volatility Ribbon (Line with breaks style)
atrHighPlot = plot(showUpper ? atrHighFluid : na, title = 'Upper Ribbon', linewidth = 1, color = color.new(colorBear, 50), style = plot.style_linebr)
atrLowPlot = plot(showLower ? atrLowFluid : na, title = 'Lower Ribbon', linewidth = 1, color = color.new(colorBull, 50), style = plot.style_linebr)

// Fill only the active side
fill(htPlot, atrHighPlot, title = 'Bearish Ribbon Fill', color = showUpper ? color.new(colorBear, 80) : na)
fill(htPlot, atrLowPlot, title = 'Bullish Ribbon Fill', color = showLower ? color.new(colorBull, 80) : na)

// ========================================================================= //
// 5. SIGNALS & ALERTS
// ========================================================================= //
//BugFixes
// Pure raw signals, no filters applied
validBuy = not na(arrowUp) and trend == 0 and trend[1] == 1
validSell = not na(arrowDown) and trend == 1 and trend[1] == 0

// Plot Arrows
plotshape(showArrows and validBuy ? atrLowFluid : na, title = 'Arrow Up', style = shape.triangleup, location = location.absolute, size = size.small, color = colorBull)
plotshape(showArrows and validSell ? atrHighFluid : na, title = 'Arrow Down', style = shape.triangledown, location = location.absolute, size = size.small, color = colorBear)

// Plot Text Labels (Appears exactly below the Buy arrow and above the Sell arrow)
plotshape(showLabels and validBuy ? atrLowFluid : na, title = 'Buy Label', text = 'BUY', style = shape.labelup, location = location.absolute, size = size.small, color = colorBull, textcolor = color.black)
plotshape(showLabels and validSell ? atrHighFluid : na, title = 'Sell Label', text = 'SELL', style = shape.labeldown, location = location.absolute, size = size.small, color = colorBear, textcolor = color.black)

// Alerts
alertcondition(validBuy, title = 'TP Fluid Buy', message = 'Fluid Buy, {{exchange}}:{{ticker}}')
alertcondition(validSell, title = 'TP Fluid Sell', message = 'Fluid Sell, {{exchange}}:{{ticker}}')
````
