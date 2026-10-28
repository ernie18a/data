# Entry Gate - ADR% / ADV / ATR Multiple

- url: https://www.tradingview.com/script/62gvUw0x-Entry-Gate-ADR-ADV-ATR-Multiple/
- type: indicator
- pine_id: PUB;26756d26547648f1802d2063f9832d99
- version: 2.0

## Description

Three critical pre-trade filters, always visible right on your chart.

Before entering any swing trade, three questions determine whether the setup is even worth considering: is this stock volatile enough to move my account, is it liquid enough to trade cleanly, and is it too extended to enter now? Entry Gate answers all three at a glance, in a single corner of your chart.

[list]
[*]ADR% (Average Daily Range) measures how much a stock moves on an average day. Too low and it won't move your portfolio. Too high and daily noise will stop you out randomly.
[*]ADV (Average Dollar Volume) measures how much money flows through the stock each day. Liquid stocks respect key levels, pull back cleanly to moving averages, and don't gap on low volume. Illiquid stocks do the opposite.
[*]ATR Multiple measures how extended the price is above its 50-day moving average, expressed in ATR units. The further extended, the higher the probability of a pause or reversal. Based on jfsrev's published formula: % Gain from MA divided by ATR%.
[*]ATR% rounds out the dashboard with the raw volatility number for context.
[/list]

All values are color-coded against your thresholds:

🟢 Green — within your ideal range
🟠 Orange — borderline, proceed with caution
🔴 Red — outside your criteria

A yellow dot also plots above the bar when the ATR Multiple exceeds your trigger level, marking historically extended zones at a glance.

[b]Fully customizable:[/b]
[list]
[*]Independent thresholds for ADR%, ADV, and ATR Multiple
[*]Warning zones for borderline values
[*]Lookback periods for each calculation
[*]Font size, table position, dot size and offset
[*]Color customization for good / warning / bad / ATR / dot
[/list]

All values are pulled from the daily timeframe via request.security, so the numbers stay consistent whether you're on a daily, weekly, or intraday chart.

Default thresholds are calibrated for swing traders running mid-sized accounts. Adjust to match your strategy.

Credits to ArmerSchlucker for the original ADR% table indicator, MikeC / TheScrutiniser and GlinckEastwoot for the ADR% formula, and jfsrev / Fred6724 for the ATR% Multiple from 50-MA approach.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vinthomas
// Based on original work by ArmerSchlucker
// Credit to MikeC / TheScrutiniser and GlinckEastwoot for ADR% formula
// ATR% Multiple formula credit to jfsrev / Fred6724

//@version=6

indicator(title="Entry Gate — ADR% / ADV / ATR Multiple", shorttitle="Entry Gate", overlay=true)

// --- Display ---
show_adrp        = input.bool(true,  title="Show ADR%",                    group="Display")
show_adv         = input.bool(true,  title="Show Avg Dollar Volume",        group="Display")
show_atr_multi   = input.bool(true,  title="Show ATR Multiple",            group="Display")
show_atr_pct     = input.bool(true,  title="Show ATR%",                    group="Display")
show_dot         = input.bool(true,  title="Show Extension Dot",           group="Display")
show_empty_row   = input.bool(true,  title="Add empty row above values",   group="Display",
  tooltip="Prevents pane icons from overlapping with the table text when multiple panes are shown")
show_on_weekly   = input.bool(true,  title="Show on Weekly/Monthly",       group="Display",
  tooltip="All values are calculated from daily data via request.security regardless of chart timeframe, so readings are valid and comparable on weekly and monthly charts")
font_size        = input.string("normal", title="Font Size",               group="Display",
  options=["tiny", "small", "normal", "large", "huge"])
table_position   = input.string("Top Right", title="Table Position",       group="Display",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"])
dot_offset_pct   = input.float(3.0, title="Dot Offset % Above High",       group="Display",
  tooltip="Percentage above the bar high where the extension dot appears. Default 3% places it clearly above any other highs-anchored indicators like Diamond Highs.",
  minval=0.0, maxval=10.0, step=0.1)
dot_width        = input.int(3, title="Dot Width",                         group="Display",
  tooltip="Visual size of the extension dot on the chart",
  minval=1, maxval=10)

// --- Lengths ---
adrp_len = input.int(20, title="ADR% Length",                group="Lengths",
  tooltip="Number of daily bars used in ADR% calculation")
adv_len  = input.int(20, title="Avg Dollar Volume Length",   group="Lengths",
  tooltip="Number of daily bars used in Avg Dollar Volume calculation")
atr_len  = input.int(14, title="ATR Length",                 group="Lengths",
  tooltip="Number of daily bars used in ATR calculation")
ma_len   = input.int(50, title="MA Length for ATR Multiple", group="Lengths",
  tooltip="The moving average used as the base for ATR Multiple calculation")

// --- ADR% Thresholds ---
adr_min       = input.float(4.0, title="Minimum (below = red)",         group="ADR% Thresholds",
  tooltip="Stocks below this ADR% may not move enough to meaningfully impact your portfolio")
adr_warn_low  = input.float(5.0, title="Warning Low (below = orange)",  group="ADR% Thresholds")
adr_warn_high = input.float(8.0, title="Warning High (above = orange)", group="ADR% Thresholds")
adr_max       = input.float(9.0, title="Maximum (above = red)",         group="ADR% Thresholds",
  tooltip="Stocks above this ADR% carry excessive daily volatility and gap risk")

// --- ADV Thresholds ---
adv_min  = input.float(50,  title="Minimum in $M (below = red, default 50M)",     group="ADV Thresholds",
  tooltip="Minimum average daily dollar volume. Below this threshold, stocks may trade erratically and lack institutional participation")
adv_warn = input.float(100, title="Warning in $M (below = orange, default 100M)", group="ADV Thresholds")

// --- ATR Multiple Thresholds ---
atr_warn_multi = input.float(8.0,  title="Warning Multiple (above = orange)", group="ATR Multiple Thresholds",
  tooltip="Price is becoming extended above the MA. Consider scaling out of positions above this level")
atr_max_multi  = input.float(10.0, title="Maximum Multiple (above = red)",    group="ATR Multiple Thresholds",
  tooltip="Price is significantly extended above the MA. Historically a zone where momentum slows or reverses")
atr_dot_multi  = input.float(10.0, title="Dot trigger (multiple threshold)",  group="ATR Multiple Thresholds",
  tooltip="A dot appears above the bar when the ATR multiple exceeds this level, signaling potential extension")

// --- Colors ---
col_green  = input.color(color.green,  title="Good color",         group="Colors")
col_orange = input.color(color.orange, title="Warning color",      group="Colors")
col_red    = input.color(color.red,    title="Bad color",          group="Colors")
col_atr    = input.color(color.blue,   title="ATR color (normal)", group="Colors")
col_dot    = input.color(color.yellow, title="Dot color",          group="Colors")

// --- Calculation functions (called inside request.security for correct daily-timeframe context) ---
f_adrp()         => 100.0 * (ta.sma(high / low, adrp_len) - 1.0)
f_adv()          => ta.sma(volume * close, adv_len)
f_atr_pct()      => (ta.atr(atr_len) / close) * 100
f_gain_from_ma() => ((close - ta.sma(close, ma_len)) / ta.sma(close, ma_len)) * 100

// --- Calculations (consolidated into a single request.security call for efficiency) ---
[adrp, adv_raw, atr_pct, gain_from_ma] = request.security(syminfo.tickerid, "D",
  [f_adrp(), f_adv(), f_atr_pct(), f_gain_from_ma()])

adv_m        = adv_raw / 1000000
atr_multiple = gain_from_ma / atr_pct

// --- Value Colors ---
adrp_col      = adrp < adr_min ? col_red : adrp < adr_warn_low ? col_orange : adrp > adr_max ? col_red : adrp > adr_warn_high ? col_orange : col_green
adv_col       = adv_m < adv_min ? col_red : adv_m < adv_warn ? col_orange : col_green
atr_multi_col = atr_multiple > atr_max_multi ? col_red : atr_multiple > atr_warn_multi ? col_orange : col_atr

// --- Font Size ---
get_size(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.normal

txt_size = get_size(font_size)

// --- Table Position ---
get_position(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

// --- Format ADV display ---
adv_display(val) =>
    val >= 1000.0 ?
      "$" + str.tostring(math.round(val / 100.0) / 10.0) + "B" :
      "$" + str.tostring(math.round(val * 10.0) / 10.0) + "M"

// --- Dynamic labels ---
adv_label_str = "ADV " + str.tostring(adv_len) + "D"

// --- Label/value spacing ---
label_pad = "    "    // trailing space on labels
value_pad = "    "    // leading space on values

// --- Extension Dot (price-anchored plot, scales correctly with chart panning) ---
dot_price = (show_dot and atr_multiple > atr_dot_multi) ? (high * (1.0 + dot_offset_pct / 100.0)) : na
plot(dot_price, title="Extension Dot", color=col_dot, style=plot.style_circles, linewidth=dot_width, offset=0)

// --- Timeframe visibility check ---
is_weekly_or_monthly = timeframe.period == "W" or timeframe.period == "M"
should_show = barstate.islast and (not is_weekly_or_monthly or show_on_weekly)

// --- Table ---
var table t = table.new(get_position(table_position), 2, 5, bgcolor=color.new(color.black, 100))

if should_show
    if show_empty_row
        table.cell(t, 0, 0, "", text_color=color.white, text_size=txt_size)
        table.cell(t, 1, 0, "", text_color=color.white, text_size=txt_size)
    if show_adrp
        table.cell(t, 0, 1, "ADR%" + label_pad,
          text_color=adrp_col, text_halign=text.align_left, text_size=txt_size)
        table.cell(t, 1, 1, value_pad + str.tostring(math.round(adrp * 100) / 100) + "%",
          text_color=adrp_col, text_halign=text.align_right, text_size=txt_size)
    if show_adv
        table.cell(t, 0, 2, adv_label_str + label_pad,
          text_color=adv_col, text_halign=text.align_left, text_size=txt_size)
        table.cell(t, 1, 2, value_pad + adv_display(adv_m),
          text_color=adv_col, text_halign=text.align_right, text_size=txt_size)
    if show_atr_multi
        table.cell(t, 0, 3, "ATR Multi" + label_pad,
          text_color=atr_multi_col, text_halign=text.align_left, text_size=txt_size)
        table.cell(t, 1, 3, value_pad + str.tostring(math.round(atr_multiple * 100) / 100),
          text_color=atr_multi_col, text_halign=text.align_right, text_size=txt_size)
    if show_atr_pct
        table.cell(t, 0, 4, "ATR%" + label_pad,
          text_color=col_atr, text_halign=text.align_left, text_size=txt_size)
        table.cell(t, 1, 4, value_pad + str.tostring(math.round(atr_pct * 100) / 100) + "%",
          text_color=col_atr, text_halign=text.align_right, text_size=txt_size)
````
