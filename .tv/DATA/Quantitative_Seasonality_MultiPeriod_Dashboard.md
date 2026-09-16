<!-- tradingview-pine-id: PUB;3d2995bcaedb45f4bff9d1a2135a222b -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Quantitative Seasonality Multi-Period Dashboard

Source: https://www.tradingview.com/script/5i5F97TR-Quantitative-Monthly-Seasonality-Dashboard-V2/

## Description

Sadashi Quant Seasonality V2 is a quantitative tool designed to evaluate the seasonal probability of any financial asset for the current calendar month, integrating volatility metrics and risk-adjusted performance data.

Unlike standard seasonal indicators, V2 evaluates both directional probability and trend quality using Bollinger Bandwidth compression filters and Profit Factor scoring, ensuring trades meet favorable risk-to-reward standards.

Key Dashboard Metrics:

    Historical Win Rate: Percentage of years the asset closed positive during the current month across 20-year, 10-year, and 5-year lookback periods.

    Profit Factor (PF): Ratio of total gross profits to total gross losses for the month. A PF > 1.0 confirms positive statistical asymmetry.

    Hist. Avg Return: Expected average performance for the current month.

    BB Bandwidth Filter: Volatility expansion/compression metric to filter out low-momentum market environments.

    Global Status: Real-time trade signal (LONG / SHORT / NO TRADE) based on quantitative eligibility thresholds.

Trading Logic:
A 50% or 60% Win Rate can yield a Profit Factor of 1.5x to 2.0x if the average winning month significantly outweighs average losses, helping traders spot high-expectancy setups regardless of raw win frequency.

Developed for the Sadashi Trading community.

---

## Source Code

````pine
//@version=6
indicator("Quantitative Seasonality Multi-Period Dashboard", 
     overlay=true, 
     max_labels_count=500,
     shorttitle="SQ_Multi")

// ==============================================================================
// 1. INPUTS & PARAMETERS
// ==============================================================================
group_design    = "Visual Settings"
table_pos_input = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=group_design)

group_quant     = "Quantitative Filters"
min_bandwidth   = input.float(4.0, "Min Bollinger Bandwidth (%)", group=group_quant)
min_win_rate    = input.float(50.0, "Min Win Rate Req (%)", group=group_quant)
min_pf          = input.float(1.0, "Min Profit Factor Req", group=group_quant)

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
// 3. SEASONAL DATA EXTRACTION (Multi-Period Storage)
// ==============================================================================
m_open  = request.security(syminfo.tickerid, "1M", open[1], barmerge.gaps_off, barmerge.lookahead_off)
m_close = request.security(syminfo.tickerid, "1M", close[1], barmerge.gaps_off, barmerge.lookahead_off)
m_month = request.security(syminfo.tickerid, "1M", month[1], barmerge.gaps_off, barmerge.lookahead_off)
m_year  = request.security(syminfo.tickerid, "1M", year[1], barmerge.gaps_off, barmerge.lookahead_off)

// Captura precisa del Open del mes actual sin desfasajes de request.security
var float live_month_open = na
bool is_monthly_change = ta.change(time("1M")) != 0

if is_monthly_change
    live_month_open := open

// Cálculo del retorno del mes en curso
float current_month_live_ret = not na(live_month_open) and live_month_open != 0 ? ((close - live_month_open) / live_month_open) * 100 : 0.0

int target_month = month(timenow)
int current_year = year(timenow)

var float[] monthly_returns = array.new_float(0)

if is_monthly_change and not na(m_open) and m_open != 0
    if m_month == target_month and (current_year - m_year) <= 20
        float r = ((m_close - m_open) / m_open) * 100
        array.push(monthly_returns, r)

// Función para calcular métricas por periodo de años (5, 10, 20)
calc_metrics(float[] returns_arr, int years_limit) =>
    int total = array.size(returns_arr)
    int count = math.min(total, years_limit)
    int wins = 0
    float gross_gains = 0.0
    float gross_losses = 0.0
    float sum_ret = 0.0

    if count > 0
        for i = (total - count) to (total - 1)
            float r = array.get(returns_arr, i)
            sum_ret += r
            if r > 0
                wins += 1
                gross_gains += r
            else
                gross_losses += math.abs(r)

    float wr = count > 0 ? (wins / float(count)) * 100.0 : 0.0
    float avg_r = count > 0 ? sum_ret / float(count) : 0.0
    float pf = gross_losses != 0 ? gross_gains / gross_losses : (gross_gains > 0 ? gross_gains : 1.0)
    [count, wr, avg_r, pf]

// Métricas por periodo
[count_20, wr_20, avg_20, pf_20] = calc_metrics(monthly_returns, 20)
[count_10, wr_10, avg_10, pf_10] = calc_metrics(monthly_returns, 10)
[count_5,  wr_5,  avg_5,  pf_5]  = calc_metrics(monthly_returns, 5)

bool is_pass = is_volatility_active and wr_20 >= min_win_rate and pf_20 >= min_pf

// Palette
color color_positive = #00e676
color color_negative = #ff5252

// ==============================================================================
// 4. DASHBOARD DISPLAY (Matriz Multi-Periodo)
// ==============================================================================
var table dash = table.new(table_pos, 4, 6, bgcolor=color.new(color.black, 15), border_color=color.gray, border_width=1)

if barstate.islast
    table.set_position(dash, table_pos)
    color status_color = is_pass ? color_positive : color_negative
    string status_text = is_pass ? "ELIGIBLE (LONG)" : "FLAT / NO TRADE"

    // Header principal
    table.cell(dash, 0, 0, "QUANT SEASONALITY", bgcolor=color.navy, text_color=color.white)
    table.cell(dash, 1, 0, str.tostring(target_month) + "/" + str.tostring(current_year), bgcolor=color.navy, text_color=color.white)
    table.cell(dash, 2, 0, "BB Bandwidth", bgcolor=color.navy, text_color=color.white)
    table.cell(dash, 3, 0, str.tostring(daily_bandwidth, "#.##") + "%", bgcolor=color.navy, text_color=color.white)

    // Status Row
    table.cell(dash, 0, 1, "Status Global", text_color=color.white)
    table.cell(dash, 1, 1, status_text, bgcolor=status_color, text_color=color.black)
    table.cell(dash, 2, 1, "Live Return", text_color=color.white)
    color curr_month_color = current_month_live_ret >= 0 ? color_positive : color_negative
    table.cell(dash, 3, 1, (current_month_live_ret >= 0 ? "+" : "") + str.tostring(current_month_live_ret, "#.##") + "%", bgcolor=curr_month_color, text_color=color.black)

    // Sub-headers de periodos
    table.cell(dash, 0, 2, "Métrica", bgcolor=color.gray, text_color=color.white)
    table.cell(dash, 1, 2, "20-Year (" + str.tostring(count_20) + "m)", bgcolor=color.gray, text_color=color.white)
    table.cell(dash, 2, 2, "10-Year (" + str.tostring(count_10) + "m)", bgcolor=color.gray, text_color=color.white)
    table.cell(dash, 3, 2, "5-Year ("  + str.tostring(count_5)  + "m)", bgcolor=color.gray, text_color=color.white)

    // Win Rate Row
    table.cell(dash, 0, 3, "Win Rate", text_color=color.white)
    table.cell(dash, 1, 3, str.tostring(wr_20, "#.#") + "%", text_color=color.white)
    table.cell(dash, 2, 3, str.tostring(wr_10, "#.#") + "%", text_color=color.white)
    table.cell(dash, 3, 3, str.tostring(wr_5,  "#.#") + "%", text_color=color.white)

    // Avg Return Row
    table.cell(dash, 0, 4, "Hist. Avg Return", text_color=color.white)
    table.cell(dash, 1, 4, (avg_20 >= 0 ? "+" : "") + str.tostring(avg_20, "#.#") + "%", text_color=avg_20 >= 0 ? color_positive : color_negative)
    table.cell(dash, 2, 4, (avg_10 >= 0 ? "+" : "") + str.tostring(avg_10, "#.#") + "%", text_color=avg_10 >= 0 ? color_positive : color_negative)
    table.cell(dash, 3, 4, (avg_5  >= 0 ? "+" : "") + str.tostring(avg_5,  "#.#") + "%", text_color=avg_5  >= 0 ? color_positive : color_negative)

    // Profit Factor Row
    table.cell(dash, 0, 5, "Profit Factor", text_color=color.white)
    table.cell(dash, 1, 5, str.tostring(pf_20, "#.##"), text_color=pf_20 >= min_pf ? color.white : color_negative)
    table.cell(dash, 2, 5, str.tostring(pf_10, "#.##"), text_color=pf_10 >= min_pf ? color.white : color_negative)
    table.cell(dash, 3, 5, str.tostring(pf_5,  "#.##"), text_color=pf_5  >= min_pf ? color.white : color_negative)
````
