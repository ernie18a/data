<!-- tradingview-pine-id: PUB;3a0362aa454442f885b87cf556edf9eb -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Supertrend + MA Crossover [SACHIN]

Source: https://www.tradingview.com/script/lSWZVbuz-Adaptive-Supertrend-MA-Crossover-Strategy/

## Description

Adaptive Supertrend MA Crossover

Overview
This strategy trades the crossover between a Moving Average and a Supertrend line - a classic trend-following combination - but with two design choices that set it apart from the standard version of this idea already published elsewhere:
 
1. The Supertrend and the Moving Average each take their own independently selectable price source (Open, High, Low, Close, HL2, HLC3, OHLC4, or HLCC4), rather than both being locked to Close.
 
2. A new Moving Average source option: "EMA of Supertrend." Instead of feeding the MA a raw price series, this applies an EMA directly to the Supertrend line itself, and then runs your chosen MA type (SMA/EMA/HMA/WMA) on top of that smoothed line. The result is a crossover between two different "views" of the same underlying trend structure, rather than a crossover between price and trend.
 
Why "EMA of Supertrend" matters
 
A standard Supertrend line is deliberately steppy - it holds a level and jumps, rather than moving smoothly, which is what makes it useful as a stop/trend marker but also means a plain price-vs-Supertrend crossover can be noisy on choppy days (price whipsaws across a flat Supertrend step repeatedly).
 
Applying an EMA to the Supertrend line first produces a smoothed trend proxy that still reacts to genuine Supertrend flips, but rounds off the sharp step edges. Running your chosen Moving Average on top of that, rather than on top of price, means the crossover signal is comparing two related measures of trend, not fighting against Supertrend's inherent steppiness. This tends to produce fewer false flips in sideways conditions while still catching genuine trend changes, without adding a second unrelated indicator to the chart.
 
This source option is exposed directly in the settings (MA Source = "EMA of Supertrend"), with its own dedicated smoothing period, so it's a toggle away from the standard price-source approach for direct comparison on your own charts.
 
https://www.tradingview.com/x/MYMYqXmq/

Caption: Chart example on GOLDPETAL, 15-min: long & short entry on the MA-Supertrend crossover.
 
How it works
 
Supertrend: calculated from your selected source (default HL2, the traditional Supertrend basis) with a configurable ATR Period and ATR Factor. Unlike TradingView's built-in Supertrend function (which is hard-coded to HL2), this version lets the basis price and the trend-flip check both use whichever source you select.
 
Moving Average: choose SMA, EMA, HMA (Hull), or WMA, computed on your selected source, including the "EMA of Supertrend" option described above.
 
Entry signal: long when the Moving Average crosses above the Supertrend line, short on the opposite cross.
 
Reverse Trading Mode: a single toggle that inverts the signal (useful for quickly testing whether the opposite side of a crossover performs better on a given instrument/timeframe, without rebuilding the logic).
 
Stop Loss / Take Profit: both optional and independently toggleable, with a shared basis switch between Percentage (of entry price) and Points, so the same settings panel works whether you're trading a low-priced or high-priced instrument.
 
Settings guide
(select this whole list after pasting and click the bullet-list button)
 
Supertrend Source - price series used for the Supertrend basis and trend-flip check
ATR Period / ATR Factor - standard Supertrend volatility inputs
MA Type - SMA / EMA / HMA / WMA
MA Source - price source, or "EMA of Supertrend"
EMA of Supertrend Period - smoothing period applied to the Supertrend line (only active when MA Source = EMA of Supertrend)
Reverse Trading Mode - inverts long/short signals
Use SL / Use TP, Basis, Values - optional exit management, Percentage or Points
 
https://www.tradingview.com/x/sbpISKxS/

Caption: Strategy Tester summary, GOLDPETAL futures, 15-min, [Jun 12, 2026 - Sep 11, 2026], default settings.
 
Disclaimer:
 
This script is a technical trading tool for educational and informational purposes. It does not constitute financial advice, and past performance in backtesting does not guarantee future results. Always test thoroughly on your own instruments and timeframes, and use appropriate risk management, before considering live use.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sachinlanke

// Supertrend + Moving Average Crossover Strategy
// Long when the Moving Average crosses above the Supertrend line, short on the opposite cross
// (or inverted, if Reverse Trading Mode is enabled).
//
// Both the Supertrend and the Moving Average take their own independently selectable price
// source (Open/High/Low/Close/HL2/HLC3/OHLC4/HLCC4). The Moving Average additionally supports
// "EMA of Supertrend" as a source - an EMA of the Supertrend line itself, which the chosen
// Moving Average type is then applied on top of.

//@version=6
strategy("Supertrend + MA Crossover [SACHIN]", overlay = true, pyramiding = 0)

// ═══════════════════════════ SUPERTREND ═══════════════════════════
grp_st = "Supertrend"
stSourceType = input.string(defval = "HL2", title = "Supertrend Source", options = ["Open", "High", "Low", "Close", "HL2", "HLC3", "OHLC4", "HLCC4"], group = grp_st, tooltip = "Price series used as the Supertrend basis (band midpoint) and for the trend-flip check. HL2 is the classic Supertrend default.")
stAtrPeriod = input.int(defval = 10, title = "ATR Period", minval = 1, group = grp_st)
stFactor = input.float(defval = 3.0, title = "ATR Factor", minval = 0.1, step = 0.1, group = grp_st)

// ═══════════════════════════ MOVING AVERAGE ═══════════════════════════
grp_ma = "Moving Average"
maType = input.string(defval = "EMA", title = "MA Type", options = ["SMA", "EMA", "HMA", "WMA"], group = grp_ma)
maLength = input.int(defval = 20, title = "MA Length", minval = 1, group = grp_ma)
maSourceType = input.string(defval = "Close", title = "MA Source", options = ["Open", "High", "Low", "Close", "HL2", "HLC3", "OHLC4", "HLCC4", "EMA of Supertrend"], group = grp_ma, tooltip = "EMA of Supertrend: the Moving Average is applied on top of an EMA-smoothed Supertrend line instead of a raw price series.")
emaOfStPeriod = input.int(defval = 5, title = "EMA of Supertrend Period", minval = 1, group = grp_ma, tooltip = "Only used when MA Source = EMA of Supertrend.")

// ═══════════════════════════ TRADING MODE ═══════════════════════════
grp_mode = "Trading Mode"
reverseMode = input.bool(defval = false, title = "Reverse Trading Mode", group = grp_mode, tooltip = "When enabled, inverts the signal: short when MA crosses above Supertrend, long when MA crosses below.")

// ═══════════════════════════ STOP LOSS / TAKE PROFIT ═══════════════════════════
grp_sltp = "Stop Loss / Take Profit"
useSL = input.bool(defval = true, title = "Use Stop Loss", group = grp_sltp)
useTP = input.bool(defval = true, title = "Use Take Profit", group = grp_sltp)
slTpMode = input.string(defval = "Percentage", title = "SL/TP Basis", options = ["Percentage", "Points"], group = grp_sltp)
slValue = input.float(defval = 1.0, title = "Stop Loss Value", minval = 0.0, group = grp_sltp, tooltip = "Percent of entry price if Basis = Percentage, else price points.")
tpValue = input.float(defval = 2.0, title = "Take Profit Value", minval = 0.0, group = grp_sltp, tooltip = "Percent of entry price if Basis = Percentage, else price points.")

// ═══════════════════════════ SOURCE / MA HELPERS ═══════════════════════════
f_getSource(t) =>
    t == "Open" ? open :
     t == "High" ? high :
     t == "Low" ? low :
     t == "Close" ? close :
     t == "HL2" ? hl2 :
     t == "HLC3" ? hlc3 :
     t == "OHLC4" ? ohlc4 :
     t == "HLCC4" ? hlcc4 : close

f_ma(t, src, len) =>
    t == "SMA" ? ta.sma(src, len) :
     t == "EMA" ? ta.ema(src, len) :
     t == "WMA" ? ta.wma(src, len) :
     t == "HMA" ? ta.hma(src, len) : ta.sma(src, len)

// ═══════════════════════════ SUPERTREND (custom, source-selectable) ═══════════════════════════
stSrc = f_getSource(stSourceType)
atrSt = ta.atr(stAtrPeriod)

upperBand = stSrc + stFactor * atrSt
lowerBand = stSrc - stFactor * atrSt

var float finalUpperBand = na
var float finalLowerBand = na
finalUpperBand := na(finalUpperBand[1]) ? upperBand : (upperBand < finalUpperBand[1] or stSrc[1] > finalUpperBand[1]) ? upperBand : finalUpperBand[1]
finalLowerBand := na(finalLowerBand[1]) ? lowerBand : (lowerBand > finalLowerBand[1] or stSrc[1] < finalLowerBand[1]) ? lowerBand : finalLowerBand[1]

var int stDir = 1
stDir := na(atrSt[1]) ? 1 : (stDir[1] == -1 and stSrc > finalUpperBand[1]) ? 1 : (stDir[1] == 1 and stSrc < finalLowerBand[1]) ? -1 : stDir[1]

stLine = stDir == 1 ? finalLowerBand : finalUpperBand
stColor = stDir == 1 ? color.lime : color.red

// ═══════════════════════════ MOVING AVERAGE (source-selectable, incl. EMA of Supertrend) ═══════════════════════════
maBaseSrc = maSourceType == "EMA of Supertrend" ? ta.ema(stLine, emaOfStPeriod) : f_getSource(maSourceType)
maLine = f_ma(maType, maBaseSrc, maLength)

// ═══════════════════════════ ENTRY LOGIC ═══════════════════════════
crossUp = ta.crossover(maLine, stLine)
crossDn = ta.crossunder(maLine, stLine)

longCondition = (reverseMode ? crossDn : crossUp) and barstate.isconfirmed
shortCondition = (reverseMode ? crossUp : crossDn) and barstate.isconfirmed

if longCondition
    strategy.entry("Long", strategy.long, comment = "Long")

if shortCondition
    strategy.entry("Short", strategy.short, comment = "Short")

// ═══════════════════════════ STOP LOSS / TAKE PROFIT ═══════════════════════════
longSLPrice  = slTpMode == "Percentage" ? strategy.position_avg_price * (1 - slValue / 100) : strategy.position_avg_price - slValue
longTPPrice  = slTpMode == "Percentage" ? strategy.position_avg_price * (1 + tpValue / 100) : strategy.position_avg_price + tpValue
shortSLPrice = slTpMode == "Percentage" ? strategy.position_avg_price * (1 + slValue / 100) : strategy.position_avg_price + slValue
shortTPPrice = slTpMode == "Percentage" ? strategy.position_avg_price * (1 - tpValue / 100) : strategy.position_avg_price - tpValue

if strategy.position_size > 0
    strategy.exit("Long Exit", from_entry = "Long", limit = useTP ? longTPPrice : na, stop = useSL ? longSLPrice : na)

if strategy.position_size < 0
    strategy.exit("Short Exit", from_entry = "Short", limit = useTP ? shortTPPrice : na, stop = useSL ? shortSLPrice : na)

// ═══════════════════════════ PLOTS ═══════════════════════════
plot(stLine, title = "Supertrend", color = stColor, linewidth = 2)
plot(maLine, title = "Moving Average", color = color.new(color.blue, 0), linewidth = 1)

plotshape(longCondition, title = "Long Signal", style = shape.triangleup, location = location.belowbar, color = color.lime, size = size.tiny)
plotshape(shortCondition, title = "Short Signal", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny)
````
