# Smooths VWAP Suite

- url: https://www.tradingview.com/script/ir55JdPw-Smooths-VWAP-Suite/
- type: indicator
- pine_id: PUB;506ee9befaca4266b3f113f3f50acadb
- version: 1.0

## Description

Title: Smooth's VWAP Suite: Advanced Futures Context & Filtered Signals
Description:

Overview & Purpose
Smooth's VWAP Suite is a comprehensive volume-weighted average price toolkit engineered specifically for futures traders (e.g., NQ, ES).

The primary justification for combining these specific elements—Daily VWAP, Standard Deviation Bands, Session AVWAPs (Overnight, RTH, Weekly), and dynamic signals—into a single script is to solve the problem of "context fragmentation." Futures markets respect multiple volume anchors simultaneously. Rather than cluttering a chart with five individual, unlinked indicators, this suite unites micro (intraday) and macro (weekly) volume levels into one cohesive map. Furthermore, it introduces a custom "Current Day Only" filter mathematically anchored to the 18:00 EST futures open, fixing the common issue where standard indicators rely on the midnight calendar-day rollover.

How It Works: Underlying Concepts & Logic
This script calculates the Volume-Weighted Average Price by maintaining a cumulative running total of Price × Volume, divided by Total Volume.

Session AVWAPs & Previous Day: The script calculates distinct VWAPs based on specific time anchors. It automatically tracks the Weekly open, the Regular Trading Hours (RTH) open, and the Overnight (OVN) session. It also statically plots the Previous Day's closing VWAP value, acting as a critical pivot for the current session.

Standard Deviation Variance: The bands surrounding the Daily VWAP are calculated using the mathematical square root of volume-weighted variance. This provides dynamic, mathematically sound support and resistance zones based on current market volatility, plotted at user-defined multipliers (defaulting to 1.0, 2.0, and 3.0 SD).

Signal Engine & EMA Filter: The built-in signals are not basic crossovers. To prevent false signals in chopping ranging markets, the script requires an EMA (Exponential Moving Average) directional filter to confirm the trend.

Reversal/Cross Signals: Trigger when price straddles the VWAP, closes on the opposite side, is aligned with the EMA slope, and is positioned correctly relative to the Weekly VWAP.

Continuation Signals: Trigger when price pushes into a Standard Deviation band (e.g., SD 1 or SD 2) and actively rejects it, closing back toward the trend direction while maintaining the EMA slope.

How Traders Can Use It
This suite is designed for trend identification, mean-reversion targeting, and precise entry confirmation.

Macro Context Alignment: Use the Weekly and Previous Day VWAP lines to determine the broader bias. If the current Daily VWAP is trading above both, the macro trend is bullish.

Mean Reversion: When price extends into the SD 2 or SD 3 bands, the asset is statistically overextended based on current volume. Traders can look for price action weakness at these extremes to target a reversion back to the Daily VWAP (the mean).

Signal Execution: Utilize the script's visual markers (Arrows/Triangles) for entry confirmations. A bullish signal firing after a bounce off the lower SD 1 band, while the Daily VWAP remains above the Weekly VWAP, offers a high-probability continuation setup.

Chart Decluttering: For active day traders, toggle the "Current Day Only" setting. This utilizes custom logic to sever all historical visual data prior to the exact 18:00 EST futures anchor, keeping your screen entirely focused on the current session's price action.

Customization
Every element is modular. Traders can toggle specific bands, adjust standard deviation multipliers, change the EMA filter length for signals, and customize the visual offsets of the price labels to fit their specific screen layout.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CaptainSmooth

//@version=5
indicator("Smooths VWAP Suite", overlay=true, max_labels_count=500)

// ══════════════════════════════════════════════════════════════
//  GROUPS
// ══════════════════════════════════════════════════════════════
G_GEN = "⚙️ General & Backtest"
G_DV  = "📊 Daily & Previous Day VWAP"
G_BD  = "📏 StDev Bands (Toggles)"
G_SES = "🕒 Session AVWAPs"
G_SG  = "⚡ Signal Logic & Cooldown"
G_TXT = "🔡 Label Appearance"

// ══════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════
src_input   = input.source(hlc3, "VWAP Source", group=G_GEN)
only_today  = input.bool(false, "Current Day Only", group=G_GEN)

dv_show     = input.bool(true,    "Show DVWAP",      group=G_DV, inline="dv")
dv_col      = input.color(color.white, "",           group=G_DV, inline="dv")
pd_show     = input.bool(true,    "Show Prev Day VWAP", group=G_DV, inline="pd")
pd_col      = input.color(color.gray, "",            group=G_DV, inline="pd")

sd_fill     = input.bool(false,   "Enable Band Background Fills", group=G_BD)
sd1_show    = input.bool(true,    "Show SD 1", group=G_BD, inline="s1")
sd_m1       = input.float(1.0,    "Mult", step=0.1, group=G_BD, inline="s1")
sd_c1       = input.color(color.new(color.aqua, 50), "", group=G_BD, inline="s1")
sd2_show    = input.bool(true,    "Show SD 2", group=G_BD, inline="s2")
sd_m2       = input.float(2.0,    "Mult", step=0.1, group=G_BD, inline="s2")
sd_c2       = input.color(color.new(color.purple, 50), "", group=G_BD, inline="s2")
sd3_show    = input.bool(true,    "Show SD 3", group=G_BD, inline="s3")
sd_m3       = input.float(3.0,    "Mult", step=0.1, group=G_BD, inline="s3")
sd_c3       = input.color(color.new(color.red, 50), "", group=G_BD, inline="s3")

wv_show     = input.bool(true,    "Weekly AVWAP",    group=G_SES, inline="wv")
wv_col      = input.color(color.yellow, "",          group=G_SES, inline="wv")
rt_show     = input.bool(true,    "RTH AVWAP",       group=G_SES, inline="rt")
rt_col      = input.color(color.lime, "",            group=G_SES, inline="rt")
ov_show     = input.bool(true,    "Overnight AVWAP", group=G_SES, inline="ov")
ov_col      = input.color(color.orange, "",          group=G_SES, inline="ov")

sg_show     = input.bool(true,    "Show Signals",    group=G_SG)
sig_cd      = input.int(5,        "Signal Cooldown (Bars)", minval=0, group=G_SG)
bull_shp    = input.string("Arrow Up", "Bull Icon", options=["Arrow Up", "Triangle Up", "Circle", "Flag"], group=G_SG, inline="sig")
bull_col    = input.color(color.teal, "",            group=G_SG, inline="sig")
bear_shp    = input.string("Arrow Down", "Bear Icon", options=["Arrow Down", "Triangle Down", "Circle", "Flag"], group=G_SG, inline="sig")
bear_col    = input.color(color.red, "",             group=G_SG, inline="sig")
ema_len     = input.int(21,       "EMA Filter Length", group=G_SG)

txt_size    = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=G_TXT)
txt_offset  = input.int(4,         "Label Offset (Bars)", minval=1, group=G_TXT)

// ══════════════════════════════════════════════════════════════
// EXACT ANCHOR POINT FILTER (FUTURES 18:00 FIX)
// ══════════════════════════════════════════════════════════════
new_day = ta.change(time("D")) != 0

int curr_dow = dayofweek(timenow, "America/New_York")
int curr_hr  = hour(timenow, "America/New_York")

// Base lookback is exactly 24 hours. Modifies over the weekend.
int lookback_days = 1
if curr_dow == 6 and curr_hr >= 17 // Friday after market close
    lookback_days := 2
else if curr_dow == 7 // Saturday
    lookback_days := 2
else if curr_dow == 1 // Sunday
    lookback_days := 3

// The Filter: Creates a perfect threshold. The current anchor will ALWAYS be greater than this.
// The previous day's anchor will ALWAYS be less than this, dropping it instantly at the 18:00 open.
is_today = not only_today or (time("D") >= (timenow - (lookback_days * 86400000)))

f_get_size(s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal
f_get_shape(sh) => sh == "Arrow Up" ? shape.arrowup : sh == "Arrow Down" ? shape.arrowdown : sh == "Triangle Up" ? shape.triangleup : sh == "Triangle Down" ? shape.triangledown : sh == "Circle" ? shape.circle : shape.flag

// ══════════════════════════════════════════════════════════════
// VWAP CALCULATIONS
// ══════════════════════════════════════════════════════════════
var float d_vol = 0.0, var float d_tpv = 0.0, var float d_tp2v = 0.0
var float pdvwap = na

if new_day
    pdvwap := d_tpv / d_vol 
    d_vol := 0.0, d_tpv := 0.0, d_tp2v := 0.0

d_vol  += volume, d_tpv  += src_input * volume, d_tp2v += src_input * src_input * volume
dvwap   = d_tpv / d_vol
d_stdev = math.sqrt(math.max(d_tp2v / d_vol - dvwap * dvwap, 0.0))

dv_u1 = dvwap + sd_m1 * d_stdev, dv_l1 = dvwap - sd_m1 * d_stdev
dv_u2 = dvwap + sd_m2 * d_stdev, dv_l2 = dvwap - sd_m2 * d_stdev
dv_u3 = dvwap + sd_m3 * d_stdev, dv_l3 = dvwap - sd_m3 * d_stdev

// --- SESSION AVWAPS ---
new_week = ta.change(time("W")) != 0
var float w_vol = 0.0, var float w_tpv = 0.0
if new_week
    w_vol := 0.0, w_tpv := 0.0
w_vol += volume, w_tpv += src_input * volume
wvwap = w_tpv / w_vol

et_min = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
is_rth = et_min >= 570 and (et_min[1] < 570 or new_day)
var float r_vol = 0.0, var float r_tpv = 0.0
if is_rth
    r_vol := 0.0, r_tpv := 0.0
r_vol += volume, r_tpv += src_input * volume
rt_vwap = r_tpv / r_vol

is_ovn = et_min >= 1080 and (et_min[1] < 1080 or new_day)
var float o_vol = 0.0, var float o_tpv = 0.0
if is_ovn
    o_vol := 0.0, o_tpv := 0.0
o_vol += volume, o_tpv += src_input * volume
ov_vwap = o_tpv / o_vol

// ══════════════════════════════════════════════════════════════
// SIGNALS
// ══════════════════════════════════════════════════════════════
ema = ta.ema(close, ema_len)
ema_up = ema > ema[1]
ema_dn = ema < ema[1]

straddle = high > dvwap and low < dvwap
raw_bull = straddle and close > dvwap and ema_up and close > wvwap
raw_bear = straddle and close < dvwap and ema_dn and close < wvwap

bull_cont_logic = (low <= dv_l1 and close > dv_l1) or (low <= dv_l2 and close > dv_l2)
bear_cont_logic = (high >= dv_u1 and close < dv_u1) or (high >= dv_u2 and close < dv_u2)

raw_bull_cont = bull_cont_logic and ema_up and close > dvwap and close > open
raw_bear_cont = bear_cont_logic and ema_dn and close < dvwap and close < open

var int last_sig_bar = 0
bull_rej  = (raw_bull or raw_bull_cont) and (bar_index - last_sig_bar > sig_cd)
bear_rej  = (raw_bear or raw_bear_cont) and (bar_index - last_sig_bar > sig_cd)

if bull_rej or bear_rej
    last_sig_bar := bar_index

// ══════════════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════════════
dv_p = plot(dv_show and is_today ? dvwap : na, "DVWAP", color=dv_col, linewidth=2)
pd_p = plot(pd_show and is_today ? pdvwap : na, "Prev Day VWAP", color=pd_col, style=plot.style_circles)

u1_p = plot(dv_show and sd1_show and is_today ? dv_u1 : na, "SD 1 Top", color=sd_c1)
l1_p = plot(dv_show and sd1_show and is_today ? dv_l1 : na, "SD 1 Bottom", color=sd_c1)
u2_p = plot(dv_show and sd2_show and is_today ? dv_u2 : na, "SD 2 Top", color=sd_c2)
l2_p = plot(dv_show and sd2_show and is_today ? dv_l2 : na, "SD 2 Bottom", color=sd_c2)
u3_p = plot(dv_show and sd3_show and is_today ? dv_u3 : na, "SD 3 Top", color=sd_c3)
l3_p = plot(dv_show and sd3_show and is_today ? dv_l3 : na, "SD 3 Bottom", color=sd_c3)

fill(u1_p, l1_p, color=sd_fill and sd1_show and is_today ? color.new(sd_c1, 90) : na, title="SD 1 Fill")
fill(u2_p, l2_p, color=sd_fill and sd2_show and is_today ? color.new(sd_c2, 93) : na, title="SD 2 Fill")
fill(u3_p, l3_p, color=sd_fill and sd3_show and is_today ? color.new(sd_c3, 95) : na, title="SD 3 Fill")

plot(wv_show and is_today ? wvwap : na, "Weekly", color=wv_col, style=plot.style_linebr)
plot(rt_show and is_today ? rt_vwap : na, "RTH", color=rt_col, style=plot.style_linebr)
plot(ov_show and is_today ? ov_vwap : na, "Overnight", color=ov_col, style=plot.style_linebr)

plotshape(sg_show and bull_rej and is_today, "Bull", f_get_shape(bull_shp), location.belowbar, bull_col, size=size.small)
plotshape(sg_show and bear_rej and is_today, "Bear", f_get_shape(bear_shp), location.abovebar, bear_col, size=size.small)

// ══════════════════════════════════════════════════════════════
// LABELS
// ══════════════════════════════════════════════════════════════
f_draw_txt(val, txt, col) =>
    var label l = na
    label.delete(l)
    l := label.new(bar_index + txt_offset, val, txt, color=color.new(color.black, 100), textcolor=col, style=label.style_none, size=f_get_size(txt_size))

if barstate.islast
    if dv_show
        f_draw_txt(dvwap, "DVWAP", dv_col)
        if sd1_show
            f_draw_txt(dv_u1, "SD 1", sd_c1), f_draw_txt(dv_l1, "SD 1", sd_c1)
        if sd2_show
            f_draw_txt(dv_u2, "SD 2", sd_c2), f_draw_txt(dv_l2, "SD 2", sd_c2)
        if sd3_show
            f_draw_txt(dv_u3, "SD 3", sd_c3), f_draw_txt(dv_l3, "SD 3", sd_c3)
    if pd_show
        f_draw_txt(pdvwap, "Prev Day VWAP", pd_col)
    if wv_show
        f_draw_txt(wvwap, "Weekly", wv_col)
    if rt_show
        f_draw_txt(rt_vwap, "RTH", rt_col)
    if ov_show
        f_draw_txt(ov_vwap, "Overnight", ov_col)
````
