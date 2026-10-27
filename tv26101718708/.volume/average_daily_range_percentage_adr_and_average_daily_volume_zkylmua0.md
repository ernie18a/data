# Average Daily Range Percentage (ADR%) and Average Daily Volume

- url: https://www.tradingview.com/script/zKYLmuA0-Average-Daily-Range-Percentage-ADR-and-Average-Daily-Volume/
- type: indicator
- pine_id: PUB;731ec7afa4ed492d985f698c705fad3f
- version: 1.0

## Description

[b]Two critical pre-trade filters, always visible right on your chart.[/b]

Before entering any swing trade, you need to know two things: is this stock volatile enough to move your account, and is it liquid enough to trade cleanly? This indicator answers both questions at a glance.

**ADR% (Average Daily Range)** measures how much a stock moves on an average day. Too low and it won't move your portfolio. Too high and the daily noise will stop you out randomly. The color tells you where you stand instantly.

**ADV (Average Dollar Volume)** measures how much money flows through the stock each day. Liquid stocks respect key levels, pull back cleanly to moving averages, and don't gap randomly on low volume. Illiquid stocks do the opposite.

[b]Both values are color-coded against your thresholds:[/b]
[list]
[*]🟢 Green — within your ideal range
[*]🟠 Orange — borderline, proceed with caution
[*]🔴 Red — outside your criteria, skip it
[*]
[/list]
[b]Fully customizable:[/b]
[list]
[*]ADR% and ADV thresholds
[*]Warning zones for borderline values
[*]Lookback periods for both calculations
[*]Colors for good, warning, and bad values
[*]
[/list]

[b]Default thresholds[/b] are calibrated for swing traders. Adjust to match your account size and risk tolerance.

Built for swing traders who want clean, fast chart reviews without second-guessing liquidity or volatility on every name.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vinthomas
// Based on original work by ArmerSchlucker
// Credit to MikeC / TheScrutiniser and GlinckEastwoot for ADR% formula

//@version=5

indicator(title="Average Daily Range Percentage (ADR%) and Average Daily Volume", shorttitle="ADR/ADV", overlay=true)

// --- Inputs ---
show_adrp      = input.bool(true,  title="Show ADR%",                 group="Display")
show_adv       = input.bool(true,  title="Show Avg Dollar Volume",     group="Display")
show_empty_row = input.bool(true,  title="Add empty row above values", group="Display",
  tooltip="Prevents pane icons from overlapping with the table text when multiple panes are shown")
font_size      = input.string("normal", title="Font Size",             group="Display",
  options=["tiny", "small", "normal", "large", "huge"])

// --- Lengths ---
adrp_len = input.int(20, title="ADR% Length",              group="Lengths",
  tooltip="Number of daily bars used in ADR% calculation")
adv_len  = input.int(20, title="Avg Dollar Volume Length", group="Lengths",
  tooltip="Number of daily bars used in Avg Dollar Volume calculation")

// --- ADR% Thresholds ---
adr_min       = input.float(4.0, title="Minimum (below = red)",        group="ADR% Thresholds")
adr_warn_low  = input.float(5.0, title="Warning Low (below = orange)",  group="ADR% Thresholds")
adr_warn_high = input.float(8.0, title="Warning High (above = orange)", group="ADR% Thresholds")
adr_max       = input.float(9.0, title="Maximum (above = red)",         group="ADR% Thresholds")

// --- ADV Thresholds ---
adv_min  = input.float(50,  title="Minimum in $M (below = red, default 50M)",     group="ADV Thresholds")
adv_warn = input.float(100, title="Warning in $M (below = orange, default 100M)", group="ADV Thresholds")

// --- Colors ---
col_green  = input.color(color.green,  title="Good color",    group="Colors")
col_orange = input.color(color.orange, title="Warning color", group="Colors")
col_red    = input.color(color.red,    title="Bad color",     group="Colors")

// --- Calculations ---
arp  = 100.0 * (ta.sma(high / low, adrp_len) - 1.0)
adrp = request.security(syminfo.tickerid, 'D', arp)
adv  = request.security(syminfo.tickerid, 'D', ta.sma(volume * close, adv_len))
adv_m = adv / 1000000

// --- Value Colors ---
adrp_col = adrp < adr_min ? col_red : adrp < adr_warn_low ? col_orange : adrp > adr_max ? col_red : adrp > adr_warn_high ? col_orange : col_green
adv_col  = adv_m < adv_min ? col_red : adv_m < adv_warn ? col_orange : col_green

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

// --- Format ADV display ---
adv_display(val) =>
    val >= 1000.0 ?
      "$" + str.tostring(math.round(val / 100.0) / 10.0) + "B" :
      "$" + str.tostring(math.round(val * 10.0) / 10.0) + "M"

// --- Dynamic label ---
adv_label_str = "ADV " + str.tostring(adv_len) + "D"

// --- Table ---
var table t = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 100))

if barstate.islast and timeframe.period != "W" and timeframe.period != "M"
    if show_empty_row
        table.cell(t, 0, 0, "", text_color=color.white, text_size=txt_size)
        table.cell(t, 1, 0, "", text_color=color.white, text_size=txt_size)
    if show_adrp
        table.cell(t, 0, 1, "ADR%",
          text_color=adrp_col, text_halign=text.align_left, text_size=txt_size)
        table.cell(t, 1, 1, str.tostring(math.round(adrp * 100) / 100) + "%",
          text_color=adrp_col, text_halign=text.align_right, text_size=txt_size)
    if show_adv
        table.cell(t, 0, 2, adv_label_str,
          text_color=adv_col, text_halign=text.align_left, text_size=txt_size)
        table.cell(t, 1, 2, adv_display(adv_m),
          text_color=adv_col, text_halign=text.align_right, text_size=txt_size)
````
