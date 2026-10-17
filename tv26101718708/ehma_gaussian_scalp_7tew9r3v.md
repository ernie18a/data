# EHMA + Gaussian Scalp

- url: https://www.tradingview.com/script/7TeW9R3v-EHMA-Gaussian-Scalp/
- type: strategy
- pine_id: PUB;0e1dee7046924b83bd103cfe1d5d0f13
- version: 1.0

## Description

Entry: EHMA turns upward AND Gaussian filter is rising (confluence)
Exit:  EHMA turns downward

## Source Code

````pine
// ============================================================================
// AMZN 1-Min Scalp — Hybrid EHMA(30) + Gaussian(20, 3-pole)
// ============================================================================
// Entry: EHMA turns upward AND Gaussian filter is rising (confluence)
// Exit:  EHMA turns downward
// TP/SL: 4x ATR / 2x ATR
//
// Backtested on BATS:AMZN 1-min (Feb 9-20 2026, ~3194 bars)
//   0.00% comm: +5.47%, PF 4.48, DD -0.52%, Sharpe 1.06
//   0.02% comm: +4.09%, PF 2.81, DD -0.73%, Sharpe 0.81
//   0.05% comm: +2.05%, PF 1.61, DD -1.25%, Sharpe 0.41
// ============================================================================

//@version=6
strategy("EHMA + Gaussian Scalp", overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=1000,
     commission_type=strategy.commission.percent,
     commission_value=0.00,
     slippage=0,
     pyramiding=1,
     margin_long=0, margin_short=0,
     calc_on_every_tick=false,
     fill_orders_on_standard_ohlc=true)

// ── Inputs ──────────────────────────────────────────────────────────────────
ehmaLen   = input.int(30,  "EHMA Length",       minval=2)
gaussLen  = input.int(20,  "Gaussian Length",    minval=2)
gaussPoles = input.int(3,  "Gaussian Poles",     minval=1, maxval=4)
atrLen    = input.int(14,  "ATR Length",         minval=1)
tpMult    = input.float(4.0, "TP (ATR mult)",   minval=0.1, step=0.5)
slMult    = input.float(2.0, "SL (ATR mult)",   minval=0.1, step=0.5)

// ── EHMA (Exponential Hull Moving Average) ──────────────────────────────────
// EHMA = EMA( 2·EMA(n/2) − EMA(n) , √n )
ehmaHalf  = ehmaLen / 2
ehmaSqrt  = math.round(math.sqrt(ehmaLen))
ehmaDiff  = 2 * ta.ema(close, ehmaHalf) - ta.ema(close, ehmaLen)
ehma      = ta.ema(ehmaDiff, ehmaSqrt)

// ── Gaussian Filter (cascaded EMAs) ─────────────────────────────────────────
gf1 = ta.ema(close, gaussLen)
gf2 = gaussPoles >= 2 ? ta.ema(gf1, gaussLen) : gf1
gf3 = gaussPoles >= 3 ? ta.ema(gf2, gaussLen) : gf2
gf4 = gaussPoles >= 4 ? ta.ema(gf3, gaussLen) : gf3
gf  = gf4

// ── ATR ─────────────────────────────────────────────────────────────────────
atrVal = ta.atr(atrLen)

// ── Signal Logic ────────────────────────────────────────────────────────────
ehmaRising     = ehma > ehma[1]
ehmaWasFalling = ehma[1] <= ehma[2]
ehmaTurnUp     = ehmaRising and ehmaWasFalling

ehmaFalling    = ehma < ehma[1]
ehmaWasRising  = ehma[1] >= ehma[2]
ehmaTurnDown   = ehmaFalling and ehmaWasRising

gfRising = gf > gf[1]

longEntry = ehmaTurnUp and gfRising
longExit  = ehmaTurnDown

// ── Strategy Orders ─────────────────────────────────────────────────────────
if longEntry
    strategy.entry("Long", strategy.long)
    strategy.exit("TP/SL", "Long",
         profit = atrVal * tpMult / syminfo.mintick,
         loss   = atrVal * slMult / syminfo.mintick)

if longExit
    strategy.close("Long")

// ── Plots ───────────────────────────────────────────────────────────────────
pEhma = plot(ehma, "EHMA", color=ehmaRising ? color.new(#26a69a, 0) : color.new(#ef5350, 0), linewidth=2)
pGf   = plot(gf,   "Gaussian", color=gfRising ? color.new(#42a5f5, 0) : color.new(#ab47bc, 0), linewidth=1)

plotshape(longEntry, "Entry", shape.triangleup,   location.belowbar, color.new(#26a69a, 0), size=size.small)
plotshape(longExit,  "Exit",  shape.triangledown, location.abovebar, color.new(#ef5350, 0), size=size.small)
````
