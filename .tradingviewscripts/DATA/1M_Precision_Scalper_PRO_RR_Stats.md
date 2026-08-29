<!-- tradingview-pine-id: PUB;a61e85c505ed44fe9795e090a7850b8a -->
<!-- tradingviewscripts-format: 1 -->
# 1M Precision Scalper PRO [RR + Stats]

Source: https://www.tradingview.com/script/tIjVkiqz-1M-Precision-Scalper-PRO-RR-Stats/

## Description

# 1M Precision Scalper PRO

The **1M Precision Scalper PRO** is a multi-filter trading indicator designed specifically for the **1-minute chart**.

Instead of generating signals from a single indicator, it combines multiple confirmation factors to filter out weak setups and focus on higher-quality trend continuation entries.

## Main Features

The indicator uses:

* EMA 9 and EMA 21 for short-term momentum and pullbacks
* EMA 50 and EMA 200 for the main trend direction
* VWAP for intraday directional confirmation
* ADX and DMI to measure trend strength
* RSI for momentum confirmation
* Relative Volume to avoid low-volume market conditions
* ATR to filter out low-volatility and sideways markets
* Pullback detection before an entry
* Bullish and bearish candle confirmation
* Break of the previous candle for additional entry confirmation

A signal is only generated when enough filters agree with each other.

## Signal Logic

### BUY Signal

A BUY signal can appear when:

* Price is above the main trend EMAs
* EMA 50 is above EMA 200
* EMA 9 is above EMA 21
* EMA 200 is rising
* Price is above VWAP
* ADX is above the selected minimum
* +DI is stronger than -DI
* RSI confirms bullish momentum
* Volume and volatility conditions are strong enough
* Price recently pulled back toward EMA 21
* A bullish confirmation candle appears
* The candle breaks the previous candle high

### SELL Signal

The opposite conditions are used for SELL signals.

## Risk Management

The indicator includes an integrated Stop Loss and Take Profit system.

The Stop Loss can be placed at:

* The opening price of the signal candle for a very tight stop
* The high or low of the signal candle for a more conservative stop

A configurable tick buffer can also be added.

The Take Profit is automatically calculated using the selected Risk-to-Reward Ratio.

Available Risk-to-Reward settings:

* 1:2
* 1:3

Example:

If the entry risk is 10 points and the Risk-to-Reward Ratio is set to 1:3, the Take Profit will be placed 30 points away from the entry.

## Trade Statistics Dashboard

The built-in dashboard automatically tracks:

* Total completed trades
* Winning trades
* Stop Loss trades
* Win rate
* Long entries
* Short entries
* Current trade status
* Current Risk-to-Reward Ratio
* ADX value
* Long and Short filter score

Only one trade is tracked at a time to prevent overlapping signals from affecting the statistics.

## Conservative Backtesting Logic

If both the Stop Loss and Take Profit are reached within the same 1-minute candle, the indicator counts the trade as a **Stop Loss**.

This is intentional because standard OHLC candle data cannot determine whether the Take Profit or Stop Loss was reached first.

This creates a more conservative and realistic performance estimate.

## Alerts

Alerts are available for:

* BUY signals
* SELL signals
* Take Profit reached
* Stop Loss reached

## Recommended Use

This indicator is designed specifically for the **1-minute timeframe** and is intended for highly liquid markets such as indices, futures, forex, gold, and other actively traded instruments.

Recommended starting settings:

* Minimum ADX: 20
* Required filters: 5 out of 6
* Risk-to-Reward Ratio: 1:3
* Stop Loss: Signal Candle Open
* Use during active trading sessions with strong liquidity

The purpose of this indicator is not to generate as many signals as possible, but to filter the market and identify higher-quality short-term trading opportunities.

Always backtest the settings on the specific market you trade before using the indicator in live trading.

---

## Source Code

````pine
//@version=6
indicator("1M Precision Scalper PRO [RR + Stats]", overlay=true, max_labels_count=500)

// =====================================================
// 1M PRECISION SCALPER PRO
// Trend + VWAP + ADX/DMI + RSI + Volume + ATR
// Pullback + Color Change Entry
// SL + TP + automatische Statistik
// =====================================================


// ─────────────────────────────────────────────────────
// 1. TREND
// ─────────────────────────────────────────────────────

groupTrend = "1. Trend"

emaFastLen  = input.int(9, "EMA Fast", minval=1, group=groupTrend)
emaPullLen  = input.int(21, "EMA Pullback", minval=1, group=groupTrend)
emaTrendLen = input.int(50, "EMA Trend", minval=1, group=groupTrend)
emaMainLen  = input.int(200, "EMA Haupttrend", minval=1, group=groupTrend)

slopeBars = input.int(
     5,
     "EMA 200 Steigung",
     minval=1,
     group=groupTrend)


// ─────────────────────────────────────────────────────
// 2. MOMENTUM
// ─────────────────────────────────────────────────────

groupMomentum = "2. Momentum"

adxLength = input.int(
     14,
     "ADX Länge",
     group=groupMomentum)

adxSmooth = input.int(
     14,
     "ADX Glättung",
     group=groupMomentum)

adxMinimum = input.float(
     20.0,
     "Mindest ADX",
     step=0.5,
     group=groupMomentum)

rsiLength = input.int(
     14,
     "RSI Länge",
     group=groupMomentum)


// ─────────────────────────────────────────────────────
// 3. VOLUMEN
// ─────────────────────────────────────────────────────

groupVolume = "3. Volumen"

useVolume = input.bool(
     true,
     "Volumenfilter",
     group=groupVolume)

volumeLength = input.int(
     20,
     "Volumen Durchschnitt",
     group=groupVolume)

volumeMultiplier = input.float(
     1.05,
     "Mindest relatives Volumen",
     step=0.05,
     group=groupVolume)


// ─────────────────────────────────────────────────────
// 4. VOLATILITÄT
// ─────────────────────────────────────────────────────

groupATR = "4. Volatilität"

atrLength = input.int(
     14,
     "ATR Länge",
     group=groupATR)

atrAverageLength = input.int(
     50,
     "ATR Durchschnitt",
     group=groupATR)

atrMinimumRatio = input.float(
     0.80,
     "Mindest ATR Verhältnis",
     step=0.05,
     group=groupATR)


// ─────────────────────────────────────────────────────
// 5. ENTRY
// ─────────────────────────────────────────────────────

groupEntry = "5. Entry"

pullbackLookback = input.int(
     3,
     "Pullback innerhalb X Kerzen",
     minval=1,
     maxval=10,
     group=groupEntry)

minimumScore = input.int(
     5,
     "Benötigte Filter",
     minval=1,
     maxval=6,
     group=groupEntry)

cooldownBars = input.int(
     8,
     "Pause nach Signal",
     minval=0,
     group=groupEntry)

minimumBodyRatio = input.float(
     0.50,
     "Mindest Kerzenkörper %",
     minval=0.1,
     maxval=1,
     step=0.05,
     group=groupEntry)

minimumBodyATR = input.float(
     0.15,
     "Kerzenkörper Mindest-ATR",
     minval=0,
     step=0.05,
     group=groupEntry)


// ─────────────────────────────────────────────────────
// 6. STOP LOSS + CRV
// ─────────────────────────────────────────────────────

groupRisk = "6. Stop Loss / Take Profit"

rrChoice = input.string(
     "3",
     "CRV",
     options=["2", "3"],
     group=groupRisk)

riskReward = rrChoice == "2" ? 2.0 : 3.0


slMethod = input.string(
     "Kerzenanfang (Open)",
     "Stop-Loss Methode",
     options=[
         "Kerzenanfang (Open)",
         "Kerzen-Tief/Hoch"
     ],
     group=groupRisk)


slBufferTicks = input.int(
     1,
     "SL Puffer in Ticks",
     minval=0,
     maxval=100,
     group=groupRisk)

slBuffer = syminfo.mintick * slBufferTicks


// ─────────────────────────────────────────────────────
// 7. SESSION
// ─────────────────────────────────────────────────────

groupSession = "7. Handelszeit"

useSession = input.bool(
     true,
     "Session Filter",
     group=groupSession)

tradeSession = input.session(
     "0800-1800",
     "Handelszeit",
     group=groupSession)

tradeTimezone = input.string(
     "Europe/Berlin",
     "Zeitzone",
     group=groupSession)


// ─────────────────────────────────────────────────────
// 8. DARSTELLUNG
// ─────────────────────────────────────────────────────

groupDisplay = "8. Darstellung"

showEMA = input.bool(
     true,
     "EMAs anzeigen",
     group=groupDisplay)

showVWAP = input.bool(
     true,
     "VWAP anzeigen",
     group=groupDisplay)

showTradeLevels = input.bool(
     true,
     "Entry / SL / TP anzeigen",
     group=groupDisplay)

showBackground = input.bool(
     false,
     "Trend Hintergrund",
     group=groupDisplay)

showDashboard = input.bool(
     true,
     "Dashboard",
     group=groupDisplay)


// =====================================================
// INDIKATOREN
// =====================================================

ema9   = ta.ema(close, emaFastLen)
ema21  = ta.ema(close, emaPullLen)
ema50  = ta.ema(close, emaTrendLen)
ema200 = ta.ema(close, emaMainLen)

vwapValue = ta.vwap(hlc3)

[plusDI, minusDI, adx] = ta.dmi(
     adxLength,
     adxSmooth)

rsi = ta.rsi(
     close,
     rsiLength)

atr = ta.atr(
     atrLength)

atrAverage = ta.sma(
     atr,
     atrAverageLength)

volumeAverage = ta.sma(
     volume,
     volumeLength)


// =====================================================
// FILTER
// =====================================================

volumeOK =
     not useVolume or
     na(volume) or
     volume > volumeAverage * volumeMultiplier


volatilityOK =
     atr > atrAverage * atrMinimumRatio


inSession =
     not useSession or
     not na(
         time(
             timeframe.period,
             tradeSession,
             tradeTimezone
         )
     )


isOneMinute =
     timeframe.isminutes and
     timeframe.multiplier == 1


// =====================================================
// LONG FILTER
// =====================================================

trendLong =
     close > ema50 and
     ema50 > ema200 and
     ema9 > ema21 and
     ema200 > ema200[slopeBars]


vwapLong =
     close > vwapValue


dmiLong =
     adx >= adxMinimum and
     plusDI > minusDI


rsiLong =
     rsi >= 52 and
     rsi <= 70


longScore =
     (trendLong ? 1 : 0) +
     (vwapLong ? 1 : 0) +
     (dmiLong ? 1 : 0) +
     (rsiLong ? 1 : 0) +
     (volumeOK ? 1 : 0) +
     (volatilityOK ? 1 : 0)


// =====================================================
// SHORT FILTER
// =====================================================

trendShort =
     close < ema50 and
     ema50 < ema200 and
     ema9 < ema21 and
     ema200 < ema200[slopeBars]


vwapShort =
     close < vwapValue


dmiShort =
     adx >= adxMinimum and
     minusDI > plusDI


rsiShort =
     rsi <= 48 and
     rsi >= 30


shortScore =
     (trendShort ? 1 : 0) +
     (vwapShort ? 1 : 0) +
     (dmiShort ? 1 : 0) +
     (rsiShort ? 1 : 0) +
     (volumeOK ? 1 : 0) +
     (volatilityOK ? 1 : 0)


// =====================================================
// PULLBACK
// =====================================================

barsSinceLongPullback =
     ta.barssince(low <= ema21)


barsSinceShortPullback =
     ta.barssince(high >= ema21)


recentLongPullback =
     not na(barsSinceLongPullback) and
     barsSinceLongPullback <= pullbackLookback


recentShortPullback =
     not na(barsSinceShortPullback) and
     barsSinceShortPullback <= pullbackLookback


// =====================================================
// KERZEN QUALITÄT
// =====================================================

candleRange = high - low

candleBody = math.abs(close - open)


bodyRatio =
     candleRange > 0 ?
     candleBody / candleRange :
     0.0


bodyQuality =
     bodyRatio >= minimumBodyRatio and
     candleBody >= atr * minimumBodyATR


// =====================================================
// COLOR CHANGE + BREAK
// =====================================================

bullishTrigger =
     close > open and
     close[1] <= open[1] and
     close > high[1] and
     close > ema9


bearishTrigger =
     close < open and
     close[1] >= open[1] and
     close < low[1] and
     close < ema9


// =====================================================
// TRADE VARIABLEN
// =====================================================

var bool inTrade = false

var int tradeDirection = 0

// 1 = LONG
// -1 = SHORT

var float entryPrice = na
var float stopPrice = na
var float takeProfitPrice = na

var int entryBar = na
var int lastSignalBar = na


// =====================================================
// STATISTIK
// =====================================================

var int totalTrades = 0
var int winningTrades = 0
var int losingTrades = 0

var int longTrades = 0
var int shortTrades = 0


// Marker
bool exitWinThisBar = false
bool exitLossThisBar = false

bool tradeClosedThisBar = false


// =====================================================
// OFFENEN TRADE ÜBERWACHEN
// =====================================================

if inTrade and bar_index > entryBar

    // LONG
    if tradeDirection == 1

        longStopHit =
             low <= stopPrice

        longTargetHit =
             high >= takeProfitPrice


        // Falls TP und SL in derselben 1M Kerze liegen,
        // wird konservativ der Stop Loss gezählt.

        if longStopHit and longTargetHit

            losingTrades += 1
            totalTrades += 1

            exitLossThisBar := true
            tradeClosedThisBar := true

            inTrade := false
            tradeDirection := 0


        else if longStopHit

            losingTrades += 1
            totalTrades += 1

            exitLossThisBar := true
            tradeClosedThisBar := true

            inTrade := false
            tradeDirection := 0


        else if longTargetHit

            winningTrades += 1
            totalTrades += 1

            exitWinThisBar := true
            tradeClosedThisBar := true

            inTrade := false
            tradeDirection := 0


    // SHORT
    else if tradeDirection == -1

        shortStopHit =
             high >= stopPrice

        shortTargetHit =
             low <= takeProfitPrice


        if shortStopHit and shortTargetHit

            losingTrades += 1
            totalTrades += 1

            exitLossThisBar := true
            tradeClosedThisBar := true

            inTrade := false
            tradeDirection := 0


        else if shortStopHit

            losingTrades += 1
            totalTrades += 1

            exitLossThisBar := true
            tradeClosedThisBar := true

            inTrade := false
            tradeDirection := 0


        else if shortTargetHit

            winningTrades += 1
            totalTrades += 1

            exitWinThisBar := true
            tradeClosedThisBar := true

            inTrade := false
            tradeDirection := 0


// =====================================================
// COOLDOWN
// =====================================================

cooldownOK =
     na(lastSignalBar) or
     bar_index - lastSignalBar > cooldownBars


// =====================================================
// BASIS SETUPS
// =====================================================

longSetup =
     barstate.isconfirmed and
     isOneMinute and
     inSession and
     recentLongPullback and
     bullishTrigger and
     bodyQuality and
     longScore >= minimumScore


shortSetup =
     barstate.isconfirmed and
     isOneMinute and
     inSession and
     recentShortPullback and
     bearishTrigger and
     bodyQuality and
     shortScore >= minimumScore


// =====================================================
// FINALE SIGNALE
// =====================================================

canEnter =
     not inTrade and
     not tradeClosedThisBar and
     cooldownOK


longSignal =
     longSetup and
     canEnter


shortSignal =
     shortSetup and
     canEnter


// =====================================================
// LONG ENTRY
// =====================================================

if longSignal

    float newStop = na

    if slMethod == "Kerzenanfang (Open)"
        newStop := open - slBuffer
    else
        newStop := low - slBuffer


    float risk =
         close - newStop


    if risk > syminfo.mintick

        entryPrice := close
        stopPrice := newStop

        takeProfitPrice :=
             entryPrice +
             risk * riskReward

        tradeDirection := 1
        inTrade := true

        entryBar := bar_index
        lastSignalBar := bar_index

        longTrades += 1


// =====================================================
// SHORT ENTRY
// =====================================================

else if shortSignal

    float newStop = na

    if slMethod == "Kerzenanfang (Open)"
        newStop := open + slBuffer
    else
        newStop := high + slBuffer


    float risk =
         newStop - close


    if risk > syminfo.mintick

        entryPrice := close
        stopPrice := newStop

        takeProfitPrice :=
             entryPrice -
             risk * riskReward

        tradeDirection := -1
        inTrade := true

        entryBar := bar_index
        lastSignalBar := bar_index

        shortTrades += 1


// =====================================================
// WINRATE
// =====================================================

winRate =
     totalTrades > 0 ?
     winningTrades * 100.0 / totalTrades :
     0.0


// =====================================================
// EMAs / VWAP
// =====================================================

plot(
     showEMA ? ema9 : na,
     "EMA 9",
     color=color.aqua,
     linewidth=1)


plot(
     showEMA ? ema21 : na,
     "EMA 21",
     color=color.yellow,
     linewidth=1)


plot(
     showEMA ? ema50 : na,
     "EMA 50",
     color=color.orange,
     linewidth=2)


plot(
     showEMA ? ema200 : na,
     "EMA 200",
     color=color.red,
     linewidth=2)


plot(
     showVWAP ? vwapValue : na,
     "VWAP",
     color=color.purple,
     linewidth=2)


// =====================================================
// TRADE LEVELS
// =====================================================

plot(
     showTradeLevels and inTrade ?
     entryPrice :
     na,
     "Entry",
     color=color.blue,
     linewidth=2,
     style=plot.style_linebr)


plot(
     showTradeLevels and inTrade ?
     stopPrice :
     na,
     "Stop Loss",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr)


plot(
     showTradeLevels and inTrade ?
     takeProfitPrice :
     na,
     "Take Profit",
     color=color.lime,
     linewidth=2,
     style=plot.style_linebr)


// =====================================================
// BUY / SELL MARKER
// =====================================================

plotshape(
     longSignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     textcolor=color.black,
     text="BUY",
     size=size.small)


plotshape(
     shortSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     text="SELL",
     size=size.small)


// =====================================================
// TP / SL MARKER
// =====================================================

plotshape(
     exitWinThisBar,
     title="TAKE PROFIT",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.lime,
     textcolor=color.black,
     text="TP",
     size=size.tiny)


plotshape(
     exitLossThisBar,
     title="STOP LOSS",
     style=shape.labelup,
     location=location.belowbar,
     color=color.red,
     textcolor=color.white,
     text="SL",
     size=size.tiny)


// =====================================================
// BACKGROUND
// =====================================================

backgroundColor =
     trendLong and longScore >= minimumScore ?
     color.new(color.green, 92) :
     trendShort and shortScore >= minimumScore ?
     color.new(color.red, 92) :
     na


bgcolor(
     showBackground ?
     backgroundColor :
     na)


// =====================================================
// ALERTS
// =====================================================

alertcondition(
     longSignal,
     title="1M BUY",
     message="1M Precision Scalper: BUY")


alertcondition(
     shortSignal,
     title="1M SELL",
     message="1M Precision Scalper: SELL")


alertcondition(
     exitWinThisBar,
     title="Take Profit",
     message="1M Precision Scalper: TAKE PROFIT erreicht")


alertcondition(
     exitLossThisBar,
     title="Stop Loss",
     message="1M Precision Scalper: STOP LOSS erreicht")


// =====================================================
// DASHBOARD
// =====================================================

var table dashboard =
     table.new(
         position.top_right,
         2,
         11,
         border_width=1)


if barstate.islast and showDashboard

    // Header
    table.cell(
         dashboard,
         0,
         0,
         "1M SCALPER",
         bgcolor=color.black,
         text_color=color.white)

    table.cell(
         dashboard,
         1,
         0,
         "STATISTIK",
         bgcolor=color.black,
         text_color=color.white)


    // Trade Status
    table.cell(
         dashboard,
         0,
         1,
         "Trade")

    table.cell(
         dashboard,
         1,
         1,
         inTrade ?
         (tradeDirection == 1 ? "LONG OFFEN" : "SHORT OFFEN") :
         "KEIN TRADE",
         text_color=
         inTrade ?
         color.yellow :
         color.gray)


    // CRV
    table.cell(
         dashboard,
         0,
         2,
         "CRV")

    table.cell(
         dashboard,
         1,
         2,
         "1 : " + str.tostring(riskReward),
         text_color=color.aqua)


    // Total Trades
    table.cell(
         dashboard,
         0,
         3,
         "Trades")

    table.cell(
         dashboard,
         1,
         3,
         str.tostring(totalTrades),
         text_color=color.white)


    // Wins
    table.cell(
         dashboard,
         0,
         4,
         "Gewonnen")

    table.cell(
         dashboard,
         1,
         4,
         str.tostring(winningTrades),
         text_color=color.lime)


    // Losses
    table.cell(
         dashboard,
         0,
         5,
         "Stop Loss")

    table.cell(
         dashboard,
         1,
         5,
         str.tostring(losingTrades),
         text_color=color.red)


    // Winrate
    table.cell(
         dashboard,
         0,
         6,
         "Winrate")

    table.cell(
         dashboard,
         1,
         6,
         str.tostring(winRate, "#.##") + "%",
         text_color=
         winRate >= 50 ?
         color.lime :
         color.orange)


    // Long Trades
    table.cell(
         dashboard,
         0,
         7,
         "Long Entries")

    table.cell(
         dashboard,
         1,
         7,
         str.tostring(longTrades))


    // Short Trades
    table.cell(
         dashboard,
         0,
         8,
         "Short Entries")

    table.cell(
         dashboard,
         1,
         8,
         str.tostring(shortTrades))


    // ADX
    table.cell(
         dashboard,
         0,
         9,
         "ADX")

    table.cell(
         dashboard,
         1,
         9,
         str.tostring(adx, "#.0"),
         text_color=
         adx >= adxMinimum ?
         color.lime :
         color.orange)


    // Scores
    table.cell(
         dashboard,
         0,
         10,
         "L/S Score")

    table.cell(
         dashboard,
         1,
         10,
         str.tostring(longScore) +
         "/6 | " +
         str.tostring(shortScore) +
         "/6")
````
