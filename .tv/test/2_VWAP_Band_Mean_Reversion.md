<!-- tradingview-pine-id: PUB;559ebcc6580a4e30a24892bd421d89f2 -->
<!-- tradingviewscripts-format: 1 -->
# 2 — VWAP Band Mean Reversion

Source: https://www.tradingview.com/script/CNC6abWu-VWAP-Band-Mean-Reversion/

## Description

VWAP BAND MEAN REVERSION
Fades overextensions from session VWAP: when price stretches beyond a standard-deviation band and snaps back, enter toward VWAP. Works best on choppy, range-bound days; an ADX filter blocks trades on strong trend days. Flat by EOD. Recommended chart: 5-min, ES/MES (index futures revert well)

---

## Source Code

````pine
//@version=6
// ============================================================
// 2) VWAP BAND MEAN REVERSION
// Fades overextensions from session VWAP: when price stretches
// beyond a standard-deviation band and snaps back, enter toward
// VWAP. Works best on choppy, range-bound days; an ADX filter
// blocks trades on strong trend days. Flat by EOD.
// Recommended chart: 5-min, ES/MES (index futures revert well)
// ============================================================
strategy("2 — VWAP Band Mean Reversion", shorttitle="VWAP-MR",
     overlay=true, initial_capital=25000,
     default_qty_type=strategy.fixed, default_qty_value=1,
     commission_type=strategy.commission.cash_per_contract, commission_value=2.50,
     slippage=1, margin_long=0, margin_short=0)
 
// -- Inputs ------------------------------------------------
sessionStr  = input.session("0930-1600", "Trading session")
flatStr     = input.session("1555-1600", "Force-flat window")
tz          = input.string("America/New_York", "Session timezone")
devLen      = input.int(50, "Deviation lookback (bars)", minval=5)
bandMult    = input.float(2.0, "Band multiple (std devs)", step=0.1)
atrLen      = input.int(14, "ATR length")
atrMult     = input.float(2.0, "ATR stop multiple", step=0.1)
useAdx      = input.bool(true, "Only trade when ADX below threshold")
adxLen      = input.int(14, "ADX length")
adxMax      = input.float(30, "Max ADX (skip trend days)", step=1)
allowShorts = input.bool(true, "Allow shorts")
 
// -- Session -----------------------------------------------
inSession = not na(time(timeframe.period, sessionStr, tz))
inFlat    = not na(time(timeframe.period, flatStr, tz))
 
// -- VWAP + bands ------------------------------------------
vwapVal = ta.vwap(hlc3)
dev     = ta.stdev(close - vwapVal, devLen)
upper   = vwapVal + dev * bandMult
lower   = vwapVal - dev * bandMult
atr     = ta.atr(atrLen)
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
 
regimeOk = not useAdx or adx < adxMax
 
// -- Entries: re-cross of band back toward VWAP ------------
longSig  = ta.crossover(close, lower)
shortSig = ta.crossunder(close, upper)
 
canTrade = inSession and not inFlat and regimeOk and strategy.position_size == 0
if canTrade and longSig
    strategy.entry("Long", strategy.long)
if canTrade and shortSig and allowShorts
    strategy.entry("Short", strategy.short)
 
// -- Exits: target = VWAP, stop = ATR multiple -------------
var float stopPrice = na
justEntered = strategy.position_size != 0 and strategy.position_size[1] == 0
if justEntered
    stopPrice := strategy.position_size > 0 ?
         strategy.position_avg_price - atr * atrMult :
         strategy.position_avg_price + atr * atrMult
 
if strategy.position_size > 0
    strategy.exit("XL", "Long", stop=stopPrice, limit=vwapVal)
if strategy.position_size < 0
    strategy.exit("XS", "Short", stop=stopPrice, limit=vwapVal)
 
// -- End-of-day flat ---------------------------------------
if inFlat or not inSession
    strategy.cancel_all()
    strategy.close_all(comment="EOD flat")
 
// -- Plots -------------------------------------------------
plot(vwapVal, "VWAP",  color=color.orange, linewidth=2)
plot(upper,   "Upper", color=color.new(color.red, 40))
plot(lower,   "Lower", color=color.new(color.green, 40))
````
