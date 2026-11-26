# Ultimate Swing Pro [Fully Customizable]

- url: https://www.tradingview.com/script/o1WSRbD8-Ultimate-Swing-Pro-Fully-Customizable/
- type: indicator
- pine_id: PUB;8962ffe3c92a4cb1bb08076addb5a54e
- version: 1.0

## Description

Created for swing trading for personal use using various indicators for better trend confirmation . fully customizable

## Source Code

````pine
//@version=6
indicator("Ultimate Swing Pro [Fully Customizable]", overlay=true)

// =====================================================================
// 1. HULL SUITE SETTINGS
// =====================================================================
hullLength  = input.int(55, title="Hull Length", group="1. Hull Suite Settings")
hullBullCol = input.color(color.new(color.green, 0), title="Hull Bullish Color", group="1. Hull Suite Settings")
hullBearCol = input.color(color.new(color.red, 0), title="Hull Bearish Color", group="1. Hull Suite Settings")
hullNeutCol = input.color(color.new(color.gray, 0), title="Hull Neutral Color", group="1. Hull Suite Settings")

hma = ta.hma(close, hullLength)
hullBull = close > hma and hma > hma[1]
hullBear = close < hma and hma < hma[1]

// Dynamic color logic based on user inputs
plotColor = hullBull ? hullBullCol : hullBear ? hullBearCol : hullNeutCol
plot(hma, title="Hull MA", color=plotColor, linewidth=2)

// =====================================================================
// 2. SIMPLE VOLUME SETTINGS
// =====================================================================
volLength = input.int(20, title="Volume SMA Length", group="2. Volume Settings")
volMult   = input.float(1.5, title="Volume Spike Multiplier", group="2. Volume Settings", step=0.1)
volAvg    = ta.sma(volume, volLength)
highVol   = volume > (volAvg * volMult)

// =====================================================================
// 3. MANSFIELD RELATIVE STRENGTH
// =====================================================================
benchmark  = input.symbol("NASDAQ:NDX", title="Benchmark Ticker", group="3. Mansfield RS")
rsLength   = input.int(52, title="RS Length", group="3. Mansfield RS")
benchClose = request.security(benchmark, timeframe.period, close)
rsLine     = close / benchClose
rsMa       = ta.sma(rsLine, rsLength)
mansfieldBull = rsLine > rsMa
mansfieldBear = rsLine < rsMa

// =====================================================================
// 4. AIR VORTEX & ADX (Corrected Calculation)
// =====================================================================
adxLen = input.int(14, title="ADX Length", group="4. Vortex & ADX")
adxThreshold = input.int(20, title="ADX Trend Threshold", group="4. Vortex & ADX")
viLen  = input.int(14, title="Vortex Length", group="4. Vortex & ADX")

// ADX Calculation
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)

// Manual Vortex Indicator (VI) Calculation
VMP = math.sum(math.abs(high - low[1]), viLen)
VMM = math.sum(math.abs(low - high[1]), viLen)
STR = math.sum(ta.tr, viLen)
vip = VMP / STR
vim = VMM / STR

trendStrong = adx > adxThreshold
vortexBull  = vip > vim and trendStrong
vortexBear  = vim > vip and trendStrong

// =====================================================================
// 5. MOMENTUM CONSENSUS PROXY
// =====================================================================
rsiLen = input.int(14, title="RSI Length", group="5. Momentum Proxy")
cciLen = input.int(14, title="CCI Length", group="5. Momentum Proxy")
rsiVal = ta.rsi(close, rsiLen)
cciVal = ta.cci(close, cciLen)
lorentzBull = rsiVal > 50 and cciVal > 0
lorentzBear = rsiVal < 50 and cciVal < 0

// =====================================================================
// 6. SWING SIGNAL SETTINGS & COLORS
// =====================================================================
buyLabelCol  = input.color(color.new(color.green, 0), title="Buy Label Background", group="6. Signal Settings")
buyTextCol   = input.color(color.new(color.white, 0), title="Buy Label Text", group="6. Signal Settings")
sellLabelCol = input.color(color.new(color.red, 0), title="Sell Label Background", group="6. Signal Settings")
sellTextCol  = input.color(color.new(color.white, 0), title="Sell Label Text", group="6. Signal Settings")

// Signal Confluence
buySignal  = hullBull and highVol and mansfieldBull and vortexBull and lorentzBull
sellSignal = hullBear and highVol and mansfieldBear and vortexBear and lorentzBear

// Plotting Customizable Signals
plotshape(buySignal,  title="Buy Signal",  style=shape.labelup,   location=location.belowbar, color=buyLabelCol, text="BUY",  textcolor=buyTextCol, size=size.small)
plotshape(sellSignal, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=sellLabelCol, text="SELL", textcolor=sellTextCol, size=size.small)

// Alerts
alertcondition(buySignal, title="Swing BUY Alert", message="Confluence Swing BUY Signal triggered.")
alertcondition(sellSignal, title="Swing SELL Alert", message="Confluence Swing SELL Signal triggered.")
````
