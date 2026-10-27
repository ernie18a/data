# Ultimate Scalp MoBo + RSI + Mult-MA + MACD Configuration

- url: https://www.tradingview.com/script/Bvpqommk-Ultimate-Scalp-MoBo-RSI-Mult-MA-MACD-Configuration/
- type: indicator
- pine_id: PUB;f481c9b40b404d9bab9734c1970006f4
- version: 1.0

## Description

[b]Overview[/b]
The[b] Ultimate Scalp Configuration[/b] is a comprehensive trend-following and pullback execution system designed specifically for scalpers and day traders. Rather than simply overlaying indicators, this script synchronizes three distinct technical layers—Trend, Volatility-Adjusted Momentum, and Price Action—to identify high-probability entries at the precise moment a pullback ends and a trend resumes.

[b]How It Works (The "Synergy")[/b]
This script uses a modular approach to filtering out "market noise," which is the primary challenge in lower-timeframe scalping:

- The Trend Layer (Multi-MA Engine): The script utilizes a fanned-out Moving Average structure (9, 50, and 200 lengths). Users can choose from 12 advanced MA types, including Zero-Lag EMA (ZLEMA) and Fractal Adaptive Moving Average (FRAMA). These are used to determine the "Path of Least Resistance." A signal only fires when the trend is perfectly aligned (Fast > Medium > Slow).

- The Volatility Layer (MoBo Bands): Momentum Breakout (MoBo) Bands are derived from Standard Deviation. They act as a volatility filter, ensuring that a "Buy" or "Sell" signal only occurs when the price has enough momentum to break out of its immediate value area.

- The Momentum Filter (RSI & MACD): To prevent "buying the top," the script cross-references the Relative Strength Index (RSI) and MACD Histogram. These ensure that momentum is not only trending but is actively accelerating in the direction of the trade.

- The Execution Layer (EMA Touch & Price Action): The primary trigger is a mean-reversion "touch" of the 9-period Fast EMA. To confirm the reversal, the script scans for one of eight institutional candlestick patterns (e.g., Morning/Evening Stars, Tweezers, or Pin Bars).

[b]Key Features[/b]
- 12 Selectable MA Types: Adapt to different market conditions (Forex, Crypto, or Futures) by switching between GMA, VIDYA, KAMA, and more.

- Advanced Price Action Detection: Integrated logic for Hammer, Shooting Star, Tweezer, Inside Bar, and Dark Cloud patterns as signal requirements.

- Secondary Volatility Filters: Built-in ADX (Trend Strength) and ATR (Volatility) filters to keep you out of sideways, low-volume markets.

- Signal Cooldown: Prevents repetitive "over-trading" by enforcing a minimum bar distance between consecutive signals.

- Dynamic TP/SL Zones: The 50 and 200 MAs are highlighted as primary dynamic levels for taking profit or placing trailing stops.

[b]How To Use[/b]
Identify the Trend: Ensure the 50 (Orange) and 200 (Blue) MAs are fanned out and the price is above/below them.

- Wait for the Pullback: Look for the price to return and "touch" the 9 EMA (Signal Line).
The Entry: Enter on the BUY or SELL label, which signifies that the pullback has met all MoBo, RSI, MACD, and Candlestick requirements.

- Management: Use the Orange MA (50) as your first Take Profit or "Break Even" zone, and the Blue MA (200) as your ultimate trend reversal stop.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb



//@version=6
indicator("Ultimate Scalp MoBo + RSI + Mult-MA + MACD Configuration", overlay = true, shorttitle = "UltScalp_MoBo")

// --- Inputs ---
maType      = input.string("ZLEMA", "Moving Average Type", options = ["ZLEMA", "GMA", "FRAMA", "FibMA", "VIDYA", "LWMA", "TMA", "VWMA", "KAMA", "VMA", "SMA", "EMA"], group = "MA Settings")
src         = input.source(close, "Source", group = "MA Settings")

// Signal Filters
useMoBo     = input.bool(true, "Filter by MoBo Breakout", group = "Signal Filters")
useRSI      = input.bool(true, "Filter by RSI (>50 Bull / <50 Bear)", group = "Signal Filters")
useMACD     = input.bool(true, "Filter by MACD Histogram/Trend", group = "Signal Filters")

// Candle Pattern Toggles
useCandles  = input.bool(true, "Require Candle Pattern", group = "Candle Patterns")
p_morning   = input.bool(true, "Morning/Evening Star", group = "Candle Patterns")
p_hammer    = input.bool(true, "Hammer/Shooting Star", group = "Candle Patterns")
p_pinbar    = input.bool(true, "Pin Bars", group = "Candle Patterns")
p_inside    = input.bool(true, "Inside Bars", group = "Candle Patterns")
p_tweezer   = input.bool(true, "Tweezers", group = "Candle Patterns")
p_darkcloud = input.bool(true, "Dark Cloud/Piercing", group = "Candle Patterns")

// Oscillators & Bands Parameters
rsiLen      = input.int(14, "RSI Length", minval = 1, group = "Oscillators")
macdFast    = input.int(12, "MACD Fast Length", group = "Oscillators")
macdSlow    = input.int(26, "MACD Slow Length", group = "Oscillators")
macdSign    = input.int(9, "MACD Signal Length", group = "Oscillators")
moboLen     = input.int(20, "MoBo Band Length", group = "Oscillators")
moboMult    = input.float(2.0, "MoBo Multiplier", group = "Oscillators")

// --- Filter Sections ---
// ADX Filter Settings
useADX      = input.bool(true, "Use ADX Filter", group = "ADX Filter")
adxLen      = input.int(14, "ADX Length", group = "ADX Filter")
adxThresh   = input.int(20, "ADX Threshold", group = "ADX Filter")

// ATR Filter Settings
useATR      = input.bool(false, "Use ATR Volatility Filter", group = "ATR Filter")
atrLen      = input.int(14, "ATR Length", group = "ATR Filter")
atrThresh   = input.float(0.0001, "ATR Min Threshold", step = 0.0001, group = "ATR Filter")

// Cooldown Setting
cooldown    = input.int(15, "Signal Cooldown (Bars)", minval = 0, group = "Cooldown Settings")

// Visual Settings
colorBull   = input.color(#089981, "Bullish Color", group = "Visuals")
colorBear   = input.color(#f23645, "Bearish Color", group = "Visuals")

// --- MA Functions ---
calcZLEMA(source, len) =>
    lag = math.floor((len - 1) / 2)
    data = source + (source - source[lag])
    ta.ema(data, len)

calcGMA(source, len) => math.exp(ta.sma(math.log(source), len))

calcFRAMA(source, len) =>
    n = len % 2 == 0 ? len : len + 1
    n3 = n / 2
    hh1 = ta.highest(high, n3), ll1 = ta.lowest(low, n3), n1 = (hh1 - ll1) / n3
    hh2 = ta.highest(high[n3], n3), ll2 = ta.lowest(low[n3], n3), n2 = (hh2 - ll2) / n3
    hh3 = ta.highest(high, n), ll3 = ta.lowest(low, n), n0 = (hh3 - ll3) / n
    dimen = n1 > 0 and n2 > 0 and n0 > 0 ? (math.log(n1 + n2) - math.log(n0)) / math.log(2) : 0.0
    alpha = math.exp(-4.6 * (dimen - 1))
    alpha := math.max(math.min(alpha, 1), 0.01)
    var float frama = na
    frama := na(frama[1]) ? source : alpha * source + (1 - alpha) * nz(frama[1])
    frama

calcVIDYA(source, len) =>
    float val = na
    alpha = 2 / (len + 1)
    cmo = math.abs(ta.cmo(source, len)) / 100
    val := alpha * cmo * source + (1 - alpha * cmo) * nz(val[1], source)
    val

calcKAMA(source, len) =>
    change = math.abs(source - source[len]), volat = math.sum(math.abs(source - source[1]), len)
    er = volat != 0 ? change / volat : 0
    sc = math.pow(er * (2 / 3 - 2 / 31) + 2 / 31, 2)
    var float kama = na
    kama := nz(kama[1], source) + sc * (source - nz(kama[1], source))
    kama

getMA(source, len, type) =>
    switch type
        "ZLEMA" => calcZLEMA(source, len)
        "GMA"   => calcGMA(source, len)
        "FRAMA" => calcFRAMA(source, len)
        "FibMA" => ta.ema(source, len)
        "VIDYA" => calcVIDYA(source, len)
        "LWMA"  => ta.wma(source, len)
        "TMA"   => ta.sma(ta.sma(source, math.ceil((len + 1) / 2)), math.floor((len + 1) / 2))
        "VWMA"  => ta.vwma(source, len)
        "KAMA"  => calcKAMA(source, len)
        "VMA"   => calcVIDYA(source, len)
        "SMA"   => ta.sma(source, len)
        "EMA"   => ta.ema(source, len)
        => ta.sma(source, len)

// --- Calculations ---
ma9   = getMA(src, 9, maType)
ma50  = getMA(src, 50, maType)
ma200 = getMA(src, 200, maType)

moboBasis = ta.sma(src, moboLen)
moboDev   = moboMult * ta.stdev(src, moboLen)
moboUpper = moboBasis + moboDev
moboLower = moboBasis - moboDev

rsiVal = ta.rsi(src, rsiLen)
[macdLine, signalLine, _] = ta.macd(src, macdFast, macdSlow, macdSign)

// Logic for ADX and ATR Filters
[_, _, adxValue] = ta.dmi(adxLen, adxLen)
f_adx = not useADX or adxValue > adxThresh

atrValue = ta.atr(atrLen)
f_atr = not useATR or atrValue > atrThresh

// --- Candle Pattern Detection ---
bodySize = math.abs(open - close)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
fullRange = high - low

isHammer = p_hammer and lowerWick > bodySize * 1.5 and upperWick < bodySize * 0.5
isShootingStar = p_hammer and upperWick > bodySize * 1.5 and lowerWick < bodySize * 0.5
isPinBull = p_pinbar and lowerWick > fullRange * 0.6
isPinBear = p_pinbar and upperWick > fullRange * 0.6
isInsideBar = p_inside and high < high[1] and low > low[1]
isTweezerBottom = p_tweezer and math.abs(low - low[1]) <= (fullRange * 0.1) and low < math.min(open, close)
isTweezerTop    = p_tweezer and math.abs(high - high[1]) <= (fullRange * 0.1) and high > math.max(open, close)
isPiercing = p_darkcloud and close[1] < open[1] and open < low[1] and close > (open[1] + close[1])/2 and close < open[1]
isDarkCloud = p_darkcloud and close[1] > open[1] and open > high[1] and close < (open[1] + close[1])/2 and close > open[1]
isMorningStar = p_morning and close[2] < open[2] and bodySize[1] < (high[1]-low[1])*0.3 and close > open and close > (open[2]+close[2])/2
isEveningStar = p_morning and close[2] > open[2] and bodySize[1] < (high[1]-low[1])*0.3 and close < open and close < (open[2]+close[2])/2

patternBull = isHammer or isPinBull or isInsideBar or isTweezerBottom or isPiercing or isMorningStar
patternBear = isShootingStar or isPinBear or isInsideBar or isTweezerTop or isDarkCloud or isEveningStar

// --- Signal Logic ---
emaTouchBull = low <= ma9 and close > ma9
emaTouchBear = high >= ma9 and close < ma9

trendBull = ma9 > ma50 and ma50 > ma200
trendBear = ma9 < ma50 and ma50 < ma200

f_moboBull = not useMoBo or src > moboUpper
f_moboBear = not useMoBo or src < moboLower
f_rsiBull  = not useRSI or rsiVal > 50
f_rsiBear  = not useRSI or rsiVal < 50
f_macdBull = not useMACD or macdLine > signalLine
f_macdBear = not useMACD or macdLine < signalLine

// Cooldown Management
var int lastSignalBar = -cooldown
canSignal = (bar_index - lastSignalBar) >= cooldown

buySignal  = trendBull and emaTouchBull and f_moboBull and f_rsiBull and f_macdBull and f_adx and f_atr and (not useCandles or patternBull) and canSignal
sellSignal = trendBear and emaTouchBear and f_moboBear and f_rsiBear and f_macdBear and f_adx and f_atr and (not useCandles or patternBear) and canSignal

if buySignal or sellSignal
    lastSignalBar := bar_index

// --- Visuals ---
plot(ma9, "Fast EMA (Signal)", color = color.new(chart.fg_color, 40))
plot(ma50, "MA 50 (TP/SL)", color = color.new(color.orange, 0), linewidth = 2)
plot(ma200, "MA 200 (TP/SL)", color = color.new(color.blue, 0), linewidth = 2)

pUpper = plot(moboUpper, "MoBo Upper", color = color.new(color.teal, 80))
pLower = plot(moboLower, "MoBo Lower", color = color.new(color.maroon, 80))
fill(pUpper, pLower, color = color.new(color.gray, 95))

barcolor(buySignal ? colorBull : sellSignal ? colorBear : na)
plotshape(buySignal, "Buy", style = shape.triangleup, location = location.belowbar, color = colorBull, size = size.small, text = "BUY", textcolor = colorBull)
plotshape(sellSignal, "Sell", style = shape.triangledown, location = location.abovebar, color = colorBear, size = size.small, text = "SELL", textcolor = colorBear)

// Label Targets
if barstate.islast
    label.new(bar_index, ma50, "TP/SL 1 (50 MA)", color = #00000000, textcolor = color.orange, style = label.style_label_left, size = size.small)
    label.new(bar_index, ma200, "TP/SL 2 (200 MA)", color = #00000000, textcolor = color.blue, style = label.style_label_left, size = size.small)
````
