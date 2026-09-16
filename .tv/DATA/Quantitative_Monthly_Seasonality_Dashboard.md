<!-- tradingview-pine-id: PUB;077d76cf12b349348f0ea34389de8b99 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Quantitative Monthly Seasonality Dashboard

Source: https://www.tradingview.com/script/GtPup8IK-Quantitative-Monthly-Seasonality-Dashboard/

## Description

** Overview

The "Quantitative Monthly Seasonality Dashboard" is an advanced statistical overlay designed to evaluate calendar anomalies, historical performance metrics, and volatility filters for swing traders and portfolio managers.

Instead of relying solely on traditional seasonal tendencies (e.g., "Sell in May"), this indicator calculates a multi-factor **Quant Score (0-100)** by cross-referencing historical monthly win rates, profit factors, average returns, and current daily market volatility.

** How It Works

1. Historical Month Backtest: Evaluates the current calendar month across a user-defined historical lookback period (default: 20 years).

2. Key Metrics Evaluated:

   - Win Rate (%): Historical percentage of positive-closing months.
   - Profit Factor: Gross gains divided by gross losses for the specified month.
   - Average Return (%): Expected mean return for the month.

3. Volatility Expansion Filter (Bollinger Bandwidth): Measures 20-day daily Bollinger Bandwidth to ensure the market is in an expansion/trending regime rather than a low-volatility squeeze.

4. Proprietary Quant Score (0-100): Combines and normalizes all quantitative metrics into a single rating score:

   - Eligible (Long): Triggers when the asset passes win rate, profit factor, and volatility thresholds.
   - Flat / No Trade: Indicates insufficient historical edge or suppressed volatility.

---

** Features & Capabilities:

- Non-Repainting Logic: Uses strict `lookahead_off` multi-timeframe requests to preserve backtest accuracy without forward bias.
- Real-Time Month Tracker: Monitors current live month returns against historical benchmarks.
- Customizable Thresholds: Fully adjustable win rate requirements, profit factor filters, and historical lookback windows.

** Best Practices:

- Top-Down Filter: Apply on Daily or Monthly charts across major indices (SPY, ES1!, QQQ), Commodities (USOIL, XAUUSD), and Mega-Cap Stocks.

- Macro Alignment: Combine this seasonal quantitative score with order flow tools or macro regime indicators to build high-probability multi-timeframe strategies.

---

## Source Code

````pine
//@version=6
indicator("Quantitative Monthly Seasonality Dashboard", 
     overlay=true, 
     max_labels_count=500,
     shorttitle="Seasonality_Quant")

// ==============================================================================
// 1. INPUTS & PARAMETERS
// ==============================================================================
group_design   = "Visual Settings"
table_pos_input= input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=group_design)

group_quant    = "Quantitative Filters"
min_bandwidth  = input.float(4.0, "Min Bollinger Bandwidth (%)", group=group_quant)
min_win_rate   = input.float(50.0, "Min Win Rate Req (%)", group=group_quant)
min_pf         = input.float(1.0, "Min Profit Factor Req", group=group_quant)
lookback_years = input.int(20, "Evaluation Lookback (Years)", group=group_quant)

// Position Mapping
table_pos = switch table_pos_input
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

// ==============================================================================
// 2. DAILY VOLATILITY METRICS (Bandwidth)
// ==============================================================================
[daily_sma, daily_std] = request.security(syminfo.tickerid, "D", [ta.sma(close, 20), ta.stdev(close, 20)], ignore_invalid_symbol=true)
daily_bandwidth = not na(daily_sma) and daily_sma != 0 ? ((daily_sma + 2 * daily_std) - (daily_sma - 2 * daily_std)) / daily_sma * 100 : 0.0
is_volatility_active = daily_bandwidth >= min_bandwidth

// ==============================================================================
// 3. SEASONAL DATA EXTRACTION (Non-Repainting)
// ==============================================================================
m_open  = request.security(syminfo.tickerid, "1M", open[1], barmerge.gaps_off, barmerge.lookahead_off)
m_close = request.security(syminfo.tickerid, "1M", close[1], barmerge.gaps_off, barmerge.lookahead_off)
m_month = request.security(syminfo.tickerid, "1M", month[1], barmerge.gaps_off, barmerge.lookahead_off)
m_year  = request.security(syminfo.tickerid, "1M", year[1], barmerge.gaps_off, barmerge.lookahead_off)

m_live_open = request.security(syminfo.tickerid, "1M", open, barmerge.gaps_off, barmerge.lookahead_off)

// Current live month return
float current_month_live_ret = not na(m_live_open) and m_live_open != 0 ? ((close - m_live_open) / m_live_open) * 100 : 0.0

int current_target_month = month(time)
int current_target_year  = year(time)

// Array calculation on last bar
var float[] monthly_returns = array.new_float(0)

if barstate.islast
    array.clear(monthly_returns)
    // Gather statistics from historical data requested via 1M
    // (Pine handles historical arrays dynamically)

// Simplified quantification logic for visualization
var int total_trades = 0
var int wins = 0
var float gross_gains = 0.0
var float gross_losses = 0.0
var float sum_returns = 0.0

is_monthly_change = ta.change(time("1M")) != 0

if is_monthly_change
    if m_month == current_target_month and (current_target_year - m_year) <= lookback_years
        if not na(m_open) and m_open != 0
            float ret = ((m_close - m_open) / m_open) * 100
            array.push(monthly_returns, ret)

total_trades := array.size(monthly_returns)
wins := 0
gross_gains := 0.0
gross_losses := 0.0
sum_returns := 0.0

if total_trades > 0
    for j = 0 to total_trades - 1
        float r = array.get(monthly_returns, j)
        sum_returns += r
        if r > 0
            wins += 1
            gross_gains += r
        else
            gross_losses += math.abs(r)

float win_rate     = total_trades > 0 ? (wins / total_trades) * 100 : 0.0
float avg_return   = total_trades > 0 ? sum_returns / total_trades : 0.0
float profit_factor= gross_losses != 0 ? gross_gains / gross_losses : (gross_gains > 0 ? gross_gains : 1.0)

// Metric Normalization (Score 0-100)
float norm_wr  = math.min(win_rate, 100.0) * 0.35
float norm_pf  = (math.min(profit_factor, 3.0) / 3.0) * 35
float norm_ret = (math.min(math.max(avg_return, 0.0), 5.0) / 5.0) * 20
float norm_bw  = (math.min(daily_bandwidth, 20.0) / 20.0) * 10

float score_100 = norm_wr + norm_pf + norm_ret + norm_bw
bool is_pass    = is_volatility_active and win_rate >= min_win_rate and profit_factor >= min_pf

// ==============================================================================
// 4. DASHBOARD DISPLAY
// ==============================================================================
var table dash = table.new(table_pos, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.gray, border_width=1)

if barstate.islast
    table.set_position(dash, table_pos)
    color status_color = is_pass ? color.green : color.red
    string status_text = is_pass ? "ELIGIBLE (LONG)" : "FLAT / NO TRADE"

    table.cell(dash, 0, 0, "QUANT SEASONALITY", bgcolor=color.blue, text_color=color.white)
    table.cell(dash, 1, 0, str.tostring(current_target_month) + "/" + str.tostring(current_target_year), bgcolor=color.blue, text_color=color.white)
    
    table.cell(dash, 0, 1, "Status", text_color=color.white)
    table.cell(dash, 1, 1, status_text, bgcolor=status_color, text_color=color.white)
    
    table.cell(dash, 0, 2, "Historical Win Rate (" + str.tostring(total_trades) + "m)", text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(win_rate, "#.#") + "%", text_color=color.white)
    
    table.cell(dash, 0, 3, "Hist. Avg Return", text_color=color.white)
    table.cell(dash, 1, 3, (avg_return >= 0 ? "+" : "") + str.tostring(avg_return, "#.#") + "%", text_color=color.white)
    
    table.cell(dash, 0, 4, "Profit Factor", text_color=color.white)
    table.cell(dash, 1, 4, str.tostring(profit_factor, "#.##"), text_color=color.white)
    
    table.cell(dash, 0, 5, "Daily BB Bandwidth", text_color=color.white)
    table.cell(dash, 1, 5, str.tostring(daily_bandwidth, "#.##") + "%", text_color=color.white)

    table.cell(dash, 0, 6, "Quant Score (0-100)", text_color=color.white)
    table.cell(dash, 1, 6, str.tostring(score_100, "#.#"), text_color=color.yellow)

    color curr_month_color = current_month_live_ret >= 0 ? color.teal : color.maroon
    string sign_prefix = current_month_live_ret >= 0 ? "+" : ""
    string live_ret_str = sign_prefix + str.tostring(current_month_live_ret, "#.##") + "%"

    table.cell(dash, 0, 7, "Month Live Return", text_color=color.white)
    table.cell(dash, 1, 7, live_ret_str, bgcolor=curr_month_color, text_color=color.white)
````
