<!-- tradingview-pine-id: PUB;44afa506110847618b0703ae83a56f10 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Jurik Trend Ribbon [QuantAlgo]

Source: https://www.tradingview.com/script/Cq3tMzy9-Jurik-Trend-Ribbon-QuantAlgo/

## Description

🟢 Overview

The Jurik Trend Ribbon is a trend-following indicator built on a phase-compensated recursive filter rather than fixed-weight averages or price crossovers. It measures the residual between price and its own running estimate, then feeds a scaled portion of that residual back into the output to recover lag without the overshoot a shorter average introduces. Direction is anchored to a stored level that only advances once the filtered path clears a volatility deadband, helping traders separate sustained directional displacement from movement contained inside the prevailing range across every timeframe and market.
[image]https://www.tradingview.com/x/M7DoBqV8/[/image]
🟢 How It Works

The foundation of the indicator is a three-stage recursive cascade. A preliminary stage smooths the source, a detrending stage retains the residual price leaves behind against that estimate, and a final stage applies phase compensation before accumulating the result:
[pine]stage_one   := inv_alpha * src + alpha * stage_one
detrend     := (src - stage_one) * (1.0 - beta) + beta * detrend
phase_shift = stage_one + phase_ratio * detrend
stage_three := (phase_shift - result) * inv_alpha * inv_alpha + alpha * alpha * stage_three
result      := result + stage_three[/pine]
Two coefficients govern the cascade. Beta is fixed by the sampling Length and weights the detrending stage. Alpha is the smoothing coefficient, and under Classic mode it stays fixed at the Power setting throughout. Under Adaptive mode it is rescheduled on every bar from realized volatility measured against its own longer baseline:
[pine]dynamic_exp = math.pow(volty_ratio, volty_exp)
alpha       = math.pow(beta, dynamic_exp)[/pine]
Because beta is less than one, a larger exponent produces a smaller alpha and a faster filter, so the cascade tracks more closely as volatility expands and settles as it contracts. Classic holds a constant response that changes only with Length, while Adaptive shifts its response with the regime and will register state changes more readily at the same envelope width.

Direction is not read from the filter's slope. A stored level tracks the filtered path at a fixed distance in ATR units and only steps when the path clears it:
[pine]if upper_bound < ratchet
    ratchet   := upper_bound
    trend_dir := -1
else if lower_bound > ratchet
    ratchet   := lower_bound
    trend_dir := 1[/pine]
Because that level rests a full deadband away from the filter, reversing direction requires the path to travel twice that distance, roughly three ATR at default settings. The level holds still through movement contained inside the envelope and commits only once displacement clears it outright, so the state persists through pullbacks rather than resetting on every fluctuation in the filter.
[image]https://www.tradingview.com/x/Go4h8GHp/[/image]
🟢 Signal Interpretation

▶ Bullish Trend (Green): When the filtered path clears the lower edge of the envelope, the stored level steps upward and the indicator enters bullish mode with green coloring applied across the ribbon and its layered bands. The level then trails beneath the path and only ever ratchets higher, so the reading persists through pullbacks that fail to displace price far enough to reach it. The transition into green marks a potential long/buy opportunity, with retracements toward the ribbon during an established bullish reading offering potential continuation entries.

▶ Bearish Trend (Red): When the filtered path clears the upper edge, the stored level steps downward and the indicator enters bearish mode with red coloring across all visual elements. The level trails above the path from that point and only tracks lower, requiring a full deadband of upward displacement before the state can flip back. The transition into red marks a potential short/sell opportunity, with rallies back toward the ribbon during an established bearish reading offering potential continuation entries on the downside.
[image]https://www.tradingview.com/x/hqVDg0nz/[/image]
🟢 Features

▶ Preconfigured Presets: Three parameter sets cover different trading approaches. "Default" targets swing trading on 1-hour and daily charts with a balanced filter and an envelope that holds direction through routine pullbacks. "Fast Response" shortens the filter, lightens the smoothing exponent, and tightens the envelope for intraday charts where the indicator needs to adapt to shorter-duration moves. "Smooth Trend" extends the filter, deepens the exponent, and widens the envelope for position trading on daily and weekly timeframes, where the cost of a false flip exceeds the cost of a delayed one. Selecting a preset overrides the individual filter and envelope inputs.
[image]https://www.tradingview.com/x/h5bFQT0m/[/image]
▶ Built-in Alerts: Three alert conditions cover all directional states. "Bullish Trend Signal" fires on the bar where the trend confirms bullish. "Bearish Trend Signal" fires on the bar where it confirms bearish. "Any Trend Change" combines both into a single condition for traders who want a unified notification regardless of direction. Because the filter reads its source on every tick, alerts should be set to Once Per Bar Close so they fire only on values that are final.
[image]https://www.tradingview.com/x/DtjVSBov/[/image]
▶ Visual Customization: Six color presets (Classic, Aqua, Cosmic, Cyber, Neon, and Custom) apply coordinated bullish and bearish color schemes across the ribbon, its layered bands, and optional bar and background coloring. The ribbon renders the same cascade across its phase range rather than a single line, so it opens as price runs ahead of the smoothed estimate and closes as that gap narrows, with band opacity brightening and fading on the same measure, and a width multiplier scales the whole ribbon for presence on zoomed-out charts. Bar coloring tints price candles with the active trend color at a configurable transparency level, and background coloring extends the directional tint across the full chart pane.
[image]https://www.tradingview.com/x/AndJzO0c/[/image]

---

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Jurik Trend Ribbon [QuantAlgo]', overlay = true)

//              ╔════════════════════════════════╗
//              ║      USER-DEFINED SETTINGS     ║
//              ╚════════════════════════════════╝

var string filter_settings = '════════ Jurik Filter ════════'
var string state_settings  = '════════ Trend State ════════'
var string visual_settings = '════════ Visual Settings ════════'

tooltip_preset     = 'Select a predefined configuration optimized for different trading styles and timeframes.\n\nImportant: selecting any preset other than Default overrides every Jurik Filter and Trend State setting below it. Manual changes to those inputs will have no effect until the preset is returned to Default.'
tooltip_preset_det = 'Default (Length 14, Power 1.5, ATR 14, Multiplier 1.5): Balanced configuration for swing trading on 1H to daily charts. Requires roughly three ATR of filter displacement before the trend state reverses.\n\nFast Response (Length 8, Power 1.0, ATR 10, Multiplier 1.0): Aggressive configuration for intraday trading on 5min to 1H charts. A shorter filter and tighter deadband surface shorter-duration moves at the cost of more frequent state changes.\n\nSmooth Trend (Length 21, Power 2.0, ATR 21, Multiplier 2.5): Conservative configuration for position trading on daily and weekly charts. Heavy smoothing and a five ATR reversal requirement hold direction through deep retracements.'
tooltip_src        = 'Price data passed through the Jurik filter. Close is standard and works well in most conditions. hl2 incorporates the bar range and can reduce wick-driven noise. hlc3 adds further stability by averaging high, low, and close equally.\n\nAlert setup: set alerts to Once Per Bar Close, not Once Per Bar. The filter reads the source on every tick, so on a forming bar the ribbon moves continuously and the trend state can flip and revert before that bar completes. Once Per Bar Close fires only on values that are final and will not change.'
tooltip_length     = 'Sampling length of the Jurik filter in bars. This is the primary smoothness control. Shorter lengths track price more tightly and open the ribbon sooner. Longer lengths suppress noise and delay state changes.'
tooltip_mode       = 'Classic holds the smoothing exponent fixed at the Power setting below, matching the standard Jurik formulation. Adaptive replaces it with an exponent scaled by normalized realized volatility, tightening the filter as volatility expands and loosening it as volatility contracts, and needs roughly 75 bars of history before the volatility baseline is valid.\n\nAdaptive makes the filter faster during volatility expansion, which will produce more frequent state changes than Classic at the same ATR Multiplier. If you switch to Adaptive, expect to widen the multiplier.'
tooltip_power      = 'Fixed smoothing exponent applied to the filter coefficient. Only applies when Smoothing Mode is set to Classic. Lower values produce a faster, noisier filter. Higher values produce a slower, cleaner filter.'
tooltip_atr_len    = 'Lookback for Average True Range, which sets the unit of the trend deadband. The trend state only changes when the filter walks beyond this volatility envelope.'
tooltip_atr_mult   = 'Width of the trend deadband in ATR units. The state machine stores a level and only moves it when the filter clears that level by this margin, so reversing direction requires the filter to travel twice this distance. At the default of 1.5 the filter must displace roughly three ATR before the state flips, which is what carries direction through pullbacks and suppresses false signals.\n\nRaise it for fewer, later state changes. Lower it for faster, noisier ones. This is the primary tuning control.'
tooltip_warmup     = 'Suppresses all output while the recursive filters settle. The Jurik cascade, the ATR, and the Adaptive volatility baseline each need history before their values are meaningful.'
tooltip_preset_col = 'Pre-configured color schemes optimized for different chart themes and visual preferences. Custom allows full color control using the two color inputs below. Classic uses traditional green/red. Aqua provides ocean-inspired tones. Cosmic offers futuristic cyan and purple. Cyber features warm orange and cool cyan contrast. Neon delivers high-contrast yellow and magenta for maximum visibility.'
tooltip_bullish    = 'Color applied to the ribbon while the trend state is bullish. Only applies when Color Preset is set to Custom.'
tooltip_bearish    = 'Color applied to the ribbon while the trend state is bearish. Only applies when Color Preset is set to Custom.'
tooltip_scale      = 'Vertical scaling applied to the ribbon for display. Each of the thirteen bands is expanded away from the filter centre by this factor, which inflates the ribbon without changing where it sits. Raise it for a heavier presence on zoomed-out charts, lower it toward 1.0 to render the filter dispersion at true scale.\n\nThis setting is purely cosmetic. Trend direction and all alerts are calculated on the unscaled filter output and are identical at every value.'
tooltip_opacity    = 'Opacity floor the ribbon fades toward as it collapses, expressed as a fraction of its full opacity. A collapsed ribbon means the filter has closed on its own baseline and price has little directional velocity, so easing the bands back adds depth without hiding them. Raise it to keep the ribbon solid at every width, lower it for a stronger contrast between running and stalled conditions. At 1.0 the fade is disabled and opacity is held constant.'
tooltip_candles    = 'Enable/disable bar coloring based on current trend state, providing instant visual confirmation without reading the ribbon directly.'
tooltip_bar_trans  = 'Transparency of the bar coloring overlay. Lower values produce vivid bars. Higher values apply a subtle tint that preserves price action visibility.'
tooltip_bg         = 'Enable/disable background shading based on current trend state, tinting the chart field without altering the ribbon.'
tooltip_bg_trans   = 'Transparency of the background shading. Lower values produce a stronger wash. Higher values keep the tint subtle so price action remains readable.'

preset         = input.string('Default', 'Preset Configuration', options = ['Default', 'Fast Response', 'Smooth Trend'], group = filter_settings, tooltip = tooltip_preset + '\n\n' + tooltip_preset_det)
jurik_source   = input.source(close, 'Price Source', group = filter_settings, tooltip = tooltip_src)
jurik_length   = input.int(14, 'Length', minval = 2, group = filter_settings, tooltip = tooltip_length)
smoothing_mode = input.string('Classic', 'Smoothing Mode', options = ['Classic', 'Adaptive'], group = filter_settings, tooltip = tooltip_mode)
jurik_power    = input.float(1.5, 'Power', minval = 0.1, maxval = 4.0, step = 0.1, group = filter_settings, tooltip = tooltip_power)

atr_length     = input.int(14, 'ATR Length', minval = 1, group = state_settings, tooltip = tooltip_atr_len)
atr_multiplier = input.float(1.5, 'ATR Multiplier', minval = 0.1, step = 0.1, group = state_settings, tooltip = tooltip_atr_mult)
warmup_bars    = input.int(100, 'Warm-up Bars', minval = 0, group = state_settings, tooltip = tooltip_warmup)

color_preset  = input.string('Custom', 'Color Preset', options = ['Custom', 'Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon'], group = visual_settings, tooltip = tooltip_preset_col)
bullish_input = input.color(#00ffaa, 'Bullish Color', group = visual_settings, tooltip = tooltip_bullish)
bearish_input = input.color(#ff0000, 'Bearish Color', group = visual_settings, tooltip = tooltip_bearish)
ribbon_scale  = input.float(3.0, 'Ribbon Width', minval = 1.0, maxval = 5.0, step = 0.1, group = visual_settings, tooltip = tooltip_scale)
min_opacity   = input.float(0.5, 'Minimum Ribbon Opacity', minval = 0.01, maxval = 1.0, step = 0.01, group = visual_settings, tooltip = tooltip_opacity)
show_candles  = input.bool(false, 'Enable Bar Coloring', group = visual_settings, tooltip = tooltip_candles)
bar_trans     = input.int(0, 'Bar Color Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bar_trans)
show_bg       = input.bool(false, 'Enable Background Coloring', group = visual_settings, tooltip = tooltip_bg)
bg_trans      = input.int(90, 'Background Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bg_trans)

if preset == 'Fast Response'
    jurik_length   := 8
    jurik_power    := 1.0
    atr_length     := 10
    atr_multiplier := 1.0
else if preset == 'Smooth Trend'
    jurik_length   := 21
    jurik_power    := 2.0
    atr_length     := 21
    atr_multiplier := 2.5

[bullish_color, bearish_color] = switch color_preset
    'Classic' => [#00ff00, #ff0000]
    'Aqua'    => [#00d4ff, #ff8c00]
    'Cosmic'  => [#49ffce, #9932cc]
    'Cyber'   => [#00cccc, #ff6600]
    'Neon'    => [#ffff00, #ff00ff]
    => [bullish_input, bearish_input]

//              ╔════════════════════════════════╗
//              ║        CORE CALCULATION        ║
//              ╚════════════════════════════════╝

jurikCoefficients(src, length, power, adaptive) =>
    beta         = 0.45 * (length - 1) / (0.45 * (length - 1) + 2.0)
    length_scale = math.sqrt(0.5 * (length - 1))
    exp_base     = math.max(math.log(length_scale) / math.log(2.0) + 2.0, 0.0)
    volty_exp    = math.max(exp_base - 2.0, 0.5)
    band_length  = length_scale * exp_base
    band_beta    = band_length / (band_length + 1.0)
    ratio_cap    = math.pow(exp_base, 1.0 / volty_exp)

    var float upper_volty = na
    var float lower_volty = na
    prior_upper = na(upper_volty) ? src : upper_volty
    prior_lower = na(lower_volty) ? src : lower_volty
    upper_delta = src - prior_upper
    lower_delta = src - prior_lower
    abs_upper   = math.abs(upper_delta)
    abs_lower   = math.abs(lower_delta)
    volty_raw   = abs_upper == abs_lower ? 0.0 : math.max(abs_upper, abs_lower)

    volty_short    = ta.sma(volty_raw, 10)
    volty_baseline = ta.sma(volty_short, 65)
    volty_ratio    = math.max(1.0, math.min(ratio_cap, nz(volty_baseline) > 0 ? volty_raw / volty_baseline : 1.0))
    dynamic_exp    = math.pow(volty_ratio, volty_exp)
    band_factor    = math.pow(band_beta, math.sqrt(dynamic_exp))

    upper_volty := upper_delta > 0 ? src : src - band_factor * upper_delta
    lower_volty := lower_delta < 0 ? src : src - band_factor * lower_delta

    [adaptive ? math.pow(beta, dynamic_exp) : math.pow(beta, power), beta]

jurikFilter(src, alpha, beta, phase) =>
    phase_ratio = math.max(0.5, math.min(2.5, phase / 100.0 + 1.5))
    inv_alpha   = 1.0 - alpha
    var float stage_one   = na
    var float detrend     = 0.0
    var float stage_three = 0.0
    var float result      = na
    if na(result)
        stage_one := src
        result    := src
    else
        stage_one   := inv_alpha * src + alpha * stage_one
        detrend     := (src - stage_one) * (1.0 - beta) + beta * detrend
        phase_shift = stage_one + phase_ratio * detrend
        stage_three := (phase_shift - result) * inv_alpha * inv_alpha + alpha * alpha * stage_three
        result      := result + stage_three
    result

[jurik_alpha, jurik_beta] = jurikCoefficients(jurik_source, jurik_length, jurik_power, smoothing_mode == 'Adaptive')

anchor = jurikFilter(jurik_source, jurik_alpha, jurik_beta, 0)
lead_7 = jurikFilter(jurik_source, jurik_alpha, jurik_beta, 100)
lead_6 = jurikFilter(jurik_source, jurik_alpha, jurik_beta, 86)
lead_5 = jurikFilter(jurik_source, jurik_alpha, jurik_beta, 71)
lead_4 = jurikFilter(jurik_source, jurik_alpha, jurik_beta, 57)
lead_3 = jurikFilter(jurik_source, jurik_alpha, jurik_beta, 43)
lead_2 = jurikFilter(jurik_source, jurik_alpha, jurik_beta, 29)
lead_1 = jurikFilter(jurik_source, jurik_alpha, jurik_beta, 14)
lag_1  = jurikFilter(jurik_source, jurik_alpha, jurik_beta, -14)
lag_2  = jurikFilter(jurik_source, jurik_alpha, jurik_beta, -29)
lag_3  = jurikFilter(jurik_source, jurik_alpha, jurik_beta, -43)
lag_4  = jurikFilter(jurik_source, jurik_alpha, jurik_beta, -57)
lag_5  = jurikFilter(jurik_source, jurik_alpha, jurik_beta, -71)
lag_6  = jurikFilter(jurik_source, jurik_alpha, jurik_beta, -86)
lag_7  = jurikFilter(jurik_source, jurik_alpha, jurik_beta, -100)

deviation   = ta.atr(atr_length) * atr_multiplier
upper_bound = anchor + deviation
lower_bound = anchor - deviation

var float ratchet   = na
var int   trend_dir = 0

if na(ratchet)
    ratchet   := anchor
    trend_dir := 1
else if upper_bound < ratchet
    ratchet   := upper_bound
    trend_dir := -1
else if lower_bound > ratchet
    ratchet   := lower_bound
    trend_dir := 1

prior_dir = nz(trend_dir[1], trend_dir)
is_ready  = bar_index >= warmup_bars and not na(ratchet)

turned_bull  = is_ready and trend_dir == 1 and prior_dir != 1
turned_bear  = is_ready and trend_dir == -1 and prior_dir != -1
state_change = turned_bull or turned_bear

trend_color = trend_dir == 1 ? bullish_color : bearish_color

//              ╔════════════════════════════════╗
//              ║         VISUALIZATION          ║
//              ╚════════════════════════════════╝

transpOf(opacity) => math.min(100.0, math.max(0.0, 100.0 - opacity * 100.0))

bandGradient(base, width, opacity, fade) =>
    color.from_gradient(width, 0.0, 1.5, color.new(base, transpOf(opacity * fade)), color.new(base, transpOf(opacity)))

scaleBand(value, midpoint, factor) => midpoint + (value - midpoint) * factor

atr_unit       = math.max(ta.atr(atr_length), syminfo.mintick)
ribbon_width   = math.abs(lead_7 - lag_7) / atr_unit

fill_1 = bandGradient(trend_color, ribbon_width, 1.00, min_opacity)
fill_2 = bandGradient(trend_color, ribbon_width, 0.92, min_opacity)
fill_3 = bandGradient(trend_color, ribbon_width, 0.83, min_opacity)
fill_4 = bandGradient(trend_color, ribbon_width, 0.73, min_opacity)
fill_5 = bandGradient(trend_color, ribbon_width, 0.62, min_opacity)
fill_6 = bandGradient(trend_color, ribbon_width, 0.50, min_opacity)
fill_7 = bandGradient(trend_color, ribbon_width, 0.38, min_opacity)
edge_color = color.new(trend_color, transpOf(0.30))
hidden     = color.new(trend_color, 100)

plot_lead_7 = plot(is_ready ? scaleBand(lead_7, anchor, ribbon_scale) : na, title = 'Lead 7', color = edge_color, editable = false, display = display.pane)
plot_lead_6 = plot(is_ready ? scaleBand(lead_6, anchor, ribbon_scale) : na, title = 'Lead 6', color = hidden, editable = false, display = display.pane)
plot_lead_5 = plot(is_ready ? scaleBand(lead_5, anchor, ribbon_scale) : na, title = 'Lead 5', color = hidden, editable = false, display = display.pane)
plot_lead_4 = plot(is_ready ? scaleBand(lead_4, anchor, ribbon_scale) : na, title = 'Lead 4', color = hidden, editable = false, display = display.pane)
plot_lead_3 = plot(is_ready ? scaleBand(lead_3, anchor, ribbon_scale) : na, title = 'Lead 3', color = hidden, editable = false, display = display.pane)
plot_lead_2 = plot(is_ready ? scaleBand(lead_2, anchor, ribbon_scale) : na, title = 'Lead 2', color = hidden, editable = false, display = display.pane)
plot_lead_1 = plot(is_ready ? scaleBand(lead_1, anchor, ribbon_scale) : na, title = 'Lead 1', color = hidden, editable = false, display = display.pane)
plot_lag_1  = plot(is_ready ? scaleBand(lag_1, anchor, ribbon_scale) : na,  title = 'Lag 1',  color = hidden, editable = false, display = display.pane)
plot_lag_2  = plot(is_ready ? scaleBand(lag_2, anchor, ribbon_scale) : na,  title = 'Lag 2',  color = hidden, editable = false, display = display.pane)
plot_lag_3  = plot(is_ready ? scaleBand(lag_3, anchor, ribbon_scale) : na,  title = 'Lag 3',  color = hidden, editable = false, display = display.pane)
plot_lag_4  = plot(is_ready ? scaleBand(lag_4, anchor, ribbon_scale) : na,  title = 'Lag 4',  color = hidden, editable = false, display = display.pane)
plot_lag_5  = plot(is_ready ? scaleBand(lag_5, anchor, ribbon_scale) : na,  title = 'Lag 5',  color = hidden, editable = false, display = display.pane)
plot_lag_6  = plot(is_ready ? scaleBand(lag_6, anchor, ribbon_scale) : na,  title = 'Lag 6',  color = hidden, editable = false, display = display.pane)
plot_lag_7  = plot(is_ready ? scaleBand(lag_7, anchor, ribbon_scale) : na,  title = 'Lag 7',  color = edge_color, editable = false, display = display.pane)

fill(plot_lead_7, plot_lead_6, color = fill_7, title = 'Band 13')
fill(plot_lead_6, plot_lead_5, color = fill_6, title = 'Band 12')
fill(plot_lead_5, plot_lead_4, color = fill_5, title = 'Band 11')
fill(plot_lead_4, plot_lead_3, color = fill_4, title = 'Band 10')
fill(plot_lead_3, plot_lead_2, color = fill_3, title = 'Band 9')
fill(plot_lead_2, plot_lead_1, color = fill_2, title = 'Band 8')
fill(plot_lead_1, plot_lag_1,  color = fill_1, title = 'Band 7')
fill(plot_lag_1,  plot_lag_2,  color = fill_2, title = 'Band 6')
fill(plot_lag_2,  plot_lag_3,  color = fill_3, title = 'Band 5')
fill(plot_lag_3,  plot_lag_4,  color = fill_4, title = 'Band 4')
fill(plot_lag_4,  plot_lag_5,  color = fill_5, title = 'Band 3')
fill(plot_lag_5,  plot_lag_6,  color = fill_6, title = 'Band 2')
fill(plot_lag_6,  plot_lag_7,  color = fill_7, title = 'Band 1')

barcolor(show_candles and is_ready ? color.new(trend_color, bar_trans) : na, title = 'Trend Bar Color')
bgcolor(show_bg and is_ready ? color.new(trend_color, bg_trans) : na, title = 'Trend Background')

//              ╔════════════════════════════════╗
//              ║             ALERTS             ║
//              ╚════════════════════════════════╝

alertcondition(turned_bull,  title = 'Bullish Trend Signal', message = 'Jurik Trend Ribbon: BULLISH state confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(turned_bear,  title = 'Bearish Trend Signal', message = 'Jurik Trend Ribbon: BEARISH state confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(state_change, title = 'Any Trend Change',     message = 'Jurik Trend Ribbon: Trend state changed on {{exchange}}:{{ticker}} - {{interval}}')

//              ╔════════════════════════════════╗
//              ║           CREATED BY           ║
//              ╚════════════════════════════════╝

// ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗     █████╗ ██╗      ██████╗  ██████╗ 
//██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝    ██╔══██╗██║     ██╔════╝ ██╔═══██╗
//██║   ██║██║   ██║███████║██╔██╗ ██║   ██║       ███████║██║     ██║  ███╗██║   ██║
//██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║       ██╔══██║██║     ██║   ██║██║   ██║
//╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║       ██║  ██║███████╗╚██████╔╝╚██████╔╝
// ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
````
