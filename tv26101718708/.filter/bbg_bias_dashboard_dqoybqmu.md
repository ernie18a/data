# BBG Bias Dashboard

- url: https://www.tradingview.com/script/DQoYBQmU-BBG-Bias-Dashboard/
- type: indicator
- pine_id: PUB;8e231f2d462c4049ab53bf18bdec797e
- version: 2.0

## Description

BTC Bias Dashboard

A lightweight multi-timeframe trading dashboard designed for BTC traders who want a quick, objective market bias without cluttering their charts.

The indicator analyzes trend alignment across the 1H and 15M timeframes using EMA 50 and VWAP, evaluates the current price position relative to VWAP, and measures market volatility through an ATR Ratio (current ATR vs. average ATR).

Features
Multi-timeframe trend analysis (1H & 15M)
EMA 50 + VWAP trend confirmation
Price vs. VWAP status
ATR Ratio volatility filter
Color-coded market conditions
Automatic trading bias:
LONG ONLY
SHORT ONLY
NO TRADE
Intended Use

The dashboard is designed to act as a high-level market filter before executing trades on lower timeframes. It helps traders stay aligned with the dominant trend, avoid low-probability setups, and maintain trading discipline.

Perfect for traders using a 1H → 15M → 5M workflow with VWAP, EMA, and ATR-based risk management.

## Source Code

````pine
//@version=6
indicator("BBG Bias Dashboard", overlay=true)

// === INPUTS ===
tfBias      = input.timeframe("60", "Higher Timeframe Bias")
tfSetup     = input.timeframe("15", "Setup Timeframe")
emaLength   = input.int(50, "EMA Length", minval=1)
atrLength   = input.int(14, "ATR Length", minval=1)
atrAvgLen   = input.int(20, "ATR Average Length", minval=1)

showTable   = input.bool(true, "Show Dashboard")

// === FUNCTIONS ===
getTrend(tf) =>
    htfClose = request.security(syminfo.tickerid, tf, close)
    htfEma   = request.security(syminfo.tickerid, tf, ta.ema(close, emaLength))
    htfVwap  = request.security(syminfo.tickerid, tf, ta.vwap(hlc3))

    bullish = htfClose > htfEma and htfClose > htfVwap
    bearish = htfClose < htfEma and htfClose < htfVwap

    bullish ? "Bullish" : bearish ? "Bearish" : "Neutral"

getColor(state) =>
    state == "Bullish" ? color.new(color.green, 0) :
     state == "Bearish" ? color.new(color.red, 0) :
     color.new(color.orange, 0)

getDistancePercent(level) =>
    not na(level) and level != 0 ? ((level - close) / close) * 100 : na

getWeeklyRangePosition(pwh, pwl) =>
    not na(pwh) and not na(pwl) and pwh != pwl ? ((close - pwl) / (pwh - pwl)) * 100 : na

getWeeklyRangeState(pos) =>
    na(pos) ? "N/A" :
     pos < 20 ? "Lower 20%" :
     pos > 80 ? "Upper 20%" :
     pos >= 45 and pos <= 55 ? "Middle" :
     pos < 45 ? "Lower Half" :
     "Upper Half"

getWeeklyRangeColor(pos) =>
    na(pos) ? color.new(color.gray, 0) :
     pos < 20 ? color.new(color.green, 0) :
     pos > 80 ? color.new(color.red, 0) :
     pos >= 45 and pos <= 55 ? color.new(color.orange, 0) :
     color.new(color.blue, 0)

// === TREND DATA ===
trend1H  = getTrend(tfBias)
trend15M = getTrend(tfSetup)

// === CURRENT VWAP ===
currentVwap = ta.vwap(hlc3)

priceVsVwap =
     close > currentVwap ? "Above" :
     close < currentVwap ? "Below" :
     "At VWAP"

priceVwapColor =
     close > currentVwap ? color.new(color.green, 0) :
     close < currentVwap ? color.new(color.red, 0) :
     color.new(color.orange, 0)

// === ATR RATIO ===
atrNow = ta.atr(atrLength)
atrAvg = ta.sma(atrNow, atrAvgLen)
atrRatio = atrAvg != 0 ? atrNow / atrAvg : na

atrState =
     na(atrRatio) ? "N/A" :
     atrRatio < 0.8 ? "Low" :
     atrRatio <= 1.2 ? "Normal" :
     "High"

atrColor =
     na(atrRatio) ? color.new(color.gray, 0) :
     atrRatio < 0.8 ? color.new(color.gray, 0) :
     atrRatio <= 1.2 ? color.new(color.green, 0) :
     color.new(color.orange, 0)

// === PREVIOUS DAY / WEEK LEVELS ===
pdh = request.security(syminfo.tickerid, "D", high[1])
pdl = request.security(syminfo.tickerid, "D", low[1])

pwh = request.security(syminfo.tickerid, "W", high[1])
pwl = request.security(syminfo.tickerid, "W", low[1])

distanceToPdh = getDistancePercent(pdh)
distanceToPdl = getDistancePercent(pdl)

distancePdhText = na(distanceToPdh) ? "N/A" : str.tostring(distanceToPdh, "#.##") + "%"
distancePdlText = na(distanceToPdl) ? "N/A" : str.tostring(distanceToPdl, "#.##") + "%"

distancePdhColor =
     na(distanceToPdh) ? color.new(color.gray, 0) :
     distanceToPdh > 0 ? color.new(color.green, 0) :
     color.new(color.red, 0)

distancePdlColor =
     na(distanceToPdl) ? color.new(color.gray, 0) :
     distanceToPdl < 0 ? color.new(color.red, 0) :
     color.new(color.green, 0)

// === WEEKLY RANGE POSITION ===
weeklyRangePosition = getWeeklyRangePosition(pwh, pwl)
weeklyRangeState    = getWeeklyRangeState(weeklyRangePosition)
weeklyRangeColor    = getWeeklyRangeColor(weeklyRangePosition)

weeklyRangeText =
     na(weeklyRangePosition) ? "N/A" :
     str.tostring(weeklyRangePosition, "#.##") + "% / " + weeklyRangeState

// === FINAL BIAS ===
bias =
     trend1H == "Bullish" and trend15M == "Bullish" and priceVsVwap == "Above" ? "LONG ONLY" :
     trend1H == "Bearish" and trend15M == "Bearish" and priceVsVwap == "Below" ? "SHORT ONLY" :
     "NO TRADE"

biasColor =
     bias == "LONG ONLY" ? color.new(color.green, 0) :
     bias == "SHORT ONLY" ? color.new(color.red, 0) :
     color.new(color.gray, 0)

// === DASHBOARD ===
var table dashboard = table.new(position.top_right, 2, 9, border_width=1)

if showTable and barstate.islast
    table.cell(dashboard, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dashboard, 1, 0, "Status", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(dashboard, 0, 1, "1H Trend", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dashboard, 1, 1, trend1H, text_color=color.white, bgcolor=getColor(trend1H))

    table.cell(dashboard, 0, 2, "15M Trend", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dashboard, 1, 2, trend15M, text_color=color.white, bgcolor=getColor(trend15M))

    table.cell(dashboard, 0, 3, "Price vs VWAP", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dashboard, 1, 3, priceVsVwap, text_color=color.white, bgcolor=priceVwapColor)

    table.cell(dashboard, 0, 4, "ATR Ratio", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dashboard, 1, 4, str.tostring(atrRatio, "#.##") + " / " + atrState, text_color=color.white, bgcolor=atrColor)

    table.cell(dashboard, 0, 5, "Distance to PDH", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dashboard, 1, 5, distancePdhText, text_color=color.white, bgcolor=distancePdhColor)

    table.cell(dashboard, 0, 6, "Distance to PDL", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dashboard, 1, 6, distancePdlText, text_color=color.white, bgcolor=distancePdlColor)

    table.cell(dashboard, 0, 7, "Weekly Range", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dashboard, 1, 7, weeklyRangeText, text_color=color.white, bgcolor=weeklyRangeColor)

    table.cell(dashboard, 0, 8, "Bias", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dashboard, 1, 8, bias, text_color=color.white, bgcolor=biasColor)
````
