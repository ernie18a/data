# Alpha Terminal Studio (G-ALPHA)

- url: https://www.tradingview.com/script/MNwyB0m9/
- type: indicator
- pine_id: PUB;264406be0efe4e89b8c25d240cb8e17c
- version: 1.0

## Description

🚀 Alpha Terminal Studio (G-ALPHA)

The Alpha Terminal Studio (G-ALPHA) is an institutional-grade, multi-modular trading terminal environment designed to unify advanced market geography, institutional liquidity mapping, structural trend vectors, and algorithmic order-flow confirmation into a single, high-performance cohesive layout. Rather than cluttering the workspace with fragmented overlays, G-ALPHA operates as a multi-timeframe quantitative command center, offering 100% control through a highly optimized, compact user interface grid.

The core objective of G-ALPHA is to eliminate retrospective retail bias by providing traders with real-time mathematical confluence zones, precise institutional stop-hunting layers, and probabilistic execution triggers natively scaled to asset volatility.

Unlike traditional indicators that operate on fixed, lagging metrics, G-ALPHA incorporates dynamic Multi-Timeframe (MTF) request engines, adaptive Average True Range (ATR) risk parameters, and algorithmic volume profiling to deliver structural clarity across all asset classes and market regimes.

💡 Key Features

🎯 Multi-Timeframe Fibonacci Pivot Engine:
Reconstructs static market geography by calculating mathematically precise Floor and Fibonacci pivot matrices from daily, weekly, or monthly boundaries. It projects dynamic expansion levels (Res 1–3) and liquidation exhaustion floors (Sup 1–3) directly onto the current asset margin.

🧠 Fractional Fibonacci MA Ribbon Wave:
Features a fully decoupled, split moving average ribbon matrix based on pure Fibonacci sequences (lengths stretching individually from micro 3 to macro 4827). Arranged in an ultra-compact inline settings grid, it allows traders to selectively plot independent momentum waves without cluttering interface panels.

🕵️‍♂️ Smart Confluence Alert Detector:
An algorithmic scanning layer that continuously measures the spatial proximity between active structural lines (MAs, Kijun-sen, and Fibo levels). When multiple independent variables overlap within a 0.15% tight mathematical threshold, the corresponding data panel dynamically flashes in high-contrast Gold—instantly identifying a high-probability institutional inflection point.

📊 Institutional Volume Profile POC Tracker:
An embedded micro-volume engine that scans the active lookback horizon to locate the exact price level featuring the highest dense transaction concentration (Point of Control - POC). It anchors a structural step-line across the canvas, verifying where large institutional block orders are heavily capitalized.

🏹 Automated Price Action Trigger Signals:
Monitors real-time micro-structure interactions exactly as price contacts major G-ALPHA levels. The moment structural Pinbars (Hammers/Shooting Stars) or Engulfing vectors develop inside institutional zones, the system executes instant green/red directional execution arrows (▲/▼).

🧬 Algorithmic Multi-Mode Candle Coloring Studio:
Provides advanced hedge-fund grade visual overlays on price action. Traders can cycle between 4 unique quantitative candle filters: Ichimoku Sentiment Trend, ATR Volatility Intensity, Extreme Fibo Threat Zones, and Signal Pattern Confirmations.

📋 Multi-Timeframe Trend Matrix Dashboard:
Deploys a sleek, semi-transparent monitoring table in the upper-right canvas corner. It keeps you synchronized with the broader market trend by scanning multi-timeframe order flow (5M, 15M, 1H, and Daily) against major balance vectors simultaneously.

🏦 Liquidity Pools & Stop Hunting Zones:
Scans major market swings over a 50-bar rolling index to automatically highlight overhead and underlying liquidity pools. It projects transparent Order Block frames where retail stop-losses are concentrated, allowing traders to anticipate institutional "Stop Hunts."

🌍 Global Session Profile Overlays:
Tracks macroeconomic volume handovers by casting precise dikey cross-sections at the exact opening brackets of major global trading seans (Asia, London, and New York).

🔬 Mathematical Logic and Structure

G-ALPHA is built on a multi-layer quant framework designed to strip out microstructure noise and isolate definitive institutional block orders.

The process initiates by capturing prior-period high-low-close matrices over user-selected horizons via strict lookahead-safe request modules. These raw data sets are converted into standard floor distribution scales and multiplied by custom Fibonacci extension variables ($0.382$, $0.618$, and $1.000$).

Simultaneously, the indicator deploys individual mathematical arrays to calculate specific moving average paths. For trend-direction parsing, the algorithm computes Ichimoku Kijun-sen vectors, determining the absolute midpoint of high and low ranges over a 26-period lookback window across multiple dimensions:

Kijun-sen = (Highest High(26) + Lowest Low(26)) / 2

To handle risk management algorithmically, the studio tracks market volatility via an integrated Average True Range (ATR) function. The resulting values are mathematically compiled and printed straight inside the right margin data boxes, giving traders instantaneous, dynamic Trailing Stop Loss [SL] and Multi-Stage Take Profit [TP1 / TP2] price marks mapped precisely to current asset volatility.

All structural calculations are evaluated globally to guarantee script stability and prevents runtime execution lag, ensuring that the canvas rendering engine delivers clean, non-repainting coordinates in real-time.

🛠️ How to Use

1. Confluence Mapping:
Look for the right-side data boxes to turn into a Gold alert color. This tells you a Fibonacci level is perfectly lining up with an active MA or Kijun-sen line, creating an institutional "Hot Zone."

2. Structural Execution:
When price tests a key G-ALPHA channel, wait for a green/red Trigger Arrow to confirm the presence of institutional absorption. Ensure the upper-right MTF Matrix aligns with your directional execution.

3. Volatility Risk Control:
Utilize the automated brackets printed right next to the active levels. Take entry positions near the Fibo floors, set your risk strictly at the printed [SL] mark, and target the corresponding [TP1] and [TP2] coordinates.

4. Liquidity & Seans Filter:
Avoid shorting a resistance level if a major "Buy Liquidity Pool" sits right above it, especially during New York session openings, as market makers are highly probable to hunt those levels first.

🎛️ Settings Dashboard Control

* Core Engine Settings: Toggles labels and configures multi-timeframe request horizons.
* Trend & Ribbon Dashboard: Features an inline compact grid layout to selectively toggle independent MA lengths and Kijun vectors.
* Quant Studio & Plugins: Configures smart confluences, Volume POC tracks, ATR lengths, Liquidity modules, and Session trackers.
* Candle Overlay Profile: Dropdown menu selector to switch between various mathematical bar-coloring systems.
* Theme & Styling Controls: Complete visual customization over colors, line weights, and line styles (Solid, Dashed, Dotted).

📌 Credits and Origins

G-ALPHA is engineered by gunebak4n as an advanced, multi-modular terminal workspace designed to bridge the gap between complex multi-timeframe analytics and seamless execution. The architecture is intentionally optimized for professional traders, systematic strategy developers, and technical purists who require strict mathematical objectivity and a clean, clutter-free workspace.

The model prioritizes script execution speed, visual grid alignment, and complete parameters flexibility without compromising deep institutional analytical data.

⚠️ Disclaimer

All analytical outputs, signals, and values generated by Alpha Terminal Studio (G-ALPHA) are purely probabilistic and non-deterministic. This indicator does not guarantee future price direction, market outcomes, or trading profitability. It is a mathematical structure tool intended to assist disciplined decision-making under market uncertainty. Proper position sizing and independent risk management are mandatory requirements at all times.

## Source Code

````pine
//@version=6
// +----------------------------------------------------------------------------+
// | Author: gunebak4n                                                          |
// | Indicator: Alpha Terminal Studio (G-ALPHA)                       |
// | Description: Institutional-grade terminal studio featuring MTF Fib Pivots,  |
// |              inline MA ribbons, Ichimoku Kijun lines, volume POC tracking, |
// |              liquidity hunting zones, session profiles, and trend matrix.  |
// +----------------------------------------------------------------------------+
indicator('Alpha Terminal Studio', shorttitle = 'G-ALPHA', overlay = true)

// ==============================================================================
// 1. GLOBAL & TIMEFRAME CONFIGURATION (User-Friendly UI Group)
// ==============================================================================
show_labels = input.bool(true, title = 'Display Level Labels', group = '--- 1. CORE ENGINE SETTINGS ---', tooltip = 'Toggles the right-side real-time data panels on/off.')
pivot_tf = input.timeframe('', title = 'Pivot Timeframe', options = ['', '1', '3', '5', '15', '30', '45', '60', '120', '240', 'D', 'W', 'M'], group = '--- 1. CORE ENGINE SETTINGS ---', tooltip = 'Select chart timeframe for Fibo calculation. Leaving empty matches your current active chart.')

current_tf = pivot_tf == '' ? timeframe.period : pivot_tf

// ==============================================================================
// 2. COMPACT INLINE RIBBONS & LINES CONTROL (Perfect Grid Alignment)
// ==============================================================================
show_d_kijun = input.bool(false, title = 'Daily Kijun', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'kijun', tooltip = 'Plots the Daily Ichimoku baseline balance vector.')
show_w_kijun = input.bool(false, title = 'Weekly Kijun', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'kijun', tooltip = 'Plots the Weekly Ichimoku baseline balance vector.')

show_ma_3 = input.bool(false, title = 'MA 3', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row1')
show_ma_13 = input.bool(false, title = '13', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row1')
show_ma_21 = input.bool(false, title = '21', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row1')
show_ma_30 = input.bool(false, title = '30', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row1')

show_ma_34 = input.bool(false, title = 'MA 34', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row2')
show_ma_49 = input.bool(false, title = '49', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row2')
show_ma_55 = input.bool(false, title = '55', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row2')
show_ma_80 = input.bool(false, title = '80', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row2')

show_ma_89 = input.bool(false, title = 'MA 89', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row3')
show_ma_130 = input.bool(false, title = '130', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row3')
show_ma_144 = input.bool(false, title = '144', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row3')
show_ma_210 = input.bool(false, title = '210', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row3')

show_ma_233 = input.bool(false, title = 'MA 233', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row4')
show_ma_341 = input.bool(false, title = '341', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row4')
show_ma_377 = input.bool(false, title = '377', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row4')
show_ma_551 = input.bool(false, title = '551', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row4')

show_ma_610 = input.bool(false, title = 'MA 610', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row5')
show_ma_892 = input.bool(false, title = '892', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row5')
show_ma_987 = input.bool(false, title = '987', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row5')

show_ma_1444 = input.bool(false, title = '1444', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row6')
show_ma_1597 = input.bool(false, title = '1597', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row6')
show_ma_2337 = input.bool(false, title = '2337', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row6')

show_ma_2584 = input.bool(false, title = '2584', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row7')
show_ma_3781 = input.bool(false, title = '3781', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row7')
show_ma_4181 = input.bool(false, title = '4181', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row7')
show_ma_4827 = input.bool(false, title = '4827', group = '--- 2. TREND & RIBBON DASHBOARD ---', inline = 'row7')

// ==============================================================================
// 3. ADVANCED ALGORITHMS & PLUGINS (User Screenshot Inspired Layout)
// ==============================================================================
show_confluence = input.bool(false, title = 'Confluence Detector', group = '--- 3. QUANT STUDIO & PLUGINS ---', inline = 'adv1', tooltip = 'Highlights label boxes in Gold when lines overlap near a Fibo point.')
show_poc = input.bool(false, title = 'Volume POC Line', group = '--- 3. QUANT STUDIO & PLUGINS ---', inline = 'adv1', tooltip = 'Draws the horizontal institutional Point of Control line based on volume profile peaks.')
show_signals = input.bool(false, title = 'Trigger Arrows', group = '--- 3. QUANT STUDIO & PLUGINS ---', inline = 'adv2', tooltip = 'Triggers directional execution markers on key candle patterns.')
atr_len = input.int(14, title = 'ATR Period', minval = 1, group = '--- 3. QUANT STUDIO & PLUGINS ---', inline = 'adv2', tooltip = 'Volatility depth calculation range for trailing stops.')

// Elit Modüller Girdileri (Horizontal Aligned)
show_liquidity = input.bool(false, title = 'Liquidity Pools', group = '--- 3. QUANT STUDIO & PLUGINS ---', inline = 'adv3', tooltip = 'Tracks swing high/low points to map out institutional order blocks.')
show_sessions = input.bool(false, title = 'Session Lines', group = '--- 3. QUANT STUDIO & PLUGINS ---', inline = 'adv3', tooltip = 'Highlights Asia, London, and NY opening market cross-sections.')
show_matrix = input.bool(false, title = 'MTF Trend Matrix', group = '--- 3. QUANT STUDIO & PLUGINS ---', inline = 'adv3', tooltip = 'Deploys an upper-right monitoring matrix table covering multi-timeframe vectors.')

candle_mode = input.string('None', title = 'Candle Overlay Profile', options = ['None', 'Kijun-sen Trend', 'ATR Intensity', 'Extreme Fibo Zones', 'Signal Confirmation'], group = '--- 3. QUANT STUDIO & PLUGINS ---', tooltip = 'Applies alternative quantitative coloring formulas onto candles.')

// ==============================================================================
// 4. VISUAL STYLE ENGINE & PALETTE MAPS
// ==============================================================================
line_style_input = input.string('Dashed', title = 'Fibo Levels Line Style', options = ['Dashed', 'Solid', 'Dotted'], group = '--- 4. THEME & STYLING CONTROLS ---')
chosen_line_style = line_style_input == 'Solid' ? line.style_solid : line_style_input == 'Dotted' ? line.style_dotted : line.style_dashed
line_width = input.int(2, title = 'Fibo Levels Line Weight', minval = 1, maxval = 5, group = '--- 4. THEME & STYLING CONTROLS ---')

pivot_color = input.color(color.gray, title = 'Fibo Center Pivot', group = '--- 4. THEME & STYLING CONTROLS ---', inline = 'palette1')
res_color = input.color(color.red, title = 'Resistance Channels', group = '--- 4. THEME & STYLING CONTROLS ---', inline = 'palette1')
sup_color = input.color(color.green, title = 'Support Channels', group = '--- 4. THEME & STYLING CONTROLS ---', inline = 'palette2')
bg_color = input.color(color.black, title = 'Label Boxes Fill', group = '--- 4. THEME & STYLING CONTROLS ---', inline = 'palette2')
conf_color = input.color(#FFD700, title = 'Confluence Alerts Color', group = '--- 4. THEME & STYLING CONTROLS ---', inline = 'palette3')
ma_color = input.color(color.white, title = 'Ribbon Waves Primary', group = '--- 4. THEME & STYLING CONTROLS ---', inline = 'palette3')
kijun_color = input.color(color.blue, title = 'Kijun Vectors Fill', group = '--- 4. THEME & STYLING CONTROLS ---', inline = 'palette4')
poc_color = input.color(color.orange, title = 'Volume Profile Line', group = '--- 4. THEME & STYLING CONTROLS ---', inline = 'palette4')

// ==============================================================================
// 5. CORE MATHEMATICS & SYSTEM SECURITY CALCULATION
// ==============================================================================
prev_high = request.security(syminfo.tickerid, current_tf, high[1], lookahead = barmerge.lookahead_off)
prev_low = request.security(syminfo.tickerid, current_tf, low[1], lookahead = barmerge.lookahead_off)
prev_close = request.security(syminfo.tickerid, current_tf, close[1], lookahead = barmerge.lookahead_off)

fib_pivot = (prev_high + prev_low + prev_close) / 3.0
range_tf = prev_high - prev_low

fib_res1 = fib_pivot + range_tf * 0.382
fib_res2 = fib_pivot + range_tf * 0.618
fib_res3 = fib_pivot + range_tf * 1.000

fib_sup1 = fib_pivot - range_tf * 0.382
fib_sup2 = fib_pivot - range_tf * 0.618
fib_sup3 = fib_pivot - range_tf * 1.000

// ==============================================================================
// 6. PROCESSING MOVING AVERAGE SCALABILITY INDICES
// ==============================================================================
ma3 = ta.sma(close, 3)
ma13 = ta.sma(close, 13)
ma21 = ta.sma(close, 21)
ma30 = ta.sma(close, 30)
ma34 = ta.sma(close, 34)
ma49 = ta.sma(close, 49)
ma55 = ta.sma(close, 55)
ma80 = ta.sma(close, 80)
ma89 = ta.sma(close, 89)
ma130 = ta.sma(close, 130)
ma144 = ta.sma(close, 144)
ma210 = ta.sma(close, 210)
ma233 = ta.sma(close, 233)
ma341 = ta.sma(close, 341)
ma377 = ta.sma(close, 377)
ma551 = ta.sma(close, 551)
ma610 = ta.sma(close, 610)
ma892 = ta.sma(close, 892)
ma987 = ta.sma(close, 987)
ma1444 = ta.sma(close, 1444)
ma1597 = ta.sma(close, 1597)
ma2337 = ta.sma(close, 2337)
ma2584 = ta.sma(close, 2584)
ma3781 = ta.sma(close, 3781)
ma4181 = ta.sma(close, 4181)
ma4827 = ta.sma(close, 4827)

plot(show_ma_3 ? ma3 : na, title = 'MA 3', color = color.new(ma_color, 45))
plot(show_ma_13 ? ma13 : na, title = 'MA 13', color = color.new(ma_color, 40))
plot(show_ma_21 ? ma21 : na, title = 'MA 21', color = color.new(ma_color, 35))
plot(show_ma_30 ? ma30 : na, title = 'MA 30', color = color.new(ma_color, 30))
plot(show_ma_34 ? ma34 : na, title = 'MA 34', color = color.new(ma_color, 25))
plot(show_ma_49 ? ma49 : na, title = 'MA 49', color = color.new(ma_color, 20))
plot(show_ma_55 ? ma55 : na, title = 'MA 55', color = color.new(ma_color, 15))
plot(show_ma_80 ? ma80 : na, title = 'MA 80', color = color.new(ma_color, 10))
plot(show_ma_89 ? ma89 : na, title = 'MA 89', color = color.new(ma_color, 5))
plot(show_ma_130 ? ma130 : na, title = 'MA 130', color = color.new(ma_color, 0))
plot(show_ma_144 ? ma144 : na, title = 'MA 144', color = ma_color)
plot(show_ma_210 ? ma210 : na, title = 'MA 210', color = ma_color)
plot(show_ma_233 ? ma233 : na, title = 'MA 233', color = ma_color)
plot(show_ma_341 ? ma341 : na, title = 'MA 341', color = ma_color)
plot(show_ma_377 ? ma377 : na, title = 'MA 377', color = ma_color)
plot(show_ma_551 ? ma551 : na, title = 'MA 551', color = ma_color)
plot(show_ma_610 ? ma610 : na, title = 'MA 610', color = ma_color)
plot(show_ma_892 ? ma892 : na, title = 'MA 892', color = ma_color)
plot(show_ma_987 ? ma987 : na, title = 'MA 987', color = ma_color)
plot(show_ma_1444 ? ma1444 : na, title = 'MA 1444', color = ma_color)
plot(show_ma_1597 ? ma1597 : na, title = 'MA 1597', color = ma_color)
plot(show_ma_2337 ? ma2337 : na, title = 'MA 2337', color = ma_color)
plot(show_ma_2584 ? ma2584 : na, title = 'MA 2584', color = ma_color)
plot(show_ma_3781 ? ma3781 : na, title = 'MA 3781', color = ma_color)
plot(show_ma_4181 ? ma4181 : na, title = 'MA 4181', color = ma_color)
plot(show_ma_4827 ? ma4827 : na, title = 'MA 4827', color = ma_color)

f_kijun() =>
    math.avg(ta.highest(high, 26), ta.lowest(low, 26))
daily_kijun = request.security(syminfo.tickerid, 'D', f_kijun(), lookahead = barmerge.lookahead_off)
weekly_kijun = request.security(syminfo.tickerid, 'W', f_kijun(), lookahead = barmerge.lookahead_off)

plot(show_d_kijun ? daily_kijun : na, title = 'Daily Kijun-sen', color = kijun_color, linewidth = 2)
plot(show_w_kijun ? weekly_kijun : na, title = 'Weekly Kijun-sen', color = color.new(kijun_color, 40), linewidth = 2)

// ==============================================================================
// 7. QUANT MODULES DEVELOPMENT: VOLUME POC & SMART CONFLUENCE ENGINE
// ==============================================================================
highest_vol = ta.highest(volume, 100)
var float session_poc = na
if volume == highest_vol
    session_poc := close
    session_poc

plot(show_poc ? session_poc : na, title = 'Volume POC Line', color = poc_color, style = plot.style_stepline, linewidth = 2)

my_atr = ta.atr(atr_len)

f_check_conf(float level) =>
    has_conf = false
    thresh = level * 0.0015
    if show_ma_3 and math.abs(ma3 - level) <= thresh or show_ma_13 and math.abs(ma13 - level) <= thresh or show_ma_21 and math.abs(ma21 - level) <= thresh or show_ma_30 and math.abs(ma30 - level) <= thresh or show_ma_89 and math.abs(ma89 - level) <= thresh or show_ma_144 and math.abs(ma144 - level) <= thresh or show_d_kijun and math.abs(daily_kijun - level) <= thresh
        has_conf := true
        has_conf
    has_conf

lbl_bg_p = show_confluence and f_check_conf(fib_pivot) ? conf_color : bg_color
lbl_bg_r1 = show_confluence and f_check_conf(fib_res1) ? conf_color : bg_color
lbl_bg_r2 = show_confluence and f_check_conf(fib_res2) ? conf_color : bg_color
lbl_bg_r3 = show_confluence and f_check_conf(fib_res3) ? conf_color : bg_color
lbl_bg_s1 = show_confluence and f_check_conf(fib_sup1) ? conf_color : bg_color
lbl_bg_s2 = show_confluence and f_check_conf(fib_sup2) ? conf_color : bg_color
lbl_bg_s3 = show_confluence and f_check_conf(fib_sup3) ? conf_color : bg_color

f_txt_col(color bg, color def) =>
    bg == conf_color ? color.black : def

// ==============================================================================
// 8. STRUCTURAL CANDLESTICK TRIGGERS PIPELINE
// ==============================================================================
body_size = math.abs(close - open)
is_pinbar = close > open and high - close > body_size * 2 or close < open and open - low > body_size * 2

near_level = false
if show_signals or candle_mode == 'Signal Confirmation' or candle_mode == 'Extreme Fibo Zones'
    levels_array = array.from(fib_pivot, fib_res1, fib_res2, fib_res3, fib_sup1, fib_sup2, fib_sup3)
    for i = 0 to array.size(levels_array) - 1 by 1
        if math.abs(close - array.get(levels_array, i)) <= close * 0.002
            near_level := true
            break

buy_sig = show_signals and near_level and is_pinbar and close > open
sell_sig = show_signals and near_level and is_pinbar and close < open

plotshape(buy_sig, title = 'Bullish Trigger', style = shape.triangleup, location = location.belowbar, color = color.green, size = size.small)
plotshape(sell_sig, title = 'Bearish Trigger', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small)

// ==============================================================================
// 9. CONDITIONAL CANDLE COLORING DASHBOARD CORES
// ==============================================================================
atr_avg = ta.sma(my_atr, 20)
var color dynamic_candle_color = na

if candle_mode == 'Kijun-sen Trend'
    dynamic_candle_color := close > daily_kijun ? color.new(#00E5FF, 10) : color.new(#FF1744, 10)
    dynamic_candle_color
else if candle_mode == 'ATR Intensity'
    dynamic_candle_color := my_atr > atr_avg ? close > open ? color.new(color.green, 0) : color.new(color.red, 0) : color.new(color.gray, 40)
    dynamic_candle_color
else if candle_mode == 'Extreme Fibo Zones'
    dynamic_candle_color := math.abs(close - fib_res3) <= close * 0.005 ? color.yellow : math.abs(close - fib_sup3) <= close * 0.005 ? color.purple : na
    dynamic_candle_color
else if candle_mode == 'Signal Confirmation'
    dynamic_candle_color := near_level and is_pinbar and close > open ? #00FF88 : near_level and is_pinbar and close < open ? #FF0055 : na
    dynamic_candle_color
else
    dynamic_candle_color := na
    dynamic_candle_color

barcolor(candle_mode != 'None' ? dynamic_candle_color : na)

// ==============================================================================
// 10. ELIT DEVELOPMENT MODÜLLERİ: LİKİDİTE, SEANSLAR VE TREND MATRİSİ
// ==============================================================================
liq_high_val = ta.highest(high, 50)[1]
liq_low_val = ta.lowest(low, 50)[1]

plot(show_liquidity ? liq_high_val : na, title = 'Buy Liquidity Pool', color = color.new(color.blue, 60), style = plot.style_linebr, linewidth = 2)
plot(show_liquidity ? liq_low_val : na, title = 'Sell Liquidity Pool', color = color.new(color.orange, 60), style = plot.style_linebr, linewidth = 2)

is_asia = hour == 0 and minute == 0
is_lon = hour == 7 and minute == 0
is_ny = hour == 12 and minute == 0
session_bg = show_sessions and is_asia ? color.new(color.blue, 95) : show_sessions and is_lon ? color.new(color.green, 95) : show_sessions and is_ny ? color.new(color.red, 95) : na
bgcolor(session_bg)

var table trend_matrix = table.new(position.top_right, 5, 2, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.gray)

c_5m = request.security(syminfo.tickerid, '5', close, lookahead = barmerge.lookahead_off)
k_5m = request.security(syminfo.tickerid, '5', math.avg(ta.highest(high, 26), ta.lowest(low, 26)), lookahead = barmerge.lookahead_off)
t_5m = c_5m > k_5m ? 'BULL' : 'BEAR'

c_15m = request.security(syminfo.tickerid, '15', close, lookahead = barmerge.lookahead_off)
k_15m = request.security(syminfo.tickerid, '15', math.avg(ta.highest(high, 26), ta.lowest(low, 26)), lookahead = barmerge.lookahead_off)
t_15m = c_15m > k_15m ? 'BULL' : 'BEAR'

c_1h = request.security(syminfo.tickerid, '60', close, lookahead = barmerge.lookahead_off)
k_1h = request.security(syminfo.tickerid, '60', math.avg(ta.highest(high, 26), ta.lowest(low, 26)), lookahead = barmerge.lookahead_off)
t_1h = c_1h > k_1h ? 'BULL' : 'BEAR'

c_1d = request.security(syminfo.tickerid, 'D', close, lookahead = barmerge.lookahead_off)
k_1d = request.security(syminfo.tickerid, 'D', math.avg(ta.highest(high, 26), ta.lowest(low, 26)), lookahead = barmerge.lookahead_off)
t_1d = c_1d > k_1d ? 'BULL' : 'BEAR'

if show_matrix and barstate.islast
    table.cell(trend_matrix, 0, 0, 'TF Matrix', text_color = color.white, text_size = size.small)
    table.cell(trend_matrix, 1, 0, '5M', text_color = color.white, text_size = size.small)
    table.cell(trend_matrix, 2, 0, '15M', text_color = color.white, text_size = size.small)
    table.cell(trend_matrix, 3, 0, '1H', text_color = color.white, text_size = size.small)
    table.cell(trend_matrix, 4, 0, 'DAILY', text_color = color.white, text_size = size.small)

    table.cell(trend_matrix, 0, 1, 'Trend', text_color = color.gray, text_size = size.small)
    table.cell(trend_matrix, 1, 1, t_5m, bgcolor = t_5m == 'BULL' ? color.green : color.red, text_color = color.white, text_size = size.small)
    table.cell(trend_matrix, 2, 1, t_15m, bgcolor = t_15m == 'BULL' ? color.green : color.red, text_color = color.white, text_size = size.small)
    table.cell(trend_matrix, 3, 1, t_1h, bgcolor = t_1h == 'BULL' ? color.green : color.red, text_color = color.white, text_size = size.small)
    table.cell(trend_matrix, 4, 1, t_1d, bgcolor = t_1d == 'BULL' ? color.green : color.red, text_color = color.white, text_size = size.small)

tf_label = current_tf == '1' ? '1m' : current_tf == '3' ? '3m' : current_tf == '5' ? '5m' : current_tf == '15' ? '15m' : current_tf == '30' ? '30m' : current_tf == '45' ? '45m' : current_tf == '60' ? '1H' : current_tf == '120' ? '2H' : current_tf == '240' ? '4H' : current_tf == 'D' ? 'Daily' : current_tf == 'W' ? 'Weekly' : current_tf == 'M' ? 'Monthly' : current_tf

// ==============================================================================
// 11. REAL-TIME CANVAS DRAWING ENGINE (DYNAMIC TARGET SPREADS MERGED)
// ==============================================================================
var line l_p = na
var line l_r1 = na
var line l_r2 = na
var line l_r3 = na
var line l_s1 = na
var line l_s2 = na
var line l_s3 = na

var label lbl_p = na
var label lbl_r1 = na
var label lbl_r2 = na
var label lbl_r3 = na
var label lbl_s1 = na
var label lbl_s2 = na
var label lbl_s3 = na

if barstate.islast
    x1 = bar_index - 3
    x2 = bar_index + 5

    line.delete(l_p)
    line.delete(l_r1)
    line.delete(l_r2)
    line.delete(l_r3)
    line.delete(l_s1)
    line.delete(l_s2)
    line.delete(l_s3)

    label.delete(lbl_p)
    label.delete(lbl_r1)
    label.delete(lbl_r2)
    label.delete(lbl_r3)
    label.delete(lbl_s1)
    label.delete(lbl_s2)
    label.delete(lbl_s3)

    l_p := line.new(x1, fib_pivot, x2, fib_pivot, color = pivot_color, style = chosen_line_style, width = line_width)
    l_r1 := line.new(x1, fib_res1, x2, fib_res1, color = res_color, style = chosen_line_style, width = line_width)
    l_r2 := line.new(x1, fib_res2, x2, fib_res2, color = res_color, style = chosen_line_style, width = line_width)
    l_r3 := line.new(x1, fib_res3, x2, fib_res3, color = res_color, style = chosen_line_style, width = line_width)

    l_s1 := line.new(x1, fib_sup1, x2, fib_sup1, color = sup_color, style = chosen_line_style, width = line_width)
    l_s2 := line.new(x1, fib_sup2, x2, fib_sup2, color = sup_color, style = chosen_line_style, width = line_width)
    l_s3 := line.new(x1, fib_sup3, x2, fib_sup3, color = sup_color, style = chosen_line_style, width = line_width)

    if show_labels
        lbl_p := label.new(bar_index - 12, fib_pivot, 'Fib Pivot (' + tf_label + ')   ' + str.tostring(fib_pivot, '#.##'), color = lbl_bg_p, textcolor = f_txt_col(lbl_bg_p, pivot_color), style = label.style_label_right)
        lbl_r1 := label.new(bar_index - 12, fib_res1, 'Fib Res 1 (' + tf_label + ')   ' + str.tostring(fib_res1, '#.##') + ' [SL: ' + str.tostring(fib_res1 + my_atr, '#.##') + '] [TP1: ' + str.tostring(fib_pivot, '#.##') + ' / TP2: ' + str.tostring(fib_sup1, '#.##') + ']', color = lbl_bg_r1, textcolor = f_txt_col(lbl_bg_r1, res_color), style = label.style_label_right)
        lbl_r2 := label.new(bar_index - 12, fib_res2, 'Fib Res 2 (' + tf_label + ')   ' + str.tostring(fib_res2, '#.##') + ' [SL: ' + str.tostring(fib_res2 + my_atr, '#.##') + '] [TP1: ' + str.tostring(fib_res1, '#.##') + ' / TP2: ' + str.tostring(fib_pivot, '#.##') + ']', color = lbl_bg_r2, textcolor = f_txt_col(lbl_bg_r2, res_color), style = label.style_label_right)
        lbl_r3 := label.new(bar_index - 12, fib_res3, 'Fib Res 3 (' + tf_label + ')   ' + str.tostring(fib_res3, '#.##') + ' [SL: ' + str.tostring(fib_res3 + my_atr, '#.##') + '] [TP1: ' + str.tostring(fib_res2, '#.##') + ' / TP2: ' + str.tostring(fib_res1, '#.##') + ']', color = lbl_bg_r3, textcolor = f_txt_col(lbl_bg_r3, res_color), style = label.style_label_right)

        lbl_s1 := label.new(bar_index - 12, fib_sup1, 'Fib Sup 1 (' + tf_label + ')   ' + str.tostring(fib_sup1, '#.##') + ' [SL: ' + str.tostring(fib_sup1 - my_atr, '#.##') + '] [TP1: ' + str.tostring(fib_pivot, '#.##') + ' / TP2: ' + str.tostring(fib_res1, '#.##') + ']', color = lbl_bg_s1, textcolor = f_txt_col(lbl_bg_s1, sup_color), style = label.style_label_right)
        lbl_s2 := label.new(bar_index - 12, fib_sup2, 'Fib Sup 2 (' + tf_label + ')   ' + str.tostring(fib_sup2, '#.##') + ' [SL: ' + str.tostring(fib_sup2 - my_atr, '#.##') + '] [TP1: ' + str.tostring(fib_sup1, '#.##') + ' / TP2: ' + str.tostring(fib_pivot, '#.##') + ']', color = lbl_bg_s2, textcolor = f_txt_col(lbl_bg_s2, sup_color), style = label.style_label_right)
        lbl_s3 := label.new(bar_index - 12, fib_sup3, 'Fib Sup 3 (' + tf_label + ')   ' + str.tostring(fib_sup3, '#.##') + ' [SL: ' + str.tostring(fib_sup3 - my_atr, '#.##') + '] [TP1: ' + str.tostring(fib_sup2, '#.##') + ' / TP2: ' + str.tostring(fib_sup1, '#.##') + ']', color = lbl_bg_s3, textcolor = f_txt_col(lbl_bg_s3, sup_color), style = label.style_label_right)
        lbl_s3
````
