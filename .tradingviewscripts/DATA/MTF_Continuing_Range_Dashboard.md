<!-- tradingview-pine-id: PUB;4fb5ddb545d94177b030396e30127e5e -->
<!-- tradingviewscripts-format: 1 -->
# MTF Continuing Range Dashboard

Source: https://www.tradingview.com/script/497HIZbi-MTF-Continuing-Range-Dashboard/

## Description

Multi-Timeframe Continuing Range Dashboard

This indicator tracks a simple, purely mechanical price-action concept — a "Continuing Range" — across up to 5 timeframes at once, and summarizes them in a compact on-chart dashboard so you don't have to flip between charts to see market structure at every timeframe.

Core Concept
A range is defined by a single candle's high and low. That range stays active — untouched — for as long as every following candle closes back inside it. The moment a candle closes above the range high or below the range low, that breakout candle's own high/low becomes the new active range, and the process repeats. The range is intentionally fixed once set: it does not expand to absorb later candles' wicks — it only holds until an actual close breaks it.

This gives a clean read on directional bias: is price currently expanding (range recently broken up or down), or still contained inside its last established range?

Dashboard

Choose up to 5 timeframes in settings (e.g. 5m, 15m, 30m, 1H, 2H).
The table shows one row per state: CR (Current Range direction) plus optional PR1...PR5 (Previous Range directions, going back further in history).
Each cell shows a green ▲ if that range's direction is up, or a red ▼ if down, for instant visual alignment across timeframes.
Hover any CR cell for a tooltip with that range's exact high/low.
Set "Previous Number of Ranges" to 0 to show only the current range, or up to 5 to see recent range history per timeframe.

Settings

5 independent timeframe selectors
Number of previous ranges to display (0–5)
Table position, text size, and custom colors for up/down/neutral states

Notes

Calculations use only confirmed (closed) candles at each selected timeframe — intrabar price movement does not affect the displayed state, so values only update once a candle on that timeframe actually finishes.
Like any multi-timeframe tool using request.security(), the values for the most recent, still-forming bar on higher timeframes reflect the last fully closed state and will update once that bar closes.
This is a structural/context tool, not a buy/sell signal generator. It's meant to help you quickly see directional bias and range status across timeframes — always combine with your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator("MTF Continuing Range Dashboard", overlay=true)

// ───────────────────────────────
// INPUTS
// ───────────────────────────────
grpTF = "Timeframes"
tf1 = input.timeframe("5",   "Timeframe 1", group=grpTF)
tf2 = input.timeframe("15",  "Timeframe 2", group=grpTF)
tf3 = input.timeframe("30",  "Timeframe 3", group=grpTF)
tf4 = input.timeframe("60",  "Timeframe 4", group=grpTF)
tf5 = input.timeframe("120", "Timeframe 5", group=grpTF)

grpTable   = "Dashboard"
prevCount  = input.int(2, "Previous Number of Ranges", minval=0, maxval=5, group=grpTable)
tablePos   = input.string("Top Right", "Table Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right","Middle Right"], group=grpTable)
textSize   = input.string("Normal", "Text Size", options=["Small","Normal","Large"], group=grpTable)
upColor    = input.color(color.new(color.green, 0), "Up Color", group=grpTable)
downColor  = input.color(color.new(color.red, 0),   "Down Color", group=grpTable)
neutralCol = input.color(color.new(color.gray, 0),  "Neutral Color", group=grpTable)
headerBg   = input.color(color.new(color.black, 0), "Header Background", group=grpTable)

f_pos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.middle_right

f_size(s) =>
    switch s
        "Small" => size.small
        "Large" => size.large
        => size.normal

// ───────────────────────────────
// CORE RANGE LOGIC (per timeframe context)
// Tracks current range (CR) plus up to 5 previous range directions (PR1..PR5)
// PR1 = the range immediately before CR, PR2 = the one before that, etc.
// ───────────────────────────────
f_rangeState() =>
    var float rHigh = na
    var float rLow  = na
    var int   dir   = 0   // current range direction
    var int   pr1   = 0
    var int   pr2   = 0
    var int   pr3   = 0
    var int   pr4   = 0
    var int   pr5   = 0

    // IMPORTANT: only mutate state on a CONFIRMED (closed) bar of this timeframe.
    // Without this guard, request.security() re-evaluates on every intrabar tick
    // of the still-forming candle, which can trigger false breakouts/shifts before
    // that candle has actually closed -- corrupting CR/PR history with noise.
    if barstate.isconfirmed
        if na(rHigh)
            // first bar seen on this timeframe: seed the range
            rHigh := high
            rLow  := low
            dir   := 0
        else
            bool brokeUp   = close > rHigh
            bool brokeDown = close < rLow
            if brokeUp or brokeDown
                // breakout -> current range becomes "previous", shift history down
                pr5 := pr4
                pr4 := pr3
                pr3 := pr2
                pr2 := pr1
                pr1 := dir
                dir := brokeUp ? 1 : -1
                rHigh := high
                rLow  := low
            // else: still inside the active range -> rangeHigh/rangeLow stay
            // FIXED, exactly as they were set by the breakout candle. The range
            // does NOT expand to include later candles' highs/lows -- it only
            // "extends" in time visually. This matches the reference behavior.

    [dir, pr1, pr2, pr3, pr4, pr5, rHigh, rLow]

// ───────────────────────────────
// PULL STATE FOR EACH SELECTED TIMEFRAME
// ───────────────────────────────
[dir1, dir1p1, dir1p2, dir1p3, dir1p4, dir1p5, rh1, rl1] = request.security(syminfo.tickerid, tf1, f_rangeState())
[dir2, dir2p1, dir2p2, dir2p3, dir2p4, dir2p5, rh2, rl2] = request.security(syminfo.tickerid, tf2, f_rangeState())
[dir3, dir3p1, dir3p2, dir3p3, dir3p4, dir3p5, rh3, rl3] = request.security(syminfo.tickerid, tf3, f_rangeState())
[dir4, dir4p1, dir4p2, dir4p3, dir4p4, dir4p5, rh4, rl4] = request.security(syminfo.tickerid, tf4, f_rangeState())
[dir5, dir5p1, dir5p2, dir5p3, dir5p4, dir5p5, rh5, rl5] = request.security(syminfo.tickerid, tf5, f_rangeState())

// helper to fetch the Nth previous direction (n = 1..5) for a given timeframe's set
f_getPrev(n, p1, p2, p3, p4, p5) =>
    switch n
        1 => p1
        2 => p2
        3 => p3
        4 => p4
        5 => p5
        => 0

// ───────────────────────────────
// DASHBOARD TABLE
// ───────────────────────────────
totalRows = 2 + prevCount   // header + CR + N previous rows
var table dash = table.new(f_pos(tablePos), 6, totalRows, border_width=1, border_color=color.new(color.gray, 50))

f_arrowCell(col, row, dir, tip) =>
    txt  = dir == 1 ? "▲" : dir == -1 ? "▼" : "–"
    col_ = dir == 1 ? upColor : dir == -1 ? downColor : neutralCol
    table.cell(dash, col, row, txt, bgcolor=color.new(col_, 80), text_color=col_,
         text_size=f_size(textSize), tooltip=tip)

if barstate.islast
    // header row (row 0): timeframe names
    table.cell(dash, 0, 0, "Range", bgcolor=headerBg, text_color=color.white, text_size=f_size(textSize))
    table.cell(dash, 1, 0, tf1,     bgcolor=headerBg, text_color=color.white, text_size=f_size(textSize))
    table.cell(dash, 2, 0, tf2,     bgcolor=headerBg, text_color=color.white, text_size=f_size(textSize))
    table.cell(dash, 3, 0, tf3,     bgcolor=headerBg, text_color=color.white, text_size=f_size(textSize))
    table.cell(dash, 4, 0, tf4,     bgcolor=headerBg, text_color=color.white, text_size=f_size(textSize))
    table.cell(dash, 5, 0, tf5,     bgcolor=headerBg, text_color=color.white, text_size=f_size(textSize))

    // row 1: CR (current range)
    table.cell(dash, 0, 1, "CR", bgcolor=headerBg, text_color=color.white, text_size=f_size(textSize))
    f_arrowCell(1, 1, dir1, "H: " + str.tostring(rh1) + "  L: " + str.tostring(rl1))
    f_arrowCell(2, 1, dir2, "H: " + str.tostring(rh2) + "  L: " + str.tostring(rl2))
    f_arrowCell(3, 1, dir3, "H: " + str.tostring(rh3) + "  L: " + str.tostring(rl3))
    f_arrowCell(4, 1, dir4, "H: " + str.tostring(rh4) + "  L: " + str.tostring(rl4))
    f_arrowCell(5, 1, dir5, "H: " + str.tostring(rh5) + "  L: " + str.tostring(rl5))

    // rows 2..(1+prevCount): PR1..PRN (previous ranges)
    // Guarded explicitly: Pine's default "for X to Y" auto-reverses direction
    // when X > Y (e.g. "for n = 1 to 0" would otherwise still run for n=1,0),
    // which would try to write a table row that doesn't exist when prevCount=0.
    if prevCount > 0
        for n = 1 to prevCount
            rowIdx = 1 + n
            table.cell(dash, 0, rowIdx, "PR" + str.tostring(n), bgcolor=headerBg, text_color=color.white, text_size=f_size(textSize))
            f_arrowCell(1, rowIdx, f_getPrev(n, dir1p1, dir1p2, dir1p3, dir1p4, dir1p5), "")
            f_arrowCell(2, rowIdx, f_getPrev(n, dir2p1, dir2p2, dir2p3, dir2p4, dir2p5), "")
            f_arrowCell(3, rowIdx, f_getPrev(n, dir3p1, dir3p2, dir3p3, dir3p4, dir3p5), "")
            f_arrowCell(4, rowIdx, f_getPrev(n, dir4p1, dir4p2, dir4p3, dir4p4, dir4p5), "")
            f_arrowCell(5, rowIdx, f_getPrev(n, dir5p1, dir5p2, dir5p3, dir5p4, dir5p5), "")
````
