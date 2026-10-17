# Market Regime Lens

- url: https://www.tradingview.com/script/zeqwXzM5-Market-Regime-Lens/
- type: indicator
- pine_id: PUB;b0238347858e455a9fc9d68f25bf9d1c
- version: 2.0

## Description

Market Regime Lens

Market Regime Lens reads the market on four independent axes and gives you one honest sentence about the current tape. It is a context descriptor, not a signal — it never tells you which way to trade. It tells you whether the tape is readable, how it moves, how long things take, and how risk is arriving.

WHY FOUR AXES, ONE COMPONENT EACH

Most multi-indicator tools stack measures that secretly say the same thing — three complexity metrics agreeing is not confirmation, it is autocorrelation. This tool deliberately uses one component per independent axis, so each number tells you something the others cannot.

STRUCTURE — Complexity-Entropy plane. Bandt-Pompe permutation entropy paired with Martin-Plastino-Rosso statistical complexity, classifying the tape as structured, mixed, or noise. Thresholds are adaptive by default: the reading is ranked against the instrument's own recent range, so it self-calibrates to any market and timeframe instead of relying on absolute cutoffs that break when you change the window.

PERSISTENCE — Anomalous-diffusion exponent. Fitted from mean-squared-displacement scaling across lags: alpha above 1 means super-diffusive (trending), alpha near 1 is a random walk, alpha below 1 is sub-diffusive (mean-reverting). This describes the character of the motion, not its direction.

TIME — First passage and null odds. Expected bars to reach the target versus the stop under a driftless diffusion, plus the null barrier probability P = b/(a+b) — what a coin flip gives you at your chosen reward-to-risk. At 1.5R that is 40%. That is the breakeven any setup must clear, stated plainly.
TAIL — Extremal index. Measures whether extreme moves cluster (theta below 1) or arrive independently. Clustered tails mean gap risk shows up in bursts, which matters for stop placement.

ON THE CHART

The main line is the diffusion exponent, colored by state and filled against the alpha = 1 random-walk baseline, so deviation from randomness is visible at a glance. Faint guides mark the trending and reverting thresholds. Background tint shows the structure class. The panel adapts to your chart theme and colors each row by meaning — including green or amber on the null-odds row depending on whether your chosen R gives better-than-even odds.

PAIRS WITH RISK & LEVELS COCKPIT

Optionally wire the target and stop sources to the Cockpit's exported levels, and the timing and null-probability rows use your real trade levels instead of internal ATR references.

WORKS ON ANY MARKET AND TIMEFRAME

All lookbacks are in bars with no session, expiry, or clock anchors. Non-repainting: everything uses the current bar's data and confirms at close.

LIMITATIONS

Not a signal and not investment advice — no axis forecasts direction. Permutation entropy and complexity require a window much larger than d factorial; at dimension 4 use at least 300 bars, since short windows are undersampling-biased and pin to a constant. Adaptive thresholds classify relative to the instrument's own recent range, so "structured" means structured for this market lately, not in any absolute sense. First-passage times and the null probability assume driftless diffusion with constant volatility — a deliberate null baseline, not a forecast. The extremal index needs enough exceedances; too short a window pins it at 1.00.

CREDITS

Original implementation. Bandt and Pompe permutation entropy; Martin-Plastino-Rosso and Lopez-Ruiz statistical complexity via Jensen-Shannon divergence; anomalous-diffusion MSD scaling; Ferro-Segers runs estimator for the extremal index; first-passage-time and gambler's-ruin barrier theory.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0
// © Market_Logic_India
//
// ============================================================================
//  MARKET REGIME LENS   v1.1   (pairs with Risk & Levels Cockpit)
// ============================================================================
//  WHAT IT IS
//  A context descriptor, not a signal. It reads the tape on four INDEPENDENT
//  axes so each number tells you something the others can't - deliberately one
//  component per axis, never a stack of measures that all say the same thing.
//
//    STRUCTURE   - Complexity-Entropy plane (Bandt-Pompe permutation entropy +
//                  Martin-Plastino-Rosso statistical complexity): readable /
//                  noise / periodic.
//    PERSISTENCE - Anomalous-diffusion exponent a from MSD scaling: a>1
//                  trending, a~1 random walk, a<1 mean-reverting.
//    TIME        - Mean first-passage estimate: expected bars to reach the
//                  target vs the stop under a driftless diffusion, PLUS the
//                  null barrier probability P = b/(a+b) - what a coin flip
//                  gives you at your chosen R (the honest breakeven any setup
//                  must beat). Reads the Cockpit's EXP_ levels, or ATR levels.
//    TAIL        - Extremal index th: clustering of extreme moves (th<1 =
//                  tail events bunch = gap risk arrives in bursts).
//
//  Output is one honest read, e.g. "structured . reverting . tails clustered"
//  - it tells you WHETHER and HOW to act on the Cockpit's levels, never WHICH
//  WAY. Persistence is a property of motion, not a forecast.
//
//  CHART LEGEND
//  Main line = diffusion exponent a, colored by state (green trending / red
//  reverting / grey random walk), filled against the a=1 random-walk baseline.
//  Faint green & red guides = the trending / reverting thresholds. Background
//  tint = structure class. Panel = the four axes plus timing and null odds.
//
//  ALERTS
//  Fires on TRANSITIONS, not on state: structure turning structured or noise,
//  persistence turning trending / reverting / random-walk, tails starting or
//  stopping clustering, and a catch-all "any regime change". A dynamic alert()
//  carries the full four-axis read - select "Any alert() function call".
//
//  LEVEL LINKING
//  The Time and Null-odds rows are far more useful against real trade levels.
//  Toggling the link on is not sufficient - the source inputs default to
//  `close`, so they must actually be pointed at the Cockpit's EXP_Target1 and
//  EXP_Stop plots. The panel states which of three states applies: internal
//  ATR, Cockpit linked, or "link ON but not wired" so a half-configured setup
//  can never masquerade as a linked one.
//
//  WHY NO EDGE CLAIM / NO HARNESS
//  Intraday directional prediction on liquid futures is near-efficient (proven
//  repeatedly). This tool makes no directional claim, so it needs no edge
//  validation - like the Cockpit, its value is descriptive: sharper context
//  for risk and patience decisions.
//
//  LIMITATIONS (read before use)
//  - Not a signal and not investment advice. No axis forecasts direction.
//  - Permutation entropy / complexity need window >> d!. At d=4 use >= 300
//    bars; short windows are undersampling-biased and pin to a constant.
//  - Adaptive thresholds classify RELATIVE to the instrument's own recent
//    range, so "structured" means structured *for this market lately*, not in
//    any absolute sense.
//  - First-passage times and the null probability assume driftless diffusion
//    with constant volatility - a deliberate null baseline, not a forecast.
//    Unlinked, they use ATR levels and are only as meaningful as those levels.
//  - The extremal index needs enough exceedances; too short a window pins it
//    at 1.00.
//
//  ALL-TIMEFRAME, ALL-ASSET . NON-REPAINT (current-bar OHLC, confirms at close;
//  no request.security, no future reference).
//
//  CREDITS  Bandt & Pompe permutation entropy; Martin-Plastino-Rosso / Lopez-
//  Ruiz statistical complexity (Jensen-Shannon); anomalous-diffusion MSD
//  scaling; Ferro-Segers / runs extremal index; first-passage-time and
//  gambler's-ruin barrier theory. Original implementation. Not investment advice.
// ============================================================================

//@version=6
indicator("Market Regime Lens", shorttitle = "REGIME", overlay = false, max_bars_back = 1000)

// ============================================================================
//  01 · INPUTS
// ============================================================================
gS = "01 · Structure (complexity-entropy)"
embedDim = input.int(4, "Embedding dimension", minval = 3, maxval = 5, group = gS, tooltip = "Ordinal pattern length. d=4 -> 24 patterns. Needs window >> d! or entropy/complexity are undersampling-biased and pin to a constant.")
cecpWin  = input.int(400, "Window (bars)", minval = 100, maxval = 500, group = gS, tooltip = "Must be many times d!. At d=4 use >= 300; 120 is badly undersampled and pins the reading.")
adaptive = input.bool(true, "Adaptive thresholds", group = gS, tooltip = "ON (default): classify by where complexity sits in its OWN recent range (percentile) - self-calibrates to any market/timeframe. OFF: use the fixed absolute thresholds below.")
adaptWin = input.int(300, "Adaptive window (bars)", minval = 50, maxval = 500, group = gS)
cHiRank  = input.float(65.0, "Structured above (pct rank)", minval = 50, maxval = 95, step = 1, group = gS)
cLoRank  = input.float(35.0, "Noise below (pct rank)", minval = 5, maxval = 50, step = 1, group = gS)
cThresh  = input.float(0.16, "Structured above (absolute C)", minval = 0.02, maxval = 0.5, step = 0.01, group = gS)
hThresh  = input.float(0.92, "Noise above (absolute H)", minval = 0.5, maxval = 1.0, step = 0.01, group = gS)

gD = "02 · Persistence (diffusion)"
msdWin  = input.int(120, "MSD window (bars)", minval = 30, maxval = 300, group = gD)
tauMax  = input.int(10, "Max lag", minval = 3, maxval = 30, group = gD)
aTrend  = input.float(1.15, "Trending above (α)", minval = 1.01, maxval = 1.8, step = 0.01, group = gD)
aRevert = input.float(0.85, "Reverting below (α)", minval = 0.2, maxval = 0.99, step = 0.01, group = gD)

gT = "03 · Time (first-passage)"
useCockpit = input.bool(false, "Link Cockpit levels", group = gT, tooltip = "Wire the sources below to the Cockpit's EXP_Target1 / EXP_Stop for real target/stop times. Off = internal ATR levels.")
cpTarget   = input.source(close, "  Cockpit EXP_Target1", group = gT)
cpStop     = input.source(close, "  Cockpit EXP_Stop", group = gT)
atrLen     = input.int(14, "ATR length (internal)", minval = 2, maxval = 100, group = gT)
tgtMult    = input.float(1.5, "Target (× ATR, internal)", minval = 0.5, maxval = 8, step = 0.25, group = gT)
stopMult   = input.float(1.0, "Stop (× ATR, internal)", minval = 0.5, maxval = 8, step = 0.25, group = gT)
sigLen     = input.int(20, "Vol length", minval = 5, maxval = 100, group = gT)

gX = "04 · Tail (extremal index)"
extWin  = input.int(300, "Window (bars)", minval = 100, maxval = 500, group = gX, tooltip = "Needs enough exceedances for a stable theta. 150 bars at the 95th pct gives only ~7 - too few.")
extPct  = input.float(90.0, "Extreme percentile", minval = 80, maxval = 98, step = 0.5, group = gX)
extThr  = input.float(0.6, "Clustered below (theta)", minval = 0.2, maxval = 1.0, step = 0.05, group = gX)

gU = "05 · Display"
themeOpt = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = gU)
tblPos   = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gU)
showBg   = input.bool(true, "Structure background", group = gU)

// ============================================================================
//  02 · THEME
// ============================================================================
bg     = chart.bg_color
lum    = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
darkBG = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : lum < 128
txtCol = darkBG ? color.white : color.black
// adaptive tint: semantic colors need more opacity on light backgrounds to read
tintV  = darkBG ? 82 : 74
f_tint(color c) => color.new(c, tintV)
// value text on a tinted cell: keep contrast on either theme
f_ink(color c) => darkBG ? color.new(c, 0) : color.new(c, 15)
colTr  = #26a69a   // trending / structured
colRv  = #ef5350   // reverting
colNs   = color.gray // noise
colPd   = #ab47bc   // periodic
colStr  = #42a5f5   // structured
colTime = #7e57c2   // timing rows
colWarn = #ffa726   // odds against you at this R

// ============================================================================
//  03 · STRUCTURE  (complexity-entropy plane)
// ============================================================================
f_factorial(int n) =>
    f = 1
    for k = 2 to n
        f := f * k
    f

f_ordinal(int d, int off) =>
    // Lehmer-code index 0..d!-1 of the ordinal pattern of close[off..off+d-1]
    idx = 0
    for i = 0 to d - 2
        c = 0
        for j = i + 1 to d - 1
            if close[off + j] < close[off + i]
                c := c + 1
        idx := idx + c * f_factorial(d - 1 - i)
    idx

f_cecp(int d, int win) =>
    npat = f_factorial(d)
    hist = array.new<float>(npat, 0.0)
    total = 0.0
    for p = 0 to win - 1
        oi = f_ordinal(d, p)
        if oi >= 0 and oi < npat
            array.set(hist, oi, array.get(hist, oi) + 1.0)
            total := total + 1.0
    float hn = na
    float cjs = na
    if total > 0
        sP = 0.0
        sM = 0.0
        invN = 1.0 / npat
        for b = 0 to npat - 1
            pr = array.get(hist, b) / total
            if pr > 0
                sP := sP - pr * math.log(pr)
            mix = (pr + invN) / 2.0
            sM := sM - mix * math.log(mix)
        sPe = math.log(npat)
        hn := sPe > 0 ? sP / sPe : na
        js = sM - sP / 2.0 - sPe / 2.0
        q0denom = ((npat + 1.0) / npat) * math.log(npat + 1.0) - 2.0 * math.log(2.0 * npat) + math.log(npat)
        q0 = q0denom != 0 ? -2.0 / q0denom : 0.0
        cjs := q0 * js * hn
    [hn, cjs]

[cecpH, cecpC] = f_cecp(embedDim, cecpWin)

// adaptive classification: where does complexity sit in its OWN recent range?
// (absolute CECP values depend on window/dimension, so relative is the robust read)
cRank = ta.percentrank(cecpC, adaptWin)

structTxt = na(cecpC) ? "—" :
   adaptive ?
     (na(cRank) ? "—" : cRank >= cHiRank ? "structured" : cRank <= cLoRank ? "noise" : "mixed") :
     (cecpC > cThresh ? "structured" : cecpH > hThresh ? "noise" : cecpH < 0.6 ? "periodic" : "mixed")
structCol = structTxt == "structured" ? colStr : structTxt == "noise" ? colNs : structTxt == "periodic" ? colPd : txtCol

// ============================================================================
//  04 · PERSISTENCE  (anomalous-diffusion exponent via MSD scaling)
// ============================================================================
f_alpha(int win, int tmax) =>
    lx = array.new<float>()
    ly = array.new<float>()
    for tau = 1 to tmax
        s = 0.0
        cnt = 0
        for i = 0 to win - 1
            dd = math.log(close[i]) - math.log(close[i + tau])
            s := s + dd * dd
            cnt := cnt + 1
        msd = cnt > 0 ? s / cnt : na
        if not na(msd) and msd > 0
            array.push(ly, math.log(msd))
            array.push(lx, math.log(tau))
    float a = na
    n = array.size(lx)
    if n >= 2
        sx = array.sum(lx)
        sy = array.sum(ly)
        sxx = 0.0
        sxy = 0.0
        for i = 0 to n - 1
            xv = array.get(lx, i)
            yv = array.get(ly, i)
            sxx := sxx + xv * xv
            sxy := sxy + xv * yv
        den = n * sxx - sx * sx
        a := den != 0 ? (n * sxy - sx * sy) / den : na
    a

alpha = f_alpha(msdWin, tauMax)
persistTxt = na(alpha) ? "—" : alpha > aTrend ? "trending" : alpha < aRevert ? "reverting" : "random-walk"
persistCol = na(alpha) ? txtCol : alpha > aTrend ? colTr : alpha < aRevert ? colRv : colNs

// ============================================================================
//  05 · TIME  (mean first-passage estimate)
// ============================================================================
ret    = math.log(close / close[1])
atrV   = ta.atr(atrLen)
retSD  = ta.stdev(ret, sigLen)
sigPx  = close * retSD
// The toggle alone is not enough - the source inputs default to `close`, so a
// user can switch linking on and still be feeding price, not levels. Detect
// whether real levels are actually arriving and fall back cleanly if not.
linkWired = useCockpit and (cpTarget != close or cpStop != close)
tgtDist  = linkWired ? math.abs(cpTarget - close) : tgtMult * atrV
stopDist = linkWired ? math.abs(cpStop - close)   : stopMult * atrV
linkTxt  = not useCockpit ? "internal ATR" : linkWired ? "Cockpit linked" : "link ON but not wired"
linkCol  = not useCockpit ? colNs : linkWired ? colTr : colRv
mfptTgt  = sigPx > 0 ? math.pow(tgtDist / sigPx, 2) : na
mfptStop = sigPx > 0 ? math.pow(stopDist / sigPx, 2) : na
// Null barrier probability: for driftless diffusion with target a and stop b,
// P(touch target before stop) = b / (a + b). This is what a coin flip gives you
// at your chosen R - the honest breakeven any setup must beat. No edge assumed.
pNull    = (tgtDist + stopDist) > 0 ? stopDist / (tgtDist + stopDist) : na
rRatio   = stopDist > 0 ? tgtDist / stopDist : na

// ============================================================================
//  06 · TAIL  (extremal index — clustering of extremes)
// ============================================================================
f_extremal(int win, float pct) =>
    absA = array.new<float>()
    for i = 0 to win - 1
        array.push(absA, math.abs(ret[i]))
    thr = array.percentile_linear_interpolation(absA, pct)
    nu = 0
    nc = 0
    prevExc = false
    for i = 0 to win - 1
        exc = array.get(absA, i) > thr
        if exc
            nu := nu + 1
            if not prevExc
                nc := nc + 1
        prevExc := exc
    nu > 0 ? nc / nu : na

theta = f_extremal(extWin, extPct)
tailTxt = na(theta) ? "—" : theta < extThr ? "clustered" : "isolated"
tailCol = na(theta) ? txtCol : theta < extThr ? colRv : txtCol

// ============================================================================
//  07 · STANCE
// ============================================================================
mfptTxt = na(mfptTgt) ? "—" : "~" + str.tostring(math.round(mfptTgt)) + " bars to target"
stanceTxt = structTxt + " · " + persistTxt + " · tails " + tailTxt

// ============================================================================
//  08 · PLOTS   (α vs the random-walk baseline, filled by persistence state)
// ============================================================================
pAlpha = plot(alpha, "Diffusion α", color = color.new(persistCol, 0), linewidth = 2)
pBase  = plot(1.0, "Random walk (α=1)", color = color.new(color.gray, 40), linewidth = 1)
fill(pAlpha, pBase, color = color.new(persistCol, 82), title = "Persistence deviation")

plot(aTrend,  "Trending guide",  color = color.new(colTr, 70), style = plot.style_line)
plot(aRevert, "Reverting guide", color = color.new(colRv, 70), style = plot.style_line)

bgcolor(showBg ? color.new(structCol, 92) : na, title = "Structure tint")

// ============================================================================
//  09 · ALERTS
//  These fire on TRANSITIONS, not on state, so they signal a change in the
//  reading rather than repeating every bar. Named conditions appear in the
//  alert dropdown; the dynamic alert() carries the full four-axis read - to
//  use it, create an alert and select "Any alert() function call".
// ============================================================================
toStructured = structTxt == "structured" and structTxt[1] != "structured"
toNoise      = structTxt == "noise"      and structTxt[1] != "noise"
toTrending   = persistTxt == "trending"  and persistTxt[1] != "trending"
toReverting  = persistTxt == "reverting" and persistTxt[1] != "reverting"
toRandomWalk = persistTxt == "random-walk" and persistTxt[1] != "random-walk"
tailsCluster = tailTxt == "clustered" and tailTxt[1] != "clustered"
tailsIsolate = tailTxt == "isolated"  and tailTxt[1] != "isolated"
anyChange    = structTxt != structTxt[1] or persistTxt != persistTxt[1] or tailTxt != tailTxt[1]

alertcondition(toStructured, "Structure -> structured", "MRL: tape became structured (more readable)")
alertcondition(toNoise,      "Structure -> noise",      "MRL: tape became noise-like (less readable)")
alertcondition(toTrending,   "Persistence -> trending", "MRL: motion turned super-diffusive (trending)")
alertcondition(toReverting,  "Persistence -> reverting","MRL: motion turned sub-diffusive (mean-reverting)")
alertcondition(toRandomWalk, "Persistence -> random walk","MRL: motion returned to random-walk scaling")
alertcondition(tailsCluster, "Tails -> clustered",      "MRL: extreme moves began clustering (burst gap risk)")
alertcondition(tailsIsolate, "Tails -> isolated",       "MRL: extreme moves became independent again")
alertcondition(anyChange,    "Any regime change",       "MRL: regime reading changed on {{ticker}} {{interval}}")

if anyChange
    alert("MRL " + syminfo.ticker + " " + timeframe.period + ": " + stanceTxt +
          "  | a " + str.tostring(alpha, "#.##") +
          " | theta " + str.tostring(theta, "#.##"), alert.freq_once_per_bar_close)

// ============================================================================
//  10 · EXP_ BUS
// ============================================================================
plot(cecpH,    "EXP_Entropy",    display = display.data_window)
plot(cecpC,    "EXP_Complexity", display = display.data_window)
plot(alpha,    "EXP_Alpha",      display = display.data_window)
plot(theta,    "EXP_Theta",      display = display.data_window)
plot(mfptTgt,  "EXP_TimeTgt",    display = display.data_window)
plot(mfptStop, "EXP_TimeStop",   display = display.data_window)
plot(pNull,    "EXP_NullPTgt",   display = display.data_window)

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

var table tbl = table.new(pos, 2, 9, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 40))

if barstate.islast
    hdrCol = darkBG ? color.new(color.gray, 62) : color.new(color.gray, 78)
    labCol = darkBG ? color.new(color.gray, 88) : color.new(color.gray, 92)

    table.cell(tbl, 0, 0, "MARKET REGIME LENS", text_color = txtCol, text_size = size.small, bgcolor = hdrCol)
    table.cell(tbl, 1, 0, str.tostring(timeframe.period), text_color = txtCol, text_size = size.small, bgcolor = hdrCol)

    // headline read — strongest tint, colored by structure class
    table.cell(tbl, 0, 1, "Read", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 1, stanceTxt, text_color = darkBG ? color.white : color.black, text_size = size.small, bgcolor = color.new(structCol, darkBG ? 45 : 55))

    structDetail = (adaptive ? "rank " + str.tostring(cRank, "#") : "C " + str.tostring(cecpC, "#.###")) + " · H " + str.tostring(cecpH, "#.##")
    table.cell(tbl, 0, 2, "Structure", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 2, structTxt + "  (" + structDetail + ")", text_color = f_ink(structCol), text_size = size.small, bgcolor = f_tint(structCol))

    table.cell(tbl, 0, 3, "Persistence", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 3, persistTxt + "  (α " + str.tostring(alpha, "#.##") + ")", text_color = f_ink(persistCol), text_size = size.small, bgcolor = f_tint(persistCol))

    table.cell(tbl, 0, 4, "Tail (θ)", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 4, str.tostring(theta, "#.##") + "  " + tailTxt, text_color = f_ink(tailCol), text_size = size.small, bgcolor = f_tint(tailCol))

    timeTxt = na(mfptTgt) ? "—" : "~" + str.tostring(math.round(mfptTgt)) + " / ~" + str.tostring(math.round(mfptStop)) + " bars"
    table.cell(tbl, 0, 5, "Time tgt/stop", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 5, timeTxt, text_color = txtCol, text_size = size.small, bgcolor = f_tint(colTime))

    // null odds: green when the R itself gives you better-than-even odds, amber otherwise
    pCol = na(pNull) ? colNs : pNull >= 0.5 ? colTr : colWarn
    table.cell(tbl, 0, 6, "Null P(target)", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 6, na(pNull) ? "—" : str.tostring(pNull * 100, "#.#") + "%  @ " + str.tostring(rRatio, "#.##") + "R", text_color = f_ink(pCol), text_size = size.small, bgcolor = f_tint(pCol))

    table.cell(tbl, 0, 7, "Levels", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 7, linkTxt, text_color = f_ink(linkCol), text_size = size.small, bgcolor = f_tint(linkCol))

    table.cell(tbl, 0, 8, "Note", text_color = txtCol, text_size = size.small, bgcolor = labCol)
    table.cell(tbl, 1, 8, "context, not direction", text_color = txtCol, text_size = size.small)
````
