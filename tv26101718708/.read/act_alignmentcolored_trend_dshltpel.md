# ACT: Alignment-Colored Trend

- url: https://www.tradingview.com/script/DShLTpEl-ACT-Alignment-Colored-Trend/
- type: indicator
- pine_id: PUB;aa2af166cd654601838670f493707e35
- version: 1.0

## Description

ACT: Alignment-Colored Trend colors candles by trend direction, then shades them by how much of the market agrees with the move: how far up a ladder of timeframes a breakout holds, and whether related indexes are breaking with it. It applies TheStrat methodology (developed by Rob Smith), and many of its underlying concepts come from TheStrat: the 1, 2 and 3 bar types, Failed 2s, timeframe continuity, and simultaneous breaks across related markets.

[b]WHAT IT DOES[/b]

Each candle is read against a ladder of five timeframes (Trigger, State 1, State 2, Direction 1, Direction 2) and against three related indexes. The Direction timeframes set the color. The shade, from faint to solid, adds up how many ladder timeframes are breaking with the trend, on the chart symbol and on the indexes. A badge names the ladder in use, and an optional dashboard, alignment dots, two alerts and four data-window values show the same reading in detail. The indicator is display only: no orders, entries or strategy.

[b]HOW IT WORKS[/b]

[b]Candle Colors[/b]
[list]
[*][b]Green / red:[/b] bull / bear. Price is above (below) both Direction timeframe opens.
[*][b]Faint to solid:[/b] the shade, 0 to 11 points of confirmation.
[*][b]Lime / pink:[/b] peak, shade 10 or more by default. A related index holds a Direction 1 breakout, and both State timeframes break with the trend.
[*][b]Blue / purple:[/b] counter-trend. The two Direction timeframes disagree, and a State 2 breakout sets the direction.
[*][b]Grey:[/b] no trend. The Direction timeframes conflict, are both inside, or are failing.
[/list]

[b]Shade[/b]
[list]
[*][b]Cascade:[/b] the highest ladder timeframe at which any of the three related indexes holds a break of its prior bar in the trend direction. Direction 1 = 7, State 2 = 3, State 1 = 1.
[*][b]State 2[/b] on the chart symbol: +2 for a break with the trend (for bulls, a 2u or a Failed 2d), +1 for an outside bar closing with it, 0 for an inside bar, -1 against or failing.
[*][b]State 1[/b] on the chart symbol: +1 breaking with the trend, -1 against.
[*][b]Counter-trend:[/b] +1 when the cascade reaches State 2 or higher.
[/list]

[b]Related Indexes[/b]
Auto picks the set from the chart symbol: ES/NQ/RTY/YM for futures, SPY/QQQ/IWM/DIA for ETFs, BTC/ETH/SOL/XRP for crypto, with the chart's own ticker left out. Stocks and other symbols compare against the ETFs. Custom takes any three symbols.

[b]Ladders[/b]
Each ladder is five steps of the Strat timeframe list (1m 5m 15m 30m 1H 4H D W M Q Y), in order: Trigger, State 1, State 2, Direction 1, Direction 2.
[list]
[*][b]Scalp:[/b] 15m, 30m, 1H, 4H, D. Auto under 1 minute.
[*][b]Day Trade:[/b] 30m, 1H, 4H, D, W. Auto from 1 minute to 1 hour.
[*][b]Swing:[/b] 4H, D, W, M, Q. Auto above 1 hour to 1 day.
[*][b]Position:[/b] D, W, M, Q, Y. Auto above 1 day to 1 week.
[/list]
The colors come from the ladder. Inside one ladder, a 1m and a 5m chart show the same reading, and the 1m updates more often. Locking a ladder keeps one reading across charts. Above its State 1 timeframe, a locked ladder stands down and the badge turns orange.

[b]Stance and Grade[/b]
Stance is Watch while the trend is on, and turns Active once the prior Trigger bar's high or low breaks behind a ladder-timeframe breakout. Stand Aside means no trend. Grade adds index sync to the shade: a simultaneous break of the prior chart bar by all three indexes adds 4, by two of them adds 2. A+ at 10, A 7, B 5, C 3, D 1. Stance and grade are readouts in the dashboard and the detailed alert, and they never change the paint.

[b]IMPLEMENTATION DETAILS[/b]

Timeframe-continuity candles show whether price is above or below the higher-timeframe opens. ACT starts from that direction and adds the following.
[list]
[*][b]Breakouts on the ladder:[/b] the shade also counts whether price is breaking prior bars on the State timeframes.

[*][b]Breadth across indexes:[/b] the cascade checks the related indexes on each ladder timeframe. On a Day Trade chart, a green ES candle starts at 7 of 11 points while NQ, RTY or YM holds a daily breakout, and at 3 or less when none does.

[*][b]Index sets by market:[/b] Auto matches the index family to the chart symbol and follows each market's sessions, including CME 4-hour windows for futures and midnight-ET windows for crypto.
[/list]

[b]HOW TO USE IT[/b]

[b]Setup[/b]
Add ACT to any chart up to 1 week. Auto picks the ladder and the index set. Pick a ladder under Timeframes to lock it, or Custom under Indexes to choose three symbols. Turning off Grey When No Trend leaves no-trend candles in the chart's own colors.

[b]Reading the Display[/b]
[list]
[*][b]Badge[/b] (on by default): the ladder in use, with each State and Direction timeframe green or red against its open.
[*][b]Dashboard[/b] (off by default): trend and its source, stance and why, grade, the Trigger bar, the indexes, and each ladder timeframe's bar type.
[*][b]Alignment dots[/b] (off by default): one per Trigger, State 1, State 2 and Direction 1 timeframe. Bright when the chart and all three indexes hold beyond that timeframe's prior high (bull) or low (bear) at the same time, dim at three of four.
[*][b]Data window:[/b] Trend, Shade, Score and Stance.
[/list]

[b]Alerts[/b]
Create an alert on ACT and pick "ACT: Trend On" (grey to colored) or "ACT: Trend Off" (colored to grey). Both fire once, on bar close. For one alert that covers both, turn on Detailed Alert Message and pick "Any alert() function call". The message carries direction, source, grade and stance.

[b]DOES IT REPAINT?[/b]

No. Closed candles don't change. Higher timeframes come from completed bars and period opens, and every forming higher-timeframe range is rebuilt from chart bars. The live candle's color updates while it forms, by design.

[b]DEFINITIONS[/b]
[list]
[*][b]1:[/b] inside bar, within the prior bar's range.
[*][b]2u / 2d:[/b] broke the prior high (low) and holds beyond it.
[*][b]3:[/b] outside bar, broke both sides of the prior bar.
[*][b]Failed 2:[/b] broke one side of the prior bar and closed back inside its range.
[*][b]Timeframe continuity:[/b] price on the same side of the open on several timeframes.
[*][b]Simultaneous break:[/b] related markets breaking the same side of their prior bar at the same time.
[*][b]Trigger, State, Direction:[/b] the ladder's five timeframes, lowest to highest.
[*][b]Cascade:[/b] the highest ladder timeframe at which a related index holds a break with the trend.
[/list]

[b]KNOWN LIMITATIONS[/b]
[list]
[*]ACT runs on charts up to 1 week. A locked ladder runs on charts up to its State 1 timeframe.
[*]When the chart timeframe doesn't divide every ladder timeframe evenly (45m, for example), some ranges are approximate and the badge shows ≈.
[*]The first bars on a chart can read low until each ladder timeframe has a completed prior bar.
[*]ACT reads three related symbols. If their data is delayed on your plan while the chart is real-time, the index reads lag the chart.
[/list]

[b]OPEN SOURCE[/b]

The complete source is published under the Mozilla Public License 2.0. The repository link is in the signature below.

[i]Trading involves risk. This is a charting tool, not financial advice. Past performance does not guarantee future results.[/i]

## Source Code

````pine
//@version=6
// ACT: Alignment-Colored Trend - v1.0.0
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// ACT colors candles by trend direction, shaded by how far up a ladder of
// timeframes, and across how many related indexes, a TheStrat breakout is
// confirmed. Display only: no orders, no strategy.
//
// HOW A CANDLE IS COLORED
//   Direction  Price above both Direction opens = bull, below both = bear.
//              When the two disagree, a directional State 2 bar (2u/3u or
//              2d/3d) sets the direction instead: counter-trend, blue/purple.
//   Grey       No direction, or the Direction timeframes are conflicting,
//              both inside, or failing.
//   Shade      0 to 11 points, faint to solid:
//              Cascade  an index holding a break of its prior Direction 1 bar
//                       in the trend direction = 7, else State 2 = 3, else
//                       State 1 = 1
//              State 2  +2 breaking with the trend, +1 outside bar with it,
//                       -1 against or failing
//              State 1  +1 breaking with the trend, -1 against
//              +1 for a counter-trend direction with a cascade at State 2
//              or higher
//   Grade      Shade plus index sync on the chart bar (all three indexes
//              break their prior bar the same way = 4, two = 2). A+ = 10+.
//              A readout only: grades never change the paint.
//
// LADDERS
//   Ladder     Trigger  State    Direction   Auto on charts
//   Scalp      15m      30m 1H   4H D        under 1 minute
//   Day Trade  30m      1H 4H    D W         1 minute to 1H
//   Swing      4H       D W      M Q         above 1H to 1D
//   Position   D        W M      Q Y         above 1D to 1W
// Every ladder is the same five steps of the Strat timeframe list
// (1m 5m 15m 30m 1H 4H D W M Q Y), slid up or down. A ladder runs on charts
// up to its State 1 timeframe. When the chart is above the Trigger, the
// Trigger is the chart bar; the State and Direction reading is unchanged.
//
// Colors belong to the ladder, not the chart: inside one ladder, a different
// chart timeframe samples the same reading more or less often. The badge names
// the ladder in use; lock one to keep it across charts.
//
// NO REPAINT: closed bars never change. Higher timeframes come from completed
// bars ([1] with lookahead_on) and period opens, and every forming
// higher-timeframe range is rebuilt from chart bars.

indicator("ACT: Alignment-Colored Trend", "ACT", overlay=true, max_bars_back=5000, max_labels_count=500)


// =============================================================================
// INPUTS
// =============================================================================

enum LadderSel
    Auto     = "Auto"
    Scalp    = "Scalp: 15m 30m 1H 4H D"
    DayTrade = "Day Trade: 30m 1H 4H D W"
    Swing    = "Swing: 4H D W M Q"
    Position = "Position: D W M Q Y"

grpLAD = "Timeframes"
i_ladder = input.enum(LadderSel.Auto, "Ladder", group=grpLAD,
     tooltip="Trigger, State 1, State 2, Direction 1, Direction 2. Auto picks the ladder from the chart timeframe: under 1m Scalp, 1m to 1H Day Trade, above 1H to 1D Swing, above 1D to 1W Position. Pick one to lock it: the colors then stay the same reading on every chart up to its State 1 timeframe, and ACT stands down above that.")
i_show_badge = input.bool(true, "Show Ladder Badge", group=grpLAD,
     tooltip="One line naming the ladder behind the colors and its State and Direction timeframes, each green while price is above its open and red while below. Orange when the selected ladder can't run on this chart.")
i_badge_pos = input.string("Bottom Right", "Badge Position",
     options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"],
     group=grpLAD)

grpX = "Indexes"
i_cross_set = input.string("Auto", "Index Set",
     options=["Auto", "Futures (ES/NQ/YM/RTY)", "ETFs (SPY/QQQ/IWM/DIA)", "Crypto (BTC/ETH/SOL/XRP)", "Custom"],
     group=grpX,
     tooltip="The three related markets checked for alignment. Auto picks the family from the chart symbol and leaves the chart's own ticker out.")
i_custom_cross1 = input.symbol("NQ1!", "Custom Index 1", group=grpX)
i_custom_cross2 = input.symbol("RTY1!", "Custom Index 2", group=grpX)
i_custom_cross3 = input.symbol("YM1!", "Custom Index 3", group=grpX)

grpC = "Candles"
i_color_bars    = input.bool(true, "Color Bars", group=grpC)
i_gray_inactive = input.bool(true, "Grey When No Trend", group=grpC,
     tooltip="ON paints bars with no trend neutral grey. OFF leaves them in the chart's own candle colors.")
i_peak_score    = input.int(10, "Peak Colors At", minval=8, maxval=11, group=grpC,
     tooltip="Shade (0 to 11) at which bull and bear candles switch to the peak colors. 10 = a Direction 1 cascade with State 2 and State 1 both breaking with the trend. Counter-trend candles keep their own colors at any strength.")
i_clr_bull     = input.color(#4CAF50, "Bull", group=grpC)
i_clr_bear     = input.color(#F44336, "Bear", group=grpC)
i_clr_bull_tip = input.color(#00FF41, "Bull Peak", group=grpC)
i_clr_bear_tip = input.color(#FF1493, "Bear Peak", group=grpC)
i_clr_ct_bull  = input.color(#2196F3, "Counter-Trend Bull", group=grpC)
i_clr_ct_bear  = input.color(#9C27B0, "Counter-Trend Bear", group=grpC)
i_clr_inactive = input.color(#4B5563, "No Trend", group=grpC)

grpP = "Panels"
i_show_sim  = input.bool(false, "Show Alignment Dots", group=grpP,
     tooltip="Four dots at the bottom, one per ladder timeframe reading upward: Trigger, State 1, State 2, Direction 1. Bright = the chart and all three indexes hold beyond that timeframe's prior high (bull) or low (bear); dim = three of the four; grey = fewer.")
i_show_dash = input.bool(false, "Show Dashboard", group=grpP)
i_table_pos = input.string("Top Right", "Dashboard Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpP)
i_text_size = input.string("Small", "Text Size",
     options=["Tiny", "Small", "Normal"], group=grpP)

grpAL = "Alerts"
i_alert_detail = input.bool(false, "Detailed Alert Message", group=grpAL,
     tooltip="The 'ACT: Trend On' and 'ACT: Trend Off' alert conditions work without this. ON adds one alert() carrying direction, source, grade and stance, so a single 'Any alert() function call' alert covers both.")

color clr_warn = #FF9800
color clr_neut = #787B86
color clr_text = #D1D4DC


// =============================================================================
// INDEX SETS
// =============================================================================

string _chart_ticker = str.upper(syminfo.ticker)
string _auto_set = syminfo.type == "crypto" ? "Crypto" : syminfo.type == "futures" ? "Futures" : "ETFs"
string _x_set_eff = i_cross_set == "Auto" ? _auto_set :
     i_cross_set == "Futures (ES/NQ/YM/RTY)" ? "Futures" :
     i_cross_set == "ETFs (SPY/QQQ/IWM/DIA)" ? "ETFs" :
     i_cross_set == "Crypto (BTC/ETH/SOL/XRP)" ? "Crypto" : "Custom"

bool _is_nq  = str.startswith(_chart_ticker, "NQ") or str.startswith(_chart_ticker, "MNQ")
bool _is_rty = str.startswith(_chart_ticker, "RTY") or str.startswith(_chart_ticker, "M2K")
bool _is_ym  = str.startswith(_chart_ticker, "YM") or str.startswith(_chart_ticker, "MYM")
string _fut1 = _is_nq or _is_rty or _is_ym ? "ES1!" : "NQ1!"
string _fut2 = _is_rty or _is_ym ? "NQ1!" : "RTY1!"
string _fut3 = _is_ym ? "RTY1!" : "YM1!"
string _fut1_lbl = _is_nq or _is_rty or _is_ym ? "ES" : "NQ"
string _fut2_lbl = _is_rty or _is_ym ? "NQ" : "RTY"
string _fut3_lbl = _is_ym ? "RTY" : "YM"

bool _is_qqq = str.startswith(_chart_ticker, "QQQ")
bool _is_iwm = str.startswith(_chart_ticker, "IWM")
bool _is_dia = str.startswith(_chart_ticker, "DIA")
string _etf1 = _is_qqq or _is_iwm or _is_dia ? "AMEX:SPY" : "NASDAQ:QQQ"
string _etf2 = _is_iwm or _is_dia ? "NASDAQ:QQQ" : "AMEX:IWM"
string _etf3 = _is_dia ? "AMEX:IWM" : "AMEX:DIA"
string _etf1_lbl = _is_qqq or _is_iwm or _is_dia ? "SPY" : "QQQ"
string _etf2_lbl = _is_iwm or _is_dia ? "QQQ" : "IWM"
string _etf3_lbl = _is_dia ? "IWM" : "DIA"

bool _is_eth = str.startswith(_chart_ticker, "ETH")
bool _is_sol = str.startswith(_chart_ticker, "SOL")
bool _is_xrp = str.startswith(_chart_ticker, "XRP")
string _cr1 = _is_eth or _is_sol or _is_xrp ? "COINBASE:BTCUSD" : "COINBASE:ETHUSD"
string _cr2 = _is_sol or _is_xrp ? "COINBASE:ETHUSD" : "COINBASE:SOLUSD"
string _cr3 = _is_xrp ? "COINBASE:SOLUSD" : "COINBASE:XRPUSD"
string _cr1_lbl = _is_eth or _is_sol or _is_xrp ? "BTC" : "ETH"
string _cr2_lbl = _is_sol or _is_xrp ? "ETH" : "SOL"
string _cr3_lbl = _is_xrp ? "SOL" : "XRP"

string ix1_sym = _x_set_eff == "Custom" ? i_custom_cross1 : _x_set_eff == "Futures" ? _fut1 : _x_set_eff == "ETFs" ? _etf1 : _cr1
string ix2_sym = _x_set_eff == "Custom" ? i_custom_cross2 : _x_set_eff == "Futures" ? _fut2 : _x_set_eff == "ETFs" ? _etf2 : _cr2
string ix3_sym = _x_set_eff == "Custom" ? i_custom_cross3 : _x_set_eff == "Futures" ? _fut3 : _x_set_eff == "ETFs" ? _etf3 : _cr3
string ix1_lbl = _x_set_eff == "Custom" ? "I1" : _x_set_eff == "Futures" ? _fut1_lbl : _x_set_eff == "ETFs" ? _etf1_lbl : _cr1_lbl
string ix2_lbl = _x_set_eff == "Custom" ? "I2" : _x_set_eff == "Futures" ? _fut2_lbl : _x_set_eff == "ETFs" ? _etf2_lbl : _cr2_lbl
string ix3_lbl = _x_set_eff == "Custom" ? "I3" : _x_set_eff == "Futures" ? _fut3_lbl : _x_set_eff == "ETFs" ? _etf3_lbl : _cr3_lbl


// =============================================================================
// HELPERS
// =============================================================================

f_table_pos(pos) =>
    switch pos
        "Top Right" => position.top_right
        "Top Center" => position.top_center
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_text_size(sz) =>
    switch sz
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        => size.small

f_clamp_int(int x, int lo, int hi) =>
    math.max(lo, math.min(hi, x))

// Candle transparency follows the shade. Index sync is the only part that moves
// at chart-bar speed, so it stays out of the shade and the paint doesn't strobe.
// Transparency above ~70 is unreadable on a dark chart, so the ramp stays
// inside the visible band: the weakest direction is still clearly a color.
f_trend_alpha(int score) =>
    float t = f_clamp_int(score, 0, 11) / 11.0
    f_clamp_int(math.round(65 - 55 * t), 5, 90)

// Timeframe names: 30m, 1H, 4H, D, W, M, Q, Y.
f_tf_lbl(string tf) =>
    int s = timeframe.in_seconds(tf)
    tf == "3M" ? "Q" : tf == "12M" ? "Y" :
         s < 60 ? str.tostring(s) + "s" :
         s < 86400 ? (s % 3600 == 0 ? str.tostring(s / 3600) + "H" : str.tostring(s / 60) + "m") :
         s == 86400 ? "D" : s == 604800 ? "W" : tf


// =============================================================================
// LADDER
// =============================================================================
// Trigger, State 1, State 2, Direction 1, Direction 2. Day Trade is the
// reference; Scalp sits one step down the Strat timeframe list, Swing two up,
// Position three up.

int e_sec = timeframe.in_seconds(timeframe.period)
int lad_auto = e_sec < 60 ? 0 : e_sec <= 3600 ? 1 : e_sec <= 86400 ? 2 : 3
bool lad_locked = i_ladder != LadderSel.Auto
int lad = switch i_ladder
    LadderSel.Scalp    => 0
    LadderSel.DayTrade => 1
    LadderSel.Swing    => 2
    LadderSel.Position => 3
    => lad_auto

string lad_name = switch lad
    0 => "Scalp"
    1 => "Day Trade"
    2 => "Swing"
    => "Position"

string tf_t = switch lad
    0 => "15"
    1 => "30"
    2 => "240"
    => "D"
string tf_s1 = switch lad
    0 => "30"
    1 => "60"
    2 => "D"
    => "W"
string tf_s2 = switch lad
    0 => "60"
    1 => "240"
    2 => "W"
    => "M"
string tf_d1 = switch lad
    0 => "240"
    1 => "D"
    2 => "M"
    => "3M"
string tf_d2 = switch lad
    0 => "D"
    1 => "W"
    2 => "3M"
    => "12M"

// A ladder runs on charts up to its State 1 timeframe. When the chart is above
// the Trigger, the Trigger moves onto the chart bar: the active-stance gate
// changes, the State and Direction reading behind the colors doesn't.
bool ladder_ok = e_sec <= timeframe.in_seconds(tf_s1)
bool trigger_is_chart = e_sec >= timeframe.in_seconds(tf_t)

// A timeframe below the chart can't be built from chart bars; park it on the
// chart timeframe so nothing requests lower-timeframe data. For the Trigger
// that is the intended behavior; for anything else ladder_ok is false.
f_eff(string tf) => timeframe.in_seconds(tf) >= e_sec ? tf : timeframe.period

string tf_t_e  = f_eff(tf_t)
string tf_s1_e = f_eff(tf_s1)
string tf_s2_e = f_eff(tf_s2)
string tf_d1_e = f_eff(tf_d1)
string tf_d2_e = f_eff(tf_d2)

string lbl_t_lad = f_tf_lbl(tf_t)
// The Trigger as it runs on this chart (Day Trade on a 1H chart: 1H).
string lbl_t  = f_tf_lbl(tf_t_e)
string lbl_s1 = f_tf_lbl(tf_s1)
string lbl_s2 = f_tf_lbl(tf_s2)
string lbl_d1 = f_tf_lbl(tf_d1)
string lbl_d2 = f_tf_lbl(tf_d2)
string lbl_dir = lbl_d1 + "/" + lbl_d2

// Exact when the chart timeframe divides every intraday ladder timeframe and
// calendar timeframes are built from bars no larger than a day. Otherwise the
// badge shows a ≈.
f_aligned(string tf) =>
    int s = timeframe.in_seconds(tf)
    s >= 86400 ? (e_sec <= 86400 or s == e_sec) : s % e_sec == 0
bool ladder_exact = f_aligned(tf_t_e) and f_aligned(tf_s1_e) and f_aligned(tf_s2_e) and f_aligned(tf_d1_e) and f_aligned(tf_d2_e)


// =============================================================================
// BAR CLASSIFICATION
// =============================================================================
// TheStrat bar types against the prior bar: 1 inside, 2u/2d one side taken,
// 3u/3d both sides taken; an F prefix marks a break that closed back inside
// the prior range.

f_classify_full(float c1_h, float c1_l, float c1_o, float c1_c,
           float cc_h, float cc_l, float cc_o, float cc_c) =>
    string btype = "n/a"
    bool b_inside = false
    bool if_bull = false
    bool if_bear = false
    bool fail_bull = false
    bool fail_bear = false
    if na(c1_h) or na(cc_h)
        [btype, b_inside, if_bull, if_bear, fail_bull, fail_bear]
    else
        brk_h = cc_h > c1_h
        brk_l = cc_l < c1_l
        above_open = cc_c > cc_o
        if brk_h and brk_l
            closed_inside = cc_c <= c1_h and cc_c >= c1_l
            if closed_inside
                if above_open
                    btype := "F3u"
                    fail_bull := true
                else
                    btype := "F3d"
                    fail_bear := true
            else
                if cc_c > c1_h
                    btype := "3u"
                    if_bull := true
                else
                    btype := "3d"
                    if_bear := true
        else if brk_h and not brk_l
            inside_c1 = cc_c <= c1_h and cc_c >= c1_l
            if inside_c1
                btype := "F2u"
                fail_bull := true
            else
                btype := "2u"
                if_bull := true
        else if brk_l and not brk_h
            inside_c1 = cc_c <= c1_h and cc_c >= c1_l
            if inside_c1
                btype := "F2d"
                fail_bear := true
            else
                btype := "2d"
                if_bear := true
        else
            b_inside := true
            btype := above_open ? "1u" : "1d"
        [btype, b_inside, if_bull, if_bear, fail_bull, fail_bear]

f_classify(float c1_h, float c1_l, float cc_h, float cc_l, float cc_o, float cc_c) =>
    [bt, _ins, ifb, ifs, _fb, _fs] = f_classify_full(c1_h, c1_l, 0.0, 0.0, cc_h, cc_l, cc_o, cc_c)
    [bt, ifb, ifs, cc_c >= cc_o]


// =============================================================================
// 4H BOUNDARIES
// =============================================================================

int et_h = hour(time, "America/New_York")

// 4H windows anchor to the CME session for futures (18, 22, 2, 6, 10, 14 ET)
// and to ET midnight for crypto. Bucketing by the hour a bar opens in, rather
// than waiting for a bar stamped exactly on an anchor, keeps the windows
// rolling on charts whose bars open off the hour (RTH sessions, 20m). The gap
// test catches a skipped window whose bucket number happens to repeat.
// Anchors follow the chart's own market, not the index set: a Custom or
// swapped set on an ES chart still uses the CME session.
int bkt_4h = _auto_set == "Futures" ? math.floor(((et_h + 6) % 24) / 4) : math.floor(et_h / 4)
bool use_4h_anchor = (_auto_set == "Futures" or _auto_set == "Crypto") and e_sec < 14400
bool new_4h_anchor = bkt_4h != bkt_4h[1] or time - time[1] >= 14400000

f_is_new(string tf) =>
    bool chg = ta.change(time(tf)) != 0
    tf == "240" and use_4h_anchor ? new_4h_anchor : chg


// =============================================================================
// HIGHER-TIMEFRAME WINDOWS
// =============================================================================

// Local window accumulator. Intraday timeframes use it whole; calendar
// timeframes use only its forming high and low (see f_rung).
f_htf_bar(bool new_bar, float src_o, float src_h, float src_l, float src_c) =>
    var bool  started = false
    var float htf_o = na, var float htf_h = na
    var float htf_l = na, var float htf_c = na
    var float htf_po = na, var float htf_ph = na
    var float htf_pl = na, var float htf_pc = na
    var float htf_p2h = na, var float htf_p2l = na
    var int   htf_t = na
    if new_bar or not started
        started := true
        htf_p2h := htf_ph, htf_p2l := htf_pl
        htf_po := htf_o, htf_ph := htf_h, htf_pl := htf_l, htf_pc := htf_c
        htf_t := time, htf_o := src_o, htf_h := src_h, htf_l := src_l
    else
        htf_h := na(src_h) ? htf_h : na(htf_h) ? src_h : math.max(htf_h, src_h)
        htf_l := na(src_l) ? htf_l : na(htf_l) ? src_l : math.min(htf_l, src_l)
    htf_c := src_c
    [htf_o, htf_h, htf_l, htf_c, htf_ph, htf_pl, htf_po, htf_pc, htf_p2h, htf_p2l, htf_t]

// Calendar timeframes (D and up) are served: the period open and the completed
// bars come from request.security ([1]/[2] with lookahead_on, so they are
// settled values). That makes them right from the first chart bar instead of
// after a full local warm-up; a Y timeframe on a 1H chart would otherwise need
// two years of loaded bars. The forming high and low still come from chart
// bars, because the served forming bar carries the period's final extremes on
// history. Served bars must cover the same hours the chart draws, or the served
// values and the forming range describe different sessions (and an
// extended-hours chart could read a 9:30 open in premarket). So serve only on
// the regular session, and for indexes only within the chart's own family;
// everything else is accumulated locally.
bool serve_chart = syminfo.session == session.regular
bool serve_index = serve_chart and _x_set_eff == _auto_set
f_served(string tf, bool allowed) => allowed and timeframe.in_seconds(tf) >= 86400

f_rung(string tf) =>
    bool is_new = f_is_new(tf)
    bool served = f_served(tf, serve_chart)
    [lo, lh, ll, lc, lph, lpl, lpo, lpc, lp2h, lp2l, lt] = f_htf_bar(is_new, open, high, low, close)
    float so = na
    float sph = na
    float spl = na
    float spo = na
    float spc = na
    float sp2h = na
    float sp2l = na
    if served
        [r_o, r_ph, r_pl, r_po, r_pc, r_p2h, r_p2l] = request.security(syminfo.tickerid, tf,
             [open, high[1], low[1], open[1], close[1], high[2], low[2]],
             barmerge.gaps_off, barmerge.lookahead_on)
        so := r_o
        sph := r_ph
        spl := r_pl
        spo := r_po
        spc := r_pc
        sp2h := r_p2h
        sp2l := r_p2l
    [served ? so : lo, lh, ll, lc,
         served ? sph : lph, served ? spl : lpl, served ? spo : lpo, served ? spc : lpc,
         served ? sp2h : lp2h, served ? sp2l : lp2l, lt, is_new]

[t_o, t_h, t_l, _, t_ph, t_pl, t_po, t_pc, t_p2h, t_p2l, t_t, t_new] = f_rung(tf_t_e)

[s1_o, s1_h, s1_l, s1_c, s1_ph, s1_pl, s1_po, s1_pc, _, _, _, s1_new] = f_rung(tf_s1_e)
[s1_type, _, s1_if_b, s1_if_s, s1_fb, s1_fs] = f_classify_full(s1_ph, s1_pl, s1_po, s1_pc, s1_h, s1_l, s1_o, s1_c)

[s2_o, s2_h, s2_l, s2_c, s2_ph, s2_pl, s2_po, s2_pc, _, _, _, s2_new] = f_rung(tf_s2_e)
[s2_type, _, s2_if_b, s2_if_s, s2_fb, s2_fs] = f_classify_full(s2_ph, s2_pl, s2_po, s2_pc, s2_h, s2_l, s2_o, s2_c)

[d1_o, d1_h, d1_l, d1_c, d1_ph, d1_pl, d1_po, d1_pc, _, _, _, d1_new] = f_rung(tf_d1_e)
[d1_type, d1_inside, d1_if_b, d1_if_s, d1_fb, d1_fs] = f_classify_full(d1_ph, d1_pl, d1_po, d1_pc, d1_h, d1_l, d1_o, d1_c)

[d2_o, d2_h, d2_l, d2_c, d2_ph, d2_pl, d2_po, d2_pc, _, _, _, _] = f_rung(tf_d2_e)
[d2_type, d2_inside, d2_if_b, d2_if_s, d2_fb, d2_fs] = f_classify_full(d2_ph, d2_pl, d2_po, d2_pc, d2_h, d2_l, d2_o, d2_c)


// =============================================================================
// INDEX ALIGNMENT
// =============================================================================
// One stream per index at the chart timeframe, read as-is on every bar: at a
// bar's close the live read and the reloaded read are the same index bar, so
// history shows what realtime showed. Index windows share the chart's
// boundaries, with calendar priors served.

f_index(string sym) =>
    request.security(sym, timeframe.period, [open, high, low, close, high[1], low[1]],
         barmerge.gaps_off, barmerge.lookahead_on)

[ix1_o, ix1_h, ix1_l, ix1_c, ix1_p1h, ix1_p1l] = f_index(ix1_sym)
[ix2_o, ix2_h, ix2_l, ix2_c, ix2_p1h, ix2_p1l] = f_index(ix2_sym)
[ix3_o, ix3_h, ix3_l, ix3_c, ix3_p1h, ix3_p1l] = f_index(ix3_sym)

[ix1_bt, ix1_if_b, ix1_if_s, _] = f_classify(ix1_p1h, ix1_p1l, ix1_h, ix1_l, ix1_o, ix1_c)
[ix2_bt, ix2_if_b, ix2_if_s, _] = f_classify(ix2_p1h, ix2_p1l, ix2_h, ix2_l, ix2_o, ix2_c)
[ix3_bt, ix3_if_b, ix3_if_s, _] = f_classify(ix3_p1h, ix3_p1l, ix3_h, ix3_l, ix3_o, ix3_c)

int sync_bull = (ix1_if_b ? 1 : 0) + (ix2_if_b ? 1 : 0) + (ix3_if_b ? 1 : 0)
int sync_bear = (ix1_if_s ? 1 : 0) + (ix2_if_s ? 1 : 0) + (ix3_if_s ? 1 : 0)

f_xrung(string sym, string tf, bool is_new, float xo, float xh, float xl, float xc) =>
    [_, lh, ll, _, lph, lpl, _, _, _, _, _] = f_htf_bar(is_new, xo, xh, xl, xc)
    bool served = f_served(tf, serve_index)
    float sph = na
    float spl = na
    if served
        [r_ph, r_pl] = request.security(sym, tf, [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_on)
        sph := r_ph
        spl := r_pl
    [lh, ll, served ? sph : lph, served ? spl : lpl]

[ix1_t_h, ix1_t_l, ix1_t_ph, ix1_t_pl] = f_xrung(ix1_sym, tf_t_e, t_new, ix1_o, ix1_h, ix1_l, ix1_c)
[ix2_t_h, ix2_t_l, ix2_t_ph, ix2_t_pl] = f_xrung(ix2_sym, tf_t_e, t_new, ix2_o, ix2_h, ix2_l, ix2_c)
[ix3_t_h, ix3_t_l, ix3_t_ph, ix3_t_pl] = f_xrung(ix3_sym, tf_t_e, t_new, ix3_o, ix3_h, ix3_l, ix3_c)
[ix1_s1_h, ix1_s1_l, ix1_s1_ph, ix1_s1_pl] = f_xrung(ix1_sym, tf_s1_e, s1_new, ix1_o, ix1_h, ix1_l, ix1_c)
[ix2_s1_h, ix2_s1_l, ix2_s1_ph, ix2_s1_pl] = f_xrung(ix2_sym, tf_s1_e, s1_new, ix2_o, ix2_h, ix2_l, ix2_c)
[ix3_s1_h, ix3_s1_l, ix3_s1_ph, ix3_s1_pl] = f_xrung(ix3_sym, tf_s1_e, s1_new, ix3_o, ix3_h, ix3_l, ix3_c)
[ix1_s2_h, ix1_s2_l, ix1_s2_ph, ix1_s2_pl] = f_xrung(ix1_sym, tf_s2_e, s2_new, ix1_o, ix1_h, ix1_l, ix1_c)
[ix2_s2_h, ix2_s2_l, ix2_s2_ph, ix2_s2_pl] = f_xrung(ix2_sym, tf_s2_e, s2_new, ix2_o, ix2_h, ix2_l, ix2_c)
[ix3_s2_h, ix3_s2_l, ix3_s2_ph, ix3_s2_pl] = f_xrung(ix3_sym, tf_s2_e, s2_new, ix3_o, ix3_h, ix3_l, ix3_c)
[ix1_d1_h, ix1_d1_l, ix1_d1_ph, ix1_d1_pl] = f_xrung(ix1_sym, tf_d1_e, d1_new, ix1_o, ix1_h, ix1_l, ix1_c)
[ix2_d1_h, ix2_d1_l, ix2_d1_ph, ix2_d1_pl] = f_xrung(ix2_sym, tf_d1_e, d1_new, ix2_o, ix2_h, ix2_l, ix2_c)
[ix3_d1_h, ix3_d1_l, ix3_d1_ph, ix3_d1_pl] = f_xrung(ix3_sym, tf_d1_e, d1_new, ix3_o, ix3_h, ix3_l, ix3_c)

// An index holding a break of its window's prior extreme in the given
// direction. A failed break against the direction counts too.
f_tf_break(float wh, float wl, float wc, float ph, float pl, int dir) =>
    if na(ph) or na(pl) or na(wh) or na(wl) or na(wc)
        false
    else
        bool brk_h = wh > ph
        bool brk_l = wl < pl
        bool is_2u = brk_h and not brk_l
        bool is_2d = brk_l and not brk_h
        bool f2u = is_2u and wc <= ph and wc >= pl
        bool f2d = is_2d and wc >= pl and wc <= ph
        dir == 1 ? ((is_2u and not f2u) or f2d) : ((is_2d and not f2d) or f2u)

// Strictly beyond the prior extreme right now (alignment dots).
f_tf_hold(float wc, float ph, float pl, int dir) =>
    dir == 1 ? (not na(ph) and wc > ph) : (not na(pl) and wc < pl)

f_hold_cnt(int dir, bool chart_hold, bool x1, bool x2, bool x3) =>
    dir == 0 ? 0 : (chart_hold ? 1 : 0) + (x1 ? 1 : 0) + (x2 ? 1 : 0) + (x3 ? 1 : 0)


// =============================================================================
// DIRECTION, SHADE AND GRADE
// =============================================================================

bool d1_up = close > d1_o
bool d1_dn = close < d1_o
bool d2_up = close > d2_o
bool d2_dn = close < d2_o
bool dir_agree_bull = d1_up and d2_up
bool dir_agree_bear = d1_dn and d2_dn
bool dir_agree = dir_agree_bull or dir_agree_bear
bool dir_conflict = (d1_up and d2_dn) or (d1_dn and d2_up)

bool s2_struct_long  = s2_type == "2u" or s2_type == "3u"
bool s2_struct_short = s2_type == "2d" or s2_type == "3d"

// A ladder that can't run on this chart never takes a direction, so nothing
// downstream arms, paints or alerts.
int trend_dir = 0
string trend_src = "none"
bool is_ct = false
if ladder_ok
    if dir_agree
        trend_dir := dir_agree_bull ? 1 : -1
        trend_src := lbl_dir
    else if s2_struct_long or s2_struct_short
        trend_dir := s2_struct_long ? 1 : -1
        bool s2_with_d1 = (s2_struct_long and d1_up) or (s2_struct_short and d1_dn)
        bool s2_with_d2 = (s2_struct_long and d2_up) or (s2_struct_short and d2_dn)
        trend_src := lbl_s2 + ((s2_with_d1 or s2_with_d2) ? " trend" : " reversal")
        is_ct := true

f_state(string bt, int dir) =>
    string state = "neutral"
    if dir == 1
        state := bt == "2u" or bt == "F2d" ? "active" : bt == "3u" ? "continuation" : bt == "1u" or bt == "1d" ? "neutral" : bt == "F2u" ? "failed" : "against"
    else
        state := bt == "2d" or bt == "F2u" ? "active" : bt == "3d" ? "continuation" : bt == "1u" or bt == "1d" ? "neutral" : bt == "F2d" ? "failed" : "against"
    state

// Cascade: the highest ladder timeframe at which any index holds a break in the
// trend direction. Direction 1 = 7, State 2 = 3, State 1 = 1.
int cascade_pts = 0
string cascade_lbl = "none"
if trend_dir != 0
    bool any_d1 = f_tf_break(ix1_d1_h, ix1_d1_l, ix1_c, ix1_d1_ph, ix1_d1_pl, trend_dir) or
         f_tf_break(ix2_d1_h, ix2_d1_l, ix2_c, ix2_d1_ph, ix2_d1_pl, trend_dir) or
         f_tf_break(ix3_d1_h, ix3_d1_l, ix3_c, ix3_d1_ph, ix3_d1_pl, trend_dir)
    if any_d1
        cascade_pts := 7
        cascade_lbl := lbl_d1
    else
        bool any_s2 = f_tf_break(ix1_s2_h, ix1_s2_l, ix1_c, ix1_s2_ph, ix1_s2_pl, trend_dir) or
             f_tf_break(ix2_s2_h, ix2_s2_l, ix2_c, ix2_s2_ph, ix2_s2_pl, trend_dir) or
             f_tf_break(ix3_s2_h, ix3_s2_l, ix3_c, ix3_s2_ph, ix3_s2_pl, trend_dir)
        if any_s2
            cascade_pts := 3
            cascade_lbl := lbl_s2
        else
            bool any_s1 = f_tf_break(ix1_s1_h, ix1_s1_l, ix1_c, ix1_s1_ph, ix1_s1_pl, trend_dir) or
                 f_tf_break(ix2_s1_h, ix2_s1_l, ix2_c, ix2_s1_ph, ix2_s1_pl, trend_dir) or
                 f_tf_break(ix3_s1_h, ix3_s1_l, ix3_c, ix3_s1_ph, ix3_s1_pl, trend_dir)
            if any_s1
                cascade_pts := 1
                cascade_lbl := lbl_s1

// Index sync on the chart bar: all three indexes break the prior bar the same
// way = 4, two = 2.
int sync_count = trend_dir == 1 ? sync_bull : trend_dir == -1 ? sync_bear : 0
int sync_pts = sync_count >= 3 ? 4 : sync_count >= 2 ? 2 : 0

string s2_state = f_state(s2_type, trend_dir)
int s2_pts = s2_state == "active" ? 2 : s2_state == "continuation" ? 1 : s2_state == "neutral" ? 0 : -1
string s1_state = f_state(s1_type, trend_dir)
int s1_pts = s1_state == "active" ? 1 : s1_state == "against" ? -1 : 0
int ct_bonus = (is_ct and cascade_pts >= 3) ? 1 : 0

int shade = cascade_pts + s2_pts + s1_pts + ct_bonus
int score = shade + sync_pts
string grade = score >= 10 ? "A+" : score >= 7 ? "A" : score >= 5 ? "B" : score >= 3 ? "C" : score >= 1 ? "D" : "F"


// =============================================================================
// STANCE
// =============================================================================
// Whether the direction is tradeable right now: 0 stand aside (grey),
// 1 watch, 2 active (a ladder-timeframe break with a Trigger break behind it).

bool s1_live_bull = not na(s1_ph) and high >= s1_ph
bool s1_live_bear = not na(s1_pl) and low  <= s1_pl
bool s2_live_bull = not na(s2_ph) and high >= s2_ph
bool s2_live_bear = not na(s2_pl) and low  <= s2_pl
bool d1_live_bull = not na(d1_ph) and high >= d1_ph
bool d1_live_bear = not na(d1_pl) and low  <= d1_pl
bool d2_live_bull = not na(d2_ph) and high >= d2_ph
bool d2_live_bear = not na(d2_pl) and low  <= d2_pl

bool bias_bull = dir_agree_bull
bool bias_bear = dir_agree_bear

int stance = 1
string stance_why = ""

if not ladder_ok
    stance := 0
    stance_why := "ladder off on this chart"
else if dir_conflict
    bool s2_ct_bull = s2_live_bull and not s2_live_bear and close >= s2_ph
    bool s2_ct_bear = s2_live_bear and not s2_live_bull and close <= s2_pl
    if s2_ct_bull or s2_ct_bear
        stance := 1
        stance_why := lbl_s2 + " counter-trend break"
    else
        stance := 0
        stance_why := lbl_dir + " conflict"
else if d1_inside and not d1_live_bull and not d1_live_bear
    if d2_inside
        stance := 0
        stance_why := lbl_d1 + " and " + lbl_d2 + " inside"
    else if bias_bull or bias_bear
        stance := 1
        stance_why := lbl_d1 + " inside, " + lbl_d2 + " directional"
    else
        stance := 0
        stance_why := "no direction"
else if (bias_bull and ((d1_fb and d2_if_b) or (d1_if_b and d2_fb))) or (bias_bear and ((d1_fs and d2_if_s) or (d1_if_s and d2_fs)))
    stance := 0
    stance_why := lbl_dir + " break failing"
else if bias_bull or bias_bear
    bool cat_d2 = bias_bull ? d2_live_bull : d2_live_bear
    bool cat_d1 = bias_bull ? d1_live_bull : d1_live_bear
    bool cat_s2 = bias_bull ? s2_live_bull : s2_live_bear
    bool cat_s1 = bias_bull ? s1_live_bull : s1_live_bear
    bool d2_failing = bias_bull ? d2_fb : d2_fs
    bool d1_failing = bias_bull ? d1_fb : d1_fs
    bool s2_failing = bias_bull ? s2_fb : s2_fs
    bool s1_failing = bias_bull ? s1_fb : s1_fs
    if cat_d2 or cat_d1 or cat_s2 or cat_s1
        string cat_lbl = cat_d2 ? lbl_d2 : cat_d1 ? lbl_d1 : cat_s2 ? lbl_s2 : lbl_s1
        bool any_exec = bias_bull ? (not na(t_ph) and t_h > t_ph) : (not na(t_pl) and t_l < t_pl)
        if any_exec
            stance := 2
            bool cat_force = cat_d2 ? not d2_failing : cat_d1 ? not d1_failing : cat_s2 ? not s2_failing : not s1_failing
            stance_why := cat_lbl + (cat_force ? " break in force" : " break failing")
        else
            stance := 1
            stance_why := cat_lbl + " break, waiting on " + lbl_t
    else
        stance := 1
        stance_why := "aligned, no break yet"
else
    stance := 0
    stance_why := "no direction"

bool trend_on = stance >= 1 and trend_dir != 0


// =============================================================================
// TRIGGER
// =============================================================================

[t_prev_type, _, _, _] = f_classify(t_p2h, t_p2l, t_ph, t_pl, t_po, t_pc)

var bool t_active_broke_low  = false
var bool t_active_broke_high = false
if t_new
    t_active_broke_low  := false
    t_active_broke_high := false
if not na(t_pl) and low < t_pl
    t_active_broke_low := true
if not na(t_ph) and high > t_ph
    t_active_broke_high := true

// =============================================================================
// TREND ON/OFF ALERTS
// =============================================================================
// Grey = no trend, which is exactly the branch that paints
// the No Trend color below. Defined once and reused there so an alert can never
// disagree with the candle, and independent of the paint toggles so turning the
// paint off doesn't silently stop the alerts.

bool is_grey = not trend_on

// Flips are taken on the confirmed bar only. The direction reads live price
// against the Direction opens and can flicker intrabar, so firing off the live
// value would put alerts in realtime that history never shows. Seeded grey:
// the first bar has no higher-timeframe windows yet.
var bool grey_prev = true
bool trend_off_edge = false
bool trend_on_edge  = false
if barstate.isconfirmed
    trend_off_edge := is_grey and not grey_prev
    trend_on_edge  := not is_grey and grey_prev
    grey_prev      := is_grey

alertcondition(trend_on_edge, "ACT: Trend On",
     "{{ticker}} {{interval}} ACT trend on: candles colored.")
alertcondition(trend_off_edge, "ACT: Trend Off",
     "{{ticker}} {{interval}} ACT trend off: candles grey.")

string stance_name = stance == 0 ? "STAND ASIDE" : stance == 1 ? "WATCH" : "ACTIVE"

if i_alert_detail and (trend_on_edge or trend_off_edge)
    string a_dir = trend_dir == 1 ? "LONG" : trend_dir == -1 ? "SHORT" : "---"
    alert("ACT " + (trend_on_edge ? "TREND ON" : "TREND OFF") + " | " + syminfo.ticker +
         " | " + a_dir + " | " + trend_src + " | " + grade + " " + str.tostring(score) +
         " | " + stance_name + ": " + stance_why + " | " + lad_name, alert.freq_once_per_bar_close)


// =============================================================================
// VISUAL OUTPUTS
// =============================================================================

int hold_t = f_hold_cnt(trend_dir, f_tf_hold(close, t_ph, t_pl, trend_dir),
     f_tf_hold(ix1_c, ix1_t_ph, ix1_t_pl, trend_dir),
     f_tf_hold(ix2_c, ix2_t_ph, ix2_t_pl, trend_dir),
     f_tf_hold(ix3_c, ix3_t_ph, ix3_t_pl, trend_dir))
int hold_s1 = f_hold_cnt(trend_dir, f_tf_hold(close, s1_ph, s1_pl, trend_dir),
     f_tf_hold(ix1_c, ix1_s1_ph, ix1_s1_pl, trend_dir),
     f_tf_hold(ix2_c, ix2_s1_ph, ix2_s1_pl, trend_dir),
     f_tf_hold(ix3_c, ix3_s1_ph, ix3_s1_pl, trend_dir))
int hold_s2 = f_hold_cnt(trend_dir, f_tf_hold(close, s2_ph, s2_pl, trend_dir),
     f_tf_hold(ix1_c, ix1_s2_ph, ix1_s2_pl, trend_dir),
     f_tf_hold(ix2_c, ix2_s2_ph, ix2_s2_pl, trend_dir),
     f_tf_hold(ix3_c, ix3_s2_ph, ix3_s2_pl, trend_dir))
int hold_d1 = f_hold_cnt(trend_dir, f_tf_hold(close, d1_ph, d1_pl, trend_dir),
     f_tf_hold(ix1_c, ix1_d1_ph, ix1_d1_pl, trend_dir),
     f_tf_hold(ix2_c, ix2_d1_ph, ix2_d1_pl, trend_dir),
     f_tf_hold(ix3_c, ix3_d1_ph, ix3_d1_pl, trend_dir))

// Dots always render so the rows never shift; grey = not aligned there.
f_dot_clr(int cnt) =>
    color dir_clr = trend_dir == 1 ? i_clr_bull : i_clr_bear
    not trend_on ? color.new(i_clr_inactive, 72) :
         cnt >= 4 ? color.new(dir_clr, 0) :
         cnt == 3 ? color.new(dir_clr, 45) : color.new(i_clr_inactive, 72)

bool show_dots = i_show_sim and ladder_ok
plotshape(show_dots, "Alignment: Trigger",     shape.circle, location.bottom, f_dot_clr(hold_t),  size=size.tiny)
plotshape(show_dots, "Alignment: State 1",     shape.circle, location.bottom, f_dot_clr(hold_s1), size=size.tiny)
plotshape(show_dots, "Alignment: State 2",     shape.circle, location.bottom, f_dot_clr(hold_s2), size=size.tiny)
plotshape(show_dots, "Alignment: Direction 1", shape.circle, location.bottom, f_dot_clr(hold_d1), size=size.tiny)

color bar_clr = na
if i_color_bars and ladder_ok
    bool peak = shade >= i_peak_score and not is_ct
    color bull_base = peak ? i_clr_bull_tip : is_ct ? i_clr_ct_bull : i_clr_bull
    color bear_base = peak ? i_clr_bear_tip : is_ct ? i_clr_ct_bear : i_clr_bear
    if trend_on and trend_dir == 1
        bar_clr := color.new(bull_base, f_trend_alpha(shade))
    else if trend_on and trend_dir == -1
        bar_clr := color.new(bear_base, f_trend_alpha(shade))
    else if i_gray_inactive and is_grey
        bar_clr := color.new(i_clr_inactive, 62)
barcolor(bar_clr)

// Data window only: the per-bar reading, for inspection and value export.
// Trend is the paint direction (1 bull, -1 bear, 0 grey), not the raw bias.
plot(trend_on ? trend_dir : 0, "Trend", display=display.data_window)
plot(shade,  "Shade",  display=display.data_window)
plot(score,  "Score",  display=display.data_window)
plot(stance, "Stance", display=display.data_window)


// =============================================================================
// LADDER BADGE
// =============================================================================
// Names the reading behind the candles: the ladder, plus its State and
// Direction timeframes, which are what the colors are made of. Colors belong
// to the ladder, not the chart, so this line is what changes when a chart
// switch changes the colors. Each timeframe reads green above its open, red
// below, grey at the open. The Trigger only gates an active stance; it is in
// the hover.

f_open_clr(float o) =>
    na(o) ? clr_neut : close > o ? i_clr_bull : close < o ? i_clr_bear : clr_neut

if i_show_badge and barstate.islast
    var table badge = table.new(f_table_pos(i_badge_pos), 6, 1,
         bgcolor=color.new(color.black, 20), frame_color=color.new(color.gray, 60), frame_width=1,
         border_color=color.new(color.black, 100), border_width=0)
    sz = f_text_size(i_text_size)
    if ladder_ok
        string how = lad_locked ? "Locked to " + lad_name + "." : "Auto picked " + lad_name + " for this chart timeframe."
        string trig = trigger_is_chart and lbl_t != lbl_t_lad ?
             " Stance turns active on a break of the prior " + lbl_t + " bar here (the chart is above " + lad_name + "'s " + lbl_t_lad + " Trigger)." :
             " Stance turns active on a break of the prior " + lbl_t + " high or low."
        table.cell(badge, 0, 0, "ACT · " + lad_name, text_color=clr_text, text_size=sz, tooltip=how + trig)
        table.cell(badge, 1, 0, lbl_s1, text_color=f_open_clr(s1_o), text_size=sz,
             tooltip="State 1: +1 breaking with the trend, -1 against.")
        table.cell(badge, 2, 0, lbl_s2, text_color=f_open_clr(s2_o), text_size=sz,
             tooltip="State 2: +2 breaking with the trend, +1 outside bar with it, -1 against. Sets a counter-trend direction when the Direction timeframes disagree (blue/purple candles).")
        table.cell(badge, 3, 0, lbl_d1, text_color=f_open_clr(d1_o), text_size=sz,
             tooltip="Direction: price above both the " + lbl_d1 + " and " + lbl_d2 + " opens = bull, below both = bear.")
        table.cell(badge, 4, 0, lbl_d2, text_color=f_open_clr(d2_o), text_size=sz,
             tooltip="Direction: price above both the " + lbl_d1 + " and " + lbl_d2 + " opens = bull, below both = bear.")
        string mode_txt = (lad_locked ? "locked" : "auto") + (ladder_exact ? "" : " ≈")
        string mode_tip = (lad_locked ? "Locked: this ladder runs unchanged on any chart up to " + lbl_s1 + "." :
             "Auto: the ladder follows the chart timeframe. A chart in another band switches the ladder, and the colors with it. Lock a ladder in settings to keep one reading.") +
             (ladder_exact ? "" : " ≈ This chart timeframe doesn't divide every ladder timeframe evenly, so some ranges are approximate.")
        table.cell(badge, 5, 0, mode_txt, text_color=color.new(clr_text, 40), text_size=sz, tooltip=mode_tip)
    else
        string msg = lad_locked ? "ACT: " + lad_name + " needs a chart at " + lbl_s1 + " or lower" : "ACT runs on charts up to 1W"
        string tip = lad_locked ? lad_name + " reads State from " + lbl_s1 + " bars built from the chart, so the chart can't be larger. Switch the chart to " + lbl_s1 + " or lower, or set Ladder to Auto." :
             "The largest ladder, Position, reads State from W bars. Switch the chart to 1W or lower."
        table.cell(badge, 0, 0, msg, text_color=clr_warn, text_size=sz, tooltip=tip)


// =============================================================================
// DASHBOARD
// =============================================================================

f_dir_clr(int d) => d == 1 ? i_clr_bull : d == -1 ? i_clr_bear : clr_neut

f_tf_row(string bt, bool if_b, bool if_s, float o) =>
    bt + (if_b ? ", in force up" : if_s ? ", in force down" : close > o ? ", above open" : ", below open")

if i_show_dash and barstate.islast
    var table dash = table.new(f_table_pos(i_table_pos), 2, 11,
         bgcolor=color.new(color.black, 20), border_width=1)
    sz = f_text_size(i_text_size)
    color hdr_bg = color.rgb(20, 20, 35)
    color row_bg = color.rgb(30, 30, 45)
    int row = 0

    table.cell(dash, 0, row, "LADDER", text_color=color.white, text_size=sz, bgcolor=hdr_bg)
    table.cell(dash, 1, row, lad_name + (lad_locked ? " (locked)" : " (auto)") + " | " + lbl_t + " " + lbl_s1 + " " + lbl_s2 + " " + lbl_d1 + " " + lbl_d2,
         text_color=ladder_ok ? clr_neut : clr_warn, text_size=sz, bgcolor=row_bg)
    row += 1

    string dir_str = trend_dir == 1 ? "BULL" : trend_dir == -1 ? "BEAR" : "---"
    table.cell(dash, 0, row, "TREND", text_color=color.white, text_size=sz, bgcolor=hdr_bg)
    table.cell(dash, 1, row, dir_str + " | " + trend_src, text_color=f_dir_clr(trend_dir), text_size=sz, bgcolor=row_bg)
    row += 1

    color stance_clr = stance == 0 ? clr_warn : stance == 1 ? clr_neut : f_dir_clr(trend_dir)
    table.cell(dash, 0, row, "STANCE", text_color=color.white, text_size=sz, bgcolor=hdr_bg)
    table.cell(dash, 1, row, stance_name + " | " + stance_why, text_color=stance_clr, text_size=sz, bgcolor=row_bg)
    row += 1

    color score_clr = score >= 10 ? color.white : score >= 7 ? color.silver : clr_neut
    table.cell(dash, 0, row, "GRADE", text_color=color.white, text_size=sz, bgcolor=hdr_bg)
    table.cell(dash, 1, row, grade + " (" + str.tostring(score) + " pts, shade " + str.tostring(shade) + ")", text_color=score_clr, text_size=sz, bgcolor=row_bg)
    row += 1

    string taken = t_active_broke_high and t_active_broke_low ? ", both sides taken" : t_active_broke_high ? ", high taken" : t_active_broke_low ? ", low taken" : ""
    table.cell(dash, 0, row, "TRIGGER " + lbl_t, text_color=color.white, text_size=sz, bgcolor=hdr_bg)
    table.cell(dash, 1, row, "prior bar " + t_prev_type + taken, text_color=clr_neut, text_size=sz, bgcolor=row_bg)
    row += 1

    string ix_str = ix1_lbl + " " + ix1_bt + ", " + ix2_lbl + " " + ix2_bt + ", " + ix3_lbl + " " + ix3_bt + " (" + str.tostring(sync_bull) + " up, " + str.tostring(sync_bear) + " down)"
    table.cell(dash, 0, row, "INDEXES", text_color=color.white, text_size=sz, bgcolor=hdr_bg)
    table.cell(dash, 1, row, ix_str, text_color=sync_bull >= 2 ? i_clr_bull : sync_bear >= 2 ? i_clr_bear : clr_neut, text_size=sz, bgcolor=row_bg)
    row += 1

    table.cell(dash, 0, row, "", bgcolor=color.rgb(50, 50, 65))
    table.cell(dash, 1, row, "", bgcolor=color.rgb(50, 50, 65))
    row += 1
    table.cell(dash, 0, row, lbl_d2, text_color=color.white, text_size=sz, bgcolor=hdr_bg)
    table.cell(dash, 1, row, f_tf_row(d2_type, d2_if_b, d2_if_s, d2_o), text_color=d2_if_b ? i_clr_bull : d2_if_s ? i_clr_bear : clr_neut, text_size=sz, bgcolor=row_bg)
    row += 1
    table.cell(dash, 0, row, lbl_d1, text_color=color.white, text_size=sz, bgcolor=hdr_bg)
    table.cell(dash, 1, row, f_tf_row(d1_type, d1_if_b, d1_if_s, d1_o), text_color=d1_if_b ? i_clr_bull : d1_if_s ? i_clr_bear : clr_neut, text_size=sz, bgcolor=row_bg)
    row += 1
    table.cell(dash, 0, row, lbl_s2, text_color=color.white, text_size=sz, bgcolor=hdr_bg)
    table.cell(dash, 1, row, f_tf_row(s2_type, s2_if_b, s2_if_s, s2_o), text_color=s2_if_b ? i_clr_bull : s2_if_s ? i_clr_bear : clr_neut, text_size=sz, bgcolor=row_bg)
    row += 1
    table.cell(dash, 0, row, lbl_s1, text_color=color.white, text_size=sz, bgcolor=hdr_bg)
    table.cell(dash, 1, row, f_tf_row(s1_type, s1_if_b, s1_if_s, s1_o), text_color=s1_if_b ? i_clr_bull : s1_if_s ? i_clr_bear : clr_neut, text_size=sz, bgcolor=row_bg)
````
