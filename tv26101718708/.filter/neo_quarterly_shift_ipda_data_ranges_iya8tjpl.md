# Neo Quarterly Shift / IPDA Data Ranges

- url: https://www.tradingview.com/script/iya8TJpl/
- type: indicator
- pine_id: PUB;adbd4f8232a14502ac1bc4c7be5b6c94
- version: 1.0

## Description

Use this for the TradingView script description (Overview / About):

---

## Neo Quarterly Shift / IPDA Data Ranges

Two ICT-style IPDA tools in one overlay: **Quarterly Shift IPDA** (compact timeline bands) and **Anchored IPDA Ranges** (full premium/discount zones on price).

---

### What is IPDA?

**IPDA** (Interbank Price Delivery Algorithm) refers to **20-, 40-, and 60-trading-day** lookback windows used to frame institutional delivery ranges. Shorter windows (20D) suit intraday context; 40D and 60D add broader bias. This script plots those ranges in two complementary ways.

---

### 1. Quarterly Shift / IPDA Data Ranges

Vertical **quarterly shift** markers (configurable count and month step) anchor **daily** IPDA lookbacks and **forward cast** segments.

- **20 / 40 / 60D** high and low levels per shift (colors and line styles are customizable).
- Drawn on a **dedicated left scale (0–100)** so bands stay in a fixed vertical strip while you zoom or scroll price—useful on busy charts.
- Optional **high/low lines**, **labels**, and **tick marks** at range extremes.
- **Forward cast** on the latest shift: developing 20/40/60-day ranges after the shift date (same logic as classic IPDA forward projection).
- Optional display on **5m, 15m, or 1H** (daily IPDA data; toggles per timeframe).

---

### 2. ICT Anchored IPDA Ranges

A **user-chosen anchor** (date/time) with lookback zones to the **left** and forward cast to the **right**—similar in spirit to anchored IPDA indicators.

- **Anchor time** (calendar picker / chart confirm) plus **bar shift** for fine-tuning on the daily series.
- **Lookback (left):** 20, 40, and 60 **daily bars before** the anchor (anchor is the shared boundary, not inside the range).
- **Forward cast (right):** 20, 40, and 60 **daily bars after** the anchor; range high/low update from bars that exist; time width projects forward when history is not yet complete.
- **Premium / discount** halves (upper/lower), **equilibrium (50%)**, optional **extension** of lookback high/EQ/low into the forward zone, and **IPDA20 / IPDA40 / IPDA60** and **+20 / +40 / +60** labels.
- Drawn on **price** via `force_overlay` (works with the indicator’s left-scale quarterly bands).

All anchored IPDA math runs on **daily** data via `request.security`, on any chart timeframe.

---

### Suggested use

- **Quarterly Shift panel:** quick scan of multiple shift dates and IPDA extremes without cluttering the price pane.
- **Anchored IPDA:** tie ranges to a specific event (monthly open, structure break, news day) and read premium/discount vs equilibrium on price.

---

### Settings summary

| Group | Purpose |
|--------|---------|
| Quarterly Shift / IPDA Data Ranges | Enable, shift lines, 20/40/60, LTF toggles, colors, labels |
| ICT Anchored IPDA Ranges | Anchor, 20/40/60, premium/discount/forward colors, EQ, extensions |

---

### Notes

- Requires sufficient **daily history** (especially 60D lookback before the anchor).
- IPDA is a **framework/concept** from ICT education, not a guaranteed forecast.
- For educational and analytical use only—not financial advice.

---

**Tags (optional):** `ict`, `ipda`, `smart money`, `premium discount`, `equilibrium`, `quarterly shift`, `forward cast`, `anchored`, `daily range`

---

You can shorten the “Suggested use” and “Notes” blocks if TradingView limits character count. I can also provide a **short** (~500 character) blurb for the subtitle field if you want one.

## Source Code

````pine
//@version=6
indicator(title="Neo Quarterly Shift / IPDA Data Ranges", shorttitle="Neo QS IPDA", overlay=true, scale=scale.left, max_bars_back=500, max_lines_count=500, max_boxes_count=500)

// Drawn on its own left scale with fixed 0-100 coordinates, so the bands keep their
// vertical screen position when the price chart is zoomed or dragged.

const string G_QS = "Quarterly Shift / IPDA Data Ranges"

bool   qsEnable      = input.bool(true, "Enable", group=G_QS)
int    qsCount       = input.int(4, "Quarterly Shift lines", minval=1, maxval=12, group=G_QS)
int    qsStep        = input.int(3, "Months between shifts", minval=1, maxval=6, group=G_QS)

color  qsVColor      = input.color(color.new(color.gray, 0), "Shift line  ", group=G_QS, inline="qsv")
string qsVStyle      = input.string('⎯⎯⎯', '', options = ['⎯⎯⎯', '----', '····'], group=G_QS, inline="qsv")
int    qsVWidth      = input.int(1, '', options = [1,2,3,4], group=G_QS, inline="qsv")

bool   qsShow20      = input.bool(true, "20D", group=G_QS, inline="qsr")
color  qsColor20     = input.color(color.teal, "", group=G_QS, inline="qsr")
bool   qsShow40      = input.bool(true, "40D", group=G_QS, inline="qsr")
color  qsColor40     = input.color(color.orange, "", group=G_QS, inline="qsr")
bool   qsShow60      = input.bool(true, "60D", group=G_QS, inline="qsr")
color  qsColor60     = input.color(color.red, "", group=G_QS, inline="qsr")
string qsRStyle      = input.string('⎯⎯⎯', "Range lines ", options = ['⎯⎯⎯', '----', '····'], group=G_QS, inline="qss")
int    qsRWidth      = input.int(1, '', options = [1,2,3,4], group=G_QS, inline="qss")

bool   qsShowHigh    = input.bool(true, "High lines", group=G_QS, inline="qshl")
bool   qsShowLow     = input.bool(true, "Low lines", group=G_QS, inline="qshl")
bool   qsShowLabels  = input.bool(true, "Labels", group=G_QS, inline="qslb")
string qsLabelSize   = input.string(size.small, "", [size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group=G_QS, inline="qslb")

bool   qsShowM5      = input.bool(false, "5m", group=G_QS, inline="qsltf")
bool   qsShowM15     = input.bool(false, "15m", group=G_QS, inline="qsltf")
bool   qsShowH1      = input.bool(false, "1H", group=G_QS, inline="qsltf")

const float QS_TOP = 100.0
const float QS_GAP = 2.0

type QsRec
    int   t
    int   day
    float dayHigh
    float dayLow
    int   t20
    float h20
    float l20
    int   th20
    int   tl20
    int   t40
    float h40
    float l40
    int   th40
    int   tl40
    int   t60
    float h60
    float l60
    int   th60
    int   tl60
    int   bi
    int   fn
    int   fe20
    float fh20
    float fl20
    int   fth20
    int   ftl20
    int   fe40
    float fh40
    float fl40
    int   fth40
    int   ftl40
    int   fe60
    float fh60
    float fl60
    int   fth60
    int   ftl60

qsLineStyle(string style) =>
    switch style
        '⎯⎯⎯'  => line.style_solid
        '----' => line.style_dashed
        '····' => line.style_dotted
        => line.style_solid

qsMonthKey(int t) =>
    year(t, "UTC") * 12 + month(t, "UTC") - 1

qsDaily(int count, int step) =>
    var map<int, QsRec> recs = map.new<int, QsRec>()
    int key = qsMonthKey(time_tradingday)
    float h20 = ta.highest(high, 20)
    float l20 = ta.lowest(low, 20)
    float h40 = ta.highest(high, 40)
    float l40 = ta.lowest(low, 40)
    float h60 = ta.highest(high, 60)
    float l60 = ta.lowest(low, 60)
    int hb20 = ta.highestbars(high, 20)
    int lb20 = ta.lowestbars(low, 20)
    int hb40 = ta.highestbars(high, 40)
    int lb40 = ta.lowestbars(low, 40)
    int hb60 = ta.highestbars(high, 60)
    int lb60 = ta.lowestbars(low, 60)
    if bar_index > 0 and key != qsMonthKey(time_tradingday[1])
        QsRec rec = QsRec.new(time, time_tradingday, high, low, time[19], h20, l20, na, na, time[39], h40, l40, na, na, time[59], h60, l60, na, na)
        if not na(h20)
            rec.th20 := time[-hb20]
            rec.tl20 := time[-lb20]
        if not na(h40)
            rec.th40 := time[-hb40]
            rec.tl40 := time[-lb40]
        if not na(h60)
            rec.th60 := time[-hb60]
            rec.tl60 := time[-lb60]
        rec.bi := bar_index
        recs.put(key, rec)
    int nowKey = year(timenow, syminfo.timezone) * 12 + month(timenow, syminfo.timezone) - 1
    int refKey = recs.contains(nowKey - 1) ? nowKey - 1 : key - 1
    // Right-side ranges of the latest shift: shift day is bar 1, capped at the bars that exist so far.
    if recs.contains(refKey)
        QsRec rr = recs.get(refKey)
        int m = math.min(bar_index - rr.bi + 1, 60)
        rr.fn := m
        float hi = na
        float lo = na
        int thi = na
        int tlo = na
        for j = 0 to m - 1
            int off = bar_index - rr.bi - j
            if na(hi) or high[off] > hi
                hi := high[off]
                thi := time[off]
            if na(lo) or low[off] < lo
                lo := low[off]
                tlo := time[off]
            if j == math.min(20, m) - 1
                rr.fe20 := time[off], rr.fh20 := hi, rr.fl20 := lo, rr.fth20 := thi, rr.ftl20 := tlo
            if j == math.min(40, m) - 1
                rr.fe40 := time[off], rr.fh40 := hi, rr.fl40 := lo, rr.fth40 := thi, rr.ftl40 := tlo
            if j == m - 1
                rr.fe60 := time[off], rr.fh60 := hi, rr.fl60 := lo, rr.fth60 := thi, rr.ftl60 := tlo
    array<QsRec> out = array.new<QsRec>()
    for k = 0 to count - 1
        int mk = refKey - k * step
        if recs.contains(mk)
            out.push(recs.get(mk))
    out

array<QsRec> qsData = request.security(syminfo.tickerid, "D", qsDaily(qsCount, qsStep))

bool qsTfOk = timeframe.isdwm or (timeframe.isminutes and ((timeframe.multiplier == 5 and qsShowM5) or (timeframe.multiplier == 15 and qsShowM15) or (timeframe.multiplier == 60 and qsShowH1)))

// Transparent hlines pin the left scale to 0-100 so the bands keep fixed screen positions.
hline(0.0, "", color.new(color.white, 100), editable=false)
hline(QS_TOP, "", color.new(color.white, 100), editable=false)

var array<line> qsLines  = array.new<line>()
var array<box>  qsLabels = array.new<box>()

// row 1/2/3 = 20D/40D/60D. The outermost row (60D) sits one gap from the top/bottom edge; 20D is innermost.
qsDrawLevel(int x1, int x2, float price, int tExt, int row, bool isHigh, color col, string name) =>
    if not na(x1) and not na(price)
        float edgeDist = QS_GAP + (3 - row) * QS_GAP
        float y = isHigh ? QS_TOP - edgeDist : edgeDist
        float tickY = isHigh ? y - QS_GAP * 0.6 : y + QS_GAP * 0.6
        string lineStyle = qsLineStyle(qsRStyle)
        qsLines.push(line.new(x1, y, x2, y, xloc=xloc.bar_time, color=col, style=lineStyle, width=qsRWidth))
        if not na(tExt)
            qsLines.push(line.new(tExt, y, tExt, tickY, xloc=xloc.bar_time, color=col, style=lineStyle, width=qsRWidth))
        if qsShowLabels
            qsLabels.push(box.new(x1, isHigh ? y + QS_GAP * 0.4 : y, x2, isHigh ? y : y - QS_GAP * 0.4, border_color=color(na), border_width=0, xloc=xloc.bar_time, bgcolor=color(na), text=name, text_size=qsLabelSize, text_color=col, text_halign=text.align_left, text_valign=isHigh ? text.align_bottom : text.align_top))

qsDrawRange(int x1, int x2, float h, float l, int th, int tl, int row, color col, string name) =>
    if qsShowHigh
        qsDrawLevel(x1, x2, h, th, row, true, col, name)
    if qsShowLow
        qsDrawLevel(x1, x2, l, tl, row, false, col, name)

if barstate.islast
    for l in qsLines
        l.delete()
    for lb in qsLabels
        lb.delete()
    qsLines.clear()
    qsLabels.clear()
    if qsEnable and qsTfOk and not na(qsData) and qsData.size() > 0
        for r in qsData
            qsLines.push(line.new(r.t, 0.0, r.t, QS_TOP, xloc=xloc.bar_time, extend=extend.both, color=qsVColor, style=qsLineStyle(qsVStyle), width=qsVWidth))
            if qsShow20
                qsDrawRange(r.t20, r.t, r.h20, r.l20, r.th20, r.tl20, 1, qsColor20, "IPDA20")
            if qsShow40
                qsDrawRange(r.t40, r.t, r.h40, r.l40, r.th40, r.tl40, 2, qsColor40, "IPDA40")
            if qsShow60
                qsDrawRange(r.t60, r.t, r.h60, r.l60, r.th60, r.tl60, 3, qsColor60, "IPDA60")
        QsRec f = qsData.get(0)
        if not na(f.fn)
            if qsShow20
                qsDrawRange(f.t, f.fn >= 20 ? f.fe20 : time, f.fh20, f.fl20, f.fth20, f.ftl20, 1, qsColor20, "IPDA20")
            if qsShow40
                qsDrawRange(f.t, f.fn >= 40 ? f.fe40 : time, f.fh40, f.fl40, f.fth40, f.ftl40, 2, qsColor40, "IPDA40")
            if qsShow60
                qsDrawRange(f.t, f.fn >= 60 ? f.fe60 : time, f.fh60, f.fl60, f.fth60, f.ftl60, 3, qsColor60, "IPDA60")

// ICT Anchored IPDA — movable anchor; N daily bars on each side of anchor (anchor = shared edge, not in range).
const string G_AI = "ICT Anchored IPDA Ranges"

bool   aiEnable      = input.bool(true, "Enable", group=G_AI)
int    aiAnchorTime  = input.time(timestamp("2026-08-01T00:00:00"), "Anchor time", group=G_AI, confirm=true)
int    aiAnchorShift = input.int(0, "Anchor bar shift", minval=-500, maxval=500, group=G_AI)
bool   aiShow20      = input.bool(true, "20", group=G_AI, inline="ais")
bool   aiShow40      = input.bool(true, "40", group=G_AI, inline="ais")
bool   aiShow60      = input.bool(true, "60", group=G_AI, inline="ais")
color  aiPremColor   = input.color(color.new(#B39DDB, 72), "Premium", group=G_AI, inline="aiz")
color  aiDiscColor   = input.color(color.new(#81C784, 78), "Discount", group=G_AI, inline="aiz")
color  aiFcColor     = input.color(color.new(color.gray, 78), "Forward cast", group=G_AI)
color  aiAnchorColor = input.color(color.new(color.gray, 35), "Anchor line", group=G_AI, inline="aiv")
int    aiAnchorWidth = input.int(1, "", minval=1, maxval=4, group=G_AI, inline="aiv")
bool   aiShowEq      = input.bool(true, "Equilibrium", group=G_AI)
bool   aiExtendLv    = input.bool(true, "Extend lookback H/L/EQ", group=G_AI)
bool   aiShowLabels  = input.bool(true, "Labels", group=G_AI, inline="ail")
string aiLabelSize   = input.string(size.small, "", [size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group=G_AI, inline="ail")
int    aiLineWidth   = input.int(1, "Line width", minval=1, maxval=4, group=G_AI)

type AiWin
    float hi
    float lo
    int   x1
    int   x2

type AiData
    int   tA
    AiWin w20
    AiWin w40
    AiWin w60
    AiWin f20
    AiWin f40
    AiWin f60

aiAnchorOff(int anchorT, int shift) =>
    int off = na
    for i = 0 to math.min(bar_index, 499)
        if year(time_tradingday[i], "UTC") == year(anchorT, "UTC") and month(time_tradingday[i], "UTC") == month(anchorT, "UTC") and dayofmonth(time_tradingday[i], "UTC") == dayofmonth(anchorT, "UTC")
            off := i
            break
    if na(off)
        for i = 0 to math.min(bar_index, 499)
            if time[i] <= anchorT
                off := i
                break
    not na(off) ? math.max(0, off - shift) : na

// back=true: N daily bars before anchor [aOff+1..aOff+N]; back=false: N after anchor [aOff-1..aOff-N]
aiWindow(int aOff, int n, bool back) =>
    float hi = na
    float lo = na
    int x1 = na
    int x2 = na
    if back and aOff + n <= bar_index
        for i = 1 to n
            int b = aOff + i
            hi := na(hi) ? high[b] : math.max(hi, high[b])
            lo := na(lo) ? low[b] : math.min(lo, low[b])
        x1 := time[aOff + n]
        x2 := time[aOff]
    if not back and aOff > 0
        int m = math.min(n, aOff)
        for i = 1 to m
            int b = aOff - i
            hi := na(hi) ? high[b] : math.max(hi, high[b])
            lo := na(lo) ? low[b] : math.min(lo, low[b])
        x1 := time[aOff]
        int endOff = aOff - n
        x2 := endOff >= 0 ? time[endOff] : time + (time - time[1]) * (-endOff)
    AiWin.new(hi, lo, x1, x2)

aiBuild(int anchorT, int shift) =>
    AiData d = AiData.new(na, AiWin.new(na, na, na, na), AiWin.new(na, na, na, na), AiWin.new(na, na, na, na), AiWin.new(na, na, na, na), AiWin.new(na, na, na, na), AiWin.new(na, na, na, na))
    int a = aiAnchorOff(anchorT, shift)
    if not na(a) and a + 60 <= bar_index
        d.tA := time[a]
        d.w20 := aiWindow(a, 20, true)
        d.w40 := aiWindow(a, 40, true)
        d.w60 := aiWindow(a, 60, true)
        d.f20 := aiWindow(a, 20, false)
        d.f40 := aiWindow(a, 40, false)
        d.f60 := aiWindow(a, 60, false)
    d

AiData aiData = request.security(syminfo.tickerid, "D", aiBuild(aiAnchorTime, aiAnchorShift), lookahead=barmerge.lookahead_off)

var array<line>  aiLines = array.new<line>()
var array<box>   aiBoxes = array.new<box>()
var array<label> aiTags  = array.new<label>()

aiHline(int x1, int x2, float y, bool dotted) =>
    chart.point p1 = chart.point.new(x1, na, y)
    chart.point p2 = chart.point.new(x2, na, y)
    aiLines.push(line.new(p1, p2, xloc=xloc.bar_time, color=color.new(color.gray, 50), style=dotted ? line.style_dotted : line.style_solid, width=aiLineWidth, force_overlay=true))

aiDraw(AiWin w, bool back, string tag, int xExt, color prem, color disc, color fc) =>
    if not na(w.hi) and not na(w.x1) and not na(w.x2)
        float eq = (w.hi + w.lo) * 0.5
        color bdr = back ? color.new(color.gray, 65) : color(na)
        int bdrW = back ? 1 : 0
        aiBoxes.push(box.new(w.x1, w.hi, w.x2, eq, xloc=xloc.bar_time, border_color=bdr, border_width=bdrW, bgcolor=back ? prem : fc, force_overlay=true))
        aiBoxes.push(box.new(w.x1, eq, w.x2, w.lo, xloc=xloc.bar_time, border_color=bdr, border_width=bdrW, bgcolor=back ? disc : fc, force_overlay=true))
        if aiShowEq
            aiHline(w.x1, w.x2, eq, not back)
        if aiExtendLv and back and not na(xExt)
            aiHline(w.x2, xExt, w.hi, true)
            aiHline(w.x2, xExt, eq, true)
            aiHline(w.x2, xExt, w.lo, true)
        if aiShowLabels
            chart.point pt = chart.point.new(w.x1, na, w.lo)
            aiTags.push(label.new(pt, tag, xloc=xloc.bar_time, style=label.style_label_up, color=color(na), textcolor=color.new(color.gray, back ? 0 : 15), size=aiLabelSize, textalign=text.align_left, force_overlay=true))

if barstate.islast
    for ln in aiLines
        ln.delete()
    for bx in aiBoxes
        bx.delete()
    for tg in aiTags
        tg.delete()
    aiLines.clear()
    aiBoxes.clear()
    aiTags.clear()
    if aiEnable and not na(aiData.tA)
        AiWin top = aiShow60 ? aiData.w60 : aiShow40 ? aiData.w40 : aiData.w20
        if not na(top.hi)
            chart.point ap1 = chart.point.new(aiData.tA, na, top.hi)
            chart.point ap2 = chart.point.new(aiData.tA, na, top.lo)
            aiLines.push(line.new(ap1, ap2, xloc=xloc.bar_time, extend=extend.both, color=aiAnchorColor, style=line.style_solid, width=aiAnchorWidth, force_overlay=true))
        if aiShow60
            aiDraw(aiData.w60, true, "IPDA60", aiData.f60.x2, aiPremColor, aiDiscColor, aiFcColor)
            aiDraw(aiData.f60, false, "+60", na, aiPremColor, aiDiscColor, aiFcColor)
        if aiShow40
            aiDraw(aiData.w40, true, "IPDA40", aiData.f40.x2, aiPremColor, aiDiscColor, aiFcColor)
            aiDraw(aiData.f40, false, "+40", na, aiPremColor, aiDiscColor, aiFcColor)
        if aiShow20
            aiDraw(aiData.w20, true, "IPDA20", aiData.f20.x2, aiPremColor, aiDiscColor, aiFcColor)
            aiDraw(aiData.f20, false, "+20", na, aiPremColor, aiDiscColor, aiFcColor)
````
