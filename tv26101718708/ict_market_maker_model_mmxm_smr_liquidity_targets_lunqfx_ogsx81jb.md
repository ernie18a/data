# ICT Market Maker Model MMXM, SMR, Liquidity & Targets [LunqFX]

- url: https://www.tradingview.com/script/ogSx81Jb-ICT-Market-Maker-Model-MMXM-SMR-Liquidity-Targets-LunqFX/
- type: indicator
- pine_id: PUB;4c2d12b5ef5c46dfaf8394223af91a16
- version: 1.0

## Description

ICT Market Maker Model draws the full MMXM on your chart and tracks it from start to finish: the original consolidation, the curve that engineers liquidity, the smart money reversal (SMR) and the return to the origin. It marks every buy side and sell side liquidity sweep along the way, confirms the reversal with a market structure shift (MSS), projects the model's three targets — and keeps a record of how often market maker buy and sell models on this symbol actually reached them.

Most market maker model indicators mark a reversal and stop there. Where the model started, how deep the curve went, where the targets are and whether the model ever completes on your market is left to you. This one runs the ICT market maker model as a state machine, stage by stage, and turns every finished model into a measured result in the panel — so before you rely on the model forming now, you can see how often buy models (MMBM) and sell models (MMSM) on this symbol made it back to the origin.

❶ THE FOUR STAGES OF THE MARKET MAKER MODEL
① ORIGINAL CONSOLIDATION — a stretch of bars whose whole range fits inside a set width in ATR, drawn as a box. This is where the model starts and where price is expected to return.
② ENGINEERING LIQUIDITY — price leaves the consolidation and builds a curve away from it in steps. In a market maker buy model (MMBM) each step is a lower low that sweeps sell side liquidity, marked SSL 1, SSL 2…; in a market maker sell model (MMSM) each step is a higher high that sweeps buy side liquidity, marked BSL 1, BSL 2…
③ SMART MONEY REVERSAL — once the curve has made the minimum number of steps and travelled far enough from the consolidation, a close beyond the last opposite swing before the extreme is the market structure shift. That swing must sit deep in the curve, beyond its equilibrium: in ICT terms the reversal happens in discount (buy model) or in premium (sell model), not back near the consolidation. The extreme is labelled SMR, the broken swing MSS.
④ RETURN CURVE — price travels back toward the origin. The model is complete when it trades back to the far side of the original consolidation.

If price closes beyond the other side of the consolidation before any reversal, or the curve runs past the expiry, the attempt is erased — the chart keeps only real models.

❷ TARGETS AND INVALIDATION
After the smart money reversal the model projects three targets:
▸ T1 · EQ — the equilibrium, halfway between the extreme and the consolidation
▸ T2 · OC edge — the near side of the original consolidation
▸ T3 · OC origin — the far side of the consolidation; reaching it completes the model
T2 and T3 lines start at the consolidation box itself, so you can see where the targets come from: a buy model's targets always sit above the reversal, a sell model's below.
▸ INVALID — the SMR extreme. If price trades beyond it, the model fails.
Each target gets a ✓ when it trades. When the MSS candle already closes past the equilibrium, T1 is ticked on that candle. A finished model is labelled MODEL COMPLETE with the number of bars it took, MODEL FAILED, or EXPIRED, with the furthest target reached.

❸ THE TRACK RECORD
Every finished model is filed by direction. For buy models, sell models and all models on this symbol the panel shows: the number of models, the share that reached T2 (back at the consolidation), the share that completed (T3), the share that failed, and the average time to completion. T1 is left out on purpose — the market structure shift can close past the equilibrium on its own, so a T1 rate would flatter the model.

❹ THE PANEL
▸ Current stage, with progress dots ● ● ○ ○
▸ Model direction: BUY MODEL · MMBM or SELL MODEL · MMSM
▸ Liquidity steps taken (SSL or BSL) and curve depth in ATR, with the minimum required
▸ Return to origin — how far the return curve has travelled, in %
▸ T1, T2, T3 and the invalidation level, ticked as they are hit
▸ The track record table

❺ HOW TO USE IT
1. Watch for an ORIGINAL CONSOLIDATION box. When price leaves it, the panel shows which model may be forming.
2. Follow the liquidity steps. A buy model needs sell side liquidity swept below; a sell model needs buy side liquidity swept above. A curve that ends at a higher-timeframe level — an old high or low, an order block, a fair value gap — is the classic ICT context for the reversal.
3. The SMR label and the MSS line mark the smart money reversal. Use your own entry model for timing and risk.
4. T1, T2 and T3 are the model's draw on liquidity. Check the track record first: it shows how far models usually go on this symbol and timeframe.
5. Works on forex, gold (XAUUSD), index CFDs and crypto, 5m to 4H.

[b]Tip: the curve can be drawn Smooth or Straight[/b] — Settings → Drawing → Curve style.

❻ SETTINGS
Model
▸ Consolidation length (bars) and max width (× ATR) — what counts as the original consolidation
▸ Swing strength — bars on each side that confirm a swing high or low
▸ Min. liquidity steps — how many SSL or BSL sweeps the curve needs before a reversal counts
▸ Min. curve depth (× ATR) — how far price must travel from the consolidation
▸ Model expiry (bars) — when an unfinished model is closed
Drawing
▸ Draw the curves — on or off
▸ [b]Curve style — Smooth or Straight.[/b] Smooth (default) rounds the curve between the liquidity steps. Straight joins them with straight segments, exactly through each swing. Settings → Drawing → Curve style.
▸ Mark liquidity steps (SSL / BSL) · Targets and invalidation
▸ Models drawn — how many finished models stay on the chart; the track record keeps all of them
▸ Label size
Panel
▸ Show panel · position · text size
Alerts
▸ Model forming · Smart money reversal · Target hit / model complete / failed
Visuals
▸ Neon candles — turquoise for rising candles, pink for falling, matching the buy and sell models; the consolidation and targets are drawn in neon violet. Off = your own chart candles.
▸ Glow candles — each body brightens towards the close. Off = flat neon bodies.

❼ ALERTS
▸ Model forming — the original consolidation is broken
▸ Smart money reversal — with T1, T2, T3 and the invalidation level
▸ Target hit, model complete, model failed
Create the alert with "Any alert() function call" for the full messages with prices. Separate alert conditions exist for buy model reversal, sell model reversal, target hit, model complete and model failed; "model forming" is sent through alert() only.

❽ NON-REPAINTING
Every stage change, target hit and failure is decided on closed bars. Swings are confirmed pivots, so a liquidity step or an MSS level is known a few bars after the swing itself — that delay is shown as it is, nothing is drawn back in time. The script does not use request.security or lookahead.

LIMITATIONS
▸ The Market Maker Model is a discretionary ICT concept. This script uses one objective version of it (consolidation by ATR width, steps by confirmed swings, MSS by a close beyond the last opposite swing). Other traders may read the same move differently.
▸ Swing confirmation delays steps and the MSS level by the "swing strength" number of bars.
▸ Only one model is tracked at a time; a new consolidation is not searched while a model is running.
▸ Higher-timeframe context (where the curve ends) is not checked automatically — it stays part of your own analysis.
▸ The track record covers only the history loaded on your chart and only finished models. Small samples are noisy, so check the "Models" column before trusting a percentage. Past rates are not a forecast.
▸ The model gives a structure and targets, not an entry. It has no stop loss or position sizing; combine it with your own entry model and risk rules.

This script is for educational purposes only and is not financial advice. Trading involves risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  ICT Market Maker Model MMXM, SMR, Liquidity & Targets [LunqFX]
// ----------------------------------------------------------------------------
//  Tracks the ICT Market Maker Model through its four stages — original
//  consolidation, the engineering-liquidity curve, the smart money reversal
//  and the return curve to the origin — draws the whole curve, projects the
//  model's three targets, and keeps a record of how often models on this
//  symbol actually reached each target.
//
//  NON-REPAINTING: every stage change, target hit and failure is decided on
//  closed bars. Swings are confirmed pivots. No request.security, no lookahead.
// ============================================================================
indicator("ICT Market Maker Model MMXM, SMR, Liquidity & Targets [LunqFX]", "MMXM [LunqFX]",
     overlay = true, max_lines_count = 300, max_labels_count = 300, max_boxes_count = 60, max_polylines_count = 60)

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gM = "Model"
consLen  = input.int(20, "Consolidation length (bars)", minval = 8, maxval = 100, group = gM,
     tooltip = "The original consolidation is a stretch of this many bars whose whole range fits inside the width below.")
consMult = input.float(2.5, "Consolidation max width (× ATR)", minval = 1.0, maxval = 8.0, step = 0.1, group = gM)
pivLen   = input.int(3, "Swing strength", minval = 2, maxval = 10, group = gM, tooltip = "Bars on each side that confirm a swing high or low.")
minSteps = input.int(2, "Min. liquidity steps", minval = 1, maxval = 6, group = gM,
     tooltip = "How many successive lower lows (buy model) or higher highs (sell model) the engineering curve must make before a reversal counts.")
legMin   = input.float(3.0, "Min. curve depth (× ATR)", minval = 1.0, maxval = 20.0, step = 0.5, group = gM,
     tooltip = "How far price must travel away from the consolidation before a smart money reversal counts.")
maxLeg   = input.int(400, "Model expiry (bars)", minval = 50, maxval = 2000, group = gM)

gD = "Drawing"
showCurve = input.bool(true, "Draw the curves", group = gD)
curveSty  = input.string("Smooth", "Curve style", options = ["Smooth", "Straight"], group = gD,
     tooltip = "Smooth rounds the curve between the swings it passes through. Straight joins them with straight segments, exactly through each swing.")
showSteps = input.bool(true, "Mark liquidity steps (SSL / BSL)", group = gD)
showTgt   = input.bool(true, "Targets and invalidation", group = gD)
keepN     = input.int(3, "Models drawn", minval = 1, maxval = 20, group = gD, tooltip = "Finished models older than this are removed from the chart. The track record keeps all of them.")
lblSize   = input.string("Normal", "Label size", options = ["Small", "Normal", "Large"], group = gD)

gP = "Panel"
showTbl  = input.bool(true, "Show panel", group = gP)
tblPos   = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = gP)
tblSize  = input.string("Normal", "Text size", options = ["Small", "Normal", "Large"], group = gP)

gA = "Alerts"
alForm   = input.bool(true, "Alert: model forming (consolidation broken)", group = gA)
alSmr    = input.bool(true, "Alert: smart money reversal", group = gA)
alTgt    = input.bool(true, "Alert: target hit / model complete / failed", group = gA)

candOn_  = input.bool(true, "Neon candles", group = "Visuals")
candGlw  = input.bool(true, "Glow candles", group = "Visuals", tooltip = "Each body is drawn in four bands that brighten towards the close, so the candle reads in the direction it moved. Off = flat translucent bodies.")

// ─────────────────────────────────────────────────────────────────────────
//  THEME
// ─────────────────────────────────────────────────────────────────────────
bgLum   = 0.2126 * color.r(chart.bg_color) + 0.7152 * color.g(chart.bg_color) + 0.0722 * color.b(chart.bg_color)
isLight = bgLum > 128
UP      = isLight ? #00A896 : #00F5D4   // turquoise: buy models, rising candles
DN      = isLight ? #E0115F : #FF2E88   // pink: sell models, falling candles
TGT     = isLight ? #7B1FD6 : #B026FF   // neon violet: consolidation and target lines
TGTX    = isLight ? #6A1BB8 : #D7A6FF   // light violet for text, readable on a dark chart
VIOLET  = isLight ? #7B1FD6 : #B026FF
GREY    = isLight ? #8A8F9C : #6B7080
TXT     = isLight ? #1A1D24 : #E8EAF0
MUTE    = isLight ? #5E6472 : #9AA0AE
PANEL   = isLight ? #FFFFFF : #0B0E14
ROW     = isLight ? #F1F3F7 : #141823
INK     = #0B0E14
NONE    = color.new(color.black, 100)

lSize = lblSize == "Small" ? size.small : lblSize == "Large" ? size.large : size.normal
tSize = tblSize == "Small" ? size.small : tblSize == "Large" ? size.large : size.normal

px(float v) =>
    str.tostring(v, format.mintick)

pct(int a, int b) =>
    b > 0 ? str.tostring(a * 100.0 / b, "0") + "%" : "—"

// ─────────────────────────────────────────────────────────────────────────
//  SERIES (computed on every bar)
// ─────────────────────────────────────────────────────────────────────────
atr  = ta.atr(50)
hh   = ta.highest(high, consLen)
ll   = ta.lowest(low, consLen)
compress = not na(atr) and hh - ll <= consMult * atr
ph   = ta.pivothigh(high, pivLen, pivLen)
pl   = ta.pivotlow(low, pivLen, pivLen)
pBar = bar_index - pivLen

// ─────────────────────────────────────────────────────────────────────────
//  STATE
//  stage 0 searching · 1 original consolidation · 2 engineering liquidity
//  stage 3 smart money reversal confirmed, return curve running
//  dir  1 = buy model (MMBM: curve down first, then back up)
//  dir -1 = sell model (MMSM: curve up first, then back down)
// ─────────────────────────────────────────────────────────────────────────
var int   stage   = 0
var int   dir     = 0
var float ocTop   = na
var float ocBot   = na
var int   ocL     = na
var int   ocR     = na
var float legExt  = na
var int   legExtBar = na
var int   legStart  = na
var float prevPiv = na
var int   steps   = 0
var float lastSw  = na     // the swing the reversal must break (formed before the extreme)
var int   lastSwBar = na
var float recentSw = na    // the latest confirmed opposite swing
var int   recentSwBar = na
var float t1 = na
var float t2 = na
var float t3 = na
var float inv = na
var int   smrBar  = na
var int   hitMax  = 0

var array<chart.point> pts    = array.new<chart.point>()
var array<chart.point> retPts = array.new<chart.point>()
var array<label>       stepLbs = array.new<label>()

var box      ocBox  = na
var polyline legPl  = na
var polyline retPl  = na
var line     t1Ln = na
var line     t2Ln = na
var line     t3Ln = na
var line     invLn = na
var label    t1Lb = na
var label    t2Lb = na
var label    t3Lb = na
var label    invLb = na
var label    smrLb = na

// record: index 0 = buy models, 1 = sell models
var array<int> rN    = array.new_int(2, 0)
var array<int> rT1   = array.new_int(2, 0)
var array<int> rT2   = array.new_int(2, 0)
var array<int> rT3   = array.new_int(2, 0)
var array<int> rFail = array.new_int(2, 0)
var array<int> rBars = array.new_int(2, 0)

evForm = false
evSmr  = false
evHit  = 0
evFrom = 0
evDone = false
evFail = false
evEnd  = false

bump(array<int> a, int i, int add) =>
    array.set(a, i, array.get(a, i) + add)

// ── drawing registry: every object of a real model is filed under its id,
//    so only the last "Models drawn" models stay on the chart
var int mid = 0
var array<line>     gLn  = array.new<line>()
var array<int>      gLnI = array.new_int()
var array<label>    gLb  = array.new<label>()
var array<int>      gLbI = array.new_int()
var array<box>      gBx  = array.new<box>()
var array<int>      gBxI = array.new_int()
var array<polyline> gPl  = array.new<polyline>()
var array<int>      gPlI = array.new_int()

regLn(line o) =>
    array.push(gLn, o)
    array.push(gLnI, mid)
regLb(label o) =>
    array.push(gLb, o)
    array.push(gLbI, mid)
regBx(box o) =>
    array.push(gBx, o)
    array.push(gBxI, mid)
regPl(polyline o) =>
    array.push(gPl, o)
    array.push(gPlI, mid)

prune(int upTo) =>
    while array.size(gLnI) > 0 and array.get(gLnI, 0) <= upTo
        line.delete(array.shift(gLn))
        array.shift(gLnI)
    while array.size(gLbI) > 0 and array.get(gLbI, 0) <= upTo
        label.delete(array.shift(gLb))
        array.shift(gLbI)
    while array.size(gBxI) > 0 and array.get(gBxI, 0) <= upTo
        box.delete(array.shift(gBx))
        array.shift(gBxI)
    while array.size(gPlI) > 0 and array.get(gPlI, 0) <= upTo
        polyline.delete(array.shift(gPl))
        array.shift(gPlI)

// ─────────────────────────────────────────────────────────────────────────
//  STATE MACHINE — closed bars only
// ─────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed and not na(atr)

    // ── 3 · return curve: targets in order, invalidation beyond the SMR extreme
    if stage == 3
        evFrom := hitMax
        failNow = dir == 1 ? low < inv : high > inv
        if failNow
            evFail := true
        else
            for k = 1 to 3
                tk = k == 1 ? t1 : k == 2 ? t2 : t3
                if hitMax == k - 1 and (dir == 1 ? high >= tk : low <= tk)
                    hitMax := k
                    evHit := k
        // the return curve follows confirmed swings in the new direction
        if dir == 1 and not na(pl) and pBar > smrBar
            array.push(retPts, chart.point.from_index(pBar, pl))
        if dir == -1 and not na(ph) and pBar > smrBar
            array.push(retPts, chart.point.from_index(pBar, ph))
        expired = bar_index - smrBar > maxLeg
        if showCurve
            live = array.copy(retPts)
            array.push(live, chart.point.from_index(bar_index, close))
            polyline.delete(retPl)
            retPl := polyline.new(live, curved = curveSty == "Smooth", xloc = xloc.bar_index, line_color = color.new(dir == 1 ? UP : DN, 0), line_width = 3)
        if evFail or hitMax == 3 or expired
            d = dir == 1 ? 0 : 1
            bump(rN, d, 1)
            bump(rT1, d, hitMax >= 1 ? 1 : 0)
            bump(rT2, d, hitMax >= 2 ? 1 : 0)
            bump(rT3, d, hitMax >= 3 ? 1 : 0)
            bump(rFail, d, evFail ? 1 : 0)
            bump(rBars, d, hitMax == 3 ? bar_index - smrBar : 0)
            evDone := hitMax == 3
            evEnd := true
            resTxt = hitMax == 3 ? "✓ MODEL COMPLETE · " + str.tostring(bar_index - smrBar) + " bars" : evFail ? "✕ MODEL FAILED" + (hitMax > 0 ? " · T" + str.tostring(hitMax) + " reached" : "") : "EXPIRED" + (hitMax > 0 ? " · T" + str.tostring(hitMax) + " reached" : "")
            regLb(label.new(bar_index, dir == 1 ? high : low, resTxt, style = dir == 1 ? label.style_label_down : label.style_label_up,
                 color = hitMax == 3 ? TGT : color.new(GREY, 0), textcolor = hitMax == 3 ? color.white : INK, size = lSize))
            if not na(retPl)
                regPl(retPl)
            retPl := na   // the finished curve stays, filed under this model
            prune(mid - keepN)
            stage := 0
            dir := 0

    // ── 2 · engineering liquidity: the curve away from the consolidation
    if stage == 2
        if dir == 1 ? low < legExt : high > legExt
            legExt := dir == 1 ? low : high
            legExtBar := bar_index
            if not na(recentSw) and recentSwBar > legStart
                lastSw := recentSw
                lastSwBar := recentSwBar
        if dir == 1 and not na(pl) and pBar > legStart and pl < prevPiv
            steps += 1
            prevPiv := pl
            array.push(pts, chart.point.from_index(pBar, pl))
            if showSteps
                array.push(stepLbs, label.new(pBar, pl, "SSL " + str.tostring(steps), style = label.style_label_up, color = NONE, textcolor = DN, size = size.small))
        if dir == -1 and not na(ph) and pBar > legStart and ph > prevPiv
            steps += 1
            prevPiv := ph
            array.push(pts, chart.point.from_index(pBar, ph))
            if showSteps
                array.push(stepLbs, label.new(pBar, ph, "BSL " + str.tostring(steps), style = label.style_label_down, color = NONE, textcolor = UP, size = size.small))
        // the opposite swing the reversal has to break (market structure shift)
        oppSw = dir == 1 ? ph : pl
        if not na(oppSw) and pBar > legStart
            recentSw := oppSw
            recentSwBar := pBar
            if pBar < legExtBar
                lastSw := oppSw
                lastSwBar := pBar

        ocEdge = dir == 1 ? ocBot : ocTop
        depth  = dir == 1 ? ocBot - legExt : legExt - ocTop
        eq  = legExt + (ocEdge - legExt) * 0.5
        // ICT: the reversal happens deep in the curve, so the swing it breaks must sit beyond the equilibrium
        deep = not na(lastSw) and (dir == 1 ? lastSw < eq : lastSw > eq)
        smr = steps >= minSteps and depth >= legMin * atr and deep and lastSwBar < legExtBar and (dir == 1 ? close > lastSw : close < lastSw)
        broken = dir == 1 ? close > ocTop : close < ocBot
        expired = bar_index - ocR > maxLeg

        // the curve as it stands: origin → swings up to the extreme → extreme
        curve = array.new<chart.point>()
        array.push(curve, chart.point.from_index(ocR, ocEdge))
        for p in pts
            if p.index < legExtBar
                array.push(curve, p)
        array.push(curve, chart.point.from_index(legExtBar, legExt))
        if showCurve
            polyline.delete(legPl)
            legPl := polyline.new(curve, curved = curveSty == "Smooth", xloc = xloc.bar_index, line_color = color.new(dir == 1 ? DN : UP, smr ? 0 : 35), line_width = 3)

        if smr
            evSmr := true
            stage := 3
            mid += 1
            smrBar := bar_index
            hitMax := 0
            t1 := legExt + (ocEdge - legExt) * 0.5
            t2 := ocEdge
            t3 := dir == 1 ? ocTop : ocBot
            inv := legExt
            array.clear(retPts)
            array.push(retPts, chart.point.from_index(legExtBar, legExt))
            // the MSS close can already be past the equilibrium: then T1 is done on the reversal bar
            if dir == 1 ? close >= t1 : close <= t1
                hitMax := 1
            mc = dir == 1 ? UP : DN
            regBx(ocBox)
            if not na(legPl)
                regPl(legPl)
            for lb in stepLbs
                regLb(lb)
            regLn(line.new(lastSwBar, lastSw, bar_index, lastSw, color = mc, width = 2, style = line.style_dashed))
            regLb(label.new(bar_index, lastSw, "MSS", style = label.style_label_left, color = NONE, textcolor = mc, size = size.small))
            smrLb := label.new(legExtBar, legExt, "SMR · " + (dir == 1 ? "MMBM ▲" : "MMSM ▼"), style = dir == 1 ? label.style_label_up : label.style_label_down,
                 color = mc, textcolor = INK, size = lSize)
            regLb(smrLb)
            if showTgt
                t1Ln := line.new(bar_index, t1, bar_index + 1, t1, color = color.new(TGT, 30), width = 1, style = line.style_dotted)
                t2Ln := line.new(bar_index, t2, bar_index + 1, t2, color = color.new(TGT, 10), width = 2)
                t3Ln := line.new(bar_index, t3, bar_index + 1, t3, color = TGT, width = 2)
                invLn := line.new(bar_index, inv, bar_index + 1, inv, color = color.new(dir == 1 ? DN : UP, 20), width = 1, style = line.style_dashed)
                t1Lb := label.new(bar_index + 1, t1, "T1 · EQ " + px(t1), style = label.style_label_left, color = color.new(PANEL, 10), textcolor = TGTX, size = size.small)
                t2Lb := label.new(bar_index + 1, t2, "T2 · OC " + (dir == 1 ? "LOW " : "HIGH ") + px(t2), style = label.style_label_left, color = color.new(PANEL, 10), textcolor = TGTX, size = size.small)
                t3Lb := label.new(bar_index + 1, t3, "T3 · OC " + (dir == 1 ? "HIGH " : "LOW ") + px(t3), style = label.style_label_left, color = TGT, textcolor = color.white, size = size.small)
                invLb := label.new(bar_index + 1, inv, "INVALID " + px(inv), style = label.style_label_left, color = color.new(PANEL, 10), textcolor = dir == 1 ? DN : UP, size = size.small)
                if hitMax >= 1
                    label.set_text(t1Lb, "✓ " + label.get_text(t1Lb))
                regLn(t1Ln)
                regLn(t2Ln)
                regLn(t3Ln)
                regLn(invLn)
                regLb(t1Lb)
                regLb(t2Lb)
                regLb(t3Lb)
                regLb(invLb)
        else if broken or expired
            // no reversal: the attempt is erased, the chart keeps only real models
            box.delete(ocBox)
            polyline.delete(legPl)
            for lb in stepLbs
                label.delete(lb)
            stage := 0
            dir := 0

    // ── 1 · original consolidation: extend while it holds, wait for the break
    if stage == 1
        if close < ocBot or close > ocTop
            dir := close < ocBot ? 1 : -1
            stage := 2
            evForm := true
            legStart := bar_index
            legExt := dir == 1 ? low : high
            legExtBar := bar_index
            prevPiv := dir == 1 ? ocBot : ocTop
            steps := 0
            lastSw := na
            lastSwBar := na
            recentSw := na
            recentSwBar := na
            legPl := na
            array.clear(pts)
            array.clear(stepLbs)
            box.set_border_color(ocBox, color.new(TGT, 0))
        else if compress
            ocTop := math.max(ocTop, high)
            ocBot := math.min(ocBot, low)
            ocR := bar_index
            box.set_top(ocBox, ocTop)
            box.set_bottom(ocBox, ocBot)
            box.set_right(ocBox, ocR)
            if ocTop - ocBot > consMult * 1.5 * atr
                box.delete(ocBox)
                stage := 0
        else if bar_index - ocR > consLen
            box.delete(ocBox)
            stage := 0

    // ── 0 · searching for an original consolidation
    if stage == 0 and compress and not evDone and not evFail
        stage := 1
        ocTop := hh
        ocBot := ll
        ocL := bar_index - consLen + 1
        ocR := bar_index
        ocBox := box.new(ocL, ocTop, ocR, ocBot, border_color = color.new(TGT, 45), border_width = 2, bgcolor = color.new(TGT, 92),
             text = "ORIGINAL CONSOLIDATION", text_color = TGTX, text_size = size.small, text_halign = text.align_left, text_valign = text.align_top)

// running drawings follow the current bar
if stage == 3 and showTgt
    line.set_x2(t1Ln, bar_index + 3)
    line.set_x2(t2Ln, bar_index + 3)
    line.set_x2(t3Ln, bar_index + 3)
    line.set_x2(invLn, bar_index + 3)
    label.set_x(t1Lb, bar_index + 3)
    label.set_x(t2Lb, bar_index + 3)
    label.set_x(t3Lb, bar_index + 3)
    label.set_x(invLb, bar_index + 3)
if evHit > 0 and showTgt
    for k = evFrom + 1 to evHit
        lb = k == 1 ? t1Lb : k == 2 ? t2Lb : t3Lb
        label.set_text(lb, "✓ " + label.get_text(lb))
if evEnd and showTgt
    label.set_x(t1Lb, bar_index + 1)
    label.set_x(t2Lb, bar_index + 1)
    label.set_x(t3Lb, bar_index + 1)
    label.set_x(invLb, bar_index + 1)
    line.set_x2(t1Ln, bar_index)
    line.set_x2(t2Ln, bar_index)
    line.set_x2(t3Ln, bar_index)
    line.set_x2(invLn, bar_index)

// ─────────────────────────────────────────────────────────────────────────
//  PANEL
// ─────────────────────────────────────────────────────────────────────────
pos = tblPos == "Top Right" ? position.top_right : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Top Left" ? position.top_left : position.bottom_left
var table tb = na

cell(int c, int r, string t, color fg, color bg, string al = text.align_left) =>
    table.cell(tb, c, r, t, text_color = fg, bgcolor = bg, text_size = tSize, text_halign = al)

if barstate.islast and showTbl
    table.delete(tb)   // rebuilt each time: merged cells cannot be merged twice
    tb := table.new(pos, 5, 15, bgcolor = PANEL, border_color = PANEL, border_width = 2, frame_color = color.new(VIOLET, 30), frame_width = 1)
    mc = dir == 1 ? UP : dir == -1 ? DN : GREY
    stName = stage == 0 ? "SEARCHING" : stage == 1 ? "① CONSOLIDATION" : stage == 2 ? "② ENGINEERING" : "③ REVERSAL · ④ RETURN"
    cell(0, 0, "MARKET MAKER MODEL", MUTE, PANEL)
    table.merge_cells(tb, 0, 0, 1, 0)
    cell(2, 0, stName, stage == 0 ? TXT : stage == 1 ? color.white : INK, stage == 0 ? ROW : stage == 1 ? TGT : mc, text.align_center)
    table.merge_cells(tb, 2, 0, 4, 0)
    dots = ""
    for k = 1 to 4
        dots += (k <= (stage == 3 ? 3 + math.min(hitMax, 1) : stage) ? "●" : "○") + (k < 4 ? "  " : "")
    cell(0, 1, "Model", MUTE, ROW)
    cell(1, 1, dir == 1 ? "BUY MODEL · MMBM" : dir == -1 ? "SELL MODEL · MMSM" : stage == 1 ? "waiting for the break" : "—", dir == 0 ? TXT : mc, ROW)
    table.merge_cells(tb, 1, 1, 2, 1)
    cell(3, 1, dots, stage == 0 ? MUTE : TGTX, ROW, text.align_center)
    table.merge_cells(tb, 3, 1, 4, 1)
    cell(0, 2, "Liquidity steps", MUTE, ROW)
    cell(1, 2, stage >= 2 ? str.tostring(steps) + (dir == 1 ? " × SSL taken" : " × BSL taken") : "—", TXT, ROW)
    table.merge_cells(tb, 1, 2, 4, 2)
    depthNow = stage >= 2 and not na(atr) ? (dir == 1 ? ocBot - legExt : legExt - ocTop) / atr : na
    cell(0, 3, "Curve depth", MUTE, ROW)
    cell(1, 3, na(depthNow) ? "—" : str.tostring(depthNow, "0.0") + " × ATR" + (stage == 2 ? (depthNow >= legMin ? "  ✓" : "  (min " + str.tostring(legMin, "0.0") + ")") : ""), TXT, ROW)
    table.merge_cells(tb, 1, 3, 4, 3)
    retr = stage == 3 and t3 != legExt ? (close - legExt) / (t3 - legExt) * 100 : na
    cell(0, 4, "Return to origin", MUTE, ROW)
    cell(1, 4, na(retr) ? "—" : str.tostring(math.max(retr, 0), "0") + "%", stage == 3 ? mc : TXT, ROW)
    table.merge_cells(tb, 1, 4, 4, 4)
    for k = 1 to 3
        tk = k == 1 ? t1 : k == 2 ? t2 : t3
        nm = k == 1 ? "T1 · equilibrium" : k == 2 ? "T2 · consolidation edge" : "T3 · origin (complete)"
        cell(0, 4 + k, nm, MUTE, ROW)
        cell(1, 4 + k, stage == 3 ? (hitMax >= k ? "✓ " : "") + px(tk) : "—", stage == 3 and hitMax >= k ? TGTX : TXT, ROW)
        table.merge_cells(tb, 1, 4 + k, 4, 4 + k)
    cell(0, 8, "Invalid beyond", MUTE, ROW)
    cell(1, 8, stage == 3 ? px(inv) : "—", dir == 1 ? DN : UP, ROW)
    table.merge_cells(tb, 1, 8, 4, 8)

    // track record
    cell(0, 9, "TRACK RECORD · THIS SYMBOL", TGTX, PANEL)
    table.merge_cells(tb, 0, 9, 4, 9)
    cell(0, 10, "", MUTE, PANEL)
    cell(1, 10, "Models", MUTE, PANEL, text.align_center)
    cell(2, 10, "T2", MUTE, PANEL, text.align_center)
    cell(3, 10, "Complete", MUTE, PANEL, text.align_center)
    cell(4, 10, "Failed", MUTE, PANEL, text.align_center)
    for d = 0 to 2
        n  = d < 2 ? array.get(rN, d) : array.sum(rN)
        af = d < 2 ? array.get(rFail, d) : array.sum(rFail)
        a2 = d < 2 ? array.get(rT2, d) : array.sum(rT2)
        a3 = d < 2 ? array.get(rT3, d) : array.sum(rT3)
        nm = d == 0 ? "▲ Buy models" : d == 1 ? "▼ Sell models" : "All models"
        rb = d == 2 ? PANEL : ROW
        cell(0, 11 + d, nm, d == 0 ? UP : d == 1 ? DN : TXT, rb)
        cell(1, 11 + d, str.tostring(n), TXT, rb, text.align_center)
        cell(2, 11 + d, pct(a2, n), TXT, rb, text.align_center)
        cell(3, 11 + d, pct(a3, n), TGTX, rb, text.align_center)
        cell(4, 11 + d, pct(af, n), MUTE, rb, text.align_center)
    t3n = array.sum(rT3)
    avgB = t3n > 0 ? array.sum(rBars) * 1.0 / t3n : na
    cell(0, 14, "Avg time to complete: " + (na(avgB) ? "—" : str.tostring(avgB, "0") + " bars"), MUTE, PANEL)
    table.merge_cells(tb, 0, 14, 4, 14)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
if alForm and evForm
    alert(syminfo.ticker + " MMXM forming: original consolidation broken " + (dir == 1 ? "down — buy model (MMBM) possible" : "up — sell model (MMSM) possible"), alert.freq_once_per_bar_close)
if alSmr and evSmr
    alert(syminfo.ticker + " MMXM smart money reversal · " + (dir == 1 ? "MMBM ▲" : "MMSM ▼") + " · T1 " + px(t1) + " · T2 " + px(t2) + " · T3 " + px(t3) + " · invalid beyond " + px(inv), alert.freq_once_per_bar_close)
if alTgt and evHit > 0 and not evDone
    alert(syminfo.ticker + " MMXM target T" + str.tostring(evHit) + " hit", alert.freq_once_per_bar_close)
if alTgt and evDone
    alert(syminfo.ticker + " MMXM model complete: price is back at the origin", alert.freq_once_per_bar_close)
if alTgt and evFail
    alert(syminfo.ticker + " MMXM model failed: price traded beyond the reversal extreme", alert.freq_once_per_bar_close)

alertcondition(evSmr and dir == 1, "MMXM buy model reversal", "{{ticker}} MMXM smart money reversal · MMBM")
alertcondition(evSmr and dir == -1, "MMXM sell model reversal", "{{ticker}} MMXM smart money reversal · MMSM")
alertcondition(evHit > 0, "MMXM target hit", "{{ticker}} MMXM target hit")
alertcondition(evDone, "MMXM model complete", "{{ticker}} MMXM model complete")
alertcondition(evFail, "MMXM model failed", "{{ticker}} MMXM model failed")

// ─────────────────────────────────────────────────────────────────────────
//  GLOW CANDLES (LunqFX house style)
// ─────────────────────────────────────────────────────────────────────────
GLOW_UP_DARK  = #00F5D4
GLOW_DN_DARK  = #FF2E88
GLOW_UP_LIGHT = #00A896
GLOW_DN_LIGHT = #E0115F

glowUp   = isLight ? GLOW_UP_LIGHT : GLOW_UP_DARK
glowDn   = isLight ? GLOW_DN_LIGHT : GLOW_DN_DARK
glowEdge = close >= open ? glowUp : glowDn
glowOn   = candOn_ and candGlw
GLOW_NONE = color.new(color.black, 100)

plotcandle(candOn_ and not glowOn ? open : na, high, low, close, "Candles", color = color.new(glowEdge, 24), wickcolor = color.new(glowEdge, 18), bordercolor = glowEdge, display = display.pane)

gQ = (close - open) / 4.0
plotcandle(glowOn ? open : na, glowOn ? math.max(open, close) : na, glowOn ? math.min(open, close) : na, glowOn ? close : na, "Glow mask", color = chart.bg_color, wickcolor = GLOW_NONE, bordercolor = chart.bg_color, display = display.pane)
plotcandle(glowOn ? open : na, glowOn ? math.max(open, open + gQ) : na, glowOn ? math.min(open, open + gQ) : na, glowOn ? open + gQ : na, "Glow band 1", color = color.new(glowEdge, 78), wickcolor = GLOW_NONE, bordercolor = GLOW_NONE, display = display.pane)
plotcandle(glowOn ? open + gQ : na, glowOn ? math.max(open + gQ, open + 2 * gQ) : na, glowOn ? math.min(open + gQ, open + 2 * gQ) : na, glowOn ? open + 2 * gQ : na, "Glow band 2", color = color.new(glowEdge, 58), wickcolor = GLOW_NONE, bordercolor = GLOW_NONE, display = display.pane)
plotcandle(glowOn ? open + 2 * gQ : na, glowOn ? math.max(open + 2 * gQ, open + 3 * gQ) : na, glowOn ? math.min(open + 2 * gQ, open + 3 * gQ) : na, glowOn ? open + 3 * gQ : na, "Glow band 3", color = color.new(glowEdge, 36), wickcolor = GLOW_NONE, bordercolor = GLOW_NONE, display = display.pane)
plotcandle(glowOn ? open + 3 * gQ : na, glowOn ? math.max(open + 3 * gQ, close) : na, glowOn ? math.min(open + 3 * gQ, close) : na, glowOn ? close : na, "Glow band 4", color = color.new(glowEdge, 8), wickcolor = GLOW_NONE, bordercolor = GLOW_NONE, display = display.pane)
plotcandle(glowOn ? open : na, glowOn ? high : na, glowOn ? low : na, glowOn ? close : na, "Glow wick", color = GLOW_NONE, wickcolor = color.new(glowEdge, 10), bordercolor = color.new(glowEdge, 30), display = display.pane)
````
