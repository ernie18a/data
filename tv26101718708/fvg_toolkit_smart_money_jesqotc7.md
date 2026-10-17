# FVG Toolkit [Smart Money]

- url: https://www.tradingview.com/script/jEsQOTc7-FVG-Toolkit-Smart-Money/
- type: indicator
- pine_id: PUB;b985fb0dd8274a9598e1e6ea1376da5a
- version: 1.0

## Description

A Fair Value Gap is a 3-candle imbalance: a candle runs hard and leaves a void that the candles around it never fully cover. But the version most tools draw is only one of three the price-action crowd actually watches. There is the visible Classic gap, the Implied gap hidden inside a single oversized candle, and the Inversion gap that appears when a broken FVG flips and starts acting as support or resistance. Tracking these one type at a time means three layers of clutter and a lot of switching back and forth. FVG Toolkit detects all three on one overlay and merges their overlap into a single confluence zone, so the chart shows structure instead of noise.

[b]HOW IT WORKS[/b]

Three FVG families, each independently toggleable, are detected on confirmed bars only:

- **Classic FVG** — the standard visible 3-candle imbalance: the wicks of candle 1 and candle 3 do not overlap, leaving an open gap (bullish `low[0] > high[2]`, bearish `high[0] < low[2]`).
- **Implied FVG** — a hidden imbalance carried by a single large candle whose outer wicks overlap. The gap is measured between the Consequent Encroachment (the 50% level) of those outer wicks. This is ElisTools' operational definition of an Implied FVG; the ICT community uses several variants, so this one is stated openly rather than presented as the only version.
- **Inversion FVG** — a Classic FVG whose boundary gets broken flips polarity and becomes a support/resistance zone: a bearish FVG broken upward becomes a bullish IFVG, and a bullish FVG broken downward becomes a bearish IFVG.

Each gap is then managed through an honest lifecycle:

- **Classic / Implied** are shown as a full zone. When price reaches the far edge the gap is violated and removed (or kept, your choice). There is no partial-fill shading — a zone is either present or gone.
- **Inversion** runs on two independent axes. Validation is the flip itself (the Classic boundary is broken, by Wick or Body) and births the IFVG; Invalidation is the opposite boundary being broken (by Wick or Body) and removes it. Because the two axes are separate, you can flip strictly and invalidate loosely, or any other mix.
- **Cluster** — when a fresh same-direction Classic FVG forms over an existing IFVG (a common displacement byproduct), the two are merged into one reinforced union zone spanning their full combined extent. This is confluence, not a BPR. Cluster priority is direction-aware: a cluster takes precedence only over overlapping standalone zones of the same direction — an opposite-side gap is never touched.

A `Min gap size (ATR x)` filter skips trivial micro-gaps, and Inversion inherits it (a filtered-out Classic can never flip). Every zone can carry an optional 50% (CE) line and label, with its own per-type and per-side colors.

1) A confirmed bar is scanned for Classic, Implied, and Inversion conditions (each only if enabled)
2) Surviving gaps are drawn as full zones; a same-direction Classic over an IFVG is merged into a cluster
3) Price reaching a far edge violates Classic/Implied; a broken boundary validates or invalidates an Inversion

[b]HOW TO READ[/b]

- A Classic zone is a visible 3-candle imbalance; an Implied zone marks the void inside one oversized candle; an Inversion zone is a former gap now flipped to the other side.
- A cluster (its own color) is a same-direction Classic and IFVG stacked together — overlap collapsed into one zone rather than two competing ones.
- The optional 50% line is the Consequent Encroachment, the midpoint many price-action traders watch inside a gap.
- "Bullish" and "Bearish" describe the direction of the pattern, not a buy or sell instruction. Marking any of these zones says nothing about whether price will fill it, hold there, or reverse. The tool maps the structure; the read is yours.

[b]INPUTS[/b]

- Max zones / Extend right — how many zones to keep on chart, and how far to project them.
- Min gap size (ATR x) — skip gaps smaller than this multiple of ATR(14); 0 turns the filter off. Inversion inherits it.
- Show Classic / Show Implied / Show Inversion — enable each family independently; each has its own color(s).
- Middle body >= ATR x (Implied) — how large the single middle candle must be to qualify as an Implied gap.
- Validation (flip) — how a Classic flips into an IFVG: Body (a body closes beyond the boundary, ICT-strict, default) or Wick (a wick beyond it, looser).
- Invalidation — how a formed IFVG is removed: Wick (a wick beyond the opposite boundary, default) or Body (a body close beyond it, ICT-strict).
- Remove on violation / Violation by — drop a Classic/Implied zone when its far edge is reached; Wick (intrabar) or Close (bar close).
- Merge same-dir overlap — fuse a same-direction Classic + IFVG into one cluster zone; with its own cluster color.
- Style — show labels, show 50% (CE) line and its width, zone border and its width.

[b]ALERTS[/b]

Two layers, set up separately in the alert dialog.

- Detection (four conditions: New bullish/bearish Classic FVG and New bullish/bearish Implied FVG) are picked from the condition dropdown and fire on closed bars — use "Once Per Bar Close."
- Lifecycle (FVG inverted, Inversion FVG invalidated, FVG mitigated) fire through alert() function calls — create them with "Any alert() function call." Use "Once Per Bar" when the matching axis is set to Wick, and "Once Per Bar Close" when it is set to Body or Close.

[b]NOTES & LIMITS[/b]

This is an observation tool, not a forecast. Marking a Classic, Implied, or Inversion FVG says nothing about whether the gap fills, holds, or reverses — it only shows where the structure sits. The Implied FVG uses ElisTools' operational definition (a large middle body, overlapping outer wicks, and the gap measured between their 50% levels); the ICT community uses several variants, so this one is stated openly rather than claimed as the single canon. The cluster is a confluence union of a same-direction Classic and IFVG, not a Balanced Price Range, and it never removes an opposite-side gap. No repaint, no lookahead: zones are created on confirmed (closed) bars only and their levels never move. Wick-based lifecycle rules update intrabar but stay exact, because a bar's high and low are running extremes that are never revised; Body and Close rules act only on bar close. No profit, win-rate, or guarantee claim. Open-source under CC BY-NC-SA 4.0 — non-commercial use, attribution to ElisTools required for reuse or derivatives. TradingView (Pine v6) only.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ElisTools
// FVG Toolkit [Smart Money] — Attribution required: credit "ElisTools" in any reuse or derivative.
//
// Three Fair Value Gap families in one overlay:
//   • Classic FVG   — visible 3-candle imbalance (wicks of candle 1 and 3 do not overlap).
//   • Implied FVG   — hidden imbalance: large middle candle, overlapping wicks; gap measured
//                     between the 50% (Consequent Encroachment) of the outer wicks.
//   • Inversion FVG — a Classic FVG whose boundary is broken flips polarity into S/R.
//
// Pattern reference: candle 1 = [2], middle (displacement) = [1], candle 3 = [0].
//
// Lifecycles:
//   Classic / Implied — deleted outright the moment price violates the gap by reaching its far
//     edge (bullish = bottom, bearish = top). The violation can be a Wick or a Close. No
//     partial-fill shading — the zone is shown full until it is removed.
//   Inversion (IFVG)  — born when a Classic FVG's boundary is broken (Validation), stays FULL,
//     and is removed only when its opposite boundary is broken (Invalidation). Validation and
//     Invalidation are independent {Wick, Body} axes.
//   Cluster           — a same-direction Classic FVG overlapping an IFVG (the displacement
//     byproduct) is merged into one reinforced zone spanning their combined extent (union).
//
// Non-repaint: zones are created only on confirmed bars; Wick rules use the bar's final
// high/low extreme and Close rules act on bar close, so history and real-time agree.

//@version=6
indicator("FVG Toolkit [Smart Money]", shorttitle = "FVG Toolkit", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
gGen       = "General"
maxZones   = input.int(30, "Max zones (total)", minval = 1, maxval = 100, group = gGen)
extendBars = input.int(20, "Extend right (bars)", minval = 0, maxval = 500, group = gGen)
minGapATR  = input.float(0.25, "Min gap size (ATR ×)", minval = 0.0, step = 0.05, group = gGen, tooltip = "FVGs whose gap height is smaller than this multiple of ATR(14) are not drawn. 0 = off. Inversion inherits this (a filtered Classic can't flip).")

gStyle     = "Style"
showLabels = input.bool(true, "Show labels", group = gStyle)
show50     = input.bool(true, "Show 50% line (CE)", group = gStyle)
lineWidth  = input.int(1, "50% line width", minval = 1, maxval = 3, group = gStyle)
showBorder = input.bool(true, "Zone border", group = gStyle)
borderWidth= input.int(1, "Border width", minval = 1, maxval = 4, group = gStyle)

gMit       = "Mitigation (Classic / Implied)"
removeMitig= input.bool(true, "Remove on violation", group = gMit, tooltip = "ON: a Classic/Implied FVG is deleted the moment price violates it (reaches the far edge). OFF: zones are kept.")
mitigMode  = input.string("Wick", "Violation by", options = ["Wick", "Close"], group = gMit, tooltip = "Wick = a wick reaching the far edge (intrabar). Close = a candle closing through the far edge (bar close).")

gClassic    = "Classic FVG"
showClassic = input.bool(true, "Show Classic FVG", group = gClassic)
cBull       = input.color(color.new(#90ee90, 82), "Bullish (light green)", inline = "c", group = gClassic)
cBear       = input.color(color.new(#ff8080, 82), "Bearish (light red)", inline = "c", group = gClassic)

gImplied    = "Implied FVG"
showImplied = input.bool(true, "Show Implied FVG", group = gImplied)
iCol        = input.color(color.new(#ffa726, 82), "Color (orange)", group = gImplied)
bodyMult    = input.float(1.5, "Middle body ≥ ATR ×", minval = 0.0, step = 0.1, group = gImplied, tooltip = "Filters the middle candle: its body must be at least this multiple of ATR(14).")

gInv      = "Inversion FVG"
showInv   = input.bool(true, "Show Inversion FVG", group = gInv, tooltip = "A Classic FVG flips into an IFVG when its boundary is broken (bearish FVG broken up → bullish IFVG; bullish FVG broken down → bearish IFVG).")
invCol    = input.color(color.new(#9e9e9e, 80), "Color (gray)", group = gInv)
valMethod = input.string("Body", "Validation (flip)", options = ["Wick", "Body"], group = gInv, tooltip = "How a Classic FVG flips into an IFVG. Body = a candle body closes beyond the boundary (ICT-strict, default). Wick = a wick beyond it (looser).")
invMethod = input.string("Wick", "Invalidation", options = ["Wick", "Body"], group = gInv, tooltip = "How a formed IFVG is removed. Wick = a wick beyond the opposite boundary (default). Body = a candle body closes beyond it (ICT-strict).")

gClus        = "Inversion Cluster"
mergeOverlap = input.bool(true, "Merge same-dir overlap (IFVG + FVG)", group = gClus, tooltip = "A fresh same-direction Classic FVG overlapping an IFVG (the displacement byproduct) is merged into one reinforced zone spanning their full combined extent (union). Cuts overlap clutter; this is confluence, not a BPR.")
clusterCol   = input.color(color.new(#7e57c2, 72), "Cluster color (purple)", group = gClus)

// ─────────────────────────────────────────────────────────────────────────────
//  TYPE & STATE   (kind: 0 = Classic, 1 = Implied, 2 = Inversion)
// ─────────────────────────────────────────────────────────────────────────────
type Zone
    float top
    float bot
    int   bornBar    // bar_index the zone was created / flipped on
    int   left
    bool  bull
    int   kind
    bool  cluster    // reinforced IFVG + FVG union
    box   bx
    line  l50
    label lbl

var array<Zone> zones = array.new<Zone>()

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────
delZone(Zone z) =>
    box.delete(z.bx)
    if not na(z.l50)
        line.delete(z.l50)
    if not na(z.lbl)
        label.delete(z.lbl)

createZone(float t, float b, bool isBull, int k) =>
    bool  hideIt  = k == 0 and not showClassic
    color baseCol = k == 1 ? iCol : (isBull ? cBull : cBear)
    int   leftIdx = bar_index - 2
    int   rightX  = bar_index + extendBars
    float midY    = (t + b) / 2.0
    color fillC   = hideIt ? na : baseCol
    color lineC   = hideIt ? na : color.new(baseCol, 0)
    color txtC    = hideIt ? na : chart.fg_color
    box bx = box.new(leftIdx, t, rightX, b, xloc = xloc.bar_index, border_width = showBorder ? borderWidth : 0, border_color = showBorder ? lineC : na, bgcolor = fillC)
    line l50 = na
    if show50
        l50 := line.new(leftIdx, midY, rightX, midY, xloc = xloc.bar_index, color = lineC, style = line.style_dotted, width = lineWidth)
    label lb = na
    if showLabels
        string tg = k == 1 ? "Implied FVG" : "FVG"
        lb := label.new(rightX, midY, tg, xloc = xloc.bar_index, style = label.style_label_right, color = color.new(color.gray, 100), textcolor = txtC, size = size.small, textalign = text.align_right)
    array.push(zones, Zone.new(t, b, bar_index, leftIdx, isBull, k, false, bx, l50, lb))
    if array.size(zones) > maxZones
        delZone(array.shift(zones))

// Restyle an IFVG as a reinforced cluster over the combined extent (union) [cTop, cBot].
// cLeft = the earlier (further-back) start bar of the two merged zones.
makeCluster(Zone z, float cTop, float cBot, int cLeft) =>
    z.top     := cTop
    z.bot     := cBot
    z.left    := cLeft
    z.cluster := true
    float ceY = (cTop + cBot) / 2.0
    box.set_top(z.bx, cTop)
    box.set_bottom(z.bx, cBot)
    box.set_left(z.bx, cLeft)
    box.set_bgcolor(z.bx, clusterCol)
    box.set_border_color(z.bx, color.new(clusterCol, 0))
    box.set_border_width(z.bx, showBorder ? borderWidth : 0)
    if not na(z.l50)
        line.set_color(z.l50, color.new(clusterCol, 0))
        line.set_x1(z.l50, cLeft)
        line.set_y1(z.l50, ceY)
        line.set_y2(z.l50, ceY)
    if not na(z.lbl)
        label.set_text(z.lbl, "IFVG + FVG")
        label.set_textcolor(z.lbl, chart.fg_color)
        label.set_y(z.lbl, ceY)

// ─────────────────────────────────────────────────────────────────────────────
//  PATTERN GEOMETRY
// ─────────────────────────────────────────────────────────────────────────────
bool  ready   = bar_index > 2
float atrV    = ta.atr(14)
float midBody = math.abs(close[1] - open[1])
bool  bigBody = not na(atrV) and midBody >= atrV * bodyMult
float minGap  = na(atrV) ? 0.0 : atrV * minGapATR              // minimum gap height (ATR-based)

// Consequent Encroachment (50%) of the outer wicks — used by Implied FVG
float ce1Up = (high[2] + math.max(open[2], close[2])) / 2.0   // candle 1 upper wick 50%
float ce3Lo = (low     + math.min(open,    close))    / 2.0   // candle 3 lower wick 50%
float ce1Lo = (low[2]  + math.min(open[2], close[2])) / 2.0   // candle 1 lower wick 50%
float ce3Up = (high    + math.max(open,    close))    / 2.0   // candle 3 upper wick 50%

bool rawBullC = ready and low > high[2] and (low - high[2]) >= minGap                                                  // Classic bullish gap
bool rawBearC = ready and high < low[2] and (low[2] - high) >= minGap                                                  // Classic bearish gap
bool rawBullI = ready and bigBody and close[1] > open[1] and low  <= high[2] and ce3Lo > ce1Up and (ce3Lo - ce1Up) >= minGap   // Implied bullish
bool rawBearI = ready and bigBody and close[1] < open[1] and high >= low[2]  and ce1Lo > ce3Up and (ce1Lo - ce3Up) >= minGap   // Implied bearish

// ─────────────────────────────────────────────────────────────────────────────
//  MANAGE EXISTING ZONES
// ─────────────────────────────────────────────────────────────────────────────
int i = array.size(zones) - 1
while i >= 0
    Zone z = array.get(zones, i)
    bool  removed = false
    int   rx = bar_index + extendBars
    float ce = (z.top + z.bot) / 2.0
    if z.kind == 2
        // ---- Inversion / cluster: invalidation when the opposite boundary is broken ----
        float lvl = z.bull ? z.bot : z.top
        bool  hit = z.bull ? (invMethod == "Wick" ? low < lvl : close < lvl) : (invMethod == "Wick" ? high > lvl : close > lvl)
        if bar_index > z.bornBar and (invMethod == "Wick" or barstate.isconfirmed) and hit
            delZone(z)
            array.remove(zones, i)
            removed := true
            alert("FVG Toolkit: Inversion FVG invalidated", alert.freq_once_per_bar)
    else
        // ---- Classic / Implied ----
        // Validation — a Classic FVG flips into an IFVG when its boundary is broken
        float vlvl = z.bull ? z.bot : z.top
        bool  vbrk = z.bull ? (valMethod == "Wick" ? low < vlvl : close < vlvl) : (valMethod == "Wick" ? high > vlvl : close > vlvl)
        bool  valOk = z.kind == 0 and showInv and bar_index > z.bornBar and (valMethod == "Wick" or barstate.isconfirmed) and vbrk
        // Violation — price reaches the far edge (bullish = bot, bearish = top), wick or close
        bool  viol = z.bull ? (mitigMode == "Wick" ? low <= z.bot : close <= z.bot) : (mitigMode == "Wick" ? high >= z.top : close >= z.top)
        bool  violOk = removeMitig and bar_index > z.bornBar and (mitigMode == "Wick" or barstate.isconfirmed) and viol
        if valOk
            z.kind    := 2
            z.bull    := not z.bull
            z.bornBar := bar_index
            box.set_bgcolor(z.bx, invCol)
            box.set_border_color(z.bx, color.new(invCol, 0))
            box.set_border_width(z.bx, showBorder ? borderWidth : 0)
            if not na(z.l50)
                line.set_color(z.l50, color.new(invCol, 0))
            if not na(z.lbl)
                label.set_text(z.lbl, "Inversion FVG")
                label.set_textcolor(z.lbl, chart.fg_color)
            alert("FVG Toolkit: FVG inverted", alert.freq_once_per_bar)
        else if violOk and ((z.kind != 0) or (not showInv) or barstate.isconfirmed)
            delZone(z)
            array.remove(zones, i)
            removed := true
            alert("FVG Toolkit: FVG mitigated", alert.freq_once_per_bar)
    if not removed
        // Render full — no partial-fill shrinking.
        box.set_top(z.bx, z.top)
        box.set_bottom(z.bx, z.bot)
        box.set_right(z.bx, rx)
        if not na(z.l50)
            line.set_y1(z.l50, ce)
            line.set_y2(z.l50, ce)
            line.set_x2(z.l50, rx)
        if not na(z.lbl)
            label.set_xy(z.lbl, rx, ce)
    i -= 1

// ─────────────────────────────────────────────────────────────────────────────
//  DETECT NEW ZONES  (confirmed bar only → non-repainting)
// ─────────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed
    if (showClassic or showInv) and rawBullC
        createZone(low, high[2], true, 0)
    else if (showClassic or showInv) and rawBearC
        createZone(low[2], high, false, 0)
    if showImplied and rawBullI
        createZone(ce3Lo, ce1Up, true, 1)
    else if showImplied and rawBearI
        createZone(ce1Lo, ce3Up, false, 1)

// ─────────────────────────────────────────────────────────────────────────────
//  CLUSTER MERGE  (a Classic FVG formed AFTER an IFVG — displacement byproduct — is absorbed)
// ─────────────────────────────────────────────────────────────────────────────
if mergeOverlap and array.size(zones) > 1
    int c = array.size(zones) - 1
    while c >= 0
        Zone cl = array.get(zones, c)
        if cl.kind == 0
            int  k = 0
            bool merged = false
            while k < array.size(zones) and not merged
                Zone iv = array.get(zones, k)
                if iv.kind == 2 and not iv.cluster and iv.bull == cl.bull and cl.bornBar > iv.bornBar and iv.top > cl.bot and iv.bot < cl.top
                    makeCluster(iv, math.max(iv.top, cl.top), math.min(iv.bot, cl.bot), iv.left < cl.left ? iv.left : cl.left)
                    delZone(cl)
                    array.remove(zones, c)
                    merged := true
                k += 1
        c -= 1

// ─────────────────────────────────────────────────────────────────────────────
//  CLUSTER PRIORITY  (a cluster removes any overlapping standalone Classic / Inversion zone)
// ─────────────────────────────────────────────────────────────────────────────
if mergeOverlap and array.size(zones) > 1
    int p = array.size(zones) - 1
    while p >= 0
        Zone o = array.get(zones, p)
        if o.kind == 0 or (o.kind == 2 and not o.cluster)
            int  m = 0
            bool kill = false
            while m < array.size(zones) and not kill
                Zone cz = array.get(zones, m)
                if m != p and cz.kind == 2 and cz.cluster and cz.bull == o.bull and cz.top > o.bot and cz.bot < o.top
                    kill := true
                m += 1
            if kill
                delZone(o)
                array.remove(zones, p)
        p -= 1

// ─────────────────────────────────────────────────────────────────────────────
//  ALERTS  (detection fires on bar close only → non-repainting)
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(rawBullC and barstate.isconfirmed, "Bullish Classic FVG", "FVG Toolkit: New bullish Classic FVG")
alertcondition(rawBearC and barstate.isconfirmed, "Bearish Classic FVG", "FVG Toolkit: New bearish Classic FVG")
alertcondition(rawBullI and barstate.isconfirmed, "Bullish Implied FVG", "FVG Toolkit: New bullish Implied FVG")
alertcondition(rawBearI and barstate.isconfirmed, "Bearish Implied FVG", "FVG Toolkit: New bearish Implied FVG")
````
