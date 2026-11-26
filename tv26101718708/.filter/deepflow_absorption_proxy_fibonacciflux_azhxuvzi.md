# DeepFlow Absorption Proxy [FibonacciFlux]

- url: https://www.tradingview.com/script/AZhxuvzI-DeepFlow-Absorption-Proxy-FibonacciFlux/
- type: indicator
- pine_id: PUB;5bbb4d0dcfd34810963279cf4e7e8d60
- version: 1.0

## Description

An OHLCV-only proxy for absorption, published together with the measurements that say how little it is entitled to claim.

WHAT IT MARKS

A bar is marked when four things are true at once: volume is at least 1.8 standard deviations above its 50-bar mean, the body is at most 36% of the bar's range, one wick is at least 38% of it, and the bar is revisiting a level it already reacted to - within 0.28 ATR of the 18-bar extreme on that side. Sell marks sit at the high, buy marks at the low. An audit table shows each of those four quantities for the last bar and whether it passed, so the reason for a mark, or for its absence, is visible rather than implied.

Real absorption is an order-book event. Nothing in OHLCV can see resting size, and this script does not pretend otherwise: it marks a shape.

HOW OFTEN, AND WHERE

At default inputs, on the 6000 bars of BINANCE:BTCUSDT 15m ending 2026-08-18 13:00 UTC - 62 days - it marks 16 bars: 0.27% of them, 9 sell and 7 buy, no two closer than 26 bars apart, and no bar ever firing both sides.

That rate belongs to the symbol and the bar size, not to the indicator. Same defaults, same measurement: BTCUSDT 1h 0.57%, BTCUSDT 4h 0.50%, ETHUSDT 15m 0.32%, ETHUSDT 1h 0.30%. On daily bars it can go a very long time without marking anything - on BTCUSDT 1D it marked nothing at all across 1000 days. It is built for intraday bars, and that is a limit rather than a preference.

WHAT THE MEASUREMENT DOES NOT SUPPORT

The tempting reading of a script like this is that the four gates recognise one event together - that a volume spike means something different on an absorption-shaped bar than on any other bar. Measured, that is not visible here.

Over the 5,951 scored bars, a volume spike is no more likely on a bar that already passed the shape and level tests than on any other bar: the lift is 0.99x on the sell side (95% CI 0.53 to 1.80) and 0.75x on the buy side (CI 0.36 to 1.45). With 123 sell candidates, an interaction smaller than roughly 1.6x could not be seen at all, so the honest statement is that the joint structure is undemonstrated at this sample size, not that it has been disproved.

A second test points the same way. Circularly shifting the volume series against untouched candles - which destroys any alignment between volume and bar shape while preserving both series' own distributions - produces about 19 marks on average (5th to 95th percentile 12 to 26) where the real series produces 16. The real series sits below its own null rather than above it, though not significantly (two-sided p = 0.59). One plausible mechanism, measured: range and volume correlate at 0.69, so genuinely high-volume bars tend to be wide-range bars, and wide-range bars are exactly what the small-body gate throws away.

The level gate is the part that surprised me most. At the shipped 18-bar lookback, a bar sitting at an 18-bar extreme is about 28% LESS likely to carry a volume spike than a bar that is not (0.72x, 95% CI 0.48 to 0.96 on BTCUSDT 15m; 0.62x on ETHUSDT 15m). The relationship does turn positive at longer lookbacks - around 60 bars it runs between 1.3x and 2.5x across BTC and ETH on 15m and 1h - but the headline BTCUSDT 15m cell does not separate from a volume-shift null even there. The default is left at 18 because every number quoted here was measured at it, and the tooltip on that input says all of the above.

Two more things a user should know before turning knobs. "Require Same Price Reaction" is what makes the indicator rare: switching it off takes the same 6000 bars from 16 marks to 147, and it also silently disables the three inputs above it, which do nothing whatsoever while it is off. And the volume threshold's default of 1.8 sits in the middle of a flat plateau - every value from 1.7 to 2.2 produces exactly the same 16 marks - so nudging it one step will usually appear to do nothing.

No edge is claimed and none was measured. There is no forward-return figure here, no hit rate, and no suggestion that a mark predicts anything.

HOW THE NUMBERS WERE CHECKED

The whole computation was reimplemented outside Pine and cross-checked against this chart's Data Window on five bars chosen in advance - three sell marks, one buy mark, and one bar that fires nothing so that a model marking everything could not pass. All five agree exactly, to the price rather than to a tolerance. The reimplementation then reproduces the entire firing set independently: the same 16 bars, at the same indices, over the same 6000.

WHAT CHANGED IN THIS VERSION

The previous version declared a compact volume profile - six inputs, three colour pickers, box and line arrays and a colour helper - and drew none of it: the file simply ended before that code existed. Shipping inputs that do nothing is the thing this publication is trying not to do, so the profile is gone and the title no longer claims one. What remains is the absorption test, which is complete and testable, plus an MPL header, the audit table, and a clamp on "Max Body / Range" so that the part of its slider that could never matter stops pretending it does.

Open source under MPL 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
indicator("DeepFlow Absorption Proxy [FibonacciFlux]", "DeepFlow Abs", overlay = true, max_labels_count = 500, max_bars_back = 5000)
// An OHLCV-only proxy for absorption: bars where volume spikes, the body stays small, one wick
// dominates, and price is revisiting a level it already reacted to. Real absorption is an
// order-book event and nothing in OHLCV can see resting size, so this marks a SHAPE, and the
// measurements below say it should be read as four filters intersecting rather than as one
// joint event.
//
// Measured at default inputs on the 6000 bars of BINANCE:BTCUSDT 15m ending 2026-08-18 13:00
// UTC (62 days): 16 marks, 0.27% of bars, 9 sell and 7 buy, minimum 26 bars apart. The rate is
// specific to the symbol AND the bar size, not a property of the indicator: BTCUSDT 1h 0.57%,
// BTCUSDT 4h 0.50%, ETHUSDT 15m 0.32%, ETHUSDT 1h 0.30%.
//
// Built for intraday bars. On daily and above it can go hundreds of bars without marking
// anything - on BTCUSDT 1D it marked nothing at all in 1000 days.
//
// What the measurements do NOT support: that the four gates know about each other. On the same
// 5951 scored bars a volume spike is no more likely on an absorption-shaped bar than on any
// other (sell candidates 0.99x, 95% CI 0.53-1.80; buy 0.75x, CI 0.36-1.45), and at n=123 an
// interaction smaller than about 1.6x would be invisible - so the joint reading is
// undemonstrated here, not disproved. Against a null that circularly shifts volume and leaves
// the candles alone, the real series marks 16 bars where the null averages about 19 (p05 12,
// p95 26, two-sided p = 0.59).
string GRP_ABS = "Absorption Proxy"
string GRP_VIS = "Visual Style"
int   atrLen        = input.int(14, "ATR Length", minval=1, maxval=100, group=GRP_ABS)
int   volLen        = input.int(50, "Volume Z-Score Length", minval=5, maxval=300, group=GRP_ABS)
float absorbVolZ    = input.float(1.8, "Absorption Volume Z-Score", minval=0.5, maxval=8.0, step=0.1, group=GRP_ABS)
float bodyRangeMax  = input.float(0.36, "Max Body / Range", minval=0.05, maxval=0.90, step=0.01, group=GRP_ABS,
     tooltip = "Capped internally at 1 minus the wick minimum. Body and wicks share the bar range, so a wick floor of 0.38 already limits the body to 0.62 - raising this above that changes nothing, and every value from 0.62 to 0.90 produced an identical signal series in testing.")
float wickRangeMin  = input.float(0.38, "Min Rejection Wick / Range", minval=0.05, maxval=0.95, step=0.01, group=GRP_ABS)
int   clusterLen    = input.int(18, "Same Price Cluster Lookback", minval=3, maxval=100, group=GRP_ABS,
     tooltip = "At the shipped 18 this gate is not doing what its name suggests on BTCUSDT 15m: bars sitting at an 18-bar extreme are about 28% LESS likely to carry a volume spike than bars that are not (0.72x, 95% CI 0.48-0.96), and 0.62x on ETHUSDT 15m. The relationship turns positive at longer lookbacks - around 60 bars it runs 1.3x to 2.5x across BTC and ETH at 15m and 1h - but the headline BTCUSDT 15m cell does not separate from a volume-shift null there either. The default is left at 18 because every number quoted in the description was measured at it.")
float clusterAtr    = input.float(0.28, "Cluster Distance ATR", minval=0.02, maxval=2.0, step=0.02, group=GRP_ABS)
bool  requireCluster = input.bool(true, "Require Same Price Reaction", group=GRP_ABS,
     tooltip = "Gates the three inputs above it: with this off, ATR Length, Same Price Cluster Lookback and Cluster Distance ATR have no effect on a single mark. It is also the switch that makes the indicator rare - turning it off takes BTCUSDT 15m from 16 marks to 147 over the same 6000 bars.")
color buyAbsColor     = input.color(color.rgb(0, 220, 200), "Buy Absorption", group=GRP_VIS)
color sellAbsColor    = input.color(color.rgb(190, 75, 255), "Sell Absorption", group=GRP_VIS)
bool  showLabels      = input.bool(false, "Show Absorption Labels", group=GRP_VIS)
var label[] absorbLabels = array.new_label()
trim_labels(label[] labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)
float atr = ta.atr(atrLen)
float volMean = ta.sma(volume, volLen)
float volStd  = ta.stdev(volume, volLen)
// For the first volLen bars ta.stdev is na and this falls through to 0.0, so a spike is
// structurally impossible there and no mark can appear - 49 bars at the default.
float volZ    = volStd != 0.0 and not na(volStd) ? (volume - volMean) / volStd : 0.0
float barRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float bodyRangeMaxEff = math.min(bodyRangeMax, 1.0 - wickRangeMin)
bool smallBody = body / barRange <= bodyRangeMaxEff
bool upperReject = upperWick / barRange >= wickRangeMin
bool lowerReject = lowerWick / barRange >= wickRangeMin
float priorHighCluster = ta.highest(high, clusterLen)[1]
float priorLowCluster  = ta.lowest(low, clusterLen)[1]
bool sameHigh = not na(priorHighCluster) and math.abs(high - priorHighCluster) <= atr * clusterAtr
bool sameLow  = not na(priorLowCluster) and math.abs(low - priorLowCluster) <= atr * clusterAtr
bool clusterHighOk = not requireCluster or sameHigh
bool clusterLowOk = not requireCluster or sameLow
bool volumeSpike = volZ >= absorbVolZ
bool sellAbsorption = volumeSpike and smallBody and upperReject and clusterHighOk and close < high - barRange * 0.25
bool buyAbsorption = volumeSpike and smallBody and lowerReject and clusterLowOk and close > low + barRange * 0.25
plotshape(buyAbsorption ? low : na, title="Buy Absorption Proxy", style=shape.circle, location=location.absolute, color=color.new(buyAbsColor, 0), size=size.small, text="ABS", textcolor=color.white)
plotshape(sellAbsorption ? high : na, title="Sell Absorption Proxy", style=shape.circle, location=location.absolute, color=color.new(sellAbsColor, 0), size=size.small, text="ABS", textcolor=color.white)
if showLabels and buyAbsorption
    label lb = label.new(x=bar_index, y=low, text="Buy Abs", style=label.style_label_up, color=color.new(buyAbsColor, 20), textcolor=color.white, size=size.tiny)
    array.push(absorbLabels, lb)
    trim_labels(absorbLabels, 80)
if showLabels and sellAbsorption
    label lb = label.new(x=bar_index, y=high, text="Sell Abs", style=label.style_label_down, color=color.new(sellAbsColor, 20), textcolor=color.white, size=size.tiny)
    array.push(absorbLabels, lb)
    trim_labels(absorbLabels, 80)

// -----------------------------------------------------------------------------
// Audit table - the four quantities the decision is made from, on the last bar
// -----------------------------------------------------------------------------
bool  showTable = input.bool(true, "Show audit table", group = GRP_VIS)
string tablePos = input.string("Bottom right", "Audit table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = GRP_VIS)

color cPanel = color.rgb(20, 23, 28)
color cLine = color.rgb(58, 63, 71)
color cInk = color.rgb(216, 220, 226)
color cDim = color.rgb(128, 132, 138)

tablePosition = tablePos == "Top left" ? position.top_left : tablePos == "Bottom right" ? position.bottom_right : tablePos == "Bottom left" ? position.bottom_left : position.top_right
var table auditTable = table.new(position.bottom_right, 3, 6, border_color = cLine, border_width = 1, frame_color = cLine, frame_width = 1)

f_row(int row, string label, string value, string verdict, color valueColor, color verdictColor) =>
    table.cell(auditTable, 0, row, label, text_color = cDim, text_size = size.small, bgcolor = cPanel, text_halign = text.align_left)
    table.cell(auditTable, 1, row, value, text_color = valueColor, text_size = size.small, bgcolor = cPanel, text_halign = text.align_right)
    table.cell(auditTable, 2, row, verdict, text_color = verdictColor, text_size = size.small, bgcolor = cPanel, text_halign = text.align_right)

if barstate.islast and showTable
    table.set_position(auditTable, tablePosition)
    color okCol = color.rgb(109, 141, 122)
    color noCol = color.rgb(128, 132, 138)

    f_row(0, "TEST", "value", "pass", cDim, cDim)
    f_row(1, "vol z", str.tostring(volZ, "0.00"), volumeSpike ? "yes" : "no", cInk, volumeSpike ? okCol : noCol)
    f_row(2, "body/rng", str.tostring(body / barRange, "0.00"), smallBody ? "yes" : "no", cInk, smallBody ? okCol : noCol)
    f_row(3, "up wick", str.tostring(upperWick / barRange, "0.00"), upperReject ? "yes" : "no", cInk, upperReject ? okCol : noCol)
    f_row(4, "low wick", str.tostring(lowerWick / barRange, "0.00"), lowerReject ? "yes" : "no", cInk, lowerReject ? okCol : noCol)
    string clusterTxt = requireCluster ? (sameHigh ? "at high" : sameLow ? "at low" : "no") : "off"
    f_row(5, "cluster", str.tostring(atr * clusterAtr, format.mintick), clusterTxt, cInk, clusterTxt == "no" ? noCol : okCol)
````
