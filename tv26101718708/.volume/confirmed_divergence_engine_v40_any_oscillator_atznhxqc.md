# Confirmed Divergence Engine v4.0 - Any Oscillator

- url: https://www.tradingview.com/script/aTznhxQc-Confirmed-Divergence-Engine-v4-0-Any-Oscillator/
- type: indicator
- pine_id: PUB;31ed178405b446058169c4d24513c54a
- version: 1.0

## Description

CONFIRMED DIVERGENCE ENGINE v4.0 · Any Oscillator

[b]WHAT THIS DOES [/b]

This is a divergence detector built around one rule: a signal prints exactly once, at the close of its confirmation bar, and can never move, repaint, or vanish. It finds regular (reversal) and hidden (continuation) divergences between price and virtually any oscillator, then forces every candidate through an eight-stage quality pipeline before anything reaches your chart. Most candidates die in the pipeline. What survives is scored 0–100, and only the best-scoring pair is drawn.

The indicator sits on the price chart (overlay). Divergence lines and labels are drawn on price; the oscillator itself is computed internally and is not plotted. If you want to see the oscillator, add it as its own pane — or run this engine in External mode directly against any oscillator already on your chart.
[b]
QUICK START[/b]

Add the indicator to any symbol and timeframe. Defaults = RSI(14), regular divergences only, adaptive zone filter.
Wait for a small triangle above or below a bar. That triangle is the signal bar — the bar where the divergence was confirmed on close.
Hover the R/H label at the pivot to see the full quality breakdown (score, oscillator delta, swing size, span, percentile rank).
Optional: create an alert on the indicator with trigger "Once Per Bar Close" (see ALERTS below).

[b]THE NON-REPAINTING MODEL — READ THIS FIRST [/b]

A pivot only exists after "Pivot right bars" fully CLOSED bars have printed beyond it, and all detection runs strictly on the closing update of the bar. Nothing is evaluated intrabar, so nothing can flicker in and out, and a signal that appears is permanent.
The honest consequence: every signal carries a fixed structural delay of "Pivot right bars" bars (default 1). Zero-lag and non-repainting pivots cannot coexist in the same tool — any divergence indicator that shows you signals "at the pivot" in real time is repainting.
Each signal draws two things: – a dotted (regular) or dashed (hidden) line + label, placed back at the pivot for readability; – a small triangle on the bar where the signal actually FIRED (pivot bar + right bars).

Act on the triangle. Backtest on the triangle. When you scroll back through history the lines will look earlier than they were tradeable — that is cosmetic. The triangle is the truth.

 [b]REGULAR vs HIDDEN [/b]

Regular bullish: price makes a lower low, oscillator makes a higher low → potential reversal up.
Regular bearish: price makes a higher high, oscillator makes a lower high → potential reversal down.
Hidden bullish: price makes a higher low, oscillator makes a lower low → potential continuation up.
Hidden bearish: price makes a lower high, oscillator makes a higher high → potential continuation down.

Regular divergences are on by default; hidden are off. Hidden divergences bypass the overbought/oversold zone filter by design (they occur mid-trend, not at extremes) but still have to pass every other gate.

[b]THE QUALITY PIPELINE
[/b]
Every freshly confirmed pivot (P2) is tested against up to 20 stored earlier pivots (P1). A pair must pass ALL of the following before it can print:

[list]
[*]Classification — strict price/oscillator inequalities for regular or hidden, bullish or bearish.
[*]Span window — P1 and P2 must be between the min and max bar distance apart (default 5–60).
[*]Oscillator magnitude — the divergence must be at least X% of the oscillator's own recent range (default 3% over a 200-bar lookback). Scale-free, so it behaves identically on RSI and on OBV.
[*]Price separation (optional) — minimum distance between the two pivot prices, in ATR units. Off by default.
[*]Zone filter (regular divs only) — P1 must sit in an oscillator extreme. – Adaptive percentile (default): P1 must rank in the outer 5% of the oscillator's recent values, P2 in the outer 25%. Works on any oscillator, bounded or not. – Fixed levels: classic thresholds (30/70 etc.) for 0–100 style oscillators. – Off.
[*]Clean line-of-sight — no bar between the pivots may pierce the straight P1→P2 connecting line, on price OR on the oscillator. This is a true tangency test: "divergences" that price has already cut through are rejected.
[*]Swing prominence — price must have bounced at least X·ATR away between the two pivots (default 0.3). This kills flat, drifting pivot pairs that only look like divergence on the oscillator.
[*]Composite quality score (0–100) — weighted blend of divergence size, zone depth, swing quality, and price separation. Anything below "Min quality score" (default 55) is discarded. If several P1s survive, only the single best-scoring one is drawn (or the most recent valid one — your choice)
[/list].

[b] READING THE CHART
[/b]
Dotted line = regular divergence. Dashed line = hidden.
Label at the pivot: "R" or "H" plus the quality score. Hover it for the full breakdown — score, oscillator delta as % of range, swing size in ATR, span in bars, and P1 percentile rank.
Triangle at the confirmation bar: green/red for regular bull/bear, teal/orange for hidden bull/bear. This is the actionable bar.

[b]USING ANY OSCILLATOR (EXTERNAL MODE) [/b]

Eight engines are built in: RSI, Stochastic %K (smoothed), MACD histogram, CCI, MFI, Rate of Change, Williams %R, and OBV.

[b][i]To run the engine on anything else:
[/i][/b]
[i]Add your oscillator to the chart as its own indicator.
In this script's settings, set Oscillator = External.
Under "External oscillator plot", select the plot from your other indicator.

The engine treats it exactly like a native oscillator. For unbounded inputs (MACD histogram, OBV, volume deltas, custom composites), keep the zone filter on Adaptive percentile — fixed levels assume a 0–100 scale and will silently block signals otherwise.[/i]

[b]SETTINGS GUIDE[/b]

[b]1 · OSCILLATOR —[/b] engine selection. "Source" applies to RSI/ROC only; "Length" to everything except MACD and OBV; MACD has its own 12/26/9 inputs.

[b]2 · PIVOT STRUCTURE —[/b] "Pivot right bars" is the single most important input in the script: it is both your pivot reliability and your confirmation delay. 1 = fastest signals, noisier pivots; 2–3 = sturdier pivots, later signals. Min/Max span controls how far apart the two pivots may be; max span also caps every historical lookup, which is what keeps the script runtime-safe on any symbol and timeframe.

[b]3 · DIVERGENCE TYPES —[/b] toggle regular and hidden independently.

[b]4 · QUALITY FILTERS —[/b] the pipeline gates described above: zone mode and percentiles, line-of-sight toggle, minimum oscillator divergence, minimum price separation, minimum swing, minimum score, best-vs-most-recent selection, and the normalisation/ATR lookbacks.

[b]5 · DISPLAY —[/b] lines, labels, score-in-label, confirmation triangles, and the four signal colours.

[b]ALERTS [/b]Create an alert on the chart → Condition = this indicator → choose one of:

[list]
[*]Regular Bullish Divergence
[*]Regular Bearish Divergence
[*]Hidden Bullish Divergence
[*]Hidden Bearish Divergence
[*]Any Divergence
[/list]

Set the trigger to "Once Per Bar Close". Detection is already gated on bar confirmation internally, so alerts can never fire on an unconfirmed intrabar state. There is also a dynamic alert() message (use "Any alert() function call") that includes the ticker, timeframe, divergence type, and score.

[i] [b]TUNING RECIPES [/b]
Too few signals → lower Min quality score to 40–45, widen "P1 in outer %" to 10–15, enable hidden divergences, or reduce Min swing to 0.1–0.2 ATR.
Too many / low quality → raise Min score to 65+, raise right bars to 2–3, tighten P1 percentile to 3, or raise the minimum oscillator divergence.
Higher timeframes / swing trading → widen Max span (100–150) and the normalisation lookback (300+) so "recent range" reflects the regime you trade.
MACD histogram, OBV, or any unbounded external plot → keep the zone filter on Adaptive.[/i]

[i][b]WHAT THIS IS NOT
[/b]Divergence is exhaustion context, not a trading system. This tool tells you that momentum and price disagreed at a confirmed structural point, with a measurable quality score — it does not predict reversals, and no filter stack can make a counter-trend signal safe on its own. Combine it with market structure, levels, and higher-timeframe context, and size accordingly. The confirmation delay is deliberate: it is the price of signals you can actually trust in a backtest.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NotLazyBear

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cmo22

//@version=6

// ─────────────────────────────────────────────────────────────────────────────
//  CONFIRMED DIVERGENCE ENGINE v4.0 · any oscillator
// ─────────────────────────────────────────────────────────────────────────────
//  Full ground-up rewrite of "Advanced Confirmed Divergence Strategy v3.2".
//
//  NON-REPAINTING MODEL
//  • A pivot only exists after `Pivot right bars` fully CLOSED bars have
//    printed beyond it, and all detection runs strictly on barstate.isconfirmed
//    (the closing update of the bar). A signal therefore appears exactly once,
//    at the close of its confirmation bar, and can never move or vanish.
//  • Honest consequence: every signal carries a fixed structural delay of
//    `Pivot right bars` bars. Zero-lag + non-repainting pivots cannot coexist.
//    The dotted line/label is drawn back at the pivot for readability; the
//    small triangle marker shows the bar where the signal actually FIRED —
//    use that bar for entries and backtests.
//
//  ANY OSCILLATOR
//  • Native engine: RSI, Stochastic %K, MACD histogram, CCI, MFI, ROC,
//    Williams %R, OBV.
//  • External mode: add any oscillator to your chart, set Oscillator=External,
//    then pick its plot under "External oscillator plot". Unbounded
//    oscillators (MACD, OBV, volume deltas…) are handled because the zone
//    filter can run on percentile rank instead of fixed levels.
//
//  QUALITY PIPELINE (every gate must pass before a signal prints)
//    1. Regular / hidden classification with strict price & osc inequality
//    2. Span window (min/max bars between P1 and P2)
//    3. Minimum oscillator divergence, as % of the oscillator's recent range
//    4. Optional minimum price separation between pivots (ATR units)
//    5. Zone filter — adaptive percentile / fixed levels / off
//    6. Clean line-of-sight: every intermediate low/high AND oscillator value
//       must stay on the correct side of the P1→P2 line (true tangency test)
//    7. Swing prominence: price must have bounced ≥ x·ATR between the pivots
//    8. Composite quality score 0–100; only the best-scoring P1 is drawn
//
//  FIXED vs v3.2
//  • v3.2 set `rsi := src`, so with default inputs it compared price against
//    itself and could never signal. v4 computes real oscillators natively
//    (or takes an external plot).
//  • v3.2's "no intersection" test only looked for a SIGN FLIP of the
//    deviation between interior bars — a pair whose interior bars all sat on
//    the wrong side of the line (a full cross-under) passed the test. v4
//    enforces true tangency: no interior bar may pierce the line at all.
//  • v3.2 looked up unbounded history (any of 50 stored pivots, arbitrarily
//    old) → potential runtime buffer errors. v4 caps the pivot span and
//    declares max_bars_back explicitly.
//  • v3.2 drew a line from P2 to EVERY qualifying stored pivot (spray).
//    v4 evaluates all candidates and keeps only the best match.
//  • v3.2 could flicker intrabar on the live bar. v4 gates everything on
//    barstate.isconfirmed.
//
//  ALERTS
//  • Create alerts with "Once Per Bar Close". Four typed alertconditions plus
//    one "Any Divergence" condition and a dynamic alert() message with scores.
//
//  NOTE: the compiler may warn that scan()/drawDiv() "should be called on
//  every bar". This is expected and safe here — the functions hold no
//  stateful ta.* calls; they only index global series, whose history is
//  maintained globally on every bar.
// ─────────────────────────────────────────────────────────────────────────────

indicator("Confirmed Divergence Engine v4.0 · Any Oscillator",
     shorttitle = "DivEngine v4",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_bars_back = 500)

// ═════════════════════════ 1 · OSCILLATOR ENGINE ═════════════════════════════
string G1 = "1 · Oscillator"
string OSC_RSI  = "RSI"
string OSC_STO  = "Stochastic %K"
string OSC_MACD = "MACD Histogram"
string OSC_CCI  = "CCI"
string OSC_MFI  = "MFI"
string OSC_ROC  = "Rate of Change"
string OSC_WPR  = "Williams %R"
string OSC_OBV  = "OBV"
string OSC_EXT  = "External"

oscType  = input.string(OSC_RSI, "Oscillator", options = [OSC_RSI, OSC_STO, OSC_MACD, OSC_CCI, OSC_MFI, OSC_ROC, OSC_WPR, OSC_OBV, OSC_EXT], group = G1)
oscSrcIn = input.source(close, "Source (RSI / ROC only)", group = G1)
oscLen   = input.int(14, "Length (all except MACD / OBV)", minval = 1, group = G1)
macdFast = input.int(12, "MACD fast", minval = 1, group = G1, inline = "macd")
macdSlow = input.int(26, "slow", minval = 1, group = G1, inline = "macd")
macdSig  = input.int(9, "signal", minval = 1, group = G1, inline = "macd")
extOsc   = input.source(close, "External oscillator plot", group = G1, tooltip = "Set Oscillator = External, then select any plot from another indicator already on your chart. The engine treats it exactly like a native oscillator.")

// All oscillators are computed unconditionally on every bar (required for
// consistent internal state of ta.* functions), then one is selected.
oscRsi = ta.rsi(oscSrcIn, oscLen)
oscSto = ta.sma(ta.stoch(close, high, low, oscLen), 3)
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
oscCci = ta.cci(hlc3, oscLen)
oscMfi = ta.mfi(hlc3, oscLen)
oscRoc = ta.roc(oscSrcIn, oscLen)
oscWpr = ta.wpr(oscLen)

float osc = switch oscType
    OSC_RSI  => oscRsi
    OSC_STO  => oscSto
    OSC_MACD => macdHist
    OSC_CCI  => oscCci
    OSC_MFI  => oscMfi
    OSC_ROC  => oscRoc
    OSC_WPR  => oscWpr
    OSC_OBV  => ta.obv
    => extOsc

// ═════════════════════════ 2 · PIVOT STRUCTURE ═══════════════════════════════
string G2 = "2 · Pivot structure"
leftBars  = input.int(3, "Pivot left bars", minval = 1, maxval = 50, group = G2)
rightBars = input.int(1, "Pivot right bars (confirmation delay)", minval = 1, maxval = 20, group = G2, tooltip = "Higher = more reliable pivots, later signals. The signal always fires exactly this many bars after the pivot — this is the unavoidable price of non-repainting.")
minSpan   = input.int(5, "Min bars between P1 and P2", minval = 2, group = G2)
maxSpan   = input.int(60, "Max bars between P1 and P2", minval = 5, maxval = 300, group = G2, tooltip = "Also bounds all historical lookups, which is what makes the script runtime-safe on any symbol/timeframe.")
maxPivots = input.int(20, "Max stored pivots per side", minval = 2, maxval = 100, group = G2)

// ═════════════════════════ 3 · DIVERGENCE TYPES ══════════════════════════════
string G3 = "3 · Divergence types"
showRegular = input.bool(true, "Regular divergences (reversal)", group = G3)
showHidden  = input.bool(false, "Hidden divergences (continuation)", group = G3, tooltip = "Hidden divs bypass the OB/OS zone filter by design; they are still subject to line-of-sight, swing, magnitude and score gates.")

// ═════════════════════════ 4 · QUALITY FILTERS ═══════════════════════════════
string G4 = "4 · Quality filters"
string Z_ADAPT = "Adaptive percentile (any oscillator)"
string Z_FIXED = "Fixed levels"
string Z_OFF   = "Off"
zoneMode = input.string(Z_ADAPT, "OB/OS zone filter (regular divs only)", options = [Z_ADAPT, Z_FIXED, Z_OFF], group = G4)
pctP1 = input.float(5, "Adaptive: P1 in outer …%", minval = 1, maxval = 50, group = G4, tooltip = "Bullish: P1 percentile-rank must be ≤ this. Bearish: ≥ 100 minus this. Scale-free, so it works on RSI, MACD histogram, OBV — anything.")
pctP2 = input.float(25, "Adaptive: P2 in outer …%", minval = 1, maxval = 60, group = G4)
fixOS1 = input.float(30, "Fixed: P1 oversold <", group = G4, inline = "fx1")
fixOB1 = input.float(70, "P1 overbought >", group = G4, inline = "fx1")
fixOS2 = input.float(50, "Fixed: P2 oversold <", group = G4, inline = "fx2")
fixOB2 = input.float(50, "P2 overbought >", group = G4, inline = "fx2", tooltip = "Fixed levels assume a 0–100 style oscillator (RSI / Stoch / MFI). For anything else use Adaptive.")
useLOS = input.bool(true, "Clean line-of-sight (price AND oscillator)", group = G4, tooltip = "Rejects the pair if any bar between the pivots pierces the P1→P2 connecting line, on price or on the oscillator. True tangency test.")
minOscDeltaPct = input.float(10, "Min oscillator divergence (% of its recent range)", minval = 0, step = 0.5, group = G4)
minPriceATR    = input.float(0, "Min price separation between pivots (ATR)", minval = 0, step = 0.1, group = G4)
minSwingATR    = input.float(0.3, "Min swing between pivots (ATR)", minval = 0, step = 0.1, group = G4, tooltip = "Price must have moved away at least this far between P1 and P2 — rejects flat, drifting pivot pairs that only look like divergence.")
minScore       = input.float(55, "Min quality score (0–100)", minval = 0, maxval = 100, group = G4)
string M_BEST   = "Best score"
string M_RECENT = "Most recent valid P1"
signalMode = input.string(M_BEST, "When several P1s qualify", options = [M_BEST, M_RECENT], group = G4)
normLen = input.int(200, "Normalisation lookback (range / percentile)", minval = 20, group = G4)
atrLen  = input.int(14, "ATR length", minval = 1, group = G4)

// ═════════════════════════ 5 · DISPLAY & ALERTS ══════════════════════════════
string G5 = "5 · Display"
showLines   = input.bool(true, "Divergence lines", group = G5)
showLabels  = input.bool(true, "Labels at the pivot", group = G5)
showScore   = input.bool(true, "Show score in label", group = G5)
showMarkers = input.bool(true, "Marker on the confirmation bar", group = G5, tooltip = "The triangle marks the bar on which the signal actually fired (pivot bar + right bars). This is the bar to act on.")
colRegBull = input.color(#00c853, "Reg bull", group = G5, inline = "cols")
colRegBear = input.color(#ff1744, "Reg bear", group = G5, inline = "cols")
colHidBull = input.color(#26c6da, "Hid bull", group = G5, inline = "cols")
colHidBear = input.color(#ff9100, "Hid bear", group = G5, inline = "cols")

// ═════════════════════════ CORE SERIES ═══════════════════════════════════════
atr      = ta.atr(atrLen)
oscHi    = ta.highest(osc, normLen)
oscLo    = ta.lowest(osc, normLen)
oscRange = math.max(oscHi - oscLo, 1e-10)
oscPrank = ta.percentrank(osc, normLen)

plPrice = ta.pivotlow(low, leftBars, rightBars)
phPrice = ta.pivothigh(high, leftBars, rightBars)

// ═════════════════════════ TYPES & STATE ═════════════════════════════════════
type Pivot
    int   bar
    float price
    float osc
    float prank

type DivHit
    bool   found = false
    Pivot  p1
    float  score
    string details

var array<Pivot> pivLows  = array.new<Pivot>()
var array<Pivot> pivHighs = array.new<Pivot>()

// ═════════════════════════ SCAN ══════════════════════════════════════════════
// Evaluates every stored P1 against the freshly confirmed P2 and returns the
// best regular and best hidden candidate that survive the full quality
// pipeline. Arrays are newest-first, so span grows monotonically and we can
// break as soon as it exceeds maxSpan (this also bounds every history lookup).
scan(bool isBull, array<Pivot> pivots, int p2bar, float p2price, float p2osc, float p2prank, float p2atr) =>
    DivHit reg = DivHit.new()
    DivHit hid = DivHit.new()
    float safeAtr = math.max(p2atr, syminfo.mintick)
    if array.size(pivots) > 0
        for p1 in pivots
            int span = p2bar - p1.bar
            if span < minSpan
                continue
            if span > maxSpan
                break

            // ── 1 · classification (strict inequalities) ─────────────────────
            bool isReg = isBull ? (p2price < p1.price and p2osc > p1.osc) : (p2price > p1.price and p2osc < p1.osc)
            bool isHid = isBull ? (p2price > p1.price and p2osc < p1.osc) : (p2price < p1.price and p2osc > p1.osc)
            if not ((isReg and showRegular) or (isHid and showHidden))
                continue

            // ── 2 · magnitude gates ──────────────────────────────────────────
            float dOsc = math.abs(p2osc - p1.osc)
            if dOsc < minOscDeltaPct / 100.0 * oscRange
                continue
            float dPrice = math.abs(p2price - p1.price)
            if dPrice < minPriceATR * safeAtr
                continue

            // ── 3 · zone gate (regular only) ─────────────────────────────────
            if isReg and zoneMode != Z_OFF
                bool zoneOK = false
                if zoneMode == Z_ADAPT
                    zoneOK := isBull ? (p1.prank <= pctP1 and p2prank <= pctP2) : (p1.prank >= 100.0 - pctP1 and p2prank >= 100.0 - pctP2)
                else
                    zoneOK := isBull ? (p1.osc < fixOS1 and p2osc < fixOS2) : (p1.osc > fixOB1 and p2osc > fixOB2)
                if not zoneOK
                    continue

            // ── 4 · line-of-sight + swing prominence (single interior walk) ──
            float pSlope = (p2price - p1.price) / span
            float oSlope = (p2osc - p1.osc) / span
            int   p1off  = bar_index - p1.bar
            bool  losOK  = true
            float bounce = isBull ? -1.0e18 : 1.0e18
            for j = 1 to span - 1
                int off = p1off - j
                float linP = p1.price + pSlope * j
                float linO = p1.osc + oSlope * j
                if isBull
                    if useLOS and (low[off] < linP or osc[off] < linO)
                        losOK := false
                        break
                    bounce := math.max(bounce, high[off])
                else
                    if useLOS and (high[off] > linP or osc[off] > linO)
                        losOK := false
                        break
                    bounce := math.min(bounce, low[off])
            if not losOK
                continue
            float swing = isBull ? bounce - math.max(p1.price, p2price) : math.min(p1.price, p2price) - bounce
            if swing < minSwingATR * safeAtr
                continue

            // ── 5 · composite quality score ──────────────────────────────────
            // sOsc   : divergence size vs the oscillator's own recent range
            // sZone  : depth of P1 in the extreme (percentile-based, scale-free)
            // sSwing : how real the bounce between the pivots was
            // sPrice : price separation between the pivots
            float sOsc   = math.min(dOsc / (0.25 * oscRange), 1.0)
            float sSwing = math.min(swing / (2.0 * safeAtr), 1.0)
            float sPrice = math.min(dPrice / (2.0 * safeAtr), 1.0)
            float score  = 0.0
            if isReg
                float sZone = isBull ? math.max(0.0, (25.0 - nz(p1.prank, 50.0)) / 25.0) : math.max(0.0, (nz(p1.prank, 50.0) - 75.0) / 25.0)
                score := 100.0 * (0.40 * sOsc + 0.25 * sZone + 0.20 * sSwing + 0.15 * sPrice)
            else
                score := 100.0 * (0.50 * sOsc + 0.30 * sSwing + 0.20 * sPrice)
            if score < minScore
                continue

            // ── 6 · keep the best (or first = most recent) candidate ─────────
            DivHit tgt = isReg ? reg : hid
            bool better = signalMode == M_BEST ? (not tgt.found or score > tgt.score) : not tgt.found
            if better
                string d = "Score " + str.tostring(score, "#")
                d += "  ·  Δosc " + str.tostring(100.0 * dOsc / oscRange, "#.#") + "% of range"
                d += "  ·  swing " + str.tostring(swing / safeAtr, "#.##") + " ATR"
                d += "  ·  span " + str.tostring(span) + " bars"
                d += "  ·  P1 %rank " + str.tostring(nz(p1.prank, 50.0), "#")
                tgt.found := true
                tgt.p1 := p1
                tgt.score := score
                tgt.details := d
    [reg, hid]

// ═════════════════════════ DRAWING ═══════════════════════════════════════════
drawDiv(bool isBull, bool isHidden, DivHit hit, int p2bar, float p2price) =>
    color c = isBull ? (isHidden ? colHidBull : colRegBull) : (isHidden ? colHidBear : colRegBear)
    if showLines
        line.new(hit.p1.bar, hit.p1.price, p2bar, p2price, xloc.bar_index, extend.none, c, isHidden ? line.style_dashed : line.style_dotted, 2)
    if showLabels
        string tag = (isHidden ? "H" : "R") + (showScore ? " " + str.tostring(hit.score, "#") : "")
        label.new(p2bar, p2price, tag, xloc.bar_index, isBull ? yloc.belowbar : yloc.abovebar, color.new(c, 55), isBull ? label.style_label_up : label.style_label_down, color.white, size.tiny, tooltip = hit.details)

// ═════════════════════════ DETECTION (bar close only) ════════════════════════
bool confirmed = barstate.isconfirmed

bool newRegBull = false
bool newHidBull = false
bool newRegBear = false
bool newHidBear = false
string alertTxt = ""

// ── Bullish side: a pivot LOW just confirmed ──────────────────────────────────
if confirmed and not na(plPrice) and not na(osc[rightBars]) and not na(atr[rightBars])
    int   p2bar   = bar_index - rightBars
    float p2price = low[rightBars]
    float p2osc   = osc[rightBars]
    float p2prank = nz(oscPrank[rightBars], 50.0)
    float p2atr   = atr[rightBars]
    [regB, hidB] = scan(true, pivLows, p2bar, p2price, p2osc, p2prank, p2atr)
    if regB.found
        drawDiv(true, false, regB, p2bar, p2price)
        newRegBull := true
        alertTxt += "Regular Bullish (score " + str.tostring(regB.score, "#") + ")  "
    if hidB.found
        drawDiv(true, true, hidB, p2bar, p2price)
        newHidBull := true
        alertTxt += "Hidden Bullish (score " + str.tostring(hidB.score, "#") + ")  "
    array.unshift(pivLows, Pivot.new(p2bar, p2price, p2osc, p2prank))
    while array.size(pivLows) > maxPivots
        array.pop(pivLows)

// ── Bearish side: a pivot HIGH just confirmed ─────────────────────────────────
if confirmed and not na(phPrice) and not na(osc[rightBars]) and not na(atr[rightBars])
    int   p2bar   = bar_index - rightBars
    float p2price = high[rightBars]
    float p2osc   = osc[rightBars]
    float p2prank = nz(oscPrank[rightBars], 50.0)
    float p2atr   = atr[rightBars]
    [regS, hidS] = scan(false, pivHighs, p2bar, p2price, p2osc, p2prank, p2atr)
    if regS.found
        drawDiv(false, false, regS, p2bar, p2price)
        newRegBear := true
        alertTxt += "Regular Bearish (score " + str.tostring(regS.score, "#") + ")  "
    if hidS.found
        drawDiv(false, true, hidS, p2bar, p2price)
        newHidBear := true
        alertTxt += "Hidden Bearish (score " + str.tostring(hidS.score, "#") + ")  "
    array.unshift(pivHighs, Pivot.new(p2bar, p2price, p2osc, p2prank))
    while array.size(pivHighs) > maxPivots
        array.pop(pivHighs)

// ═════════════════════════ CONFIRMATION MARKERS ══════════════════════════════
plotshape(showMarkers and newRegBull, "Regular Bull signal", shape.triangleup, location.belowbar, colRegBull, size = size.tiny)
plotshape(showMarkers and newHidBull, "Hidden Bull signal", shape.triangleup, location.belowbar, colHidBull, size = size.tiny)
plotshape(showMarkers and newRegBear, "Regular Bear signal", shape.triangledown, location.abovebar, colRegBear, size = size.tiny)
plotshape(showMarkers and newHidBear, "Hidden Bear signal", shape.triangledown, location.abovebar, colHidBear, size = size.tiny)

// ═════════════════════════ ALERTS ════════════════════════════════════════════
// Create alerts with "Once Per Bar Close". Detection is already gated on bar
// confirmation, so these can never fire on an unconfirmed intrabar state.
alertcondition(newRegBull, "Regular Bullish Divergence", "Regular bullish divergence confirmed")
alertcondition(newRegBear, "Regular Bearish Divergence", "Regular bearish divergence confirmed")
alertcondition(newHidBull, "Hidden Bullish Divergence", "Hidden bullish divergence confirmed")
alertcondition(newHidBear, "Hidden Bearish Divergence", "Hidden bearish divergence confirmed")
alertcondition(newRegBull or newRegBear or newHidBull or newHidBear, "Any Divergence", "Divergence confirmed")

if alertTxt != ""
    alert(syminfo.ticker + " " + timeframe.period + "  →  " + alertTxt, alert.freq_once_per_bar_close)
````
