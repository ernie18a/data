# Untouched Levels [Zen]

- url: https://www.tradingview.com/script/9cwR0ZIw-Untouched-Levels-Zen/
- type: indicator
- pine_id: PUB;9ec22a8ec34245249bad6ae9dfbaac72
- version: 1.0

## Description

Untouched Levels [Zen] marks the previous-day and previous-week highs and lows that price has not traded through yet, and shows them for up to 12 symbols in one table. Each level is judged only on closed candles of a confirmation timeframe (4H by default), so the table tells a level that was swept by a wick and closed back apart from a level that was broken by a close.

WHAT IT DOES
- Keeps a pool of untouched levels for each symbol: the high and low of every finished UTC day (PDH / PDL) and of every finished week (PWH / PWL, weeks start Monday 00:00 UTC). A level stays in the pool until price trades beyond it; it is not replaced when the next day or week starts.
- Levels expire after a set age: 20 days for daily levels and 8 weeks for weekly levels by default.
- For each symbol the table shows the nearest untouched level above and below price, the distance to each in %, the last event and its age.
- On the chart it draws the nearest untouched levels of the chart symbol.

HOW IT WORKS
A level is taken by the first confirmation candle whose wick goes beyond it: strictly above a high level or strictly below a low level, one tick is enough. That candle's close decides the state:
- SWEPT: the candle closed back on the level's side (at or below a high level, at or above a low level).
- BROKEN: the candle closed beyond the level.
A taken level leaves the pool, so it is not checked again later.
If one candle takes several levels, the table shows one event: weekly before daily, then SWEPT before BROKEN, then the farthest level on that side; if both sides are equal, the low side.
Age counts confirmation candles since the event; 0 means the last closed candle.
When a daily and a weekly level share the same price, the weekly name is shown.

HOW TO USE
- Use a chart timeframe at or below the confirmation timeframe (for 4H: 4H, 1H, 15m and so on). If the chart timeframe is higher, the table shows a notice and the lines and alerts are off.
- A highlighted row means a SWEPT event on one of the last closed candles (the last 2 by default). Those are the symbols to open and read on their own chart.
- BSL above and SSL below give the nearest untouched level on each side and how far away it is.
- Tip: the indicator's "More" menu has "Move tables to bottom panel". It puts the table under the chart so it never covers the candles.

TABLE
Columns: symbol, Close (of the last closed confirmation candle), BSL above (type and price), %, SSL below (type and price), %, Last event, Age. The header shows the confirmation timeframe and the UTC time of the last close. A symbol that returns no data shows "no data".

LINES
The nearest untouched levels of the chart symbol, up to 3 per side by default. Weekly levels are solid, daily levels are dashed, and the levels are labelled at the last bar. Levels closer to each other than 8% of the chart's price range (the drawn levels and the last 100 bars) keep their own lines but share one label, one row per level. Colours follow the chart theme, light or dark.

ALERTS
- "Any alert() function call": one message per confirmation close that lists every table symbol with a new event, for example "AAVE: PDH 155.48 SWEPT ↑ · close 153.58". An alert fires only for a close the script saw live, not at the moment the alert is created.
- Four conditions for the chart symbol: High level swept, Low level swept, High level broken, Low level broken.
Display settings (lines, table) never change detection or alerts.

INPUTS
Confirmation timeframe (4H), Keep daily levels in days (20), Keep weekly levels in weeks (8), Highlight a fresh SWEPT in candles (2), Show levels on the chart, Levels per side on the chart (3), Table position, Table text size, Alert on new events of all table coins, and 12 symbol slots, each with its own on/off box (defaults on Binance: BTC, ETH, SOL, XRP, ADA, AAVE, NEAR, ONDO, LINK, DOGE, AVAX, SUI).

NON-REPAINTING
Every value comes from the last closed confirmation candle. The state of a closed candle never changes, and the live candle is not judged until it closes.

LIMITS
- Days and weeks are counted in UTC. That fits 24/7 crypto markets; on markets with sessions the levels can differ from the exchange's own daily candles.
- History used: the longer keep window plus 14 days of confirmation candles.
- One data request per symbol plus one for the chart symbol, 13 in total with all slots on.
- The lines follow the chart symbol and the table rows follow their slots, so BTCUSDT and BTCUSDT.P are different symbols.
- Only the last event of each symbol is shown, and the level behind it has already left the pool.

WHAT IS ORIGINAL
Levels of past days and weeks stay in play until price actually takes them instead of being replaced every period. Each take is classified by the close of a confirmation candle, not by the current price, so a wick is never reported as a break and the state does not flicker inside a candle. The distance to the nearest untouched level on each side, the age of the last event and many symbols in one table turn this into a scan of where the untouched levels are and which of them were just swept.

This is an analysis tool, not a trading strategy: it gives no entries, targets or performance claims.

## Source Code

````pine
//@version=6
indicator("Untouched Levels [Zen]", overlay = true, max_lines_count = 50, max_labels_count = 50, behind_chart = false)

// Untouched Levels [Zen] — v1.0
// Previous-day and previous-week highs and lows that price has not traded through yet,
// for up to 12 symbols in one table, plus the chart symbol's levels as lines.
// A level is judged only on CLOSED candles of the confirmation timeframe:
// SWEPT = a wick went beyond it and the candle closed back; BROKEN = the candle closed beyond it.
// Every value comes from the last closed confirmation candle: [1] + lookahead_on (non-repainting).

// ============ Inputs ============
string confTf = input.timeframe("240", "Confirmation timeframe")
int    dKeep  = input.int(20, "Keep daily levels (days)", minval = 1, maxval = 60, display = display.none)
int    wKeep  = input.int(8, "Keep weekly levels (weeks)", minval = 1, maxval = 26, display = display.none)
int    hotN   = input.int(2, "Highlight a fresh SWEPT (candles)", minval = 0, maxval = 10, display = display.none)
bool   showLn = input.bool(true, "Show levels on the chart", display = display.none)
int    nLines = input.int(3, "Levels per side on the chart", minval = 1, maxval = 10, display = display.none)
string tPos   = input.string("Top right", "Table position", options = ["Top right", "Middle right", "Bottom right", "Bottom left", "Top left"], display = display.none)
string tSzIn  = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"], display = display.none)
bool   alAll  = input.bool(true, "Alert on new events of all table coins", tooltip = "Needs an alert with the 'Any alert() function call' condition. One message per confirmation close lists every coin with a new SWEPT or BROKEN event.", display = display.none)

bool   u1  = input.bool(true, "1",  inline = "s1", display = display.none)
string s1  = input.symbol("BINANCE:BTCUSDT",  "", inline = "s1", display = display.none)
bool   u2  = input.bool(true, "2",  inline = "s2", display = display.none)
string s2  = input.symbol("BINANCE:ETHUSDT",  "", inline = "s2", display = display.none)
bool   u3  = input.bool(true, "3",  inline = "s3", display = display.none)
string s3  = input.symbol("BINANCE:SOLUSDT",  "", inline = "s3", display = display.none)
bool   u4  = input.bool(true, "4",  inline = "s4", display = display.none)
string s4  = input.symbol("BINANCE:XRPUSDT",  "", inline = "s4", display = display.none)
bool   u5  = input.bool(true, "5",  inline = "s5", display = display.none)
string s5  = input.symbol("BINANCE:ADAUSDT",  "", inline = "s5", display = display.none)
bool   u6  = input.bool(true, "6",  inline = "s6", display = display.none)
string s6  = input.symbol("BINANCE:AAVEUSDT", "", inline = "s6", display = display.none)
bool   u7  = input.bool(true, "7",  inline = "s7", display = display.none)
string s7  = input.symbol("BINANCE:NEARUSDT", "", inline = "s7", display = display.none)
bool   u8  = input.bool(true, "8",  inline = "s8", display = display.none)
string s8  = input.symbol("BINANCE:ONDOUSDT", "", inline = "s8", display = display.none)
bool   u9  = input.bool(true, "9",  inline = "s9", display = display.none)
string s9  = input.symbol("BINANCE:LINKUSDT", "", inline = "s9", display = display.none)
bool   u10 = input.bool(true, "10", inline = "s10", display = display.none)
string s10 = input.symbol("BINANCE:DOGEUSDT", "", inline = "s10", display = display.none)
bool   u11 = input.bool(true, "11", inline = "s11", display = display.none)
string s11 = input.symbol("BINANCE:AVAXUSDT", "", inline = "s11", display = display.none)
bool   u12 = input.bool(true, "12", inline = "s12", display = display.none)
string s12 = input.symbol("BINANCE:SUIUSDT",  "", inline = "s12", display = display.none)

// ============ Colours: follow the chart theme ============
color bgC     = chart.bg_color
bool  isLight = (color.r(bgC) + color.g(bgC) + color.b(bgC)) / 3 > 128
color cAbove  = isLight ? #AD4A12 : #D9703A
color cBelow  = isLight ? #1B46B4 : #6F88EE
color cBroken = isLight ? #647482 : #8391A4
color cHot    = isLight ? #F0D3CB : color.new(#C98B78, 80)

// ============ One table row ============
type Row
    float above    // nearest untouched level above
    int   aTy      // 1 = daily, 2 = weekly
    float below    // nearest untouched level below
    int   bTy
    int   evTy     // last event: level type, 0 = no event yet
    int   evSt     // 1 = SWEPT, 2 = BROKEN
    int   evSide   // 1 = high level, 2 = low level
    float evPx
    int   age      // confirmation candles since the event, 0 = the last closed one
    float cl       // close of the last closed confirmation candle
    int   t        // open time of the last closed confirmation candle

// ============ Core: runs on the confirmation timeframe of each symbol ============
f_core(int _dKeep, int _wKeep) =>
    var array<float> hiPx = array.new<float>()
    var array<int>   hiTy = array.new<int>()
    var array<int>   hiT  = array.new<int>()
    var array<float> loPx = array.new<float>()
    var array<int>   loTy = array.new<int>()
    var array<int>   loT  = array.new<int>()
    var float dH = na
    var float dL = na
    var float wH = na
    var float wL = na
    var int   evTy   = 0
    var int   evSt   = 0
    var int   evSide = 0
    var float evPx   = na
    var int   evBar  = na

    // UTC day and week, whatever the exchange session. Weeks start Monday 00:00 UTC.
    int  dayId  = int(math.floor(time / 86400000))
    int  weekId = int(math.floor((time + 3 * 86400000) / 604800000))
    bool newD   = dayId != dayId[1]
    bool newW   = weekId != weekId[1]

    // 1. a new day / week turns the finished period's high and low into levels
    if newD and not na(dH)
        array.push(hiPx, dH)
        array.push(hiTy, 1)
        array.push(hiT, time)
        array.push(loPx, dL)
        array.push(loTy, 1)
        array.push(loT, time)
    if newW and not na(wH)
        array.push(hiPx, wH)
        array.push(hiTy, 2)
        array.push(hiT, time)
        array.push(loPx, wL)
        array.push(loTy, 2)
        array.push(loT, time)

    // 2. running high / low of the current day and week
    dH := newD or na(dH) ? high : math.max(dH, high)
    dL := newD or na(dL) ? low  : math.min(dL, low)
    wH := newW or na(wH) ? high : math.max(wH, high)
    wL := newW or na(wL) ? low  : math.min(wL, low)

    // 3. this candle takes levels; a taken level leaves the pool
    // Last event priority: weekly > daily, then SWEPT > BROKEN,
    // then the farthest level on a side; both sides equal -> the low side.
    int best = 0
    int nH = array.size(hiPx)
    if nH > 0
        for i = nH - 1 to 0
            float lv = array.get(hiPx, i)
            if high > lv
                int ty    = array.get(hiTy, i)
                int st    = close > lv ? 2 : 1
                int score = ty * 10 + (st == 1 ? 1 : 0)
                if score >= best
                    best   := score
                    evTy   := ty
                    evSt   := st
                    evSide := 1
                    evPx   := lv
                    evBar  := bar_index
                array.remove(hiPx, i)
                array.remove(hiTy, i)
                array.remove(hiT, i)
    int nL = array.size(loPx)
    if nL > 0
        for i = nL - 1 to 0
            float lv = array.get(loPx, i)
            if low < lv
                int ty    = array.get(loTy, i)
                int st    = close < lv ? 2 : 1
                int score = ty * 10 + (st == 1 ? 1 : 0)
                if score >= best
                    best   := score
                    evTy   := ty
                    evSt   := st
                    evSide := 2
                    evPx   := lv
                    evBar  := bar_index
                array.remove(loPx, i)
                array.remove(loTy, i)
                array.remove(loT, i)

    // 4. levels older than the keep window leave the pool
    int dMs = _dKeep * 86400000
    int wMs = _wKeep * 604800000
    nH := array.size(hiPx)
    if nH > 0
        for i = nH - 1 to 0
            int keepMs = array.get(hiTy, i) == 1 ? dMs : wMs
            if time - array.get(hiT, i) > keepMs
                array.remove(hiPx, i)
                array.remove(hiTy, i)
                array.remove(hiT, i)
    nL := array.size(loPx)
    if nL > 0
        for i = nL - 1 to 0
            int keepMs = array.get(loTy, i) == 1 ? dMs : wMs
            if time - array.get(loT, i) > keepMs
                array.remove(loPx, i)
                array.remove(loTy, i)
                array.remove(loT, i)

    // 5. nearest untouched level above and below; same price -> weekly wins
    float above = na
    int   aTy   = 0
    for [i, p] in hiPx
        int t = array.get(hiTy, i)
        if na(above) or p < above or (p == above and t > aTy)
            above := p
            aTy   := t
    float below = na
    int   bTy   = 0
    for [i, p] in loPx
        int t = array.get(loTy, i)
        if na(below) or p > below or (p == below and t > bTy)
            below := p
            bTy   := t
    int age = na(evBar) ? na : bar_index - evBar

    [above, aTy, below, bTy, evTy, evSt, evSide, evPx, age, close, hiPx, hiTy, hiT, loPx, loTy, loT]

// Values of the last CLOSED confirmation candle, packed into one object
f_pack() =>
    [ab, aT, be, bT, eT, eS, eD, eP, ag, cl, hP, hY, hT, lP, lY, lT] = f_core(dKeep, wKeep)
    Row.new(ab[1], aT[1], be[1], bT[1], eT[1], eS[1], eD[1], eP[1], ag[1], cl[1], time[1])

// Pools of the last CLOSED confirmation candle for the chart lines.
// A var array's [1] is the same mutated array, so copy it on every bar first.
f_levels() =>
    [ab, aT, be, bT, eT, eS, eD, eP, ag, cl, hP, hY, hT, lP, lY, lT] = f_core(dKeep, wKeep)
    array<float> hPc = array.copy(hP)
    array<int>   hYc = array.copy(hY)
    array<int>   hTc = array.copy(hT)
    array<float> lPc = array.copy(lP)
    array<int>   lYc = array.copy(lY)
    array<int>   lTc = array.copy(lT)
    [hPc[1], hYc[1], hTc[1], lPc[1], lYc[1], lTc[1], Row.new(ab[1], aT[1], be[1], bT[1], eT[1], eS[1], eD[1], eP[1], ag[1], cl[1], time[1])]

// History needed: the keep window + 14 days, so a partial first day / week expires
int calcN = int(math.ceil((math.max(dKeep, wKeep * 7) + 14) * 86400 / timeframe.in_seconds(confTf)))

// A switched-off or empty slot makes no request
f_req(bool _on, string _sym) =>
    Row r = na
    if _on and _sym != ""
        r := request.security(_sym, confTf, f_pack(), lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true, calc_bars_count = calcN)
    r

Row r1  = f_req(u1,  s1)
Row r2  = f_req(u2,  s2)
Row r3  = f_req(u3,  s3)
Row r4  = f_req(u4,  s4)
Row r5  = f_req(u5,  s5)
Row r6  = f_req(u6,  s6)
Row r7  = f_req(u7,  s7)
Row r8  = f_req(u8,  s8)
Row r9  = f_req(u9,  s9)
Row r10 = f_req(u10, s10)
Row r11 = f_req(u11, s11)
Row r12 = f_req(u12, s12)

// 13th request: the chart symbol itself (ticker.new keeps regular candles on Heikin Ashi charts)
string chartSym = ticker.new(syminfo.prefix, syminfo.ticker)
[lvHiP, lvHiY, lvHiT, lvLoP, lvLoY, lvLoT, rC] = request.security(chartSym, confTf, f_levels(), lookahead = barmerge.lookahead_on, calc_bars_count = calcN)

// ============ Table ============
bool   tfOK     = timeframe.in_seconds() <= timeframe.in_seconds(confTf)
string tfNm     = str.tostring(timeframe.in_seconds(confTf) / 3600, "#.#") + "H"
int    confOpen = time(confTf)

f_pos(string _s) =>
    switch _s
        "Middle right" => position.middle_right
        "Bottom right" => position.bottom_right
        "Bottom left"  => position.bottom_left
        "Top left"     => position.top_left
        => position.top_right

var table tb = table.new(f_pos(tPos), 8, 13, bgcolor = color.new(chart.bg_color, 5), border_width = 1)
string tSz = tSzIn == "Tiny" ? size.tiny : tSzIn == "Normal" ? size.normal : size.small

f_name(string _s) =>
    array<string> parts = str.split(_s, ":")
    string nm = array.size(parts) > 0 ? array.get(parts, array.size(parts) - 1) : _s
    str.replace_all(nm, "USDT", "")

f_px(float _v) =>
    na(_v) ? "—" : str.tostring(_v, _v >= 100 ? "#.##" : _v >= 1 ? "#.####" : "#.######")

f_lvl(int _ty, bool _isHigh) =>
    _ty == 1 ? (_isHigh ? "PDH" : "PDL") : _ty == 2 ? (_isHigh ? "PWH" : "PWL") : ""

f_cell(int _c, int _r, string _txt, color _fg, color _bg) =>
    table.cell(tb, _c, _r, _txt, text_color = _fg, bgcolor = _bg, text_size = tSz)

f_row(int _r, string _sym, Row _x) =>
    color fg = chart.fg_color
    bool noData = na(_x)
    if not noData
        noData := na(_x.cl)
    if noData
        f_cell(0, _r, f_name(_sym), fg, color(na))
        f_cell(1, _r, "no data", fg, color(na))
    else
        bool   hot   = _x.evTy != 0 and _x.evSt == 1 and not na(_x.age) and _x.age < hotN
        color  rowBg = hot ? cHot : color(na)
        string evTxt = _x.evTy == 0 ? "—" : f_lvl(_x.evTy, _x.evSide == 1) + " " + (_x.evSt == 1 ? "SWEPT" : "BROKEN") + (_x.evSide == 1 ? " ↑" : " ↓")
        color  evFg  = _x.evTy != 0 and _x.evSt == 2 ? cBroken : fg
        f_cell(0, _r, f_name(_sym), fg, rowBg)
        f_cell(1, _r, f_px(_x.cl), fg, rowBg)
        f_cell(2, _r, na(_x.above) ? "—" : f_lvl(_x.aTy, true) + " " + f_px(_x.above), cAbove, rowBg)
        f_cell(3, _r, na(_x.above) ? "" : str.tostring((_x.above - _x.cl) / _x.cl * 100, "#.##") + "%", cAbove, rowBg)
        f_cell(4, _r, na(_x.below) ? "—" : f_lvl(_x.bTy, false) + " " + f_px(_x.below), cBelow, rowBg)
        f_cell(5, _r, na(_x.below) ? "" : str.tostring((_x.cl - _x.below) / _x.cl * 100, "#.##") + "%", cBelow, rowBg)
        f_cell(6, _r, evTxt, evFg, rowBg)
        f_cell(7, _r, na(_x.age) or _x.evTy == 0 ? "" : str.tostring(_x.age), fg, rowBg)

// Draws a row only for a switched-on slot; returns the next free row
f_slot(int _r, bool _on, string _sym, Row _x) =>
    int r = _r
    if _on and _sym != ""
        f_row(r, _sym, _x)
        r += 1
    r

// ============ Lines: untouched levels of the chart symbol ============
// The price range the chart shows, roughly: the last 100 bars plus the drawn levels (lines widen the autoscale)
float hiBars = ta.highest(high, 100)
float loBars = ta.lowest(low, 100)
var int          firstT  = time    // first chart bar: a line never starts before it
var array<line>  lvLines = array.new<line>()
var array<label> lvLabs  = array.new<label>()

f_clearLines() =>
    for ln in lvLines
        line.delete(ln)
    for lb in lvLabs
        label.delete(lb)
    array.clear(lvLines)
    array.clear(lvLabs)

// Nearest nLines levels on one side; a daily and a weekly level at the same price are one line, named weekly.
// Draws the lines and hands back each line's price and label text, nearest first.
f_drawSide(array<float> _px, array<int> _ty, array<int> _t, bool _isHigh, color _c, array<float> _outPx, array<string> _outTx) =>
    int n = 0
    if not na(_px)
        n := array.size(_px)
    if n > 0
        array<int> idx = array.sort_indices(_px, _isHigh ? order.ascending : order.descending)
        int drawn = 0
        int k = 0
        while k < n and drawn < nLines
            int   i  = array.get(idx, k)
            float p  = array.get(_px, i)
            int   ty = array.get(_ty, i)
            int   t0 = array.get(_t, i)
            int   j  = k + 1
            while j < n
                int i2 = array.get(idx, j)
                if array.get(_px, i2) != p
                    break
                ty := math.max(ty, array.get(_ty, i2))
                t0 := math.min(t0, array.get(_t, i2))
                j += 1
            bool wk = ty == 2
            array.push(lvLines, line.new(math.max(t0, firstT), p, time, p, xloc = xloc.bar_time, extend = extend.right, color = _c, width = wk ? 2 : 1, style = wk ? line.style_solid : line.style_dashed))
            array.push(_outPx, p)
            array.push(_outTx, f_lvl(ty, _isHigh) + " " + f_px(p))
            drawn += 1
            k := j

// One label per group of neighbouring levels: a level closer than _tol to the group's first level joins the group.
// One row per level, higher price on top; the label sits on the group's highest level.
f_labelSide(array<float> _px, array<string> _tx, bool _isHigh, color _c, float _tol) =>
    int n = array.size(_px)
    if n > 0
        string gTxt  = ""
        float  gBase = na
        float  gTop  = na
        for i = 0 to n - 1
            float  p   = array.get(_px, i)
            string one = array.get(_tx, i)
            if not na(gBase) and math.abs(p - gBase) < _tol
                gTxt := _isHigh ? one + "\n" + gTxt : gTxt + "\n" + one
                gTop := math.max(gTop, p)
            else
                if not na(gBase)
                    array.push(lvLabs, label.new(bar_index, gTop, gTxt, xloc = xloc.bar_index, style = label.style_label_lower_right, color = color.new(_c, 100), textcolor = _c, size = size.small, textalign = text.align_right))
                gTxt  := one
                gBase := p
                gTop  := p
        array.push(lvLabs, label.new(bar_index, gTop, gTxt, xloc = xloc.bar_index, style = label.style_label_lower_right, color = color.new(_c, 100), textcolor = _c, size = size.small, textalign = text.align_right))

if barstate.islast
    f_clearLines()
    if showLn and tfOK
        array<float>  hPx = array.new<float>()
        array<string> hTx = array.new<string>()
        array<float>  lPx = array.new<float>()
        array<string> lTx = array.new<string>()
        f_drawSide(lvHiP, lvHiY, lvHiT, true, cAbove, hPx, hTx)
        f_drawSide(lvLoP, lvLoY, lvLoT, false, cBelow, lPx, lTx)
        // Labels of levels closer than 8% of the chart's price range would print over each other, so they are stacked
        float rngTop = nz(hiBars, high)
        float rngBot = nz(loBars, low)
        if array.size(hPx) > 0
            rngTop := math.max(rngTop, array.max(hPx))
        if array.size(lPx) > 0
            rngBot := math.min(rngBot, array.min(lPx))
        float lblTol = (rngTop - rngBot) * 0.08
        f_labelSide(hPx, hTx, true, cAbove, lblTol)
        f_labelSide(lPx, lTx, false, cBelow, lblTol)

if barstate.islast
    table.clear(tb, 0, 0, 7, 12)
    color hdBg = color.new(chart.fg_color, 85)
    if not tfOK
        f_cell(0, 0, "Confirmation timeframe must be at or above the chart timeframe", chart.fg_color, hdBg)
    else
        f_cell(0, 0, tfNm + " close · " + str.format_time(confOpen, "HH:mm", "UTC") + " UTC", chart.fg_color, hdBg)
        f_cell(1, 0, "Close", chart.fg_color, hdBg)
        f_cell(2, 0, "BSL above", chart.fg_color, hdBg)
        f_cell(3, 0, "%", chart.fg_color, hdBg)
        f_cell(4, 0, "SSL below", chart.fg_color, hdBg)
        f_cell(5, 0, "%", chart.fg_color, hdBg)
        f_cell(6, 0, "Last event", chart.fg_color, hdBg)
        f_cell(7, 0, "Age", chart.fg_color, hdBg)
        int rr = 1
        rr := f_slot(rr, u1,  s1,  r1)
        rr := f_slot(rr, u2,  s2,  r2)
        rr := f_slot(rr, u3,  s3,  r3)
        rr := f_slot(rr, u4,  s4,  r4)
        rr := f_slot(rr, u5,  s5,  r5)
        rr := f_slot(rr, u6,  s6,  r6)
        rr := f_slot(rr, u7,  s7,  r7)
        rr := f_slot(rr, u8,  s8,  r8)
        rr := f_slot(rr, u9,  s9,  r9)
        rr := f_slot(rr, u10, s10, r10)
        rr := f_slot(rr, u11, s11, r11)
        rr := f_slot(rr, u12, s12, r12)

// ============ Alerts (layer 2) ============
// A row has a new event when a new confirmation candle has closed for that symbol and its event is on that candle (age 0).
f_isNew(Row _x) =>
    int tt = na
    if not na(_x)
        tt := _x.t
    bool fresh = not na(tt) and tt != nz(tt[1], -1)
    bool ev = false
    if fresh
        ev := _x.evTy != 0 and _x.age == 0
    ev

bool n1  = f_isNew(r1)
bool n2  = f_isNew(r2)
bool n3  = f_isNew(r3)
bool n4  = f_isNew(r4)
bool n5  = f_isNew(r5)
bool n6  = f_isNew(r6)
bool n7  = f_isNew(r7)
bool n8  = f_isNew(r8)
bool n9  = f_isNew(r9)
bool n10 = f_isNew(r10)
bool n11 = f_isNew(r11)
bool n12 = f_isNew(r12)
bool nC  = f_isNew(rC)

// Live gate: the previous chart bar was also real-time, so a new confirmation close was seen live, not at start-up
bool rtNow  = barstate.isrealtime
bool liveOK = rtNow and rtNow[1]

f_msg(string _m, bool _on, string _sym, bool _new, Row _x) =>
    string m = _m
    if _on and _sym != "" and _new
        m := m + (m == "" ? "" : "\n") + f_name(_sym) + ": " + f_lvl(_x.evTy, _x.evSide == 1) + " " + f_px(_x.evPx) + (_x.evSt == 1 ? " SWEPT" : " BROKEN") + (_x.evSide == 1 ? " ↑" : " ↓") + " · close " + f_px(_x.cl)
    m

string msg = ""
msg := f_msg(msg, u1,  s1,  n1,  r1)
msg := f_msg(msg, u2,  s2,  n2,  r2)
msg := f_msg(msg, u3,  s3,  n3,  r3)
msg := f_msg(msg, u4,  s4,  n4,  r4)
msg := f_msg(msg, u5,  s5,  n5,  r5)
msg := f_msg(msg, u6,  s6,  n6,  r6)
msg := f_msg(msg, u7,  s7,  n7,  r7)
msg := f_msg(msg, u8,  s8,  n8,  r8)
msg := f_msg(msg, u9,  s9,  n9,  r9)
msg := f_msg(msg, u10, s10, n10, r10)
msg := f_msg(msg, u11, s11, n11, r11)
msg := f_msg(msg, u12, s12, n12, r12)

if alAll and tfOK and liveOK and msg != ""
    alert("Untouched Levels · " + tfNm + " close\n" + msg, alert.freq_once_per_bar)

// Chart symbol: 4 fixed conditions for the alert dropdown
bool cNew  = tfOK and liveOK and nC
int  cSide = 0
int  cSt   = 0
if cNew
    cSide := rC.evSide
    cSt   := rC.evSt
alertcondition(cNew and cSide == 1 and cSt == 1, "High level swept", "{{ticker}}: a previous-day/week high was swept (wick above, confirmation candle closed back below)")
alertcondition(cNew and cSide == 2 and cSt == 1, "Low level swept",  "{{ticker}}: a previous-day/week low was swept (wick below, confirmation candle closed back above)")
alertcondition(cNew and cSide == 1 and cSt == 2, "High level broken", "{{ticker}}: a previous-day/week high was broken (confirmation candle closed above)")
alertcondition(cNew and cSide == 2 and cSt == 2, "Low level broken",  "{{ticker}}: a previous-day/week low was broken (confirmation candle closed below)")
````
