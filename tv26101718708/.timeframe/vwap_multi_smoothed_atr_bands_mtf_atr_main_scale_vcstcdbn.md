# VWAP Multi Smoothed ATR Bands - MTF ATR Main Scale

- url: https://www.tradingview.com/script/vCsTcdBN-VWAP-Multi-Smoothed-ATR-Bands-MTF-ATR-Main-Scale/
- type: indicator
- pine_id: PUB;a0839d7afebc403d977f3eba03f09163
- version: 1.0

## Description

VWAP indicator that marks out certain band/channel from VWAP based on ATR of time frame of choice

## Source Code

````pine
//@version=6
indicator("VWAP Multi Smoothed ATR Bands - MTF ATR Main Scale", overlay=true)

// === Inputs ===
src = input.source(hlc3, "Source")

atrTimeframe = input.timeframe("5", "ATR Timeframe")
atrLength = input.int(14, "ATR Length", minval=1)
atrSmoothLength = input.int(100, "ATR Smooth Length", minval=1)

m1 = input.float(1.0, "ATR Multiplier 1", step=0.1)
m2 = input.float(2.0, "ATR Multiplier 2", step=0.1)
m3 = input.float(3.0, "ATR Multiplier 3", step=0.1)

// === VWAP ===
// TradingView built-in session VWAP
vwapValue = ta.vwap(src)

// === Higher Timeframe Smoothed ATR ===
// Method A:
// ATR and EMA smoothing are both calculated on the selected ATR timeframe.
smoothAtr = request.security(syminfo.tickerid,atrTimeframe,ta.ema(ta.atr(atrLength), atrSmoothLength),barmerge.gaps_off,barmerge.lookahead_off)

// === Bands ===
upper1 = vwapValue + smoothAtr * m1
lower1 = vwapValue - smoothAtr * m1

upper2 = vwapValue + smoothAtr * m2
lower2 = vwapValue - smoothAtr * m2

upper3 = vwapValue + smoothAtr * m3
lower3 = vwapValue - smoothAtr * m3

// === Plots ===
plot(vwapValue, title="VWAP", linewidth=2, color=color.blue)

plot(upper1, title="Upper 1 ATR", color=color.green)
plot(lower1, title="Lower 1 ATR", color=color.green)

plot(upper2, title="Upper 2 ATR", color=color.orange)
plot(lower2, title="Lower 2 ATR", color=color.orange)

plot(upper3, title="Upper 3 ATR", color=color.purple)
plot(lower3, title="Lower 3 ATR", color=color.purple)
````
