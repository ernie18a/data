# Heikin Ashi CVD (Dashboard Mode)

- url: https://www.tradingview.com/script/WOiUJUpV/
- type: indicator
- pine_id: PUB;8c694816de2549bf9201335e1c1412bb
- version: 1.0

## Description

Title: Heikin Ashi CVD (Cumulative Volume Delta) with Absorption & Dashboard
Description:

Standard Cumulative Volume Delta (CVD) is a powerful tool for reading order flow, but its raw data can be extremely noisy and erratic, making objective analysis difficult.

This indicator addresses this issue by applying Heikin Ashi (HA) smoothing directly to the CVD data. By filtering out micro-fluctuations, it reveals the true underlying flow of aggressive market buying and selling. Furthermore, this script is packed with visual supports, including Absorption (Divergence) Detection, Delta Spike Alerts, and CVD Bollinger Bands, designed to provide a deeper understanding of market micro-structure.

🌟 Key Features
Heikin Ashi Smoothed CVD:
Transforms noisy volume delta into smooth, easily readable Heikin Ashi candles. Green (Teal) candles indicate dominant aggressive buying, while Red candles indicate dominant aggressive selling. This helps traders maintain a clearer perspective on the overall order flow, reducing premature reactions to market noise.

Smart Absorption Detection (White Candles):
A unique analytical feature of this indicator. When the HA-CVD shows a strong trend (a candle with no lower/upper wick), but the actual price candle moves in the opposite direction, the CVD candle will turn White. This signals a divergence: aggressive market orders are being absorbed by passive limit orders. It highlights a significant anomaly worth monitoring for potential shifts in market dynamics.

Delta Spike Alerts:
Automatically detects abnormal surges in volume delta (2.5x higher than the 20-period average). The background will highlight Teal for extreme buying spikes and Red for extreme selling spikes, alerting you to potential order flow climax or breakout phases.

CVD Bollinger Bands:
Unlike price, CVD has no fixed upper or lower boundaries. We applied Bollinger Bands to the CVD to help you identify relative "overbought" or "oversold" order flow conditions. (The script safely handles daily resets so the bands remain stable).

Real-time Status Dashboard:
A clean, unobtrusive panel at the bottom right that instantly displays the current "CVD Trend" (based on EMA crossovers) and the "Market Heat" (based on short vs. long-term volume moving averages).

Hybrid Calculation Modes:

High Precision (Premium Users): Uses request.security_lower_tf to calculate highly accurate delta from the 5-second timeframe.

Normal Mode (Free Users): Uses a 1-minute approximation formula so all TradingView users can utilize the indicator without calculation limits.

💡 How to Interpret HA-CVD
Trend Assessment:
Monitor the consistency of the HA-CVD candle colors to gauge the health of the current trend. A steady color structure suggests sustained aggressive order flow, helping you objectively evaluate the market direction.

Spotting Absorption:
Look for White Candles at key Support/Resistance levels or VWAP. If you see aggressive selling (negative delta) being absorbed (price refuses to drop), it can serve as an early warning sign that the current momentum is stalling due to institutional limit orders.

Identifying Exhaustion:
Watch for the CVD to pierce its upper or lower Bollinger Bands combined with a Delta Spike (Background highlight). This often marks a phase of short-term order flow exhaustion, suggesting a potential consolidation or reversion.

Settings:
You can easily toggle the Daily Reset feature (based on NY Midnight), adjust the lower timeframe for precision mode, and turn the dashboard on or off via the indicator settings.

## Source Code

````pine
//@version=6
indicator('Heikin Ashi CVD (Dashboard Mode)', shorttitle = 'HA-CVD+Dash', overlay = false, dynamic_requests = true)

// --- Settings ---
calc_mode = input.string('Sec-TF (High Precision / Premium)', title = 'Calculation Mode', options = ['Sec-TF (High Precision / Premium)', 'Normal (1m Approximation / All Plans)'])
sec_tf = input.timeframe('5S', title = 'Lower Timeframe')
reset_daily = input.bool(true, title = 'Reset CVD Daily (NY Midnight Base)')
show_panel = input.bool(true, title = 'Show Status Panel')

// --- Data Fetching & Delta Calculation ---
float delta = 0.0
float max_delta = 0.0
float min_delta = 0.0

if calc_mode == 'Sec-TF (High Precision / Premium)'
    c_arr = request.security_lower_tf(syminfo.tickerid, sec_tf, close)
    o_arr = request.security_lower_tf(syminfo.tickerid, sec_tf, open)
    v_arr = request.security_lower_tf(syminfo.tickerid, sec_tf, volume)
    float exact_delta = 0.0
    
    if array.size(c_arr) > 0
        for i = 0 to array.size(c_arr) - 1 by 1
            c = array.get(c_arr, i)
            o = array.get(o_arr, i)
            v = array.get(v_arr, i)
            step_delta = c > o ? v : c < o ? -v : 0
            exact_delta := exact_delta + step_delta
            max_delta := math.max(max_delta, exact_delta)
            min_delta := math.min(min_delta, exact_delta)
        delta := exact_delta
    else
        delta := close > open ? volume : close < open ? -volume : 0
        max_delta := math.max(0, delta)
        min_delta := math.min(0, delta)
else
    delta := close > open ? volume : close < open ? -volume : 0
    max_delta := math.max(0, delta)
    min_delta := math.min(0, delta)

// --- CVD Calculation ---
var float cvd_cum = 0.0
var int bars_since_reset = 0

is_new_day = ta.change(time('D', 'America/New_York'))

if reset_daily and bool(is_new_day)
    cvd_cum := delta
    bars_since_reset := 1
else
    cvd_cum := cvd_cum + delta
    bars_since_reset := bars_since_reset + 1

cvd_c = cvd_cum
cvd_o = reset_daily and bool(is_new_day) ? 0.0 : nz(cvd_cum[1], cvd_cum)
cvd_h = cvd_o + max_delta
cvd_l = cvd_o + min_delta

// --- Heikin Ashi (HA) Calculation ---
var float ha_o = na
ha_c = (cvd_o + cvd_h + cvd_l + cvd_c) / 4.0
ha_o := na(ha_o[1]) ? cvd_o : (ha_o[1] + nz(ha_c[1])) / 2.0
ha_h = math.max(cvd_h, math.max(ha_o, ha_c))
ha_l = math.min(cvd_l, math.min(ha_o, ha_c))

// --- Visual Support 1: Delta Spike Detection ---
avg_delta_abs = ta.sma(math.abs(delta), 20)
is_delta_spike_buy = delta > avg_delta_abs * 2.5
is_delta_spike_sell = delta < -(avg_delta_abs * 2.5)
bgcolor(is_delta_spike_buy ? color.new(color.teal, 85) : is_delta_spike_sell ? color.new(color.red, 85) : na, title = 'Delta Spike Alert')

// --- Visual Support 2: Zero Line Crossover Emphasis ---
cross_up = ta.crossover(ha_c, 0)
cross_dn = ta.crossunder(ha_c, 0)
plotshape(cross_up, style = shape.triangleup, location = location.bottom, color = color.teal, size = size.tiny, title = 'Cross Up')
plotshape(cross_dn, style = shape.triangledown, location = location.top, color = color.red, size = size.tiny, title = 'Cross Down')

// --- Rendering ---
candle_color = ha_c >= ha_o ? color.teal : color.red

// Absorption (Divergence) Detection Conditions
cond1_cvd = ha_c >= ha_o and ha_l == ha_o
cond1_real = close < open
cond1 = cond1_cvd and cond1_real

cond2_cvd = ha_c < ha_o and ha_h == ha_o
cond2_real = close > open
cond2 = cond2_cvd and cond2_real

body_color = cond1 or cond2 ? color.white : candle_color
plotcandle(ha_o, ha_h, ha_l, ha_c, title = 'HA-CVD', color = body_color, wickcolor = candle_color, bordercolor = candle_color)

// --- Visual Support 3: Status Panel ---
if show_panel
    var table status_tbl = table.new(position.bottom_right, 4, 1, bgcolor = na, border_width = 1)

    ema_short = ta.ema(ha_c, 9) // Short-term Trend
    ema_long = ta.ema(ha_c, 21) // Mid-term Trend
    direction_is_buy = ema_short > ema_long
    dir_text = direction_is_buy ? 'Bullish' : 'Bearish'
    dir_color = direction_is_buy ? color.teal : color.red

    // Market Heat (Volume Evaluation)
    vol_sma_short = ta.sma(volume, 5)
    vol_sma_long = ta.sma(volume, 50)
    color text_col = chart.fg_color

    vol_heat = vol_sma_short > vol_sma_long * 1.5 ? 'Hot' : vol_sma_short < vol_sma_long * 0.7 ? 'Cold' : 'Normal'
    heat_color = vol_sma_short > vol_sma_long * 1.5 ? color.orange : vol_sma_short < vol_sma_long * 0.7 ? color.gray : text_col

    table.cell(status_tbl, 0, 0, 'CVD Trend', text_color = text_col, text_size = size.small)
    table.cell(status_tbl, 1, 0, dir_text, text_color = dir_color, text_size = size.small)
    table.cell(status_tbl, 2, 0, 'Market Heat', text_color = text_col, text_size = size.small)
    table.cell(status_tbl, 3, 0, vol_heat, text_color = heat_color, text_size = size.small)

// --- Visual Support 4: CVD Bollinger Bands ---
bb_length = 20
bb_mult = 2.0
cvd_basis = bars_since_reset >= bb_length ? ta.sma(cvd_c, bb_length) : na
cvd_dev = bars_since_reset >= bb_length ? bb_mult * ta.stdev(cvd_c, bb_length) : na
cvd_upper = cvd_basis + cvd_dev
cvd_lower = cvd_basis - cvd_dev
p_upper = plot(cvd_upper, color = color.new(color.gray, 70), title = 'CVD BB Upper')
p_lower = plot(cvd_lower, color = color.new(color.gray, 70), title = 'CVD BB Lower')
p_basis = plot(cvd_basis, color = color.new(color.gray, 50), title = 'CVD BB Basis', style = plot.style_line)
fill(p_upper, p_lower, color = color.new(color.gray, 90), title = 'CVD BB Background')
````
