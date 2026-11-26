# Enhanced Bollinger Bands [Regime + %B Decay]

- url: https://www.tradingview.com/script/DSfbnP9k/
- type: indicator
- pine_id: PUB;fa3b49578e854b779c91f71ad2e0e176
- version: 1.0

## Description

A modular rewrite of classic Bollinger Bands. Most BB indicators just plot bands; this one treats them as a system with four moving parts.

   Adaptive basis. Pick SMA, EMA, HMA, KAMA (with tunable fast/slow SC), or VWMA. HMA tracks trend with low lag; KAMA adapts to noise; VWMA weights by volume.

   Asymmetric bands (optional). Instead of one σ for both sides, upper/lower bands can use upside/downside semi-deviation (√2-normalized so magnitudes stay comparable to symmetric σ). Useful for markets with persistent skew. A floor at 50% of symmetric σ prevents the semi-dev from collapsing to zero in one-sided trends — a known failure mode of naive semi-dev bands.

   Regime classification. Every bar is tagged SQUEEZE / WALK_UP / WALK_DOWN / RANGE. Squeeze detection supports TTM-style nesting (BB inside Keltner), bandwidth percentile (current BW vs. its own history — recommended ≥500 bars on crypto 1H), or both. The regime drives the background color so you can read the state at a glance.

   %B Decay — the reversal trigger. During an active band walk, the script tracks each new price extreme and the %B at that bar. If price keeps making new highs but %B at those highs is decreasing, the penetration depth is fading: price is still grinding higher, but its relative extreme vs. the volatility-adaptive band is shrinking. After N consecutive decays (default 2, configurable), an orange triangle prints. Conceptually this is a price-vs-adaptive-threshold divergence, scoped to where it matters — inside an active walk, not on every bar. Cleaner than RSI divergence because the threshold itself adapts to volatility.

## Source Code

````pine
//@version=6
indicator("Enhanced Bollinger Bands [Regime + %B Decay]", shorttitle="EBB+D", overlay=true, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════
enum Regime
    SQUEEZE
    WALK_UP
    WALK_DOWN
    RANGE

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════
g1 = "1. Basis (Middle Line)"
basisType = input.string("HMA", "Type", options=["SMA","EMA","HMA","KAMA","VWMA"], group=g1)
basisLen  = input.int(20, "Length", minval=2, group=g1)
basisSrc  = input.source(close, "Source", group=g1)
kamaFast  = input.int(2,  "KAMA Fast SC", minval=1, group=g1)
kamaSlow  = input.int(30, "KAMA Slow SC", minval=2, group=g1)

g2 = "2. Volatility"
mult1      = input.float(1.0, "1σ Multiplier", minval=0.1, step=0.1, group=g2)
mult2      = input.float(2.0, "2σ Multiplier", minval=0.1, step=0.1, group=g2)
mult3      = input.float(3.0, "3σ Multiplier (0 = hide)", minval=0.0, step=0.1, group=g2)
asymmetric = input.bool(false, "Asymmetric Bands", group=g2, tooltip="Upper band uses upside semi-deviation, lower band uses downside semi-deviation (both √2-normalized to match symmetric σ magnitudes).")
kcLen      = input.int(20, "Keltner Length", minval=2, group=g2)
kcMult     = input.float(1.5, "Keltner Multiplier", minval=0.1, step=0.1, group=g2)
useTR      = input.bool(true, "Keltner uses True Range", group=g2)

g3 = "3. Regime Detection"
sqzMethod  = input.string("Both", "Squeeze Method", options=["TTM Nested","BW Percentile","Both"], group=g3, tooltip="TTM: BB nested inside KC | BW%: bandwidth in low historical percentile | Both: requires both conditions.")
bwLookback = input.int(500, "Bandwidth Percentile Lookback", minval=20, group=g3, tooltip="Recommended ≥500 for crypto 1H (≈20 days of history).")
sqzPct     = input.float(20, "Squeeze Percentile Threshold", minval=1, maxval=99, group=g3)
walkBars   = input.int(3, "Band Walk Consecutive Bars", minval=2, group=g3)

g4 = "4. Reversal Trigger (%B Decay)"
enableDecay  = input.bool(true, "Enable %B Penetration Decay Detection", group=g4)
minDecays    = input.int(2, "Consecutive Decay Threshold", minval=1, group=g4, tooltip="During band walk, each time price prints a new extreme, %B at that bar is recorded. If %B at the new extreme is weaker than at the previous new extreme, the decay count increments. The trigger fires when count reaches this threshold. Default 2 = at least two consecutive decays.")
decayMinDiff = input.float(0.0, "Minimum Decay Magnitude", minval=0.0, step=0.01, group=g4, tooltip="%B change must exceed this magnitude to count as a valid decay. 0 = no filter. Try 0.02–0.05 to filter noise.")

g5 = "5. Plot"
showMid    = input.bool(true,  "Basis", group=g5)
show1Sig   = input.bool(true,  "1σ Bands", group=g5)
show2Sig   = input.bool(true,  "2σ Bands", group=g5)
showFills  = input.bool(true,  "Band Fills", group=g5)
showKC     = input.bool(false, "Show Keltner Channel", group=g5)
showBg     = input.bool(true,  "Regime Background", group=g5)
showDecay  = input.bool(true,  "Decay Trigger Markers", group=g5)

// ═══════════════════════════════════════════════════════════════════
// MODULE 1 — BASIS
// ═══════════════════════════════════════════════════════════════════
kama(src, len, fast, slow) =>
    chgAbs = math.abs(src - src[len])
    volSum = math.sum(math.abs(src - src[1]), len)
    er = volSum != 0 ? chgAbs / volSum : 0.0
    fSC = 2.0 / (fast + 1)
    sSC = 2.0 / (slow + 1)
    sc  = math.pow(er * (fSC - sSC) + sSC, 2)
    var float k = na
    k := na(k[1]) ? src : k[1] + sc * (src - k[1])
    k

basis = switch basisType
    "SMA"  => ta.sma(basisSrc, basisLen)
    "EMA"  => ta.ema(basisSrc, basisLen)
    "HMA"  => ta.hma(basisSrc, basisLen)
    "KAMA" => kama(basisSrc, basisLen, kamaFast, kamaSlow)
    "VWMA" => ta.vwma(basisSrc, basisLen)
    => ta.sma(basisSrc, basisLen)

// ═══════════════════════════════════════════════════════════════════
// MODULE 2 — VOLATILITY
// ═══════════════════════════════════════════════════════════════════
symDev = ta.stdev(basisSrc, basisLen)

semiDev(src, ma, len, upside) =>
    sumSq = 0.0
    for i = 0 to len - 1
        diff = src[i] - ma[i]
        ok   = upside ? diff > 0 : diff < 0
        sumSq += ok ? diff * diff : 0.0
    math.sqrt(sumSq / len)

upDevRaw = asymmetric ? semiDev(basisSrc, basis, basisLen, true)  * math.sqrt(2) : symDev
dnDevRaw = asymmetric ? semiDev(basisSrc, basis, basisLen, false) * math.sqrt(2) : symDev

// Floor protection: prevent semi-deviation from collapsing to 0 in one-sided trends
upDev = asymmetric ? math.max(upDevRaw, symDev * 0.5) : upDevRaw
dnDev = asymmetric ? math.max(dnDevRaw, symDev * 0.5) : dnDevRaw

upper1 = basis + mult1 * upDev
lower1 = basis - mult1 * dnDev
upper2 = basis + mult2 * upDev
lower2 = basis - mult2 * dnDev
upper3 = basis + mult3 * upDev
lower3 = basis - mult3 * dnDev

// Keltner: reuses basis as midline to maintain geometric consistency
kcRng   = useTR ? ta.tr(true) : (high - low)
kcRngMA = ta.sma(kcRng, kcLen)
upperKC = basis + kcRngMA * kcMult
lowerKC = basis - kcRngMA * kcMult

// ═══════════════════════════════════════════════════════════════════
// MODULE 3 — METRICS
// ═══════════════════════════════════════════════════════════════════
bandRange = upper2 - lower2
pctB  = bandRange != 0 ? (close - lower2) / bandRange : 0.5
bw    = basis != 0 ? bandRange / basis * 100 : 0.0
bwPct = ta.percentrank(bw, bwLookback)

// ═══════════════════════════════════════════════════════════════════
// MODULE 4 — REGIME
// ═══════════════════════════════════════════════════════════════════
sqzTTM = (lower2 > lowerKC) and (upper2 < upperKC)
sqzBW  = bwPct < sqzPct
isSqueeze = switch sqzMethod
    "TTM Nested"    => sqzTTM
    "BW Percentile" => sqzBW
    "Both"          => sqzTTM and sqzBW
    => false

walkUpRaw = close > upper2
walkDnRaw = close < lower2

var int walkUpCnt = 0
var int walkDnCnt = 0
walkUpCnt := walkUpRaw ? walkUpCnt + 1 : 0
walkDnCnt := walkDnRaw ? walkDnCnt + 1 : 0

isWalkUp = walkUpCnt >= walkBars
isWalkDn = walkDnCnt >= walkBars

Regime regime = if isSqueeze
    Regime.SQUEEZE
else if isWalkUp
    Regime.WALK_UP
else if isWalkDn
    Regime.WALK_DOWN
else
    Regime.RANGE

// ═══════════════════════════════════════════════════════════════════
// MODULE 5 — %B DECAY (Reversal Trigger)
// ═══════════════════════════════════════════════════════════════════
// Core idea: during an active band walk, record %B each time price prints
// a new extreme (high for walk-up, low for walk-down). If %B at successive
// new extremes is decreasing (upper walk) or increasing (lower walk), the
// "penetration depth" is fading — price is still grinding into new territory,
// but its extremity relative to the adaptive band is shrinking. This is the
// most direct signal of intra-walk exhaustion, essentially a price-vs-
// adaptive-threshold divergence.

var float walkExtremeClose = na  // highest/lowest close during current walk
var float walkExtremePctB  = na  // %B at that extreme
var int   decayCount       = 0   // consecutive decay count
var int   walkDir          = 0   // 1=up, -1=down, 0=inactive

bool decayTrigUp = false
bool decayTrigDn = false

walkUpActive = regime == Regime.WALK_UP
walkDnActive = regime == Regime.WALK_DOWN

// State transitions: reset tracking on walk entry/exit
if walkUpActive and walkDir != 1
    walkDir          := 1
    walkExtremeClose := close
    walkExtremePctB  := pctB
    decayCount       := 0
else if walkDnActive and walkDir != -1
    walkDir          := -1
    walkExtremeClose := close
    walkExtremePctB  := pctB
    decayCount       := 0
else if not walkUpActive and not walkDnActive
    walkDir          := 0
    walkExtremeClose := na
    walkExtremePctB  := na
    decayCount       := 0

// Decay detection (every bar)
if enableDecay
    if walkDir == 1 and not na(walkExtremeClose)
        if close > walkExtremeClose
            // New high printed: check if %B has decayed
            if pctB < walkExtremePctB - decayMinDiff
                decayCount := decayCount + 1
            else
                decayCount := 0  // this new high did not decay, reset count
            walkExtremeClose := close
            walkExtremePctB  := pctB
            if decayCount >= minDecays
                decayTrigUp := true
    else if walkDir == -1 and not na(walkExtremeClose)
        if close < walkExtremeClose
            if pctB > walkExtremePctB + decayMinDiff
                decayCount := decayCount + 1
            else
                decayCount := 0
            walkExtremeClose := close
            walkExtremePctB  := pctB
            if decayCount >= minDecays
                decayTrigDn := true

// ═══════════════════════════════════════════════════════════════════
// MODULE 6 — PLOT
// ═══════════════════════════════════════════════════════════════════
col_basis = color.new(color.orange, 0)
col_2     = color.new(#2962FF, 0)
col_1     = color.new(#2962FF, 50)
col_3     = color.new(#2962FF, 70)
col_kc    = color.new(color.gray, 50)
col_decay = color.new(color.orange, 0)

plot(showMid ? basis : na, "Basis", col_basis, 2)

u1 = plot(show1Sig ? upper1 : na, "Upper 1σ", col_1, 1)
l1 = plot(show1Sig ? lower1 : na, "Lower 1σ", col_1, 1)
u2 = plot(show2Sig ? upper2 : na, "Upper 2σ", col_2, 2)
l2 = plot(show2Sig ? lower2 : na, "Lower 2σ", col_2, 2)
u3 = plot(mult3 > 0 ? upper3 : na, "Upper 3σ", col_3, 1)
l3 = plot(mult3 > 0 ? lower3 : na, "Lower 3σ", col_3, 1)

plot(showKC ? upperKC : na, "Upper KC", col_kc, 1, plot.style_circles)
plot(showKC ? lowerKC : na, "Lower KC", col_kc, 1, plot.style_circles)

fill(u1, u2, showFills ? color.new(#2962FF, 92) : na, "Fill 1-2σ ↑")
fill(l1, l2, showFills ? color.new(#2962FF, 92) : na, "Fill 1-2σ ↓")
fill(u2, u3, showFills and mult3 > 0 ? color.new(#2962FF, 96) : na, "Fill 2-3σ ↑")
fill(l2, l3, showFills and mult3 > 0 ? color.new(#2962FF, 96) : na, "Fill 2-3σ ↓")

bgC = switch regime
    Regime.SQUEEZE   => color.new(color.yellow, 85)
    Regime.WALK_UP   => color.new(color.green,  90)
    Regime.WALK_DOWN => color.new(color.red,    90)
    Regime.RANGE     => na
    => na
bgcolor(showBg ? bgC : na, title="Regime BG")

// Decay trigger markers: orange triangles. Above = short clue, below = long clue.
plotshape(showDecay and decayTrigUp, "Upper %B Decay", shape.triangledown, location.abovebar, col_decay, size=size.small)
plotshape(showDecay and decayTrigDn, "Lower %B Decay", shape.triangleup,   location.belowbar, col_decay, size=size.small)

// ═══════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════
alertcondition(decayTrigUp, "WALK_UP %B Decay",   "Upper-band walk: %B penetration depth is decaying — potential short clue")
alertcondition(decayTrigDn, "WALK_DOWN %B Decay", "Lower-band walk: %B penetration depth is decaying — potential long clue")

// ═══════════════════════════════════════════════════════════════════
// DATA WINDOW (for parameter tuning)
// ═══════════════════════════════════════════════════════════════════
regimeNum = switch regime
    Regime.SQUEEZE   => 1
    Regime.WALK_UP   => 2
    Regime.WALK_DOWN => -2
    Regime.RANGE     => 0
    => 0

plot(pctB,             "%B",                display=display.data_window)
plot(bw,               "BandWidth %",       display=display.data_window)
plot(bwPct,            "BW Percentile",     display=display.data_window)
plot(regimeNum,        "Regime (1/2/-2/0)", display=display.data_window)
plot(walkDir,          "Walk Dir",          display=display.data_window)
plot(decayCount,       "Decay Count",       display=display.data_window)
plot(walkExtremePctB,  "Last Extreme %B",   display=display.data_window)
````
