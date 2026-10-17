# Market Regime [EMA & ATR]

- url: https://www.tradingview.com/script/8dc7tAvH/
- type: indicator
- pine_id: PUB;54efdbb2978f43c1b70318a43d211098
- version: 1.0

## Description

Description:

The Market Regime Explorer is a comprehensive multi-timeframe indicator designed to identify the current market environment by combining trend direction and volatility breakouts. It utilizes a dual-chart display technique, bringing essential trend data to your main chart while keeping momentum and volatility metrics neatly organized in the subchart.

Key Features:

[list]
[*]Dual-Display Magic (Main Chart & Subchart): Built with Pine Script v5's force_overlay feature, this script plots the moving average directly over your price action on the main chart, while simultaneously rendering the ATR and EMA Slope in a clean subchart below.

[*]Trend Direction (Main Chart): A customizable moving average (Default: 200 EMA) is plotted on the main chart. It dynamically changes color based on whether the price closes above or below the MA, giving you an immediate visual cue of the baseline trend.

[*]Volatility Breakouts (Subchart): The ATR line tracks market volatility. When the ATR breaches your custom threshold (Default: 25), the area fills with color to signal an active market regime.

[*]Momentum Coloring: The ATR fill color is driven by the slope (momentum) of the EMA. If the EMA is rising during a volatility breakout, it paints green. If the EMA is falling, it paints red. If volatility is below the threshold, it remains a neutral gray.

[*]On-Chart HUD Gauge: A dynamic, visual progress bar (Heads-Up Display) is drawn directly on your chart. It visualizes the current EMA slope percentage in real-time, functioning like a speedometer. The gauge features a customizable limit (clipping) and smoothly transitions from red (strong downtrend) to yellow (neutral) to green (strong uptrend).

[*]Multi-Timeframe (MTF) Support: Easily track higher timeframe market regimes without changing your current chart view using the built-in MTF dropdown.
[/list]
Customization:
Every aspect of this indicator is fully customizable. You can adjust the MA types (SMA, EMA, WMA, RMA), smoothing lengths, ATR thresholds, HUD positioning, and color schemes to perfectly fit your trading strategy and visual preferences.

[i]Disclaimer:
This script is provided for educational and informational purposes only and does not constitute financial advice. Trading in financial markets involves a high level of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always conduct your own research and trade at your own risk.[/i]

## Source Code

````pine
//@version=6
indicator('Market Regime [EMA & ATR]', shorttitle = 'Market Regime', overlay = false)

// =========================================================================
// 1. GENERAL INPUTS (TIMEFRAME)
// =========================================================================
res = input.timeframe('', title = 'Timeframe')

// =========================================================================
// 2. EMA SETTINGS
// =========================================================================
grpEma = 'EMA Settings'
emaLen = input.int(200, title = 'Length', group = grpEma)
emaSrc = input.source(close, title = 'Source', group = grpEma)
emaOffset = input.int(0, title = 'Offset', group = grpEma)
smoothType = input.string('None', title = 'Smoothing Type', options = ['None', 'SMA', 'EMA', 'WMA', 'RMA'], group = grpEma)
smoothLen = input.int(14, title = 'Smoothing Length', group = grpEma)
smoothStd = input.float(2.0, title = 'Smoothing StdDev', group = grpEma, tooltip = 'Mostly unused for basic MAs, kept for completeness.')

// =========================================================================
// 3. ATR SETTINGS
// =========================================================================
grpAtr = 'ATR Settings'
atrLen = input.int(14, title = 'Length', group = grpAtr)
atrSmooth = input.string('RMA', title = 'Smoothing', options = ['RMA', 'SMA', 'EMA', 'WMA'], group = grpAtr)
atrThresh = input.float(25.0, title = 'ATR Threshold', group = grpAtr, step = 0.1)

// =========================================================================
// 4. COLOR SETTINGS
// =========================================================================
grpCol = 'Colors'
colEmaUp = input.color(color.red, title = 'EMA Above Price', group = grpCol)
colEmaDn = input.color(color.green, title = 'EMA Below Price', group = grpCol)

colAtrUp = input.color(color.green, title = 'ATR > Thresh & EMA Rising', group = grpCol)
colAtrDn = input.color(color.red, title = 'ATR > Thresh & EMA Falling', group = grpCol)
colAtrGray = input.color(color.gray, title = 'ATR < Thresh', group = grpCol)

// =========================================================================
// 5. GAUGE BAR SETTINGS (HUD)
// =========================================================================
grpGauge = 'EMA Slope Gauge (HUD)'
showGauge = input.bool(true, title = 'Show EMA Slope Gauge', group = grpGauge)
gaugeMax = input.float(0.01, title = 'Gauge Range Limit (+/- %)', group = grpGauge, step = 0.01, tooltip = 'Limits the gauge scale. Values beyond this are clipped to the edges.')
gaugePosStr = input.string('Top Right', title = 'Gauge Position', options = ['Top Right', 'Top Center', 'Top Left', 'Bottom Right', 'Bottom Center', 'Bottom Left'], group = grpGauge)

// Helper function to convert string to position
get_pos(p) =>
    p == 'Top Right' ? position.top_right : p == 'Top Center' ? position.top_center : p == 'Top Left' ? position.top_left : p == 'Bottom Right' ? position.bottom_right : p == 'Bottom Center' ? position.bottom_center : position.bottom_left

// =========================================================================
// 6. CALCULATION FUNCTIONS
// =========================================================================
get_smoothed(src, type, len) =>
    float out = src
    if type == 'SMA'
        out := ta.sma(src, len)
        out
    else if type == 'EMA'
        out := ta.ema(src, len)
        out
    else if type == 'RMA'
        out := ta.rma(src, len)
        out
    else if type == 'WMA'
        out := ta.wma(src, len)
        out
    out

calc_data() =>
    // EMA Calculation
    float _ema_base = ta.ema(emaSrc, emaLen)
    float _ema = smoothType == 'None' ? _ema_base : get_smoothed(_ema_base, smoothType, smoothLen)

    // ATR Calculation
    float _tr = ta.tr(true)
    float _atr = get_smoothed(_tr, atrSmooth, atrLen)

    // EMA Slope (%)
    float _ema_pct = na(_ema[1]) ? 0 : (_ema - _ema[1]) / _ema[1] * 100

    [_ema, _atr, _ema_pct, close]

// =========================================================================
// 7. MULTI-TIMEFRAME DATA FETCH
// =========================================================================
[ema_val, atr_val, ema_pct, close_val] = request.security(syminfo.tickerid, res, calc_data())

// =========================================================================
// 8. LOGIC & COLORING (PLOTTING)
// =========================================================================
// EMA Color (Main chart)
color emaColor = ema_val > close_val ? colEmaUp : colEmaDn

// ATR Color based on threshold and EMA slope
color atrColor = colAtrGray
if atr_val > atrThresh
    if ema_pct > 0
        atrColor := colAtrUp
        atrColor
    else if ema_pct < 0
        atrColor := colAtrDn
        atrColor

// EMA in MAIN CHART
plot(ema_val, title = 'EMA (Main Chart)', color = emaColor, linewidth = 2, offset = emaOffset, force_overlay = true)

// ATR Threshold 
hline(atrThresh, title = 'ATR Threshold Dashed', color = color.gray, linestyle = hline.style_dashed)
p_thresh = plot(atrThresh, title = 'ATR Threshold Hidden', color = color.new(color.white, 100))

// ATR Line in SUBCHART
p_atr = plot(atr_val, title = 'ATR Line', color = atrColor, linewidth = 2, style = plot.style_line)

// Fill area between ATR Line and Threshold
fillColor = color.new(atrColor, 80)
fill(p_atr, p_thresh, color = fillColor, title = 'ATR Fill')

// EMA Slope (%) in SUBCHART
plot(ema_pct, title = 'EMA Slope (%)', color = color.new(color.blue, 70), style = plot.style_area)

// =========================================================================
// 9. DRAWING THE GAUGE BAR (HUD)
// =========================================================================
var int gaugeCells = 21 // Number of cells to make the bar smooth
var table gaugeTable = table.new(get_pos(gaugePosStr), gaugeCells, 1, border_width = 1, border_color = color.black, frame_color = color.black, frame_width = 1)

// Only update the gauge on the last bar to save resources
if barstate.islast and showGauge
    // 1. Clipping: Clamp the current slope to the max/min limit
    float maxLimit = math.abs(gaugeMax)
    float clamped_slope = math.max(math.min(ema_pct, maxLimit), -maxLimit)

    // 2. Normalize value to a 0.0 - 1.0 range
    float norm = (clamped_slope + maxLimit) / (2 * maxLimit)

    // 3. Find active cell index (0 to 20)
    int activeIdx = math.round(norm * (gaugeCells - 1))

    // 4. Draw the bar cells
    for i = 0 to gaugeCells - 1 by 1
        // Determine section color (Left: Red, Middle: Yellow, Right: Green)
        color cellCol = color.gray
        if i < 7
            cellCol := color.red
            cellCol
        else if i < 14
            cellCol := color.yellow
            cellCol
        else
            cellCol := color.green
            cellCol

        // Arrow placement
        string pointerTxt = i == activeIdx ? '▲' : ''

        // Draw Cell
        table.cell(gaugeTable, i, 0, text = pointerTxt, text_color = color.black, bgcolor = cellCol, width = 1.5, height = 4, text_size = size.normal)
````
