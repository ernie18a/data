# Multi-Timeframe Candle Open Tracker (R2F Trading)

- url: https://www.tradingview.com/script/YtXlkX47-Multi-Timeframe-Candle-Open-Tracker-R2F-Trading/
- type: indicator
- pine_id: PUB;95376bdf819b458f985114cd987acf2d
- version: 3.0

## Description

Multi-Timeframe Candle Open Tracker

A compact table that shows which candles are opening a fresh bar right now and which open on the next bar, across four groups of timeframes at the same time: hourly, daily, weekly, and monthly.

The table sits in the corner of your chart. Each group has a NOW row and a NEXT row. A green cell means a new candle of that timeframe is opening, and a red cell means it is not. If you are trading off the 4H and want to know whether the 8H and 12H are also turning over on the current bar, you can read it from the table instead of flipping between timeframes.

What it covers:
- HOUR: 1H through 12H
- DAY: 1D through 5D
- WEEK: 1W through 4W
- MONTH: 1M through 12M

How the timing works

The readout is calculated from the clock and the calendar rather than from the chart you happen to be on, so the table shows the same thing on a 1-minute chart and on a 6-month chart. Many candle-open tools break when the chart timeframe is higher than the candle being checked, because their data source either collapses every sub-period together or lags a full period behind. This one avoids that by deriving each candle boundary directly from the date.

Multi-period candles are anchored the way TradingView builds them. Multi-month candles align to the calendar year, so a new 6M candle opens in January and July, quarters break on January, April, July, and October, and a 12M candle opens each January. Weekly multiples align to the ISO week. Daily multiples run as a continuous Monday-to-Friday trading-day count, so a 5D candle matches a trading week while the shorter multiples cycle through without resetting every Monday.

Market closure

For markets that close, such as forex over the weekend, the hour and day rows detect when the daily candle has stopped rolling. While the market is shut, nothing reads as opening now, and the next bar is treated as the reopen, where the hourly candles all reset and open together. The same reset applies at each normal day boundary, so the final hour of the session shows every hourly candle opening next.

Settings

- Table position and text size
- A top-margin control that drops the table below the symbol overlay on mobile, with no effect on your desktop layout
- Show and hide toggles for the hour, day, week, and month sections
- An optional grey divider between sections, with adjustable thickness
- Colour control for the open and closed cells, the section headers, the dividers, and the grid

Notes

The hour and day rows assume a 24-hour daily candle, which fits forex and crypto. The daily multiples 2D, 3D, and 4D are anchored to the start of the year; 1D and 5D are exact, and you can check the in-between multiples against a 3D or 4D chart if your broker anchors them differently. The day row currently treats both Saturday and Sunday as closed, so during the Sunday forex reopen the daily section reads as closed while price is already moving.

Works on any asset and any chart timeframe.

- R2F Trading

## Source Code

````pine
// ─────────────────────────────────────────────────────────
// Multi-Timeframe Candle Open Tracker v6
// Shows which timeframes are opening a NEW candle now and next:
//   HOUR  : 1H–12H   (current / next hour)
//   DAY   : 1D–4D    (current / next day)
//   WEEK  : 1W–3W    (current / next week)
//   MONTH : 1M–12M   (current / next month)
// Green = new candle opening | Red = no new candle
//
// METHOD
//   Hourly  : counts hours since the exchange's actual daily open,
//             then checks divisibility. Pure clock, every timeframe.
//   Month   : year-anchored. A new N-month candle opens when
//             (month - 1) % N == 0, which is how TradingView builds
//             them (6M opens Jan & Jul, quarters Jan/Apr/Jul/Oct).
//   Day/Week: for each multiple the script asks the daily (or weekly)
//             series how many bars have passed since that multiple
//             last opened, using ta.barssince on timeframe.change.
//             That follows TradingView's own candle boundaries, so it
//             is correct regardless of session open time, weekends or
//             holidays. Position 0 = opening now; last bar = opening
//             next.
//
// LIMITS
//   • Works on any chart timeframe. On a chart above daily the day
//     section reads the daily bars inside the current bar and takes the
//     most recent as "today"; the week section does the same above
//     weekly. At or below the base unit it uses a normal request.
//   • Multiples beyond the read set (above 4D or 3W) show a neutral
//     dot, as can the very first bars of available history.
//   • Hour rows assume a 24-hour daily candle (forex / crypto).
//
// MARKET CLOSED (forex weekend / session gap)
//   When the daily candle hasn't rolled for 24h+, the hour row treats
//   the market as closed: nothing opens "now", and the next bar is the
//   reopen, where the hourly candles all reset and open together (so
//   NEXT lights every hourly cell).
//
// Works on any asset, any market, any chart timeframe.
// ─────────────────────────────────────────────────────────
//@version=6
indicator("Multi-Timeframe Candle Open Tracker", overlay = true)

// ── INPUTS: layout ──────────────────────────────────────
i_textSize  = input.string("tiny", "Text Size", options = ["tiny", "small", "normal", "large", "huge"], group = "Layout")
i_position  = input.string("top_right", "Table Position", options = ["top_right", "top_center", "top_left", "bottom_right", "bottom_center", "bottom_left"], group = "Layout")
i_topPad    = input.int(0, "Top Margin (rows)", minval = 0, maxval = 12, tooltip = "Pushes the table down so it clears the symbol/price overlay. Leave at 0 on desktop; raise to ~3–5 on a mobile layout. Settings save per layout, so this won't affect your PC.", group = "Layout")
i_showSep   = input.bool(true, "Separator Between Sections", group = "Layout")
i_sepHeight = input.float(0.1, "Separator Height (% of chart)", minval = 0.1, maxval = 5.0, step = 0.1, tooltip = "Thickness of the grey divider rows. Lower = thinner; 0.1 is a hairline. Raise toward 1 for a chunkier divider.", group = "Layout")

// ── INPUTS: sections ────────────────────────────────────
i_showHour  = input.bool(true, "Show HOUR", group = "Sections")
i_showDay   = input.bool(true, "Show DAY",  group = "Sections")
i_showWeek  = input.bool(true, "Show WEEK", group = "Sections")
i_showMonth = input.bool(true, "Show MONTH", group = "Sections")

// ── INPUTS: periods (controls table WIDTH) ──────────────
// Comma-separated lists. Fewer entries = a narrower table.
// On a mobile layout, trim these to just what you watch;
// settings save per layout, so your desktop stays full.
i_hours   = input.string("1,2,3,4,5,6,7,8,9,10,11,12", "Hours",  group = "Periods", tooltip = "Which hourly candles to show, e.g. 1,2,4,12. Fewer columns = smaller table.")
i_days    = input.string("1,2,3,4",                    "Days",   group = "Periods", tooltip = "2D-4D are phase-locked to TradingView's real candles, so they match your chart on any timeframe. A neutral dot means the boundary wasn't available at the current zoom.")
i_weeks   = input.string("1,2,3",                      "Weeks",  group = "Periods", tooltip = "2W-3W are phase-locked to TradingView's real candles. A neutral dot means the boundary wasn't available at the current zoom.")
i_months  = input.string("1,2,3,4,5,6,7,8,9,10,11,12", "Months", group = "Periods")

// ── INPUTS: colours ─────────────────────────────────────
i_colorOpen   = input.color(color.new(#00C853, 0), "New Candle (Open)", group = "Colours")
i_colorClosed = input.color(color.new(#FF1744, 0), "No New Candle",      group = "Colours")
i_titleBg     = input.color(color.new(#0F1419, 0), "Section Title Background", group = "Colours")
i_titleTxt    = input.color(color.new(#4DD0E1, 0), "Section Title Text",       group = "Colours")
i_headerBg    = input.color(color.new(#1E1E1E, 0), "Row Background",  group = "Colours")
i_headerTxt   = input.color(color.new(#FFFFFF, 0), "Period Label Text", group = "Colours")
i_rowTxt      = input.color(color.new(#90A4AE, 0), "NOW / NEXT Text",   group = "Colours")
i_cellTxt     = input.color(color.new(#FFFFFF, 0), "Marker Text",       group = "Colours")
i_sepColor    = input.color(color.new(#808080, 0), "Separator Colour",  group = "Colours")
i_grid        = input.color(color.new(#2A2A2A, 0), "Grid Border",       group = "Colours")

// ── RESOLVE ENUMS ───────────────────────────────────────
_pos = switch i_position
    "top_right"     => position.top_right
    "top_center"    => position.top_center
    "top_left"      => position.top_left
    "bottom_right"  => position.bottom_right
    "bottom_center" => position.bottom_center
    "bottom_left"   => position.bottom_left
    => position.top_right

_size = switch i_textSize
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    "huge"   => size.huge
    => size.tiny

// Section titles render one step larger than the rest.
_titleSize = switch i_textSize
    "tiny"   => size.small
    "small"  => size.normal
    "normal" => size.large
    "large"  => size.huge
    "huge"   => size.huge
    => size.small

// ── HOURLY DETECTION ────────────────────────────────────
// Anchored to the exchange's actual daily open. Hourly candles
// all reset at each new day (hour 0), so they open together there.
// If the daily candle hasn't rolled for 24h+ (e.g. the forex
// weekend), the market is treated as closed: nothing opens "now",
// and the next bar is the reopen -> every hourly candle opens.
// Assumes a 24-hour daily candle (forex / crypto).
dailyOpenTime    = request.security(syminfo.tickerid, "D", time)
int msPerHour    = 60 * 60 * 1000
int hoursElapsed = int(math.floor((timenow - dailyOpenTime) / msPerHour))
bool _mktClosed  = hoursElapsed >= 24               // daily candle didn't roll -> market closed
int  _hWrap      = (hoursElapsed + 1) % 24          // next hour, wrapped at the day boundary

hNow(int n)  => not _mktClosed and (hoursElapsed % n == 0)
hNext(int n) => _mktClosed or (_hWrap % n == 0)

// ── MONTH POSITION (from the monthly candle's own open) ─────────
// A new N-month candle opens when (month - 1) % N == 0, the way
// TradingView anchors them to the year (6M -> Jan & Jul, quarters ->
// Jan/Apr/Jul/Oct). The month is taken from the monthly candle's open
// rather than the wall clock: on futures the monthly candle opens on
// the prior evening's session, so month(timenow) can still report the
// old month for a few hours after TradingView has rolled the candle.
// Nudging the open ~15 days forward lands inside the new month's body
// and matches the chart. Falls back to the wall clock only if the
// monthly open isn't available (a chart above monthly).
_mOpen  = request.security(syminfo.tickerid, "1M", time, lookahead = barmerge.lookahead_on)
int _cm = na(_mOpen) ? month(timenow, syminfo.timezone) : month(_mOpen + 15 * 86400000, syminfo.timezone)
int _nm = _cm % 12 + 1                             // next month

// ── DAY / WEEK POSITION (counts TradingView's own bars, any chart) ─
// For each multiple we read, on the daily (or weekly) series, how many
// bars have passed since it last opened (ta.barssince on
// timeframe.change). That uses TradingView's real boundaries, so it is
// immune to session opens, weekends and holidays. To make it read on
// every chart, each multiple is fetched two ways and chosen by the
// chart timeframe:
//   chart at / below the base unit -> a normal higher-timeframe request
//   chart above the base unit      -> a lower-timeframe request, taking
//                                     the most recent sub-bar as "today"
// ignore_invalid_timeframe makes the lower-timeframe call return an
// empty array (instead of erroring) on charts where it doesn't apply,
// so both calls run every bar and the right one is picked.
//   position 0   = the multiple opens this period
//   position n-1 = its last bar, so the next one opens a fresh multiple
bool _chartLEDay  = timeframe.in_seconds() <= timeframe.in_seconds("1D")
bool _chartLEWeek = timeframe.in_seconds() <= timeframe.in_seconds("1W")

_hD2 = request.security(syminfo.tickerid, "1D", ta.barssince(timeframe.change("2D")), lookahead = barmerge.lookahead_on)
_hD3 = request.security(syminfo.tickerid, "1D", ta.barssince(timeframe.change("3D")), lookahead = barmerge.lookahead_on)
_hD4 = request.security(syminfo.tickerid, "1D", ta.barssince(timeframe.change("4D")), lookahead = barmerge.lookahead_on)
_hW2 = request.security(syminfo.tickerid, "1W", ta.barssince(timeframe.change("2W")), lookahead = barmerge.lookahead_on)
_hW3 = request.security(syminfo.tickerid, "1W", ta.barssince(timeframe.change("3W")), lookahead = barmerge.lookahead_on)

_lD2 = request.security_lower_tf(syminfo.tickerid, "1D", ta.barssince(timeframe.change("2D")), ignore_invalid_timeframe = true)
_lD3 = request.security_lower_tf(syminfo.tickerid, "1D", ta.barssince(timeframe.change("3D")), ignore_invalid_timeframe = true)
_lD4 = request.security_lower_tf(syminfo.tickerid, "1D", ta.barssince(timeframe.change("4D")), ignore_invalid_timeframe = true)
_lW2 = request.security_lower_tf(syminfo.tickerid, "1W", ta.barssince(timeframe.change("2W")), ignore_invalid_timeframe = true)
_lW3 = request.security_lower_tf(syminfo.tickerid, "1W", ta.barssince(timeframe.change("3W")), ignore_invalid_timeframe = true)

// Most recent sub-bar of a lower-timeframe array, or na when empty.
// sz seeds v as a series int so it can be reassigned, and array.last
// is only touched when the array actually has elements.
f_last(array<int> a) =>
    int sz = array.size(a)
    int v  = sz
    if sz > 0
        v := array.last(a)
    else
        v := na
    v

// Pick the higher-timeframe read at/below the base unit, else the
// latest lower-timeframe sub-bar from the chart above it.
f_pickD(int hv, array<int> a) => _chartLEDay  ? hv : f_last(a)
f_pickW(int hv, array<int> a) => _chartLEWeek ? hv : f_last(a)

// Position within the n-period candle (0-indexed). 1 always opens.
// na for multiples beyond the read set, which renders a neutral dot.
f_posD(int n) =>
    switch n
        1 => 0
        2 => f_pickD(_hD2, _lD2)
        3 => f_pickD(_hD3, _lD3)
        4 => f_pickD(_hD4, _lD4)
        => na
f_posW(int n) =>
    switch n
        1 => 0
        2 => f_pickW(_hW2, _lW2)
        3 => f_pickW(_hW3, _lW3)
        => na

// ── OPEN-NOW / OPEN-NEXT TESTS ──────────────────────────
// Months: year-anchored, matches how TradingView builds them.
mNow(int n)  => (_cm - 1) % n == 0
mNext(int n) => (_nm - 1) % n == 0
// Days / weeks: opening now at position 0, opening next on the last
// bar of the multiple. An na position carries through to a dot.
dNow(int n)  => f_posD(n) == 0
dNext(int n) => f_posD(n) == n - 1
wNow(int n)  => f_posW(n) == 0
wNext(int n) => f_posW(n) == n - 1

// ── PERIOD LISTS -> COLUMN LAYOUT ───────────────────────
// Parse a "1,2,4" string into an int array. The number of
// visible periods sets how wide the table is.
f_parse(string csv) =>
    string clean = str.replace_all(csv, " ", "")
    array<string> parts = str.split(clean, ",")
    array<int> out = array.new<int>()
    for s in parts
        float v = str.tonumber(s)
        if not na(v) and v >= 1 and array.size(out) < 20
            array.push(out, int(v))
    out

hP = f_parse(i_hours)
dP = f_parse(i_days)
wP = f_parse(i_weeks)
mP = f_parse(i_months)

int _hN     = i_showHour  ? array.size(hP) : 0
int _dN     = i_showDay   ? array.size(dP) : 0
int _wN     = i_showWeek  ? array.size(wP) : 0
int _mN     = i_showMonth ? array.size(mP) : 0
int _maxP   = int(math.max(math.max(_hN, _dN), math.max(_wN, _mN)))   // widest visible section
int _lastCol = _maxP                                                  // last visible column

// ── DRAW HELPERS ────────────────────────────────────────
// Thin full-width divider row.
f_sep(table tbl, int row) =>
    for c = 0 to _lastCol
        table.cell(tbl, c, row, "", bgcolor = i_sepColor, text_size = size.tiny, height = i_sepHeight)

// One section: title bar + NOW row + NEXT row.
// `periods` is the list of timeframe numbers to show in this section.
f_section(table tbl, int row, string title, string suf, periods, nowA, nextA) =>
    int n = array.size(periods)
    // Title bar (larger accent text)
    table.cell(tbl, 0, row, title, bgcolor = i_titleBg, text_color = i_titleTxt, text_size = _titleSize)
    for c = 1 to _maxP
        string lbl = c <= n ? str.tostring(array.get(periods, c - 1)) + suf : ""
        table.cell(tbl, c, row, lbl, bgcolor = i_titleBg, text_color = i_headerTxt, text_size = _size)
    // NOW
    table.cell(tbl, 0, row + 1, "NOW", bgcolor = i_headerBg, text_color = i_rowTxt, text_size = _size)
    for c = 1 to _maxP
        if c <= n
            int op = array.get(nowA, c - 1)
            string mk = na(op) ? "·" : (op == 1 ? "●" : "○")
            color  bg = na(op) ? i_headerBg : (op == 1 ? i_colorOpen : i_colorClosed)
            table.cell(tbl, c, row + 1, mk, bgcolor = bg, text_color = i_cellTxt, text_size = _size)
        else
            table.cell(tbl, c, row + 1, "", bgcolor = i_headerBg, text_size = _size)
    // NEXT
    table.cell(tbl, 0, row + 2, "NEXT", bgcolor = i_headerBg, text_color = i_rowTxt, text_size = _size)
    for c = 1 to _maxP
        if c <= n
            int op = array.get(nextA, c - 1)
            string mk = na(op) ? "·" : (op == 1 ? "●" : "○")
            color  bg = na(op) ? i_headerBg : (op == 1 ? i_colorOpen : i_colorClosed)
            table.cell(tbl, c, row + 2, mk, bgcolor = bg, text_color = i_cellTxt, text_size = _size)
        else
            table.cell(tbl, c, row + 2, "", bgcolor = i_headerBg, text_size = _size)

// ── BUILD TABLE ─────────────────────────────────────────
var table t = table.new(_pos, 22, 22, border_width = 1, border_color = i_grid)

if barstate.islast
    table.clear(t, 0, 0, 21, 21)

    // HOUR arrays (1 = opening, 0 = not; na = unavailable for day/week)
    nowH = array.new<int>()
    nextH = array.new<int>()
    for p in hP
        array.push(nowH, hNow(p) ? 1 : 0)
        array.push(nextH, hNext(p) ? 1 : 0)

    // DAY arrays
    nowD = array.new<int>()
    nextD = array.new<int>()
    for p in dP
        array.push(nowD, dNow(p) ? 1 : 0)
        array.push(nextD, dNext(p) ? 1 : 0)

    // WEEK arrays
    nowW = array.new<int>()
    nextW = array.new<int>()
    for p in wP
        array.push(nowW, wNow(p) ? 1 : 0)
        array.push(nextW, wNext(p) ? 1 : 0)

    // MONTH arrays
    nowM = array.new<int>()
    nextM = array.new<int>()
    for p in mP
        array.push(nowM, mNow(p) ? 1 : 0)
        array.push(nextM, mNext(p) ? 1 : 0)

    // ── Layout cursor ──
    int r = 0
    // Top margin: one transparent multi-line cell reserves vertical space
    if i_topPad > 0
        string pad = ""
        for k = 1 to i_topPad
            pad := pad + "\n"
        table.cell(t, 0, 0, pad, text_color = color.new(color.white, 100), bgcolor = color.new(color.white, 100), text_size = _size)
        r := 1

    bool prev = false
    if i_showHour
        f_section(t, r, "HOUR", "H", hP, nowH, nextH)
        r += 3
        prev := true
    if i_showDay
        if prev and i_showSep
            f_sep(t, r)
            r += 1
        f_section(t, r, "DAY", "D", dP, nowD, nextD)
        r += 3
        prev := true
    if i_showWeek
        if prev and i_showSep
            f_sep(t, r)
            r += 1
        f_section(t, r, "WEEK", "W", wP, nowW, nextW)
        r += 3
        prev := true
    if i_showMonth
        if prev and i_showSep
            f_sep(t, r)
            r += 1
        f_section(t, r, "MONTH", "M", mP, nowM, nextM)
        r += 3
        prev := true

// ── END ─────────────────────────────────────────────────
````
