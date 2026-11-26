# AureusEdge | Day Trading Setup

- url: https://www.tradingview.com/script/Us6WhCRW-AureusEdge-Day-Trading-Setup/
- type: indicator
- pine_id: PUB;8b373c68041c478ab9d311546931b074
- version: 1.0

## Description

Three timeframes. One chart. No switching.

Most traders lose context when they switch timeframes to find setups.
This indicator solves that by bringing 15-minute trend, 5-minute structure,
and 1-minute trigger logic all to the same chart at once.

——

HOW IT WORKS

15-minute — Trend and Fair Value Gaps
The 15-minute EMA defines whether you are in an uptrend or downtrend.
Fair Value Gaps from the 15-minute chart are drawn as zones directly on
your chart. These are the imbalances price tends to return to before
continuing in the trend direction.

5-minute — Market Structure
Confirmed swing highs and lows from the 5-minute chart are labeled
HH, HL, LH and LL with dashed reference lines. Higher Highs and Higher
Lows confirm a bullish trend. Lower Highs and Lower Lows confirm bearish.

1-minute — Trigger
The 1-minute EMA cross (8 / 21) acts as the entry trigger.
A long setup is armed when the 15-minute trend is bullish, 5-minute
structure is bullish, and price is near a Fair Value Gap or a key
structure level. Same logic inverted for shorts.

The panel shows the current status of all three layers at once.
Alert conditions fire when all conditions align — no visual arrows,
no chart clutter.

——

NO REPAINTING

All higher timeframe data uses request.security with lookahead set to off
and confirmed bars only. What triggered on the chart is what triggered.

——

SETTINGS

15M EMA: default 50. Controls trend direction on the 15-minute chart.
Keep FVGs: number of Fair Value Gap zones displayed simultaneously.
Pivot Lookback: defines what counts as a swing point on the 5-minute chart.
1M EMA Fast / Slow: default 8 / 21. The trigger cross on the 1-minute chart.

——

Works on any instrument and any timeframe combination.
Designed for day trading — load on the 1-minute chart.

Not financial advice. Always manage your own risk.

## Source Code

````pine
//@version=6
// =============================================================================
//  AUREUSEDGE - Gold Scalper
//  Three-timeframe funnel on the 1M chart:
//
//   15M  →  Trend-Kontext (EMA) + Fair Value Gaps als Zonen
//    5M  →  Market Structure (HH / HL / LH / LL) as lines
//    1M  →  Entry-Trigger (EMA-Cross) + Signal mit SL/TP
//
//  Trade the 1M chart - this indicator brings all context to you.
//  No timeframe switching. One look, one decision.
//
//  Farbpalette STRIKT nach AureusEdge-Logo:  GOLD / PINK / WHITE / DARK
//  LONG = GOLD,  SHORT = PINK.  Repaint-frei (lookahead_off + [1]).
//  Not financial advice.
// =============================================================================
indicator("AureusEdge | Day Trading Setup", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ── BRAND COLORS ─────────────────────────────────────────────────────────────
GOLD  = color.rgb(212, 175,  55)
PINK  = color.rgb(219,  98, 158)
WHITE = color.rgb(255, 255, 255)
DARK  = color.rgb( 10,  10,  16)
BULL  = GOLD
BEAR  = PINK

// ── INPUTS ───────────────────────────────────────────────────────────────────
grpT = "15M - Trend & FVG"
ema15Len = input.int(50,  "15M Trend EMA",     minval=5,  group=grpT)
showFVG  = input.bool(true,"15M FVG Zones",               group=grpT)
fvgKeep  = input.int(3,   "Keep FVGs",    minval=1, maxval=8, group=grpT)

grpS = "5M - Market Structure"
pivLeft  = input.int(3,  "Pivot Left",  minval=1, maxval=8, group=grpS)
pivRight = input.int(3,  "Pivot Right", minval=1, maxval=4, group=grpS)
showStruct = input.bool(true, "5M Structure Lines", group=grpS)

grpE = "1M - Entry Trigger"
ema1Fast  = input.int(8,   "1M EMA Fast", minval=2, group=grpE)
ema1Slow  = input.int(21,  "1M EMA Slow", minval=2, group=grpE)
showSig   = input.bool(true,"Show Signal Status in Panel", group=grpE)

grpU = "UI"
showPanel = input.bool(true, "Panel", group=grpU)

// ── 1M EMAs (Trigger – auf dem Chart sichtbar) ───────────────────────────────
ema1f = ta.ema(close, ema1Fast)
ema1s = ta.ema(close, ema1Slow)
plot(ema1f, "EMA 8  (1M)",  color=color.new(GOLD, 40), linewidth=1)
plot(ema1s, "EMA 21 (1M)",  color=color.new(WHITE, 45), linewidth=1)

// ── 15M DATEN (repaint-frei: nur bestaetigte Bars via [1] und [3]) ────────────
[ema15, c15, h15_c, l15_c, h15_a, l15_a] = request.security(
     syminfo.tickerid, "15",
     [ta.ema(close, ema15Len)[1],
      close[1],
      high[1],   // C-Kerze (aktuellste bestaetigte 15M Bar)
      low[1],
      high[3],   // A-Kerze (2 Bars vor C = 3-Kerzen-Pattern)
      low[3]],
     lookahead = barmerge.lookahead_off)

trend15Up = c15 > ema15
trend15Dn = c15 < ema15

// 15M FVG: 3-Kerzen-Imbalance  (A – B – C)
// Bull: Low(C) > High(A) → Gap dazwischen
// Bear: High(C) < Low(A) → Gap dazwischen
bull15FVG   = l15_c > h15_a
bear15FVG   = h15_c < l15_a
bull15FVGtop = bull15FVG ? l15_c : na
bull15FVGbot = bull15FVG ? h15_a : na
bear15FVGtop = bear15FVG ? l15_a : na
bear15FVGbot = bear15FVG ? h15_c : na

// ── 15M FVG ZONEN zeichnen ───────────────────────────────────────────────────
var array<box>   fvgBoxes  = array.new<box>()
var float lastBullTop = na
var float lastBearTop = na

if showFVG
    // Bull FVG – neue Box nur wenn sich der Level geaendert hat
    if bull15FVG and bull15FVGtop != lastBullTop
        lastBullTop := bull15FVGtop
        b = box.new(bar_index, bull15FVGtop, bar_index + 80, bull15FVGbot,
             border_color=color.new(BULL, 45),
             bgcolor     =color.new(BULL, 90),
             border_width=1,
             text="FVG 15M", text_color=color.new(BULL, 30),
             text_size=size.tiny, text_halign=text.align_left,
             text_valign=text.align_center)
        array.push(fvgBoxes, b)
        if array.size(fvgBoxes) > fvgKeep
            box.delete(array.shift(fvgBoxes))

    // Bear FVG
    if bear15FVG and bear15FVGtop != lastBearTop
        lastBearTop := bear15FVGtop
        b = box.new(bar_index, bear15FVGtop, bar_index + 80, bear15FVGbot,
             border_color=color.new(BEAR, 45),
             bgcolor     =color.new(BEAR, 90),
             border_width=1,
             text="FVG 15M", text_color=color.new(BEAR, 30),
             text_size=size.tiny, text_halign=text.align_left,
             text_valign=text.align_center)
        array.push(fvgBoxes, b)
        if array.size(fvgBoxes) > fvgKeep
            box.delete(array.shift(fvgBoxes))

// Extend FVG boxes to the right (stay active until next FVG)
if array.size(fvgBoxes) > 0
    for i = 0 to array.size(fvgBoxes) - 1
        box.set_right(array.get(fvgBoxes, i), bar_index + 80)

// ── 5M STRUKTUR – Pivots (repaint-frei, gaps_on = nur bei neuem Pivot) ────────
ph5 = request.security(syminfo.tickerid, "5",
      ta.pivothigh(high, pivLeft, pivRight),
      gaps    = barmerge.gaps_on,
      lookahead = barmerge.lookahead_off)

pl5 = request.security(syminfo.tickerid, "5",
      ta.pivotlow(low, pivLeft, pivRight),
      gaps    = barmerge.gaps_on,
      lookahead = barmerge.lookahead_off)

// Track last 2 confirmed pivot highs and lows
var float ph5_1 = na
var float ph5_2 = na
var float pl5_1 = na
var float pl5_2 = na

if not na(ph5)
    ph5_2 := ph5_1
    ph5_1 := ph5

if not na(pl5)
    pl5_2 := pl5_1
    pl5_1 := pl5

// Structure classification
isHH = not na(ph5_1) and not na(ph5_2) and ph5_1 > ph5_2   // Higher High
isLH = not na(ph5_1) and not na(ph5_2) and ph5_1 < ph5_2   // Lower High
isHL = not na(pl5_1) and not na(pl5_2) and pl5_1 > pl5_2   // Higher Low
isLL = not na(pl5_1) and not na(pl5_2) and pl5_1 < pl5_2   // Lower Low

struct5Bull = isHH and isHL    // Bullish structure: HH + HL
struct5Bear = isLH and isLL    // Bearish structure: LH + LL

// ── 5M STRUKTUR LINIEN ────────────────────────────────────────────────────────
var array<line>  sLines = array.new<line>()
var array<label> sLbls  = array.new<label>()

if showStruct and barstate.islast
    // Alte Linien loeschen
    for ln in sLines
        line.delete(ln)
    array.clear(sLines)
    for lb in sLbls
        label.delete(lb)
    array.clear(sLbls)

    // Current pivot high
    if not na(ph5_1)
        phTxt = isHH ? "HH  " + str.tostring(ph5_1, "#.00") : "LH  " + str.tostring(ph5_1, "#.00")
        phCol = isHH ? BULL : BEAR
        array.push(sLines, line.new(bar_index - 60, ph5_1, bar_index + 18, ph5_1,
             color=color.new(phCol, 20), width=1, style=line.style_dashed))
        array.push(sLbls, label.new(bar_index + 18, ph5_1, phTxt,
             color=color.new(DARK, 20), textcolor=phCol,
             style=label.style_label_left, size=size.small))

    // Previous pivot high (line only, no label)
    if not na(ph5_2)
        array.push(sLines, line.new(bar_index - 60, ph5_2, bar_index + 18, ph5_2,
             color=color.new(WHITE, 78), width=1, style=line.style_dotted))

    // Current pivot low
    if not na(pl5_1)
        plTxt = isHL ? "HL  " + str.tostring(pl5_1, "#.00") : "LL  " + str.tostring(pl5_1, "#.00")
        plCol = isHL ? BULL : BEAR
        array.push(sLines, line.new(bar_index - 60, pl5_1, bar_index + 18, pl5_1,
             color=color.new(plCol, 20), width=1, style=line.style_dashed))
        array.push(sLbls, label.new(bar_index + 18, pl5_1, plTxt,
             color=color.new(DARK, 20), textcolor=plCol,
             style=label.style_label_left, size=size.small))

    // Previous pivot low (line only, no label)
    if not na(pl5_2)
        array.push(sLines, line.new(bar_index - 60, pl5_2, bar_index + 18, pl5_2,
             color=color.new(WHITE, 78), width=1, style=line.style_dotted))

// ── ENTRY LOGIK ───────────────────────────────────────────────────────────────
// 1M Trigger: EMA-Cross
longTrigger  = ta.crossover(ema1f, ema1s)
shortTrigger = ta.crossunder(ema1f, ema1s)

// In FVG Zone?
inBullFVG = not na(lastBullTop) and close <= lastBullTop and close >= (bull15FVGbot)
inBearFVG = not na(lastBearTop) and close >= (bear15FVGbot) and close <= lastBearTop

// Near 5M structure level (tolerance: 0.4% of price)
slDistProx = close * 0.004
nearHL = not na(pl5_1) and close >= pl5_1 - slDistProx and close <= pl5_1 + slDistProx
nearLH = not na(ph5_1) and close >= ph5_1 - slDistProx and close <= ph5_1 + slDistProx

// ── Signalbedingungen ─────────────────────────────────────────────────────────
// LONG:  15M Uptrend + 5M bullish structure (HH+HL)
//        + Preis in Bull-FVG ODER nahe HL
//        + 1M EMA-Cross nach oben (Trigger)
longSig  = showSig and trend15Up and struct5Bull and (inBullFVG or nearHL) and longTrigger

// SHORT: 15M Downtrend + 5M bearish structure (LH+LL)
//        + Preis in Bear-FVG ODER nahe LH
//        + 1M EMA-Cross nach unten (Trigger)
shortSig = showSig and trend15Dn and struct5Bear and (inBearFVG or nearLH) and shortTrigger

// Signal drawing removed — alerts fire without visual clutter on the chart

alertcondition(longSig,  "AureusEdge LONG Scalp",  "AureusEdge Day Trading Setup: LONG - 15M Trend + 5M Structure + 1M Cross")
alertcondition(shortSig, "AureusEdge SHORT Scalp", "AureusEdge Day Trading Setup: SHORT - 15M Trend + 5M Structure + 1M Cross")

// ── PANEL (AureusEdge-Stil) ───────────────────────────────────────────────────
if showPanel and barstate.islast
    var table p = table.new(position.top_right, 2, 20,
         bgcolor      = color.new(DARK, 8),
         border_color = GOLD,
         border_width = 0,
         frame_color  = GOLD,
         frame_width  = 1)

    // Trend-Farben und Texte
    t15Col  = trend15Up ? GOLD : trend15Dn ? PINK : color.new(WHITE, 45)
    t15Txt  = trend15Up ? "Uptrend ↑" : trend15Dn ? "Downtrend ↓" : "Range ~"
    fvgTxt  = bull15FVG ? "Bull FVG active" : bear15FVG ? "Bear FVG active" : "no FVG"
    fvgCol  = bull15FVG ? GOLD : bear15FVG ? PINK : color.new(WHITE, 55)
    s5Txt   = struct5Bull ? "HH + HL" : struct5Bear ? "LH + LL" : "mixed"
    s5Col   = struct5Bull ? GOLD : struct5Bear ? PINK : color.new(WHITE, 45)
    hhTxt   = isHH ? "HH" : isLH ? "LH" : "--"
    hlTxt   = isHL ? "HL" : isLL ? "LL" : "--"
    hhCol   = isHH ? GOLD : isLH ? PINK : color.new(WHITE, 45)
    hlCol   = isHL ? GOLD : isLL ? PINK : color.new(WHITE, 45)

    zoneTxt = inBullFVG ? "Bull FVG ✓" : inBearFVG ? "Bear FVG ✓" : nearHL ? "near HL" : nearLH ? "near LH" : "outside"
    zoneCol = (inBullFVG or nearHL) ? GOLD : (inBearFVG or nearLH) ? PINK : color.new(WHITE, 55)

    armed   = (trend15Up and struct5Bull) or (trend15Dn and struct5Bear)
    sigTxt  = longSig ? "▲ LONG" : shortSig ? "▼ SHORT" : armed ? "Armed - waiting for zone" : "Watching..."
    sigCol  = longSig ? GOLD : shortSig ? PINK : armed ? color.new(GOLD, 30) : color.new(WHITE, 55)
    sigBg   = longSig ? color.new(GOLD, 82) : shortSig ? color.new(PINK, 82) : color.new(DARK, 8)

    // ── Aufbau ──
    // Goldlinie oben
    table.cell(p, 0,  0, "", bgcolor=GOLD, text_size=size.tiny)
    table.cell(p, 1,  0, "", bgcolor=GOLD, text_size=size.tiny)
    // Name
    table.cell(p, 0,  1, " AUREUS", text_color=WHITE, text_size=size.normal, bgcolor=color.new(DARK,8), text_halign=text.align_right)
    table.cell(p, 1,  1, "EDGE  ",  text_color=GOLD,  text_size=size.normal, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    // Subtitle
    table.cell(p, 0,  2, " Day Trading Setup", text_color=color.new(GOLD,55), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_right)
    table.cell(p, 1,  2, "15M / 5M / 1M  ", text_color=color.new(GOLD,55), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    // Separator
    table.cell(p, 0,  3, "", bgcolor=color.new(GOLD,80), text_size=size.tiny)
    table.cell(p, 1,  3, "", bgcolor=color.new(GOLD,80), text_size=size.tiny)
    // 15M Block
    table.cell(p, 0,  4, " 15M Trend", text_color=color.new(WHITE,55), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    table.cell(p, 1,  4, t15Txt + " ", text_color=t15Col, text_size=size.small, bgcolor=color.new(DARK,8), text_halign=text.align_right)
    table.cell(p, 0,  5, " 15M FVG", text_color=color.new(WHITE,55), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    table.cell(p, 1,  5, fvgTxt + " ", text_color=fvgCol, text_size=size.small, bgcolor=color.new(DARK,8), text_halign=text.align_right)
    // Separator
    table.cell(p, 0,  6, "", bgcolor=color.new(GOLD,85), text_size=size.tiny)
    table.cell(p, 1,  6, "", bgcolor=color.new(GOLD,85), text_size=size.tiny)
    // 5M Block
    table.cell(p, 0,  7, " 5M Structure", text_color=color.new(WHITE,55), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    table.cell(p, 1,  7, s5Txt + " ", text_color=s5Col, text_size=size.small, bgcolor=color.new(DARK,8), text_halign=text.align_right)
    table.cell(p, 0,  8, " 5M High", text_color=color.new(WHITE,55), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    table.cell(p, 1,  8, hhTxt + "  " + (na(ph5_1) ? "--" : str.tostring(ph5_1, "#.00")) + " ", text_color=hhCol, text_size=size.small, bgcolor=color.new(DARK,8), text_halign=text.align_right)
    table.cell(p, 0,  9, " 5M Low", text_color=color.new(WHITE,55), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    table.cell(p, 1,  9, hlTxt + "  " + (na(pl5_1) ? "--" : str.tostring(pl5_1, "#.00")) + " ", text_color=hlCol, text_size=size.small, bgcolor=color.new(DARK,8), text_halign=text.align_right)
    // Separator
    table.cell(p, 0, 10, "", bgcolor=color.new(GOLD,85), text_size=size.tiny)
    table.cell(p, 1, 10, "", bgcolor=color.new(GOLD,85), text_size=size.tiny)
    // Entry Block
    table.cell(p, 0, 11, " Entry Zone", text_color=color.new(WHITE,55), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    table.cell(p, 1, 11, zoneTxt + " ", text_color=zoneCol, text_size=size.small, bgcolor=color.new(DARK,8), text_halign=text.align_right)
    table.cell(p, 0, 12, " 1M EMA Cross", text_color=color.new(WHITE,55), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    table.cell(p, 1, 12, (ema1f > ema1s ? "Bull ▲" : "Bear ▼") + " ", text_color=(ema1f > ema1s ? GOLD : PINK), text_size=size.small, bgcolor=color.new(DARK,8), text_halign=text.align_right)
    // Separator
    table.cell(p, 0, 13, "", bgcolor=color.new(GOLD,85), text_size=size.tiny)
    table.cell(p, 1, 13, "", bgcolor=color.new(GOLD,85), text_size=size.tiny)
    // Signal
    table.cell(p, 0, 14, " Signal", text_color=color.new(WHITE,55), text_size=size.tiny, bgcolor=sigBg, text_halign=text.align_left)
    table.cell(p, 1, 14, sigTxt + " ", text_color=sigCol, text_size=size.small, bgcolor=sigBg, text_halign=text.align_right)
    // Goldlinie unten
    table.cell(p, 0, 15, "", bgcolor=color.new(GOLD,80), text_size=size.tiny)
    table.cell(p, 1, 15, "", bgcolor=color.new(GOLD,80), text_size=size.tiny)
    // Footer
    table.cell(p, 0, 16, "Not financial advice.", text_color=color.new(GOLD,65), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    table.cell(p, 1, 16, "", bgcolor=color.new(DARK,8))
    table.cell(p, 0, 17, "", text_color=color.new(WHITE,70), text_size=size.tiny, bgcolor=color.new(DARK,8), text_halign=text.align_left)
    table.cell(p, 1, 17, "", bgcolor=color.new(DARK,8))
````
