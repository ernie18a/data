# Momentum Bands | Breakout

- url: https://www.tradingview.com/script/gqaZYhUN-Momentum-Bands-Breakout/
- type: strategy
- pine_id: PUB;c68d545af1cd4dec807fe11efac19c81
- version: 1.0

## Description

This strategy hunts for N-bar breakouts confirmed by volume expansion — but instead of trading every breakout blindly (like a standard Opening Range or Donchian breakout), it runs price through a trend filter and an RSI momentum check first. Breakouts that align with the EMA trend and show accelerating RSI get traded as genuine continuation moves. Breakouts that fire against the prevailing trend, with RSI already rolling over, get treated as exhaustion — and faded instead of chased. Built-in ATR-based position sizing and a trailing stop round it out into a complete, risk-managed system rather than just a signal generator.

[b]Key Features[/b]
[list]
[*]Trend-gated entries — EMA fast/slow cross defines regime; longs only trade with the trend, fades only trade against it
[*]Volume-confirmed breakouts — requires expansion above the rolling volume average, not just a price poke
[*]RSI momentum-exhaustion filter — distinguishes accelerating momentum (real breakout) from divergence (fakeout)
[*]ATR-based risk sizing — position size auto-scales to a fixed % of equity risked, using ATR-derived stop distance
[*]ATR trailing stop — lets winners run instead of capping them at a fixed target
[*]Glowing ATR bands — layered, fading visual bands around trend basis for at-a-glance regime read
[*]Breakout candle highlighting — candles color-shift on signal and while a position is open
[*]Live + archived trailing-stop path — see the stop while a trade is open, and its full trail once closed
[/list]
[b]How It Works[/b]
[list]
[*]Price breaks above the highest high of the last N bars with volume above its rolling average — that's the breakout trigger.
[*]EMA fast vs. slow defines trend direction.
[*]RSI and its rate of change are checked at the breakout bar: still climbing and near its own recent peak = momentum confirms. Already fading or below its recent peak = momentum diverges.
[*]Confirmed + with-trend → long. Diverging + against-trend → short (fade).
[*]Every entry is sized off account risk %, not a fixed share count, and exits on an ATR stop plus ATR trailing stop.
[/list]

[b]Tips[/b]
[list]
[*]Backtest across multiple symbols and volatility regimes before trusting the defaults — breakout/fade systems behave very differently in trending vs. choppy markets
[*]Widen nLen (breakout lookback) on lower timeframes to reduce noise-driven false breakouts
[*]If fades are underperforming, try disabling allowShorts and running long-only to isolate performance
[*]Tighten rsiConfirmLvl for higher-conviction (fewer, cleaner) long signals
[*]Use the glowing bands as a quick visual regime check even when not actively watching signals
[/list]

## Source Code

````pine
//@version=6
strategy("Momentum Exhaustion Breakout", overlay=true,
     initial_capital=100000, default_qty_type=strategy.fixed, pyramiding=0,
     commission_type=strategy.commission.percent, commission_value=0.05, slippage=1)

// ------------------------- INPUTS -------------------------
nLen        = input.int(20, "Breakout Lookback (N bars)")
volLen      = input.int(20, "Volume MA Length")
volMult     = input.float(1.5, "Volume Expansion Multiplier", step=0.1)

emaFastLen  = input.int(20, "EMA Fast (trend filter)")
emaSlowLen  = input.int(50, "EMA Slow (trend filter)")

rsiLen        = input.int(14, "RSI Length")
rocLen        = input.int(5, "RSI Rate-of-Change Lookback")
rsiConfirmLvl = input.float(55, "Min RSI to Confirm Longs")

atrLen       = input.int(14, "ATR Length")
atrSLMult    = input.float(1.5, "Initial Stop = ATR x")
atrTrailMult = input.float(1.5, "Trailing Stop = ATR x")
riskPct      = input.float(1.0, "Risk % of Equity per Trade")
allowShorts  = input.bool(true, "Enable Fade-the-Fakeout Shorts")

grpViz = "Visuals"
bandMult   = input.float(2.0, "Band Width = ATR x", step=0.1, group=grpViz)
bullColor  = input.color(color.rgb(45, 212, 191), "Bull Color", group=grpViz)   // mint/cyan
bearColor  = input.color(color.rgb(255, 67, 53), "Bear Color", group=grpViz)   // amber
showBands   = input.bool(true, "Show ATR Bands", group=grpViz)
showCandles = input.bool(true, "Show Breakout Candles", group=grpViz)

// ------------------------- TREND CONTEXT -------------------------
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
uptrend   = emaFast > emaSlow
downtrend = emaFast < emaSlow

// ------------------------- BREAKOUT + MOMENTUM -------------------------
priorHigh    = ta.highest(high[1], nLen)
priorLow     = ta.lowest(low[1], nLen)
volAvg       = ta.sma(volume, volLen)
volExpansion = volume > volAvg * volMult

rsiVal     = ta.rsi(close, rsiLen)
rsiROC     = rsiVal - rsiVal[rocLen]
priorRSIPk = ta.highest(rsiVal[1], nLen)

breakoutUp = high > priorHigh and volExpansion

longSignal = breakoutUp and uptrend and rsiROC > 0 and rsiVal > rsiConfirmLvl
fadeSignal = allowShorts and breakoutUp and not uptrend and
     (rsiVal < priorRSIPk or rsiROC < 0)

atrVal = ta.atr(atrLen)

// ------------------------- POSITION SIZING -------------------------
riskAmount = strategy.equity * (riskPct / 100)
slDistance = atrVal * atrSLMult
qty        = slDistance > 0 ? riskAmount / slDistance : 0

// ------------------------- ENTRIES -------------------------
if longSignal and strategy.position_size == 0 and qty > 0
    strategy.entry("Long", strategy.long, qty=qty)

if fadeSignal and strategy.position_size == 0 and qty > 0
    strategy.entry("Fade Short", strategy.short, qty=qty)

// ------------------------- TRAILING EXIT -------------------------
if strategy.position_size > 0
    stopLong = strategy.position_avg_price - slDistance
    strategy.exit("Exit Long", "Long", stop=stopLong,
         trail_points=atrVal * atrTrailMult, trail_offset=atrVal * atrTrailMult)

if strategy.position_size < 0
    stopShort = strategy.position_avg_price + slDistance
    strategy.exit("Exit Short", "Fade Short", stop=stopShort,
         trail_points=atrVal * atrTrailMult, trail_offset=atrVal * atrTrailMult)

// ------------------------- SIGNAL STATE (persists between signals) -------------------------
var color stateColor = color.new(color.gray, 60)
if longSignal
    stateColor := bullColor
if fadeSignal
    stateColor := bearColor

// ------------------------- ATR BANDS WITH GLOW FADE -------------------------
bandWidth = atrVal * bandMult
upperBand = emaFast + bandWidth
lowerBand = emaFast - bandWidth

// Basis line, glowing outward in the current state color
basisPlot = plot(showBands ? emaFast : na, "Trend Basis", color=color.new(stateColor, 40), linewidth=1)

// Upper band: 3 layered copies, wide+faint underneath -> narrow+solid on top = fade-in glow
plot(showBands ? upperBand : na, "Upper Glow Outer", color=color.new(bullColor, 90), linewidth=6)
plot(showBands ? upperBand : na, "Upper Glow Mid",   color=color.new(bullColor, 80), linewidth=3)
upperPlot = plot(showBands ? upperBand : na, "Upper Band Core", color=color.new(bullColor, 55), linewidth=1)

// Lower band: same glow treatment in bear color
plot(showBands ? lowerBand : na, "Lower Glow Outer", color=color.new(bearColor, 90), linewidth=6)
plot(showBands ? lowerBand : na, "Lower Glow Mid",   color=color.new(bearColor, 80), linewidth=3)
lowerPlot = plot(showBands ? lowerBand : na, "Lower Band Core", color=color.new(bearColor, 55), linewidth=1)

fill(basisPlot, upperPlot, color=uptrend ? color.new(bullColor, 88) : na, title="Upper Fill")
fill(basisPlot, lowerPlot, color=downtrend ? color.new(bearColor, 88) : na, title="Lower Fill")

// ------------------------- BREAKOUT CANDLES -------------------------
candleColor = longSignal or (strategy.position_size > 0) ? bullColor :
     fadeSignal or (strategy.position_size < 0) ? bearColor : na

plotcandle(showCandles ? open : na, showCandles ? high : na, showCandles ? low : na, showCandles ? close : na,
     title="Breakout Candles", color=candleColor, bordercolor=candleColor, wickcolor=candleColor)
````
