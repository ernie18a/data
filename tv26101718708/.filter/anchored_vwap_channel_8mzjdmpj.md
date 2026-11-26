# Anchored VWAP Channel

- url: https://www.tradingview.com/script/8MZJdmPJ-Anchored-VWAP-Channel/
- type: indicator
- pine_id: PUB;369aa30414384ada90b64de5c3bcd62f
- version: 2.0

## Description

Anchored VWAP Channel — Regime, Confluence & Reversals
What it is
This is a single overlay that builds a complete read of price around one Anchored VWAP. Instead of just drawing a VWAP line, it wraps the VWAP in a volatility channel and then layers the context a discretionary trader normally checks by eye — where price sits versus fair value, whether the move is trending or stretched, where high-volume and Fibonacci levels line up, and where the edges are getting rejected. Everything is derived from the same anchor and measured in the same volatility unit (one standard deviation, σ), so the pieces describe one structure rather than competing with each other.
It runs on any asset class and any timeframe. On instruments that carry real volume (stocks, futures, crypto, etc.) the VWAP, the channel, and the volume profile are fully volume-weighted; on feeds without real volume it falls back gracefully and flags the change in the table (see "Notes and limitations").
Why these components are combined (and how they work together)
This is intentionally a mashup, and the parts are chosen because they answer different questions about the same reference point:
•	The Anchored VWAP is the fair-value anchor — the volume-weighted average price since a chosen pivot.
•	The channel turns dispersion around that anchor into a measurable unit: the bands are the AVWAP ± k·σ, where σ is the volume-weighted standard deviation of price about the VWAP. This converts "how far is price from fair value" into a number (σ-distance) every other module can reuse.
•	The regime read uses that σ-distance together with the VWAP slope and the band behaviour to label continuation vs reversal — so the same channel that draws the bands also tells you whether to trust a band tag or fade it.
•	The volume profile (Point of Control + Value Area) is computed over the same anchored window, so the high-volume price and the value range are measured on exactly the data the VWAP is built from — not an arbitrary separate lookback.
•	The Fibonacci grid is drawn on the active swing leg and is only emphasised where a level coincides with the VWAP, a band, or the POC. The channel and profile are what make a fib level meaningful here; on their own the fib levels would be just lines.
•	The reversal signals fire on outer-band rejections, and the optional confluence filter suppresses them while the regime is strongly trending (when band tags tend to continue) — i.e. one module gates another.
In short: the channel produces a σ-distance, and the regime, profile, fib confluence, reversal logic, divergence and squeeze modules all consume that single shared measurement. That shared plumbing is the reason these are bundled into one script instead of run as six separate indicators.
What it plots
•	Anchored VWAP centerline with a glow halo, colored by slope direction.
•	Channel bands at ±1σ and ±2σ. The fill can be a "reversion heat" gradient (denser toward the outer band, red above the VWAP, green below) or a neutral glow, or off.
•	Volume profile drawn as a translucent Value Area box (VAL→VAH) with a distinct POC line — kept visually and positionally separate from the fib lines so the two are never confused.
•	Fibonacci grid (active-leg retracement, plus optional swing-to-swing), with confluence levels marked by a star and a brighter tone.
•	Signals: trend-shift triangles on VWAP reclaim/loss; solid reversal labels on band rejections; diamonds and connecting lines for σ-distance divergence; a marker on volatility-squeeze release.
•	Status table (single panel): regime, bias, σ-distance, AVWAP, POC, Value Area, squeeze state, divergence, a reversion stop/target/RR template, a data-health row, multi-timeframe regime agreement, and a built-in legend.
•	Optional forward projection cone and an optional self-calibration panel that scores how past signals resolved.
Anchor modes
Rolling (fixed bar window), Swing Low, Swing High, or Dual (auto — anchors to the more recent significant pivot). Pivot detection uses bar-count lookbacks (8/13/21/34/55/89), so the entire tool self-scales to any timeframe.
How to use it
1.	Read the table first: regime + σ-distance tell you whether price is trending or stretched, and how far from fair value it is.
2.	Use the bands as context — near the centerline is fair value; the ±2σ edge is where reversion risk is highest (and the heat fill shades it).
3.	Treat reversal labels as fade-the-stretch signals, strongest when the regime is not trending and when a divergence diamond agrees.
4.	Use trend-shift triangles (VWAP reclaim/loss) for continuation context.
5.	Use fib-confluence stars and the Value Area box / POC as the levels most likely to react.
6.	Check multi-timeframe agreement in the table before acting.
7.	Optionally turn on the calibration panel to see, on your own symbol and timeframe, how often each signal type has historically followed through.
What makes it original
•	A single shared σ framework: bands, regime, divergence, reversals and risk template all read from one volume-weighted standard-deviation measurement around one anchor, rather than bolting unrelated indicators together.
•	Reversion-heat channel fill that encodes reversion risk as color density.
•	Confluence-filtered reversals — band rejections gated by regime/divergence.
•	Volume profile rendered as a separated zone so it never blends into the fib levels.
•	A transparent self-calibration panel that scores the script's own signals against a follow-through threshold (descriptive, not a backtest).
Key settings
•	Calculation Source — works on any asset/market; default hlc3, switchable to close, hl2, ohlc4, etc.
•	Anchor mode and pivot/rolling length.
•	Inner/outer band multipliers and fill style.
•	Signal sensitivity, session-open filter, reversal-confirmation strictness.
•	Table position / text size / legend, and toggles for every module.
Notes and limitations
•	Signals are evaluated on closed bars; the σ-distance divergence confirms a few bars after a pivot by design, so it prints late (this is normal for pivot-based divergence and is not repainting of confirmed history).
•	Last-bar drawings (profile, fib, projection cone) are redrawn on each new bar and will shift forward — that is expected.
•	Asset classes / volume: runs on any market and any timeframe. On instruments that carry real volume (stocks, futures, crypto, etc.) the Anchored VWAP, the volume-weighted σ channel, and the Volume Profile (POC / Value Area) are all fully volume-weighted as intended. On feeds with no real volume (e.g. spot forex, some indices / CFDs) the script still works but degrades gracefully: the VWAP becomes a simple anchored mean, the channel uses an unweighted standard deviation, and the profile becomes a time-at-price distribution. The Data row in the table flags this state as "no-vol / DEGRADED" so you always know which mode you are in.
•	The multi-timeframe dashboard uses higher-timeframe requests; you can turn it off to reduce load.
•	This is an analysis/visualization tool, not a strategy — it does not place orders and is not optimized or backtested for entries/exits.
Disclaimer
This script is provided for educational and informational purposes only and is not financial, investment, or trading advice. It does not predict future prices. Markets carry risk and you can lose money. Past behaviour of any signal (including the calibration panel) does not guarantee future results. Always do your own research and consider consulting a licensed financial professional before trading. You are solely responsible for your decisions and their outcomes.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════
//  ANCHORED VWAP CHANNEL — REGIME, FIB CONFLUENCE & REVERSALS
//
//  A single overlay that frames price around an Anchored VWAP and reads the
//  context around it. Every component shares the SAME anchor and the SAME
//  volatility unit (one standard deviation, σ), so they reinforce one another
//  rather than being separate indicators stacked together:
//
//
//   • Channel   : Anchored VWAP centerline ± k·(volume-weighted σ), 1σ & 2σ.
//   • Anchor    : Rolling, Swing Low, Swing High, or Dual (auto-picks the more
//                 recent significant pivot). Lookbacks are in BAR COUNTS, so
//                 the whole tool self-scales to any timeframe.
//   • Regime    : continuation vs reversal, read from VWAP slope, σ-distance,
//                 outer-band rejections, and VWAP reclaim/loss.
//   • Profile   : volume Point of Control + Value Area over the anchored
//                 window, drawn as a zone (box) kept visually separate.
//   • Fib grid  : retracement of the active leg (+ optional swing-to-swing),
//                 highlighting levels that align with VWAP / bands / POC.
//   • Reversals : outer-band rejections flagged as reversal signals, with an
//                 optional confluence filter (non-trending regime / divergence).
//   • Extras    : σ-distance divergence, volatility-squeeze (efficiency-ratio)
//                 release, multi-timeframe regime agreement, and an optional
//                 self-calibration panel that scores how past signals resolved.
//
//  Works on any symbol and timeframe and on any price source (input below).
//  Volume is optional: with no volume feed the channel falls back to an
//  unweighted standard deviation and flags the data as degraded.
//
//  Educational tool for studying price structure. Not financial advice.
// ════════════════════════════════════════════════════════════════════════
indicator("Anchored VWAP Channel — Regime, Confluence & Reversals", "AVWAP Channel+", overlay=true, max_lines_count=120, max_labels_count=120, max_boxes_count=120, max_bars_back=2000, dynamic_requests=true)

// ───────────────────────────── INPUTS ──────────────────────────────────
gA = "Anchor"
anchorMode = input.string("Dual (auto)", "Anchor Mode", options=["Rolling","Swing Low","Swing High","Dual (auto)"], group=gA)
rollFib    = input.string("34", "Rolling Window (bars)", options=["8","13","21","34","55","89"], group=gA, tooltip="Used only in Rolling mode.")
pivFib     = input.string("21", "Swing Pivot Length (bars)", options=["8","13","21","34","55","89"], group=gA, tooltip="Used by Swing/Dual modes to detect anchor pivots. Larger = more significant swings.")
src        = input.source(hlc3, "Calculation Source", group=gA, tooltip="Price series used for the Anchored VWAP, channel σ, and profile. Default hlc3 suits most assets; switch to close, hl2, ohlc4, or any plotted series. Works on any symbol/market.")

gB = "Channel Bands"
mult1 = input.float(1.0, "Inner Band (σ)", step=0.1, minval=0.1, group=gB)
mult2 = input.float(2.0, "Outer Band (σ)", step=0.1, minval=0.1, group=gB)
fillMode = input.string("Reversion heat", "Channel Fill", options=["Reversion heat","Neon glow","Off"], group=gB, tooltip="Reversion heat: the band gets denser toward the ±2σ edge where reversion risk is highest — RED above the VWAP (stretched up, may pull back) and GREEN below (stretched down, may bounce) — fading to clear near fair value. Neon glow: bright at the center, fading outward.")
glowOn   = input.bool(true, "Neon Glow", group=gB, tooltip="Layered halo on the centerline + gradient fill that fades outward.")
glowBase = input.int(82, "Glow Intensity", minval=70, maxval=85, step=1, group=gB, tooltip="Lower = brighter / denser glow.")

gP = "Anchored Volume Profile"
showVP = input.bool(true, "Show POC / VAH / VAL", group=gP)
vaPct  = input.float(70.0, "Value Area %", minval=50, maxval=95, step=1, group=gP) / 100.0
vpBins = input.int(24, "Profile Resolution", minval=8, maxval=50, group=gP)

gF = "Fibonacci Levels"
showFib  = input.bool(true,  "Active-Leg Retracement", group=gF)
showFib2 = input.bool(true,  "2nd Degree (swing-to-swing)", group=gF)
confTolS = input.float(0.20, "Confluence Tolerance (σ)", step=0.05, minval=0.05, group=gF, tooltip="Two levels are 'confluent' if within this many standard deviations of each other / of the VWAP, bands, or POC.")

gR = "Regime"
showReg = input.bool(true, "Show Regime Read", group=gR)
slopeLk = input.int(5, "VWAP Slope Lookback", minval=1, maxval=50, group=gR)

gS = "Style"
colUp  = input.color(#21dfac, "Up", inline="c", group=gS)
colDn  = input.color(#df216d, "Down", inline="c", group=gS)
colPoc = input.color(#ffa600, "POC", group=gS)
colFib = input.color(color.new(#9aa0a6, 0), "Fib", group=gS)
colConf= input.color(#ffd166, "Confluence", group=gS)
showTbl= input.bool(true, "Info Table", group=gS)
cleanView = input.bool(false, "Clean View (beginner)", group=gS, tooltip="Hides the busier markers (coil dots, divergence diamonds) and keeps just the reversal labels, trend triangles, and channel — the at-a-glance read.")
showLegend = input.bool(true, "Legend (symbol key)", group=gS, tooltip="Appends a short key to the bottom of the table explaining what each on-chart symbol means.")
tblPos = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=gS)
tblSize = input.string("Tiny", "Table Text Size", options=["Tiny","Small"], group=gS, tooltip="Tiny fits the whole table on screen; Small is easier to read if you have room.")

// ───────────────────────────── HELPERS ─────────────────────────────────
int rollN  = switch rollFib
    "8"=>8
    "13"=>13
    "21"=>21
    "34"=>34
    "55"=>55
    "89"=>89
    =>34
int pivLen = switch pivFib
    "8"=>8
    "13"=>13
    "21"=>21
    "34"=>34
    "55"=>55
    "89"=>89
    =>21

// ───────────────────────────── VOLUME (index fallback) ─────────────────
// Indices carry no volume. Fall back to 1.0 so the anchored mean still works
// (it becomes a price/time VWAP and the profile a time-based distribution).
float vw = (na(volume) or volume <= 0) ? 1.0 : volume
bool noVol = na(volume) or volume <= 0

// ───────────────────────────── ANCHOR ENGINE (forward accumulation) ────
// Accumulate FORWARD from each anchor (reset on a new pivot, seed the bars
// between the pivot and its confirmation). Never whole-chart cumulative —
// that loses float precision (catastrophic cancellation) on long histories.

// LOW anchor (last swing low)
var float lPV=0.0
var float lV=0.0
var float lP2V=0.0
var float lAnchorPx=na
var int   lBar=na
pl = ta.pivotlow(low, pivLen, pivLen)
if not na(pl)
    lPV := 0.0
    lV  := 0.0
    lP2V:= 0.0
    for k = 0 to pivLen
        lPV  += src[k] * vw[k]
        lV   += vw[k]
        lP2V += src[k] * src[k] * vw[k]
    lBar := bar_index - pivLen
    lAnchorPx := pl
else if not na(lBar)
    lPV  += src * vw
    lV   += vw
    lP2V += src * src * vw
float lAV = (not na(lBar) and lV > 0) ? lPV / lV : na
float lSD = (not na(lBar) and lV > 0) ? math.sqrt(math.max(lP2V/lV - lAV*lAV, 0.0)) : na

// HIGH anchor (last swing high)
var float hPV=0.0
var float hV=0.0
var float hP2V=0.0
var float hAnchorPx=na
var int   hBar=na
ph = ta.pivothigh(high, pivLen, pivLen)
if not na(ph)
    hPV := 0.0
    hV  := 0.0
    hP2V:= 0.0
    for k = 0 to pivLen
        hPV  += src[k] * vw[k]
        hV   += vw[k]
        hP2V += src[k] * src[k] * vw[k]
    hBar := bar_index - pivLen
    hAnchorPx := ph
else if not na(hBar)
    hPV  += src * vw
    hV   += vw
    hP2V += src * src * vw
float hAV = (not na(hBar) and hV > 0) ? hPV / hV : na
float hSD = (not na(hBar) and hV > 0) ? math.sqrt(math.max(hP2V/hV - hAV*hAV, 0.0)) : na

// ROLLING anchor
float rW   = math.sum(vw, rollN)
float rAV  = rW > 0 ? math.sum(src*vw, rollN)/rW : na
float rSD  = rW > 0 ? math.sqrt(math.max(math.sum(src*src*vw, rollN)/rW - rAV*rAV, 0.0)) : na

// ───────────────────────────── PRIMARY SELECTION ───────────────────────
bool dualLowRecent = nz(lBar, -1) >= nz(hBar, -1)
float pvwap = switch anchorMode
    "Rolling"   => rAV
    "Swing Low" => lAV
    "Swing High"=> hAV
    => dualLowRecent ? lAV : hAV
float psd = switch anchorMode
    "Rolling"   => rSD
    "Swing Low" => lSD
    "Swing High"=> hSD
    => dualLowRecent ? lSD : hSD
int paBar = switch anchorMode
    "Rolling"   => bar_index - (rollN - 1)
    "Swing Low" => lBar
    "Swing High"=> hBar
    => dualLowRecent ? lBar : hBar

// Robustness: if the selected anchor hasn't formed yet (na), fall back to the
// rolling anchor so the channel never blanks out on the chart.
if na(pvwap)
    pvwap := rAV
    psd   := rSD
    paBar := bar_index - (rollN - 1)

bool isUp = pvwap >= pvwap[1]
color tCol = isUp ? colUp : colDn

// ───────────────────────────── PLOT: CHANNEL ───────────────────────────
// σ-multiple levels (extra half/mid steps give the glow a smooth gradient)
float u1 = pvwap + psd*mult1
float l1 = pvwap - psd*mult1
float u2 = pvwap + psd*mult2
float l2 = pvwap - psd*mult2
float ue = pvwap + psd*mult1*0.5
float le = pvwap - psd*mult1*0.5
float um = pvwap + psd*(mult1+mult2)*0.5
float lm = pvwap - psd*(mult1+mult2)*0.5

// Neon centerline: wide translucent halo beneath a crisp core
plot(glowOn ? pvwap : na, "AVWAP halo 2", color=color.new(tCol, 77), linewidth=8)
plot(glowOn ? pvwap : na, "AVWAP halo 1", color=color.new(tCol, 49), linewidth=4)
pMid = plot(pvwap, "AVWAP", color=tCol, linewidth=2)

// Band edges (pUe/pLe/pUm/pLm are invisible anchors used only for fills)
pUe = plot(ue, "U0.5", color=na)
pLe = plot(le, "L0.5", color=na)
pU1 = plot(u1, "U1", color=color.new(tCol, glowOn ? 30 : 16))
pL1 = plot(l1, "L1", color=color.new(tCol, glowOn ? 30 : 16))
pUm = plot(um, "U1.5", color=na)
pLm = plot(lm, "L1.5", color=na)
pU2 = plot(u2, "U2", color=color.new(tCol, glowOn ? 38 : 49))
pL2 = plot(l2, "L2", color=color.new(tCol, glowOn ? 38 : 49))

// Gradient fill. Reversion heat = denser toward the outer band (high reversion
// risk), fading to clear at the VWAP; red above, green below. Neon glow = bright
// at the center, fading outward.
int g0 = glowBase
f_fc(int seg, bool up) =>
    fillMode == "Off" ? na : fillMode == "Reversion heat" ? color.new(up ? colDn : colUp, 85 - seg*13) : color.new(tCol, glowOn ? math.min(97, (g0 - 15) + seg*9) : (seg <= 1 ? 81 : 88))
fill(pMid, pUe, f_fc(0, true),  title="Fill 0.5σ up")
fill(pMid, pLe, f_fc(0, false), title="Fill 0.5σ dn")
fill(pUe,  pU1, f_fc(1, true),  title="Fill 1σ up")
fill(pLe,  pL1, f_fc(1, false), title="Fill 1σ dn")
fill(pU1,  pUm, f_fc(2, true),  title="Fill 1.5σ up")
fill(pL1,  pLm, f_fc(2, false), title="Fill 1.5σ dn")
fill(pUm,  pU2, f_fc(3, true),  title="Fill 2σ up")
fill(pLm,  pL2, f_fc(3, false), title="Fill 2σ dn")

// Dual: draw the secondary anchor's VWAP as a reference line
float secVWAP = anchorMode == "Dual (auto)" ? (dualLowRecent ? hAV : lAV) : na
plot(secVWAP, "Secondary AVWAP", color=color.new(#9aa0a6, 25), linewidth=1, style=plot.style_line)

// ───────────────────────────── REGIME ──────────────────────────────────
bool upS = pvwap > pvwap[slopeLk]
bool dnS = pvwap < pvwap[slopeLk]
float z  = psd > 0 ? (close - pvwap) / psd : 0.0
bool upTag = high >= pvwap + psd*mult2
bool dnTag = low  <= pvwap - psd*mult2
bool upRej = upTag and close < pvwap + psd*mult2
bool dnRej = dnTag and close > pvwap - psd*mult2
bool crossDn = ta.crossunder(close, pvwap)
bool crossUp = ta.crossover(close, pvwap)

string reg = "—"
string cr  = "—"
color  regCol = color.gray
if na(pvwap)
    reg := "no anchor yet"
    cr  := "—"
else if upRej
    reg := "Reversion ▼"
    cr := "reversal risk"
    regCol := colDn
else if dnRej
    reg := "Reversion ▲"
    cr := "reversal risk"
    regCol := colUp
else if z > mult1 and upS
    reg := "Trending ▲"
    cr := "continuation"
    regCol := colUp
else if z < -mult1 and dnS
    reg := "Trending ▼"
    cr := "continuation"
    regCol := colDn
else if upS
    reg := close >= pvwap ? "Holding ▲" : "Pullback ▲"
    cr := "continuation (watch VWAP)"
    regCol := colUp
else if dnS
    reg := close <= pvwap ? "Holding ▼" : "Pullback ▼"
    cr := "continuation (watch VWAP)"
    regCol := colDn
else
    reg := "Balance"
    cr := "neutral"
    regCol := color.gray
// Reversal symptoms: losing/reclaiming the anchor against the prevailing slope
if upS and crossDn
    cr := "reversal symptom: lost VWAP"
if dnS and crossUp
    cr := "reversal symptom: reclaimed VWAP"

// ───────────────────────────── TIER-2 TELLS + RISK + HEALTH ────────────
gT = "Tells"
showDiv    = input.bool(true, "σ-Distance Divergence", group=gT, tooltip="Price prints a higher high but its σ-distance from VWAP makes a lower high (fading upside) — and the mirror at lows. Confirms on closed pivots, so it prints a few bars late.")
divPiv     = input.int(5, "Divergence Pivot Length", minval=2, maxval=30, group=gT)
showDivLine = input.bool(true, "Draw Divergence Lines", group=gT, tooltip="Connects the two diverging price pivots with a line drawn on price, like a classic divergence line.")
showCoil   = input.bool(true, "Coiled-Spring Tell", group=gT, tooltip="Efficiency ratio: was compressed (range-bound) and is now releasing — the moment a squeeze breaks.")
erShortLen = input.int(10, "Coil ER Short", minval=3, maxval=40, group=gT)
erLongLen  = input.int(30, "Coil ER Long",  minval=10, maxval=80, group=gT)
erCompThr  = input.float(0.30, "Coil Compression Thr", minval=0.1, maxval=0.6, step=0.05, group=gT)
erLook     = input.int(5, "Coil Lookback (bars)", minval=2, maxval=20, group=gT)

// σ-distance divergence (pivot-based, non-repainting; prints divPiv bars late)
phP = ta.pivothigh(high, divPiv, divPiv)
plP = ta.pivotlow(low,  divPiv, divPiv)
var float dLastPH=na
var float dPrevPH=na
var float dLastPHz=na
var float dPrevPHz=na
var int   dLastPHb=na
var int   dPrevPHb=na
var float dLastPL=na
var float dPrevPL=na
var float dLastPLz=na
var float dPrevPLz=na
var int   dLastPLb=na
var int   dPrevPLb=na
bool bearDivZ = false
bool bullDivZ = false
if not na(phP)
    dPrevPH  := dLastPH
    dPrevPHz := dLastPHz
    dPrevPHb := dLastPHb
    dLastPH  := phP
    dLastPHz := z[divPiv]
    dLastPHb := bar_index - divPiv
    if not na(dPrevPH) and not na(dPrevPHz)
        bearDivZ := showDiv and dLastPH > dPrevPH and dLastPHz < dPrevPHz
if not na(plP)
    dPrevPL  := dLastPL
    dPrevPLz := dLastPLz
    dPrevPLb := dLastPLb
    dLastPL  := plP
    dLastPLz := z[divPiv]
    dLastPLb := bar_index - divPiv
    if not na(dPrevPL) and not na(dPrevPLz)
        bullDivZ := showDiv and dLastPL < dPrevPL and dLastPLz > dPrevPLz

var string lastDivTxt = "—"
var int    lastDivBar = na
if bullDivZ
    lastDivTxt := "Bull ▲"
    lastDivBar := bar_index
if bearDivZ
    lastDivTxt := "Bear ▼"
    lastDivBar := bar_index

plotshape(showDiv and not cleanView and bullDivZ ? low  : na, "σ-div bull", shape.diamond, location.belowbar, color.new(colUp,0), size=size.tiny)
plotshape(showDiv and not cleanView and bearDivZ ? high : na, "σ-div bear", shape.diamond, location.abovebar, color.new(colDn,0), size=size.tiny)

// Divergence lines drawn on price between the two diverging pivots (capped FIFO)
var array<line>  divLines = array.new<line>()
var array<label> divLabs  = array.new<label>()
f_pushDiv(int b0, float p0, int b1, float p1, bool bear) =>
    line dl = line.new(b0, p0, b1, p1, color=color.new(bear ? colDn : colUp, 0), width=2)
    array.push(divLines, dl)
    label lb = label.new(b1, p1, bear ? "σ▼" : "σ▲", style=bear ? label.style_label_down : label.style_label_up, color=color.new(bear ? colDn : colUp, 15), textcolor=color.white, size=size.tiny)
    array.push(divLabs, lb)
    if array.size(divLines) > 24
        line.delete(array.shift(divLines))
    if array.size(divLabs) > 24
        label.delete(array.shift(divLabs))
if showDivLine and bearDivZ and not na(dPrevPHb)
    f_pushDiv(dPrevPHb, dPrevPH, dLastPHb, dLastPH, true)
if showDivLine and bullDivZ and not na(dPrevPLb)
    f_pushDiv(dPrevPLb, dPrevPL, dLastPLb, dLastPL, false)

// Coiled-spring (efficiency-ratio compression -> release)
f_er(int len) =>
    float net = math.abs(close - close[len])
    float pth = math.sum(math.abs(close - close[1]), len)
    pth > 0 ? net / pth : 0.0
float erS = f_er(erShortLen)
float erL = f_er(erLongLen)
bool coilWasComp  = showCoil and not na(erL[erLook]) and erL[erLook] <= erCompThr
bool coilRising   = showCoil and not na(erS[3]) and erS > erS[3]
bool coilReleased = coilWasComp and coilRising
string coilState  = not showCoil ? "off" : coilReleased ? "RELEASED" : coilWasComp ? "coiled" : erS > 0.45 ? "expanding" : "—"
color  coilCol    = coilReleased ? colPoc : coilWasComp ? color.new(#e3b341,0) : color.gray
plotshape(showCoil and not cleanView and coilReleased and not coilReleased[1] ? low : na, "Coil released", shape.circle, location.belowbar, color.new(colPoc,0), size=size.tiny)

// ── Data-health (Tier 3) ──
gH = "Data Health"
showHealth = input.bool(true, "Data-Health Row", group=gH, tooltip="OK / DEGRADED / CRITICAL from anchor presence, warm-up, and volume reliability.")
bool warmedUp  = bar_index >= math.max(rollN, pivLen*2)
bool hasAnchor = not na(pvwap)
int  healthCode = (not hasAnchor) ? 2 : ((noVol or not warmedUp) ? 1 : 0)
string healthTxt = healthCode == 0 ? "OK" : healthCode == 1 ? "DEGRADED" : "CRITICAL"
color  healthCol = healthCode == 0 ? colUp : healthCode == 1 ? color.new(#e3b341,0) : colDn

// ── Risk context (Tier 2): reversion template around the channel ──
gK = "Risk & Targets"
showRisk = input.bool(true, "Risk Context Row", group=gK, tooltip="Reversion template: stop just beyond the outer band, target the VWAP (or the opposite outer band), with R:R. Reference only — not advice.")
tgtMode  = input.string("VWAP", "Target", options=["VWAP","Opposite band"], group=gK)
bool revShort = z >= 0
float rEntry  = close
float rStop   = revShort ? (pvwap + psd*mult2 + psd*0.25) : (pvwap - psd*mult2 - psd*0.25)
float rTarget = tgtMode == "VWAP" ? pvwap : (revShort ? pvwap - psd*mult2 : pvwap + psd*mult2)
float rRisk   = math.abs(rEntry - rStop)
float rRew    = math.abs(rTarget - rEntry)
float rR      = rRisk > 0 ? rRew / rRisk : na

// ───────────────────────────── DRAW STATE (last bar) ───────────────────
var line  pocLn=na
var box   vaBox=na
var label pocLb=na
var label vahLb=na
var label valLb=na
var label regLb=na
var label anchLb=na
var array<line>  fibLines = array.new<line>()
var array<label> fibLabs  = array.new<label>()
var array<box>   confBoxes= array.new<box>()
var float pocPrice=na
var float vahPrice=na
var float valPrice=na

// reference levels for confluence (built each last bar)
clearAll() =>
    line.delete(pocLn)
    box.delete(vaBox)
    label.delete(pocLb)
    label.delete(vahLb)
    label.delete(valLb)
    if array.size(fibLines)>0
        for l in fibLines
            line.delete(l)
        array.clear(fibLines)
    if array.size(fibLabs)>0
        for l in fibLabs
            label.delete(l)
        array.clear(fibLabs)
    if array.size(confBoxes)>0
        for b in confBoxes
            box.delete(b)
        array.clear(confBoxes)

if barstate.islast
    clearAll()
    int winLen = anchorMode == "Rolling" ? rollN : (na(paBar) ? na : math.min(bar_index - paBar + 1, 1500))

    if not na(winLen) and winLen > 2 and not na(pvwap)
        int xa = math.max(0, bar_index - winLen + 1)
        int xe = bar_index + math.min(math.round(winLen*0.25), 50)
        int xe2 = math.min(xe + 9, bar_index + 60)  // separate column for value-area tags
        // window high/low + profile bins
        float hi = high, lo = low
        array<float> buckets = array.new<float>(vpBins, 0.0)
        for i = 0 to winLen - 1
            hi := math.max(hi, high[i])
            lo := math.min(lo, low[i])
        float step = (hi - lo) / vpBins
        if step > 0 and showVP
            for i = 0 to winLen - 1
                int idx = math.max(0, math.min(vpBins-1, math.floor((src[i]-lo)/step)))
                array.set(buckets, idx, array.get(buckets, idx) + vw[i])
            int pocBin = array.indexof(buckets, array.max(buckets))
            pocPrice := lo + (pocBin + 0.5)*step
            float tot = array.sum(buckets), vaV = array.get(buckets, pocBin)
            int up = pocBin, dn = pocBin
            while vaV < tot*vaPct and (up < vpBins-1 or dn > 0)
                float aV = up < vpBins-1 ? array.get(buckets, up+1) : -1.0
                float bV = dn > 0 ? array.get(buckets, dn-1) : -1.0
                if aV < 0 and bV < 0
                    break
                if aV >= bV
                    up += 1
                    vaV += aV
                else
                    dn -= 1
                    vaV += bV
            vahPrice := lo + (up+1)*step
            valPrice := lo + dn*step
            vaBox := box.new(xa, vahPrice, xe2, valPrice, border_color=color.new(colPoc,28), border_width=1, bgcolor=color.new(colPoc,81))
            pocLn := line.new(xa, pocPrice, xe2, pocPrice, color=colPoc, width=2)
            pocLb := label.new(xe2, pocPrice, "POC", style=label.style_label_left, color=color.new(colPoc,10), textcolor=color.white, size=size.small)
            vahLb := label.new(xe2, vahPrice, "VAH", style=label.style_label_left, color=color.new(colPoc,15), textcolor=color.white, size=size.tiny)
            valLb := label.new(xe2, valPrice, "VAL", style=label.style_label_left, color=color.new(colPoc,15), textcolor=color.white, size=size.tiny)

        // ── Confluence reference set: VWAP, bands, POC ──
        array<float> refs = array.new<float>()
        array.push(refs, pvwap)
        array.push(refs, pvwap + psd*mult1)
        array.push(refs, pvwap - psd*mult1)
        array.push(refs, pvwap + psd*mult2)
        array.push(refs, pvwap - psd*mult2)
        if not na(pocPrice)
            array.push(refs, pocPrice)
        float tol = psd * confTolS

        // ── Fib drawing helper (inline) ──
        array<float> ratios = array.from(0.236, 0.382, 0.5, 0.618, 0.786)

        // active-leg grid
        array<float> grid1 = array.new<float>()
        if showFib
            for r in ratios
                float lvl = hi - (hi - lo)*r
                array.push(grid1, lvl)
                bool conf = false
                for rf in refs
                    if math.abs(lvl - rf) <= tol
                        conf := true
                line ln = line.new(xa, lvl, xe, lvl, color=conf ? colConf : color.new(colFib, 15), width=conf ? 2 : 1, style=line.style_solid)
                array.push(fibLines, ln)
                label lb = label.new(xe, lvl, (conf ? "★ " : "") + str.tostring(r, "0.000"), style=label.style_label_left, color=color.new(conf ? colConf : colFib, conf ? 8 : 12), textcolor=color.white, size=size.tiny)
                array.push(fibLabs, lb)

        // 2nd-degree grid: swing-low to swing-high (structural leg)
        if showFib2 and not na(lAnchorPx) and not na(hAnchorPx)
            float g2hi = math.max(lAnchorPx, hAnchorPx)
            float g2lo = math.min(lAnchorPx, hAnchorPx)
            for r in ratios
                float lvl = g2hi - (g2hi - g2lo)*r
                // cluster if near a grid1 level OR a reference
                bool clust = false
                for g in grid1
                    if math.abs(lvl - g) <= tol
                        clust := true
                for rf in refs
                    if math.abs(lvl - rf) <= tol
                        clust := true
                line ln = line.new(xa, lvl, xe, lvl, color=clust ? colConf : color.new(colFib, 15), width=clust ? 2 : 1, style=line.style_solid)
                array.push(fibLines, ln)
                if clust
                    box bx = box.new(xa, lvl + tol, xe, lvl - tol, border_color=na, bgcolor=color.new(colConf, 80))
                    array.push(confBoxes, bx)

    // anchor marker
    label.delete(anchLb)
    if anchorMode != "Rolling" and not na(paBar)
        bool anchIsLow = anchorMode == "Swing Low" or (anchorMode == "Dual (auto)" and dualLowRecent)
        float apx = anchIsLow ? lAnchorPx : hAnchorPx
        anchLb := label.new(paBar, apx, anchIsLow ? "⚓▲" : "⚓▼", style=anchIsLow ? label.style_label_up : label.style_label_down, color=color.new(tCol, 12), textcolor=color.white, size=size.tiny)

    // regime label near price
    label.delete(regLb)
    if showReg and not na(pvwap)
        regLb := label.new(bar_index + math.round(nz(rollN,10)*0.25), close, reg + "\n" + cr, style=label.style_label_left, color=color.new(regCol, 15), textcolor=color.white, size=size.small)

// ───────────────────────────── INFO TABLE (declared here, rendered at end) ─
tblPosMap = tblPos == "Top Left" ? position.top_left : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Bottom Left" ? position.bottom_left : tblPos == "Middle Right" ? position.middle_right : position.top_right
var table tbl = table.new(tblPosMap, 2, 30, bgcolor=color.new(#0a0e16,4), border_color=color.new(#2b3340,0), border_width=1)

// ───────────────────────────── ALERTS ──────────────────────────────────
alertcondition(crossUp,  "Reclaimed AVWAP", "Price reclaimed the anchored VWAP.")
alertcondition(crossDn,  "Lost AVWAP", "Price lost the anchored VWAP.")
alertcondition(upRej,    "Upper-band rejection", "Price rejected the outer upper band (reversion risk).")
alertcondition(dnRej,    "Lower-band rejection", "Price rejected the outer lower band (reversion risk).")
alertcondition(ta.crossover(close, pvwap + psd*mult2),  "Break outer upper", "Price broke above outer band (trend extension).")
alertcondition(ta.crossunder(close, pvwap - psd*mult2), "Break outer lower", "Price broke below outer band (trend extension).")
alertcondition(bullDivZ, "σ-distance bull divergence", "Lower low in price but a higher low in σ-distance — fading downside.")
alertcondition(bearDivZ, "σ-distance bear divergence", "Higher high in price but a lower high in σ-distance — fading upside.")
alertcondition(coilReleased and not coilReleased[1], "Coiled-spring release", "Channel released from compression (squeeze break).")

// ───────────────────────────── HISTORICAL SIGNAL MARKERS ───────────────
// Persist on every bar the event fired, so you can scroll back and review them.
showSig = input.bool(true, "Historical Signal Markers", group="Signals")
sigMode = input.string("Confirmed", "Signal Sensitivity", options=["All","Confirmed","Strong"], group="Signals", tooltip="All = every event. Confirmed = VWAP crosses must agree with the VWAP slope. Strong = band rejections only (no crosses).")
plainTags = input.bool(false, "Plain-English Tags", group="Signals", tooltip="Adds short words to the signals so the chart reads at a glance, with no technical knowledge needed.")
bool cuOK = sigMode == "All" or (sigMode == "Confirmed" and upS)
bool cdOK = sigMode == "All" or (sigMode == "Confirmed" and dnS)

// ── Session-opening filter (skip the post-open gap-bar noise) ──
useSessFilter = input.bool(false, "Skip signals after the open", group="Session Filter", tooltip="Intraday only: suppress signals in the first N bars after the session open so 9:15 gap bars don't fire false flips. Pairs with Signal Sensitivity.")
sessSkipBars  = input.int(3, "Bars to skip", minval=0, maxval=30, group="Session Filter")
bool isIntra  = timeframe.in_seconds() < 86400
bool newSess  = ta.change(time("D")) != 0
var int barsIntoSess = 9999
barsIntoSess := newSess ? 1 : barsIntoSess + 1
bool sessOK = (not useSessFilter) or (not isIntra) or (barsIntoSess > sessSkipBars)

// Resolved (sensitivity + session gated) events — drive BOTH markers and calibration
bool firedUp = crossUp and cuOK and sessOK
bool firedDn = crossDn and cdOK and sessOK
bool firedUR = upRej and sessOK
bool firedDR = dnRej and sessOK

// Trend shifts use triangles (these sit at the bar edge, away from the fill).
plotshape(showSig and not plainTags and firedUp ? low  : na, "Reclaimed AVWAP", shape.triangleup,   location.belowbar, color.new(colUp,0), size=size.tiny)
plotshape(showSig and not plainTags and firedDn ? high : na, "Lost AVWAP",      shape.triangledown, location.abovebar, color.new(colDn,0), size=size.tiny)
plotshape(showSig and plainTags and firedUp ? low  : na, "Reclaimed (tag)", shape.triangleup,   location.belowbar, color.new(colUp,0), size=size.tiny, text="turn up",   textcolor=color.new(colUp,0))
plotshape(showSig and plainTags and firedDn ? high : na, "Lost (tag)",      shape.triangledown, location.abovebar, color.new(colDn,0), size=size.tiny, text="turn down", textcolor=color.new(colDn,0))

// ── CONFIRMED REVERSAL SIGNALS ──
// A band rejection = price tagged the outer band and closed back inside = the
// stretch got rejected. Drawn as a SOLID opaque label so it pops over the heat
// fill (the old thin arrows blended into the same-coloured band).
gRv = "Reversal Signals"
showReversal = input.bool(true, "Reversal Labels", group=gRv, tooltip="Marks band rejections as reversal signals with a solid, high-contrast label that stands out over the heat fill.")
revMode = input.string("Non-trending regime", "Confirmation", options=["Rejection only","Non-trending regime","Confirming tell"], group=gRv, tooltip="How strict the reversal must be. Rejection only = every band rejection. Non-trending = skip rejections during a strong trend (band-riding fails). Confirming tell = also require a matching σ-divergence nearby.")
revConfWin = input.int(20, "Confirming-tell window (bars)", minval=3, maxval=100, group=gRv)

var int lastBearDivB = na
var int lastBullDivB = na
if bearDivZ
    lastBearDivB := bar_index
if bullDivZ
    lastBullDivB := bar_index
bool bearTellRecent = not na(lastBearDivB) and (bar_index - lastBearDivB) <= revConfWin
bool bullTellRecent = not na(lastBullDivB) and (bar_index - lastBullDivB) <= revConfWin
bool strongUpTrend  = z > mult1 and upS
bool strongDnTrend  = z < -mult1 and dnS
bool revDown = showReversal and firedUR and (revMode == "Rejection only" ? true : revMode == "Non-trending regime" ? not strongUpTrend : bearTellRecent)
bool revUp   = showReversal and firedDR and (revMode == "Rejection only" ? true : revMode == "Non-trending regime" ? not strongDnTrend : bullTellRecent)

var array<label> revLabs = array.new<label>()
f_pushRev(float y, bool down) =>
    label lb = label.new(bar_index, y, down ? "▼ Reversal?" : "▲ Reversal?", style=down ? label.style_label_down : label.style_label_up, color=color.new(down ? colDn : colUp, 0), textcolor=color.white, size=size.small)
    array.push(revLabs, lb)
    if array.size(revLabs) > 24
        label.delete(array.shift(revLabs))
if revDown
    f_pushRev(high, true)
if revUp
    f_pushRev(low, false)
alertcondition(revDown, "Reversal down (confirmed)", "Confirmed reversal at the top — the up-stretch was rejected, price may fall.")
alertcondition(revUp,   "Reversal up (confirmed)",   "Confirmed reversal at the bottom — the down-stretch was rejected, price may rise.")

// ───────────────────────────── CALIBRATION TRACKER ─────────────────────
// Past-only and descriptive. Logs each fired signal, waits calHorizon bars,
// then records whether price moved >= calMoveATR x ATR in the signal's
// direction. Reports a measured hit-rate per signal type with a 95% Wilson
// interval. NOT a backtest and NOT a forward prediction — a sanity check.
gCal = "Calibration"
calEnable    = input.bool(true,  "Track signal calibration (background)", group=gCal, tooltip="Lightweight; leave on even with the panel hidden.")
calShowPanel = input.bool(false, "Show calibration panel", group=gCal)
calPanelPos  = input.string("Bottom Left", "Panel Position", options=["Bottom Left","Bottom Right","Middle Left","Top Left"], group=gCal)
calHorizon   = input.int(10,  "Evaluation horizon (bars)", minval=3, maxval=100, group=gCal)
calMoveATR   = input.float(0.5, "Min follow-through (x ATR)", minval=0.1, maxval=3.0, step=0.1, group=gCal, tooltip="Move in the signal direction within the horizon to count as a hit.")
calAtrLen    = input.int(14,  "ATR length", minval=1, group=gCal)

float atrV = ta.atr(calAtrLen)

// 95% Wilson score interval for a binomial proportion -> [lo, hi] in [0,1]
f_propCI(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p   = hits / float(total)
        float zc  = 1.96
        float den = 1.0 + zc*zc/total
        float cen = (p + zc*zc/(2.0*total)) / den
        float hw  = zc * math.sqrt(p*(1.0-p)/total + zc*zc/(4.0*total*total)) / den
        lo := math.max(0.0, cen - hw)
        hi := math.min(1.0, cen + hw)
    [lo, hi]

// Per-type tallies: 0=Reclaim 1=Lost 2=Up-rej 3=Lo-rej
var array<int>   calTot = array.new<int>(4, 0)
var array<int>   calHit = array.new<int>(4, 0)
var array<int>   pBar   = array.new<int>(0)
var array<float> pPx    = array.new<float>(0)
var array<float> pAtr   = array.new<float>(0)
var array<int>   pDir   = array.new<int>(0)
var array<int>   pTyp   = array.new<int>(0)

logSig(int ty, int dir) =>
    array.push(pBar, bar_index)
    array.push(pPx,  close)
    array.push(pAtr, atrV)
    array.push(pDir, dir)
    array.push(pTyp, ty)

if calEnable and barstate.isconfirmed
    if firedUp
        logSig(0,  1)
    if firedDn
        logSig(1, -1)
    if firedUR
        logSig(2, -1)
    if firedDR
        logSig(3,  1)
    int idx = 0
    while idx < array.size(pBar)
        if bar_index - array.get(pBar, idx) >= calHorizon
            float p0 = array.get(pPx, idx)
            float a0 = array.get(pAtr, idx)
            int   dr = array.get(pDir, idx)
            int   ty = array.get(pTyp, idx)
            float mv = close - p0
            bool  hit = dr == 1 ? mv >= calMoveATR*a0 : mv <= -calMoveATR*a0
            array.set(calTot, ty, array.get(calTot, ty) + 1)
            if hit
                array.set(calHit, ty, array.get(calHit, ty) + 1)
            array.remove(pBar, idx)
            array.remove(pPx,  idx)
            array.remove(pAtr, idx)
            array.remove(pDir, idx)
            array.remove(pTyp, idx)
        else
            idx += 1
    while array.size(pBar) > 300
        array.shift(pBar)
        array.shift(pPx)
        array.shift(pAtr)
        array.shift(pDir)
        array.shift(pTyp)

calPosMap = calPanelPos == "Bottom Left" ? position.bottom_left : calPanelPos == "Bottom Right" ? position.bottom_right : calPanelPos == "Middle Left" ? position.middle_left : position.top_left
var table calT = table.new(calPosMap, 4, 6, bgcolor=color.new(#0d1117,10), border_color=color.gray, border_width=1)
if calEnable and calShowPanel and barstate.islast
    table.clear(calT, 0, 0, 3, 5)
    table.cell(calT,0,0,"Calibration (past)", text_color=color.new(#b39ddb,0), text_size=size.small)
    table.cell(calT,1,0,"N",   text_color=color.new(#c2cbd6,0), text_size=size.small)
    table.cell(calT,2,0,"Hit", text_color=color.new(#c2cbd6,0), text_size=size.small)
    table.cell(calT,3,0,"95% CI", text_color=color.new(#c2cbd6,0), text_size=size.small)
    array<string> rowNm = array.from("Reclaim", "Lost", "Up-rej", "Lo-rej")
    int allT = 0
    int allH = 0
    for r = 0 to 3
        int rt = array.get(calTot, r)
        int rh = array.get(calHit, r)
        allT += rt
        allH += rh
        float rate = rt > 0 ? rh*100.0/rt : na
        [lo, hi] = f_propCI(rh, rt)
        string rateTxt = rt == 0 ? "—" : rt < 5 ? "warm" : str.tostring(rate, "0") + "%"
        string ciTxt   = na(lo) ? "—" : str.tostring(math.round(lo*100)) + "–" + str.tostring(math.round(hi*100)) + "%"
        color  rateCol = rt < 5 ? color.gray : rate >= 55 ? colUp : rate >= 45 ? color.new(#e3b341,0) : colDn
        table.cell(calT,0,r+1, array.get(rowNm,r), text_color=color.white, text_size=size.small)
        table.cell(calT,1,r+1, str.tostring(rt), text_color=color.white, text_size=size.small)
        table.cell(calT,2,r+1, rateTxt, text_color=rateCol, text_size=size.small)
        table.cell(calT,3,r+1, ciTxt, text_color=color.white, text_size=size.small)
    float allRate = allT > 0 ? allH*100.0/allT : na
    [alo, ahi] = f_propCI(allH, allT)
    string allRateTxt = allT == 0 ? "—" : allT < 5 ? "warm" : str.tostring(allRate, "0") + "%"
    string allCiTxt   = na(alo) ? "—" : str.tostring(math.round(alo*100)) + "–" + str.tostring(math.round(ahi*100)) + "%"
    table.cell(calT,0,5,"All", text_color=color.new(#b39ddb,0), text_size=size.small)
    table.cell(calT,1,5, str.tostring(allT), text_color=color.white, text_size=size.small)
    table.cell(calT,2,5, allRateTxt, text_color=color.white, text_size=size.small)
    table.cell(calT,3,5, allCiTxt, text_color=color.white, text_size=size.small)

// ───────────────────────────── MTF REGIME DASHBOARD ────────────────────
showMTF = input.bool(true, "Show MTF Regime Dashboard", group="Multi-Timeframe")

// Lightweight per-TF regime: rolling-window VWAP read (cheap to run via security).
mtfRegime(simple int win) =>
    w = math.sum(vw, win)
    v = w > 0 ? math.sum(src*vw, win)/w : na
    s = w > 0 ? math.sqrt(math.max(math.sum(src*src*vw, win)/w - v*v, 0.0)) : na
    bool up = v > v[3]
    float zz = s > 0 ? (close - v)/s : 0.0
    bool uRej = (high >= v + s*mult2) and close < v + s*mult2
    bool dRej = (low  <= v - s*mult2) and close > v - s*mult2
    int kind = 0
    int dir  = 0
    if na(v)
        kind := -1
    else if uRej
        kind := 3
        dir := -1
    else if dRej
        kind := 3
        dir := 1
    else if zz > mult1 and up
        kind := 2
        dir := 1
    else if zz < -mult1 and not up
        kind := 2
        dir := -1
    else if up
        kind := 1
        dir := 1
    else
        kind := 1
        dir := -1
    [dir, kind]

// ── Standard TradingView timeframe ladder (ascending) with seconds ──
array<string> ladder    = array.from("1","2","3","5","15","30","45","60","120","180","240","D","W","M")
array<int>    ladderSec = array.from(60,120,180,300,900,1800,2700,3600,7200,10800,14400,86400,604800,2592000)

// Target list = current chart TF + the next 5 higher standard options
// NOTE: the request.security loop runs ONLY when the dashboard is on — leaving
// it unconditional made the script recompute up to 6 HTF requests every recalc
// even with the table hidden, which can make TradingView drop the indicator.
array<string> tfs     = array.new<string>()
array<int>    tfSec   = array.new<int>()
array<int>    mtfDir  = array.new<int>()
array<int>    mtfKind = array.new<int>()
int curSec = timeframe.in_seconds(timeframe.period)
if showMTF
    array.push(tfs, timeframe.period)
    array.push(tfSec, curSec)
    int added = 0
    for i = 0 to array.size(ladder) - 1
        if array.get(ladderSec, i) > curSec and added < 5
            array.push(tfs, array.get(ladder, i))
            array.push(tfSec, array.get(ladderSec, i))
            added += 1
    for i = 0 to array.size(tfs) - 1
        [d, k] = request.security(syminfo.tickerid, array.get(tfs, i), mtfRegime(rollN), lookahead=barmerge.lookahead_off)
        array.push(mtfDir, d)
        array.push(mtfKind, k)

fmtTf(int sec) =>
    sec < 60 ? str.tostring(sec) + "s" : sec < 3600 ? str.tostring(int(sec/60)) + "m" : sec < 86400 ? str.tostring(int(sec/3600)) + "h" : sec < 604800 ? str.tostring(int(sec/86400)) + "D" : sec < 2592000 ? str.tostring(int(sec/604800)) + "W" : str.tostring(int(sec/2592000)) + "M"
mtfTxt(int k) =>
    k == 2 ? "Trend" : k == 1 ? "Hold" : k == 3 ? "Rev" : k == -1 ? "—" : "Bal"
mtfCol(int d, int k) =>
    k == -1 ? color.new(color.gray, 50) : d > 0 ? color.new(colUp, 35) : d < 0 ? color.new(colDn, 35) : color.new(color.gray, 50)
mtfArr(int d) =>
    d > 0 ? "▲" : d < 0 ? "▼" : "•"

// ───────────────────────────── SINGLE STATUS TABLE (2-col, sized to fit) ─
if showTbl and barstate.islast
    string tSz = tblSize == "Small" ? size.small : size.tiny
    int agreeN = 0
    int totN = 0
    for i = 0 to array.size(mtfDir) - 1
        int dd = array.get(mtfDir, i)
        if dd != 0
            totN += 1
            if (isUp and dd > 0) or (not isUp and dd < 0)
                agreeN += 1
    string alignTxt = not showMTF ? "off" : totN > 0 ? str.tostring(agreeN) + "/" + str.tostring(totN) + " align" : "—"

    table.clear(tbl, 0, 0, 1, 29)
    int rr = 0
    table.cell(tbl,0,rr,"Fib AVWAP+", text_color=color.new(#79c0ff,0), text_size=tSz, bgcolor=color.new(#161d2b,0))
    table.cell(tbl,1,rr,anchorMode + " " + timeframe.period, text_color=color.new(#c2cbd6,0), text_size=tSz, bgcolor=color.new(#161d2b,0))
    rr += 1
    table.cell(tbl,0,rr,"Regime", text_color=color.new(#c2cbd6,0), text_size=tSz)
    table.cell(tbl,1,rr,reg, bgcolor=color.new(regCol,18), text_color=color.white, text_size=tSz)
    rr += 1
    table.cell(tbl,0,rr,"Bias", text_color=color.new(#c2cbd6,0), text_size=tSz)
    table.cell(tbl,1,rr,cr, text_color=color.white, text_size=tSz)
    rr += 1
    table.cell(tbl,0,rr,"σ-dist", text_color=color.new(#c2cbd6,0), text_size=tSz)
    table.cell(tbl,1,rr,na(z)?"—":str.tostring(z,"0.00")+"σ", text_color=color.white, text_size=tSz)
    rr += 1
    table.cell(tbl,0,rr,"AVWAP", text_color=color.new(#c2cbd6,0), text_size=tSz)
    table.cell(tbl,1,rr,na(pvwap)?"—":str.tostring(pvwap,format.mintick), text_color=color.white, text_size=tSz)
    rr += 1
    table.cell(tbl,0,rr,"POC", text_color=color.new(#c2cbd6,0), text_size=tSz)
    table.cell(tbl,1,rr,na(pocPrice)?"—":str.tostring(pocPrice,format.mintick), text_color=colPoc, text_size=tSz)
    rr += 1
    table.cell(tbl,0,rr,"VA H/L", text_color=color.new(#c2cbd6,0), text_size=tSz)
    table.cell(tbl,1,rr,(na(vahPrice)?"—":str.tostring(vahPrice,format.mintick))+" / "+(na(valPrice)?"—":str.tostring(valPrice,format.mintick)), text_color=color.white, text_size=tSz)
    rr += 1
    if showCoil
        table.cell(tbl,0,rr,"Coil", text_color=color.new(#c2cbd6,0), text_size=tSz)
        table.cell(tbl,1,rr,coilState, bgcolor=color.new(coilCol,28), text_color=color.white, text_size=tSz)
        rr += 1
    if showDiv
        string dvAge = na(lastDivBar) ? "—" : lastDivTxt + " (" + str.tostring(bar_index - lastDivBar) + "b)"
        table.cell(tbl,0,rr,"σ-div", text_color=color.new(#c2cbd6,0), text_size=tSz)
        table.cell(tbl,1,rr,dvAge, text_color=color.white, text_size=tSz)
        rr += 1
    if showRisk
        table.cell(tbl,0,rr,"Setup", text_color=color.new(#c2cbd6,0), text_size=tSz)
        table.cell(tbl,1,rr, revShort ? "Short → reversion" : "Long → reversion", text_color=revShort?colDn:colUp, text_size=tSz)
        rr += 1
        table.cell(tbl,0,rr,"Stop / Tgt", text_color=color.new(#c2cbd6,0), text_size=tSz)
        table.cell(tbl,1,rr, (na(rStop)?"—":str.tostring(rStop,format.mintick)) + " / " + (na(rTarget)?"—":str.tostring(rTarget,format.mintick)), text_color=color.white, text_size=tSz)
        rr += 1
        table.cell(tbl,0,rr,"R:R", text_color=color.new(#c2cbd6,0), text_size=tSz)
        table.cell(tbl,1,rr, na(rR)?"—":str.tostring(rR,"0.00")+"R", text_color=(not na(rR) and rR>=1.5)?colUp:color.white, text_size=tSz)
        rr += 1
    if showHealth
        table.cell(tbl,0,rr,"Health", text_color=color.new(#c2cbd6,0), text_size=tSz)
        table.cell(tbl,1,rr, healthTxt + (noVol?" · no-vol":""), bgcolor=color.new(healthCol,28), text_color=color.white, text_size=tSz)
        rr += 1
    if showMTF
        table.cell(tbl,0,rr,"MTF " + alignTxt, text_color=color.new(#79c0ff,0), text_size=tSz, bgcolor=color.new(#161d2b,0))
        table.cell(tbl,1,rr,"dir·state", text_color=color.new(#c2cbd6,0), text_size=tSz, bgcolor=color.new(#161d2b,0))
        rr += 1
        for i = 0 to array.size(tfs) - 1
            table.cell(tbl,0,rr, fmtTf(array.get(tfSec, i)) + (i==0?" •":""), text_color = i==0?color.new(#79c0ff,0):color.gray, text_size=tSz)
            table.cell(tbl,1,rr, mtfArr(array.get(mtfDir,i)) + " " + mtfTxt(array.get(mtfKind,i)), bgcolor=mtfCol(array.get(mtfDir,i), array.get(mtfKind,i)), text_color=color.white, text_size=tSz)
            rr += 1
    if showLegend
        table.cell(tbl,0,rr,"— Legend —", text_color=color.new(#79c0ff,0), text_size=tSz, bgcolor=color.new(#161d2b,0))
        table.cell(tbl,1,rr,"what symbols mean", text_color=color.new(#c2cbd6,0), text_size=tSz, bgcolor=color.new(#161d2b,0))
        rr += 1
        table.cell(tbl,0,rr,"◆ σ▲▼", text_color=color.white, text_size=tSz)
        table.cell(tbl,1,rr,"Divergence — trend tiring", text_color=color.new(#c2cbd6,0), text_size=tSz)
        rr += 1
        table.cell(tbl,0,rr,"▼▲ box", text_color=color.white, text_size=tSz)
        table.cell(tbl,1,rr,"Reversal — band rejected", text_color=color.new(#c2cbd6,0), text_size=tSz)
        rr += 1
        table.cell(tbl,0,rr,"▲ ▼", text_color=color.white, text_size=tSz)
        table.cell(tbl,1,rr,"Trend shift at VWAP", text_color=color.new(#c2cbd6,0), text_size=tSz)
        rr += 1
        table.cell(tbl,0,rr,"●", text_color=colPoc, text_size=tSz)
        table.cell(tbl,1,rr,"Coil (squeeze) release", text_color=color.new(#c2cbd6,0), text_size=tSz)
        rr += 1
        table.cell(tbl,0,rr,"box / ★", text_color=color.white, text_size=tSz)
        table.cell(tbl,1,rr,"Value area / Fib confluence", text_color=color.new(#c2cbd6,0), text_size=tSz)
        rr += 1

// ───────────────────────────── FORWARD GLOW PROJECTION CONE ─────────────
// Projects the channel forward from the last bar: half-width = psd*sqrt(h),
// median tilted by the AVWAP slope (regime direction). Drawn as a glowing
// P25/P50/P75 cone with a gradient fill. Reuses psd + slope; pure visual.
gCone = "Projection Cone"
showCone = input.bool(false, "Forward Glow Cone", group=gCone, tooltip="Off by default. Projects the AVWAP forward; width grows with sqrt(horizon), tilt from the VWAP slope.")
coneH    = input.int(20, "Horizon (bars)", minval=5, maxval=100, group=gCone)
coneTilt = input.float(1.0, "Tilt Sensitivity", minval=0.0, maxval=3.0, step=0.1, group=gCone, tooltip="How strongly the AVWAP slope tilts the cone. 0 = flat.")

var line cOut25=na
var line cOut50=na
var line cOut75=na
var line cMid25=na
var line cMid50=na
var line cMid75=na
var line cCor25=na
var line cCor50=na
var line cCor75=na
var label cLb25=na
var label cLb50=na
var label cLb75=na
var array<box> coneFill = array.new<box>()

if showCone and barstate.islast and not na(pvwap) and not na(psd) and psd > 0
    line.delete(cOut25)
    line.delete(cOut50)
    line.delete(cOut75)
    line.delete(cMid25)
    line.delete(cMid50)
    line.delete(cMid75)
    line.delete(cCor25)
    line.delete(cCor50)
    line.delete(cCor75)
    label.delete(cLb25)
    label.delete(cLb50)
    label.delete(cLb75)
    if array.size(coneFill) > 0
        for b in coneFill
            box.delete(b)
        array.clear(coneFill)

    int h = coneH
    float driftBar = (pvwap - pvwap[slopeLk]) / slopeLk * coneTilt
    float z25 = -0.6745
    float z75 =  0.6745
    float ctr = close + driftBar * h
    float sigH = psd * math.sqrt(h)
    float p25 = ctr + z25 * sigH
    float p50 = ctr
    float p75 = ctr + z75 * sigH
    int x0 = bar_index
    int xH = bar_index + h
    color cLo = colDn
    color cMd = tCol
    color cHi = colUp

    // gradient cone fill (6 stepped boxes per side)
    int steps = 6
    for s = 0 to steps - 1
        float f0 = s / float(steps)
        float f1 = (s + 1) / float(steps)
        int bx0 = bar_index + math.round(h * f0)
        int bx1 = bar_index + math.round(h * f1)
        float p25b = close + (p25 - close) * f1
        float p50a = close + (p50 - close) * f0
        float p75b = close + (p75 - close) * f1
        int op = math.min(96, 88 + s)
        box blo = box.new(bx0, math.max(p50a, p25b), bx1, math.min(p50a, p25b), border_color=na, bgcolor=color.new(cLo, op))
        array.push(coneFill, blo)
        box bhi = box.new(bx0, math.max(p75b, p50a), bx1, math.min(p75b, p50a), border_color=na, bgcolor=color.new(cHi, op))
        array.push(coneFill, bhi)

    // 3-layer glow lines per percentile (wide halo -> crisp core)
    cOut25 := line.new(x0, close, xH, p25, color=color.new(cLo,80), width=7)
    cOut50 := line.new(x0, close, xH, p50, color=color.new(cMd,80), width=7)
    cOut75 := line.new(x0, close, xH, p75, color=color.new(cHi,80), width=7)
    cMid25 := line.new(x0, close, xH, p25, color=color.new(cLo,50), width=4)
    cMid50 := line.new(x0, close, xH, p50, color=color.new(cMd,50), width=4)
    cMid75 := line.new(x0, close, xH, p75, color=color.new(cHi,50), width=4)
    cCor25 := line.new(x0, close, xH, p25, color=cLo, width=2)
    cCor50 := line.new(x0, close, xH, p50, color=cMd, width=2)
    cCor75 := line.new(x0, close, xH, p75, color=cHi, width=2)
    cLb25 := label.new(xH, p25, "P25 " + str.tostring(p25, format.mintick), style=label.style_label_left, color=color.new(cLo,15), textcolor=color.white, size=size.tiny)
    cLb50 := label.new(xH, p50, "P50 " + str.tostring(p50, format.mintick), style=label.style_label_left, color=color.new(cMd,15), textcolor=color.white, size=size.tiny)
    cLb75 := label.new(xH, p75, "P75 " + str.tostring(p75, format.mintick), style=label.style_label_left, color=color.new(cHi,15), textcolor=color.white, size=size.tiny)
````
