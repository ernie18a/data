# Trendline Architect [Quantum Algo]

- url: https://www.tradingview.com/script/V8QOdl7X-Trendline-Architect-Quantum-Algo/
- type: indicator
- pine_id: PUB;d159e90b046344628af155714434ec25
- version: 1.0

## Description

Trendline Architect [Quantum Algo]
====================================================

🔶 OVERVIEW

Trendline Architect is an automatic trendline indicator that does what most trendline tools skip: it validates every line before drawing it, makes each line earn its status through real touches, grades every breakout by quality, and then automates the break-and-retest sequence that trendline traders normally track by hand. Lines are born as dotted candidates, promoted to solid confirmed trendlines only after the market validates them with a third touch, graded on breakout, kept on a retest watch after they break, and paired into parallel channels automatically — all with a deliberately quiet chart: one-letter signals whose full context lives in hover tooltips.

The problem this script solves is trendline spaghetti and trendline noise. Automatic trendline tools typically draw every pivot-to-pivot connection and alert on every violation. This engine rejects invalid lines at birth, refuses duplicates, caps how many lines can exist per side, silences the breaks of unproven lines by default, and filters weak breakouts by grade — so what remains on the chart is only what the market has actually respected.

🔶 WHAT IS A TRENDLINE BREAK AND RETEST?

A trendline connects successive swing points and acts as dynamic support or resistance while price respects it. A breakout occurs when price closes decisively through the line. The retest is what disciplined traders wait for next: price returning to the broken line from the other side and rejecting — old support acting as new resistance, or old resistance reclaimed as support. That return-and-reject is one of the most traded patterns in classical charting, and this engine detects the entire sequence automatically: validated line, graded break, watch window, confirmed retest.

🔶 WHY THIS SCRIPT IS ORIGINAL

1. Geometric validity at birth. A candidate line is rejected before it is ever drawn if any candle close violated the segment between its two anchor pivots. Lines that were never respected never reach the chart.

2. Touch-earned lifecycle. Every line starts as a dotted, untagged candidate. Each validated touch — a wick into tolerance with a close that respects the line — is counted, and only at the configured touch count is the line promoted: solid, thicker, fully colored, with a live ×N touch tag. The chart itself shows which lines the market obeys.

3. Anti-spaghetti engineering. Duplicate candidates with similar slope and position are refused, each side is capped at a configurable number of active lines with the weakest evicted first, and stale lines expire by age. The chart stays readable on every timeframe.

4. Breakout quality grading. Every breakout is scored from three observable components — volume z-score, penetration depth in Average True Range units, and breakout candle body ratio — into grades A, B, and C. Grade A signals highlight in the accent color.

5. A retest engine. Broken lines are not deleted; they turn into gray watch lines for a configurable window. A return to the broken line with a rejecting close prints the Retest signal — the classic polarity flip, automated.

6. Silence by default, depth on demand. Signals print as single letters — B for breakout, R for retest — with the full context (direction, grade, volume, penetration) in the hover tooltip. Two noise filters ship enabled: breaks of unconfirmed lines retire silently, and breakouts below a minimum grade stay off the chart and out of the alerts.

7. Automatic channel detection. When an active support line and resistance line run parallel within a slope tolerance, the engine fills the channel between them and reports it on the dashboard.

8. A live architecture dashboard. Active support and resistance counts, the nearest line with its distance in Average True Range units, a trend read derived from confirmed line slopes, the last break grade, the retest watch count, and channel status — in a compact, fully themeable panel.

🔶 HOW IT WORKS

Line construction: Confirmed swing pivots anchor every candidate line. Each new pivot is paired with the previous same-side pivot, the segment is checked for historical violations, duplicates are rejected, and side capacity is enforced before the line is created.

Touch validation: A touch counts only when the wick enters the tolerance band around the line and the close still respects it. Touches accumulate on the line's tag; the confirming touch promotes the line and, from that point, validated touches are marked with dots.

Breakouts: A close through the line beyond the buffer triggers the break. Confirmed lines produce graded signals; forming lines retire silently when the default filter is on. The broken line converts to a gray dashed watch line.

Retests: Within the watch window, a return to the broken line with a rejecting close prints R — upward reclaim of broken resistance, or downward rejection at broken support. Watch lines that see no retest expire quietly.

Channels: Active opposite-side lines are compared by slope; the closest parallel pair within tolerance is filled as a channel.

Non-repainting: Pivots require confirmation, and all touches, promotions, breaks, and retests are evaluated on closed bars only. Once printed, nothing moves.

Chart hygiene: Completed lines, touch dots, and signals are all capped by input, keeping the chart clean and the auto-scale anchored to current price.

🔶 HOW TO USE IT

1. Works on any market — cryptocurrency, forex, gold, indices, stocks, futures — and any timeframe. Raise the pivot length for larger structures.
2. Trust the visual hierarchy: dotted lines are candidates, solid lines with ×N tags are market-validated, gray dashed lines are broken and on retest watch.
3. Treat B signals as regime information: grade A breakouts with volume and penetration carry far more weight than the minimum-grade ones, and the grade is one hover away.
4. The R signal is the classic entry location: the broken line has flipped roles and price has confirmed the flip. Stops belong on the far side of the retested line.
5. Use the dashboard's Nearest row to know how far price is from the closest active line in Average True Range units before it gets there.
6. If you want the raw, unfiltered feed, disable the two noise filters in Signals — the engine detects everything either way.

🔶 SETTINGS

- Detection: pivot length, maximum anchor span, active lines per side, line expiry, completed lines to keep.
- Touches, breaks and retests: touch tolerance, touches to confirm, breakout buffer, retest watch window.
- Signals: breakout and retest toggles, confirmed-lines-only filter, minimum breakout grade.
- Channel detection with slope similarity tolerance.
- Full color customization, extension length, touch dots toggle.
- Themeable dashboard: position, four text sizes, title band, background, frame, grid, and three text colors.

🔶 ALERTS

- Trendline Confirmed — a line collected its confirming touch.
- Bullish / Bearish Trendline Breakout — a qualified close through a line, honoring the grade filter.
- Bullish / Bearish Retest Confirmed — a broken line was retested and rejected.
- Parallel Channel Detected — an active support and resistance pair is running as a channel.

🔶 FREQUENTLY ASKED QUESTIONS

Does the indicator repaint? No. Anchors are confirmed pivots and every touch, break, and retest is evaluated at bar close. Pivot confirmation introduces intentional lag equal to the pivot length.

Why do I see so few lines? By design. Between geometric validation, duplicate rejection, side caps, and expiry, only lines with genuine market respect survive. Raise the per-side cap or lower the confirmation count for a busier chart.

What do B and R mean? B is a graded breakout and R is a confirmed retest of the broken line. Hover either label for direction, grade, volume, and penetration details.

Why did a breakout print no signal? Either the line was still unconfirmed while the confirmed-only filter is on, or the break graded below your minimum. The line still changed state; only the signal was filtered.

What makes a grade A breakout? Elevated volume, deep penetration beyond the line in Average True Range terms, and a strong-bodied breakout candle — all three together.

🔶 CREDITS

Trendline analysis, breakout trading, and the break-and-retest pattern are classical charting techniques in the public domain, refined by generations of technicians. This script gratefully acknowledges that shared lineage. The geometric validity engine, touch-earned lifecycle, breakout grading model, retest watch engine, channel detection, noise-filtering architecture, and all code in this script are original work — no third-party or open-source script code was reused.

🔶 LIMITATIONS

Trendlines are geometry, not guarantees: valid lines break and graded breakouts fail. Pivot confirmation delays anchor recognition by design. Volume grading is less meaningful on symbols with unreliable volume reporting. Channel detection reports the closest parallel pair, not every possible channel. No indicator replaces independent analysis.

🔶 DISCLAIMER

This script is provided strictly for educational and informational purposes. It is not financial advice, an investment recommendation, or a solicitation to buy or sell any financial instrument. Past behavior of any trendline, breakout, or retest does not guarantee future results. Trading involves substantial risk. Always do your own research and manage risk independently.

## Source Code

````pine
//@version=6
indicator("Trendline Architect [Quantum Algo]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  Trendline analysis is classical charting technique in the
//  public domain. The validity engine, touch-based lifecycle,
//  break quality grading, retest engine, channel detection and
//  all code in this script are original work.
// ════════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════
grpD = "Line Detection"
pivLen   = input.int(8, "Pivot Length", minval = 3, maxval = 30, group = grpD, tooltip = "Bars on each side required to confirm the swing points that anchor every trendline.")
maxSpan  = input.int(150, "Maximum Anchor Span (Bars)", minval = 20, maxval = 300, group = grpD)
maxSide  = input.int(3, "Active Lines Per Side", minval = 1, maxval = 5, group = grpD, tooltip = "The engine keeps only the strongest lines per side. Weaker duplicates are rejected at birth.")
maxAge   = input.int(250, "Line Expiry (Bars)", minval = 50, maxval = 500, group = grpD)
keepHist = input.int(10, "Completed Lines To Keep", minval = 2, maxval = 30, group = grpD, tooltip = "Older completed lines beyond this count are deleted so the chart stays clean and the auto-scale stays anchored to price.")

grpT = "Touches, Breaks & Retests"
touchTol   = input.float(0.20, "Touch Tolerance (Average True Range Ratio)", step = 0.05, minval = 0.05, group = grpT)
confirmTch = input.int(3, "Touches To Confirm A Line", minval = 3, maxval = 6, group = grpT)
breakBuf   = input.float(0.10, "Breakout Buffer (Average True Range Ratio)", step = 0.05, minval = 0.0, group = grpT)
retestWin  = input.int(30, "Retest Watch Window (Bars)", minval = 5, maxval = 100, group = grpT, tooltip = "After a breakout the broken line stays on watch for this many bars. A return and rejection prints the Retest signal.")

grpC = "Channel Detection"
showChan  = input.bool(true, "Detect Parallel Channels", group = grpC)
chanTol   = input.float(25, "Slope Similarity Tolerance (%)", step = 5, minval = 5, maxval = 60, group = grpC)

grpX = "Signals"
showBreaks  = input.bool(true, "Show Breakout Signals", group = grpX)
showRetests = input.bool(true, "Show Retest Signals", group = grpX)
sigConfOnly = input.bool(true, "Signal Only Confirmed Line Breaks", group = grpX, tooltip = "When enabled, breaks of forming (two-touch) lines retire silently. Only lines the market has validated with a third touch can print breakout and retest signals.")
minGradeS   = input.string("B", "Minimum Breakout Grade", options = ["A", "B", "C"], group = grpX, tooltip = "Breakouts below this grade change the line state but stay silent.")
keepSigs    = input.int(8, "Signals To Keep", minval = 2, maxval = 30, group = grpX)

grpV = "Chart Visuals"
bullCol  = input.color(#00a89d, "Support Color", group = grpV)
bearCol  = input.color(#e8365f, "Resistance Color", group = grpV)
goldCol  = input.color(#d99b1e, "Accent Color", group = grpV)
silvCol  = input.color(#5c6b80, "Neutral Color", group = grpV)
extBars  = input.int(6, "Extend Lines Right (Bars)", minval = 2, maxval = 30, group = grpV)
showDots = input.bool(true, "Mark Validated Touches", group = grpV)

grpB = "Dashboard"
showDash    = input.bool(true, "Show Dashboard", group = grpB)
dashPos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpB)
dashSize    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpB)
dashTitleBg = input.color(color.new(#231a08, 0), "Title Band", group = grpB)
dashBg      = input.color(color.new(#171207, 8), "Background", group = grpB)
dashFrame   = input.color(color.new(#d99b1e, 15), "Frame", group = grpB)
dashGrid    = input.color(color.new(#d99b1e, 80), "Grid", group = grpB)
dashHeadTxt = input.color(color.new(#f0c05a, 0), "Header Text", group = grpB)
dashBodyTxt = input.color(color.new(#eef2f7, 5), "Body Text", group = grpB)
dashMuteTxt = input.color(color.new(#cdb87e, 15), "Muted Text", group = grpB)

// ════════════════════════════════════════════════════════════════
//  SHARED SERIES
// ════════════════════════════════════════════════════════════════
atr   = ta.atr(14)
volMa = ta.sma(volume, 50)
volSd = ta.stdev(volume, 50)
volZ  = na(volSd) or volSd == 0 ? 0.0 : (volume - volMa) / volSd

f_rep(string s, int n) =>
    out = ""
    if n > 0
        for i = 1 to n
            out += s
    out

// ════════════════════════════════════════════════════════════════
//  LINE REGISTRY  ·  state: 0 forming · 1 confirmed · 2 broken
// ════════════════════════════════════════════════════════════════
var array<line>  tlLn   = array.new<line>()
var array<label> tlTag  = array.new<label>()
var array<int>   tlX1   = array.new<int>()
var array<float> tlY1   = array.new<float>()
var array<float> tlSl   = array.new<float>()
var array<int>   tlSide = array.new<int>()    // 1 support · -1 resistance
var array<int>   tlTch  = array.new<int>()
var array<int>   tlSt   = array.new<int>()
var array<int>   tlBb   = array.new<int>()    // break bar

var array<line>  histLn  = array.new<line>()
var array<label> histTag = array.new<label>()
var array<label> dotLbs  = array.new<label>()
var array<label> sigLbs  = array.new<label>()
var linefill chFill = na

var string lastBreak = "—"
var int    lastGradeN = 0

// event flags (reset every bar)
bool evConfirm    = false
bool evBreakBull  = false
bool evBreakBear  = false
bool evRetestBull = false
bool evRetestBear = false
bool evChannel    = false

f_yAt(int i, int b) =>
    tlY1.get(i) + tlSl.get(i) * (b - tlX1.get(i))

// move a finished line to history and drop it from the registry
f_retire(int i) =>
    histLn.push(tlLn.get(i))
    histTag.push(tlTag.get(i))
    tlLn.remove(i)
    tlTag.remove(i)
    tlX1.remove(i)
    tlY1.remove(i)
    tlSl.remove(i)
    tlSide.remove(i)
    tlTch.remove(i)
    tlSt.remove(i)
    tlBb.remove(i)

// count active (state <= 1) lines on a side, return weakest index
f_sideScan(int side_) =>
    int cnt = 0
    int weak = -1
    int weakTch = 99
    int weakX = 2147483647
    if tlLn.size() > 0
        for i = 0 to tlLn.size() - 1
            if tlSide.get(i) == side_ and tlSt.get(i) <= 1
                cnt += 1
                if tlTch.get(i) < weakTch or (tlTch.get(i) == weakTch and tlX1.get(i) < weakX)
                    weakTch := tlTch.get(i)
                    weakX := tlX1.get(i)
                    weak := i
    [cnt, weak]

// ════════════════════════════════════════════════════════════════
//  LINE BIRTH  ·  geometric validity + duplicate rejection
// ════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

var float prevPH = na
var int   prevPHBar = na
var float prevPL = na
var int   prevPLBar = na

f_tryCreate(bool isSup, float p2, int b2, float p1, int b1) =>
    ok = b2 > b1 and b2 - b1 <= maxSpan and b2 - b1 >= pivLen
    if ok
        slope = (p2 - p1) / (b2 - b1)
        // 1) geometric validity: no close may have violated the segment
        for b = b1 to b2
            yb = p1 + slope * (b - b1)
            cb = close[bar_index - b]
            if isSup ? cb < yb - atr * 0.02 : cb > yb + atr * 0.02
                ok := false
                break
        if ok
            // 2) duplicate rejection against active lines on the same side
            if tlLn.size() > 0
                for i = 0 to tlLn.size() - 1
                    if tlSide.get(i) == (isSup ? 1 : -1) and tlSt.get(i) <= 1
                        yNow  = f_yAt(i, bar_index)
                        yCand = p1 + slope * (bar_index - b1)
                        if math.abs(yNow - yCand) < atr * 0.5 and math.abs(tlSl.get(i) - slope) * 50 < atr * 0.5
                            ok := false
                            break
        if ok
            // 3) capacity: evict the weakest if the side is full
            [cnt, weak] = f_sideScan(isSup ? 1 : -1)
            if cnt >= maxSide and weak >= 0
                line.delete(tlLn.get(weak))
                label.delete(tlTag.get(weak))
                tlLn.remove(weak)
                tlTag.remove(weak)
                tlX1.remove(weak)
                tlY1.remove(weak)
                tlSl.remove(weak)
                tlSide.remove(weak)
                tlTch.remove(weak)
                tlSt.remove(weak)
                tlBb.remove(weak)
            c = isSup ? bullCol : bearCol
            yExt = p1 + slope * (bar_index + extBars - b1)
            tlLn.push(line.new(b1, p1, bar_index + extBars, yExt, color = color.new(c, 25), style = line.style_dotted, width = 1))
            tlTag.push(label.new(bar_index + extBars, yExt, "", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(c, 15), size = size.tiny))
            tlX1.push(b1)
            tlY1.push(p1)
            tlSl.push(slope)
            tlSide.push(isSup ? 1 : -1)
            tlTch.push(2)
            tlSt.push(0)
            tlBb.push(0)

if not na(ph) and barstate.isconfirmed
    b2 = bar_index - pivLen
    if not na(prevPH)
        f_tryCreate(false, ph, b2, prevPH, prevPHBar)
    prevPH := ph
    prevPHBar := b2
if not na(pl) and barstate.isconfirmed
    b2 = bar_index - pivLen
    if not na(prevPL)
        f_tryCreate(true, pl, b2, prevPL, prevPLBar)
    prevPL := pl
    prevPLBar := b2

// ════════════════════════════════════════════════════════════════
//  LINE LIFE  ·  touches → confirmation → breakout → retest
// ════════════════════════════════════════════════════════════════
if not na(chFill)
    linefill.delete(chFill)
    chFill := na

if tlLn.size() > 0
    for i = tlLn.size() - 1 to 0
        st   = tlSt.get(i)
        side = tlSide.get(i)
        ln   = tlLn.get(i)
        y    = f_yAt(i, bar_index)
        yE   = f_yAt(i, bar_index + extBars)
        line.set_x2(ln, bar_index + extBars)
        line.set_y2(ln, yE)
        tg = tlTag.get(i)
        label.set_x(tg, bar_index + extBars)
        label.set_y(tg, yE)
        bool retire = false
        if barstate.isconfirmed
            if st <= 1
                c = side == 1 ? bullCol : bearCol
                // validated touch: wick into tolerance, close respecting the line
                touched = side == 1 ? low <= y + atr * touchTol and low >= y - atr * touchTol and close > y : high >= y - atr * touchTol and high <= y + atr * touchTol and close < y
                if touched
                    tlTch.set(i, tlTch.get(i) + 1)
                    if tlTch.get(i) >= confirmTch
                        label.set_text(tg, "×" + str.tostring(tlTch.get(i)))
                    if showDots and tlTch.get(i) >= confirmTch
                        dotLbs.push(label.new(bar_index, y, "●", style = side == 1 ? label.style_label_up : label.style_label_down, color = color.new(color.black, 100), textcolor = color.new(c, 10), size = size.tiny))
                    if st == 0 and tlTch.get(i) >= confirmTch
                        tlSt.set(i, 1)
                        line.set_style(ln, line.style_solid)
                        line.set_width(ln, 2)
                        line.set_color(ln, color.new(c, 0))
                        evConfirm := true
                // breakout: close through the line with buffer
                broke = side == 1 ? close < y - atr * breakBuf : close > y + atr * breakBuf
                if broke
                    if sigConfOnly and st == 0
                        retire := true
                    else
                        pen  = math.abs(close - y) / atr
                        body = high > low ? math.abs(close - open) / (high - low) : 0.0
                        gradeN = 1 + (volZ > 1 ? 1 : 0) + (pen > 0.5 ? 1 : 0) + (body > 0.6 ? 1 : 0)
                        grade  = gradeN >= 4 ? "A" : gradeN == 3 ? "B" : "C"
                        minN   = minGradeS == "A" ? 4 : minGradeS == "B" ? 3 : 1
                        dirUp  = side == -1
                        if gradeN >= minN
                            lastGradeN := gradeN
                            lastBreak := (dirUp ? "▲ " : "▼ ") + grade
                            if dirUp
                                evBreakBull := true
                            else
                                evBreakBear := true
                            if showBreaks
                                sc = gradeN >= 4 ? goldCol : dirUp ? bullCol : bearCol
                                sigLbs.push(label.new(bar_index, dirUp ? low : high, "B", style = dirUp ? label.style_label_up : label.style_label_down, color = color.new(sc, 5), textcolor = dirUp ? #06222b : #2b0612, size = size.small, tooltip = "Breakout " + (dirUp ? "▲" : "▼") + " · Grade " + grade + " " + f_rep("◆", gradeN) + " · Volume " + str.tostring(volZ, "#.0") + "σ · Penetration " + str.tostring(pen, "#.0") + " ATR"))
                        tlSt.set(i, 2)
                        tlBb.set(i, bar_index)
                        line.set_color(ln, color.new(silvCol, 40))
                        line.set_style(ln, line.style_dashed)
                        line.set_width(ln, 1)
                        label.set_textcolor(tg, color.new(silvCol, 30))
                // expiry
                if bar_index - tlX1.get(i) > maxAge
                    retire := true
            else if st == 2
                // retest engine: return to the broken line and reject
                if bar_index - tlBb.get(i) > retestWin
                    retire := true
                else
                    if side == 1 and high >= y - atr * touchTol and close < y
                        evRetestBear := true
                        if showRetests
                            sigLbs.push(label.new(bar_index, high, "R", style = label.style_label_down, color = color.new(bearCol, 0), textcolor = #2b0612, size = size.small, tooltip = "Retest confirmed ▼ · broken support rejected from below"))
                        retire := true
                    else if side == -1 and low <= y + atr * touchTol and close > y
                        evRetestBull := true
                        if showRetests
                            sigLbs.push(label.new(bar_index, low, "R", style = label.style_label_up, color = color.new(bullCol, 0), textcolor = #06222b, size = size.small, tooltip = "Retest confirmed ▲ · broken resistance reclaimed as support"))
                        retire := true
        if retire
            f_retire(i)

// ════════════════════════════════════════════════════════════════
//  CHANNEL DETECTION  ·  parallel active support + resistance
// ════════════════════════════════════════════════════════════════
int chS = -1
int chR = -1
if showChan and tlLn.size() > 1
    float best = 1e10
    for i = 0 to tlLn.size() - 1
        if tlSt.get(i) <= 1 and tlSide.get(i) == 1
            for j = 0 to tlLn.size() - 1
                if tlSt.get(j) <= 1 and tlSide.get(j) == -1
                    sA = tlSl.get(i)
                    sB = tlSl.get(j)
                    ref = math.max(math.abs(sA), math.abs(sB), atr * 0.01)
                    d = math.abs(sA - sB) / ref
                    if d <= chanTol / 100.0 and d < best and f_yAt(j, bar_index) > f_yAt(i, bar_index)
                        best := d
                        chS := i
                        chR := j
if chS >= 0 and chR >= 0
    chFill := linefill.new(tlLn.get(chR), tlLn.get(chS), color.new(goldCol, 90))
    evChannel := true

// ════════════════════════════════════════════════════════════════
//  DRAWING MEMORY CAPS
// ════════════════════════════════════════════════════════════════
while histLn.size() > keepHist
    line.delete(histLn.shift())
while histTag.size() > keepHist
    label.delete(histTag.shift())
while dotLbs.size() > 40
    label.delete(dotLbs.shift())
while sigLbs.size() > keepSigs
    label.delete(sigLbs.shift())

// ════════════════════════════════════════════════════════════════
//  PREMIUM DASHBOARD
// ════════════════════════════════════════════════════════════════
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
bodySize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small
headSize = dashSize == "Tiny" ? size.small : dashSize == "Large" ? size.large : dashSize == "Normal" ? size.normal : size.small

var table tb = table.new(dPos, 2, 8, bgcolor = dashBg, frame_color = dashFrame, frame_width = 1, border_color = dashGrid, border_width = 1)

if showDash and barstate.islast
    int nS = 0
    int nR = 0
    int nW = 0
    float nearD = 1e10
    int nearSide = 0
    float slSum = 0.0
    int slN = 0
    if tlLn.size() > 0
        for i = 0 to tlLn.size() - 1
            if tlSt.get(i) <= 1
                y = f_yAt(i, bar_index)
                if tlSide.get(i) == 1
                    nS += 1
                else
                    nR += 1
                d = math.abs(close - y)
                if d < nearD
                    nearD := d
                    nearSide := tlSide.get(i)
                if tlSt.get(i) == 1
                    slSum += tlSl.get(i)
                    slN += 1
            else
                nW += 1
    trendTxt = slN == 0 ? "Forming" : slSum / slN > atr * 0.02 ? "Rising" : slSum / slN < -atr * 0.02 ? "Falling" : "Flat"
    trendCol = trendTxt == "Rising" ? bullCol : trendTxt == "Falling" ? bearCol : dashBodyTxt
    table.cell(tb, 0, 0, "◈ TRENDLINE ARCHITECT", bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 0, f_rep("◆", math.min(4, lastGradeN)), bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = bodySize)
    table.cell(tb, 0, 1, "Support", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 1, str.tostring(nS), text_color = bullCol, text_size = bodySize)
    table.cell(tb, 0, 2, "Resistance", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 2, str.tostring(nR), text_color = bearCol, text_size = bodySize)
    table.cell(tb, 0, 3, "Nearest", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 3, nearSide == 0 ? "—" : (nearSide == 1 ? "Support · " : "Resistance · ") + str.tostring(nearD / atr, "#.0") + " ATR", text_color = nearSide == 1 ? bullCol : nearSide == -1 ? bearCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 4, "Trend", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 4, trendTxt, text_color = trendCol, text_size = bodySize)
    table.cell(tb, 0, 5, "Last Break", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 5, lastBreak, text_color = lastGradeN >= 4 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 6, "Retest Watch", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 6, str.tostring(nW), text_color = nW > 0 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 7, "Channel", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 7, chS >= 0 ? "Active" : "—", text_color = chS >= 0 ? goldCol : dashBodyTxt, text_size = bodySize)

// ════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════
alertcondition(evConfirm, "Trendline Confirmed", "A trendline collected its confirming touch and was promoted to confirmed.")
alertcondition(evBreakBull, "Bullish Trendline Breakout", "Price closed above a resistance trendline.")
alertcondition(evBreakBear, "Bearish Trendline Breakout", "Price closed below a support trendline.")
alertcondition(evRetestBull, "Bullish Retest Confirmed", "A broken resistance line was retested and rejected upward.")
alertcondition(evRetestBear, "Bearish Retest Confirmed", "A broken support line was retested and rejected downward.")
alertcondition(evChannel, "Parallel Channel Detected", "An active support and resistance line are running as a parallel channel.")
````
