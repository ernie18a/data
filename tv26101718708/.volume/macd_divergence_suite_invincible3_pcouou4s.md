# MACD Divergence Suite [invincible3]

- url: https://www.tradingview.com/script/pCouOU4S-MACD-Divergence-Suite-invincible3/
- type: indicator
- pine_id: PUB;93600ffbaa4d4ff1b4f08883d01014fb
- version: 1.0

## Description

[b]MACD Divergence Suite [invincible3][/b]

[b]Overview[/b]

MACD Divergence Suite is an advanced MACD-based momentum and trend indicator designed to provide a clearer view of market direction, momentum strength, divergence, and multi-timeframe confirmation.

This indicator expands the traditional MACD by adding configurable moving average types, normalized MACD values, gradient cloud visualization, SMA-based candle coloring, divergence labels, signal arrows, and a compact multi-timeframe dashboard.

[b]Configurable MACD Calculation[/b]

The indicator allows full customization of the MACD calculation. Users can choose the price source and select different moving average types for the fast line, slow line, and signal line.

Supported moving average types include:

• EMA
• SMA
• DEMA
• TEMA
• WMA
• VWMA
• HMA
• RMA

This makes the indicator flexible for different trading styles, assets, and timeframes.

[b]Normalized MACD[/b]

The MACD values are normalized to a fixed scale, making momentum easier to compare across different markets and timeframes. This helps reduce the visual inconsistency that can happen when using raw MACD values on assets with very different price ranges.

[b]Gradient MACD Cloud[/b]

A layered gradient cloud is plotted between the MACD line and the signal line. The cloud changes color based on bullish or bearish momentum and becomes visually stronger when the MACD spread increases.

This helps traders quickly identify momentum expansion, compression, and possible trend shifts.

[b]Trend-Colored MACD Line[/b]

The main MACD line uses trend-sensitive coloring based on the selected bullish and bearish colors. Strong bullish movement appears with stronger bullish color, while strong bearish movement appears with stronger bearish color.

The signal line remains gray to keep the chart clean and easy to read.

[b]Oscillator Bars[/b]

The oscillator bars show normalized MACD histogram strength. Bar colors use a gradient effect based on momentum strength, helping traders visually detect increasing or weakening momentum.

[b]SMA Candle Coloring[/b]

The indicator includes SMA-based candle coloring on the main chart. Candles are colored bullish when price is above the selected SMA and bearish when price is below the selected SMA.

This provides quick trend confirmation directly on the price chart.

[b]Divergence Detection[/b]

The indicator detects bullish and bearish divergence using the normalized MACD oscillator. Divergence lines and labels can appear on both the MACD pane and the price chart.

Bullish divergence highlights possible upside reversal areas, while bearish divergence highlights possible downside reversal areas.

[b]Signal Arrows[/b]

MACD crossover signals are shown with arrows. The signals can be filtered using normalized MACD levels, helping reduce weak signals in neutral zones.

Arrow distance can also be adjusted so chart signals appear cleaner and do not overlap candles.

[b]Multi-Timeframe Dashboard[/b]

A compact multi-timeframe dashboard summarizes market conditions across multiple timeframes.

The dashboard includes:

• Normalized MACD value
• MACD signal direction
• Histogram state
• Recent divergence status
• SMA-based trend condition

The trend row shows whether price is above or below the selected SMA, giving a simple Bull/Bear trend filter across timeframes.

[b]Key Features[/b]

• Configurable MACD moving average types
• Adjustable fast, slow, and signal lengths
• Selectable price source
• Normalized MACD scale
• Gradient MACD cloud
• Trend-colored MACD line
• Gray signal line for cleaner visibility
• Strength-based oscillator bars
• SMA-based candle coloring
• Bullish and bearish divergence detection
• Divergence labels on MACD pane and price chart
• Multi-timeframe dashboard
• Optional normalized MACD signal filtering
• Adjustable signal arrow distance
• Custom bullish and bearish color presets

[b]How to Use[/b]

Use the MACD line, signal line, and cloud to read momentum direction. A bullish cloud suggests positive momentum, while a bearish cloud suggests negative momentum.

Use the oscillator bars to confirm whether momentum is increasing or weakening.

Use divergence labels to identify potential reversal areas.

Use the SMA candle coloring and dashboard trend row as a trend filter. Bullish signals are generally stronger when price is above the SMA, while bearish signals are generally stronger when price is below the SMA.

[b]Best Used For[/b]

This indicator is useful for:

• Trend-following analysis
• Momentum confirmation
• Multi-timeframe market structure
• Divergence-based reversal spotting
• Signal filtering
• Visual MACD analysis

[b]Disclaimer[/b]

This indicator is intended for technical analysis and educational use only. It should not be used as financial advice. Always combine signals with proper risk management and additional market analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Invincible3

//@version=6
indicator(
     "MACD Divergence Suite [invincible3]",
     shorttitle = "MACD",
     overlay = false,
     max_lines_count = 500,
     max_labels_count = 500
)

// ─────────────────────────────────────────────
// Colors
// ─────────────────────────────────────────────
color C_BG = chart.bg_color

// ─────────────────────────────────────────────
// MACD Settings
// ─────────────────────────────────────────────
grp_m = "MACD Settings"

src = input.source(close, "Price Source", group = grp_m)

f_len = input.int(12, "Fast Length", minval = 1, group = grp_m)
s_len = input.int(26, "Slow Length", minval = 1, group = grp_m)
si_l  = input.int(9, "Signal Length", minval = 1, group = grp_m)

fast_ma_type = input.string(
     "EMA",
     "Fast MA Type",
     options = ["EMA", "SMA", "DEMA", "TEMA", "WMA", "VWMA", "HMA", "RMA"],
     group = grp_m
)

slow_ma_type = input.string(
     "EMA",
     "Slow MA Type",
     options = ["EMA", "SMA", "DEMA", "TEMA", "WMA", "VWMA", "HMA", "RMA"],
     group = grp_m
)

signal_ma_type = input.string(
     "EMA",
     "Signal MA Type",
     options = ["EMA", "SMA", "DEMA", "TEMA", "WMA", "VWMA", "HMA", "RMA"],
     group = grp_m
)

norm = input.int(100, "Normalization Lookback", minval = 10, group = grp_m)

// ─────────────────────────────────────────────
// User Defined Settings
// ─────────────────────────────────────────────
grp_u = "User Defined Settings"

sma_len = input.int(
     50,
     "SMA Length",
     minval = 1,
     group = grp_u
)

use_norm_macd_filter = input.bool(
     true,
     "Use Normalized MACD Signal Filter",
     group = grp_u
)

bull_norm_level = input.float(
     -70.0,
     "Bull Signal Below Normalized MACD",
     minval = -100,
     maxval = 100,
     step = 1,
     group = grp_u
)

bear_norm_level = input.float(
     70.0,
     "Bear Signal Above Normalized MACD",
     minval = -100,
     maxval = 100,
     step = 1,
     group = grp_u
)

arrow_atr_len = input.int(
     20,
     "Arrow ATR Length",
     minval = 1,
     group = grp_u
)

arrow_distance = input.float(
     1,
     "Chart Arrow Distance",
     minval = 0.0,
     step = 0.05,
     group = grp_u
)

pane_arrow_distance = input.float(
     20.0,
     "MACD Pane Arrow Distance",
     minval = 0.0,
     step = 0.5,
     group = grp_u
)

div_label_distance = input.float(
     0.45,
     "Chart Divergence Label Distance",
     minval = 0.0,
     step = 0.05,
     group = grp_u
)

// ─────────────────────────────────────────────
// Visual Settings
// ─────────────────────────────────────────────
grp_v = "Visual Settings"

show_zones          = input.bool(true, "Show OB/OS Zones", group = grp_v)
show_cloud          = input.bool(true, "Show MACD Gradient Cloud", group = grp_v)
cloud_intensity     = input.float(1.8, "Cloud Gradient Intensity", minval = 0.1, maxval = 5.0, step = 0.1, group = grp_v)
show_osc_bars       = input.bool(true, "Show Normal MACD Oscillator Bars", group = grp_v)
enable_bar_coloring = input.bool(true, "Enable SMA Candle Coloring", group = grp_v)
show_mtf_dashboard  = input.bool(true, "Show MTF Dashboard", group = grp_v)

colorPreset = input.string(
     "Custom",
     "Color Preset",
     options = ["Classic", "Aqua", "Cosmic", "Ember", "Neon", "Custom"],
     group = grp_v
)

bullColorInput = input.color(#00ffaa, "Bullish Color", group = grp_v)
bearColorInput = input.color(#ff0000, "Bearish Color", group = grp_v)

[bullish_color, bearish_color] = switch colorPreset
    "Classic" => [#00ff00, #ff0000]
    "Aqua"    => [#00bfff, #ff8c00]
    "Cosmic"  => [#49ffce, #9932cc]
    "Ember"   => [#ff6600, #00cccc]
    "Neon"    => [#ffff00, #ff00ff]
    "Custom"  => [bullColorInput, bearColorInput]

// ─────────────────────────────────────────────
// Divergence Settings
// ─────────────────────────────────────────────
grp_d = "Divergence Settings"

sh_div_l       = input.bool(true, "Show Divergence Lines", group = grp_d)
pv_len         = input.int(3, "Pivot Lookback", minval = 1, group = grp_d)
div_only_zones = input.bool(true, "Only Show Divergence Near OB/OS", group = grp_d)
div_ob_level   = input.float(70.0, "Divergence OB Level", group = grp_d)
div_os_level   = input.float(-70.0, "Divergence OS Level", group = grp_d)

// ─────────────────────────────────────────────
// MTF Dashboard Settings
// ─────────────────────────────────────────────
grp_t = "MTF Dashboard"

tf1 = input.timeframe("5", "TF 1", group = grp_t)
tf2 = input.timeframe("15", "TF 2", group = grp_t)
tf3 = input.timeframe("60", "TF 3", group = grp_t)
tf4 = input.timeframe("120", "TF 4", group = grp_t)
tf5 = input.timeframe("240", "TF 5", group = grp_t)
tf6 = input.timeframe("720", "TF 6", group = grp_t)
tf7 = input.timeframe("D", "TF 7", group = grp_t)
tf8 = input.timeframe("7D", "TF 8", group = grp_t)

mtf_div_recent_bars = input.int(
     5,
     "H-Divergence Recent Bars",
     minval = 1,
     group = grp_t
)

tb_size_str = input.string(
     "Small",
     "Table Text Size",
     options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"],
     group = grp_t
)

tb_font_str = input.string(
     "Default",
     "Table Font",
     options = ["Default", "Monospace"],
     group = grp_t
)

// ─────────────────────────────────────────────
// MA Function
// ─────────────────────────────────────────────
f_ma(_src, _len, _type) =>
    _ema1 = ta.ema(_src, _len)
    _ema2 = ta.ema(_ema1, _len)
    _ema3 = ta.ema(_ema2, _len)

    _dema = 2.0 * _ema1 - _ema2
    _tema = 3.0 * (_ema1 - _ema2) + _ema3

    switch _type
        "EMA"  => _ema1
        "SMA"  => ta.sma(_src, _len)
        "DEMA" => _dema
        "TEMA" => _tema
        "WMA"  => ta.wma(_src, _len)
        "VWMA" => ta.vwma(_src, _len)
        "HMA"  => ta.hma(_src, _len)
        "RMA"  => ta.rma(_src, _len)
        => _ema1

// ─────────────────────────────────────────────
// Core MACD Logic
// ─────────────────────────────────────────────
fast_ma = f_ma(src, f_len, fast_ma_type)
slow_ma = f_ma(src, s_len, slow_ma_type)

mac = fast_ma - slow_ma
sig = f_ma(mac, si_l, signal_ma_type)
his = mac - sig

// ─────────────────────────────────────────────
// MACD Normalization
// ─────────────────────────────────────────────
mx = ta.highest(math.abs(mac), norm)

nm = mx != 0 ? mac / mx * 100 : 0
ns = mx != 0 ? sig / mx * 100 : 0

hist_mx = ta.highest(math.abs(his), norm)
normal_macd_osc = hist_mx != 0 ? his / hist_mx * 100 : 0

osc = normal_macd_osc

// ─────────────────────────────────────────────
// Oscillator Bar Gradient
// ─────────────────────────────────────────────
osc_strength_percent  = math.min(math.abs(osc), 100.0)
hist_strength_percent = math.min(math.abs(normal_macd_osc), 100.0)

alignment_percent = ((nm > ns and osc > 0) or (nm < ns and osc < 0)) ? 100.0 : 50.0
slope_percent     = ((osc > osc[1] and osc > 0) or (osc < osc[1] and osc < 0)) ? 100.0 : 50.0

total_strength_percent =
     osc_strength_percent * 0.45 +
     hist_strength_percent * 0.25 +
     alignment_percent * 0.20 +
     slope_percent * 0.10

bull_bar_color = color.from_gradient(
     total_strength_percent,
     0,
     100,
     color.new(bullish_color, 85),
     color.new(bullish_color, 10)
)

bear_bar_color = color.from_gradient(
     total_strength_percent,
     0,
     100,
     color.new(bearish_color, 85),
     color.new(bearish_color, 10)
)

osc_bar_color = osc >= 0 ? bull_bar_color : bear_bar_color

// ─────────────────────────────────────────────
// SMA Based Candle Coloring
// ─────────────────────────────────────────────
chart_sma = ta.sma(close, sma_len)

sma_candle_color =
     close > chart_sma ? color.new(bullish_color, 0) :
     close < chart_sma ? color.new(bearish_color, 0) :
     color.new(color.gray, 0)

plotcandle(
     open, high, low, close,
     title = "SMA Based Candle Color",
     color = enable_bar_coloring ? sma_candle_color : na,
     wickcolor = enable_bar_coloring ? sma_candle_color : na,
     bordercolor = enable_bar_coloring ? sma_candle_color : na,
     force_overlay = true
)

// ─────────────────────────────────────────────
// MTF State Function
// Returns: normalized MACD, MACD state, histogram state, divergence state, trend state
// ─────────────────────────────────────────────
f_mtfState() =>
    _fastMa = f_ma(src, f_len, fast_ma_type)
    _slowMa = f_ma(src, s_len, slow_ma_type)

    _mac = _fastMa - _slowMa
    _sig = f_ma(_mac, si_l, signal_ma_type)
    _his = _mac - _sig

    _mx = ta.highest(math.abs(_mac), norm)
    _nm = _mx != 0 ? _mac / _mx * 100 : 0

    _histMx = ta.highest(math.abs(_his), norm)
    _osc = _histMx != 0 ? _his / _histMx * 100 : 0

    _smaLine = ta.sma(close, sma_len)

    _macSig = _mac > _sig ? 1 : _mac < _sig ? -1 : 0
    _histSig = _his > 0 ? 1 : _his < 0 ? -1 : 0
    _trendState = close > _smaLine ? 1 : close < _smaLine ? -1 : 0

    _pl = ta.pivotlow(_osc, pv_len, pv_len)
    _ph = ta.pivothigh(_osc, pv_len, pv_len)

    _prevPlPrice = ta.valuewhen(not na(_pl), low[pv_len], 1)
    _prevPlOsc   = ta.valuewhen(not na(_pl), _osc[pv_len], 1)

    _prevPhPrice = ta.valuewhen(not na(_ph), high[pv_len], 1)
    _prevPhOsc   = ta.valuewhen(not na(_ph), _osc[pv_len], 1)

    _bullDivRaw = not na(_pl) and not na(_prevPlPrice) and low[pv_len] < _prevPlPrice and _osc[pv_len] > _prevPlOsc
    _bearDivRaw = not na(_ph) and not na(_prevPhPrice) and high[pv_len] > _prevPhPrice and _osc[pv_len] < _prevPhOsc

    _bullZoneOk = not div_only_zones or _osc[pv_len] <= div_os_level or _prevPlOsc <= div_os_level
    _bearZoneOk = not div_only_zones or _osc[pv_len] >= div_ob_level or _prevPhOsc >= div_ob_level

    _bullDiv = _bullDivRaw and _bullZoneOk
    _bearDiv = _bearDivRaw and _bearZoneOk

    _bullBars = ta.barssince(_bullDiv)
    _bearBars = ta.barssince(_bearDiv)

    _recentBullDiv = not na(_bullBars) and _bullBars <= mtf_div_recent_bars
    _recentBearDiv = not na(_bearBars) and _bearBars <= mtf_div_recent_bars

    _divState = _recentBullDiv ? 1 : _recentBearDiv ? -1 : 0

    [_nm, _macSig, _histSig, _divState, _trendState]

// ─────────────────────────────────────────────
// MTF Values
// ─────────────────────────────────────────────
[m1_macd, m1_sig, m1_hist, m1_div, m1_trend] = request.security(syminfo.tickerid, tf1, f_mtfState())
[m2_macd, m2_sig, m2_hist, m2_div, m2_trend] = request.security(syminfo.tickerid, tf2, f_mtfState())
[m3_macd, m3_sig, m3_hist, m3_div, m3_trend] = request.security(syminfo.tickerid, tf3, f_mtfState())
[m4_macd, m4_sig, m4_hist, m4_div, m4_trend] = request.security(syminfo.tickerid, tf4, f_mtfState())
[m5_macd, m5_sig, m5_hist, m5_div, m5_trend] = request.security(syminfo.tickerid, tf5, f_mtfState())
[m6_macd, m6_sig, m6_hist, m6_div, m6_trend] = request.security(syminfo.tickerid, tf6, f_mtfState())
[m7_macd, m7_sig, m7_hist, m7_div, m7_trend] = request.security(syminfo.tickerid, tf7, f_mtfState())
[m8_macd, m8_sig, m8_hist, m8_div, m8_trend] = request.security(syminfo.tickerid, tf8, f_mtfState())

// ─────────────────────────────────────────────
// General Helper
// ─────────────────────────────────────────────
f_transp(_x) =>
    int(math.round(math.max(0.0, math.min(100.0, _x))))

// ─────────────────────────────────────────────
// Dashboard Style Helpers
// ─────────────────────────────────────────────
tb_size = tb_size_str == "Tiny" ? size.tiny : tb_size_str == "Small" ? size.small : tb_size_str == "Normal" ? size.normal : tb_size_str == "Large" ? size.large : tb_size_str == "Huge" ? size.huge : size.auto
tb_font = tb_font_str == "Monospace" ? font.family_monospace : font.family_default

color TB_BG      = chart.bg_color
color TB_HEAD    = color.new(chart.fg_color, 90)
color TB_LABEL   = color.new(chart.fg_color, 90)
color TB_CELL    = color.new(chart.fg_color, 95)
color TB_BORDER  = color.new(chart.fg_color, 80)
color TB_TEXT    = chart.fg_color
color TB_MUTED   = color.new(chart.fg_color, 50)

f_tfTxt(_tf) =>
    switch _tf
        "1"   => "1M"
        "3"   => "3M"
        "5"   => "5M"
        "15"  => "15M"
        "30"  => "30M"
        "45"  => "45M"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "720" => "12H"
        "D"   => "1D"
        "W"   => "1W"
        "7D"  => "7D"
        => _tf

f_macdTxt(_v) =>
    str.tostring(_v, "#.0")

f_sigIcon(_s) =>
    _s == 1 ? "▲" : _s == -1 ? "▼" : "-"

f_histIcon(_s) =>
    _s == 1 ? "+" : _s == -1 ? "−" : "-"

f_divTxt(_s) =>
    _s == 1 ? "Bull" : _s == -1 ? "Bear" : "-"

f_trendTxt(_s) =>
    _s == 1 ? "Bull" : _s == -1 ? "Bear" : "-"

f_macdBg(_v) =>
    _v > 0 ? color.from_gradient(math.min(_v, 100), 0, 100, color.new(bearish_color, 85), color.new(bearish_color, 30)) :
     _v < 0 ? color.from_gradient(math.min(math.abs(_v), 100), 0, 100, color.new(bullish_color, 85), color.new(bullish_color, 30)) :
     TB_CELL

f_stateBg(_s) =>
    _s == 1 ? color.new(bullish_color, 80) :
     _s == -1 ? color.new(bearish_color, 80) :
     TB_CELL

f_stateTextColor(_s) =>
    _s == 1 ? bullish_color :
     _s == -1 ? bearish_color :
     TB_MUTED

f_histTextColor(_s) =>
    _s == 1 ? bullish_color :
     _s == -1 ? bearish_color :
     TB_MUTED

f_dashCell(_tb, _col, _row, _txt, _bg, _txtCol) =>
    table.cell(
         _tb,
         _col,
         _row,
         _txt,
         bgcolor = _bg,
         text_color = _txtCol,
         text_halign = text.align_center,
         text_valign = text.align_center,
         text_size = tb_size,
         text_font_family = tb_font
    )

// ─────────────────────────────────────────────
// OB/OS Zones
// ─────────────────────────────────────────────
p_ob_h = plot(show_zones ? 100 : na, "OB Upper", color = color.new(bearish_color, 80))
p_ob_l = plot(show_zones ? 70 : na, "OB Lower", color = color.new(bearish_color, 100))
fill(p_ob_h, p_ob_l, show_zones ? color.new(bearish_color, 90) : na)

p_os_h = plot(show_zones ? -70 : na, "OS Upper", color = color.new(bullish_color, 100))
p_os_l = plot(show_zones ? -100 : na, "OS Lower", color = color.new(bullish_color, 80))
fill(p_os_h, p_os_l, show_zones ? color.new(bullish_color, 90) : na)

hline(0, "Zero Line", color = color.new(color.gray, 50))

// ─────────────────────────────────────────────
// Normal MACD Oscillator Bars
// ─────────────────────────────────────────────
plot(
     show_osc_bars ? normal_macd_osc : na,
     "Normal MACD Oscillator Bars",
     style = plot.style_columns,
     color = osc_bar_color
)

// ─────────────────────────────────────────────
// MACD Trend Line + Gray Signal Line
// ─────────────────────────────────────────────
macd_slope_abs = math.abs(nm - nz(nm[1], nm))

macd_trend_strength =
     math.min(
          math.abs(nm - ns) * 0.45 +
          math.abs(normal_macd_osc) * 0.35 +
          macd_slope_abs * 0.20,
          100.0
     )

macd_bull_trend = nm > ns and nm > nz(nm[1], nm)
macd_bear_trend = nm < ns and nm < nz(nm[1], nm)

macd_line_color =
     macd_bull_trend ? color.from_gradient(
          macd_trend_strength,
          0,
          100,
          color.new(bullish_color, 70),
          color.new(bullish_color, 0)
     ) :
     macd_bear_trend ? color.from_gradient(
          macd_trend_strength,
          0,
          100,
          color.new(bearish_color, 70),
          color.new(bearish_color, 0)
     ) :
     color.new(color.gray, 35)

signal_gray = color.new(color.gray, 25)

p_m = plot(
     nm,
     "MACD Trend Line",
     color = macd_line_color,
     linewidth = 2
)

p_s = plot(
     ns,
     "Signal Gray Line",
     color = signal_gray,
     linewidth = 1
)

// ─────────────────────────────────────────────
// Layered MACD Gradient Cloud
// ─────────────────────────────────────────────
cloud_base = nm >= ns ? bullish_color : bearish_color
cloud_spread = math.min(math.abs(nm - ns) * cloud_intensity, 100.0)

t1 = f_transp(96.0 - cloud_spread * 0.10)
t2 = f_transp(92.0 - cloud_spread * 0.18)
t3 = f_transp(88.0 - cloud_spread * 0.28)
t4 = f_transp(82.0 - cloud_spread * 0.38)
t5 = f_transp(76.0 - cloud_spread * 0.48)

cloud_20 = ns + (nm - ns) * 0.20
cloud_40 = ns + (nm - ns) * 0.40
cloud_60 = ns + (nm - ns) * 0.60
cloud_80 = ns + (nm - ns) * 0.80

p_c20 = plot(show_cloud ? cloud_20 : na, "Cloud Layer 20", color = color.new(color.white, 100))
p_c40 = plot(show_cloud ? cloud_40 : na, "Cloud Layer 40", color = color.new(color.white, 100))
p_c60 = plot(show_cloud ? cloud_60 : na, "Cloud Layer 60", color = color.new(color.white, 100))
p_c80 = plot(show_cloud ? cloud_80 : na, "Cloud Layer 80", color = color.new(color.white, 100))

fill(p_s,   p_c20, show_cloud ? color.new(cloud_base, t1) : na, title = "MACD Cloud Gradient 1")
fill(p_c20, p_c40, show_cloud ? color.new(cloud_base, t2) : na, title = "MACD Cloud Gradient 2")
fill(p_c40, p_c60, show_cloud ? color.new(cloud_base, t3) : na, title = "MACD Cloud Gradient 3")
fill(p_c60, p_c80, show_cloud ? color.new(cloud_base, t4) : na, title = "MACD Cloud Gradient 4")
fill(p_c80, p_m,   show_cloud ? color.new(cloud_base, t5) : na, title = "MACD Cloud Gradient 5")

// ─────────────────────────────────────────────
// Divergence Logic
// Labels are shown in MACD pane and price chart.
// ─────────────────────────────────────────────
ph = ta.pivothigh(osc, pv_len, pv_len)
pl = ta.pivotlow(osc, pv_len, pv_len)

div_label_gap = ta.atr(arrow_atr_len) * div_label_distance

var float last_ph_p = na
var float last_ph_o = na
var int   last_ph_i = na

var float last_pl_p = na
var float last_pl_o = na
var int   last_pl_i = na

if not na(pl)
    bullDivRaw = not na(last_pl_p) and low[pv_len] < last_pl_p and osc[pv_len] > last_pl_o
    bullZoneOk = not div_only_zones or osc[pv_len] <= div_os_level or last_pl_o <= div_os_level
    bullDiv = bullDivRaw and bullZoneOk

    if bullDiv
        if sh_div_l
            line.new(
                 last_pl_i,
                 last_pl_p,
                 bar_index[pv_len],
                 low[pv_len],
                 color = bullish_color,
                 width = 2,
                 force_overlay = true
            )

            line.new(
                 last_pl_i,
                 last_pl_o,
                 bar_index[pv_len],
                 osc[pv_len],
                 color = bullish_color,
                 width = 2
            )

        label.new(
             bar_index[pv_len],
             osc[pv_len],
             "Bull Div",
             color = color.new(bullish_color, 100),
             textcolor = bullish_color,
             style = label.style_label_up,
             size = size.tiny
        )

        label.new(
             bar_index[pv_len],
             low[pv_len] - div_label_gap,
             "Bull Div",
             color = color.new(bullish_color, 100),
             textcolor = bullish_color,
             style = label.style_label_up,
             size = size.tiny,
             force_overlay = true
        )

    last_pl_p := low[pv_len]
    last_pl_o := osc[pv_len]
    last_pl_i := bar_index[pv_len]

if not na(ph)
    bearDivRaw = not na(last_ph_p) and high[pv_len] > last_ph_p and osc[pv_len] < last_ph_o
    bearZoneOk = not div_only_zones or osc[pv_len] >= div_ob_level or last_ph_o >= div_ob_level
    bearDiv = bearDivRaw and bearZoneOk

    if bearDiv
        if sh_div_l
            line.new(
                 last_ph_i,
                 last_ph_p,
                 bar_index[pv_len],
                 high[pv_len],
                 color = bearish_color,
                 width = 2,
                 force_overlay = true
            )

            line.new(
                 last_ph_i,
                 last_ph_o,
                 bar_index[pv_len],
                 osc[pv_len],
                 color = bearish_color,
                 width = 2
            )

        label.new(
             bar_index[pv_len],
             osc[pv_len],
             "Bear Div",
             color = color.new(bearish_color, 100),
             textcolor = bearish_color,
             style = label.style_label_down,
             size = size.tiny
        )

        label.new(
             bar_index[pv_len],
             high[pv_len] + div_label_gap,
             "Bear Div",
             color = color.new(bearish_color, 100),
             textcolor = bearish_color,
             style = label.style_label_down,
             size = size.tiny,
             force_overlay = true
        )

    last_ph_p := high[pv_len]
    last_ph_o := osc[pv_len]
    last_ph_i := bar_index[pv_len]

// ─────────────────────────────────────────────
// MTF Dashboard — Screenshot Style
// ─────────────────────────────────────────────
var table tb = table.new(
     position.top_right,
     9,
     6,
     bgcolor = TB_BG,
     border_width = 1,
     border_color = TB_BORDER,
     frame_width = 1,
     frame_color = TB_BORDER
)

if barstate.islast
    if show_mtf_dashboard
        f_dashCell(tb, 0, 0, "Timeframe", TB_HEAD, TB_TEXT)
        f_dashCell(tb, 1, 0, f_tfTxt(tf1), TB_HEAD, TB_TEXT)
        f_dashCell(tb, 2, 0, f_tfTxt(tf2), TB_HEAD, TB_TEXT)
        f_dashCell(tb, 3, 0, f_tfTxt(tf3), TB_HEAD, TB_TEXT)
        f_dashCell(tb, 4, 0, f_tfTxt(tf4), TB_HEAD, TB_TEXT)
        f_dashCell(tb, 5, 0, f_tfTxt(tf5), TB_HEAD, TB_TEXT)
        f_dashCell(tb, 6, 0, f_tfTxt(tf6), TB_HEAD, TB_TEXT)
        f_dashCell(tb, 7, 0, f_tfTxt(tf7), TB_HEAD, TB_TEXT)
        f_dashCell(tb, 8, 0, f_tfTxt(tf8), TB_HEAD, TB_TEXT)

        f_dashCell(tb, 0, 1, "MACD", TB_LABEL, TB_TEXT)
        f_dashCell(tb, 1, 1, f_macdTxt(m1_macd), f_macdBg(m1_macd), TB_TEXT)
        f_dashCell(tb, 2, 1, f_macdTxt(m2_macd), f_macdBg(m2_macd), TB_TEXT)
        f_dashCell(tb, 3, 1, f_macdTxt(m3_macd), f_macdBg(m3_macd), TB_TEXT)
        f_dashCell(tb, 4, 1, f_macdTxt(m4_macd), f_macdBg(m4_macd), TB_TEXT)
        f_dashCell(tb, 5, 1, f_macdTxt(m5_macd), f_macdBg(m5_macd), TB_TEXT)
        f_dashCell(tb, 6, 1, f_macdTxt(m6_macd), f_macdBg(m6_macd), TB_TEXT)
        f_dashCell(tb, 7, 1, f_macdTxt(m7_macd), f_macdBg(m7_macd), TB_TEXT)
        f_dashCell(tb, 8, 1, f_macdTxt(m8_macd), f_macdBg(m8_macd), TB_TEXT)

        f_dashCell(tb, 0, 2, "MACD Signals", TB_LABEL, TB_TEXT)
        f_dashCell(tb, 1, 2, f_sigIcon(m1_sig), f_stateBg(m1_sig), f_stateTextColor(m1_sig))
        f_dashCell(tb, 2, 2, f_sigIcon(m2_sig), f_stateBg(m2_sig), f_stateTextColor(m2_sig))
        f_dashCell(tb, 3, 2, f_sigIcon(m3_sig), f_stateBg(m3_sig), f_stateTextColor(m3_sig))
        f_dashCell(tb, 4, 2, f_sigIcon(m4_sig), f_stateBg(m4_sig), f_stateTextColor(m4_sig))
        f_dashCell(tb, 5, 2, f_sigIcon(m5_sig), f_stateBg(m5_sig), f_stateTextColor(m5_sig))
        f_dashCell(tb, 6, 2, f_sigIcon(m6_sig), f_stateBg(m6_sig), f_stateTextColor(m6_sig))
        f_dashCell(tb, 7, 2, f_sigIcon(m7_sig), f_stateBg(m7_sig), f_stateTextColor(m7_sig))
        f_dashCell(tb, 8, 2, f_sigIcon(m8_sig), f_stateBg(m8_sig), f_stateTextColor(m8_sig))

        f_dashCell(tb, 0, 3, "Histogram Signals", TB_LABEL, TB_TEXT)
        f_dashCell(tb, 1, 3, f_histIcon(m1_hist), TB_CELL, f_histTextColor(m1_hist))
        f_dashCell(tb, 2, 3, f_histIcon(m2_hist), TB_CELL, f_histTextColor(m2_hist))
        f_dashCell(tb, 3, 3, f_histIcon(m3_hist), TB_CELL, f_histTextColor(m3_hist))
        f_dashCell(tb, 4, 3, f_histIcon(m4_hist), TB_CELL, f_histTextColor(m4_hist))
        f_dashCell(tb, 5, 3, f_histIcon(m5_hist), TB_CELL, f_histTextColor(m5_hist))
        f_dashCell(tb, 6, 3, f_histIcon(m6_hist), TB_CELL, f_histTextColor(m6_hist))
        f_dashCell(tb, 7, 3, f_histIcon(m7_hist), TB_CELL, f_histTextColor(m7_hist))
        f_dashCell(tb, 8, 3, f_histIcon(m8_hist), TB_CELL, f_histTextColor(m8_hist))

        f_dashCell(tb, 0, 4, "H-Divergence", TB_LABEL, TB_TEXT)
        f_dashCell(tb, 1, 4, f_divTxt(m1_div), f_stateBg(m1_div), f_stateTextColor(m1_div))
        f_dashCell(tb, 2, 4, f_divTxt(m2_div), f_stateBg(m2_div), f_stateTextColor(m2_div))
        f_dashCell(tb, 3, 4, f_divTxt(m3_div), f_stateBg(m3_div), f_stateTextColor(m3_div))
        f_dashCell(tb, 4, 4, f_divTxt(m4_div), f_stateBg(m4_div), f_stateTextColor(m4_div))
        f_dashCell(tb, 5, 4, f_divTxt(m5_div), f_stateBg(m5_div), f_stateTextColor(m5_div))
        f_dashCell(tb, 6, 4, f_divTxt(m6_div), f_stateBg(m6_div), f_stateTextColor(m6_div))
        f_dashCell(tb, 7, 4, f_divTxt(m7_div), f_stateBg(m7_div), f_stateTextColor(m7_div))
        f_dashCell(tb, 8, 4, f_divTxt(m8_div), f_stateBg(m8_div), f_stateTextColor(m8_div))

        f_dashCell(tb, 0, 5, "Trend", TB_LABEL, TB_TEXT)
        f_dashCell(tb, 1, 5, f_trendTxt(m1_trend), f_stateBg(m1_trend), f_stateTextColor(m1_trend))
        f_dashCell(tb, 2, 5, f_trendTxt(m2_trend), f_stateBg(m2_trend), f_stateTextColor(m2_trend))
        f_dashCell(tb, 3, 5, f_trendTxt(m3_trend), f_stateBg(m3_trend), f_stateTextColor(m3_trend))
        f_dashCell(tb, 4, 5, f_trendTxt(m4_trend), f_stateBg(m4_trend), f_stateTextColor(m4_trend))
        f_dashCell(tb, 5, 5, f_trendTxt(m5_trend), f_stateBg(m5_trend), f_stateTextColor(m5_trend))
        f_dashCell(tb, 6, 5, f_trendTxt(m6_trend), f_stateBg(m6_trend), f_stateTextColor(m6_trend))
        f_dashCell(tb, 7, 5, f_trendTxt(m7_trend), f_stateBg(m7_trend), f_stateTextColor(m7_trend))
        f_dashCell(tb, 8, 5, f_trendTxt(m8_trend), f_stateBg(m8_trend), f_stateTextColor(m8_trend))
    else
        table.clear(tb, 0, 0, 8, 5)

// ─────────────────────────────────────────────
// Signals
// Normalized MACD condition + moved arrows
// ─────────────────────────────────────────────
bull_norm_ok = not use_norm_macd_filter or nm <= bull_norm_level
bear_norm_ok = not use_norm_macd_filter or nm >= bear_norm_level

bullSignal = ta.crossover(nm, ns) and bull_norm_ok
bearSignal = ta.crossunder(nm, ns) and bear_norm_ok

oscCrossUp = ta.crossover(osc, 0)
oscCrossDn = ta.crossunder(osc, 0)

plotshape(
     oscCrossUp ? 0 : na,
     "Oscillator Cross Up",
     shape.cross,
     location.absolute,
     bullish_color,
     size = size.tiny
)

plotshape(
     oscCrossDn ? 0 : na,
     "Oscillator Cross Down",
     shape.cross,
     location.absolute,
     bearish_color,
     size = size.tiny
)

arrow_gap = ta.atr(arrow_atr_len) * arrow_distance

bull_chart_y = bullSignal ? low - arrow_gap : na
bear_chart_y = bearSignal ? high + arrow_gap : na

plotshape(
     bull_chart_y,
     "Bull Cross Chart",
     shape.triangleup,
     location.absolute,
     bullish_color,
     size = size.tiny,
     force_overlay = true
)

plotshape(
     bear_chart_y,
     "Bear Cross Chart",
     shape.triangledown,
     location.absolute,
     bearish_color,
     size = size.tiny,
     force_overlay = true
)

bull_pane_y = bullSignal ? nm - pane_arrow_distance : na
bear_pane_y = bearSignal ? nm + pane_arrow_distance : na

plotshape(
     bull_pane_y,
     "Bull Cross MACD Pane",
     shape.triangleup,
     location.absolute,
     bullish_color,
     size = size.tiny
)

plotshape(
     bear_pane_y,
     "Bear Cross MACD Pane",
     shape.triangledown,
     location.absolute,
     bearish_color,
     size = size.tiny
)
````
