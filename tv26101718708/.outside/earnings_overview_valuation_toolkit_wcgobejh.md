# Earnings Overview & Valuation Toolkit

- url: https://www.tradingview.com/script/WCGoBeJh-Earnings-Overview-Valuation-Toolkit/
- type: indicator
- pine_id: PUB;ca8576e6e310424c9aa0b38c5e82e0af
- version: 1.0

## Description

[b]Earnings Overview & Valuation Toolkit[/b]

Understanding how corporate earnings impact a stock’s price is one of the most critical challenges for stock traders and investors. The [b]Earnings Overview & Valuation Toolkit[/b] is a comprehensive, institutional-grade analysis suite designed to combine macro fundamental valuation, historical announcement reaction patterns, and forward-looking volatility forecasting into a single, unified indicator.

By utilizing the latest Pine Script® v6 [pine]force_overlay[/pine] capabilities, this toolkit runs in a separate sub-panel to display clean percentage-based metrics (like earnings surprises and price reactions), while simultaneously overlaying price-based valuation bands, volatility cones, and a statistical dashboard directly onto the main price chart.

[image]https://www.tradingview.com/x/8A02RExv/[/image]


[b]Key Features & Components[/b]

[list] [*] [b]Dynamic P/E Valuation Bands (Main Chart Overlay)[/b] Instead of static valuation lines, this component tracks the company's Trailing Twelve Month (TTM) EPS and projects historical valuation multiples onto the chart. It calculates the [i]10th percentile[/i] (Undervalued), [i]50th percentile[/i] (Median/Fair Value), and [i]90th percentile[/i] (Overvalued) P/E ratios over a rolling lookback window (default: 500 bars). The zones are color-coded in soft green and red to help you immediately identify when a stock like 
 [symbol="NASDAQ:AAPL"]NASDAQ:AAPL[/symbol] or [symbol="NASDAQ:NVDA"]NASDAQ:NVDA[/symbol] is entering a historical discount or premium zone.

[*] [b]Earnings Surprise & Price Reaction Tracker (Sub-Pane)[/b] This panel analyzes analyst bias and the subsequent market response.

[b]Earnings Surprise Column[/b]: Plots the percentage beat (green) or miss (red) compared to consensus analyst estimates.
[b]Reaction Dot[/b]: Calculates the percentage price change over a configurable window (default: 5 bars) post-earnings. A negative offset is applied so that this dot aligns [i]directly above or below[/i] the earnings column on the day of the release, helping you visually correlate the surprise with the subsequent momentum.
[*] [b]Catalyst Countdown & Volatility Predictor (Main Chart Overlay)[/b] To protect you from binary earnings day risk, this tool pulls the upcoming expected earnings date ([pine]earnings.future_time[/pine]) and projects a [b]dynamic Volatility Cone[/b] directly onto the chart starting from the last candle. The boundaries of the cone represent the expected trading range on the release day, calculated using the absolute average return from the last 8 earnings releases.

[*] [b]Unified Stats Dashboard (Main Chart Table)[/b] A clean, real-time table anchored to the top-right of your main chart that consolidates:

Trailing Twelve Months (TTM) EPS & Latest Reported EPS.
Current P/E multiple relative to price.
Dynamic Valuation Status ("Undervalued", "Fair Value", "Overvalued").
Average Earnings Day Move % and the Volatility Multiplier compared to standard daily ATR (e.g. "2.5x normal daily volatility").
Consensus Analyst Estimates for the next quarter (EPS and formatted Revenue).
Next Earnings Release Date and countdown (days/hours). [/list]
[image]https://www.tradingview.com/x/5c4i06Qs/[/image]


[b]How to Use this Toolkit Profitably[/b]

[list=1] [*] [b]The Post-Earnings Announcement Drift (PEAD) Strategy[/b] Scan for stocks that have reported earnings in the last 1 to 5 days. Look for a [b]positive surprise[/b] (green column) paired with a [b]positive price reaction[/b] (green dot). If the stock is currently trading [b]below its orange Median PE Band[/b], this confirms institutional buying momentum with a margin of safety. Hold for 2 to 4 weeks, placing your stop-loss below the low of the earnings day candle.

[*] [b]The Pre-Earnings Volatility Ride[/b] Scan for stocks with an upcoming earnings countdown of 7 to 10 days. Verify they have a strong track record of beating earnings (high 8-quarter average surprise) and a high Volatility Multiplier (e.g. >1.5x normal ATR). Buy the Call/Put option contract expiring the week after earnings to capture rising Implied Volatility (IV) and price run-up. [b]Crucial Rule:[/b] Sell to close the contract the afternoon before the release to capture the maximum IV peak and avoid the overnight gap and IV crush.

[*] [b]The Macro Value Rebound[/b] For long-term investors, monitor your watchlist for high-quality, profitable companies whose stock prices fall to or below the green [b]Undervalued Band[/b]. Wait for a technical reversal or a positive earnings reaction dot to confirm a floor, and buy shares or long-dated LEAP options to ride the reversion back to the orange Median and red Overvalued bands. [/list]
[image]https://www.tradingview.com/x/5k6DM8RN/[/image]

[b]Indicator Inputs & Customization[/b]

The toolkit is designed to be highly customizable to fit your trading style: [list] [*] [b]Reaction Window (Bars)[/b]: Change the length of time used to measure the post-earnings price impact. [*] [b]Max Surprise Clamp %[/b]: Caps extreme surprise % columns to keep the sub-pane scale readable. [*] [b]P/E Lookback (Bars)[/b]: Adjust the length of history used to compute valuation percentiles. [*] [b]Show Volatility Cone[/b]: Toggle the dynamic future projection lines and box on/off. [*] [b]Color Customization[/b]: Easily match the bands, fills, and columns to your light or dark chart theme. [/list]

[i]Disclaimer: Corporate earnings data is subject to reporting schedules and analyst revisions. Always practice proper risk management and size your option plays according to your account size. Past performance does not guarantee future results.[/i]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Antigravity / Capital Coders LLC

//@version=6
indicator("Earnings Overview & Valuation Toolkit", shorttitle="Earnings Overview", overlay=false, format=format.percent)

//#region[Tooltips]
var reactionWindowTT  = "The number of trading bars after the earnings release to measure the price percentage change (reaction)."
var clampTT           = "Clamps the visual surprise percentage to prevent massive outliers from flattening the rest of the chart."
var offsetReactionTT  = "Visually offsets the price reaction dot so that it aligns directly above/below the earnings column on the day of the release."
var lookbackTT        = "The number of trading bars used to calculate historical P/E ratio percentiles."
var lowPctTT          = "The percentile representing the undervalued limit. The multiplier of TTM EPS at this percentile determines the lower green band."
var highPctTT         = "The percentile representing the overvalued limit. The multiplier of TTM EPS at this percentile determines the upper red band."
var volLookbackTT     = "The number of previous earnings events to analyze for calculating average earnings day price moves."
var showConeTT        = "Draws a dynamic volatility projection cone/box starting from the current close price to the expected next earnings date on the main chart."
var showTableTT       = "Displays a consolidated statistical summary table in the top-right corner of the main chart."
//#endregion

//#region[User Inputs]
// Surprise Settings
int reaction_window   = input.int(5, title="Reaction Window (Bars)", minval=1, maxval=30, tooltip=reactionWindowTT, group="Surprise Settings")
float max_clamp       = input.float(150.0, title="Max Surprise Clamp %", minval=10.0, tooltip=clampTT, group="Surprise Settings")
bool offset_reaction  = input.bool(true, title="Offset Reaction to Earnings Day", tooltip=offsetReactionTT, group="Surprise Settings")

// Valuation Settings
int pe_lookback       = input.int(500, title="P/E Lookback (Bars)", minval=50, maxval=2000, tooltip=lookbackTT, group="Valuation Settings")
float low_percentile  = input.float(10.0, title="Undervalued Percentile", minval=1.0, maxval=49.0, step=1.0, tooltip=lowPctTT, group="Valuation Settings")
float high_percentile = input.float(90.0, title="Overvalued Percentile", minval=51.0, maxval=99.0, step=1.0, tooltip=highPctTT, group="Valuation Settings")

// Volatility Settings
int reports_lookback  = input.int(8, title="Volatility Lookback (Quarters)", minval=2, maxval=20, tooltip=volLookbackTT, group="Volatility Settings")
bool show_cone        = input.bool(true, title="Show Volatility Cone Projection", tooltip=showConeTT, group="Volatility Settings")

// Visual Settings
bool show_table       = input.bool(true, title="Show Stats Table on Main Chart", tooltip=showTableTT, group="Visual Settings")

// Color Customization
color color_beat      = input.color(color.rgb(38, 166, 154), title="Beat Column Color", group="Color Customization")   // Emerald/Teal
color color_miss      = input.color(color.rgb(239, 83, 80), title="Miss Column Color", group="Color Customization")   // Soft Coral
color color_pos_react = input.color(color.rgb(0, 230, 118), title="Positive Reaction Dot", group="Color Customization") // Neon Green
color color_neg_react = input.color(color.rgb(255, 23, 68), title="Negative Reaction Dot", group="Color Customization") // Bright Red
color color_low       = input.color(color.rgb(76, 175, 80), title="Undervalued Line", group="Color Customization")    // Soft Green
color color_med       = input.color(color.rgb(255, 152, 0), title="Fair Value Line", group="Color Customization")     // Soft Orange
color color_high      = input.color(color.rgb(244, 67, 54), title="Overvalued Line", group="Color Customization")     // Soft Red
color color_low_fill  = input.color(color.new(color.rgb(76, 175, 80), 93), title="Undervalued Zone Fill", group="Color Customization")
color color_high_fill = input.color(color.new(color.rgb(244, 67, 54), 93), title="Overvalued Zone Fill", group="Color Customization")
color color_up_cone   = input.color(color.rgb(38, 166, 154), title="Upper Cone Boundary", group="Color Customization")
color color_down_cone = input.color(color.rgb(239, 83, 80), title="Lower Cone Boundary", group="Color Customization")
color color_zone_bg   = input.color(color.new(color.rgb(33, 150, 243), 93), title="Cone Zone Background", group="Color Customization")
color color_zone_brd  = input.color(color.new(color.rgb(33, 150, 243), 40), title="Cone Zone Border", group="Color Customization")
color color_zero_line = input.color(color.new(color.gray, 60), title="Zero Line Color", group="Color Customization")
//#endregion

//#region[Custom Array Percentile Method]
// @function Computes the P-th percentile of values inside a dynamic float array
// @param arr The source array containing historical data
// @param p The target percentile (0 to 100)
// @returns The computed percentile value, or na if array is empty
method percentile(float[] arr, float p) =>
    if array.size(arr) == 0
        float(na)
    else
        float[] sorted_arr = array.copy(arr)
        array.sort(sorted_arr)
        int idx = math.round((p / 100.0) * (array.size(sorted_arr) - 1))
        array.get(sorted_arr, idx)
//#endregion

//#region[Data Fetching & Base Calculations]
// Fetch actual and estimated earnings at publication bars
float actual_eps   = request.earnings(syminfo.tickerid, earnings.actual, gaps=barmerge.gaps_on)
float estimate_eps = request.earnings(syminfo.tickerid, earnings.estimate, gaps=barmerge.gaps_on)

// 1. Surprise Calculations
float surprise     = actual_eps - estimate_eps
float surprise_pct = not na(estimate_eps) and estimate_eps != 0 ? (surprise / math.abs(estimate_eps)) * 100 : na
float clamped_surprise_pct = math.max(-max_clamp, math.min(max_clamp, surprise_pct))

// Track historical average surprise over the last 8 quarters
var float[] surprise_history = array.new_float()
if not na(surprise_pct)
    array.push(surprise_history, surprise_pct)
    if array.size(surprise_history) > 8
        array.shift(surprise_history)

float avg_surprise = array.size(surprise_history) > 0 ? array.avg(surprise_history) : na

// 2. Trailing Twelve Months (TTM) EPS
var float[] eps_quarters = array.new_float()
if not na(actual_eps)
    array.push(eps_quarters, actual_eps)
    if array.size(eps_quarters) > 4
        array.shift(eps_quarters)

float ttm_eps = array.size(eps_quarters) == 4 ? array.sum(eps_quarters) : na

// 3. Historical P/E ratio tracking
float pe_ratio = ttm_eps > 0 ? (close / ttm_eps) : na

var float[] pe_history = array.new_float()
if not na(pe_ratio)
    array.push(pe_history, pe_ratio)
    if array.size(pe_history) > pe_lookback
        array.shift(pe_history)
//#endregion

//#region[Valuation Bands & Volatility Calculations]
// Calculate historical P/E percentiles
float pe_low  = pe_history.percentile(low_percentile)
float pe_med  = pe_history.percentile(50.0)
float pe_high = pe_history.percentile(high_percentile)

// Generate valuation band prices (overlaid on main chart)
float val_low  = not na(ttm_eps) and not na(pe_low) ? ttm_eps * pe_low : na
float val_med  = not na(ttm_eps) and not na(pe_med) ? ttm_eps * pe_med : na
float val_high = not na(ttm_eps) and not na(pe_high) ? ttm_eps * pe_high : na

// 4. Price Reaction and Earnings Volatility Calculations
var float base_price = na
var int bars_since   = na

if not na(actual_eps)
    base_price := close
    bars_since := 0

float reaction_pct = na
if not na(bars_since)
    bars_since := bars_since + 1
    if bars_since == reaction_window
        reaction_pct := ((close - base_price) / base_price) * 100
        bars_since := na
        base_price := na

var float[] historical_moves = array.new_float()
if not na(actual_eps)
    day_move = (math.abs(close - close[1]) / close[1]) * 100
    array.push(historical_moves, day_move)
    if array.size(historical_moves) > reports_lookback
        array.shift(historical_moves)

float avg_expected_move = array.size(historical_moves) > 0 ? array.avg(historical_moves) : na

// Request baseline ATR Daily Volatility
float daily_atr     = request.security(syminfo.tickerid, "D", ta.atr(14))
float daily_close   = request.security(syminfo.tickerid, "D", close)
float daily_atr_pct = not na(daily_close) and daily_close != 0 ? (daily_atr / daily_close) * 100 : na

float vol_multiplier = not na(avg_expected_move) and not na(daily_atr_pct) and daily_atr_pct != 0 ? avg_expected_move / daily_atr_pct : na
//#endregion

//#region[Future Countdown & Catalyst Info]
float next_eps_est = earnings.future_eps
float next_rev_est = earnings.future_revenue

int days_to_earnings  = not na(earnings.future_time) ? math.max(0, math.ceil((earnings.future_time - time) / 86400000)) : na
int hours_to_earnings = not na(earnings.future_time) ? math.max(0, math.ceil((earnings.future_time - time) / 3600000)) : na

string countdown_str = "N/A"
if not na(days_to_earnings)
    if days_to_earnings > 1
        countdown_str := str.tostring(days_to_earnings) + " days"
    else
        countdown_str := str.tostring(hours_to_earnings) + " hours"

format_revenue(float rev) =>
    if na(rev)
        "N/A"
    else if rev >= 1000000000
        str.tostring(rev / 1000000000, "#.##") + "B"
    else if rev >= 1000000
        str.tostring(rev / 1000000, "#.##") + "M"
    else
        str.tostring(rev, "#.##")
//#endregion

//#region[Indicator Pane Plotting (Overlay = False)]
// Zero line
hline(0.0, title="Zero Line", color=color_zero_line, linestyle=hline.style_dashed)

// Columns for earnings surprise
plot(clamped_surprise_pct, title="Earnings Surprise %", color=clamped_surprise_pct >= 0 ? color_beat : color_miss, style=plot.style_columns)

// Price reaction plot
int plot_offset = offset_reaction ? -reaction_window : 0
plot(reaction_pct, title="Price Reaction %", color=reaction_pct >= 0 ? color_pos_react : color_neg_react, 
     style=plot.style_circles, linewidth=4, offset=plot_offset)
//#endregion

//#region[Main Chart Plotting (Force Overlay = True)]
// Plots forced onto the main price chart
plot_low  = plot(val_low, title="Undervalued Band", color=color_low, linewidth=2, style=plot.style_line, force_overlay=true)
plot_med  = plot(val_med, title="Fair Value (Median)", color=color_med, linewidth=1, style=plot.style_line, force_overlay=true)
plot_high = plot(val_high, title="Overvalued Band", color=color_high, linewidth=2, style=plot.style_line, force_overlay=true)

// Fills connected between forced plots will automatically render on the main chart
fill(plot_low, plot_med, color=color_low_fill, title="Undervalued Zone")
fill(plot_med, plot_high, color=color_high_fill, title="Overvalued Zone")

// Future Volatility Cone drawings (forced onto the main chart)
var line upper_line = na
var line lower_line = na
var box target_box   = na

if barstate.islast and show_cone and not na(earnings.future_time) and earnings.future_time > time and not na(avg_expected_move)
    float current_close = close
    float move_amt      = current_close * (avg_expected_move / 100.0)
    float projected_high= current_close + move_amt
    float projected_low = current_close - move_amt
    
    line.delete(upper_line)
    line.delete(lower_line)
    box.delete(target_box)
    
    upper_line := line.new(x1=time, y1=current_close, x2=earnings.future_time, y2=projected_high, 
                           xloc=xloc.bar_time, color=color_up_cone, style=line.style_dashed, width=2, force_overlay=true)
    lower_line := line.new(x1=time, y1=current_close, x2=earnings.future_time, y2=projected_low, 
                           xloc=xloc.bar_time, color=color_down_cone, style=line.style_dashed, width=2, force_overlay=true)
    target_box := box.new(left=time, top=projected_high, right=earnings.future_time, bottom=projected_low,
                          xloc=xloc.bar_time, border_color=color_zone_brd, bgcolor=color_zone_bg, border_style=line.style_dotted, force_overlay=true)
//#endregion

//#region[Unified Statistics Dashboard]
// Valuation Status
string valuation_status = "N/A"
color status_color      = chart.fg_color

if not na(pe_ratio) and not na(pe_low) and not na(pe_high)
    if pe_ratio <= pe_low
        valuation_status := "Undervalued"
        status_color     := color_low
    else if pe_ratio >= pe_high
        valuation_status := "Overvalued"
        status_color     := color_high
    else
        valuation_status := "Fair Value"
        status_color     := color_med

// Persistent values for last reported earnings
var float latest_actual       = na
var float latest_estimate     = na
var float latest_surprise_pct = na

if not na(actual_eps)
    latest_actual       := actual_eps
    latest_estimate     := estimate_eps
    latest_surprise_pct := surprise_pct

// Create dynamic dashboard table (forced onto main chart)
var table stats_table = table.new(position.top_right, 2, 9, bgcolor=color.new(chart.bg_color, 15), border_color=color.new(color.gray, 70), border_width=1, force_overlay=true)
if barstate.islast and show_table and not na(ttm_eps)
    // Table Headers
    table.cell(stats_table, 0, 0, "Combined Earnings Metric", bgcolor=color.new(color.blue, 30), text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(stats_table, 1, 0, "Value", bgcolor=color.new(color.blue, 30), text_color=color.white, text_size=size.small, text_halign=text.align_right)
    
    // TTM EPS
    table.cell(stats_table, 0, 1, "TTM EPS / Latest EPS", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_left)
    table.cell(stats_table, 1, 1, str.tostring(ttm_eps, "$#.##") + " / " + str.tostring(latest_actual, "$#.##"), text_color=chart.fg_color, text_size=size.small, text_halign=text.align_right)
    
    // Current PE
    table.cell(stats_table, 0, 2, "Price / Current P/E", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_left)
    table.cell(stats_table, 1, 2, str.tostring(close, "$#.##") + " / " + str.tostring(pe_ratio, "#.##") + "x", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_right)
    
    // Valuation Status
    table.cell(stats_table, 0, 3, "Valuation Status", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_left)
    table.cell(stats_table, 1, 3, valuation_status, bgcolor=color.new(status_color, 85), text_color=status_color, text_size=size.small, text_halign=text.align_right)
    
    // Latest Surprise %
    table.cell(stats_table, 0, 4, "Latest EPS Surprise %", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_left)
    table.cell(stats_table, 1, 4, str.tostring(latest_surprise_pct, "#.##") + "%", 
               bgcolor=latest_surprise_pct >= 0 ? color.new(color_beat, 85) : color.new(color_miss, 85),
               text_color=latest_surprise_pct >= 0 ? color_beat : color_miss, text_size=size.small, text_halign=text.align_right)
    
    // Average surprise
    table.cell(stats_table, 0, 5, "8-Quarter Avg Surprise", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_left)
    table.cell(stats_table, 1, 5, str.tostring(avg_surprise, "#.##") + "%", 
               text_color=avg_surprise >= 0 ? color_beat : color_miss, text_size=size.small, text_halign=text.align_right)
    
    // Earnings Volatility expected
    table.cell(stats_table, 0, 6, "Avg Earnings Day Move", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_left)
    table.cell(stats_table, 1, 6, not na(avg_expected_move) ? str.tostring(avg_expected_move, "#.##") + "% (" + str.tostring(vol_multiplier, "#.##") + "x Normal)" : "N/A", 
               text_color=chart.fg_color, text_size=size.small, text_halign=text.align_right)
               
    // Expected next EPS and Revenue
    table.cell(stats_table, 0, 7, "Next Quarter Est (EPS/Rev)", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_left)
    table.cell(stats_table, 1, 7, (not na(next_eps_est) ? str.tostring(next_eps_est, "$#.##") : "N/A") + " / " + format_revenue(next_rev_est), text_color=chart.fg_color, text_size=size.small, text_halign=text.align_right)
    
    // Countdown
    next_date_str = not na(earnings.future_time) ? str.format("{0,date,yyyy-MM-dd}", earnings.future_time) : "N/A"
    table.cell(stats_table, 0, 8, "Next Report / Countdown", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_left)
    table.cell(stats_table, 1, 8, next_date_str + " (" + countdown_str + ")", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_right)

// Warning for non-stock tickers (forced onto main chart)
var table warning_table = table.new(position.middle_center, 1, 1, force_overlay=true)
if barstate.islast and na(ttm_eps)
    table.cell(warning_table, 0, 0, "No Earnings Data Found for " + syminfo.ticker + ".\nEnsure you are using a stock ticker with scheduled/historical earnings.", 
               bgcolor=color.new(color_miss, 80), text_color=color_neg_react, text_size=size.normal)
//#endregion

//Plots

plot(vol_multiplier, "Average Earnings Move", color = na, display = display.none + display.pine_screener)
plot(avg_surprise, "Average Surprise", color = na, display = display.none + display.pine_screener)
plot(latest_surprise_pct, "Latest Surprise", color = na, display = display.none + display.pine_screener)
````
