# Pullback Measured Move

- url: https://www.tradingview.com/script/BgCsV7WY-Pullback-Measured-Move/
- type: indicator
- pine_id: PUB;3150cdb9679e43e1b79cf7ed22f188bb
- version: 1.0

## Description

## Pullback Measured Move (PMM)

Price moves in rhythm. After an impulse leg, the market pulls back - and the size of that pullback often tells you exactly how far the next leg will travel. This indicator automates that measurement so you don't have to eyeball it or draw lines manually while the move is already underway.

How It Works

PMM detects three-point swing structures using alternating pivot highs and lows:

**Bearish:** Swing High (A) → Swing Low (B) → Lower High (C)
**Bullish:** Swing Low (A) → Swing High (B) → Higher Low (C)

Once point C is confirmed, the indicator measures the full pullback range from B to C — wicks included, since larger wicks reflect greater volatility and produce proportionally larger continuations. It then projects that range × your chosen multiplier from B in the trend direction, giving you a calculated target for where the next impulse leg is likely to terminate.

The default multiplier is 2×, meaning the projected move equals double the pullback distance. You can adjust this to 1× (equal legs), 1.618× (golden ratio), or any value that fits your instrument and timeframe.

### What's on the Chart

- **Solid blue line** at point B — measures the pullback range (labeled "1×")
- **Dashed blue line** at point C — shows the projected distance to target (labeled with your multiplier)
- **Dotted horizontal line** — the target level, extending forward with price displayed
- **Optional A-B-C labels** — toggle on to see exactly where the pattern anchored (off by default to keep things clean)

### How to Use It

The pattern fires the moment the pullback pivot (C) is confirmed, giving you a directional bias and a price target for the continuation leg. Use it as a confluence tool alongside your existing setup — when your entry signal aligns with a PMM target zone, you have a structurally grounded level to manage against.

Works on any instrument and any timeframe. For faster charts, lower the Pivot Lookback to catch smaller swings. For swing trading, increase it to filter for only the strongest structures.

### Key Settings

- **Pivot Lookback** — Bars left/right to confirm a swing (default 5). Lower = more patterns, higher = fewer but stronger.
- **Projection Multiplier** — How many times the pullback range to project (default 2.0).
- **Min Pullback (× ATR)** — Filters out pullbacks smaller than this fraction of ATR to reduce noise.
- **Require Trend Structure** — When on, bearish patterns require a lower high and bullish require a higher low. Turn off to see all pullbacks regardless.
- **Direction Filter** — Show bearish only, bullish only, or both.

### Alerts

Three alert conditions are built in — Bearish, Bullish, and Any — so you can get notified the moment a new pattern confirms without watching the chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jacobrholland
// ══════════════════════════════════════════════════════════════
// PULLBACK MEASURED MOVE — Auto-Projection Indicator
// ══════════════════════════════════════════════════════════════
// Detects trend pullbacks via zigzag swing structure (A→B→C),
// measures the pullback range (B→C), and projects that range
// × multiplier from B in the trend direction to mark the
// expected termination point of the next impulse leg.
//
// Bearish: High(A) → Low(B) → Lower High(C)
//   Pullback = C − B  |  Target = B − mult × Pullback
//
// Bullish: Low(A) → High(B) → Higher Low(C)
//   Pullback = B − C  |  Target = B + mult × Pullback
// ══════════════════════════════════════════════════════════════
//@version=6
indicator("Pullback Measured Move", "PMM", overlay=true,
     max_lines_count=500, max_labels_count=200)

// ─── INPUTS ──────────────────────────────────────────────────
var GRP_DET  = "Detection"
pivotLen     = input.int(5, "Pivot Lookback",
                 minval=2, maxval=20, group=GRP_DET,
                 tooltip="Bars left & right to confirm a swing. Lower = more signals, higher = fewer but stronger.")
minPbAtr     = input.float(0.3, "Min Pullback (× ATR)",
                 step=0.1, minval=0.0, group=GRP_DET,
                 tooltip="Ignore pullbacks smaller than this multiple of 14-period ATR.")
mergeAtr     = input.float(0.5, "Swing Merge Distance (× ATR)",
                 step=0.1, minval=0.0, group=GRP_DET,
                 tooltip="Swings closer than this to the previous registered swing are absorbed rather than creating a new direction change. Reduces clutter in consolidation zones.")
trendStrict  = input.bool(true, "Require Trend Structure",
                 group=GRP_DET,
                 tooltip="On = only show patterns with lower highs (bear) / higher lows (bull). Off = show all pullbacks.")
dirFilter    = input.string("Both", "Direction Filter",
                 options=["Both", "Bearish Only", "Bullish Only"], group=GRP_DET)

var GRP_PROJ = "Projection"
projMult     = input.float(2.0, "Projection Multiplier",
                 step=0.25, minval=0.5, maxval=10.0, group=GRP_PROJ,
                 tooltip="How many times the pullback range to project. 1.0 = equal move, 2.0 = double.")
extBars      = input.int(25, "Target Line Extension (bars)",
                 minval=5, maxval=200, group=GRP_PROJ)

var GRP_VIS  = "Display"
showMeas     = input.bool(true, "Show Measurement Line", group=GRP_VIS)
showProj     = input.bool(true, "Show Projection Line", group=GRP_VIS)
showTarget   = input.bool(true, "Show Target Level", group=GRP_VIS)
showSwingLbl = input.bool(false, "Label Swing Points (A B C)", group=GRP_VIS)
maxPat       = input.int(5, "Max Patterns Visible",
                 minval=1, maxval=20, group=GRP_VIS)
lineW        = input.int(2, "Line Width", minval=1, maxval=4, group=GRP_VIS)

var GRP_CLR  = "Colors"
measClr      = input.color(#42A5F5, "Measurement Line",  group=GRP_CLR)
projClr      = input.color(#42A5F5, "Projection Line",   group=GRP_CLR)
bearClr      = input.color(#FF5252, "Bearish Target",     group=GRP_CLR)
bullClr      = input.color(#69F0AE, "Bullish Target",     group=GRP_CLR)

// ─── STATE ───────────────────────────────────────────────────
atr14 = ta.atr(14)

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

// Zigzag tracking — last 3 alternating swings
// v6: bools can't be na, so swing type is tracked as int
//     -1 = uninitialized, 0 = swing low, 1 = swing high
var int   zDir = 0
var float s1   = na,  var int b1 = na,  var int type1 = -1
var float s2   = na,  var int b2 = na,  var int type2 = -1
var float s3   = na,  var int b3 = na,  var int type3 = -1

// Drawing storage
var line[]  arrMeas = array.new_line()
var line[]  arrProj = array.new_line()
var line[]  arrTgt  = array.new_line()
var label[] arrLbl  = array.new_label()
var label[] arrSwg  = array.new_label()

// ─── ZIGZAG + PATTERN DETECTION ──────────────────────────────
detected = false
pDir     = 0

if not na(ph)
    phBar = bar_index - pivotLen
    if zDir != 1
        // Only register direction change if swing is far enough from previous
        swingDist = math.abs(ph - s1)
        if swingDist >= mergeAtr * atr14 or type1 == -1
            // Direction change → new confirmed swing high
            s3 := s2,  b3 := b2,  type3 := type2
            s2 := s1,  b2 := b1,  type2 := type1
            s1 := ph,  b1 := phBar, type1 := 1
            zDir := 1

            // Bearish pattern: H(A) → L(B) → H(C), pullback C confirmed
            if type3 == 1 and type2 == 0 and type1 == 1 and not na(s3)
                pbRange = s1 - s2
                trendOk = trendStrict ? s3 > s1 : true
                dirOk   = dirFilter == "Both" or dirFilter == "Bearish Only"
                if trendOk and dirOk and pbRange > minPbAtr * atr14
                    detected := true
                    pDir     := -1
    else
        // Same direction — update if higher
        if ph > s1
            s1 := ph
            b1 := phBar

if not na(pl)
    plBar = bar_index - pivotLen
    if zDir != -1
        // Only register direction change if swing is far enough from previous
        swingDist2 = math.abs(pl - s1)
        if swingDist2 >= mergeAtr * atr14 or type1 == -1
            s3 := s2,  b3 := b2,  type3 := type2
            s2 := s1,  b2 := b1,  type2 := type1
            s1 := pl,  b1 := plBar, type1 := 0
            zDir := -1

            // Bullish pattern: L(A) → H(B) → L(C), pullback C confirmed
            if type3 == 0 and type2 == 1 and type1 == 0 and not na(s3)
                pbRange2 = s2 - s1
                trendOk2 = trendStrict ? s3 < s1 : true
                dirOk2   = dirFilter == "Both" or dirFilter == "Bullish Only"
                if trendOk2 and dirOk2 and pbRange2 > minPbAtr * atr14
                    detected := true
                    pDir     := 1
    else
        if pl < s1
            s1 := pl
            b1 := plBar

// ─── DRAWING ─────────────────────────────────────────────────
if detected
    // Compute geometry
    float pbTop = pDir == -1 ? s1 : s2
    float pbBot = pDir == -1 ? s2 : s1
    float pbR   = pbTop - pbBot
    float tgt   = pDir == -1 ? pbBot - projMult * pbR : pbTop + projMult * pbR
    color  tClr = pDir == -1 ? bearClr : bullClr

    // ── Measurement line: vertical at B, spanning the pullback range ──
    if showMeas
        mL = line.new(b2, pbBot, b2, pbTop,
             color=measClr, width=lineW, style=line.style_solid)
        array.push(arrMeas, mL)
        // "1×" label at midpoint
        mLbl = label.new(b2, math.avg(pbBot, pbTop), "1×",
               style=label.style_label_right,
               color=color.new(measClr, 90), textcolor=measClr,
               size=size.tiny)
        array.push(arrSwg, mLbl)

    // ── Projection line: vertical at C, from B-level to target ──
    if showProj
        float projOrigin = pDir == -1 ? pbBot : pbTop
        pL = line.new(b1, projOrigin, b1, tgt,
             color=projClr, width=lineW, style=line.style_dashed)
        array.push(arrProj, pL)
        // Multiplier label
        pLbl = label.new(b1, math.avg(projOrigin, tgt),
               str.tostring(projMult, "#.##") + "×",
               style=label.style_label_right,
               color=color.new(projClr, 90), textcolor=projClr,
               size=size.tiny)
        array.push(arrSwg, pLbl)

    // ── Target level: horizontal line extending forward ──
    if showTarget
        tL = line.new(b1, tgt, b1 + extBars, tgt,
             color=tClr, width=lineW, style=line.style_dotted)
        array.push(arrTgt, tL)
        tLbl = label.new(b1 + extBars, tgt,
               (pDir == -1 ? "▼ " : "▲ ") + str.tostring(tgt, format.mintick),
               style=label.style_label_left,
               color=color.new(tClr, 85), textcolor=tClr,
               size=size.small)
        array.push(arrLbl, tLbl)

    // ── Optional A-B-C swing labels ──
    if showSwingLbl
        aStyle = type3 == 1 ? label.style_label_down : label.style_label_up
        bStyle = type2 == 1 ? label.style_label_down : label.style_label_up
        cStyle = type1 == 1 ? label.style_label_down : label.style_label_up
        array.push(arrSwg, label.new(b3, s3, "A", style=aStyle,
             color=color.new(chart.fg_color, 85), textcolor=chart.fg_color, size=size.tiny))
        array.push(arrSwg, label.new(b2, s2, "B", style=bStyle,
             color=color.new(chart.fg_color, 85), textcolor=chart.fg_color, size=size.tiny))
        array.push(arrSwg, label.new(b1, s1, "C", style=cStyle,
             color=color.new(chart.fg_color, 85), textcolor=chart.fg_color, size=size.tiny))

    // ── Cleanup oldest patterns ──
    while array.size(arrMeas) > maxPat
        line.delete(array.shift(arrMeas))
    while array.size(arrProj) > maxPat
        line.delete(array.shift(arrProj))
    while array.size(arrTgt) > maxPat
        line.delete(array.shift(arrTgt))
    while array.size(arrLbl) > maxPat
        label.delete(array.shift(arrLbl))
    while array.size(arrSwg) > maxPat * 5
        label.delete(array.shift(arrSwg))

// ─── ALERTS ──────────────────────────────────────────────────
alertcondition(detected and pDir == -1,
     "Bearish Measured Move",
     "Bearish pullback projection detected")
alertcondition(detected and pDir == 1,
     "Bullish Measured Move",
     "Bullish pullback projection detected")
alertcondition(detected,
     "Any Measured Move",
     "Pullback measured move pattern detected")

// ─── INFO TABLE ──────────────────────────────────────────────
var table infoTbl = table.new(position.top_right, 2, 1,
     bgcolor=color.new(chart.bg_color, 30),
     border_color=color.new(chart.fg_color, 80),
     border_width=1)
if barstate.islast
    table.cell(infoTbl, 0, 0, "PMM",
         text_color=measClr, text_size=size.small)
    table.cell(infoTbl, 1, 0, str.tostring(projMult, "#.##") + "× | Piv " + str.tostring(pivotLen),
         text_color=chart.fg_color, text_size=size.small)
````
