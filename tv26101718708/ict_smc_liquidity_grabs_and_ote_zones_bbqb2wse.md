# ICT SMC Liquidity Grabs and OTE Zones

- url: https://www.tradingview.com/script/bbqb2wsE-ICT-SMC-Liquidity-Grabs-and-OTE-Zones/
- type: indicator
- pine_id: PUB;c7e264e49d3f480dbc00b99942867db2
- version: 1.0

## Description

ICT SMC Liquidity Grabs and OTE Zones

This indicator combines three core ICT Smart Money Concepts into one clean confluence tool: liquidity sweeps (grabs), Order Blocks formed on strong reversal candles, and Optimal Trade Entry (OTE) Fibonacci zones at 61.8% and 78.6%.

How it works:
- Detects liquidity grabs by checking if price sweeps the highest high or lowest low over a user-defined lookback and closes back inside.
- After a grab, it marks the Order Block only on strong candles (body > 30% of range).
- Dynamic Fibonacci levels are drawn from the most recent confirmed pivot swing high/low.
- Buy/sell entries trigger only when a liquidity grab + strong candle + price inside the OTE zone align.
- Optional stop-loss lines and exact SL levels are shown on signals for immediate risk visibility.
- Take-profit targets: TP1 at previous swing extreme, TP2 at 1.5x risk (adjustable).

Key customizations (all exposed in inputs):
- Liquidity lookback period
- Pivot strength (left/right bars) — tune for different timeframes
- Order Block box length
- TP2 multiplier and SL distance multiplier
- Full color control for every element
- Toggle visibility of grabs, blocks, Fib lines, entries, and SL

Best used on NQ and ES futures, 5-minute and 15-minute charts during NY session. Works best in ranging or mildly trending markets where liquidity sweeps are respected.

How to use:
1. Wait for LG-L + bullish candle inside buy OTE zone → long
2. SL below the OTE zone (shown automatically)
3. TP1 = previous swing high, TP2 = 1.5R
4. Reverse for shorts on LG-H

Important warnings:
- Pivot-based Fib levels only confirm after the right-side bars complete (standard repainting until confirmation — normal for all pivot indicators).
- In strong trending markets, grabs can fail more often. Reduce position size or add your own higher-timeframe filter.
- This is a confluence tool, not a standalone strategy. Always apply proper risk management (risk 0.5-1% per trade max).
- No backtest claims are made. Past performance on any chart does not guarantee future results.

All inputs are grouped logically. Default settings are optimized for NQ 5m. Test on your preferred symbol and timeframe before live use.

Open source. No invite-only or paid versions.

This is a confluence tool, not a magic arrow. You only take trades when all three things line up:

Liquidity Grab (orange LG label)
Order Block (colored box)
Price inside OTE Fib zone + strong candle

Visual Legend (what you see on the chart)





















































ElementColorMeaningWhat to DoLG-HOrangeLiquidity Grab High (sweep of highs)Look for short setupLG-LOrangeLiquidity Grab Low (sweep of lows)Look for long setupRed BoxRedBearish Order Block (after LG-H)Potential short zoneGreen BoxGreenBullish Order Block (after LG-L)Potential long zoneGreen LinesGreenBuy OTE zone (61.8% – 78.6% from swing low)Long entry areaRed LinesRedSell OTE zone (61.8% – 78.6% from swing high)Short entry areaRed SL LineRedStop Loss (appears only on valid entry)Your risk level

Step-by-Step How to Trade (Using Your Screenshot)
Step 1: Find a Liquidity Grab
Look for the orange LG-H or LG-L labels.
In your chart you can see many — especially on the left and middle sections.
Step 2: Wait for the Order Block
After the LG, check if a colored box appears:

LG-H + red box = bearish OB (institutional selling zone)
LG-L + green box = bullish OB (institutional buying zone)

Step 3: Check if price is in the OTE Zone

For longs: Price must be between the two green Fib lines
For shorts: Price must be between the two red Fib lines

Step 4: Confirm with candle + take the trade
Only enter when you also get a strong candle (big body) in the direction of the grab.

## Source Code

````pine
//@version=6
indicator("ICT SMC Liquidity Grabs and OTE Zones", overlay=true)

// ==== INPUT TOGGLES ====
showLiquidity   = input.bool(true,  "Show Liquidity Grabs")
showOrderBlocks = input.bool(true,  "Show Order Blocks")
showFibonacci   = input.bool(true,  "Show Fibonacci OTE Levels")
showEntries     = input.bool(true,  "Show Entry Arrows & Labels")
showSL          = input.bool(true,  "Show SL Lines & Levels")

// ==== CUSTOMIZATION ====
lookback     = input.int(20,  "Liquidity Lookback (bars)", minval=5, maxval=100)
pivotLeft    = input.int(5,   "Pivot Left Strength",       minval=1, maxval=20)
pivotRight   = input.int(5,   "Pivot Right Strength",      minval=1, maxval=20)
obBars       = input.int(15,  "OB Box Length (bars)",      minval=5, maxval=100)
tpMultiplier = input.float(1.5, "TP2 R-Multiplier",        step=0.1, minval=0.1)
slMultiplier = input.float(0.5, "SL Distance (x zone height)", step=0.1, minval=0.1)

fibLevel1 = input.float(0.618, "Fib Level 1 (Lower)", minval=0, maxval=1, step=0.001)
fibLevel2 = input.float(0.786, "Fib Level 2 (Upper)", minval=0, maxval=1, step=0.001)

liqColor     = input.color(color.orange, "Liquidity Grab Color")
bullColor    = input.color(color.green,  "Bullish (OB/Entry)")
bearColor    = input.color(color.red,    "Bearish (OB/Entry)")
fibBuyColor  = input.color(color.new(color.green, 0), "Fib Buy Lines")
fibSellColor = input.color(color.new(color.red, 0),   "Fib Sell Lines")

// ==== LIQUIDITY GRABS ====
liqHigh = ta.highest(high, lookback)
liqLow  = ta.lowest(low,  lookback)
liqGrabHigh = high > liqHigh[1] and close < liqHigh[1]
liqGrabLow  = low  < liqLow[1]  and close > liqLow[1]

plotshape(showLiquidity and liqGrabHigh, "LG High", style=shape.labeldown, location=location.abovebar, color=liqColor, text="LG-H")
plotshape(showLiquidity and liqGrabLow,  "LG Low",  style=shape.labelup,   location=location.belowbar, color=liqColor, text="LG-L")

// ==== ORDER BLOCKS ====
isBullish() => close > open and (close - open) > (high - low) * 0.3
isBearish() => open > close and (open - close) > (high - low) * 0.3

if showOrderBlocks
    if liqGrabHigh and isBearish()
        box.new(left=bar_index, right=bar_index + obBars, top=high, bottom=low, border_color=bearColor, bgcolor=color.new(bearColor, 85))
    if liqGrabLow and isBullish()
        box.new(left=bar_index, right=bar_index + obBars, top=high, bottom=low, border_color=bullColor, bgcolor=color.new(bullColor, 85))

// ==== FIB OTE LEVELS ====
swingHigh = ta.pivothigh(high, pivotLeft, pivotRight)
swingLow  = ta.pivotlow(low,  pivotLeft, pivotRight)

var float swingHighPrice = na
var float swingLowPrice  = na

if not na(swingHigh)
    swingHighPrice := swingHigh
if not na(swingLow)
    swingLowPrice := swingLow

prevSwingHigh = ta.valuewhen(not na(swingHigh), swingHigh, 1)
prevSwingLow  = ta.valuewhen(not na(swingLow),  swingLow,  1)

fibRange = swingHighPrice - swingLowPrice
ote1     = swingLowPrice  + fibRange * fibLevel1
ote2     = swingLowPrice  + fibRange * fibLevel2
oteSell1 = swingHighPrice - fibRange * fibLevel1
oteSell2 = swingHighPrice - fibRange * fibLevel2

plot(showFibonacci ? ote1 : na,     "OTE Lower Buy",  color=fibBuyColor, style=plot.style_line)
plot(showFibonacci ? ote2 : na,     "OTE Upper Buy",  color=fibBuyColor, style=plot.style_line)
plot(showFibonacci ? oteSell1 : na, "OTE Upper Sell", color=fibSellColor, style=plot.style_line)
plot(showFibonacci ? oteSell2 : na, "OTE Lower Sell", color=fibSellColor, style=plot.style_line)

// ==== BUY ENTRY ====
inOTEZone   = low <= ote2 and high >= ote1
validBuyOTE = showFibonacci and showEntries and liqGrabLow and inOTEZone and isBullish()

plotshape(validBuyOTE, "Buy Arrow", location=location.belowbar, style=shape.triangleup, color=bullColor, size=size.small)

riskBuy = ote2 - ote1
tpBuy1  = prevSwingHigh
tpBuy2  = ote2 + riskBuy * tpMultiplier
slBuy   = ote1 - riskBuy * slMultiplier

if validBuyOTE
    box.new(left=bar_index, right=bar_index + obBars, top=ote2, bottom=ote1, border_color=bullColor, bgcolor=color.new(bullColor, 85))
    label.new(bar_index, ote1, "OTE BUY\nSL: " + str.tostring(slBuy, "#.##"), style=label.style_label_up, color=bullColor, textcolor=color.white)
    alert("OTE BUY Entry | SL " + str.tostring(slBuy, "#.##"), alert.freq_once_per_bar)
    if showSL
        line.new(bar_index, slBuy, bar_index + 25, slBuy, color=color.red, width=2)

// ==== SELL ENTRY ====
inOTESellZone = low <= oteSell1 and high >= oteSell2
validSellOTE  = showFibonacci and showEntries and liqGrabHigh and inOTESellZone and isBearish()

plotshape(validSellOTE, "Sell Arrow", location=location.abovebar, style=shape.triangledown, color=bearColor, size=size.small)

riskSell = oteSell1 - oteSell2
tpSell1  = prevSwingLow
tpSell2  = oteSell2 - riskSell * tpMultiplier
slSell   = oteSell1 + riskSell * slMultiplier

if validSellOTE
    box.new(left=bar_index, right=bar_index + obBars, top=oteSell1, bottom=oteSell2, border_color=bearColor, bgcolor=color.new(bearColor, 85))
    label.new(bar_index, oteSell1, "OTE SELL\nSL: " + str.tostring(slSell, "#.##"), style=label.style_label_down, color=bearColor, textcolor=color.white)
    alert("OTE SELL Entry | SL " + str.tostring(slSell, "#.##"), alert.freq_once_per_bar)
    if showSL
        line.new(bar_index, slSell, bar_index + 25, slSell, color=color.red, width=2)
````
