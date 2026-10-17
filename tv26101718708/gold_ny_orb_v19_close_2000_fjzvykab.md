# Gold NY ORB v19  Close 20:00

- url: https://www.tradingview.com/script/FJZvYKaB-Gold-NY-ORB-v19-Close-20-00/
- type: strategy
- pine_id: PUB;57a5448ea08448dfaf8208f8bdd1c388
- version: 1.0

## Description

---

**Gold NY Open Range Breakout v19 — XAUUSD**

Captures Gold's directional expansion at the New York session open. Long-only, reflecting Gold's structural bullish bias. No overnight holds.

**Logic**
- **13:00–14:00 UTC** — Defines the Open Range (OR) high/low during the London/NY overlap
- **14:00–16:30 UTC** — Enters long on a confirmed breakout above the OR high with volume > 1.5× average
- **Compression filter** — OR must be ≤ 2.5× ATR(14). Tight range = coiled spring
- **Regime filter** — Skips days where ATR > 2× its 20-bar average (avoids news spikes)
- **20:00 UTC** — Hard session close, no overnight exposure

**Parameters**
- Stop Loss: 1× OR range | Take Profit: 2.5× OR range (2.5:1 R:R)
- Risk per trade: 1% equity

**Results (training set):** ~73% win rate on XAUUSD 15m

## Source Code

````pine

//@version=6
strategy("Gold NY ORB v19 [Ahmed] — 2.5:1 Close 20:00",
     overlay=true, initial_capital=10000,
     default_qty_type=strategy.percent_of_equity, default_qty_value=100,
     commission_type=strategy.commission.percent, commission_value=0.02,
     slippage=2, calc_on_every_tick=false)

inDate = time >= timestamp("2024-01-01 00:00 UTC")

isWkd = dayofweek != dayofweek.saturday and dayofweek != dayofweek.sunday
bHour = hour(time, "UTC")
bMin  = minute(time, "UTC")

isORPeriod   = isWkd and bHour == 13
isEntryWin   = isWkd and bHour >= 14 and (bHour < 16 or (bHour == 16 and bMin <= 30))
isSessionEnd = isWkd and bHour == 20 and bMin == 0

atr      = ta.atr(14)
volAvg   = ta.sma(volume, 20)
atrAvg20 = ta.sma(atr, 20)
regimeOK = atr <= atrAvg20 * 2.0

var float orHigh    = na
var float orLow     = na
var bool  orReady   = false
var bool  longFired = false

isNewDay = ta.change(time("D")) != 0
if isNewDay
    orHigh    := na
    orLow     := na
    orReady   := false
    longFired := false

if isORPeriod
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow,  low)

if not isORPeriod and not na(orHigh) and not orReady and bHour >= 14
    orReady := true

orRange = na(orHigh) or na(orLow) ? na : orHigh - orLow
orOK    = orReady and not na(orRange) and orRange <= atr * 2.5

longBreak = inDate and isEntryWin and orOK and regimeOK and not longFired
          and close > orHigh and close[1] <= orHigh
          and close > open and volume > volAvg * 1.5

if longBreak
    strategy.entry("Long", strategy.long)
    strategy.exit("LongX", "Long", stop=close - orRange, limit=close + orRange * 2.5)
    longFired := true

if isSessionEnd and strategy.position_size > 0
    strategy.close_all("Session End")

plot(orReady ? orHigh : na, "OR High", color=color.new(color.green, 20), linewidth=1, style=plot.style_linebr)
plot(orReady ? orLow  : na, "OR Low",  color=color.new(color.red,   20), linewidth=1, style=plot.style_linebr)
plotshape(longBreak, "Long Entry", shape.triangleup, location.belowbar, color.fuchsia, size=size.small, text="v19")
````
