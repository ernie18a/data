<!-- tradingview-pine-id: PUB;fec1cf71518f401695738515bd21e038 -->
<!-- tradingviewscripts-format: 1 -->
# Bionic -- EMA Crossover with Target Price Levels & EMAs [FREE]

Source: https://www.tradingview.com/script/1vr0Phb5-Bionic-EMA-Crossover-with-Target-Price-Levels-EMAs-FREE/

## Description

Here is the complete writeup, ready to post:

Bionic - EMA Crossover with Target Price Levels & EMAs [FREE]

This indicator combines a two-EMA crossover signal system with automatically projected price targets and a configurable stack of up to eight additional EMAs. The goal is a single overlay that identifies trend shifts, quantifies where price has historically traveled after those shifts, and keeps your key moving averages labeled on the chart.

Crossover Signals

The core signal engine watches two EMAs (default 9 and 21, both configurable). When the fast EMA crosses above the slow EMA, a green up arrow prints below the bar. When the fast EMA crosses below the slow EMA, a red down arrow prints above the bar. Both arrow colors are configurable, and alert conditions are included for each direction so you can route signals to TradingView notifications.

Target Price Levels

At each confirmed crossover, the indicator projects two horizontal target lines. These targets are derived from your chart's recent history: the script scans a configurable lookback window (default 500 bars), measures how far price has typically extended beyond prior crossover points in that window, and anchors half-move and full-move projections from the open of the signal bar.

Bullish crossovers produce Bull Target 1 (half of the historical extension) and Bull Target 2 (the full historical extension) above the entry area.
Bearish crossunders produce Bear Target 1 and Bear Target 2 below the entry area.

An optional label setting displays the exact price of each target on the chart.

Two behaviors are by design and worth understanding before use. First, target levels reflect the state of the lookback window at the moment the signal fires. Because the window rolls forward with each bar, the same historical crossover can show different target values depending on when the chart is loaded. Targets are calculated on confirmed bars and do not repaint after placement, but they are snapshots of recent statistics rather than fixed structural levels. Second, only the most recent signal's targets remain on the chart. Each new crossover deletes the prior target lines and labels, so the display always represents the active signal.

Targets are statistical references drawn from past behavior on the current symbol and timeframe. They are context for planning exits, not guarantees.

EMA Shading

The area between the two signal EMAs is shaded by market posture: bullish coloring when price holds above both EMAs, bearish coloring when price sits below both, neutral coloring when price is between them, and distinct crossover and crossunder colors at the moment of a signal. All five colors are configurable, and the shading can be disabled entirely.

Multiple EMAs

Beyond the signal pair, the indicator plots up to eight independent EMAs (defaults include 9, 21, 34, 55, and an optional 400, with four slots off by default). Each EMA has its own length, color, and enable toggle. Each line carries a floating label at its right edge showing the EMA length and, optionally, its live price. Label distance and line width are globally configurable.

Global Toggles

Top-level switches let you disable all EMAs, disable shading, or suppress bullish or bearish target lines independently, so you can strip the display down to only the elements you trade with.

Settings Summary

EMA Cross Configuration: signal EMA lengths, lookback window for target calculation, target label toggle
Arrow Color Configuration: up and down arrow colors
Shading Settings: five posture colors
Multiple EMAs: eight configurable EMA slots plus global label and width controls

This indicator is a decision-support tool. It does not constitute financial advice. Test it on your instrument and timeframe before trading live.

---

## Source Code

````pine
//@version=6
indicator('Bionic -- EMA Crossover with Target Price Levels & EMAs [FREE]', shorttitle = 'Bionic - EMA Cross w/Target Price [FREE]', overlay = true)
enableAllEMAs = input.bool(false, 'Disable All EMAs', group = 'Global -- On/Off Toggles')
turnOffEMAShading = input.bool(false, 'Disable Shading Between EMAs', group = 'Global -- On/Off Toggles')
enableBullLines = input.bool(false, 'Disable Bullish Target Lines', group = 'Global -- On/Off Toggles')
enableBearLines = input.bool(false, 'Disable Bearish Target Lines', group = 'Global -- On/Off Toggles')
disableTargetLabels = input.bool(false, 'Disable Target Price Labels', group = 'Global -- On/Off Toggles')

// User inputs for EMA lengths
ema1_length = input.int(9, 'EMA 1 Length', minval = 1, group = 'EMA Cross Configration')
ema2_length = input.int(21, 'EMA 2 Length', minval = 1, group = 'EMA Cross Configration')

// Other user inputs
arraylookback = input.float(500, 'ATR Lookback Length', group = 'EMA Cross Configration', tooltip = 'Value to calculate the target price levels.')


// Inputs for arrow colors
up_arrow_color = input.color(color.green, title = 'Up Arrow Color', group = 'Arrow Color Configuration')
down_arrow_color = input.color(color.red, title = 'Down Arrow Color', group = 'Arrow Color Configuration')

// Vertical connector from crossover arrow to target lines
vert_line_width = input.int(3, 'Vertical Line Width', minval = 1, group = 'Crossover-to-Target Vertical Line')
vert_bull_color = input.color(color.green, 'Bullish Vertical Line Color', group = 'Crossover-to-Target Vertical Line')
vert_bear_color = input.color(color.red, 'Bearish Vertical Line Color', group = 'Crossover-to-Target Vertical Line')

// Target line label configuration
tgt1_lbl_text = input.string('Target 1', 'Target 1 Label Text', group = 'Target Line Labels Configuration')
tgt2_lbl_text = input.string('Target 2', 'Target 2 Label Text', group = 'Target Line Labels Configuration')
bull_lbl_color = input.color(color.new(color.lime, 50), 'Bullish Label Color', group = 'Target Line Labels Configuration')
bear_lbl_color = input.color(color.new(color.red, 50), 'Bearish Label Color', group = 'Target Line Labels Configuration')
tgt_lbl_text_color = input.color(color.white, 'Label Text Color', group = 'Target Line Labels Configuration')

// Calculating EMAs
ema1 = ta.ema(close, ema1_length)
ema2 = ta.ema(close, ema2_length)

// Determine the crossover points
ema1_cross_ema2 = ta.crossover(ema1, ema2)
ema2_cross_ema1 = ta.crossover(ema2, ema1)

// Plot arrows on the chart at the crossover points
plotshape(ema1_cross_ema2 ? close : na, title = 'Up Arrow', location = location.belowbar, style = shape.triangleup, size = size.small, color = up_arrow_color)
plotshape(ema2_cross_ema1 ? close : na, title = 'Down Arrow', location = location.abovebar, style = shape.triangledown, size = size.small, color = down_arrow_color)

// Sentiment 
bool bullish = close >= ema1 and close >= ema2
bool bearish = close <= ema1 and close <= ema2
bool neutral = close < ema1 and close > ema2

// User-configurable color inputs (base colors)
bull_base = input.color(color.lime, 'Bullish Color', group = 'Shading between EMAs Settings')
bear_base = input.color(color.red, 'Bearish Color', group = 'Shading between EMAs Settings')
neutralcolor_base = input.color(color.gray, 'Neutral Color', group = 'Shading between EMAs Settings')
crossovercolor_base = input.color(color.purple, 'Crossover Color', group = 'Shading between EMAs Settings')
crossundercolor_base = input.color(color.orange, 'Crossunder Color', group = 'Shading between EMAs Settings')

// Default transparency (50%)
default_opacity = 50

// Apply transparency to colors
bull = color.new(bull_base, default_opacity)
bear = color.new(bear_base, default_opacity)
neutralcolor = color.new(neutralcolor_base, default_opacity)
crossovercolor = color.new(crossovercolor_base, default_opacity)
crossundercolor = color.new(crossundercolor_base, default_opacity)


color pallette = bullish ? bull : bearish ? bear : neutralcolor
color emacolor = ema1_cross_ema2 ? crossovercolor : ema2_cross_ema1 ? crossundercolor : pallette

// Plot EMAs and fill area between them
filla = plot(turnOffEMAShading ? na : ema1, color = emacolor, linewidth = 1)
fillb = plot(turnOffEMAShading ? na : ema2, color = emacolor, linewidth = 1)
fill(filla, fillb, color = pallette)

// Other logic for crossover and crossunder
bool above_ema = close >= ema1 and close >= ema2
bool below_ema = close < ema1 and close <= ema2
bool crossover = ema1_cross_ema2
bool crossunder = ema2_cross_ema1

bull_a = array.new_float()
crossover_a = array.new_float()
crossunder_a = array.new_float()
bear_a = array.new_float()

for i = 0 to arraylookback by 1
    if above_ema[i]
        array.push(bull_a, close[i])
    if crossover[i]
        array.push(crossover_a, close[i])
    if below_ema[i]
        array.push(bear_a, close[i])
    if crossunder[i]
        array.push(crossunder_a, close[i])

max_above = array.max(bull_a)
crossover_avg = array.avg(crossover_a)
max_below = array.min(bear_a)
crossunder_avg = array.avg(crossunder_a)

bull_dif1 = (max_above - crossover_avg) / 2
bull_dif2 = max_above - crossover_avg
bear_dif1 = (crossunder_avg - max_below) / 2
bear_dif2 = crossunder_avg - max_below

// Anchor and targets default to na so missing history skips drawing instead of anchoring at 0
float op = na
float bull_tgt = na
float bull_tgt_2 = na
float bear_tgt = na
float bear_tgt_2 = na
var label bull_tgt_1_lbl = na
var label bull_tgt_2_lbl = na
var label bear_tgt_1_lbl = na
var label bear_tgt_2_lbl = na
var line bull_tgt_lin = na
var line bull_tgt_lin_2 = na
var line bear_tgt_lin = na
var line bear_tgt_lin_2 = na
var line bull_vert_lin = na
var line bear_vert_lin = na

if crossover
    // Anchor to this cross bar's own open
    op := open
    bull_tgt := op + bull_dif1
    bull_tgt_2 := op + bull_dif2
    bull_tgt_2
if crossunder
    // Anchor to this cross bar's own open
    op := open
    bear_tgt := op - bear_dif1
    bear_tgt_2 := op - bear_dif2
    bear_tgt_2

if crossover and barstate.isconfirmed
    line.delete(bull_tgt_lin)
    line.delete(bull_tgt_lin_2)
    line.delete(bull_vert_lin)
    label.delete(bull_tgt_1_lbl)
    label.delete(bull_tgt_2_lbl)
    if not enableBullLines and not na(bull_tgt_2)
        bull_tgt_lin := line.new(bar_index[1], y1 = bull_tgt, x2 = bar_index, y2 = bull_tgt, extend = extend.right, color = bull, width = 3)
        bull_tgt_lin_2 := line.new(bar_index[1], y1 = bull_tgt_2, x2 = bar_index, y2 = bull_tgt_2, extend = extend.right, color = bull, width = 3)
        bull_vert_lin := line.new(bar_index, y1 = low, x2 = bar_index, y2 = bull_tgt_2, color = vert_bull_color, width = vert_line_width, style = line.style_dotted)
        if not disableTargetLabels
            bull_tgt_1_lbl := label.new(bar_index[1], y = bull_tgt, text = tgt1_lbl_text + '\n' + str.tostring(math.round(bull_tgt, 2)), color = bull_lbl_color, textcolor = tgt_lbl_text_color, style = label.style_label_right)
            bull_tgt_2_lbl := label.new(bar_index[1], y = bull_tgt_2, text = tgt2_lbl_text + '\n' + str.tostring(math.round(bull_tgt_2, 2)), color = bull_lbl_color, textcolor = tgt_lbl_text_color, style = label.style_label_right)
            bull_tgt_2_lbl

if crossunder and barstate.isconfirmed
    line.delete(bear_tgt_lin)
    line.delete(bear_tgt_lin_2)
    line.delete(bear_vert_lin)
    label.delete(bear_tgt_1_lbl)
    label.delete(bear_tgt_2_lbl)
    if not enableBearLines and not na(bear_tgt_2)
        bear_tgt_lin := line.new(bar_index[1], y1 = bear_tgt, x2 = bar_index, y2 = bear_tgt, extend = extend.right, color = bear, width = 3)
        bear_tgt_lin_2 := line.new(bar_index[1], y1 = bear_tgt_2, x2 = bar_index, y2 = bear_tgt_2, extend = extend.right, color = bear, width = 3)
        bear_vert_lin := line.new(bar_index, y1 = high, x2 = bar_index, y2 = bear_tgt_2, color = vert_bear_color, width = vert_line_width, style = line.style_dotted)
        if not disableTargetLabels
            bear_tgt_1_lbl := label.new(bar_index[1], y = bear_tgt, text = tgt1_lbl_text + '\n' + str.tostring(math.round(bear_tgt, 2)), color = bear_lbl_color, textcolor = tgt_lbl_text_color, style = label.style_label_right)
            bear_tgt_2_lbl := label.new(bar_index[1], y = bear_tgt_2, text = tgt2_lbl_text + '\n' + str.tostring(math.round(bear_tgt_2, 2)), color = bear_lbl_color, textcolor = tgt_lbl_text_color, style = label.style_label_right)
            bear_tgt_2_lbl

// Toggling a Disable input on removes any lines/labels already on the chart
if enableBullLines
    line.delete(bull_tgt_lin)
    line.delete(bull_tgt_lin_2)
    line.delete(bull_vert_lin)
    label.delete(bull_tgt_1_lbl)
    label.delete(bull_tgt_2_lbl)
if enableBearLines
    line.delete(bear_tgt_lin)
    line.delete(bear_tgt_lin_2)
    line.delete(bear_vert_lin)
    label.delete(bear_tgt_1_lbl)
    label.delete(bear_tgt_2_lbl)
if disableTargetLabels
    label.delete(bull_tgt_1_lbl)
    label.delete(bull_tgt_2_lbl)
    label.delete(bear_tgt_1_lbl)
    label.delete(bear_tgt_2_lbl)


///*///*///*///*///*///*///*///*///*///
///          EMAs Logic             /// 
///*///*///*///*///*///*///*///*///*///

//offset2 = input.int(title="EMA Label Offset", defval=0, minval=-500, maxval=500, display = display.data_window)


get_timeframe_title(simple string tf = '') =>
    chartTf = timeframe.isminutes == true and timeframe.multiplier > 59 ? timeframe.multiplier / 60 % 2 == 0 ? str.tostring(timeframe.multiplier / 60) + 'h' : str.tostring(timeframe.multiplier) + 'm' : timeframe.isminutes == true ? str.tostring(timeframe.multiplier) + 'm' : timeframe.period
    result = tf == '' ? '' : request.security(syminfo.tickerid, tf, chartTf)
    result

distance = input(2, 'Label Distance', group = 'Multiple EMAs -- Global Configuration', tooltip = 'Distance of the label from the end of the EMA line. Lowest value is zero.')
show_prices = not enableAllEMAs and input.bool(true, 'Show price labels', group = 'Multiple EMAs -- Global Configuration', tooltip = 'Toogle this on and off to see prices at the end of the EMA label')
EMAlineWidth = input(2, 'Line Width of EMAs', group = 'Multiple EMAs -- Global Configuration', tooltip = 'Width of all displayed EMAs.')


ema1_enable = not enableAllEMAs and input.bool(true, 'Enable EMA 1', group = 'Multiple EMAs -- EMA 1 Configuration')
ema1_timeframe = input.timeframe('', 'EMA 1 Timeframe', group = 'Multiple EMAs -- EMA 1 Configuration')
ema1_len = input.int(9, minval = 1, title = 'EMA 1 Length', group = 'Multiple EMAs -- EMA 1 Configuration')
ema1_out = ta.ema(close, ema1_len)
ema1_color_input = input(color.new(#A5D6A7, 20), title = 'EMA 1 Color', group = 'Multiple EMAs -- EMA 1 Configuration')
ema1_color = ema1_enable ? ema1_color_input : na

ema2_enable = not enableAllEMAs and input.bool(true, 'Enable EMA 2', group = 'Multiple EMAs -- EMA 2 Configuration')
ema2_timeframe = input.timeframe('', 'EMA 2 Timeframe', group = 'Multiple EMAs -- EMA 2 Configuration')
ema2_len = input.int(21, minval = 1, title = 'EMA 2 Length', group = 'Multiple EMAs -- EMA 2 Configuration')
ema2_out = ta.ema(close, ema2_len)
ema2_color_input = input(color.new(#F2AF29, 20), title = 'EMA 2 Color', group = 'Multiple EMAs -- EMA 2 Configuration')
ema2_color = ema2_enable ? ema2_color_input : na

ema3_enable = not enableAllEMAs and input.bool(true, 'Enable EMA 3', group = 'Multiple EMAs -- EMA 3 Configuration')
ema3_timeframe = input.timeframe('', 'EMA 3 Timeframe', group = 'Multiple EMAs -- EMA 3 Configuration')
ema3_len = input.int(34, minval = 1, title = 'EMA 3 Length', group = 'Multiple EMAs -- EMA 3 Configuration')
ema3_out = ta.ema(close, ema3_len)
ema3_color_input = input(color.new(#725AC1, 20), title = 'EMA 3 Color', group = 'Multiple EMAs -- EMA 3 Configuration')
ema3_color = ema3_enable ? ema3_color_input : na

ema4_enable = not enableAllEMAs and input.bool(true, 'Enable EMA 4', group = 'Multiple EMAs -- EMA 4 Configuration')
ema4_timeframe = input.timeframe('', 'EMA 4 Timeframe', group = 'Multiple EMAs -- EMA 4 Configuration')
ema4_len = input.int(55, minval = 1, title = 'EMA 4 Length', group = 'Multiple EMAs -- EMA 4 Configuration')
ema4_out = ta.ema(close, ema4_len)
ema4_color_input = input(color.new(#FE5E41, 20), title = 'EMA 4 Color', group = 'Multiple EMAs -- EMA 4 Configuration')
ema4_color = ema4_enable ? ema4_color_input : na

ema5_enable = not enableAllEMAs and input.bool(false, 'Enable EMA 5', group = 'Multiple EMAs -- EMA 5 Configuration')
ema5_timeframe = input.timeframe('', 'EMA 5 Timeframe', group = 'Multiple EMAs -- EMA 5 Configuration')
ema5_len = input.int(400, minval = 1, title = 'EMA 5 Length', group = 'Multiple EMAs -- EMA 5 Configuration')
ema5_out = ta.ema(close, ema5_len)
ema5_color_input = input(color.new(#243E36, 20), title = 'EMA 5 Color', group = 'Multiple EMAs -- EMA 5 Configuration')
ema5_color = ema5_enable ? ema5_color_input : na

ema6_enable = not enableAllEMAs and input.bool(false, 'Enable EMA 6', group = 'Multiple EMAs -- EMA 6 Configuration')
ema6_timeframe = input.timeframe('', 'EMA 6 Timeframe', group = 'Multiple EMAs -- EMA 6 Configuration')
ema6_len = input.int(9, minval = 1, title = 'EMA 6 Length', group = 'Multiple EMAs -- EMA 6 Configuration')
ema6_out = ta.ema(close, ema6_len)
ema6_color_input = input(color.new(#3B3923, 20), title = 'EMA 6 Color', group = 'Multiple EMAs -- EMA 6 Configuration')
ema6_color = ema6_enable ? ema6_color_input : na

ema7_enable = not enableAllEMAs and input.bool(false, 'Enable EMA 7', group = 'Multiple EMAs -- EMA 7 Configuration')
ema7_timeframe = input.timeframe('', 'EMA 7 Timeframe', group = 'Multiple EMAs -- EMA 7 Configuration')
ema7_len = input.int(26, minval = 1, title = 'EMA 7 Length', group = 'Multiple EMAs -- EMA 7 Configuration')
ema7_out = ta.ema(close, ema7_len)
ema7_color_input = input(color.new(#3A7CA5, 20), title = 'EMA 7 Color', group = 'Multiple EMAs -- EMA 7 Configuration')
ema7_color = ema7_enable ? ema7_color_input : na

ema8_enable = not enableAllEMAs and input.bool(false, 'Enable EMA 8', group = 'Multiple EMAs -- EMA 8 Configuration')
ema8_timeframe = input.timeframe('', 'EMA 8 Timeframe', group = 'Multiple EMAs -- EMA 8 Configuration')
ema8_len = input.int(12, minval = 1, title = 'EMA 8 Length', group = 'Multiple EMAs -- EMA 8 Configuration')
ema8_out = ta.ema(close, ema8_len)
ema8_color_input = input(color.new(#795663, 20), title = 'EMA 8 Color', group = 'Multiple EMAs -- EMA 8 Configuration')
ema8_color = ema8_enable ? ema8_color_input : na





securityNoRepaint(sym, tf, src) =>
    request.security(sym, tf, src[barstate.isrealtime ? 1 : 0])[barstate.isrealtime ? 0 : 1]
    //offset2 = input.int(title="EMA Label Offset", defval=0, minval=-500, maxval=500, display = display.data_window)

// ****************************************************************
// The following were commented out due to creating an erroneous calculation of the EMA line plot
// No idea as to why the delta between actual and this implementation, though can only assume it is due to the security NoRepaint function
//
//ema1_tf = securityNoRepaint(syminfo.tickerid, ema1_timeframe, ema1_out)
//ema2_tf = securityNoRepaint(syminfo.tickerid, ema2_timeframe, ema2_out)
//ema3_tf = securityNoRepaint(syminfo.tickerid, ema3_timeframe, ema3_out)
//ema4_tf = securityNoRepaint(syminfo.tickerid, ema4_timeframe, ema4_out)
//ema5_tf = securityNoRepaint(syminfo.tickerid, ema5_timeframe, ema5_out)
//ema6_tf = securityNoRepaint(syminfo.tickerid, ema6_timeframe, ema6_out)
//ema7_tf = securityNoRepaint(syminfo.tickerid, ema7_timeframe, ema7_out)
//ema8_tf = securityNoRepaint(syminfo.tickerid, ema8_timeframe, ema8_out)
//plot(ema1_tf, title="EMA", color=ema1_color, linewidth=EMAlineWidth, style=plot.style_line, offset=offset2)
//plot(ema2_tf, title="EMA", color=ema2_color, linewidth=EMAlineWidth, style=plot.style_line, offset=0)
//plot(ema3_tf, title="EMA", color=ema3_color, linewidth=EMAlineWidth, style=plot.style_line, offset=0)
//plot(ema4_tf, title="EMA", color=ema4_color, linewidth=EMAlineWidth, style=plot.style_line, offset=0)
//plot(ema5_tf, title="EMA", color=ema5_color, linewidth=EMAlineWidth, style=plot.style_line, offset=0)
//plot(ema6_tf, title="EMA", color=ema6_color, linewidth=EMAlineWidth, style=plot.style_line, offset=0)
//plot(ema7_tf, title="EMA", color=ema7_color, linewidth=EMAlineWidth, style=plot.style_line, offset=0)
//plot(ema8_tf, title="EMA", color=ema8_color, linewidth=EMAlineWidth, style=plot.style_line, offset=0)
// ****************************************************************


plot(ema1_out, title = 'EMA', color = ema1_color, linewidth = math.max(1, EMAlineWidth), style = plot.style_line)
plot(ema2_out, title = 'EMA', color = ema2_color, linewidth = math.max(1, EMAlineWidth), style = plot.style_line)
plot(ema3_out, title = 'EMA', color = ema3_color, linewidth = math.max(1, EMAlineWidth), style = plot.style_line)
plot(ema4_out, title = 'EMA', color = ema4_color, linewidth = math.max(1, EMAlineWidth), style = plot.style_line)
plot(ema5_out, title = 'EMA', color = ema5_color, linewidth = math.max(1, EMAlineWidth), style = plot.style_line)
plot(ema6_out, title = 'EMA', color = ema6_color, linewidth = math.max(1, EMAlineWidth), style = plot.style_line)
plot(ema7_out, title = 'EMA', color = ema7_color, linewidth = math.max(1, EMAlineWidth), style = plot.style_line)
plot(ema8_out, title = 'EMA', color = ema8_color, linewidth = math.max(1, EMAlineWidth), style = plot.style_line)



var label ema1_label = na
ema1_label_size = size.normal
var label ema2_label = na
ema2_label_size = size.normal
var label ema3_label = na
ema3_label_size = size.normal
var label ema4_label = na
ema4_label_size = size.normal
var label ema5_label = na
ema5_label_size = size.normal
var label ema6_label = na
ema6_label_size = size.normal
var label ema7_label = na
ema7_label_size = size.normal
var label ema8_label = na
ema8_label_size = size.normal

timeframe_text = get_timeframe_title(ema1_timeframe)
timeframe2_text = get_timeframe_title(ema2_timeframe)
timeframe3_text = get_timeframe_title(ema3_timeframe)
timeframe4_text = get_timeframe_title(ema4_timeframe)
timeframe5_text = get_timeframe_title(ema5_timeframe)
timeframe6_text = get_timeframe_title(ema6_timeframe)
timeframe7_text = get_timeframe_title(ema7_timeframe)
timeframe8_text = get_timeframe_title(ema8_timeframe)

label_x = time + math.round(ta.change(time) * distance)

ema1_p_str = show_prices ? ' - ' + str.tostring(math.round_to_mintick(ema1_out)) : ''
ema2_p_str = show_prices ? ' - ' + str.tostring(math.round_to_mintick(ema2_out)) : ''
ema3_p_str = show_prices ? ' - ' + str.tostring(math.round_to_mintick(ema3_out)) : ''
ema4_p_str = show_prices ? ' - ' + str.tostring(math.round_to_mintick(ema4_out)) : ''
ema5_p_str = show_prices ? ' - ' + str.tostring(math.round_to_mintick(ema5_out)) : ''
ema6_p_str = show_prices ? ' - ' + str.tostring(math.round_to_mintick(ema6_out)) : ''
ema7_p_str = show_prices ? ' - ' + str.tostring(math.round_to_mintick(ema7_out)) : ''
ema8_p_str = show_prices ? ' - ' + str.tostring(math.round_to_mintick(ema8_out)) : ''

labelpadding = '                                         '

ema1_label_txt = timeframe_text == '' ? labelpadding + 'EMA ' + str.tostring(ema1_len) + ema1_p_str : labelpadding + 'EMA ' + str.tostring(ema1_len) + ' (' + timeframe_text + ')' + ema1_p_str
ema1_label := label.new(label_x, ema1_out, text = ema1_label_txt, xloc = xloc.bar_time, color = ema1_color, textcolor = ema1_color, style = label.style_none, size = size.normal)
label.delete(ema1_label[1])

ema2_label_txt = timeframe2_text == '' ? labelpadding + 'EMA ' + str.tostring(ema2_len) + ema2_p_str : labelpadding + 'EMA ' + str.tostring(ema2_len) + ' (' + timeframe2_text + ')' + ema2_p_str
ema2_label := label.new(label_x, ema2_out, text = ema2_label_txt, xloc = xloc.bar_time, color = ema2_color, textcolor = ema2_color, style = label.style_none, size = size.normal)
label.delete(ema2_label[1])

ema3_label_txt = timeframe3_text == '' ? labelpadding + 'EMA ' + str.tostring(ema3_len) + ema3_p_str : labelpadding + 'EMA ' + str.tostring(ema3_len) + ' (' + timeframe3_text + ')' + ema3_p_str
ema3_label := label.new(label_x, ema3_out, text = ema3_label_txt, xloc = xloc.bar_time, color = ema3_color, textcolor = ema3_color, style = label.style_none, size = size.normal)
label.delete(ema3_label[1])

ema4_label_txt = timeframe4_text == '' ? labelpadding + 'EMA ' + str.tostring(ema4_len) + ema4_p_str : labelpadding + 'EMA ' + str.tostring(ema4_len) + ' (' + timeframe4_text + ')' + ema4_p_str
ema4_label := label.new(label_x, ema4_out, text = ema4_label_txt, xloc = xloc.bar_time, color = ema4_color, textcolor = ema4_color, style = label.style_none, size = size.normal)
label.delete(ema4_label[1])

ema5_label_txt = timeframe5_text == '' ? labelpadding + 'EMA ' + str.tostring(ema5_len) + ema5_p_str : labelpadding + 'EMA ' + str.tostring(ema5_len) + ' (' + timeframe5_text + ')' + ema5_p_str
ema5_label := label.new(label_x, ema5_out, text = ema5_label_txt, xloc = xloc.bar_time, color = ema5_color, textcolor = ema5_color, style = label.style_none, size = size.normal)
label.delete(ema5_label[1])

ema6_label_txt = timeframe6_text == '' ? labelpadding + 'EMA ' + str.tostring(ema6_len) + ema6_p_str : labelpadding + 'EMA ' + str.tostring(ema6_len) + ' (' + timeframe6_text + ')' + ema6_p_str
ema6_label := label.new(label_x, ema6_out, text = ema6_label_txt, xloc = xloc.bar_time, color = ema6_color, textcolor = ema6_color, style = label.style_none, size = size.normal)
label.delete(ema6_label[1])

ema7_label_txt = timeframe7_text == '' ? labelpadding + 'EMA ' + str.tostring(ema7_len) + ema7_p_str : labelpadding + 'EMA ' + str.tostring(ema7_len) + ' (' + timeframe7_text + ')' + ema7_p_str
ema7_label := label.new(label_x, ema7_out, text = ema7_label_txt, xloc = xloc.bar_time, color = ema7_color, textcolor = ema7_color, style = label.style_none, size = size.normal)
label.delete(ema7_label[1])

ema8_label_txt = timeframe8_text == '' ? labelpadding + 'EMA ' + str.tostring(ema8_len) + ema8_p_str : labelpadding + 'EMA ' + str.tostring(ema8_len) + ' (' + timeframe8_text + ')' + ema8_p_str
ema8_label := label.new(label_x, ema8_out, text = ema8_label_txt, xloc = xloc.bar_time, color = ema8_color, textcolor = ema8_color, style = label.style_none, size = size.normal)
label.delete(ema8_label[1])


// Alert conditions
alertcondition(crossover, 'EMA Bullish Cross', 'Bullish Cross')
alertcondition(crossunder, 'EMA Bearish Cross', 'Bearish Cross')
````
