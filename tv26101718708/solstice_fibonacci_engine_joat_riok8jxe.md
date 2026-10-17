# Solstice Fibonacci Engine [JOAT]

- url: https://www.tradingview.com/script/riok8JxE-Solstice-Fibonacci-Engine-JOAT/
- type: indicator
- pine_id: PUB;b5a411606a4049b28c5ef21d54771d83
- version: 1.0

## Description

Solstice Fibonacci Engine [JOAT]

[b]Introduction[/b]

The Solstice Fibonacci Engine is a fully automatic Fibonacci retracement and extension tool built for traders who want institutional-grade price levels drawn on their chart without the tedium of manually dragging anchor points. It detects the dominant swing high and swing low within your currently visible chart range, recalculates every time you scroll or zoom, and renders the complete Fibonacci suite — retracements from 0% to 100% and extensions to -100% — in a single, clean overlay.

The engine is purpose-built around two price zones that institutional order flow traders treat as highest-probability areas: the OTE (Optimal Trade Entry) zone from 61.8% to 78.6% retracement, and the Target Zone from -50% to -61.8% extension. These zones are shaded and labeled automatically, with TP1 through TP4 labels placed at the key confluence levels that align with those areas, giving you a ready-made trade management framework the moment any new swing is established.

[image]https://www.tradingview.com/x/YxIqdHoi/[/image]

[b]Core Concepts[/b]

[b]Visible Range Swing Detection[/b]

Unlike most Fibonacci tools that require manual anchoring or use fixed lookback lengths, Solstice tracks the swing high and swing low within the portion of the chart you are actually looking at:

[pine]
int  visLeft  = int(chart.left_visible_bar_time)
int  visRight = int(chart.right_visible_bar_time)
bool isVis    = time >= visLeft and time <= visRight

if isVis
    if na(swHi) or high > swHi
        swHi    := high
        swHiBar := bar_index
    if na(swLo) or low < swLo
        swLo    := low
        swLoBar := bar_index
[/pine]

When you scroll left or right the swing resets instantly to reflect your new visible window. This makes the tool behave like a dynamic Fibonacci that always measures the most contextually relevant move — the one you are actually analyzing.

[b]Trend Direction from Swing Sequence[/b]

The engine determines whether price is in an uptrend or downtrend by comparing the bar index of the swing high against the bar index of the swing low:

[pine]
bool trendUp = nz(swLoBar, 0) < nz(swHiBar, 0)
[/pine]

If the swing low came first (left) and the swing high came after (right), price moved up — so retracement levels are drawn from the top down. If the swing high came first, price moved down and levels are drawn from the bottom up. This single boolean drives whether TP1–TP4 labels are placed above or below current price.

[b]OTE Zone — 61.8% to 78.6%[/b]

The Optimal Trade Entry zone marks the golden pocket of Fibonacci retracement theory. Price returning into this band after a clean impulsive move often finds the institutional order flow that originally created the swing:

[pine]
if showOTE
    fibZone(color.new(oteClr, 90), 61.8, 78.6, trendUp,
            bar_index - 2, lx, swHi, swLo, "OTE ZONE")
[/pine]

The zone is rendered as a shaded box extending to the right of the last visible bar, keeping it visible as new bars form. An alert fires on bar close the first time price enters this zone after it was outside it.

[b]Target Zone — -50% to -61.8% Extension[/b]

The Target Zone marks the take-profit extension area beyond the 0% level:

[pine]
if showTgt
    fibZone(color.new(tgtClr, 90), -50.0, -61.8, trendUp,
            bar_index - 2, lx, swHi, swLo, "TARGET ZONE")
[/pine]

When price has retraced into the OTE and reversed, the -50% to -61.8% extension zone becomes the natural profit target objective — where the move typically exhausts before the next consolidation.

[b]TP1–TP4 Trade Management Labels[/b]

Four take-profit labels are placed at the levels that define a complete trade management plan from entry to full profit-taking:

| Label | Level | Meaning |
|-------|-------|---------|
| TP1   | 38.2% | First objective — scalp or partial close |
| TP2   | 0%    | Full return to the original swing point |
| TP3   | -27.2% | First extension beyond the swing |
| TP4   | -61.8% | Deep extension — full target zone |

[b]Features[/b]

[list]
[*] Auto swing detection from visible chart range — no manual anchoring required
[*] Dynamic recalculation on every chart scroll or zoom
[*] Full Fibonacci suite: 0%, 23.6%, 38.2%, 50%, 61.8%, 70.6%, 78.6%, 100%, -27.2%, -50%, -61.8%, -100%, 150%, 200%
[*] Per-level toggle switches — show only the levels you want
[*] OTE Zone (61.8%–78.6%) shaded box with right-extension
[*] Target Zone (-50% to -61.8%) shaded box with right-extension
[*] TP1–TP4 labels with optional percentage labels on every level
[*] Optional swing diagonal line from anchor to anchor
[*] Dashboard showing swing trend, zone touch status, swing high/low, and range
[*] Auto dark/light theme detection
[*] Alerts fire on confirmed bar close when price enters OTE or Target Zone
[*] Webhook JSON alert format for automation
[*] Watermark
[/list]

[image]https://www.tradingview.com/x/O0aW7M0c/[/image]

[b]Input Parameters[/b]

[b]Main Settings[/b]
[list]
[*] Show All Elements — master toggle for all drawing objects
[*] Show Swing Diagonal Line — draws a line connecting the two swing anchor points
[*] Line Width — 1 to 5 pixels
[*] Line Style — Solid, Dashed, or Dotted
[*] Label Offset (bars) — how far to the right labels are placed beyond the last bar
[/list]

[b]Fibonacci Levels[/b]
[list]
[*] Individual toggles for each level: 0%, 23.6%, 38.2%, 50%, 61.8%, 70.6%, 78.6%, 100%, -27.2%, -50%, -61.8%, -100%, 150%, 200%
[/list]

[b]Zones and Targets[/b]
[list]
[*] Show OTE Zone — toggles the 61.8%–78.6% shaded box
[*] Show Target Zone — toggles the -50% to -61.8% shaded box
[*] Show Zone Labels — text inside zone boxes
[*] Show TP1–TP4 Labels — take-profit label markers
[*] Show Level % Labels — percentage text on every drawn level line
[/list]

[b]Visual Settings[/b]
[list]
[*] Theme — Auto (reads chart background), Dark, or Light
[*] Show Dashboard — compact panel showing current swing readings
[*] Dashboard Position — Top Left, Top Right, Bottom Left, Bottom Right
[*] Show Watermark
[*] Webhook JSON — switches alerts to machine-readable JSON format
[/list]

[b]Colors[/b]
[list]
[*] Fib Lines — color for all retracement/extension level lines
[*] OTE Zone — fill color for the OTE box
[*] Target Zone — fill color for the Target Zone box
[/list]

[b]How to Use[/b]

[list]
[*] Add the indicator to any chart on any timeframe — it automatically maps to your current visible range.
[*] Zoom or scroll your chart to frame the impulsive swing you want to analyze. The Fibonacci grid recalculates to match.
[*] Look for price to retrace into the [b]OTE Zone[/b] (gold band between 61.8% and 78.6%). This is the institutional entry area.
[*] When price reverses out of the OTE zone, monitor the [b]TP1[/b] label at 38.2% for partial profits, [b]TP2[/b] at 0% for full return to the swing origin, and [b]TP3/TP4[/b] in the Target Zone for extended runners.
[*] Set the OTE Zone and Target Zone alerts to receive notifications when price enters either area on bar close.
[*] Enable percentage labels if you need to confirm exact level values for manual entries.
[/list]

[b]Indicator Limitations[/b]

[list]
[*] The swing is determined by the highest high and lowest low within the visible range only — it does not use a structural pivot detection algorithm. On heavily zoomed-out charts, the swing might span an unusually long period.
[*] Fibonacci levels are mathematical retracements of the detected swing range. They are areas of interest, not guaranteed reversal zones. Always combine with your own confluence analysis.
[*] The OTE and Target Zone alerts trigger only on the first bar close when price enters the zone from outside. If price exits and re-enters, a new alert fires.
[*] Retracement drawing regenerates on every bar close at the last bar. On very high-resolution timeframes with large numbers of active objects, this can approach TradingView drawing limits.
[/list]

[b]Originality Statement[/b]

The Solstice Fibonacci Engine is an original Pine Script v6 implementation. Its use of chart.left_visible_bar_time and chart.right_visible_bar_time for dynamic visible-range swing detection is a novel approach that produces a self-adjusting Fibonacci tool with no manual intervention. The OTE and Target Zone framework, TP1–TP4 label system, and scroll-responsive recalculation are original design decisions made specifically for this publication.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. It does not constitute financial advice. Fibonacci levels are areas of potential price reaction, not certainties. Past Fibonacci confluence does not guarantee future performance. Always use proper risk management and consult a licensed financial professional before trading.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(
    title            = "Solstice Fibonacci Engine [JOAT]",
    shorttitle       = "SFE [JOAT]",
    overlay          = true,
    max_lines_count  = 500,
    max_labels_count = 500,
    max_boxes_count  = 500)

// ─── Groups ───────────────────────────────────────────────────────────────────
G_MAIN  = "Main Settings"
G_LEVS  = "Fibonacci Levels"
G_ZONES = "Zones and Targets"
G_VIS   = "Visual Settings"
G_DASH  = "Dashboard"
G_ALERT = "Alerts"
G_COL   = "Colors"

INDICATOR_VERSION = "v1.0.0"

// ─── Inputs — Main ────────────────────────────────────────────────────────────
showAll      = input.bool(true,    "Show All Elements",        group=G_MAIN)
showDiag     = input.bool(false,   "Show Swing Diagonal Line", group=G_MAIN)
lineW        = input.int(1,        "Line Width",    minval=1, maxval=5, group=G_MAIN)
lineStyleStr = input.string("Dashed","Line Style",  options=["Solid","Dashed","Dotted"], group=G_MAIN)
labelOffset  = input.int(15,       "Label Offset (bars)", minval=5, maxval=60, group=G_MAIN)

// ─── Inputs — Levels (toggles) ────────────────────────────────────────────────
sh0     = input.bool(true,  "0%",      inline="lv1", group=G_LEVS)
sh236   = input.bool(false, "23.6%",   inline="lv1", group=G_LEVS)
sh382   = input.bool(true,  "38.2%",   inline="lv1", group=G_LEVS)
sh500   = input.bool(false, "50%",     inline="lv2", group=G_LEVS)
sh618   = input.bool(true,  "61.8%",   inline="lv2", group=G_LEVS)
sh706   = input.bool(true,  "70.6%",   inline="lv2", group=G_LEVS)
sh786   = input.bool(true,  "78.6%",   inline="lv3", group=G_LEVS)
sh100   = input.bool(true,  "100%",    inline="lv3", group=G_LEVS)
shN272  = input.bool(true,  "-27.2%",  inline="lv4", group=G_LEVS)
shN05   = input.bool(true,  "-50%",    inline="lv4", group=G_LEVS)
shN618  = input.bool(true,  "-61.8%",  inline="lv5", group=G_LEVS)
shN1    = input.bool(false, "-100%",   inline="lv5", group=G_LEVS)
sh150   = input.bool(false, "150%",    inline="lv6", group=G_LEVS)
sh200   = input.bool(false, "200%",    inline="lv6", group=G_LEVS)

// ─── Inputs — Zones ───────────────────────────────────────────────────────────
showOTE    = input.bool(true,  "Show OTE Zone (61.8–78.6%)",    group=G_ZONES)
showTgt    = input.bool(true,  "Show Target Zone (-50% to -61.8%)", group=G_ZONES)
showTxt    = input.bool(true,  "Show Zone Labels",              group=G_ZONES)
showTpLbls = input.bool(true,  "Show TP1–TP4 Labels",           group=G_ZONES)
showPctLbls = input.bool(false,"Show Level % Labels",           group=G_ZONES)

// ─── Inputs — Visual ──────────────────────────────────────────────────────────
themeStr   = input.string("Auto","Theme", options=["Auto","Dark","Light"], group=G_VIS)
showDash   = input.bool(true,   "Show Dashboard",  group=G_DASH)
dashPosStr = input.string("Top Right","Position",
    options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=G_DASH)
showWM     = input.bool(true,   "Show Watermark",  group=G_VIS)
webhookFmt = input.bool(false,  "Webhook JSON",    group=G_ALERT)
fibClr     = input.color(#FF8F00,   "Fib Lines",   inline="c1", group=G_COL)
oteClr     = input.color(#FFD600,   "OTE Zone",    inline="c1", group=G_COL)
tgtClr     = input.color(#00C853,   "Target Zone", inline="c2", group=G_COL)

// ─── Theme ────────────────────────────────────────────────────────────────────
isDark  = switch themeStr
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128

TXT     = isDark ? #E0E0E0 : #1A1A1A
TXT_M   = isDark ? color.new(#9E9E9E, 0) : color.new(#757575, 0)
TBL_BG  = isDark ? color.new(#0D1117, 5) : color.new(#FFFFFF, 5)
TBL_BD  = isDark ? color.new(#21262D, 0) : color.new(#D0D0D0, 0)
TBL_ALT = isDark ? color.new(#161B22, 0) : color.new(#F6F8FA, 0)
HDR_BG  = color.new(#1565C0, 0)
LBL_CLR = isDark ? #FFFFFF : #212121
TP_BG   = isDark ? color.new(#424242, 80) : color.new(#FFFFFF, 80)
WM_C    = isDark ? color.new(#FFFFFF, 85) : color.new(#000000, 85)

// ─── Utility ──────────────────────────────────────────────────────────────────
safeDiv(float n, float d, float fb = 0.0) =>
    d != 0.0 and not na(n) and not na(d) ? n / d : fb

getLStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        =>          line.style_dashed

getDashPos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>               position.top_right

// Fibonacci zone box drawing helper
fibZone(color zClr, float pct1, float pct2, bool isUp, int leftBar, int rightBar,
        float swHi, float swLo, string lbl) =>
    float rng = swHi - swLo
    float r1  = 1.0 - (pct1 / 100.0)
    float r2  = 1.0 - (pct2 / 100.0)
    float p1  = isUp ? swLo + rng * r1 : swHi - rng * r1
    float p2  = isUp ? swLo + rng * r2 : swHi - rng * r2
    var box b = box.new(na, na, na, na, xloc=xloc.bar_index,
        border_style=line.style_dashed, extend=extend.right,
        border_color=color.new(color.gray, 70), text_color=color.new(color.gray, 70),
        text_halign=text.align_right)
    box.set_lefttop(b, leftBar, math.max(p1, p2))
    box.set_rightbottom(b, rightBar, math.min(p1, p2))
    box.set_bgcolor(b, zClr)
    box.set_text(b, showTxt ? lbl : "")

// ─── Swing Detection (visible range) ─────────────────────────────────────────
var float swHi    = na
var float swLo    = na
var int   swHiBar = na
var int   swLoBar = na

int  visLeft  = int(chart.left_visible_bar_time)
int  visRight = int(chart.right_visible_bar_time)
bool isVis    = time >= visLeft and time <= visRight

var int lastLeft  = na
var int lastRight = na

// Reset swing on visible range change (user scrolls)
if barstate.isfirst or visLeft != lastLeft or visRight != lastRight
    swHi     := na
    swLo     := na
    swHiBar  := na
    swLoBar  := na
    lastLeft  := visLeft
    lastRight := visRight

if isVis
    if na(swHi) or high > swHi
        swHi    := high
        swHiBar := bar_index
    if na(swLo) or low < swLo
        swLo    := low
        swLoBar := bar_index

float swRange  = nz(swHi - swLo, 0.0)
bool  trendUp  = nz(swLoBar, 0) < nz(swHiBar, 0)
bool  hasSwing = not na(swHi) and not na(swLo) and swRange > 0.0

// ─── Zone Touch Detection for Alerts ─────────────────────────────────────────
var bool inOTE    = false
var bool inTarget = false

float oteHi = hasSwing ? (trendUp ? swHi - swRange * 0.618 : swLo + swRange * 0.618) : na
float oteLo = hasSwing ? (trendUp ? swHi - swRange * 0.786 : swLo + swRange * 0.786) : na
float oteTop = not na(oteHi) and not na(oteLo) ? math.max(oteHi, oteLo) : na
float oteBot = not na(oteHi) and not na(oteLo) ? math.min(oteHi, oteLo) : na

float tgtHi  = hasSwing ? (trendUp ? swHi + swRange * 0.5  : swLo - swRange * 0.5 ) : na
float tgtLo  = hasSwing ? (trendUp ? swHi + swRange * 0.618: swLo - swRange * 0.618) : na
float tgtTop = not na(tgtHi) and not na(tgtLo) ? math.max(tgtHi, tgtLo) : na
float tgtBot = not na(tgtHi) and not na(tgtLo) ? math.min(tgtHi, tgtLo) : na

bool inOTEnow  = not na(oteTop) and not na(oteBot) and close <= oteTop and close >= oteBot
bool inTgtnow  = not na(tgtTop) and not na(tgtBot) and close <= tgtTop and close >= tgtBot
bool oteTouch  = inOTEnow  and not inOTE  and barstate.isconfirmed and hasSwing
bool tgtTouch  = inTgtnow  and not inTarget and barstate.isconfirmed and hasSwing

if barstate.isconfirmed
    inOTE    := inOTEnow
    inTarget := inTgtnow

// ─── Drawing on Last Bar ─────────────────────────────────────────────────────
var line[]  fibLines  = array.new<line>()
var label[] fibLabels = array.new<label>()
var label[] tpLabels  = array.new<label>()
var line    diagLine  = na

if barstate.islast and hasSwing and showAll

    // Cleanup previous objects
    if not na(diagLine)
        line.delete(diagLine)
    for l in fibLines
        line.delete(l)
    array.clear(fibLines)
    for lb in fibLabels
        label.delete(lb)
    array.clear(fibLabels)
    for lb in tpLabels
        label.delete(lb)
    array.clear(tpLabels)

    float diff   = swRange
    int   lx     = bar_index + labelOffset
    string ls    = getLStyle(lineStyleStr)

    // ── Build level arrays ──────────────────────────────────────────────────
    var array<float>  lvls = array.new<float>()
    var array<string> pcts = array.new<string>()
    array.clear(lvls)
    array.clear(pcts)

    float tp1 = na
    float tp2 = na
    float tp3 = na
    float tp4 = na

    if trendUp
        float lv0    = swHi
        float lv236  = swHi - diff * 0.236
        float lv382  = swHi - diff * 0.382
        float lv500  = swHi - diff * 0.500
        float lv618  = swHi - diff * 0.618
        float lv706  = swHi - diff * 0.706
        float lv786  = swHi - diff * 0.786
        float lv100  = swLo
        float lvN272 = swHi + diff * 0.272
        float lvN05  = swHi + diff * 0.500
        float lvN618 = swHi + diff * 0.618
        float lvN1   = swHi + diff
        float lv150  = swHi - diff * 1.500
        float lv200  = swHi - diff * 2.000

        tp1 := lv382
        tp2 := lv0
        tp3 := lvN272
        tp4 := lvN618

        if sh0
            array.push(lvls, lv0)
            array.push(pcts, "0%")
        if sh236
            array.push(lvls, lv236)
            array.push(pcts, "23.6%")
        if sh382
            array.push(lvls, lv382)
            array.push(pcts, "38.2%")
        if sh500
            array.push(lvls, lv500)
            array.push(pcts, "50%")
        if sh618
            array.push(lvls, lv618)
            array.push(pcts, "61.8%")
        if sh706
            array.push(lvls, lv706)
            array.push(pcts, "70.6%")
        if sh786
            array.push(lvls, lv786)
            array.push(pcts, "78.6%")
        if sh100
            array.push(lvls, lv100)
            array.push(pcts, "100%")
        if shN272
            array.push(lvls, lvN272)
            array.push(pcts, "-27.2%")
        if shN05
            array.push(lvls, lvN05)
            array.push(pcts, "-50%")
        if shN618
            array.push(lvls, lvN618)
            array.push(pcts, "-61.8%")
        if shN1
            array.push(lvls, lvN1)
            array.push(pcts, "-100%")
        if sh150
            array.push(lvls, lv150)
            array.push(pcts, "150%")
        if sh200
            array.push(lvls, lv200)
            array.push(pcts, "200%")

        if showDiag
            diagLine := line.new(swLoBar, swLo, swHiBar, swHi,
                color=fibClr, width=lineW, style=ls)
    else
        float lv0    = swLo
        float lv236  = swLo + diff * 0.236
        float lv382  = swLo + diff * 0.382
        float lv500  = swLo + diff * 0.500
        float lv618  = swLo + diff * 0.618
        float lv706  = swLo + diff * 0.706
        float lv786  = swLo + diff * 0.786
        float lv100  = swHi
        float lvN272 = swLo - diff * 0.272
        float lvN05  = swLo - diff * 0.500
        float lvN618 = swLo - diff * 0.618
        float lvN1   = swLo - diff
        float lv150  = swLo + diff * 1.500
        float lv200  = swLo + diff * 2.000

        tp1 := lv382
        tp2 := lv0
        tp3 := lvN272
        tp4 := lvN618

        if sh0
            array.push(lvls, lv0)
            array.push(pcts, "0%")
        if sh236
            array.push(lvls, lv236)
            array.push(pcts, "23.6%")
        if sh382
            array.push(lvls, lv382)
            array.push(pcts, "38.2%")
        if sh500
            array.push(lvls, lv500)
            array.push(pcts, "50%")
        if sh618
            array.push(lvls, lv618)
            array.push(pcts, "61.8%")
        if sh706
            array.push(lvls, lv706)
            array.push(pcts, "70.6%")
        if sh786
            array.push(lvls, lv786)
            array.push(pcts, "78.6%")
        if sh100
            array.push(lvls, lv100)
            array.push(pcts, "100%")
        if shN272
            array.push(lvls, lvN272)
            array.push(pcts, "-27.2%")
        if shN05
            array.push(lvls, lvN05)
            array.push(pcts, "-50%")
        if shN618
            array.push(lvls, lvN618)
            array.push(pcts, "-61.8%")
        if shN1
            array.push(lvls, lvN1)
            array.push(pcts, "-100%")
        if sh150
            array.push(lvls, lv150)
            array.push(pcts, "150%")
        if sh200
            array.push(lvls, lv200)
            array.push(pcts, "200%")

        if showDiag
            diagLine := line.new(swHiBar, swHi, swLoBar, swLo,
                color=fibClr, width=lineW, style=ls)

    // ── Draw Fibonacci level lines ─────────────────────────────────────────
    for i = 0 to array.size(lvls) - 1
        float lvl = array.get(lvls, i)
        string pct = array.get(pcts, i)
        ln = line.new(bar_index - 2, lvl, lx, lvl,
            color=fibClr, width=lineW, style=ls)
        array.push(fibLines, ln)
        if showPctLbls
            lb = label.new(lx, lvl, pct,
                textcolor=LBL_CLR, style=label.style_none, size=size.small)
            array.push(fibLabels, lb)

    // ── TP Labels ──────────────────────────────────────────────────────────
    if showTpLbls
        if not na(tp1) and sh382
            array.push(tpLabels, label.new(lx + 4, tp1, "TP1",
                textcolor=LBL_CLR, style=label.style_label_center, size=size.small, color=TP_BG))
        if not na(tp2) and sh0
            array.push(tpLabels, label.new(lx + 4, tp2, "TP2",
                textcolor=LBL_CLR, style=label.style_label_center, size=size.small, color=TP_BG))
        if not na(tp3) and shN272
            array.push(tpLabels, label.new(lx + 4, tp3, "TP3",
                textcolor=LBL_CLR, style=label.style_label_center, size=size.small, color=TP_BG))
        if not na(tp4) and shN618
            array.push(tpLabels, label.new(lx + 4, tp4, "TP4",
                textcolor=LBL_CLR, style=label.style_label_center, size=size.small, color=TP_BG))

    // ── Zone boxes ────────────────────────────────────────────────────────
    if showOTE
        fibZone(color.new(oteClr, 90),  61.8, 78.6, trendUp, bar_index - 2, lx, swHi, swLo, "OTE ZONE")
    if showTgt
        fibZone(color.new(tgtClr, 90), -50.0, -61.8, trendUp, bar_index - 2, lx, swHi, swLo, "TARGET ZONE")

// ─── Dashboard ────────────────────────────────────────────────────────────────
string trendStr = not hasSwing ? "—" : trendUp ? "Bullish" : "Bearish"
color  trendC   = not hasSwing ? TXT_M : trendUp ? #00C853 : #D50000
string sigStr   = oteTouch ? "OTE Zone" : tgtTouch ? "Target Zone" : "—"
color  sigC     = oteTouch ? oteClr : tgtTouch ? tgtClr : TXT_M

if showDash and barstate.islast
    var tbl = table.new(getDashPos(dashPosStr), 2, 7, TBL_BG, TBL_BD, 1, TBL_BD, 1)

    table.cell(tbl, 0, 0, "JOAT  |  Solstice Fibonacci",
        text_color=#FFFFFF, bgcolor=HDR_BG, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    table.cell(tbl, 0, 1, "Swing Trend", text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 1, trendStr, text_color=trendC, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 2, "Zone Touch",  text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 2, sigStr, text_color=sigC, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 3, "Swing High",  text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 3, hasSwing ? str.tostring(swHi, format.mintick) : "—",
        text_color=TXT, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 4, "Swing Low",   text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 4, hasSwing ? str.tostring(swLo, format.mintick) : "—",
        text_color=TXT, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 5, "Range",       text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 5, hasSwing ? str.tostring(swRange, format.mintick) : "—",
        text_color=TXT, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 6, "Version",     text_color=TXT_M, text_size=size.tiny,  bgcolor=TBL_ALT)
    table.cell(tbl, 1, 6, INDICATOR_VERSION, text_color=TXT_M, text_size=size.tiny, bgcolor=TBL_ALT)

// ─── Watermark ────────────────────────────────────────────────────────────────
if showWM and barstate.islast
    var wmT = table.new(position.bottom_center, 1, 1,
        bgcolor=color.new(color.black, 100), border_color=color.new(color.black, 100), border_width=0)
    table.cell(wmT, 0, 0, "JackOfAllTrades",
        text_color=WM_C, text_size=size.normal, text_halign=text.align_center,
        bgcolor=color.new(color.black, 100))

// ─── Alerts ───────────────────────────────────────────────────────────────────
string tkr  = syminfo.tickerid
string tf   = timeframe.period
string pxS  = str.tostring(close, format.mintick)

string oteTxt  = "SFE OTE Zone | " + tkr + " | TF: " + tf + " | Price: " + pxS
string tgtTxt  = "SFE Target Zone | " + tkr + " | TF: " + tf + " | Price: " + pxS
string oteJson = '{"event":"ote_zone","ticker":"' + tkr + '","tf":"' + tf + '","price":' + pxS + '}'
string tgtJson = '{"event":"target_zone","ticker":"' + tkr + '","tf":"' + tf + '","price":' + pxS + '}'

if oteTouch
    alert(webhookFmt ? oteJson : oteTxt, alert.freq_once_per_bar_close)
if tgtTouch
    alert(webhookFmt ? tgtJson : tgtTxt, alert.freq_once_per_bar_close)

alertcondition(oteTouch, "Price in OTE Zone",    "SFE: Price has entered the OTE retracement zone")
alertcondition(tgtTouch, "Price in Target Zone", "SFE: Price has entered the Fibonacci Target Zone")
````
