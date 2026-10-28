# CQ_(-)_MTF Countdown Table

- url: https://www.tradingview.com/script/v6wkKZv0-CQ-MTF-Countdown-Table/
- type: indicator
- pine_id: PUB;538ea35e519c419fbaebf21555d9d6c8
- version: 2.0

## Description

================================================================================
  CQ_(-)_MTF COUNTDOWN TABLE  —  USER MANUAL
  © CQuevedo345 
================================================================================

  Pine Script v6  |  Overlay Indicator  |  Multi-Timeframe Candle Timer


────────────────────────────────────────────────────────────────────────────────
  OVERVIEW
────────────────────────────────────────────────────────────────────────────────

The CQ MTF Countdown Table is a real-time, multi-timeframe candle progress
monitor that displays how far into — and how far from the close of — each
major candle period you currently are. It renders a compact table directly
on your chart showing elapsed time, remaining time, and progress percentages
for up to four timeframes simultaneously: 1H, 4H, 1D, and 1W.

The table updates live on every bar close and on the last bar using timenow,
so the countdown is always accurate to the second.


────────────────────────────────────────────────────────────────────────────────
  FEATURE SUMMARY
────────────────────────────────────────────────────────────────────────────────

  • Multi-Timeframe Coverage
      Tracks candle progress across 1H, 4H, 1D, and 1W simultaneously.
      Each timeframe can be independently shown or hidden.

  • Elapsed Percentage Column
      Shows what percentage of the current candle has already elapsed,
      displayed as a whole number (e.g. 73%). The cell background uses a
      color gradient that transitions from a user-defined "low" color at 0%
      to a user-defined "high" color at 100%, giving an instant visual read
      of candle age at a glance.

  • Elapsed Time Columns (Days + Time)
      For 1H, 4H, and 1D rows, the Days column is intentionally left blank
      (those candles don't span multiple days) and the Time column shows
      elapsed time formatted as MM m (1H) or HH h : MM m (4H, 1D).
      For the 1W row, both the Days column (e.g. 03D) and the Time column
      (e.g. 14h : 22m) are populated to reflect the full weekly structure.

  • Remaining Time Columns (Days + Time)
      Mirror of the elapsed columns, but counting down toward the candle
      close. The 1W row shows remaining days and remaining intraday time
      separately. The remaining columns have their own independent text-size
      setting so they can be made larger or smaller than the rest of the
      table without affecting other columns.

  • Seconds Alert Column
      When remaining time on any row drops below a user-configured threshold
      (0–5 minutes), a dedicated RMNG SECS cell lights up showing the exact
      remaining seconds (e.g. 47s). The cell and text color change to a
      high-contrast alert style automatically. Above the threshold the cell
      stays blank and dim.

  • Bullish / Bearish TF Label Color
      The leftmost cell of each row (the TF label: 1H, 4H, 1D, 1W) is
      colored green or red depending on whether the current close is at or
      above the candle's open (bullish) or below it (bearish). Colors are
      fully customizable.

  • Active Timeframe Marker
      When the chart's current timeframe matches one of the table rows, that
      row's label is prefixed with a ▶ arrow so you can instantly see which
      row corresponds to the candle you are currently trading on.

  • Gradient on Time Cells (Optional)
      When the gradient toggle is enabled, elapsed time cells adopt the same
      low→high gradient as the percentage column. Remaining time cells use
      the inverse (high→low). When the gradient is enabled, the otherwise-
      empty "Days" cells on 1H/4H/1D rows are also filled with the matching
      gradient color, keeping the row visually cohesive instead of leaving
      dead dark gaps. When the toggle is off, all time cells use a uniform
      dim background.

  • Orientation Toggle
      The entire table can be switched between Horizontal (timeframes as
      rows, columns as data fields — the default) and Vertical (timeframes
      as columns, data fields as rows). All cell logic, merging, and
      alignment adapts automatically.

  • Position, Size, and Color Customization
      Every visual aspect of the table is configurable: table position
      (8 anchor points), global text size, remaining-column text size
      (independent), title background, header background, text colors for
      elapsed and remaining fields, gradient low/high colors, bullish and
      bearish background colors, and seconds-alert text color.

  • Week Anchor — Monday 00:00 UTC
      The 1W candle is anchored to Monday midnight UTC regardless of the
      broker or exchange session, matching TradingView's standard weekly
      candle definition. The calculation uses timenow and UTC dayofweek to
      derive the exact open timestamp of the current week dynamically.

  • Accurate 4H and 1D Duration
      Rather than assuming fixed 4-hour or 24-hour durations, the indicator
      reads time_close from request.security for 4H and 1D so that DST
      shifts, session gaps, and exchange-specific candle lengths are handled
      correctly.


────────────────────────────────────────────────────────────────────────────────
  TABLE LAYOUT
────────────────────────────────────────────────────────────────────────────────

  Horizontal orientation (default):

  ┌─────────────────────────────────────────────────────────────────────┐
  │              MTF ELAPSED/REMAINING CANDLE TIME                      │
  ├────────┬───────────┬────────────┬────────────┬───────────┬──────────┤
  │  TF    │ ELPSD %   │ ELPSD DAYS │ ELPSD TIME │ RMNG DAYS │ RMNG TIME│ RMNG SECS
  ├────────┼───────────┼────────────┼────────────┼───────────┼──────────┤
  │  1H    │   73%     │            │   43m      │           │   17m    │
  │▶ 4H   │   18%     │            │  00h : 43m │           │ 03h : 17m│
  │  1D    │   62%     │            │  14h : 52m │           │ 09h : 07m│
  │  1W    │   44%     │  03D       │  14h : 22m │  04D      │ 09h : 37m│
  └────────┴───────────┴────────────┴────────────┴───────────┴──────────┘

  Column index reference:
    Col 0  —  TF label (bull/bear colored)
    Col 1  —  Elapsed percentage (gradient colored)
    Col 2  —  Elapsed days  (1W only; gradient-filled on other rows if gradient ON)
    Col 3  —  Elapsed time  (formatted per TF)
    Col 4  —  Remaining days  (1W only; gradient-filled on other rows if gradient ON)
    Col 5  —  Remaining time  (formatted per TF)
    Col 6  —  Remaining seconds alert  (appears only near candle close)

  In Vertical orientation the rows and columns are transposed: each
  timeframe becomes a column and each data field becomes a row.


────────────────────────────────────────────────────────────────────────────────
  INPUT SETTINGS REFERENCE
────────────────────────────────────────────────────────────────────────────────

  ── Timeframes ──

    Show 1H                 Toggle the 1-hour row on or off.
    Show 4H                 Toggle the 4-hour row on or off.
    Show 1D                 Toggle the daily row on or off.
    Show 1W                 Toggle the weekly row on or off.


  ── Display ──

    Show Elapsed Time       Shows/hides the Elapsed Days and Elapsed Time
     (Col 2)                columns (cols 2–3). When hidden both cells are
                            rendered as blank dim cells.

    Show Remaining Time     Shows/hides the Remaining Days and Remaining
     (Col 3)                Time columns (cols 4–5). When hidden both cells
                            are rendered as blank dim cells.

    Seconds Alert           Sets the threshold in whole minutes (0–5) below
     Threshold (min)        which the RMNG SECS column activates. At 0 the
                            seconds column never appears. At 5 it lights up
                            during the final 5 minutes of every candle.

    Table Orientation       Horizontal (default) — timeframes as rows.
                            Vertical — timeframes as columns.

    Table Position          Anchor point for the table on the chart.
                            Options: top-left, top-center, top-right,
                            middle-left, middle-right, bottom-left,
                            bottom-center, bottom-right.

    Text Size               Size of text in the title row and all data
                            cells except the remaining-time columns.
                            Options: tiny, small, normal, large.

    Remaining Time          Independent text size for cols 4, 5, and 6
     Columns Text Size      (remaining days, remaining time, seconds alert).
                            Options: tiny, small, normal, large.
                            Useful for making the countdown more prominent
                            without enlarging the rest of the table.


  ── Colors ──

    Bullish Background      Cell background for the TF label when
                            close >= open on that timeframe.

    Bearish Background      Cell background for the TF label when
                            close < open on that timeframe.

    Elapsed % Low (0%)      The gradient start color shown when a candle
                            has just opened (0% elapsed).

    Elapsed % High (100%)   The gradient end color shown when a candle is
                            nearly complete (100% elapsed).

    Title Background        Background of the merged title row.

    Header Background       Background of the column header row.

    Text Color              Default text color used across most cells.

    Text Color (Elapsed)    Color of elapsed header labels and elapsed cell
                            text values.

    Text Color (Remaining)  Color of remaining header labels and remaining
                            cell text values.

    Seconds Alert Text      Text color inside the RMNG SECS cell when the
                            alert threshold is active.

    Use Gradient on         OFF (default): elapsed and remaining time cells
     Elapsed/Remaining      use a uniform dim background regardless of
     Time Cells             candle progress.
                            ON: elapsed time cells use the same low→high
                            gradient as the % column. Remaining time cells
                            use the inverse high→low gradient. Additionally,
                            the empty "Days" cells on 1H, 4H, and 1D rows
                            are filled with the matching gradient color
                            (elapsed gradient for col 2, remaining gradient
                            for col 4) instead of staying as dark gaps.


────────────────────────────────────────────────────────────────────────────────
  TIME FORMATTING REFERENCE
────────────────────────────────────────────────────────────────────────────────

  1H  elapsed / remaining   →   MM m           (e.g.  43m,  17m)
  4H  elapsed / remaining   →   HH h : MM m    (e.g.  00h : 43m)
  1D  elapsed / remaining   →   HH h : MM m    (e.g.  14h : 52m)
  1W  days column           →   DD D           (e.g.  03D,  04D)
  1W  time column           →   HH h : MM m    (e.g.  14h : 22m)
  Seconds alert             →   SS s           (e.g.  47s)

  All values are floored to whole minutes or seconds; no rounding up occurs
  so the display never shows a value higher than the actual remaining time.


────────────────────────────────────────────────────────────────────────────────
  NOTES AND TIPS
────────────────────────────────────────────────────────────────────────────────

  • The table renders only on the last bar (barstate.islast). It does not
    paint on historical bars and adds no visual noise to your chart history.

  • timenow is used for all live calculations, so the indicator reflects
    real wall-clock time even when the chart is not actively ticking (e.g.
    outside regular session hours on session-limited instruments).

  • The 1H row uses a simplified lookahead=off request to avoid peeking at
    future hour opens. The 4H, 1D, and 1W rows use lookahead=on so that
    time_close values are correctly available on the current bar.

  • For instruments with irregular sessions (futures, crypto, forex) the
    1D duration is derived from the actual time_close returned by the
    exchange feed, so DST and session-length variations are handled
    automatically.

  • If all four timeframe rows are hidden the table will still render its
    title and header row. Toggle at least one timeframe on for meaningful
    output.

  • Setting both "Show Elapsed Time" and "Show Remaining Time" to OFF will
    leave only the TF label, percentage, and seconds alert columns visible,
    producing a compact minimal layout useful for small screen areas.


────────────────────────────────────────────────────────────────────────────────
  VERSION HISTORY
────────────────────────────────────────────────────────────────────────────────

  v1.0   Initial release. 1H/4H/1D/1W timers, gradient %, bull/bear colors,
         orientation toggle, seconds alert, elapsed/remaining columns.

  v1.1   Added independent text size control for remaining-time columns
         (cols 4, 5, 6). Gradient fill extended to empty "Days" cells on
         1H/4H/1D rows when the gradient toggle is enabled, eliminating
         dark gaps and keeping row backgrounds visually consistent.


────────────────────────────────────────────────────────────────────────────────
  © CQuevedo345  —  Mozilla Public License 2.0
================================================================================

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © CQuevedo345 / UkutaLabs
//@version=6
indicator("CQ_(-)_MTF Countdown Table", overlay=true)

// ════════════════════════════════════════════════════════════════════════════════
// ── INPUTS ────────────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
grp_tf   = "── Timeframes ──"
i_show1h = input.bool(true, "Show 1H", group=grp_tf)
i_show4h = input.bool(true, "Show 4H", group=grp_tf)
i_show1d = input.bool(true, "Show 1D", group=grp_tf)
i_show1w = input.bool(true, "Show 1W", group=grp_tf)

grp_disp        = "── Display ──"
i_showTitle     = input.bool(false, "Show Table Title", group=grp_disp,
     tooltip="Toggles the title row/column at the top of the table.")
i_timeMode      = input.string("Remaining Only", "Show Time Columns",
     options=["Elapsed Only", "Remaining Only", "Both"],
     group=grp_disp,
     tooltip="Elapsed Only: shows elapsed % + elapsed time columns.\n" +
             "Remaining Only: shows elapsed % + remaining time columns.\n" +
             "Both: shows all columns.")
i_secThresh     = input.int(5, "Seconds Alert Threshold (min)",
     minval=0, maxval=5, group=grp_disp,
     tooltip="Show remaining seconds in col 4 when remaining time is below this many minutes.")
i_orient = input.string("Horizontal", "Table Orientation",
     options=["Horizontal", "Vertical"], group=grp_disp)
i_pos    = input.string(position.top_right, "Table Position",
     options=[position.top_left, position.top_center, position.top_right,
              position.middle_left, position.middle_right,
              position.bottom_left, position.bottom_center, position.bottom_right],
     group=grp_disp)
i_tsize    = input.string(size.small, "Text Size",
     options=[size.tiny, size.small, size.normal, size.large], group=grp_disp)
i_tsizeRem = input.string(size.small, "Remaining Time Columns Text Size",
     options=[size.tiny, size.small, size.normal, size.large], group=grp_disp)

grp_col        = "── Colors ──"
i_colBull      = input.color(color.rgb(0, 180, 50),     "Bullish Background",    group=grp_col)
i_colBear      = input.color(color.rgb(220, 20, 20),    "Bearish Background",    group=grp_col)
i_colPctLo     = input.color(color.rgb(0, 0, 65),       "Elapsed % Low  (0%)",   group=grp_col)
i_colPctHi     = input.color(color.rgb(0, 68, 255),     "Elapsed % High (100%)", group=grp_col)
i_colTitle     = input.color(color.rgb(2, 2, 27, 50),   "Title Background",      group=grp_col)
i_colHdr       = input.color(color.rgb(30, 30, 60, 50), "Header Background",     group=grp_col)
i_colText      = input.color(color.rgb(255, 255, 255),  "Text Color",            group=grp_col)
i_colText_e    = input.color(color.rgb(0, 255, 170),    "Text Color (Elapsed)",  group=grp_col)
i_colText_r    = input.color(color.rgb(0, 238, 255),    "Text Color (Remaining)",group=grp_col)
i_colSecAlert  = input.color(color.rgb(255, 255, 255),  "Seconds Alert Text",    group=grp_col)
i_timeGradient = input.bool(false,
     "Use Gradient on Elapsed/Remaining Time Cells",
     group   = grp_col,
     tooltip = "ON:  Elapsed time cells use the same gradient as the % column (low→high).\n" +
               "     Remaining time cells use the inverse gradient (high→low).\n" +
               "     Empty day cells on 1H/4H/1D rows also fill with the matching gradient color.\n" +
               "OFF: Both use the predefined dim background color.")

// ════════════════════════════════════════════════════════════════════════════════
// ── SECURITY ──────────────────────────────────────────════════════════════════
// ════════════════════════════════════════════════════════════════════════════════
[o1h, t1h_open] = request.security(syminfo.tickerid, "60",
     [open, time], lookahead=barmerge.lookahead_off)

[o4h, t4h_open, t4h_close] = request.security(syminfo.tickerid, "240",
     [open, time, time_close], lookahead=barmerge.lookahead_on)

[o1d, t1d_open, t1d_close] = request.security(syminfo.tickerid, "D",
     [open, time, time_close], lookahead=barmerge.lookahead_on)

[o1w, t1w_open] = request.security(syminfo.tickerid, "W",
     [open, time], lookahead=barmerge.lookahead_on)

// ════════════════════════════════════════════════════════════════════════════════
// ── MONDAY 00:00 UTC → SUNDAY 23:59:59 UTC WEEK ANCHOR ───────────────────────
// ════════════════════════════════════════════════════════════════════════════════
f_weekOpenMs() =>
    int dow         = dayofweek(timenow, "UTC")
    int daysSince   = dow == 2 ? 0 : dow == 1 ? 6 : dow - 2
    int nowSec      = int(timenow / 1000)
    int monSec      = nowSec - daysSince * 86400
    int midnightSec = int(monSec / 86400) * 86400
    midnightSec * 1000

// ════════════════════════════════════════════════════════════════════════════════
// ── COLOR GRADIENT ────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
f_grad(color lo, color hi, float pct) =>
    float p = math.max(0.0, math.min(1.0, pct))
    color.rgb(
         int(color.r(lo) + (color.r(hi) - color.r(lo)) * p),
         int(color.g(lo) + (color.g(hi) - color.g(lo)) * p),
         int(color.b(lo) + (color.b(hi) - color.b(lo)) * p))

// ════════════════════════════════════════════════════════════════════════════════
// ── FORMAT HELPERS ────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
f_fmt1H(int secs) =>
    int m = math.max(0, math.min(59, int(secs / 60)))
    str.tostring(m, "00") + "m"

f_fmt(int secs) =>
    int s = math.max(secs, 0)
    int h = int(s / 3600)
    int m = int((s - h * 3600) / 60)
    str.tostring(h, "00") + "h : " + str.tostring(m, "00") + "m"

f_fmtWdays(int secs) =>
    str.tostring(int(math.max(secs, 0) / 86400), "00") + "D"

f_fmtWtime(int secs) =>
    int s   = math.max(secs, 0)
    int rem = s - int(s / 86400) * 86400
    int h   = int(rem / 3600)
    int m   = int((rem - h * 3600) / 60)
    str.tostring(h, "00") + "h : " + str.tostring(m, "00") + "m"

f_fmtSec(int secs) =>
    str.tostring(math.max(secs, 0), "00") + "s"

// ════════════════════════════════════════════════════════════════════════════════
// ── PER-TF CALCULATIONS ───────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
f_calc1H() =>
    int elapsed = math.min(math.max(int((timenow - t1h_open) / 1000), 0), 3599)
    int remain  = 3600 - elapsed
    float pct   = float(elapsed) / 3600.0
    bool isBull = close >= o1h
    [pct, elapsed, remain, isBull]

f_calc4H() =>
    int dur     = math.max(int((t4h_close - t4h_open) / 1000), 1)
    int elapsed = math.min(math.max(int((timenow - t4h_open) / 1000), 0), dur)
    int remain  = dur - elapsed
    float pct   = float(elapsed) / float(dur)
    bool isBull = close >= o4h
    [pct, elapsed, remain, isBull]

f_calc1D() =>
    int dur     = math.max(int((t1d_close - t1d_open) / 1000), 1)
    int elapsed = math.min(math.max(int((timenow - t1d_open) / 1000), 0), dur)
    int remain  = dur - elapsed
    float pct   = float(elapsed) / float(dur)
    bool isBull = close >= o1d
    [pct, elapsed, remain, isBull]

f_calc1W() =>
    int openMs  = f_weekOpenMs()
    int dur     = 604800
    int elapsed = math.min(math.max(int((timenow - openMs) / 1000), 0), dur)
    int remain  = dur - elapsed
    float pct   = float(elapsed) / float(dur)
    bool isBull = close >= o1w
    [pct, elapsed, remain, isBull]

// ════════════════════════════════════════════════════════════════════════════════
// ── CHART TF MATCH ────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
int  chartMin = timeframe.in_seconds() / 60
bool match1h  = chartMin == 60
bool match4h  = chartMin == 240
bool match1d  = chartMin == 1440
bool match1w  = chartMin == 10080

// ════════════════════════════════════════════════════════════════════════════════
// ── TIME MODE HELPERS ─────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool showEl  = i_timeMode == "Elapsed Only"  or i_timeMode == "Both"
bool showRem = i_timeMode == "Remaining Only" or i_timeMode == "Both"

// ════════════════════════════════════════════════════════════════════════════════
// ── TABLE SETUP ───────────────────────────────────────────────────────────────
// Layout (logical rows when Horizontal):
//   row 0 = title   (present only when i_showTitle)
//   row 1 = headers
//   rows 2-5 = data
//
// Logical columns: 0=TF 1=PCT 2=EL DAYS 3=EL H:M 4=REM DAYS 5=REM H:M 6=SECS
//
// When title is hidden the header sits at logical row 0 and data starts at 1,
// so the table dimensions shrink by one in the title axis.
// ════════════════════════════════════════════════════════════════════════════════
bool isH = i_orient == "Horizontal"

// Count active TF rows
int nTFrows = (i_show1h ? 1 : 0) + (i_show4h ? 1 : 0) +
              (i_show1d ? 1 : 0) + (i_show1w ? 1 : 0)

// Total logical rows: title(0 or 1) + header(1) + data rows
int nLogRows = (i_showTitle ? 1 : 0) + 1 + nTFrows

// 7 logical columns always declared; unused cols rendered blank
int nCols = isH ? 7 : nLogRows
int nRows = isH ? nLogRows : 7

var table tbl = table.new(i_pos, nCols, nRows,
     bgcolor      = color.rgb(6, 6, 12, 50),
     frame_color  = color.rgb(0, 0, 0, 50),
     frame_width  = 1,
     border_color = color.rgb(0, 0, 0, 50),
     border_width = 1)

// ════════════════════════════════════════════════════════════════════════════════
// ── TABLE HELPERS ─────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
f_cell(int lCol, int lRow, string txt, color bg, color tc, string sz,
       string halign, string valign) =>
    int c = isH ? lCol : lRow
    int r = isH ? lRow : lCol
    table.cell(tbl, c, r, txt,
         bgcolor     = bg,
         text_color  = tc,
         text_size   = sz,
         text_halign = halign,
         text_valign = valign)

f_merge(int lC1, int lR1, int lC2, int lR2) =>
    int c1 = isH ? lC1 : lR1
    int r1 = isH ? lR1 : lC1
    int c2 = isH ? lC2 : lR2
    int r2 = isH ? lR2 : lC2
    table.merge_cells(tbl, c1, r1, c2, r2)

f_drawRow(int lRow, string tfLbl, float pct, int elSec, int remSec,
          bool isBull, bool isW, bool isMatch) =>

    color bgDim      = color.rgb(20, 20, 45)
    color bgOff      = color.rgb(15, 15, 30)
    color bgTF       = isBull ? i_colBull : i_colBear
    color bgPct      = f_grad(i_colPctLo, i_colPctHi, pct)
    color bgEl       = i_timeGradient ? f_grad(i_colPctLo, i_colPctHi, pct) : bgDim
    color bgRem      = i_timeGradient ? f_grad(i_colPctHi, i_colPctLo, pct) : bgDim
    color bgElEmpty  = i_timeGradient ? bgEl  : bgOff
    color bgRemEmpty = i_timeGradient ? bgRem : bgOff

    // Col 0 — TF label
    f_cell(0, lRow, isMatch ? "▶ " + tfLbl : tfLbl,
         bgTF, i_colText, i_tsize, text.align_right, text.align_center)

    // Col 1 — Elapsed %
    f_cell(1, lRow, str.tostring(int(pct * 100)) + "%",
         bgPct, i_colText, i_tsize, text.align_center, text.align_center)

    // Cols 2-3 — Elapsed time
    if showEl
        if isW
            f_cell(2, lRow, f_fmtWdays(elSec),
                 bgEl, i_colText_e, i_tsize, text.align_center, text.align_center)
            f_cell(3, lRow, f_fmtWtime(elSec),
                 bgEl, i_colText_e, i_tsize, text.align_center, text.align_center)
        else
            f_cell(2, lRow, "",
                 bgElEmpty, i_colText_e, i_tsize, text.align_center, text.align_center)
            f_cell(3, lRow, tfLbl == "1H" ? f_fmt1H(elSec) : f_fmt(elSec),
                 bgEl, i_colText_e, i_tsize, text.align_center, text.align_center)
    else
        f_cell(2, lRow, "", bgOff, i_colText, i_tsize, text.align_center, text.align_center)
        f_cell(3, lRow, "", bgOff, i_colText, i_tsize, text.align_center, text.align_center)

    // Cols 4-5 — Remaining time
    if showRem
        if isW
            f_cell(4, lRow, f_fmtWdays(remSec),
                 bgRem, i_colText_r, i_tsizeRem, text.align_center, text.align_center)
            f_cell(5, lRow, f_fmtWtime(remSec),
                 bgRem, i_colText_r, i_tsizeRem, text.align_center, text.align_center)
        else
            f_cell(4, lRow, "",
                 bgRemEmpty, i_colText_r, i_tsizeRem, text.align_center, text.align_center)
            f_cell(5, lRow, tfLbl == "1H" ? f_fmt1H(remSec) : f_fmt(remSec),
                 bgRem, i_colText_r, i_tsizeRem, text.align_center, text.align_center)
    else
        f_cell(4, lRow, "", bgOff, i_colText, i_tsizeRem, text.align_center, text.align_center)
        f_cell(5, lRow, "", bgOff, i_colText, i_tsizeRem, text.align_center, text.align_center)

    // Col 6 — Seconds alert
    bool showSec = remSec <= i_secThresh * 60
    f_cell(6, lRow,
         showSec and showRem ? f_fmtSec(remSec) : "",
         showSec and showRem ? color.rgb(0, 5, 49, 50) : bgOff,
         showSec and showRem ? i_colSecAlert : i_colText,
         i_tsizeRem, text.align_center, text.align_center)

// ════════════════════════════════════════════════════════════════════════════════
// ── DRAW ──────────────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
if barstate.islast

    // ── Title (row 0) — drawn only when enabled ───────────────────────────────
    int hdrRow  = 0   // logical row for headers
    int dataRow = 1   // logical row where data starts

    if i_showTitle
        f_cell(0, 0, "MTF ELAPSED/REMAINING CANDLE TIME",
             i_colTitle, i_colText, i_tsize,
             text.align_center, text.align_center)
        f_merge(0, 0, 6, 0)
        hdrRow  := 1
        dataRow := 2

    // ── Headers ───────────────────────────────────────────────────────────────
    f_cell(0, hdrRow, "TF",          i_colHdr, i_colText,   size.tiny, text.align_center, text.align_center)
    f_cell(1, hdrRow, "ELPSD\n%",    i_colHdr, i_colText_e, size.tiny, text.align_center, text.align_center)

    if showEl
        f_cell(2, hdrRow, "ELPSD\nDAYS", i_colHdr, i_colText_e, size.tiny, text.align_center, text.align_center)
        f_cell(3, hdrRow, "ELPSD\nTIME", i_colHdr, i_colText_e, size.tiny, text.align_center, text.align_center)
    else
        f_cell(2, hdrRow, "", i_colHdr, i_colText, size.tiny, text.align_center, text.align_center)
        f_cell(3, hdrRow, "", i_colHdr, i_colText, size.tiny, text.align_center, text.align_center)

    if showRem
        f_cell(4, hdrRow, "RMNG\nDAYS", i_colHdr, i_colText_r, size.tiny, text.align_center, text.align_center)
        f_cell(5, hdrRow, "RMNG\nTIME", i_colHdr, i_colText_r, size.tiny, text.align_center, text.align_center)
        f_cell(6, hdrRow, "RMNG\nSECS", i_colHdr, i_colText_r, size.tiny, text.align_center, text.align_center)
    else
        f_cell(4, hdrRow, "", i_colHdr, i_colText, size.tiny, text.align_center, text.align_center)
        f_cell(5, hdrRow, "", i_colHdr, i_colText, size.tiny, text.align_center, text.align_center)
        f_cell(6, hdrRow, "", i_colHdr, i_colText, size.tiny, text.align_center, text.align_center)

    // ── Data rows ─────────────────────────────────────────────────────────────
    int lRow = dataRow

    if i_show1h
        [pct, el, rem, bull] = f_calc1H()
        f_drawRow(lRow, "1H", pct, el, rem, bull, false, match1h)
        lRow := lRow + 1

    if i_show4h
        [pct, el, rem, bull] = f_calc4H()
        f_drawRow(lRow, "4H", pct, el, rem, bull, false, match4h)
        lRow := lRow + 1

    if i_show1d
        [pct, el, rem, bull] = f_calc1D()
        f_drawRow(lRow, "1D", pct, el, rem, bull, false, match1d)
        lRow := lRow + 1

    if i_show1w
        [pct, el, rem, bull] = f_calc1W()
        f_drawRow(lRow, "1W", pct, el, rem, bull, true, match1w)
````
