# Swell - Fast/Slow Consensus Oscillator

- url: https://www.tradingview.com/script/5VjrXsp2/
- type: indicator
- pine_id: PUB;486934e1ce8a41f2b471b244d1b01d26
- version: 7.0

## Description

This oscillator plots one statistic at two speeds and trades their consensus. Both lines measure the same thing — the volatility-normalized deviation of price from a moving mean, a z-score. The fast line is raw Bollinger percent-B; the slow line is the same deviation passed through triple smoothing, in the style of the Firefly oscillator. Think of one sea surface decomposed into two frequencies: the slow line is the swell, the long-wavelength energy that sets the direction of the water; the fast line is the chop on top of it. Consensus signals ride the chop in the direction of the swell — the century-old tide-and-wave reading of markets, made spectral. The slow line defines the directional regime and wears its verdict as color: teal when it sits above the midline and rises, red when it sits below and falls, amber when position and slope disagree — the regime is on hold and regime-gated signals disarm until the two agree again.

Markers are emoji, and every extreme marker sits directly on the boundary that fired it. A bull prints when the fast line reclaims the midline inside a bullish regime; a bear prints on the mirror event. A sprout prints when the fast line turns up through an oversold boundary, a diamond when that happens inside a bullish regime. A fire prints when the fast line rolls over through an overbought boundary, a trap when that happens inside a bearish regime, and a siren when the rollover coincides with the slow line stalling at elevated levels. Overbought and oversold are hybrid by default: enclosing bands drawn from the fast line's own recent statistics, lagged one bar so a spike is judged against pre-spike conditions, tighten the definition of extreme in quiet stretches, while the fixed levels stay armed as an absolute safety net — a crossback fires on either boundary. All four trigger boundaries are drawn as thin lines, so every marker can be traced to the exact line it crossed.

Background tints follow the short-term motion and carry small labels with the judgment, drawn along the top of the pane and horizontally centered on each episode; the ongoing episode's label slides until the episode closes, then freezes. A red tint marks a pullback zone — the slow line bullish while the fast line sits below the midline, a dip within an uptrend. A green tint marks a suspect rally — the slow line bearish while the fast line pushes above the midline, a bounce to distrust. A violet tint marks a volatility squeeze, when Bollinger bandwidth sits below a percentile threshold of its own history — quiet stretches that tend to precede expansions. An optional filter restricts the four entry signals to a release window after a squeeze; advisories and regime alerts are never filtered. Every event on the chart is subscribable as an alert: each of the seven markers fires exactly when its emoji prints, plus regime turns, zone starts, squeeze start and release, and a catch-all condition covering any marker.

Inputs. The fast side takes the usual Bollinger length and multiplier. The slow side takes the Firefly lookback and smoothing length, with optional double smoothing and a ZLEMA variant. The consensus block sets the midline, the adaptive band length and multiplier, the fixed overbought and oversold levels, the elevated threshold for exhaustion, and a toggle requiring slope agreement for the regime, which makes signals stricter and later. The squeeze block sets the bandwidth lookback, the percentile threshold, and the release window.

Scope. An oscillator reads stretch, not regime-appropriateness: in a strong trend, extreme readings often mark strength rather than reversal, and the overheat cue in particular will fire repeatedly while price keeps running. Treat the markers as cues to investigate, not as a trading system, and let the slow line's color arbitrate which side of the book is open. The fast line is based on BBPCT% by AlgoAlpha; the slow line is based on the Firefly Oscillator by LazyBear, from an original idea by Yasu.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Swell — Fast/Slow Consensus Oscillator (pane indicator)
//
// One sea surface, two frequencies: the slow line is the swell, the fast line
// is the chop; consensus signals ride the chop in the direction of the swell.
//
// Concept: both source indicators measure the same statistic -- the volatility-normalized
// deviation of price from a moving mean (a z-score):
//   BBPCT %B = 50 + 25*z   (raw, fast)
//   Firefly  = 46 + 50*z~  (triple-smoothed, slow)
// The slow Firefly line defines the directional regime, the fast BBPCT line times
// entries/exits, and fast/slow conflict zones are shaded in the background.
//
// Marker legend (extreme markers anchor ON the boundary they crossed; midline
// triggers anchor on the fast line):
//   🌱 oversold rebound, regime-agnostic (advisory)
//   🐂 long trigger: bull regime, fast line reclaims midline
//   💎 oversold reversal within bull regime (rare by construction)
//   🔥 overheat rollover, regime-agnostic (profit-taking cue)
//   🐻 short trigger: bear regime, fast line loses midline
//   🪤 overbought reversal within bear regime (failed rally / bull trap)
//   🚨 exhaustion: overheat rollover + slow line stalling at high level
//
// Volatility squeeze: violet background tint when Bollinger bandwidth (dev/price) sits below
// a percentile threshold of its own history -- quiet periods that tend to precede expansions.
// An optional filter (off by default) restricts the four entry signals (🐂💎🐻🪤) to bars
// within a release window after a squeeze. Advisories, exhaustion, and regime alerts are
// never filtered.
//
// Adaptive thresholds (on by default, hybrid): Firefly-style enclosing bands (SMA +/- k*stdev
// of the fast line itself, lagged one bar so spikes are judged against pre-spike statistics)
// tighten the extreme definition in quiet regimes, while the fixed levels (108 / -8) stay
// armed as an absolute-extreme safety net -- an extreme crossback fires on EITHER boundary.
// Turning the toggle off reverts to fixed levels only. The four trigger
// boundaries (adaptive up/down bands, fixed levels) are drawn as thin lines so
// every extreme marker can be traced to the exact line it crossed.
//
// Background zones carry small labels at the first bar of each episode
// (all three in the top lane, horizontally centered on their episode):
//   "Pullback zone"  (red tint)    slow bullish, fast below midline -- dip within an uptrend
//   "Suspect rally"  (green tint)  slow bearish, fast above midline -- distrust the bounce
//   Zone tints follow the SHORT-TERM price motion (dip = red, bounce = green),
//   not the advisory sentiment; read the label text for the judgment.
//   "Squeeze"        (violet tint) bandwidth compressed below its percentile threshold
//
// Amber is reserved for the non-directional state: slow-line color when its
// position and slope disagree (regime on hold).
// Slow-line colors: teal = above midline & rising, red = below & falling, amber = on hold.
// Fast line: single translucent blue; read its position against the dashed midline.
//
// Fast line based on BBPCT% (c) AlgoAlpha.
// Slow line based on Firefly Oscillator (c) LazyBear (original idea by Yasu).

//@version=6
indicator("Swell - Fast/Slow Consensus Oscillator", shorttitle="Swell", overlay=false, max_labels_count=500)

// --- Fast line: BBPCT %B (entry/exit timing) ---
grpF  = "Fast line: BBPCT% (timing)"
fLen  = input.int(20, "BB Length", minval=1, group=grpF)
fSrc  = input.source(close, "Source", group=grpF)
fMult = input.float(2.0, "StdDev Multiplier", minval=0.001, maxval=50, step=0.1, group=grpF)

// --- Slow line: Firefly (directional regime) ---
grpS    = "Slow line: Firefly (regime)"
ffLen       = input.int(10, "Lookback Length", minval=5, maxval=20, group=grpS)
ffSmooth      = input.int(3, "Signal Smoothing", minval=3, maxval=10, group=grpS)
dblSm   = input.bool(false, "Double Smooth", group=grpS)
useZl   = input.bool(false, "Use ZLEMA", group=grpS)
showSig = input.bool(false, "Show Firefly Signal Line (highest over the smoothing window)", group=grpS)

// --- Consensus thresholds & logic ---
grpC      = "Consensus thresholds & logic"
midTh     = input.float(50, "Midline Threshold", group=grpC)
useAdapt  = input.bool(true, "Adaptive OB/OS Thresholds (hybrid: adaptive band OR fixed level)", group=grpC)
adLen     = input.int(20, "Adaptive Band Length", minval=2, group=grpC)
adMult    = input.float(2.0, "Adaptive Band Multiplier", minval=0.1, maxval=10, step=0.1, group=grpC)
obTh      = input.float(108, "Fixed Overbought Threshold", group=grpC)
osTh      = input.float(-8, "Fixed Oversold Threshold", group=grpC)
hotTh     = input.float(100, "Slow-Line Elevated Threshold (exhaustion)", group=grpC)
needSlope = input.bool(true, "Regime Requires Slow-Line Slope Agreement (stricter, later signals)", group=grpC)
showZones = input.bool(true, "Highlight Pullback / Suspect-Rally Zones", group=grpC)
showZoneLabels = input.bool(true, "Zone Labels (episode start)", group=grpC)
showEdges = input.bool(true, "Show Trigger Boundary Lines", group=grpC)

// --- Volatility squeeze ---
grpQ        = "Volatility squeeze"
sqLen       = input.int(250, "Bandwidth Percentile Lookback", minval=50, group=grpQ)
sqTh        = input.float(20, "Squeeze Threshold (percentile)", minval=1, maxval=50, group=grpQ)
showSqueeze = input.bool(true, "Show Squeeze Background", group=grpQ)
useSqFilter = input.bool(false, "Filter Entry Signals: only within the release window after a squeeze", group=grpQ)
sqWin       = input.int(20, "Squeeze Release Window (bars)", minval=1, group=grpQ)

// --- Alerts ---
grpAl = "Alerts"
alertTemplate = input.string("{{ticker}} | {{events}} triggered", "Named master alert message", group=grpAl,
     tooltip="Template for the 'Any alert() function call' notification. Placeholders use the official double-brace style but are substituted BY THE SCRIPT at runtime (the platform never processes alert() messages). Available: {{ticker}}, {{exchange}}, {{interval}}, {{close}}, {{fast}} fast-line value, {{slow}} slow-line value, {{events}} emoji + names of the markers that printed, {{emoji}} emojis only, {{names}} names only. Anything outside this list passes through literally, and the custom ones ({{events}} etc.) do NOT work in alertcondition dialog messages. Edit the wording HERE, then delete and recreate the alert -- alerts are snapshots of code plus inputs.")
strictSide = input.bool(false, "Composite Side Alerts: regime-gated entries only (exclude 🌱 🔥 🚨 advisories)", group=grpAl,
     tooltip="Affects only the two composite alerts 'Any Long-Side Signal' and 'Any Short-Side Signal'. OFF (default): regime-agnostic advisories join their side -- 🌱 rebound joins the long composite, 🔥 overheat and 🚨 exhaustion join the short composite. ON: composites fire only on the regime-gated entries (🐂 💎 long, 🐻 🪤 short). alertcondition() messages are frozen constants, so the notification cannot name the exact marker -- subscribe to the named master alert (Any alert() function call) for that. Remember to delete and recreate alerts after changing this input.")

// --- Calculations ---
// Moving-average helper: EMA by default, ZLEMA when enabled
smoothMA(s, l) =>
    e1 = ta.ema(s, l)
    e2 = ta.ema(e1, l)
    zl = e1 + (e1 - e2)
    useZl ? zl : e1

// Fast line: %B = 100 * (price - lower band) / (upper band - lower band) = 50 + 25*z
basis = ta.sma(fSrc, fLen)
dev   = fMult * ta.stdev(fSrc, fLen)
denom = 2 * dev
pctB  = denom == 0 ? 50.0 : 100 * (fSrc - (basis - dev)) / denom

// Slow line: z-score * 100 -> triple smoothing -> rescaled to 46 + 50*z~
wPrice = (high + low + 2 * close) / 4
wMean  = smoothMA(wPrice, ffLen)
wDev   = ta.stdev(wPrice, ffLen)
zRaw   = (wPrice - wMean) * 100 / (wDev == 0 ? 1 : wDev)
zSm    = smoothMA(zRaw, ffSmooth)
zSmDbl = smoothMA(zSm, ffSmooth)   // computed unconditionally: v6 ternaries are lazy
zSm2   = dblSm ? zSmDbl : zSm
slowLine     = (smoothMA(zSm2, ffLen) + 100) / 2 - 4
slowSignal     = ta.highest(slowLine, ffSmooth)

// Volatility context: bandwidth as % of price, ranked against its own history
bw            = 100 * dev / fSrc
bwRank        = ta.percentrank(bw, sqLen)
squeezed      = bwRank <= sqTh
recentSqueeze = nz(ta.barssince(squeezed), sqWin + 1) <= sqWin

// Adaptive OB/OS thresholds: enclosing bands on the fast line, lagged one bar so a spike is
// judged against pre-spike statistics. Hybrid: an extreme crossback fires on either boundary.
adBasis = ta.sma(pctB, adLen)
adDev   = adMult * ta.stdev(pctB, adLen)
adUp    = (adBasis + adDev)[1]
adLo    = (adBasis - adDev)[1]
// v6: and/or short-circuit, so every ta.* call is extracted to run on every bar
midUpX  = ta.crossover(pctB, midTh)
midDnX  = ta.crossunder(pctB, midTh)
obFixX  = ta.crossunder(pctB, obTh)
obAdpX  = ta.crossunder(pctB, adUp)
osFixX  = ta.crossover(pctB, osTh)
osAdpX  = ta.crossover(pctB, adLo)
obCross = obFixX or (useAdapt and obAdpX)
osCross = osFixX or (useAdapt and osAdpX)
// Extreme markers anchor ON the boundary they crossed (fixed level takes
// precedence when both boundaries were crossed on the same bar).
obAnchor = obFixX ? obTh : adUp
osAnchor = osFixX ? osTh : adLo

// --- Regime & signals ---
bullRegime = slowLine > midTh and (not needSlope or slowLine >= slowLine[1])
bearRegime = slowLine < midTh and (not needSlope or slowLine <= slowLine[1])
entryOk    = not useSqFilter or recentSqueeze

longTrigger     = bullRegime and midUpX and entryOk                        // bull regime: fast line reclaims the midline
longReversal    = bullRegime and osCross and entryOk                       // bull regime: fast line turns up from oversold (rare by construction)
shortTrigger    = bearRegime and midDnX and entryOk                        // bear regime: fast line loses the midline
shortReversal   = bearRegime and obCross and entryOk                       // bear regime: fast line rolls over from overbought
overheat        = obCross                                                  // regime-agnostic: overheat rollover
oversoldRebound = osCross                                                  // regime-agnostic: oversold rebound
exhaustion      = overheat and slowLine > hotTh and slowLine <= slowLine[1]                  // overheat rollover while slow line stalls at elevated levels
regimeUp        = ta.crossover(slowLine, midTh)
regimeDown      = ta.crossunder(slowLine, midTh)

pullbackZone = slowLine > midTh and pctB < midTh   // slow bullish / fast weak: pullback within uptrend (opportunity)
suspectZone  = slowLine < midTh and pctB > midTh   // slow bearish / fast strong: rally within downtrend (distrust)

// Displayed-marker booleans (mutual exclusions applied once; plots and alerts
// share these so a subscription fires exactly when its emoji prints).
sproutShown = oversoldRebound and not longReversal
trapShown   = shortReversal and not exhaustion
fireShown   = overheat and not shortReversal and not exhaustion
anyMarker   = longTrigger or longReversal or sproutShown or shortTrigger or trapShown or fireShown or exhaustion

// Composite side booleans: everything worth acting on in ONE direction, so a
// single alert subscription covers a whole side. Long side = dip-buying
// markers, short side = rally-selling / de-risking markers. The strict toggle
// drops the regime-agnostic advisories (🌱 🔥 🚨) from their composite; the
// named master alert below always covers the full marker set regardless.
anyLongSide  = longTrigger or longReversal or (not strictSide and sproutShown)
anyShortSide = shortTrigger or trapShown or (not strictSide and (fireShown or exhaustion))

// Zone / squeeze episode transitions.
pullbackStart = pullbackZone and not pullbackZone[1]
suspectStart  = suspectZone and not suspectZone[1]
squeezeStart  = squeezed and not squeezed[1]
squeezeEnd    = not squeezed and squeezed[1]

// --- Colors ---
cLong  = #089981   // teal  : bullish
cShort = #f23645   // red   : bearish
cWarn  = #f59e0b   // amber : regime on hold / suspect-rally tint
cFast  = #2962ff   // blue  : fast line
cSq    = #7e57c2   // violet: volatility squeeze tint

// --- Plots ---
// Slow line: teal = above midline & rising, red = below & falling, amber = position/slope disagree
slowCol = slowLine > midTh ? (slowLine >= slowLine[1] ? color.new(cLong, 0) : color.new(cWarn, 0)) :
                       (slowLine <= slowLine[1] ? color.new(cShort, 0) : color.new(cWarn, 0))
plot(slowLine, "Firefly (slow)", color = slowCol, linewidth = 2)
plot(pctB, "BBPCT (fast)", color = color.new(cFast, 35), linewidth = 1)

hline(midTh, "Midline", color = color.new(color.gray, 50), linestyle = hline.style_dashed)

// Extreme-zone bands (edge = whichever boundary is reached first in hybrid mode)
obEdge = useAdapt ? math.min(nz(adUp, obTh), obTh) : obTh
osEdge = useAdapt ? math.max(nz(adLo, osTh), osTh) : osTh

// --- Pine Screener columns ---------------------------------------------------
// Invisible on the chart (data-window display) and declared right after the
// main lines ON PURPOSE: per the official help center, the screener auto-adds
// the FIRST TEN plots as its default filter set AND table columns, and every
// plot stays listed there regardless of its display state -- declaration
// order is the only clutter control. Alert conditions are also usable as
// filters (the first TWO are auto-added), which is why the two composite
// side alerts lead the alerts section below. The screener computes on only
// the LAST 500 BARS; the 250-bar squeeze lookback still fits.
// One numeric column per question, so every scan is a single filter:
//   Long signal:  1 = long trigger, 2 = oversold reversal, 3 = rebound advisory
//   Short signal: 1 = short trigger, 2 = trap, 3 = overheat, 4 = exhaustion
//   Regime: 1 bull, -1 bear, 0 on hold (amber). Zone: 1 pullback, -1 suspect.
// Coinciding markers resolve to the stronger code (reversal over trigger).
// Scans are manual snapshots, so one-bar signal pulses are easy to miss;
// the bars-since columns make recency filters robust ("<= 3" style). They
// follow the composite side definitions, so they respect the strict toggle
// (inputs stay adjustable in the screener's settings dialog); blank cell =
// no such signal within the screener's 500-bar window.
int longSig  = longReversal ? 2 : longTrigger ? 1 : sproutShown ? 3 : 0
int shortSig = trapShown ? 2 : shortTrigger ? 1 : exhaustion ? 4 : fireShown ? 3 : 0
plot(longSig,  "Long signal (1 trig, 2 rev, 3 rebound)", display = display.data_window)
plot(shortSig, "Short signal (1 trig, 2 trap, 3 heat, 4 exh)", display = display.data_window)
plot(ta.barssince(anyLongSide),  "Bars since long-side signal",  display = display.data_window)
plot(ta.barssince(anyShortSide), "Bars since short-side signal", display = display.data_window)
plot(bullRegime ? 1 : bearRegime ? -1 : 0, "Regime (1 bull, -1 bear, 0 hold)", display = display.data_window)
plot(pullbackZone ? 1 : suspectZone ? -1 : 0, "Zone (1 pullback, -1 suspect)", display = display.data_window)
plot(squeezed ? 1 : 0, "Squeeze (0/1)", display = display.data_window)

// Two 0-100 gauges for threshold scans (>= 70 style):
//   Regime pressure reads the SLOW line only -- fast-line dips are pullback
//   opportunities by doctrine, not reversal risk. 0 = regime solid, 100 =
//   about to flip; symmetric for bull and bear sides.
//   Trigger proximity reads the FAST line's distance to its nearest event
//   line (midline / effective OB / effective OS). Gate-agnostic approximation:
//   whether a marker actually prints still depends on the regime gates.
float slowDelta   = ta.change(slowLine)
float slowMoveAvg = ta.sma(math.abs(slowDelta), adLen)
float sideSign    = slowLine > midTh ? 1.0 : -1.0
float posProx     = math.max(0.0, 1.0 - math.abs(slowLine - midTh) / 50.0)
float slopeProx   = sideSign * slowDelta >= 0 ? 0.0 : math.min(1.0, -sideSign * slowDelta / math.max(2.0 * slowMoveAvg, 1e-9))
float regimePressure = 100.0 * math.max(posProx, slopeProx)
float fastMoveAvg = ta.sma(math.abs(ta.change(pctB)), adLen)
float nearestLine = math.min(math.abs(pctB - midTh), math.min(math.abs(pctB - obEdge), math.abs(pctB - osEdge)))
float trigProx    = 100.0 * math.max(0.0, 1.0 - nearestLine / math.max(2.0 * fastMoveAvg, 1e-9))
plot(regimePressure, "Regime pressure (0-100)", display = display.data_window)
// -- everything from here on is beyond the screener's default ten: still
// selectable there manually, just not auto-added.
plot(trigProx,       "Trigger proximity (0-100)", display = display.data_window)
plot(showSig ? slowSignal : na, "Firefly Signal", color = color.new(color.gray, 40), display = display.pane)

pOb  = plot(obEdge, display = display.none, editable = false)
pObT = plot(obEdge + 22, display = display.none, editable = false)
pOs  = plot(osEdge, display = display.none, editable = false)
pOsB = plot(osEdge - 22, display = display.none, editable = false)
fill(pOb, pObT, color.new(cShort, 90), title = "Overbought Zone")
fill(pOs, pOsB, color.new(cLong, 92), title = "Oversold Zone")

// --- Trigger boundary lines: the lines whose crossings fire the emojis ---
// Fire-family markers (fire/trap/siren) = fast line crossing DOWN through a red
// line; sprout-family (sprout/diamond) = crossing UP through a green line.
// Extreme markers sit directly ON the boundary that fired them.
plot(showEdges and useAdapt ? adUp : na, "Adaptive OB band (trigger)", color = color.new(cShort, 30), linewidth = 1, display = display.pane)
plot(showEdges and useAdapt ? adLo : na, "Adaptive OS band (trigger)", color = color.new(cLong, 30), linewidth = 1, display = display.pane)
plot(showEdges ? obTh : na, "Fixed OB level", color = color.new(cShort, 60), linewidth = 1, display = display.pane)
plot(showEdges ? osTh : na, "Fixed OS level", color = color.new(cLong, 60), linewidth = 1, display = display.pane)



// --- Signal markers (emoji anchored on the fast line at the trigger bar) ---
plotchar(longTrigger ? pctB : na,  title = "Long Trigger",           char = "🐂", location = location.absolute, size = size.tiny, display = display.pane)
plotchar(longReversal ? osAnchor : na, title = "Long Oversold Reversal", char = "💎", location = location.absolute, size = size.tiny, display = display.pane)
plotchar(sproutShown ? osAnchor : na, title = "Oversold Rebound", char = "🌱", location = location.absolute, size = size.tiny, display = display.pane)
plotchar(shortTrigger ? pctB : na, title = "Short Trigger",          char = "🐻", location = location.absolute, size = size.tiny, display = display.pane)
plotchar(trapShown ? obAnchor : na, title = "Short Overbought Reversal", char = "🪤", location = location.absolute, size = size.tiny, display = display.pane)
plotchar(fireShown ? obAnchor : na, title = "Overheat Rollover", char = "🔥", location = location.absolute, size = size.tiny, display = display.pane)
plotchar(exhaustion ? obAnchor : na, title = "Exhaustion Warning", char = "🚨", location = location.absolute, size = size.tiny, display = display.pane)

bgcolor(showZones ? (pullbackZone ? color.new(cShort, 93) : suspectZone ? color.new(cLong, 92) : na) : na, title = "Conflict Zones")
bgcolor(showSqueeze and squeezed ? color.new(cSq, 92) : na, title = "Volatility Squeeze")

// --- Zone labels: colored pills in the TOP lane, horizontally centered on
// their episode. A zone's true center is only knowable when it ends, so the
// ongoing episode's label slides right as the zone grows and freezes at the
// real center when the episode closes; finalized labels never move again.
var int   pbStart = na
var label pbLbl   = na
var int   suStart = na
var label suLbl   = na
var int   sqStart = na
var label sqLbl   = na

if showZoneLabels and showZones and pullbackStart
    pbStart := bar_index
    pbLbl := label.new(bar_index, obTh + 4, "Pullback\nzone", style = label.style_label_down,
         color = color.new(cShort, 20), textcolor = color.white, size = size.small)
if pullbackZone and not na(pbLbl)
    label.set_x(pbLbl, int(math.round(math.avg(pbStart, bar_index))))
if not pullbackZone
    pbLbl := na

if showZoneLabels and showZones and suspectStart
    suStart := bar_index
    suLbl := label.new(bar_index, obTh + 4, "Suspect\nrally", style = label.style_label_down,
         color = color.new(cLong, 20), textcolor = color.white, size = size.small)
if suspectZone and not na(suLbl)
    label.set_x(suLbl, int(math.round(math.avg(suStart, bar_index))))
if not suspectZone
    suLbl := na

if showZoneLabels and showSqueeze and squeezeStart
    sqStart := bar_index
    sqLbl := label.new(bar_index, obTh + 4, "Squeeze", style = label.style_label_down,
         color = color.new(cSq, 20), textcolor = color.white, size = size.small)
if squeezed and not na(sqLbl)
    label.set_x(sqLbl, int(math.round(math.avg(sqStart, bar_index))))
if not squeezed
    sqLbl := na

// --- Alerts ---
// Composite side alerts lead ON PURPOSE: the Pine Screener auto-adds the
// first TWO alertconditions as ready-made filters, and these two are the
// broadest single-subscription conditions (one per direction). Message text
// is a frozen constant (alertcondition limitation), so it lists the possible
// markers instead of the one that fired -- the named master alert() at the
// bottom reports the exact marker(s) at runtime.
alertcondition(anyLongSide,     title = "Any Long-Side Signal (dip-buying composite)",    message = "Swell | Long-side marker printed: 🐂 trigger / 💎 reversal / 🌱 rebound (advisory dropped if strict toggle is on) {{exchange}}:{{ticker}}")
alertcondition(anyShortSide,    title = "Any Short-Side Signal (rally-selling composite)", message = "Swell | Short-side marker printed: 🐻 trigger / 🪤 trap / 🔥 overheat / 🚨 exhaustion (advisories dropped if strict toggle is on) {{exchange}}:{{ticker}}")
alertcondition(longTrigger,     title = "Long Entry Trigger",        message = "Swell | Long trigger: bullish regime, fast line crossed above midline {{exchange}}:{{ticker}}")
alertcondition(longReversal,    title = "Long Oversold Reversal",    message = "Swell | Oversold reversal within bullish regime {{exchange}}:{{ticker}}")
alertcondition(sproutShown,     title = "Oversold Rebound",          message = "Swell | Fast line turned up from the oversold threshold {{exchange}}:{{ticker}}")
alertcondition(shortTrigger,    title = "Short Entry Trigger",       message = "Swell | Short trigger: bearish regime, fast line crossed below midline {{exchange}}:{{ticker}}")
alertcondition(trapShown,       title = "Short Overbought Reversal", message = "Swell | Overbought rollover within bearish regime {{exchange}}:{{ticker}}")
alertcondition(fireShown,       title = "Overheat Rollover",         message = "Swell | Fast line rolled over from the overbought threshold {{exchange}}:{{ticker}}")
alertcondition(exhaustion,      title = "Exhaustion Warning",        message = "Swell | Overheat rollover while slow line stalls at elevated levels {{exchange}}:{{ticker}}")
alertcondition(regimeUp,        title = "Regime Turned Bullish",     message = "Swell | Slow line crossed above the midline {{exchange}}:{{ticker}}")
alertcondition(regimeDown,      title = "Regime Turned Bearish",     message = "Swell | Slow line crossed below the midline {{exchange}}:{{ticker}}")
alertcondition(squeezeStart,    title = "Volatility Squeeze Started",  message = "Swell | Bandwidth entered squeeze territory {{exchange}}:{{ticker}}")
alertcondition(squeezeEnd,      title = "Volatility Squeeze Released", message = "Swell | Squeeze released; entry release window open {{exchange}}:{{ticker}}")
alertcondition(pullbackStart,   title = "Pullback Zone Started",       message = "Swell | Pullback within uptrend: slow bullish, fast below midline {{exchange}}:{{ticker}}")
alertcondition(suspectStart,    title = "Suspect Rally Started",       message = "Swell | Rally within downtrend: slow bearish, fast above midline {{exchange}}:{{ticker}}")

// --- Named master alert ------------------------------------------------------
// alertcondition() messages are frozen at creation, so even the composite side
// alerts above cannot say which marker fired. This alert() call composes the
// names at runtime: create ONE alert with the condition "Any alert() function
// call" and every notification carries the exact marker(s) that printed on
// that close. It always covers the FULL marker set, ignoring the strict toggle.
// The notification text comes from the template input (Alerts group).
// Placeholders wear the official double-brace style, but substitution happens
// HERE at runtime -- the platform never touches alert() messages, so official
// placeholders beyond this list pass through literally. Any value computable
// at the close can join the list: one computed string plus one replace line.
if anyMarker and barstate.isconfirmed
    evEmoji = array.new_string()
    evName  = array.new_string()
    if longTrigger
        array.push(evEmoji, "🐂")
        array.push(evName, "Long trigger")
    if longReversal
        array.push(evEmoji, "💎")
        array.push(evName, "Oversold reversal (bull)")
    if sproutShown
        array.push(evEmoji, "🌱")
        array.push(evName, "Oversold rebound")
    if shortTrigger
        array.push(evEmoji, "🐻")
        array.push(evName, "Short trigger")
    if trapShown
        array.push(evEmoji, "🪤")
        array.push(evName, "Overbought reversal (bear)")
    if fireShown
        array.push(evEmoji, "🔥")
        array.push(evName, "Overheat rollover")
    if exhaustion
        array.push(evEmoji, "🚨")
        array.push(evName, "Exhaustion")
    evFull = array.new_string()
    for i = 0 to array.size(evEmoji) - 1
        array.push(evFull, array.get(evEmoji, i) + " " + array.get(evName, i))
    string msg = str.replace_all(alertTemplate, "{{ticker}}", syminfo.ticker)
    msg := str.replace_all(msg, "{{exchange}}", syminfo.prefix)
    msg := str.replace_all(msg, "{{interval}}", timeframe.period)
    msg := str.replace_all(msg, "{{close}}", str.tostring(close, format.mintick))
    msg := str.replace_all(msg, "{{fast}}", str.tostring(pctB, "#.#"))
    msg := str.replace_all(msg, "{{slow}}", str.tostring(slowLine, "#.#"))
    msg := str.replace_all(msg, "{{events}}", array.join(evFull, " + "))
    msg := str.replace_all(msg, "{{emoji}}", array.join(evEmoji, "+"))
    msg := str.replace_all(msg, "{{names}}", array.join(evName, " + "))
    alert(msg, alert.freq_once_per_bar_close)
````
