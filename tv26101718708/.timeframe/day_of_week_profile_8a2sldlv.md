# Day of Week Profile

- url: https://www.tradingview.com/script/8a2sLdLv-Day-of-Week-Profile/
- type: indicator
- pine_id: PUB;574c08cbf0944fc59fe32c8fc52522aa
- version: 1.0

## Description

its a indicator inspired by luxalgo first iteration im just going to keep releasing shi because this is like github to me now and these indicators are vibe coded so yeah. All for educational purposes i just want to help traders visualise this is where i say Michael J Huddleston is the goat

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unclehk2000
//
// Day of Week Profile
// Right: one column per weekday — each day's range (or net move) as a % of the daily open, with an IQR box, median
// and 10–90 whisker, an all-days column as the yardstick, and today's live value placed in its weekday's distribution.
// Middle: an hour-of-day profile of when the trading day's high and low were set (ET).
// Left: month-of-year seasonality — each month's close-to-close move (or range) as a % of the prior month's close,
// with futures roll gaps removed, and the current month-to-date placed in its month's distribution.
// Dashboard: daily ATR, today's range and net move, and whether each is above, below or on the median of the same
// weekday at the same time of day — "on it" meaning inside the uncertainty band of that median.
// Full trading day only (18:00–17:00 ET). Built for CME index futures on continuous charts (NQ1!, ES1!, RTY1!).
//
// Column layout inspired by "Day Of Week Price Distribution" by LuxAlgo (CC BY-NC-SA 4.0).
// Written from scratch; no LuxAlgo code is used.

indicator("Day of Week Profile", "DoW Profile", overlay = false, max_labels_count = 500, max_boxes_count = 120, max_lines_count = 80)

TZ = "America/New_York"

// ─────────────────────────────────────────── Inputs
showWhat = input.string("Weekdays, hours and months", "Show", options = ["Weekdays, hours and months", "Weekdays and hours", "Months only"])

gH = "Day of week"
nWk     = input.int(20, "Days per weekday", minval = 5, maxval = 40, group = gH, tooltip = "How many of each weekday to sample: 20 = the last 20 Mondays, the last 20 Tuesdays and so on. Taken from daily bars, so it works on any chart timeframe.")
metric  = input.string("Range %", "Measure", options = ["Range %", "Net move %"], group = gH, tooltip = "Range % = (high − low) / open. Net move % = (close − open) / open. Both use the full trading day.")
showAll = input.bool(true, "All-days column", group = gH)
showDot = input.bool(true, "Each day as a dot", group = gH, tooltip = "Green = the day closed up, red = down. Older days fade.")

gT = "Hour of high / low"
showHr  = input.bool(true, "Hour-of-day profile", group = gT)
hrFor   = input.string("Today's weekday", "Profile", options = ["Today's weekday", "All weekdays"], group = gT)
hrN     = input.int(30, "Days in profile", minval = 10, maxval = 120, group = gT, tooltip = "Taken from 60-minute bars. Also the sample for the dashboard's 'by now' rows. How far back it reaches depends on your plan's bar history.")
colHi   = input.color(#f23645, "Hour of the high", group = gT)
colLo   = input.color(#089981, "Hour of the low", group = gT)

gM = "Month of year"
monYrs  = input.int(16, "Years per month", minval = 5, maxval = 20, group = gM, tooltip = "How many of each calendar month to sample: 16 = the last 16 completed Januaries, Februaries and so on. Use a continuous contract (NQ1!) so the history is long enough.")
monMet  = input.string("Net move %", "Measure", options = ["Net move %", "Range %"], group = gM, tooltip = "Net move % = month close − prior month close, as a % of the prior month close. Range % = month high − low over the same base. Points come from the back-adjusted series so contract rolls don't add a gap; the base comes from the unadjusted series so the % is true to the price level at the time.")
monPP   = input.float(0.5, "Strong / weak when median is ± pp vs all months", step = 0.1, group = gM)
showMd  = input.bool(true, "Each year as a dot", group = gM)
mGap    = input.int(10, "Month spacing (bars)", minval = 5, maxval = 40, group = gM)

gD = "Dashboard"
showDash = input.bool(true, "Dashboard", group = gD)
dashOn   = input.string("Price chart", "Show on", options = ["Price chart", "Indicator pane"], group = gD)
dashPos  = input.string("Top right", "Position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = gD)
dashSzI  = input.string("Small", "Size", options = ["Tiny", "Small", "Normal"], group = gD)
atrLen   = input.int(14, "ATR length (days)", minval = 2, maxval = 100, group = gD, tooltip = "Daily ATR from completed days, back-adjusted so a contract roll doesn't count as a true range.")
bandCI   = input.string("80%", "Neutral band", options = ["68%", "80%", "90%", "95%"], group = gD, tooltip = "Today is 'Neutral' when it sits inside this confidence band around the median of the same weekday at the same time of day. The band is the uncertainty of the median itself, so it narrows as the sample grows. Wider band = more days read Neutral.")
colNeu   = input.color(#d1d4dc, "Neutral", group = gD)

gC = "Colours"
wideX   = input.float(1.05, "Wide when median ≥ × all", step = 0.01, group = gC)
narX    = input.float(0.95, "Narrow when median ≤ × all", step = 0.01, group = gC)
colWide = input.color(#ff6d00, "Wide / above", group = gC)
colNar  = input.color(#00acc1, "Narrow / below", group = gC)
colNorm = input.color(#787b86, "Typical", group = gC)
colAll  = input.color(#b2b5be, "All days", group = gC)
colUp   = input.color(#089981, "Up / strong", group = gC)
colDn   = input.color(#f23645, "Down / weak", group = gC)
colNow  = input.color(#ffb300, "Today / this month", group = gC)

gL = "Layout"
gap     = input.int(14, "Weekday spacing (bars)", minval = 6, maxval = 60, group = gL)
hrW     = input.int(5, "Hour width (bars)", minval = 3, maxval = 12, group = gL)
txtSz   = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gL)
sz  = txtSz == "Tiny" ? size.tiny : txtSz == "Small" ? size.small : size.normal
dSz = dashSzI == "Tiny" ? size.tiny : dashSzI == "Small" ? size.small : size.normal
zCI = bandCI == "68%" ? 1.0 : bandCI == "80%" ? 1.2816 : bandCI == "90%" ? 1.6449 : 1.96

// ─────────────────────────────────────────── History requests (completed periods only)
tkU = ticker.modify(syminfo.tickerid, backadjustment = backadjustment.off)
tkA = ticker.modify(syminfo.tickerid, backadjustment = backadjustment.on)

// Daily context: pushes the previous day's figures on every daily bar, so today is never in the sample.
dayHist(int keep) =>
    var array<float> rg = array.new<float>()
    var array<float> nt = array.new<float>()
    var array<float> pt = array.new<float>()
    var array<int>   dw = array.new<int>()
    var array<int>   tt = array.new<int>()
    if bar_index > 0 and open[1] > 0
        rg.push(100.0 * (high[1] - low[1]) / open[1])
        nt.push(100.0 * (close[1] - open[1]) / open[1])
        pt.push(high[1] - low[1])
        dw.push(dayofweek(time_tradingday[1], "UTC"))
        tt.push(time_tradingday[1])
        if rg.size() > keep
            rg.shift()
            nt.shift()
            pt.shift()
            dw.shift()
            tt.shift()
    [rg, nt, pt, dw, tt]

// 60-minute context. Per completed day: the ET hour of the high and of the low, plus the running range and net move
// at the end of each hour slot (18:00 … 16:00). Returns the hour-of-high/low history, and, for the current day's
// weekday, every past day's running range / net at this hour slot and the slot before (the chart interpolates by minute).
hourHist(int keep, int want) =>
    var array<int>   hi = array.new<int>()
    var array<int>   lo = array.new<int>()
    var array<int>   dw = array.new<int>()
    var array<float> cR = array.new<float>()
    var array<float> cN = array.new<float>()
    var array<float> dR = array.new<float>(23, na)
    var array<float> dN = array.new<float>(23, na)
    var array<float> r0 = array.new<float>()
    var array<float> r1 = array.new<float>()
    var array<float> n0 = array.new<float>()
    var array<float> n1 = array.new<float>()
    var float dO   = na
    var float dH   = na
    var float dL   = na
    var int   hH   = 0
    var int   hL   = 0
    var int   dd   = 0
    var int   seen = 0
    bool nd   = bar_index == 0 or time_tradingday != time_tradingday[1]
    int  hNow = hour(time, "America/New_York")
    int  slot = (hNow - 18 + 24) % 24
    if nd
        if seen > 1
            hi.push(hH)
            lo.push(hL)
            dw.push(dd)
            float lr = 0.0
            float ln = 0.0
            for j = 0 to 22
                if not na(dR.get(j))
                    lr := dR.get(j)
                    ln := dN.get(j)
                cR.push(lr)
                cN.push(ln)
            if dw.size() > keep + 50
                hi := hi.slice(50, hi.size()).copy()
                lo := lo.slice(50, lo.size()).copy()
                dw := dw.slice(50, dw.size()).copy()
                cR := cR.slice(50 * 23, cR.size()).copy()
                cN := cN.slice(50 * 23, cN.size()).copy()
        seen += 1
        dO := open
        dH := high
        dL := low
        hH := hNow
        hL := hNow
        dd := dayofweek(time_tradingday, "UTC")
        dR.fill(na)
        dN.fill(na)
    else
        if high > dH
            dH := high
            hH := hNow
        if low < dL
            dL := low
            hL := hNow
    if slot <= 22 and dO > 0
        dR.set(slot, 100.0 * (dH - dL) / dO)
        dN.set(slot, 100.0 * (close - dO) / dO)
    r0.clear()
    r1.clear()
    n0.clear()
    n1.clear()
    int nD = dw.size()
    if slot <= 22 and nD > 0
        for i = nD - 1 to 0
            if dw.get(i) == dd
                int b = i * 23
                r1.unshift(cR.get(b + slot))
                n1.unshift(cN.get(b + slot))
                r0.unshift(slot > 0 ? cR.get(b + slot - 1) : 0.0)
                n0.unshift(slot > 0 ? cN.get(b + slot - 1) : 0.0)
                if r1.size() >= want
                    break
    [hi, lo, dw, r0, r1, n0, n1]

// Monthly contexts. Each completed month is keyed by its mid-point time (same in both series).
// Unadjusted: the level the month started from (prior month close).
monBase(int keep) =>
    var array<int>   mk = array.new<int>()
    var array<float> mb = array.new<float>()
    if bar_index > 1
        mk.push(int((time[1] + time_close[1]) / 2))
        mb.push(close[2])
        if mk.size() > keep
            mk.shift()
            mb.shift()
    [mk, mb, close[1]]

// Back-adjusted: the month's move and range in points with roll gaps removed.
monMove(int keep) =>
    var array<int>   mk = array.new<int>()
    var array<float> mp = array.new<float>()
    var array<float> mr = array.new<float>()
    if bar_index > 1
        mk.push(int((time[1] + time_close[1]) / 2))
        mp.push(close[1] - close[2])
        mr.push(high[1] - low[1])
        if mk.size() > keep
            mk.shift()
            mp.shift()
            mr.shift()
    [mk, mp, mr, close - close[1], high - low]

[dRg, dNt, dPt, dDw, dTt]          = request.security(tkU, "D", dayHist(nWk * 5 + 40), lookahead = barmerge.lookahead_on)
[hHi, hLo, hDw, tR0, tR1, tN0, tN1] = request.security(tkU, "60", hourHist(hrN * 5 + 40, hrN), lookahead = barmerge.lookahead_on)
[uK, uB, uCurB]                    = request.security(tkU, "M", monBase(monYrs * 12 + 24), lookahead = barmerge.lookahead_on)
[aK, aP, aR, aCurP, aCurR]         = request.security(tkA, "M", monMove(monYrs * 12 + 24), lookahead = barmerge.lookahead_on)
atrD                               = request.security(tkA, "D", ta.atr(atrLen)[1], lookahead = barmerge.lookahead_on)

// ─────────────────────────────────────────── Today, live from the chart
var float tO   = na
var float tHi  = na
var float tLo  = na
var int   tHhr = na
var int   tLhr = na
bool newTd = ta.change(time_tradingday) != 0
if newTd or na(tO)
    tO   := open
    tHi  := high
    tLo  := low
    tHhr := hour(time, TZ)
    tLhr := tHhr
else
    if high > tHi
        tHi  := high
        tHhr := hour(time, TZ)
    if low < tLo
        tLo  := low
        tLhr := hour(time, TZ)

int   tDow  = dayofweek(time_tradingday, "UTC")
int   curMo = month(time_tradingday, "UTC")
bool  isWk  = tDow >= 2 and tDow <= 6
float tRng  = 100.0 * (tHi - tLo) / tO
float tNet  = 100.0 * (close - tO) / tO

// ─────────────────────────────────────────── Helpers
var array<label> pL = array.new<label>()
var array<box>   pB = array.new<box>()
var array<line>  pN = array.new<line>()

dPos = dashPos == "Top right" ? position.top_right : dashPos == "Bottom right" ? position.bottom_right : dashPos == "Top left" ? position.top_left : position.bottom_left
var table dashP = table.new(dPos, 3, 10, bgcolor = color.new(#131722, 5), frame_color = #363a45, frame_width = 1, border_color = #2a2e39, border_width = 1, force_overlay = true)
var table dashI = table.new(dPos, 3, 10, bgcolor = color.new(#131722, 5), frame_color = #363a45, frame_width = 1, border_color = #2a2e39, border_width = 1, force_overlay = false)
if barstate.isfirst
    dashP.merge_cells(0, 0, 2, 0)
    dashP.merge_cells(0, 9, 2, 9)
    dashI.merge_cells(0, 0, 2, 0)
    dashI.merge_cells(0, 9, 2, 9)

wipe() =>
    for l in pL
        l.delete()
    for b in pB
        b.delete()
    for n in pN
        n.delete()
    pL.clear()
    pB.clear()
    pN.clear()

// Indices (oldest → newest) of the last `want` days on weekday `wd` (0 = any weekday).
idxFor(array<int> dws, int wd, int want) =>
    array<int> out = array.new<int>()
    int n = 0
    if not na(dws)
        n := dws.size()
    if n > 0
        for i = n - 1 to 0
            int d = dws.get(i)
            if (wd == 0 and d >= 2 and d <= 6) or d == wd
                out.unshift(i)
                if out.size() >= want
                    break
    out

// Indices (oldest → newest) of the last `want` completed months that are calendar month `m`.
moIdx(array<int> mids, int m, int want) =>
    array<int> out = array.new<int>()
    int n = mids.size()
    if n > 0
        for i = n - 1 to 0
            if month(mids.get(i), "UTC") == m
                out.unshift(i)
                if out.size() >= want
                    break
    out

valsAt(array<float> src, array<int> idx) =>
    array<float> out = array.new<float>()
    for i in idx
        out.push(src.get(i))
    out

lastN(array<float> src, int k) =>
    array<float> out = array.new<float>()
    int n = src.size()
    if n > 0
        for i = math.max(0, n - k) to n - 1
            out.push(src.get(i))
    out

rankOf(array<float> a, float x) =>
    float r = na
    int n = a.size()
    if n > 0 and not na(x)
        int c = 0
        for v in a
            if v <= x
                c += 1
        r := 100.0 * c / n
    r

// Median and its distribution-free confidence band (order statistics n/2 ± z·√n/2).
medBand(array<float> a, float z) =>
    float m  = na
    float lo = na
    float hi = na
    int n = a.size()
    if n >= 3
        array<float> s = a.copy()
        s.sort(order.ascending)
        m := s.median()
        int r1 = math.max(0, math.floor(n / 2.0 - z * math.sqrt(n) / 2.0))
        int r2 = math.min(n - 1, math.ceil(n / 2.0 + z * math.sqrt(n) / 2.0) - 1)
        lo := s.get(r1)
        hi := s.get(math.max(r1, r2))
    [m, lo, hi]

stTxt(float x, float lo, float hi) => na(x) or na(lo) ? "" : x > hi ? "Above" : x < lo ? "Below" : "Neutral"
stCol(string s, color up, color dn) => s == "Above" ? color.new(up, 15) : s == "Below" ? color.new(dn, 15) : s == "Neutral" ? colNeu : #00000000

dRow(table t, int r, string a, string b, string s, color bg, string tip) =>
    t.cell(0, r, a, text_color = #b2b5be, text_size = dSz, text_halign = text.align_left)
    t.cell(1, r, b, text_color = #e0e3eb, text_size = dSz, text_halign = text.align_left)
    t.cell(2, r, s, text_color = s == "Neutral" ? #131722 : #ffffff, text_size = dSz, text_halign = text.align_center, bgcolor = bg, tooltip = tip)

mapY(float v, float a0, float a1, float b0, float b1) => a1 > a0 ? b0 + (v - a0) / (a1 - a0) * (b1 - b0) : b0

f2(float x) => str.tostring(x, "0.00")
sgn(float x) => (x >= 0 ? "+" : "") + str.tostring(x, "0.00")
sgn0(float x) => (x >= 0 ? "+" : "") + str.tostring(x, "0")
dayName(int d) => d == 2 ? "Mon" : d == 3 ? "Tue" : d == 4 ? "Wed" : d == 5 ? "Thu" : d == 6 ? "Fri" : d == 7 ? "Sat" : "Sun"
moName(int m) => m == 1 ? "Jan" : m == 2 ? "Feb" : m == 3 ? "Mar" : m == 4 ? "Apr" : m == 5 ? "May" : m == 6 ? "Jun" : m == 7 ? "Jul" : m == 8 ? "Aug" : m == 9 ? "Sep" : m == 10 ? "Oct" : m == 11 ? "Nov" : "Dec"

// ─────────────────────────────────────────── Draw (last bar only)
if barstate.islast
    wipe()
    string stamp  = str.format_time(time, "HH:mm MM/dd", TZ)
    bool   hasMo  = not na(aK) and not na(uK)
    bool   showWk = showWhat != "Months only" and not na(dRg)
    bool   showMo = showWhat != "Weekdays and hours" and hasMo
    bool   isR    = metric == "Range %"
    bool   mR     = monMet == "Range %"

    // layout, right to left: weekdays | hours | months
    int nCol = showAll ? 6 : 5
    int w    = math.max(1, math.floor(gap / 4))
    int hb   = math.max(1, math.floor((hrW - 1) / 2))
    int mw   = math.max(1, math.floor(mGap / 4))
    int xR   = bar_index - w - 2
    int xL   = xR - (nCol - 1) * gap
    int x0   = xL - w - gap - 23 * hrW + 1
    int xMr  = showWk ? (showHr ? x0 - gap : xL - w - gap) : bar_index - 2
    int xM0  = xMr - mw - 11 * mGap

    // ── month values (roll-free points over the unadjusted base)
    array<int>   jK   = array.new<int>()
    array<float> jNet = array.new<float>()
    array<float> jRng = array.new<float>()
    array<float> jPts = array.new<float>()
    if hasMo
        int nA = aK.size()
        if nA > 0
            for i = 0 to nA - 1
                int k = uK.indexof(aK.get(i))
                if k >= 0
                    float base = uB.get(k)
                    if base > 0
                        jK.push(aK.get(i))
                        jNet.push(100.0 * aP.get(i) / base)
                        jRng.push(100.0 * aR.get(i) / base)
                        jPts.push(aP.get(i))

    // ── weekday values and the y band
    array<float> src  = isR ? dRg : dNt
    float tVal   = isR ? tRng : tNet
    array<float> allV = array.new<float>()
    float medAll = na
    float yLo = na
    float yHi = na
    if showWk
        allV := valsAt(src, idxFor(dDw, 0, nWk * 5))
        medAll := allV.size() > 0 ? allV.median() : na
        for c = 0 to nCol - 1
            int wd = c < 5 ? c + 2 : 0
            array<float> v = valsAt(src, idxFor(dDw, wd, wd == 0 ? nWk * 5 : nWk))
            if v.size() >= 3
                float lo = showDot and wd != 0 ? v.min() : v.percentile_linear_interpolation(10)
                float hi = showDot and wd != 0 ? v.max() : v.percentile_linear_interpolation(90)
                yLo := na(yLo) ? lo : math.min(yLo, lo)
                yHi := na(yHi) ? hi : math.max(yHi, hi)
        if isWk and not na(tVal) and not na(yLo)
            yLo := math.min(yLo, tVal)
            yHi := math.max(yHi, tVal)

    // ── month extents
    float moNow = na
    float mLo   = na
    float mHi   = na
    if showMo
        if uCurB > 0
            moNow := 100.0 * (mR ? aCurR : aCurP) / uCurB
        array<float> mSrc0 = mR ? jRng : jNet
        for m = 1 to 12
            array<float> v = valsAt(mSrc0, moIdx(jK, m, monYrs))
            if v.size() >= 3
                float lo = showMd ? v.min() : v.percentile_linear_interpolation(10)
                float hi = showMd ? v.max() : v.percentile_linear_interpolation(90)
                mLo := na(mLo) ? lo : math.min(mLo, lo)
                mHi := na(mHi) ? hi : math.max(mHi, hi)
        if not na(moNow) and not na(mLo)
            mLo := math.min(mLo, moNow)
            mHi := math.max(mHi, moNow)
        if not mR and not na(mLo)
            mLo := math.min(mLo, 0.0)
            mHi := math.max(mHi, 0.0)
        if not showWk
            yLo := mLo
            yHi := mHi

    if not na(yLo) and yHi > yLo
        float pad = 0.06 * (yHi - yLo)

        // ══════════ weekday columns
        if showWk
            int   todayX = na
            float rkW    = na
            float medW   = na
            int   nW     = 0
            for c = 0 to nCol - 1
                int wd = c < 5 ? c + 2 : 0
                array<int> ix = idxFor(dDw, wd, wd == 0 ? nWk * 5 : nWk)
                array<float> v = valsAt(src, ix)
                int n = v.size()
                if n >= 3
                    int   xc   = xL + c * gap
                    float med  = v.median()
                    float q1   = v.percentile_linear_interpolation(25)
                    float q3   = v.percentile_linear_interpolation(75)
                    float p10  = v.percentile_linear_interpolation(10)
                    float p90  = v.percentile_linear_interpolation(90)
                    float mult = isR and medAll > 0 ? med / medAll : na
                    bool  isT  = isWk and wd == tDow
                    color cc   = wd == 0 ? colAll : not isR ? colNorm : mult >= wideX ? colWide : mult <= narX ? colNar : colNorm

                    pN.push(line.new(xc, p10, xc, p90, color = color.new(cc, 40), width = 1))
                    pB.push(box.new(xc - w, q3, xc + w, q1, border_color = isT ? colNow : cc, border_width = isT ? 2 : 1, bgcolor = color.new(cc, 80)))
                    pN.push(line.new(xc - w - 1, med, xc + w + 1, med, color = cc, width = 3))

                    int ups = 0
                    for j = 0 to n - 1
                        int i = ix.get(j)
                        if dNt.get(i) > 0
                            ups += 1
                        if showDot and wd != 0
                            int   tr  = int(75.0 * (n - 1 - j) / math.max(1, n - 1))
                            color dc  = color.new(dNt.get(i) >= 0 ? colUp : colDn, tr)
                            string tip = str.format_time(dTt.get(i), "EEE MM/dd/yy", "UTC") + "\nrange " + f2(dRg.get(i)) + "% (" + str.tostring(dPt.get(i), "0") + " pts)\nnet " + sgn(dNt.get(i)) + "%"
                            pL.push(label.new(xc - w + (j % (2 * w + 1)), v.get(j), "•", color = #00000000, style = label.style_label_center, textcolor = dc, size = sz, tooltip = tip))

                    string nm = wd == 0 ? "All" : dayName(wd)
                    string st = isR ? nm + "\n" + f2(med) + "%" + (wd == 0 ? "" : "\n×" + str.tostring(mult, "0.00")) + "\nn " + str.tostring(n) : nm + "\nup " + str.tostring(100.0 * ups / n, "0") + "%\nmed " + sgn(med) + "%\nn " + str.tostring(n)
                    pL.push(label.new(xc, yLo - pad, st, color = #00000000, style = label.style_label_up, textcolor = isT ? colNow : cc, size = sz))

                    if isT and not na(tVal)
                        todayX := xc
                        rkW    := rankOf(v, tVal)
                        medW   := med
                        nW     := n
                        pL.push(label.new(xc, tVal, "◆", color = #00000000, style = label.style_label_center, textcolor = colNow, size = sz))

            string what = isR ? "range" : "net move"
            pL.push(label.new(xL - w, yHi + pad, "Day of week · " + what + " as % of the daily open · last " + str.tostring(nWk) + " of each", color = #00000000, style = label.style_label_lower_left, textcolor = chart.fg_color, size = sz))

            if not na(todayX)
                int xEnd = xR + w + 2
                pN.push(line.new(todayX, tVal, xEnd, tVal, color = colNow, style = line.style_dotted, width = 1))
                float rkA  = rankOf(allV, tVal)
                string dn  = dayName(tDow)
                string txt = isR ? "Today " + dn + " · " + f2(tRng) + "% (" + str.tostring(tHi - tLo, "0") + " pts)\nP" + str.tostring(rkW, "0") + " of " + str.tostring(nW) + " " + dn + " · P" + str.tostring(rkA, "0") + " of all days\n" + dn + " median " + f2(medW) + "% ≈ " + str.tostring(medW / 100.0 * tO, "0") + " pts · " + stamp : "Today " + dn + " · " + sgn(tNet) + "%\nP" + str.tostring(rkW, "0") + " of " + str.tostring(nW) + " " + dn + " · P" + str.tostring(rkA, "0") + " of all days · " + stamp
                pL.push(label.new(xEnd, tVal, txt, color = #00000000, style = label.style_label_left, textcolor = colNow, size = sz, textalign = text.align_left))

        // ══════════ hour-of-day high / low profile, scaled to the same height
        if showWk and showHr and not na(hHi)
            int wdH = hrFor == "Today's weekday" and isWk ? tDow : 0
            array<int> ixh = idxFor(hDw, wdH, hrN)
            int nh = ixh.size()
            if nh >= 5
                array<int> cH = array.new<int>(24, 0)
                array<int> cL = array.new<int>(24, 0)
                for i in ixh
                    int a = hHi.get(i)
                    int b = hLo.get(i)
                    cH.set(a, cH.get(a) + 1)
                    cL.set(b, cL.get(b) + 1)
                int   mx  = math.max(1, math.max(cH.max(), cL.max()))
                float hgt = yHi - yLo
                string who = wdH == 0 ? "days" : dayName(wdH) + "s"
                for j = 0 to 22
                    int h  = (18 + j) % 24
                    int xi = x0 + j * hrW
                    int kH = cH.get(h)
                    int kL = cL.get(h)
                    if kH > 0
                        pB.push(box.new(xi, yLo + hgt * kH / mx, xi + hb, yLo, border_color = colHi, bgcolor = color.new(colHi, 35)))
                    if kL > 0
                        pB.push(box.new(xi + hb, yLo + hgt * kL / mx, xi + 2 * hb, yLo, border_color = colLo, bgcolor = color.new(colLo, 35)))
                    string tip = str.tostring(h, "00") + ":00 ET\nday's high here " + str.tostring(100.0 * kH / nh, "0") + "%\nday's low here " + str.tostring(100.0 * kL / nh, "0") + "%\nof the last " + str.tostring(nh) + " " + who
                    pL.push(label.new(xi + hb, yLo - pad, h % 3 == 0 ? str.tostring(h, "00") : "·", color = #00000000, style = label.style_label_up, textcolor = chart.fg_color, size = size.tiny, tooltip = tip))
                pL.push(label.new(x0, yHi + pad, "Hour of the day's high (left bar) / low (right bar), ET · last " + str.tostring(nh) + " " + who, color = #00000000, style = label.style_label_lower_left, textcolor = chart.fg_color, size = sz))

                if timeframe.isintraday and isWk
                    int jn = (hour(time, TZ) - 18 + 24) % 24
                    if jn <= 22
                        int xn = x0 + jn * hrW + hb
                        pN.push(line.new(xn, yLo, xn, yHi, color = colNow, style = line.style_dotted, width = 1))
                    if timeframe.in_seconds() <= 3600 and not na(tHhr)
                        int jh = (tHhr - 18 + 24) % 24
                        int jl = (tLhr - 18 + 24) % 24
                        if jh <= 22
                            pL.push(label.new(x0 + jh * hrW, yLo + hgt * cH.get(tHhr) / mx, "H", color = #00000000, style = label.style_label_down, textcolor = colNow, size = sz, tooltip = "Today's high so far: " + str.tostring(tHhr, "00") + ":00 hour · " + str.tostring(100.0 * cH.get(tHhr) / nh, "0") + "% of the last " + str.tostring(nh) + " " + who + " set their high here · " + stamp))
                        if jl <= 22
                            pL.push(label.new(x0 + jl * hrW + 2 * hb, yLo + hgt * cL.get(tLhr) / mx, "L", color = #00000000, style = label.style_label_down, textcolor = colNow, size = sz, tooltip = "Today's low so far: " + str.tostring(tLhr, "00") + ":00 hour · " + str.tostring(100.0 * cL.get(tLhr) / nh, "0") + "% of the last " + str.tostring(nh) + " " + who + " set their low here · " + stamp))

        // ══════════ month-of-year seasonality (scaled into the same band when shown beside the weekdays)
        if showMo and not na(mLo) and mHi > mLo
            array<float> mSrc = mR ? jRng : jNet
            array<float> allM = lastN(mSrc, monYrs * 12)
            float medAllM = allM.size() > 0 ? allM.median() : na
            float moRk  = na
            float moMed = na
            int   moN   = 0
            int   moUp  = 0
            for m = 1 to 12
                array<int> ix = moIdx(jK, m, monYrs)
                array<float> v = valsAt(mSrc, ix)
                int n = v.size()
                if n >= 3
                    int   xc   = xM0 + (m - 1) * mGap
                    float med  = v.median()
                    float q1   = v.percentile_linear_interpolation(25)
                    float q3   = v.percentile_linear_interpolation(75)
                    float p10  = v.percentile_linear_interpolation(10)
                    float p90  = v.percentile_linear_interpolation(90)
                    float mult = mR and medAllM > 0 ? med / medAllM : na
                    float dpp  = med - medAllM
                    bool  isC  = m == curMo
                    color cc   = mR ? (mult >= wideX ? colWide : mult <= narX ? colNar : colNorm) : (dpp >= monPP ? colUp : dpp <= -monPP ? colDn : colNorm)

                    pN.push(line.new(xc, mapY(p10, mLo, mHi, yLo, yHi), xc, mapY(p90, mLo, mHi, yLo, yHi), color = color.new(cc, 40), width = 1))
                    pB.push(box.new(xc - mw, mapY(q3, mLo, mHi, yLo, yHi), xc + mw, mapY(q1, mLo, mHi, yLo, yHi), border_color = isC ? colNow : cc, border_width = isC ? 2 : 1, bgcolor = color.new(cc, 80)))
                    pN.push(line.new(xc - mw - 1, mapY(med, mLo, mHi, yLo, yHi), xc + mw + 1, mapY(med, mLo, mHi, yLo, yHi), color = cc, width = 3))

                    int ups = 0
                    for j = 0 to n - 1
                        int i = ix.get(j)
                        if jNet.get(i) > 0
                            ups += 1
                        if showMd
                            int   tr  = int(75.0 * (n - 1 - j) / math.max(1, n - 1))
                            color dc  = color.new(jNet.get(i) >= 0 ? colUp : colDn, tr)
                            string tip = str.format_time(jK.get(i), "MMM yyyy", "UTC") + "\nnet " + sgn(jNet.get(i)) + "% (" + str.tostring(jPts.get(i), "0.00") + " pts)\nrange " + f2(jRng.get(i)) + "%"
                            pL.push(label.new(xc - mw + (j % (2 * mw + 1)), mapY(v.get(j), mLo, mHi, yLo, yHi), "•", color = #00000000, style = label.style_label_center, textcolor = dc, size = sz, tooltip = tip))

                    string st = mR ? moName(m) + "\n" + f2(med) + "%\n×" + str.tostring(mult, "0.00") + "\nn " + str.tostring(n) : moName(m) + "\n" + sgn(med) + "%\nup " + str.tostring(100.0 * ups / n, "0") + "%\nn " + str.tostring(n)
                    pL.push(label.new(xc, yLo - pad, st, color = #00000000, style = label.style_label_up, textcolor = isC ? colNow : cc, size = sz))

                    if isC and not na(moNow)
                        moRk  := rankOf(v, moNow)
                        moMed := med
                        moN   := n
                        moUp  := ups
                        pL.push(label.new(xc, mapY(moNow, mLo, mHi, yLo, yHi), "◆", color = #00000000, style = label.style_label_center, textcolor = colNow, size = sz, tooltip = moName(m) + " to date " + (mR ? f2(moNow) : sgn(moNow)) + "% · " + stamp))

            if not mR
                float y0 = mapY(0.0, mLo, mHi, yLo, yHi)
                pN.push(line.new(xM0 - mw - 1, y0, xM0 + 11 * mGap + mw + 1, y0, color = color.new(chart.fg_color, 60), style = line.style_dotted, width = 1))

            string mWhat = mR ? "range" : "net move"
            string l1 = "Month of year · " + mWhat + " % of prior month close, roll gaps removed · last " + str.tostring(monYrs) + " years" + (showWk ? " · scaled to fit" : "")
            string l2 = na(moRk) ? "" : "\n" + moName(curMo) + " to date " + (mR ? f2(moNow) : sgn(moNow)) + "% · P" + str.tostring(moRk, "0") + " of " + str.tostring(moN) + " " + moName(curMo) + "s · median " + (mR ? f2(moMed) : sgn(moMed)) + "%" + (mR ? "" : " · up " + str.tostring(100.0 * moUp / moN, "0") + "%") + " · " + stamp
            pL.push(label.new(xM0 - mw, yHi + pad, l1 + l2, color = #00000000, style = label.style_label_lower_left, textcolor = chart.fg_color, size = sz, textalign = text.align_left))

    // ══════════ dashboard
    if showDash
        table T = dashOn == "Price chart" ? dashP : dashI
        string dn   = isWk ? dayName(tDow) : "—"
        float  rPts = tHi - tLo
        float  nPts = close - tO
        float  atrP = 100.0 * atrD / tO

        // same weekday, full day (daily bars)
        array<float> fdR = array.new<float>()
        if isWk and not na(dRg)
            fdR := valsAt(dRg, idxFor(dDw, tDow, nWk))
        float fdMed = fdR.size() >= 3 ? fdR.median() : na
        float fdPts = fdMed / 100.0 * tO

        // same weekday, same time of day (60-minute bars, interpolated to the minute)
        bool  tmOK = timeframe.isintraday and isWk and not na(tR1)
        float fr   = timeframe.isintraday ? math.min(1.0, (minute(time, TZ) + timeframe.in_seconds() / 60.0) / 60.0) : 1.0
        array<float> tmR = array.new<float>()
        array<float> tmN = array.new<float>()
        if tmOK
            int k = tR1.size()
            if k > 0
                for i = 0 to k - 1
                    tmR.push(tR0.get(i) + (tR1.get(i) - tR0.get(i)) * fr)
                    tmN.push(tN0.get(i) + (tN1.get(i) - tN0.get(i)) * fr)
        [mRm, mRlo, mRhi] = medBand(tmR, zCI)
        [mNm, mNlo, mNhi] = medBand(tmN, zCI)
        string sR = stTxt(tRng, mRlo, mRhi)
        string sN = stTxt(tNet, mNlo, mNhi)

        // this hour in the hour-of-high/low history
        int hNowET = hour(time, TZ)
        array<int> ixh2 = idxFor(hDw, isWk ? tDow : 0, hrN)
        int nh2 = ixh2.size()
        int kh  = 0
        int kl  = 0
        for i in ixh2
            if hHi.get(i) == hNowET
                kh += 1
            if hLo.get(i) == hNowET
                kl += 1

        // this month to date (net, roll-free)
        float moNet = uCurB > 0 ? 100.0 * aCurP / uCurB : na
        array<float> mv = valsAt(jNet, moIdx(jK, curMo, monYrs))
        float mvMed = mv.size() >= 3 ? mv.median() : na
        int   mvUp  = 0
        for x in mv
            if x > 0
                mvUp += 1

        string tipR = "Above / Below = today's range so far is outside the " + bandCI + " uncertainty band of the median range of the last " + str.tostring(tmR.size()) + " " + dn + "s at this same time of day. Neutral = inside it."
        string tipN = "Above / Below = today's net move so far is outside the " + bandCI + " uncertainty band of the median net move of the last " + str.tostring(tmN.size()) + " " + dn + "s at this same time of day. Neutral = inside it."

        T.cell(0, 0, syminfo.ticker + " · " + dn + " · " + stamp + " ET", text_color = #e0e3eb, text_size = dSz, text_halign = text.align_left)
        dRow(T, 1, "ATR " + str.tostring(atrLen) + " (daily)", str.tostring(atrD, "0") + " pts · " + f2(atrP) + "%", "", #00000000, "")
        dRow(T, 2, "Range so far", str.tostring(rPts, "0") + " pts · " + f2(tRng) + "% · " + str.tostring(100.0 * rPts / atrD, "0") + "% of ATR", "", #00000000, "")
        dRow(T, 3, "   vs " + dn + " by now", tmOK and not na(mRm) ? "median " + f2(mRm) + "% · band " + f2(mRlo) + "–" + f2(mRhi) + "%" : "intraday chart, weekday only", sR, stCol(sR, colWide, colNar), tipR)
        dRow(T, 4, "   vs " + dn + " full day", na(fdMed) ? "—" : "median " + str.tostring(fdPts, "0") + " pts · " + str.tostring(100.0 * tRng / fdMed, "0") + "% done · " + str.tostring(math.max(0.0, fdPts - rPts), "0") + " pts to go", "", #00000000, "")
        dRow(T, 5, "Net move", sgn(tNet) + "% · " + sgn0(nPts) + " pts", "", #00000000, "")
        dRow(T, 6, "   vs " + dn + " by now", tmOK and not na(mNm) ? "median " + sgn(mNm) + "% · band " + sgn(mNlo) + " to " + sgn(mNhi) + "%" : "intraday chart, weekday only", sN, stCol(sN, colUp, colDn), tipN)
        dRow(T, 7, "This hour", nh2 > 0 ? str.tostring(hNowET, "00") + ":00 ET · set " + str.tostring(100.0 * kh / nh2, "0") + "% of highs · " + str.tostring(100.0 * kl / nh2, "0") + "% of lows" : "—", "", #00000000, "")
        dRow(T, 8, moName(curMo) + " to date", na(moNet) ? "—" : sgn(moNet) + "% · median " + (na(mvMed) ? "—" : sgn(mvMed)) + "% · up " + (mv.size() > 0 ? str.tostring(100.0 * mvUp / mv.size(), "0") : "—") + "% of " + str.tostring(mv.size()), "", #00000000, "")
        T.cell(0, 9, "n: " + str.tostring(fdR.size()) + " " + dn + " full day · " + str.tostring(tmR.size()) + " by now · " + str.tostring(nh2) + " for hours · " + str.tostring(mv.size()) + " " + moName(curMo) + "s · band = " + bandCI + " uncertainty of the median", text_color = #787b86, text_size = size.tiny, text_halign = text.align_left)
````
