# Support - Resistance & Fibonacci [StrixEDGE]

- url: https://www.tradingview.com/script/HqM3gqYf-Support-Resistance-Fibonacci-StrixEDGE/
- type: indicator
- pine_id: PUB;b94f8081bce24d349c8bfffb6b128498
- version: 3.0

## Description

StrixZONE automatically detects Support and Resistance zones from price structure and overlays Fibonacci retracement levels — with a deliberate visual separation between the two. S/R zones are drawn historically (left of current price), while Fibonacci levels project into the future (right of current price). This separation ensures zero overlap and a clean, readable chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW IT WORKS

The indicator operates on two independent analytical layers:

LAYER 1 — SUPPORT & RESISTANCE (Historical)
Automatically detects swing highs and swing lows using configurable pivot lookback detection. The most recent three resistance levels (R1, R2, R3) and three support levels (S1, S2, S3) are tracked and displayed as colored zones extending across the historical portion of the chart, stopping at the current bar.

https://www.tradingview.com/x/xSQZWRxK/

R1/S1 is the most recent and visually strongest. R2/S2 and R3/S3 progressively fade, reflecting their age and diminishing relevance. Resistance zones are red, support zones are teal. Each zone has a configurable thickness based on ATR, creating a price band rather than a single line — because in practice, support and resistance are zones, not exact prices.

https://www.tradingview.com/x/EtoL9RRt/

LAYER 2 — FIBONACCI RETRACEMENT (Forward Projection)
Calculates the highest high and lowest low over a 120-bar lookback and draws seven standard Fibonacci levels between them: 0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, and 100%. All levels project forward from the current bar by a configurable number of bars (default 20), showing where key retracement levels sit ahead of price.

The 50% and 61.8% levels are drawn with thicker solid lines. All others use thinner dashed lines. The 50%–61.8% region is highlighted as the Golden Zone — the area where retracements most frequently find support or resistance in trending markets. Each level displays its exact price at the right edge.

https://www.tradingview.com/x/UGBbGFeh/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VISUAL SEPARATION — WHY IT MATTERS

Most indicators that combine S/R with Fibonacci draw everything on top of the same price area, creating visual clutter that makes the chart harder to read. StrixZONE deliberately separates the two layers in time:

→ S/R zones occupy the left side of the chart (historical price action where the levels were established)
→ Fibonacci levels occupy the right side (projected forward where price is heading)
→ The current bar is the boundary — S/R stops here, Fibonacci starts here

This means you can see at a glance where historical structure sits versus where retracement math says the next key levels are. When a Fibonacci level aligns with a nearby S/R zone, that confluence is immediately visible without the two drawing systems overlapping.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUPPORT & RESISTANCE DETAILS

Detection uses the standard pivot high/low method with a configurable lookback (default 10 bars). A swing high requires the bar's high to be higher than all bars within the lookback window on both sides. The same logic applies in reverse for swing lows.

Levels shift automatically as new pivots are detected. When a new resistance pivot forms, R1 becomes R2, R2 becomes R3, and the new level takes the R1 position. This ensures the most current market structure is always prioritized.

Visual hierarchy:
→ R1 / S1 — most opaque, largest label (most recent, most relevant)
→ R2 / S2 — slightly faded (still relevant but older)
→ R3 / S3 — most faded (historical context, may be invalidated)

https://www.tradingview.com/x/qTrMNxJJ/

Zone width is ATR-based (default 0.2× ATR), so zones automatically adapt to the instrument's volatility. A high-volatility asset gets wider zones; a stable asset gets tighter zones.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FIBONACCI DETAILS

Levels are calculated from the absolute highest high and lowest low over the lookback period (default 120 bars). This captures the dominant price range for retracement analysis.

All seven levels are drawn as horizontal lines projecting right from the current bar:
→ 0% and 100% — range boundaries (dashed, subtle gray)
→ 23.6% and 78.6% — minor retracement levels (dashed)
→ 38.2% — standard retracement (dashed)
→ 50% — midpoint (solid, thick, yellow)
→ 61.8% — golden ratio (solid, thick, orange)

The Golden Zone (50%–61.8%) is filled with a translucent highlight and labeled. This is the area where price most commonly reverses during healthy retracements in trending markets.

Each level includes a price label at the right edge showing the percentage and exact price value, making it easy to set orders at these levels.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DASHBOARD

A compact table in the top-right corner displays:
→ R1 — nearest resistance price
→ S1 — nearest support price
→ FIB 50% — the midpoint price for quick reference
→ POSITION — current price as a percentage of the Fibonacci range (e.g., 72% means price is in the upper portion of the range)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETTINGS

Support & Resistance:
• Pivot Lookback (default 10) — bars required on each side to confirm a swing. Higher values detect fewer but more significant levels.
• Zone Width (default 0.2 ATR) — thickness of each S/R zone. Increase for wider zones on volatile instruments.

Fibonacci:
• Fibonacci Bars Right (default 20) — how far the levels project into the future.
• Golden Zone toggle — show or hide the 50–61.8% highlight.

Display:
• Show S/R Zones — toggle the entire S/R layer.
• Show Fibonacci — toggle the entire Fibonacci layer.
• Show Dashboard — toggle the status table.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT MAKES THIS ORIGINAL

StrixZONE is not simply S/R lines drawn next to Fibonacci lines. Its originality lies in the deliberate temporal separation: S/R zones render historically from where they were established, while Fibonacci levels project exclusively into the future. This design choice eliminates the visual clutter that occurs when both systems draw over the same price bars — a problem common to multi-layer overlay indicators. The ATR-adaptive zone width, the three-tier visual hierarchy for level relevance, and the clean forward projection of Fibonacci create a tool that is structurally distinct from standard S/R or Fibonacci indicators.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RECOMMENDED USE

Designed for all timeframes and all markets with OHLC data: crypto, forex, stocks, indices, commodities. Particularly effective on 15-minute to 4-hour charts for day and swing trading. Works well as a standalone structural analysis tool or alongside momentum indicators like StrixEDGE or StrixPULSE.

Look for confluence: when a Fibonacci level (especially 50% or 61.8%) sits near an S/R zone, that price area carries double significance as a potential reversal or breakout point.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ALERTS

Two alert conditions available:
→ Resistance Breakout — price closes above R1
https://www.tradingview.com/x/n68oCFCQ/
→ Support Breakdown — price closes below S1
https://www.tradingview.com/x/79oIYj1d/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DISCLAIMER
This indicator is a technical analysis tool, not financial advice. No indicator guarantees profitable outcomes. Past performance does not indicate future results. Always apply proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Support - Resistance & Fibonacci [StrixEDGE]", shorttitle="S/R & Fib [StrixEDGE]", overlay=true,
     max_labels_count=50, max_lines_count=30, max_boxes_count=20, max_bars_back=500)

// ══════════════════════════════════════════════════════════════════════
//  v2.1 — Auto Pivot S/R | Break Detection | GZ 0.618–0.786
// ══════════════════════════════════════════════════════════════════════


// ┌─────────────────────────────────────────────────────────────────┐
// │                         INPUTS                                  │
// └─────────────────────────────────────────────────────────────────┘

var GRP_SR = "📊 Support / Resistance"
int    i_pivLen      = input.int(10, "Pivot Lookback", minval=3, maxval=50, group=GRP_SR,
     tooltip="Bars left & right to confirm a swing high/low.")
float  i_zoneW       = input.float(0.3, "Zone Width (ATR×)", minval=0.05, step=0.05, group=GRP_SR,
     tooltip="Width of S/R zone band as a multiple of ATR(14)")
int    i_touchThresh = input.int(3, "Touches for STRONG", minval=2, maxval=10, group=GRP_SR,
     tooltip="Minimum wicks touching the zone to classify as ★ STRONG")
bool   i_showSR      = input.bool(true, "Show S/R Zones", group=GRP_SR)
bool   i_showBroken  = input.bool(true, "Show Broken Levels", group=GRP_SR,
     tooltip="Keep broken S/R levels visible on chart (dimmed). Turn off to hide them completely.")

var GRP_FIB = "📐 Fibonacci"
bool   i_showFib    = input.bool(true, "Show Fibonacci", group=GRP_FIB)
bool   i_showGZ     = input.bool(true, "Golden Zone (0.618–0.786)", group=GRP_FIB)
int    i_fibExt     = input.int(20, "Fibonacci Bars Right", minval=5, maxval=100, group=GRP_FIB)
bool   i_showLabels = input.bool(true, "Show Price Labels", group=GRP_FIB)

var GRP_DASH = "📋 Dashboard"
bool   i_showDash = input.bool(true, "Show Dashboard", group=GRP_DASH)
string i_dashSize = input.string("Tiny", "Dashboard Size", options=["Tiny","Small","Normal","Large","Huge"], group=GRP_DASH)


// ┌─────────────────────────────────────────────────────────────────┐
// │                    COLOR CONSTANTS                               │
// └─────────────────────────────────────────────────────────────────┘
color C_RES    = #EF5350
color C_SUP    = #26A69A
color C_WHITE  = color.white
color C_GZ     = #FF7043
color C_STRONG = #FFD700
color C_BROKEN = #555555
color C_ACTIVE = #4CAF50


// ┌─────────────────────────────────────────────────────────────────┐
// │              CORE CALCULATIONS                                  │
// └─────────────────────────────────────────────────────────────────┘

float atr14 = ta.atr(14)
float zH    = nz(atr14, 1.0) * i_zoneW

// ── Automatic Pivot Detection ───────────────────────────────────
float pivHi = ta.pivothigh(high, i_pivLen, i_pivLen)
float pivLo = ta.pivotlow(low, i_pivLen, i_pivLen)

// ── State: price, origin bar, broken flag, break bar ────────────
// Resistance
var float r1_p = na, var int r1_b = na, var bool r1_brk = false, var int r1_bb = na
var float r2_p = na, var int r2_b = na, var bool r2_brk = false, var int r2_bb = na
var float r3_p = na, var int r3_b = na, var bool r3_brk = false, var int r3_bb = na
// Support
var float s1_p = na, var int s1_b = na, var bool s1_brk = false, var int s1_bb = na
var float s2_p = na, var int s2_b = na, var bool s2_brk = false, var int s2_bb = na
var float s3_p = na, var int s3_b = na, var bool s3_brk = false, var int s3_bb = na

// ── New pivot → shift levels, carry break state ─────────────────
if not na(pivHi)
    r3_p := r2_p, r3_b := r2_b, r3_brk := r2_brk, r3_bb := r2_bb
    r2_p := r1_p, r2_b := r1_b, r2_brk := r1_brk, r2_bb := r1_bb
    r1_p := pivHi, r1_b := bar_index - i_pivLen
    r1_brk := false, r1_bb := na

if not na(pivLo)
    s3_p := s2_p, s3_b := s2_b, s3_brk := s2_brk, s3_bb := s2_bb
    s2_p := s1_p, s2_b := s1_b, s2_brk := s1_brk, s2_bb := s1_bb
    s1_p := pivLo, s1_b := bar_index - i_pivLen
    s1_brk := false, s1_bb := na

// ── Break Detection (close beyond level = broken) ──────────────
// Resistance broken when close > level
if not na(r1_p) and not r1_brk and close > r1_p
    r1_brk := true, r1_bb := bar_index
if not na(r2_p) and not r2_brk and close > r2_p
    r2_brk := true, r2_bb := bar_index
if not na(r3_p) and not r3_brk and close > r3_p
    r3_brk := true, r3_bb := bar_index

// Support broken when close < level
if not na(s1_p) and not s1_brk and close < s1_p
    s1_brk := true, s1_bb := bar_index
if not na(s2_p) and not s2_brk and close < s2_p
    s2_brk := true, s2_bb := bar_index
if not na(s3_p) and not s3_brk and close < s3_p
    s3_brk := true, s3_bb := bar_index


// ── Touch-Count Strength Scorer ─────────────────────────────────
f_touches(float level, float band) =>
    int count = 0
    if not na(level)
        for i = 1 to 150
            if (high[i] >= level - band and high[i] <= level + band) or (low[i] >= level - band and low[i] <= level + band)
                count += 1
    count

int r1_tc = f_touches(r1_p, zH), bool r1_strong = r1_tc >= i_touchThresh
int r2_tc = f_touches(r2_p, zH), bool r2_strong = r2_tc >= i_touchThresh
int r3_tc = f_touches(r3_p, zH), bool r3_strong = r3_tc >= i_touchThresh
int s1_tc = f_touches(s1_p, zH), bool s1_strong = s1_tc >= i_touchThresh
int s2_tc = f_touches(s2_p, zH), bool s2_strong = s2_tc >= i_touchThresh
int s3_tc = f_touches(s3_p, zH), bool s3_strong = s3_tc >= i_touchThresh


// ── Fibonacci ───────────────────────────────────────────────────
float fibHi  = ta.highest(high, 120)
float fibLo  = ta.lowest(low, 120)
float fibRng = fibHi - fibLo
float f000   = fibLo
float f236   = fibLo + fibRng * 0.236
float f382   = fibLo + fibRng * 0.382
float f500   = fibLo + fibRng * 0.500
float f618   = fibLo + fibRng * 0.618
float f786   = fibLo + fibRng * 0.786
float f100   = fibHi


// ┌─────────────────────────────────────────────────────────────────┐
// │                    HELPER FUNCTIONS                              │
// └─────────────────────────────────────────────────────────────────┘

f_price(float p) =>
    string result = na(p) ? "—" : p >= 10000 ? str.tostring(p, "#.##") : p >= 100 ? str.tostring(p, "#.###") : p >= 1 ? str.tostring(p, "#.####") : p >= 0.01 ? str.tostring(p, "#.######") : str.tostring(p, "#.########")
    result


// ┌─────────────────────────────────────────────────────────────────┐
// │     S/R ZONES — Active vs Broken Drawing                        │
// └─────────────────────────────────────────────────────────────────┘

var line  ln_r1 = na, var box bx_r1 = na, var label lb_r1 = na, var label lp_r1 = na
var line  ln_r2 = na, var box bx_r2 = na, var label lb_r2 = na, var label lp_r2 = na
var line  ln_r3 = na, var box bx_r3 = na, var label lb_r3 = na, var label lp_r3 = na
var line  ln_s1 = na, var box bx_s1 = na, var label lb_s1 = na, var label lp_s1 = na
var line  ln_s2 = na, var box bx_s2 = na, var label lb_s2 = na, var label lp_s2 = na
var line  ln_s3 = na, var box bx_s3 = na, var label lb_s3 = na, var label lp_s3 = na

if barstate.islast and i_showSR

    // Delete previous
    line.delete(ln_r1), box.delete(bx_r1), label.delete(lb_r1), label.delete(lp_r1)
    line.delete(ln_r2), box.delete(bx_r2), label.delete(lb_r2), label.delete(lp_r2)
    line.delete(ln_r3), box.delete(bx_r3), label.delete(lb_r3), label.delete(lp_r3)
    line.delete(ln_s1), box.delete(bx_s1), label.delete(lb_s1), label.delete(lp_s1)
    line.delete(ln_s2), box.delete(bx_s2), label.delete(lb_s2), label.delete(lp_s2)
    line.delete(ln_s3), box.delete(bx_s3), label.delete(lb_s3), label.delete(lp_s3)

    int bi         = bar_index
    int active_end = bi + 5   // active levels extend 5 bars right

    // ════════════════════════════════════════════════════════════════
    //  R1 — Most Recent Resistance
    // ════════════════════════════════════════════════════════════════
    if not na(r1_p) and (not r1_brk or i_showBroken)
        int   x1     = nz(r1_b, bi - 10)
        int   endBar = r1_brk ? nz(r1_bb, bi) : active_end
        bool  isAct  = not r1_brk

        int   lw   = isAct ? (r1_strong ? 3 : 2) : 1
        int   bgTr = isAct ? (r1_strong ? 82 : 88) : 95
        color lnCl = isAct ? C_RES : C_BROKEN
        color lbBg = isAct ? (r1_strong ? color.new(C_STRONG, 40) : color.new(C_RES, 60)) : color.new(C_BROKEN, 60)
        string tag = isAct ? (r1_strong ? "★ STRONG R1" : "▼ R1") : "✗ R1"

        ln_r1 := line.new(x1, r1_p, endBar, r1_p, color=lnCl, width=lw, style=isAct ? line.style_solid : line.style_dotted)
        bx_r1 := box.new(x1, r1_p + zH, endBar, r1_p - zH,
             border_color=color.new(lnCl, 85), border_width=0, bgcolor=color.new(lnCl, bgTr))
        lb_r1 := label.new(x1, r1_p + zH, tag,
             style=label.style_label_down, color=lbBg, textcolor=isAct ? C_WHITE : color.new(C_WHITE, 50), size=size.small)
        if i_showLabels and isAct
            lp_r1 := label.new(endBar + 1, r1_p, "R1  " + f_price(r1_p) + (r1_strong ? "  ★" : ""),
                 style=label.style_label_left, color=color.new(C_RES, 70), textcolor=C_RES, size=size.small)

    // ════════════════════════════════════════════════════════════════
    //  R2 — Second Resistance
    // ════════════════════════════════════════════════════════════════
    if not na(r2_p) and (not r2_brk or i_showBroken)
        int   x2     = nz(r2_b, bi - 20)
        int   endBar = r2_brk ? nz(r2_bb, bi) : active_end
        bool  isAct  = not r2_brk

        int   lw   = isAct ? (r2_strong ? 3 : 1) : 1
        int   bgTr = isAct ? (r2_strong ? 82 : 92) : 96
        color lnCl = isAct ? (r2_strong ? C_RES : color.new(C_RES, 25)) : C_BROKEN
        color lbBg = isAct ? (r2_strong ? color.new(C_STRONG, 40) : color.new(C_RES, 70)) : color.new(C_BROKEN, 70)
        string tag = isAct ? (r2_strong ? "★ STRONG R2" : "▼ R2") : "✗ R2"

        ln_r2 := line.new(x2, r2_p, endBar, r2_p, color=lnCl, width=lw, style=isAct ? line.style_solid : line.style_dotted)
        bx_r2 := box.new(x2, r2_p + zH, endBar, r2_p - zH,
             border_color=color.new(lnCl, 90), border_width=0, bgcolor=color.new(lnCl, bgTr))
        lb_r2 := label.new(x2, r2_p + zH, tag,
             style=label.style_label_down, color=lbBg, textcolor=isAct ? color.new(C_WHITE, r2_strong ? 0 : 25) : color.new(C_WHITE, 60), size=size.tiny)
        if i_showLabels and isAct
            lp_r2 := label.new(endBar + 1, r2_p, "R2  " + f_price(r2_p) + (r2_strong ? "  ★" : ""),
                 style=label.style_label_left, color=color.new(C_RES, 80), textcolor=color.new(C_RES, r2_strong ? 0 : 25), size=size.small)

    // ════════════════════════════════════════════════════════════════
    //  R3 — Oldest Resistance
    // ════════════════════════════════════════════════════════════════
    if not na(r3_p) and (not r3_brk or i_showBroken)
        int   x3     = nz(r3_b, bi - 30)
        int   endBar = r3_brk ? nz(r3_bb, bi) : active_end
        bool  isAct  = not r3_brk

        int   lw   = isAct ? (r3_strong ? 3 : 1) : 1
        int   bgTr = isAct ? (r3_strong ? 82 : 94) : 96
        color lnCl = isAct ? (r3_strong ? C_RES : color.new(C_RES, 40)) : C_BROKEN
        color lbBg = isAct ? (r3_strong ? color.new(C_STRONG, 40) : color.new(C_RES, 78)) : color.new(C_BROKEN, 75)
        string tag = isAct ? (r3_strong ? "★ STRONG R3" : "▼ R3") : "✗ R3"

        ln_r3 := line.new(x3, r3_p, endBar, r3_p, color=lnCl, width=lw, style=isAct ? (r3_strong ? line.style_solid : line.style_dashed) : line.style_dotted)
        bx_r3 := box.new(x3, r3_p + zH, endBar, r3_p - zH,
             border_color=color.new(lnCl, 92), border_width=0, bgcolor=color.new(lnCl, bgTr))
        lb_r3 := label.new(x3, r3_p + zH, tag,
             style=label.style_label_down, color=lbBg, textcolor=isAct ? color.new(C_WHITE, r3_strong ? 0 : 40) : color.new(C_WHITE, 65), size=size.tiny)
        if i_showLabels and isAct
            lp_r3 := label.new(endBar + 1, r3_p, "R3  " + f_price(r3_p) + (r3_strong ? "  ★" : ""),
                 style=label.style_label_left, color=color.new(C_RES, 85), textcolor=color.new(C_RES, r3_strong ? 0 : 40), size=size.small)

    // ════════════════════════════════════════════════════════════════
    //  S1 — Most Recent Support
    // ════════════════════════════════════════════════════════════════
    if not na(s1_p) and (not s1_brk or i_showBroken)
        int   x1     = nz(s1_b, bi - 10)
        int   endBar = s1_brk ? nz(s1_bb, bi) : active_end
        bool  isAct  = not s1_brk

        int   lw   = isAct ? (s1_strong ? 3 : 2) : 1
        int   bgTr = isAct ? (s1_strong ? 82 : 88) : 95
        color lnCl = isAct ? C_SUP : C_BROKEN
        color lbBg = isAct ? (s1_strong ? color.new(C_STRONG, 40) : color.new(C_SUP, 60)) : color.new(C_BROKEN, 60)
        string tag = isAct ? (s1_strong ? "★ STRONG S1" : "▲ S1") : "✗ S1"

        ln_s1 := line.new(x1, s1_p, endBar, s1_p, color=lnCl, width=lw, style=isAct ? line.style_solid : line.style_dotted)
        bx_s1 := box.new(x1, s1_p + zH, endBar, s1_p - zH,
             border_color=color.new(lnCl, 85), border_width=0, bgcolor=color.new(lnCl, bgTr))
        lb_s1 := label.new(x1, s1_p - zH, tag,
             style=label.style_label_up, color=lbBg, textcolor=isAct ? C_WHITE : color.new(C_WHITE, 50), size=size.small)
        if i_showLabels and isAct
            lp_s1 := label.new(endBar + 1, s1_p, "S1  " + f_price(s1_p) + (s1_strong ? "  ★" : ""),
                 style=label.style_label_left, color=color.new(C_SUP, 70), textcolor=C_SUP, size=size.small)

    // ════════════════════════════════════════════════════════════════
    //  S2 — Second Support
    // ════════════════════════════════════════════════════════════════
    if not na(s2_p) and (not s2_brk or i_showBroken)
        int   x2     = nz(s2_b, bi - 20)
        int   endBar = s2_brk ? nz(s2_bb, bi) : active_end
        bool  isAct  = not s2_brk

        int   lw   = isAct ? (s2_strong ? 3 : 1) : 1
        int   bgTr = isAct ? (s2_strong ? 82 : 92) : 96
        color lnCl = isAct ? (s2_strong ? C_SUP : color.new(C_SUP, 25)) : C_BROKEN
        color lbBg = isAct ? (s2_strong ? color.new(C_STRONG, 40) : color.new(C_SUP, 70)) : color.new(C_BROKEN, 70)
        string tag = isAct ? (s2_strong ? "★ STRONG S2" : "▲ S2") : "✗ S2"

        ln_s2 := line.new(x2, s2_p, endBar, s2_p, color=lnCl, width=lw, style=isAct ? line.style_solid : line.style_dotted)
        bx_s2 := box.new(x2, s2_p + zH, endBar, s2_p - zH,
             border_color=color.new(lnCl, 90), border_width=0, bgcolor=color.new(lnCl, bgTr))
        lb_s2 := label.new(x2, s2_p - zH, tag,
             style=label.style_label_up, color=lbBg, textcolor=isAct ? color.new(C_WHITE, s2_strong ? 0 : 25) : color.new(C_WHITE, 60), size=size.tiny)
        if i_showLabels and isAct
            lp_s2 := label.new(endBar + 1, s2_p, "S2  " + f_price(s2_p) + (s2_strong ? "  ★" : ""),
                 style=label.style_label_left, color=color.new(C_SUP, 80), textcolor=color.new(C_SUP, s2_strong ? 0 : 25), size=size.small)

    // ════════════════════════════════════════════════════════════════
    //  S3 — Oldest Support
    // ════════════════════════════════════════════════════════════════
    if not na(s3_p) and (not s3_brk or i_showBroken)
        int   x3     = nz(s3_b, bi - 30)
        int   endBar = s3_brk ? nz(s3_bb, bi) : active_end
        bool  isAct  = not s3_brk

        int   lw   = isAct ? (s3_strong ? 3 : 1) : 1
        int   bgTr = isAct ? (s3_strong ? 82 : 94) : 96
        color lnCl = isAct ? (s3_strong ? C_SUP : color.new(C_SUP, 40)) : C_BROKEN
        color lbBg = isAct ? (s3_strong ? color.new(C_STRONG, 40) : color.new(C_SUP, 78)) : color.new(C_BROKEN, 75)
        string tag = isAct ? (s3_strong ? "★ STRONG S3" : "▲ S3") : "✗ S3"

        ln_s3 := line.new(x3, s3_p, endBar, s3_p, color=lnCl, width=lw, style=isAct ? (s3_strong ? line.style_solid : line.style_dashed) : line.style_dotted)
        bx_s3 := box.new(x3, s3_p + zH, endBar, s3_p - zH,
             border_color=color.new(lnCl, 92), border_width=0, bgcolor=color.new(lnCl, bgTr))
        lb_s3 := label.new(x3, s3_p - zH, tag,
             style=label.style_label_up, color=lbBg, textcolor=isAct ? color.new(C_WHITE, s3_strong ? 0 : 40) : color.new(C_WHITE, 65), size=size.tiny)
        if i_showLabels and isAct
            lp_s3 := label.new(endBar + 1, s3_p, "S3  " + f_price(s3_p) + (s3_strong ? "  ★" : ""),
                 style=label.style_label_left, color=color.new(C_SUP, 85), textcolor=color.new(C_SUP, s3_strong ? 0 : 40), size=size.small)


// ┌─────────────────────────────────────────────────────────────────┐
// │     FIBONACCI — Golden Zone 0.618–0.786                         │
// └─────────────────────────────────────────────────────────────────┘

var line fL0 = na, var line fL2 = na, var line fL3 = na
var line fL5 = na, var line fL6 = na, var line fL7 = na, var line fL1 = na
var linefill gzF = na
var label fb0 = na, var label fb2 = na, var label fb3 = na
var label fb5 = na, var label fb6 = na, var label fb7 = na, var label fb1 = na
var label gzLb = na

if barstate.islast and i_showFib
    line.delete(fL0), line.delete(fL2), line.delete(fL3)
    line.delete(fL5), line.delete(fL6), line.delete(fL7), line.delete(fL1)
    linefill.delete(gzF)
    label.delete(fb0), label.delete(fb2), label.delete(fb3)
    label.delete(fb5), label.delete(fb6), label.delete(fb7), label.delete(fb1)
    label.delete(gzLb)

    int fA = bar_index
    int fB = bar_index + i_fibExt
    int fC = fB + 2

    fL0 := line.new(fA, f000, fB, f000, color=color.new(#78909C, 30), width=1, style=line.style_dashed)
    fL2 := line.new(fA, f236, fB, f236, color=color.new(#42A5F5, 10), width=1, style=line.style_dashed)
    fL3 := line.new(fA, f382, fB, f382, color=color.new(#26C6DA, 10), width=1, style=line.style_dashed)
    fL5 := line.new(fA, f500, fB, f500, color=color.new(#FFCA28, 0),  width=2, style=line.style_solid)
    fL6 := line.new(fA, f618, fB, f618, color=color.new(C_GZ, 0),     width=2, style=line.style_solid)
    fL7 := line.new(fA, f786, fB, f786, color=color.new(C_GZ, 0),     width=2, style=line.style_solid)
    fL1 := line.new(fA, f100, fB, f100, color=color.new(#78909C, 30), width=1, style=line.style_dashed)

    if i_showGZ
        gzF  := linefill.new(fL6, fL7, color=color.new(C_GZ, 87))
        gzLb := label.new(fA + i_fibExt / 2, (f618 + f786) / 2.0, "GOLDEN ZONE",
             style=label.style_none, textcolor=color.new(C_GZ, 0), size=size.large)

    fb0 := label.new(fC, f000, "0% — "    + str.tostring(f000, format.mintick), style=label.style_none, textcolor=color.new(#78909C, 20), size=size.normal)
    fb2 := label.new(fC, f236, "23.6% — " + str.tostring(f236, format.mintick), style=label.style_none, textcolor=color.new(#42A5F5, 0),  size=size.normal)
    fb3 := label.new(fC, f382, "38.2% — " + str.tostring(f382, format.mintick), style=label.style_none, textcolor=color.new(#26C6DA, 0),  size=size.normal)
    fb5 := label.new(fC, f500, "50% — "   + str.tostring(f500, format.mintick), style=label.style_none, textcolor=color.new(#FFCA28, 0),  size=size.normal)
    fb6 := label.new(fC, f618, "61.8% — " + str.tostring(f618, format.mintick), style=label.style_none, textcolor=color.new(C_GZ, 0),     size=size.normal)
    fb7 := label.new(fC, f786, "78.6% — " + str.tostring(f786, format.mintick), style=label.style_none, textcolor=color.new(C_GZ, 0),     size=size.normal)
    fb1 := label.new(fC, f100, "100% — "  + str.tostring(f100, format.mintick), style=label.style_none, textcolor=color.new(#78909C, 20), size=size.normal)


// ┌─────────────────────────────────────────────────────────────────┐
// │                       DASHBOARD                                 │
// └─────────────────────────────────────────────────────────────────┘

if i_showDash and barstate.islast
    tbl_sz = switch i_dashSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.tiny

    var table d = table.new(position.top_right, 4, 11,
         bgcolor=color.new(#131722, 5), border_color=color.new(#2A2E39, 0),
         border_width=1, frame_color=color.new(#363A45, 0), frame_width=2)

    // Row 0 — Title
    table.cell(d, 0, 0, "StrixEDGE", text_color=color.white, text_size=tbl_sz, bgcolor=color.new(#1565C0, 0))
    table.cell(d, 1, 0, "v2.1",      text_color=#90CAF9,     text_size=tbl_sz, bgcolor=color.new(#1565C0, 0))
    table.cell(d, 2, 0, "AUTO S/R",  text_color=#90CAF9,     text_size=tbl_sz, bgcolor=color.new(#1565C0, 0))
    table.cell(d, 3, 0, "STATUS",    text_color=#90CAF9,     text_size=tbl_sz, bgcolor=color.new(#1565C0, 0))

    // ── Helper: status text & color ─────────────────────────────
    // R1
    string r1_stat = not na(r1_p) ? (r1_brk ? "✗ BROKEN" : (r1_strong ? "★ STRONG" : "ACTIVE")) : "—"
    color  r1_stCl = not na(r1_p) ? (r1_brk ? C_BROKEN : (r1_strong ? C_STRONG : C_ACTIVE)) : C_BROKEN
    color  r1_pCl  = r1_brk ? C_BROKEN : #FF8A80
    table.cell(d, 0, 1, "▼ R1", text_color=r1_brk ? C_BROKEN : C_RES, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 1, 1, f_price(r1_p), text_color=r1_pCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 2, 1, "", bgcolor=color.new(#1E222D, 0))
    table.cell(d, 3, 1, r1_stat, text_color=r1_stCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))

    // R2
    string r2_stat = not na(r2_p) ? (r2_brk ? "✗ BROKEN" : (r2_strong ? "★ STRONG" : "ACTIVE")) : "—"
    color  r2_stCl = not na(r2_p) ? (r2_brk ? C_BROKEN : (r2_strong ? C_STRONG : C_ACTIVE)) : C_BROKEN
    color  r2_pCl  = r2_brk ? C_BROKEN : color.new(#FF8A80, 25)
    table.cell(d, 0, 2, "▼ R2", text_color=r2_brk ? C_BROKEN : color.new(C_RES, 25), text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 1, 2, f_price(r2_p), text_color=r2_pCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 2, 2, "", bgcolor=color.new(#1E222D, 0))
    table.cell(d, 3, 2, r2_stat, text_color=r2_stCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))

    // R3
    string r3_stat = not na(r3_p) ? (r3_brk ? "✗ BROKEN" : (r3_strong ? "★ STRONG" : "ACTIVE")) : "—"
    color  r3_stCl = not na(r3_p) ? (r3_brk ? C_BROKEN : (r3_strong ? C_STRONG : C_ACTIVE)) : C_BROKEN
    color  r3_pCl  = r3_brk ? C_BROKEN : color.new(#FF8A80, 40)
    table.cell(d, 0, 3, "▼ R3", text_color=r3_brk ? C_BROKEN : color.new(C_RES, 40), text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 1, 3, f_price(r3_p), text_color=r3_pCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 2, 3, "", bgcolor=color.new(#1E222D, 0))
    table.cell(d, 3, 3, r3_stat, text_color=r3_stCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))

    // Separator
    for i = 0 to 3
        table.cell(d, i, 4, "", bgcolor=color.new(#363A45, 0), text_size=size.tiny)

    // S1
    string s1_stat = not na(s1_p) ? (s1_brk ? "✗ BROKEN" : (s1_strong ? "★ STRONG" : "ACTIVE")) : "—"
    color  s1_stCl = not na(s1_p) ? (s1_brk ? C_BROKEN : (s1_strong ? C_STRONG : C_ACTIVE)) : C_BROKEN
    color  s1_pCl  = s1_brk ? C_BROKEN : #80CBC4
    table.cell(d, 0, 5, "▲ S1", text_color=s1_brk ? C_BROKEN : C_SUP, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 1, 5, f_price(s1_p), text_color=s1_pCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 2, 5, "", bgcolor=color.new(#1E222D, 0))
    table.cell(d, 3, 5, s1_stat, text_color=s1_stCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))

    // S2
    string s2_stat = not na(s2_p) ? (s2_brk ? "✗ BROKEN" : (s2_strong ? "★ STRONG" : "ACTIVE")) : "—"
    color  s2_stCl = not na(s2_p) ? (s2_brk ? C_BROKEN : (s2_strong ? C_STRONG : C_ACTIVE)) : C_BROKEN
    color  s2_pCl  = s2_brk ? C_BROKEN : color.new(#80CBC4, 25)
    table.cell(d, 0, 6, "▲ S2", text_color=s2_brk ? C_BROKEN : color.new(C_SUP, 25), text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 1, 6, f_price(s2_p), text_color=s2_pCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 2, 6, "", bgcolor=color.new(#1E222D, 0))
    table.cell(d, 3, 6, s2_stat, text_color=s2_stCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))

    // S3
    string s3_stat = not na(s3_p) ? (s3_brk ? "✗ BROKEN" : (s3_strong ? "★ STRONG" : "ACTIVE")) : "—"
    color  s3_stCl = not na(s3_p) ? (s3_brk ? C_BROKEN : (s3_strong ? C_STRONG : C_ACTIVE)) : C_BROKEN
    color  s3_pCl  = s3_brk ? C_BROKEN : color.new(#80CBC4, 40)
    table.cell(d, 0, 7, "▲ S3", text_color=s3_brk ? C_BROKEN : color.new(C_SUP, 40), text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 1, 7, f_price(s3_p), text_color=s3_pCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 2, 7, "", bgcolor=color.new(#1E222D, 0))
    table.cell(d, 3, 7, s3_stat, text_color=s3_stCl, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))

    // Golden Zone
    table.cell(d, 0, 8, "GZ 0.618", text_color=C_GZ, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 1, 8, str.tostring(f618, format.mintick), text_color=#FFD54F, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 2, 8, "", bgcolor=color.new(#1E222D, 0))
    table.cell(d, 3, 8, "", bgcolor=color.new(#1E222D, 0))

    table.cell(d, 0, 9, "GZ 0.786", text_color=C_GZ, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 1, 9, str.tostring(f786, format.mintick), text_color=#FFD54F, text_size=tbl_sz, bgcolor=color.new(#1E222D, 0))
    table.cell(d, 2, 9, "", bgcolor=color.new(#1E222D, 0))
    table.cell(d, 3, 9, "", bgcolor=color.new(#1E222D, 0))

    // Position
    float pct = fibRng > 0 ? (close - fibLo) / fibRng * 100.0 : 50.0
    color pc  = pct > 50 ? C_SUP : C_RES
    table.cell(d, 0, 10, "POSITION", text_color=#B0BEC5, text_size=tbl_sz, bgcolor=color.new(#131722, 0))
    table.cell(d, 1, 10, str.tostring(pct, "#") + "%", text_color=pc, text_size=tbl_sz, bgcolor=color.new(#131722, 0))
    table.cell(d, 2, 10, "", bgcolor=color.new(#131722, 0))
    table.cell(d, 3, 10, "", bgcolor=color.new(#131722, 0))


// ┌─────────────────────────────────────────────────────────────────┐
// │                        ALERTS                                   │
// └─────────────────────────────────────────────────────────────────┘
alertcondition(not na(r1_p) and close > r1_p and close[1] <= r1_p, "R1 Breakout",  "StrixZONE: R1 broken on {{ticker}} — close at {{close}}")
alertcondition(not na(s1_p) and close < s1_p and close[1] >= s1_p, "S1 Breakdown", "StrixZONE: S1 broken on {{ticker}} — close at {{close}}")
alertcondition(not na(r3_p) and close > r3_p and close[1] <= r3_p, "R3 Breakout",  "StrixZONE: R3 broken on {{ticker}}")
alertcondition(not na(s3_p) and close < s3_p and close[1] >= s3_p, "S3 Breakdown", "StrixZONE: S3 broken on {{ticker}}")

// ══════════════════════════════════════════════════════════════════════
// END OF SCRIPT
// ══════════════════════════════════════════════════════════════════════
````
