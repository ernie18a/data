# Pattern Analog Projection

- url: https://www.tradingview.com/script/kMVtQIrz-Pattern-Analog-Projection/
- type: indicator
- pine_id: PUB;1a6994815adc4cfdaf22e3aa1aeea7f2
- version: 1.0

## Description

Pattern Analog Projection

OVERVIEW
This tool searches historical price action for the sequences that most closely
resemble the current market structure, then projects what typically followed
those analogous sequences. It is a context and probability tool, not a buy/sell
signal generator.

HOW IT WORKS
- Shape matching: the last N bars are compared against historical windows using
  Pearson correlation, which is invariant to price level and scale. This compares
  pattern geometry rather than absolute prices.
- Volatility gating: candidates whose relative-volatility profile differs too much
  from the current window are rejected, so analogs share a similar character.
- Top analogs: the best non-overlapping matches are ranked and stored (up to 5).
- Forecast cone: the future paths that followed each analog are aggregated. The
  dashed center line is the average projection; the shaded envelope spans the most
  bullish and most bearish analog outcomes.
- Probability: the share of analogs that finished bullish, bearish, or neutral
  over the projection horizon.
- Confidence: a 0-100 score (graded A+ to C) combining match quality, directional
  agreement, and outcome consistency.
- Market regime: the current structure is classified (Strong Trend, Trending,
  Range, Compression, Volatile Expansion) using an efficiency ratio and ATR.

INPUTS
- Pattern Length, Projection Length, Search Depth, Search Step
- Number of Analogs, Min Correlation Filter, Forecast Mode (Average / Best / Median)
- Volatility Matching and tolerance, Neutral Band
- Toggles for cone, historical analogs, similarity heatmap, dashboard
- Dashboard position and colors

HOW TO USE
1. Add to any symbol and timeframe; load plenty of history for better matches.
2. Read the Confidence grade first. Treat low-confidence forecasts with caution.
3. Use the cone as a likely-path context, combined with your own trade plan and
   risk management - not as a standalone entry trigger.
4. The highlighted region shows the closest historical analog for reference.

NOTES
- The projection re-derives as each new bar closes. It draws forward only and does
  not repaint historical bars; there are no historical signals to restate.
- Heavy calculation runs on the last bar. If you see a loop-timeout, lower Search
  Depth or raise Search Step.
- Past structural resemblance does not guarantee future outcomes. This script is
  for research and education only and is not financial advice.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//   PATTERN ANALOG PROJECTION
//   ──────────────────────────────────────────────────────────────────────────
//   Institutional-style structural forecasting.
//   • Z-score / Pearson shape matching across history (scale & level invariant)
//   • Top-5 non-overlapping analog database, volatility-gated
//   • Multi-analog forecast: average center + bull/bear cone envelope
//   • Probability + Confidence-grade + Market-regime engines
//   • Subtle similarity heatmap, clean premium dashboard
//   ──────────────────────────────────────────────────────────────────────────
//   Heavy work runs only on the last confirmed bar. No lookahead, no future
//   leaks. The forecast re-derives as each new bar closes (it is a projection,
//   not a historical signal, so it does not repaint prior bars).
//   For research/education only — not investment advice.
// ════════════════════════════════════════════════════════════════════════════
indicator("Pattern Analog Projection", overlay = true, max_polylines_count = 12, max_boxes_count = 30, max_labels_count = 30)

// ─────────────────────────────── INPUTS ────────────────────────────────────
gA = "Analog Engine"
patLen   = input.int(30, "Pattern Length", minval = 8, maxval = 200, group = gA, tooltip = "How many recent bars define the shape to match.")
projLen  = input.int(15, "Projection Length", minval = 3, maxval = 100, group = gA)
maxBack  = input.int(800, "Search Depth (bars)", minval = 100, maxval = 4000, group = gA, tooltip = "Lower this if you hit a 'loop too long' error.")
srchStep = input.int(1, "Search Step", minval = 1, maxval = 5, group = gA, tooltip = "Raise to 2-3 to speed up on slow charts.")
nAnalog  = input.int(5, "Number of Analogs", minval = 1, maxval = 5, group = gA)
corrMin  = input.float(0.3, "Min Correlation Filter", minval = 0, maxval = 1, step = 0.05, group = gA)
fcMode   = input.string("Average", "Forecast Mode", options = ["Average", "Best Match", "Median"], group = gA)

gM = "Matching Filters"
volMatch = input.bool(true, "Volatility Matching", group = gM, tooltip = "Only accept analogs with a similar relative-volatility profile.")
volTol   = input.float(0.5, "Volatility Tolerance", minval = 0.1, maxval = 2.0, step = 0.1, group = gM)
neuBand  = input.float(0.15, "Neutral Band %", minval = 0, step = 0.05, group = gM, tooltip = "Outcomes within ±this % count as Neutral.")

gD = "Display"
showCone   = input.bool(true, "Show Forecast Cone", group = gD)
showAnalog = input.bool(true, "Show Historical Analogs", group = gD)
showHeat   = input.bool(true, "Show Similarity Heatmap", group = gD)
showStats  = input.bool(true, "Show Dashboard", group = gD)
dashPos    = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gD)

gS = "Style"
upCol  = input.color(#26a69a, "Bull", group = gS)
dnCol  = input.color(#ef5350, "Bear", group = gS)
midCol = input.color(#42a5f5, "Center Line", group = gS)
accent = input.color(#7e57c2, "Analog Accent", group = gS)

// ─────────────────────────── HELPER FUNCTIONS ──────────────────────────────
// Pearson correlation between current window [0..n-1] and candidate [k..k+n-1].
// Pearson is invariant to level and scale → equivalent to z-score shape match.
f_corr(int k, int n) =>
    float sa = 0.0, float sb = 0.0, float saa = 0.0, float sbb = 0.0, float sab = 0.0
    for i = 0 to n - 1
        a = close[i]
        b = close[k + i]
        sa  += a
        sb  += b
        saa += a * a
        sbb += b * b
        sab += a * b
    cov = sab - sa * sb / n
    va  = saa - sa * sa / n
    vb  = sbb - sb * sb / n
    den = math.sqrt(va * vb)
    den != 0 ? cov / den : 0.0

// Mean / std of a window → used for volatility (coefficient of variation) gating.
f_meanstd(int k, int n) =>
    float s = 0.0, float ss = 0.0
    for i = 0 to n - 1
        v = close[k + i]
        s  += v
        ss += v * v
    m  = s / n
    sd = math.sqrt(math.max(ss / n - m * m, 0.0))
    [m, sd]

// Highest / lowest close inside a window (for the analog highlight box).
f_winHL(int k, int n) =>
    float hi = close[k]
    float lo = close[k]
    for i = 0 to n - 1
        v = close[k + i]
        hi := math.max(hi, v)
        lo := math.min(lo, v)
    [hi, lo]

f_dashPos() =>
    switch dashPos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

// ───────────────────────── MARKET REGIME (global) ──────────────────────────
absChg = math.abs(close - close[1])
chgSum = math.sum(absChg, patLen)
netMv  = math.abs(close - close[patLen])
er     = chgSum != 0 ? netMv / chgSum : 0.0          // Kaufman efficiency ratio
atrV   = ta.atr(14)
atrAvg = ta.sma(atrV, 50)
volExp = atrAvg != 0 ? atrV / atrAvg : 1.0

regime = er > 0.6 ? "Strong Trend" : er > 0.4 ? "Trending" : volExp > 1.4 ? "Volatile Expansion" : (er < 0.25 and volExp < 0.9) ? "Compression" : "Range"
regCol = er > 0.4 ? (close > close[patLen] ? upCol : dnCol) : volExp > 1.4 ? #ffb300 : color.gray

// ──────────────────────────── OBJECT HOLDERS ───────────────────────────────
var polyline[] gPoly = array.new<polyline>()
var box[]      gBox  = array.new<box>()
var label[]    gLab  = array.new<label>()

// persisted dashboard values
var float vBest = na, var float vAvgC = na, var float vConf = na
var string vGrade = na, var float vBull = na, var float vBear = na, var float vNeu = na
var float vExp = na, var float vWin = na, var float vFvol = na, var int vN = 0

// ════════════════════════════ MAIN (last bar) ══════════════════════════════
if barstate.islast
    // clear previous drawings
    for p in gPoly
        polyline.delete(p)
    array.clear(gPoly)
    for b in gBox
        box.delete(b)
    array.clear(gBox)
    for l in gLab
        label.delete(l)
    array.clear(gLab)

    // template volatility profile (coefficient of variation)
    [tMean, tStd] = f_meanstd(0, patLen)
    tCV = tMean != 0 ? tStd / tMean : 0.0

    // ── scan history, collect qualifying candidates ──
    kStart = patLen + projLen
    effMax = math.min(maxBack, bar_index - patLen - projLen - 1)
    ks = array.new<int>()
    cs = array.new<float>()
    if effMax > kStart
        k = kStart
        while k <= effMax
            c = f_corr(k, patLen)
            keep = c >= corrMin
            if keep and volMatch
                [cm, csd] = f_meanstd(k, patLen)
                cCV = cm != 0 ? csd / cm : 0.0
                keep := tCV != 0 ? math.abs(cCV - tCV) / tCV <= volTol : true
            if keep
                array.push(ks, k)
                array.push(cs, c)
            k += srchStep

    // ── rank and greedily pick top-N non-overlapping analogs ──
    selK = array.new<int>()
    selC = array.new<float>()
    if array.size(cs) > 0
        ord = array.sort_indices(cs, order.descending)
        oi = 0
        while oi < array.size(ord) and array.size(selK) < nAnalog
            idx = array.get(ord, oi)
            kk  = array.get(ks, idx)
            cc  = array.get(cs, idx)
            overlap = false
            for sk in selK
                if math.abs(kk - sk) < patLen
                    overlap := true
                    break
            if not overlap
                array.push(selK, kk)
                array.push(selC, cc)
            oi += 1

    nSel = array.size(selK)

    if nSel > 0
        // ── aggregate projection paths (ratio space) ──
        sumR = array.new<float>(projLen + 1, 0.0)
        minR = array.new<float>(projLen + 1, 1e12)
        maxR = array.new<float>(projLen + 1, -1e12)
        finalRet = array.new<float>()
        sumCorr = 0.0
        for s = 0 to nSel - 1
            kk = array.get(selK, s)
            anc = close[kk]
            for j = 0 to projLen
                r = anc != 0 ? close[kk - j] / anc : 1.0
                array.set(sumR, j, array.get(sumR, j) + r)
                if r < array.get(minR, j)
                    array.set(minR, j, r)
                if r > array.get(maxR, j)
                    array.set(maxR, j, r)
            array.push(finalRet, (anc != 0 ? close[kk - projLen] / anc : 1.0) - 1.0)
            sumCorr += array.get(selC, s)

        // center path source by forecast mode
        medK = -1
        if fcMode == "Median"
            fOrd = array.sort_indices(finalRet, order.ascending)
            medK := array.get(selK, array.get(fOrd, math.floor(nSel / 2)))
        centerK = fcMode == "Best Match" ? array.get(selK, 0) : fcMode == "Median" ? medK : -1

        // ── probability + statistics ──
        band = neuBand / 100.0
        bull = 0, bear = 0, neu = 0
        sumRet = 0.0, maxRet = -1e12, minRet = 1e12, wins = 0
        for fr in finalRet
            if fr > band
                bull += 1
            else if fr < -band
                bear += 1
            else
                neu += 1
            sumRet += fr
            maxRet := math.max(maxRet, fr)
            minRet := math.min(minRet, fr)
            wins += fr > 0 ? 1 : 0
        avgRet = sumRet / nSel
        // forecast volatility (std of outcomes)
        varRet = 0.0
        for fr in finalRet
            varRet += (fr - avgRet) * (fr - avgRet)
        fVol = math.sqrt(varRet / nSel)

        avgCorr   = sumCorr / nSel
        dirAgree  = math.max(bull, bear) / nSel
        consist   = 1.0 - math.min(fVol / 0.03, 1.0)
        conf      = math.round(math.max(math.min((avgCorr * 0.4 + dirAgree * 0.3 + consist * 0.3) * 100, 100), 0))
        grade     = conf >= 85 ? "A+" : conf >= 75 ? "A" : conf >= 65 ? "B+" : conf >= 55 ? "B" : "C"

        // persist for dashboard
        vBest := array.get(selC, 0)
        vAvgC := avgCorr
        vConf := conf
        vGrade := grade
        vBull := bull / nSel * 100
        vBear := bear / nSel * 100
        vNeu  := neu / nSel * 100
        vExp  := avgRet * 100
        vWin  := wins / nSel * 100
        vFvol := fVol * 100
        vN    := nSel

        // ── SIMILARITY HEATMAP (subtle box over the analysed window) ──
        if showHeat
            [hh, ll] = f_winHL(0, patLen)
            bc = vBest >= 0.85 ? color.new(upCol, 90) : vBest >= 0.65 ? color.new(#ffb300, 92) : color.new(dnCol, 92)
            array.push(gBox, box.new(bar_index - patLen + 1, hh, bar_index, ll, border_color = na, bgcolor = bc))

        // ── HISTORICAL ANALOG HIGHLIGHT ──
        if showAnalog
            for s = 0 to nSel - 1
                kk = array.get(selK, s)
                [whi, wlo] = f_winHL(kk, patLen)
                lx = bar_index - (kk + patLen - 1)
                rx = bar_index - kk
                a = s == 0 ? 82 : 92
                array.push(gBox, box.new(lx, whi, rx, wlo, border_color = color.new(accent, s == 0 ? 25 : 70), bgcolor = color.new(accent, a)))
                if s == 0
                    array.push(gLab, label.new(lx, whi, "▶ analog start", style = label.style_label_down, color = color.new(accent, 0), textcolor = color.white, size = size.tiny))
                    array.push(gLab, label.new(rx, whi, "analog end ■", style = label.style_label_down, color = color.new(accent, 0), textcolor = color.white, size = size.tiny))

        // ── FORECAST CONE ──
        if showCone
            ptsC = array.new<chart.point>()
            ptsU = array.new<chart.point>()
            ptsL = array.new<chart.point>()
            for j = 0 to projLen
                x = bar_index + j
                cr = centerK > 0 ? (close[centerK] != 0 ? close[centerK - j] / close[centerK] : 1.0) : array.get(sumR, j) / nSel
                array.push(ptsC, chart.point.from_index(x, close * cr))
                array.push(ptsU, chart.point.from_index(x, close * array.get(maxR, j)))
                array.push(ptsL, chart.point.from_index(x, close * array.get(minR, j)))

            // filled envelope (upper forward + lower backward)
            poly = array.new<chart.point>()
            for j = 0 to projLen
                array.push(poly, array.get(ptsU, j))
            for j = projLen to 0
                array.push(poly, array.get(ptsL, j))
            leanUp = avgRet >= 0
            array.push(gPoly, polyline.new(poly, closed = true, xloc = xloc.bar_index, line_color = na, fill_color = color.new(leanUp ? upCol : dnCol, 90)))
            array.push(gPoly, polyline.new(ptsU, closed = false, xloc = xloc.bar_index, line_color = color.new(upCol, 45), line_width = 1))
            array.push(gPoly, polyline.new(ptsL, closed = false, xloc = xloc.bar_index, line_color = color.new(dnCol, 45), line_width = 1))
            array.push(gPoly, polyline.new(ptsC, closed = false, xloc = xloc.bar_index, line_color = color.new(midCol, 0), line_width = 2, line_style = line.style_dashed))

            tgt = close * (array.get(sumR, projLen) / nSel)
            array.push(gLab, label.new(bar_index + projLen, tgt, str.tostring(math.round(vBull)) + "% bull  →  " + str.tostring(tgt, format.mintick), style = label.style_label_left, color = color.new(leanUp ? upCol : dnCol, 0), textcolor = color.white, size = size.small))
    else
        vN := 0

// ═══════════════════════════ PREMIUM DASHBOARD ═════════════════════════════
var table dash = table.new(f_dashPos(), 2, 17, border_width = 1, border_color = color.new(color.gray, 70), frame_width = 1, frame_color = color.new(color.gray, 60))

f_hdr(int r, string t, color bg) =>
    table.cell(dash, 0, r, t, text_color = color.white, bgcolor = bg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, "", bgcolor = bg)
f_row(int r, string k, string v, color vbg) =>
    table.cell(dash, 0, r, k, text_color = color.new(color.white, 15), bgcolor = color.new(#1b1b27, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = color.white, bgcolor = vbg, text_size = size.small, text_halign = text.align_right)

if showStats and barstate.islast
    found = vN > 0
    gc = vGrade == "A+" or vGrade == "A" ? upCol : vGrade == "B+" or vGrade == "B" ? #ffb300 : dnCol
    cc = na(vConf) ? color.gray : vConf >= 75 ? upCol : vConf >= 55 ? #ffb300 : dnCol
    dark = color.new(#13131c, 0)
    sep  = color.new(#1b1b27, 0)

    f_hdr(0, "  PATTERN ANALOG PROJECTION", color.new(accent, 0))
    f_row(1, "Best Match",   found ? str.tostring(math.round(vBest * 100)) + "%" : "—", dark)
    f_row(2, "Top-" + str.tostring(vN) + " Avg",  found ? str.tostring(math.round(vAvgC * 100)) + "%" : "—", dark)
    f_row(3, "Confidence",   found ? str.tostring(vConf) + " / 100" : "—", color.new(cc, 20))
    f_row(4, "Grade",        found ? vGrade : "—", color.new(gc, 0))
    f_hdr(5, "  PROBABILITY", sep)
    f_row(6, "Bull",         found ? str.tostring(math.round(vBull)) + "%" : "—", color.new(upCol, 25))
    f_row(7, "Bear",         found ? str.tostring(math.round(vBear)) + "%" : "—", color.new(dnCol, 25))
    f_row(8, "Neutral",      found ? str.tostring(math.round(vNeu)) + "%" : "—", color.new(color.gray, 25))
    f_hdr(9, "  CONTEXT", sep)
    f_row(10, "Regime",      regime, color.new(regCol, 20))
    f_row(11, "Exp. Move",   found ? (vExp >= 0 ? "+" : "") + str.tostring(vExp, "0.00") + "%" : "—", color.new(vExp >= 0 ? upCol : dnCol, 25))
    f_row(12, "Win Rate",    found ? str.tostring(math.round(vWin)) + "%" : "—", dark)
    f_row(13, "Forecast Vol",found ? str.tostring(vFvol, "0.00") + "%" : "—", dark)
    f_row(14, "Samples",     str.tostring(vN), dark)
    f_row(15, "Projection",  str.tostring(projLen) + " bars", dark)
    f_row(16, "Quality",     found ? (vBest >= 0.85 ? "High" : vBest >= 0.65 ? "Moderate" : "Low") : "—", dark)
````
