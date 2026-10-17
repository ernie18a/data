# VWAP Intraday, Weekly, Monthly

- url: https://www.tradingview.com/script/mthvTwSg-VWAP-Intraday-Weekly-Monthly/
- type: indicator
- pine_id: PUB;17fef429a5964fd1ab59e1f5e6194de9
- version: 1.0

## Description

A clean, professional implementation of three anchored VWAPs — Intraday, Weekly and Monthly — with standard deviation bands, cloud fills and candle coloring. Built for futures, stocks and forex traders who use VWAP as a core part of their analysis.

━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IS VWAP?
━━━━━━━━━━━━━━━━━━━━━━━━
Volume Weighted Average Price is the most widely referenced intraday benchmark used by institutional traders, market makers and algorithms. It represents the average price at which all volume has transacted over a given period. Price above VWAP is generally considered bullish, price below is bearish. The standard deviation bands show statistical distance from fair value — the further price extends from VWAP, the more extended and mean-reversion prone the move becomes.

━━━━━━━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━
▶ Intraday VWAP — resets each session. Band 1 and Band 2 with optional cloud fill.
▶ Weekly VWAP — resets each week. Band 1 and Band 2 with optional cloud fill.
▶ Monthly VWAP — resets each month, correctly anchored to the first session of the calendar month. Band 1 and Band 2 with optional cloud fill.
▶ Candle Coloring — green when price closes above Intraday Band 1, red when below. Neutral inside the bands.
▶ Multiple Anchors — Globex (18:00 ET, best for NQ/ES futures), Midnight (stocks and forex), Market Open (9:30 ET RTH), London session (03:00 ET) and Asia session.
▶ Source Selection — HLC3 (typical price, institutional standard), Close, HL2 or OHLC4.

━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━━━━━
Futures traders (NQ, ES, MNQ): use Globex anchor. This anchors VWAP to the 18:00 ET session open, matching institutional platforms like Sierra Chart and Bookmap.

Stock traders: use Midnight or Market Open anchor depending on your preference.

Forex traders: use Midnight anchor for a standard daily reset.

Band 1 (1.0 std dev) is the primary level. Price rejecting from Band 1 and reversing toward VWAP is one of the most reliable setups in VWAP trading. Price closing outside Band 1 signals a strong directional move. Band 2 (2.0 std dev) marks extended moves where mean reversion is statistically more likely.

Weekly and Monthly VWAPs act as macro support and resistance levels. Price above both is a bullish macro structure. Price between them shows a transitional zone. Price below both is bearish.

━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━
All colors, opacity and line thickness are adjustable by clicking each color swatch — the popup includes color, opacity, thickness and line style in one place.

Each band's standard deviation multiplier is adjustable. The default 1.0 and 2.0 are the most commonly used values but some traders prefer 1.5 / 2.5 depending on their instrument and style.

━━━━━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━━━━━
- Works on any timeframe and any instrument with volume data.
- For accurate Globex VWAP on NQ/ES, ensure your chart data includes the overnight session.
- Monthly VWAP is anchored to the first Globex session of each calendar month, not midnight of the 1st — this matches the institutional convention for futures.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © VWAP Intraday, Weekly, Monthly

//@version=6
indicator(title="VWAP Intraday, Weekly, Monthly", shorttitle="VWAP IWM", overlay=true, max_bars_back=1000)

// ============================================================
// GENERAL SETTINGS
// ============================================================
vwap_anchor     = input.string("Globex (18:00 ET)", "Anchor", options=["Globex (18:00 ET)","Midnight","Market Open (9:30 ET)"], group="GENERAL", tooltip="Globex: futures sessions starting 18:00 ET — best for NQ/ES/futures.\nMidnight: standard calendar day — best for stocks and forex.\nMarket Open: anchors to 9:30 ET RTH open only.")
vwap_source     = input.string("HLC3", "Source", options=["HLC3","Close","HL2","OHLC4"], group="GENERAL", tooltip="Price source for all VWAP calculations. HLC3 (typical price) is the institutional standard.")
candle_color_on = input.bool(true,         "Candle Coloring", group="GENERAL", inline="cc", tooltip="Green candles above Intraday Band 1. Red candles below Intraday Band 1. No colour inside the bands.")
cc_bull         = input.color(color.green, "", group="GENERAL", inline="cc")
cc_bear         = input.color(color.red,   "", group="GENERAL", inline="cc")

// ============================================================
// INTRADAY VWAP
// ============================================================
intraday_show  = input.bool(true,          "Intraday VWAP", group="INTRADAY VWAP", inline="i0")
intraday_color = input.color(color.orange, "",              group="INTRADAY VWAP", inline="i0")

intra_b1_show  = input.bool(true,        "Band 1", group="INTRADAY VWAP", inline="ib1", tooltip="Standard deviation multiplier. 1.0 = one std dev from VWAP — the primary institutional level.")
intra_b1_mult  = input.float(1.0, "",    minval=0.1, step=0.1, group="INTRADAY VWAP", inline="ib1")
intra_b1_color = input.color(color.blue, "",        group="INTRADAY VWAP", inline="ib1")
intra_b1_fill  = input.bool(true,        "Fill",    group="INTRADAY VWAP", inline="ib1")
intra_b1_bg    = input.color(color.new(color.blue, 90), "", group="INTRADAY VWAP", inline="ib1")

intra_b2_show  = input.bool(false,                      "Band 2", group="INTRADAY VWAP", inline="ib2", tooltip="Standard deviation multiplier. 2.0 = two std devs — extended move away from fair value.")
intra_b2_mult  = input.float(2.0, "",                   minval=0.1, step=0.1, group="INTRADAY VWAP", inline="ib2")
intra_b2_color = input.color(color.new(color.blue, 40), "", group="INTRADAY VWAP", inline="ib2")
intra_b2_fill  = input.bool(false,                      "Fill", group="INTRADAY VWAP", inline="ib2")
intra_b2_bg    = input.color(color.new(color.blue, 95), "", group="INTRADAY VWAP", inline="ib2")

// ============================================================
// WEEKLY VWAP
// ============================================================
weekly_show    = input.bool(true,        "Weekly VWAP", group="WEEKLY VWAP", inline="w0")
weekly_color   = input.color(color.aqua, "",            group="WEEKLY VWAP", inline="w0")

weekly_b1_show  = input.bool(true,        "Band 1", group="WEEKLY VWAP", inline="wb1", tooltip="Standard deviation multiplier for Weekly Band 1.")
weekly_b1_mult  = input.float(1.0, "",    minval=0.1, step=0.1, group="WEEKLY VWAP", inline="wb1")
weekly_b1_color = input.color(color.aqua, "",        group="WEEKLY VWAP", inline="wb1")
weekly_b1_fill  = input.bool(false,       "Fill",    group="WEEKLY VWAP", inline="wb1")
weekly_b1_bg    = input.color(color.new(color.aqua, 100), "", group="WEEKLY VWAP", inline="wb1")

weekly_b2_show  = input.bool(false,           "Band 2", group="WEEKLY VWAP", inline="wb2", tooltip="Standard deviation multiplier for Weekly Band 2.")
weekly_b2_mult  = input.float(1.5, "",        minval=0.1, step=0.1, group="WEEKLY VWAP", inline="wb2")
weekly_b2_color = input.color(color.orange,   "",         group="WEEKLY VWAP", inline="wb2")
weekly_b2_fill  = input.bool(false,           "Fill",     group="WEEKLY VWAP", inline="wb2")
weekly_b2_bg    = input.color(color.new(color.orange, 100), "", group="WEEKLY VWAP", inline="wb2")

// ============================================================
// MONTHLY VWAP
// ============================================================
monthly_show    = input.bool(true,          "Monthly VWAP", group="MONTHLY VWAP", inline="m0")
monthly_color   = input.color(color.purple, "",             group="MONTHLY VWAP", inline="m0")

monthly_b1_show  = input.bool(true,          "Band 1", group="MONTHLY VWAP", inline="mb1", tooltip="Standard deviation multiplier for Monthly Band 1.")
monthly_b1_mult  = input.float(1.0, "",      minval=0.1, step=0.1, group="MONTHLY VWAP", inline="mb1")
monthly_b1_color = input.color(color.purple, "",         group="MONTHLY VWAP", inline="mb1")
monthly_b1_fill  = input.bool(false,         "Fill",     group="MONTHLY VWAP", inline="mb1")
monthly_b1_bg    = input.color(color.new(color.purple, 100), "", group="MONTHLY VWAP", inline="mb1")

monthly_b2_show  = input.bool(false,        "Band 2", group="MONTHLY VWAP", inline="mb2", tooltip="Standard deviation multiplier for Monthly Band 2.")
monthly_b2_mult  = input.float(1.5, "",     minval=0.1, step=0.1, group="MONTHLY VWAP", inline="mb2")
monthly_b2_color = input.color(color.blue,  "",        group="MONTHLY VWAP", inline="mb2")
monthly_b2_fill  = input.bool(false,        "Fill",    group="MONTHLY VWAP", inline="mb2")
monthly_b2_bg    = input.color(color.new(color.blue, 100), "", group="MONTHLY VWAP", inline="mb2")

// ============================================================
// SESSION DETECTION
// ============================================================
bar_hour_et   = hour(time,      "America/New_York")
bar_minute_et = minute(time,    "America/New_York")
bar_dow_et    = dayofweek(time, "America/New_York")

is_globex_start = switch vwap_anchor
    "Globex (18:00 ET)"      => bar_hour_et == 18 and bar_minute_et == 0 and bar_dow_et >= dayofweek.sunday and bar_dow_et <= dayofweek.thursday
    "Midnight"               => bar_hour_et == 0  and bar_minute_et == 0 and bar_dow_et >= dayofweek.monday and bar_dow_et <= dayofweek.friday
    "Market Open (9:30 ET)"  => bar_hour_et == 9  and bar_minute_et == 30 and bar_dow_et >= dayofweek.monday and bar_dow_et <= dayofweek.friday
    => bar_hour_et == 18 and bar_minute_et == 0 and bar_dow_et >= dayofweek.sunday and bar_dow_et <= dayofweek.thursday

is_week_start = switch vwap_anchor
    "Globex (18:00 ET)"      => bar_hour_et == 18 and bar_minute_et == 0 and bar_dow_et == dayofweek.sunday
    "Midnight"               => bar_hour_et == 0  and bar_minute_et == 0 and bar_dow_et == dayofweek.monday
    "Market Open (9:30 ET)"  => bar_hour_et == 9  and bar_minute_et == 30 and bar_dow_et == dayofweek.monday
    => bar_hour_et == 18 and bar_minute_et == 0 and bar_dow_et == dayofweek.sunday

var int last_month_anchored = -1
bar_month_trading = month(time + 6 * 3600000, "America/New_York")
is_month_start = is_globex_start and bar_month_trading != last_month_anchored and last_month_anchored != -1
if is_globex_start and bar_month_trading != last_month_anchored
    last_month_anchored := bar_month_trading

// ============================================================
// SOURCE
// ============================================================
src = switch vwap_source
    "HLC3"  => (high + low + close) / 3.0
    "Close" => close
    "HL2"   => (high + low) / 2.0
    "OHLC4" => (open + high + low + close) / 4.0
    => (high + low + close) / 3.0

// ============================================================
// VWAP CALCULATIONS
// ============================================================
var float intra_sum_pv  = 0.0
var float intra_sum_v   = 0.0
var float intra_sum_pv2 = 0.0
if is_globex_start
    intra_sum_pv  := 0.0
    intra_sum_v   := 0.0
    intra_sum_pv2 := 0.0
intra_sum_pv  += src * volume
intra_sum_v   += volume
intra_sum_pv2 += src * src * volume
intra_vwap    = intra_sum_v > 0 ? intra_sum_pv / intra_sum_v : na
intra_var     = intra_sum_v > 0 ? math.sqrt(math.max(intra_sum_pv2 / intra_sum_v - intra_vwap * intra_vwap, 0.0)) : na
intra_upper1  = intra_vwap + intra_b1_mult * intra_var
intra_lower1  = intra_vwap - intra_b1_mult * intra_var
intra_upper2  = intra_vwap + intra_b2_mult * intra_var
intra_lower2  = intra_vwap - intra_b2_mult * intra_var

var float week_sum_pv  = 0.0
var float week_sum_v   = 0.0
var float week_sum_pv2 = 0.0
if is_week_start
    week_sum_pv  := 0.0
    week_sum_v   := 0.0
    week_sum_pv2 := 0.0
week_sum_pv  += src * volume
week_sum_v   += volume
week_sum_pv2 += src * src * volume
week_vwap    = week_sum_v > 0 ? week_sum_pv / week_sum_v : na
week_var     = week_sum_v > 0 ? math.sqrt(math.max(week_sum_pv2 / week_sum_v - week_vwap * week_vwap, 0.0)) : na
week_upper1  = week_vwap + weekly_b1_mult * week_var
week_lower1  = week_vwap - weekly_b1_mult * week_var
week_upper2  = week_vwap + weekly_b2_mult * week_var
week_lower2  = week_vwap - weekly_b2_mult * week_var

var float month_sum_pv  = 0.0
var float month_sum_v   = 0.0
var float month_sum_pv2 = 0.0
if is_month_start
    month_sum_pv  := 0.0
    month_sum_v   := 0.0
    month_sum_pv2 := 0.0
month_sum_pv  += src * volume
month_sum_v   += volume
month_sum_pv2 += src * src * volume
month_vwap    = month_sum_v > 0 ? month_sum_pv / month_sum_v : na
month_var     = month_sum_v > 0 ? math.sqrt(math.max(month_sum_pv2 / month_sum_v - month_vwap * month_vwap, 0.0)) : na
month_upper1  = month_vwap + monthly_b1_mult * month_var
month_lower1  = month_vwap - monthly_b1_mult * month_var
month_upper2  = month_vwap + monthly_b2_mult * month_var
month_lower2  = month_vwap - monthly_b2_mult * month_var

// ============================================================
// PLOTS
// ============================================================
p_intra_vwap   = plot(intraday_show   ? intra_vwap   : na, "Intraday VWAP",  color=intraday_color,   linewidth=2)
p_intra_upper1 = plot(intra_b1_show   ? intra_upper1 : na, "Intra Upper B1", color=intra_b1_color,   linewidth=1)
p_intra_lower1 = plot(intra_b1_show   ? intra_lower1 : na, "Intra Lower B1", color=intra_b1_color,   linewidth=1)
p_intra_upper2 = plot(intra_b2_show   ? intra_upper2 : na, "Intra Upper B2", color=intra_b2_color,   linewidth=1)
p_intra_lower2 = plot(intra_b2_show   ? intra_lower2 : na, "Intra Lower B2", color=intra_b2_color,   linewidth=1)

p_week_vwap    = plot(weekly_show     ? week_vwap    : na, "Weekly VWAP",    color=weekly_color,     linewidth=2)
p_week_upper1  = plot(weekly_b1_show  ? week_upper1  : na, "Week Upper B1",  color=weekly_b1_color,  linewidth=1)
p_week_lower1  = plot(weekly_b1_show  ? week_lower1  : na, "Week Lower B1",  color=weekly_b1_color,  linewidth=1)
p_week_upper2  = plot(weekly_b2_show  ? week_upper2  : na, "Week Upper B2",  color=weekly_b2_color,  linewidth=1)
p_week_lower2  = plot(weekly_b2_show  ? week_lower2  : na, "Week Lower B2",  color=weekly_b2_color,  linewidth=1)

p_month_vwap   = plot(monthly_show    ? month_vwap   : na, "Monthly VWAP",   color=monthly_color,    linewidth=2)
p_month_upper1 = plot(monthly_b1_show ? month_upper1 : na, "Month Upper B1", color=monthly_b1_color, linewidth=1)
p_month_lower1 = plot(monthly_b1_show ? month_lower1 : na, "Month Lower B1", color=monthly_b1_color, linewidth=1)
p_month_upper2 = plot(monthly_b2_show ? month_upper2 : na, "Month Upper B2", color=monthly_b2_color, linewidth=1)
p_month_lower2 = plot(monthly_b2_show ? month_lower2 : na, "Month Lower B2", color=monthly_b2_color, linewidth=1)

// ============================================================
// FILLS
// ============================================================
fill(p_intra_vwap,   p_intra_upper1, intra_b1_fill  and intra_b1_show  and intraday_show     ? intra_b1_bg   : na)
fill(p_intra_vwap,   p_intra_lower1, intra_b1_fill  and intra_b1_show  and intraday_show     ? intra_b1_bg   : na)
fill(p_intra_upper1, p_intra_upper2, intra_b2_fill  and intra_b2_show  and intra_b1_show     ? intra_b2_bg   : na)
fill(p_intra_lower1, p_intra_lower2, intra_b2_fill  and intra_b2_show  and intra_b1_show     ? intra_b2_bg   : na)
fill(p_week_vwap,    p_week_upper1,  weekly_b1_fill  and weekly_b1_show  and weekly_show     ? weekly_b1_bg  : na)
fill(p_week_vwap,    p_week_lower1,  weekly_b1_fill  and weekly_b1_show  and weekly_show     ? weekly_b1_bg  : na)
fill(p_week_upper1,  p_week_upper2,  weekly_b2_fill  and weekly_b2_show  and weekly_b1_show  ? weekly_b2_bg  : na)
fill(p_week_lower1,  p_week_lower2,  weekly_b2_fill  and weekly_b2_show  and weekly_b1_show  ? weekly_b2_bg  : na)
fill(p_month_vwap,   p_month_upper1, monthly_b1_fill and monthly_b1_show and monthly_show    ? monthly_b1_bg : na)
fill(p_month_vwap,   p_month_lower1, monthly_b1_fill and monthly_b1_show and monthly_show    ? monthly_b1_bg : na)
fill(p_month_upper1, p_month_upper2, monthly_b2_fill and monthly_b2_show and monthly_b1_show ? monthly_b2_bg : na)
fill(p_month_lower1, p_month_lower2, monthly_b2_fill and monthly_b2_show and monthly_b1_show ? monthly_b2_bg : na)

// ============================================================
// CANDLE COLORING
// ============================================================
candle_col = if candle_color_on and not na(intra_vwap)
    if close > intra_upper1
        cc_bull
    else if close < intra_lower1
        cc_bear
    else
        na
else
    na
barcolor(candle_col)
````
