<!-- tradingview-pine-id: PUB;6816e552533647d69bb04c34df55a37f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA Pinch Ladder [AlgoNorth]

Source: https://www.tradingview.com/script/52m4Z0Yo-EMA-Pinch-Ladder-AlgoNorth/

## Description

EMA Pinch Ladder 

You know that moment when your moving averages bunch up into one tight little knot and the whole chart goes quiet?

Every trader has a theory about what comes next. EMA Pinch Ladder goes and finds out.

It spots every time six EMAs pinch together on your chart, boxes it up, then tracks how far price travels once the pinch lets go. Every result is filed on the ladder by how long the pinch lasted — quick blips, medium coils, marathon squeezes — and sits right next to what an ordinary stretch of your chart does. One glance tells you whether the quiet on this chart has really been the calm before the storm.

The glowing ribbon shows how neatly the stack is lined up. The white thread follows a pinch as it forms, one closed bar at a time. The panel keeps a running tally, with the sample count on every row. And because everything is measured in ATRs, the same settings carry across symbols and timeframes.

One heads-up before you dive in: the ladder measures how far price moved, not which way, and the zones are drawn once each pinch has played out. Think of it as a history book for your chart rather than a crystal ball — more on that in the limitations below.

🔶 USAGE

🔸 Reading the chart
- Cyan zone — a finished pinch: the six EMAs closed in tight. The tag says how many bars it lasted.
- Pink zone — the 20 bars measured from the release: the full high-to-low range price covered, tagged in ATRs.
- White thread — a pinch in progress, drawn at the close of each bar.
- Diamond — marks the bar where a pinch of at least the minimum length ended.
- Ribbon glow — how neatly the six EMAs are stacked and how far they have fanned. Cosmetic: it restates what the lines already show.

🔸 Reading the ladder
Here's an example of the panel on ES1! 15m, last bar 2026-09-21 02:30 exchange time (Chicago), bar #20,799:

1–5 bars    6.2×  n=57
6–10 bars   4.7×  n=57
11–20 bars  5.3×  n=71
21+ bars    4.9×  n=103
Any bar     3.9×  n=3000

How to read it: "1–5 bars 6.2× n=57" means that after the 57 pinches lasting 1–5 bars, price travelled a median of about 6.2 ATRs over the 20 bars from the release.

"Any bar" is the same measurement from every bar (the last 3,000), so you can compare. Here, every pinch row sits above it, and the shortest pinches sit highest.

Your numbers will differ with the symbol, timeframe and history loaded, and they shift as new bars arrive. Check the limitations for one important caveat before reading too much into any gap, then load it on your own market and see what yours says.

🔸 Ways to use it
- Test the squeeze idea on your own symbol and timeframe before building anything on it.
- Get a feel for how much room price has needed after pinches on this chart.
- Compare markets and timeframes without changing any settings — everything is measured in ATRs, so the same values carry across.
- Watch the State row: it shows live whether the stack is pinched right now, and for how many bars.
- Alerts: pinch reached minimum length, pinch released, stack in bull order, stack in bear order.

🔶 DETAILS

🔸 What counts as a pinch
Six EMAs (8, 13, 21, 34, 55, 89 by default) form the stack. The gap between the highest and lowest is divided by a 100-bar ATR, so "Pinch width" is a multiple of ATR, not a price distance — one setting behaves similarly across symbols and timeframes.

A pinch starts when the gap drops under the pinch width, and ends once it opens past the width plus the release buffer (25% by default). The buffer stops one pinch being chopped into several while the gap hovers on the line. It also means a running pinch can include bars slightly wider than the pinch width itself.

🔸 What gets measured
When a pinch ends, the script takes the full high-to-low range of the 20 bars from the release (20 by default, adjustable) — counting the release bar as bar one — and divides it by the ATR as it stood at the release. The ATR is frozen there, so 3× means three times the volatility going in.

🔸 How the ladder is built
Every finished pinch is filed by length: 1–5, 6–10, 11–20 and 21+ bars (all three boundaries adjustable). Pinches too short to draw are still counted. Each row shows the median, not the average, so one wild release can't dominate it. A row stays blank until it holds 5 samples, and n is always shown.

🔸 Nothing repaints
Every pinch decision happens on a closed bar. Zones and tags are created once and never moved or recoloured. The live readouts are the panel's State and Stack width rows, and the EMA lines on the forming bar, which settle at the close like any moving average. Nothing is fetched: no other timeframe, no external data — every number comes from the bars on your chart.

🔸 Why zones can overlap
Cyan zones are pinches; pink zones are the 20 bars measured after each one ends. If the market pinches again inside that window, the two zones overlap — both are correct, they just describe the same bars from two angles.

🔸 A thread without a zone
That's a pinch shorter than "Minimum bars to draw": it was tracked live and counted in the panel, but too short to be boxed.

🔶 SETTINGS

🔸 Stack — six EMA lengths (source fixed to close) and the ATR length used as the yardstick.
🔸 Pinch — pinch width, release buffer, outcome bars and minimum bars to draw (also the threshold for the two pinch alerts).
🔸 Length buckets — three ladder boundaries (read in ascending order, whatever order you enter them) and the minimum samples before a row shows a figure.
🔸 Stack appearance — palettes including Neutral (one hue for both orders, so the stack can't be mistaken for your candle colours), custom colours, glow strength and EMA lines.
🔸 Zones and tags — show or hide each element, colours, fills, how many zones stay on the chart, edge width and tag size.
🔸 Panel — full or compact rows, five positions and text size. The header shows the live settings and the last row shows the bar time and count, so you can always tell which copy you're reading and that it's current.

🔶 LIMITATIONS

🔸 Historical context, not live calls. Zones are drawn once each pinch has played out. While a pinch is running, the live signs are the thread and the State row.

🔸 Measures distance, not direction. The outcome is the full high-to-low range of the window, so a trend, a reversal and wide chop can all print the same number. It tells you how far price travelled, not which way.

🔸 Part of the gap is built in. Each window starts on the bar where the stack opened up, so some of the extra movement comes from how the window is chosen. The "Any bar" row is there as a reference for that.

🔸 Samples overlap. "Any bar" includes the pinch bars themselves, and back-to-back pinches can share bars, so treat n as a count of windows rather than fully independent samples. Each row keeps its most recent 500 pinches; "Any bar" keeps the last 3,000 bars.

🔸 Your chart, your numbers. Symbol, timeframe, loaded history and settings all change the figures. Heikin Ashi and Renko use synthetic bars, and the panel flags it when one is loaded.

🔸 A measuring tool, not a strategy. It gives no entries or exits and isn't a backtest. It describes the past, and it isn't financial advice.

Also worth knowing: it needs about 100 bars to warm up, overnight and regular hours are counted together, "Last bar" shows exchange time, and you can move the panel with Position if price runs through it.

🔶 SUMMARY

EMA ribbons are nothing new — the twist here is the measuring. EMA Pinch Ladder marks every time six EMAs pinch together on your chart and measures how far price travels once each pinch lets go. Each result is filed on a ladder by how long the pinch lasted, and the panel shows every row beside an ordinary stretch of the same chart, with the sample count included.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoNorth
//@version=6
indicator("EMA Pinch Ladder [AlgoNorth]", overlay = true, max_boxes_count = 120, max_lines_count = 250, max_labels_count = 120)

// ───────────────────────── Inputs ─────────────────────────
string G_STACK  = "Stack"
string G_PINCH  = "Pinch"
string G_LADDER = "Length buckets"
string G_SKIN   = "Stack appearance"
string G_ZONES  = "Zones and tags"
string G_PANEL  = "Panel"

int    len1       = input.int(8, "EMA 1 (fastest)", minval = 1, maxval = 500, group = G_STACK, tooltip = "Length of the fastest EMA in the stack.")
int    len2       = input.int(13, "EMA 2", minval = 1, maxval = 500, group = G_STACK, tooltip = "Length of the second EMA in the stack.")
int    len3       = input.int(21, "EMA 3", minval = 1, maxval = 500, group = G_STACK, tooltip = "Length of the third EMA in the stack.")
int    len4       = input.int(34, "EMA 4", minval = 1, maxval = 500, group = G_STACK, tooltip = "Length of the fourth EMA in the stack.")
int    len5       = input.int(55, "EMA 5", minval = 1, maxval = 500, group = G_STACK, tooltip = "Length of the fifth EMA in the stack.")
int    len6       = input.int(89, "EMA 6 (slowest)", minval = 1, maxval = 500, group = G_STACK, tooltip = "Length of the slowest EMA in the stack.")
int    atrLen     = input.int(100, "Width ATR length", minval = 10, maxval = 500, group = G_STACK, tooltip = "The stack's width is measured in multiples of this ATR, so one setting reads the same on any symbol and timeframe.")

float  pinchW     = input.float(1.1, "Pinch width", minval = 0.1, maxval = 10.0, step = 0.1, group = G_PINCH, tooltip = "The stack counts as pinched while the gap between its highest and lowest EMA is narrower than this many ATRs. Once started, a pinch stays pinched until the gap exceeds this width plus the release buffer.")
int    bufferPct  = input.int(25, "Release buffer %", minval = 0, maxval = 100, group = G_PINCH, tooltip = "A pinch ends once the stack opens this much wider than the pinch width. Stops one pinch being counted as several while the width sits on the line.")
int    outBars    = input.int(20, "Outcome bars", minval = 2, maxval = 200, group = G_PINCH, tooltip = "How many bars after a release are measured, counting the release bar itself. The measurement is taken only once all of them have closed.")
int    minDraw    = input.int(8, "Minimum bars to draw", minval = 2, maxval = 200, group = G_PINCH, tooltip = "Pinches shorter than this are still measured and still appear in the panel's ladder. Longer ones are drawn on the chart and are the ones the two pinch alerts fire on.")

int    edge1      = input.int(5, "Bucket 1 ends at", minval = 1, maxval = 400, group = G_LADDER, tooltip = "Upper length, in bars, of the first row of the panel ladder. Edges are read in ascending order: one set below the edge before it is raised to sit just above it.")
int    edge2      = input.int(10, "Bucket 2 ends at", minval = 2, maxval = 500, group = G_LADDER, tooltip = "Upper length, in bars, of the second row of the panel ladder. Edges are read in ascending order: one set below the edge before it is raised to sit just above it.")
int    edge3      = input.int(20, "Bucket 3 ends at", minval = 3, maxval = 600, group = G_LADDER, tooltip = "Upper length, in bars, of the third row. Everything longer falls into the last row. Edges are read in ascending order: one set below the edge before it is raised to sit just above it.")
int    minN       = input.int(5, "Minimum samples to show", minval = 3, maxval = 200, group = G_LADDER, tooltip = "A row shows its figure only once it holds at least this many measured pinches. The sample count is shown either way.")

string palette    = input.string("Vivid", "Stack palette", options = ["Vivid", "Green / Red", "Aurora", "Neutral", "Custom"], group = G_SKIN, tooltip = "Colours for a stack in bull order and in bear order. Vivid is built for dark charts. Neutral uses one hue for both, so the stack's colour cannot be read as a direction; with it the strands go flat and order strength then reads only through the glow's intensity.")
color  upCustom   = input.color(#00d9a3, "Custom bull colour", group = G_SKIN, tooltip = "Bull-order colour when the palette is set to Custom.")
color  dnCustom   = input.color(#ff2d55, "Custom bear colour", group = G_SKIN, tooltip = "Bear-order colour when the palette is set to Custom.")
color  mixCol     = input.color(#8a8f9c, "Mixed colour", group = G_SKIN, tooltip = "Colour of the stack while its EMAs are out of order.")
int    glowStr    = input.int(55, "Glow strength %", minval = 0, maxval = 90, group = G_SKIN, tooltip = "Peak opacity at the fast edge of the stack. It fades to clear at the slow edge and brightens as the stack lines up and fans out. Raised automatically on light charts, where a translucent fill has less to contrast against. 0 turns the glow off.")
bool   showLines  = input.bool(true, "Show EMA lines", group = G_SKIN, tooltip = "Draws the six EMAs as thin strands, tinted by how firmly the stack is ordered.")

bool   showPinch  = input.bool(true, "Show pinch zones", group = G_ZONES, tooltip = "Spans the widest the stack reached across each finished pinch, tagged with its length. Drawn once the pinch ends and never altered.")
color  pinchCol   = input.color(#2ad4e8, "Pinch colour", group = G_ZONES, tooltip = "Colour of the pinch zones and their tags.")
float  pinchPad   = input.float(0.6, "Pinch standoff", minval = 0.0, maxval = 3.0, step = 0.1, group = G_ZONES, tooltip = "How far the pinch zone's edges sit outside the stack, in ATRs. Raise it if the zone is hard to tell apart from the EMA lines it wraps.")
int    pinchFillP = input.int(9, "Pinch fill %", minval = 0, maxval = 60, group = G_ZONES, tooltip = "Opacity of the pinch zone fill. Its top and bottom edges stay visible at 0. Raise it on a mid-tone background, where a light fill has little to contrast against.")
int    pinchKept  = input.int(20, "Pinch zones kept", minval = 1, maxval = 50, group = G_ZONES, tooltip = "How many of the most recent pinch zones stay on the chart. This has no effect on the panel's statistics, which retain far more.")
bool   showThread = input.bool(true, "Show live thread", group = G_ZONES, tooltip = "Draws a thread through the middle of the stack on every closed bar belonging to a pinch that is still running.")
bool   showDiam   = input.bool(true, "Show release marks", group = G_ZONES, tooltip = "A small diamond on the bar where a pinch of at least the minimum length ends, whether or not its zone is drawn. It carries no direction.")

bool   showOut    = input.bool(true, "Show outcome zones", group = G_ZONES, tooltip = "Once the outcome bars have closed, a zone spans the full price range they covered, tagged in ATRs. Drawn only after those bars close and never altered.")
color  outCol     = input.color(#f2456b, "Outcome colour", group = G_ZONES, tooltip = "Colour of the outcome zones and their tags.")
int    outFillP   = input.int(9, "Outcome fill %", minval = 0, maxval = 60, group = G_ZONES, tooltip = "Opacity of the outcome zone fill. Its top and bottom edges stay visible at 0. Raise it on a mid-tone background, where a light fill has little to contrast against.")
int    outKept    = input.int(20, "Outcome zones kept", minval = 1, maxval = 60, group = G_ZONES, tooltip = "How many of the most recent outcome zones stay on the chart. This has no effect on the panel's statistics, which retain far more.")

int    edgeWidth  = input.int(2, "Zone edge width", minval = 1, maxval = 4, group = G_ZONES, tooltip = "Thickness of the top and bottom edges on the pinch and outcome zones.")
int    tagBgP     = input.int(22, "Tag background %", minval = 0, maxval = 100, group = G_ZONES, tooltip = "Opacity of the pill behind each tag. The tag's text stays the chart's own foreground colour at every setting, so raise this for a solid pill and lower it for text that floats on the chart.")
string lblSizeIn  = input.string("Normal", "Tag text size", options = ["Tiny", "Small", "Normal", "Large"], group = G_ZONES, tooltip = "Text size of the pinch and outcome tags on the chart.")

bool   showPanel  = input.bool(true, "Show panel", group = G_PANEL, tooltip = "Live panel with the stack's state and width, and the measured move after each pinch length on this chart.")
string panelSize  = input.string("Full", "Panel rows", options = ["Full", "Compact"], group = G_PANEL, tooltip = "Full shows every row. Compact keeps the state, the ladder and the last-bar row, dropping the stack width and the baseline.")
string panelPos   = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G_PANEL, tooltip = "Panel corner. Move it if price is running through the panel — the chart's own bars are drawn over any panel. Pick different corners when several copies are loaded, so the panels never overlap.")
string panelText  = input.string("Small", "Panel text size", options = ["Tiny", "Small", "Normal"], group = G_PANEL, tooltip = "Panel text size.")

// Ladder edges are read in ascending order, whatever order they are entered in.
int eA = edge1
int eB = math.max(edge2, eA + 1)
int eC = math.max(edge3, eB + 1)

// ───────────────────────── Helpers ─────────────────────────
f_meter(float x, float full) =>
    int k = math.round(math.max(math.min(nz(x) / full, 1.0), 0.0) * 10)
    string s = ""
    for i = 1 to 10
        s += i <= k ? "▰" : "▱"
    s

f_row(table t, int r, string a, string b, color cb, string sz, string tip) =>
    table.cell(t, 0, r, a, text_color = color.new(chart.fg_color, 42), text_halign = text.align_left, text_size = sz, tooltip = tip)
    table.cell(t, 1, r, b, text_color = cb, text_halign = text.align_right, text_size = sz, tooltip = tip)

f_text(array<float> a, int minSamples) =>
    int n = a.size()
    string v = n >= minSamples ? str.tostring(a.median(), "0.0") + "×" : "–"
    v + "  n=" + str.tostring(n)

f_push(array<float> a, float v, int cap) =>
    a.push(v)
    if a.size() > cap
        a.shift()

// ───────────────────────── Palette ─────────────────────────
color colUp = switch palette
    "Vivid"       => #00d9a3
    "Green / Red" => #089981
    "Aurora"      => #22d3ee
    "Neutral"     => chart.fg_color
    => upCustom
color colDn = switch palette
    "Vivid"       => #ff2d55
    "Green / Red" => #f23645
    "Aurora"      => #e040fb
    "Neutral"     => chart.fg_color
    => dnCustom

string lblSize = switch lblSizeIn
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    => size.normal

// chart.fg_color is light on a dark chart and dark on a light one, so its brightness tells us which we are on.
bool  lightChart = color.r(chart.fg_color) + color.g(chart.fg_color) + color.b(chart.fg_color) < 382
color tagText    = color.new(chart.fg_color, 0)

// ───────────────────────── Stack ─────────────────────────
float e1      = ta.ema(close, len1)
float e2      = ta.ema(close, len2)
float e3      = ta.ema(close, len3)
float e4      = ta.ema(close, len4)
float e5      = ta.ema(close, len5)
float e6      = ta.ema(close, len6)
float atrN    = ta.atr(atrLen)
float atrSafe = na(atrN) ? ta.tr(true) : atrN
float hiWin   = ta.highest(high, outBars)
float loWin   = ta.lowest(low, outBars)

bool  warm   = not na(e1) and not na(e2) and not na(e3) and not na(e4) and not na(e5) and not na(e6) and not na(atrN)
float sTop   = math.max(e1, e2, e3, e4, e5, e6)
float sBot   = math.min(e1, e2, e3, e4, e5, e6)
float sMid   = (e1 + e2 + e3 + e4 + e5 + e6) / 6
float spread = (sTop - sBot) / math.max(atrSafe, syminfo.mintick)
int   ord    = e1 > e2 and e2 > e3 and e3 > e4 and e4 > e5 and e5 > e6 ? 1 : e1 < e2 and e2 < e3 and e3 < e4 and e4 < e5 and e5 < e6 ? -1 : 0
int   score  = (e1 > e2 ? 1 : e1 < e2 ? -1 : 0) + (e2 > e3 ? 1 : e2 < e3 ? -1 : 0) + (e3 > e4 ? 1 : e3 < e4 ? -1 : 0) + (e4 > e5 ? 1 : e4 < e5 ? -1 : 0) + (e5 > e6 ? 1 : e5 < e6 ? -1 : 0)
float orderK = math.abs(score) / 5.0
float widthK = math.min(nz(warm ? spread : 0.0) / 4.0, 1.0)
color hue    = score > 0 ? colUp : score < 0 ? colDn : mixCol
float relTh  = pinchW * (1 + bufferPct / 100.0)
bool  conf   = barstate.isconfirmed

// ───────────────────────── State (changes on closed bars only) ─────────────────────────
var bool          inRun     = false
var int           runLen    = 0
var int           runStart  = na
var int           runEnd    = na
var float         runTop    = na
var float         runBot    = na

var array<int>    pendIdx   = array.new<int>()
var array<float>  pendAtr   = array.new<float>()
var array<int>    pendLen   = array.new<int>()

var array<float>  bk1       = array.new<float>()
var array<float>  bk2       = array.new<float>()
var array<float>  bk3       = array.new<float>()
var array<float>  bk4       = array.new<float>()
var array<float>  anyBar    = array.new<float>()

var array<box>    pinchBox  = array.new<box>()
var array<line>   pinchLine = array.new<line>()
var array<label>  pinchTag  = array.new<label>()
var array<box>    outBox    = array.new<box>()
var array<line>   outLine   = array.new<line>()
var array<label>  outTag    = array.new<label>()

bool livePinch = warm and (inRun ? spread <= relTh : spread < pinchW)
bool relDrawn  = false
bool reachMin  = false

if conf and warm
    // ── track the run ──
    if not inRun
        if spread < pinchW
            inRun    := true
            runLen   := 1
            runStart := bar_index
            runEnd   := bar_index
            runTop   := sTop
            runBot   := sBot
    else
        if spread <= relTh
            runLen += 1
            reachMin := runLen == minDraw
            runEnd := bar_index
            runTop := math.max(runTop, sTop)
            runBot := math.min(runBot, sBot)
        else
            // ── the run has ended: queue it for measurement, whatever its length ──
            inRun := false
            pendIdx.push(bar_index)
            pendAtr.push(atrSafe)
            pendLen.push(runLen)

            if runLen >= minDraw
                relDrawn := true
                if showPinch
                    float pad  = atrSafe * pinchPad
                    float pTop = runTop + pad
                    float pBot = runBot - pad
                    string ptip = "The six EMAs closed inside " + str.tostring(pinchW, "0.0#") + " ATR of each other to open this pinch, and stayed inside " + str.tostring(relTh, "0.0##") + " ATR — the pinch width plus the release buffer — for " + str.tostring(runLen) + " bars."
                    box   pb = box.new(runStart, pTop, runEnd, pBot, border_color = color.new(pinchCol, 100), border_width = 1, bgcolor = color.new(pinchCol, 100 - pinchFillP))
                    line  pt = line.new(runStart, pTop, runEnd, pTop, xloc.bar_index, extend.none, pinchCol, line.style_solid, edgeWidth)
                    line  pl = line.new(runStart, pBot, runEnd, pBot, xloc.bar_index, extend.none, pinchCol, line.style_solid, edgeWidth)
                    label pg = label.new(runStart, pTop, "Pinch · " + str.tostring(runLen) + " bars", xloc.bar_index, yloc.price, color.new(pinchCol, 100 - tagBgP), label.style_label_lower_left, tagText, lblSize, tooltip = ptip)
                    pinchBox.push(pb)
                    pinchLine.push(pt)
                    pinchLine.push(pl)
                    pinchTag.push(pg)
                    while pinchTag.size() > pinchKept
                        label.delete(pinchTag.shift())
                        box.delete(pinchBox.shift())
                        line.delete(pinchLine.shift())
                        line.delete(pinchLine.shift())
            runLen := 0

    // ── reference: the same measurement starting from any bar ──
    if bar_index >= outBars
        float refAtr = atrSafe[outBars - 1]
        if not na(refAtr) and refAtr > 0
            f_push(anyBar, (hiWin - loWin) / refAtr, 3000)

    // ── measure every queued pinch once its outcome bars have closed ──
    while pendIdx.size() > 0 and bar_index - pendIdx.first() >= outBars - 1
        int   qIdx = pendIdx.shift()
        float qAtr = pendAtr.shift()
        int   qLen = pendLen.shift()
        float move = (hiWin - loWin) / qAtr

        if qLen <= eA
            f_push(bk1, move, 500)
        else if qLen <= eB
            f_push(bk2, move, 500)
        else if qLen <= eC
            f_push(bk3, move, 500)
        else
            f_push(bk4, move, 500)

        if qLen >= minDraw and showOut
            string otip = "Price range over the " + str.tostring(outBars) + " bars from this release, counting the release bar: " + str.tostring(move, "0.0") + "× ATR. The pinch before it lasted " + str.tostring(qLen) + " bars."
            box   ob = box.new(qIdx, hiWin, bar_index, loWin, border_color = color.new(outCol, 100), border_width = 1, bgcolor = color.new(outCol, 100 - outFillP))
            line  lt = line.new(qIdx, hiWin, bar_index, hiWin, xloc.bar_index, extend.none, outCol, line.style_solid, edgeWidth)
            line  lb = line.new(qIdx, loWin, bar_index, loWin, xloc.bar_index, extend.none, outCol, line.style_solid, edgeWidth)
            label ol = label.new(qIdx, hiWin, str.tostring(move, "0.0") + "× ATR", xloc.bar_index, yloc.price, color.new(outCol, 100 - tagBgP), label.style_label_lower_left, tagText, lblSize, tooltip = otip)
            outBox.push(ob)
            outLine.push(lt)
            outLine.push(lb)
            outTag.push(ol)
            while outTag.size() > outKept
                label.delete(outTag.shift())
                box.delete(outBox.shift())
                line.delete(outLine.shift())
                line.delete(outLine.shift())

// ───────────────────────── Visuals ─────────────────────────
linesDisp = showLines ? display.all : display.none
glowDisp  = glowStr > 0 ? display.all : display.none

f_strand(int t) =>
    color.from_gradient(orderK, 0.0, 1.0, color.new(chart.fg_color, t), color.new(hue, t))

p1 = plot(e1, "EMA 1", f_strand(5), 2, display = linesDisp)
p2 = plot(e2, "EMA 2", f_strand(35), 1, display = linesDisp)
p3 = plot(e3, "EMA 3", f_strand(45), 1, display = linesDisp)
p4 = plot(e4, "EMA 4", f_strand(55), 1, display = linesDisp)
p5 = plot(e5, "EMA 5", f_strand(65), 1, display = linesDisp)
p6 = plot(e6, "EMA 6", f_strand(72), 1, display = linesDisp)

float glowA   = math.min(glowStr * (lightChart ? 1.35 : 1.0) * (0.3 + 0.7 * orderK) * (0.5 + 0.5 * widthK), 95)
color nearCol = color.new(hue, 100 - glowA)
color coreCol = color.new(hue, 100 - glowA * 0.6)
color farCol  = color.new(hue, 100)
bool  fastUp  = e1 >= e6
bool  fastUp3 = e1 >= e3
fill(p1, p6, math.max(e1, e6), math.min(e1, e6), fastUp ? nearCol : farCol, fastUp ? farCol : nearCol, "Stack glow", display = glowDisp)
fill(p1, p3, math.max(e1, e3), math.min(e1, e3), fastUp3 ? coreCol : farCol, fastUp3 ? farCol : coreCol, "Stack core", display = glowDisp)

float threadY = showThread and conf and livePinch ? sMid : na
plot(threadY, "Live thread", color.new(chart.fg_color, 0), 3, plot.style_linebr)
plotshape(showDiam and relDrawn ? sMid : na, "Release", shape.diamond, location.absolute, color.new(chart.fg_color, 0), size = size.tiny)

// ───────────────────────── Alerts (closed bars only) ─────────────────────────
alertcondition(conf and reachMin, "Pinch reached minimum length", "EMA Pinch Ladder: the EMA stack has been pinched for the minimum number of bars on {{ticker}} ({{interval}})")
alertcondition(conf and relDrawn, "Pinch released", "EMA Pinch Ladder: a pinch of at least the minimum length has ended on {{ticker}} ({{interval}})")
alertcondition(conf and warm and ord == 1 and ord[1] != 1, "Stack in bull order", "EMA Pinch Ladder: all six EMAs are now in bull order on {{ticker}} ({{interval}})")
alertcondition(conf and warm and ord == -1 and ord[1] != -1, "Stack in bear order", "EMA Pinch Ladder: all six EMAs are now in bear order on {{ticker}} ({{interval}})")

// ───────────────────────── Panel ─────────────────────────
string tPos = switch panelPos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    => position.top_right
string tSize = switch panelText
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

var table panel = table.new(tPos, 2, 11, bgcolor = color.new(chart.bg_color, 6), frame_color = color.new(chart.fg_color, 82), frame_width = 1, border_color = color.new(chart.fg_color, 90), border_width = 1)

if barstate.islast and showPanel
    bool   full   = panelSize == "Full"
    string state  = not warm ? "–" : inRun ? "Pinched · " + str.tostring(runLen) + " bars" : ord == 1 ? "Fanned · bull order" : ord == -1 ? "Fanned · bear order" : "Mixed"
    color  stCol  = not warm ? color.new(chart.fg_color, 48) : inRun ? pinchCol : ord == 1 ? colUp : ord == -1 ? colDn : mixCol
    color  dimCol = color.new(chart.fg_color, 48)
    string setTxt = str.tostring(len1) + "–" + str.tostring(len6) + " · < " + str.tostring(pinchW, "0.0#") + "× · " + str.tostring(outBars) + " bars"
    string lbl1   = "1–" + str.tostring(eA) + " bars"
    string lbl2   = str.tostring(eA + 1) + "–" + str.tostring(eB) + " bars"
    string lbl3   = str.tostring(eB + 1) + "–" + str.tostring(eC) + " bars"
    string lbl4   = str.tostring(eC + 1) + "+ bars"
    string bTip   = "Median price range over the " + str.tostring(outBars) + " bars from each release, counting the release bar, for pinches of this length. Taken from the history this chart has loaded, holding the most recent 500 pinches per row. n is how many have been measured. Every pinch is counted here, including the short ones that are not drawn."

    table.clear(panel, 0, 0, 1, 10)
    if chart.is_standard
        table.cell(panel, 0, 0, "EMA Pinch Ladder", text_color = chart.fg_color, text_halign = text.align_left, text_size = tSize, bgcolor = color.new(pinchCol, 88))
        table.cell(panel, 1, 0, setTxt, text_color = color.new(chart.fg_color, 30), text_halign = text.align_right, text_size = tSize, bgcolor = color.new(pinchCol, 88))
    else
        table.cell(panel, 0, 0, "EMA Pinch Ladder", text_color = chart.fg_color, text_halign = text.align_left, text_size = tSize, bgcolor = color.new(outCol, 70))
        table.cell(panel, 1, 0, "synthetic bars — figures are not from traded prices", text_color = chart.fg_color, text_halign = text.align_right, text_size = tSize, bgcolor = color.new(outCol, 70))

    int r = 1
    f_row(panel, r, "State", state, stCol, tSize, "Pinched: the stack is inside a squeeze now. Fanned: all six EMAs are in order. Mixed: neither. A dash means there is not yet enough history to measure.")
    r += 1
    if full
        f_row(panel, r, "Stack width", f_meter(warm ? spread : 0.0, 8.0) + "  " + (warm ? str.tostring(spread, "0.0") + "×" : "–"), chart.fg_color, tSize, "Gap between the highest and lowest EMA on this bar, in ATRs.")
        r += 1
    f_row(panel, r, "Pinch length", "move / " + str.tostring(outBars) + " bars", dimCol, tSize, bTip)
    r += 1
    f_row(panel, r, lbl1, f_text(bk1, minN), chart.fg_color, tSize, bTip)
    r += 1
    f_row(panel, r, lbl2, f_text(bk2, minN), chart.fg_color, tSize, bTip)
    r += 1
    f_row(panel, r, lbl3, f_text(bk3, minN), chart.fg_color, tSize, bTip)
    r += 1
    f_row(panel, r, lbl4, f_text(bk4, minN), chart.fg_color, tSize, bTip)
    r += 1
    if full
        f_row(panel, r, "Any bar", f_text(anyBar, minN), dimCol, tSize, "The same measurement started from every bar, pinch or not, over the most recent 3000 bars of loaded history.")
        r += 1
    f_row(panel, r, "Last bar", str.format_time(time, "yyyy-MM-dd HH:mm", syminfo.timezone) + " · #" + str.tostring(bar_index + 1, "#,###"), dimCol, tSize, "Time and number of the last bar the panel was computed on.")
````
