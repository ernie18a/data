# Swing Circles

- url: https://www.tradingview.com/script/kHyhZuFj-Swing-Circles/
- type: indicator
- pine_id: PUB;c8de25cb4b1342c198e71684ee1c2e2a
- version: 1.0

## Description

- Signals occur in real time throughout the duration of the candle. They may appear and disappear throughout the candle that they're tracking but when the candle closes there is no re-paint. These are solid signals. I've added 1 single alert whenever and Swing Circle triggers red or green.


 - Swing Circles combines two momentum indicators — a smoothed CCI and Williams %R — to flag potential exhaustion points where price may be overextended in one direction while the underlying momentum tells a conflicting story.
The CCI (Commodity Channel Index) measures how far price has deviated from its average. When it's reading extremely high or low it tells us price has made a significant move. The Slow %R (Williams Percent Range) measures where price sits within its range over a longer lookback period — near the top of its range or near the bottom.
The signal logic looks for disagreement between the two:

 - 🔴 Red circle above the candle — CCI is extremely elevated (above 150), meaning price has surged hard, BUT the Slow %R is sitting deep in oversold territory (below -65), meaning over the longer lookback price is actually near the bottom of its range. That contradiction suggests the short-term push may be exhausted and a reversal could be coming.
 - 🟢 Green circle below the candle — CCI is extremely depressed (below -150), meaning price has sold off hard, BUT the Slow %R is near the top of its range (above -35), again a contradiction that suggests the selloff may be losing steam.

 - In short — it's hunting for moments where short-term momentum has gone to an extreme but the bigger picture range context isn't confirming it, which is often where swing reversals set up.



 - To get MORE signals — make the conditions EASIER to meet:

 - CCI thresholds — bring them closer to zero. 150/-150 → 130/-130 → 100/-100. The CCI will cross those levels more frequently so circles fire more often.
%R thresholds — bring them closer to -50 (the midpoint). So -65 → -55 and -35 → -45. That widens the zone where %R qualifies, making it easier for both conditions to be true at the same time.
 - CCI Length — shorten it (e.g. 13 → 8). A shorter CCI is more reactive and will spike to extremes more often.
Slow %R Length — shorten it (e.g. 112 → 60). A shorter lookback makes %R more sensitive and it will swing around more frequently.
Enable smoothing on %R — counterintuitively this can sometimes increase signals by keeping %R in a qualifying zone longer since smoothing slows its exit.


 - To get FEWER signals — make the conditions HARDER to meet:

 - CCI thresholds — push them further from zero. 150/-150 → 175/-175 → 200/-200. Fewer bars will reach those extremes.
%R thresholds — push them toward the edges. -65 → -75 and -35 → -25. Now %R needs to be deeper in its extreme to qualify.
 - CCI Length — lengthen it (e.g. 13 → 20). A longer CCI is smoother and spikes to extremes less often.
Slow %R Length — lengthen it (e.g. 112 → 150+). A longer lookback makes %R very slow moving and harder to reach extremes.
HMA Length — lengthen it (e.g. 8 → 13). More smoothing on the CCI means it moves more slowly and is less likely to spike past your threshold.

## Source Code

````pine
//@version=6
indicator("Swing Circles", overlay=true)

// ─── HMA Function ─────────────────────────────────────────────────────────────
hma(source, length) =>
    ta.wma(2 * ta.wma(source, length / 2) - ta.wma(source, length), math.floor(math.sqrt(length)))

// ─── In1: CCI (HMA Smoothed) ──────────────────────────────────────────────────
GRP_CCI = "CCI Settings (In1)"
cciLength    = input.int(13,  "CCI Length",   minval=1, group=GRP_CCI)
src          = input(hlc3,    "Source",                  group=GRP_CCI)
cciHMALength = input.int(8,   "HMA Length",   minval=1, group=GRP_CCI)

ma_raw  = ta.sma(src, cciLength)
cci     = (src - ma_raw) / (0.015 * ta.dev(src, cciLength))
cciPlot = hma(cci, cciHMALength)

// ─── In2: Slow %R ─────────────────────────────────────────────────────────────
GRP_PR = "Slow %R Settings (In2)"
slowLength         = input.int(112,   "Slow Length",          minval=1, group=GRP_PR)
enableSmoothing    = input.bool(false, "Enable Smoothing",               group=GRP_PR)
slowSmoothLength   = input.int(3,     "Smoothing Length (EMA)", minval=1, group=GRP_PR, active=enableSmoothing)

prSrc        = input(close, "Source", group=GRP_PR)
slowMax      = ta.highest(slowLength)
slowMin      = ta.lowest(slowLength)
slowPR_raw   = 100 * (prSrc - slowMax) / (slowMax - slowMin)
slowPR       = enableSmoothing ? ta.ema(slowPR_raw, slowSmoothLength) : slowPR_raw

// ─── Thresholds ───────────────────────────────────────────────────────────────
GRP_THRESH = "Thresholds"
cciHighThresh  = input.int(150,  "CCI Upper Level",     group=GRP_THRESH)
cciLowThresh   = input.int(-150, "CCI Lower Level",     group=GRP_THRESH)
prHighThresh   = input.int(-35,  "%R Upper Level",      group=GRP_THRESH)
prLowThresh    = input.int(-65,  "%R Lower Level",      group=GRP_THRESH)

// ─── Signal Logic ─────────────────────────────────────────────────────────────
bearSignal = cciPlot > cciHighThresh and slowPR < prLowThresh
bullSignal = cciPlot < cciLowThresh  and slowPR > prHighThresh

// ─── Plots ────────────────────────────────────────────────────────────────────
plotshape(bearSignal, title="Bear Circle", location=location.abovebar,
     style=shape.circle, color=color.red,   size=size.small)
plotshape(bullSignal, title="Bull Circle", location=location.belowbar,
     style=shape.circle, color=color.green, size=size.small)

// ─── Alert ────────────────────────────────────────────────────────────────────
alertcondition(bearSignal or bullSignal, title="Swing Circles",
     message="Swing Circle triggered — check chart for bull or bear signal.")
````
