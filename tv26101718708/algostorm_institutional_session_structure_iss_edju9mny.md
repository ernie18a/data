# AlgoStorm Institutional Session Structure (ISS)

- url: https://www.tradingview.com/script/edJU9MNY-AlgoStorm-Institutional-Session-Structure-ISS/
- type: indicator
- pine_id: PUB;7f99791d30bd4e648423a288e56f5977
- version: 3.0

## Description

[b]AlgoStorm Institutional Session Structure (ISS)[/b]

A complete intraday auction-structure engine that maps global session boxes (Asia, London, New York), the Globex overnight range, the Initial Balance with day-type extension targets, the Opening Range, and an automated overnight-inventory classification of the RTH open — directly onto your intraday charts.

The AlgoStorm Institutional Session Structure (ISS) indicator is designed for index futures and intraday traders who read the market through the auction lens: where overnight inventory built, whether the open printed inside or outside that inventory, whether the Initial Balance is containing rotation or the day is extending toward trend, and which session built the reference high or low everyone now trades against. It answers those questions structurally instead of drawing decorative boxes.

[b]TIMEFRAME REQUIREMENT — READ BEFORE LOADING[/b]
This is an intraday tool. It refuses to run on 1D charts and above, and the chart timeframe should stay at or below the Opening Range length (the Opening Range and Initial Balance locks resolve at bar granularity). All session windows are DST-aware through a configurable IANA timezone, defaulting to New York time.

[b]Technical Architecture: Fixed-Pool Session Engine[/b]
Session-structure indicators commonly rebuild their drawings on every bar, bloating chart performance and churning objects. ISS uses a different execution model:

[list]
[*][b]Per-Session Box Engines:[/b] Each session runs its own tracking engine with a private box history. The active box updates its high/low boundary in place as the session develops; boxes older than the history cap (default five days, configurable to twenty) are evicted automatically.
[*][b]Time-Window Lock Pipeline:[/b] The overnight range, Initial Balance, and Opening Range each accumulate in staging registers, then lock permanently the moment their window closes — the overnight at the RTH open, the IB and OR when their configurable minute-windows complete. Locked levels cannot move for the rest of the day.
[*][b]Extension Mathematics:[/b] Extension targets use the classic day-type formula, extension(m) = IB low + m × IB range above the market and IB high − m × IB range below it, with 1.5× and 2.0× defaults. A 1.5× tag means price has traveled 150% of the IB range from the opposite IB boundary.
[*][b]Zero-Churn Drawing Pool:[/b] Every level line and label is created exactly once at initialization and repositioned in place afterward. No per-bar create/delete cycles, no garbage-collection artifacts.
[*][b]Label Anti-Overlap Engine:[/b] Right-edge labels (ON, IB, extensions, OR) are sorted by price each bar and automatically spaced apart whenever two or more sit within a configurable minimum gap (default 0.05% of price). Level lines always stay locked to the true price — only the label text position shifts to stay readable. On by default; fully optional.
[*][b]Confirmed-Bar Alert Gate:[/b] Every alert condition is gated on confirmed bar closes inside RTH. Nothing repaints, and no alert can fire intra-bar and then vanish.
[/list]

[b]Features & Functionality[/b]

[list]
[*][b]Session Boxes:[/b] Asia, London, and New York boxes with running high/low, dotted session-open line, and session label. Defaults cover the full sessions (18:00–03:00, 03:00–09:30, 09:30–16:00 New York time); killzone-style alternatives are documented in the input tooltips.
[*][b]Overnight Range Lock:[/b] Globex high/low accumulated through the overnight window and held through the trading day — the reference frame for gap and inventory reads.
[*][b]Initial Balance + Extension Targets:[/b] First 60 minutes of RTH (configurable 15–120) with configurable extension multiples for day-type classification: containment inside the IB, 1.5× tests, or 2× trend extension.
[*][b]Opening Range:[/b] First 15 minutes of RTH (configurable 1–60) — the breakout reference for the open drive.
[*][b]Overnight Inventory Read:[/b] At the RTH open, the engine classifies the print: above the ON high, upper half of the ON range, lower half, or below the ON low — the gap-risk context before the first rotation completes.
[*][b]Session State Table:[/b] Active session, ON high/low, open-vs-ON classification, IB range (shows "forming…" while building, then the locked H/L) with a separate breakout status (inside IB vs. breakout ▲/▼), OR range and status, and which IB extensions have been tested — the whole auction state in one glance.
[*][b]Alert Suite:[/b] Eight conditions — Opening Range breakout up/down, Initial Balance breakout up/down, overnight high/low break, and upper/lower reach of the second IB extension multiple (default 2.0×, trend-day behavior). The first multiple (default 1.5×) is tracked live in the state table but does not carry its own alert.
[/list]

[b]Honest limitations:[/b] ISS is structural context, not a signal system — [i]no entries, no exits, no arrows[/i]. Intraday levels draw for the current day only by design; historical context comes from the session boxes. If you also run our Institutional Key Levels (IKL) script, keep IKL's Initial Balance, Opening Range, and Overnight toggles off so nothing double-plots — ISS is the time-anchored view, IKL is the right-edge level strip.

Open-source under CC BY-NC-SA 4.0. [i]Educational tool — not financial advice.[/i]

## Source Code

````pine
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoStorm

//@version=6
indicator(title = "AlgoStorm Institutional Session Structure (ISS)", shorttitle = "ISS • [AlgoStorm]", overlay = true, max_boxes_count = 150, max_lines_count = 150, max_labels_count = 50)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  NOTES
//  • The intraday auction skeleton in one tool:
//      – Session boxes  : Asia, London, New York — running H/L, session open line.
//      – Overnight range: Globex H/L accumulated 18:00–09:30 ET, locked at the
//                         RTH open and carried through the day.
//      – Initial Balance: first N minutes of RTH (default 60), locked when the
//                         window closes, with classic day-type extensions.
//      – Opening Range  : first N minutes of RTH (default 15) — breakout levels.
//      – Inventory read : where the RTH open printed relative to the overnight
//                         range (above / upper half / lower half / below).
//  • Companion to IKL (the right-edge key-levels strip): ISS draws
//    TIME-ANCHORED structure — boxes and ranges across the day — not a level
//    list. Running both? Keep IKL's IB / OPR / Overnight toggles off (they are
//    off by default) so nothing double-plots.
//  • Intraday levels (ON / IB / OR / extensions) are drawn for the CURRENT day
//    only — deliberate chart hygiene. Historical context comes from the session
//    boxes (default 5 days of history, configurable).
//  • Extension math (classic day-type framework): a "1.5× IB" extension means
//    price has travelled 150% of the IB range from the opposite IB boundary,
//    i.e.  extUp(m) = IBL + m × range  (so 1.5× sits at IBH + 0.5 × range),
//          extDn(m) = IBH − m × range.
//  • All session windows are DST-aware via the configurable timezone.
//  • Drawing objects are pooled — created once, repositioned in place. No
//    per-bar create/delete churn.
//  • Labels auto-declutter: when two or more right-edge levels sit within the
//    configured minimum price gap of each other, their text labels are nudged
//    apart vertically (top to bottom) so text never overlaps. The level LINES
//    always stay at the true price — only the label text position shifts.
//    Tune or disable this under "Label Decluttering".
//  • All alerts fire on confirmed bar closes — no intra-bar repainting.
//  • Intraday timeframes only (below 1D). Keep the chart TF at or below the
//    Opening Range length or the OR/IB lock will resolve at bar granularity.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ─── Timeframe guard ──────────────────────────────────────────────────────────
if timeframe.in_seconds() >= 86400
    runtime.error("ISS is an intraday session-structure tool — switch to a chart timeframe below 1D.")

// ─── Historical buffer ────────────────────────────────────────────────────────
//  Drawings convert bar_index x-coordinates to timestamps through the built-in
//  `time` series (Pine error RE10143). The level lines are redrawn on every
//  realtime tick from the RTH start bar, which falls further back all night
//  (~1,440 bars on a 1-min chart), past the automatic 400-bar buffer. Size the
//  buffer to Pine's maximum, and clamp x-coordinates to 4,990 bars back so charts
//  faster than ~20 s start the lines a little after the open instead of halting.
max_bars_back(time, 5000)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

string G_VIS = "Core Visibility Toggles"
bool i_showAsia  = input.bool(defval = true,  title = "Asia Session Box",          group = G_VIS)
bool i_showLon   = input.bool(defval = true,  title = "London Session Box",        group = G_VIS)
bool i_showNy    = input.bool(defval = true,  title = "New York Session Box",      group = G_VIS)
bool i_showOpens = input.bool(defval = true,  title = "Session Open Lines",        group = G_VIS)
bool i_showON    = input.bool(defval = true,  title = "Overnight (Globex) H/L",    group = G_VIS)
bool i_showIB    = input.bool(defval = true,  title = "Initial Balance H/L",       group = G_VIS)
bool i_showExt   = input.bool(defval = true,  title = "IB Extensions",             group = G_VIS)
bool i_showOR    = input.bool(defval = true,  title = "Opening Range H/L",         group = G_VIS)
bool i_showTable = input.bool(defval = true,  title = "Session State Table",       group = G_VIS)

string G_SESS = "Session Windows (DST-Aware)"
string i_tz       = input.string(defval = "America/New_York", title = "Session Timezone", group = G_SESS,
                     tooltip = "IANA timezone all session windows below are interpreted in. Default anchors everything to New York time.")
string i_asiaSess = input.session(defval = "1800-0300", title = "Asia Session",     group = G_SESS,
                     tooltip = "Full Asia/Pacific window. ICT Asia killzone alternative: 2000-0000.")
string i_lonSess  = input.session(defval = "0300-0930", title = "London Session",   group = G_SESS,
                     tooltip = "Full European window. ICT London killzone alternative: 0200-0500.")
string i_nySess   = input.session(defval = "0930-1600", title = "New York Session (RTH)", group = G_SESS,
                     tooltip = "Doubles as the RTH anchor for the Initial Balance, Opening Range, and overnight lock. ICT NY killzone alternative: 0700-1000 (note: moving this moves the IB/OR anchor too).")
string i_onSess   = input.session(defval = "1800-0930", title = "Overnight (Globex) Window", group = G_SESS,
                     tooltip = "Accumulates the overnight high/low; locked at the RTH open.")

string G_STRUCT = "Structure Windows"
int   i_ibMin  = input.int(defval = 60, title = "Initial Balance Length (min)", group = G_STRUCT, minval = 15, maxval = 120, step = 5,
                  tooltip = "Classic day-type IB is the first 60 minutes of RTH.")
int   i_orMin  = input.int(defval = 15, title = "Opening Range Length (min)",   group = G_STRUCT, minval = 1, maxval = 60,
                  tooltip = "Common choices: 5 / 15 / 30 minutes. Keep the chart timeframe at or below this value.")
float i_ext1   = input.float(defval = 1.5, title = "IB Extension Multiple 1",   group = G_STRUCT, minval = 1.25, maxval = 3.0, step = 0.25)
float i_ext2   = input.float(defval = 2.0, title = "IB Extension Multiple 2",   group = G_STRUCT, minval = 1.5,  maxval = 4.0, step = 0.25)

string G_DISP = "Display"
int i_histDays = input.int(defval = 5, title = "Session Box History (days)", group = G_DISP, minval = 1, maxval = 20,
                  tooltip = "How many past boxes to keep per session. Intraday levels always draw for the current day only.")
int i_lblOff   = input.int(defval = 8, title = "Label Offset (bars)",        group = G_DISP, minval = 1, maxval = 50,
                  tooltip = "Shifts level labels rightward into the chart margin.")

string G_DECL = "Label Decluttering"
bool  i_declutter  = input.bool(defval = true, title = "Auto-Space Overlapping Labels", group = G_DECL,
                      tooltip = "When two or more level labels sit too close together in price, nudge them apart vertically (top to bottom) so the text never overlaps. Connecting lines always stay at the true price — only the label text position shifts.")
float i_minGapPct  = input.float(defval = 0.05, title = "Minimum Label Spacing (% of price)", group = G_DECL, minval = 0.01, maxval = 2.0, step = 0.01,
                      tooltip = "Minimum vertical distance enforced between adjacent labels, expressed as a percentage of the current price. Raise this if labels still overlap on your instrument/zoom level; lower it if labels are spaced further apart than necessary.")

string G_COLORS = "Color Suite"
color i_cAsia = input.color(defval = #fff59d, title = "Asia Session",     group = G_COLORS)
color i_cLon  = input.color(defval = #faa1a4, title = "London Session",   group = G_COLORS)
color i_cNy   = input.color(defval = #a5d6a7, title = "New York Session", group = G_COLORS)
color i_cON   = input.color(defval = #ffffff, title = "Overnight H/L",    group = G_COLORS)
color i_cIB   = input.color(defval = #c7e36c, title = "Initial Balance",  group = G_COLORS)
color i_cExt  = input.color(defval = #ffffff, title = "IB Extensions",    group = G_COLORS)
color i_cOR   = input.color(defval = #ffffff, title = "Opening Range",    group = G_COLORS)

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION BOX ENGINE
// One call site per session — `var` arrays are per-call-site in Pine, so each
// session keeps its own private box history. Oldest boxes are evicted once the
// history cap is reached; the box tracks its session's running H/L in place.
// ═══════════════════════════════════════════════════════════════════════════════

f_sessionBox(bool show, string sess, string name, color col) =>
    bool inSess  = not na(time("", sess, i_tz))
    bool starts  = inSess and not inSess[1]
    var array<box>  bxs = array.new<box>()
    var array<line> opn = array.new<line>()
    if show
        color openCol = i_showOpens ? color.new(col, 45) : color.new(col, 100)
        if starts
            array.push(bxs, box.new(bar_index, high, bar_index, low,
                 border_color = color.new(col, 55), border_width = 1,
                 bgcolor      = color.new(col, 92),
                 text = name, text_color = color.new(col, 25),
                 text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top))
            array.push(opn, line.new(bar_index, open, bar_index, open,
                 color = openCol, style = line.style_dotted, width = 1))
            if array.size(bxs) > i_histDays
                box.delete(array.shift(bxs))
                line.delete(array.shift(opn))
        else if inSess and array.size(bxs) > 0
            box b = array.get(bxs, array.size(bxs) - 1)
            box.set_right(b, bar_index)
            box.set_top(b, math.max(box.get_top(b), high))
            box.set_bottom(b, math.min(box.get_bottom(b), low))
            line o = array.get(opn, array.size(opn) - 1)
            line.set_x2(o, bar_index)
            line.set_color(o, openCol)
    inSess

bool asiaIn = f_sessionBox(i_showAsia, i_asiaSess, "ASIA",     i_cAsia)
bool lonIn  = f_sessionBox(i_showLon,  i_lonSess,  "LONDON",   i_cLon)
bool nyIn   = f_sessionBox(i_showNy,   i_nySess,   "NEW YORK", i_cNy)

// ═══════════════════════════════════════════════════════════════════════════════
// RTH STRUCTURE ENGINE — overnight lock, Initial Balance, Opening Range
// ═══════════════════════════════════════════════════════════════════════════════

bool inRTH    = not na(time("", i_nySess, i_tz))
bool rthStart = inRTH and not inRTH[1]

bool inON    = not na(time("", i_onSess, i_tz))
bool onStart = inON and not inON[1]

// ─── Overnight accumulation (locked at RTH open) ─────────────────────────────
var float _onH = na
var float _onL = na
var float onH  = na
var float onL  = na

if onStart
    _onH := high
    _onL := low
else if inON
    _onH := math.max(nz(_onH, high), high)
    _onL := math.min(nz(_onL, low),  low)

// ─── Day state ────────────────────────────────────────────────────────────────
var int    rthStartBar  = na
var int    lastRthBar   = na
var int    rthStartTime = na
var float  rthHi        = na
var float  rthLo        = na
var string gapRead      = "—"

var float _ibH = na
var float _ibL = na
var float ibH  = na
var float ibL  = na
var float ibExtU1 = na
var float ibExtD1 = na
var float ibExtU2 = na
var float ibExtD2 = na

var float _orH = na
var float _orL = na
var float orH  = na
var float orL  = na

if rthStart
    // Lock the overnight range and read where the open printed inside it.
    onH  := _onH
    onL  := _onL
    _onH := na
    _onL := na
    rthStartBar  := bar_index
    rthStartTime := time
    rthHi := high
    rthLo := low
    ibH := na
    ibL := na
    ibExtU1 := na
    ibExtD1 := na
    ibExtU2 := na
    ibExtD2 := na
    orH := na
    orL := na
    _ibH := na
    _ibL := na
    _orH := na
    _orL := na
    gapRead := na(onH) or na(onL) ? "—" :
         open > onH ? "ABOVE ON HIGH ▲" :
         open < onL ? "BELOW ON LOW ▼" :
         open >= (onH + onL) / 2 ? "UPPER HALF OF ON" : "LOWER HALF OF ON"

if inRTH
    lastRthBar := bar_index
    rthHi := math.max(nz(rthHi, high), high)
    rthLo := math.min(nz(rthLo, low),  low)

// ─── IB / OR windows (bar-granularity, measured from the RTH open) ───────────
bool ibWindow = inRTH and not na(rthStartTime) and (time - rthStartTime) < i_ibMin * 60000
bool orWindow = inRTH and not na(rthStartTime) and (time - rthStartTime) < i_orMin * 60000

if ibWindow
    _ibH := math.max(nz(_ibH, high), high)
    _ibL := math.min(nz(_ibL, low),  low)
if orWindow
    _orH := math.max(nz(_orH, high), high)
    _orL := math.min(nz(_orL, low),  low)

bool ibLock = inRTH and not ibWindow and ibWindow[1]
bool orLock = inRTH and not orWindow and orWindow[1]

if ibLock
    ibH  := _ibH
    ibL  := _ibL
    _ibH := na
    _ibL := na
    float rng = ibH - ibL
    ibExtU1 := ibL + i_ext1 * rng
    ibExtD1 := ibH - i_ext1 * rng
    ibExtU2 := ibL + i_ext2 * rng
    ibExtD2 := ibH - i_ext2 * rng

if orLock
    orH  := _orH
    orL  := _orL
    _orH := na
    _orL := na

// ═══════════════════════════════════════════════════════════════════════════════
// DRAWING POOL — created once, repositioned in place on the last bar
// ═══════════════════════════════════════════════════════════════════════════════

var line  lnOnH = line.new(na, na, na, na, xloc = xloc.bar_index, color = color.new(color.white, 100))
var line  lnOnL = line.new(na, na, na, na, xloc = xloc.bar_index, color = color.new(color.white, 100))
var line  lnIbH = line.new(na, na, na, na, xloc = xloc.bar_index, color = color.new(color.white, 100))
var line  lnIbL = line.new(na, na, na, na, xloc = xloc.bar_index, color = color.new(color.white, 100))
var line  lnE1U = line.new(na, na, na, na, xloc = xloc.bar_index, color = color.new(color.white, 100))
var line  lnE1D = line.new(na, na, na, na, xloc = xloc.bar_index, color = color.new(color.white, 100))
var line  lnE2U = line.new(na, na, na, na, xloc = xloc.bar_index, color = color.new(color.white, 100))
var line  lnE2D = line.new(na, na, na, na, xloc = xloc.bar_index, color = color.new(color.white, 100))
var line  lnOrH = line.new(na, na, na, na, xloc = xloc.bar_index, color = color.new(color.white, 100))
var line  lnOrL = line.new(na, na, na, na, xloc = xloc.bar_index, color = color.new(color.white, 100))

var label lbOnH = label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small, color = color.new(color.white, 100), textcolor = color.new(color.white, 100))
var label lbOnL = label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small, color = color.new(color.white, 100), textcolor = color.new(color.white, 100))
var label lbIbH = label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small, color = color.new(color.white, 100), textcolor = color.new(color.white, 100))
var label lbIbL = label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small, color = color.new(color.white, 100), textcolor = color.new(color.white, 100))
var label lbE1U = label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small, color = color.new(color.white, 100), textcolor = color.new(color.white, 100))
var label lbE1D = label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small, color = color.new(color.white, 100), textcolor = color.new(color.white, 100))
var label lbE2U = label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small, color = color.new(color.white, 100), textcolor = color.new(color.white, 100))
var label lbE2D = label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small, color = color.new(color.white, 100), textcolor = color.new(color.white, 100))
var label lbOrH = label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small, color = color.new(color.white, 100), textcolor = color.new(color.white, 100))
var label lbOrL = label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small, color = color.new(color.white, 100), textcolor = color.new(color.white, 100))

// ─── Level bundle type — pairs a pooled line/label with its true price so the
//     decluttering pass below can sort and re-space labels without losing
//     track of which line/label/color/text each one belongs to. ────────────
type LevelItem
    line   ln
    label  lb
    float  y
    color  col
    string txt
    string sty

// Hides a pooled line/label pair (used when its level is inactive this bar).
// Clearing coordinates + full transparency prevents auto-scale squeeze.
f_hide(line ln, label lb) =>
    line.set_xy1(ln, na, na)
    line.set_xy2(ln, na, na)
    line.set_color(ln, color.new(color.white, 100))
    label.set_x(lb, na)
    label.set_y(lb, na)
    label.set_color(lb, color.new(color.white, 100))
    label.set_textcolor(lb, color.new(color.white, 100))

// Draws a level's line at its true price. Line position never gets decluttered —
// only the label text position is adjusted, so lines always reflect real levels.
f_showLine(line ln, float y, color col, string sty) =>
    line.set_xy1(ln, math.max(rthStartBar, bar_index - 4990), y)
    line.set_xy2(ln, math.max(lastRthBar, bar_index - 4990), y)
    line.set_color(ln, col)
    line.set_style(ln, sty)

// Places a level's label at its (possibly decluttered) yPos, while the printed
// price value always reflects the true price (trueY), not the display position.
f_showLabel(label lb, float yPos, float trueY, color col, string txt) =>
    label.set_xy(lb, math.max(lastRthBar + i_lblOff, bar_index - 4990), yPos)
    label.set_text(lb, txt + "  " + str.tostring(trueY, format.mintick))
    label.set_color(lb, color.new(col, 85))
    label.set_textcolor(lb, col)

string ext1Txt = "IB " + str.tostring(i_ext1, "#.##") + "×"
string ext2Txt = "IB " + str.tostring(i_ext2, "#.##") + "×"

if barstate.islast and not na(rthStartBar)
    array<LevelItem> items = array.new<LevelItem>()

    if i_showON and not na(onH)
        array.push(items, LevelItem.new(ln = lnOnH, lb = lbOnH, y = onH, col = i_cON, txt = "ON HIGH", sty = line.style_solid))
    else
        f_hide(lnOnH, lbOnH)
    if i_showON and not na(onL)
        array.push(items, LevelItem.new(ln = lnOnL, lb = lbOnL, y = onL, col = i_cON, txt = "ON LOW", sty = line.style_solid))
    else
        f_hide(lnOnL, lbOnL)

    if i_showIB and not na(ibH)
        array.push(items, LevelItem.new(ln = lnIbH, lb = lbIbH, y = ibH, col = i_cIB, txt = "IBH", sty = line.style_solid))
    else
        f_hide(lnIbH, lbIbH)
    if i_showIB and not na(ibL)
        array.push(items, LevelItem.new(ln = lnIbL, lb = lbIbL, y = ibL, col = i_cIB, txt = "IBL", sty = line.style_solid))
    else
        f_hide(lnIbL, lbIbL)

    if i_showExt and not na(ibExtU1)
        array.push(items, LevelItem.new(ln = lnE1U, lb = lbE1U, y = ibExtU1, col = i_cExt, txt = ext1Txt + " ▲", sty = line.style_dashed))
    else
        f_hide(lnE1U, lbE1U)
    if i_showExt and not na(ibExtD1)
        array.push(items, LevelItem.new(ln = lnE1D, lb = lbE1D, y = ibExtD1, col = i_cExt, txt = ext1Txt + " ▼", sty = line.style_dashed))
    else
        f_hide(lnE1D, lbE1D)
    if i_showExt and not na(ibExtU2)
        array.push(items, LevelItem.new(ln = lnE2U, lb = lbE2U, y = ibExtU2, col = i_cExt, txt = ext2Txt + " ▲", sty = line.style_dashed))
    else
        f_hide(lnE2U, lbE2U)
    if i_showExt and not na(ibExtD2)
        array.push(items, LevelItem.new(ln = lnE2D, lb = lbE2D, y = ibExtD2, col = i_cExt, txt = ext2Txt + " ▼", sty = line.style_dashed))
    else
        f_hide(lnE2D, lbE2D)

    if i_showOR and not na(orH)
        array.push(items, LevelItem.new(ln = lnOrH, lb = lbOrH, y = orH, col = i_cOR, txt = "ORH", sty = line.style_dotted))
    else
        f_hide(lnOrH, lbOrH)
    if i_showOR and not na(orL)
        array.push(items, LevelItem.new(ln = lnOrL, lb = lbOrL, y = orL, col = i_cOR, txt = "ORL", sty = line.style_dotted))
    else
        f_hide(lnOrL, lbOrL)

    int n = array.size(items)

    // Draw every active level's line at its true price — unaffected by decluttering.
    for i = 0 to n - 1
        LevelItem it = array.get(items, i)
        f_showLine(it.ln, it.y, it.col, it.sty)

    // Sort active items by true price, descending (highest price first), so the
    // pass below can place labels top-to-bottom. Simple insertion sort — the
    // active-level count is small (max 10), so the cost is negligible.
    if n > 1
        for i = 1 to n - 1
            LevelItem key = array.get(items, i)
            int j = i - 1
            bool cont = true
            while j >= 0 and cont
                LevelItem cur = array.get(items, j)
                if cur.y < key.y
                    array.set(items, j + 1, cur)
                    j -= 1
                else
                    cont := false
            array.set(items, j + 1, key)

    // Declutter pass: walk top-to-bottom. If a label would sit closer than the
    // minimum gap to the label placed immediately above it, push it down just
    // enough to clear — the printed price value still reflects the true level.
    float minGap = close * i_minGapPct / 100.0
    float prevY  = na
    for i = 0 to n - 1
        LevelItem it = array.get(items, i)
        float placedY = it.y
        if i_declutter and not na(prevY) and placedY > prevY - minGap
            placedY := prevY - minGap
        f_showLabel(it.lb, placedY, it.y, it.col, it.txt)
        prevY := placedY

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION STATE TABLE
// Populated only on the last bar to avoid unnecessary per-bar cell redraws.
// ═══════════════════════════════════════════════════════════════════════════════

var table info_table = table.new(position.top_right, 2, 8,
                                  bgcolor      = color.new(color.black, 80),
                                  border_width = 1,
                                  border_color = color.new(color.gray, 65))

if i_showTable and barstate.islast
    string sessName = nyIn ? "NEW YORK" : lonIn ? "LONDON" : asiaIn ? "ASIA" : "OFF HOURS"
    color  sessCol  = nyIn ? i_cNy : lonIn ? i_cLon : asiaIn ? i_cAsia : color.gray

    string onTxt = not na(onH) and not na(onL) ?
         str.tostring(onH, format.mintick) + " / " + str.tostring(onL, format.mintick) : "—"
    string ibTxt = not na(ibH) and not na(ibL) ?
         str.tostring(ibH, format.mintick) + " / " + str.tostring(ibL, format.mintick) :
         inRTH ? "forming…" : "—"
    string orTxt = not na(orH) and not na(orL) ?
         str.tostring(orH, format.mintick) + " / " + str.tostring(orL, format.mintick) :
         inRTH ? "forming…" : "—"

    string ibStat = na(ibH) ? "—" : close > ibH ? "BREAKOUT ▲" : close < ibL ? "BREAKOUT ▼" : "INSIDE IB"
    string orStat = na(orH) ? "—" : close > orH ? "BREAKOUT ▲" : close < orL ? "BREAKOUT ▼" : "INSIDE OR"

    string extTested = ""
    if not na(ibExtU1)
        extTested += rthHi >= ibExtU2 ? str.tostring(i_ext2, "#.##") + "×▲ " : rthHi >= ibExtU1 ? str.tostring(i_ext1, "#.##") + "×▲ " : ""
        extTested += rthLo <= ibExtD2 ? str.tostring(i_ext2, "#.##") + "×▼" : rthLo <= ibExtD1 ? str.tostring(i_ext1, "#.##") + "×▼" : ""
    extTested := extTested == "" ? "—" : extTested

    table.cell(info_table, 0, 0, "ISS",            bgcolor = color.new(color.gray, 55), text_color = color.white, text_size = size.small)
    table.cell(info_table, 1, 0, "State",          bgcolor = color.new(color.gray, 55), text_color = color.white, text_size = size.small)
    table.cell(info_table, 0, 1, "Session",        text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 1, sessName,         text_color = sessCol,     text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 2, "ON H/L",         text_color = i_cON,       text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 2, onTxt,            text_color = i_cON,       text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 3, "Open vs ON",     text_color = i_cON,       text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 3, gapRead,          text_color = i_cON,       text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 4, "IB H/L",         text_color = i_cIB,       text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 4, ibTxt,            text_color = i_cIB,       text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 5, "IB Status",      text_color = i_cIB,       text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 5, ibStat,           text_color = i_cIB,       text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 6, "Ext Tested",     text_color = i_cExt,      text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 6, extTested,        text_color = i_cExt,      text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 7, "OR Status",      text_color = i_cOR,       text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 7, orStat,           text_color = i_cOR,       text_size = size.small, bgcolor = color.new(color.black, 85))

// ═══════════════════════════════════════════════════════════════════════════════
// ALERT CONDITIONS
// All conditions are gated on confirmed bar closes inside RTH — no repainting.
// ═══════════════════════════════════════════════════════════════════════════════

bool xOrU = ta.crossover(close,  orH)
bool xOrD = ta.crossunder(close, orL)
bool xIbU = ta.crossover(close,  ibH)
bool xIbD = ta.crossunder(close, ibL)
bool xOnU = ta.crossover(close,  onH)
bool xOnD = ta.crossunder(close, onL)
bool xE2U = ta.crossover(close,  ibExtU2)
bool xE2D = ta.crossunder(close, ibExtD2)

bool gate = barstate.isconfirmed and inRTH

alertcondition(gate and xOrU, title = "OR Breakout ▲",     message = "Price closed above the Opening Range high — {{ticker}} @ {{close}}")
alertcondition(gate and xOrD, title = "OR Breakout ▼",     message = "Price closed below the Opening Range low — {{ticker}} @ {{close}}")
alertcondition(gate and xIbU, title = "IB Breakout ▲",     message = "Price closed above the Initial Balance high — {{ticker}} @ {{close}}")
alertcondition(gate and xIbD, title = "IB Breakout ▼",     message = "Price closed below the Initial Balance low — {{ticker}} @ {{close}}")
alertcondition(gate and xOnU, title = "ON High Break ▲",   message = "Price closed above the Overnight high — {{ticker}} @ {{close}}")
alertcondition(gate and xOnD, title = "ON Low Break ▼",    message = "Price closed below the Overnight low — {{ticker}} @ {{close}}")
alertcondition(gate and xE2U, title = "IB Extension 2 ▲",  message = "Price closed above the upper IB extension — trend-day behavior — {{ticker}} @ {{close}}")
alertcondition(gate and xE2D, title = "IB Extension 2 ▼",  message = "Price closed below the lower IB extension — trend-day behavior — {{ticker}} @ {{close}}")
````
