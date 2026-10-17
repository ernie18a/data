# RRG Overlay - Thematic & Innovation

- url: https://www.tradingview.com/script/UmXUKHOM-RRG-Overlay-Thematic-Innovation/
- type: indicator
- pine_id: PUB;1b1a542f48ca4eac90240b5daf0d2236
- version: 1.0

## Description

Overview
The RRG Overlay — Thematic & Innovation indicator is a specialized add-on designed to expand your Relative Rotation Graph (RRG) analysis. While standard RRG tools focus on traditional market sectors, this overlay brings 39 highly targeted thematic, disruptive tech, and innovation ETFs right to your chart.

This script is engineered to be an overlay—meaning it is meant to be added to the exact same pane as your primary RRG Host indicator (e.g., RRG_Host_Sectors). This allows you to directly compare niche growth sectors against broader market performance in a single, unified visual workspace.

Key Features
Massive Ticker Coverage: Tracks the rotational paths of 39 specific thematic ETFs. Categories include Artificial Intelligence, Robotics, Cybersecurity, Cloud Computing, Clean Energy, Genomics, FinTech, Blockchain, eSports, and more.

Fading Historical Tails: Visualizes the momentum and path of each ticker using customizable, fading tail segments.

Dynamic Data Table: Features a built-in, top-right sorting table (positioned to avoid overlapping the Host's top-left table).

Advanced Sorting Metrics: Quickly rank tickers by momentum. Sort the table by Weeks Rising, Weeks Positive Momentum, Tail Velocity, Heading (Degrees), Reversals, RS-Ratio, or RS-Momentum.

Quadrant Tracking: Beautifully maps each ETF's journey through the four classic RRG phases: Leading (Green), Weakening (Yellow), Lagging (Red), and Improving (Blue).

⚠️ IMPORTANT: Setup & Sync Instructions
Because this is an overlay script designed to share a pane with a Host RRG indicator, your mathematical and spatial parameters must be perfectly synced for the coordinates to align correctly.

Add your RRG Host script to the chart.

Add this RRG Overlay — Thematic & Innovation script to the chart.

Set the timeframe of the chart to weekly.

Drag this indicator into the SAME PANE as the Host script.

Open the Settings for this indicator. Under the "Sync With Host" group, ensure the following inputs exactly match your Host indicator:

RS Smoothing (EMA)

Normalization Window

Scale Factor

X Scale (bars/unit)

Under the "Display" settings, ensure your Anchor Offset matches the Host so the center crosshairs align perfectly.

Included ETF Themes
This overlay pits the following themes against the SHV (Short Treasury Bond) benchmark to measure absolute rotational strength:

Next-Gen Tech: AI/Robotics (BOTZ, ROBO, AIQ), Cyber & Cloud (CIBR, BUG, SKYY, CLOU), FinTech & Blockchain (FINX, ARKF, BLOK, IPAY).

Green & Infrastructure: Clean Energy & Solar (ICLN, QCLN, TAN, FAN), Smart Grid & Batteries (GRID, BATT), Infrastructure (PAVE).

Innovation & Disruption: ARK Funds (ARKK, ARKQ, ARKG, ARKW), Space (UFO), 3D Printing (PRNT), Quantum (QTUM).

Consumer & Lifestyle: E-commerce (IBUY), Gaming & Metaverse (ESPO, HERO, METV), Cannabis (YOLO), Sports Betting (BETZ), Pet Care (PAWZ).

Performance Note
To stay within Pine Script's rendering limits and ensure optimal loading speeds, the maximum safe tail length is capped at 12 bars when plotting all 39 tickers simultaneously.

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  RRG Overlay — Thematic & Innovation                                    ║
// ║  Add to the SAME PANE as RRG_Host_Sectors.                             ║
// ║  IMPORTANT: RS Smoothing, Normalization Window, Scale Factor,          ║
// ║             X Scale, and Anchor Offset must match the Host.            ║
// ╚══════════════════════════════════════════════════════════════════════════╝
//@version=6
indicator("RRG Overlay - Thematic & Innovation", shorttitle="RRG:Thematic",
          overlay=false, max_lines_count=500, max_labels_count=500, max_boxes_count=20)

// ═══════════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════════
var string G_SYNC = "Sync With Host  ← must match all RRG indicators"
var string G_DISP = "Display"
var string G_TBL  = "Table"

i_ratioLen   = input.int   (10,    "RS Smoothing (EMA)",             minval=1,   maxval=100,   group=G_SYNC)
i_normLen    = input.int   (52,    "Normalization Window",           minval=10,  maxval=260,   group=G_SYNC)
i_scl        = input.float (2.5,   "Scale Factor",                   minval=0.1, maxval=10.0,  step=0.1,  group=G_SYNC)
i_xScl       = input.float (30.0,  "X Scale (bars/unit)",            minval=5.0, maxval=200.0, step=5.0,  group=G_SYNC)
// NOTE: With 39 tickers, max safe tail = 12 (39×11 + 2 crosshair = 431 lines < 500 limit).
// Setting i_tail > 12 will cause Pine Script to silently drop the oldest tail segments
// (CIBR and nearby tickers lose their tails first due to draw order).
i_tail       = input.int   (12,    "Tail Length (bars)",             minval=3,   maxval=12,    group=G_DISP)
i_showArrows = input.bool  (false, "Show Direction Arrows",          group=G_DISP)
i_gridRange  = input.float (8.0,   "Grid Fixed Range (units, 0=auto)", minval=0.0, maxval=30.0, step=0.5, group=G_DISP)
i_anchorOff  = input.int   (100,   "Anchor Offset (bars right)",     minval=0,   maxval=499,   step=10,   group=G_DISP)
i_showBg     = input.bool  (false, "Show Quadrant Background",       group=G_DISP)
// bgMult now only controls the crosshair arm length; background is infinite.
i_bgMult     = input.float (2.0,   "Crosshair Arm Multiplier",       minval=1.0, maxval=10.0,  step=0.5,  group=G_DISP)
i_pad        = input.float (0.20,  "Grid Padding (units)",           minval=0.1, maxval=3.0,   step=0.1,  group=G_DISP)
i_showTbl    = input.bool  (true,  "Show Table",                     group=G_TBL)
i_sortMode   = input.string("Wks Rising", "Sort By",
               options=["Wks Rising","Wks+ Mom","Velocity","Heading","Reversals","RS-Ratio","RS-Momentum"], group=G_TBL)
i_sortDesc   = input.bool  (true,  "Descending (high=most rising)",  group=G_TBL)
i_tblSize    = input.string("Small", "Table Text Size",
               options=["Tiny","Small","Normal"],                     group=G_TBL)

// ═══════════════════════════════════════════════════════════════════════════
//  COLOURS
// ═══════════════════════════════════════════════════════════════════════════
C00 = color.rgb(  0, 170, 255)
C01 = color.rgb(255, 102,   0)
C02 = color.rgb(255,  51, 102)
C03 = color.rgb(255, 170,   0)
C04 = color.rgb(170, 170, 204)
C05 = color.rgb(204,  68, 255)
C06 = color.rgb(255,  68,   0)
C07 = color.rgb(187, 136, 102)
C08 = color.rgb( 51, 204, 102)
C09 = color.rgb(  0, 204, 170)
C10 = color.rgb(136,  85, 221)
C11 = color.rgb(170, 221, 255)
C12 = color.rgb(255, 215,   0)
C13 = color.rgb(192, 192, 192)
C14 = color.rgb(100, 200, 130)
C15 = color.rgb(220, 110, 180)
C16 = color.rgb(180, 200,  80)
C17 = color.rgb( 80, 210, 200)
C18 = color.rgb(210, 160,  80)
C19 = color.rgb(140,  90, 220)
C20 = color.rgb(220,  90,  90)
C21 = color.rgb( 90, 180, 140)
C22 = color.rgb(180,  80, 220)
C23 = color.rgb(220, 200,  80)
C24 = color.rgb( 80, 150, 220)
C25 = color.rgb(255, 180, 120)
C26 = color.rgb(120, 255, 180)
C27 = color.rgb(180, 120, 255)
C28 = color.rgb(255, 120, 180)
C29 = color.rgb(120, 180, 255)
C30 = color.rgb(200, 255, 120)
C31 = color.rgb(255, 200, 120)
C32 = color.rgb(120, 200, 255)
C33 = color.rgb(255, 120, 200)
C34 = color.rgb(200, 120, 255)
C35 = color.rgb(120, 255, 200)
C36 = color.rgb(240, 160,  80)
C37 = color.rgb( 80, 240, 160)
C38 = color.rgb(160,  80, 240)

C_LEAD = color.rgb( 67, 162,  72)
C_WEAK = color.rgb(180, 148,  40)
C_IMPR = color.rgb( 74, 120, 188)
C_LAGG = color.rgb(180,  70,  70)

// ═══════════════════════════════════════════════════════════════════════════
//  SECURITIES  (39 + benchmark)
// ═══════════════════════════════════════════════════════════════════════════
bmSHV = request.security("SHV",  "", close)
sC00  = request.security("BOTZ", "", close)
sC01  = request.security("ROBO", "", close)
sC02  = request.security("AIQ",  "", close)
sC03  = request.security("ARKQ", "", close)
sC04  = request.security("CIBR", "", close)
sC05  = request.security("BUG",  "", close)
sC06  = request.security("SKYY", "", close)
sC07  = request.security("CLOU", "", close)
sC08  = request.security("IBUY", "", close)
sC09  = request.security("FINX", "", close)
sC10  = request.security("ARKF", "", close)
sC11  = request.security("IPAY", "", close)
sC12  = request.security("ARKG", "", close)
sC13  = request.security("DRIV", "", close)
sC14  = request.security("UFO",  "", close)
sC15  = request.security("ICLN", "", close)
sC16  = request.security("QCLN", "", close)
sC17  = request.security("TAN",  "", close)
sC18  = request.security("FAN",  "", close)
sC19  = request.security("GRID", "", close)
sC20  = request.security("BATT", "", close)
sC21  = request.security("PRNT", "", close)
sC22  = request.security("METV", "", close)
sC23  = request.security("ESPO", "", close)
sC24  = request.security("HERO", "", close)
sC25  = request.security("SOCL", "", close)
sC26  = request.security("QTUM", "", close)
sC27  = request.security("ARKW", "", close)
sC28  = request.security("ARKK", "", close)
sC29  = request.security("PAVE", "", close)
sC30  = request.security("KROP", "", close)
sC31  = request.security("VEGI", "", close)
sC32  = request.security("CGW",  "", close)
sC33  = request.security("PAWZ", "", close)
sC34  = request.security("AGNG", "", close)
sC35  = request.security("MILN", "", close)
sC36  = request.security("BETZ", "", close)
sC37  = request.security("YOLO", "", close)
sC38  = request.security("BLOK", "", close)

// ═══════════════════════════════════════════════════════════════════════════
//  RRG MATH
// ═══════════════════════════════════════════════════════════════════════════
rrg(sc, bm) =>
    rs   = sc / bm
    e    = ta.ema(rs, i_ratioLen)
    mu   = ta.sma(e, i_normLen)
    sig  = ta.stdev(e, i_normLen)
    xv   = sig  > 0.0 ? 100.0 + (e  - mu)  / sig  * i_scl : 100.0
    mr   = xv - xv[i_ratioLen]
    mmu  = ta.sma(mr, i_normLen)
    msig = ta.stdev(mr, i_normLen)
    yv   = msig > 0.0 ? 100.0 + (mr - mmu) / msig * i_scl : 100.0
    [xv, yv]

[xv00, yv00] = rrg(sC00, bmSHV)
[xv01, yv01] = rrg(sC01, bmSHV)
[xv02, yv02] = rrg(sC02, bmSHV)
[xv03, yv03] = rrg(sC03, bmSHV)
[xv04, yv04] = rrg(sC04, bmSHV)
[xv05, yv05] = rrg(sC05, bmSHV)
[xv06, yv06] = rrg(sC06, bmSHV)
[xv07, yv07] = rrg(sC07, bmSHV)
[xv08, yv08] = rrg(sC08, bmSHV)
[xv09, yv09] = rrg(sC09, bmSHV)
[xv10, yv10] = rrg(sC10, bmSHV)
[xv11, yv11] = rrg(sC11, bmSHV)
[xv12, yv12] = rrg(sC12, bmSHV)
[xv13, yv13] = rrg(sC13, bmSHV)
[xv14, yv14] = rrg(sC14, bmSHV)
[xv15, yv15] = rrg(sC15, bmSHV)
[xv16, yv16] = rrg(sC16, bmSHV)
[xv17, yv17] = rrg(sC17, bmSHV)
[xv18, yv18] = rrg(sC18, bmSHV)
[xv19, yv19] = rrg(sC19, bmSHV)
[xv20, yv20] = rrg(sC20, bmSHV)
[xv21, yv21] = rrg(sC21, bmSHV)
[xv22, yv22] = rrg(sC22, bmSHV)
[xv23, yv23] = rrg(sC23, bmSHV)
[xv24, yv24] = rrg(sC24, bmSHV)
[xv25, yv25] = rrg(sC25, bmSHV)
[xv26, yv26] = rrg(sC26, bmSHV)
[xv27, yv27] = rrg(sC27, bmSHV)
[xv28, yv28] = rrg(sC28, bmSHV)
[xv29, yv29] = rrg(sC29, bmSHV)
[xv30, yv30] = rrg(sC30, bmSHV)
[xv31, yv31] = rrg(sC31, bmSHV)
[xv32, yv32] = rrg(sC32, bmSHV)
[xv33, yv33] = rrg(sC33, bmSHV)
[xv34, yv34] = rrg(sC34, bmSHV)
[xv35, yv35] = rrg(sC35, bmSHV)
[xv36, yv36] = rrg(sC36, bmSHV)
[xv37, yv37] = rrg(sC37, bmSHV)
[xv38, yv38] = rrg(sC38, bmSHV)

// ═══════════════════════════════════════════════════════════════════════════
//  TAIL HISTORY
// ═══════════════════════════════════════════════════════════════════════════
var float[] ax00 = array.new<float>(), var float[] ay00 = array.new<float>()
var float[] ax01 = array.new<float>(), var float[] ay01 = array.new<float>()
var float[] ax02 = array.new<float>(), var float[] ay02 = array.new<float>()
var float[] ax03 = array.new<float>(), var float[] ay03 = array.new<float>()
var float[] ax04 = array.new<float>(), var float[] ay04 = array.new<float>()
var float[] ax05 = array.new<float>(), var float[] ay05 = array.new<float>()
var float[] ax06 = array.new<float>(), var float[] ay06 = array.new<float>()
var float[] ax07 = array.new<float>(), var float[] ay07 = array.new<float>()
var float[] ax08 = array.new<float>(), var float[] ay08 = array.new<float>()
var float[] ax09 = array.new<float>(), var float[] ay09 = array.new<float>()
var float[] ax10 = array.new<float>(), var float[] ay10 = array.new<float>()
var float[] ax11 = array.new<float>(), var float[] ay11 = array.new<float>()
var float[] ax12 = array.new<float>(), var float[] ay12 = array.new<float>()
var float[] ax13 = array.new<float>(), var float[] ay13 = array.new<float>()
var float[] ax14 = array.new<float>(), var float[] ay14 = array.new<float>()
var float[] ax15 = array.new<float>(), var float[] ay15 = array.new<float>()
var float[] ax16 = array.new<float>(), var float[] ay16 = array.new<float>()
var float[] ax17 = array.new<float>(), var float[] ay17 = array.new<float>()
var float[] ax18 = array.new<float>(), var float[] ay18 = array.new<float>()
var float[] ax19 = array.new<float>(), var float[] ay19 = array.new<float>()
var float[] ax20 = array.new<float>(), var float[] ay20 = array.new<float>()
var float[] ax21 = array.new<float>(), var float[] ay21 = array.new<float>()
var float[] ax22 = array.new<float>(), var float[] ay22 = array.new<float>()
var float[] ax23 = array.new<float>(), var float[] ay23 = array.new<float>()
var float[] ax24 = array.new<float>(), var float[] ay24 = array.new<float>()
var float[] ax25 = array.new<float>(), var float[] ay25 = array.new<float>()
var float[] ax26 = array.new<float>(), var float[] ay26 = array.new<float>()
var float[] ax27 = array.new<float>(), var float[] ay27 = array.new<float>()
var float[] ax28 = array.new<float>(), var float[] ay28 = array.new<float>()
var float[] ax29 = array.new<float>(), var float[] ay29 = array.new<float>()
var float[] ax30 = array.new<float>(), var float[] ay30 = array.new<float>()
var float[] ax31 = array.new<float>(), var float[] ay31 = array.new<float>()
var float[] ax32 = array.new<float>(), var float[] ay32 = array.new<float>()
var float[] ax33 = array.new<float>(), var float[] ay33 = array.new<float>()
var float[] ax34 = array.new<float>(), var float[] ay34 = array.new<float>()
var float[] ax35 = array.new<float>(), var float[] ay35 = array.new<float>()
var float[] ax36 = array.new<float>(), var float[] ay36 = array.new<float>()
var float[] ax37 = array.new<float>(), var float[] ay37 = array.new<float>()
var float[] ax38 = array.new<float>(), var float[] ay38 = array.new<float>()

pushCap(xa, ya, xv, yv) =>
    array.push(xa, xv)
    array.push(ya, yv)
    while array.size(xa) > i_tail
        array.shift(xa)
        array.shift(ya)

pushCap(ax00, ay00, xv00, yv00)
pushCap(ax01, ay01, xv01, yv01)
pushCap(ax02, ay02, xv02, yv02)
pushCap(ax03, ay03, xv03, yv03)
pushCap(ax04, ay04, xv04, yv04)
pushCap(ax05, ay05, xv05, yv05)
pushCap(ax06, ay06, xv06, yv06)
pushCap(ax07, ay07, xv07, yv07)
pushCap(ax08, ay08, xv08, yv08)
pushCap(ax09, ay09, xv09, yv09)
pushCap(ax10, ay10, xv10, yv10)
pushCap(ax11, ay11, xv11, yv11)
pushCap(ax12, ay12, xv12, yv12)
pushCap(ax13, ay13, xv13, yv13)
pushCap(ax14, ay14, xv14, yv14)
pushCap(ax15, ay15, xv15, yv15)
pushCap(ax16, ay16, xv16, yv16)
pushCap(ax17, ay17, xv17, yv17)
pushCap(ax18, ay18, xv18, yv18)
pushCap(ax19, ay19, xv19, yv19)
pushCap(ax20, ay20, xv20, yv20)
pushCap(ax21, ay21, xv21, yv21)
pushCap(ax22, ay22, xv22, yv22)
pushCap(ax23, ay23, xv23, yv23)
pushCap(ax24, ay24, xv24, yv24)
pushCap(ax25, ay25, xv25, yv25)
pushCap(ax26, ay26, xv26, yv26)
pushCap(ax27, ay27, xv27, yv27)
pushCap(ax28, ay28, xv28, yv28)
pushCap(ax29, ay29, xv29, yv29)
pushCap(ax30, ay30, xv30, yv30)
pushCap(ax31, ay31, xv31, yv31)
pushCap(ax32, ay32, xv32, yv32)
pushCap(ax33, ay33, xv33, yv33)
pushCap(ax34, ay34, xv34, yv34)
pushCap(ax35, ay35, xv35, yv35)
pushCap(ax36, ay36, xv36, yv36)
pushCap(ax37, ay37, xv37, yv37)
pushCap(ax38, ay38, xv38, yv38)

// ═══════════════════════════════════════════════════════════════════════════
//  INVISIBLE PLOTS  (keep y-axis anchored near 100)
// ═══════════════════════════════════════════════════════════════════════════
plot(yv00, display=display.none)
plot(yv01, display=display.none)
plot(yv02, display=display.none)
plot(yv03, display=display.none)
plot(yv04, display=display.none)
plot(yv05, display=display.none)
plot(yv06, display=display.none)
plot(yv07, display=display.none)
plot(yv08, display=display.none)
plot(yv09, display=display.none)
plot(yv10, display=display.none)
plot(yv11, display=display.none)
plot(yv12, display=display.none)
plot(yv13, display=display.none)
plot(yv14, display=display.none)
plot(yv15, display=display.none)
plot(yv16, display=display.none)
plot(yv17, display=display.none)
plot(yv18, display=display.none)
plot(yv19, display=display.none)
plot(yv20, display=display.none)
plot(yv21, display=display.none)
plot(yv22, display=display.none)
plot(yv23, display=display.none)
plot(yv24, display=display.none)
plot(yv25, display=display.none)
plot(yv26, display=display.none)
plot(yv27, display=display.none)
plot(yv28, display=display.none)
plot(yv29, display=display.none)
plot(yv30, display=display.none)
plot(yv31, display=display.none)
plot(yv32, display=display.none)
plot(yv33, display=display.none)
plot(yv34, display=display.none)
plot(yv35, display=display.none)
plot(yv36, display=display.none)
plot(yv37, display=display.none)
plot(yv38, display=display.none)

// ═══════════════════════════════════════════════════════════════════════════
//  DRAWING UTILITIES
// ═══════════════════════════════════════════════════════════════════════════
var line[]  allLines  = array.new<line>()
var label[] allLabels = array.new<label>()
var box[]   allBoxes  = array.new<box>()
var int     ANCHOR    = 0

toX(r) =>
    raw = ANCHOR + int(math.round((r - 100.0) * i_xScl))
    math.max(bar_index - 9000, math.min(bar_index + 499, raw))

clearAll() =>
    for ln in allLines
        line.delete(ln)
    array.clear(allLines)
    for lb in allLabels
        label.delete(lb)
    array.clear(allLabels)
    for bx in allBoxes
        box.delete(bx)
    array.clear(allBoxes)

atan2(y, x) =>
    if x == 0.0
        y > 0.0 ? 90.0 : y < 0.0 ? -90.0 : 0.0
    else
        base = math.todegrees(math.atan(y / x))
        x < 0.0 ? (y >= 0.0 ? base + 180.0 : base - 180.0) : base

dirArrow(dx, dy) =>
    adx = math.abs(dx)
    ady = math.abs(dy)
    if adx < 0.03 and ady < 0.03
        "·"
    else if adx > ady * 2.2
        dx > 0 ? "→" : "←"
    else if ady > adx * 2.2
        dy > 0 ? "↑" : "↓"
    else
        dx > 0 ? (dy > 0 ? "↗" : "↘") : (dy > 0 ? "↖" : "↙")

drawSec(xa, ya, col, nm) =>
    n = array.size(xa)
    if n >= 2
        for i = 0 to n - 2
            x1v  = array.get(xa, i)
            y1v  = array.get(ya, i)
            x2v  = array.get(xa, i + 1)
            y2v  = array.get(ya, i + 1)
            prog = n > 2 ? float(i) / float(n - 2) : 1.0
            fade = prog * prog
            alp  = int(math.round(96.0 - fade * 94.0))
            lw   = prog < 0.30 ? 1 : prog < 0.60 ? 2 : prog < 0.85 ? 3 : 4
            array.push(allLines,
                line.new(toX(x1v), y1v, toX(x2v), y2v,
                         xloc=xloc.bar_index,
                         color=color.new(col, alp), width=lw))
    if n >= 1
        hx  = array.get(xa, n - 1)
        hy  = array.get(ya, n - 1)
        hdx = n >= 2 ? hx - array.get(xa, n - 2) : 0.0
        hdy = n >= 2 ? hy - array.get(ya, n - 2) : 0.0
        arr = dirArrow(hdx, hdy)
        array.push(allLabels,
            label.new(toX(hx), hy, "",
                      xloc=xloc.bar_index, yloc=yloc.price,
                      color=col, style=label.style_circle, size=size.tiny))
        array.push(allLabels,
            label.new(toX(hx), hy, i_showArrows ? nm + " " + arr : nm,
                      xloc=xloc.bar_index, yloc=yloc.price,
                      color=color.new(color.black, 100),
                      textcolor=color.white,
                      style=label.style_label_up, size=size.small,
                      textalign=text.align_center))

// ═══════════════════════════════════════════════════════════════════════════
//  SORT METRICS
// ═══════════════════════════════════════════════════════════════════════════
tailVelocity(xa, ya) =>
    n = array.size(xa)
    if n >= 2
        dx = array.get(xa, n-1) - array.get(xa, n-2)
        dy = array.get(ya, n-1) - array.get(ya, n-2)
        math.sqrt(dx*dx + dy*dy)
    else
        0.0

tailHeading(xa, ya) =>
    n = array.size(xa)
    if n >= 2
        dx  = array.get(xa, n-1) - array.get(xa, n-2)
        dy  = array.get(ya, n-1) - array.get(ya, n-2)
        deg = atan2(dy, dx)
        deg < 0.0 ? deg + 360.0 : deg
    else
        0.0

tailReversals(xa, ya) =>
    n   = array.size(xa)
    cnt = 0
    if n >= 2
        for i = 0 to n - 2
            x1 = array.get(xa, i)
            x2 = array.get(xa, i+1)
            y1 = array.get(ya, i)
            y2 = array.get(ya, i+1)
            if (x1 - 100.0) * (x2 - 100.0) < 0.0
                cnt += 1
            if (y1 - 100.0) * (y2 - 100.0) < 0.0
                cnt += 1
    float(cnt)

weeksPosM(ya) =>
    n   = array.size(ya)
    cnt = 0
    if n >= 1
        i = n - 1
        while i >= 0 and array.get(ya, i) > 100.0
            cnt += 1
            i   -= 1
    cnt

weeksRising(ya) =>
    n   = array.size(ya)
    cnt = 0
    if n >= 2
        i = n - 1
        while i >= 1 and array.get(ya, i) > array.get(ya, i - 1)
            cnt += 1
            i   -= 1
    cnt

getSortKey(xa, ya, xval, yval) =>
    switch i_sortMode
        "Wks+ Mom"   => float(weeksPosM(ya))
        "Wks Rising" => float(weeksRising(ya))
        "Velocity"   => tailVelocity(xa, ya)
        "Heading"    => tailHeading(xa, ya)
        "Reversals"  => tailReversals(xa, ya)
        "RS-Ratio"   => xval
        =>              yval

// ═══════════════════════════════════════════════════════════════════════════
//  TABLE  (top_left to avoid overlapping the Host's top_right table)
// ═══════════════════════════════════════════════════════════════════════════
var table tbl = table.new(position.top_right, 3, 40,
    bgcolor      = color.new(color.rgb(6, 12, 20), 8),
    border_color = color.new(color.rgb(30, 38, 50), 0),
    border_width = 1,
    frame_color  = color.new(color.rgb(30, 38, 50), 0),
    frame_width  = 1)

renderRow(tbl, row, col, tk, nm, sv, sz, szSm) =>
    dbg   = color.new(color.rgb(8, 14, 22), 0)
    svStr = str.tostring(sv, "#.00")
    if i_sortMode == "Wks Rising" or i_sortMode == "Wks+ Mom"
        svStr := str.tostring(int(sv)) + "w"
    else if i_sortMode == "Reversals"
        svStr := str.tostring(int(sv))
    else if i_sortMode == "Heading"
        svStr := str.tostring(sv, "#.0") + "°"
    table.cell(tbl, 0, row, "● " + tk,
               text_color=col, text_size=sz, bgcolor=dbg, text_halign=text.align_left)
    table.cell(tbl, 1, row, nm,
               text_color=color.new(color.rgb(130, 140, 155), 0),
               text_size=szSm, bgcolor=dbg, text_halign=text.align_left)
    table.cell(tbl, 2, row, svStr,
               text_color=color.new(color.rgb(180, 200, 230), 0),
               text_size=szSm, bgcolor=dbg, text_halign=text.align_right)

// ═══════════════════════════════════════════════════════════════════════════
//  RENDER  (fires on every bar update; only draws on the last bar)
// ═══════════════════════════════════════════════════════════════════════════
if barstate.islast
    // 1. Sync anchor with Host
    ANCHOR := math.min(bar_index + 499, bar_index + i_anchorOff)

    // 2. Wipe previous drawing objects
    clearAll()

    // 3. Infinite quadrant background boxes.
    //    Boxes extend to extreme coordinates so coloured regions always fill
    //    the full visible pane regardless of zoom — no size mismatch with Host.
    //    Default off: the Host already draws this on the shared pane.
    grHalf    = (i_gridRange > 0.0 ? i_gridRange : 10.0) / 2.0
    crossHalf = grHalf * i_bgMult

    if i_showBg
        // X extends to the full chart in both directions (infinite X).
        // Y is bounded to bgHalf so the y-axis scale is not blown out.
        grHalfBg = (i_gridRange > 0.0 ? i_gridRange : 10.0) / 2.0
        bgHalf   = grHalfBg * i_bgMult
        xFarL    = math.max(0, bar_index - 100000)
        xFarR    = bar_index + 499
        xMid     = toX(100.0)
        yTop     = 100.0 + bgHalf
        yMid     = 100.0
        yBot     = 100.0 - bgHalf
        array.push(allBoxes, box.new(xFarL, yTop, xMid,  yMid, xloc=xloc.bar_index, border_color=color.new(C_IMPR, 100), bgcolor=color.new(C_IMPR, 85)))
        array.push(allBoxes, box.new(xMid,  yTop, xFarR, yMid, xloc=xloc.bar_index, border_color=color.new(C_LEAD, 100), bgcolor=color.new(C_LEAD, 85)))
        array.push(allBoxes, box.new(xFarL, yMid, xMid,  yBot, xloc=xloc.bar_index, border_color=color.new(C_LAGG, 100), bgcolor=color.new(C_LAGG, 85)))
        array.push(allBoxes, box.new(xMid,  yMid, xFarR, yBot, xloc=xloc.bar_index, border_color=color.new(C_WEAK, 100), bgcolor=color.new(C_WEAK, 85)))

    // Centre-axes crosshair — same formula as Host
    cxll = toX(100.0 - crossHalf)
    cxrr = toX(100.0 + crossHalf)
    AC   = color.new(color.rgb(180, 195, 215), 62)
    array.push(allLines,
        line.new(ANCHOR, 100.0 + crossHalf, ANCHOR, 100.0 - crossHalf,
                 xloc=xloc.bar_index, color=AC, style=line.style_dashed, width=1))
    array.push(allLines,
        line.new(cxll, 100.0, cxrr, 100.0,
                 xloc=xloc.bar_index, color=AC, style=line.style_dashed, width=1))

    // 4. Tails
    drawSec(ax00, ay00, C00, "BOTZ")
    drawSec(ax01, ay01, C01, "ROBO")
    drawSec(ax02, ay02, C02, "AIQ")
    drawSec(ax03, ay03, C03, "ARKQ")
    drawSec(ax04, ay04, C04, "CIBR")
    drawSec(ax05, ay05, C05, "BUG")
    drawSec(ax06, ay06, C06, "SKYY")
    drawSec(ax07, ay07, C07, "CLOU")
    drawSec(ax08, ay08, C08, "IBUY")
    drawSec(ax09, ay09, C09, "FINX")
    drawSec(ax10, ay10, C10, "ARKF")
    drawSec(ax11, ay11, C11, "IPAY")
    drawSec(ax12, ay12, C12, "ARKG")
    drawSec(ax13, ay13, C13, "DRIV")
    drawSec(ax14, ay14, C14, "UFO")
    drawSec(ax15, ay15, C15, "ICLN")
    drawSec(ax16, ay16, C16, "QCLN")
    drawSec(ax17, ay17, C17, "TAN")
    drawSec(ax18, ay18, C18, "FAN")
    drawSec(ax19, ay19, C19, "GRID")
    drawSec(ax20, ay20, C20, "BATT")
    drawSec(ax21, ay21, C21, "PRNT")
    drawSec(ax22, ay22, C22, "METV")
    drawSec(ax23, ay23, C23, "ESPO")
    drawSec(ax24, ay24, C24, "HERO")
    drawSec(ax25, ay25, C25, "SOCL")
    drawSec(ax26, ay26, C26, "QTUM")
    drawSec(ax27, ay27, C27, "ARKW")
    drawSec(ax28, ay28, C28, "ARKK")
    drawSec(ax29, ay29, C29, "PAVE")
    drawSec(ax30, ay30, C30, "KROP")
    drawSec(ax31, ay31, C31, "VEGI")
    drawSec(ax32, ay32, C32, "CGW")
    drawSec(ax33, ay33, C33, "PAWZ")
    drawSec(ax34, ay34, C34, "AGNG")
    drawSec(ax35, ay35, C35, "MILN")
    drawSec(ax36, ay36, C36, "BETZ")
    drawSec(ax37, ay37, C37, "YOLO")
    drawSec(ax38, ay38, C38, "BLOK")

    // 5. Table
    if i_showTbl
        tblSz   = switch i_tblSize
            "Tiny"   => size.tiny
            "Normal" => size.normal
            =>          size.small
        tblSzSm = switch i_tblSize
            "Normal" => size.small
            =>          size.tiny

        float[] sk = array.new<float>(39, 0.0)
        array.set(sk,  0, getSortKey(ax00, ay00, xv00, yv00))
        array.set(sk,  1, getSortKey(ax01, ay01, xv01, yv01))
        array.set(sk,  2, getSortKey(ax02, ay02, xv02, yv02))
        array.set(sk,  3, getSortKey(ax03, ay03, xv03, yv03))
        array.set(sk,  4, getSortKey(ax04, ay04, xv04, yv04))
        array.set(sk,  5, getSortKey(ax05, ay05, xv05, yv05))
        array.set(sk,  6, getSortKey(ax06, ay06, xv06, yv06))
        array.set(sk,  7, getSortKey(ax07, ay07, xv07, yv07))
        array.set(sk,  8, getSortKey(ax08, ay08, xv08, yv08))
        array.set(sk,  9, getSortKey(ax09, ay09, xv09, yv09))
        array.set(sk, 10, getSortKey(ax10, ay10, xv10, yv10))
        array.set(sk, 11, getSortKey(ax11, ay11, xv11, yv11))
        array.set(sk, 12, getSortKey(ax12, ay12, xv12, yv12))
        array.set(sk, 13, getSortKey(ax13, ay13, xv13, yv13))
        array.set(sk, 14, getSortKey(ax14, ay14, xv14, yv14))
        array.set(sk, 15, getSortKey(ax15, ay15, xv15, yv15))
        array.set(sk, 16, getSortKey(ax16, ay16, xv16, yv16))
        array.set(sk, 17, getSortKey(ax17, ay17, xv17, yv17))
        array.set(sk, 18, getSortKey(ax18, ay18, xv18, yv18))
        array.set(sk, 19, getSortKey(ax19, ay19, xv19, yv19))
        array.set(sk, 20, getSortKey(ax20, ay20, xv20, yv20))
        array.set(sk, 21, getSortKey(ax21, ay21, xv21, yv21))
        array.set(sk, 22, getSortKey(ax22, ay22, xv22, yv22))
        array.set(sk, 23, getSortKey(ax23, ay23, xv23, yv23))
        array.set(sk, 24, getSortKey(ax24, ay24, xv24, yv24))
        array.set(sk, 25, getSortKey(ax25, ay25, xv25, yv25))
        array.set(sk, 26, getSortKey(ax26, ay26, xv26, yv26))
        array.set(sk, 27, getSortKey(ax27, ay27, xv27, yv27))
        array.set(sk, 28, getSortKey(ax28, ay28, xv28, yv28))
        array.set(sk, 29, getSortKey(ax29, ay29, xv29, yv29))
        array.set(sk, 30, getSortKey(ax30, ay30, xv30, yv30))
        array.set(sk, 31, getSortKey(ax31, ay31, xv31, yv31))
        array.set(sk, 32, getSortKey(ax32, ay32, xv32, yv32))
        array.set(sk, 33, getSortKey(ax33, ay33, xv33, yv33))
        array.set(sk, 34, getSortKey(ax34, ay34, xv34, yv34))
        array.set(sk, 35, getSortKey(ax35, ay35, xv35, yv35))
        array.set(sk, 36, getSortKey(ax36, ay36, xv36, yv36))
        array.set(sk, 37, getSortKey(ax37, ay37, xv37, yv37))
        array.set(sk, 38, getSortKey(ax38, ay38, xv38, yv38))

        int[] si = array.sort_indices(sk, i_sortDesc ? order.descending : order.ascending)

        string[] tickers = array.from(
             "BOTZ","ROBO","AIQ","ARKQ","CIBR","BUG","SKYY","CLOU","IBUY","FINX",
             "ARKF","IPAY","ARKG","DRIV","UFO","ICLN","QCLN","TAN","FAN","GRID",
             "BATT","PRNT","METV","ESPO","HERO","SOCL","QTUM","ARKW","ARKK","PAVE",
             "KROP","VEGI","CGW","PAWZ","AGNG","MILN","BETZ","YOLO","BLOK")
        string[] names = array.from(
             "AI Robotics","Global Robotics","AI Tech","ARK Auto","Cybersec",
             "Cybersec GX","Cloud","Cloud GX","Online Retail","Fintech",
             "ARK Fintech","Mobile Pay","Genomics","EV Auto","Space",
             "Clean Energy","Clean Edge","Solar","Wind","Smart Grid",
             "Battery","3D Printing","Metaverse","Gaming eSports","Gaming GX",
             "Social Media","Quantum","ARK Next Gen","ARK Innov","Infrastr",
             "Ag Food Tech","Ag Tech","Global Water","Pet Care","Aging Pop",
             "Millennials","Sports Betting","Cannabis","Blockchain")
        color[] cols = array.from(
             C00,C01,C02,C03,C04,C05,C06,C07,C08,C09,
             C10,C11,C12,C13,C14,C15,C16,C17,C18,C19,
             C20,C21,C22,C23,C24,C25,C26,C27,C28,C29,
             C30,C31,C32,C33,C34,C35,C36,C37,C38)

        hbg = color.new(color.rgb(12, 20, 32), 0)
        hc  = color.new(color.rgb(90, 105, 125), 0)
        hca = color.new(color.rgb(180, 200, 230), 0)
        sortHdr = switch i_sortMode
            "Wks Rising" => "WKSR"
            "Wks+ Mom"   => "WKS+"
            "Velocity"   => "VELOC"
            "Heading"    => "HEAD"
            "Reversals"  => "REVRS"
            "RS-Ratio"   => "RS-R"
            =>              "RS-M"

        table.cell(tbl, 0, 0, "TICKER", text_color=hc,  text_size=tblSzSm, bgcolor=hbg, text_halign=text.align_left)
        table.cell(tbl, 1, 0, "NAME",   text_color=hc,  text_size=tblSzSm, bgcolor=hbg, text_halign=text.align_left)
        table.cell(tbl, 2, 0, sortHdr + (i_sortDesc ? " v" : " ^"),
                   text_color=hca, text_size=tblSzSm, bgcolor=hbg, text_halign=text.align_right)

        for row = 0 to 38
            idx = array.get(si, row)
            renderRow(tbl, row + 1,
                      array.get(cols,    idx),
                      array.get(tickers, idx),
                      array.get(names,   idx),
                      array.get(sk,      idx),
                      tblSz, tblSzSm)
````
