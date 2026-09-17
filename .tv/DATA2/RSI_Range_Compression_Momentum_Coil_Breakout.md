<!-- tradingview-pine-id: PUB;348bd597ed364574839a3ae2884340fa -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSI Range Compression (Momentum Coil Breakout)

Source: https://www.tradingview.com/script/dwgn7hrE-Coil-Breaker-RSI-Range-Compression/

## Description

Most RSI strategies fire off static 30/70 thresholds. Coil Breaker does something different: it treats RSI itself as a volatility asset and watches for its own trading range to contract to a multi-month low — a "coil" — before trading the breakout when it releases.

How it works:

[*]Measures RSI's high-minus-low range over the last N bars and ranks it against its own history using a percentile score
[*]When that range compresses into the bottom percentile (default 20%), RSI is flagged as "coiled" — oscillating tightly around 50, momentum dormant
[*]A dynamic Bollinger-style channel is plotted directly around RSI so you can visually watch the coil tighten before it fires
[*]Once a squeeze has been active recently, a breakout above/below the established coil band (not the still-forming one) triggers an entry
[*]Direction is set by an EMA slope filter — the coil tells you something's coming, the EMA tells you which way
[*]Optional ADX filter keeps you out of truly dead, directionless chop
[*]ATR-based stop, fixed R-multiple target, and equity-percent risk sizing so every trade risks a constant dollar amount

Important — read before trading:
This is a breakout/momentum system, not a mean-reversion one, and it behaves accordingly: expect a low win rate (often 30–40%) alongside a high average win/loss ratio. Most coil breakouts fail or chop — you're paying for early entry with more false signals. The edge comes from asymmetric payoff (2R+ winners vs. 1R losers), not from being right often. Judge this strategy on profit factor and expectancy, not win rate. If a 60%+ win rate is what you're looking for, this isn't that system.

Tips:

[*]Backtest coilLen, pctLen, and the percentile threshold across your specific instrument/timeframe — coil dynamics vary a lot between assets
[*]Watch the equity curve shape, not just the total return — make sure gains aren't carried by one or two outlier trades
[*]Works best on instruments/timeframes with genuine volatility cycles (expansion/contraction), not ultra-choppy or illiquid markets
[*]Pair with higher-timeframe context if you want to filter out counter-trend coil breaks

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blitz_locked

//@version=6
strategy("RSI Range Compression (Momentum Coil Breakout)", overlay=false,
     initial_capital=10000, default_qty_type=strategy.percent_of_equity,
     default_qty_value=100, commission_type=strategy.commission.percent,
     commission_value=0.04, slippage=1)

//inputs
grpRSI = "RSI Coil"
rsiLen      = input.int(14, "RSI Length", group=grpRSI)
coilLen     = input.int(20, "RSI Range Lookback (N)", group=grpRSI)
pctLen      = input.int(100, "Percentile Lookback (history window)", group=grpRSI)
coilPct     = input.float(20, "Contraction Percentile Threshold (%)", minval=1, maxval=50, group=grpRSI)
coilMemory  = input.int(5, "Bars a Squeeze Stays 'Valid' After Firing", group=grpRSI)

grpTrend = "Trend / Direction Filter"
emaLen      = input.int(50, "EMA Length", group=grpTrend)
slopeLen    = input.int(5, "EMA Slope Lookback", group=grpTrend)

grpFilt = "Optional Extra Filter"
useADX      = input.bool(true, "Require Minimum ADX (avoid dead markets)", group=grpFilt)
adxLen      = input.int(14, "ADX Length", group=grpFilt)
adxMin      = input.float(15, "Minimum ADX", group=grpFilt)

grpRisk = "Risk Management"
atrLen      = input.int(14, "ATR Length", group=grpRisk)
atrMult     = input.float(2.0, "Stop = ATR x Mult", group=grpRisk)
rMultiple   = input.float(2.0, "Take Profit (R multiple)", group=grpRisk)
riskPct     = input.float(1.0, "Risk % of Equity per Trade", group=grpRisk)
allowLongs  = input.bool(true, "Allow Longs", group=grpRisk)
allowShorts = input.bool(true, "Allow Shorts", group=grpRisk)

//calculations
rsi = ta.rsi(close, rsiLen)

rsiHigh = ta.highest(rsi,coilLen)
rsiLow = ta.lowest(rsi, coilLen)
rsiRange = rsiHigh-rsiLow

rangePctRank = ta.percentrank(rsiRange,pctLen)
isSqueeze = rangePctRank<=coilPct

barsSinceSqueeze=ta.barssince(isSqueeze)
squeezeRecent=not na(barsSinceSqueeze) and barsSinceSqueeze<=coilMemory

ema = ta.ema(close,emaLen)
emaSlopeUp = ema>ema[slopeLen]
emaSlopeDown = ema<ema[slopeLen]

[diPlus,diMinus,adx]=ta.dmi(adxLen,adxLen)
adxOK = not useADX or adx>=adxMin

longTrigger = ta.crossover(rsi,rsiHigh[1]) and squeezeRecent and emaSlopeUp and adxOK and allowLongs
shortTrigger = ta.crossunder(rsi,rsiLow[1]) and squeezeRecent and emaSlopeDown and adxOK and allowShorts

//risk/position-sizing
atrVal = ta.atr(atrLen)
stopDist = atrVal*atrMult

riskAmt = strategy.equity * (riskPct/100)
qty = riskAmt/stopDist

if (longTrigger and strategy.position_size == 0)
    stopPrice = close - stopDist
    targetPrice = close + stopPrice * rMultiple
    strategy.entry("Long",strategy.long,qty=qty)
    strategy.exit("Long Exit", "Long", stop=stopPrice, limit=targetPrice)

if (shortTrigger and strategy.position_size == 0)
    stopPrice = close + stopDist
    targetPrice = close - stopDist * rMultiple
    strategy.entry("Short", strategy.short, qty=qty)
    strategy.exit("Short Exit", "Short", stop=stopPrice, limit=targetPrice)

// ───────────────────────────── PLOTTING ─────────────────────────────
// Direction-based color
rsiColor = rsi > rsi[1] ? color.new(#00ff88, 0) : color.new(#ff3366, 0)

// Glow effect: wide, transparent layers behind a sharp core line
plot(rsi, "RSI Glow Outer", color=color.new(rsiColor, 85), linewidth=8)
plot(rsi, "RSI Glow Mid",   color=color.new(rsiColor, 70), linewidth=5)
plot(rsi, "RSI Core",       color=rsiColor,                 linewidth=2)

// Reference levels
hline(70, "Overbought", color=color.new(color.gray, 60))
hline(50, "Midline", color=color.new(color.gray, 70))
hline(30, "Oversold", color=color.new(color.gray, 60))

// The "coil channel" — Bollinger-style band drawn around RSI's own range
bandTop = plot(rsiHigh, "Coil High", color=color.new(color.aqua, 40))
bandBot = plot(rsiLow, "Coil Low", color=color.new(color.aqua, 40))
fill(bandTop, bandBot, color=isSqueeze ? color.new(color.aqua, 70) : color.new(color.aqua, 92),
     title="Coil Zone")

// Highlight active squeeze bars directly on the RSI pane
bgcolor(isSqueeze ? color.new(color.yellow, 85) : na, title="Squeeze Active")

// Mark breakout signals
plotshape(longTrigger, "Long Signal", shape.triangleup, location.bottom,
     color=color.new(color.lime, 20), size=size.tiny)
plotshape(shortTrigger, "Short Signal", shape.triangledown, location.top,
     color=color.new(color.red, 20), size=size.tiny)
````
