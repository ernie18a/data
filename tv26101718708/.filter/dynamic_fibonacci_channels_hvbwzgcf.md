# Dynamic Fibonacci Channels

- url: https://www.tradingview.com/script/hVBWzGcf-Dynamic-Fibonacci-Channels/
- type: indicator
- pine_id: PUB;a79beedb2f9b4409be49e9df311bc0da
- version: 1.0

## Description

Robert Krausz's Dynamic Fibonacci Channels, as described in his Fibonacci Trader software, for TradingView. A center line, the Dynamic Balance Point, with two Fibonacci channels around it, built from a rolling window of the last N bars of a timeframe you choose.

HOW IT WORKS
• Dynamic Balance Point (DBP) = (highest high + lowest low + close) / 3 over the last N bars of the selected timeframe. The current bar is included, so the value updates live.
• Range = highest high − lowest low of the same N bars.
• Each channel is centered on the DBP and its full width is Range × ratio:
Upper = DBP + Range × ratio / 2
Lower = DBP − Range × ratio / 2
• Defaults: Channel 1 = 0.382, Channel 2 = 0.786.

HOW TO USE IT
The DBP is the market's balance over the last N bars. The channels mark how far price is stretched from that balance:
• Inside Channel 1: price is near balance.
• Beyond Channel 2: price is far from balance; watch for exhaustion or a strong trend.
Use the channels as reference levels for entries, stops and targets, together with your own trend tools. On its own it is not a signal generator.

INPUTS
• Timeframe (default D): the timeframe the calculation runs on.
• Length (default 5): number of bars in the window.
• Channel 1 / Channel 2: on/off and ratio for each channel.
Colors, widths and styles are set in the Style tab. The DBP line is hidden by default; enable it in the Style tab.

DRAWING AND LIMITATIONS
• On a chart at the selected timeframe, each bar shows the value calculated at that bar's close. The current bar updates until it closes.
• On a lower chart timeframe (for example, a daily DFC on an hourly chart), each period gets one point on its last chart bar, and the points are joined by a line. The line between two points is drawn for readability only: the bars in between did not know that period's final value yet. On the last bar the line continues to the current period's live value, which changes until the period closes.
• Nothing is drawn on a chart above the selected timeframe.
• No forward shift.

CREDITS
The concept and the default ratios are Robert Krausz's (Fibonacci Trader). The code is my own open-source implementation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bashu9
//@version=6

//#region Header Info
// ——————————————————————————————————————————————————————————————————————————
// Indicator:   Dynamic Fibonacci Channels
// Author:      bashu9
// Description: Krausz's Dynamic Fibonacci Channels: the Dynamic Balance Point with two Fibonacci channels around it.
// ——————————————————————————————————————————————————————————————————————————
//#endregion

indicator("Dynamic Fibonacci Channels", shorttitle = "DFC", overlay = true)

// Robert Krausz's Dynamic Fibonacci Channels (as in Fibonacci Trader): a
// center line, the Dynamic Balance Point, plus two Fibonacci channels around
// it, over a rolling window of the last N bars of the selected timeframe
// (current bar included, so the live bar updates tick by tick). No forward
// shift. Colors, widths, styles and visibility are set in the Style tab.

// ─── INPUTS ──────────────────────────────────────────────────────────────────
string tf     = input.timeframe("D", "Timeframe")
int    len    = input.int(5, "Length", minval = 2)
bool   ch1_on = input.bool(true, "Channel 1", inline = "ch1")
float  ch1_r  = input.float(0.382, "", step = 0.001, inline = "ch1")
bool   ch2_on = input.bool(true, "Channel 2", inline = "ch2")
float  ch2_r  = input.float(0.786, "", step = 0.001, inline = "ch2")

// Drawn only while the chart is at or below the timeframe; on a higher chart
// nothing is drawn (no error), as in the other indicators.
bool dfc_valid = timeframe.in_seconds() <= timeframe.in_seconds(tf)

// ─── CALCULATION (reusable) ──────────────────────────────────────────────────
// Dynamic Balance Point: (highest high + lowest low + close) / 3.
dbp(float hh, float ll, float c) =>
    (hh + ll + c) / 3

// A channel whose FULL width is rng × ratio, centered on the DBP.
channel(float bp, float rng, float ratio) =>
    [bp + rng * ratio / 2, bp - rng * ratio / 2]

// Runs on the selected timeframe: HH/LL of the last `n` bars incl. the current one.
calc(int n) =>
    float hh = ta.highest(high, n)
    float ll = ta.lowest(low, n)
    [dbp(hh, ll, close), hh - ll]

[bp, rng] = request.security(syminfo.tickerid, tf, calc(len), lookahead = barmerge.lookahead_off)

// Smooth (always; matters on lower chart timeframes): one point per period, on its last chart
// bar, joined by the plot line (drawing only: the bars in between didn't know
// that period's value yet). A period whose closing bar isn't recognised gets
// its point on the next period's first bar. On the chart's last bar the line
// continues to the current period's live value (lookahead on, read only there,
// where it can't reach past existing data; lookahead off would give the last
// closed period on a historical last bar).
[bp_live, rng_live] = request.security(syminfo.tickerid, tf, calc(len), lookahead = barmerge.lookahead_on)
bool per_last = timeframe.in_seconds() >= timeframe.in_seconds(tf) or time_close == time_close(tf)
var int done_key = na  // the last period whose point was placed
bool per_late = timeframe.change(tf) and (na(done_key) or done_key != time(tf)[1])
float s_bp  = na
float s_rng = na
if per_last
    s_bp  := bp
    s_rng := rng
    done_key := time(tf)
else if per_late
    s_bp  := bp[1]
    s_rng := rng[1]
    done_key := time(tf)[1]
else if barstate.islast
    s_bp  := bp_live
    s_rng := rng_live

[c1_up, c1_lo] = channel(s_bp, s_rng, ch1_r)
[c2_up, c2_lo] = channel(s_bp, s_rng, ch2_r)

// ─── PLOTS (Style tab) ───────────────────────────────────────────────────────
plot(dfc_valid ? s_bp : na, "Dynamic BP", #00FF00, 1, linestyle = plot.linestyle_dashed, display = display.none)
plot(dfc_valid and ch1_on ? c1_up : na, "Channel 1 Upper", #FF0000, 1)
plot(dfc_valid and ch1_on ? c1_lo : na, "Channel 1 Lower", #FF0000, 1)
plot(dfc_valid and ch2_on ? c2_up : na, "Channel 2 Upper", #00FFFF, 1)
plot(dfc_valid and ch2_on ? c2_lo : na, "Channel 2 Lower", #00FFFF, 1)
````
