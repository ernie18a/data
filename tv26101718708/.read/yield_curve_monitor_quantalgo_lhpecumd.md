# Yield Curve Monitor [QuantAlgo]

- url: https://www.tradingview.com/script/lhpeCUMD-Yield-Curve-Monitor-QuantAlgo/
- type: indicator
- pine_id: PUB;fcd35fa7e9224914b8961acde907a906
- version: 1.0

## Description

[b]🟢 Overview[/b]

The [b]Yield Curve Monitor[/b] is a macro dashboard that tracks the slope of the government bond yield curve through two widely followed spreads, the 10-year minus 2-year and the 10-year minus 3-month. It records each inversion’s length, the longest inversion on record, and the date and days since the curve last turned positive, while classifying each spread’s recent move as a bull or bear steepener or flattener. Whether you trade equities, bonds, or crypto, the indicator keeps both the state of the curve and the direction it is moving in view on any chart.
[image]https://www.tradingview.com/x/1WDqKr7r/[/image]
[b]🟢 What is the Yield Curve?[/b]

The yield curve plots government bond yields across maturities, from short-term bills to long-term bonds. In normal conditions longer maturities pay more than shorter ones, so the curve slopes upward and the spread between a long and a short yield is positive. When short-term yields rise above long-term yields, the spread turns negative and the curve is inverted, a condition widely watched as a warning sign for the economy. The 10-year minus 3-month spread is the measure behind the Federal Reserve Bank of New York’s yield curve recession model, while the 10-year minus 2-year spread is widely quoted in market commentary.

Beyond whether the curve is inverted, traders also read how it is moving. A steepener widens the spread and a flattener narrows it. Each is called bull when yields are falling and bear when yields are rising, since bond prices rise as yields fall. Together these form four regimes:

[b]1. Bull Steepener:[/b] Short-term yields fall faster than long-term yields.
[b]2. Bear Steepener:[/b] Long-term yields rise faster than short-term yields.
[b]3. Bull Flattener:[/b] Long-term yields fall faster than short-term yields.
[b]4. Bear Flattener:[/b] Short-term yields rise faster than long-term yields.
[image]https://www.tradingview.com/x/h5VImCT1/[/image]
[b]🟢 Key Features[/b]

[b]▶ Two Benchmark Spreads[/b]

Each spread is the 10-year yield minus a shorter tenor, multiplied by 100 to read in basis points. Plotted Spreads chooses what the pane draws:

[b]1. 10Y - 2Y[/b] draws the 10-year minus 2-year spread as columns, colored by whether the spread is positive or inverted.
[b]2. 10Y - 3M[/b] draws the 10-year minus 3-month spread as a line.
[b]3. Both[/b] draws the columns and the line together.

The yield inputs are set to US Treasuries and accept yield symbols from other countries, so the same monitor can follow another country’s curve. A 30-year yield sits in the dashboard beside the 10-year, so the far end of the curve reads alongside both spreads.
[image]https://www.tradingview.com/x/UtmhNTiV/[/image]
[b]▶ Curve Regime Classification[/b]

The Regime row reads each spread’s move over the Change Lookback, counted in daily sessions, so 21 covers about a month and 63 about a quarter. Steepening or flattening comes from whether the spread widened or narrowed over that span. Bull or bear comes from whether the average of its two yields fell or rose.

Regime Threshold sets the smallest spread change, in basis points, that registers as a regime. Anything smaller reads Neutral, so minor shifts do not show up as a change in direction. When the spread moves but the average yield holds unchanged, the row reads a plain Steepener or Flattener. Steepening regimes appear in the positive spread color and flattening regimes in the inverted color, with the size of the move shown in the Change row above.
[image]https://www.tradingview.com/x/CPD1Ic8S/[/image]
[b]▶ Inversion Tracking[/b]

An inversion begins on the first bar that closes with a spread below zero and ends on the first bar that closes with it back at zero or above. Its length is counted in calendar days between those two bars.

Each spread keeps its own record of the current inversion, the longest one in the loaded history, and the date the curve last turned positive along with the days that have passed since. This keeps both the start and the end of each cycle in view. Inversion shading tints the pane background while the plotted spread is below zero, so every inversion across the history stands out at a glance.
[image]https://www.tradingview.com/x/EbvMY9vw/[/image]
[b]▶ Curve Dashboard[/b]

The dashboard sets both spreads side by side in a single table that can be placed in any of nine positions.

[b]1. Spread:[/b] The current value in basis points, colored by its sign.
[b]2. Change: [/b]The move over the Change Lookback, with the session count shown in the row label.
[b]3. Regime:[/b] The current steepener or flattener reading, or Neutral.
[b]4. Status:[/b] Positive above zero, Flat at zero, and Inverted below zero.
[b]5. Days Inverted:[/b] The length of the inversion in progress.
[b]6. Longest Inversion (Days):[/b] The longest stretch below zero across the loaded history.
[b]7. Last Un-Inversion:[/b] The date the spread last returned to zero or above, followed by the days since in parentheses.
[b]8. Short Yields:[/b] The 2-year and 3-month yields, each placed under its own spread.
[b]9. Long Yields:[/b] The 10-year and 30-year yields.
[image]https://www.tradingview.com/x/Zs7kxPFo/[/image]
[b]▶ Built-in Alerts[/b]

Six ready-made alert conditions cover the key turns in both spreads under every Plotted Spreads setting. Each fires when a bar closes.

[b]1. 10Y - 2Y Inverted:[/b] Fires when the 10Y - 2Y spread closes below zero.
[b]2. 10Y - 2Y Un-Inverted:[/b] Fires when the 10Y - 2Y spread closes back at zero or above.
[b]3. 10Y - 3M Inverted:[/b] Fires when the 10Y - 3M spread closes below zero.
[b]4. 10Y - 3M Un-Inverted:[/b] Fires when the 10Y - 3M spread closes back at zero or above.
[b]5. 10Y - 2Y Regime Change:[/b] Fires when the 10Y - 2Y spread closes in a new regime.
[b]6. 10Y - 3M Regime Change:[/b] Fires when the 10Y - 3M spread closes in a new regime.
[image]https://www.tradingview.com/x/qXLZlHDN/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator("Yield Curve Monitor [QuantAlgo]", overlay = false, precision = 1)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string curve_settings  = "════════ Curve Settings ════════"
var string visual_settings = "════════ Visualization Settings ════════"

tooltip_long         = "Long tenor yield that forms the long leg of both spreads. Each spread is the 10-year yield minus a shorter tenor, multiplied by 100 to read in basis points, so it is positive while the curve slopes upward and negative while it is inverted. Every yield is read from the daily bars of its symbol, so on intraday charts the spreads step once per day, while on the live bar they follow the yields as they trade through the session. Yield symbols from another country can be entered here and in the tenors below to monitor that country's curve. When a symbol cannot be loaded, the figures built on it read n/a and its plots stay blank."
tooltip_short        = "Short tenor yield subtracted from the 10-year yield to form the 10Y - 2Y spread. The spread is positive while the 10-year yield sits above the 2-year yield and negative, an inverted curve, while it sits below. The yield itself is listed in the dashboard's Short Yields row under the 10Y - 2Y column."
tooltip_bill         = "Bill yield subtracted from the 10-year yield to form the 10Y - 3M spread, which spans the curve from its very front to the 10-year point. The spread is positive while the 10-year yield sits above the 3-month yield and negative, an inverted curve, while it sits below. The yield itself is listed in the dashboard's Short Yields row under the 10Y - 3M column."
tooltip_ultra        = "Long bond yield listed in the dashboard's Long Yields row beside the 10-year yield, so the far end of the curve reads alongside the two spreads. It does not enter either spread, the shading, or the alerts."
tooltip_mode         = "Which spreads are drawn in the pane, in basis points. 10Y - 2Y draws the 10-year minus 2-year spread as columns colored by whether the spread is positive or inverted. 10Y - 3M draws the 10-year minus 3-month spread as a line. Both draws the columns and the line together. The plotted spread, or the 10Y - 2Y spread when both are plotted, drives the inversion shading. The dashboard and every alert cover both spreads under every setting. The 10Y - 2Y Inverted and 10Y - 3M Inverted alerts fire when a chart bar closes with that spread below zero after it sat at zero or above, and the 10Y - 2Y Un-Inverted and 10Y - 3M Un-Inverted alerts fire when a chart bar closes with that spread back at zero or above."
tooltip_change       = "Number of daily sessions behind the Change and Regime rows in the dashboard. Change reads the current spread minus the spread that many sessions earlier, and Regime classifies that same move as set by Regime Threshold. Sessions count the trading days of the yield symbols, so 21 spans about one month, 63 about one quarter, and 252 about one year. A positive change means the spread has widened and the curve has steepened, while a negative change means the spread has narrowed and the curve has flattened. Shorter lookbacks (5-21) track recent repricing along the curve. Longer lookbacks (63-252) show the broader trend in its slope."
tooltip_regime       = "Minimum change in a spread over the Change Lookback, in basis points, for the Regime row to classify the move. A spread that widened by at least this much reads as a steepener, and one that narrowed by at least this much reads as a flattener. Each is labeled Bull when the average of its two yields fell over the same lookback and Bear when that average rose, and reads as a plain Steepener or Flattener when the average held unchanged. Bull and Bear describe bonds, whose prices rise as yields fall. A smaller move in the spread reads Neutral. Lower values (0-3) register every shift in slope, so the regime changes more often. Higher values (10-25) register only larger shifts, so the regime holds longer and reads Neutral more often. A chart bar that closes in a new regime fires the 10Y - 2Y Regime Change or 10Y - 3M Regime Change alert."
tooltip_color_preset = "Pre-configured color schemes for different chart themes and visual preferences. Classic uses traditional green and red. Aqua provides ocean-inspired blue and orange. Cosmic offers futuristic cyan and purple. Cyber features cool cyan and warm orange contrast. Neon delivers high-contrast yellow and magenta for maximum visibility. Each preset sets the positive and inverted spread colors, while Custom uses the Positive Spread Color and Inverted Spread Color set below. The 10Y - 3M Line Color applies under every preset."
tooltip_pos_color    = "Color applied to the 10Y - 2Y columns while the spread is zero or above, to the dashboard spread and status figures while a spread is positive, and to the Regime figure while a spread steepens. Use a vibrant color to highlight an upward sloping curve. Only used when Color Preset is set to Custom."
tooltip_inv_color    = "Color applied to the 10Y - 2Y columns while the spread is below zero, to the dashboard spread and status figures while a spread is inverted, to the Regime figure while a spread flattens, and to the inversion shading. Use a warning color to highlight an inverted curve. Only used when Color Preset is set to Custom."
tooltip_line_color   = "Color applied to the 10Y - 3M spread line. It applies under every Color Preset, so the line keeps one consistent color while the columns, shading, and dashboard figures follow the preset."
tooltip_shade        = "Enable/disable tinting the pane background in the inverted spread color while the plotted spread is below zero, or the 10Y - 2Y spread when both are plotted, so every inversion across the chart history stands out at a glance. Disable for a cleaner pane that relies on the columns, line, and dashboard."
tooltip_dashboard    = "Enable/disable the dashboard, which lists for each spread its current value in basis points, its change and regime over the Change Lookback, its status, how many days the current inversion has lasted, its longest inversion, and the date of its last un-inversion with the calendar days since, followed by the four yields. Status reads Positive above zero, Flat at zero, and Inverted below zero. An inversion begins on the first chart bar that closes with the spread below zero and ends on the first bar that closes with it at zero or above, and its length is counted in calendar days between those bars, so it resolves to the day on daily and lower timeframes. Longest Inversion includes the current inversion while it lasts. The inversion figures cover the chart history loaded, so an inversion already underway on the first loaded bar is counted from that bar, and charts that load more years of history capture more past inversions."
tooltip_dash_pos     = "Position in the pane where the dashboard is anchored, covering every corner, the middle of each edge, and the center. Tables from other indicators placed at the same position overlap with it. Only applies when Show Dashboard is turned on."
tooltip_text_size    = "Text size for every row and figure in the dashboard. Tiny and Small keep it compact beside the spreads, while Normal and Large suit presentation and screen recording. Only applies when Show Dashboard is turned on."

string longInput        = input.symbol("TVC:US10Y", "10-Year Yield", group = curve_settings, tooltip = tooltip_long)
string shortInput       = input.symbol("TVC:US02Y", "2-Year Yield", group = curve_settings, tooltip = tooltip_short)
string billInput        = input.symbol("TVC:US03MY", "3-Month Yield", group = curve_settings, tooltip = tooltip_bill)
string ultraInput       = input.symbol("TVC:US30Y", "30-Year Yield", group = curve_settings, tooltip = tooltip_ultra)
string modeInput        = input.string("Both", "Plotted Spreads", group = curve_settings, options = ["10Y - 2Y", "10Y - 3M", "Both"], tooltip = tooltip_mode)
int chgLenInput         = input.int(21, "Change Lookback", group = curve_settings, minval = 1, maxval = 1000, tooltip = tooltip_change)
float regimeThrInput    = input.float(5.0, "Regime Threshold (bps)", group = curve_settings, minval = 0.0, step = 0.5, tooltip = tooltip_regime)

string colorPreset      = input.string("Custom", "Color Preset", group = visual_settings, options = ["Custom", "Classic", "Aqua", "Cosmic", "Cyber", "Neon"], tooltip = tooltip_color_preset)
color posColorInput     = input.color(#00ffaa, "Positive Spread Color", group = visual_settings, tooltip = tooltip_pos_color)
color invColorInput     = input.color(#ff0000, "Inverted Spread Color", group = visual_settings, tooltip = tooltip_inv_color)
color lineColorInput    = input.color(#f0b90b, "10Y - 3M Line Color", group = visual_settings, tooltip = tooltip_line_color)
bool shadeInput         = input.bool(true, "Show Inversion Shading", group = visual_settings, tooltip = tooltip_shade)
bool tableInput         = input.bool(true, "Show Dashboard", group = visual_settings, tooltip = tooltip_dashboard)
string tablePosInput    = input.string("Bottom Right", "Dashboard Position", group = visual_settings, options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip = tooltip_dash_pos)
string textSizeInput    = input.string("Small", "Text Size", group = visual_settings, options = ["Tiny", "Small", "Normal", "Large"], tooltip = tooltip_text_size)

//              ╔════════════════════════════════╗              //
//              ║      PRESET CONFIGURATION      ║              //
//              ╚════════════════════════════════╝              //

[posCol, invCol] = switch colorPreset
    "Classic" => [#00ff00, #ff0000]
    "Aqua" => [#00d4ff, #ff8c00]
    "Cosmic" => [#49ffce, #9932cc]
    "Cyber" => [#00cccc, #ff6600]
    "Neon" => [#ffff00, #ff00ff]
    => [posColorInput, invColorInput]

string textSize = switch textSizeInput
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

//              ╔════════════════════════════════╗              //
//              ║          SPREAD ENGINE         ║              //
//              ╚════════════════════════════════╝              //

[yLong, yLongPast]   = request.security(longInput, "D", [close, close[chgLenInput]], ignore_invalid_symbol = true)
[yShort, yShortPast] = request.security(shortInput, "D", [close, close[chgLenInput]], ignore_invalid_symbol = true)
[yBill, yBillPast]   = request.security(billInput, "D", [close, close[chgLenInput]], ignore_invalid_symbol = true)
float yUltra         = request.security(ultraInput, "D", close, ignore_invalid_symbol = true)

float spread2y = (yLong - yShort) * 100.0
float spread3m = (yLong - yBill) * 100.0
float change2y = spread2y - (yLongPast - yShortPast) * 100.0
float change3m = spread3m - (yLongPast - yBillPast) * 100.0
float level2y  = ((yLong - yLongPast) + (yShort - yShortPast)) * 50.0
float level3m  = ((yLong - yLongPast) + (yBill - yBillPast)) * 50.0

//              ╔════════════════════════════════╗              //
//              ║          REGIME ENGINE         ║              //
//              ╚════════════════════════════════╝              //

regimeCode(float chg, float lvl) =>
    float c  = math.round(chg, 2)
    float l  = math.round(lvl, 2)
    int code = na
    if not na(c) and not na(l)
        code := math.abs(c) < regimeThrInput or c == 0 ? 0 : (c > 0 ? 1 : 4) + (l < 0 ? 0 : l > 0 ? 1 : 2)
    code

int regime2y = regimeCode(change2y, level2y)
int regime3m = regimeCode(change3m, level3m)

//              ╔════════════════════════════════╗              //
//              ║        INVERSION ENGINE        ║              //
//              ╚════════════════════════════════╝              //

inversionState(float spread) =>
    var int startTime = na
    var float longest = 0.0
    var int lastExit  = na
    bool began        = false
    bool ended        = false
    if spread < 0 and na(startTime)
        startTime := time
        began     := true
    else if spread >= 0 and not na(startTime)
        longest   := math.max(longest, (time - startTime) / 86400000.0)
        lastExit  := time
        startTime := na
        ended     := true
    float current = na(startTime) ? 0.0 : (time - startTime) / 86400000.0
    [current, math.max(longest, current), lastExit, began, ended]

[days2y, longest2y, exitTime2y, enter2y, exit2y] = inversionState(spread2y)
[days3m, longest3m, exitTime3m, enter3m, exit3m] = inversionState(spread3m)

//              ╔════════════════════════════════╗              //
//              ║          VISUALIZATION         ║              //
//              ╚════════════════════════════════╝              //

float shadeSpread = modeInput == "10Y - 3M" ? spread3m : spread2y

plot(modeInput != "10Y - 3M" ? spread2y : na, "10Y - 2Y Spread (bps)", color.new(spread2y < 0 ? invCol : posCol, 30), style = plot.style_columns)
plot(modeInput != "10Y - 2Y" ? spread3m : na, "10Y - 3M Spread (bps)", lineColorInput, 2)
hline(0.0, "Zero Line", color.new(chart.fg_color, 50), hline.style_solid)
bgcolor(shadeInput and shadeSpread < 0 ? color.new(invCol, 88) : na, title = "Inversion Shading")

//              ╔════════════════════════════════╗              //
//              ║            DASHBOARD           ║              //
//              ╚════════════════════════════════╝              //

fmtBps(float v) =>
    float r = math.round(v, 2)
    na(v) ? "n/a" : (r > 0 ? "+" : "") + str.tostring(r == 0 ? 0.0 : r, "0.0#") + " bps"

fmtYield(float v) =>
    na(v) ? "n/a" : str.tostring(v, "0.000") + "%"

fmtDays(float d, float spread) =>
    na(spread) ? "n/a" : str.tostring(math.round(d))

fmtDate(int t, float spread) =>
    na(spread) ? "n/a" : na(t) ? "None" : str.format_time(t, "dd MMM yyyy", syminfo.timezone) + " (" + str.tostring(math.round((time - t) / 86400000.0)) + "d)"

statusText(float v) =>
    na(v) ? "n/a" : v < 0 ? "Inverted" : v > 0 ? "Positive" : "Flat"

statusColor(float v) =>
    v < 0 ? invCol : v > 0 ? posCol : chart.fg_color

regimeText(int code) =>
    switch code
        0 => "Neutral"
        1 => "Bull Steepener"
        2 => "Bear Steepener"
        3 => "Steepener"
        4 => "Bull Flattener"
        5 => "Bear Flattener"
        6 => "Flattener"
        => "n/a"

regimeColor(int code) =>
    code >= 1 and code <= 3 ? posCol : code >= 4 ? invCol : chart.fg_color

string tablePos = switch tablePosInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_right

color hdrBg  = color.new(chart.fg_color, 85)
color cellBg = color.new(chart.bg_color, 10)
color txt    = chart.fg_color

var table dash = tableInput ? table.new(tablePos, 3, 10, border_width = 1, border_color = color.new(chart.fg_color, 85), frame_width = 1, frame_color = color.new(chart.fg_color, 70)) : na

if barstate.islast and not na(dash)
    table.cell(dash, 0, 0, "Yield Curve", text_color = txt, bgcolor = hdrBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 0, "10Y - 2Y", text_color = txt, bgcolor = hdrBg, text_size = textSize)
    table.cell(dash, 2, 0, "10Y - 3M", text_color = txt, bgcolor = hdrBg, text_size = textSize)
    table.cell(dash, 0, 1, "Spread", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 1, fmtBps(spread2y), text_color = statusColor(spread2y), bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 2, 1, fmtBps(spread3m), text_color = statusColor(spread3m), bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 2, "Change (" + str.tostring(chgLenInput) + " Sessions)", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 2, fmtBps(change2y), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 2, 2, fmtBps(change3m), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 3, "Regime", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 3, regimeText(regime2y), text_color = regimeColor(regime2y), bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 2, 3, regimeText(regime3m), text_color = regimeColor(regime3m), bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 4, "Status", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 4, statusText(spread2y), text_color = statusColor(spread2y), bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 2, 4, statusText(spread3m), text_color = statusColor(spread3m), bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 5, "Days Inverted", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 5, fmtDays(days2y, spread2y), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 2, 5, fmtDays(days3m, spread3m), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 6, "Longest Inversion (Days)", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 6, fmtDays(longest2y, spread2y), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 2, 6, fmtDays(longest3m, spread3m), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 7, "Last Un-Inversion", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 7, fmtDate(exitTime2y, spread2y), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 2, 7, fmtDate(exitTime3m, spread3m), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 8, "Short Yields", text_color = txt, bgcolor = hdrBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 8, "2Y " + fmtYield(yShort), text_color = txt, bgcolor = hdrBg, text_size = textSize)
    table.cell(dash, 2, 8, "3M " + fmtYield(yBill), text_color = txt, bgcolor = hdrBg, text_size = textSize)
    table.cell(dash, 0, 9, "Long Yields", text_color = txt, bgcolor = hdrBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 9, "10Y " + fmtYield(yLong), text_color = txt, bgcolor = hdrBg, text_size = textSize)
    table.cell(dash, 2, 9, "30Y " + fmtYield(yUltra), text_color = txt, bgcolor = hdrBg, text_size = textSize)

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

bool inverts2y   = barstate.isconfirmed and enter2y
bool uninverts2y = barstate.isconfirmed and exit2y
bool inverts3m   = barstate.isconfirmed and enter3m
bool uninverts3m = barstate.isconfirmed and exit3m
bool regimeChg2y = barstate.isconfirmed and not na(regime2y) and not na(regime2y[1]) and regime2y != regime2y[1]
bool regimeChg3m = barstate.isconfirmed and not na(regime3m) and not na(regime3m[1]) and regime3m != regime3m[1]

alertcondition(inverts2y, title = "10Y - 2Y Inverted", message = "Yield Curve Monitor: 10Y - 2Y spread INVERTED as it closed below zero - {{interval}}")
alertcondition(uninverts2y, title = "10Y - 2Y Un-Inverted", message = "Yield Curve Monitor: 10Y - 2Y spread UN-INVERTED as it closed at or above zero - {{interval}}")
alertcondition(inverts3m, title = "10Y - 3M Inverted", message = "Yield Curve Monitor: 10Y - 3M spread INVERTED as it closed below zero - {{interval}}")
alertcondition(uninverts3m, title = "10Y - 3M Un-Inverted", message = "Yield Curve Monitor: 10Y - 3M spread UN-INVERTED as it closed at or above zero - {{interval}}")
alertcondition(regimeChg2y, title = "10Y - 2Y Regime Change", message = "Yield Curve Monitor: 10Y - 2Y curve regime CHANGED as a bar closed in a new regime - {{interval}}")
alertcondition(regimeChg3m, title = "10Y - 3M Regime Change", message = "Yield Curve Monitor: 10Y - 3M curve regime CHANGED as a bar closed in a new regime - {{interval}}")

//              ╔════════════════════════════════╗              //
//              ║           CREATED BY           ║              //
//              ╚════════════════════════════════╝              //

// ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗     █████╗ ██╗      ██████╗  ██████╗ 
//██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝    ██╔══██╗██║     ██╔════╝ ██╔═══██╗
//██║   ██║██║   ██║███████║██╔██╗ ██║   ██║       ███████║██║     ██║  ███╗██║   ██║
//██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║       ██╔══██║██║     ██║   ██║██║   ██║
//╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║       ██║  ██║███████╗╚██████╔╝╚██████╔╝
// ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
````
