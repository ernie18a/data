# 55 Moving Average Fan 

- url: https://www.tradingview.com/script/ZAKuIP37-55-Moving-Average-Fan/
- type: indicator
- pine_id: PUB;61c1bad0abee4a62bcb013fa704080a2
- version: 1.0

## Description

EMA 26/55/100/200 fan system. Cross signals, fan-out detection, EMA 55 retest entries, 200 EMA as invalidation line.

Three states: stacked bull (26>55>100>200, fanned out by min %), stacked bear (mirror), neutral. EMA 55 retests in a fanned bull state are buy opportunities; 200 EMA = SL invalidation.

How to use:

Best on daily ; also works on 4H
Look for "Cross up/down" labels at EMA 26/55 crosses
After fan-out, dip to EMA 55 = entry (triangle up/down marker)

SL below EMA 200 in bull regime, above in bear

Alerts: 26/55 Cross Up/Down, 55 Retest Buy/Sell, Bull/Bear Fan-out.

## Source Code

````pine
//@version=5
indicator("55 Moving Average Fan ", overlay=true, max_lines_count=500, max_labels_count=500)

// Built from sunny's notes:
//   - EMA 26, 55, 100, 200
//   - Wait for 55 and 26 to cross and FAN OUT
//   - After fan-out, any retrace to 55 is buying opportunity
//   - 100 and 200 can turn into S+R
//   - Best on daily, works on 4h
//   - Use EMA to trail stop loss
//   - Bullish: buy dip to 100/200, SL below 200 (invalidation)
//   - When 26/55 cross again, signal to exit positions

// Inputs
ema1Len    = input.int(26,  "EMA 1 (fast)")
ema2Len    = input.int(55,  "EMA 2")
ema3Len    = input.int(100, "EMA 3")
ema4Len    = input.int(200, "EMA 4 (trend filter)")
fanGapPct  = input.float(0.5, "Fan-out gap min % between 26 & 55", step=0.1)
showCross  = input.bool(true,"Show 26/55 cross signals")
showRetest = input.bool(true,"Mark EMA 55 retests after fan-out")
retestTol  = input.float(0.3,"EMA 55 retest tolerance %", step=0.1)
useDailyTF = input.bool(false,"Force daily timeframe data")
htf        = input.timeframe("D", "Higher timeframe (when forced)")
col1       = input.color(color.red,    "EMA 26")
col2       = input.color(color.yellow, "EMA 55")
col3       = input.color(color.aqua,   "EMA 100")
col4       = input.color(color.fuchsia,"EMA 200")

// HTF source helper
f_src(s) => useDailyTF ? request.security(syminfo.tickerid, htf, s, lookahead=barmerge.lookahead_off) : s
c_ = f_src(close)

ema1 = ta.ema(c_, ema1Len)
ema2 = ta.ema(c_, ema2Len)
ema3 = ta.ema(c_, ema3Len)
ema4 = ta.ema(c_, ema4Len)

plot(ema1, "EMA 26",  color=col1, linewidth=1)
plot(ema2, "EMA 55",  color=col2, linewidth=2)
plot(ema3, "EMA 100", color=col3, linewidth=2)
plot(ema4, "EMA 200", color=col4, linewidth=3)

// Trend regime
bullStack = ema1 > ema2 and ema2 > ema3 and ema3 > ema4
bearStack = ema1 < ema2 and ema2 < ema3 and ema3 < ema4

// Cross signals
crossUp   = ta.crossover (ema1, ema2)
crossDown = ta.crossunder(ema1, ema2)

// Fan-out: 26 and 55 separated by at least fanGapPct%
gap = math.abs(ema1 - ema2) / ema2 * 100.0
fannedOut = gap >= fanGapPct

bullSetup = bullStack and fannedOut
bearSetup = bearStack and fannedOut

plotshape(crossUp   and showCross, "Cross up",   shape.labelup,   location.belowbar, color=color.green, size=size.small, text="X up", textcolor=color.white)
plotshape(crossDown and showCross, "Cross down", shape.labeldown, location.abovebar, color=color.red,   size=size.small, text="X dn", textcolor=color.white)

// EMA 55 retest in fanned bull state -> buying op
retestBuy  = bullSetup and low <= ema2 * (1 + retestTol/100.0) and low >= ema2 * (1 - retestTol/100.0) and close > ema2
retestSell = bearSetup and high >= ema2 * (1 - retestTol/100.0) and high <= ema2 * (1 + retestTol/100.0) and close < ema2

plotshape(retestBuy  and showRetest, "55 retest buy",  shape.triangleup,   location.belowbar, color=color.green, size=size.small, text="55")
plotshape(retestSell and showRetest, "55 retest sell", shape.triangledown, location.abovebar, color=color.red,   size=size.small, text="55")

// EMA 200 as invalidation line
plot(bullStack ? ema4 : na, "Bull SL (200 EMA)", color=color.new(color.red, 50), style=plot.style_circles, linewidth=2)
plot(bearStack ? ema4 : na, "Bear SL (200 EMA)", color=color.new(color.red, 50), style=plot.style_circles, linewidth=2)

// Background tint by regime
bgcolor(bullSetup ? color.new(color.green, 95) : bearSetup ? color.new(color.red, 95) : na)

alertcondition(crossUp,     "26/55 Cross Up",   "EMA 26 crossed above EMA 55")
alertcondition(crossDown,   "26/55 Cross Down", "EMA 26 crossed below EMA 55")
alertcondition(retestBuy,   "55 Retest Buy",    "Bullish 55 EMA retest in fanned state")
alertcondition(retestSell,  "55 Retest Sell",   "Bearish 55 EMA retest in fanned state")
alertcondition(bullSetup and not bullSetup[1], "Bull Fan-out", "Bullish stack with fan-out")
alertcondition(bearSetup and not bearSetup[1], "Bear Fan-out", "Bearish stack with fan-out")
````
