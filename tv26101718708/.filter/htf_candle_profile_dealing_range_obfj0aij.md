# HTF Candle Profile & Dealing Range

- url: https://www.tradingview.com/script/obFj0Aij-HTF-Candle-Profile-Dealing-Range/
- type: indicator
- pine_id: PUB;c2b9a7c2d9874ffa8622696910846529
- version: 2.0

## Description

Built around the concept of HTF candle profiling and dealing ranges.

When a new HTF candle opens, the open line gives you an immediate reference point to profile price from. For a bullish candle formation, price typically trades lower first to form its wick before expanding higher and then closing. You are looking to spot the protraction phase (aka wick formation) of the HTF candle you are trading to then align yourself with the body (aka the expansion phase of the candle). The open line is your reference for validating the profile and confirming the candle is behaving as expected.

For bearish it is the mirror. Price trades high first to form the wick, then expands lower to create the candle body and then closes.

The EQ of the previous candle's dealing range acts as your continuation/invalidation level. In a true expansion, price should not make deep retracements back into the prior range. A breach of EQ questions the move. If price holds and continues, you stay in and target the prior swing high or low along with whatever HTF draws you have mapped beyond that.

The dealing range, wick high to wick low of the previous HTF candle, gives you the full boundary of where price came from and what it needs to respect or break to confirm the next move.

Auto-detects your chart timeframe. No manual setup needed.

Pairings: M1/M15 · M3/M30 · M5/1H · M15/4H · M90/6H · 1H/1D · 4H/1W

## Source Code

````pine
//@version=5
//nevels
indicator("HTF Candle Profile & Dealing Ranges", overlay=true, max_lines_count=20, max_labels_count=20)

// ─────────────────────────────────────────────────────────────────
// SETTINGS — OPEN LINE
// ─────────────────────────────────────────────────────────────────
openColor      = input.color(color.new(color.gray, 0), "Open Line Color",           group="Open Line")
openWidth      = input.int(1,   "Open Line Width",                                  group="Open Line", minval=1, maxval=4)
openStyle      = input.string("Dotted", "Open Line Style",                         group="Open Line", options=["Solid", "Dashed", "Dotted"])

// ─────────────────────────────────────────────────────────────────
// SETTINGS — EQ LINE
// ─────────────────────────────────────────────────────────────────
eqColor        = input.color(color.new(color.red, 0),  "EQ Line Color",             group="EQ Line")
eqWidth        = input.int(1,   "EQ Line Width",                                    group="EQ Line", minval=1, maxval=4)
eqStyle        = input.string("Dashed", "EQ Line Style",                           group="EQ Line", options=["Solid", "Dashed", "Dotted"])

// ─────────────────────────────────────────────────────────────────
// SETTINGS — DEALING RANGE
// ─────────────────────────────────────────────────────────────────
rangeColor      = input.color(color.new(color.gray, 0), "Range Line Color",         group="Dealing Range")
rangeWidth      = input.int(1,   "Range Line Width",                                group="Dealing Range", minval=1, maxval=4)
rangeStyle      = input.string("Solid", "Range Line Style",                        group="Dealing Range", options=["Solid", "Dashed", "Dotted"])
showRange       = input.bool(true,  "Show Dealing Range (Wick High / Wick Low)",    group="Dealing Range")
showRangeLabels = input.bool(true,  "Show Dealing Range Labels",                    group="Dealing Range")

// ─────────────────────────────────────────────────────────────────
// SETTINGS — GENERAL
// ─────────────────────────────────────────────────────────────────
lineMult        = input.float(2.0, "Line Length Multiplier", minval=0.5, maxval=20.0, step=0.5, group="General", tooltip="1.0 = exactly 1 HTF candle duration. Increase to extend lines further right.")
labelSize       = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group="General")

// ─────────────────────────────────────────────────────────────────
// HELPER: CONVERT STRING STYLE TO LINE STYLE
// ─────────────────────────────────────────────────────────────────
f_lineStyle(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted

// ─────────────────────────────────────────────────────────────────
// HELPER: CONVERT STRING TO LABEL SIZE
// ─────────────────────────────────────────────────────────────────
f_labelSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

// ─────────────────────────────────────────────────────────────────
// AUTO-DETECT HTF FROM CURRENT CHART TIMEFRAME
// Pairings: M1->M15, M3->M30, M5->1H, M15->4H, M30->1D, M90->6H, 1H->1D, 4H->1W
// Nothing shows on any other timeframe
// ─────────────────────────────────────────────────────────────────
f_htfPeriod() =>
    switch timeframe.period
        "1"   => "15"
        "3"   => "30"
        "5"   => "60"
        "15"  => "240"
        "30"  => "1D"
        "90"  => "360"
        "60"  => "1D"
        "240" => "1W"
        => ""

isSupported = f_htfPeriod() != ""
htfPeriod   = f_htfPeriod()

// ─────────────────────────────────────────────────────────────────
// FETCH HTF DATA
// ─────────────────────────────────────────────────────────────────
htfOpen  = request.security(syminfo.tickerid, htfPeriod, open,    lookahead=barmerge.lookahead_on)
htfTime  = request.security(syminfo.tickerid, htfPeriod, time,    lookahead=barmerge.lookahead_on)
prevHigh = request.security(syminfo.tickerid, htfPeriod, high[1], lookahead=barmerge.lookahead_on)
prevLow  = request.security(syminfo.tickerid, htfPeriod, low[1],  lookahead=barmerge.lookahead_on)
prevTime = request.security(syminfo.tickerid, htfPeriod, time[1], lookahead=barmerge.lookahead_on)
prevEQ   = (prevHigh + prevLow) / 2

// ─────────────────────────────────────────────────────────────────
// DETECT NEW HTF CANDLE
// ─────────────────────────────────────────────────────────────────
isNewHTFCandle = isSupported and ta.change(htfTime) != 0

// HTF candle duration in bars
htfDurationMs = htfTime - prevTime
ltfDurationMs = time - time[1]
barsInHTF     = htfDurationMs / ltfDurationMs

// ─────────────────────────────────────────────────────────────────
// PERSISTENT LINE + LABEL VARS
// ─────────────────────────────────────────────────────────────────
var line  openLine  = na
var line  eqLine    = na
var line  highLine  = na
var line  lowLine   = na
var label openLabel = na
var label eqLabel   = na
var label highLabel = na
var label lowLabel  = na

// ─────────────────────────────────────────────────────────────────
// FORMAT TIME AS MILITARY HH:MM
// ─────────────────────────────────────────────────────────────────
f_timeLabel(t) =>
    h    = hour(t, "America/New_York")
    m    = minute(t, "America/New_York")
    hStr = h < 10 ? "0" + str.tostring(h) : str.tostring(h)
    mStr = m < 10 ? "0" + str.tostring(m) : str.tostring(m)
    hStr + ":" + mStr

// ─────────────────────────────────────────────────────────────────
// ON EACH NEW HTF CANDLE: DELETE OLD, DRAW NEW
// ─────────────────────────────────────────────────────────────────
if isNewHTFCandle
    endBar   = bar_index + int(barsInHTF * lineMult)
    labelBar = bar_index + int(barsInHTF * lineMult)
    lSize    = f_labelSize(labelSize)

    // Delete old lines + labels
    line.delete(openLine)
    line.delete(eqLine)
    line.delete(highLine)
    line.delete(lowLine)
    label.delete(openLabel)
    label.delete(eqLabel)
    label.delete(highLabel)
    label.delete(lowLabel)

    // ── Current HTF Open line ──
    openLine := line.new(
         x1    = bar_index,
         y1    = htfOpen,
         x2    = endBar,
         y2    = htfOpen,
         xloc  = xloc.bar_index,
         color = openColor,
         style = f_lineStyle(openStyle),
         width = openWidth)

    openLabel := label.new(
         x         = labelBar,
         y         = htfOpen,
         text      = f_timeLabel(htfTime),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(color.black, 100),
         textcolor = openColor,
         style     = label.style_label_left,
         size      = lSize)

    // ── Previous HTF EQ line ──
    eqLine := line.new(
         x1    = bar_index,
         y1    = prevEQ,
         x2    = endBar,
         y2    = prevEQ,
         xloc  = xloc.bar_index,
         color = eqColor,
         style = f_lineStyle(eqStyle),
         width = eqWidth)

    eqLabel := label.new(
         x         = labelBar,
         y         = prevEQ,
         text      = "EQ",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(color.black, 100),
         textcolor = eqColor,
         style     = label.style_label_left,
         size      = lSize)

    // ── Dealing Range lines (toggleable) ──
    if showRange
        highLine := line.new(
             x1    = bar_index,
             y1    = prevHigh,
             x2    = endBar,
             y2    = prevHigh,
             xloc  = xloc.bar_index,
             color = rangeColor,
             style = f_lineStyle(rangeStyle),
             width = rangeWidth)

        lowLine := line.new(
             x1    = bar_index,
             y1    = prevLow,
             x2    = endBar,
             y2    = prevLow,
             xloc  = xloc.bar_index,
             color = rangeColor,
             style = f_lineStyle(rangeStyle),
             width = rangeWidth)

        if showRangeLabels
            highLabel := label.new(
                 x         = labelBar,
                 y         = prevHigh,
                 text      = "Range High",
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(color.black, 100),
                 textcolor = rangeColor,
                 style     = label.style_label_left,
                 size      = lSize)

            lowLabel := label.new(
                 x         = labelBar,
                 y         = prevLow,
                 text      = "Range Low",
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(color.black, 100),
                 textcolor = rangeColor,
                 style     = label.style_label_left,
                 size      = lSize)
````
