# Multi-Timeframe FVGs [ufo]

- url: https://www.tradingview.com/script/F6oUQzkH-Multi-Timeframe-FVGs-ufo/
- type: indicator
- pine_id: PUB;29c2bb8697094e7b8775e9c773b79b6a
- version: 2.0

## Description

[b]Multi-Timeframe FVGs[/b] shows Fair Value Gaps (FVGs) from up to six timeframes on one chart, higher or lower than the chart timeframe. Each gap is tracked after it forms (tapped, fill %, touches or invalidated), and you choose how much of that is shown.


[b]Key features[/b]
[list]
[*][b]Fill tracking:[/b] boxes and lines can shrink as price fills them, or show the filled part in a second color. Labels can show the fill %, touches and the time the FVG formed.
[*][b]Hover details:[/b] hover over a label to see everything about an FVG: when it formed, its levels, size, fill % and touches.
[*][b]Higher and lower timeframes:[/b] e.g. daily FVGs on a 5-minute chart, or 15-minute FVGs on a 1-hour chart, found on the real 15-minute candles.
[*][b]Less clutter:[/b] lookback per timeframe (last X FVGs, hours, days or nearest to price), hide nested FVGs, minimum size, direction and session filters, extend only the nearest FVGs, or a minimal line or bracket display.
[*][b]Potential FVGs:[/b] optionally see a gap while its third candle is still forming.
[*][b]Alerts:[/b] new FVG, first tap and EQ (50%) tapped, each sent once per FVG.
[/list]
[image]https://www.tradingview.com/x/vybfJ8lD/[/image]
[i]The same type of 15-minute FVG with different settings. The left box shows the default display.[/i]


[b]What is an FVG[/b]

A Fair Value Gap (FVG) is a three-candle pattern where the middle candle moves so fast that the wicks of the first and third candle do not overlap. The space between those wicks is a price range that was only traded briefly, in one direction. Many traders watch FVGs as areas where price may return to or react.


[b]How it works[/b]
[list]
[*][b]Detection:[/b] for timeframes equal to or higher than the chart, the script uses the last three [i]completed[/i] candles of that timeframe, so an FVG appears once candle 3 has closed and confirmed FVGs do not repaint. Lower timeframes (Show TFs Below Chart TF) are read from the candles of that timeframe inside each chart candle. A pattern with a price gap between two of its candles (no trading at all in between, e.g. an opening gap) is not counted as an FVG.
[*][b]Tracking:[/b] an FVG is tapped when a wick trades into it. Fill % is how deep price has traded in, touches counts separate entries, and EQ tapped is the first time price reaches the middle (50%), called the EQ.
[*][b]Invalidation:[/b] Wick fill, Body fill, Wick fill EQ or Body fill EQ (or None). Body rules use the candle bodies of the FVG's own timeframe. Invalidated FVGs are removed or kept in their own colors.
[*][b]Display:[/b] extended FVGs are placed in a column per timeframe to the right of price, so timeframes do not overlap. The script stays below TradingView's limit of 500 boxes, lines and labels, so drawings are not removed without notice.
[/list]


[b]Settings[/b]
[list]
[*][b]Timeframe & Lookback:[/b] six timeframes, each with a lookback of the last X FVGs, X hours, X days, or the X nearest FVGs above and below price.
[*][b]Filters:[/b] Hide nested FVGs (an FVG inside a same-direction FVG of a higher timeframe), Show Potential FVGs (dashed, marked with * in the label, e.g. 15m*), Show TFs Below Chart TF, Only show FVGs near price (ATR based), Min. FVG size (ticks or % ATR), Session (only FVGs that formed inside a time window, e.g. 09:30 - 16:00 New York time) and Direction (bullish, bearish or both).
[*][b]FVG Display:[/b] Include Volume Imbalance (extends the FVG to a gap between the bodies of two neighboring candles within its three candles), Draw FVG from (candle 1 to 4), Box Length (Extend, Fixed bars or Extend nearest), Offset / TF Spacing, Display (Box, Line or Bracket), border, and EQ or Quadrant levels.
[*][b]FVG Status:[/b] Invalidated when, Fill Display (Shrink or Two-tone), Tapped FVG Color and Show Invalidated FVGs.
[*][b]FVG Labels:[/b] timeframe style, extra text, position, Fill Info (fill %, touches or both), Time (open time of candle 2 in a selectable time zone; daily and higher FVGs show the date) and Hover Details (all details of the FVG when you hover over a label next to the FVG).
[*][b]Colors:[/b] one global color pair, or colors per timeframe.
[*][b]Alerts:[/b] New FVG, Tapped and EQ tapped, filtered by direction and timeframe.
[/list]


[b]How to use[/b]
[list=1]
[*]Choose up to six timeframes and a lookback for each. Turn on Show TFs Below Chart TF to add timeframes lower than your chart.
[*]Use the filters, Extend nearest or the Line / Bracket display to keep the chart readable, and Fill Display or Fill Info to see how far each FVG has been filled.
[*]For alerts, choose the events in the Alerts settings, then create an alert with the condition "FVGs [ufo]" and "Any alert() function call".
[/list]


[b]Limitations[/b]
[list]
[*]For timeframes equal to or higher than the chart, touches are counted per chart candle, so leaving and re-entering an FVG within one candle counts as one touch. A lower chart timeframe counts touches more precisely.
[*]Lower timeframe FVGs start at the chart candle that contains them. TradingView limits how many lower timeframe candles a script can load, so very low timeframes on a high chart timeframe (e.g. 1-minute FVGs on a daily chart) only reach back a limited time.
[*]Potential FVGs repaint by design: they update live and disappear if the gap closes before candle 3 closes. They have no alerts or tracking.
[*]While the market is closed, extended FVGs end at the next session open instead of in their timeframe columns, and brackets show as a plain line. Both return to normal when the market opens.
[*]The Hours / Days lookback counts chart bars (closed markets are not included), up to 5,000 bars back.
[*]Up to 200 FVGs are stored per timeframe. Alerts are sent on realtime bars only.
[*]This is an analysis tool. It does not give buy or sell signals or predict how price will react to an FVG.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ufonose
//
//@version=6
indicator("Multi-Timeframe FVGs [ufo]", shorttitle="FVGs [ufo]", overlay=true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ── Types ──────────────────────────────────────────────────────────────────────────────────────────────────
// One candle of an FVG timeframe. x = time of the chart bar the candle starts in, used for drawing
type Candle
    float   o
    float   h
    float   l
    float   c
    int     t
    int     x

// The drawings of one FVG
type Visual
    box     zone                // FVG box. Invisible in Line / Bracket display, then it only holds Inside FVG label text
    box     filled              // Two-tone: box over the part of the FVG that price has already traded into
    box     textbox             // Two-tone + Inside FVG label: invisible full-size box holding the label text
    label   tag                 // Next to FVG label
    line    eq                  // EQ line (50%)
    line    q1                  // Quadrants: 25% line
    line    q3                  // Quadrants: 75% line
    line    edge                // Line / Bracket: right edge (the untraded part, or the full FVG)
    line    edge_filled         // Line / Bracket: part of the right edge that price has traded into
    line    tick_far            // Bracket: tick at the far side of the FVG
    line    tick_near           // Bracket: tick at the near side of the FVG

// One FVG. The near side is the side price trades in from (candle 3 side), the far side is the candle 1 side
type Gap
    bool    bull
    float   top
    float   bot
    int     t1                  // open time of candle 1 (duplicate check, Time Lookback)
    int     t2                  // open time of candle 2 (Time label, Hover Details, session filter)
    int     x1                  // chart bar times where candles 1 to 4 start (Draw FVG from)
    int     x2
    int     x3
    int     x4
    int     born                // bar_index of the chart bar where the FVG was confirmed
    int     stop_t              // Fixed Length: time of the chart bar where the box stops
    bool    potential   = false // candle 3 is still forming
    bool    in_session  = true  // session filter: candle 2 opened inside the session
    float   deepest             // deepest price reached inside the FVG (na = not traded into yet)
    int     touches     = 0     // number of separate times price traded into the FVG
    bool    inside      = false // price was inside the FVG on the previous candle
    int     tap_bar             // alerts: bar_index of the first tap
    int     eq_bar              // alerts: bar_index where price first reached the EQ
    bool    dead        = false // invalidated
    int     dead_t              // time of the chart bar where the FVG was invalidated
    Visual  v

// One timeframe row: its settings, its FVGs, and the state for lower timeframes
type Layer
    string  tf
    bool    on
    int     lb_amt
    string  lb_unit
    color   col_bull
    color   col_bear
    bool    alerts
    Gap[]   gaps                // newest first
    int     cutoff              // Time Lookback: FVGs whose candle 1 opened before this time are not shown
    int     last_t1             // candle 1 time of the newest FVG, so an FVG is never added twice
    int     seen_t              // higher timeframes: candle 3 time that was last checked
    Gap     pot                 // potential FVG (last bar only)
    Candle  p1                  // previous closed candle
    Candle  p2                  // the closed candle before that
    Candle  forming             // candle that is still forming (potential FVGs)
    float   atr                 // running ATR(14) of the timeframe
    float   prev_c
    int     last_t              // time of the last processed candle
    // Alerts of FVGs that were invalidated on the same bar as their tap / EQ tap (e.g. Invalidated when: Tapped)
    string[] late_keys
    string[] late_msgs
    int     late_bar

// Number of drawings that currently exist, so the script never goes over TradingView's limit
type Budget
    int     boxes   = 0
    int     lines   = 0
    int     labels  = 0

// ── Settings ───────────────────────────────────────────────────────────────────────────────────────────────
TF_Group                            = "Timeframe & Lookback Settings"
Filter_Group                        = "Filters"
Box_Group                           = "FVG Display"
Mitigation_Group                    = "FVG Status"
Label_Group                         = "FVG Labels"
Colors_Group                        = "Colors"
Alert_Group                         = "Alerts"


string tooltip1 = "Timeframe Settings:\n\tShow/Hide timeframe\n\tTimeframe to display\n\tLookback amount\n\tLookback unit\n\nLookback unit:\n- FVGs: only show the last X valid FVGs\n- Hours / Days: only show FVGs formed in the last X hours/days (time is based on candle bars, this does not include the time when markets are closed)\n- Nearest: only show the X nearest valid FVGs above price and the X nearest below price. Updates as price moves\n\nTimeframes lower than the chart timeframe are only shown with the Show TFs Below Chart TF setting"
string tooltip2 = "Hide an FVG when it is completely inside a valid FVG in the same direction from a higher timeframe\n\nExample: a 15m BISI inside a 1H BISI is hidden, only the 1H BISI is shown"
string tooltip3 = "Show FVGs of timeframes lower than the chart timeframe, e.g. 15m FVGs on a 1H chart"
string tooltip4 = "Only display FVGs within this many ATRs of the current price (daily ATR on intraday charts, 3x monthly ATR on daily charts, 12x monthly ATR on weekly charts)"
string tooltip5 = "Show an FVG that is still forming: candle 1 and the current, unfinished candle 3 have a gap\n\nDisplay | Line style: how potential FVGs are drawn, separate from the Display setting of the confirmed FVGs\n\nDrawn with a lighter fill and a * after the timeframe in the label, e.g. 15m*\n\nPotential FVGs have no alerts, fill tracking or invalidation"
string tooltip6 = "Only show FVGs with a minimum size:\n- Ticks: at least X ticks\n- % ATR: at least X% of the ATR(14) of the FVG timeframe, so it adapts to volatility"
string tooltip7 = "Only show FVGs that formed inside this time window, in the selected time zone\n\nDaily and higher FVGs are always shown"
string tooltip8 = "Only show bullish FVGs, only bearish FVGs, or both"
string tooltip9 = "Extend the FVG box when there is a volume imbalance inside the 3-candle sequence of the FVG\n\nA volume imbalance is a gap between the candle bodies of two candles next to each other (on the FVG timeframe), in the same direction as the FVG\n\nThe EQ, Quadrants, invalidation and fill tracking use the extended box. The Min. FVG size filter uses the FVG without the volume imbalance"
string tooltip10 = "Candle where the FVG box starts:\n- Candle 1: the candle before the gap\n- Candle 2: the candle that created the gap\n- Candle 3: the candle that confirmed the gap\n- Candle 4: the first candle that can trade into the gap\n\nFVGs are always detected once candle 3 has closed"
string tooltip11 = "Extend: the FVG box extends to the current candle (+ Offset)\n\nFixed bars: the FVG box stops X chart bars after the FVG was confirmed\n\nExtend nearest: per timeframe, only the X nearest valid bullish and X nearest valid bearish FVGs extend to the current candle. The other FVGs stop after the Fixed Length"
string tooltip12 = "Number of chart bars an FVG box is drawn after the FVG was confirmed, for boxes that are not extended"
string tooltip13 = "Number of bars between the current candle and the first column of extended FVGs"
string tooltip14 = "Number of bars between the columns of extended FVGs of each timeframe"
string tooltip15 = "Box: draw the full FVG box\nLine: only draw the right edge of the FVG as a vertical line\nBracket: like Line, with short ticks at the top and bottom of the FVG, like ]\n\nEQ / Quadrants levels and labels are still shown when enabled"
string tooltip16 = "Line Width | Filled Part Width\n\nFilled Part Width: width of the part of the line that price has already traded into"
string tooltip17 = "Line Style | Transparency (0 = solid, 100 = invisible)\n\nThe line color is based on the FVG color"
string tooltip18 = "Length of the top and bottom lines of the Bracket display"
string tooltip19 = "Show Box: color the inside of the FVG box\nShow Border: draw the outline of the FVG box\n\nBorder transparency: 0 = solid, 100 = invisible\n\nThe border color is based on the FVG color"
string tooltip20 = "Show levels inside the FVG:\n- EQ: the 50% line (equilibrium)\n- Quadrants: the 25%, 50% and 75% lines\n\nColor | Line style"
string tooltip21 = "When an FVG counts as invalidated:\n- None: never\n- Tapped: price trades into the FVG\n- Wick fill: price trades through the far side of the FVG\n- Body fill: a candle body of the FVG timeframe closes through the far side of the FVG\n- Wick fill EQ: price trades through the EQ (50%)\n- Body fill EQ: a candle body of the FVG timeframe closes through the EQ (50%)"
string tooltip22 = "How a partially filled FVG is drawn:\n- Off: the box, line or bracket keeps its full size\n- Shrink: the box, line or bracket shrinks as price trades into it, so it only covers the part of the FVG that is still unfilled (this will not shrink the EQ or Quadrants levels)\n- Two-tone: the part of the FVG that price has already traded into is drawn in these colors (Bullish | Bearish), the unfilled part keeps its normal color"
string tooltip23 = "Change the FVG color once price has traded into it, but has not invalidated it yet\n\nBullish Color | Bearish Color\n\nAn FVG is tapped as soon as a wick trades into it"
string tooltip24 = "Keep invalidated FVGs on the chart in these colors (Bullish | Bearish)"
string tooltip25 = "Maximum number of invalidated FVGs to keep on the chart per timeframe. Invalidated FVGs do not count toward the per-timeframe Lookback"
string tooltip26 = "Bullish Label Color | Bearish Label Color | Size | Font"
string tooltip27 = "Next to FVG: the label is placed just to the right of the FVG box\nInside FVG: the label is placed inside the FVG box, aligned to its right edge\n\nTop / Center / Bottom: the label is aligned to the top edge, the middle or the bottom edge of the FVG"
string tooltip28 = "How the timeframe is written in the label. 15m is just an example, the actual timeframe of the FVG is used\n\nThe separator styles (15m | , 15m · , 15m:) only show the separator when there is text after the timeframe, e.g. 15m | BISI"
string tooltip29 = "Bullish FVG Text | Bearish FVG Text\n\nAdded after the timeframe in the label when enabled\nExample: [15m] BISI / [15m] SIBI"
string tooltip30 = "Adds fill info to the label of partially filled FVGs:\n- Fill %: how deep price has traded into the FVG\n- Touches: how many separate times price has traded into the FVG"
string tooltip31 = "Adds the time the FVG formed (open time of candle 2) to the label of all FVGs, in the selected time zone. Summer/winter time changes are applied automatically\n\nExchange: the time zone of the symbol's exchange\n\nDaily and higher FVGs show the date of their trading day instead"
string tooltip32 = "Hover over a label to see all details of the FVG\n\nOnly works with Label Position: Next to FVG\n\nThe time uses the time zone of the Time setting above"
string tooltip33 = "Use the same Bullish | Bearish FVG colors for all timeframes"
string tooltip34 = "Bullish and Bearish FVG colors for each timeframe, in the same order as the Timeframe & Lookback Settings"
string tooltip35 = "Alert events, each is sent only once per FVG:\n- New FVG: an FVG is confirmed\n- Tapped: price trades into the FVG for the first time\n- EQ tapped: price trades to the EQ (50%) of the FVG for the first time\n\nEvents that happen at the same time are combined into one message\n\nTo receive alerts: Create Alert > Condition: FVGs [ufo] > Any alert() function call"
string tooltip36 = "Timeframes that send alerts, in the same order as the Timeframe & Lookback Settings"

string LB_FVGS                      = "FVGs"
string LB_HOURS                     = "Hours"
string LB_DAYS                      = "Days"
string LB_NEAREST                   = "Nearest"

show_1                       = input.bool(true, "", inline="htf1", group=TF_Group)
htf_1                        = input.timeframe("15", "", inline="htf1", group=TF_Group, active=show_1)
lb_amt_1                     = input.float(2.0, "", minval=1, maxval=999, step=1, inline="htf1", group=TF_Group, active=show_1)
lb_unit_1                    = input.string(LB_DAYS, "", options=[LB_FVGS, LB_HOURS, LB_DAYS, LB_NEAREST], inline="htf1", group=TF_Group, tooltip = tooltip1, active=show_1)

show_2                       = input.bool(true, "", inline="htf2", group=TF_Group)
htf_2                        = input.timeframe("30", "", inline="htf2", group=TF_Group, active=show_2)
lb_amt_2                     = input.float(2.0, "", minval=1, maxval=999, step=1, inline="htf2", group=TF_Group, active=show_2)
lb_unit_2                    = input.string(LB_DAYS, "", options=[LB_FVGS, LB_HOURS, LB_DAYS, LB_NEAREST], inline="htf2", group=TF_Group, active=show_2)

show_3                       = input.bool(true, "", inline="htf3", group=TF_Group)
htf_3                        = input.timeframe("60", "", inline="htf3", group=TF_Group, active=show_3)
lb_amt_3                     = input.float(2.0, "", minval=1, maxval=999, step=1, inline="htf3", group=TF_Group, active=show_3)
lb_unit_3                    = input.string(LB_DAYS, "", options=[LB_FVGS, LB_HOURS, LB_DAYS, LB_NEAREST], inline="htf3", group=TF_Group, active=show_3)

show_4                       = input.bool(true, "", inline="htf4", group=TF_Group)
htf_4                        = input.timeframe("240", "", inline="htf4", group=TF_Group, active=show_4)
lb_amt_4                     = input.float(2.0, "", minval=1, maxval=999, step=1, inline="htf4", group=TF_Group, active=show_4)
lb_unit_4                    = input.string(LB_NEAREST, "", options=[LB_FVGS, LB_HOURS, LB_DAYS, LB_NEAREST], inline="htf4", group=TF_Group, active=show_4)

show_5                       = input.bool(false, "", inline="htf5", group=TF_Group)
htf_5                        = input.timeframe("1D", "", inline="htf5", group=TF_Group, active=show_5)
lb_amt_5                     = input.float(2.0, "", minval=1, maxval=999, step=1, inline="htf5", group=TF_Group, active=show_5)
lb_unit_5                    = input.string(LB_FVGS, "", options=[LB_FVGS, LB_HOURS, LB_DAYS, LB_NEAREST], inline="htf5", group=TF_Group, active=show_5)

show_6                       = input.bool(false, "", inline="htf6", group=TF_Group)
htf_6                        = input.timeframe("1W", "", inline="htf6", group=TF_Group, active=show_6)
lb_amt_6                     = input.float(2.0, "", minval=1, maxval=999, step=1, inline="htf6", group=TF_Group, active=show_6)
lb_unit_6                    = input.string(LB_FVGS, "", options=[LB_FVGS, LB_HOURS, LB_DAYS, LB_NEAREST], inline="htf6", group=TF_Group, active=show_6)

// Time zone names used in the settings, converted to the time zone names Pine Script uses
f_timeZone(string name) =>
    switch name
        "Exchange"      => syminfo.timezone
        "UTC"           => "Etc/UTC"
        "Chicago"       => "America/Chicago"
        "Los Angeles"   => "America/Los_Angeles"
        "Sao Paulo"     => "America/Sao_Paulo"
        "London"        => "Europe/London"
        "Berlin"        => "Europe/Berlin"
        "Athens"        => "Europe/Athens"
        "Moscow"        => "Europe/Moscow"
        "Dubai"         => "Asia/Dubai"
        "Kolkata"       => "Asia/Kolkata"
        "Singapore"     => "Asia/Singapore"
        "Hong Kong"     => "Asia/Hong_Kong"
        "Tokyo"         => "Asia/Tokyo"
        "Sydney"        => "Australia/Sydney"
        "Auckland"      => "Pacific/Auckland"
        => "America/New_York"

// Filters
hide_nested                      = input.bool(false, "Hide nested FVGs", group=Filter_Group, tooltip=tooltip2)
ltf_allow                        = input.bool(false, "Show TFs Below Chart TF", group=Filter_Group, tooltip=tooltip3)
prox_filter                      = input.bool(false, "Only show FVGs near price |", group=Filter_Group, inline="prox")
prox_mult                        = input.float(0.2, "ATR x", minval=0.1, step=0.1, group=Filter_Group, inline="prox", tooltip=tooltip4, active=prox_filter)
potential_show                   = input.bool(false, "Potential FVGs ‏", group=Filter_Group, inline="pot")
pot_display                      = input.string("Box", "", options=["Box", "Line", "Bracket"], group=Filter_Group, inline="pot", active=potential_show)
pot_style                        = input.string('----', '', options = ['⎯⎯⎯', '----', '····'], group=Filter_Group, inline="pot", active=potential_show, tooltip=tooltip5)
min_size_show                    = input.bool(false, "Min. FVG size ‏ ‏ ‏", group=Filter_Group, inline="minsize")
min_size                         = input.float(20, "", minval=0, step=1, group=Filter_Group, inline="minsize", active=min_size_show)
min_size_unit                    = input.string("Ticks", "", options=["Ticks", "% ATR"], group=Filter_Group, inline="minsize", active=min_size_show, tooltip=tooltip6)
session_on                       = input.bool(false, "Session", group=Filter_Group, inline="sess")
session_s                        = input.session("0930-1600", "", group=Filter_Group, inline="sess", active=session_on)
session_tz_s                     = input.string("New York", "", options=["Exchange", "UTC", "New York", "Chicago", "Los Angeles", "Sao Paulo", "London", "Berlin", "Athens", "Moscow", "Dubai", "Kolkata", "Singapore", "Hong Kong", "Tokyo", "Sydney", "Auckland"], group=Filter_Group, inline="sess", active=session_on, tooltip=tooltip7)
session_tz                       = f_timeZone(session_tz_s)
session_start                    = int(str.tonumber(str.substring(session_s, 0, 2))) * 60 + int(str.tonumber(str.substring(session_s, 2, 4)))
session_end                      = int(str.tonumber(str.substring(session_s, 5, 7))) * 60 + int(str.tonumber(str.substring(session_s, 7, 9)))
dir_filter                       = input.string("Both", "Direction ‏ ‏ ‏ ‏ ‏", options=["Both", "Bullish", "Bearish"], group=Filter_Group, inline="dir", tooltip=tooltip8)

// FVG Display
vib_on                           = input.bool(false, "Include Volume Imbalance", group=Box_Group, tooltip=tooltip9)
draw_start                       = input.string("Candle 3", "Draw FVG from", options=["Candle 1", "Candle 2", "Candle 3", "Candle 4"], group=Box_Group, tooltip=tooltip10)
extend_mode                      = input.string("Extend nearest", "Box Length", options=["Extend", "Fixed bars", "Extend nearest"], group=Box_Group, tooltip=tooltip11)
bool extend_active               = extend_mode != "Fixed bars"      // some boxes extend to the current candle
bool fixed_active                = extend_mode != "Extend"          // some boxes have a fixed length
nearest_extend                   = input.int(1, "Nearest to extend", minval=1, group=Box_Group, active=extend_mode == "Extend nearest")
fixed_len                        = input.int(12, "Fixed Length", minval=1, group=Box_Group, active=fixed_active, tooltip=tooltip12)
col_offset                       = input.int(4, "Offset", minval=0, group=Box_Group, active=extend_active, tooltip=tooltip13)
col_spacing                      = input.int(10, "TF Spacing", minval=0, group=Box_Group, active=extend_active, tooltip=tooltip14)
display_mode                     = input.string("Box", "Display", options=["Box", "Line", "Bracket"], group=Box_Group, tooltip=tooltip15)
bool line_mode                   = display_mode != "Box"
bracket_mode                     = display_mode == "Bracket"
bool pot_box                     = potential_show and pot_display == "Box"
line_w                           = input.int(2, "Line Width ‏ ‏ ‏ ‏ ‏", minval=1, maxval=10, group=Box_Group, inline="lw", active=line_mode)
line_w_filled                    = input.int(1, "", minval=1, maxval=10, group=Box_Group, inline="lw", active=line_mode, tooltip=tooltip16)
line_style                       = input.string('⎯⎯⎯', "Line Style ‏ ‏ ‏ ‏ ‏ ‏ ‏", options = ['⎯⎯⎯', '----', '····'], group=Box_Group, inline="ls", active=line_mode)
line_transp                      = input.int(0, "", minval=0, maxval=100, step=1, group=Box_Group, inline="ls", active=line_mode, tooltip=tooltip17)
bracket_len                      = input.int(3, "Bracket Length", minval=1, maxval=50, group=Box_Group, active=display_mode == "Bracket" or (potential_show and pot_display == "Bracket"), tooltip=tooltip18)
box_fill                         = input.bool(true, "Show Box", group=Box_Group, inline="fill", active=not line_mode or pot_box)
border_show                      = input.bool(true, "Show Border", group=Box_Group, inline="fill", active=not line_mode or pot_box)
border_transp                    = input.int(30, "", minval=0, maxval=100, step=1, group=Box_Group, inline="fill", active=border_show and (not line_mode or pot_box), tooltip=tooltip19)
ce_show                          = input.bool(false, "Levels", group=Box_Group, inline="ce")
lvl_mode                         = input.string("EQ", "", options=["EQ", "Quadrants"], group=Box_Group, inline="ce", active=ce_show)
lvl_color                        = input.color(color.new(#2e2e2e,60), "", group=Box_Group, inline="ce", active=ce_show)
lvl_style                        = input.string('····', '', options = ['⎯⎯⎯', '----', '····'], group=Box_Group, inline="ce", active=ce_show, tooltip=tooltip20)

// FVG Status: tested, partially filled, invalidated
mitigated_type                   = input.string('Wick fill', 'Invalidated when', options = ['None', 'Tapped', 'Wick fill', 'Body fill', 'Wick fill EQ', 'Body fill EQ'], group=Mitigation_Group, tooltip=tooltip21)
bool invalidation_on             = mitigated_type != 'None'
fill_display                     = input.string("Off", "Fill Display ‏ ‏ ‏ ‏ ‏ ‏", options=["Off", "Shrink", "Two-tone"], group=Mitigation_Group, inline="filldisp")
bool twotone_show                = fill_display == "Two-tone"
shrink_on                        = fill_display == "Shrink"
filled_bull                      = input.color(color.new(#2e2e2e, 90), "", group=Mitigation_Group, inline="filldisp", active=twotone_show)
filled_bear                      = input.color(color.new(#2e2e2e, 90), "", group=Mitigation_Group, inline="filldisp", active=twotone_show, tooltip=tooltip22)
tested_show                      = input.bool(false, "Tapped FVG Color ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ", group=Mitigation_Group, inline="tested")
tapped_bull                      = input.color(color.new(#1b5e20, 85), "", group=Mitigation_Group, inline="tested", active=tested_show)
tapped_bear                      = input.color(color.new(#f23645, 85), "", group=Mitigation_Group, inline="tested", active=tested_show, tooltip=tooltip23)
mitigated_show                   = input.bool(false, "Show Invalidated FVGs ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ", group=Mitigation_Group, inline="miti", active=invalidation_on)
inval_bull                       = input.color(color.new(#345e36,85), "", group=Mitigation_Group, inline="miti", active=invalidation_on and mitigated_show)
inval_bear                       = input.color(color.new(#6d2228,85), "", group=Mitigation_Group, inline="miti", active=invalidation_on and mitigated_show, tooltip=tooltip24)
inval_max                        = input.int(5, "Max invalidated per timeframe", minval=0, group=Mitigation_Group, tooltip=tooltip25, active=invalidation_on and mitigated_show)

// Labels
label_show                       = input.bool(true, "Show Label", group=Label_Group, inline="label")
lbl_bull                         = input.color(color.new(#2e2e2e, 0), "", group=Label_Group, inline='label', active=label_show)
lbl_bear                         = input.color(color.new(#2e2e2e, 0), "", group=Label_Group, inline='label', active=label_show)
label_size_s                     = input.string("Small", "", ["Tiny", "Small", "Normal", "Large", "Huge"], group=Label_Group, inline="label", active=label_show)
lbl_size                         = switch label_size_s
    "Tiny"      => size.tiny
    "Normal"    => size.normal
    "Large"     => size.large
    "Huge"      => size.huge
    => size.small
lbl_font                         = input.string("Default", "", options=["Default", "Monospace"], group=Label_Group, inline="label", active=label_show, tooltip=tooltip26)
label_position                   = input.string("Next to FVG", "Label Position‏ ‏ ‏ ", options=["Next to FVG", "Inside FVG"], group=Label_Group, inline="lblpos", active=label_show)
lbl_valign                       = input.string("Center", "", options=["Top", "Center", "Bottom"], group=Label_Group, inline="lblpos", active=label_show, tooltip=tooltip27)
tf_style                         = input.string("[15m]", "Timeframe Style ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ‏ ", options=["15m", "[15m]", "(15m)", "{15m}", "<15m>", "15m |", "15m ·", "15m:"], group=Label_Group, inline="fill5",active=label_show, tooltip=tooltip28)
extra_show                       = input.bool(false, "Extra Text", group=Label_Group, inline="labeltxt", active=label_show)
extra_bull                       = input.string("BISI", "", group=Label_Group, inline="labeltxt", active=label_show and extra_show)
extra_bear                       = input.string("SIBI", "", group=Label_Group, inline="labeltxt", active=label_show and extra_show, tooltip=tooltip29)
fillinfo_show                    = input.bool(false, "Fill Info ‏ ‏ ‏ ", group=Label_Group, inline="fillinfo", active=label_show)
fillinfo_type                    = input.string("Fill %", "", options=["Fill %", "Touches", "Both"], group=Label_Group, inline="fillinfo", active=label_show and fillinfo_show, tooltip=tooltip30)
time_show                        = input.bool(false, "Time ‏ ‏ ‏ ‏ ‏ ‏ ‏ ", group=Label_Group, inline="time", active=label_show)
time_zone_s                      = input.string("New York", "", options=["Exchange", "UTC", "New York", "Chicago", "Los Angeles", "Sao Paulo", "London", "Berlin", "Athens", "Moscow", "Dubai", "Kolkata", "Singapore", "Hong Kong", "Tokyo", "Sydney", "Auckland"], group=Label_Group, inline="time", active=label_show and (time_show or label_position == "Next to FVG"), tooltip=tooltip31)
time_tz                          = f_timeZone(time_zone_s)
hover_show                       = input.bool(true, "Hover Details", group=Label_Group, active=label_show and label_position == "Next to FVG", tooltip=tooltip32)

global_color                     = input.bool(true, "Global Color", inline="colg", group=Colors_Group)
global_bull                      = input.color(color.new(#00332a,90), "", inline="colg", group=Colors_Group, active=global_color)
global_bear                      = input.color(color.new(#801922,90), "", inline="colg", group=Colors_Group, active=global_color, tooltip=tooltip33)
tf1_bull                         = input.color(color.new(#00332a,90), "Timeframe 1 ‏ ‏ ‏ ‏ ‏ ‏ ‏ ", inline="col1", group=Colors_Group, active=show_1 and not global_color)
tf1_bear                         = input.color(color.new(#801922,90), "", inline="col1", group=Colors_Group, tooltip = tooltip34, active=show_1 and not global_color)
tf2_bull                         = input.color(color.new(#00332a,90), "Timeframe 2 ‏ ‏ ‏ ‏ ‏ ‏ ‏ ", inline="col2", group=Colors_Group, active=show_2 and not global_color)
tf2_bear                         = input.color(color.new(#801922,90), "", inline="col2", group=Colors_Group, active=show_2 and not global_color)
tf3_bull                         = input.color(color.new(#00332a,90), "Timeframe 3 ‏ ‏ ‏ ‏ ‏ ‏ ‏ ", inline="col3", group=Colors_Group, active=show_3 and not global_color)
tf3_bear                         = input.color(color.new(#801922,90), "", inline="col3", group=Colors_Group, active=show_3 and not global_color)
tf4_bull                         = input.color(color.new(#00332a,90), "Timeframe 4 ‏ ‏ ‏ ‏ ‏ ‏ ‏ ", inline="col4", group=Colors_Group, active=show_4 and not global_color)
tf4_bear                         = input.color(color.new(#801922,90), "", inline="col4", group=Colors_Group, active=show_4 and not global_color)
tf5_bull                         = input.color(color.new(#00332a,90), "Timeframe 5 ‏ ‏ ‏ ‏ ‏ ‏ ‏ ", inline="col5", group=Colors_Group, active=show_5 and not global_color)
tf5_bear                         = input.color(color.new(#801922,90), "", inline="col5", group=Colors_Group, active=show_5 and not global_color)
tf6_bull                         = input.color(color.new(#00332a,90), "Timeframe 6 ‏ ‏ ‏ ‏ ‏ ‏ ‏ ", inline="col6", group=Colors_Group, active=show_6 and not global_color)
tf6_bear                         = input.color(color.new(#801922,90), "", inline="col6", group=Colors_Group, active=show_6 and not global_color)

// Alerts
alert_new                        = input.bool(false, "New FVG", group=Alert_Group, inline="alev")
alert_tested                     = input.bool(false, "Tapped", group=Alert_Group, inline="alev")
alert_eq                         = input.bool(false, "EQ tapped", group=Alert_Group, inline="alev", tooltip=tooltip35)
bool alert_any                   = alert_new or alert_tested or alert_eq
alert_dir                        = input.string("Both", "Direction", options=["Both", "Bullish", "Bearish"], group=Alert_Group, active=alert_any)
alert_tf1                        = input.bool(true, "TF1", group=Alert_Group, inline="altf", active=alert_any and show_1)
alert_tf2                        = input.bool(true, "TF2", group=Alert_Group, inline="altf", active=alert_any and show_2)
alert_tf3                        = input.bool(true, "TF3", group=Alert_Group, inline="altf", active=alert_any and show_3)
alert_tf4                        = input.bool(true, "TF4", group=Alert_Group, inline="altf", active=alert_any and show_4)
alert_tf5                        = input.bool(true, "TF5", group=Alert_Group, inline="altf", active=alert_any and show_5)
alert_tf6                        = input.bool(true, "TF6", group=Alert_Group, inline="altf", active=alert_any and show_6, tooltip=tooltip36)

// ── Variables ──────────────────────────────────────────────────────────────────────────────────────────────
color NONE                          = color.new(color.white, 100)

// Maximum number of FVGs (valid + invalidated) kept in memory per timeframe
int MAX_GAPS                        = 200

// Drawing limit per type (boxes, lines, labels). TradingView allows 500 and deletes the oldest drawings
// when a script goes over it, so the script stops adding new drawings itself just below that limit
int DRAW_LIMIT                      = 490
var Budget budget                   = Budget.new()

// Fixed Length end times are only needed when a Box Length mode uses them
bool fixed_used                     = extend_mode != "Extend"

int bar_ms                          = nz(time - time[1], timeframe.in_seconds() * 1000)

// Only show FVGs near price: daily ATR on intraday charts, 3x monthly ATR on daily charts, 12x monthly ATR on weekly charts
float atr_daily                     = request.security(syminfo.tickerid, "1D", ta.atr(14))
float atr_monthly                   = request.security(syminfo.tickerid, "1M", ta.atr(14))
float prox_atr                      = timeframe.isintraday ? atr_daily : timeframe.isdaily ? atr_monthly * 3 : timeframe.isweekly ? atr_monthly * 12 : na

// ── Functions ──────────────────────────────────────────────────────────────────────────────────────────────
f_lineStyle(string s) =>
    s == '----' ? line.style_dashed : s == '····' ? line.style_dotted : line.style_solid

// Timeframe text for labels and alerts, e.g. "15m", "4H", "1D"
f_tfText(string tf) =>
    int s = timeframe.in_seconds(tf)
    s % 86400 == 0 ? tf : s % 3600 == 0 ? str.tostring(int(s / 3600)) + "H" : s % 60 == 0 ? str.tostring(int(s / 60)) + "m" : str.tostring(s) + "s"

f_atLeastChart(string tf) =>
    timeframe.in_seconds(tf) >= timeframe.in_seconds()

// A timeframe row that draws FVGs
f_active(bool on, string tf) =>
    on and (f_atLeastChart(tf) or ltf_allow)

f_dirOk(bool bull) =>
    dir_filter == "Both" or (dir_filter == "Bullish") == bull

// Session filter: did candle 2 open inside the session? Not used for daily and higher FVGs. Works across midnight
f_inSession(int t, string tf) =>
    bool ok = true
    if session_on and timeframe.in_seconds(tf) < 86400
        int m = hour(t, session_tz) * 60 + minute(t, session_tz)
        ok := session_start <= session_end ? m >= session_start and m < session_end : m >= session_start or m < session_end
    ok

// Time Lookback cutoff: open time of the chart bar X hours/days ago (counted in chart bars, max 4999 back)
f_cutoff(float amount, string unit) =>
    int bars = math.round(amount * (unit == LB_DAYS ? 86400.0 : 3600.0) / timeframe.in_seconds())
    unit == LB_HOURS or unit == LB_DAYS ? time[math.min(bars, math.min(bar_index, 4999))] : na

// Only `time` needs a long history (Time Lookback), so only its buffer is set to 5000 bars
max_bars_back(time, 5000)

// Potential FVGs: open, high, low and open time of the FVG timeframe candle that is still forming, built from the
// chart bars since that candle opened (no lookahead needed). Each call keeps its own values
f_formingCandle(string tf) =>
    var float f_open    = na
    var float f_high    = na
    var float f_low     = na
    var int   f_time    = na
    if timeframe.change(tf)
        f_open  := open
        f_high  := high
        f_low   := low
        f_time  := time
    else
        f_high  := math.max(f_high, high)
        f_low   := math.min(f_low, low)
    [f_open, f_high, f_low, f_time]

// Checks three candles for an FVG. Returns na when there is none, when two candles have a price gap between them
// (nothing traded in between, e.g. an opening gap, which is not an FVG) or when it is below the Min. FVG size
f_build(Candle a, Candle b, Candle c, float atr) =>
    Gap g = na
    bool bull       = c.l > a.h
    bool bear       = c.h < a.l
    bool price_gap  = b.l > a.h or b.h < a.l or c.l > b.h or c.h < b.l
    if (bull or bear) and not price_gap
        float top   = bull ? c.l : a.l
        float bot   = bull ? a.h : c.h
        float span  = top - bot
        bool big    = not min_size_show or (min_size_unit == "Ticks" ? math.round(span / syminfo.mintick) >= min_size : not na(atr) and span >= atr * min_size / 100)
        if big
            // Include Volume Imbalance: when the bodies of candles 1-2 or 2-3 do not overlap in the direction of the
            // FVG, the FVG is extended to that candle body. The size filter above uses the FVG without it
            if vib_on
                float a_hi  = math.max(a.o, a.c)
                float a_lo  = math.min(a.o, a.c)
                float b_hi  = math.max(b.o, b.c)
                float b_lo  = math.min(b.o, b.c)
                float c_hi  = math.max(c.o, c.c)
                float c_lo  = math.min(c.o, c.c)
                if bull
                    if b_lo > a_hi
                        bot := math.min(bot, a_hi)
                    if c_lo > b_hi
                        top := math.max(top, c_lo)
                else
                    if b_hi < a_lo
                        top := math.max(top, a_lo)
                    if c_hi < b_lo
                        bot := math.min(bot, c_hi)
            g := Gap.new(bull = bull, top = top, bot = bot, t1 = a.t, t2 = b.t, x1 = a.x, x2 = b.x, x3 = c.x)
    g

// Distance from price to the nearest edge of an FVG (0 when price is inside it)
f_dist(Gap g) =>
    close > g.top ? close - g.top : close < g.bot ? g.bot - close : 0.0

f_nearPrice(Gap g) =>
    not prox_filter or na(prox_atr) or (g.top > close - prox_atr * prox_mult and g.bot < close + prox_atr * prox_mult)

// Marks the k entries with the smallest distance to price
f_mark(bool[] marks, float[] dist, int[] idx, int k) =>
    if dist.size() > 0 and k > 0
        int[] ranks = dist.sort_indices(order.ascending)
        for j = 0 to math.min(k, ranks.size()) - 1
            marks.set(idx.get(ranks.get(j)), true)
    marks

// Time an FVG formed: open time of candle 2. Daily and higher FVGs show the date of their trading day. Their
// candles often open the evening before (e.g. futures at 17:00 Chicago time), so 12 hours are added
f_formed(int t2, string tf, bool detailed) =>
    bool daily_up = timeframe.in_seconds(tf) >= 86400
    string s = ""
    if daily_up
        s := str.format_time(t2 + 12 * 3600000, detailed ? "dd MMM yyyy" : "dd MMM", syminfo.timezone)
    else
        s := detailed ? str.format_time(t2, "dd MMM HH:mm", time_tz) + " (" + time_zone_s + ")" : str.format_time(t2, "HH:mm", time_tz)
    s

// ── FVG Methods ────────────────────────────────────────────────────────────────────────────────────────────
method nearSide(Gap g) =>
    g.bull ? g.top : g.bot

method farSide(Gap g) =>
    g.bull ? g.bot : g.top

method eqLevel(Gap g) =>
    (g.top + g.bot) / 2

// Deletes all drawings of an FVG and takes them off the drawing budget
method erase(Gap g) =>
    Visual v = g.v
    if not na(v)
        if not na(v.zone)
            box.delete(v.zone)
            budget.boxes -= 1
        if not na(v.filled)
            box.delete(v.filled)
            budget.boxes -= 1
        if not na(v.textbox)
            box.delete(v.textbox)
            budget.boxes -= 1
        if not na(v.tag)
            label.delete(v.tag)
            budget.labels -= 1
        if not na(v.eq)
            line.delete(v.eq)
            budget.lines -= 1
        if not na(v.q1)
            line.delete(v.q1)
            line.delete(v.q3)
            budget.lines -= 2
        if not na(v.edge)
            line.delete(v.edge)
            budget.lines -= 1
        if not na(v.edge_filled)
            line.delete(v.edge_filled)
            budget.lines -= 1
        if not na(v.tick_far)
            line.delete(v.tick_far)
            line.delete(v.tick_near)
            budget.lines -= 2
        g.v := Visual.new()
    g

// Updates an FVG with one candle: o/c = candle body of the FVG timeframe, h/l = wick (the chart bar for higher
// timeframes, the candle itself for lower timeframes). Price has to trade through a level, touching it is not enough
method track(Gap g, float o, float c, float h, float l) =>
    if fixed_used and na(g.stop_t) and bar_index - g.born >= fixed_len
        g.stop_t := time
    if not g.dead
        float near = g.nearSide()
        // Furthest price of this candle in the FVG's direction (wick, or the body for the Body rules).
        // Most candles do not reach the FVG at all, then nothing can change and the rest is skipped
        float reach = g.bull ? math.min(l, o, c) : math.max(h, o, c)
        if g.bull ? reach < near : reach > near
            float far   = g.farSide()
            float mid   = g.eqLevel()
            // Tapped, fill and touches always use wicks; Invalidated when only decides when the FVG is invalidated
            float px    = g.bull ? l : h
            bool in_gap = g.bull ? px < near : px > near
            if in_gap
                g.deepest := na(g.deepest) ? px : g.bull ? math.min(g.deepest, px) : math.max(g.deepest, px)
                if not g.inside
                    g.touches += 1
                    if g.touches == 1
                        g.tap_bar := bar_index
                if na(g.eq_bar) and (g.bull ? px <= mid : px >= mid)
                    g.eq_bar := bar_index
            g.inside := in_gap
            float body = g.bull ? math.min(o, c) : math.max(o, c)
            g.dead := switch mitigated_type
                'Tapped'            => in_gap
                'Wick fill'         => g.bull ? l < far : h > far
                'Body fill'         => g.bull ? body < far : body > far
                'Wick fill EQ'      => g.bull ? l < mid : h > mid
                'Body fill EQ'      => g.bull ? body < mid : body > mid
                => false
            if g.dead
                g.dead_t := time
        else if g.inside
            // Price left the FVG: the next time it trades into it counts as a new touch
            g.inside := false
    g

// Label text: timeframe + optional extra text, time and fill info
method labelText(Layer L, Gap g, bool touched, float fill_pct) =>
    string tail = ""
    string extra = str.trim(g.bull ? extra_bull : extra_bear)
    if extra_show and extra != ""
        tail += " " + extra
    if time_show
        tail += " " + f_formed(g.t2, L.tf, false)
    if fillinfo_show and touched
        string pct  = str.tostring(math.round(fill_pct * 100)) + "%"
        string hits = "x" + str.tostring(g.touches)
        tail += " " + (fillinfo_type == "Touches" ? hits : fillinfo_type == "Both" ? pct + " " + hits : pct)
    // Timeframe Style is a template ("15m" is replaced). Separator styles only show the separator when text follows
    string name = f_tfText(L.tf) + (g.potential ? "*" : "")
    bool sep    = tf_style == "15m |" or tf_style == "15m ·" or tf_style == "15m:"
    (sep and tail == "" ? name : str.replace(tf_style, "15m", name)) + tail

// Hover details: tooltip of Next to FVG labels with all information about the FVG
method hoverText(Layer L, Gap g, bool touched, float fill_pct) =>
    float span      = g.top - g.bot
    string status   = g.potential ? "Potential (candle 3 is still forming)" : g.dead ? "Invalidated" : touched ? "Tapped" : "Untouched"
    string s        = f_tfText(L.tf) + (g.bull ? " Bullish FVG" : " Bearish FVG")
    s += "\nFormed: " + f_formed(g.t2, L.tf, true)
    s += "\nTop: " + str.tostring(g.top, format.mintick)
    s += "\nBottom: " + str.tostring(g.bot, format.mintick)
    s += "\nEQ: " + str.tostring(g.eqLevel(), format.mintick)
    s += "\nSize: " + str.tostring(span, format.mintick) + " (" + str.tostring(math.round(span / syminfo.mintick)) + " ticks)"
    s += "\nStatus: " + status
    if not g.potential and not g.dead
        s += "\nFilled: " + str.tostring(math.round(fill_pct * 100)) + "%"
        s += "\nTouches: " + str.tostring(g.touches)
        s += "\nEQ tapped: " + (na(g.eq_bar) ? "No" : "Yes")
    s

// Draws or updates one FVG. col = column of its timeframe, extended = the FVG reaches the current candle
method paint(Layer L, Gap g, int col, bool extended) =>
    Visual v            = g.v
    // Display of this FVG: potential FVGs have their own display
    string mode         = g.potential ? pot_display : display_mode
    bool as_line        = mode != "Box"
    bool as_bracket     = mode == "Bracket"
    float near          = g.nearSide()
    float far           = g.farSide()
    float mid           = g.eqLevel()
    // Partially filled: price traded into the FVG, but it is not invalidated
    bool touched        = not g.dead and not na(g.deepest)
    float fill_lvl      = touched ? (g.bull ? math.max(g.deepest, far) : math.min(g.deepest, far)) : na
    float fill_pct      = touched ? math.abs(near - fill_lvl) / (g.top - g.bot) : 0.0
    // Shrink / Two-tone: the box only covers the unfilled part (in Line / Bracket, Two-tone is shown on the line)
    bool split          = touched and (shrink_on or (twotone_show and not as_line))
    float edge_lvl      = split ? fill_lvl : near
    color base          = g.dead ? (g.bull ? inval_bull : inval_bear) : touched and tested_show ? (g.bull ? tapped_bull : tapped_bear) : (g.bull ? L.col_bull : L.col_bear)
    // Potential FVG: half as opaque, and always a dashed border or line
    if g.potential
        base := color.new(base, 100 - (100 - color.t(base)) / 2)
    bool border_on      = (border_show or g.potential) and not as_line
    color border_col    = border_on ? color.new(base, border_transp) : NONE
    color fill_col      = box_fill and not as_line ? base : NONE

    // Right edge: the column of the timeframe, the invalidation bar, or the end of the Fixed Length
    int right           = g.dead ? g.dead_t : time + bar_ms * (col_offset + 1 + col_spacing * (col - 1))
    if extend_mode == "Fixed bars" or (extend_mode == "Extend nearest" and not extended)
        // Until the end bar is reached, the remaining bars are projected into the future
        int fixed_end   = na(g.stop_t) ? time + bar_ms * (fixed_len - (bar_index - g.born)) : g.stop_t
        right           := g.dead ? math.min(g.dead_t, fixed_end) : fixed_end
    int left            = switch draw_start
        "Candle 2" => g.x2
        "Candle 3" => g.x3
        "Candle 4" => g.x4
        => g.x1

    string txt          = label_show ? L.labelText(g, touched, fill_pct) : ""
    string tip          = label_show and hover_show and label_position == "Next to FVG" ? L.hoverText(g, touched, fill_pct) : ""
    color txt_col       = g.bull ? lbl_bull : lbl_bear
    string family       = lbl_font == "Monospace" ? font.family_monospace : font.family_default
    bool inside_txt     = label_show and label_position == "Inside FVG"
    string valign       = lbl_valign == "Top" ? text.align_top : lbl_valign == "Bottom" ? text.align_bottom : text.align_center
    // Next to FVG label height: top edge, middle or bottom edge. With Shrink it follows the unfilled part
    float span_top      = shrink_on ? math.max(far, edge_lvl) : g.top
    float span_bot      = shrink_on ? math.min(far, edge_lvl) : g.bot
    float tag_y         = lbl_valign == "Top" ? span_top : lbl_valign == "Bottom" ? span_bot : (span_top + span_bot) / 2
    string tag_style    = lbl_valign == "Top" ? label.style_label_upper_left : lbl_valign == "Bottom" ? label.style_label_lower_left : label.style_label_left
    float z_top         = math.max(far, edge_lvl)
    float z_bot         = math.min(far, edge_lvl)

    if na(v.zone)
        // Only drawn when the drawing budget has room, otherwise the FVG is skipped until there is room again
        if budget.boxes < DRAW_LIMIT
            // Inside FVG text sits right against the box's right edge (a label keeps a gap for its pointer)
            v.zone := box.new(left, z_top, right, z_bot, border_col, border_on ? 1 : 0, border_style = g.potential ? f_lineStyle(pot_style) : line.style_solid, xloc = xloc.bar_time, bgcolor = fill_col, text = inside_txt ? txt : "", text_halign = text.align_right, text_valign = valign, text_color = txt_col, text_size = lbl_size, text_font_family = family)
            budget.boxes += 1
            if label_show and not inside_txt and budget.labels < DRAW_LIMIT
                v.tag := label.new(right, tag_y, txt, xloc = xloc.bar_time, color = NONE, style = tag_style, textcolor = txt_col, size = lbl_size, text_font_family = family, tooltip = tip)
                budget.labels += 1
            if ce_show and budget.lines < DRAW_LIMIT
                v.eq := line.new(left, mid, right, mid, xloc = xloc.bar_time, color = lvl_color, style = f_lineStyle(lvl_style))
                budget.lines += 1
    else
        box.set_right(v.zone, right)
        box.set_top(v.zone, z_top)
        box.set_bottom(v.zone, z_bot)
        box.set_bgcolor(v.zone, fill_col)
        box.set_border_color(v.zone, border_col)
        if inside_txt
            box.set_text(v.zone, txt)
        if not na(v.tag)
            label.set_xy(v.tag, right, tag_y)
            label.set_text(v.tag, txt)
            label.set_tooltip(v.tag, tip)
        if not na(v.eq)
            line.set_x2(v.eq, right)

    // Quadrants: 25% and 75% lines (the 50% line is the EQ line)
    if ce_show and lvl_mode == "Quadrants" and not na(v.zone)
        float q1 = far + (near - far) * 0.25
        float q3 = far + (near - far) * 0.75
        if na(v.q1)
            if budget.lines + 2 <= DRAW_LIMIT
                v.q1 := line.new(left, q1, right, q1, xloc = xloc.bar_time, color = lvl_color, style = f_lineStyle(lvl_style))
                v.q3 := line.new(left, q3, right, q3, xloc = xloc.bar_time, color = lvl_color, style = f_lineStyle(lvl_style))
                budget.lines += 2
        else
            line.set_x2(v.q1, right)
            line.set_x2(v.q3, right)
    else if not na(v.q1)
        line.delete(v.q1)
        line.delete(v.q3)
        budget.lines -= 2
        v.q1 := na
        v.q3 := na

    // Two-tone (Box display): second box over the part of the FVG that is already filled
    if split and twotone_show and not as_line and not na(v.zone)
        color tt        = g.bull ? filled_bull : filled_bear
        float f_top     = math.max(near, fill_lvl)
        float f_bot     = math.min(near, fill_lvl)
        if na(v.filled)
            if budget.boxes < DRAW_LIMIT
                v.filled := box.new(left, f_top, right, f_bot, border_show ? color.new(tt, border_transp) : NONE, border_show ? 1 : 0, xloc = xloc.bar_time, bgcolor = box_fill ? tt : NONE)
                budget.boxes += 1
        else
            box.set_right(v.filled, right)
            box.set_top(v.filled, f_top)
            box.set_bottom(v.filled, f_bot)
    else if not na(v.filled)
        box.delete(v.filled)
        budget.boxes -= 1
        v.filled := na

    // Two-tone + Inside FVG label: the text moves to an invisible full-size box, so it does not move with the fill
    if inside_txt and not na(v.filled)
        if na(v.textbox)
            if budget.boxes < DRAW_LIMIT
                v.textbox := box.new(left, g.top, right, g.bot, NONE, 0, xloc = xloc.bar_time, bgcolor = NONE, text = txt, text_halign = text.align_right, text_valign = valign, text_color = txt_col, text_size = lbl_size, text_font_family = family)
                budget.boxes += 1
        else
            box.set_right(v.textbox, right)
            box.set_text(v.textbox, txt)
        // The text only moves when the full-size box could be drawn
        if not na(v.textbox)
            box.set_text(v.zone, "")
    else if not na(v.textbox)
        box.delete(v.textbox)
        budget.boxes -= 1
        v.textbox := na

    // Line and Bracket display: vertical line on the right edge. The filled part can have its own width and color
    if as_line and not na(v.zone)
        bool part       = touched and not shrink_on and (twotone_show or line_w_filled != line_w)
        float line_end  = touched and (shrink_on or part) ? fill_lvl : near
        // Potential FVGs use their own line style, width 1 and a fixed 30% transparency
        int transp      = g.potential ? 30 : line_transp
        color lc        = color.new(base, transp)
        color fc        = twotone_show ? color.new(g.bull ? filled_bull : filled_bear, transp) : lc
        string ls       = f_lineStyle(g.potential ? pot_style : line_style)
        int lw          = g.potential ? 1 : line_w
        if na(v.edge)
            if budget.lines < DRAW_LIMIT
                v.edge := line.new(right, far, right, line_end, xloc = xloc.bar_time, color = lc, width = lw, style = ls)
                budget.lines += 1
        else
            line.set_xy1(v.edge, right, far)
            line.set_xy2(v.edge, right, line_end)
            line.set_color(v.edge, lc)
        if part and not na(v.edge)
            if na(v.edge_filled)
                if budget.lines < DRAW_LIMIT
                    v.edge_filled := line.new(right, fill_lvl, right, near, xloc = xloc.bar_time, color = fc, width = line_w_filled, style = ls)
                    budget.lines += 1
            else
                line.set_xy1(v.edge_filled, right, fill_lvl)
                line.set_xy2(v.edge_filled, right, near)
                line.set_color(v.edge_filled, fc)
        else if not na(v.edge_filled)
            line.delete(v.edge_filled)
            budget.lines -= 1
            v.edge_filled := na

        // Bracket: short ticks pointing left from both ends of the edge line, like "]"
        if as_bracket and not na(v.edge)
            int tick_left   = right - bar_ms * bracket_len
            float near_y    = touched and shrink_on ? fill_lvl : near
            color near_col  = part ? fc : lc
            int near_w      = part ? line_w_filled : lw
            if na(v.tick_far)
                if budget.lines + 2 <= DRAW_LIMIT
                    v.tick_far  := line.new(tick_left, far, right, far, xloc = xloc.bar_time, color = lc, width = lw, style = ls)
                    v.tick_near := line.new(tick_left, near_y, right, near_y, xloc = xloc.bar_time, color = near_col, width = near_w, style = ls)
                    budget.lines += 2
            else
                line.set_xy1(v.tick_far, tick_left, far)
                line.set_xy2(v.tick_far, right, far)
                line.set_color(v.tick_far, lc)
                line.set_xy1(v.tick_near, tick_left, near_y)
                line.set_xy2(v.tick_near, right, near_y)
                line.set_color(v.tick_near, near_col)
                line.set_width(v.tick_near, near_w)
        else if not na(v.tick_far)
            line.delete(v.tick_far)
            line.delete(v.tick_near)
            budget.lines -= 2
            v.tick_far  := na
            v.tick_near := na
    g

// ── Layer Methods ──────────────────────────────────────────────────────────────────────────────────────────
// Adds a new FVG. x4 = chart bar time where candle 4 starts
method add(Layer L, Gap g, int x4) =>
    g.x4            := x4
    g.born          := bar_index
    g.in_session    := f_inSession(g.t2, L.tf)
    g.v             := Visual.new()
    L.gaps.unshift(g)
    L.last_t1       := g.t1
    if L.gaps.size() > MAX_GAPS
        // The oldest invalidated FVG goes first, so older valid FVGs are kept
        int idx = L.gaps.size() - 1
        for i = L.gaps.size() - 1 to 0
            if L.gaps.get(i).dead
                idx := i
                break
        L.gaps.remove(idx).erase()
    L

// Alert id and name of an FVG, e.g. "[15m]" + candle 1 time and "[15m] Bullish FVG"
f_alertId(Layer L, Gap g) =>
    string tag = "[" + f_tfText(L.tf) + "]"
    [tag + str.tostring(g.t1), tag + (g.bull ? " Bullish FVG" : " Bearish FVG")]

// An FVG that is invalidated on the bar of its tap or EQ tap still sends those alerts. Normally only drawn FVGs send
// alerts. An FVG confirmed on this bar is not drawn yet when it is invalidated (on live bars the script starts every
// price update from the state at the start of the bar), so it counts as drawn when it passes the display filters
method noteLate(Layer L, Gap g) =>
    if na(L.late_bar) or L.late_bar != bar_index
        L.late_keys.clear()
        L.late_msgs.clear()
        L.late_bar := bar_index
    bool born_now = g.born == bar_index
    bool drawn = not na(g.v.zone) or (born_now and g.in_session and f_dirOk(g.bull) and f_nearPrice(g))
    if L.alerts and drawn and (alert_dir == "Both" or (alert_dir == "Bullish") == g.bull)
        [id, name] = f_alertId(L, g)
        if alert_new and born_now
            L.late_keys.push(id + "new")
            L.late_msgs.push(name + " formed")
        if alert_tested and g.tap_bar == bar_index
            L.late_keys.push(id + "tap")
            L.late_msgs.push(name + " tapped")
        if alert_eq and g.eq_bar == bar_index
            L.late_keys.push(id + "eq")
            L.late_msgs.push(name + " EQ tapped")
    L

// Tracks all FVGs with one candle. Invalidated FVGs are removed unless Show Invalidated FVGs is on
method update(Layer L, float o, float c, float h, float l) =>
    int n = L.gaps.size()
    if n > 0
        for i = n - 1 to 0
            Gap g       = L.gaps.get(i)
            bool was    = g.dead
            g.track(o, c, h, l)
            if g.dead and not was
                L.noteLate(g)
                if not mitigated_show
                    g.erase()
                    L.gaps.remove(i)
    L

// Time Lookback: FVGs older than the window can never be shown again, so they are removed (oldest are at the end)
method prune(Layer L) =>
    if not na(L.cutoff)
        while L.gaps.size() > 0 and L.gaps.last().t1 < L.cutoff
            L.gaps.pop().erase()
    L

// Timeframes equal to or higher than the chart: the last three completed candles, checked once per new candle
method scanHigher(Layer L, float o1, float h1, float l1, float c1, int t1, float o2, float h2, float l2, float c2, int t2, float o3, float h3, float l3, float c3, int t3, float atr) =>
    if not na(t1) and (na(L.seen_t) or t3 != L.seen_t)
        L.seen_t := t3
        if (l3 > h1 or h3 < l1) and (na(L.last_t1) or t1 > L.last_t1)
            Gap g = f_build(Candle.new(o1, h1, l1, c1, t1, t1), Candle.new(o2, h2, l2, c2, t2, t2), Candle.new(o3, h3, l3, c3, t3, t3), atr)
            if not na(g)
                // This is the first chart bar of candle 4
                L.add(g, time)
    L

// Timeframes lower than the chart: the candles inside the chart bar, in order. Each closed candle first updates the
// existing FVGs, then becomes candle 3 of a new check. A candle that is still forming is kept for potential FVGs
method scanLower(Layer L, float[] ao, float[] ah, float[] al, float[] ac, int[] at) =>
    L.forming := na
    if not na(at)
        int n = at.size()
        if n > 0
            int tf_ms = timeframe.in_seconds(L.tf) * 1000
            for k = 0 to n - 1
                int t = at.get(k)
                if na(L.last_t) or t > L.last_t
                    Candle cur  = Candle.new(ao.get(k), ah.get(k), al.get(k), ac.get(k), t, time)
                    bool closed = k < n - 1 or barstate.isconfirmed or t + tf_ms <= timenow
                    if closed
                        L.last_t := t
                        L.update(cur.o, cur.c, cur.h, cur.l)
                        // ATR(14) of the timeframe (RMA of the true range, like ta.atr), for the Min. FVG size filter
                        float tr    = na(L.prev_c) ? cur.h - cur.l : math.max(cur.h - cur.l, math.abs(cur.h - L.prev_c), math.abs(cur.l - L.prev_c))
                        L.atr       := na(L.atr) ? tr : (L.atr * 13 + tr) / 14
                        L.prev_c    := cur.c
                        if not na(L.p2)
                            Gap g = f_build(L.p2, L.p1, cur, L.atr)
                            if not na(g) and (na(L.last_t1) or g.t1 > L.last_t1)
                                // Candle 4 starts in this chart bar, or in the next one when candle 3 is its last candle
                                L.add(g, k < n - 1 ? time : time_close)
                        L.p2 := L.p1
                        L.p1 := cur
                    else
                        L.forming := cur
    L

// Decides which FVGs of the timeframe are shown and draws them. col = column of the timeframe
method render(Layer L, int col) =>
    int n = L.gaps.size()
    if n > 0
        bool time_mode      = L.lb_unit == LB_HOURS or L.lb_unit == LB_DAYS
        bool nearest_mode   = L.lb_unit == LB_NEAREST
        // Filters: near price, session, direction, and the Time Lookback window. Filtered FVGs are still tracked
        bool[] passes = array.new_bool(n, false)
        for i = 0 to n - 1
            Gap g = L.gaps.get(i)
            passes.set(i, f_nearPrice(g) and g.in_session and f_dirOk(g.bull) and (not time_mode or na(L.cutoff) or g.t1 >= L.cutoff))

        // Nearest lookback: the X nearest valid FVGs above price and the X nearest below price
        bool[] picked = array.new_bool(n, false)
        if nearest_mode
            float[] d_up = array.new_float()
            int[]   i_up = array.new_int()
            float[] d_dn = array.new_float()
            int[]   i_dn = array.new_int()
            for i = 0 to n - 1
                Gap g = L.gaps.get(i)
                if passes.get(i) and not g.dead
                    if g.eqLevel() >= close
                        d_up.push(f_dist(g))
                        i_up.push(i)
                    else
                        d_dn.push(f_dist(g))
                        i_dn.push(i)
            f_mark(picked, d_up, i_up, L.lb_amt)
            f_mark(picked, d_dn, i_dn, L.lb_amt)

        // Shown FVGs, newest first. Invalidated FVGs have their own limit, so they never push valid ones off the chart
        bool[] shown    = array.new_bool(n, false)
        int valid_n     = 0
        int dead_n      = 0
        int limit       = time_mode ? MAX_GAPS : L.lb_amt
        for i = 0 to n - 1
            Gap g = L.gaps.get(i)
            if passes.get(i)
                if g.dead
                    if dead_n < inval_max
                        shown.set(i, true)
                        dead_n += 1
                else if nearest_mode ? picked.get(i) : valid_n < limit
                    shown.set(i, true)
                    valid_n += 1

        // Extend nearest: only the X nearest shown valid bullish and X nearest bearish FVGs reach the current candle
        bool[] extended = array.new_bool(n, extend_mode == "Extend")
        if extend_mode == "Extend nearest"
            float[] d_bull = array.new_float()
            int[]   i_bull = array.new_int()
            float[] d_bear = array.new_float()
            int[]   i_bear = array.new_int()
            for i = 0 to n - 1
                Gap g = L.gaps.get(i)
                if shown.get(i) and not g.dead
                    if g.bull
                        d_bull.push(f_dist(g))
                        i_bull.push(i)
                    else
                        d_bear.push(f_dist(g))
                        i_bear.push(i)
            f_mark(extended, d_bull, i_bull, nearest_extend)
            f_mark(extended, d_bear, i_bear, nearest_extend)

        for i = 0 to n - 1
            Gap g = L.gaps.get(i)
            if shown.get(i)
                L.paint(g, col, extended.get(i))
            else
                g.erase()
    L

// Potential FVG: candle 1 and the still forming candle 3 already have a gap. Redrawn on every update, not stored
method showPotential(Layer L, int col, Candle c1, Candle c2, Candle c3, float atr) =>
    if not na(L.pot)
        L.pot.erase()
        L.pot := na
    if potential_show and not na(c1) and not na(c2) and not na(c3)
        if not na(c1.t) and not na(c3.t)
            Gap g = f_build(c1, c2, c3, atr)
            if not na(g)
                if f_nearPrice(g) and f_dirOk(g.bull) and f_inSession(g.t2, L.tf)
                    g.potential := true
                    // There is no candle 4 yet, so Draw FVG from "Candle 4" starts at candle 3
                    g.x4        := g.x3
                    g.born      := bar_index
                    g.v         := Visual.new()
                    L.pot       := g
                    L.paint(g, col, true)
    L

// Alerts: this bar's events of the valid, drawn FVGs. keys identify each event so it is only sent once
method collectAlerts(Layer L, string[] keys, string[] msgs) =>
    if L.on and L.alerts
        for g in L.gaps
            if not g.dead and not na(g.v.zone) and (alert_dir == "Both" or (alert_dir == "Bullish") == g.bull)
                [id, name] = f_alertId(L, g)
                if alert_new and g.born == bar_index
                    keys.push(id + "new")
                    msgs.push(name + " formed")
                if alert_tested and g.tap_bar == bar_index
                    keys.push(id + "tap")
                    msgs.push(name + " tapped")
                if alert_eq and g.eq_bar == bar_index
                    keys.push(id + "eq")
                    msgs.push(name + " EQ tapped")
        if L.late_bar == bar_index and L.late_keys.size() > 0
            for k = 0 to L.late_keys.size() - 1
                keys.push(L.late_keys.get(k))
                msgs.push(L.late_msgs.get(k))
    L

// Hide nested: the valid, drawn FVGs of a timeframe, with the timeframe in seconds
method collectDrawn(Layer L, Gap[] list, int[] secs) =>
    if L.on
        int s = timeframe.in_seconds(L.tf)
        for g in L.gaps
            if not g.dead and not na(g.v.zone)
                list.push(g)
                secs.push(s)
    L

// One timeframe row on one bar. [1]/[2]/[3] offsets with lookahead_on only use completed candles, so historical
// and realtime bars give the same result (no repainting). Candle 1 = [3], candle 2 = [2], candle 3 = [1]
f_run(Layer L, string tf, float amt, int col) =>
    [o3, h3, l3, c3, t3, o2, h2, l2, c2, t2, o1, h1, l1, c1, t1, atr] = request.security(syminfo.tickerid, tf, [open[1], high[1], low[1], close[1], time[1], open[2], high[2], low[2], close[2], time[2], open[3], high[3], low[3], close[3], time[3], ta.atr(14)[1]], lookahead = barmerge.lookahead_on)
    string ltf = ltf_allow and timeframe.in_seconds(tf) < timeframe.in_seconds() ? tf : timeframe.period
    [lo, lh, ll, lc, lt] = request.security_lower_tf(syminfo.tickerid, ltf, [open, high, low, close, time], ignore_invalid_timeframe = true)
    [fo, fh, fl, ft] = f_formingCandle(tf)
    L.cutoff := f_cutoff(amt, L.lb_unit)
    if L.on
        bool higher = f_atLeastChart(tf)
        if higher
            L.scanHigher(o1, h1, l1, c1, t1, o2, h2, l2, c2, t2, o3, h3, l3, c3, t3, atr)
            L.prune()
            L.update(o3, c3, high, low)
        else if ltf_allow
            L.scanLower(lo, lh, ll, lc, lt)
            L.prune()
        // Drawings only show the current state, so they are only made on the last bar
        if barstate.islast and (higher or ltf_allow)
            L.render(col)
            if higher
                Candle forming = na
                if not na(ft)
                    forming := Candle.new(fo, fh, fl, close, ft, ft)
                L.showPotential(col, Candle.new(o2, h2, l2, c2, t2, t2), Candle.new(o3, h3, l3, c3, t3, t3), forming, atr)
            else
                L.showPotential(col, L.p2, L.p1, L.forming, L.atr)
    L

// ── Main ───────────────────────────────────────────────────────────────────────────────────────────────────
f_newLayer(bool on, string tf, float amt, string unit, color bull, color bear, bool alerts) =>
    Layer.new(tf = tf, on = on, lb_amt = math.floor(amt), lb_unit = unit, col_bull = bull, col_bear = bear, alerts = alerts, gaps = array.new<Gap>(), late_keys = array.new_string(), late_msgs = array.new_string())

var Layer L1 = f_newLayer(show_1, htf_1, lb_amt_1, lb_unit_1, global_color ? global_bull : tf1_bull, global_color ? global_bear : tf1_bear, alert_tf1)
var Layer L2 = f_newLayer(show_2, htf_2, lb_amt_2, lb_unit_2, global_color ? global_bull : tf2_bull, global_color ? global_bear : tf2_bear, alert_tf2)
var Layer L3 = f_newLayer(show_3, htf_3, lb_amt_3, lb_unit_3, global_color ? global_bull : tf3_bull, global_color ? global_bear : tf3_bear, alert_tf3)
var Layer L4 = f_newLayer(show_4, htf_4, lb_amt_4, lb_unit_4, global_color ? global_bull : tf4_bull, global_color ? global_bear : tf4_bear, alert_tf4)
var Layer L5 = f_newLayer(show_5, htf_5, lb_amt_5, lb_unit_5, global_color ? global_bull : tf5_bull, global_color ? global_bear : tf5_bear, alert_tf5)
var Layer L6 = f_newLayer(show_6, htf_6, lb_amt_6, lb_unit_6, global_color ? global_bull : tf6_bull, global_color ? global_bear : tf6_bear, alert_tf6)

// Column of each timeframe for extended FVGs (Offset / TF Spacing): the number of active rows up to that one
int col_1 = f_active(show_1, htf_1) ? 1 : 0
int col_2 = col_1 + (f_active(show_2, htf_2) ? 1 : 0)
int col_3 = col_2 + (f_active(show_3, htf_3) ? 1 : 0)
int col_4 = col_3 + (f_active(show_4, htf_4) ? 1 : 0)
int col_5 = col_4 + (f_active(show_5, htf_5) ? 1 : 0)
int col_6 = col_5 + (f_active(show_6, htf_6) ? 1 : 0)

f_run(L1, htf_1, lb_amt_1, col_1)
f_run(L2, htf_2, lb_amt_2, col_2)
f_run(L3, htf_3, lb_amt_3, col_3)
f_run(L4, htf_4, lb_amt_4, col_4)
f_run(L5, htf_5, lb_amt_5, col_5)
f_run(L6, htf_6, lb_amt_6, col_6)

// Hide nested FVGs: remove an FVG that lies inside a same-direction FVG of a higher timeframe
if hide_nested and barstate.islast
    Gap[] drawn = array.new<Gap>()
    int[] secs  = array.new_int()
    L1.collectDrawn(drawn, secs)
    L2.collectDrawn(drawn, secs)
    L3.collectDrawn(drawn, secs)
    L4.collectDrawn(drawn, secs)
    L5.collectDrawn(drawn, secs)
    L6.collectDrawn(drawn, secs)
    int n = drawn.size()
    if n > 1
        bool[] nested = array.new_bool(n, false)
        for i = 0 to n - 1
            Gap a = drawn.get(i)
            for j = 0 to n - 1
                Gap b = drawn.get(j)
                if secs.get(j) > secs.get(i) and b.bull == a.bull and b.top >= a.top and b.bot <= a.bot
                    nested.set(i, true)
                    break
        // Marked first and removed afterwards, so every FVG is compared with all others
        for i = 0 to n - 1
            if nested.get(i)
                drawn.get(i).erase()

// ── Alerts ─────────────────────────────────────────────────────────────────────────────────────────────────
// varip keeps the events already sent during the current bar (other variables reset on every price update)
varip string sent_keys  = ""
varip int    sent_bar   = na

if barstate.isrealtime and alert_any
    if na(sent_bar) or sent_bar != bar_index
        sent_keys   := ""
        sent_bar    := bar_index
    string[] keys   = array.new_string()
    string[] msgs   = array.new_string()
    L1.collectAlerts(keys, msgs)
    L2.collectAlerts(keys, msgs)
    L3.collectAlerts(keys, msgs)
    L4.collectAlerts(keys, msgs)
    L5.collectAlerts(keys, msgs)
    L6.collectAlerts(keys, msgs)
    string msg = ""
    if keys.size() > 0
        for k = 0 to keys.size() - 1
            string key = "|" + keys.get(k) + "|"
            if not str.contains(sent_keys, key)
                sent_keys += key
                msg += (msg == "" ? "" : "\n") + msgs.get(k)
    // Events of the same update are combined into one message
    if msg != ""
        alert(syminfo.ticker + "\n" + msg, alert.freq_all)
````
