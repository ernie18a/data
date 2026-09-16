<!-- tradingview-pine-id: PUB;22cdcd5d555e44578dda88d3ac768236 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Interest Rate Differential & Comparison

Source: https://www.tradingview.com/script/3NhPypxj/

## Description

This indicator compares 10-year government bond yields and yield differentials for six major FX currency pairs.

Supported pairs:
• USDJPY — US10Y / JP10Y
• EURJPY — DE10Y / JP10Y
• GBPJPY — GB10Y / JP10Y
• AUDJPY — AU10Y / JP10Y
• CHFJPY — CH10Y / JP10Y
• EURUSD — DE10Y / US10Y

## Modes

Base
Displays the base currency's 10-year government bond yield.

Counter
Displays the counter currency's 10-year government bond yield.

Differential
Displays the difference between the base and counter yields.

Both
Displays both yields using their original values.

Shifted
Shifts the counter yield vertically by a fixed amount to make the movements of the two yields easier to compare visually.

The Shift value is for visualization only. It does not represent the actual interest-rate differential.

All-diffs
Displays the current 10-year yield differential for all supported currency pairs.

This mode is also useful when adjusting the pair-specific Shift values. You can view the current differential for all pairs while adjusting the Shift settings in the indicator's Inputs.

## Examples
Shifted mode:
[image]https://www.tradingview.com/x/tXnVJuRs/[/image]

All-diffs mode:
[image]https://www.tradingview.com/x/DPndAgqD/[/image]

## Data

The indicator uses TradingView's 10-year government bond yield symbols:
US10Y, DE10Y, GB10Y, AU10Y, CH10Y and JP10Y.

Data availability and update frequency depend on the underlying TradingView symbols.

## Credits

Based on the open-source script "Interest Rate Differential" by wcapucci89.

This version substantially extends the original script with automatic FX pair detection, support for six currency pairs, shifted yield comparison, pair-specific Shift settings, and an all-pair differential view.

## Disclaimer

This indicator is intended for visual analysis and comparison of interest rates. It is not a trading signal and does not provide investment advice.

---

## Source Code

````pine
//@version=6
//last update: 2026/08/23 15:03

indicator('Interest Rate Differential & Comparison', overlay = false)

mode = input.string(defval= "base", title= "mode", options= ["base", "counter", "differential", "both", "shifted", "all-diffs"])
y_offset_USDJPY = input.float(defval= 1.8, title= "y_offset_USDJPY", step= 0.02)
y_offset_EURJPY = input.float(defval= 0.34, title= "y_offset_EURJPY", step= 0.02)
y_offset_GBPJPY = input.float(defval= 2.16, title= "y_offset_GBPJPY", step= 0.02)
y_offset_AUDJPY = input.float(defval= 2.12, title= "y_offset_AUDJPY", step= 0.02)
y_offset_CHFJPY = input.float(defval= -2.46, title= "y_offset_CHFJPY", step= 0.02)
y_offset_EURUSD = input.float(defval= -1.44, title= "y_offset_EURUSD", step= 0.02)

res = input.timeframe(defval = "", title = "Interest Rate Timeframe", tooltip = "Timeframe used for the government bond yield data.")

base_color = input.color(color.new(color.blue, 0), "Base color", group="Color")
counter_color = input.color(color.new(color.red, 0), "Counter color", group="Color")
differential_color = input.color(color.new(color.purple, 0), "Differential color", group="Color")
table_text_color = input.color(color.new(color.black, 0), "Table text color", group="Color")

// ─────────────────────────────
// Get yields
// ─────────────────────────────
us10y = request.security("TVC:US10Y", res, close)
de10y = request.security("TVC:DE10Y", res, close)
gb10y = request.security("TVC:GB10Y", res, close)
au10y = request.security("TVC:AU10Y", res, close)
ch10y = request.security("TVC:CH10Y", res, close)
jp10y = request.security("TVC:JP10Y", res, close)

[base, counter, base_name, counter_name] = switch syminfo.ticker
    "USDJPY" => [us10y, jp10y, "US10Y", "JP10Y"]
    "EURJPY" => [de10y, jp10y, "DE10Y", "JP10Y"]
    "GBPJPY" => [gb10y, jp10y, "GB10Y", "JP10Y"]
    "CHFJPY" => [ch10y, jp10y, "CH10Y", "JP10Y"]
    "AUDJPY" => [au10y, jp10y, "AU10Y", "JP10Y"]
    "EURUSD" => [de10y, us10y, "DE10Y", "US10Y"]
    => [na, na, "", ""]

y_offset = switch syminfo.ticker
    "USDJPY" => y_offset_USDJPY
    "EURJPY" => y_offset_EURJPY
    "GBPJPY" => y_offset_GBPJPY
    "CHFJPY" => y_offset_CHFJPY
    "AUDJPY" => y_offset_AUDJPY
    "EURUSD" => y_offset_EURUSD

// ─────────────────────────────
// Calculate differential
// ─────────────────────────────
differential = base - counter

usd_jpy_diff = us10y - jp10y
eur_jpy_diff = de10y - jp10y
gbp_jpy_diff = gb10y - jp10y
aud_jpy_diff = au10y - jp10y
chf_jpy_diff = ch10y - jp10y
eur_usd_diff = de10y - us10y

plot(base, title = 'base', color = base_color, linewidth = 2, display = (mode == "base" or mode == "both" or mode == "shifted") ? display.all : display.none)
plot(counter, title = 'counter', color = counter_color, linewidth = 2, display = (mode == "counter" or mode == "both") ? display.all : display.none)
plot(differential, title = 'differential', color = differential_color, linewidth = 2, display = (mode == "differential" ? display.all : display.none))

plot(counter + y_offset, title="shifted counter", color=counter_color, linewidth=2, display=(mode == "shifted") ? display.all : display.none)

// ─────────────────────────────
// Shifted mode
// ─────────────────────────────
var table legend = table.new(
     position.bottom_right,
     2,
     3,
     bgcolor = color.new(color.white, 100))

if barstate.islast

    if mode == "shifted"

        table.cell(
             legend, 0, 0,
             "━━",
             text_color = base_color,
             text_size = size.small)

        table.cell(
             legend, 1, 0,
             base_name,
             text_color = base_color,
             text_size = size.small)

        table.cell(
             legend, 0, 1,
             "Differential",
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             legend, 1, 1,
             str.tostring(differential, "#.##")+'%',
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             legend, 0, 2,
             "━━",
             text_color = counter_color,
             text_size = size.small)

        table.cell(
             legend, 1, 2,
             counter_name + " + " + str.tostring(y_offset, "#.##"),
             text_color = counter_color,
             text_size = size.small)

    else

        table.clear(legend, 0, 0, 1, 2)

// ─────────────────────────────
// All-diffs mode
// ─────────────────────────────
var table all_diffs = table.new(
     position.middle_right,
     2,
     7,
     bgcolor = color.new(color.white, 100))

if barstate.islast

    if mode == "all-diffs"

        table.cell(
            all_diffs, 0, 0,
            "Pair",
            text_color = table_text_color,
            text_size = size.small)

        table.cell(
            all_diffs, 1, 0,
            "Differential",
            text_color = table_text_color,
            text_size = size.small)

        table.cell(
             all_diffs, 0, 1,
             "USDJPY",
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 1, 1,
             str.tostring(usd_jpy_diff, "#.##")+'%',
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 0, 2,
             "EURJPY",
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 1, 2,
             str.tostring(eur_jpy_diff, "#.##")+'%',
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 0, 3,
             "GBPJPY",
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 1, 3,
             str.tostring(gbp_jpy_diff, "#.##")+'%',
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 0, 4,
             "AUDJPY",
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 1, 4,
             str.tostring(aud_jpy_diff, "#.##")+'%',
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 0, 5,
             "CHFJPY",
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 1, 5,
             str.tostring(chf_jpy_diff, "#.##")+'%',
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 0, 6,
             "EURUSD",
             text_color = table_text_color,
             text_size = size.small)

        table.cell(
             all_diffs, 1, 6,
             str.tostring(eur_usd_diff, "#.##")+'%',
             text_color = table_text_color,
             text_size = size.small)

    else

        table.clear(all_diffs, 0, 0, 1, 6)
````
