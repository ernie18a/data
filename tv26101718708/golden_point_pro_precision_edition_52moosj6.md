# Golden Point PRO | Precision Edition

- url: https://www.tradingview.com/script/52MOOsj6-Golden-Point-PRO-Precision-Edition/
- type: indicator
- pine_id: PUB;62c5ede2bb834a268d841ef72dd6d77d
- version: 1.0

## Description

# Golden Point PRO | Precision Edition

**Golden Point PRO | Precision Edition** is a multi-factor technical analysis indicator designed to identify selective BUY and SELL opportunities through trend, momentum, volume, and volatility confluence.

The indicator combines several established technical tools into a weighted **Golden Score**, helping traders evaluate market conditions and identify potential directional opportunities.

### Key Features

**1. Golden Score (0–100)**

A weighted scoring system evaluates seven market factors:

- EMA trend alignment
- VWAP positioning
- RSI momentum
- ADX trend strength and directional movement
- Relative trading volume
- ATR volatility conditions
- Price momentum

Higher scores indicate stronger alignment among the enabled factors, not a guaranteed probability of success.

**2. Unique BUY & SELL Signals**

The indicator uses a directional signal management system designed to eliminate consecutive signals in the same direction.

- A BUY signal is generated when bullish conditions meet the required criteria.
- Additional BUY signals are suppressed until a valid SELL signal occurs.
- A SELL signal follows the same logic in the opposite direction.

All signals are confirmed at candle close to avoid intrabar signal repainting.

**3. Precision Filters**

Additional filters help reduce low-quality setups:

- Trend Entry Filter: Identifies potential entries following a recent pullback toward the fast EMA.
- Sideways Market Filter: Uses EMA separation and ADX to identify potentially weak or ranging market conditions.
- Minimum Golden Score: Allows traders to adjust signal selectivity.

**4. Real-Time Dashboard**

An integrated dashboard displays:

- Market trend
- Momentum direction
- ADX strength
- Volume confirmation
- ATR volatility status
- Market condition
- BUY and SELL Golden Scores
- Last confirmed signal
- Current chart timeframe

**5. Customizable TradingView Alerts**

Supports individual BUY alerts, SELL alerts, and combined BUY/SELL alerts.

### How to Use

Golden Point PRO can be applied to stocks, futures, forex, and cryptocurrency charts, subject to the availability and quality of the underlying market data.

The indicator automatically uses the selected chart timeframe.

Green arrows identify confirmed bullish signals, while red arrows identify confirmed bearish signals.

Traders can adjust the Golden Score threshold and individual filters according to their preferred market and trading style.

### Important Information

Golden Point PRO is a technical analysis tool, not an automated trading strategy.

The indicator does not execute orders or manage positions, stops, or profit targets.

Its Golden Score represents technical confluence rather than a statistical probability of a profitable trade.

Although signals are confirmed at candle close, market conditions can change after a signal is generated.

**Disclaimer:** This indicator is intended for educational and informational purposes only. It does not constitute financial advice. Trading involves risk, and past performance does not guarantee future results.

## Source Code

````pine

 //@version=6
indicator("Golden Point PRO | Precision Edition", shorttitle="Golden Point PRO", overlay=true, max_labels_count=500)

// ============================================================================
// 01. GENERAL SETTINGS
// ============================================================================
groupGeneral = "01 | General Settings"

scoreMin = input.int(85, "Minimum Golden Score", minval=50, maxval=100, step=5, group=groupGeneral)

// ============================================================================
// 02. MOVING AVERAGES
// ============================================================================
groupEMA = "02 | Moving Averages"

emaFastLen = input.int(9, "Fast EMA Length", minval=1, group=groupEMA)
emaSlowLen = input.int(21, "Slow EMA Length", minval=2, group=groupEMA)

showEMA = input.bool(true, "Show EMAs", group=groupEMA)
useEMA = input.bool(true, "Enable EMA Filter", group=groupEMA)

// ============================================================================
// 03. VWAP
// ============================================================================
groupVWAP = "03 | VWAP"

useVWAP = input.bool(true, "Enable VWAP Filter", group=groupVWAP)
showVWAP = input.bool(true, "Show VWAP", group=groupVWAP)

// ============================================================================
// 04. RSI
// ============================================================================
groupRSI = "04 | RSI"

rsiLen = input.int(14, "RSI Length", minval=2, group=groupRSI)
rsiBuyLevel = input.int(55, "Minimum RSI for BUY", minval=1, maxval=99, group=groupRSI)
rsiSellLevel = input.int(45, "Maximum RSI for SELL", minval=1, maxval=99, group=groupRSI)
useRSI = input.bool(true, "Enable RSI Filter", group=groupRSI)

// ============================================================================
// 05. ADX
// ============================================================================
groupADX = "05 | Trend Strength"

diLen = input.int(14, "DI Length", minval=2, group=groupADX)
adxSmooth = input.int(14, "ADX Smoothing", minval=2, group=groupADX)
adxMin = input.float(23.0, "Minimum ADX", minval=1, step=0.5, group=groupADX)
useADX = input.bool(true, "Enable ADX Filter", group=groupADX)

// ============================================================================
// 06. VOLUME
// ============================================================================
groupVolume = "06 | Volume"

volLen = input.int(20, "Volume Average Length", minval=1, group=groupVolume)
volMult = input.float(1.10, "Minimum Volume Multiplier", minval=0.1, step=0.05, group=groupVolume)
useVolume = input.bool(true, "Enable Volume Filter", group=groupVolume)

// ============================================================================
// 07. VOLATILITY
// ============================================================================
groupATR = "07 | ATR Volatility"

atrLen = input.int(14, "ATR Length", minval=1, group=groupATR)
atrAvgLen = input.int(20, "ATR Average Length", minval=1, group=groupATR)
atrMult = input.float(0.90, "Minimum Relative ATR", minval=0.1, step=0.05, group=groupATR)
useATR = input.bool(true, "Enable ATR Filter", group=groupATR)

// ============================================================================
// 08. PRECISION FILTERS
// ============================================================================
groupPrecision = "08 | Precision Filters"

useTrendEntry = input.bool(true, "Enable Trend Entry Filter", group=groupPrecision)
entryLookback = input.int(5, "Entry Setup Lookback", minval=1, maxval=30, group=groupPrecision)

useSideways = input.bool(true, "Enable Sideways Market Filter", group=groupPrecision)
minEmaSpreadATR = input.float(0.15, "Minimum EMA Spread / ATR", minval=0.01, step=0.01, group=groupPrecision)
minAdxSideways = input.float(20.0, "Minimum ADX for Trending Market", minval=1, step=0.5, group=groupPrecision)

// ============================================================================
// 09. VISUAL SETTINGS
// ============================================================================
groupVisual = "09 | Visual Settings"

showSignals = input.bool(true, "Show BUY / SELL Signals", group=groupVisual)
showScoreLabels = input.bool(true, "Show Golden Score Labels", group=groupVisual)
showBackground = input.bool(false, "Color Background by Trend", group=groupVisual)
showBarColors = input.bool(false, "Color Candles", group=groupVisual)
showPanel = input.bool(true, "Show Dashboard", group=groupVisual)

// ============================================================================
// 10. ALERT SETTINGS
// ============================================================================
groupAlerts = "10 | Alert Settings"

enableBuyAlert = input.bool(true, "Enable BUY Alerts", group=groupAlerts)
enableSellAlert = input.bool(true, "Enable SELL Alerts", group=groupAlerts)

// ============================================================================
// 11. CORE CALCULATIONS
// ============================================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
vwapValue = ta.vwap(hlc3)

rsiValue = ta.rsi(close, rsiLen)

[diPlus, diMinus, adxValue] = ta.dmi(diLen, adxSmooth)

volumeAverage = ta.sma(volume, volLen)

atrValue = ta.atr(atrLen)
atrAverage = ta.sma(atrValue, atrAvgLen)

// ============================================================================
// 12. TREND CONDITIONS
// ============================================================================
emaBull = emaFast > emaSlow and close > emaFast
emaBear = emaFast < emaSlow and close < emaFast

vwapBull = close > vwapValue
vwapBear = close < vwapValue

rsiBull = rsiValue >= rsiBuyLevel
rsiBear = rsiValue <= rsiSellLevel

diBull = diPlus > diMinus
diBear = diMinus > diPlus

adxStrong = adxValue >= adxMin

volumeValid = not na(volumeAverage) and volumeAverage > 0 and volume >= volumeAverage * volMult

atrValid = not na(atrAverage) and atrAverage > 0 and atrValue >= atrAverage * atrMult

// ============================================================================
// 13. PRICE MOMENTUM
// ============================================================================
bullCandle = close > open
bearCandle = close < open

bullMomentum = close > close[1] and bullCandle
bearMomentum = close < close[1] and bearCandle

// ============================================================================
// 14. GOLDEN SCORE
// Maximum score: 100
// EMA: 20
// VWAP: 20
// RSI: 15
// ADX/DI: 15
// Volume: 10
// ATR: 10
// Momentum: 10
// Disabled filters are excluded from the total.
// ============================================================================
float buyPoints = 0.0
float sellPoints = 0.0
float maxPoints = 10.0

if bullMomentum
    buyPoints += 10

if bearMomentum
    sellPoints += 10

if useEMA
    maxPoints += 20
    if emaBull
        buyPoints += 20
    if emaBear
        sellPoints += 20

if useVWAP
    maxPoints += 20
    if vwapBull
        buyPoints += 20
    if vwapBear
        sellPoints += 20

if useRSI
    maxPoints += 15
    if rsiBull
        buyPoints += 15
    if rsiBear
        sellPoints += 15

if useADX
    maxPoints += 15
    if adxStrong and diBull
        buyPoints += 15
    if adxStrong and diBear
        sellPoints += 15

if useVolume
    maxPoints += 10
    if volumeValid
        buyPoints += 10
        sellPoints += 10

if useATR
    maxPoints += 10
    if atrValid
        buyPoints += 10
        sellPoints += 10

int goldenBuy = int(math.round(buyPoints / maxPoints * 100))
int goldenSell = int(math.round(sellPoints / maxPoints * 100))

// ============================================================================
// 15. DIRECTIONAL FILTERS
// ============================================================================
buyDirection = (not useEMA or emaBull) and (not useVWAP or vwapBull)

sellDirection = (not useEMA or emaBear) and (not useVWAP or vwapBear)

// ============================================================================
// 16. SIDEWAYS MARKET FILTER
// ============================================================================
emaSpread = math.abs(emaFast - emaSlow)

emaSpreadRatio = atrValue > 0 ? emaSpread / atrValue : 0.0

sidewaysMarket = emaSpreadRatio < minEmaSpreadATR or adxValue < minAdxSideways

marketAllowed = not useSideways or not sidewaysMarket

// ============================================================================
// 17. TREND ENTRY FILTER
// ============================================================================
recentBullPullback = ta.lowest(low, entryLookback) <= emaFast

recentBearPullback = ta.highest(high, entryLookback) >= emaFast

bullEntrySetup = not useTrendEntry or (recentBullPullback and close > emaFast)

bearEntrySetup = not useTrendEntry or (recentBearPullback and close < emaFast)

// ============================================================================
// 18. SIGNAL QUALIFICATION
// ============================================================================
buyQualified = buyDirection and bullMomentum and goldenBuy >= scoreMin and marketAllowed and bullEntrySetup

sellQualified = sellDirection and bearMomentum and goldenSell >= scoreMin and marketAllowed and bearEntrySetup

// ============================================================================
// 19. UNIQUE BUY / SELL SIGNAL ENGINE
//
// Only one BUY is allowed until a SELL is confirmed.
// Only one SELL is allowed until a BUY is confirmed.
//
// Signal state:
//  0 = No previous signal
//  1 = Last signal was BUY
// -1 = Last signal was SELL
//
// No cooldown.
// No repeated signals in the same direction.
// Confirmed candle close only.
// ============================================================================
var int lastSignal = 0

bool buySignal = false
bool sellSignal = false

if barstate.isconfirmed
    if buyQualified and lastSignal != 1
        buySignal := true
        lastSignal := 1

    else if sellQualified and lastSignal != -1
        sellSignal := true
        lastSignal := -1

// ============================================================================
// 20. MOVING AVERAGE PLOTS
// ============================================================================
plot(showEMA ? emaFast : na, title="Fast EMA", color=color.aqua, linewidth=2)

plot(showEMA ? emaSlow : na, title="Slow EMA", color=color.orange, linewidth=2)

plot(showVWAP ? vwapValue : na, title="VWAP", color=color.yellow, linewidth=2)

// ============================================================================
// 21. UNIQUE BUY AND SELL ARROWS
// ============================================================================
plotshape(showSignals and buySignal, title="Golden BUY", style=shape.arrowup, location=location.belowbar, color=color.lime, size=size.large)

plotshape(showSignals and sellSignal, title="Golden SELL", style=shape.arrowdown, location=location.abovebar, color=color.red, size=size.large)

// ============================================================================
// 22. GOLDEN SCORE LABELS
// ============================================================================
if showSignals and showScoreLabels and buySignal
    label.new(bar_index, low - atrValue * 0.45, "BUY\n" + str.tostring(goldenBuy) + "/100", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

if showSignals and showScoreLabels and sellSignal
    label.new(bar_index, high + atrValue * 0.45, "SELL\n" + str.tostring(goldenSell) + "/100", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

// ============================================================================
// 23. CHART COLORS
// ============================================================================
trendBull = emaFast > emaSlow and (na(vwapValue) or close > vwapValue)

trendBear = emaFast < emaSlow and (na(vwapValue) or close < vwapValue)

trendColor = trendBull ? color.lime : trendBear ? color.red : color.gray

bgcolor(showBackground ? color.new(trendColor, 92) : na)

barcolor(showBarColors ? color.new(trendColor, 15) : na)

// ============================================================================
// 24. MARKET STATUS
// ============================================================================
trendText = trendBull ? "BULLISH" : trendBear ? "BEARISH" : "NEUTRAL"

trendPanelColor = trendBull ? color.lime : trendBear ? color.red : color.silver

momentumText = rsiValue > 55 ? "BULLISH" : rsiValue < 45 ? "BEARISH" : "NEUTRAL"

momentumColor = rsiValue > 55 ? color.lime : rsiValue < 45 ? color.red : color.silver

adxText = adxStrong ? "STRONG" : "WEAK"

adxPanelColor = adxStrong ? color.lime : color.orange

volumeText = volumeValid ? "CONFIRMED" : "LOW"

volumePanelColor = volumeValid ? color.lime : color.orange

atrText = atrValid ? "ADEQUATE" : "LOW"

atrPanelColor = atrValid ? color.lime : color.orange

marketText = sidewaysMarket ? "SIDEWAYS" : "TRENDING"

marketColor = sidewaysMarket ? color.orange : color.lime

signalText = lastSignal == 1 ? "BUY ACTIVE" : lastSignal == -1 ? "SELL ACTIVE" : "WAITING"

signalColor = lastSignal == 1 ? color.lime : lastSignal == -1 ? color.red : color.silver

// ============================================================================
// 25. GOLDEN POINT PRO DASHBOARD
// ============================================================================
var table dashboard = table.new(position.top_right, 2, 11, border_width=1, border_color=color.new(color.gray, 60))

panelBG = color.rgb(18, 23, 34)
panelHeader = color.rgb(35, 43, 60)

if barstate.islast
    if showPanel
        table.cell(dashboard, 0, 0, "GOLDEN POINT", text_color=color.yellow, bgcolor=panelHeader)
        table.cell(dashboard, 1, 0, "PRECISION", text_color=color.yellow, bgcolor=panelHeader)

        table.cell(dashboard, 0, 1, "TREND", text_color=color.white, bgcolor=panelBG)
        table.cell(dashboard, 1, 1, trendText, text_color=trendPanelColor, bgcolor=panelBG)

        table.cell(dashboard, 0, 2, "MOMENTUM", text_color=color.white, bgcolor=panelBG)
        table.cell(dashboard, 1, 2, momentumText, text_color=momentumColor, bgcolor=panelBG)

        table.cell(dashboard, 0, 3, "ADX", text_color=color.white, bgcolor=panelBG)
        table.cell(dashboard, 1, 3, adxText + " " + str.tostring(adxValue, "#.0"), text_color=adxPanelColor, bgcolor=panelBG)

        table.cell(dashboard, 0, 4, "VOLUME", text_color=color.white, bgcolor=panelBG)
        table.cell(dashboard, 1, 4, volumeText, text_color=volumePanelColor, bgcolor=panelBG)

        table.cell(dashboard, 0, 5, "ATR", text_color=color.white, bgcolor=panelBG)
        table.cell(dashboard, 1, 5, atrText, text_color=atrPanelColor, bgcolor=panelBG)

        table.cell(dashboard, 0, 6, "MARKET", text_color=color.white, bgcolor=panelBG)
        table.cell(dashboard, 1, 6, marketText, text_color=marketColor, bgcolor=panelBG)

        table.cell(dashboard, 0, 7, "BUY SCORE", text_color=color.white, bgcolor=panelBG)
        table.cell(dashboard, 1, 7, str.tostring(goldenBuy) + "/100", text_color=color.lime, bgcolor=panelBG)

        table.cell(dashboard, 0, 8, "SELL SCORE", text_color=color.white, bgcolor=panelBG)
        table.cell(dashboard, 1, 8, str.tostring(goldenSell) + "/100", text_color=color.red, bgcolor=panelBG)

        table.cell(dashboard, 0, 9, "LAST SIGNAL", text_color=color.white, bgcolor=panelBG)
        table.cell(dashboard, 1, 9, signalText, text_color=signalColor, bgcolor=panelBG)

        table.cell(dashboard, 0, 10, "TIMEFRAME", text_color=color.white, bgcolor=panelBG)
        table.cell(dashboard, 1, 10, timeframe.period, text_color=color.aqua, bgcolor=panelBG)
    else
        table.clear(dashboard, 0, 0, 1, 10)

// ============================================================================
// 26. TRADINGVIEW ALERTS
// ============================================================================
alertcondition(buySignal and enableBuyAlert, title="Golden Point PRO | BUY", message="GOLDEN POINT PRO - UNIQUE BUY CONFIRMED | {{ticker}} | TF {{interval}} | Price {{close}}")

alertcondition(sellSignal and enableSellAlert, title="Golden Point PRO | SELL", message="GOLDEN POINT PRO - UNIQUE SELL CONFIRMED | {{ticker}} | TF {{interval}} | Price {{close}}")

alertcondition((buySignal and enableBuyAlert) or (sellSignal and enableSellAlert), title="Golden Point PRO | BUY or SELL", message="GOLDEN POINT PRO - UNIQUE SIGNAL CONFIRMED | {{ticker}} | TF {{interval}} | Price {{close}}")

// ============================================================================
// 27. DATA WINDOW
// ============================================================================
plot(goldenBuy, title="Golden Buy Score", color=color.new(color.lime, 100), display=display.data_window)

plot(goldenSell, title="Golden Sell Score", color=color.new(color.red, 100), display=display.data_window)

// ============================================================================
// 28. END OF INDICATOR
// ============================================================================
````
