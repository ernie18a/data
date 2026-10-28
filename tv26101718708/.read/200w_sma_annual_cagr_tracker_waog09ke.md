# 200W SMA Annual CAGR Tracker

- url: https://www.tradingview.com/script/Waog09kE-200W-SMA-Annual-CAGR-Tracker/
- type: indicator
- pine_id: PUB;10edbb23e0fc4138a34c3ccef36c2364
- version: 1.0

## Description

A Pine Script indicator that calculates the annualized Compound Annual Growth Rate (CAGR) for either the weekly close price or the weekly 200-period Simple Moving Average (200W SMA). The script allows users to choose a custom lookback period expressed in years, months, or weeks, and it displays both the reference series and the computed CAGR as a chart label and an optional summary table.

Features:

Weekly reference series plotting:
200W SMA
Weekly close
Annual CAGR calculation over configurable lookback periods
Custom lookback unit: years, months, or weeks
Optional on-chart label with CAGR value
Optional table summary showing current value, past value, CAGR, and lookback duration
Use Case:
Ideal for long-term traders and investors who want a quick visual gauge of how the weekly trend or 200-week moving average has performed on an annualized basis. Great for comparing price momentum against a slow-moving trend benchmark.

How to Use:

Select the reference type: 200W or Weekly
Choose the lookback length and unit
Enable labels and/or the table for a cleaner visual summary
Apply to weekly or lower timeframes to view the weekly reference and CAGR overlay
Note:
This indicator uses historical weekly data with lookahead=barmerge.lookahead_off to avoid repainting.

## Source Code

````pine
//@version=6
indicator("200W SMA Annual CAGR Tracker", overlay=true, max_labels_count=500)

// --------- Inputs ---------
show_reference = input.bool(true, "Show Reference Plot")
reference_option = input.string("200W", "Reference", options=["200W", "Weekly"])
show_label = input.bool(true, "Show CAGR Label")
show_table = input.bool(true, "Show CAGR Table")
lookback_length = input.int(10, "Lookback length", minval=1, maxval=100)
lookback_unit = input.string("Years", "Lookback unit", options=["Years", "Months", "Weeks"])
source = input.source(close, "Source")

// --------- Weekly reference + CAGR ---------
calc_weekly_cagr(_source, _length, _lookback_length, _lookback_unit) =>
    int lookback_bars = _lookback_unit == "Years" ? _lookback_length * 52 :
         _lookback_unit == "Months" ? int(math.round(_lookback_length * 4.345238)) :
         _lookback_length
    float weekly_value = _length == 1 ? _source : ta.sma(_source, _length)
    float weekly_value_past = weekly_value[lookback_bars]
    float lookback_years = _lookback_unit == "Years" ? float(_lookback_length) :
         _lookback_unit == "Months" ? float(_lookback_length) / 12.0 :
         float(_lookback_length) / 52.0
    float annual_cagr = na(weekly_value_past) or lookback_years <= 0.0 ? na : math.pow(weekly_value / weekly_value_past, 1.0 / lookback_years) - 1.0
    [weekly_value, weekly_value_past, annual_cagr]

reference_length = reference_option == "200W" ? 200 : 1
reference_name = reference_option == "200W" ? "200W SMA" : "Weekly Close"
[ref_value, ref_value_past, cagr] = request.security(syminfo.tickerid, "W", calc_weekly_cagr(source, reference_length, lookback_length, lookback_unit), lookahead=barmerge.lookahead_off)

cagr_pct = na(cagr) ? na : cagr * 100

// --------- Plot ---------
plot(show_reference ? ref_value : na, title = "Weekly/200W Reference", color=color.orange, linewidth=2)

if show_label and barstate.islast
    label.new(
      bar_index,
      high,
      reference_name + " CAGR (" + str.tostring(lookback_length) + " " + lookback_unit + "): " + (na(cagr_pct) ? "n/a" : str.format("{0,number,0.00}%", cagr_pct)),
      xloc=xloc.bar_index,
      yloc=yloc.abovebar,
      color=color.new(color.blue, 80),
      textcolor=color.white,
      style=label.style_label_down)

// --------- Table ---------
var table cagr_table = na
if show_table and barstate.islast
    if na(cagr_table)
        cagr_table := table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 80), border_color=color.gray)

    table.cell(cagr_table, 0, 0, "Metric", bgcolor=color.new(color.blue, 70), text_color=color.white)
    table.cell(cagr_table, 1, 0, "Value", bgcolor=color.new(color.blue, 70), text_color=color.white)

    table.cell(cagr_table, 0, 1, "Current " + reference_name, text_color=color.white)
    table.cell(cagr_table, 1, 1, na(ref_value) ? "n/a" : str.format("{0,number,0.00}", ref_value), text_color=color.orange)

    table.cell(cagr_table, 0, 2, str.tostring(lookback_length) + " " + lookback_unit + " ago", text_color=color.white)
    table.cell(cagr_table, 1, 2, na(ref_value_past) ? "n/a" : str.format("{0,number,0.00}", ref_value_past), text_color=color.yellow)

    table.cell(cagr_table, 0, 3, "Annual CAGR", text_color=color.white)
    table.cell(cagr_table, 1, 3, na(cagr_pct) ? "n/a" : str.format("{0,number,0.00}%", cagr_pct), text_color=color.lime)

    table.cell(cagr_table, 0, 4, "Lookback duration", text_color=color.white)
    table.cell(cagr_table, 1, 4, str.tostring(lookback_length) + " " + lookback_unit, text_color=color.silver)

    table.cell(cagr_table, 0, 5, "Note", text_color=color.white)
    table.cell(cagr_table, 1, 5, "Uses weekly " + reference_name + " history", text_color=color.silver)
````
