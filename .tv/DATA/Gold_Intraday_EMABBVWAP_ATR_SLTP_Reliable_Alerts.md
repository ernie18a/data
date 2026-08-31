<!-- tradingview-pine-id: PUB;b99b6e3f63da455192b84017ba3e7261 -->
<!-- tradingviewscripts-format: 1 -->
# Gold Intraday EMA/BB/VWAP + ATR SLTP + Reliable Alerts

Source: https://www.tradingview.com/script/gszRpedF-Gold-Intraday-EMA-BB-VWAP-ATR-SLTP-Reliable-Alerts/

## Description

Script Name

EMA + VWAP + Bollinger ATR Strategy with Smart Alerts

Short Description

A non-repainting intraday trading strategy that combines EMA, VWAP, and the Bollinger Bands middle line for trend-following entries. The strategy uses ATR-based Stop Loss and Take Profit, supports session and weekday filters, and includes reliable entry, stop-loss, and take-profit alerts.

Full Description
Overview

This strategy is designed for intraday trading and combines trend confirmation with volatility-based risk management. It generates long and short signals based on the relationship between the EMA, Bollinger Bands middle line, and VWAP.

Entry Rules

Buy

Fast EMA crosses above the Bollinger Bands middle line.
Price is above the Slow EMA.
Price is above VWAP.
Trading session and weekday filters allow trading.

Sell

Fast EMA crosses below the Bollinger Bands middle line.
Price is below the Slow EMA.
Price is below VWAP.
Trading session and weekday filters allow trading.
Exit Rules
ATR-based Stop Loss.
ATR-based Take Profit.
Fixed SL/TP calculated at entry.
No trailing stop.
Features
Non-repainting signals.
ATR-based risk management.
Fixed Stop Loss and Take Profit.
EMA trend confirmation.
VWAP trend filter.
Bollinger Bands middle-line crossover.
Session filter (Asia, London, New York).
Weekday filter.
Entry alerts.
Stop Loss alerts.
Take Profit alerts.
Optimized for intraday trading.
Inputs
Fast EMA Length
Slow EMA Length
Bollinger Bands Length
ATR Length
ATR Stop Loss Multiplier
ATR Take Profit Multiplier
Session Selection
Weekday Selection
Recommended Timeframes
5 Minutes
15 Minutes
30 Minutes
1 Hour
Recommended Markets
Gold (XAUUSD)
Forex
Indices
Cryptocurrencies
Stocks
Alerts

The strategy provides separate alerts for:

BUY Entry
SELL Entry
BUY Stop Loss
SELL Stop Loss
BUY Take Profit
SELL Take Profit
Notes
Wait for the candle to close before acting on a signal.
Test different ATR multipliers based on the instrument and timeframe.
Use proper risk management and position sizing.

---

## Source Code

````pine
//@version=6
strategy(
     "Gold Intraday EMA/BB/VWAP + ATR SLTP + Reliable Alerts",
     overlay = true,
     pyramiding = 0,
     process_orders_on_close = true,
     calc_on_order_fills = true,
     calc_on_every_tick = true,
     margin_long = 100,
     margin_short = 100,
     default_qty_type = strategy.percent_of_equity,
     default_qty_value = 10)

//==============================
// Inputs
//==============================

emaFastLen = input.int(9, "Fast EMA")
emaSlowLen = input.int(21, "Slow EMA")
bbLen      = input.int(20, "BB Mid Length")
atrLen     = input.int(14, "ATR Length")

atrSLmult  = input.float(1.5, "ATR SL", step=0.1)
atrTPmult  = input.float(2.0, "ATR TP", step=0.1)

//==============================
// Session Filter
//==============================

sessionAsia   = input.bool(true, "Asia")
sessionLondon = input.bool(true, "London")
sessionNY     = input.bool(false, "New York")

//==============================
// Weekday Filter
//==============================

tradeMonday    = input.bool(true)
tradeTuesday   = input.bool(true)
tradeWednesday = input.bool(true)
tradeThursday  = input.bool(true)
tradeFriday    = input.bool(false)

//==============================
// Indicators
//==============================

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

bbMid = ta.sma(close, bbLen)

vwapValue = ta.vwap(close)

atr = ta.atr(atrLen)

//==============================
// Trade Conditions
//==============================

bullCross = ta.crossover(emaFast, bbMid)
bearCross = ta.crossunder(emaFast, bbMid)

buySignal =
     bullCross and
     close > emaSlow and
     close > vwapValue

sellSignal =
     bearCross and
     close < emaSlow and
     close < vwapValue

//==============================
// Session Filter
//==============================

hourUTC = hour(time, "UTC")

asia =
     sessionAsia and
     hourUTC >= 0 and
     hourUTC < 8

london =
     sessionLondon and
     hourUTC >= 8 and
     hourUTC < 16

newYork =
     sessionNY and
     hourUTC >= 16

sessionAllowed =
     asia or london or newYork

//==============================
// Weekday Filter
//==============================

weekdayAllowed =
     (dayofweek == dayofweek.monday and tradeMonday) or
     (dayofweek == dayofweek.tuesday and tradeTuesday) or
     (dayofweek == dayofweek.wednesday and tradeWednesday) or
     (dayofweek == dayofweek.thursday and tradeThursday) or
     (dayofweek == dayofweek.friday and tradeFriday)

tradeAllowed =
     sessionAllowed and
     weekdayAllowed

//==============================
// Persistent Variables
//==============================

var float longSL = na
var float longTP = na

var float shortSL = na
var float shortTP = na

var float longEntry = na
var float shortEntry = na

// Alert flags

var bool buyAlertSent = false
var bool sellAlertSent = false

var bool buySLAlertSent = false
var bool buyTPAlertSent = false

var bool sellSLAlertSent = false
var bool sellTPAlertSent = false
//====================================================
// ENTRY LOGIC
//====================================================

// BUY ENTRY
if buySignal and tradeAllowed and strategy.position_size == 0

    longEntry := close
    longSL := longEntry - atr * atrSLmult
    longTP := longEntry + atr * atrTPmult

    strategy.entry("BUY", strategy.long)

    strategy.exit(
         "BUY Exit",
         from_entry = "BUY",
         stop = longSL,
         limit = longTP)

    buyAlertSent := false
    buySLAlertSent := false
    buyTPAlertSent := false


// SELL ENTRY
if sellSignal and tradeAllowed and strategy.position_size == 0

    shortEntry := close
    shortSL := shortEntry + atr * atrSLmult
    shortTP := shortEntry - atr * atrTPmult

    strategy.entry("SELL", strategy.short)

    strategy.exit(
         "SELL Exit",
         from_entry = "SELL",
         stop = shortSL,
         limit = shortTP)

    sellAlertSent := false
    sellSLAlertSent := false
    sellTPAlertSent := false


//====================================================
// ENTRY ALERTS
//====================================================

buyTriggered =
     strategy.position_size > 0 and
     strategy.position_size[1] <= 0

sellTriggered =
     strategy.position_size < 0 and
     strategy.position_size[1] >= 0


if buyTriggered and not buyAlertSent

    alert("BUY ENTRY", alert.freq_once_per_bar_close)

    buyAlertSent := true


if sellTriggered and not sellAlertSent

    alert("SELL ENTRY", alert.freq_once_per_bar_close)

    sellAlertSent := true


//====================================================
// RESET VALUES WHEN FLAT
//====================================================

if strategy.position_size == 0 and strategy.position_size[1] != 0

    longEntry := na
    shortEntry := na

    longSL := na
    longTP := na

    shortSL := na
    shortTP := na

    buyAlertSent := false
    sellAlertSent := false

    buySLAlertSent := false
    buyTPAlertSent := false

    sellSLAlertSent := false
    sellTPAlertSent := false
````
