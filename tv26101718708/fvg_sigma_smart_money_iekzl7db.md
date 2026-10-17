# FVG Sigma [Smart Money]

- url: https://www.tradingview.com/script/iekzl7dB-FVG-Sigma-Smart-Money/
- type: indicator
- pine_id: PUB;9fffb1e222984674a4860d57fb7fb6ce
- version: 2.0

## Description

A Fair Value Gap is a 3-candle imbalance: the middle candle runs hard and leaves a void between candle 1 and candle 3. The problem with marking them is that gaps come in every size — most tools draw every single one, and the chart fills with noise where trivial micro-gaps sit next to the ones that actually mattered. FVG Sigma measures each gap's width and keeps only the statistically unusual ones.

[b]HOW IT WORKS[/b]

Every gap's geometric width is fed into a rolling sample pool, with separate pools for bullish and bearish gaps. A new gap is z-scored against its own pool *before* it is added (no look-ahead into its own sample):

`z = (gap width − mean) / standard deviation`

Only gaps with `z >= threshold` (e.g. 2 sigma) are drawn — "unusually large for this symbol on this timeframe." Because a z-score is scale-free (the mean and the standard deviation share the gap's own units), there is no ATR or point normalization to tune; sigma absorbs symbol and timeframe scale on its own. The pool still collects *every* gap, so the baseline stays honest — but only the outliers reach the chart. Until a pool has gathered Min Samples gaps, nothing is drawn (warm-up).

Each surviving gap is then tracked for mitigation. The zone splits into a vivid *fresh* band and a faded *consumed* band at the deepest penetration so far (a high-water mark that never retreats), and an in-zone label reports consumption as a live percentage. When the consumed front reaches the far edge, the gap is fully mitigated and removed (or kept faded, your choice).

1) A confirmed 3-candle gap is measured and z-scored against its side's pool
2) If `z >= threshold`, the zone is drawn; otherwise it is only added to the pool
3) Price penetration splits the zone fresh/consumed and updates the live percentage

[b]HOW TO READ[/b]

- A vivid band is the fresh, un-touched portion of a significant gap.
- The faded band behind it is the part price has already traded through.
- The in-zone label is the live consumed percentage (how much of the gap is gone).
- "Significant" means statistically large — an unusual imbalance, not a buy or sell instruction. A large gap is just a large gap; it does not predict fill, reversal, or direction. The tool marks the area; the read is yours.

[b]INPUTS[/b]

- Sample Size N — how many recent gap widths each side's pool holds.
- Z-Score Threshold (sigma) — how extreme a gap must be to be drawn. Higher = fewer, stronger gaps.
- Min Samples — warm-up; filtering starts only once the pool has this many gaps.
- Mitigation — Wick (penetration tracked by bar high/low, live but exact) or Close (only confirmed closes count).
- Remove Mitigated / Avoid Overlap — drop fully-consumed zones; skip a new gap that overlaps a same-side one.
- Bullish FVG / Bearish FVG — enable each side independently.
- Show Last Bullish / Bearish — per-side display caps.
- Extend Right / Show Consumed % — projection length; toggle the live label.
- Style — bullish/bearish fills and text colours, fresh and mitigated transparency.

[b]ALERTS[/b]

Two separate conditions: New significant Bullish FVG and New significant Bearish FVG. Both fire on closed bars — use "Once Per Bar Close."

[b]NOTES & LIMITS[/b]

This is a statistical observation, not a forecast: the filter flags gaps that are unusually large for the current symbol and timeframe, nothing more. It does not say a gap will be filled, hold, or reverse. Scale-free by design — the z-score normalizes symbol and timeframe scale, so there is no ATR or point setting to calibrate. No repaint, no lookahead: gaps are created on confirmed (closed) bars only and their levels never move. Mitigation in Wick mode updates the consumed percentage live but stays exact, because a bar's high/low is a running extreme that is never revised; Close mode updates only on bar close. Open-source under CC BY-NC-SA 4.0 — non-commercial use, attribution to ElisTools required for reuse or derivatives. TradingView (Pine v6) only.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ElisTools
// FVG Sigma [Smart Money] — Attribution required: credit "ElisTools" in any reuse or derivative.
//@version=6
indicator("FVG Sigma [Smart Money]", "FVG Sigma", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 500)
// ============================================================
//  FVG SIGMA  —  © ElisTools
//
//  A classic Fair Value Gap is a 3-candle imbalance: the middle
//  candle runs so hard that a price void is left between candle 1
//  and candle 3.
//    • Bullish FVG = low[0] > high[2]   (gap = high[2] .. low[0])
//    • Bearish FVG = high[0] < low[2]   (gap = high[0] .. low[2])
//
//  The twist — statistical size filter:
//  Every geometric FVG width is fed into a rolling sample pool
//  (SEPARATE pools for bullish and bearish). A new gap is z-scored
//  against its own pool BEFORE being added:
//        z = (gapWidth − mean) / stdev
//  Only gaps whose z exceeds the threshold (e.g. 2σ) are drawn —
//  i.e. "unusually large for THIS symbol on THIS timeframe."
//  Because z-score is scale-free, no ATR / point normalization is
//  needed: σ absorbs the symbol/timeframe scale automatically.
//
//  Mitigation: each zone splits into a faded "consumed" band and a
//  vivid "fresh" band at the deepest penetration (high-water `front`).
//  The in-zone label reports that consumption as a live %.
//  Wick or Close mitigation; fully mitigated when the front reaches
//  the far edge. Zones are CREATED only on closed bars (never
//  repaint); levels never move — see the non-repaint note below.
//
//  Lifecycle stats — what actually HAPPENED to the σ-filtered gaps:
//  every significant gap is enrolled at birth, BEFORE the display
//  gate (avoidOverlap / maxN), so the outcome sample is never biased
//  by gaps that merely went undrawn. Each enrolment is followed for
//  H bars and settles into one finalised outcome:
//    • CE reached — price touched the midpoint (top+bot)/2
//    • Filled     — price reached the far edge (inherits Mitigation)
//    • Unfilled   — H bars elapsed with no full fill
//  Counting runs on confirmed bars only and stamps are one-way: a
//  settled record is counted once, dropped, and never revised.
// ============================================================
// ----------------------- Inputs -----------------------
int    zLen         = input.int(50, "Sample Size (N)", minval = 5, group = "Z-Score Filter", tooltip = "Per-side rolling pool of the last N gap widths. mean/σ are computed from this pool.")
float  zThreshold   = input.float(2.0, "Z-Score Threshold (σ)", minval = 0, step = 0.1, group = "Z-Score Filter", tooltip = "Only gaps with z ≥ this are drawn. 2.0 = statistically unusual. Higher = stricter / rarer. z-score already normalizes scale, so no ATR needed.")
int    minSamples   = input.int(10, "Min Samples", minval = 2, group = "Z-Score Filter", tooltip = "Filtering activates only after a pool holds this many gaps. Until then gaps are collected but NOT drawn (warm-up).")
string mitigation   = input.string("Wick", "Mitigation", options = ["Wick", "Close"], group = "Detection", tooltip = "When a gap is consumed. Wick = price wicks through (updates live, exact). Close = a candle closes through (updates on bar close, fully non-repaint). The lifecycle 'Filled' outcome inherits this setting.")
bool   removeMit    = input.bool(true,  "Remove Mitigated", group = "Detection", tooltip = "On = delete fully mitigated gaps. Off = keep them shown faded.")
bool   avoidOverlap = input.bool(true,  "Avoid Overlap", group = "Detection", tooltip = "Skip a new gap that overlaps an existing same-side gap (cleaner chart). Display only — lifecycle stats still enrol it.")
bool   showBull     = input.bool(true,  "Bullish FVG", group = "Detection")
bool   showBear     = input.bool(true,  "Bearish FVG", group = "Detection")
int    maxBull      = input.int(10, "Show Last Bullish", minval = 0, maxval = 50, group = "Display")
int    maxBear      = input.int(10, "Show Last Bearish", minval = 0, maxval = 50, group = "Display")
int    extendBars   = input.int(30, "Extend Right (bars)", minval = 0, group = "Display")
bool   showPctLabel = input.bool(true, "Show Consumed %", group = "Display", tooltip = "Tag each zone with how much of it price has consumed (mitigation depth), inside the zone, right-adjacent and centered.")
bool   lifecycleOn  = input.bool(true, "Lifecycle Stats", group = "Lifecycle", tooltip = "Track what happened to every significant gap and report it in the top-right panel. Enrolment happens before the display filters, so the sample is unbiased.")
int    outcomeWin   = input.int(100, "Outcome Window (bars)", minval = 1, group = "Lifecycle", tooltip = "H — how many bars a gap is followed after birth. If it has not fully filled by then it settles as Unfilled. Percentages stay '—' until the mature sample reaches 20.")
color  bullCol      = input.color(color.new(#4dd0e1, 72), "Bullish", group = "Style", inline = "bull", tooltip = "Pastel turquoise zone fill.")
color  bullText     = input.color(#00838f, "Text", group = "Style", inline = "bull", tooltip = "Consumed % label and panel column color (bullish).")
color  bearCol      = input.color(color.new(#ef9a9a, 72), "Bearish", group = "Style", inline = "bear", tooltip = "Pastel red-pink zone fill.")
color  bearText     = input.color(#c62828, "Text", group = "Style", inline = "bear", tooltip = "Consumed % label and panel column color (bearish).")
int    freshTransp  = input.int(72, "Fresh Transparency",     minval = 0, maxval = 100, group = "Style", tooltip = "Transparency of the un-touched (fresh) part of a zone. Lower = more solid.")
int    mitTransp    = input.int(90, "Mitigated Transparency", minval = 0, maxval = 100, group = "Style", tooltip = "Transparency of the consumed part of a zone. Higher = fainter.")
// ----------------------- Type -------------------------
type FVG
    box   bxMit        // consumed (faded) band
    box   bxFresh      // un-touched (vivid) band
    label lb
    float top
    float bot
    float front        // deepest penetration so far (high-water mark)
    int   bornBar      // bar_index the gap was created on
    int   dir          // 1 = bullish, -1 = bearish
    float z            // z-score at formation (metadata)
    bool  mitigated
// Lifecycle enrolment — display-independent, so stats stay unbiased.
type Track
    float top
    float bot
    float ce           // consequent encroachment = (top + bot) / 2
    int   bornBar
    int   dir
    bool  ceHit        // one-way flag: price reached CE at some point
// Settled outcomes. mature = filled + unfilled; ce and filled are subsets.
type Stats
    int mature = 0
    int ce     = 0
    int filled = 0
var array<FVG>   bulls     = array.new<FVG>()
var array<FVG>   bears     = array.new<FVG>()
var array<float> bullGaps  = array.new<float>()   // rolling bullish gap-width pool
var array<float> bearGaps  = array.new<float>()   // rolling bearish gap-width pool
var array<Track> bullTrack = array.new<Track>()   // live bullish enrolments
var array<Track> bearTrack = array.new<Track>()   // live bearish enrolments
var Stats        bullSt    = Stats.new()
var Stats        bearSt    = Stats.new()
// ----------------------- Helpers ----------------------
// True if [t,b] overlaps any same-side gap already stored.
overlapsAny(array<FVG> arr, float t, float b) =>
    bool res = false
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            o = arr.get(i)
            if t >= o.bot and b <= o.top
                res := true
                break
    res
// Position the two bands from the current penetration front.
//  Bullish: consumed band on top (top..front), fresh below (front..bot).
//  Bearish: fresh band on top (top..front), consumed below (front..bot).
applyBands(FVG o, int right) =>
    if o.dir == 1
        o.bxMit.set_top(o.top)
        o.bxMit.set_bottom(o.front)
        o.bxFresh.set_top(o.front)
        o.bxFresh.set_bottom(o.bot)
    else
        o.bxFresh.set_top(o.top)
        o.bxFresh.set_bottom(o.front)
        o.bxMit.set_top(o.front)
        o.bxMit.set_bottom(o.bot)
    o.bxMit.set_right(right)
    o.bxFresh.set_right(right)
// Fraction of the zone height consumed so far (0..100).
consumedPct(FVG o) =>
    float h = o.top - o.bot
    float c = o.dir == 1 ? (o.top - o.front) : (o.front - o.bot)
    h > 0 ? math.min(100.0, math.max(0.0, c / h * 100.0)) : 0.0
// Refresh the in-zone % label: anchored at the right edge, drawn to the
// LEFT of the anchor (style_label_right) so it sits inside the zone,
// right-adjacent and vertically centered. Transparent bubble = text only.
updLabel(FVG o, int right) =>
    if not na(o.lb)
        o.lb.set_xy(right, (o.top + o.bot) / 2)
        o.lb.set_text(str.tostring(consumedPct(o), "0") + "%")
// Build an FVG (two bands + optional % label) anchored at the middle candle.
makeFVG(int dir, int leftBar, float t, float b, float z) =>
    base  = dir == 1 ? bullCol  : bearCol
    txt   = dir == 1 ? bullText : bearText
    right = bar_index + extendBars
    front = dir == 1 ? t : b                       // nothing consumed yet
    bxMit   = box.new(leftBar, t, right, b, border_color = na, border_width = 0, bgcolor = color.new(base, mitTransp))
    bxFresh = box.new(leftBar, t, right, b, border_color = na, border_width = 0, bgcolor = color.new(base, freshTransp))
    label lb = na
    if showPctLabel
        lb := label.new(right, (t + b) / 2, "0%", style = label.style_label_right, color = color.new(color.gray, 100), textcolor = txt, size = size.small)
    o = FVG.new(bxMit, bxFresh, lb, t, b, front, bar_index, dir, z, false)
    applyBands(o, right)
    o
// Keep only the newest maxN gaps (newest are unshifted to the front).
trim(array<FVG> arr, int maxN) =>
    while arr.size() > maxN
        o = arr.pop()
        o.bxMit.delete()
        o.bxFresh.delete()
        if not na(o.lb)
            o.lb.delete()
// Extend live gaps, advance the penetration front, detect mitigation.
refresh(array<FVG> arr) =>
    int right = bar_index + extendBars
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            o = arr.get(i)
            // Advance the penetration front (high-water mark) — only AFTER the
            // creation bar, so the formation move never counts as mitigation.
            // Wick uses the bar's low/high (running extreme == final extreme, so
            // exact even live). Close uses the bar's close, which is only final
            // once confirmed -> gate Close on barstate.isconfirmed so consumed %
            // and mitigation never repaint intrabar.
            if not o.mitigated and bar_index > o.bornBar and (mitigation == "Wick" or barstate.isconfirmed)
                reach = mitigation == "Wick" ? (o.dir == 1 ? low : high) : close
                if o.dir == 1
                    o.front := math.max(math.min(o.front, reach), o.bot)
                else
                    o.front := math.min(math.max(o.front, reach), o.top)
            // fully mitigated once the front reaches the far edge
            fullMit = o.dir == 1 ? o.front <= o.bot : o.front >= o.top
            if fullMit and not o.mitigated
                o.mitigated := true
                if removeMit
                    o.bxMit.delete()
                    o.bxFresh.delete()
                    if not na(o.lb)
                        o.lb.delete()
                    arr.remove(i)
                    continue
                else
                    applyBands(o, right)   // render fully-consumed (faded) state, then freeze
                    updLabel(o, right)     // -> "100%", then frozen
            if not o.mitigated
                applyBands(o, right)
                updLabel(o, right)
// Settle live enrolments. Call on CONFIRMED bars only.
// Stamps are one-way: CE is flagged once and never cleared; a record that
// settles (filled, or aged out) is counted once, dropped, and never revised.
// Counting happens AT settlement, so ce and filled can never exceed mature.
settle(array<Track> tr, Stats st) =>
    if tr.size() > 0
        for i = tr.size() - 1 to 0
            k = tr.get(i)
            if bar_index > k.bornBar        // the birth bar itself never counts
                // CE touch: price reached the midpoint.
                if not k.ceHit and (k.dir == 1 ? low <= k.ce : high >= k.ce)
                    k.ceHit := true
                // Full fill inherits the Mitigation mode (Wick / Close).
                reach     = mitigation == "Wick" ? (k.dir == 1 ? low : high) : close
                bool full = k.dir == 1 ? reach <= k.bot : reach >= k.top
                bool aged = bar_index - k.bornBar >= outcomeWin
                if full or aged             // outcome finalised -> stamp and drop
                    st.mature := st.mature + 1
                    if k.ceHit
                        st.ce := st.ce + 1
                    if full
                        st.filled := st.filled + 1
                    tr.remove(i)
// Share of the mature sample; "—" while the sample is too thin to read.
pctTxt(int part, int mature) =>
    mature < 20 ? "—" : str.tostring(part * 100.0 / mature, "0") + "%"
// Evaluate a gap against its pool, draw if significant, then store the sample.
//  dir 1 = bullish, -1 = bearish.
processGap(int dir, float t, float b, array<FVG> arr, array<float> pool, array<Track> tr, int maxN) =>
    float sz   = t - b                              // gap width (always > 0 here)
    float z    = na
    bool  draw = false
    if pool.size() >= minSamples
        float mu = array.avg(pool)
        float sd = array.stdev(pool)
        z    := sd > 0 ? (sz - mu) / sd : 0.0       // compare BEFORE adding this sample
        draw := z >= zThreshold
    // Birth registration — enrol EVERY significant gap here, before the
    // avoidOverlap / maxN display gate, otherwise the outcome sample would be
    // biased toward whatever the chart happened to have room to draw.
    if lifecycleOn and draw
        tr.unshift(Track.new(t, b, (t + b) / 2, bar_index, dir, false))
    bool made = false
    if draw and maxN > 0 and (not avoidOverlap or not overlapsAny(arr, t, b))
        arr.unshift(makeFVG(dir, bar_index - 1, t, b, z))   // anchor at middle candle
        trim(arr, maxN)
        made := true                               // a NEW significant gap was drawn
    pool.unshift(sz)                                // collect EVERY gap into the pool
    while pool.size() > zLen
        pool.pop()
    made
// ------------------ FVG detection (3-candle) -----------------
confirmed = barstate.isconfirmed                    // act only on closed bars -> non-repainting
bullFVG   = not na(high[2]) and low  > high[2]
bearFVG   = not na(low[2])  and high < low[2]
bool newSigBull = false
bool newSigBear = false
if confirmed and showBull and bullFVG
    newSigBull := processGap(1, low, high[2], bulls, bullGaps, bullTrack, maxBull)    // bull gap = high[2] .. low[0]
if confirmed and showBear and bearFVG
    newSigBear := processGap(-1, low[2], high, bears, bearGaps, bearTrack, maxBear)   // bear gap = high[0] .. low[2]
// -------------------- Live refresh ---------------------
// NON-REPAINT: gaps are CREATED only on closed bars and their levels never
// move. Wick mitigation/shading update live yet stay exact (bar low/high ==
// running extreme). Close mitigation updates on bar close only (fully
// reproducible). Box extension and label position follow the live bar —
// cosmetic, not signal repaint.
refresh(bulls)
refresh(bears)
// -------------------- Lifecycle ------------------------
// Confirmed bars only -> counters never move intrabar and reload identically.
if lifecycleOn and confirmed
    settle(bullTrack, bullSt)
    settle(bearTrack, bearSt)
var table panel = na
if lifecycleOn and barstate.islast
    if na(panel)
        panel := table.new(position.top_right, 3, 5, bgcolor = color.new(chart.bg_color, 15), border_color = color.new(chart.fg_color, 85), border_width = 1)
    panel.cell(0, 0, "Lifecycle " + str.tostring(outcomeWin) + "b", text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
    panel.cell(1, 0, "Bull", text_color = bullText, text_size = size.small)
    panel.cell(2, 0, "Bear", text_color = bearText, text_size = size.small)
    panel.cell(0, 1, "Sample", text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
    panel.cell(1, 1, str.tostring(bullSt.mature), text_color = bullText, text_size = size.small)
    panel.cell(2, 1, str.tostring(bearSt.mature), text_color = bearText, text_size = size.small)
    panel.cell(0, 2, "CE reached", text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
    panel.cell(1, 2, pctTxt(bullSt.ce, bullSt.mature), text_color = bullText, text_size = size.small)
    panel.cell(2, 2, pctTxt(bearSt.ce, bearSt.mature), text_color = bearText, text_size = size.small)
    panel.cell(0, 3, "Filled", text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
    panel.cell(1, 3, pctTxt(bullSt.filled, bullSt.mature), text_color = bullText, text_size = size.small)
    panel.cell(2, 3, pctTxt(bearSt.filled, bearSt.mature), text_color = bearText, text_size = size.small)
    panel.cell(0, 4, "Unfilled", text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
    panel.cell(1, 4, pctTxt(bullSt.mature - bullSt.filled, bullSt.mature), text_color = bullText, text_size = size.small)
    panel.cell(2, 4, pctTxt(bearSt.mature - bearSt.filled, bearSt.mature), text_color = bearText, text_size = size.small)
// -------------------- Alerts ---------------------------
// Fire only when a NEW significant (z ≥ threshold) gap is drawn — and since
// newSig* is set inside the `confirmed` blocks, this can only be true on a
// closed bar. Create the alert with "Once Per Bar Close" to match.
alertcondition(newSigBull, title = "New significant bullish FVG", message = "FVG Sigma: new significant BULLISH FVG on {{ticker}} {{interval}}")
alertcondition(newSigBear, title = "New significant bearish FVG", message = "FVG Sigma: new significant BEARISH FVG on {{ticker}} {{interval}}")
````
