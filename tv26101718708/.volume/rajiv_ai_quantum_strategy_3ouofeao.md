# RAJIV AI Quantum Strategy

- url: https://www.tradingview.com/script/3oUOfEAo-RAJIV-AI-Quantum-Strategy/
- type: indicator
- pine_id: PUB;4d3f28d2925947c1b93ccf069b414ecf
- version: 1.0

## Description

RAJIV AI Quantum Strategy — Description

The RAJIV AI Quantum Strategy is an advanced multi-indicator trading system designed for:

Intraday Trading
Scalping
Swing Trading
Momentum Trading
Trend Following

It combines multiple technical indicators into a single customizable strategy where traders can enable or disable indicators according to their trading style.

Main Features
1. Multi Indicator Confirmation

The script combines:

EMA Cross
RSI
ADX
MACD
ROC
Supertrend
VWAP
Hull MA
Volume Confirmation
Stochastic
Bollinger Bands
CCI
MFI
ATR Filter
Parabolic SAR
Ichimoku

You can turn ON/OFF any indicator from settings.

2. Smart Buy & Sell Signals

The strategy generates:

BUY signals
SELL signals

only when all selected indicators agree together.

This reduces:

false signals
fake breakouts
weak momentum entries
3. ATR Based Dynamic Stoploss

The stoploss is automatically calculated using:

SL=Entry±ATR

Benefits:

adapts to volatility
avoids fixed stoploss problems
works on all timeframes
4. ATR Based Risk Reward Targets

Targets are generated automatically using:

TP 1:2
TP 1:3
TP 1:4

Formula:

TP=Entry+(Risk×RR)

This helps:

partial profit booking
trailing trades
position management
5. Visual Entry System

The script automatically draws:

Buy Entry Line
Sell Entry Line
Stoploss Line
Target Lines

with labels directly on chart.

6. Institutional Confirmation

Optional confirmations include:

Volume Surge
VWAP Position
ATR Expansion
Trend Strength (ADX)
Momentum Shift (MACD/ROC)

This helps identify:

strong trend continuation
institutional buying/selling
momentum breakout moves
7. Fully Customizable

Users can:

add/remove indicators
change lengths
modify ATR multiplier
change RR targets
hide/show visuals
use only selected indicators
Best Timeframes

Recommended:

5 Min
15 Min
30 Min
1 Hour

Best for:

NSE Stocks
BankNifty
Nifty
Futures
Momentum Stocks
Trading Logic
BUY Setup

The strategy buys when:

selected indicators become bullish
momentum confirms
trend strength confirms
optional volume confirms
SELL Setup

The strategy sells when:

selected indicators become bearish
momentum weakens
trend reverses
optional volume confirms
Risk Management

The strategy is built around:

ATR based SL
Multi RR targets
Confirmation based entries

This improves:

risk control
trade accuracy
consistency
Suggested Indicator Combinations
Scalping

Enable:

EMA
RSI
MACD
VWAP
Intraday Momentum

Enable:

Supertrend
ADX
MACD
Volume
VWAP
Swing Trading

Enable:

Hull MA
Ichimoku
RSI
ADX
High Accuracy Setup

Enable:

EMA
RSI
ADX
MACD
VWAP
Volume
ATR Filter
Important Note

More indicators = fewer but stronger signals.

Fewer indicators = more signals but higher risk.

For best results:

use proper risk management
avoid sideways markets
trade with trend
combine with support/resistance zones

## Source Code

````pine
//@version=6
indicator("RAJIV AI Quantum Strategy", overlay = true,
     max_lines_count = 500,
     max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INDICATOR OPTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
useEMA        = input.bool(true,  "EMA Cross")
useRSI        = input.bool(true,  "RSI")
useADX        = input.bool(true,  "ADX")
useMACD       = input.bool(true,  "MACD")
useROC        = input.bool(false, "ROC")
useSupertrend = input.bool(false, "Supertrend")
useVWAP       = input.bool(false, "VWAP")
useHull       = input.bool(false, "Hull MA")
useVolume     = input.bool(false, "Volume Confirmation")
useStoch      = input.bool(false, "Stochastic")
useBB         = input.bool(false, "Bollinger Band")
useCCI        = input.bool(false, "CCI")
useMFI        = input.bool(false, "MFI")
useATRFilter  = input.bool(false, "ATR Trend Filter")
useSAR        = input.bool(false, "Parabolic SAR")
useIchimoku   = input.bool(false, "Ichimoku")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY OPTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showSignals   = input.bool(true, "Show Signals")
showSL        = input.bool(true, "Show Stoploss")
showTP        = input.bool(true, "Show Targets")
showBG        = input.bool(false, "Background")
showEMAPlot   = input.bool(true, "Show EMA")
showVWAPPlot  = input.bool(true, "Show VWAP")
showHullPlot  = input.bool(true, "Show Hull")
showBBPlot    = input.bool(false, "Show BB")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFastLen = input.int(9, "EMA Fast")
emaSlowLen = input.int(21, "EMA Slow")

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

bullEMA = ta.crossover(emaFast, emaSlow)
bearEMA = ta.crossunder(emaFast, emaSlow)

plot(useEMA and showEMAPlot ? emaFast : na,
     color = color.lime,
     linewidth = 2)

plot(useEMA and showEMAPlot ? emaSlow : na,
     color = color.red,
     linewidth = 2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiLen  = input.int(14, "RSI Length")

rsi = ta.rsi(close, rsiLen)

bullRSI = rsi > 55
bearRSI = rsi < 45

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADX
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
adxLen   = input.int(14, "ADX Length")
adxLevel = input.int(20, "ADX Strength")

upMove   = high - high[1]
downMove = low[1] - low

plusDM  = (upMove > downMove and upMove > 0) ? upMove : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0

trur = ta.rma(ta.tr, adxLen)

plusDI  = 100 * ta.rma(plusDM, adxLen) / trur
minusDI = 100 * ta.rma(minusDM, adxLen) / trur

dx  = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx = ta.rma(dx, adxLen)

bullADX = adx > adxLevel
bearADX = adx > adxLevel

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MACD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[macdLine, signalLine, _] =
     ta.macd(close, 12, 26, 9)

bullMACD = ta.crossover(macdLine, signalLine)
bearMACD = ta.crossunder(macdLine, signalLine)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ROC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
roc = ta.roc(close, 9)

bullROC = roc > 0
bearROC = roc < 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPERTREND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[supertrend, direction] =
     ta.supertrend(3.0, 10)

bullSuper = direction < 0
bearSuper = direction > 0

plot(useSupertrend ? supertrend : na,
     color = bullSuper ? color.green : color.red,
     linewidth = 2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vwapValue = ta.vwap(close)

bullVWAP = close > vwapValue
bearVWAP = close < vwapValue

plot(useVWAP and showVWAPPlot ? vwapValue : na,
     color = color.blue,
     linewidth = 2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HULL MA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hull = ta.hma(close, 55)

bullHull = close > hull
bearHull = close < hull

plot(useHull and showHullPlot ? hull : na,
     color = color.orange,
     linewidth = 2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLUME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volSMA = ta.sma(volume, 20)

bullVolume = volume > volSMA * 1.5
bearVolume = volume > volSMA * 1.5

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STOCHASTIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
stochK = ta.stoch(close, high, low, 14)

bullStoch = ta.crossover(stochK, 20)
bearStoch = ta.crossunder(stochK, 80)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BOLLINGER BAND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
basis = ta.sma(close, 20)
dev   = ta.stdev(close, 20) * 2

upperBB = basis + dev
lowerBB = basis - dev

bullBB = close > basis
bearBB = close < basis

plot(useBB and showBBPlot ? upperBB : na,
     color = color.gray)

plot(useBB and showBBPlot ? lowerBB : na,
     color = color.gray)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CCI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cci = ta.cci(close, 20)

bullCCI = cci > 100
bearCCI = cci < -100

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MFI FIXED
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mfiLen = input.int(14, "MFI Length")

mfi = ta.mfi(hlc3, mfiLen)

bullMFI = mfi > 50
bearMFI = mfi < 50

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(14)
atrMA = ta.sma(atr, 14)

bullATR = atr > atrMA
bearATR = atr > atrMA

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PARABOLIC SAR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
sar = ta.sar(0.02, 0.02, 0.2)

bullSAR = close > sar
bearSAR = close < sar

plot(useSAR ? sar : na,
     style = plot.style_cross,
     color = color.fuchsia)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ICHIMOKU
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tenkan =
     (ta.highest(high, 9) +
     ta.lowest(low, 9)) / 2

kijun =
     (ta.highest(high, 26) +
     ta.lowest(low, 26)) / 2

bullIchi = tenkan > kijun
bearIchi = tenkan < kijun

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENABLE CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaBuy   = useEMA        ? bullEMA     : true
emaSell  = useEMA        ? bearEMA     : true

rsiBuy   = useRSI        ? bullRSI     : true
rsiSell  = useRSI        ? bearRSI     : true

adxBuy   = useADX        ? bullADX     : true
adxSell  = useADX        ? bearADX     : true

macdBuy  = useMACD       ? bullMACD    : true
macdSell = useMACD       ? bearMACD    : true

rocBuy   = useROC        ? bullROC     : true
rocSell  = useROC        ? bearROC     : true

superBuy = useSupertrend ? bullSuper   : true
superSell= useSupertrend ? bearSuper   : true

vwapBuy  = useVWAP       ? bullVWAP    : true
vwapSell = useVWAP       ? bearVWAP    : true

hullBuy  = useHull       ? bullHull    : true
hullSell = useHull       ? bearHull    : true

volBuy   = useVolume     ? bullVolume  : true
volSell  = useVolume     ? bearVolume  : true

stochBuy = useStoch      ? bullStoch   : true
stochSell= useStoch      ? bearStoch   : true

bbBuy    = useBB         ? bullBB      : true
bbSell   = useBB         ? bearBB      : true

cciBuy   = useCCI        ? bullCCI     : true
cciSell  = useCCI        ? bearCCI     : true

mfiBuy   = useMFI        ? bullMFI     : true
mfiSell  = useMFI        ? bearMFI     : true

atrBuy   = useATRFilter  ? bullATR     : true
atrSell  = useATRFilter  ? bearATR     : true

sarBuy   = useSAR        ? bullSAR     : true
sarSell  = useSAR        ? bearSAR     : true

ichiBuy  = useIchimoku   ? bullIchi    : true
ichiSell = useIchimoku   ? bearIchi    : true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buySignal =
     emaBuy and
     rsiBuy and
     adxBuy and
     macdBuy and
     rocBuy and
     superBuy and
     vwapBuy and
     hullBuy and
     volBuy and
     stochBuy and
     bbBuy and
     cciBuy and
     mfiBuy and
     atrBuy and
     sarBuy and
     ichiBuy

sellSignal =
     emaSell and
     rsiSell and
     adxSell and
     macdSell and
     rocSell and
     superSell and
     vwapSell and
     hullSell and
     volSell and
     stochSell and
     bbSell and
     cciSell and
     mfiSell and
     atrSell and
     sarSell and
     ichiSell

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR RR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atrSL = atr * 1.0

buyEntry = close
buySL    = buyEntry - atrSL

buyRisk = buyEntry - buySL

buyTP2 = buyEntry + (buyRisk * 2)
buyTP3 = buyEntry + (buyRisk * 3)
buyTP4 = buyEntry + (buyRisk * 4)

sellEntry = close
sellSL    = sellEntry + atrSL

sellRisk = sellSL - sellEntry

sellTP2 = sellEntry - (sellRisk * 2)
sellTP3 = sellEntry - (sellRisk * 3)
sellTP4 = sellEntry - (sellRisk * 4)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     showSignals and buySignal,
     title = "BUY",
     style = shape.labelup,
     location = location.belowbar,
     color = color.green,
     text = "RAJIV BUY",
     textcolor = color.white)

plotshape(
     showSignals and sellSignal,
     title = "SELL",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.red,
     text = "RAJIV SELL",
     textcolor = color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUY LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if buySignal

    line.new(bar_index, buyEntry, bar_index + 20, buyEntry,
         color = color.green, width = 3)

    if showSL
        line.new(bar_index, buySL, bar_index + 20, buySL,
             color = color.red, width = 2)

    if showTP
        line.new(bar_index, buyTP2, bar_index + 20, buyTP2,
             color = color.blue)

        line.new(bar_index, buyTP3, bar_index + 20, buyTP3,
             color = color.blue)

        line.new(bar_index, buyTP4, bar_index + 20, buyTP4,
             color = color.blue)

    label.new(bar_index, buyEntry, "BUY ENTRY",
         color = color.green,
         textcolor = color.white)

    if showSL
        label.new(bar_index, buySL, "SL")

    if showTP
        label.new(bar_index, buyTP2, "TP 1:2")
        label.new(bar_index, buyTP3, "TP 1:3")
        label.new(bar_index, buyTP4, "TP 1:4")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SELL LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if sellSignal

    line.new(bar_index, sellEntry, bar_index + 20, sellEntry,
         color = color.red, width = 3)

    if showSL
        line.new(bar_index, sellSL, bar_index + 20, sellSL,
             color = color.green, width = 2)

    if showTP
        line.new(bar_index, sellTP2, bar_index + 20, sellTP2,
             color = color.orange)

        line.new(bar_index, sellTP3, bar_index + 20, sellTP3,
             color = color.orange)

        line.new(bar_index, sellTP4, bar_index + 20, sellTP4,
             color = color.orange)

    label.new(bar_index, sellEntry, "SELL ENTRY",
         color = color.red,
         textcolor = color.white)

    if showSL
        label.new(bar_index, sellSL, "SL")

    if showTP
        label.new(bar_index, sellTP2, "TP 1:2")
        label.new(bar_index, sellTP3, "TP 1:3")
        label.new(bar_index, sellTP4, "TP 1:4")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BACKGROUND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bgcolor(
     showBG ?
     buySignal ?
     color.new(color.green, 92) :
     sellSignal ?
     color.new(color.red, 92) :
     na : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(
     buySignal,
     title = "RAJIV BUY",
     message = "RAJIV BUY SIGNAL")

alertcondition(
     sellSignal,
     title = "RAJIV SELL",
     message = "RAJIV SELL SIGNAL")
````
