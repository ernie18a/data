# Fibonacci Levels Engine [StrixEDGE]

- url: https://www.tradingview.com/script/KIbB2b7s-Fibonacci-Levels-Engine-StrixEDGE/
- type: indicator
- pine_id: PUB;5193943635684e9b91f02043815524e9
- version: 2.0

## Description

What It Does

Fibonacci Levels Engine automatically detects the most recent swing high and swing low within a configurable lookback window, draws the standard Fibonacci retracement grid (0 %, 23.6 %, 38.2 %, 50 %, 61.8 %, 78.6 %, 88.6 %, 100 %) plus the 127.2 % and 161.8 % extensions, and projects every level into the future so you can see where price is heading relative to the structure.

https://www.tradingview.com/x/sbIaH5EV/

What separates this indicator from a plain Fibonacci overlay is the Edge Analysis layer — three original components that work together to tell you how meaningful a given Fibonacci zone is right now, not just where it sits on the chart:

1. Edge Score (0–100) — A composite confluence gauge displayed in the dashboard.
2. Proximity Heatmap — Dynamic line opacity that makes levels glow as price approaches them.
3. ATR Volatility Band — A band around the Golden Zone midpoint that adapts to current volatility.

How It Works

Core: Swing Detection & Fibonacci Grid

The indicator scans the last N bars (default 20, configurable 5–300) to find the highest high and lowest low. It determines trend direction by comparing which extreme occurred first: if the swing low is further back in time than the swing high, the structure is bullish (price moved from low to high); otherwise it is bearish. Fibonacci ratios are then calculated from that range and drawn as horizontal levels from the swing origin to a user-defined projection length (default 30 bars into the future).

Two shaded zones highlight areas of interest:
- Golden Zone (0.618–0.786) — the highest-probability retracement area in classical Fibonacci theory.
https://www.tradingview.com/x/smfDFFyD
- Deep Zone (0.786–0.886) — often the last line of defense before a full retracement.
https://www.tradingview.com/x/LeQephc0/
Both zones, the 50 % midline, and the extension levels can be toggled on or off independently.

Edge Score — Confluence Gauge

The Edge Score combines three independent measurements into a single 0–100 reading:

RSI Momentum Alignment | 0–35 | In a bullish structure, a low RSI (below 35) scores highest because it signals oversold conditions near support. In a bearish structure, a high RSI (above 65) scores highest. Intermediate RSI values receive proportionally lower scores. |
https://www.tradingview.com/x/2Mg7rDht/
| Proximity to Golden Zone | 0–35 | Measures the absolute distance between the current close and the Golden Zone midpoint as a ratio of the total Fibonacci range. The closer price is to the midpoint, the higher the score. |
https://www.tradingview.com/x/lJaUNruG/
| EMA Trend Alignment | 0–30 | Checks the stacking order of the 8, 21, and 55-period EMAs. A fully aligned stack (e.g., EMA 8 > EMA 21 > EMA 55 in a bullish structure) scores 30; partial alignment scores 20; misalignment scores 10. |

The resulting score is classified as STRONG (≥ 75), MODERATE (≥ 50), WEAK (≥ 25), or LOW (< 25) and displayed with a color-coded label in the dashboard. A high Edge Score means RSI, price proximity, and trend direction are all converging at the Fibonacci zone — not just that price touched a line.

Proximity Heatmap

Every Fibonacci level's line opacity is recalculated on each bar based on how far the current close is from that level. When price is near a level, the line becomes more opaque (visually brighter); when price is far away, the line fades. This is computed as a transparency value derived from the ratio of (distance to level) / (total Fibonacci range), scaled between 10 and 75. The effect lets you instantly see which levels are "active" without scanning numbers — the relevant lines stand out on their own.

ATR Volatility Band

A translucent band is drawn around the Golden Zone midpoint, extending ± 0.5 × ATR (default 14-period). This addresses a practical problem: a Fibonacci level is a single price, but real entries need a buffer that accounts for market noise. The band widens in volatile conditions and contracts in quiet ones, giving you a dynamic "fair value area" inside the Golden Zone rather than a fixed line.

Dashboard Panel

A compact table in the top-right corner of the chart displays:
- Trend — Current structural direction (Bull / Bear) with color coding.
- Edge — The composite Edge Score and its label.
- RSI — Current RSI value, color-coded for overbought/oversold extremes.
- G-Zone — Live status showing ✅ with the midpoint price when the close is inside the Golden Zone https://www.tradingview.com/x/mTv7kQ6W/
or ⏳ Waiting when it is outside. https://www.tradingview.com/x/ubukvEju/
- ATR — Current Average True Range value.
- Range — The total Fibonacci range (swing high minus swing low).

Dashboard text size is adjustable (Tiny / Small / Normal / Large).

How to Use It

Identify the structure — Add the indicator to your chart. The dashboard immediately tells you whether the current swing structure is bullish or bearish and shows the Edge Score.

Watch the Golden Zone — When price pulls back toward the 0.618–0.786 area, check the dashboard: a high Edge Score (50+) means RSI and trend EMAs are aligned with the retracement, which increases the odds of a bounce. The G-Zone row will switch from ⏳ to ✅ when price enters the zone.

Use the Volatility Band for entries — Rather than placing a limit order on the exact 0.618 or 0.786 line, use the ATR band as your entry zone. It automatically adjusts to current volatility, giving you a wider buffer in choppy markets and a tighter one in clean trends.

Read the heatmap — Glowing lines tell you which levels price is currently interacting with. If a line is bright and the Edge Score is high, that level carries more weight. If the line is faded, price is far away and the level is not in play.

Settings Overview

- Pivot Lookback (5–300, default 20) — Number of bars scanned for swing high/low detection.
- Right Projection (5–200, default 30) — How far levels extend into the future.
- Golden Zone / Deep Zone / 50 % / Extensions — Toggle individual level groups.
- Edge Score Panel — Show or hide the dashboard.
- ATR Volatility Band — Show or hide the dynamic band.
- Proximity Heatmap — Enable or disable the distance-based line opacity effect.
- ATR / RSI Length — Periods for the ATR and RSI calculations used in the Edge Score and Volatility Band.
- Style — Full color customization for bullish/bearish, zones, bands, levels, labels, and line width.

Set alerts — Four built-in alert conditions are included:
- Price enters the Golden Zone (0.618–0.786)
- Price enters the Deep Zone (0.786–0.886)
- Edge Score reaches 75 or above (strong confluence)
- Price crosses the 0 % or 100 % level (breakout / full retracement)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Fibonacci Levels Engine [StrixEDGE]", "Fibonacci Levels Engine [StrixEDGE]", true,
     max_lines_count  = 500,
     max_labels_count  = 500,
     max_boxes_count   = 500)


// ══════════════════════════════════════════════════════════════════
//                         ⚙️  INPUTS
// ══════════════════════════════════════════════════════════════════

// ── Core ──────────────────────────────────────────────────────────
i_lookback   = input.int(20,  "Pivot Lookback",       minval = 5,  maxval = 300, group = "Core", tooltip = "Number of bars scanned to find swing high / swing low")
i_extend     = input.int(30,  "Right Projection",     minval = 5,  maxval = 200, group = "Core", tooltip = "How many bars to project levels into the future")

// ── Levels ────────────────────────────────────────────────────────
i_showGolden = input.bool(true,  "Golden Zone  (0.618 – 0.786)",   group = "Levels")
i_showDeep   = input.bool(true,  "Deep Zone    (0.786 – 0.886)",   group = "Levels")
i_show50     = input.bool(true,  "Show 0.5 Midline",               group = "Levels")
i_showExt    = input.bool(true,  "Extensions   (1.272 / 1.618)",   group = "Levels")
i_showLabels = input.bool(true,  "Price Labels",                   group = "Levels")

// ── Edge Analysis (unique) ────────────────────────────────────────
i_showEdge   = input.bool(true,  "Edge Score Panel",      group = "Edge Analysis")
i_showVolB   = input.bool(true,  "ATR Volatility Band",   group = "Edge Analysis", tooltip = "Dynamic band around the Golden Zone midpoint based on ATR")
i_heatmap    = input.bool(true,  "Proximity Heatmap",     group = "Edge Analysis", tooltip = "Lines glow brighter as price approaches them")
i_atrLen     = input.int(14,     "ATR Length",  minval = 5, maxval = 50, group = "Edge Analysis")
i_rsiLen     = input.int(14,     "RSI Length",  minval = 5, maxval = 50, group = "Edge Analysis")

// ── Style ─────────────────────────────────────────────────────────
i_bullC      = input.color(#00e676,                "Bullish",          group = "Style")
i_bearC      = input.color(#ff1744,                "Bearish",          group = "Style")
i_goldenC    = input.color(color.new(#ffd740, 60), "Golden Zone Fill", group = "Style")  // ← NDRYSHUAR: 78 → 60 (më e dukshme)
i_deepC      = input.color(color.new(#ff6d00, 82), "Deep Zone Fill",   group = "Style")
i_volBC      = input.color(color.new(#42a5f5, 86), "Volatility Band",  group = "Style")
i_levelC     = input.color(#546e7a,                "Neutral Levels",   group = "Style")
i_lblTxtC    = input.color(#000000,                "Label Text Color", group = "Style", tooltip = "Color of the price text on level labels")
i_lineW      = input.int(1, "Line Width", minval = 1, maxval = 3,      group = "Style")
i_panelSize  = input.string("Small", "Dashboard Size", options = ["Tiny", "Small", "Normal", "Large"], group = "Edge Analysis")


// ══════════════════════════════════════════════════════════════════
//                     📐  CORE CALCULATIONS
// ══════════════════════════════════════════════════════════════════

// ── Swing detection ───────────────────────────────────────────────
swH      = ta.highest(high, i_lookback)
swL      = ta.lowest(low,   i_lookback)
hiOffset = ta.highestbars(high, i_lookback)
loOffset = ta.lowestbars(low,   i_lookback)

// Trend direction: if the low is further back than the high → bullish
isBull   = loOffset < hiOffset
trendC   = isBull ? i_bullC : i_bearC

// ── Fibonacci levels ──────────────────────────────────────────────
fibRange    = swH - swL
safeDivisor = fibRange > 0 ? fibRange : 1.0

calcFib(ratio) =>
    isBull ? swH - ratio * fibRange : swL + ratio * fibRange

f0    = calcFib(0.0)
f236  = calcFib(0.236)
f382  = calcFib(0.382)
f500  = calcFib(0.5)
f618  = calcFib(0.618)
f786  = calcFib(0.786)
f886  = calcFib(0.886)
f100  = calcFib(1.0)

// Extensions
fE127 = calcFib(-0.272)
fE162 = calcFib(-0.618)

// ── Volatility band around golden zone midpoint ───────────────────
atrVal    = ta.atr(i_atrLen)
goldenMid = (f618 + f786) / 2.0
volUpper  = goldenMid + atrVal * 0.5
volLower  = goldenMid - atrVal * 0.5


// ══════════════════════════════════════════════════════════════════
//               🎯  EDGE SCORE  (0 – 100)   [UNIQUE]
// ══════════════════════════════════════════════════════════════════

rsiVal = ta.rsi(close, i_rsiLen)

// Component 1 — RSI momentum alignment (0-35)
rsiScore = 0.0
if isBull
    rsiScore := rsiVal < 35 ? 35.0 : rsiVal < 45 ? 28.0 : rsiVal < 55 ? 18.0 : 8.0
else
    rsiScore := rsiVal > 65 ? 35.0 : rsiVal > 55 ? 28.0 : rsiVal > 45 ? 18.0 : 8.0

// Component 2 — Proximity to golden zone (0-35)
distGolden = math.abs(close - goldenMid)
proxRatio  = 1.0 - math.min(distGolden / safeDivisor, 1.0)
proxScore  = proxRatio * 35.0

// Component 3 — EMA trend alignment (0-30)
ema8  = ta.ema(close, 8)
ema21 = ta.ema(close, 21)
ema55 = ta.ema(close, 55)

trendScore = 0.0
if isBull
    trendScore := ema8 > ema21 and ema21 > ema55 ? 30.0 : ema8 > ema21 ? 20.0 : 10.0
else
    trendScore := ema8 < ema21 and ema21 < ema55 ? 30.0 : ema8 < ema21 ? 20.0 : 10.0

edgeScore  = math.round(rsiScore + proxScore + trendScore)
edgeLabel  = edgeScore >= 75 ? "STRONG" : edgeScore >= 50 ? "MODERATE" : edgeScore >= 25 ? "WEAK" : "LOW"
edgeColorF = edgeScore >= 75 ? #00e676 : edgeScore >= 50 ? #ffd740 : edgeScore >= 25 ? #ff9800 : #ff1744


// ══════════════════════════════════════════════════════════════════
//          🌡️  PROXIMITY HEATMAP ALPHA  [UNIQUE]
// ══════════════════════════════════════════════════════════════════

calcAlpha(float _price) =>
    if i_heatmap and fibRange > 0
        _dist  = math.abs(close - _price)
        _ratio = math.min(_dist / safeDivisor, 1.0)
        int(math.round(_ratio * 65 + 10))
    else
        0


// ══════════════════════════════════════════════════════════════════
//            🖊️  DRAW HELPER  (global scope)
// ══════════════════════════════════════════════════════════════════

drawLvl(int _x1, int _x2, int _xLbl, float _price, string _txt, color _col, int _w, string _sty) =>
    _lineStyle = switch _sty
        "solid"  => line.style_solid
        "dot"    => line.style_dotted
        =>          line.style_dashed
    _alpha = calcAlpha(_price)
    _usedC = color.new(_col, _alpha)
    _ln    = line.new(_x1, _price, _x2, _price, color = _usedC, width = _w, style = _lineStyle)
    _lb    = label.new(_xLbl, _price,
         _txt + "  " + str.tostring(_price, format.mintick),
         style     = label.style_label_left,
         color     = color.new(_col, 88),
         textcolor = i_lblTxtC,
         size      = size.small)
    if not i_showLabels
        label.delete(_lb)
    [_ln, _lb]


// ══════════════════════════════════════════════════════════════════
//                      🎨  DRAWING
// ══════════════════════════════════════════════════════════════════

// Persistent drawing objects
var line  l_f0   = na
var label lb_f0  = na
var line  l_f236 = na
var label lb_f236 = na
var line  l_f382 = na
var label lb_f382 = na
var line  l_f500 = na
var label lb_f500 = na
var line  l_f618 = na
var label lb_f618 = na
var line  l_f786 = na
var label lb_f786 = na
var line  l_f886 = na
var label lb_f886 = na
var line  l_f100 = na
var label lb_f100 = na
var line  l_e127 = na
var label lb_e127 = na
var line  l_e162 = na
var label lb_e162 = na
var box   bx_golden = na
var box   bx_deep   = na
var box   bx_vol    = na
var label lb_goldenTxt = na   // ← E RE: etiketa "GOLDEN ZONE"

// Dashboard table
var table dashboard = table.new(position.top_right, 2, 7,
     bgcolor      = color.new(#0d1117, 5),
     border_color = color.new(#30363d, 0),
     border_width = 1)


if barstate.islast and fibRange > 0

    // ── Coordinates ──────────────────────────────────────────────
    startOff = math.min(hiOffset, loOffset)
    x1       = bar_index + startOff
    x2       = bar_index + i_extend
    xLbl     = x2 + 2

    // ── Cleanup ──────────────────────────────────────────────────
    line.delete(l_f0)
    label.delete(lb_f0)
    line.delete(l_f236)
    label.delete(lb_f236)
    line.delete(l_f382)
    label.delete(lb_f382)
    line.delete(l_f500)
    label.delete(lb_f500)
    line.delete(l_f618)
    label.delete(lb_f618)
    line.delete(l_f786)
    label.delete(lb_f786)
    line.delete(l_f886)
    label.delete(lb_f886)
    line.delete(l_f100)
    label.delete(lb_f100)
    line.delete(l_e127)
    label.delete(lb_e127)
    line.delete(l_e162)
    label.delete(lb_e162)
    box.delete(bx_golden)
    box.delete(bx_deep)
    box.delete(bx_vol)
    label.delete(lb_goldenTxt)   // ← E RE: cleanup

    // ── Main levels ──────────────────────────────────────────────
    [ln0,   lb0]   = drawLvl(x1, x2, xLbl, f0,   "0 %",    trendC,   i_lineW + 1, "solid")
    [ln236, lb236] = drawLvl(x1, x2, xLbl, f236, "23.6 %", i_levelC, i_lineW,     "dash")
    [ln382, lb382] = drawLvl(x1, x2, xLbl, f382, "38.2 %", i_levelC, i_lineW,     "dash")
    [ln618, lb618] = drawLvl(x1, x2, xLbl, f618, "61.8 %", #ffd740,  i_lineW + 1, "solid")   // ← +1 width
    [ln786, lb786] = drawLvl(x1, x2, xLbl, f786, "78.6 %", #ffd740,  i_lineW + 1, "solid")   // ← +1 width
    [ln886, lb886] = drawLvl(x1, x2, xLbl, f886, "88.6 %", #ff6d00,  i_lineW,     "dash")
    [ln100, lb100] = drawLvl(x1, x2, xLbl, f100, "100 %",  trendC,   i_lineW + 1, "solid")

    l_f0   := ln0
    lb_f0  := lb0
    l_f236 := ln236
    lb_f236 := lb236
    l_f382 := ln382
    lb_f382 := lb382
    l_f618 := ln618
    lb_f618 := lb618
    l_f786 := ln786
    lb_f786 := lb786
    l_f886 := ln886
    lb_f886 := lb886
    l_f100 := ln100
    lb_f100 := lb100

    // 50 % midline (optional)
    if i_show50
        [ln500, lb500] = drawLvl(x1, x2, xLbl, f500, "50 %", i_levelC, i_lineW, "dot")
        l_f500  := ln500
        lb_f500 := lb500

    // Extensions (optional)
    if i_showExt
        [lnE1, lbE1] = drawLvl(x1, x2, xLbl, fE127, "127.2 %", trendC, i_lineW, "dot")
        [lnE2, lbE2] = drawLvl(x1, x2, xLbl, fE162, "161.8 %", trendC, i_lineW, "dot")
        l_e127  := lnE1
        lb_e127 := lbE1
        l_e162  := lnE2
        lb_e162 := lbE2

    // ── Golden Zone fill + LABEL ─────────────────────────────────
    if i_showGolden
        gTop = math.max(f618, f786)
        gBot = math.min(f618, f786)
        bx_golden := box.new(x1, gTop, x2, gBot,
             border_color = color.new(#ffd740, 35),    // ← më e dukshme (ishte 60)
             border_width = 2,                          // ← më e trashë (ishte 1)
             border_style = line.style_solid,           // ← solid (ishte dotted)
             bgcolor      = i_goldenC)

        // ⭐ Etiketa GOLDEN ZONE — në qendër të zonës
        lb_goldenTxt := label.new(
             math.round(math.avg(x1, x2)),              // x = qendra horizontale
             math.avg(gTop, gBot),                       // y = qendra vertikale
             "⭐ GOLDEN ZONE",
             style          = label.style_label_center,
             color          = color.new(#ffd740, 80),
             textcolor      = color.rgb(7, 7, 7),
             size           = size.normal,
             text_font_family = font.family_monospace)

    // ── Deep Zone fill ───────────────────────────────────────────
    if i_showDeep
        dTop = math.max(f786, f886)
        dBot = math.min(f786, f886)
        bx_deep := box.new(x1, dTop, x2, dBot,
             border_color = color.new(#ff6d00, 70),
             border_width = 1,
             border_style = line.style_dotted,
             bgcolor      = i_deepC)

    // ── Volatility Band fill ─────────────────────────────────────
    if i_showVolB
        bx_vol := box.new(x1, volUpper, x2, volLower,
             border_color = color.new(#42a5f5, 75),
             border_width = 1,
             border_style = line.style_dotted,
             bgcolor      = i_volBC)


// ══════════════════════════════════════════════════════════════════
//                    📊  DASHBOARD PANEL
// ══════════════════════════════════════════════════════════════════

// Golden Zone check (needed by dashboard before alerts)
inGolden = (close >= math.min(f618, f786)) and (close <= math.max(f618, f786))

// Resolve dashboard size from input
panelSz = switch i_panelSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    =>          size.small

// Header uses one step larger than body
panelHdr = switch i_panelSize
    "Tiny"   => size.small
    "Small"  => size.normal
    "Normal" => size.large
    "Large"  => size.huge
    =>          size.normal

if barstate.islast and i_showEdge
    // Header
    table.cell(dashboard, 0, 0, "Strix", text_color = #ffffff, text_size = panelHdr, text_font_family = font.family_monospace)
    table.cell(dashboard, 1, 0, "EDGE",  text_color = trendC,  text_size = panelHdr, text_font_family = font.family_monospace)

    // Trend
    table.cell(dashboard, 0, 1, "Trend",  text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 1, isBull ? "▲ BULL" : "▼ BEAR", text_color = trendC, text_size = panelSz, text_font_family = font.family_monospace)

    // Edge Score
    table.cell(dashboard, 0, 2, "Edge",   text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 2, str.tostring(edgeScore) + "  " + edgeLabel, text_color = edgeColorF, text_size = panelSz, text_font_family = font.family_monospace)

    // RSI
    table.cell(dashboard, 0, 3, "RSI",    text_color = #8b949e, text_size = panelSz)
    rsiC = rsiVal > 70 ? #ff1744 : rsiVal < 30 ? #00e676 : #c9d1d9
    table.cell(dashboard, 1, 3, str.tostring(rsiVal, "#.1"), text_color = rsiC, text_size = panelSz, text_font_family = font.family_monospace)

    // Golden Zone status (✅ active / ⏳ waiting)
    table.cell(dashboard, 0, 4, "G-Zone", text_color = #8b949e, text_size = panelSz)
    gZoneText = inGolden ? "✅ " + str.tostring(goldenMid, format.mintick) : "⏳ Waiting"
    gZoneClr  = inGolden ? #00e676 : #8b949e
    table.cell(dashboard, 1, 4, gZoneText, text_color = gZoneClr, text_size = panelSz, text_font_family = font.family_monospace)

    // ATR
    table.cell(dashboard, 0, 5, "ATR",    text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 5, str.tostring(atrVal, format.mintick), text_color = #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)

    // Range
    table.cell(dashboard, 0, 6, "Range",  text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 6, str.tostring(fibRange, format.mintick), text_color = #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)


// ══════════════════════════════════════════════════════════════════
//                      🔔  ALERTS
// ══════════════════════════════════════════════════════════════════

alertcondition(inGolden, "StrixEDGE: Golden Zone Entry",  "Price entered the Fibonacci Golden Zone (0.618–0.786)")

inDeep = (close >= math.min(f786, f886)) and (close <= math.max(f786, f886))
alertcondition(inDeep,   "StrixEDGE: Deep Zone Entry",    "Price entered the Fibonacci Deep Zone (0.786–0.886)")

alertcondition(edgeScore >= 75, "StrixEDGE: Strong Edge",  "Edge Score >= 75 — high-probability Fibonacci confluence detected")

alertcondition(ta.cross(close, f0), "StrixEDGE: Break 0 %", "Price crossed the Fibonacci 0 % level")

alertcondition(ta.cross(close, f100), "StrixEDGE: Full Retrace", "Price crossed the Fibonacci 100 % level (full retracement)")
````
