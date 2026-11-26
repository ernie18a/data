# PIGO TREND ATR EXT v2

- url: https://www.tradingview.com/script/pLrHIfk1/
- type: indicator
- pine_id: PUB;9a621fb0fcdc4d7cb33d25b08444b0b4
- version: 1.0

## Description

PIGO TREND ATR EXT — Multi-Timeframe Trend, Strength & Exhaustion Dashboard

A comprehensive multi-timeframe analysis tool that combines trend direction, 
momentum strength (ADX), volatility (ATR), and statistical exhaustion (Z-score 
multilayer) in a single configurable dashboard. Built for traders who need 
clear, structured information to identify three distinct setup types: early 
continuation, consolidated continuation, and fade at target zones.

🎯 PURPOSE

This indicator solves a fundamental problem in multi-timeframe analysis: 
distinguishing healthy trend extension from genuine exhaustion. Traditional 
distance-from-EMA metrics produce false exhaustion signals during sustained 
trends. This indicator uses a multi-layer Z-score system that filters real 
exhaustion from normal trend extension.

📊 HOW IT WORKS

For each configurable timeframe, the indicator displays four metrics:

1. TREND DIRECTION
   - 🟢 Uptrend (EMA rising)
   - 🔴 Downtrend (EMA falling)
   - ⚫️ Neutral (no clear direction)
   
   Two trend identification methods available: direction of single EMA, or 
   comparison between two EMAs.

2. STRENGTH (FORCE) — ADX-based
   - 💪 Strong (ADX above strong threshold)
   - 👊 Medium (ADX between thresholds)
   - 🤏 Weak (ADX below weak threshold)
   
   Customizable ADX length and threshold values.

3. EXHAUSTION (Z-SCORE MULTILAYER) — The key innovation
   - ✅ Normal (no exhaustion detected)
   - ⚠️ Warning (one layer triggered)
   - 🔥 Extreme (multiple layers confirmed)
   
   Calculated through three independent layers:
   
   Layer 1 — Statistical extension:
   Z-score of distance between price and EMA, normalized by historical 
   standard deviation. Detects positions that are statistically rare for 
   the instrument's recent behavior, NOT just absolute extension.
   
   Layer 2 — Acceleration:
   Compares recent price velocity to average velocity. Detects parabolic 
   acceleration that typically precedes reversals.
   
   Layer 3 — RSI extreme:
   Confirms statistical extreme through traditional RSI overbought/oversold 
   levels.
   
   The 🔥 signal only triggers when at least 2 of 3 layers align (configurable). 
   This eliminates the false positives common in single-metric exhaustion 
   indicators during sustained trends.

4. ATR — Volatility reference
   Standard ATR for the timeframe, useful for stop-loss sizing and 
   position management.

🔄 MULTI-TIMEFRAME ARCHITECTURE

Up to 19 timeframes can be displayed simultaneously, from 1m to Monthly. 
Each timeframe is calculated independently using request.security() with 
proper context handling. Values remain consistent regardless of which 
chart the indicator is applied to.

📋 DASHBOARD

Real-time table displays:
- Timeframe label
- Trend direction (with background color)
- Strength indicator
- Exhaustion indicator with Z-score value (in σ)
- ATR value
- EMA value (optional)

Position and size are fully configurable.

🎯 THREE OPERATIONAL SETUPS IDENTIFIED

This indicator helps identify three distinct trading patterns through specific 
combinations of trend, force, and exhaustion readings:

1. EARLY CONTINUATION
   Pattern: Trend defined + Force 👊 + Z-score negative (~-1)
   Interpretation: Pullback completed after impulse, retest opportunity
   Best for: Entry after recent trend change at structural level

2. CONSOLIDATED CONTINUATION
   Pattern: Trend defined + Force 💪 + Z-score warning (+1.5 to +2.5σ)
   Interpretation: Mature trend with sustained momentum
   Best for: Riding established trends with clear momentum

3. FADE AT TARGET ZONE
   Pattern: Trend + Force 💪 + Z-score extreme (>+2.8σ) + 🔥
   Interpretation: Climax reading at statistical extreme
   Best for: Counter-trend entries at Fibonacci targets, prior highs/lows, 
   or liquidity sweep zones, when combined with technical confluence

⚙️ RECOMMENDED CONFIGURATION

For scalping (NQ, ES, futures):
- EMA Length: 21 (single EMA approach)
- ADX Length: 9, Weak: 18, Strong: 35
- Z-score Lookback: 80
- Z-score Warning: 1.8σ / Extreme: 2.8σ
- Acceleration Threshold: 1.4
- RSI Length: 14, Overbought: 78, Oversold: 22
- Layers Required for 🔥: 2
- Smoothed Close: ON
- Active TFs: 5m, 15m, 1h

For swing trading (4H+):
- EMA Length: 50/200 (two-EMA comparison)
- ADX Length: 14, Weak: 20, Strong: 40
- Z-score thresholds: same as scalping
- Active TFs: 1h, 4h, D, W

🎓 KEY ADVANTAGES OVER TRADITIONAL METHODS

Traditional "distance from EMA in ATRs" methods produce constant 🔥 signals 
during strong trends because price naturally stays far from EMA in trending 
markets. This creates false exhaustion alerts.

The Z-score multilayer system addresses this by:

1. Normalizing distance against the instrument's OWN recent history 
   (not absolute values)
2. Requiring acceleration as confirmation (real exhaustion typically 
   shows parabolic acceleration before reversal)
3. Adding RSI extreme as a third independent filter
4. Requiring multiple layers to align before triggering 🔥

This produces clean, reliable exhaustion signals that align with real 
reversal points rather than firing constantly during healthy trends.

🔔 ALERTS

Multiple alert conditions available:
- Trend changes (overall, uptrend start, downtrend start, neutral)
- Multi-timeframe alignments (3D+D+4h, D+4h+1h, 4h+1h+15m, 1h+15m+5m, 
  15m+5m+3m, 5m+3m+1m)

Useful for setting notifications when specific timeframe combinations align 
in the same direction, indicating high-probability continuation setups.

📊 DASHBOARD CUSTOMIZATION

All visual elements are configurable:
- Position (top right, bottom right, middle, etc.)
- Text size (tiny, small, normal, large)
- Background colors per trend state
- Indicator emojis (customizable for each state)
- Show/hide individual columns (Strength, ATR, Extension, EMA value)
- Header on/off
- Active timeframes (toggle each individually)

⚠️ LIMITATIONS

- Requires sufficient historical bars on each timeframe for accurate Z-score 
  calculation (lookback of 80 bars)
- In extremely illiquid markets, ADX values may be unreliable
- Daily/Weekly timeframe values may need adjustment for instruments with 
  significant gaps
- Best suited for liquid markets (futures, major forex pairs, large-cap 
  stocks, major crypto)

🎓 RECOMMENDED USE

This is a context indicator, not an automatic entry trigger. It provides 
structured information to help traders identify high-quality setups. For 
maximum effectiveness, combine with:

- Technical zone analysis (Fibonacci levels, support/resistance, prior 
  highs/lows)
- Structural confirmations (Break of Structure, Fair Value Gaps, liquidity 
  sweeps)
- Multi-timeframe momentum confirmation (e.g., RSI/KDE indicators for 
  precise timing)

The three-layer exhaustion system specifically helps avoid the most common 
fade trading mistake: shorting strong uptrends just because price has moved 
"a lot" in absolute terms. Real exhaustion requires statistical rarity, 
acceleration, AND momentum extreme — not just distance.

## Source Code

````pine
//@version=6
indicator("PIGO TREND ATR EXT v2", shorttitle = "PigoTRATR+v2", overlay = true, scale = scale.none, dynamic_requests = true)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* BAR SETTINGS *//
paint_bars             = input(false, title = "Paint bars?", group = 'Bars Settings')
catch_flat             = input(false, title = "Try to catch flat?", group = 'Bars Settings')
uptrend_colour         = input.color(color.green, title = "Uptrend colour",    group = 'Bars Settings')
downtrend_colour       = input.color(color.red,   title = "Downtrend colour",  group = 'Bars Settings')
neutraltrend_colour    = input.color(color.gray,  title = "Neutraltrend colour", group = 'Bars Settings')
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* TABLE SETTINGS *//
show_header            = input(false, title = "Show header?",              group = 'Table Settings')
show_ema_value         = input(false, title = "Show EMA value?",           group = 'Table Settings')
show_strength          = input(true,  title = "Show trend strength?",      group = 'Table Settings')
show_atr               = input(true,  title = "Show ATR?",                 group = 'Table Settings')
show_extension         = input(true,  title = "Show exhaustion?",          group = 'Table Settings')
dashboard_position     = input.session("Middle right", "Position", ["Top right", "Bottom right", "Top left", "Bottom left", "Top center", "Bottom center", "Middle right"], group = 'Table Settings')
text_size              = input.session('Small', "Size", options = ["Tiny", "Small", "Normal", "Large"], group = 'Table Settings')
text_color             = input.color(color.white, title = "Text colour",   group = 'Table Settings')
table_color            = input.color(color.gray,  title = "Border colour", group = 'Table Settings')
uptrend_indicator      = input("🟢",  title = "Uptrend indicator",      group = 'Table Settings')
downtrend_indicator    = input("🔴",  title = "Downtrend indicator",    group = 'Table Settings')
neutraltrend_indicator = input("⚫️", title = "Neutraltrend indicator", group = 'Table Settings')
strong_trend_indicator = input("💪", title = "Strong trend indicator", group = 'Table Settings')
medium_trend_indicator = input("👊", title = "Medium trend indicator", group = 'Table Settings')
weak_trend_indicator   = input("🤏", title = "Weak trend indicator",   group = 'Table Settings')
ext_normal_indicator   = input("✅", title = "Exhaustion normal indicator",  group = 'Table Settings')
ext_warning_indicator  = input("⚠️", title = "Exhaustion warning indicator", group = 'Table Settings')
ext_extreme_indicator  = input("🔥", title = "Exhaustion extreme indicator", group = 'Table Settings')
header_bg_color        = input.color(color.rgb(128, 128, 128, 75), title = "Header background colour",       group = 'Table Settings')
uptrend_bg_color       = input.color(color.rgb(76,  175, 80,  75), title = "Uptrend background colour",      group = 'Table Settings')
downtrend_bg_color     = input(color.rgb(255, 82,  82,  75),       title = "Downtrend background colour",    group = 'Table Settings')
neutraltrend_bg_color  = input(color.rgb(120, 123, 134, 75),       title = "Neutraltrend background colour", group = 'Table Settings')
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* ATR SETTINGS *//
atr_length = input.int(14, "ATR Length", minval = 1, group = 'ATR Settings')
atr_color  = input.color(color.yellow,  title = "ATR text colour", group = 'ATR Settings')
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* EMA SETTINGS — todo manual *//
trend_identification_approach = input.session("Direction of a single EMA", "Trend identification approach", ["Direction of a single EMA", "Comparison of the two EMAs"], group = '📈 EMA Settings')
ema1_length = input.int(21,  title = "Primary EMA length",    minval = 1, maxval = 800, group = '📈 EMA Settings')
ema2_length = input.int(50, title = "Secondary EMA length",   minval = 1, maxval = 800, group = '📈 EMA Settings')
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* ADX SETTINGS — todo manual *//
adx_length           = input.int(14, title = "ADX length",           minval = 1, maxval = 100, group = '💪 ADX Settings')
adx_weak_threshold   = input.int(20, title = "ADX weak threshold",   minval = 1, maxval = 100, group = '💪 ADX Settings')
adx_strong_threshold = input.int(40, title = "ADX strong threshold", minval = 1, maxval = 100, group = '💪 ADX Settings')
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* EXHAUSTION SETTINGS — sistema multicapa *//
ext_zscore_lookback   = input.int(50, title = "Z-score lookback bars", minval = 20, maxval = 200, group = '📐 Exhaustion Settings', tooltip = "Cuántas velas se usan para calcular el promedio y desviación estándar de la distancia precio-EMA. Más alto = más estable, menos sensible. 50 es buen balance.")
ext_zscore_warning    = input.float(1.5, title = "Z-score warning threshold", minval = 0.5, step = 0.1, group = '📐 Exhaustion Settings', tooltip = "Cuántas desviaciones estándar sobre el promedio para mostrar ⚠️. 1.5 = top 7% de extensión histórica.")
ext_zscore_extreme    = input.float(2.5, title = "Z-score extreme threshold", minval = 1.0, step = 0.1, group = '📐 Exhaustion Settings', tooltip = "Cuántas desviaciones estándar para mostrar 🔥. 2.5 = top 1% de extensión histórica.")
ext_accel_threshold   = input.float(1.5, title = "Acceleration threshold", minval = 1.0, step = 0.1, group = '📐 Exhaustion Settings', tooltip = "Velocidad reciente vs velocidad media. >1.5 indica aceleración parabólica.")
ext_rsi_length        = input.int(14, title = "RSI length", minval = 5, maxval = 50, group = '📐 Exhaustion Settings')
ext_rsi_overbought    = input.float(75, title = "RSI overbought", minval = 50, maxval = 95, group = '📐 Exhaustion Settings')
ext_rsi_oversold      = input.float(25, title = "RSI oversold", minval = 5, maxval = 50, group = '📐 Exhaustion Settings')
ext_require_layers    = input.int(2, title = "Layers required for 🔥", minval = 1, maxval = 3, group = '📐 Exhaustion Settings', tooltip = "Cuántas de las 3 capas (Z-score extremo, aceleración, RSI extremo) deben cumplirse para marcar 🔥. 2 = balance recomendado, 3 = muy estricto, 1 = muy sensible.")
ext_color             = input.color(color.orange, title = "Exhaustion text colour", group = '📐 Exhaustion Settings')
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* TIMEFRAME SETTINGS *//
show_1m  = input(true,  title = 'Show 1m',  group = 'Timeframe Settings')
show_2m  = input(false, title = 'Show 2m',  group = 'Timeframe Settings')
show_3m  = input(false, title = 'Show 3m',  group = 'Timeframe Settings')
show_5m  = input(true,  title = 'Show 5m',  group = 'Timeframe Settings')
show_10m = input(false, title = 'Show 10m', group = 'Timeframe Settings')
show_15m = input(true,  title = 'Show 15m', group = 'Timeframe Settings')
show_30m = input(false, title = 'Show 30m', group = 'Timeframe Settings')
show_45m = input(false, title = 'Show 45m', group = 'Timeframe Settings')
show_1h  = input(true,  title = 'Show 1h',  group = 'Timeframe Settings')
show_2h  = input(false, title = 'Show 2h',  group = 'Timeframe Settings')
show_3h  = input(false, title = 'Show 3h',  group = 'Timeframe Settings')
show_4h  = input(true,  title = 'Show 4h',  group = 'Timeframe Settings')
show_6h  = input(false, title = 'Show 6h',  group = 'Timeframe Settings')
show_8h  = input(false, title = 'Show 8h',  group = 'Timeframe Settings')
show_12h = input(false, title = 'Show 12h', group = 'Timeframe Settings')
show_D   = input(true,  title = 'Show D',   group = 'Timeframe Settings')
show_3D  = input(false, title = 'Show 3D',  group = 'Timeframe Settings')
show_W   = input(false, title = 'Show W',   group = 'Timeframe Settings')
show_M   = input(false, title = 'Show M',   group = 'Timeframe Settings')
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* TABLE POSITION & SIZE *//
var table_position =
 dashboard_position == 'Top right'      ? position.top_right     :
 dashboard_position == 'Top left'       ? position.top_left      :
 dashboard_position == 'Top center'     ? position.top_center    :
 dashboard_position == 'Bottom right'   ? position.bottom_right  :
 dashboard_position == 'Bottom left'    ? position.bottom_left   :
 dashboard_position == 'Bottom center'  ? position.bottom_center :
 position.middle_right
var table_text_size =
 text_size == 'Normal' ? size.normal :
 text_size == 'Large'  ? size.large  :
 text_size == 'Tiny'   ? size.tiny   :
 size.small
var t = table.new(position = table_position, columns = 6, rows = 21, frame_color = table_color, frame_width = 2, border_color = table_color, border_width = 2)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* CALCULATION FUNCTIONS *//
calc_smma(src, len) =>
    var float smma = na
    sma_val = ta.sma(src, len)
    smma := na(smma) ? sma_val : (smma[1] * (len - 1) + src) / len
    smma
calc_zlema(src, len) =>
    ema1 = ta.ema(src, len)
    ema2 = ta.ema(ema1, len)
    ema1 + (ema1 - ema2)
check_impulse() =>
    impulse_length   = 34
    impulse_strength = 9
    hi      = calc_smma(high,  impulse_length)
    lo      = calc_smma(low,   impulse_length)
    mi      = calc_zlema(hlc3, impulse_length)
    md      = mi > hi ? mi - hi : mi < lo ? mi - lo : 0.0
    md_prev = mi[1] > hi[1] ? mi[1] - hi[1] : mi[1] < lo[1] ? mi[1] - lo[1] : 0.0
    sb      = ta.sma(md,      impulse_strength)
    sb_prev = ta.sma(md_prev, impulse_strength)
    (md - sb) != 0 and (md_prev - sb_prev) != 0
calc_adx(len) =>
    up      = ta.change(high)
    down    = -ta.change(low)
    plusDM  = na(up)   ? na : up   > down and up   > 0 ? up   : 0.0
    minusDM = na(down) ? na : down > up   and down > 0 ? down : 0.0
    trur    = ta.rma(ta.tr, len)
    plus    = fixnan(100 * ta.rma(plusDM,  len) / trur)
    minus   = fixnan(100 * ta.rma(minusDM, len) / trur)
    sum     = plus + minus
    100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), len)
get_strength_indicator(adx_value) =>
    adx_value < adx_weak_threshold ? weak_trend_indicator : adx_value > adx_strong_threshold ? strong_trend_indicator : medium_trend_indicator
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* EXHAUSTION FUNCTION — Sistema multicapa Z-score + Aceleración + RSI *//
get_exhaustion() =>
    // Capa 1: Z-score de la distancia precio-EMA
    ema_val = ta.ema(close, ema1_length)
    distance = math.abs(close - ema_val)
    avg_distance = ta.sma(distance, ext_zscore_lookback)
    std_distance = ta.stdev(distance, ext_zscore_lookback)
    zscore = std_distance == 0 ? 0.0 : (distance - avg_distance) / std_distance
    
    // Capa 2: Aceleración (velocidad reciente vs media)
    velocity_recent = math.abs(close - close[3]) / 3
    velocity_avg = ta.sma(math.abs(close - close[1]), 20)
    acceleration = velocity_avg == 0 ? 1.0 : velocity_recent / velocity_avg
    
    // Capa 3: RSI extremo
    rsi_val = ta.rsi(close, ext_rsi_length)
    rsi_extreme = rsi_val >= ext_rsi_overbought or rsi_val <= ext_rsi_oversold
    
    // Determinar cuántas capas se cumplen
    layer1_extreme = zscore >= ext_zscore_extreme
    layer1_warning = zscore >= ext_zscore_warning and zscore < ext_zscore_extreme
    layer2 = acceleration >= ext_accel_threshold
    layer3 = rsi_extreme
    
    layers_count = (layer1_extreme ? 1 : 0) + (layer2 ? 1 : 0) + (layer3 ? 1 : 0)
    
    // Decisión final
    ext_indicator = layers_count >= ext_require_layers ? ext_extreme_indicator : (layer1_warning or layer1_extreme or layer2 or layer3) ? ext_warning_indicator : ext_normal_indicator
    
    [zscore, ext_indicator]
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* TREND STATUS *//
get_trend_status() =>
    impulse              = catch_flat ? check_impulse() : true
    ema1_cur             = ta.ema(close, ema1_length)
    ema1_prev            = ema1_cur[1]
    ema1_prev2           = ema1_cur[2]
    round_dec            = ema1_cur > 1000 ? 0 : ema1_cur > 10 ? 1 : ema1_cur > 0 ? 2 : ema1_cur > 0.1 ? 3 : 10
    ema1_str             = str.tostring(math.round(ema1_cur, round_dec))
    var string trend_cur  = na
    var string trend_prev = na
    var color  trend_bg   = na
    if trend_identification_approach == "Direction of a single EMA"
        trend_bg   := not impulse ? neutraltrend_bg_color : ema1_cur  > ema1_prev  ? uptrend_bg_color  : ema1_cur  < ema1_prev  ? downtrend_bg_color  : neutraltrend_bg_color
        trend_cur  := not impulse ? neutraltrend_indicator : ema1_cur  > ema1_prev  ? uptrend_indicator  : ema1_cur  < ema1_prev  ? downtrend_indicator  : neutraltrend_indicator
        trend_prev := not impulse ? neutraltrend_indicator : ema1_prev > ema1_prev2 ? uptrend_indicator  : ema1_prev < ema1_prev2 ? downtrend_indicator  : neutraltrend_indicator
    else
        ema2_cur  = ta.ema(close, ema2_length)
        ema2_prev = ema2_cur[1]
        trend_bg   := not impulse ? neutraltrend_bg_color : ema1_cur  > ema2_cur  ? uptrend_bg_color  : ema1_cur  < ema2_cur  ? downtrend_bg_color  : neutraltrend_bg_color
        trend_cur  := not impulse ? neutraltrend_indicator : ema1_cur  > ema2_cur  ? uptrend_indicator  : ema1_cur  < ema2_cur  ? downtrend_indicator  : neutraltrend_indicator
        trend_prev := not impulse ? neutraltrend_indicator : ema1_prev > ema2_prev ? uptrend_indicator  : ema1_prev < ema2_prev ? downtrend_indicator  : neutraltrend_indicator
    [ema1_str, trend_bg, trend_cur, trend_prev]
//* STRENGTH INTERMEDIA *//
get_strength_only() =>
    get_strength_indicator(calc_adx(adx_length))
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* ATR FUNCTIONS *//
get_atr(tf) =>
    request.security(syminfo.tickerid, tf, ta.atr(atr_length))
format_atr(val) =>
    if na(val)
        "—"
    else
        decimals = syminfo.mintick >= 1 ? 0 : syminfo.mintick >= 0.1 ? 1 : syminfo.mintick >= 0.01 ? 2 : 3
        str.tostring(math.round(val, decimals))
format_zscore(val) =>
    if na(val)
        "—"
    else
        str.tostring(math.round(val, 1)) + "σ"
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* MTF DATA REQUESTS — TF real para tendencia *//
[ema_1m,  bg_1m,  ind_1m,  _] = if show_1m
    request.security(syminfo.tickerid, "1", get_trend_status())
else
    [na, na, na, na]
[ema_2m,  bg_2m,  ind_2m,  _] = if show_2m
    request.security(syminfo.tickerid, "2", get_trend_status())
else
    [na, na, na, na]
[ema_3m,  bg_3m,  ind_3m,  _] = if show_3m
    request.security(syminfo.tickerid, "3", get_trend_status())
else
    [na, na, na, na]
[ema_5m,  bg_5m,  ind_5m,  _] = if show_5m
    request.security(syminfo.tickerid, "5", get_trend_status())
else
    [na, na, na, na]
[ema_10m, bg_10m, ind_10m, _] = if show_10m
    request.security(syminfo.tickerid, "10", get_trend_status())
else
    [na, na, na, na]
[ema_15m, bg_15m, ind_15m, _] = if show_15m
    request.security(syminfo.tickerid, "15", get_trend_status())
else
    [na, na, na, na]
[ema_30m, bg_30m, ind_30m, _] = if show_30m
    request.security(syminfo.tickerid, "30", get_trend_status())
else
    [na, na, na, na]
[ema_45m, bg_45m, ind_45m, _] = if show_45m
    request.security(syminfo.tickerid, "45", get_trend_status())
else
    [na, na, na, na]
[ema_1h,  bg_1h,  ind_1h,  _] = if show_1h
    request.security(syminfo.tickerid, "60", get_trend_status())
else
    [na, na, na, na]
[ema_2h,  bg_2h,  ind_2h,  _] = if show_2h
    request.security(syminfo.tickerid, "120", get_trend_status())
else
    [na, na, na, na]
[ema_3h,  bg_3h,  ind_3h,  _] = if show_3h
    request.security(syminfo.tickerid, "180", get_trend_status())
else
    [na, na, na, na]
[ema_4h,  bg_4h,  ind_4h,  _] = if show_4h
    request.security(syminfo.tickerid, "240", get_trend_status())
else
    [na, na, na, na]
[ema_6h,  bg_6h,  ind_6h,  _] = if show_6h
    request.security(syminfo.tickerid, "360", get_trend_status())
else
    [na, na, na, na]
[ema_8h,  bg_8h,  ind_8h,  _] = if show_8h
    request.security(syminfo.tickerid, "480", get_trend_status())
else
    [na, na, na, na]
[ema_12h, bg_12h, ind_12h, _] = if show_12h
    request.security(syminfo.tickerid, "720", get_trend_status())
else
    [na, na, na, na]
[ema_D,   bg_D,   ind_D,   _] = if show_D
    request.security(syminfo.tickerid, "D", get_trend_status())
else
    [na, na, na, na]
[ema_3D,  bg_3D,  ind_3D,  _] = if show_3D
    request.security(syminfo.tickerid, "3D", get_trend_status())
else
    [na, na, na, na]
[ema_W,   bg_W,   ind_W,   _] = if show_W
    request.security(syminfo.tickerid, "W", get_trend_status())
else
    [na, na, na, na]
[ema_M,   bg_M,   ind_M,   _] = if show_M
    request.security(syminfo.tickerid, "M", get_trend_status())
else
    [na, na, na, na]
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* STRENGTH REQUESTS — TF intermedia *//
str_1m  = show_1m  ? request.security(syminfo.tickerid, "1",   get_strength_only()) : na
str_2m  = show_2m  ? request.security(syminfo.tickerid, "1",   get_strength_only()) : na
str_3m  = show_3m  ? request.security(syminfo.tickerid, "1",   get_strength_only()) : na
str_5m  = show_5m  ? request.security(syminfo.tickerid, "3",   get_strength_only()) : na
str_10m = show_10m ? request.security(syminfo.tickerid, "5",   get_strength_only()) : na
str_15m = show_15m ? request.security(syminfo.tickerid, "8",   get_strength_only()) : na
str_30m = show_30m ? request.security(syminfo.tickerid, "15",  get_strength_only()) : na
str_45m = show_45m ? request.security(syminfo.tickerid, "20",  get_strength_only()) : na
str_1h  = show_1h  ? request.security(syminfo.tickerid, "30",  get_strength_only()) : na
str_2h  = show_2h  ? request.security(syminfo.tickerid, "60",  get_strength_only()) : na
str_3h  = show_3h  ? request.security(syminfo.tickerid, "90",  get_strength_only()) : na
str_4h  = show_4h  ? request.security(syminfo.tickerid, "120", get_strength_only()) : na
str_6h  = show_6h  ? request.security(syminfo.tickerid, "180", get_strength_only()) : na
str_8h  = show_8h  ? request.security(syminfo.tickerid, "240", get_strength_only()) : na
str_12h = show_12h ? request.security(syminfo.tickerid, "360", get_strength_only()) : na
str_D   = show_D   ? request.security(syminfo.tickerid, "720", get_strength_only()) : na
str_3D  = show_3D  ? request.security(syminfo.tickerid, "D",   get_strength_only()) : na
str_W   = show_W   ? request.security(syminfo.tickerid, "3D",  get_strength_only()) : na
str_M   = show_M   ? request.security(syminfo.tickerid, "W",   get_strength_only()) : na
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* EXHAUSTION REQUESTS — TF REAL *//
[ext_val_1m,  ext_ind_1m]  = if show_1m
    request.security(syminfo.tickerid, "1", get_exhaustion())
else
    [na, na]
[ext_val_2m,  ext_ind_2m]  = if show_2m
    request.security(syminfo.tickerid, "2", get_exhaustion())
else
    [na, na]
[ext_val_3m,  ext_ind_3m]  = if show_3m
    request.security(syminfo.tickerid, "3", get_exhaustion())
else
    [na, na]
[ext_val_5m,  ext_ind_5m]  = if show_5m
    request.security(syminfo.tickerid, "5", get_exhaustion())
else
    [na, na]
[ext_val_10m, ext_ind_10m] = if show_10m
    request.security(syminfo.tickerid, "10", get_exhaustion())
else
    [na, na]
[ext_val_15m, ext_ind_15m] = if show_15m
    request.security(syminfo.tickerid, "15", get_exhaustion())
else
    [na, na]
[ext_val_30m, ext_ind_30m] = if show_30m
    request.security(syminfo.tickerid, "30", get_exhaustion())
else
    [na, na]
[ext_val_45m, ext_ind_45m] = if show_45m
    request.security(syminfo.tickerid, "45", get_exhaustion())
else
    [na, na]
[ext_val_1h,  ext_ind_1h]  = if show_1h
    request.security(syminfo.tickerid, "60", get_exhaustion())
else
    [na, na]
[ext_val_2h,  ext_ind_2h]  = if show_2h
    request.security(syminfo.tickerid, "120", get_exhaustion())
else
    [na, na]
[ext_val_3h,  ext_ind_3h]  = if show_3h
    request.security(syminfo.tickerid, "180", get_exhaustion())
else
    [na, na]
[ext_val_4h,  ext_ind_4h]  = if show_4h
    request.security(syminfo.tickerid, "240", get_exhaustion())
else
    [na, na]
[ext_val_6h,  ext_ind_6h]  = if show_6h
    request.security(syminfo.tickerid, "360", get_exhaustion())
else
    [na, na]
[ext_val_8h,  ext_ind_8h]  = if show_8h
    request.security(syminfo.tickerid, "480", get_exhaustion())
else
    [na, na]
[ext_val_12h, ext_ind_12h] = if show_12h
    request.security(syminfo.tickerid, "720", get_exhaustion())
else
    [na, na]
[ext_val_D,   ext_ind_D]   = if show_D
    request.security(syminfo.tickerid, "D", get_exhaustion())
else
    [na, na]
[ext_val_3D,  ext_ind_3D]  = if show_3D
    request.security(syminfo.tickerid, "3D", get_exhaustion())
else
    [na, na]
[ext_val_W,   ext_ind_W]   = if show_W
    request.security(syminfo.tickerid, "W", get_exhaustion())
else
    [na, na]
[ext_val_M,   ext_ind_M]   = if show_M
    request.security(syminfo.tickerid, "M", get_exhaustion())
else
    [na, na]
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* ATR REQUESTS *//
atr_1m  = show_1m  ? get_atr("1")   : na
atr_2m  = show_2m  ? get_atr("2")   : na
atr_3m  = show_3m  ? get_atr("3")   : na
atr_5m  = show_5m  ? get_atr("5")   : na
atr_10m = show_10m ? get_atr("10")  : na
atr_15m = show_15m ? get_atr("15")  : na
atr_30m = show_30m ? get_atr("30")  : na
atr_45m = show_45m ? get_atr("45")  : na
atr_1h  = show_1h  ? get_atr("60")  : na
atr_2h  = show_2h  ? get_atr("120") : na
atr_3h  = show_3h  ? get_atr("180") : na
atr_4h  = show_4h  ? get_atr("240") : na
atr_6h  = show_6h  ? get_atr("360") : na
atr_8h  = show_8h  ? get_atr("480") : na
atr_12h = show_12h ? get_atr("720") : na
atr_D   = show_D   ? get_atr("D")   : na
atr_3D  = show_3D  ? get_atr("3D")  : na
atr_W   = show_W   ? get_atr("W")   : na
atr_M   = show_M   ? get_atr("M")   : na
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* TABLE DRAWING *//
f_draw_row(row, tf_label, trend_ind, strength_ind, ema_val, atr_val, ext_ind, ext_val, bg) =>
    col = 0
    table.cell(t, col, row, tf_label,  text_color = text_color, text_size = table_text_size, bgcolor = bg)
    col += 1
    table.cell(t, col, row, trend_ind, text_color = text_color, text_size = table_text_size, bgcolor = bg)
    col += 1
    if show_strength
        table.cell(t, col, row, strength_ind, text_color = text_color, text_size = table_text_size, bgcolor = bg)
        col += 1
    if show_extension
        ext_text = ext_ind + " " + format_zscore(ext_val)
        table.cell(t, col, row, ext_text, text_color = ext_color, text_size = table_text_size, bgcolor = bg)
        col += 1
    if show_atr
        table.cell(t, col, row, atr_val, text_color = atr_color, text_size = table_text_size, bgcolor = bg)
        col += 1
    if show_ema_value
        table.cell(t, col, row, ema_val, text_color = text_color, text_size = table_text_size, bgcolor = bg)
if barstate.islast
    row_idx = 0
    if show_header
        table.cell(t, 0, row_idx, "TF",    text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
        table.cell(t, 1, row_idx, "Trend", text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
        col = 2
        if show_strength
            table.cell(t, col, row_idx, "Force", text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
            col += 1
        if show_extension
            table.cell(t, col, row_idx, "Exh", text_color = ext_color, text_size = table_text_size, bgcolor = header_bg_color)
            col += 1
        if show_atr
            table.cell(t, col, row_idx, "ATR", text_color = atr_color, text_size = table_text_size, bgcolor = header_bg_color)
            col += 1
        if show_ema_value
            table.cell(t, col, row_idx, str.tostring(ema1_length) + " EMA", text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
        row_idx += 1
    if show_1m
        f_draw_row(row_idx, "1m",  ind_1m,  str_1m,  ema_1m,  format_atr(atr_1m),  ext_ind_1m,  ext_val_1m,  bg_1m)
        row_idx += 1
    if show_2m
        f_draw_row(row_idx, "2m",  ind_2m,  str_2m,  ema_2m,  format_atr(atr_2m),  ext_ind_2m,  ext_val_2m,  bg_2m)
        row_idx += 1
    if show_3m
        f_draw_row(row_idx, "3m",  ind_3m,  str_3m,  ema_3m,  format_atr(atr_3m),  ext_ind_3m,  ext_val_3m,  bg_3m)
        row_idx += 1
    if show_5m
        f_draw_row(row_idx, "5m",  ind_5m,  str_5m,  ema_5m,  format_atr(atr_5m),  ext_ind_5m,  ext_val_5m,  bg_5m)
        row_idx += 1
    if show_10m
        f_draw_row(row_idx, "10m", ind_10m, str_10m, ema_10m, format_atr(atr_10m), ext_ind_10m, ext_val_10m, bg_10m)
        row_idx += 1
    if show_15m
        f_draw_row(row_idx, "15m", ind_15m, str_15m, ema_15m, format_atr(atr_15m), ext_ind_15m, ext_val_15m, bg_15m)
        row_idx += 1
    if show_30m
        f_draw_row(row_idx, "30m", ind_30m, str_30m, ema_30m, format_atr(atr_30m), ext_ind_30m, ext_val_30m, bg_30m)
        row_idx += 1
    if show_45m
        f_draw_row(row_idx, "45m", ind_45m, str_45m, ema_45m, format_atr(atr_45m), ext_ind_45m, ext_val_45m, bg_45m)
        row_idx += 1
    if show_1h
        f_draw_row(row_idx, "1h",  ind_1h,  str_1h,  ema_1h,  format_atr(atr_1h),  ext_ind_1h,  ext_val_1h,  bg_1h)
        row_idx += 1
    if show_2h
        f_draw_row(row_idx, "2h",  ind_2h,  str_2h,  ema_2h,  format_atr(atr_2h),  ext_ind_2h,  ext_val_2h,  bg_2h)
        row_idx += 1
    if show_3h
        f_draw_row(row_idx, "3h",  ind_3h,  str_3h,  ema_3h,  format_atr(atr_3h),  ext_ind_3h,  ext_val_3h,  bg_3h)
        row_idx += 1
    if show_4h
        f_draw_row(row_idx, "4h",  ind_4h,  str_4h,  ema_4h,  format_atr(atr_4h),  ext_ind_4h,  ext_val_4h,  bg_4h)
        row_idx += 1
    if show_6h
        f_draw_row(row_idx, "6h",  ind_6h,  str_6h,  ema_6h,  format_atr(atr_6h),  ext_ind_6h,  ext_val_6h,  bg_6h)
        row_idx += 1
    if show_8h
        f_draw_row(row_idx, "8h",  ind_8h,  str_8h,  ema_8h,  format_atr(atr_8h),  ext_ind_8h,  ext_val_8h,  bg_8h)
        row_idx += 1
    if show_12h
        f_draw_row(row_idx, "12h", ind_12h, str_12h, ema_12h, format_atr(atr_12h), ext_ind_12h, ext_val_12h, bg_12h)
        row_idx += 1
    if show_D
        f_draw_row(row_idx, "D",   ind_D,   str_D,   ema_D,   format_atr(atr_D),   ext_ind_D,   ext_val_D,   bg_D)
        row_idx += 1
    if show_3D
        f_draw_row(row_idx, "3D",  ind_3D,  str_3D,  ema_3D,  format_atr(atr_3D),  ext_ind_3D,  ext_val_3D,  bg_3D)
        row_idx += 1
    if show_W
        f_draw_row(row_idx, "W",   ind_W,   str_W,   ema_W,   format_atr(atr_W),   ext_ind_W,   ext_val_W,   bg_W)
        row_idx += 1
    if show_M
        f_draw_row(row_idx, "M",   ind_M,   str_M,   ema_M,   format_atr(atr_M),   ext_ind_M,   ext_val_M,   bg_M)
        row_idx += 1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* BARS *//
[_, _, cur_trend, prev_trend] = get_trend_status()
barcolor_value = cur_trend == uptrend_indicator ? uptrend_colour : cur_trend == downtrend_indicator ? downtrend_colour : neutraltrend_colour
barcolor(color = barcolor_value, editable = false, display = paint_bars ? display.all : display.none)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* ALERTS *//
alertcondition(cur_trend != prev_trend, '0. Trend changed', '⏰ PigoFX - Trend changed on {{ticker}}:{{interval}}min')
alertcondition(cur_trend != prev_trend and cur_trend == uptrend_indicator,      '1. Uptrend started',   '🟢 PigoFX - Uptrend started on {{ticker}}:{{interval}}min')
alertcondition(cur_trend != prev_trend and cur_trend == downtrend_indicator,    '2. Downtrend started', '🔴 PigoFX - Downtrend started on {{ticker}}:{{interval}}min')
alertcondition(cur_trend != prev_trend and cur_trend == neutraltrend_indicator, '3. Neutral started',   '⚫️ PigoFX - Neutral trend started on {{ticker}}:{{interval}}min')
alertcondition(ind_3D == ind_D   and ind_D  == ind_4h,  '4. 3D, D, 4h aligned',   'PigoFX - 3D, D, 4h {{ticker}} trend alignment')
alertcondition(ind_D  == ind_4h  and ind_4h == ind_1h,  '5. D, 4h, 1h aligned',   'PigoFX - D, 4h, 1h {{ticker}} trend alignment')
alertcondition(ind_4h == ind_1h  and ind_1h == ind_15m, '6. 4h, 1h, 15m aligned', 'PigoFX - 4h, 1h, 15m {{ticker}} trend alignment')
alertcondition(ind_1h == ind_15m and ind_15m == ind_5m, '7. 1h, 15m, 5m aligned', 'PigoFX - 1h, 15m, 5m {{ticker}} trend alignment')
alertcondition(ind_15m == ind_5m and ind_5m == ind_3m,  '8. 15m, 5m, 3m aligned', 'PigoFX - 15m, 5m, 3m {{ticker}} trend alignment')
alertcondition(ind_5m == ind_3m  and ind_3m == ind_1m,  '9. 5m, 3m, 1m aligned',  'PigoFX - 5m, 3m, 1m {{ticker}} trend alignment')
````
