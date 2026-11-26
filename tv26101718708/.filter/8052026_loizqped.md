# 8.05.2026

- url: https://www.tradingview.com/script/LOIZQPEd/
- type: indicator
- pine_id: PUB;e2fc66fbf25e42ac9133c07e07f9e910
- version: 1.0

## Description

First of all, 
huge thanks and respect to all the traders, coders, Pine Script developers, Smart Money Concepts researchers, and TradingView community members whose ideas, concepts, and open discussions inspired this indicator.

This project is not about inventing something entirely new — it is a compilation, refinement, and integration of many powerful trading concepts developed and shared by others over the years.
I simply combined these ideas into one workflow and adapted them into a unified visual trading environment.
Special appreciation goes to everyone who contributed concepts related to Fair Value Gaps (FVG), Supply & Demand, BOS structures, MACD divergences, multi-timeframe moving averages, session ranges, opening ranges, and trend visualization systems.
Without the collective creativity of the trading community, this indicator would not exist.

AS Multi-Concept Trading Framework
This indicator is a comprehensive multi-layer market structure and trend analysis framework built for TradingView using Pine Script v6.
It combines trend-following tools, Smart Money Concepts (SMC), liquidity analysis, momentum confirmation, session mapping, and market structure visualization into a single integrated system.
The goal of the indicator is not to predict the market, but to visually organize important information in a clean and actionable way.

Main Features
1. Multi-Layer Trend Engine
The script combines several moving average systems:
SMA 9 (stepline visualization)
SMA 20
SMA 200
EMA 200
Additional configurable multi-timeframe MAs
The indicator dynamically colors:
candles,
moving average zones,
trend regions,
EMA/SMA relationships,
allowing traders to instantly recognize trend direction and momentum conditions.

2. Fair Value Gap (FVG) Detection
Integrated Smart Money Concepts Fair Value Gap engine:
Features:
Bullish and bearish FVG detection
Dynamic or static FVG zones
Mitigation tracking
Unmitigated level display
Multi-timeframe FVG analysis
Statistical dashboard
Extendable imbalance zones
The system visually tracks liquidity inefficiencies and highlights areas where price may revisit in the future.

3. Supply & Demand Zones
Advanced Supply & Demand engine with:
Swing high / swing low detection
Automatic zone creation
BOS (Break of Structure) conversion
POI (Point of Interest) labeling
ATR-based zone sizing
Overlap filtering
Dynamic zone extension
This module helps identify institutional accumulation and distribution areas.

4. Market Structure Visualization
The indicator includes market structure tools such as:
HH / HL / LH / LL labeling
ZigZag structure mapping
BOS visualization
Swing analysis
This helps traders understand whether the market is trending, ranging, accumulating, or distributing.

5. MACD-AS Momentum & Divergences
Custom MACD-AS implementation including:
Momentum histogram
Smoothed signal line
Bullish divergences
Bearish divergences
Pivot-based divergence detection
The divergence engine helps identify potential reversals and momentum exhaustion.

6. Multi-Timeframe Moving Average System
The script supports configurable moving averages across different timeframes:
SMA
EMA
RMA / SMMA
WMA
VWMA
Each MA can independently use its own timeframe and smoothing type, allowing advanced higher-timeframe market alignment.

7. Session & Opening Range Visualization
Integrated global market session tracking:
Asia
Japan
Europe (London)
US
New York
Custom Poland session (end of the day)
Each session can generate:
Opening Range boxes
Dynamic session highs/lows
Liquidity range visualization
This helps traders identify volatility transitions and session-based liquidity behavior.

8. 15-Minute Liquidity Ranges
The indicator continuously calculates:
Live liquidity ranges
Non-repainting range highs/lows
Higher timeframe support/resistance zones
Useful for intraday liquidity targeting and range expansion analysis.

9. Alert System
Built-in alerts include:
Bullish FVG
Bearish FVG
SMA9 bullish crossover
SMA9 bearish crossover
The alert engine is designed to provide lightweight but meaningful market notifications.

Design Philosophy:
This indicator is designed as a visual decision-support framework rather than a mechanical signal generator.

The focus is on:
context,
liquidity,
structure,
momentum,
higher timeframe alignment,
institutional behavior visualization.
It is intended for discretionary traders who combine multiple concepts into a unified market reading process.

Important Notes:
Some modules may repaint depending on selected settings and timeframe requests.
Multi-timeframe calculations can behave differently in real-time and historical bars.
The indicator is highly visual and intended to be customized according to individual trading styles.
This tool should not be considered financial advice.

Final Thanks
Once again, sincere thanks to the TradingView community, open-source Pine Script authors, SMC educators, quantitative traders, and all developers whose work inspired parts of this framework.
This script is a tribute to collaborative learning in trading and technical analysis.

## Source Code

````pine
//@version=6
indicator('8.05.2026', overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 1000)

// SMA / EMA
sma9        = ta.sma(close, 9)
sma20       = ta.sma(close, 20)
sma20_high  = ta.sma(high, 20)

sma200      = ta.sma(close, 200)
ema200      = ta.ema(close, 200)

// SMA 9 jako schodkowa
p_sma9 = plot(sma9,
     title = 'SMA 9',
     color = color.rgb(255, 153, 0, 61),
     linewidth = 1,
     style = plot.style_stepline, offset=1)

// Ukryte ploty dla fill
p_sma20      = plot(sma20, display = display.none)
p_sma20_high = plot(sma20_high, display = display.none)

p_sma200     = plot(sma200, display = display.none)
p_ema200     = plot(ema200, display = display.none)

// TREND
uptrend   = sma9 > sma9[1]
downtrend = sma9 < sma9[1]

// Kolory
bullColor = color.rgb(0, 255, 0, 84)
bearColor = color.rgb(255, 0, 0, 88)

// Gradient między SMA 20 i SMA 20 High
fill(p_sma20, p_sma20_high,
     color = uptrend ? color.new(bullColor, 80) :
             downtrend ? color.new(bearColor, 90) :
             na)

fill(p_sma20, p_sma20_high,
     color = uptrend ? color.new(bullColor, 90) :
             downtrend ? color.new(bearColor, 90) :
             na)

// Wypełnienie EMA 200 ↔ SMA 200
fill(p_ema200, p_sma200,
     color = close > ema200 ? color.new(color.blue, 85) :
             close < ema200 ? color.new(color.purple, 85) :
             na)

fill(p_ema200, p_sma200,
     color = close > ema200 ? color.new(color.blue, 85) :
             close < ema200 ? color.new(color.purple, 85) :
             na)

// Kolor świec
barcolor(
     uptrend   ? color.rgb(12, 91, 0) :
     downtrend ? color.rgb(122, 0, 0) :
     color.gray
)

//FVG
//-----------------------------------------------------------------------------{
thresholdPer = input.float(0, 'Threshold %', minval = 0, maxval = 100, step = .1, inline = 'threshold')
auto = input(false, 'Auto', inline = 'threshold')

showLast = input.int(0, 'Unmitigated Levels', minval = 0)
mitigationLevels = input.bool(false, 'Mitigation Levels')

tf = input.timeframe('', 'Timeframe')

//Style
extend = input.int(20, 'Extend', minval = 0, inline = 'extend', group = 'Style')
dynamic = input(false, 'Dynamic', inline = 'extend', group = 'Style')

bullCss = input.color(color.new(#089981, 70), 'Bullish FVG', group = 'Style')
bearCss = input.color(color.new(#f23645, 70), 'Bearish FVG', group = 'Style')

//Dashboard
showDash = input(false, 'Show Dashboard', group = 'Dashboard')
dashLoc = input.string('Top Right', 'Location', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = 'Dashboard')
textSize = input.string('Small', 'Size', options = ['Tiny', 'Small', 'Normal'], group = 'Dashboard')

//-----------------------------------------------------------------------------}
//UDT's
//-----------------------------------------------------------------------------{
type fvg
	float max
	float min
	bool isbull
	int t = time

//-----------------------------------------------------------------------------}
//Methods/Functions
//-----------------------------------------------------------------------------{
n = bar_index

method tosolid(color id) =>
    color.rgb(color.r(id), color.g(id), color.b(id))

detect() =>
    var new_fvg = fvg.new(na, na, bool(na), na)
    threshold = auto ? ta.cum((high - low) / low) / bar_index : thresholdPer / 100

    bull_fvg = low > high[2] and close[1] > high[2] and (low - high[2]) / high[2] > threshold
    bear_fvg = high < low[2] and close[1] < low[2] and (low[2] - high) / high > threshold

    if bull_fvg
        new_fvg := fvg.new(low, high[2], true)
        new_fvg
    else if bear_fvg
        new_fvg := fvg.new(low[2], high, false)
        new_fvg

    [bull_fvg, bear_fvg, new_fvg]

//-----------------------------------------------------------------------------}
//FVG's detection/display
//-----------------------------------------------------------------------------{
var float max_bull_fvg = na
var float min_bull_fvg = na
var bull_count = 0
var bull_mitigated = 0
var float max_bear_fvg = na
var float min_bear_fvg = na
var bear_count = 0
var bear_mitigated = 0
var t = 0

var fvg_records = array.new<fvg>(0)
var fvg_areas = array.new<box>(0)

[bull_fvg, bear_fvg, new_fvg] = request.security(syminfo.tickerid, tf, detect())

//Bull FVG's
if bull_fvg and new_fvg.t != t
    if dynamic
        max_bull_fvg := new_fvg.max
        min_bull_fvg := new_fvg.min
        min_bull_fvg

    //Populate FVG array
    if not dynamic
        fvg_areas.unshift(box.new(n - 2, new_fvg.max, n + extend, new_fvg.min, na, bgcolor = bullCss))
    fvg_records.unshift(new_fvg)

    bull_count := bull_count + 1
    t := new_fvg.t
    t
else if dynamic
    max_bull_fvg := math.max(math.min(close, max_bull_fvg), min_bull_fvg)
    max_bull_fvg

//Bear FVG's
if bear_fvg and new_fvg.t != t
    if dynamic
        max_bear_fvg := new_fvg.max
        min_bear_fvg := new_fvg.min
        min_bear_fvg

    //Populate FVG array
    if not dynamic
        fvg_areas.unshift(box.new(n - 2, new_fvg.max, n + extend, new_fvg.min, na, bgcolor = bearCss))
    fvg_records.unshift(new_fvg)

    bear_count := bear_count + 1
    t := new_fvg.t
    t
else if dynamic
    min_bear_fvg := math.min(math.max(close, min_bear_fvg), max_bear_fvg)
    min_bear_fvg

//-----------------------------------------------------------------------------}
//Unmitigated/Mitigated lines
//-----------------------------------------------------------------------------{
//Test for mitigation
if fvg_records.size() > 0
    for i = fvg_records.size() - 1 to 0 by 1
        get = fvg_records.get(i)

        if get.isbull
            if close < get.min
                //Display line if mitigated
                if mitigationLevels
                    line.new(get.t, get.min, time, get.min, xloc.bar_time, color = bullCss, style = line.style_dashed)

                //Delete box
                if not dynamic
                    area = fvg_areas.remove(i)
                    area.delete()

                fvg_records.remove(i)
                bull_mitigated := bull_mitigated + 1
                bull_mitigated
        else if close > get.max
            //Display line if mitigated
            if mitigationLevels
                line.new(get.t, get.max, time, get.max, xloc.bar_time, color = bearCss, style = line.style_dashed)

            //Delete box
            if not dynamic
                area = fvg_areas.remove(i)
                area.delete()

            fvg_records.remove(i)
            bear_mitigated := bear_mitigated + 1
            bear_mitigated

//Unmitigated lines
var unmitigated = array.new<line>(0)

//Remove umitigated lines 
if barstate.islast and showLast > 0 and fvg_records.size() > 0
    if unmitigated.size() > 0
        for element in unmitigated
            element.delete()
        unmitigated.clear()

    for i = 0 to math.min(showLast - 1, fvg_records.size() - 1) by 1
        get = fvg_records.get(i)

        unmitigated.push(line.new(get.t, get.isbull ? get.min : get.max, time, get.isbull ? get.min : get.max, xloc.bar_time, color = get.isbull ? bullCss : bearCss))

//-----------------------------------------------------------------------------}
//Dashboard
//-----------------------------------------------------------------------------{
var table_position = dashLoc == 'Bottom Left' ? position.bottom_left : dashLoc == 'Top Right' ? position.top_right : position.bottom_right

var table_size = textSize == 'Tiny' ? size.tiny : textSize == 'Small' ? size.small : size.normal

var tb = table.new(table_position, 3, 3, bgcolor = #1e222d, border_color = #373a46, border_width = 1, frame_color = #373a46, frame_width = 1)

if showDash
    if barstate.isfirst
        tb.cell(1, 0, 'Bullish', text_color = bullCss.tosolid(), text_size = table_size)
        tb.cell(2, 0, 'Bearish', text_color = bearCss.tosolid(), text_size = table_size)

        tb.cell(0, 1, 'Count', text_size = table_size, text_color = color.white)
        tb.cell(0, 2, 'Mitigated', text_size = table_size, text_color = color.white)

    if barstate.islast
        tb.cell(1, 1, str.tostring(bull_count), text_color = bullCss.tosolid(), text_size = table_size)
        tb.cell(2, 1, str.tostring(bear_count), text_color = bearCss.tosolid(), text_size = table_size)

        tb.cell(1, 2, str.tostring(bull_mitigated / bull_count * 100, format.percent), text_color = bullCss.tosolid(), text_size = table_size)
        tb.cell(2, 2, str.tostring(bear_mitigated / bear_count * 100, format.percent), text_color = bearCss.tosolid(), text_size = table_size)

//-----------------------------------------------------------------------------}
//Plots
//-----------------------------------------------------------------------------{
//Dynamic Bull FVG
max_bull_plot = plot(max_bull_fvg, color = na)
min_bull_plot = plot(min_bull_fvg, color = na)
fill(max_bull_plot, min_bull_plot, color = bullCss)

//Dynamic Bear FVG
max_bear_plot = plot(max_bear_fvg, color = na)
min_bear_plot = plot(min_bear_fvg, color = na)
fill(max_bear_plot, min_bear_plot, color = bearCss)

len = input.int(200, minval=1, title="Length")
src = input(close, title="Source")
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display = display.none)
out = ta.ema(src, len)
plot(out, title="EMA", color=color.rgb(0, 60, 110), offset=offset)

// CM EMA TREND BARS INPUTS
emaLength = input.int(34, minval=1, maxval=300, title="EMA UpTrend")
showEma   = input.bool(true, title="Show EMA")

// EMA
usedEma = ta.ema(close, emaLength)

// CONDITIONS
emaUp   = hlc3 >= usedEma
emaDown = hlc3 < usedEma

// TREND CHANGE (sygnały)
longSignal  = emaUp and emaDown[1]
shortSignal = emaDown and emaUp[1]

// COLORS
col = emaUp ? color.lime : emaDown ? color.red : color.white

// BAR COLORING
barcolor(emaUp ? color.lime : emaDown ? color.rgb(152, 0, 0) : na)

// PLOT EMA
plot(showEma ? usedEma : na, title="EMA", linewidth=1, color=col)

// -------------------------------
// INPUTS
// -------------------------------
length = input.int(9, 'Length')
source = input.source(close, 'Source')

// MA Types
typeMA0 = input.string('SMA', 'MA1 Type', options=['SMA','EMA','SMMA (RMA)','WMA','VWMA'])
typeMA1 = input.string('SMA', 'MA2 Type', options=['SMA','EMA','SMMA (RMA)','WMA','VWMA'])
typeMA2 = input.string('SMA', 'MA3 Type', options=['SMA','EMA','SMMA (RMA)','WMA','VWMA'])
typeMA3 = input.string('SMA', 'MA4 Type', options=['SMA','EMA','SMMA (RMA)','WMA','VWMA'])

// Timeframes
ma_tf0 = input.timeframe('30', 'MA1 Timeframe')
ma_tf1 = input.timeframe('60', 'MA2 Timeframe')
ma_tf2 = input.timeframe('240', 'MA3 Timeframe')
ma_tf3 = input.timeframe('D', 'MA4 Timeframe')

// Colors
color0 = input.color(color.rgb(221, 221, 27, 65), 'MA1 Color')
color1 = input.color(#1b8fdd82, 'MA2 Color')
color2 = input.color(color.rgb(111, 27, 221, 33), 'MA3 Color')
color3 = input.color(color.rgb(255, 255, 255, 21), 'MA4 Color')

// -------------------------------
// FUNCTIONS
// -------------------------------
calc_ma(src, len, type) =>
    switch type
        'SMA' => ta.sma(src, len)
        'EMA' => ta.ema(src, len)
        'SMMA (RMA)' => ta.rma(src, len)
        'WMA' => ta.wma(src, len)
        'VWMA' => ta.vwma(src, len)

// Bez repaint (lookahead_off!)
getMTF(tf, expr) =>
    request.security(syminfo.tickerid, tf, expr, lookahead=barmerge.lookahead_off)

// -------------------------------
// MA CALCULATION
// -------------------------------
ma1 = getMTF(ma_tf0, calc_ma(source, length, typeMA0))
ma2 = getMTF(ma_tf1, calc_ma(source, length, typeMA1))
ma3 = getMTF(ma_tf2, calc_ma(source, length, typeMA2))
ma4 = getMTF(ma_tf3, calc_ma(source, length, typeMA3))

// -------------------------------
// PLOT
// -------------------------------
plot(ma1, 'MA1', color=color0, linewidth=2)
plot(ma2, 'MA2', color=color1, linewidth=3)
plot(ma3, 'MA3', color=color2, linewidth=4)
plot(ma4, 'MA4', color=color3, linewidth=5)

//      INDICATOR SETTINGS
swing_length = input.int(10, title = 'Swing High/Low Length', group = 'Settings', minval = 1, maxval = 50)
history_of_demand_to_keep = input.int(20, title = 'History To Keep', minval = 5, maxval = 50)
box_width = input.float(2.5, title = 'Supply/Demand Box Width', group = 'Settings', minval = 1, maxval = 10, step = 0.5)

//      INDICATOR VISUAL SETTINGS
show_zigzag = input.bool(false, title = 'Show Zig Zag', group = 'Visual Settings', inline = '1')
show_price_action_labels = input.bool(false, title = 'Show Price Action Labels', group = 'Visual Settings', inline = '2')

supply_color = input.color(color.new(#ededed, 91), title = 'Supply', group = 'Visual Settings', inline = '3')
supply_outline_color = input.color(color.new(#ffffff, 95), title = 'Outline', group = 'Visual Settings', inline = '3')

demand_color = input.color(color.new(#00ffff, 91), title = 'Demand', group = 'Visual Settings', inline = '4')
demand_outline_color = input.color(color.new(#ffffff, 94), title = 'Outline', group = 'Visual Settings', inline = '4')

bos_label_color = input.color(color.rgb(255, 255, 255, 55), title = 'BOS Label', group = 'Visual Settings', inline = '5')
poi_label_color = input.color(color.rgb(255, 255, 255, 47), title = 'POI Label', group = 'Visual Settings', inline = '7')

swing_type_color = input.color(color.black, title = 'Price Action Label', group = 'Visual Settings', inline = '8')
zigzag_color = input.color(color.new(#000000, 0), title = 'Zig Zag', group = 'Visual Settings', inline = '9')

//      FUNCTION TO ADD NEW AND REMOVE LAST IN ARRAY
f_array_add_pop(array, new_value_to_add) =>
    array.unshift(array, new_value_to_add)
    array.pop(array)

//      FUNCTION SWING H & L LABELS
f_sh_sl_labels(array, swing_type) =>

    var string label_text = na
    if swing_type == 1
        if array.get(array, 0) >= array.get(array, 1)
            label_text := 'HH'
            label_text
        else
            label_text := 'LH'
            label_text
        label.new(bar_index - swing_length, array.get(array, 0), text = label_text, style = label.style_label_down, textcolor = swing_type_color, color = color.new(swing_type_color, 100), size = size.tiny)

    else if swing_type == -1
        if array.get(array, 0) >= array.get(array, 1)
            label_text := 'HL'
            label_text
        else
            label_text := 'LL'
            label_text
        label.new(bar_index - swing_length, array.get(array, 0), text = label_text, style = label.style_label_up, textcolor = swing_type_color, color = color.new(swing_type_color, 100), size = size.tiny)

//      FUNCTION MAKE SURE SUPPLY ISNT OVERLAPPING
f_check_overlapping(new_poi, box_array, atr) =>

    atr_threshold = atr * 2
    okay_to_draw = true

    for i = 0 to array.size(box_array) - 1 by 1
        top = box.get_top(array.get(box_array, i))
        bottom = box.get_bottom(array.get(box_array, i))
        poi = (top + bottom) / 2

        upper_boundary = poi + atr_threshold
        lower_boundary = poi - atr_threshold

        if new_poi >= lower_boundary and new_poi <= upper_boundary
            okay_to_draw := false
            break
        else
            okay_to_draw := true
            okay_to_draw
    okay_to_draw

//      FUNCTION TO DRAW SUPPLY OR DEMAND ZONE
f_supply_demand(value_array, bn_array, box_array, label_array, box_type, atr) =>

    atr_buffer = atr * (box_width / 10)
    box_left = array.get(bn_array, 0)
    box_right = bar_index

    var float box_top = 0.00
    var float box_bottom = 0.00
    var float poi = 0.00

    if box_type == 1
        box_top := array.get(value_array, 0)
        box_bottom := box_top - atr_buffer
        poi := (box_top + box_bottom) / 2
        poi
    else if box_type == -1
        box_bottom := array.get(value_array, 0)
        box_top := box_bottom + atr_buffer
        poi := (box_top + box_bottom) / 2
        poi

    okay_to_draw = f_check_overlapping(poi, box_array, atr)
    // okay_to_draw = true

    //delete oldest box, and then create a new box and add it to the array
    if box_type == 1 and okay_to_draw
        box.delete(array.get(box_array, array.size(box_array) - 1))
        f_array_add_pop(box_array, box.new(left = box_left, top = box_top, right = box_right, bottom = box_bottom, border_color = supply_outline_color, bgcolor = supply_color, extend = extend.right, text = '', text_halign = text.align_center, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index))

        box.delete(array.get(label_array, array.size(label_array) - 1))
        f_array_add_pop(label_array, box.new(left = box_left, top = poi, right = box_right, bottom = poi, border_color = color.new(poi_label_color, 90), bgcolor = color.new(poi_label_color, 90), extend = extend.right, text = 'POI', text_halign = text.align_left, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index))

    else if box_type == -1 and okay_to_draw
        box.delete(array.get(box_array, array.size(box_array) - 1))
        f_array_add_pop(box_array, box.new(left = box_left, top = box_top, right = box_right, bottom = box_bottom, border_color = demand_outline_color, bgcolor = demand_color, extend = extend.right, text = '', text_halign = text.align_center, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index))

        box.delete(array.get(label_array, array.size(label_array) - 1))
        f_array_add_pop(label_array, box.new(left = box_left, top = poi, right = box_right, bottom = poi, border_color = color.new(poi_label_color, 90), bgcolor = color.new(poi_label_color, 90), extend = extend.right, text = 'POI', text_halign = text.align_left, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index))

//      FUNCTION TO CHANGE SUPPLY/DEMAND TO A BOS IF BROKEN
f_sd_to_bos(box_array, bos_array, label_array, zone_type) =>

    if zone_type == 1
        for i = 0 to array.size(box_array) - 1 by 1
            level_to_break = box.get_top(array.get(box_array, i))
            // if ta.crossover(close, level_to_break)
            if close >= level_to_break
                copied_box = box.copy(array.get(box_array, i))
                f_array_add_pop(bos_array, copied_box)
                mid = (box.get_top(array.get(box_array, i)) + box.get_bottom(array.get(box_array, i))) / 2
                box.set_top(array.get(bos_array, 0), mid)
                box.set_bottom(array.get(bos_array, 0), mid)
                box.set_extend(array.get(bos_array, 0), extend.none)
                box.set_right(array.get(bos_array, 0), bar_index)
                box.set_text(array.get(bos_array, 0), 'BOS')
                box.set_text_color(array.get(bos_array, 0), bos_label_color)
                box.set_text_size(array.get(bos_array, 0), size.small)
                box.set_text_halign(array.get(bos_array, 0), text.align_center)
                box.set_text_valign(array.get(bos_array, 0), text.align_center)
                box.delete(array.get(box_array, i))
                box.delete(array.get(label_array, i))

    if zone_type == -1
        for i = 0 to array.size(box_array) - 1 by 1
            level_to_break = box.get_bottom(array.get(box_array, i))
            // if ta.crossunder(close, level_to_break)
            if close <= level_to_break
                copied_box = box.copy(array.get(box_array, i))
                f_array_add_pop(bos_array, copied_box)
                mid = (box.get_top(array.get(box_array, i)) + box.get_bottom(array.get(box_array, i))) / 2
                box.set_top(array.get(bos_array, 0), mid)
                box.set_bottom(array.get(bos_array, 0), mid)
                box.set_extend(array.get(bos_array, 0), extend.none)
                box.set_right(array.get(bos_array, 0), bar_index)
                box.set_text(array.get(bos_array, 0), 'BOS')
                box.set_text_color(array.get(bos_array, 0), bos_label_color)
                box.set_text_size(array.get(bos_array, 0), size.small)
                box.set_text_halign(array.get(bos_array, 0), text.align_center)
                box.set_text_valign(array.get(bos_array, 0), text.align_center)
                box.delete(array.get(box_array, i))
                box.delete(array.get(label_array, i))

//      FUNCTION MANAGE CURRENT BOXES BY CHANGING ENDPOINT
f_extend_box_endpoint(box_array) =>

    for i = 0 to array.size(box_array) - 1 by 1
        box.set_right(array.get(box_array, i), bar_index + 100)

//      CALCULATE ATR 
atr = ta.atr(50)

//      CALCULATE SWING HIGHS & SWING LOWS
swing_high = ta.pivothigh(high, swing_length, swing_length)
swing_low = ta.pivotlow(low, swing_length, swing_length)

//      ARRAYS FOR SWING H/L & BN 
var swing_high_values = array.new_float(5, 0.00)
var swing_low_values = array.new_float(5, 0.00)

var swing_high_bns = array.new_int(5, 0)
var swing_low_bns = array.new_int(5, 0)

//      ARRAYS FOR SUPPLY / DEMAND
var current_supply_box = array.new_box(history_of_demand_to_keep, na)
var current_demand_box = array.new_box(history_of_demand_to_keep, na)

//      ARRAYS FOR SUPPLY / DEMAND POI LABELS
var current_supply_poi = array.new_box(history_of_demand_to_keep, na)
var current_demand_poi = array.new_box(history_of_demand_to_keep, na)

//      ARRAYS FOR BOS
var supply_bos = array.new_box(5, na)
var demand_bos = array.new_box(5, na)

//      NEW SWING HIGH
if not na(swing_high)

    //MANAGE SWING HIGH VALUES
    f_array_add_pop(swing_high_values, swing_high)
    f_array_add_pop(swing_high_bns, bar_index[swing_length])
    if show_price_action_labels
        f_sh_sl_labels(swing_high_values, 1)

    f_supply_demand(swing_high_values, swing_high_bns, current_supply_box, current_supply_poi, 1, atr)

//      NEW SWING LOW
else if not na(swing_low)

    //MANAGE SWING LOW VALUES
    f_array_add_pop(swing_low_values, swing_low)
    f_array_add_pop(swing_low_bns, bar_index[swing_length])
    if show_price_action_labels
        f_sh_sl_labels(swing_low_values, -1)

    f_supply_demand(swing_low_values, swing_low_bns, current_demand_box, current_demand_poi, -1, atr)

f_sd_to_bos(current_supply_box, supply_bos, current_supply_poi, 1)
f_sd_to_bos(current_demand_box, demand_bos, current_demand_poi, -1)

f_extend_box_endpoint(current_supply_box)
f_extend_box_endpoint(current_demand_box)

//ZIG ZAG
h = ta.highest(high, swing_length * 2 + 1)
l = ta.lowest(low, swing_length * 2 + 1)
f_isMin(len) =>
    l == low[len]
f_isMax(len) =>
    h == high[len]

var dirUp = false
var lastLow = high * 100
var lastHigh = 0.0
var timeLow = bar_index
var timeHigh = bar_index
var line li = na

f_drawLine() =>
    _li_color = show_zigzag ? zigzag_color : color.new(#ffffff, 100)
    line.new(timeHigh - swing_length, lastHigh, timeLow - swing_length, lastLow, xloc.bar_index, color = _li_color, width = 2)

if dirUp
    if f_isMin(swing_length) and low[swing_length] < lastLow
        lastLow := low[swing_length]
        timeLow := bar_index
        line.delete(li)
        li := f_drawLine()
        li

    if f_isMax(swing_length) and high[swing_length] > lastLow
        lastHigh := high[swing_length]
        timeHigh := bar_index
        dirUp := false
        li := f_drawLine()
        li

if not dirUp
    if f_isMax(swing_length) and high[swing_length] > lastHigh
        lastHigh := high[swing_length]
        timeHigh := bar_index
        line.delete(li)
        li := f_drawLine()
        li
    if f_isMin(swing_length) and low[swing_length] < lastHigh
        lastLow := low[swing_length]
        timeLow := bar_index
        dirUp := true
        li := f_drawLine()
        if f_isMax(swing_length) and high[swing_length] > lastLow
            lastHigh := high[swing_length]
            timeHigh := bar_index
            dirUp := false
            li := f_drawLine()
            li

// =====================
// INPUTS MACD
// =====================
fast_length   = input.int(12, "Fast Length")
slow_length   = input.int(26, "Slow Length")
signal_length = input.int(9, "Signal Smoothing", minval=1, maxval=50)
srcq           = input.source(close, "Source")

pivotLen = input.int(5, "Pivot Length (Divergences)", minval=2)

// =====================
// COLORS
// =====================
col_grow_above = color.new(#26A69A, 0)
col_grow_below = color.new(#FFCDD2, 0)
col_fall_above = color.new(#B2DFDB, 0)
col_fall_below = color.new(#EF5350, 0)

// =====================
// MACD-AS CORE
// =====================
fast_ma  = ta.ema(srcq, fast_length)
slow_ma  = ta.ema(srcq, slow_length)

macd     = fast_ma - slow_ma
msignal  = ta.ema(macd, signal_length)
macdas   = macd - msignal
signal   = ta.ema(macdas, signal_length)

// =====================
// PLOTS
// =====================
plot(macdas, title="MACD-AS Histogram",
     style=plot.style_columns,
     color=(macdas >= 0 ?
        (macdas[1] < macdas ? col_grow_above : col_fall_above) :
        (macdas[1] < macdas ? col_grow_below : col_fall_below)))

plot(signal, title="Signal", color=color.blue, linewidth=1)

// =====================
// DIVERGENCES MACD
// =====================

// pivots price
pivotLowPrice  = ta.pivotlow(low, pivotLen, pivotLen)
pivotHighPrice = ta.pivothigh(high, pivotLen, pivotLen)

// pivots macd
pivotLowMacd  = ta.pivotlow(macdas, pivotLen, pivotLen)
pivotHighMacd = ta.pivothigh(macdas, pivotLen, pivotLen)

// store last pivots
var float lastLowPrice  = na
var float lastLowMacd   = na
var int   lastLowBar    = na

var float lastHighPrice = na
var float lastHighMacd  = na
var int   lastHighBar   = na

// =====================
// BULLISH DIVERGENCE
// =====================
if not na(pivotLowPrice) and not na(pivotLowMacd)
    if not na(lastLowPrice) and not na(lastLowMacd)
        // price lower low + macd higher low
        if pivotLowPrice < lastLowPrice and pivotLowMacd > lastLowMacd
            line.new(lastLowBar, lastLowPrice, bar_index - pivotLen, pivotLowPrice, color=color.rgb(0, 230, 119, 62), width=1)
      
    lastLowPrice := pivotLowPrice
    lastLowMacd  := pivotLowMacd
    lastLowBar   := bar_index - pivotLen

// =====================
// BEARISH DIVERGENCE
// =====================
if not na(pivotHighPrice) and not na(pivotHighMacd)
    if not na(lastHighPrice) and not na(lastHighMacd)
        // price higher high + macd lower high
        if pivotHighPrice > lastHighPrice and pivotHighMacd < lastHighMacd
            line.new(lastHighBar, lastHighPrice, bar_index - pivotLen, pivotHighPrice, color=color.rgb(176, 0, 0, 48), width=1)

    lastHighPrice := pivotHighPrice
    lastHighMacd  := pivotHighMacd
    lastHighBar   := bar_index - pivotLen

//────────────────────────────────────
// 15m DATA STREAM (LIVE - może repaintować)
//────────────────────────────────────
h15 = request.security(syminfo.tickerid, "15", high)
l15 = request.security(syminfo.tickerid, "15", low)

//────────────────────────────────────
// INPUTS
//────────────────────────────────────
lengthx = input.int(20, "15m Bars Lookback (LIVE)")
lengthq = input.int(200, "15m Bars Lookback (NO REPAINT)")

//────────────────────────────────────
// LIVE RANGE
//────────────────────────────────────
rangeHigh = ta.highest(h15, lengthx)
rangeLow  = ta.lowest(l15, lengthx)

//────────────────────────────────────
// NO REPAINT DATA
//────────────────────────────────────
h15q = request.security(syminfo.tickerid, "15", high, lookahead=barmerge.lookahead_off)
l15q = request.security(syminfo.tickerid, "15", low,  lookahead=barmerge.lookahead_off)

rangeHighq = ta.highest(h15q, lengthq)
rangeLowq  = ta.lowest(l15q, lengthq)

//────────────────────────────────────
// LINES (LIVE)
//────────────────────────────────────
var line hiLine = na
var line loLine = na

if na(hiLine)
    hiLine := line.new(bar_index, rangeHigh, bar_index, rangeHigh, extend=extend.right, color=color.rgb(126, 0, 0), width=2)

if na(loLine)
    loLine := line.new(bar_index, rangeLow, bar_index, rangeLow, extend=extend.right, color=color.rgb(0, 107, 21), width=2)

// update
line.set_xy1(hiLine, bar_index, rangeHigh)
line.set_xy2(hiLine, bar_index + 1, rangeHigh)

line.set_xy1(loLine, bar_index, rangeLow)
line.set_xy2(loLine, bar_index + 1, rangeLow)

//────────────────────────────────────
// LINES (NO REPAINT)
//────────────────────────────────────
var line hiLineq = na
var line loLineq = na

if na(hiLineq)
    hiLineq := line.new(bar_index, rangeHighq, bar_index, rangeHighq, extend=extend.right, color=color.rgb(157, 0, 0), width=5)

if na(loLineq)
    loLineq := line.new(bar_index, rangeLowq, bar_index, rangeLowq, extend=extend.right, color=color.rgb(0, 134, 4), width=5)

// update 
line.set_xy1(hiLineq, bar_index, rangeHighq)
line.set_xy2(hiLineq, bar_index + 1, rangeHighq)

line.set_xy1(loLineq, bar_index, rangeLowq)
line.set_xy2(loLineq, bar_index + 1, rangeLowq)

//────────────────────────────────────
// Opening Range
//────────────────────────────────────
orMinutes = input.int(5, "Opening Range Minutes")

showA = input.bool(true, "Azja")
showJ = input.bool(true, "Japan")
showEU = input.bool(true, "Europe (London)")
showUS = input.bool(true, "US")
showNY = input.bool(true, "New York")
showDS = input.bool(true, "DS (Poland)")

//────────────────────────────────────
// TIMEZONE (ONLY POLAND)
//────────────────────────────────────
tz = "Europe/Warsaw"

//────────────────────────────────────
// SESSIONS (POLISH TIME)
//────────────────────────────────────
aSess  = "0000-0800"   // Australia
jSess  = "0200-1000"   // DS Japon
euSess = "0900-1700"   // Europa
usSess = "1400-2200"   // US
nySess = "1530-2250"   // NY
dSess  = "2250-2300"   // DS (Poland)

//────────────────────────────────────
// SESSION DETECTION (ALL IN PL TIME)
//────────────────────────────────────
inA  = not na(time(timeframe.period, aSess, tz))
inJ = not na(time(timeframe.period, jSess, tz))
inEU = not na(time(timeframe.period, euSess, tz))
inUS = not na(time(timeframe.period, usSess, tz))
inNY = not na(time(timeframe.period, nySess, tz))
inDS = not na(time(timeframe.period, dSess, tz))

newA  = inA  and not inA[1]
newJ  = inJ  and not inJ[1]
newEU = inEU and not inEU[1]
newUS = inUS and not inUS[1]
newNY = inNY and not inNY[1]
newDS = inDS and not inDS[1]

//────────────────────────────────────
// AZJA
//────────────────────────────────────
var float aHigh = na
var float aLow  = na
var int aCount  = 0
var int aStart  = na
var box aBox    = na

if newA
    aHigh := na
    aLow  := na
    aCount := 0
    aStart := bar_index
    aBox := na

if showA and inA
    if aCount < orMinutes
        aHigh := na(aHigh) ? high : math.max(aHigh, high)
        aLow  := na(aLow)  ? low  : math.min(aLow, low)
        aCount += 1

    if aCount == orMinutes and na(aBox)
        aBox := box.new(aStart, aHigh, bar_index, aLow,
            bgcolor=color.new(#5b005e, 79), border_color=na)

    if not na(aBox)
        box.set_right(aBox, bar_index)
        box.set_top(aBox, aHigh)
        box.set_bottom(aBox, aLow)

//────────────────────────────────────
// JAPAN
//────────────────────────────────────
var float jHigh = na
var float jLow  = na
var int jCount  = 0
var int jStart  = na
var box jBox    = na

if newJ
    jHigh := na
    jLow  := na
    jCount := 0
    jStart := bar_index
    jBox := na

if showJ and inJ
    if jCount < orMinutes
        jHigh := na(jHigh) ? high : math.max(jHigh, high)
        jLow  := na(jLow)  ? low  : math.min(jLow, low)
        jCount += 1

    if jCount == orMinutes and na(jBox)
        jBox := box.new(jStart, jHigh, bar_index, jLow,
            bgcolor=color.new(#00585e, 79), border_color=na)

    if not na(jBox)
        box.set_right(jBox, bar_index)
        box.set_top(jBox, jHigh)
        box.set_bottom(jBox, jLow)

//────────────────────────────────────
// EUROPE
//────────────────────────────────────
var float euHigh = na
var float euLow  = na
var int euCount  = 0
var int euStart  = na
var box euBox    = na

if newEU
    euHigh := na
    euLow  := na
    euCount := 0
    euStart := bar_index
    euBox := na

if showEU and inEU
    if euCount < orMinutes
        euHigh := na(euHigh) ? high : math.max(euHigh, high)
        euLow  := na(euLow)  ? low  : math.min(euLow, low)
        euCount += 1

    if euCount == orMinutes and na(euBox)
        euBox := box.new(euStart, euHigh, bar_index, euLow,
            bgcolor=color.new(#535353, 50), border_color=na)

    if not na(euBox)
        box.set_right(euBox, bar_index)
        box.set_top(euBox, euHigh)
        box.set_bottom(euBox, euLow)

//────────────────────────────────────
// US
//────────────────────────────────────
var float usHigh = na
var float usLow  = na
var int usCount  = 0
var int usStart  = na
var box usBox    = na

if newUS
    usHigh := na
    usLow  := na
    usCount := 0
    usStart := bar_index
    usBox := na

if showUS and inUS
    if usCount < orMinutes
        usHigh := na(usHigh) ? high : math.max(usHigh, high)
        usLow  := na(usLow)  ? low  : math.min(usLow, low)
        usCount += 1

    if usCount == orMinutes and na(usBox)
        usBox := box.new(usStart, usHigh, bar_index, usLow,
            bgcolor=color.new(#1100ff, 77), border_color=na)

    if not na(usBox)
        box.set_right(usBox, bar_index)
        box.set_top(usBox, usHigh)
        box.set_bottom(usBox, usLow)

//────────────────────────────────────
// NEW YORK
//────────────────────────────────────
var float nyHigh = na
var float nyLow  = na
var int nyCount  = 0
var int nyStart  = na
var box nyBox    = na

if newNY
    nyHigh := na
    nyLow  := na
    nyCount := 0
    nyStart := bar_index
    nyBox := na

if showNY and inNY
    if nyCount < orMinutes
        nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
        nyLow  := na(nyLow)  ? low  : math.min(nyLow, low)
        nyCount += 1

    if nyCount == orMinutes and na(nyBox)
        nyBox := box.new(nyStart, nyHigh, bar_index, nyLow,
            bgcolor=color.new(#6d0000, 70), border_color=na)

    if not na(nyBox)
        box.set_right(nyBox, bar_index)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)

//────────────────────────────────────
// DAILY SESSION (POLAND)
//────────────────────────────────────
var float dHigh = na
var float dLow  = na
var int dCount  = 0
var int dStart  = na
var box dBox    = na

if newDS
    dHigh := na
    dLow  := na
    dCount := 0
    dStart := bar_index
    dBox := na

if showDS and inDS
    if dCount < orMinutes
        dHigh := na(dHigh) ? high : math.max(dHigh, high)
        dLow  := na(dLow)  ? low  : math.min(dLow, low)
        dCount += 1

    if dCount == orMinutes and na(dBox)
        dBox := box.new(dStart, dHigh, bar_index, dLow,
            bgcolor=color.new(#fff700, 45), border_color=na)

    if not na(dBox)
        box.set_right(dBox, bar_index)
        box.set_top(dBox, dHigh)
        box.set_bottom(dBox, dLow)

//-----------------------------------------------------------------------------}
// ALERTS
//-----------------------------------------------------------------------------{

// CROSS SMA9
sma9Up   = ta.crossover(close, sma9)
sma9Down = ta.crossunder(close, sma9)

// ONE COMBINED ALERT WITH DIFFERENT MESSAGES
if bull_fvg
    alert("Bull FVG", alert.freq_once_per_bar_close)

if bear_fvg
    alert("Bear FVG", alert.freq_once_per_bar_close)

if sma9Up
    alert("sma9 UP", alert.freq_once_per_bar_close)

if sma9Down
    alert("sma9 DOWN", alert.freq_once_per_bar_close)
````
