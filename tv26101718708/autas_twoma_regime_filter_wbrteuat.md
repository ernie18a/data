# AUTAS Two-MA Regime Filter

- url: https://www.tradingview.com/script/WbrTeuat-AUTAS-Two-MA-Regime-Filter/
- type: indicator
- pine_id: PUB;a1ac3e8b7004441095b0217c1764e4ca
- version: 1.0

## Description

The same distance from a moving average means opposite things depending on the market's regime. This indicator reads the regime first, then signals accordingly.

REGIME (fast SMA 5, slow SMA 20)
- Trend up: slow MA rising, price and fast MA above it (green)
- Trend down: the mirror image (red)
- Range: everything else (grey)

SIGNALS
- T (trend): joins the trend only on a pullback to the slow MA (within 0.3σ) or a fresh fast/slow cross, never while price is stretched.
- R (range): fades moves stretched beyond 2σ from the slow MA.
- A cooldown spaces signals out.

The box at top-right shows the current regime and distance from the slow MA in σ. Alerts are included; set them to "Once per bar close."

   SETTINGS
   - Fast / Slow MA: 5 and 20 by default.
   - Slow MA slope lookback: how many bars back the slope is measured (5).
   - Trend pullback band: how close to the slow MA a pullback must come (0.3σ).
   - Range stretch: how far price must stretch before a fade (2σ).
   - Minimum bars between signals: the cooldown (3).

Known limits: the trend filter waits for the slow MA to turn, so it enters new trends late, and range fades can trigger at the very start of a new trend. Built for US30 on M5, adjustable for any symbol or timeframe.

Not financial advice.

## Source Code

````pine
//@version=6
// Two-MA Regime Filter
// Trade WITH a trend only on a pullback or fresh cross at the slow MA; in a range, fade 2σ stretches.
// Same rules as the M5 two-MA + regime persona on the AUTAS trading desk, applied to chart bars.
indicator("Two-MA Regime Filter", shorttitle="2MA Regime", overlay=true)

// ---------- inputs
fastLen  = input.int(5,     "Fast MA",                          minval=1)
slowLen  = input.int(20,    "Slow MA",                          minval=2)
slopeLen = input.int(5,     "Slow MA slope lookback (bars)",    minval=1)
band     = input.float(0.3, "Trend pullback band (σ)",          step=0.05, minval=0)
stretch  = input.float(2.0, "Range stretch to fade (σ)",        step=0.1,  minval=0.5)
cooldown = input.int(3,     "Minimum bars between signals",     minval=0)
showBg   = input.bool(true, "Shade the regime")
showBox  = input.bool(true, "Show regime box")

// ---------- regime
fast    = ta.sma(close, fastLen)
slow    = ta.sma(close, slowLen)
sd      = ta.stdev(close, slowLen)
rising  = slow > slow[slopeLen]
falling = slow < slow[slopeLen]
trendUp = rising  and close > slow and fast > slow
trendDn = falling and close < slow and fast < slow
isRange = not trendUp and not trendDn
dist    = close - slow
z       = sd > 0 ? dist / sd : 0.0
crossUp = ta.crossover(fast, slow)
crossDn = ta.crossunder(fast, slow)

// ---------- signals
// Trend: distance from the slow MA means strength — only join on a fresh cross or a pullback into the band.
rawBuyT  = trendUp and (crossUp or math.abs(dist) < sd * band)
rawSellT = trendDn and (crossDn or math.abs(dist) < sd * band)
// Range: distance means stretch — fade moves beyond the stretch threshold.
rawBuyR  = isRange and sd > 0 and dist < -stretch * sd
rawSellR = isRange and sd > 0 and dist >  stretch * sd

var int lastSig = na
ready = na(lastSig) or bar_index - lastSig > cooldown
buyT  = rawBuyT  and ready
sellT = rawSellT and ready and not buyT
buyR  = rawBuyR  and ready and not buyT and not sellT
sellR = rawSellR and ready and not buyT and not sellT and not buyR
if buyT or sellT or buyR or sellR
    lastSig := bar_index

// ---------- drawing
plot(fast, "Fast MA", color=color.new(#00d47c, 0), linewidth=1)
plot(slow, "Slow MA", color=color.new(#f59e0b, 0), linewidth=2)
bgcolor(showBg ? (trendUp ? color.new(#00d47c, 92) : trendDn ? color.new(#ef4444, 92) : color.new(#94a3b8, 96)) : na, title="Regime shading")
plotshape(buyT,  "Trend buy",        shape.triangleup,   location.belowbar, color.new(#00d47c, 0), size=size.small, text="T")
plotshape(sellT, "Trend sell",       shape.triangledown, location.abovebar, color.new(#ef4444, 0), size=size.small, text="T")
plotshape(buyR,  "Range fade buy",   shape.triangleup,   location.belowbar, color.new(#3b82f6, 0), size=size.small, text="R")
plotshape(sellR, "Range fade sell",  shape.triangledown, location.abovebar, color.new(#f59e0b, 0), size=size.small, text="R")

var table box = table.new(position.top_right, 1, 2, bgcolor=color.new(#0a0e1a, 10))
if showBox and barstate.islast
    regimeTxt = trendUp ? "TREND UP" : trendDn ? "TREND DOWN" : "RANGE"
    regimeCol = trendUp ? #00d47c : trendDn ? #ef4444 : #94a3b8
    table.cell(box, 0, 0, regimeTxt, text_color=regimeCol, text_size=size.normal)
    table.cell(box, 0, 1, "dist " + str.tostring(dist, format.mintick) + "  (" + str.tostring(z, "#.#") + "σ)", text_color=#94a3b8, text_size=size.small)

// ---------- alerts (set them to "Once per bar close" to avoid intrabar repaints)
alertcondition(buyT or buyR,   "Buy signal",  "Two-MA Regime: BUY on {{ticker}} at {{close}}")
alertcondition(sellT or sellR, "Sell signal", "Two-MA Regime: SELL on {{ticker}} at {{close}}")
alertcondition(trendUp and not trendUp[1], "Regime → trend up",   "Two-MA Regime: {{ticker}} turned TREND UP")
alertcondition(trendDn and not trendDn[1], "Regime → trend down", "Two-MA Regime: {{ticker}} turned TREND DOWN")
alertcondition(isRange and not isRange[1], "Regime → range",      "Two-MA Regime: {{ticker}} turned RANGE")
````
