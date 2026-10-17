# ICT Entry Model  Liquidity Sweep, MSS & FVG [LunqFX]

- url: https://www.tradingview.com/script/TP7yixOx-ICT-Entry-Model-Liquidity-Sweep-MSS-FVG-LunqFX/
- type: indicator
- pine_id: PUB;597cabf3dd5d432e91c3221190dba5a7
- version: 1.0

## Description

A smart-money entry is never a single signal — it is a sequence. Price runs the stops beyond a swing, structure shifts the other way, and the entry is taken from the imbalance that shift left behind. Most ICT indicators draw one of those pieces and leave you to assemble the rest by hand. This one tracks the whole sequence live and finishes it with an actual trade: entry, stop, target and a quality score that tells you whether the setup was worth taking at all.

❶ THE FOUR STAGES

▸ LIQUIDITY SWEEP — price trades beyond a swing high or low, takes the stops resting there, and closes back inside. The sweep is marked and the level it raided is drawn. This is the manipulation leg, and it is where the stop for the trade will sit.

▸ MSS (MARKET STRUCTURE SHIFT) — after the sweep, price closes through the last short-term swing in the opposite direction. This is the confirmation that the sweep was a reversal and not a continuation. Note that the shift is measured against internal structure, not the major swing: waiting for a major swing to break would put the entry far too late, which is the single most common mistake in automated ICT tools.

▸ FVG ENTRY — the displacement that broke structure leaves a three-candle imbalance. That gap is the entry zone, drawn as a box, because price commonly returns to fill it before continuing.

▸ RISK AND TARGET — the stop goes beyond the sweep extreme, the target is your chosen R multiple. Both are drawn as filled zones running back to the entry, so the whole trade reads as one object instead of a set of loose lines.

❷ SETUP QUALITY 0–100

Not every sequence deserves a trade, and this is where the indicator does something no other entry tool does. Every setup is graded on four measurable properties:

▸ SWEEP DEPTH — how far beyond the level price actually ran, in ATR. A deeper raid means more stops were genuinely taken. ▸ DISPLACEMENT — how decisively the structure was broken, in ATR. A weak break is a weak setup. ▸ FVG SIZE — how large the imbalance is. A bigger gap is a stronger entry. ▸ SPEED — how quickly the shift followed the sweep. A fast reversal is aggressive; a slow one has lost its edge.

The four are blended into a single 0–100 score shown on every entry tag and in the dashboard. Set the minimum quality in the settings and weak sequences simply stop being drawn — you trade the good ones instead of every arrow.

❸ HOW TO TRADE IT

1 — Wait for the SWEEP marker. The dashboard turns amber and reads SWEEP · WAITING MSS. Nothing to do yet: the manipulation has happened but it is not confirmed.

2 — Wait for MSS. When structure shifts, the setup is drawn and the dashboard turns green for a long or red for a short. If structure does not shift within the allowed window, the sweep is discarded and the model resets — no stale signals.

3 — Check the quality score before committing. High scores come from a deep sweep, a decisive break and a clean imbalance. If the number is low, the sequence was technically valid but structurally weak.

4 — Place the trade from the ticket. Entry at the FVG edge, stop beyond the sweep, target at your R multiple. The dashboard shows all three plus the exact risk in price, so the position size follows directly.

5 — Let price come to you. The FVG is a limit entry, not a market entry. If price never returns to the gap, the setup is simply skipped — that is the model working as intended.

❹ HOW IT WORKS

Liquidity swings and internal structure are detected with confirmed pivots, so a level only exists once the bars on both sides of it have closed. A sweep requires a bar to trade beyond the swing and close back inside it, and it is only registered when the shift level is still unbroken — otherwise the sequence could confirm itself on the very next bar. The structure shift requires a close through that internal level within your chosen window. The imbalance is found in the displacement leg using the standard three-candle definition. The stop is the sweep extreme, the target is the entry plus or minus the risk times your R multiple, and setups whose stop would be smaller than a fraction of ATR are rejected as untradeable. The quality score is a weighted blend of the four properties above, each normalised by ATR so the score behaves the same on every symbol and timeframe.

Works on any market and timeframe — forex, gold, indices, crypto and stocks. Intraday charts from 5m to 4h suit the model best, since that is where liquidity raids and structure shifts happen most often.

SETTINGS — liquidity swing length, internal structure length, maximum bars from sweep to shift, R multiple for the target, minimum stop distance, minimum quality, number of setups kept, level extension, FVG and level visibility, candle colouring and dashboard position.

ALERTS — long setup confirmed, short setup confirmed, and any setup confirmed. All fire on closed bars only.

NON-REPAINTING — every stage is validated on bar close and built from confirmed pivots. A setup that has printed never moves, never changes its levels and never disappears.

The four stages are not four indicators bundled together — they are four steps of one entry model, and none of them is tradeable alone. The sweep without the shift is just a wick; the shift without the sweep is just a break; the imbalance without either is just a gap. That is why they belong in a single tool.

This indicator is an educational market-analysis tool, not financial advice. The quality score describes the structure of a setup and does not predict its outcome. Always confirm with your own analysis and manage your risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  ICT Entry Model — Liquidity Sweep, MSS & FVG Entry with SL/TP [LunqFX]
// ----------------------------------------------------------------------------
//  One model, start to finish. Smart-money entries are not a single signal —
//  they are a SEQUENCE, and this tool tracks that sequence live:
//
//      1  LIQUIDITY SWEEP — price runs the stops beyond a swing and rejects
//      2  MSS            — structure shifts the other way (the confirmation)
//      3  FVG ENTRY      — the imbalance left by the displacement is the entry
//      4  SL / TP        — stop beyond the sweep, target from your R multiple
//
//  Each of the four steps is one stage of the same setup, which is why they
//  live in one indicator: on their own they are not tradeable, in sequence
//  they are the complete ICT entry model.
//
//  SETUP QUALITY 0-100 — original: not every sequence is worth taking. The
//  score grades the sweep depth (how many stops were actually taken), the
//  displacement strength, the size of the FVG and how fast the shift happened,
//  so you can skip weak setups instead of trading every arrow.
//
//  NON-REPAINTING: swings come from confirmed pivots, sweeps and the structure
//  shift are validated on closed bars. A printed setup never moves.
// ============================================================================
indicator("ICT Entry Model — Liquidity Sweep, MSS & FVG Entry with SL/TP [LunqFX]",
     "ICT Entry Model [LunqFX]", overlay = true,
     max_lines_count = 200, max_labels_count = 200, max_boxes_count = 100)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE — designed for a LIGHT chart (pale cyan → white gradient).
//  Deep saturated hues, all far from the background's cyan, so every element
//  separates by darkness as well as by colour.
// ─────────────────────────────────────────────────────────────────────────
GREEN     = #15803D          // bullish setup / take profit
GREEN_D   = #0B5227
GREEN_TXT = #6BE79B          // bright — text on the dark card
RED       = #B91C1C          // bearish setup / stop loss
RED_D     = #7F1414
RED_TXT   = #FF9090
AMBER     = #B45309          // the liquidity sweep — its own identity
AMBER_TXT = #FFC46B
SLATE     = #1E293B          // entry line, neutral
INK       = #101720          // label plates
CARD      = #131A24          // floating dark panel on a light chart
TXT       = #F1F5F9
MUTE      = #94A3B8

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gM      = "Model"
pivLen  = input.int(8,  "Liquidity swing length", minval = 2, maxval = 50, group = gM, tooltip = "Which swings hold the stops that get swept. Higher = only major liquidity.")
intLen  = input.int(3,  "Internal structure length", minval = 1, maxval = 20, group = gM, tooltip = "The short-term swing whose break confirms the shift. This is what price must close through after the sweep — not the major swing.")
maxWait = input.int(20, "Max bars sweep → MSS", minval = 3, maxval = 100, group = gM, tooltip = "If structure does not shift within this many bars the sweep is discarded.")
rrMult  = input.float(2.0, "Take profit (R)", minval = 0.5, maxval = 10, step = 0.5, group = gM)
minRisk = input.float(0.20, "Min stop distance (× ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = gM, tooltip = "Rejects setups where the FVG edge sits almost on the sweep, which would leave an untradeable micro-stop.")
minQual = input.int(0, "Hide setups below quality", minval = 0, maxval = 90, group = gM)

gV      = "Visuals"
showFVG = input.bool(true, "FVG entry zone", group = gV)
showSL  = input.bool(true, "SL / TP levels", group = gV)
keepN   = input.int(3, "Setups kept on chart", minval = 1, maxval = 12, group = gV, tooltip = "Lower this on fast timeframes where setups come close together.")
extR    = input.int(7, "Extend levels (bars)", minval = 2, maxval = 60, group = gV, tooltip = "How far right the level lines run before their price tag. Keep it short so the newest setup's tags stay inside the visible chart.")
candOn  = input.bool(true, "Clean candles", group = gV, tooltip = "Neutral candle colours so the setup stays the hero.")

gP      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group = gP)
hudPos  = input.string("Top Right","Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  SWINGS  (confirmed pivots — the liquidity pools)
// ─────────────────────────────────────────────────────────────────────────
atr14 = ta.atr(14)
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)

var float swHigh = na
var float swLow  = na
var int   swHighBar = na
var int   swLowBar  = na
var bool  hiTaken = false
var bool  loTaken = false

if not na(ph)
    swHigh    := ph
    swHighBar := bar_index - pivLen
    hiTaken   := false
if not na(pl)
    swLow    := pl
    swLowBar := bar_index - pivLen
    loTaken  := false

// internal (short-term) structure — this is the level the shift must break
iph = ta.pivothigh(intLen, intLen)
ipl = ta.pivotlow(intLen, intLen)
var float intHigh    = na
var int   intHighBar = na
var float intLow     = na
var int   intLowBar  = na
if not na(iph)
    intHigh    := iph
    intHighBar := bar_index - intLen
if not na(ipl)
    intLow    := ipl
    intLowBar := bar_index - intLen

// ─────────────────────────────────────────────────────────────────────────
//  STATE MACHINE:  0 idle → 1 swept → setup fires on MSS
// ─────────────────────────────────────────────────────────────────────────
var int   state     = 0
var int   dir       = 0        // 1 bullish setup, -1 bearish
var float sweepExt  = na       // the extreme of the sweep = stop level
var int   sweepBar  = na
var float sweptLvl  = na       // the swing level that was run
var float mssLevel  = na       // level whose break confirms the shift
var int   mssLevBar = na
var int   waited    = 0

newSetup = false
setupDir = 0

// ── stage 1: liquidity sweep (wick through, close back inside) ──
// The shift level must still be UNBROKEN at the moment of the sweep, otherwise
// the sequence would "confirm" itself on the very next bar.
if barstate.isconfirmed and state == 0
    if not na(swLow) and not loTaken and low < swLow and close > swLow and not na(intHigh) and intHigh > close
        loTaken  := true
        state    := 1
        dir      := 1
        sweepExt := low
        sweepBar := bar_index
        sweptLvl := swLow
        mssLevel := intHigh
        mssLevBar:= intHighBar
        waited   := 0
    else if not na(swHigh) and not hiTaken and high > swHigh and close < swHigh and not na(intLow) and intLow < close
        hiTaken  := true
        state    := 1
        dir      := -1
        sweepExt := high
        sweepBar := bar_index
        sweptLvl := swHigh
        mssLevel := intLow
        mssLevBar:= intLowBar
        waited   := 0

// ── stage 2: market structure shift confirms the sweep ──
mssFired = false
if barstate.isconfirmed and state == 1
    waited += 1
    if waited > maxWait
        state := 0                      // sequence expired, discard
    else
        if dir == 1 and not na(mssLevel) and close > mssLevel
            mssFired := true
        if dir == -1 and not na(mssLevel) and close < mssLevel
            mssFired := true

// ─────────────────────────────────────────────────────────────────────────
//  STAGE 3: find the FVG left by the displacement leg
// ─────────────────────────────────────────────────────────────────────────
var array<line>  sLn = array.new<line>()
var array<label> sLb = array.new<label>()
var array<box>   sBx = array.new<box>()
// Every drawing remembers which setup it belongs to, so a setup is always
// retired as a whole. Counting objects instead would break the moment one
// setup draws a different number of them than another.
var array<int>   lnSeq = array.new<int>()
var array<int>   lbSeq = array.new<int>()
var array<int>   bxSeq = array.new<int>()
// Price tags live only on the newest setup. On low timeframes setups cluster,
// and three tags per setup times four setups is unreadable — older setups keep
// their zones and their SWEEP / MSS markers, which is what you actually read.
var array<label> tagLb = array.new<label>()

// Every setup adds the SAME number of lines and labels (sweep, MSS, entry and,
// when levels are on, SL and TP). Trimming them with one shared limit keeps a
// setup's line and its price tag alive together — otherwise the lines get
// deleted first and orphaned labels are left floating with nothing attached.
trimAll(int seq) =>
    cutoff = seq - keepN
    while array.size(lnSeq) > 0 and array.get(lnSeq, 0) <= cutoff
        line.delete(array.shift(sLn))
        array.shift(lnSeq)
    while array.size(lbSeq) > 0 and array.get(lbSeq, 0) <= cutoff
        label.delete(array.shift(sLb))
        array.shift(lbSeq)
    while array.size(bxSeq) > 0 and array.get(bxSeq, 0) <= cutoff
        box.delete(array.shift(sBx))
        array.shift(bxSeq)

var int setupSeq = 0        // staggers the price tags of nearby setups

// live setup values for the dashboard
var float uEntry = na
var float uSL    = na
var float uTP    = na
var int   uDir   = 0
var int   uQual  = 0

if mssFired
    // scan the displacement leg for the most recent 3-bar imbalance
    fvgT = 0.0
    fvgB = 0.0
    fvgAt = -1
    // the imbalance belongs to the displacement leg, so it is close by — a wide
    // search would find a stale gap and stretch its box across the screen
    span = math.min(waited + 4, 18)
    for j = 0 to span
        if fvgAt < 0
            if dir == 1 and low[j] > high[j + 2]
                fvgT := low[j]
                fvgB := high[j + 2]
                fvgAt := j
            if dir == -1 and high[j] < low[j + 2]
                fvgT := low[j + 2]
                fvgB := high[j]
                fvgAt := j

    // entry at the near edge of the FVG; if none formed, entry at the shift level
    entry = fvgAt >= 0 ? (dir == 1 ? fvgT : fvgB) : mssLevel
    sl    = sweepExt
    risk  = math.abs(entry - sl)
    tp    = dir == 1 ? entry + risk * rrMult : entry - risk * rrMult

    // ── SETUP QUALITY 0-100 ──
    a      = math.max(nz(atr14), syminfo.mintick)          // never divide by 0/na
    depth  = math.abs(sweepExt - sweptLvl) / a
    disp   = math.abs(close - mssLevel) / a
    fSize  = fvgAt >= 0 ? math.abs(fvgT - fvgB) / a : 0.0
    qSweep = math.min(1.0, depth / 0.45) * 100
    qDisp  = math.min(1.0, disp / 1.20) * 100
    qFvg   = math.min(1.0, fSize / 0.40) * 100
    qSpeed = math.max(0.0, 1.0 - waited / float(maxWait)) * 100
    qual   = int(math.round(0.30 * qSweep + 0.30 * qDisp + 0.25 * qFvg + 0.15 * qSpeed))

    // entry must sit on the correct side of the stop AND leave a tradeable stop
    valid = risk > a * minRisk and (dir == 1 ? entry > sl : entry < sl)

    if qual >= minQual and valid
        newSetup := true
        setupDir := dir
        uEntry := entry
        uSL := sl
        uTP := tp
        uDir := dir
        uQual := qual

        col  = dir == 1 ? GREEN : RED
        setupSeq += 1
        xB   = bar_index + extR          // right edge of the trade zones
        xSL  = xB
        xEnt = xB + 5                    // small ladder so tags never overlap
        xTP  = xB + 10

        // 1) sweep marker
        array.push(sLb, label.new(sweepBar, sweepExt, " SWEEP ", style = dir == 1 ? label.style_label_up : label.style_label_down, color = color.new(AMBER, 0), textcolor = color.white, size = size.large))
        array.push(lbSeq, setupSeq)
        array.push(sLn, line.new(sweepBar, sweptLvl, bar_index, sweptLvl, color = color.new(AMBER, 15), width = 2, style = line.style_dotted))
        array.push(lnSeq, setupSeq)

        // 2) MSS line
        array.push(sLn, line.new(mssLevBar, mssLevel, bar_index, mssLevel, color = color.new(col, 0), width = 3))
        array.push(lnSeq, setupSeq)
        array.push(sLb, label.new(math.round(math.avg(mssLevBar, bar_index)), mssLevel, " MSS ", style = label.style_label_center, color = color.new(col, 0), textcolor = color.white, size = size.large))
        array.push(lbSeq, setupSeq)

        // 3) FVG entry zone
        if showFVG and fvgAt >= 0
            array.push(sBx, box.new(bar_index - fvgAt - 2, fvgT, xB, fvgB, border_color = color.new(col, 40), bgcolor = color.new(col, 78)))
            array.push(bxSeq, setupSeq)

        // 4) RISK and REWARD zones — the target is the top of a filled block
        //    that runs back to the entry, so it reads as one trade instead of a
        //    lone line floating somewhere above the chart.
        if showSL
            array.push(sBx, box.new(bar_index, math.max(entry, sl), xB, math.min(entry, sl), border_color = color.new(RED, 55), bgcolor = color.new(RED, 88)))
            array.push(bxSeq, setupSeq)
            array.push(sBx, box.new(bar_index, math.max(entry, tp), xB, math.min(entry, tp), border_color = color.new(GREEN, 55), bgcolor = color.new(GREEN, 88)))
            array.push(bxSeq, setupSeq)

        // 5) entry line + price tags (newest setup only)
        array.push(sLn, line.new(bar_index, entry, xEnt, entry, color = color.new(SLATE, 5), width = 3, style = line.style_dashed))
        array.push(lnSeq, setupSeq)

        // retire the previous setup's tags before drawing this one's
        if array.size(tagLb) > 0
            for i = 0 to array.size(tagLb) - 1
                label.delete(array.get(tagLb, i))
            array.clear(tagLb)

        array.push(tagLb, label.new(xEnt, entry, "  ENTRY  " + str.tostring(entry, format.mintick) + "  ·  Q" + str.tostring(qual) + "  ", style = label.style_label_left, color = color.new(INK, 0), textcolor = dir == 1 ? GREEN_TXT : RED_TXT, size = size.large))
        if showSL
            array.push(tagLb, label.new(xSL, sl, "  SL  " + str.tostring(sl, format.mintick) + "  ", style = label.style_label_left, color = color.new(RED, 0), textcolor = color.white, size = size.large))
            array.push(tagLb, label.new(xTP, tp, "  TP  " + str.tostring(tp, format.mintick) + "  ·  " + str.tostring(rrMult, "#.#") + "R  ", style = label.style_label_left, color = color.new(GREEN, 0), textcolor = color.white, size = size.large))
        trimAll(setupSeq)
    state := 0                          // sequence complete either way

// ─────────────────────────────────────────────────────────────────────────
//  CLEAN CANDLES — neutral, so the setup colours stay the hero on a light chart
// ─────────────────────────────────────────────────────────────────────────
// Deep petrol-slate: related to the background's cyan in hue but far darker, so
// the candles harmonise with the chart instead of fighting it, and never clash
// with the green/red of the model. Hollow up, solid down.
CANDLE = #2F4858
isUp   = close >= open
cBody  = isUp ? #FFFFFF : CANDLE
plotcandle(candOn ? open : na, high, low, close, title = "Candles", color = cBody, wickcolor = CANDLE, bordercolor = CANDLE)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
hudPosition(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

// A TRADE TICKET, not a stats table: coloured header carries the direction,
// then the three prices that actually matter, then the risk line.
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(hudPosition(hudPos), 2, 5, bgcolor = CARD, border_color = color.new(#28323F, 0), border_width = 1, frame_width = 0)

    waiting = state == 1
    hdrBg = waiting ? AMBER : uDir == 1 ? GREEN : uDir == -1 ? RED : #33404F
    hdrTx = waiting ? (dir == 1 ? "▲  SWEEP · WAITING MSS" : "▼  SWEEP · WAITING MSS") : uDir == 1 ? "▲  LONG SETUP" : uDir == -1 ? "▼  SHORT SETUP" : "SCANNING"
    qTx   = uDir == 0 ? "" : "Q " + str.tostring(uQual) + "  "

    // header
    table.cell(hud, 0, 0, "  " + hdrTx + "  ", text_color = color.white, text_size = size.large, text_halign = text.align_left, bgcolor = hdrBg)
    table.cell(hud, 1, 0, qTx, text_color = color.white, text_size = size.large, text_halign = text.align_right, bgcolor = hdrBg)

    // the ticket body — while a new sweep is pending these are the LAST setup's
    // levels, so they are labelled as such instead of pretending to be live
    pfx = waiting ? "LAST " : ""
    dim = waiting ? 45 : 0
    table.cell(hud, 0, 1, "  " + pfx + "ENTRY", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 1, (na(uEntry) ? "—" : str.tostring(uEntry, format.mintick)) + "  ", text_color = color.new(TXT, dim), text_size = size.huge, text_halign = text.align_right, bgcolor = CARD)

    table.cell(hud, 0, 2, "  " + pfx + "STOP", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 2, (na(uSL) ? "—" : str.tostring(uSL, format.mintick)) + "  ", text_color = color.new(RED_TXT, dim), text_size = size.large, text_halign = text.align_right, bgcolor = CARD)

    table.cell(hud, 0, 3, "  " + pfx + "TARGET", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 3, (na(uTP) ? "—" : str.tostring(uTP, format.mintick)) + "  ", text_color = color.new(GREEN_TXT, dim), text_size = size.large, text_halign = text.align_right, bgcolor = CARD)

    // risk line
    rTx = na(uEntry) or na(uSL) ? "—" : "RISK " + str.tostring(math.abs(uEntry - uSL), format.mintick) + "   ·   1 : " + str.tostring(rrMult, "#.#") + " R"
    table.cell(hud, 0, 4, "  " + rTx, text_color = color.new(TXT, 35), text_size = size.normal, text_halign = text.align_left, bgcolor = color.new(#1B242F, 0))
    table.cell(hud, 1, 4, "LunqFX  ", text_color = MUTE, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(#1B242F, 0))

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(newSetup and setupDir ==  1, "Long setup",  "LunqFX ICT Entry Model: long setup — sweep, MSS and FVG entry confirmed")
alertcondition(newSetup and setupDir == -1, "Short setup", "LunqFX ICT Entry Model: short setup — sweep, MSS and FVG entry confirmed")
alertcondition(newSetup,                    "Any setup",   "LunqFX ICT Entry Model: new setup confirmed")
````
