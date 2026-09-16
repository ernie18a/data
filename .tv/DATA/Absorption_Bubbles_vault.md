<!-- tradingview-pine-id: PUB;27739d31dd2a49d5a173ba01e0bbc211 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Absorption Bubbles [vault]

Source: https://www.tradingview.com/script/K9jpcuzk-Absorption-Bubbles-vault/

## Description

Absorption Bubbles [vault]

Absorption Bubbles is a tool for spotting high volume absorption at swing highs and lows, showing where aggressive orders pushing into an extreme were absorbed before the move gives it away.

How it works

The script measures every candle's volume against its own standard deviation (Threshold STDEV Length), so thresholds adapt automatically to any instrument and timeframe instead of relying on fixed volume numbers. A bubble prints only when three conditions line up on the same candle: price makes a local swing high or low, the candle closes with a rejection wick at that extreme, and scaled volume clears the selected threshold multiplier. On top of that, volume below its moving average (Threshold EMA Length) never prints, which filters out low-activity noise by design.

Green bubbles under swing lows signal buyers absorbing sell pressure. Red bubbles above swing highs signal sellers absorbing the push up. Absorption at an extreme tells you where the fight happened — the move that follows is usually the confirmation.

Bubble tiers

- Small, Medium, and Large bubbles, each with its own independent toggle and threshold multiplier (default 2x / 3x / 4.5x)
- Bubble size scales with absorption intensity, so weak, moderate, and heavy prints are visually distinguishable at a glance
- Optional Strength Gradient Color keys the bubble color to absorption intensity instead of flat buy/sell colors

Additional settings

- Bubble Positions: right at the wick or slightly offset above/below the extreme
- Bubble Size: Compact, Normal, or Large display presets
- Appearance Delay: shifts the bubble by N candles for confirmation
- Show POC: draws a line at the absorption price that extends until the next print, usable as a level to trade back into
- Timeframe-Adjusted Settings: independent STDEV/EMA lengths and threshold multipliers for 5m, 15m, 1H, and 4H — the script switches automatically based on the chart timeframe
- Built-in alerts for buy-side and sell-side absorption
- Works on any timeframe and any instrument with volume data

Disclaimer:

This is a context tool, not a signal service. Nothing here constitutes financial advice.

---

## Source Code

````pine
//@version=6
indicator("Absorption Bubbles [vault]", overlay=true, max_labels_count=500, max_lines_count=500)

//==================================================
// GENERAL
//==================================================
groupGeneral = "General"
bubblePos    = input.string("Above / Below Wick", "Bubble Positions", options=["Above / Below Wick", "At Wick"], group=groupGeneral)
buyColor     = input.color(color.new(color.green, 0), "Buy Order Bubbles", group=groupGeneral)
sellColor    = input.color(color.new(color.red, 0),   "Sell Order Bubbles", group=groupGeneral)
useGradient  = input.bool(false, "Strength Gradient Color", group=groupGeneral, tooltip="Color bubbles by absorption intensity instead of a flat buy/sell color")
bubbleSizeIn = input.string("Normal", "Bubble Size", options=["Compact", "Normal", "Large"], group=groupGeneral)

//==================================================
// THRESHOLD MULTIPLIERS
//==================================================
groupThresh = "Threshold Multipliers"
useSmall    = input.bool(false, "Small Bubble", inline="sm", group=groupThresh)
smallMult   = input.float(2.0, "×", inline="sm", group=groupThresh)
useMedium   = input.bool(true,  "Medium Bubble", inline="md", group=groupThresh)
mediumMult  = input.float(3.0, "×", inline="md", group=groupThresh)
useLarge    = input.bool(true,  "Large Bubble", inline="lg", group=groupThresh)
largeMult   = input.float(4.5, "×", inline="lg", group=groupThresh)

//==================================================
// ADDITIONAL SETTINGS
//==================================================
groupAdd    = "Additional Settings"
stdevLen    = input.int(30, "Threshold STDEV Length", minval=1, group=groupAdd)
emaLen      = input.int(30, "Threshold EMA Length", minval=1, group=groupAdd)
appearDelay = input.int(0, "Appearance Delay", minval=0, maxval=20, group=groupAdd)
showPOC     = input.bool(false, "Show POC", group=groupAdd)

//==================================================
// TIMEFRAME-ADJUSTED SETTINGS
//==================================================
groupTF = "Timeframe-Adjusted Settings"
tfOverrideOn = input.bool(false, "Timeframe Override", group=groupTF)

tf1On = input.bool(false, "", inline="tf1a", group=groupTF)
tf1   = input.timeframe("5", "", inline="tf1a", group=groupTF)
tf1Stdev  = input.int(30, "STDEV", inline="tf1b", group=groupTF)
tf1Ema    = input.int(30, "EMA", inline="tf1b", group=groupTF)
tf1Small  = input.float(2.0, "S", inline="tf1c", group=groupTF)
tf1Medium = input.float(3.0, "M", inline="tf1c", group=groupTF)
tf1Large  = input.float(4.5, "L", inline="tf1c", group=groupTF)

tf2On = input.bool(false, "", inline="tf2a", group=groupTF)
tf2   = input.timeframe("15", "", inline="tf2a", group=groupTF)
tf2Stdev  = input.int(30, "STDEV", inline="tf2b", group=groupTF)
tf2Ema    = input.int(30, "EMA", inline="tf2b", group=groupTF)
tf2Small  = input.float(2.0, "S", inline="tf2c", group=groupTF)
tf2Medium = input.float(3.0, "M", inline="tf2c", group=groupTF)
tf2Large  = input.float(4.5, "L", inline="tf2c", group=groupTF)

tf3On = input.bool(false, "", inline="tf3a", group=groupTF)
tf3   = input.timeframe("60", "", inline="tf3a", group=groupTF)
tf3Stdev  = input.int(30, "STDEV", inline="tf3b", group=groupTF)
tf3Ema    = input.int(30, "EMA", inline="tf3b", group=groupTF)
tf3Small  = input.float(2.0, "S", inline="tf3c", group=groupTF)
tf3Medium = input.float(3.0, "M", inline="tf3c", group=groupTF)
tf3Large  = input.float(4.5, "L", inline="tf3c", group=groupTF)

tf4On = input.bool(false, "", inline="tf4a", group=groupTF)
tf4   = input.timeframe("240", "", inline="tf4a", group=groupTF)
tf4Stdev  = input.int(30, "STDEV", inline="tf4b", group=groupTF)
tf4Ema    = input.int(30, "EMA", inline="tf4b", group=groupTF)
tf4Small  = input.float(2.0, "S", inline="tf4c", group=groupTF)
tf4Medium = input.float(3.0, "M", inline="tf4c", group=groupTF)
tf4Large  = input.float(4.5, "L", inline="tf4c", group=groupTF)

//==================================================
// STYLE
//==================================================
groupStyle = "Style"
buySmallColor  = input.color(color.new(color.green, 60), "Buy · Small",  group=groupStyle)
buyMediumColor = input.color(color.new(color.green, 30), "Buy · Medium", group=groupStyle)
buyLargeColor  = input.color(color.new(color.green, 0),  "Buy · Large",  group=groupStyle)
sellSmallColor  = input.color(color.new(color.red, 60), "Sell · Small",  group=groupStyle)
sellMediumColor = input.color(color.new(color.red, 30), "Sell · Medium", group=groupStyle)
sellLargeColor  = input.color(color.new(color.red, 0),  "Sell · Large",  group=groupStyle)
pocColor   = input.color(color.yellow, "POC Line", group=groupStyle)
pocStyleIn = input.string("Solid", "POC Line Style", options=["Solid", "Dashed", "Dotted"], group=groupStyle)

//==================================================
// RESOLVE ACTIVE THRESHOLDS (TIMEFRAME OVERRIDE)
//==================================================
useTf1 = tfOverrideOn and tf1On and timeframe.period == tf1
useTf2 = tfOverrideOn and tf2On and timeframe.period == tf2
useTf3 = tfOverrideOn and tf3On and timeframe.period == tf3
useTf4 = tfOverrideOn and tf4On and timeframe.period == tf4

activeStdevLen = useTf1 ? tf1Stdev : useTf2 ? tf2Stdev : useTf3 ? tf3Stdev : useTf4 ? tf4Stdev : stdevLen
activeEmaLen = useTf1 ? tf1Ema : useTf2 ? tf2Ema : useTf3 ? tf3Ema : useTf4 ? tf4Ema : emaLen
activeSmall = useTf1 ? tf1Small : useTf2 ? tf2Small : useTf3 ? tf3Small : useTf4 ? tf4Small : smallMult
activeMedium = useTf1 ? tf1Medium : useTf2 ? tf2Medium : useTf3 ? tf3Medium : useTf4 ? tf4Medium : mediumMult
activeLarge = useTf1 ? tf1Large : useTf2 ? tf2Large : useTf3 ? tf3Large : useTf4 ? tf4Large : largeMult

//==================================================
// ABSORPTION MATH
// (volume scaled by its own STDEV, exactly like the
//  session-rejection script, EMA acts as noise filter)
//==================================================
volStdev  = ta.stdev(volume, int(activeStdevLen))
volEma    = ta.ema(volume, int(activeEmaLen))
scaledVol = volStdev != 0 ? volume / volStdev : 0.0
aboveAvg  = volume > volEma  // noise filter: below-average volume never prints

midPrice = (high + low) / 2
topBody  = math.max(open, close)
lowBody  = math.min(open, close)

// wick zones (same validation as the session script)
upperZone = midPrice >= topBody and midPrice <= high   // long upper wick -> sellers absorbed the push up
lowerZone = midPrice <= lowBody and midPrice >= low    // long lower wick -> buyers absorbed the push down

// swing high/low filter: absorption only matters at local extremes
swingLen  = 5
atSwingHi = high >= ta.highest(high, swingLen)
atSwingLo = low  <= ta.lowest(low,  swingLen)

buyAbsorption  = lowerZone and atSwingLo and aboveAvg and scaledVol >= activeSmall
sellAbsorption = upperZone and atSwingHi and aboveAvg and scaledVol >= activeSmall

tier = scaledVol >= activeLarge ? 3 : scaledVol >= activeMedium ? 2 : scaledVol >= activeSmall ? 1 : 0

showBuySmall   = useSmall  and buyAbsorption  and tier == 1
showBuyMedium  = useMedium and buyAbsorption  and tier == 2
showBuyLarge   = useLarge  and buyAbsorption  and tier == 3
showSellSmall  = useSmall  and sellAbsorption and tier == 1
showSellMedium = useMedium and sellAbsorption and tier == 2
showSellLarge  = useLarge  and sellAbsorption and tier == 3

//==================================================
// COLORS (gradient from the session script, keyed to intensity)
//==================================================
gradBuy  = color.from_gradient(scaledVol, activeSmall, activeLarge + 2, color.new(buyColor, 60),  color.new(buyColor, 0))
gradSell = color.from_gradient(scaledVol, activeSmall, activeLarge + 2, color.new(sellColor, 60), color.new(sellColor, 0))

colBuySmall   = useGradient ? gradBuy  : buySmallColor
colBuyMedium  = useGradient ? gradBuy  : buyMediumColor
colBuyLarge   = useGradient ? gradBuy  : buyLargeColor
colSellSmall  = useGradient ? gradSell : sellSmallColor
colSellMedium = useGradient ? gradSell : sellMediumColor
colSellLarge  = useGradient ? gradSell : sellLargeColor

//==================================================
// POSITION (location.absolute so bubbles hug the candle)
//==================================================
pad = ta.atr(14) * 0.25  // small offset so "Above / Below Wick" sits just off the extreme
hugWick = bubblePos == "At Wick"

yBuy  = hugWick ? low  : low  - pad
ySell = hugWick ? high : high + pad

valBuySmall   = showBuySmall   ? yBuy  : na
valBuyMedium  = showBuyMedium  ? yBuy  : na
valBuyLarge   = showBuyLarge   ? yBuy  : na
valSellSmall  = showSellSmall  ? ySell : na
valSellMedium = showSellMedium ? ySell : na
valSellLarge  = showSellLarge  ? ySell : na

//==================================================
// PLOTS (all global scope, size preset gated by series)
//==================================================
isCompact = bubbleSizeIn == "Compact"
isNormal  = bubbleSizeIn == "Normal"
isLarge   = bubbleSizeIn == "Large"

plotshape(isCompact ? valBuySmall : na,   "Buy Small (Compact)",   shape.circle, location.absolute, colBuySmall,   offset=appearDelay, size=size.tiny)
plotshape(isNormal  ? valBuySmall : na,   "Buy Small (Normal)",    shape.circle, location.absolute, colBuySmall,   offset=appearDelay, size=size.tiny)
plotshape(isLarge   ? valBuySmall : na,   "Buy Small (Large)",     shape.circle, location.absolute, colBuySmall,   offset=appearDelay, size=size.small)

plotshape(isCompact ? valBuyMedium : na,  "Buy Medium (Compact)",  shape.circle, location.absolute, colBuyMedium,  offset=appearDelay, size=size.tiny)
plotshape(isNormal  ? valBuyMedium : na,  "Buy Medium (Normal)",   shape.circle, location.absolute, colBuyMedium,  offset=appearDelay, size=size.small)
plotshape(isLarge   ? valBuyMedium : na,  "Buy Medium (Large)",    shape.circle, location.absolute, colBuyMedium,  offset=appearDelay, size=size.normal)

plotshape(isCompact ? valBuyLarge : na,   "Buy Large (Compact)",   shape.circle, location.absolute, colBuyLarge,   offset=appearDelay, size=size.small)
plotshape(isNormal  ? valBuyLarge : na,   "Buy Large (Normal)",    shape.circle, location.absolute, colBuyLarge,   offset=appearDelay, size=size.normal)
plotshape(isLarge   ? valBuyLarge : na,   "Buy Large (Large)",     shape.circle, location.absolute, colBuyLarge,   offset=appearDelay, size=size.large)

plotshape(isCompact ? valSellSmall : na,  "Sell Small (Compact)",  shape.circle, location.absolute, colSellSmall,  offset=appearDelay, size=size.tiny)
plotshape(isNormal  ? valSellSmall : na,  "Sell Small (Normal)",   shape.circle, location.absolute, colSellSmall,  offset=appearDelay, size=size.tiny)
plotshape(isLarge   ? valSellSmall : na,  "Sell Small (Large)",    shape.circle, location.absolute, colSellSmall,  offset=appearDelay, size=size.small)

plotshape(isCompact ? valSellMedium : na, "Sell Medium (Compact)", shape.circle, location.absolute, colSellMedium, offset=appearDelay, size=size.tiny)
plotshape(isNormal  ? valSellMedium : na, "Sell Medium (Normal)",  shape.circle, location.absolute, colSellMedium, offset=appearDelay, size=size.small)
plotshape(isLarge   ? valSellMedium : na, "Sell Medium (Large)",   shape.circle, location.absolute, colSellMedium, offset=appearDelay, size=size.normal)

plotshape(isCompact ? valSellLarge : na,  "Sell Large (Compact)",  shape.circle, location.absolute, colSellLarge,  offset=appearDelay, size=size.small)
plotshape(isNormal  ? valSellLarge : na,  "Sell Large (Normal)",   shape.circle, location.absolute, colSellLarge,  offset=appearDelay, size=size.normal)
plotshape(isLarge   ? valSellLarge : na,  "Sell Large (Large)",    shape.circle, location.absolute, colSellLarge,  offset=appearDelay, size=size.large)

//==================================================
// POC (marks the absorption wick price until the next one)
//==================================================
pocLineStyle = pocStyleIn == "Solid" ? line.style_solid : pocStyleIn == "Dashed" ? line.style_dashed : line.style_dotted

var line pocLineBuy  = na
var line pocLineSell = na

if showPOC and (showBuySmall or showBuyMedium or showBuyLarge)
    line.delete(pocLineBuy)
    pocLineBuy := line.new(bar_index, low, bar_index + 1, low, color=pocColor, style=pocLineStyle, extend=extend.right)

if showPOC and (showSellSmall or showSellMedium or showSellLarge)
    line.delete(pocLineSell)
    pocLineSell := line.new(bar_index, high, bar_index + 1, high, color=pocColor, style=pocLineStyle, extend=extend.right)

//==================================================
// ALERTS
//==================================================
alertcondition(showBuySmall or showBuyMedium or showBuyLarge, "Buy Absorption", "Absorption Bubbles [vault]: buy-side absorption at swing low")
alertcondition(showSellSmall or showSellMedium or showSellLarge, "Sell Absorption", "Absorption Bubbles [vault]: sell-side absorption at swing high")
````
