# Gap Fill Probability for SPY SPX XSP

- url: https://www.tradingview.com/script/5ukZAfQL-Gap-Fill-Probability-for-SPY-SPX-XSP/
- type: indicator
- pine_id: PUB;17e11de8a6274bf5ba15a5bc7aa0874a
- version: 2.0

## Description

[b]Gap Fill Probability Viewer - open gaps with an adaptive fill probability[/b]

Gap Fill Probability Viewer automatically finds price gaps on your chart and draws each one as a colored zone - no more drawing rectangles by hand. It then tells you how likely each open gap is to "fill," and exactly how far price has to travel to close it.

[b]What it shows[/b]

[list]
[*]Gap zones - every gap-up and gap-down, drawn as a box that extends to the current bar.
[*]Fill probability (P) - an estimate of how likely the gap is to close, shown as a % and color-coded (green = likely, orange = uncertain, red = unlikely).
[*]p-value - the flip side of P: the chance the gap stays open.
[*]Distance to close - how far the current price is from fully closing the gap, in both points and % of the charted symbol.
[*]Stats table - a clean summary for the gap closest to filling.
[/list]

[b]How the probability works[/b]

The estimate adapts to three things research associates with gap fills:
- Size - bigger gaps are harder to fill.
- Distance - the closer price is to the gap, the higher the odds.
- Recency - fresh gaps fill faster; old, stubborn gaps lose momentum.

Handy options
- Auto-hide, fade, or keep gaps once they fill.
- Filter out tiny gaps by % or ATR.
- Detect gaps on wicks or candle bodies.
- Fully tunable probability model and colors.

⚠️ [b]The fill probability is a heuristic estimate for study and education — not a guarantee or financial advice. Calibrate the settings to your own market and timeframe.[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MasterOfDesaster

//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  Gap Fill Probability for SPY SPX XSP
//  Highlights open price gaps as zones and estimates an ADAPTIVE fill
//  probability driven by recency and distance-to-close.
//
//  ── FILL-PROBABILITY MODEL — grounded in the empirical S&P 500 gap literature ─
//   • Index gaps fill at a HIGH unconditional rate. Studies of SPX / SPY / ES
//     overnight gaps report ~70–90% eventual fill — far above single stocks —
//     because index diversification suppresses true "breakaway" gaps and
//     overnight mean-reversion dominates (cf. the overnight-gap mean-reversion
//     literature on index futures, Caginalp/Constantine-style gap studies, and
//     the broad practitioner finding that the large majority of SPX gaps fill).
//   • Gap SIZE is the dominant predictor: fill probability declines
//     monotonically with size. Small gaps (<~0.2 ATR / <0.2%) fill almost
//     always; large gaps fill materially less often, especially short-horizon.
//   • RECENCY / hazard is FRONT-LOADED: most fills occur within the first few
//     sessions; the per-bar fill hazard decays with the gap's age, so a gap
//     that has stayed open for many bars carries lower *near-term* fill odds.
//   • DISTANCE-to-close: as price retraces into the gap, the remaining run to
//     the far edge shrinks and the conditional fill probability rises.
//
//  These four facts are combined in a logistic (logit) model:
//     z       = logit(baseRate) − sizeSens·gapATR − distSens·remATR
//                                 − recSens·(age / recencyHalfLife)
//     P(fill) = 1 / (1 + e^−z)
//  All coefficients are user-tunable so the model can be re-calibrated to your
//  own backtest of the underlying you trade.
//
//  ── OUTPUTS per open gap ──
//   • P        — adaptive fill probability (%)
//   • p-value  — complement (1 − P): probability the gap STAYS OPEN / "does not
//                close"; read it as the significance against the "it fills" null.
//   • Δ        — remaining distance to a COMPLETE close, in underlying points
//                AND in % of current price (based on the charted symbol).
//
//  Heuristic estimate for study/education — NOT investment advice.
// ════════════════════════════════════════════════════════════════════════════
indicator("Gap Viewer", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ─────────────────────────────── Inputs ────────────────────────────────────
var string gD = "Gap detection"
useWicks  = input.bool(true,  "Detect gaps on wicks (high/low)", group = gD,
   tooltip = "On: a gap = no overlap between adjacent bar ranges (high/low).\nOff: gaps are measured on bodies (open/close).")
minGapPct = input.float(0.05, "Minimum gap size (%)", minval = 0.0, step = 0.01, group = gD)
minGapATR = input.float(0.0,  "Minimum gap size (ATR mult.)", minval = 0.0, step = 0.1, group = gD,
   tooltip = "Extra filter in ATR units. 0 = off.")
atrLen    = input.int(14,     "ATR length", minval = 1, group = gD)
maxGaps   = input.int(50,     "Max gaps to track", minval = 1, maxval = 490, group = gD)

var string gV = "Display"
closedMode = input.string("Hide", "Closed (filled) gaps", options = ["Hide", "Fade", "Keep"], group = gV,
   tooltip = "Hide: remove the box once the gap fully fills.\nFade: keep it faded.\nKeep: leave it as-is.")
upCol      = input.color(color.new(#f23645, 84), "Gap-up zone (support below)",  group = gV)
downCol    = input.color(color.new(#f23645, 84), "Gap-down zone (resistance above)", group = gV)
showBorder = input.bool(true,  "Show zone border", group = gV)

var string gP = "Fill-probability model"
showTable   = input.bool(true,  "Show stats table (nearest open gap)", group = gP)
showGapLab  = input.bool(true,  "Show P-label on each open gap", group = gP)
tablePos    = input.string("Top Right", "Table position",
   options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gP)
baseRate    = input.float(0.85, "Base eventual fill rate (lit. ≈ 0.85)", minval = 0.30, maxval = 0.99, step = 0.01, group = gP,
   tooltip = "Unconditional S&P 500 gap-fill rate anchor from the literature (~70–90%).")
sizeSens    = input.float(0.55, "Gap-size sensitivity (per ATR)", minval = 0.0, step = 0.05, group = gP,
   tooltip = "How strongly a larger gap lowers fill probability.")
distSens    = input.float(0.45, "Distance sensitivity (per remaining ATR)", minval = 0.0, step = 0.05, group = gP,
   tooltip = "How strongly remaining distance-to-close lowers fill probability.")
recSens     = input.float(0.50, "Recency sensitivity", minval = 0.0, step = 0.05, group = gP,
   tooltip = "How strongly an aging (stale) gap lowers near-term fill probability.")
recencyHL   = input.int(15,     "Recency half-life (bars)", minval = 1, group = gP)

// ─────────────────────────────── State ─────────────────────────────────────
var box[]   bxs    = array.new<box>()
var label[] lbs    = array.new<label>()
var float[] gTop   = array.new<float>()   // top edge of gap zone
var float[] gBot   = array.new<float>()   // bottom edge of gap zone
var int[]   gDir   = array.new<int>()     // 1 = gap up, -1 = gap down
var int[]   gBar   = array.new<int>()     // formation bar_index
var bool[]  gFill  = array.new<bool>()    // filled / closed?

// ─────────────────────────────── Detection ─────────────────────────────────
topPrev = useWicks ? high[1] : math.max(open[1], close[1])
botPrev = useWicks ? low[1]  : math.min(open[1], close[1])
topCur  = useWicks ? high    : math.max(open, close)
botCur  = useWicks ? low     : math.min(open, close)

atr     = ta.atr(atrLen)
gapUp   = botCur > topPrev
gapDown = topCur < botPrev
gapSz   = gapUp ? (botCur - topPrev) : gapDown ? (botPrev - topCur) : 0.0
gapPct  = close != 0 ? gapSz / close * 100.0 : 0.0
gapAtr  = (not na(atr) and atr > 0) ? gapSz / atr : 0.0
passF   = gapPct >= minGapPct and (minGapATR <= 0 or gapAtr >= minGapATR)
newGap  = (gapUp or gapDown) and passF and not na(atr) and barstate.isconfirmed

if newGap
    zTop = gapUp ? botCur  : botPrev        // top of the empty zone
    zBot = gapUp ? topPrev : topCur         // bottom of the empty zone
    bx = box.new(bar_index, zTop, bar_index, zBot,
       border_color = showBorder ? color.new(color.gray, 40) : color.new(color.gray, 100),
       border_width = 1, bgcolor = gapUp ? upCol : downCol, extend = extend.none)
    lb = showGapLab ? label.new(bar_index, (zTop + zBot) / 2, "", style = label.style_none,
       textcolor = chart.fg_color, size = size.small) : na
    array.push(bxs, bx)
    array.push(lbs, lb)
    array.push(gTop, zTop)
    array.push(gBot, zBot)
    array.push(gDir, gapUp ? 1 : -1)
    array.push(gBar, bar_index)
    array.push(gFill, false)
    // prune oldest beyond the cap
    if array.size(bxs) > maxGaps
        box.delete(array.get(bxs, 0))
        label.delete(array.get(lbs, 0))
        array.remove(bxs, 0)
        array.remove(lbs, 0)
        array.remove(gTop, 0)
        array.remove(gBot, 0)
        array.remove(gDir, 0)
        array.remove(gBar, 0)
        array.remove(gFill, 0)

// ─────────────────── Per-bar update: fill checks + probability ──────────────
logit(p) => math.log(p / (1.0 - p))

// nearest open gap tracking (closest to filling)
float nDistPts = na
float nDistPct = na
float nP       = na
float nGapPts  = na
float nGapPct  = na
int   nAge     = na
int   nDir     = na

n = array.size(bxs)
if n > 0
    for i = 0 to n - 1
        if not array.get(gFill, i)
            bx  = array.get(bxs, i)
            lb  = array.get(lbs, i)
            dir = array.get(gDir, i)
            top = array.get(gTop, i)
            bot = array.get(gBot, i)
            box.set_right(bx, bar_index)

            // a gap fully CLOSES when price reaches its far (origin) edge
            filled = dir == 1 ? (low <= bot) : (high >= top)
            if filled
                array.set(gFill, i, true)
                if closedMode == "Hide"
                    box.delete(bx)
                else if closedMode == "Fade"
                    box.set_bgcolor(bx, color.new(color.gray, 93))
                    box.set_border_color(bx, color.new(color.gray, 80))
                if not na(lb)
                    label.delete(lb)
            else
                // remaining run to a COMPLETE close
                target  = dir == 1 ? bot : top
                distPts = math.abs(close - target)
                distPct = close != 0 ? distPts / close * 100.0 : 0.0
                gSize   = top - bot
                gAtr    = (not na(atr) and atr > 0) ? gSize   / atr : 0.0
                remAtr  = (not na(atr) and atr > 0) ? distPts / atr : 0.0
                age     = bar_index - array.get(gBar, i)

                // logistic fill-probability model (see header)
                z = logit(baseRate) - sizeSens * gAtr - distSens * remAtr - recSens * (age * 1.0 / recencyHL)
                P = 1.0 / (1.0 + math.exp(-z))
                P := math.max(0.01, math.min(0.99, P))

                if not na(lb)
                    arrow = dir == 1 ? "▲ up-gap" : "▼ down-gap"
                    txt = arrow + "  P=" + str.tostring(P * 100, "#.#") + "%  p=" + str.tostring(1 - P, "#.##") + "\nΔ " + str.tostring(distPts, format.mintick) + " pts / " + str.tostring(distPct, "#.##") + "%"
                    label.set_xy(lb, bar_index, (top + bot) / 2)
                    label.set_text(lb, txt)

                // keep the gap that is closest to filling for the table
                if na(nDistPts) or distPts < nDistPts
                    nDistPts := distPts
                    nDistPct := distPct
                    nP       := P
                    nGapPts  := gSize
                    nGapPct  := close != 0 ? gSize / close * 100.0 : 0.0
                    nAge     := age
                    nDir     := dir

// ─────────────────────────────── Stats table ───────────────────────────────
posMap = tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table t = na
if showTable and na(t)
    t := table.new(posMap, 2, 9, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 50))

if showTable and barstate.islast
    table.clear(t, 0, 0, 1, 8)
    hdr = color.new(color.gray, 0)
    bg1 = color.new(color.gray, 88)
    bg2 = color.new(color.gray, 80)
    table.cell(t, 0, 0, "Gap Viewer — nearest open gap", text_color = chart.fg_color, text_size = size.small, bgcolor = hdr)
    table.merge_cells(t, 0, 0, 1, 0)
    if na(nP)
        table.cell(t, 0, 1, "No open gaps", text_color = chart.fg_color, text_size = size.small, bgcolor = bg1)
        table.merge_cells(t, 0, 1, 1, 1)
    else
        pcol = nP >= 0.66 ? color.new(color.green, 0) : nP >= 0.4 ? color.new(color.orange, 0) : color.new(color.red, 0)
        rows = array.from("Direction", "Gap size (pts)", "Gap size (%)", "Age (bars)", "Dist→close (pts)", "Dist→close (%)", "Fill prob. P", "p-value (stays open)")
        vals = array.from(nDir == 1 ? "▲ Up-gap" : "▼ Down-gap", str.tostring(nGapPts, format.mintick), str.tostring(nGapPct, "#.##") + "%", str.tostring(nAge), str.tostring(nDistPts, format.mintick), str.tostring(nDistPct, "#.##") + "%", str.tostring(nP * 100, "#.#") + "%", str.tostring(1 - nP, "#.###"))
        for r = 0 to 7
            bg = r % 2 == 0 ? bg1 : bg2
            table.cell(t, 0, r + 1, array.get(rows, r), text_color = chart.fg_color, text_size = size.small, bgcolor = bg, text_halign = text.align_left)
            tc = r == 6 ? pcol : chart.fg_color
            table.cell(t, 1, r + 1, array.get(vals, r), text_color = tc, text_size = size.small, bgcolor = bg, text_halign = text.align_right)
````
