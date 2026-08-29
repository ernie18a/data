<!-- tradingview-pine-id: PUB;d195b8106fcd47ecaee7d2223c6fc0bd -->
<!-- tradingviewscripts-format: 1 -->
# 3/10 Divergence + Ante (Raschke)

Source: https://www.tradingview.com/script/Me4lbUrm-3-10-Divergence-Ante-Raschke/

## Description

Rule-based LBR 3/10 divergences with three quality gates, TICK-confirmed "triple" divergences (the blindfold trade), and the Anti/kiss continuation setup — all in one pane, all with alerts.

█ OVERVIEW

TradingView already has plenty of 3/10 oscillators. They all do the same thing: plot SMA(3) − SMA(10) with a 16-period signal line and stop there. You still have to eyeball every divergence and every pullback yourself.

This script codifies the two setups the oscillator was actually built around, as taught by Linda Bradford Raschke and Adam Grimes: the momentum divergence (with the quality filters that separate a real one from noise) and the Anti — the first pullback after a fresh momentum impulse.

█ WHY THIS IS DIFFERENT

Three things I could not find in any other public script, let alone together:

 • Divergences are gated, not just "detected." Generic divergence scripts fire on any two
   oscillator pivots that disagree with price, producing endless noise. Here a divergence must
   pass three quality gates drawn from how Raschke actually teaches the pattern: the two swings
   must be the right distance apart, the first swing must be a genuine extension outside a
   Keltner band, and momentum must stay on one side of its signal line for the entire pattern.
   Most signals that generic scripts print never make it through these filters — by design.

 • Triple divergence with NYSE TICK. When the price/oscillator divergence is also confirmed
   by the NYSE TICK diverging at the same two pivots, a separate higher-conviction signal prints.
   This is LBR's famous "blindfold trade" — the setup she said she'd take without looking at the
   chart. There are TICK-divergence scripts and there are 3/10 scripts; none require both to line
   up at the same pivots.

 • The Anti ("kiss") is detected mechanically. The first-pullback-after-impulse trade is
   usually described discretionarily. Here it is codified: a new momentum extreme (the fast line
   turns black so you can see the impulse), then a shallow retracement toward a sloping signal
   line, then a turn back in trend direction. No zero-line crossing tricks, no repurposed
   MACD-cross signals.

If you just want a plain 3/10, use any of the existing ones. This one is for trading the setups.

█ THE OSCILLATOR

 • Fast line (blue): SMA(close, 3) − SMA(close, 10). Short-term momentum.
 • Slow line (orange): SMA(fast, 16). The trend of momentum.
 • Histogram: fast − slow. Teal above zero, red below.
 • The fast line turns black on any bar where it makes a new momentum high or low over the
   impulse lookback. Black = impulse — your visual cue that an Anti setup may be arming.

Simple moving averages throughout — not EMAs. Typing 3/10/16 into a standard MACD gives you the wrong indicator.

█ SIGNAL 1 — DIVERGENCE (green/red triangles)

A bullish divergence prints when ALL of the following are true (bearish is the mirror):

1 — Two price pivot lows the right distance apart (9–12 bars by default). Raschke's
   divergences are a rhythm, not just a shape: the swings need enough separation to represent
   two distinct tests, but not so much that the pattern goes stale.

2 — Price makes an equal or lower low while the fast line makes a higher low. The classic
   definition: sellers pushed price to a new low but couldn't generate new momentum doing it.

3 — The first swing traded outside the Keltner band (20 EMA ± 2.0 × ATR by default).
   This is the exhaustion filter. A divergence is a fade — and per both Raschke and Grimes you
   only fade a move that is overextended. If the first low never left the channel, there was
   nothing climactic to fade, and the signal is skipped.

4 — The fast line never reached the slow line between the two pivots. The histogram stays
   below zero the whole time, proving momentum stayed one-sided through the pattern. You're
   catching genuine seller exhaustion, not a choppy range where the oscillator whips across its
   signal line.

The script draws a line connecting the two oscillator pivots and prints a triangle. Because pivots need right-side bars to confirm, the shape appears a few bars after the actual swing — it does NOT repaint once printed.

How to trade it — Raschke

A divergence is not an entry, it's a condition. It tells you the last push is suspect and the next reaction is likely to retrace. Enter on price confirmation — a break of the divergence bar's high for longs, or the first strong close back inside the range — with a stop beyond the divergence extreme. First target is the middle of the prior range or the moving average. Divergence trades are countertrend, so take profits actively.

How to trade it — Grimes

Grimes uses the same 3/10 and treats divergence primarily as a warning: a trend leg that fails to make a new momentum extreme is a leg whose next pullback you don't buy. So even if you never fade anything, the triangles have a second use — a bearish divergence printing in your uptrend means stand aside on the next pullback entry, because the trend's momentum sponsorship is fading.

█ SIGNAL 2 — TRIPLE DIVERGENCE (yellow diamonds)

Everything in Signal 1, PLUS the NYSE TICK diverging at the same two pivots:

 • Bullish: price lower low + 3/10 higher low + TICK higher low.
 • Bearish: price higher high + 3/10 lower high + TICK lower high.

TICK measures the breadth of program buying and selling across the whole exchange. When price makes a new low but TICK refuses to, the selling pressure across the market — not just your symbol — is drying up. Raschke called the three-way version the trade she'd take blindfolded.

The yellow diamond prints in addition to the regular triangle, never instead of it. TICK data is requested without lookahead (no repainting) and defaults to USI:TICK.

Practical notes: this signal is intraday, US-equities-hours only — TICK is flat overnight and meaningless for crypto, forex, and non-US symbols; toggle it off there. Best on index futures, SPY/QQQ, and liquid US stocks on intraday timeframes.

█ SIGNAL 3 — ANTI / "KISS" (aqua and fuchsia circles)

The with-trend setup — Raschke's Anti / first pullback, the pattern Grimes describes as the closest thing to a bread-and-butter trade. The sequence for longs (shorts are the mirror):

1 — Impulse. The fast line makes a new momentum high over the lookback window and turns
   black on the chart. A fresh momentum extreme statistically begets a retest of the price
   extreme after a pullback: strong momentum rarely dies on the first attempt. The extreme must
   have occurred above the slow line.

2 — Kiss. The fast line pulls back toward the slow line but only shallowly — within a
   configurable fraction of the impulse-high-to-slow-line band, while the histogram is still
   positive. This is Grimes's "reluctant pullback": the best continuation entries come when the
   countertrend push can barely dent momentum. If the fast line slices through the slow line,
   the setup is voided — that's a different, weaker structure.

3 — Slope. The slow line itself must be rising. The pullback happens against a
   still-advancing momentum trend — this is what makes it an Anti rather than a guess.

4 — Turn. The fast line ticks back up from a local low. The circle prints on the turn —
   momentum resuming in trend direction. Grimes: enter when momentum turns back in the
   direction of the trend.

How to trade it: the circle is the alignment signal; execute off price. Typical plan — buy the break of the prior bar's high, stop below the pullback swing low, first target the impulse high (the retest), runner beyond. Because the setup requires a recent momentum extreme, you are structurally always trading in the direction of proven strength.

█ FEATURES / INPUTS

 • 3/10: fast, slow, and signal lengths for the oscillator (SMAs).
 • Divergence: pivot lookback; min/max bars between pivots; Keltner EMA, ATR, and
   multiplier for the exhaustion filter.
 • Triple divergence: on/off toggle and the TICK symbol (swap for your feed's TICK).
 • Anti (kiss): impulse lookback defining a "new momentum extreme"; kiss depth (smaller =
   pullback must get closer to the slow line); slow-line slope length.

Six alert conditions: bullish/bearish divergence, triple bullish/bearish divergence, Anti long/short. All fire on confirmed, non-repainting conditions.

█ LIMITATIONS

 • Divergence shapes appear a few bars after the pivot — the cost of using confirmed swings
   instead of repainting ones.
 • Triple divergence only works where TICK works: US equities, intraday, regular hours.
 • Divergence signals are countertrend by nature. In a runaway trend the Keltner and spacing
   gates will suppress most of them — that is intentional. Raschke's own warning: don't hunt
   divergences in the strongest trending markets.
 • Nothing here is an entry system by itself. Both Raschke and Grimes trigger off price; the
   oscillator tells you when and where to look.

█ THANKS

Credit to Linda Bradford Raschke (Street Smarts, LBRGroup) and Adam Grimes (The Art and Science of Technical Analysis) for the underlying methodology. Educational tool, not financial advice.

---

## Source Code

````pine
//@version=6
// 3/10 Oscillator — Divergence + Ante (Raschke), minimal
// DIVERGENCE (3 gates): pivots 9-12 apart, first swing outside Keltner,
//                       fast fails to reach the MA between pivots.
// TRIPLE DIVERGENCE   : the divergence above PLUS NYSE TICK diverging at the
//                       same two pivots (LBR "blindfold" setup). Plotted as a
//                       separate signal — does not replace the original.
// ANTE / "kiss" (ABC) : IMPULSE = fast line makes a new momentum HIGH/LOW within
//                       the last `impLen` (40) bars; then fast pulls back toward
//                       the sloping slow line (shallow kiss) and turns to resume.
// The fast line is colored BLACK on bars that print a new 40-bar momentum extreme.
indicator("3/10 Divergence + Ante (Raschke)", "3/10 Div+Ante", overlay=false)

// --- 3/10 inputs ---
fLen = input.int(3,  "3/10 fast SMA",  minval=1, group="3/10")
sLen = input.int(10, "3/10 slow SMA",  minval=1, group="3/10")
mLen = input.int(16, "MA / slow line", minval=1, group="3/10")

// --- divergence inputs ---
piv  = input.int(3,  "Pivot lookback (left=right)", minval=1, group="Divergence")
gMin = input.int(9,  "Min bars apart", minval=1, group="Divergence")
gMax = input.int(12, "Max bars apart", minval=1, group="Divergence")
kE   = input.int(20, "Keltner EMA",    minval=1, group="Divergence")
kA   = input.int(10, "Keltner ATR",    minval=1, group="Divergence")
kM   = input.float(2.0, "Keltner mult", minval=0.1, step=0.1, group="Divergence")

// --- triple divergence (TICK) inputs ---
showTriple = input.bool(true, "Show triple divergence (price + 3/10 + TICK)", group="Triple divergence")
tickSym    = input.symbol("USI:TICK", "TICK symbol", group="Triple divergence")

// --- ante (kiss) inputs ---
impLen   = input.int(40,   "Impulse lookback (new fast-line momentum high/low)", minval=2, group="Ante (kiss)")
kissFrac = input.float(0.25,"Ante: kiss depth (frac of high-to-line; smaller = closer to line)", minval=0.05, maxval=1.0, step=0.05, group="Ante (kiss)")
slopeLen = input.int(3,    "Ante: slow-line slope length", minval=1, group="Ante (kiss)")

// --- 3/10 oscillator ---
fast = ta.sma(close, fLen) - ta.sma(close, sLen)   // fast line
ma   = ta.sma(fast, mLen)                          // slow line (the MA)
histv = fast - ma

// --- TICK on the chart's timeframe (no lookahead; flat outside NYSE RTH) ---
tLo = request.security(tickSym, timeframe.period, low,  barmerge.gaps_off, barmerge.lookahead_off)
tHi = request.security(tickSym, timeframe.period, high, barmerge.gaps_off, barmerge.lookahead_off)

// IMPULSE = fast line makes a new momentum high/low within the last impLen bars
newHi = fast >= ta.highest(fast, impLen)
newLo = fast <= ta.lowest(fast, impLen)

// plots (fast turns black on a new 40-bar momentum extreme)
fastColor = (newHi or newLo) ? color.black : color.new(color.blue, 0)
plot(histv, "hist", style=plot.style_columns, color = histv >= 0 ? color.new(color.teal,55) : color.new(color.red,55))
plot(fast, "fast", color=fastColor, linewidth=2)
plot(ma,   "MA",   color=color.new(color.orange,0), linewidth=2)
hline(0, "", color=color.new(color.gray,50), linestyle=hline.style_dotted)

// --- Keltner ---
kLo = ta.ema(close, kE) - kM * ta.atr(kA)
kUp = ta.ema(close, kE) + kM * ta.atr(kA)

// ============================ DIVERGENCE ============================
pl = ta.pivotlow(low,  piv, piv)
ph = ta.pivothigh(high, piv, piv)

var float pl1p = na
var float pl2p = na
var float pl1o = na
var float pl2o = na
var float pl1k = na
var float pl2k = na
var float pl1t = na
var float pl2t = na
var int   pl1b = na
var int   pl2b = na
if not na(pl)
    pl1p := pl2p
    pl1o := pl2o
    pl1b := pl2b
    pl1k := pl2k
    pl1t := pl2t
    pl2p := low[piv]
    pl2o := fast[piv]
    pl2b := bar_index[piv]
    pl2k := kLo[piv]
    pl2t := tLo[piv]

var float ph1p = na
var float ph2p = na
var float ph1o = na
var float ph2o = na
var float ph1k = na
var float ph2k = na
var float ph1t = na
var float ph2t = na
var int   ph1b = na
var int   ph2b = na
if not na(ph)
    ph1p := ph2p
    ph1o := ph2o
    ph1b := ph2b
    ph1k := ph2k
    ph1t := ph2t
    ph2p := high[piv]
    ph2o := fast[piv]
    ph2b := bar_index[piv]
    ph2k := kUp[piv]
    ph2t := tHi[piv]

// --- original divergence (UNCHANGED) ---
bull = false
if not na(pl) and not na(pl1b)
    gap = pl2b - pl1b
    bull := gap >= gMin and gap <= gMax
         and pl2p <= pl1p and pl2o > pl1o
         and pl1p < pl1k
         and ta.highest(histv, gap + 1)[piv] < 0
    if bull
        line.new(pl1b, pl1o, pl2b, pl2o, xloc=xloc.bar_index, color=color.lime, width=2)

bear = false
if not na(ph) and not na(ph1b)
    gap = ph2b - ph1b
    bear := gap >= gMin and gap <= gMax
         and ph2p >= ph1p and ph2o < ph1o
         and ph1p > ph1k
         and ta.lowest(histv, gap + 1)[piv] > 0
    if bear
        line.new(ph1b, ph1o, ph2b, ph2o, xloc=xloc.bar_index, color=color.red, width=2)

plotshape(bull, "Bull div", style=shape.triangleup,   location=location.bottom, color=color.lime, size=size.tiny, offset=-piv)
plotshape(bear, "Bear div", style=shape.triangledown, location=location.top,    color=color.red,  size=size.tiny, offset=-piv)

// --- TRIPLE divergence = original divergence + TICK diverging at the same pivots ---
tickHL = not na(pl1t) and not na(pl2t) and pl2t > pl1t   // TICK higher low
tickLH = not na(ph1t) and not na(ph2t) and ph2t < ph1t   // TICK lower high

bull3 = showTriple and bull and tickHL
bear3 = showTriple and bear and tickLH

plotshape(bull3, "Triple bull div (price+3/10+TICK)", style=shape.diamond, location=location.bottom, color=color.yellow, size=size.small, offset=-piv)
plotshape(bear3, "Triple bear div (price+3/10+TICK)", style=shape.diamond, location=location.top,    color=color.yellow, size=size.small, offset=-piv)

// ============================ ANTE (kiss) ============================
// impulse present = a new fast-line momentum high/low occurred within impLen bars,
// and that extreme was on the correct side of the slow line
impUp = ta.barssince(newHi) <= impLen and ta.highest(fast, impLen) > ma
impDn = ta.barssince(newLo) <= impLen and ta.lowest(fast, impLen) < ma

slope  = ma - ma[slopeLen]                       // slow-line slope
top    = ta.highest(fast, impLen)                // impulse high
bot    = ta.lowest(fast, impLen)                 // impulse low
turnUp = fast > fast[1] and fast[1] <= fast[2]   // fast made a local low, ticking up
turnDn = fast < fast[1] and fast[1] >= fast[2]   // fast made a local high, ticking down

// kiss: fast retraced back near the sloping slow line (within kissFrac of the
// impulse-high-to-line band), still on its side of the line
kissUp = histv >= 0 and fast <= ma + kissFrac * (top - ma)
kissDn = histv <= 0 and fast >= ma - kissFrac * (ma - bot)

anteBull = slope > 0 and impUp and kissUp and turnUp
anteBear = slope < 0 and impDn and kissDn and turnDn

plotshape(anteBull, "Ante long",  style=shape.circle, location=location.bottom, color=color.aqua,    size=size.tiny)
plotshape(anteBear, "Ante short", style=shape.circle, location=location.top,    color=color.fuchsia, size=size.tiny)

// --- alerts ---
alertcondition(bull,     "3/10 Bullish Divergence", "3/10 bullish divergence")
alertcondition(bear,     "3/10 Bearish Divergence", "3/10 bearish divergence")
alertcondition(bull3,    "TRIPLE Bullish Divergence", "TRIPLE bullish divergence: price LL + 3/10 HL + TICK HL")
alertcondition(bear3,    "TRIPLE Bearish Divergence", "TRIPLE bearish divergence: price HH + 3/10 LH + TICK LH")
alertcondition(anteBull, "3/10 Ante Long",          "3/10 ante (kiss) long")
alertcondition(anteBear, "3/10 Ante Short",         "3/10 ante (kiss) short")
````
