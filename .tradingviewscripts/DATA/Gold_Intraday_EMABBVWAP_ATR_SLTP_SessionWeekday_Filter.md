<!-- tradingview-pine-id: PUB;cfca8c011e0044d8858fb78875b07577 -->
<!-- tradingviewscripts-format: 1 -->
# Gold Intraday EMA/BB/VWAP + ATR SL/TP + Session/Weekday Filter

Source: https://www.tradingview.com/script/mZYK8jsg-Gold-Intraday-EMA-BB-VWAP-ATR-SL-TP-Session-Weekday-Filter/

## Description

This strategy you’ve built is a trend‑following crossover system designed specifically for Gold (XAUUSD), with multiple layers of filtering and risk control. Let me break down its mechanics and purpose:
EMA vs BB Midline crossover:

The fast EMA crossing above the Bollinger Band midline (20‑SMA) signals bullish momentum.

Crossing below signals bearish momentum.

VWAP filter: Ensures trades only trigger when price is aligned with institutional value zones (longs above VWAP, shorts below VWAP).

EMA slow confirmation: Adds trend validation by requiring price to be above/below a slower EMA.
Risk Management
ATR‑based stop loss (SL):

User chooses multiplier (e.g., 1×, 2.5×, 3× ATR).

Wider stops reduce false exits but increase drawdown.

ATR‑based take profit (TP):

User chooses multiplier (e.g., 2×, 3× ATR).

Defines risk/reward ratio directly.

This flexibility lets you test different R:R setups in backtests

---

## Source Code

````pine
//@version=6
strategy("Gold Intraday EMA/BB/VWAP + ATR SL/TP + Session/Weekday Filter", 
     overlay=true, margin_long=100, margin_short=100, 
     default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// === Inputs ===
emaFastLen   = input.int(9, "Fast EMA Length")
emaSlowLen   = input.int(21, "Slow EMA Length")
bbLen        = input.int(20, "BB Mid (SMA) Length")
atrLen       = input.int(14, "ATR Length")

// User‑defined multipliers
atrSLmult    = input.float(1.5, "ATR Stop Multiplier", minval=0.5, step=0.1)
atrTPmult    = input.float(2.0, "ATR Take Profit Multiplier", minval=0.5, step=0.1)

// Session filter inputs
sessionAsia   = input.bool(true, "Trade Asian Session (00:00–08:00 UTC)")
sessionLondon = input.bool(true, "Trade London Session (08:00–16:00 UTC)")
sessionNY     = input.bool(false, "Trade New York Session (16:00–23:59 UTC)")

// Weekday filter inputs
tradeMonday    = input.bool(true, "Trade Monday")
tradeTuesday   = input.bool(true, "Trade Tuesday")
tradeWednesday = input.bool(true, "Trade Wednesday")
tradeThursday  = input.bool(true, "Trade Thursday")
tradeFriday    = input.bool(false, "Trade Friday")

// === Core Calculations ===
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
bbMid   = ta.sma(close, bbLen)
vwapVal = ta.vwap(close)
atrVal  = ta.atr(atrLen)

// ATR‑based SL/TP
atrStopBuy  = close - atrSLmult * atrVal
atrStopSell = close + atrSLmult * atrVal
atrTPBuy    = close + atrTPmult * atrVal
atrTPSell   = close - atrTPmult * atrVal

// === Crossover Logic ===
bullCross = ta.crossover(emaFast, bbMid)
bearCross = ta.crossunder(emaFast, bbMid)

// === Signal Conditions ===
buySignal  = bullCross and close > emaSlow and close > vwapVal
sellSignal = bearCross and close < emaSlow and close < vwapVal

// === Session Filter Logic ===
hourUTC = hour(time, "UTC")
inAsia   = sessionAsia   and (hourUTC >= 0  and hourUTC < 8)
inLondon = sessionLondon and (hourUTC >= 8  and hourUTC < 16)
inNY     = sessionNY     and (hourUTC >= 16 and hourUTC < 24)
sessionAllowed = inAsia or inLondon or inNY

// === Weekday Filter Logic ===
dayOfWeek = dayofweek(time)
weekdayAllowed = (dayOfWeek == dayofweek.monday    and tradeMonday) or
                 (dayOfWeek == dayofweek.tuesday   and tradeTuesday) or
                 (dayOfWeek == dayofweek.wednesday and tradeWednesday) or
                 (dayOfWeek == dayofweek.thursday  and tradeThursday) or
                 (dayOfWeek == dayofweek.friday    and tradeFriday)

// === Final Trade Permission ===
tradeAllowed = sessionAllowed and weekdayAllowed

// === Strategy Entries ===
if (buySignal and tradeAllowed)
    strategy.entry("BUY", strategy.long)
    strategy.exit("BUY Exit", "BUY", stop=atrStopBuy, limit=atrTPBuy)

if (sellSignal and tradeAllowed)
    strategy.entry("SELL", strategy.short)
    strategy.exit("SELL Exit", "SELL", stop=atrStopSell, limit=atrTPSell)

// === Plotting ===
plot(emaFast, "EMA Fast", color=color.blue)
plot(emaSlow, "EMA Slow", color=color.purple)
plot(bbMid,   "BB Mid",   color=color.orange)
plot(vwapVal, "VWAP",     color=color.aqua)

// ATR Stop/TP lines
plot(buySignal ? atrStopBuy : na, "ATR Stop Buy", color=color.red, style=plot.style_linebr)
plot(buySignal ? atrTPBuy   : na, "ATR TP Buy",   color=color.green, style=plot.style_linebr)
plot(sellSignal ? atrStopSell : na, "ATR Stop Sell", color=color.red, style=plot.style_linebr)
plot(sellSignal ? atrTPSell   : na, "ATR TP Sell",   color=color.green, style=plot.style_linebr)

// Markers
plotshape(buySignal and tradeAllowed, title="Buy Signal", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, size=size.small)
plotshape(sellSignal and tradeAllowed, title="Sell Signal", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, size=size.small)
````
