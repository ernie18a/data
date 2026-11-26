# CVD & Open Interest Dashboard

- url: https://www.tradingview.com/script/dNpNQvgs/
- type: indicator
- pine_id: PUB;798df85736cc439c8d9e806bd46a2715
- version: 1.0

## Description

The CVD & Open Interest Dashboard is a comprehensive order flow tool designed to reveal the true mechanics behind price movements. By combining Cumulative Volume Delta (CVD) and Open Interest (OI) into a single, clean sub-window, this indicator helps you objectively distinguish between true market participation (new positions) and forced positioning (liquidations).

Instead of cluttering your main chart, this dashboard provides all the essential market internal data you need at a glance.

🌟 Core Concepts & Features
1. Smart CVD Engine (Premium & Free Compatible):

High Precision Mode (Premium Users): Leverages TradingView's request.security_lower_tf to fetch raw tick-by-tick order flow from the 10-second timeframe. This provides an incredibly accurate view of aggressive buying and selling.

Normal Mode (Free Users): Automatically calculates the delta based on your current chart timeframe, ensuring all users can benefit from the tool without running into calculation limits.

2. Visual OI Anomalies (Spikes):
The script tracks the net change in Open Interest. When it detects an abnormal surge in OI (customizable via the Anomaly Multiplier), it cross-references it with the CVD to color-code the move:

Green Spikes (Area/Line): Indicates aggressive Long initiations or Short Liquidations.

Red Spikes (Area/Line): Indicates aggressive Short initiations or Long Liquidations.

3. Real-Time Market State (Top Left):
A real-time environmental panel that tracks the smoothed trends of both Price and Open Interest to give you the objective state of the market:

🟦 Long Build-up (Real Uptrend): Price is rising + OI is rising.

🟨 Short Cover (Weak Uptrend): Price is rising + OI is falling (Fuel is running out).

🟥 Short Build-up (Real Downtrend): Price is falling + OI is rising.

🟪 Long Liq (Weak Downtrend): Price is falling + OI is falling.
(Note: The indicator softly highlights the background of only the very last candle to keep you aware without muddying your past chart data).

4. Bull vs. Bear Power Gauge (Bottom Right):
A dynamic progress bar acting as a tug-of-war meter. It aggregates the volume of all significant aggressive actions over your chosen rolling period (e.g., the last 60 bars). This gives you an immediate percentage read on which side actually controls the current session.

⚙️ Setup & Customization
OI Ticker Flexibility: The default is set to BINANCE:BTCUSDT.P_OI (Binance Futures BTC). You can easily change this to your preferred exchange directly from the settings menu (e.g., simply search for Bybit or OKX OI in the symbol input).

Server Optimization: The script is optimized with max_bars_back = 1000 to prevent timeout errors and keep your chart running smoothly while processing intense lower-timeframe data.

Disclaimer: This script is designed for educational and objective environmental analysis purposes only. Always use it in conjunction with your own price action analysis and risk management rules.

## Source Code

````pine
//@version=6
indicator('CVD & Open Interest Dashboard', shorttitle = 'CVD + OI Dash', format = format.volume, overlay = false, max_bars_back = 1000, dynamic_requests = true)

// =====================================================================
// 1. INPUTS (Settings)
// =====================================================================
grp_data = '1. Data Sources & Thresholds'
oi_ticker = input.symbol('BINANCE:BTCUSDT.P_OI', title = 'Open Interest Ticker', tooltip = 'Select your exchange\'s OI ticker (e.g., BINANCE:BTCUSDT.P_OI, BYBIT:BTCUSDT.OI)', group = grp_data)
spike_mult = input.float(2.5, title = 'Anomaly Detection Multiplier (2.0-3.0)', group = grp_data)
sma_len = input.int(20, title = 'Noise Smoothing Period', group = grp_data)

grp_gauge = '2. Gauge & LTF Settings'
lookback_bars = input.int(60, title = 'Gauge Rolling Period (Last X bars)', tooltip = 'e.g., 60 on a 1m chart equals 1 hour of power', group = grp_gauge)
calc_mode = input.string('Normal (Free / All Plans)', title = 'CVD Calculation Mode', options = ['High Precision (Premium / 10S)', 'Normal (Free / All Plans)'], group = grp_gauge)

grp_macro = '3. Macro Environment Settings'
smooth_len = input.int(3, title = 'Macro Smoothing Period', tooltip = 'For determining OI and Price trends (Noise reduction)', group = grp_macro)


// =====================================================================
// 2. DATA FETCHING & CALCULATIONS
// =====================================================================
oi = request.security(oi_ticker, timeframe.period, close, ignore_invalid_symbol = true)
oi_delta = nz(oi - oi[1])

float true_candle_delta = 0.0
float total_vol = 0.0

if calc_mode == 'High Precision (Premium / 10S)'
    ltf_vol_expr = close > open ? volume : close < open ? -volume : 0
    ltf_delta_array = request.security_lower_tf(syminfo.tickerid, '10S', ltf_vol_expr)
    ltf_total_vol_array = request.security_lower_tf(syminfo.tickerid, '10S', volume)
    true_candle_delta := array.sum(ltf_delta_array)
    total_vol := array.sum(ltf_total_vol_array)
    total_vol
else
    true_candle_delta := close > open ? volume : close < open ? -volume : 0
    total_vol := volume
    total_vol

cvd_direction = true_candle_delta > total_vol * 0.01 ? 1 : true_candle_delta < -(total_vol * 0.01) ? -1 : 0

abs_delta_sma = ta.sma(math.abs(oi_delta), sma_len)
is_spike = math.abs(oi_delta) > abs_delta_sma * spike_mult


// =====================================================================
// 3. MAIN DELTA PLOTS
// =====================================================================
color_normal_area = color.new(color.gray, 85)
color_normal_line = color.new(color.gray, 60)
color_green_area = color.new(#089981, 40)
color_green_line = color.new(#089981, 0)
color_red_area = color.new(#f23645, 40)
color_red_line = color.new(#f23645, 0)

is_L_action = is_spike and (oi_delta > 0 and cvd_direction == 1 or oi_delta < 0 and cvd_direction == -1)
is_S_action = is_spike and (oi_delta > 0 and cvd_direction == -1 or oi_delta < 0 and cvd_direction == 1)

dynamic_color_area = is_L_action ? color_green_area : is_S_action ? color_red_area : color_normal_area
dynamic_color_line = is_L_action ? color_green_line : is_S_action ? color_red_line : color_normal_line

plot(oi_delta, title = 'OI Area', color = dynamic_color_area, style = plot.style_area)
plot(oi_delta, title = 'OI Line', color = dynamic_color_line, style = plot.style_line, linewidth = 1)
plot(0, title = 'Zero Line', color = color.new(color.gray, 60), linewidth = 1)


// =====================================================================
// 4. POWER GAUGE (Bottom Right)
// =====================================================================
vol_delta = math.abs(oi_delta)
L_IN_vol = cvd_direction == 1 and oi_delta > 0 ? vol_delta : 0
S_LQ_vol = cvd_direction == 1 and oi_delta < 0 ? vol_delta : 0
S_IN_vol = cvd_direction == -1 and oi_delta > 0 ? vol_delta : 0
L_LQ_vol = cvd_direction == -1 and oi_delta < 0 ? vol_delta : 0

bull_add = L_IN_vol + S_LQ_vol
bear_add = S_IN_vol + L_LQ_vol

rolling_bull = math.sum(bull_add, lookback_bars)
rolling_bear = math.sum(bear_add, lookback_bars)

var table bias_table = table.new(position.bottom_right, 2, 2, bgcolor = na, border_width = 1, border_color = color.new(color.gray, 90))

if barstate.islast
    total_power = rolling_bull + rolling_bear
    bull_ratio = total_power == 0 ? 0.5 : rolling_bull / total_power
    bear_ratio = 1.0 - bull_ratio

    bull_pct = math.round(bull_ratio * 100)
    bear_pct = 100 - bull_pct

    table.cell(bias_table, 0, 0, 'Bull: ' + str.tostring(math.round(rolling_bull)), text_color = color.new(#089981, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(bias_table, 1, 0, 'Bear: ' + str.tostring(math.round(rolling_bear)), text_color = color.new(#f23645, 0), text_size = size.small, text_halign = text.align_right)

    bull_text = bull_pct >= 10 ? str.tostring(bull_pct) + '%' : ''
    bear_text = bear_pct >= 10 ? str.tostring(bear_pct) + '%' : ''

    table.cell(bias_table, 0, 1, text = bull_text, bgcolor = color.new(#089981, 15), text_color = color.white, text_size = size.small, width = math.max(0.1, bull_pct))
    table.cell(bias_table, 1, 1, text = bear_text, bgcolor = color.new(#f23645, 15), text_color = color.white, text_size = size.small, width = math.max(0.1, bear_pct))


// =====================================================================
// 5. MACRO STATE HIGHLIGHT & TABLE (Top Left)
// =====================================================================
oi_smoothed = ta.sma(oi, smooth_len)
p_smoothed = ta.sma(close, smooth_len)

price_up = p_smoothed > p_smoothed[1]
price_dn = p_smoothed < p_smoothed[1]
oi_up = oi_smoothed > oi_smoothed[1]
oi_dn = oi_smoothed < oi_smoothed[1]

macro_color = if price_up and oi_up
    color.new(color.blue, 85)
else if price_up and oi_dn
    color.new(color.yellow, 85)
else if price_dn and oi_up
    color.new(color.red, 85)
else if price_dn and oi_dn
    color.new(color.purple, 85)
else
    na

macro_text = if price_up and oi_up
    '🟦 Long Build-up (Real Uptrend)'
else if price_up and oi_dn
    '🟨 Short Cover (Weak Uptrend)'
else if price_dn and oi_up
    '🟥 Short Build-up (Real Downtrend)'
else if price_dn and oi_dn
    '🟪 Long Liq (Weak Downtrend)'
else
    '⏳ Analyzing...'

bgcolor(barstate.islast ? macro_color : na, title = 'Macro State Band')

var table macro_table = table.new(position.top_left, 1, 1, bgcolor = color.new(color.black, 80), border_width = 1, border_color = color.gray)
if barstate.islast
    table.cell(macro_table, 0, 0, macro_text, text_color = color.white, text_size = size.small)
````
