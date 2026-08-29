<!-- tradingview-pine-id: PUB;295514a47120451cbc20d2366d3038bd -->
<!-- tradingviewscripts-format: 1 -->
# Compression Breakout & Follow-Through Scoring [SlatinaTrades]

Source: https://www.tradingview.com/script/AFtVAe6o-Compression-Breakout-Follow-Through-Scoring-SlatinaTrades/

## Description

🌀 Compression Breakout & Follow-Through Scoring — grades the coil, then checks its own homework.

Most squeeze/compression tools flag a tight range and stop there. This one also tracks what happens after the break — and separates completed setups by quartile to show whether the coil's tightness or the breakout candle's quality actually predicted the outcome, instead of assuming either one does.

THE MECHANICS

🧊 Compression detection — three conditions have to hold together: box range ≤ a multiple of base-ATR (C1), Bollinger Band width inside a squeeze percentile (C2), and a minimum dwell in confirmed bars (C3). All three gate the coil; none of them alone is enough.

🔒 State machine — COILING → PRIMED → BREAKOUT (up/down) → HELD or FAILED, with EXPIRED for coils that age out unbroken. The box freezes on arm (tighten-only re-lock while PRIMED — it can tighten further, never widen), so what you see is a committed level, not a moving target.

📊 Tightness score (0–100) — weighted blend of C1 margin, C2 depth, and dwell length. Grades how genuine the compression is, not just whether it cleared a threshold.

🎯 Break-quality score (0–100) — weighted blend of close location, body ratio, range expansion vs ATR14, and where volatility sits inside a regime band (mid-band scores highest; dead or chaotic extremes score low).

📈 Follow-through score (0–100) — tracks maximum favorable excursion beyond the broken edge over a fixed window, capped at a set ATR multiple. A break that reclaims the level before the window closes is scored FAILED instead.

SEPARATION HARNESS — the honesty check

A stats table bins every completed setup (HELD or FAILED) into quartiles two ways: by tightness score and by break-quality score. Each quartile reports mean follow-through in ATR units and reclaim rate. If a score's Q4 looks like its Q1, that score isn't doing the work it claims to — the table shows you that plainly instead of asking you to trust a single headline number.

NON-REPAINT

Every state transition and every follow-through update runs on barstate.isconfirmed. The box freezes the moment a coil arms. The optional HTF alignment read uses a closed-bar offset (lookahead_on + gaps_off on [1]) and is a flag only — it never gates the state machine.

WHAT IT IS NOT

Not a strategy. No entries, no stops, no targets, no risk sizing anywhere in this script. Bidirectional context only — it tells you a coil compressed and how the break resolved, not what to do about it. Settings are starting points, not recommendations; tune box length, dwell, and weights to what you're trading and validate before risking anything on it.

ALERTS

New Coil Primed · Bull Breakout · Bear Breakout · Follow-Through Confirmed · Reclaim. All gated to confirmed bars, all carry numeric state/score payloads for automation.

Still useful after it's been on your chart a while — every read maps to a concrete decision about whether this coil is worth watching.

---

## Source Code

````pine
//@version=6
// ============================================================================
// Compression Breakout & Follow-Through Scoring  [SlatinaTrades]
// Scores coils, grades breakouts, and tracks follow-through. Bidirectional.
// Context only — no entries, stops, targets, or risk anywhere in this file.
// Non-repaint: every transition gated on barstate.isconfirmed; box frozen on
// arm; HTF read with [1] + lookahead_on + gaps_off (flag only, never a gate).
// ============================================================================
indicator("Compression Breakout & Follow-Through Scoring [SlatinaTrades]", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 50, max_bars_back = 500)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS — DETECTION
// ─────────────────────────────────────────────────────────────────────────
gDet        = "Detection Engine"
boxLen      = input.int(6,   "Box length (rolling window)", minval = 2,  group = gDet)
compressMult= input.float(1.5, "C1: box ≤ mult × base-ATR", minval = 0.1, step = 0.1, group = gDet)
atrBaseLen  = input.int(100, "Base-ATR length",             minval = 5,  group = gDet)
bbLen       = input.int(20,  "BB length",                   minval = 5,  group = gDet)
bbMult      = input.float(2.0, "BB mult",                   minval = 0.5, step = 0.1, group = gDet)
squeezePct  = input.float(35, "C2: squeeze percentile",     minval = 1, maxval = 99, group = gDet)
percLen     = input.int(200, "Percentile lookback",         minval = 20, group = gDet)
minDwell    = input.int(3,   "C3: min dwell (confirmed bars)", minval = 1, group = gDet)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS — STATE MACHINE
// ─────────────────────────────────────────────────────────────────────────
gSM         = "State Machine"
maxAge      = input.int(24, "Max age while PRIMED (bars)", minval = 1, group = gSM)
cooldownBars= input.int(4,  "Cooldown after window closes", minval = 0, group = gSM)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS — FOLLOW-THROUGH
// ─────────────────────────────────────────────────────────────────────────
gFT         = "Follow-Through"
followWindow= input.int(12,  "Follow-through window (bars)", minval = 1, group = gFT)
ftCapAtr    = input.float(3.0, "FT score caps at (ATR beyond edge)", minval = 0.5, step = 0.5, group = gFT)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS — BREAK-QUALITY SCORE COMPONENTS
// ─────────────────────────────────────────────────────────────────────────
gBQ         = "Break-Quality Score"
expandMult  = input.float(1.0, "Expansion: range vs mult × ATR14", minval = 0.1, step = 0.1, group = gBQ)
atrLoMult   = input.float(0.5, "Regime band low  (× base-ATR)",    minval = 0.1, step = 0.1, group = gBQ)
atrHiMult   = input.float(3.0, "Regime band high (× base-ATR)",    minval = 0.5, step = 0.1, group = gBQ)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS — SCORE WEIGHTS (equal by default)
// ─────────────────────────────────────────────────────────────────────────
gW          = "Score Weights"
wC1         = input.float(1.0, "Tightness · C1 margin",   minval = 0, step = 0.1, group = gW)
wC2         = input.float(1.0, "Tightness · C2 depth",    minval = 0, step = 0.1, group = gW)
wDwell      = input.float(1.0, "Tightness · dwell length", minval = 0, step = 0.1, group = gW)
wCloseLoc   = input.float(1.0, "Break · close location",  minval = 0, step = 0.1, group = gW)
wBody       = input.float(1.0, "Break · body ratio",      minval = 0, step = 0.1, group = gW)
wExp        = input.float(1.0, "Break · expansion",       minval = 0, step = 0.1, group = gW)
wRegime     = input.float(1.0, "Break · regime position", minval = 0, step = 0.1, group = gW)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS — HTF ALIGNMENT (flag only)
// ─────────────────────────────────────────────────────────────────────────
gHTF        = "HTF Alignment (flag)"
useHtf      = input.bool(true, "Enable HTF alignment flag", group = gHTF)
htfRes      = input.timeframe("240", "HTF resolution",      group = gHTF)
htfLen      = input.int(20, "HTF SMA length",  minval = 2,  group = gHTF)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS — DISPLAY
// ─────────────────────────────────────────────────────────────────────────
gDisp       = "Display"
minBQFilter = input.bool(false, "Filter: hide breaks below quality", group = gDisp)
minBQ       = input.float(0.0, "  min break-quality to draw", minval = 0, maxval = 100, group = gDisp)
showDash    = input.bool(true,  "Show dashboard panel",  group = gDisp)
showStats   = input.bool(true,  "Show separation harness table", group = gDisp)
showHeroTag = input.bool(false, "Show hero state tag on box (thumbnail)", group = gDisp)
useSession  = input.bool(false, "Session filter (UTC — dashboard flag only)", group = gDisp)
sessSpec    = input.session("0000-2359", "  session window (UTC)", group = gDisp)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS — PALETTE
// ─────────────────────────────────────────────────────────────────────────
gPal        = "Palette"
bullCol     = input.color(#14B8A6, "Bull-teal", group = gPal)
bearCol     = input.color(#F43F5E, "Bear-pink", group = gPal)
coilCol     = input.color(#F59E0B, "Coil (tightness-graded)", group = gPal)
expireCol   = input.color(#94A3B8, "Expired silver", group = gPal)
txtCol      = input.color(#E2E8F0, "Panel text", group = gPal)
panelBg     = input.color(#0F172A, "Panel background", group = gPal)

// ============================================================================
// CONSTANTS / ENUM
// ============================================================================
// state codes: 0 COILING · 1 PRIMED · 2 BREAKOUT_UP · 3 BREAKOUT_DOWN · 4 HELD · 5 FAILED · 6 EXPIRED
ST_COIL  = 0
ST_PRIME = 1
ST_UP    = 2
ST_DOWN  = 3
ST_HELD  = 4
ST_FAIL  = 5
ST_EXP   = 6
EXP_CAP  = 2.0     // expansion score saturates at 2× the expand threshold
HIST_CAP = 300     // bounded coil/harness sample

// ============================================================================
// UDTs
// ============================================================================
type Coil
    box   boxId        = na
    label tagId        = na
    float boxHigh      = na
    float boxLow       = na
    int   birthBar     = na
    int   armBar       = na
    int   dwell        = 0
    float tightness    = na
    int   state        = 0
    int   breakDir     = 0     // +1 up · -1 down · 0 none
    float breakEdge    = na
    float breakQual    = na
    int   breakBar     = na
    float atrRef       = na
    float mfe          = 0.0   // raw favorable excursion beyond edge (price)
    float followThrough= na    // 0–100
    bool  reclaim      = false

// ============================================================================
// HELPERS
// ============================================================================
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_isTerm(int s) => s == ST_HELD or s == ST_FAIL or s == ST_EXP

// Compression-tightness score (0–100)
f_tight(float boxRange, float atrBase, float bbW, float bbThr, int dwell) =>
    c1s   = f_clamp((compressMult * atrBase - boxRange) / (compressMult * atrBase), 0, 1)
    c2s   = na(bbThr) or bbThr == 0 ? 0.0 : f_clamp((bbThr - bbW) / bbThr, 0, 1)
    dws   = f_clamp(dwell / (2.0 * minDwell), 0, 1)
    wsum  = wC1 + wC2 + wDwell
    wsum <= 0 ? na : 100.0 * (wC1 * c1s + wC2 * c2s + wDwell * dws) / wsum

// Break-quality score (0–100), direction-mirrored close location
f_breakQual(int dir, float atr14, float atrBase) =>
    rng   = high - low
    cl    = rng <= 0 ? 0.5 : (dir > 0 ? (close - low) / rng : (high - close) / rng)
    br    = rng <= 0 ? 0.0 : math.abs(close - open) / rng
    exps  = atr14 <= 0 ? 0.0 : f_clamp((rng / (expandMult * atr14)) / EXP_CAP, 0, 1)
    lo    = atrLoMult * atrBase
    hi    = atrHiMult * atrBase
    pos   = hi > lo ? (atr14 - lo) / (hi - lo) : 0.5
    regs  = pos >= 0 and pos <= 1 ? f_clamp(1 - math.abs(pos - 0.5) * 2, 0, 1) : 0.0
    wsum  = wCloseLoc + wBody + wExp + wRegime
    wsum <= 0 ? na : 100.0 * (wCloseLoc * cl + wBody * br + wExp * exps + wRegime * regs) / wsum

// Coil box color by tightness (tighter = hotter / more opaque)
f_coilTransp(float t) => int(f_clamp(90 - 0.4 * nz(t), 50, 90))

// Quartile binning: returns [q1ft,q1fk, q2ft,q2fk, q3ft,q3fk, q4ft,q4fk]
f_quartiles(array<float> keys, array<float> ft, array<bool> rc) =>
    res = array.new_float(8, na)
    n   = keys.size()
    if n >= 4
        idx = keys.sort_indices(order.ascending)
        for q = 0 to 3
            lo = int(math.floor(q * n / 4.0))
            hi = int(math.floor((q + 1) * n / 4.0)) - 1
            sumFt = 0.0
            cntRc = 0
            cnt   = 0
            for k = lo to hi
                ii = idx.get(k)
                sumFt += ft.get(ii)
                cntRc += rc.get(ii) ? 1 : 0
                cnt   += 1
            res.set(q * 2,     cnt > 0 ? sumFt / cnt : na)
            res.set(q * 2 + 1, cnt > 0 ? 100.0 * cntRc / cnt : na)
    res

// ============================================================================
// SERIES (computed every bar — never inside conditionals)
// ============================================================================
atrBase = ta.atr(atrBaseLen)
atr14   = ta.atr(14)
boxHi   = ta.highest(high, boxLen)
boxLo   = ta.lowest(low,  boxLen)
boxRng  = boxHi - boxLo

basis   = ta.sma(close, bbLen)
dev     = bbMult * ta.stdev(close, bbLen)
bbWidth = basis == 0 ? na : (2 * dev) / basis
bbThr   = ta.percentile_linear_interpolation(bbWidth, percLen, squeezePct)
bbRank  = ta.percentrank(bbWidth, percLen)   // current BB-width percentile

c1      = not na(atrBase) and boxRng <= compressMult * atrBase
c2      = not na(bbThr) and not na(bbWidth) and bbWidth <= bbThr
compOk  = c1 and c2

// HTF alignment flag (non-repaint idiom; flag only, never a gate)
htfSma  = request.security(syminfo.tickerid, htfRes, ta.sma(close, htfLen)[1], lookahead = barmerge.lookahead_on, gaps = barmerge.gaps_off)
htfBull = useHtf and not na(htfSma) and close > htfSma
htfBear = useHtf and not na(htfSma) and close < htfSma

inSession = not useSession or not na(time(timeframe.period, sessSpec, "UTC"))

// ============================================================================
// PERSISTENT STATE
// ============================================================================
var array<Coil> coils        = array.new<Coil>()
var int         compRun      = 0
var int         cooldownUntil= 0

// plot mirrors (updated only on confirmed bars → non-repaint)
var float pBoxHigh = na
var float pBoxLow  = na
var float pTight   = na
var float pBQual   = na
var int   pState   = na
var float pFT      = na

// alert triggers (fresh each bar)
bool trigPrimed = false
bool trigBull   = false
bool trigBear   = false
bool trigHeld   = false
bool trigFail   = false

// ============================================================================
// STATE MACHINE + LIFECYCLE (confirmed bars only)
// ============================================================================
if barstate.isconfirmed
    compRun := compOk ? compRun + 1 : 0

    Coil act    = coils.size() > 0 ? coils.last() : na
    bool hasAct = not na(act) and not f_isTerm(act.state)

    tightNow = f_tight(boxRng, atrBase, bbWidth, bbThr, compRun)

    // ── No active coil → maybe start a COILING coil ──────────────────────
    if not hasAct
        canStart = compOk and not na(boxHi) and not na(boxLo) and not na(atrBase) and bar_index >= cooldownUntil
        if canStart
            b = box.new(bar_index - boxLen + 1, boxHi, bar_index, boxLo, border_color = color.new(coilCol, 20), border_width = 1, bgcolor = color.new(coilCol, f_coilTransp(tightNow)))
            c = Coil.new()
            c.boxId     := b
            c.boxHigh   := boxHi
            c.boxLow    := boxLo
            c.birthBar  := bar_index
            c.dwell     := compRun
            c.tightness := tightNow
            c.state     := ST_COIL
            coils.push(c)

    // ── Active COILING ───────────────────────────────────────────────────
    else if act.state == ST_COIL
        if compOk
            // rolling box update (not yet frozen)
            act.boxHigh   := boxHi
            act.boxLow    := boxLo
            act.dwell     := compRun
            act.tightness := tightNow
            box.set_top(act.boxId, boxHi)
            box.set_bottom(act.boxId, boxLo)
            box.set_right(act.boxId, bar_index)
            box.set_bgcolor(act.boxId, color.new(coilCol, f_coilTransp(tightNow)))
            // ARM → PRIMED (freeze the box; frozen-box contract)
            if compRun >= minDwell and bar_index >= cooldownUntil
                act.state  := ST_PRIME
                act.armBar := bar_index
                box.set_border_width(act.boxId, 2)
                box.set_border_color(act.boxId, color.new(coilCol, 0))
                trigPrimed := true
        else
            // never armed → remove the coil
            box.delete(act.boxId)
            coils.pop()

    // ── Active PRIMED ────────────────────────────────────────────────────
    else if act.state == ST_PRIME
        // tighten-only re-lock (tighten ok, widen never); resets age timer
        if compOk and boxHi <= act.boxHigh and boxLo >= act.boxLow and (boxHi - boxLo) < (act.boxHigh - act.boxLow)
            act.boxHigh   := boxHi
            act.boxLow    := boxLo
            act.armBar    := bar_index
            act.tightness := tightNow
            box.set_top(act.boxId, boxHi)
            box.set_bottom(act.boxId, boxLo)
            box.set_bgcolor(act.boxId, color.new(coilCol, f_coilTransp(tightNow)))
        box.set_right(act.boxId, bar_index)

        brokeUp   = close > act.boxHigh
        brokeDown = close < act.boxLow

        if brokeUp or brokeDown
            dir = brokeUp ? 1 : -1
            bq  = f_breakQual(dir, atr14, atrBase)
            draw = not minBQFilter or bq >= minBQ
            act.state     := brokeUp ? ST_UP : ST_DOWN
            act.breakDir  := dir
            act.breakEdge := brokeUp ? act.boxHigh : act.boxLow
            act.breakBar  := bar_index
            act.breakQual := bq
            act.atrRef    := atr14
            act.mfe       := 0.0
            col = brokeUp ? bullCol : bearCol
            box.set_bgcolor(act.boxId, color.new(col, 78))
            box.set_border_color(act.boxId, color.new(col, 0))
            if draw
                sty = brokeUp ? label.style_label_up : label.style_label_down
                yy  = brokeUp ? low : high
                txt = (brokeUp ? "▲ BREAKOUT↑" : "▼ BREAKOUT↓") + "  Q " + str.tostring(bq, "#")
                act.tagId := label.new(bar_index, yy, txt, style = sty, color = color.new(col, 10), textcolor = color.white, size = size.small)
            trigBull := brokeUp
            trigBear := brokeDown

    // ── Active BREAKOUT (follow-through tracking window) ───────────────────
    else if act.state == ST_UP or act.state == ST_DOWN
        up = act.state == ST_UP
        // MFE: greatest favorable excursion beyond the broken edge
        exc = up ? high - act.breakEdge : act.breakEdge - low
        act.mfe := math.max(act.mfe, math.max(exc, 0))
        box.set_right(act.boxId, bar_index)

        // reclaim = lost the broken edge (excursed-then-reclaimed → reclaim wins)
        reclaimed = up ? close < act.boxHigh : close > act.boxLow
        elapsed   = (bar_index - act.breakBar) >= followWindow
        ftScore   = act.atrRef > 0 ? f_clamp((act.mfe / act.atrRef) / ftCapAtr, 0, 1) * 100 : na

        if reclaimed
            act.state        := ST_FAIL
            act.reclaim      := true
            act.followThrough:= ftScore
            box.set_bgcolor(act.boxId, color(na))                      // hollow footprint
            box.set_border_color(act.boxId, color.new(up ? bullCol : bearCol, 45))
            box.set_border_style(act.boxId, line.style_dashed)
            cooldownUntil := bar_index + cooldownBars
            trigFail := true
        else if elapsed
            act.state        := ST_HELD
            act.reclaim      := false
            act.followThrough:= ftScore
            box.set_bgcolor(act.boxId, color.new(up ? bullCol : bearCol, 88))  // solid dimmed
            box.set_border_color(act.boxId, color.new(up ? bullCol : bearCol, 30))
            cooldownUntil := bar_index + cooldownBars
            trigHeld := true

    // ── EXPIRE check (PRIMED aged with no break) ─────────────────────────
    act2 = coils.size() > 0 ? coils.last() : na
    if not na(act2) and act2.state == ST_PRIME and (bar_index - act2.armBar) > maxAge
        act2.state := ST_EXP
        box.set_bgcolor(act2.boxId, color.new(expireCol, 85))
        box.set_border_color(act2.boxId, color.new(expireCol, 40))
        box.set_border_style(act2.boxId, line.style_dotted)
        cooldownUntil := bar_index + cooldownBars

    // ── trim bounded history ─────────────────────────────────────────────
    if coils.size() > HIST_CAP
        coils.shift()

    // ── plot mirrors ─────────────────────────────────────────────────────
    Coil cur = coils.size() > 0 ? coils.last() : na
    if not na(cur)
        pBoxHigh := cur.boxHigh
        pBoxLow  := cur.boxLow
        pTight   := cur.tightness
        pBQual   := cur.breakQual
        pState   := cur.state
        pFT      := cur.followThrough

// ============================================================================
// HERO STATE TAG (thumbnail helper — off by default)
// ============================================================================
if showHeroTag and barstate.islast and coils.size() > 0
    Coil h = coils.last()
    if h.state == ST_PRIME
        label.new(bar_index, (h.boxHigh + h.boxLow) / 2, "PRIMED", style = label.style_label_center, color = color.new(coilCol, 15), textcolor = color.white, size = size.huge, xloc = xloc.bar_index)

// ============================================================================
// DASHBOARD
// ============================================================================
f_stateStr(int s) => s == 0 ? "COILING" : s == 1 ? "PRIMED" : s == 2 ? "BREAKOUT↑" : s == 3 ? "BREAKOUT↓" : s == 4 ? "HELD" : s == 5 ? "FAILED" : s == 6 ? "EXPIRED" : "—"
f_stateCol(int s) => s == 1 ? coilCol : s == 2 or s == 4 ? bullCol : s == 3 ? bearCol : s == 5 ? bearCol : s == 6 ? expireCol : txtCol

if showDash and barstate.islast
    Coil d   = coils.size() > 0 ? coils.last() : na
    sc       = na(d) ? int(na) : d.state
    agev     = na(d) ? int(na) : (d.state == ST_COIL ? d.dwell : bar_index - d.armBar)
    boxAtr   = na(d) or na(atr14) or atr14 == 0 ? float(na) : (d.boxHigh - d.boxLow) / atr14
    htfStr   = not useHtf ? "off" : htfBull ? "with ↑" : htfBear ? "with ↓" : "flat"
    sessStr  = not useSession ? "off" : inSession ? "in" : "out"

    t = table.new(position.top_right, 2, 9, bgcolor = panelBg, border_color = color.new(txtCol, 70), border_width = 1, frame_color = color.new(txtCol, 60), frame_width = 1)
    table.cell(t, 0, 0, "Compression Breakout", text_color = txtCol, text_size = size.normal, text_halign = text.align_left)
    table.cell(t, 1, 0, "▪ SlatinaTrades", text_color = color.new(txtCol, 30), text_size = size.small, text_halign = text.align_right)

    table.cell(t, 0, 1, "Compression",  text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 1, na(d) or na(d.tightness) ? "—" : str.tostring(d.tightness, "#"), text_color = txtCol, text_size = size.small, text_halign = text.align_right)

    table.cell(t, 0, 2, "Coil age",     text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 2, na(agev) ? "—" : str.tostring(agev), text_color = txtCol, text_size = size.small, text_halign = text.align_right)

    table.cell(t, 0, 3, "Squeeze %ile", text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 3, na(bbRank) ? "—" : str.tostring(bbRank, "#"), text_color = txtCol, text_size = size.small, text_halign = text.align_right)

    table.cell(t, 0, 4, "State",        text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 4, na(sc) ? "—" : f_stateStr(sc), text_color = color.white, bgcolor = na(sc) ? color(na) : color.new(f_stateCol(sc), 20), text_size = size.small, text_halign = text.align_right)

    table.cell(t, 0, 5, "Box ÷ ATR14",  text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 5, na(boxAtr) ? "—" : str.tostring(boxAtr, "#.##"), text_color = txtCol, text_size = size.small, text_halign = text.align_right)

    table.cell(t, 0, 6, "Follow-through", text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 6, na(d) or na(d.followThrough) ? "—" : str.tostring(d.followThrough, "#"), text_color = txtCol, text_size = size.small, text_halign = text.align_right)

    table.cell(t, 0, 7, "HTF align",    text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 7, htfStr, text_color = txtCol, text_size = size.small, text_halign = text.align_right)

    table.cell(t, 0, 8, "Session",      text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 8, sessStr, text_color = txtCol, text_size = size.small, text_halign = text.align_right)

// ============================================================================
// SEPARATION HARNESS — mean FT and reclaim % by tightness and break-quality quartile
// ============================================================================
if showStats and barstate.islast
    tKeys = array.new_float()
    qKeys = array.new_float()
    ftVal = array.new_float()
    rcVal = array.new_bool()
    n = coils.size()
    if n > 0
        for i = 0 to n - 1
            Coil r = coils.get(i)
            if (r.state == ST_HELD or r.state == ST_FAIL) and not na(r.tightness) and not na(r.breakQual) and not na(r.atrRef) and r.atrRef > 0
                tKeys.push(r.tightness)
                qKeys.push(r.breakQual)
                ftVal.push(r.mfe / r.atrRef)
                rcVal.push(r.reclaim)

    m = tKeys.size()
    byT = f_quartiles(tKeys, ftVal, rcVal)
    byQ = f_quartiles(qKeys, ftVal, rcVal)

    s = table.new(position.bottom_right, 5, 7, bgcolor = panelBg, border_color = color.new(txtCol, 70), border_width = 1, frame_color = color.new(txtCol, 60), frame_width = 1)
    // row 0 — title + quartile headers
    table.cell(s, 0, 0, "Separation harness  n=" + str.tostring(m), text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(s, 1, 0, "Q1", text_color = txtCol, text_size = size.small)
    table.cell(s, 2, 0, "Q2", text_color = txtCol, text_size = size.small)
    table.cell(s, 3, 0, "Q3", text_color = txtCol, text_size = size.small)
    table.cell(s, 4, 0, "Q4", text_color = txtCol, text_size = size.small)
    // tightness block (rows 1–3)
    table.cell(s, 0, 1, "▸ by TIGHTNESS",  text_color = coilCol, text_size = size.small, text_halign = text.align_left)
    table.cell(s, 0, 2, "  mean FT (ATR)", text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(s, 0, 3, "  reclaim %",     text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    // break-quality block (rows 4–6)
    table.cell(s, 0, 4, "▸ by BREAK-QUAL", text_color = coilCol, text_size = size.small, text_halign = text.align_left)
    table.cell(s, 0, 5, "  mean FT (ATR)", text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    table.cell(s, 0, 6, "  reclaim %",     text_color = txtCol, text_size = size.small, text_halign = text.align_left)
    for q = 0 to 3
        c = q + 1
        table.cell(s, c, 2, na(byT.get(q * 2))     ? "—" : str.tostring(byT.get(q * 2), "#.#"),      text_color = txtCol, text_size = size.small)
        table.cell(s, c, 3, na(byT.get(q * 2 + 1)) ? "—" : str.tostring(byT.get(q * 2 + 1), "#") + "%", text_color = txtCol, text_size = size.small)
        table.cell(s, c, 5, na(byQ.get(q * 2))     ? "—" : str.tostring(byQ.get(q * 2), "#.#"),      text_color = txtCol, text_size = size.small)
        table.cell(s, c, 6, na(byQ.get(q * 2 + 1)) ? "—" : str.tostring(byQ.get(q * 2 + 1), "#") + "%", text_color = txtCol, text_size = size.small)

// ============================================================================
// HIDDEN PLOTS FOR ALERTS (display.none, na-safe, names verbatim)
// ============================================================================
plot(nz(pBoxHigh), "boxHigh",     display = display.none)
plot(nz(pBoxLow),  "boxLow",      display = display.none)
plot(nz(pTight),   "tightness",   display = display.none)
plot(nz(pBQual),   "breakQual",   display = display.none)
plot(nz(pState),   "stateCode",   display = display.none)
plot(nz(pFT),      "followThrough", display = display.none)

// ============================================================================
// ALERTS (bidirectional + lifecycle; numeric state codes only)
// ============================================================================
alertcondition(trigPrimed, "New Coil Primed",        '{"sym":"{{ticker}}","tf":"{{interval}}","evt":"primed","state":{{plot("stateCode")}},"tight":{{plot("tightness")}},"bh":{{plot("boxHigh")}},"bl":{{plot("boxLow")}}}')
alertcondition(trigBull,   "Bull Breakout",           '{"sym":"{{ticker}}","tf":"{{interval}}","evt":"bull","state":{{plot("stateCode")}},"bq":{{plot("breakQual")}},"bh":{{plot("boxHigh")}},"bl":{{plot("boxLow")}}}')
alertcondition(trigBear,   "Bear Breakout",           '{"sym":"{{ticker}}","tf":"{{interval}}","evt":"bear","state":{{plot("stateCode")}},"bq":{{plot("breakQual")}},"bh":{{plot("boxHigh")}},"bl":{{plot("boxLow")}}}')
alertcondition(trigHeld,   "Follow-Through Confirmed", '{"sym":"{{ticker}}","tf":"{{interval}}","evt":"held","state":{{plot("stateCode")}},"ft":{{plot("followThrough")}}}')
alertcondition(trigFail,   "Reclaim",                 '{"sym":"{{ticker}}","tf":"{{interval}}","evt":"reclaim","state":{{plot("stateCode")}},"ft":{{plot("followThrough")}}}')
````
