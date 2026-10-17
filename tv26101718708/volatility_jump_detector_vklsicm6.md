# Volatility Jump Detector

- url: https://www.tradingview.com/script/vKLsicM6-Volatility-Jump-Detector/
- type: indicator
- pine_id: PUB;32077a481fdc422c8293eff3bdad7472
- version: 3.0

## Description

Volatility Jump Detector

This tool marks structurally significant price moves and tells you what kind of move each one was. It is an event detector, not a signal — it does not predict direction. It answers "did something real just happen here, and what was behind it?"

HOW JUMPS ARE DETECTED

Most "big candle" indicators compare a move to an ordinary volatility estimate, which has a circular flaw: a large jump inflates the very volatility measure used to judge it, so the biggest moves look less exceptional than they are.

This uses bipower variation (Barndorff-Nielsen and Shephard; Lee and Mykland), which builds the local volatility estimate from products of adjacent absolute returns. That construction is insensitive to a single large move, and it is computed excluding the current bar — so a jump cannot inflate its own threshold. A move is flagged when it exceeds a chosen multiple of that robust volatility, and the panel reports the exact sigma reading.

TWO INDEPENDENT CONTEXT AXES

INTENSITY — Is the recent jump rate elevated versus its own long-run baseline? Reported as a multiple with the underlying counts always visible, so you can see the sample behind the verdict. Note on method: a Hawkes branching-ratio estimate was implemented first and dropped. At a 4-sigma threshold real data yields only a handful of jumps per few hundred bars, far too few for count-variance statistics — it returned zero on every timeframe tested. A plain rate comparison is what sparse events can actually support, and below a minimum count the reading honestly says "insufficient" rather than printing a fabricated number.

VOLUME — Was the jump backed by participation, or did it slip through a thin book? A large move on heavy volume and the same move on nothing are different events. Auto-disables on instruments without a volume feed.

Optionally link the Risk & Levels Cockpit's exported levels, and jumps that fire through your invalidation level or at the point of control are flagged.

ON THE CHART

Direction-aware triangles mark each jump, colored by the intensity regime at that moment. The most recent jump is labelled with its sigma reading and volume tag. The background tints when jump intensity is elevated. The panel adapts to your chart theme and colors each row by meaning.

WORKS ON ANY MARKET AND TIMEFRAME

All lookbacks are in bars with no session, expiry, or clock anchors. Non-repainting: the robust volatility estimate excludes the current bar, and everything confirms at close.

LIMITATIONS

Not a signal and not investment advice. This marks events and describes them; it does not forecast what follows. An earlier version classified jumps as "ignition" versus "exhaustion" and measured the forward tendency of each — the measured continuation and reversal rates sat at base rate, so that classification was removed rather than kept as decoration. Jump detection depends on the threshold you choose; a lower threshold marks more moves and dilutes significance. Intensity needs a long baseline window because jumps are rare, and reports "insufficient" when the count is too low. Volume confirmation requires a volume feed.

CREDITS

Original implementation. Barndorff-Nielsen and Shephard bipower variation; Lee and Mykland (2008) jump test; jump-rate intensity comparison.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0
// © Market_Logic_India
//
// ============================================================================
//  VOLATILITY JUMP DETECTOR   v3.0   (pairs with Risk & Levels Cockpit)
// ============================================================================
//  WHAT IT IS
//  An event descriptor, not a signal. It marks structurally significant moves
//  and gives each one CONTEXT on two independent axes - never a direction call.
//
//    JUMP   - Barndorff-Nielsen-Shephard bipower / Lee-Mykland test: flags a
//             bar whose move exceeds the local, jump-ROBUST volatility. The
//             volatility yardstick is computed EXCLUDING the current bar, so it
//             is insensitive to the jump it is measuring.
//    INTENSITY - Is the recent jump rate elevated versus its own long-run
//             baseline? A sparse-event-safe rate comparison.
//    VOLUME  - Was the jump backed by participation (volume vs its average) or
//             did it slip through a thin book? Auto-disables where the
//             instrument has no volume feed.
//    LEVEL CONTEXT (optional) - if wired to the Cockpit's EXP_ bus, flags when
//             a jump fires THROUGH the invalidation level or AT a value level.
//
//  v3 CHANGES vs v2  (methodology upgrades - detection fidelity, not edge)
//  1. PRINCIPLED THRESHOLD.  The v2 fixed "4 x sigma" is replaced by the actual
//     Lee-Mykland (2008) critical value. The maximum of the test statistic over
//     n scanned bars converges to a Gumbel law, so the correct threshold GROWS
//     with how many bars you scan (a multiple-testing / family-wise-error
//     correction). You now pick a false-positive level alpha; the threshold in
//     sigma-units is derived automatically and self-calibrates across timeframes
//     and assets. The classic fixed-sigma mode is retained as a fallback so you
//     can overlay old-vs-new on the same chart.
//  2. ROBUST LOCAL VARIANCE.  Optional MedRV estimator (Andersen-Dobrev-
//     Schaumburg 2012): the median of adjacent absolute-return triples. Unlike
//     plain bipower it is robust to TWO adjacent jumps (which otherwise
//     contaminate the |r_t||r_t-1| product and mask the second event) and to
//     zero returns on illiquid bars. Bipower is retained as a selectable mode.
//  3. POISSON INTENSITY.  "Elevated" is no longer a magic 1.5x. Under the null
//     that the recent rate equals baseline, the recent count is Poisson; a
//     variance-stabilised (Anscombe) z-score decides elevated / quiet at a
//     chosen sigma level. Well-behaved for the small counts jumps actually
//     produce. Ratio mode retained.
//  4. GAP HANDLING (optional).  log(close/close[1]) treats an overnight session
//     gap as a jump. A toggle suppresses the flag on the first regular-session
//     bar so equity/futures opens do not generate false positives.
//
//  WHY DESCRIPTIVE / NO HARNESS
//  Intraday directional prediction on liquid futures is near-efficient. This
//  tool claims no edge - its value is attention (a real event just fired) and
//  context (cascade risk, level interaction), which help regardless of edge.
//  The v3 upgrades sharpen the EVENT DETECTION (false-positive control,
//  robustness, honest calibration); they do not manufacture predictive edge.
//
//  ALERTS
//  Named conditions: jump fired (any / up / down), volume-confirmed jump, thin-
//  volume jump, intensity became elevated, jump through the linked break level,
//  jump at the linked POC. A dynamic alert() also fires on every jump carrying
//  the live sigma, direction, volume state and intensity in one message - to
//  use it, create an alert and select "Any alert() function call".
//
//  ALL-TIMEFRAME, ALL-ASSET . NON-REPAINT (current-bar OHLC, robust vol excludes
//  the current bar; confirms at close; no request.security, no future ref).
//
//  CREDITS  Barndorff-Nielsen & Shephard bipower variation; Lee & Mykland
//  (2008) nonparametric jump test and Gumbel critical value; Andersen, Dobrev
//  & Schaumburg (2012) MedRV; variance-stabilised Poisson (Anscombe) intensity.
//  Original implementation. Not investment advice.
// ============================================================================

//@version=6
indicator("Volatility Jump Detector", shorttitle = "VJD", overlay = true, max_bars_back = 3100, max_labels_count = 20)

// ============================================================================
//  00 · HELPERS
// ============================================================================
// median of three scalars = max of the three pairwise minimums
med3(float a, float b, float c) => math.max(math.max(math.min(a, b), math.min(a, c)), math.min(b, c))

// ============================================================================
//  01 · INPUTS
// ============================================================================
gJ = "01 · Jump detection"
jumpWin    = input.int(20, "Local volatility window (bars)", minval = 5, maxval = 100, group = gJ, tooltip = "Bars used to estimate the local, jump-robust volatility. Always excludes the current bar.")
volEst     = input.string("MedRV (robust)", "Volatility estimator", options = ["MedRV (robust)", "Bipower (classic)"], group = gJ, tooltip = "MedRV (median of adjacent |return| triples) is robust to two adjacent jumps and to zero returns. Bipower is the classic |r_t|*|r_t-1| estimator.")
detectMode = input.string("Lee-Mykland (significance)", "Threshold mode", options = ["Lee-Mykland (significance)", "Fixed σ multiple (classic)"], group = gJ, tooltip = "Lee-Mykland derives the threshold from a false-positive level and the scan window (multiple-testing correction). Fixed mode uses the v2 constant σ multiple.")
alphaPct   = input.float(1.0, "  L-M false-positive level α (%)", minval = 0.01, maxval = 20.0, step = 0.05, group = gJ, tooltip = "Family-wise probability of at least one FALSE jump across the scan window. Lower α ⇒ higher threshold ⇒ fewer, more certain flags.")
nScan      = input.int(250, "  L-M scan window n (bars)", minval = 10, maxval = 5000, group = gJ, tooltip = "Multiple-testing horizon: how many bars you are effectively scanning. The threshold grows slowly with n. ~a session for intraday, ~a year (250) for daily.")
jumpThresh = input.float(4.0, "  Fixed threshold (× robust σ)", minval = 2.0, maxval = 10.0, step = 0.25, group = gJ, tooltip = "Only used in Fixed σ multiple mode.")

gR = "02 · Jump intensity"
shortWin  = input.int(100, "Recent window (bars)", minval = 20, maxval = 300, group = gR, tooltip = "Recent jump rate is measured over this window.")
longWin   = input.int(2000, "Baseline window (bars)", minval = 200, maxval = 3000, group = gR, tooltip = "Long-run rate for comparison. Jumps are rare, so this needs to be long enough to accumulate a usable count.")
minJumps  = input.int(8, "Min jumps to report", minval = 3, maxval = 50, group = gR, tooltip = "Below this many jumps in the baseline window there is nothing statistically meaningful to say, so it reports 'insufficient'.")
intMode   = input.string("Poisson significance", "Intensity test", options = ["Poisson significance", "Ratio × baseline"], group = gR, tooltip = "Poisson: is the recent count a significant excess over the baseline rate (variance-stabilised z)? Ratio: recent rate as a plain multiple of baseline.")
zHot      = input.float(2.0, "  Poisson z for elevated/quiet (σ)", minval = 1.0, maxval = 4.0, step = 0.1, group = gR, tooltip = "z ≈ 2.0 ≈ 2.3% one-sided; 2.33 ≈ 1%. Elevated when z ≥ this, quiet when z ≤ −this.")
hotMult   = input.float(1.5, "  Ratio: elevated above (× baseline)", minval = 1.1, maxval = 5.0, step = 0.1, group = gR)
quietMult = input.float(0.7, "  Ratio: quiet below (× baseline)", minval = 0.1, maxval = 0.95, step = 0.05, group = gR)

gV = "03 · Volume confirmation"
volLen  = input.int(20, "Volume average (bars)", minval = 5, maxval = 100, group = gV)
volMult = input.float(1.5, "Confirmed above (× average)", minval = 1.0, maxval = 5.0, step = 0.1, group = gV, tooltip = "A jump on volume at or above this multiple of average is 'confirmed' participation; below it the move went through a thin book. Auto-disables where no volume feed exists.")

gG = "04 · Gap handling"
excludeGaps = input.bool(false, "Suppress jumps on session open (gap)", group = gG, tooltip = "Intraday only: log(close/close[1]) turns an overnight gap into a spurious jump. When on, the first regular-session bar is not flagged.")

gL = "05 · Cockpit level context (optional)"
useLevels = input.bool(false, "Flag jumps at linked levels", group = gL, tooltip = "Wire the sources to the Cockpit's EXP_ levels. A jump whose bar straddles a level is flagged.")
lvlBreak  = input.source(close, "  Cockpit EXP_Break (up or dn)", group = gL)
lvlPOC    = input.source(close, "  Cockpit EXP_POC", group = gL)

gU = "06 · Display"
themeOpt  = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = gU)
tblPos    = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gU)
showMarks = input.bool(true, "Jump markers", group = gU)
markColMode = input.string("Direction (green / red)", "Marker & label colour", options = ["Direction (green / red)", "Intensity (cyan / red)"], group = gU, tooltip = "Direction: green = up jump, red = down jump (conventional). Intensity: cyan = normal jump rate, red = elevated — direction is then read from the triangle's shape/position, and colour is free to show cascade risk.")
showLast  = input.bool(true, "Label last jump", group = gU)
showBg    = input.bool(true, "Tint background when intensity elevated", group = gU)

// ============================================================================
//  02 · THEME
// ============================================================================
bg     = chart.bg_color
lum    = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
darkBG = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : lum < 128
txtCol = darkBG ? color.white : color.black
tintV  = darkBG ? 82 : 74
f_tint(color c) => color.new(c, tintV)
f_ink(color c) => darkBG ? color.new(c, 0) : color.new(c, 15)
colCalm = #00e5ff   // quiet / normal jump rate
colHot  = #ff5252   // elevated jump rate
colMid  = #ffb300   // moderate
colNs   = color.gray
colUp   = #26a69a
colDn   = #ef5350

// ============================================================================
//  03 · LOCAL ROBUST VOLATILITY  (bipower OR MedRV, current bar excluded)
// ============================================================================
ret  = math.log(close / close[1])
absr = math.abs(ret)

// Bipower variation: E[(π/2)|r_t||r_t-1|] = σ² per bar
prodBP    = absr * absr[1]
bpMeanRaw = ta.sma(prodBP, jumpWin)
bpMean    = bpMeanRaw[1]                                  // exclude current bar
varBP     = (math.pi / 2) * bpMean

// MedRV: c * median(|r_t|,|r_t-1|,|r_t-2|)² estimates σ² per bar, robust to
// adjacent jumps and zero returns. Triple uses current+past only (no future);
// the window is shifted by one so the current return is excluded from its own test.
C_MED     = math.pi / (6.0 - 4.0 * math.sqrt(3.0) + math.pi)   // ≈ 1.4193
fsAdj     = jumpWin / (jumpWin - 2.0)                          // ADS finite-sample factor (median triples lose 2)
tripSq    = math.pow(med3(absr, absr[1], absr[2]), 2)
medRaw    = ta.sma(tripSq, jumpWin)
medMean   = medRaw[1]                                     // exclude current bar
varMed    = C_MED * fsAdj * medMean

localVar  = volEst == "MedRV (robust)" ? varMed : varBP
sigC      = localVar > 0 ? math.sqrt(localVar) : na
jumpStat  = not na(sigC) and sigC > 0 ? absr / sigC : 0.0

// ============================================================================
//  04 · THRESHOLD  (Lee-Mykland Gumbel critical value, or fixed σ multiple)
//  In this script's normalisation jumpStat ≈ |standard normal| under the null,
//  so the max over n bars follows the classical extreme-value law. Mapping
//  Lee-Mykland's C_n, S_n through the √(π/2) scaling gives, in σ-units:
//     β* = √(2 ln n) − (ln π + ln ln n) / (2√(2 ln n)) + q / √(2 ln n)
//  with q = −ln(−ln(1−α)). Threshold rises with the scan window n.
// ============================================================================
alphaLM = alphaPct / 100.0
lnN     = math.log(nScan)
sN      = math.sqrt(2.0 * lnN)
qLM     = -math.log(-math.log(1.0 - alphaLM))
betaLM  = sN - (math.log(math.pi) + math.log(lnN)) / (2.0 * sN) + qLM / sN
betaEff = detectMode == "Fixed σ multiple (classic)" ? jumpThresh : betaLM

// Gap suppression (intraday session open)
gapBar  = excludeGaps and timeframe.isintraday and session.isfirstbar_regular

rawJump = jumpStat > betaEff
jump    = rawJump and not gapBar
jumpDir = ret > 0 ? 1 : ret < 0 ? -1 : 0

// ============================================================================
//  05 · JUMP INTENSITY  (Poisson significance, or ratio — sparse-event safe)
//  Under the null "recent rate = baseline rate", the recent count is Poisson
//  with mean λ = baseline_rate × recent_window. The Anscombe variance-stabilising
//  transform z = 2(√(k+3/8) − √(λ+3/8)) ≈ N(0,1) behaves well for small counts.
// ============================================================================
jflag     = jump ? 1.0 : 0.0
jShort    = math.sum(jflag, shortWin)
jLong     = math.sum(jflag, longWin)
rateShort = jShort / shortWin
rateLong  = jLong / longWin
enoughN   = jLong >= minJumps

intensity = enoughN and rateLong > 0 ? rateShort / rateLong : na          // ratio, for display
lambda    = rateLong * shortWin                                           // expected recent count
zPois     = 2.0 * (math.sqrt(jShort + 0.375) - math.sqrt(lambda + 0.375)) // Anscombe z

hotPois   = enoughN and zPois >= zHot
quietPois = enoughN and zPois <= -zHot
hotRatio  = not na(intensity) and intensity >= hotMult
quietRatio = not na(intensity) and intensity <= quietMult

hot   = intMode == "Poisson significance" ? hotPois   : hotRatio
quiet = intMode == "Poisson significance" ? quietPois : quietRatio

reflexTxt = not enoughN ? "insufficient (" + str.tostring(jLong, "#") + " jumps)" :
   hot ? "elevated" : quiet ? "quiet" : "normal"
reflexCol = not enoughN ? colNs : hot ? colHot : quiet ? colCalm : colMid

// ============================================================================
//  06 · VOLUME CONFIRMATION  (participation behind the move)
// ============================================================================
volAvg   = ta.sma(volume, volLen)
hasVol   = not na(volume) and volume > 0 and not na(volAvg) and volAvg > 0
volRatio = hasVol ? volume / volAvg : na
volConf  = hasVol and volRatio >= volMult
volCol   = not hasVol ? colNs : volConf ? colUp : colMid

// ============================================================================
//  07 · LEVEL CONTEXT  (optional Cockpit linkage)
// ============================================================================
throughBreak = useLevels and jump and high >= lvlBreak and low <= lvlBreak
atPOC        = useLevels and jump and high >= lvlPOC and low <= lvlPOC
lvlTxt = not useLevels ? "" : throughBreak ? " · through break" : atPOC ? " · at POC" : ""

// ============================================================================
//  08 · VISUALS
// ============================================================================
dirCol = jumpDir > 0 ? colUp : colDn
mkCol  = markColMode == "Direction (green / red)" ? dirCol : (hot ? colHot : colCalm)
bgcolor(showBg and hot ? color.new(colHot, 93) : na, title = "Elevated intensity")
plotshape(showMarks and jump and jumpDir > 0, "Jump up",   style = shape.triangleup,   location = location.belowbar, color = mkCol, size = size.small)
plotshape(showMarks and jump and jumpDir < 0, "Jump down", style = shape.triangledown, location = location.abovebar, color = mkCol, size = size.small)

var int lastJBar = na
var int lastJDir = 0
var float lastJStat = na
var bool lastJVolConf = false
var float lastJVolRatio = na
if jump
    lastJBar := bar_index
    lastJDir := jumpDir
    lastJStat := jumpStat
    lastJVolConf := volConf
    lastJVolRatio := volRatio
barsSince = not na(lastJBar) ? bar_index - lastJBar : na

var label bLast = na
if showLast and jump
    label.delete(bLast)
    arr = jumpDir > 0 ? " ▲" : " ▼"
    lstyle = jumpDir > 0 ? label.style_label_lower_left : label.style_label_upper_left
    lloc   = jumpDir > 0 ? high : low
    bLast := label.new(bar_index + 3, lloc, "JUMP" + arr + " " + str.tostring(jumpStat, "#.#") + "σ" + (hasVol ? (volConf ? " ·vol✓" : " ·thin") : "") + lvlTxt, style = lstyle, color = mkCol, textcolor = color.black, size = size.tiny)

// ============================================================================
//  09 · ALERTS
// ============================================================================
jumpUp      = jump and jumpDir > 0
jumpDown    = jump and jumpDir < 0
jumpVolConf = jump and volConf
jumpThin    = jump and hasVol and not volConf
intensityUp = hot and not hot[1]

alertcondition(jump,        "Jump fired (any)",       "VJD: significant jump detected on {{ticker}} {{interval}}")
alertcondition(jumpUp,      "Jump up",                "VJD: upward jump on {{ticker}} {{interval}}")
alertcondition(jumpDown,    "Jump down",              "VJD: downward jump on {{ticker}} {{interval}}")
alertcondition(jumpVolConf, "Jump - volume confirmed","VJD: jump on above-average volume - genuine participation")
alertcondition(jumpThin,    "Jump - thin volume",     "VJD: jump on thin volume - move went through an empty book")
alertcondition(intensityUp, "Intensity became elevated","VJD: jump rate has moved above its long-run baseline")
alertcondition(throughBreak,"Jump through break level","VJD: jump fired through the linked invalidation level")
alertcondition(atPOC,       "Jump at POC",            "VJD: jump fired at the linked point of control")

// rich dynamic alert - one message carrying the full context of the event
if jump
    dirTxt = jumpDir > 0 ? "UP" : "DOWN"
    vTxt   = not hasVol ? "vol n/a" : (volConf ? "vol confirmed " : "thin vol ") + str.tostring(volRatio, "#.#") + "x"
    iTxt   = not enoughN ? "intensity n/a" : "intensity " + (na(intensity) ? "-" : str.tostring(intensity, "#.##") + "x base")
    lTxt   = throughBreak ? " | THROUGH BREAK" : atPOC ? " | at POC" : ""
    alert("VJD " + syminfo.ticker + " " + timeframe.period + ": " + dirTxt + " jump " +
          str.tostring(jumpStat, "#.#") + " sigma (thr " + str.tostring(betaEff, "#.##") + ") | " + vTxt + " | " + iTxt + lTxt, alert.freq_once_per_bar_close)

// ============================================================================
//  10 · EXP_ BUS
// ============================================================================
plot(jump ? 1 : 0,        "EXP_Jump",     display = display.data_window)
plot(jumpDir,             "EXP_JumpDir",  display = display.data_window)
plot(jumpStat,            "EXP_JumpStat", display = display.data_window)
plot(betaEff,             "EXP_Thresh",   display = display.data_window)
plot(intensity,           "EXP_Intensity", display = display.data_window)
plot(zPois,               "EXP_IntensityZ", display = display.data_window)
plot(volRatio,            "EXP_VolRatio",  display = display.data_window)
plot(throughBreak ? 1 : 0,"EXP_AtBreak",  display = display.data_window)

// ============================================================================
//  11 · DASHBOARD
// ============================================================================
pos = switch tblPos
    "Top Left"      => position.top_left
    "Top Right"     => position.top_right
    "Bottom Left"   => position.bottom_left
    "Bottom Right"  => position.bottom_right
    "Middle Right"  => position.middle_right
    => position.top_right

var table tbl = table.new(pos, 2, 8, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 40))

if barstate.islast
    hdrCol = darkBG ? color.new(color.gray, 62) : color.new(color.gray, 78)
    labCol = darkBG ? color.new(color.gray, 88) : color.new(color.gray, 92)

    table.cell(tbl, 0, 0, "VOLATILITY JUMP DETECTOR", text_color = txtCol, text_size = size.small, bgcolor = hdrCol)
    table.cell(tbl, 1, 0, str.tostring(timeframe.period), text_color = txtCol, text_size = size.small, bgcolor = hdrCol)

    lastTxt = na(lastJBar) ? "—" : ("JUMP" + (lastJDir > 0 ? " ▲" : " ▼") + "  " + str.tostring(lastJStat, "#.#") + "σ")
    lastCol = na(lastJBar) ? colNs : lastJDir > 0 ? colUp : colDn
    table.cell(tbl, 0, 1, "Last jump", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 1, lastTxt + (na(barsSince) ? "" : "  (" + str.tostring(barsSince) + " bars)"), text_color = f_ink(lastCol), text_size = size.small, bgcolor = f_tint(lastCol))

    nowCol = jump ? colUp : colNs
    table.cell(tbl, 0, 2, "Now (σ / thr)", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 2, str.tostring(jumpStat, "#.#") + " / " + str.tostring(betaEff, "#.##"), text_color = f_ink(nowCol), text_size = size.small, bgcolor = f_tint(nowCol))

    brTxt = not enoughN ? reflexTxt :
       intMode == "Poisson significance" ? reflexTxt + "  (z " + str.tostring(zPois, "#.#") + ")" :
       na(intensity) ? reflexTxt : reflexTxt + "  (" + str.tostring(intensity, "#.##") + "× base)"
    table.cell(tbl, 0, 3, "Jump intensity", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 3, brTxt, text_color = f_ink(reflexCol), text_size = size.small, bgcolor = f_tint(reflexCol))

    lvlCol = not useLevels ? colNs : throughBreak ? colHot : atPOC ? colMid : colNs
    table.cell(tbl, 0, 4, "Level context", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 4, not useLevels ? "off" : throughBreak ? "through break" : atPOC ? "at POC" : "—", text_color = f_ink(lvlCol), text_size = size.small, bgcolor = f_tint(lvlCol))

    lastVolTxt = na(lastJBar) ? "—" : not hasVol ? "n/a (no volume)" : (na(lastJVolRatio) ? "—" : str.tostring(lastJVolRatio, "#.#") + "×  " + (lastJVolConf ? "confirmed" : "thin"))
    lastVolCol = na(lastJBar) or not hasVol ? colNs : lastJVolConf ? colUp : colMid
    table.cell(tbl, 0, 5, "Volume at jump", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 5, lastVolTxt, text_color = f_ink(lastVolCol), text_size = size.small, bgcolor = f_tint(lastVolCol))

    table.cell(tbl, 0, 6, "Jump count", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 6, str.tostring(jShort, "#") + " recent / " + str.tostring(jLong, "#") + " base", text_color = txtCol, text_size = size.small)

    cfgTxt = (volEst == "MedRV (robust)" ? "MedRV" : "BPV") + " · " + (detectMode == "Fixed σ multiple (classic)" ? "σ×" + str.tostring(jumpThresh, "#.#") : "L-M α " + str.tostring(alphaPct, "#.##") + "%")
    table.cell(tbl, 0, 7, "Config", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 7, cfgTxt, text_color = txtCol, text_size = size.small)
````
