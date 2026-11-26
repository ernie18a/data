# Price Action Concepts [b1k]

- url: https://www.tradingview.com/script/FFzp048q-Price-Action-Concepts-b1k/
- type: indicator
- pine_id: PUB;1312bafc0e634237881bd22a887c0093
- version: 3.0

## Description

Price Action Concepts

everything i actually watch on an intraday chart, in one indicator. built off my Essential Time Ranges and folded in the tools i kept loading separately.

what's inside:

Time ranges — hourly high/low + midpoint, opening range (30s up to 30m, pulled from lower-timeframe data so it's accurate on any chart and extends across RTH), initial balance (9:30-10:30), and the RTH box.

Range metrics — ADR(10), AWR(8), today's day range and this week's range, plus % of each used so you know how much is left in the tank. ADR/AWR projected off the open (open +/- range/2), same read as Quant Matrix.

Value areas — VAH / VAL / POC for the session you choose (RTH or ETH), both TPO and volume profile, plus the last 3 sessions. volume draws as a zone, TPO as lines. also marks TPO single prints and volume imbalances (low-volume nodes) for the fast-move levels.

1kpier levels — overnight high/low, previous day and week high/low, wickless 15m candles, and a reference grid.

HoD/LoD timing — where the high and low of the range printed and how long it took to get there.

Session distributions — the Quant Matrix boxes (each session sized to its own average range, centered on the open) and the distribution table, total or by day of week, points or percent.

built around ES/NQ but the ratios carry across instruments. every element has its own color, line type and width, so you can set it up to read the way you want and turn off what you don't use.

- b1kPier

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © b1kPier 2026
// ─────────────────────────────────────────────────────────────────────────────
//  Price Action Concepts  [b1k]
//  Reworked from "Essential Time Ranges" into a single Price Action cockpit.
//  Sections (all toggleable):
//    A) Time Ranges     — hourly ranges + midpoint, Opening Range, Initial Balance, RTH box,
//                         session-open boxes (Asia 18:00 / London 04:00 / NY 09:30, per-session duration)
//    B) Range Metrics   — ADR(10), AWR(8), today's Day Range, % ADR used, ADR projection lines
//    C) Value Areas     — TPO + Volume Profile histograms + VAH/VAL/POC (independent granularity),
//                         previous 3 sessions as VA lines/zones
//    D) 1kpier Levels   — Overnight H/L, Prev Day/Week H/L, Wickless candles, Reference grid
//    E) HoD / LoD Timing— time-to-high / time-to-low within a range, interval buckets
//    F) Distributions   — Quant Matrix session boxes (open ± avg range/2) + distribution table
//  Most elements expose color + line-type + width inputs for easy colour-coding.
//
//  Changelog
//    2026-09-03
//      + A · Session Opens — Asia 18:00 / London 04:00 / NY 09:30 (NY time).
//        Per-session start + duration (min). Box measures that window, then freezes.
//      + C · TPO and Volume histograms on the developing session (TPO left, VP right).
//      + C · Independent VP / TPO granularity (Rows or Ticks). Shared va_rows removed.
//      ~ Single prints follow TPO rows; LVNs follow VP rows.
//      ~ Previous 3 sessions still VAH/VAL/POC only (Pine 500-box cap).
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Price Action Concepts [b1k]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ═════════════════════════════════════════════════════════════════════════════
//  GLOBAL HELPER FUNCTIONS  (Pine requires user functions at global scope)
// ═════════════════════════════════════════════════════════════════════════════
f_pos(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

f_lineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_hline(x1, price, c, styl, w) =>
    line.new(x1, price, bar_index, price, xloc = xloc.bar_index, extend = extend.right, color = c, style = styl, width = w)

f_hlbl(price, c, t) =>
    label.new(bar_index, price, t, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 80), textcolor = color.white, size = size.small)

f_interval(int m) =>
    string r = ">30 min"
    if na(m)
        r := "-"
    else if m <= 1
        r := "0-1 min"
    else if m <= 5
        r := "1-5 min"
    else if m <= 15
        r := "5-15 min"
    else if m <= 30
        r := "15-30 min"
    r

// HH:mm → minute-of-day. Invalid strings fall back to `fb`.
f_hhmm(string s, int fb) =>
    int r = fb
    if not na(s)
        array<string> p = str.split(s, ":")
        if array.size(p) >= 2
            float hf = str.tonumber(array.get(p, 0))
            float mf = str.tonumber(array.get(p, 1))
            if not na(hf) and not na(mf)
                int h = int(math.round(hf))
                int m = int(math.round(mf))
                r := math.max(0, math.min(23, h)) * 60 + math.max(0, math.min(59, m))
    r

// True when NY minute-of-day is inside [start, start+dur), wrapping past midnight.
f_in_open_win(int nyMod, int startMin, int durMin) =>
    bool inside = false
    if durMin > 0
        int endMin = startMin + durMin
        inside := endMin <= 1440 ? (nyMod >= startMin and nyMod < endMin) : (nyMod >= startMin or nyMod < (endMin - 1440))
    inside

// Resolve profile row count from Rows vs Ticks mode. Clamped 6–100.
f_gran_rows(float sLo, float sHi, string mode, int nRows, int nTicks) =>
    int r = nRows
    if mode == "Ticks" and sHi > sLo and nTicks > 0
        float stepPx = nTicks * syminfo.mintick
        if stepPx > 0
            r := int(math.round((sHi - sLo) / stepPx))
    math.max(6, math.min(100, nz(r, nRows)))

// Horizontal histogram: TPO left-aligned, VP right-aligned. POC row is more opaque.
f_draw_hist(array<float> bins, float sLo, float sHi, int x1, int x2, color col, bool fromLeft, int widthPct, array<box> dest) =>
    int n = array.size(bins)
    int span = math.max(1, x2 - x1)
    int maxW = math.max(1, int(span * widthPct / 100.0))
    if n > 0 and sHi > sLo
        float step = (sHi - sLo) / n
        float mx = 0.0
        int pocIdx = 0
        for rr = 0 to n - 1
            float v = array.get(bins, rr)
            if v > mx
                mx := v
                pocIdx := rr
        if mx > 0.0
            for rr = 0 to n - 1
                float v = array.get(bins, rr)
                if v > 0.0
                    int w = math.max(1, int(math.round(v / mx * maxW)))
                    float yBot = sLo + rr * step
                    float yTop = sLo + (rr + 1) * step
                    int xa = fromLeft ? x1 : x2 - w
                    int xb = fromLeft ? x1 + w : x2
                    bool isPoc = rr == pocIdx
                    array.push(dest, box.new(xa, yTop, xb, yBot, xloc = xloc.bar_index, bgcolor = color.new(col, isPoc ? 40 : 70), border_color = color.new(col, isPoc ? 20 : 55), border_width = isPoc ? 1 : 0))
    dest

// Build a price profile from per-bar low/high/weight arrays.
// split=true  -> distribute weight across spanned rows (Volume Profile)
// split=false -> add full weight to each spanned row (TPO / bar count)
// Returns [poc, vah, val, bins].
f_build_profile(array<float> lows, array<float> highs, array<float> wts, float sLo, float sHi, int rows, float vaPct, bool split, bool active) =>
    float poc = na
    float vah = na
    float val = na
    array<float> bins = array.new_float()
    int n = array.size(lows)
    if active and n > 0 and sHi > sLo and rows > 0
        float step = (sHi - sLo) / rows
        bins := array.new_float(rows, 0.0)
        for i = 0 to n - 1
            float bl = array.get(lows, i)
            float bh = array.get(highs, i)
            float w  = array.get(wts, i)
            int loIdx = int(math.floor((bl - sLo) / step))
            int hiIdx = int(math.floor((bh - sLo) / step))
            loIdx := loIdx < 0 ? 0 : loIdx > rows - 1 ? rows - 1 : loIdx
            hiIdx := hiIdx < 0 ? 0 : hiIdx > rows - 1 ? rows - 1 : hiIdx
            int span = hiIdx - loIdx + 1
            float add = split ? w / span : w
            for rr = loIdx to hiIdx
                array.set(bins, rr, array.get(bins, rr) + add)
        // Point of Control = fullest row
        int pocIdx = 0
        float pocVal = array.get(bins, 0)
        for rr = 1 to rows - 1
            float v = array.get(bins, rr)
            if v > pocVal
                pocVal := v
                pocIdx := rr
        // Expand value area outward from POC to vaPct of total
        float total  = array.sum(bins)
        float target = vaPct * total
        int lo = pocIdx
        int hi = pocIdx
        float running = array.get(bins, pocIdx)
        while running < target and (lo > 0 or hi < rows - 1)
            float upV = hi < rows - 1 ? array.get(bins, hi + 1) : -1.0
            float dnV = lo > 0 ? array.get(bins, lo - 1) : -1.0
            if upV >= dnV
                hi := hi + 1
                running := running + upV
            else
                lo := lo - 1
                running := running + dnV
        poc := sLo + (pocIdx + 0.5) * step
        vah := sLo + (hi + 1) * step
        val := sLo + lo * step
    [poc, vah, val, bins]

// Return the mid-prices of profile rows that are single prints / low-volume nodes.
// lowMode=false -> rows with weight <= thr (TPO single prints, thr = max TPOs)
// lowMode=true  -> rows with weight <= thr * max-row (VP volume imbalance / LVN)
f_profile_rows(array<float> lows, array<float> highs, array<float> wts, float sLo, float sHi, int rows, bool split, bool lowMode, float thr, bool active) =>
    array<float> res = array.new_float()
    if active and array.size(lows) > 0 and sHi > sLo and rows > 0
        float step = (sHi - sLo) / rows
        array<float> bins = array.new_float(rows, 0.0)
        for i = 0 to array.size(lows) - 1
            float bl = array.get(lows, i)
            float bh = array.get(highs, i)
            float w  = array.get(wts, i)
            int loIdx = int(math.floor((bl - sLo) / step))
            int hiIdx = int(math.floor((bh - sLo) / step))
            loIdx := loIdx < 0 ? 0 : loIdx > rows - 1 ? rows - 1 : loIdx
            hiIdx := hiIdx < 0 ? 0 : hiIdx > rows - 1 ? rows - 1 : hiIdx
            int span = hiIdx - loIdx + 1
            float add = split ? w / span : w
            for rr = loIdx to hiIdx
                array.set(bins, rr, array.get(bins, rr) + add)
        float mx = 0.0
        for rr = 0 to rows - 1
            mx := math.max(mx, array.get(bins, rr))
        for rr = 0 to rows - 1
            float v = array.get(bins, rr)
            bool hit = lowMode ? (mx > 0 and v > 0 and v <= thr * mx) : (v > 0 and v <= thr)
            if hit
                array.push(res, sLo + (rr + 0.5) * step)
    res

// --- Session distribution type + method (ported from Quant Matrix) ---
type ses_stats
    array<float> ranges
    array<float> range_pcts
    array<int>   day
    array<box>   boxes
    array<label> labels
    string session
    color  obj_color
    float  cur_hi = na
    float  cur_lo = na
    float  cur_op = na

method update_ses(ses_stats S, string sess_str, string tz, bool draw_box, bool draw_lbl) =>
    in_sess = not na(time(timeframe.period, sess_str, tz))
    bool opened  = in_sess and not in_sess[1]
    bool closing = not in_sess and in_sess[1]
    // Range tracking (always, so the table works even with boxes hidden)
    if opened
        S.cur_hi := high
        S.cur_lo := low
        S.cur_op := open
        S.day.unshift(dayofweek)
        S.ranges.unshift(0.0)
        S.range_pcts.unshift(0.0)
    else if in_sess
        S.cur_hi := math.max(S.cur_hi, high)
        S.cur_lo := math.min(S.cur_lo, low)
    else if closing and S.ranges.size() > 0 and not na(S.cur_hi)
        S.ranges.set(0, S.cur_hi - S.cur_lo)
        S.range_pcts.set(0, S.cur_op != 0 ? (S.cur_hi - S.cur_lo) / S.cur_op * 100 : 0.0)
    // Boxes (only when enabled, centered on session open ± avg range/2)
    if draw_box
        float avg_r = S.ranges.size() > 1 ? S.ranges.avg() : 0.0
        if opened
            box nb = box.new(bar_index, S.cur_op + avg_r / 2, bar_index, S.cur_op - avg_r / 2, bgcolor = S.obj_color, border_color = S.obj_color)
            S.boxes.unshift(nb)
            label nl = draw_lbl ? label.new(bar_index, S.cur_op + avg_r / 2, str.tostring(avg_r, "#.##"), style = label.style_label_down, color = color.new(S.obj_color, 60), textcolor = color.white, size = size.tiny) : na
            S.labels.unshift(nl)
            if S.boxes.size() > 30
                box.delete(S.boxes.pop())
                label.delete(S.labels.pop())
        else if in_sess and S.boxes.size() > 0
            box cb = S.boxes.get(0)
            cb.set_right(bar_index)
            cb.set_top(S.cur_op + avg_r / 2)
            cb.set_bottom(S.cur_op - avg_r / 2)

// Session-open range box: measures H/L only inside the window, then freezes.
type open_rng
    string       name
    array<box>   kept
    array<label> lbls
    float        hi    = na
    float        lo    = na
    box          bx    = na
    bool         wasIn = false

method update_open(open_rng O, int nyMod, int startMin, int durMin, color fill, color border, bool show, bool drawLbl) =>
    bool inWin = f_in_open_win(nyMod, startMin, durMin)
    if show
        if inWin and not O.wasIn
            O.hi := high
            O.lo := low
            box nb = box.new(bar_index, high, bar_index + 1, low, xloc = xloc.bar_index, bgcolor = fill, border_color = border, border_width = 1)
            O.bx := nb
            O.kept.unshift(nb)
            label nl = drawLbl ? label.new(bar_index, high, O.name, style = label.style_label_down, color = color.new(border, 70), textcolor = color.white, size = size.tiny) : na
            O.lbls.unshift(nl)
            if O.kept.size() > 20
                box.delete(O.kept.pop())
                label.delete(O.lbls.pop())
        else if inWin
            O.hi := math.max(nz(O.hi, high), high)
            O.lo := math.min(nz(O.lo, low), low)
            if not na(O.bx)
                box cb = O.bx
                cb.set_top(O.hi)
                cb.set_bottom(O.lo)
                cb.set_right(bar_index + 1)
            if drawLbl and O.lbls.size() > 0
                label lb = O.lbls.get(0)
                if not na(lb)
                    lb.set_xy(bar_index, O.hi)
                    lb.set_text(O.name)
    O.wasIn := inWin

// Average a session's stored values, optionally only same-weekday sessions; ignores the forming (0) entry
f_avg_ses(array<float> vals, array<int> days, bool byDow, int curDow) =>
    float s = 0.0
    int   n = 0
    for i = 0 to array.size(vals) - 1
        float v = array.get(vals, i)
        if v > 0 and (not byDow or array.get(days, i) == curDow)
            s := s + v
            n := n + 1
    n > 0 ? s / n : na

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION A — TIME RANGES
// ═════════════════════════════════════════════════════════════════════════════
grpTR = "A · Time Ranges"
showHourly      = input.bool(true,  "Show Hourly Ranges", group = grpTR)
hourlyStyle     = input.string("Boxes", "Hourly Style", options = ["Boxes", "High/Low Lines"], group = grpTR)
hourlyLineStyle = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], inline = "H0", group = grpTR)
hourly_width    = input.int(1, "Width", minval = 1, maxval = 4, inline = "H0", group = grpTR)
rangeColor      = input.color(color.new(color.blue, 90), "Hourly Fill", inline = "H1", group = grpTR)
borderColor     = input.color(color.new(color.blue, 0),  "Border/Line", inline = "H1", group = grpTR)
showMid         = input.bool(true, "Show Midpoint", inline = "H2", group = grpTR)
midColor        = input.color(color.new(color.red, 0), "", inline = "H2", group = grpTR)
midStyle        = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], inline = "H2", group = grpTR)
midWidth        = input.int(1, "", minval = 1, maxval = 4, inline = "H2", group = grpTR)

showOR      = input.bool(true, "Show Opening Range", inline = "OR", group = grpTR)
orDur       = input.string("5m", "", options = ["30s", "1m", "3m", "5m", "15m", "30m"], inline = "OR", group = grpTR)
orColor     = input.color(color.new(color.purple, 80), "", inline = "OR", group = grpTR)
orBorderCol = input.color(color.new(color.purple, 30), "OR Border", inline = "OR2", group = grpTR)
orBorderW   = input.int(1, "Width", minval = 1, maxval = 4, inline = "OR2", group = grpTR)

showIB       = input.bool(true, "Show Initial Balance (09:30-10:30)", inline = "IB", group = grpTR)
showIBLabels = input.bool(true, "Labels", inline = "IB", group = grpTR)
ibColor      = input.color(color.new(color.gray, 0), "", inline = "IB", group = grpTR)
ibStyle      = input.string("Solid",  "IB rails", options = ["Solid", "Dashed", "Dotted"], inline = "IB2", group = grpTR)
ibWidth      = input.int(2, "", minval = 1, maxval = 4, inline = "IB2", group = grpTR)
ibMidStyle   = input.string("Dotted", "IB mid",   options = ["Solid", "Dashed", "Dotted"], inline = "IB2", group = grpTR)

showRTH  = input.bool(true, "Show RTH Box (09:30-16:00)", inline = "RT", group = grpTR)
rthColor = input.color(color.new(color.green, 88), "", inline = "RT", group = grpTR)

grpSO = "A · Session Opens"
show_so_asia = input.bool(true, "Asia Open",   inline = "SA", group = grpSO)
asia_start   = input.string("18:00", "",       inline = "SA", group = grpSO)
asia_dur     = input.int(60, "min", minval = 5, maxval = 360, inline = "SA", group = grpSO)
asia_fill    = input.color(color.new(color.blue, 80),  "Fill",   inline = "SA2", group = grpSO)
asia_border  = input.color(color.new(color.blue, 20),  "Border", inline = "SA2", group = grpSO)

show_so_lon  = input.bool(true, "London Open", inline = "SL", group = grpSO)
lon_start    = input.string("04:00", "",       inline = "SL", group = grpSO)
lon_dur      = input.int(60, "min", minval = 5, maxval = 360, inline = "SL", group = grpSO)
lon_fill     = input.color(color.new(color.red, 80),   "Fill",   inline = "SL2", group = grpSO)
lon_border   = input.color(color.new(color.red, 20),   "Border", inline = "SL2", group = grpSO)

show_so_ny   = input.bool(true, "NY Open",     inline = "SN", group = grpSO)
ny_so_start  = input.string("09:30", "",       inline = "SN", group = grpSO)
ny_dur       = input.int(60, "min", minval = 5, maxval = 360, inline = "SN", group = grpSO)
ny_fill      = input.color(color.new(color.green, 80), "Fill",   inline = "SN2", group = grpSO)
ny_border    = input.color(color.new(color.green, 20), "Border", inline = "SN2", group = grpSO)

show_so_lbls = input.bool(true, "Session Open Labels", group = grpSO)

// --- New-York minute-of-day (works on ES/NQ regardless of chart timezone) ---
nyH        = hour(time, "America/New_York")
nyMin      = minute(time, "America/New_York")
nyMinOfDay = nyH * 60 + nyMin

// OR duration in milliseconds (supports sub-minute 30s window)
orDurMs = orDur == "30s" ? 30000 : orDur == "1m" ? 60000 : orDur == "3m" ? 180000 : orDur == "5m" ? 300000 : orDur == "15m" ? 900000 : 1800000
isRTH = nyMinOfDay >= 570 and nyMinOfDay < 960
isIB  = nyMinOfDay >= 570 and nyMinOfDay < 630
// RTH open timestamp of the current day → OR window measured from it (millisecond-accurate)
rthOpenNow = isRTH and not isRTH[1]
var int rthOpenTime = na
if rthOpenNow
    rthOpenTime := time
// --- Opening Range (accurate on any chart TF via lower-timeframe intrabars; box extends across RTH) ---
or_ltf = orDur == "30s" ? "1S" : "1"
[or_lh, or_ll, or_lt] = request.security_lower_tf(syminfo.tickerid, or_ltf, [high, low, time])

var float orHi = na
var float orLo = na
var int   orStartBar = na
var box   orBox = na
if showOR
    if rthOpenNow
        orHi := na
        orLo := na
        orStartBar := bar_index
        orBox := na
    // Build OR from intrabars whose timestamp is inside [RTH open, RTH open + duration)
    if isRTH and not na(rthOpenTime)
        if array.size(or_lt) > 0
            for i = 0 to array.size(or_lt) - 1
                int it = array.get(or_lt, i)
                if it >= rthOpenTime and it < rthOpenTime + orDurMs
                    orHi := math.max(nz(orHi, array.get(or_lh, i)), array.get(or_lh, i))
                    orLo := math.min(nz(orLo, array.get(or_ll, i)), array.get(or_ll, i))
        else if (time - rthOpenTime) < orDurMs
            orHi := math.max(nz(orHi, high), high)
            orLo := math.min(nz(orLo, low), low)
    // Draw the OR box and keep extending its right edge across the whole RTH session
    if isRTH and not na(orHi) and not na(orLo)
        if na(orBox)
            orBox := box.new(orStartBar, orHi, bar_index + 1, orLo, xloc = xloc.bar_index, bgcolor = orColor, border_color = orBorderCol, border_width = orBorderW)
        else
            box.set_top(orBox, orHi)
            box.set_bottom(orBox, orLo)
            box.set_right(orBox, bar_index + 1)

// --- Initial Balance (09:30-10:30) drawn as high / low / mid rails ---
var float ibHi = na
var float ibLo = na
var int   ibOpenBar = na
var line  ibHiLn = na
var line  ibLoLn = na
var line  ibMidLn = na
var label ibHiLb = na
var label ibLoLb = na
var label ibMidLb = na
if showIB
    bool ibOpen = isIB and not isIB[1]
    if ibOpen
        ibHi := high
        ibLo := low
        ibOpenBar := bar_index
        ibHiLn := na
        ibLoLn := na
        ibMidLn := na
        ibHiLb := na
        ibLoLb := na
        ibMidLb := na
    else if isIB
        ibHi := math.max(nz(ibHi, high), high)
        ibLo := math.min(nz(ibLo, low), low)
    if isIB and not na(ibHi)
        float ibMid = (ibHi + ibLo) / 2
        if na(ibHiLn)
            ibHiLn  := line.new(ibOpenBar, ibHi,  bar_index, ibHi,  color = ibColor, width = ibWidth, style = f_lineStyle(ibStyle))
            ibLoLn  := line.new(ibOpenBar, ibLo,  bar_index, ibLo,  color = ibColor, width = ibWidth, style = f_lineStyle(ibStyle))
            ibMidLn := line.new(ibOpenBar, ibMid, bar_index, ibMid, color = color.new(ibColor, 40), style = f_lineStyle(ibMidStyle))
        else
            line.set_xy1(ibHiLn, ibOpenBar, ibHi)
            line.set_xy2(ibHiLn, bar_index, ibHi)
            line.set_xy1(ibLoLn, ibOpenBar, ibLo)
            line.set_xy2(ibLoLn, bar_index, ibLo)
            line.set_xy1(ibMidLn, ibOpenBar, ibMid)
            line.set_xy2(ibMidLn, bar_index, ibMid)
        if showIBLabels
            if na(ibHiLb)
                ibHiLb  := label.new(bar_index, ibHi,  "IB High " + str.tostring(ibHi, "#.##"),  style = label.style_label_left, color = color.new(ibColor, 80), textcolor = ibColor, size = size.small)
                ibLoLb  := label.new(bar_index, ibLo,  "IB Low "  + str.tostring(ibLo, "#.##"),  style = label.style_label_left, color = color.new(ibColor, 80), textcolor = ibColor, size = size.small)
                ibMidLb := label.new(bar_index, ibMid, "IB 50% "  + str.tostring(ibMid, "#.##"), style = label.style_label_left, color = color.new(ibColor, 80), textcolor = ibColor, size = size.small)
            else
                label.set_xy(ibHiLb, bar_index, ibHi)
                label.set_text(ibHiLb, "IB High " + str.tostring(ibHi, "#.##"))
                label.set_xy(ibLoLb, bar_index, ibLo)
                label.set_text(ibLoLb, "IB Low " + str.tostring(ibLo, "#.##"))
                label.set_xy(ibMidLb, bar_index, ibMid)
                label.set_text(ibMidLb, "IB 50% " + str.tostring(ibMid, "#.##"))

// --- RTH box (09:30-16:00) ---
var float rthHi = na
var float rthLo = na
var box   rthBox = na
var array<box> rthBoxes = array.new<box>()
if showRTH
    bool rthOpen = isRTH and not isRTH[1]
    if rthOpen
        rthHi  := high
        rthLo  := low
        rthBox := box.new(bar_index, high, bar_index + 1, low, bgcolor = rthColor, border_color = color.new(rthColor, 40))
        array.push(rthBoxes, rthBox)
        if array.size(rthBoxes) > 20
            box.delete(array.shift(rthBoxes))
    else if isRTH
        rthHi := math.max(nz(rthHi, high), high)
        rthLo := math.min(nz(rthLo, low), low)
        if not na(rthBox)
            box.set_top(rthBox, rthHi)
            box.set_bottom(rthBox, rthLo)
            box.set_right(rthBox, bar_index + 1)

// --- Hourly ranges + midpoint ---
var float hourlyHigh = na
var float hourlyLow  = na
var array<box>  hBoxes    = array.new<box>()
var array<line> hHiLines  = array.new<line>()
var array<line> hLoLines  = array.new<line>()
var array<line> hMidLines = array.new<line>()
bool newHour = timeframe.change("60")
if showHourly
    if newHour
        hourlyHigh := high
        hourlyLow  := low
        if hourlyStyle == "Boxes"
            b = box.new(bar_index, high, bar_index + 1, low, bgcolor = rangeColor, border_color = borderColor, border_width = hourly_width, border_style = f_lineStyle(hourlyLineStyle))
            array.push(hBoxes, b)
            if array.size(hBoxes) > 60
                box.delete(array.shift(hBoxes))
        else
            hl = line.new(bar_index, high, bar_index + 1, high, color = borderColor, width = hourly_width, style = f_lineStyle(hourlyLineStyle))
            ll = line.new(bar_index, low,  bar_index + 1, low,  color = borderColor, width = hourly_width, style = f_lineStyle(hourlyLineStyle))
            array.push(hHiLines, hl)
            array.push(hLoLines, ll)
            if array.size(hHiLines) > 60
                line.delete(array.shift(hHiLines))
                line.delete(array.shift(hLoLines))
        if showMid
            m = line.new(bar_index, (high + low) / 2, bar_index + 1, (high + low) / 2, color = midColor, width = midWidth, style = f_lineStyle(midStyle))
            array.push(hMidLines, m)
            if array.size(hMidLines) > 60
                line.delete(array.shift(hMidLines))
    else
        hourlyHigh := math.max(nz(hourlyHigh, high), high)
        hourlyLow  := math.min(nz(hourlyLow, low), low)
    if hourlyStyle == "Boxes" and array.size(hBoxes) > 0
        lb = array.get(hBoxes, array.size(hBoxes) - 1)
        box.set_top(lb, hourlyHigh)
        box.set_bottom(lb, hourlyLow)
        box.set_right(lb, bar_index + 1)
    else if hourlyStyle == "High/Low Lines" and array.size(hHiLines) > 0
        lhh = array.get(hHiLines, array.size(hHiLines) - 1)
        line.set_xy2(lhh, bar_index + 1, hourlyHigh)
        line.set_y1(lhh, hourlyHigh)
        lll = array.get(hLoLines, array.size(hLoLines) - 1)
        line.set_xy2(lll, bar_index + 1, hourlyLow)
        line.set_y1(lll, hourlyLow)
    if showMid and array.size(hMidLines) > 0
        lm = array.get(hMidLines, array.size(hMidLines) - 1)
        line.set_xy2(lm, bar_index + 1, (hourlyHigh + hourlyLow) / 2)
        line.set_y1(lm, (hourlyHigh + hourlyLow) / 2)

// --- Session-open boxes (Asia / London / NY): measure the window, then freeze ---
var so_asia = open_rng.new("Asia",   array.new<box>(), array.new<label>())
var so_lon  = open_rng.new("London", array.new<box>(), array.new<label>())
var so_ny   = open_rng.new("NY",     array.new<box>(), array.new<label>())
so_asia.update_open(nyMinOfDay, f_hhmm(asia_start, 1080), asia_dur, asia_fill, asia_border, show_so_asia, show_so_lbls)
so_lon.update_open(nyMinOfDay,  f_hhmm(lon_start, 240),   lon_dur,  lon_fill,  lon_border,  show_so_lon,  show_so_lbls)
so_ny.update_open(nyMinOfDay,   f_hhmm(ny_so_start, 570), ny_dur,   ny_fill,   ny_border,   show_so_ny,   show_so_lbls)

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION B — RANGE METRICS  (ADR10 / AWR8 / Day Range)  — from Quant Matrix
// ═════════════════════════════════════════════════════════════════════════════
grpB = "B · Range Metrics"
show_rm_table = input.bool(true, "Show Range Metrics Table", group = grpB)
rm_pos        = input.string("Top Left", "Table Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpB)
adr_len       = input.int(10, "ADR Length (days)",  minval = 1, inline = "L", group = grpB)
awr_len       = input.int(8,  "AWR Length (weeks)", minval = 1, inline = "L", group = grpB)
show_adr_proj = input.bool(true, "Show ADR Projection Lines", inline = "PJ", group = grpB)
show_awr_proj = input.bool(true, "Show AWR Projection Lines", inline = "PJ", group = grpB)
adr_proj_col  = input.color(color.new(color.teal, 0),   "ADR Proj", inline = "PC", group = grpB)
awr_proj_col  = input.color(color.new(color.orange, 0), "AWR Proj", inline = "PC", group = grpB)
adr_style     = input.string("Dashed", "ADR line", options = ["Solid", "Dashed", "Dotted"], inline = "AL", group = grpB)
adr_width     = input.int(1, "", minval = 1, maxval = 4, inline = "AL", group = grpB)
awr_style     = input.string("Solid",  "AWR line", options = ["Solid", "Dashed", "Dotted"], inline = "WL", group = grpB)
awr_width     = input.int(1, "", minval = 1, maxval = 4, inline = "WL", group = grpB)
low_fuel_pct  = input.float(80, "Low-fuel % (range used)", minval = 10, maxval = 100, group = grpB)
rm_bg         = input.color(color.new(color.black, 20), "Table BG", inline = "S", group = grpB)
rm_txt        = input.color(color.white, "Text", inline = "S", group = grpB)

// ADR(10) and AWR(8) over COMPLETED higher-timeframe bars (non-repainting idiom)
adr10 = request.security(syminfo.tickerid, "D", ta.sma(high - low, adr_len)[1], lookahead = barmerge.lookahead_on)
awr8  = request.security(syminfo.tickerid, "W", ta.sma(high - low, awr_len)[1], lookahead = barmerge.lookahead_on)

// Today's developing day range + day open (for open-centered projection, Quant-Matrix style)
var float dHi = na
var float dLo = na
var float dOpen = na
var int   dOpenBar = na
bool newDayB = ta.change(time("D")) != 0
if newDayB
    dHi := high
    dLo := low
    dOpen := open
    dOpenBar := bar_index
else
    dHi := math.max(nz(dHi, high), high)
    dLo := math.min(nz(dLo, low), low)
todayRange = dHi - dLo
pctADR     = adr10 > 0 ? todayRange / adr10 * 100 : na

// This week's developing range + week open
var float wHi = na
var float wLo = na
var float wOpen = na
var int   wOpenBar = na
bool newWeekB = ta.change(time("W")) != 0
if newWeekB
    wHi := high
    wLo := low
    wOpen := open
    wOpenBar := bar_index
else
    wHi := math.max(nz(wHi, high), high)
    wLo := math.min(nz(wLo, low), low)
weekRange = wHi - wLo
pctAWR     = awr8 > 0 ? weekRange / awr8 * 100 : na

// Projection rails: expected range CENTERED ON THE OPEN (like Quant Matrix's open ± range/2), drawn as horizontal lines
adrHiProj = not na(adr10) and not na(dOpen) ? dOpen + adr10 / 2 : na
adrLoProj = not na(adr10) and not na(dOpen) ? dOpen - adr10 / 2 : na
awrHiProj = not na(awr8)  and not na(wOpen) ? wOpen + awr8 / 2  : na
awrLoProj = not na(awr8)  and not na(wOpen) ? wOpen - awr8 / 2  : na
var line adrHiLn = na
var line adrLoLn = na
var line awrHiLn = na
var line awrLoLn = na
if barstate.islast
    line.delete(adrHiLn)
    line.delete(adrLoLn)
    line.delete(awrHiLn)
    line.delete(awrLoLn)
    if show_adr_proj and not na(adrHiProj)
        adrHiLn := f_hline(dOpenBar, adrHiProj, adr_proj_col, f_lineStyle(adr_style), adr_width)
        adrLoLn := f_hline(dOpenBar, adrLoProj, adr_proj_col, f_lineStyle(adr_style), adr_width)
    if show_awr_proj and not na(awrHiProj)
        awrHiLn := f_hline(wOpenBar, awrHiProj, awr_proj_col, f_lineStyle(awr_style), awr_width)
        awrLoLn := f_hline(wOpenBar, awrLoProj, awr_proj_col, f_lineStyle(awr_style), awr_width)

var table rmTable = na
if show_rm_table and barstate.islast
    if na(rmTable)
        rmTable := table.new(f_pos(rm_pos), 2, 7, bgcolor = rm_bg, border_color = color.new(color.gray, 40), border_width = 1)
    table.set_position(rmTable, f_pos(rm_pos))
    color fuelDay  = na(pctADR) ? rm_txt : pctADR >= low_fuel_pct ? color.new(color.red, 0) : color.new(color.lime, 0)
    color fuelWeek = na(pctAWR) ? rm_txt : pctAWR >= low_fuel_pct ? color.new(color.red, 0) : color.new(color.lime, 0)
    table.cell(rmTable, 0, 0, "Range Metrics", text_color = rm_txt, text_size = size.small, bgcolor = color.new(color.black, 10), text_halign = text.align_left)
    table.cell(rmTable, 1, 0, "",              text_color = rm_txt, text_size = size.small, bgcolor = color.new(color.black, 10))
    table.cell(rmTable, 0, 1, "ADR (" + str.tostring(adr_len) + ")", text_color = rm_txt, text_size = size.small, text_halign = text.align_left)
    table.cell(rmTable, 1, 1, str.tostring(adr10, "#.##"),           text_color = rm_txt, text_size = size.small, text_halign = text.align_right)
    table.cell(rmTable, 0, 2, "Day Range",                          text_color = rm_txt, text_size = size.small, text_halign = text.align_left)
    table.cell(rmTable, 1, 2, str.tostring(todayRange, "#.##"),      text_color = rm_txt, text_size = size.small, text_halign = text.align_right)
    table.cell(rmTable, 0, 3, "% ADR used",                         text_color = rm_txt, text_size = size.small, text_halign = text.align_left)
    table.cell(rmTable, 1, 3, na(pctADR) ? "-" : str.tostring(pctADR, "#.#") + "%", text_color = fuelDay, text_size = size.small, text_halign = text.align_right)
    table.cell(rmTable, 0, 4, "AWR (" + str.tostring(awr_len) + ")", text_color = rm_txt, text_size = size.small, text_halign = text.align_left)
    table.cell(rmTable, 1, 4, str.tostring(awr8, "#.##"),            text_color = rm_txt, text_size = size.small, text_halign = text.align_right)
    table.cell(rmTable, 0, 5, "Week Range",                         text_color = rm_txt, text_size = size.small, text_halign = text.align_left)
    table.cell(rmTable, 1, 5, str.tostring(weekRange, "#.##"),       text_color = rm_txt, text_size = size.small, text_halign = text.align_right)
    table.cell(rmTable, 0, 6, "% AWR used",                         text_color = rm_txt, text_size = size.small, text_halign = text.align_left)
    table.cell(rmTable, 1, 6, na(pctAWR) ? "-" : str.tostring(pctAWR, "#.#") + "%", text_color = fuelWeek, text_size = size.small, text_halign = text.align_right)

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION C — VALUE AREAS  (TPO + Volume Profile: VAH / VAL / POC)
// ═════════════════════════════════════════════════════════════════════════════
grpVP = "C · Value Areas (TPO + Volume)"
show_va    = input.bool(true, "Show Value Areas", group = grpVP)
va_session = input.string("RTH", "Profile Session", options = ["RTH", "ETH"], group = grpVP)
rth_sess   = input.session("0930-1600", "RTH Session", group = grpVP)
eth_sess   = input.session("1800-0930", "ETH Session", group = grpVP)
va_tz      = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "UTC", "Europe/London", "Asia/Tokyo"], group = grpVP)
va_pct     = input.float(70, "Value Area %", minval = 30, maxval = 95, group = grpVP) / 100.0
show_vp    = input.bool(true, "Volume Profile VA", inline = "M", group = grpVP)
show_tpo   = input.bool(true, "TPO VA",            inline = "M", group = grpVP)
show_prev3 = input.bool(true, "Show Previous 3 Sessions", group = grpVP)
show_vp_hist  = input.bool(true, "Show VP Histogram",  inline = "HST", group = grpVP)
show_tpo_hist = input.bool(true, "Show TPO Histogram", inline = "HST", group = grpVP)
hist_width_pct = input.int(30, "Histogram Width % of session", minval = 5, maxval = 80, group = grpVP)
vp_gran_mode  = input.string("Rows", "VP Granularity",  options = ["Rows", "Ticks"], inline = "VPG", group = grpVP)
vp_rows       = input.int(24, "Rows", minval = 6, maxval = 100, inline = "VPG", group = grpVP)
vp_ticks      = input.int(4, "Ticks/row", minval = 1, maxval = 100, inline = "VPG", group = grpVP)
tpo_gran_mode = input.string("Rows", "TPO Granularity", options = ["Rows", "Ticks"], inline = "TPG", group = grpVP)
tpo_rows      = input.int(24, "Rows", minval = 6, maxval = 100, inline = "TPG", group = grpVP)
tpo_ticks     = input.int(4, "Ticks/row", minval = 1, maxval = 100, inline = "TPG", group = grpVP)
col_vp     = input.color(color.new(color.orange, 0), "Volume VA color", inline = "C", group = grpVP)
col_tpo    = input.color(color.new(color.blue, 0),   "TPO VA color",    inline = "C", group = grpVP)
vp_style   = input.string("Zone", "Volume VA Display", options = ["Zone", "Lines"], group = grpVP)
va_fill    = input.int(82, "Volume Zone Transparency", minval = 0, maxval = 100, group = grpVP)
vp_poc_style  = input.string("Solid",  "VP POC line",     options = ["Solid", "Dashed", "Dotted"], inline = "VP1", group = grpVP)
vp_poc_width  = input.int(2, "", minval = 1, maxval = 4, inline = "VP1", group = grpVP)
vp_band_style = input.string("Dashed", "VP VAH/VAL line", options = ["Solid", "Dashed", "Dotted"], inline = "VP2", group = grpVP)
vp_band_width = input.int(1, "", minval = 1, maxval = 4, inline = "VP2", group = grpVP)
tpo_poc_style  = input.string("Solid",  "TPO POC line",     options = ["Solid", "Dashed", "Dotted"], inline = "TP1", group = grpVP)
tpo_poc_width  = input.int(2, "", minval = 1, maxval = 4, inline = "TP1", group = grpVP)
tpo_band_style = input.string("Dotted", "TPO VAH/VAL line", options = ["Solid", "Dashed", "Dotted"], inline = "TP2", group = grpVP)
tpo_band_width = input.int(1, "", minval = 1, maxval = 4, inline = "TP2", group = grpVP)
show_sp   = input.bool(true, "TPO Single Prints", inline = "SP", group = grpVP)
sp_col    = input.color(color.new(color.red, 0), "", inline = "SP", group = grpVP)
sp_style  = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], inline = "SP", group = grpVP)
sp_width  = input.int(1, "", minval = 1, maxval = 4, inline = "SP", group = grpVP)
sp_max    = input.int(1, "Single-print max TPOs", minval = 1, maxval = 4, group = grpVP)
show_imb  = input.bool(true, "VP Volume Imbalances (LVN)", inline = "IMB", group = grpVP)
imb_col   = input.color(color.new(color.yellow, 0), "", inline = "IMB", group = grpVP)
imb_style = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], inline = "IMB", group = grpVP)
imb_width = input.int(1, "", minval = 1, maxval = 4, inline = "IMB", group = grpVP)
imb_frac  = input.float(25, "Imbalance: node < % of POC volume", minval = 1, maxval = 90, group = grpVP) / 100.0

va_sess_str = va_session == "RTH" ? rth_sess : eth_sess
in_va = not na(time(timeframe.period, va_sess_str, va_tz))
va_open  = in_va and not in_va[1]
va_close = not in_va and in_va[1]

// Current session accumulators
var array<float> vaLows  = array.new_float()
var array<float> vaHighs = array.new_float()
var array<float> vaVols  = array.new_float()
var array<float> vaOnes  = array.new_float()
var float vaSlo = na
var float vaShi = na
var int   vaStartBar = na

// Snapshots of the last completed sessions (index 0 = most recent)
var array<float> h_vp_poc  = array.new_float()
var array<float> h_vp_vah  = array.new_float()
var array<float> h_vp_val  = array.new_float()
var array<float> h_tpo_poc = array.new_float()
var array<float> h_tpo_vah = array.new_float()
var array<float> h_tpo_val = array.new_float()
var array<int>   h_start   = array.new_int()
var array<int>   h_end     = array.new_int()

if show_va
    if va_open
        array.clear(vaLows)
        array.clear(vaHighs)
        array.clear(vaVols)
        array.clear(vaOnes)
        vaSlo := low
        vaShi := high
        vaStartBar := bar_index
    if in_va
        array.push(vaLows, low)
        array.push(vaHighs, high)
        array.push(vaVols, nz(volume))
        array.push(vaOnes, 1.0)
        vaSlo := math.min(nz(vaSlo, low), low)
        vaShi := math.max(nz(vaShi, high), high)
// Finalize a completed session into history — tuple assigned at GLOBAL scope,
// heavy work guarded by `do_finalize` so it only runs once per session close.
int vpN  = f_gran_rows(nz(vaSlo, close), nz(vaShi, close), vp_gran_mode,  vp_rows,  vp_ticks)
int tpoN = f_gran_rows(nz(vaSlo, close), nz(vaShi, close), tpo_gran_mode, tpo_rows, tpo_ticks)
bool do_finalize = show_va and va_close and array.size(vaLows) > 0
bool fHasVol = array.sum(vaVols) > 0
[fvpP, fvpH, fvpL, fvpB] = f_build_profile(vaLows, vaHighs, fHasVol ? vaVols : vaOnes, vaSlo, vaShi, vpN,  va_pct, fHasVol, do_finalize)
[ftpP, ftpH, ftpL, ftpB] = f_build_profile(vaLows, vaHighs, vaOnes, vaSlo, vaShi, tpoN, va_pct, false, do_finalize)
if do_finalize
    array.unshift(h_vp_poc, fvpP)
    array.unshift(h_vp_vah, fvpH)
    array.unshift(h_vp_val, fvpL)
    array.unshift(h_tpo_poc, ftpP)
    array.unshift(h_tpo_vah, ftpH)
    array.unshift(h_tpo_val, ftpL)
    array.unshift(h_start, vaStartBar)
    array.unshift(h_end, bar_index)
    if array.size(h_vp_poc) > 3
        array.pop(h_vp_poc)
        array.pop(h_vp_vah)
        array.pop(h_vp_val)
        array.pop(h_tpo_poc)
        array.pop(h_tpo_vah)
        array.pop(h_tpo_val)
        array.pop(h_start)
        array.pop(h_end)

// Developing (current) session profile — tuple at GLOBAL scope, computed only on the last bar.
// Volume Profile falls back to bar-count weighting when the symbol has no volume feed.
bool do_va_now = barstate.islast and show_va and array.size(vaLows) > 0
bool cHasVol = array.sum(vaVols) > 0
[cvpP, cvpH, cvpL, cvpB] = f_build_profile(vaLows, vaHighs, cHasVol ? vaVols : vaOnes, vaSlo, vaShi, vpN,  va_pct, cHasVol, do_va_now)
[ctpP, ctpH, ctpL, ctpB] = f_build_profile(vaLows, vaHighs, vaOnes, vaSlo, vaShi, tpoN, va_pct, false, do_va_now)
int va_x1 = nz(vaStartBar, bar_index)

// Draw value areas on the last bar; delete + rebuild for a clean picture.
// TPO renders as lines; Volume VA renders as a shaded zone (default) or lines, so both are always visible.
var array<line> va_lines = array.new<line>()
var array<box>  va_boxes = array.new<box>()
if barstate.islast and show_va
    for ln in va_lines
        line.delete(ln)
    for bx in va_boxes
        box.delete(bx)
    array.clear(va_lines)
    array.clear(va_boxes)

    // Current (developing) session — values precomputed above at global scope
    if array.size(vaLows) > 0 and not na(cvpP)
        if show_vp
            if vp_style == "Zone"
                array.push(va_boxes, box.new(va_x1, cvpH, bar_index + 1, cvpL, xloc = xloc.bar_index, bgcolor = color.new(col_vp, va_fill), border_color = color.new(col_vp, 35), border_width = 1))
                array.push(va_lines, f_hline(va_x1, cvpP, col_vp, f_lineStyle(vp_poc_style), vp_poc_width))
            else
                array.push(va_lines, f_hline(va_x1, cvpP, col_vp, f_lineStyle(vp_poc_style),  vp_poc_width))
                array.push(va_lines, f_hline(va_x1, cvpH, col_vp, f_lineStyle(vp_band_style), vp_band_width))
                array.push(va_lines, f_hline(va_x1, cvpL, col_vp, f_lineStyle(vp_band_style), vp_band_width))
        if show_tpo
            array.push(va_lines, f_hline(va_x1, ctpP, col_tpo, f_lineStyle(tpo_poc_style),  tpo_poc_width))
            array.push(va_lines, f_hline(va_x1, ctpH, col_tpo, f_lineStyle(tpo_band_style), tpo_band_width))
            array.push(va_lines, f_hline(va_x1, ctpL, col_tpo, f_lineStyle(tpo_band_style), tpo_band_width))
        // Developing-session histograms (TPO left, VP right). Previous 3 stay as VA lines/zones.
        if show_tpo_hist and array.size(ctpB) > 0
            va_boxes := f_draw_hist(ctpB, vaSlo, vaShi, va_x1, bar_index + 1, col_tpo, true,  hist_width_pct, va_boxes)
        if show_vp_hist and array.size(cvpB) > 0
            va_boxes := f_draw_hist(cvpB, vaSlo, vaShi, va_x1, bar_index + 1, col_vp,  false, hist_width_pct, va_boxes)
        // TPO single prints (rows touched by <= sp_max TPOs) — drawn across the session
        if show_sp
            array<float> spRows = f_profile_rows(vaLows, vaHighs, vaOnes, vaSlo, vaShi, tpoN, false, false, sp_max, true)
            for si = 0 to array.size(spRows) - 1
                array.push(va_lines, line.new(va_x1, array.get(spRows, si), bar_index, array.get(spRows, si), xloc = xloc.bar_index, color = sp_col, style = f_lineStyle(sp_style), width = sp_width))
        // VP volume imbalances / low-volume nodes (rows < imb_frac of POC volume)
        if show_imb
            array<float> imbRows = f_profile_rows(vaLows, vaHighs, cHasVol ? vaVols : vaOnes, vaSlo, vaShi, vpN, cHasVol, true, imb_frac, true)
            for ii = 0 to array.size(imbRows) - 1
                array.push(va_lines, line.new(va_x1, array.get(imbRows, ii), bar_index, array.get(imbRows, ii), xloc = xloc.bar_index, color = imb_col, style = f_lineStyle(imb_style), width = imb_width))

    // Previous sessions
    if show_prev3
        for k = 0 to array.size(h_vp_poc) - 1
            int xs = array.get(h_start, k)
            int xe = array.get(h_end, k)
            if show_vp
                if vp_style == "Zone"
                    array.push(va_boxes, box.new(xs, array.get(h_vp_vah, k), xe, array.get(h_vp_val, k), xloc = xloc.bar_index, bgcolor = color.new(col_vp, va_fill), border_color = color.new(col_vp, 55), border_width = 1))
                    array.push(va_lines, line.new(xs, array.get(h_vp_poc, k), xe, array.get(h_vp_poc, k), xloc = xloc.bar_index, color = col_vp, style = f_lineStyle(vp_poc_style), width = vp_poc_width))
                else
                    array.push(va_lines, f_hline(xs, array.get(h_vp_poc, k), col_vp, f_lineStyle(vp_poc_style),  vp_poc_width))
                    array.push(va_lines, f_hline(xs, array.get(h_vp_vah, k), col_vp, f_lineStyle(vp_band_style), vp_band_width))
                    array.push(va_lines, f_hline(xs, array.get(h_vp_val, k), col_vp, f_lineStyle(vp_band_style), vp_band_width))
            if show_tpo
                array.push(va_lines, f_hline(xs, array.get(h_tpo_poc, k), col_tpo, f_lineStyle(tpo_poc_style),  tpo_poc_width))
                array.push(va_lines, f_hline(xs, array.get(h_tpo_vah, k), col_tpo, f_lineStyle(tpo_band_style), tpo_band_width))
                array.push(va_lines, f_hline(xs, array.get(h_tpo_val, k), col_tpo, f_lineStyle(tpo_band_style), tpo_band_width))

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION D — 1KPIER LEVELS
// ═════════════════════════════════════════════════════════════════════════════
grp_glo  = "D · Overnight High / Low"
grp_prev = "D · Previous Day / Week H/L"
grp_wlc  = "D · Wickless Candles (15m)"
grp_grid = "D · Reference Grid"

show_globex = input.bool(true, "Show Overnight H/L", group = grp_glo)
glo_sess    = input.session("1800-0930", "Session (HHMM-HHMM)", group = grp_glo)
gmt_tz      = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "UTC", "Europe/London", "Asia/Tokyo"], group = grp_glo)
col_ghi     = input.color(color.new(color.aqua, 20), "Overnight High color", group = grp_glo)
col_glo     = input.color(color.new(color.red, 20),  "Overnight Low color",  group = grp_glo)
on_style    = input.string("Dashed", "Overnight line", options = ["Solid", "Dashed", "Dotted"], inline = "ON", group = grp_glo)
on_width    = input.int(1, "", minval = 1, maxval = 4, inline = "ON", group = grp_glo)

show_prev_day  = input.bool(true, "Show Previous Day H/L",  group = grp_prev)
show_prev_week = input.bool(true, "Show Previous Week H/L", group = grp_prev)
col_pdh = input.color(color.new(color.fuchsia, 15), "Prev Day High",  inline = "P1", group = grp_prev)
col_pdl = input.color(color.new(color.purple, 15),  "Prev Day Low",   inline = "P1", group = grp_prev)
col_pwh = input.color(color.new(color.blue, 15),    "Prev Week High", inline = "P2", group = grp_prev)
col_pwl = input.color(color.new(color.navy, 15),    "Prev Week Low",  inline = "P2", group = grp_prev)
pd_style = input.string("Dashed", "Prev Day line",  options = ["Solid", "Dashed", "Dotted"], inline = "P3", group = grp_prev)
pd_width = input.int(1, "", minval = 1, maxval = 4, inline = "P3", group = grp_prev)
pw_style = input.string("Solid",  "Prev Week line", options = ["Solid", "Dashed", "Dotted"], inline = "P4", group = grp_prev)
pw_width = input.int(1, "", minval = 1, maxval = 4, inline = "P4", group = grp_prev)

show_wlc      = input.bool(true, "Show Wickless Candles", group = grp_wlc)
wlc_days      = input.int(3, "Lookback days", minval = 1, maxval = 10, group = grp_wlc)
wlc_tolerance = input.int(1, "Wick Tolerance (Ticks)", minval = 0, maxval = 5, group = grp_wlc, tooltip = "Allows a tiny wick (1-2 ticks) to still count as wickless")
col_wlc_bull  = input.color(color.new(color.lime, 50),   "Wickless Bull", inline = "W", group = grp_wlc)
col_wlc_bear  = input.color(color.new(color.orange, 50), "Wickless Bear", inline = "W", group = grp_wlc)

show_grid   = input.bool(false, "Show Reference Grid (heavy)", group = grp_grid)
grid_range  = input.float(100, "Reference Range (points)", minval = 1, group = grp_grid)
col_grid    = input.color(color.new(color.gray, 60),   "Grid line color",       group = grp_grid)
col_grid_20 = input.color(color.new(color.yellow, 40), "20% / 80% level color", group = grp_grid)
grid_style  = input.string("Dotted", "Grid line", options = ["Solid", "Dashed", "Dotted"], inline = "GR", group = grp_grid)
grid_width  = input.int(1, "", minval = 1, maxval = 4, inline = "GR", group = grp_grid)

// D1. Overnight High / Low
is_globex = not na(time(timeframe.period, glo_sess, gmt_tz))
var bool prev_globex = false
is_session_open = is_globex and not prev_globex
prev_globex := is_globex

var float g_hi = na
var float g_lo = na
var line  ln_ghi = na
var line  ln_glo = na
var label lb_ghi = na
var label lb_glo = na
if show_globex
    if is_session_open
        g_hi := high
        g_lo := low
    else if is_globex
        g_hi := math.max(nz(g_hi, high), high)
        g_lo := math.min(nz(g_lo, low), low)
    if is_globex and not na(g_hi) and not na(g_lo)
        line.delete(ln_ghi)
        label.delete(lb_ghi)
        ln_ghi := line.new(bar_index, g_hi, bar_index + 1, g_hi, extend = extend.right, color = col_ghi, width = on_width, style = f_lineStyle(on_style))
        lb_ghi := label.new(bar_index, g_hi, "ONH " + str.tostring(g_hi, "#.##"), style = label.style_label_right, color = color.new(col_ghi, 80), textcolor = color.white, size = size.small)
        line.delete(ln_glo)
        label.delete(lb_glo)
        ln_glo := line.new(bar_index, g_lo, bar_index + 1, g_lo, extend = extend.right, color = col_glo, width = on_width, style = f_lineStyle(on_style))
        lb_glo := label.new(bar_index, g_lo, "ONL " + str.tostring(g_lo, "#.##"), style = label.style_label_right, color = color.new(col_glo, 80), textcolor = color.white, size = size.small)

// D2. Previous Day / Week High & Low
prev_day_high  = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
prev_day_low   = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_on)
prev_week_high = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_on)
prev_week_low  = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_on)

var line ln_pdh = na
var line ln_pdl = na
var line ln_pwh = na
var line ln_pwl = na
var label lb_pdh = na
var label lb_pdl = na
var label lb_pwh = na
var label lb_pwl = na
if barstate.islast
    if show_prev_day and not na(prev_day_high)
        if na(ln_pdh)
            ln_pdh := line.new(bar_index - 1, prev_day_high, bar_index, prev_day_high, extend = extend.both, color = col_pdh, width = pd_width, style = f_lineStyle(pd_style))
            lb_pdh := label.new(bar_index, prev_day_high, "PDH " + str.tostring(prev_day_high, "#.##"), style = label.style_label_left, color = color.new(col_pdh, 80), textcolor = color.white, size = size.small)
        else
            line.set_xy1(ln_pdh, bar_index - 1, prev_day_high)
            line.set_xy2(ln_pdh, bar_index, prev_day_high)
            label.set_xy(lb_pdh, bar_index, prev_day_high)
            label.set_text(lb_pdh, "PDH " + str.tostring(prev_day_high, "#.##"))
    if show_prev_day and not na(prev_day_low)
        if na(ln_pdl)
            ln_pdl := line.new(bar_index - 1, prev_day_low, bar_index, prev_day_low, extend = extend.both, color = col_pdl, width = pd_width, style = f_lineStyle(pd_style))
            lb_pdl := label.new(bar_index, prev_day_low, "PDL " + str.tostring(prev_day_low, "#.##"), style = label.style_label_left, color = color.new(col_pdl, 80), textcolor = color.white, size = size.small)
        else
            line.set_xy1(ln_pdl, bar_index - 1, prev_day_low)
            line.set_xy2(ln_pdl, bar_index, prev_day_low)
            label.set_xy(lb_pdl, bar_index, prev_day_low)
            label.set_text(lb_pdl, "PDL " + str.tostring(prev_day_low, "#.##"))
    if show_prev_week and not na(prev_week_high)
        if na(ln_pwh)
            ln_pwh := line.new(bar_index - 1, prev_week_high, bar_index, prev_week_high, extend = extend.both, color = col_pwh, width = pw_width, style = f_lineStyle(pw_style))
            lb_pwh := label.new(bar_index, prev_week_high, "PWH " + str.tostring(prev_week_high, "#.##"), style = label.style_label_left, color = color.new(col_pwh, 80), textcolor = color.white, size = size.small)
        else
            line.set_xy1(ln_pwh, bar_index - 1, prev_week_high)
            line.set_xy2(ln_pwh, bar_index, prev_week_high)
            label.set_xy(lb_pwh, bar_index, prev_week_high)
            label.set_text(lb_pwh, "PWH " + str.tostring(prev_week_high, "#.##"))
    if show_prev_week and not na(prev_week_low)
        if na(ln_pwl)
            ln_pwl := line.new(bar_index - 1, prev_week_low, bar_index, prev_week_low, extend = extend.both, color = col_pwl, width = pw_width, style = f_lineStyle(pw_style))
            lb_pwl := label.new(bar_index, prev_week_low, "PWL " + str.tostring(prev_week_low, "#.##"), style = label.style_label_left, color = color.new(col_pwl, 80), textcolor = color.white, size = size.small)
        else
            line.set_xy1(ln_pwl, bar_index - 1, prev_week_low)
            line.set_xy2(ln_pwl, bar_index, prev_week_low)
            label.set_xy(lb_pwl, bar_index, prev_week_low)
            label.set_text(lb_pwl, "PWL " + str.tostring(prev_week_low, "#.##"))

// D3. Wickless Candles (15m) with tick tolerance
[tf15_o, tf15_h, tf15_l, tf15_c, tf15_t] = request.security(syminfo.tickerid, "15", [open, high, low, close, time], lookahead = barmerge.lookahead_off)
cutoff_time = timestamp(syminfo.timezone, year(timenow, syminfo.timezone), month(timenow, syminfo.timezone), dayofmonth(timenow, syminfo.timezone) - wlc_days, 0, 0, 0)
tol_val = wlc_tolerance * syminfo.mintick
is_wickless_bull = (tf15_o - tf15_l) <= tol_val and (tf15_h - tf15_c) <= tol_val and tf15_c > tf15_o
is_wickless_bear = (tf15_h - tf15_o) <= tol_val and (tf15_c - tf15_l) <= tol_val and tf15_c < tf15_o
is_wickless = is_wickless_bull or is_wickless_bear
in_lookback = tf15_t >= cutoff_time
var array<box> wlc_boxes = array.new<box>()
if show_wlc and is_wickless and in_lookback and barstate.isconfirmed
    bx_col = is_wickless_bull ? col_wlc_bull : col_wlc_bear
    bx = box.new(bar_index, tf15_h, bar_index + 1, tf15_l, bgcolor = bx_col, border_color = bx_col, border_width = 1)
    array.push(wlc_boxes, bx)
    if array.size(wlc_boxes) > 120
        box.delete(array.shift(wlc_boxes))

// D4. Reference Grid
var array<line>  grid_lines  = array.new<line>()
var array<label> grid_labels = array.new<label>()
if show_grid and barstate.islast
    for ln in grid_lines
        line.delete(ln)
    for lb in grid_labels
        label.delete(lb)
    array.clear(grid_lines)
    array.clear(grid_labels)
    float price_mid   = (high + low) / 2
    float half_span   = grid_range * 20
    float grid_bottom = math.floor((price_mid - half_span) / grid_range) * grid_range
    float grid_top    = math.ceil((price_mid + half_span) / grid_range) * grid_range
    float lvl = grid_bottom
    while lvl <= grid_top
        ln_main = line.new(bar_index - 1, lvl, bar_index, lvl, extend = extend.both, color = col_grid, width = grid_width, style = f_lineStyle(grid_style))
        array.push(grid_lines, ln_main)
        lb_main = label.new(bar_index, lvl, str.tostring(lvl, "#.##"), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(col_grid, 20), size = size.tiny)
        array.push(grid_labels, lb_main)
        float lvl_20 = lvl + grid_range * 0.20
        ln_20 = line.new(bar_index - 1, lvl_20, bar_index, lvl_20, extend = extend.both, color = col_grid_20, width = grid_width, style = f_lineStyle(grid_style))
        array.push(grid_lines, ln_20)
        lb_20 = label.new(bar_index, lvl_20, str.tostring(lvl_20, "#.##"), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(col_grid_20, 10), size = size.tiny)
        array.push(grid_labels, lb_20)
        float lvl_80 = lvl + grid_range * 0.80
        ln_80 = line.new(bar_index - 1, lvl_80, bar_index, lvl_80, extend = extend.both, color = col_grid_20, width = grid_width, style = f_lineStyle(grid_style))
        array.push(grid_lines, ln_80)
        lb_80 = label.new(bar_index, lvl_80, str.tostring(lvl_80, "#.##"), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(col_grid_20, 10), size = size.tiny)
        array.push(grid_labels, lb_80)
        lvl := lvl + grid_range
else if not show_grid and barstate.islast
    for ln in grid_lines
        line.delete(ln)
    for lb in grid_labels
        label.delete(lb)
    array.clear(grid_lines)
    array.clear(grid_labels)

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION E — HoD / LoD TIMING
// ═════════════════════════════════════════════════════════════════════════════
grpE = "E · HoD / LoD Timing"
show_hodlod   = input.bool(true, "Show HoD/LoD Table", group = grpE)
hl_start      = input.string("09:30", "Range Start (HH:mm)", inline = "R", group = grpE)
hl_end        = input.string("16:00", "Range End (HH:mm)",   inline = "R", group = grpE)
hl_tz         = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "UTC", "Europe/London", "Asia/Tokyo"], group = grpE)
hl_pos        = input.string("Bottom Right", "Table Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpE)
show_hl_lines = input.bool(false, "Plot HoD/LoD Lines", inline = "HLL", group = grpE)
hl_width      = input.int(2, "Width", minval = 1, maxval = 4, inline = "HLL", group = grpE)
hod_col       = input.color(color.orange, "HoD color", inline = "HL", group = grpE)
lod_col       = input.color(color.aqua,   "LoD color", inline = "HL", group = grpE)

hl_sess = str.replace_all(hl_start, ":", "") + "-" + str.replace_all(hl_end, ":", "")
in_hl = not na(time(timeframe.period, hl_sess, hl_tz))
var float hod = na
var float lod = na
var int   hod_t = na
var int   lod_t = na
var int   rng_start_t = na
if in_hl and not in_hl[1]
    hod := high
    lod := low
    hod_t := time
    lod_t := time
    rng_start_t := time
else if in_hl
    if high > hod
        hod := high
        hod_t := time
    if low < lod
        lod := low
        lod_t := time
hod_min = not na(hod_t) and not na(rng_start_t) ? int((hod_t - rng_start_t) / 60000) : na
lod_min = not na(lod_t) and not na(rng_start_t) ? int((lod_t - rng_start_t) / 60000) : na

var table hlTable = na
if show_hodlod and barstate.islast
    if na(hlTable)
        hlTable := table.new(f_pos(hl_pos), 4, 3, border_width = 1, bgcolor = color.new(color.gray, 20))
    table.set_position(hlTable, f_pos(hl_pos))
    table.cell(hlTable, 0, 0, "HoD/LoD", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 10))
    table.cell(hlTable, 1, 0, "Price",   text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 10))
    table.cell(hlTable, 2, 0, "Min",     text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 10))
    table.cell(hlTable, 3, 0, "Interval",text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 10))
    table.cell(hlTable, 0, 1, "HoD",                          text_color = hod_col, text_size = size.small)
    table.cell(hlTable, 1, 1, str.tostring(hod, "#.##"),      text_color = hod_col, text_size = size.small)
    table.cell(hlTable, 2, 1, na(hod_min) ? "-" : str.tostring(hod_min), text_color = hod_col, text_size = size.small)
    table.cell(hlTable, 3, 1, f_interval(hod_min),            text_color = hod_col, text_size = size.small)
    table.cell(hlTable, 0, 2, "LoD",                          text_color = lod_col, text_size = size.small)
    table.cell(hlTable, 1, 2, str.tostring(lod, "#.##"),      text_color = lod_col, text_size = size.small)
    table.cell(hlTable, 2, 2, na(lod_min) ? "-" : str.tostring(lod_min), text_color = lod_col, text_size = size.small)
    table.cell(hlTable, 3, 2, f_interval(lod_min),            text_color = lod_col, text_size = size.small)

plot(show_hl_lines ? hod : na, "HoD Line", color = hod_col, style = plot.style_linebr, linewidth = hl_width)
plot(show_hl_lines ? lod : na, "LoD Line", color = lod_col, style = plot.style_linebr, linewidth = hl_width)

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION F — SESSION DISTRIBUTIONS  (boxes + table, ported from Quant Matrix)
// ═════════════════════════════════════════════════════════════════════════════
grpF = "F · Session Distributions"
show_dist_boxes = input.bool(true,  "Show Distribution Boxes",   inline = "DB", group = grpF)
show_dist_lbls  = input.bool(false, "Box Labels (avg range)",    inline = "DB", group = grpF)
show_dist_table = input.bool(true,  "Show Distribution Table",   group = grpF)
dist_show_pcts  = input.bool(false, "Table Values As Percent",   group = grpF)
filter_dow      = input.string("Total", "Average Mode", options = ["Total", "Day of Week"], group = grpF)
dist_tz         = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "UTC", "Europe/London", "Asia/Tokyo"], group = grpF)
dist_pos        = input.string("Middle Right", "Table Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpF)

s1 = input.session("0400-0800", "S1", inline = "S1", group = grpF)
c1 = input.color(color.new(color.blue, 70), "", inline = "S1", group = grpF)
s2 = input.session("0800-1200", "S2", inline = "S2", group = grpF)
c2 = input.color(color.new(color.red, 70),  "", inline = "S2", group = grpF)
s3 = input.session("1200-1600", "S3", inline = "S3", group = grpF)
c3 = input.color(color.new(color.teal, 70), "", inline = "S3", group = grpF)
s4 = input.session("1600-0400", "S4", inline = "S4", group = grpF)
c4 = input.color(color.new(color.gray, 70), "", inline = "S4", group = grpF)
dist_bg  = input.color(color.new(color.black, 20), "Table BG", inline = "DS", group = grpF)
dist_txt = input.color(color.white, "Text", inline = "DS", group = grpF)
dist_bd  = input.color(color.new(color.gray, 40), "Border", inline = "DS", group = grpF)
dist_hl  = input.color(color.new(color.blue, 65), "Highlight today's column (DOW mode)", group = grpF)

var s1_stats = ses_stats.new(array.new_float(), array.new_float(), array.new_int(), array.new<box>(), array.new<label>(), s1, c1)
var s2_stats = ses_stats.new(array.new_float(), array.new_float(), array.new_int(), array.new<box>(), array.new<label>(), s2, c2)
var s3_stats = ses_stats.new(array.new_float(), array.new_float(), array.new_int(), array.new<box>(), array.new<label>(), s3, c3)
var s4_stats = ses_stats.new(array.new_float(), array.new_float(), array.new_int(), array.new<box>(), array.new<label>(), s4, c4)

s1_stats.update_ses(s1, dist_tz, show_dist_boxes, show_dist_lbls)
s2_stats.update_ses(s2, dist_tz, show_dist_boxes, show_dist_lbls)
s3_stats.update_ses(s3, dist_tz, show_dist_boxes, show_dist_lbls)
s4_stats.update_ses(s4, dist_tz, show_dist_boxes, show_dist_lbls)

// Distribution table — Quant-Matrix style. Total mode: one avg column.
// Day-of-Week mode: full sessions x weekday matrix, today's column highlighted.
var table distTable = na
if show_dist_table and barstate.islast
    array<ses_stats> allStats = array.from(s1_stats, s2_stats, s3_stats, s4_stats)
    array<int>       dows = array.from(2, 3, 4, 5, 6)
    array<string>    dnms = array.from("Mon", "Tue", "Wed", "Thu", "Fri")
    bool   byDow  = filter_dow == "Day of Week"
    int    curDow = dayofweek
    string suf    = dist_show_pcts ? "%" : ""
    color  hdrBg  = color.new(color.black, 10)
    if na(distTable)
        distTable := table.new(f_pos(dist_pos), 6, 5, bgcolor = dist_bg, border_color = dist_bd, border_width = 1)
    table.set_position(distTable, f_pos(dist_pos))
    // Header
    table.cell(distTable, 0, 0, byDow ? "Session" : "Distributions", text_color = dist_txt, text_size = size.small, bgcolor = hdrBg, text_halign = text.align_left)
    if byDow
        for d = 0 to 4
            bool today = array.get(dows, d) == curDow
            table.cell(distTable, d + 1, 0, array.get(dnms, d), text_color = dist_txt, text_size = size.small, bgcolor = today ? dist_hl : hdrBg, text_halign = text.align_right)
    else
        table.cell(distTable, 1, 0, dist_show_pcts ? "avg %" : "avg", text_color = dist_txt, text_size = size.small, bgcolor = hdrBg, text_halign = text.align_right)
    // Session rows
    for r = 0 to array.size(allStats) - 1
        ses_stats    st   = array.get(allStats, r)
        array<float> vals = dist_show_pcts ? st.range_pcts : st.ranges
        table.cell(distTable, 0, r + 1, "S" + str.tostring(r + 1) + " " + st.session, text_color = color.new(st.obj_color, 0), text_size = size.small, text_halign = text.align_left)
        if byDow
            for d = 0 to 4
                int   dw    = array.get(dows, d)
                float av    = f_avg_ses(vals, st.day, true, dw)
                bool  today = dw == curDow
                table.cell(distTable, d + 1, r + 1, na(av) ? "-" : str.tostring(av, "#.##") + suf, text_color = dist_txt, text_size = size.small, bgcolor = today ? dist_hl : na, text_halign = text.align_right)
        else
            float av = f_avg_ses(vals, st.day, false, 0)
            table.cell(distTable, 1, r + 1, na(av) ? "-" : str.tostring(av, "#.##") + suf, text_color = dist_txt, text_size = size.small, text_halign = text.align_right)
````
