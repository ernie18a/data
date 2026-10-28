# Balance Step

- url: https://www.tradingview.com/script/7IBOvHM2-Balance-Step/
- type: indicator
- pine_id: PUB;bd0aab1cb8e341a7b242662d867e1437
- version: 1.0

## Description

Robert Krausz's Balance Step, as described in his Fibonacci Trader software, for TradingView. It's a simple moving average of the last N Balance Points of a timeframe, drawn as a step line, with the next period's level projected forward.

HOW IT WORKS
• Balance Point (BP) of a period = (high + low + close) / 3.
• Balance Step = simple moving average of the last N Balance Points (default 5) of the selected timeframe.
• Each period shows the value known at the previous period's close, so the line is flat across a period and steps at the next one.

HOW TO USE IT
The Balance Step is a slow balance line. Price above it shows strength, price below it shows weakness. Since the next period's level is drawn in advance, you can use it as a reference for the coming period. Several timeframes together (for example daily, weekly and monthly) show the balance of each time horizon on one chart. It's a reference level, not a signal generator.

INPUTS
• Length (default 5): the number of Balance Points averaged, shared by all periods.
• Own Period (default D): always on.
• Next Period (default W): off by default.
• High Period (default M): off by default.
• Each period has its own line color, width and style in the Inputs tab.

DRAWING AND LIMITATIONS
• On a chart at the Own Period, each bar's value is drawn one bar forward, so the next period's level sits one bar past the last bar.
• On a chart below a period (for example, the weekly Balance Step on a daily chart), each bar shows the value in force for its period. After the last bar, the line continues to the period's end. It then steps to the next period's level, which is calculated from the current period so far, and runs across the next period. That projected part changes until the current period closes.
• History never repaints: each period uses only the previous, completed period's values.
• Own is drawn on charts at or below its Period. Next and High are drawn only on charts below theirs.

CREDITS
The concept is Robert Krausz's (Fibonacci Trader). The code is my own open-source implementation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bashu9
//@version=6

//#region Header Info
// ——————————————————————————————————————————————————————————————————————————
// Indicator:   Balance Step
// Author:      bashu9
// Description: Krausz's Balance Step: a moving average of the last N Balance Points in step formation, on Own / Next / High Periods.
// ——————————————————————————————————————————————————————————————————————————
//#endregion

indicator("Balance Step", overlay = true)

// Robert Krausz's Balance Step (as in Fibonacci Trader): a simple moving
// average of the last 5 Balance Points ((high + low + close) / 3) of the
// selected timeframe, in step formation, projected one period forward. Each
// period shows the value known at the previous period's close; the latest value
// is drawn one period into the future. Own, Next and High Periods, like the HiLo.

// ─── INPUTS ──────────────────────────────────────────────────────────────────
int    len        = input.int(5, "Length", minval = 1, group = "Balance Step")  // shared by all periods

string own_res    = input.timeframe("D", "Period", group = "Own Period")
color  own_c      = input.color(#FF0000, "Line Color", group = "Own Period")
int    own_w      = input.int(1, "Line Width", minval = 1, maxval = 4, group = "Own Period")
string own_st     = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = "Own Period")

bool   next_show  = input.bool(false, "Show Next Period", group = "Next Period")
string next_res   = input.timeframe("W", "Period", group = "Next Period")
color  next_c     = input.color(#0000FF, "Line Color", group = "Next Period")
int    next_w     = input.int(2, "Line Width", minval = 1, maxval = 4, group = "Next Period")
string next_st    = input.string("Dashed", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = "Next Period")

bool   high_show  = input.bool(false, "Show High Period", group = "High Period")
string high_res   = input.timeframe("M", "Period", group = "High Period")
color  high_c     = input.color(#FF00FF, "Line Color", group = "High Period")
int    high_w     = input.int(3, "Line Width", minval = 1, maxval = 4, group = "High Period")
string high_st    = input.string("Dashed", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = "High Period")

// ─── CALCULATION ─────────────────────────────────────────────────────────────
bp(float h, float l, float c) =>
    (h + l + c) / 3

bstep(int n) =>
    ta.sma(bp(high, low, close), n)

// Per timeframe: [now, prev, live]
//   now  — the value known at this bar (lookahead off): on a chart at the
//          timeframe, the bar's own value, drawn one bar forward (offset 1);
//   prev — the value in force for this bar's period (the previous period's,
//          [1] with lookahead on, no repaint), drawn below the timeframe;
//   live — the current period's value so far (lookahead on, read only on the
//          last bar): the next period's level, for the projection.
f_vals(string res) =>
    float now_v  = request.security(syminfo.tickerid, res, bstep(len), lookahead = barmerge.lookahead_off)
    float prev_v = request.security(syminfo.tickerid, res, bstep(len)[1], lookahead = barmerge.lookahead_on)
    float live_v = request.security(syminfo.tickerid, res, bstep(len), lookahead = barmerge.lookahead_on)
    [now_v, prev_v, live_v]

// Line styles as top-level expressions of the inputs (plot's linestyle needs an
// input-qualified value; a function would return a simple one).
own_ls  = own_st  == "Dashed" ? plot.linestyle_dashed : own_st  == "Dotted" ? plot.linestyle_dotted : plot.linestyle_solid
next_ls = next_st == "Dashed" ? plot.linestyle_dashed : next_st == "Dotted" ? plot.linestyle_dotted : plot.linestyle_solid
high_ls = high_st == "Dashed" ? plot.linestyle_dashed : high_st == "Dotted" ? plot.linestyle_dotted : plot.linestyle_solid
f_lst(string st) => st == "Dashed" ? line.style_dashed : st == "Dotted" ? line.style_dotted : line.style_solid

[own_now, own_prev, own_live]    = f_vals(own_res)
[next_now, next_prev, next_live] = f_vals(next_res)
[high_now, high_prev, high_live] = f_vals(high_res)

// Own: drawn while the chart is at or below its Period; Next/High: while below.
bool own_same = timeframe.in_seconds() >= timeframe.in_seconds(own_res)
bool own_ok   = timeframe.in_seconds() <= timeframe.in_seconds(own_res)
bool next_ok  = next_show and timeframe.in_seconds() < timeframe.in_seconds(next_res)
bool high_ok  = high_show and timeframe.in_seconds() < timeframe.in_seconds(high_res)

// ─── DRAWING ─────────────────────────────────────────────────────────────────
// Step-line plots, look from Inputs (not in the Style tab). On a chart at the
// timeframe (Own only): each bar's own value one bar forward, so the next
// period's level sits one bar = one period past the last bar. Below it: each
// bar shows the value in force for its period (no shift).
plot(own_ok  ? (own_same ? own_now : own_prev) : na, "Balance Step (Own)", own_c, own_w, plot.style_stepline, offset = own_same ? 1 : 0, linestyle = own_ls, editable = false)
plot(next_ok ? next_prev : na, "Balance Step (Next)", next_c, next_w, plot.style_stepline, linestyle = next_ls, editable = false)
plot(high_ok ? high_prev : na, "Balance Step (High)", high_c, high_w, plot.style_stepline, linestyle = high_ls, editable = false)

// Below the timeframe the plot ends on the last bar, mid-period. As in FT, the
// line continues as a polyline in the same look: the level in force to the
// period's end, a riser to the next period's level (the current period so
// far), and that level across the next period.
f_tail(string res, float prev_v, float live_v, color c, int w, string st) =>
    polyline pl = na
    if not na(prev_v)
        int t1 = time_close(res)                                  // the next period's start
        array<chart.point> tp = array.from(chart.point.from_time(time, prev_v), chart.point.from_time(t1, prev_v))
        if not na(live_v)
            tp.push(chart.point.from_time(t1, live_v))
            tp.push(chart.point.from_time(t1 + timeframe.in_seconds(res) * 1000, live_v))
        pl := polyline.new(tp, xloc = xloc.bar_time, line_color = c, line_width = w, line_style = f_lst(st))
    pl

var array<polyline> tails = array.new<polyline>()
if barstate.islast
    for pl in tails
        pl.delete()
    tails.clear()
    if own_ok and not own_same
        tails.push(f_tail(own_res, own_prev, own_live, own_c, own_w, own_st))
    if next_ok
        tails.push(f_tail(next_res, next_prev, next_live, next_c, next_w, next_st))
    if high_ok
        tails.push(f_tail(high_res, high_prev, high_live, high_c, high_w, high_st))
````
