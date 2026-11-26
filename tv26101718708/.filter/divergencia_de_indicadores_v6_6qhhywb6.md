# Divergencia de indicadores v6

- url: https://www.tradingview.com/script/6qhHyWb6/
- type: indicator
- pine_id: PUB;c3f6c46fc96b4b4aa11a6f217b7faa46
- version: 4.0

## Description

Based on https://es.tradingview.com/script/n8AGnIZd-Divergence-for-Many-Indicators-v4/ and 

Update:

1. Converted to Pine Script v6
2. Added EMAs config

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeTheBlue
//Based on https://es.tradingview.com/script/n8AGnIZd-Divergence-for-Many-Indicators-v4/ and converted to Pine Script v6
//Added EMAs config

//@version=6
indicator('Divergences v6 modified by @J777', overlay = true, max_bars_back = 1000, max_lines_count = 400, max_labels_count = 400)
import TradingView/ta/12
prd = input.int(defval = 5, title = 'Pivot Period', minval = 1, maxval = 50)
source = input.string(defval = 'Close', title = 'Source for Pivot Points', options = ['Close', 'High/Low'])
searchdiv = input.string(defval = 'Regular', title = 'Divergence Type', options = ['Regular', 'Hidden', 'Regular/Hidden'])
showindis = input.string(defval = 'Full', title = 'Show Indicator Names', options = ['Full', 'First Letter', 'Don\'t Show'])
showlimit = input.int(1, title = 'Minimum Number of Divergence', minval = 1, maxval = 11)
maxpp = input.int(defval = 10, title = 'Maximum Pivot Points to Check', minval = 1, maxval = 20)
maxbars = input.int(defval = 100, title = 'Maximum Bars to Check', minval = 30, maxval = 200)
shownum = input(defval = true, title = 'Show Divergence Number')
showlast = input(defval = true, title = 'Show Only Last Divergence')
dontconfirm = input(defval = false, title = 'Don\'t Wait for Confirmation')
showlines = input(defval = true, title = 'Show Divergence Lines')
showpivot = input(defval = false, title = 'Show Pivot Points')
calcmacd = input(defval = true, title = 'MACD')
calcmacda = input(defval = true, title = 'MACD Histogram')
macdfast = input.int(defval = 12, title = 'MACD Fast Length', minval = 1)
macdslow = input.int(defval = 26, title = 'MACD Slow Length', minval = 1)
macdsig = input.int(defval = 9, title = 'MACD Signal Length', minval = 1)
calcrsi = input(defval = true, title = 'RSI')
rsilen = input.int(defval = 14, title = 'RSI Length', minval = 1)
calcstoc = input(defval = true, title = 'Stochastic')
stoclen = input.int(defval = 14, title = 'Stochastic Length', minval = 1)
calccci = input(defval = true, title = 'CCI')
ccilen = input.int(defval = 10, title = 'CCI Length', minval = 1)
calcmom = input(defval = true, title = 'Momentum')
momlen = input.int(defval = 10, title = 'Momentum Length', minval = 1)
calcobv = input(defval = true, title = 'OBV')
calcvwmacd = input(defval = true, title = 'VWmacd')
VWMAfast = input.int(defval = 12, title = 'VWMA Fast', minval = 1)
VWMAslow = input.int(defval = 26, title = 'VWMA Slow', minval = 1)
calccmf = input(defval = true, title = 'Chaikin Money Flow')
cmflen = input.int(defval = 21, title = 'Chaikin Money Flow Index SMA Length', minval = 1)
calcmfi = input(defval = true, title = 'Money Flow Index')
mfilen = input.int(defval = 14, title = 'Money Flow Index Length', minval = 1)
calcvd = input(defval = true, title = "Cumulative Volume Delta")
anchorInput = input.timeframe("1D", "Anchor period")
lowerTimeframeTooltip = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation. By default, the timeframe is chosen automatically. These inputs override this with a custom timeframe."
 + " \n\nHigher timeframes provide more historical data, but the data will be less precise."
useCustomTimeframeInput = input.bool(false, "Use custom timeframe", tooltip = lowerTimeframeTooltip)
lowerTimeframeInput = input.timeframe("1", "Timeframe", active = useCustomTimeframeInput)
caludvol = input(defval = true, title = "Up/Down Volume")
calcext = input(false, title = 'Check External Indicator')
externalindi = input(defval = close, title = 'External Indicator')
pos_reg_div_col = input(defval = color.teal, title = 'Positive Regular Divergence')
neg_reg_div_col = input(defval = color.red, title = 'Negative Regular Divergence')
pos_hid_div_col = input(defval = color.orange, title = 'Positive Hidden Divergence')
neg_hid_div_col = input(defval = color.purple, title = 'Negative Hidden Divergence')
pos_div_text_col = input(defval = color.white, title = 'Positive Divergence Text Color')
neg_div_text_col = input(defval = color.white, title = 'Negative Divergence Text Color')
reg_div_l_style_ = input.string(defval = 'Solid', title = 'Regular Divergence Line Style', options = ['Solid', 'Dashed', 'Dotted'])
hid_div_l_style_ = input.string(defval = 'Dashed', title = 'Hdden Divergence Line Style', options = ['Solid', 'Dashed', 'Dotted'])
reg_div_l_width = input.int(defval = 2, title = 'Regular Divergence Line Width', minval = 1, maxval = 5)
hid_div_l_width = input.int(defval = 1, title = 'Hidden Divergence Line Width', minval = 1, maxval = 5)
ma1show = input.bool(defval = true, title = 'Show MA1')
ma1col = input.color(defval = #b8b8b8, title = 'Color')
ma1type = input.string("VWMA", "Type", ["EMA", "SMA", "RMA", "WMA", "VWMA"], display = display.none)
ma1len = input.int(defval = 12, title = 'Length', minval = 1)
ma1src  = input.source(close, "Source")
ma1(ma1src, ma1len, ma1type) =>
    switch ma1type
        "SMA"       => ta.sma(ma1src,  ma1len) 
        "EMA"       => ta.ema(ma1src,  ma1len) 
        "RMA"       => ta.rma(ma1src,  ma1len) 
        "WMA"       => ta.wma(ma1src,  ma1len) 
        "VWMA"      => ta.vwma(ma1src,  ma1len) 
        => na

ma2show = input.bool(defval = false, title = 'Show MA2')
ma2col = input.color(defval = #3179f5, title = 'Color')
ma2type = input.string("EMA", "Type", ["EMA", "SMA", "RMA", "WMA", "VWMA"], display = display.none)
ma2len = input.int(defval = 18, title = 'Length', minval = 1)
ma2src  = input.source(close, "Source")
ma2(ma2src, ma2len, ma2type) =>
    switch ma2type
        "SMA"       => ta.sma(ma1src,  ma1len) 
        "EMA"       => ta.ema(ma1src,  ma1len) 
        "RMA"       => ta.rma(ma1src,  ma1len) 
        "WMA"       => ta.wma(ma1src,  ma1len) 
        "VWMA"      => ta.vwma(ma1src,  ma1len) 
        => na

plot(ma1show ? ma1(ma1src, ma1len, ma1type) : na, color = ma1show ? ma1col : na)
plot(ma2show ? ma2(ma2src, ma2len, ma2type) : na, color = ma2show ? ma2col : na)

//lowerTimeframe
var lowerTimeframe = switch
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.isseconds     => "1S"
    timeframe.isintraday    => "1"
    timeframe.isdaily       => "5"
    => "60"



// set line styles
var reg_div_l_style = reg_div_l_style_ == 'Solid' ? line.style_solid : reg_div_l_style_ == 'Dashed' ? line.style_dashed : line.style_dotted
var hid_div_l_style = hid_div_l_style_ == 'Solid' ? line.style_solid : hid_div_l_style_ == 'Dashed' ? line.style_dashed : line.style_dotted


// get indicators
rsi = ta.rsi(close, rsilen) // RSI
[macd, signal, deltamacd] = ta.macd(close, 12, 24, 9) // MACD
moment = ta.mom(close, momlen) // Momentum
cci = ta.cci(close, ccilen) // CCI
Obv = ta.obv // OBV
stk = ta.sma(ta.stoch(close, high, low, stoclen), 3) // Stochastic
maFast = ta.vwma(close, VWMAfast) // volume weighted macd
maSlow = ta.vwma(close, VWMAslow) // volume weighted macd
vwmacd = maFast - maSlow // volume weighted macd
Cmfm = (close - low - (high - close)) / (high - low) // Chaikin money flow
Cmfv = Cmfm * volume
cmf = ta.sma(Cmfv, cmflen) / ta.sma(volume, cmflen)
Mfi = ta.mfi(close, mfilen) // Money Flow Index
[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe, anchorInput) //CVD
[upVolume, downVolume, delta] = ta.requestUpAndDownVolume(lowerTimeframe) //Up/Down Volume

// keep indicators names and colors in arrays
var indicators_name = array.new_string(13)
var div_colors = array.new_color(4)
if barstate.isfirst
    // names
    array.set(indicators_name, 0, showindis == 'Full' ? 'MACD' : 'M')
    array.set(indicators_name, 1, showindis == 'Full' ? 'Hist' : 'H')
    array.set(indicators_name, 2, showindis == 'Full' ? 'RSI' : 'E')
    array.set(indicators_name, 3, showindis == 'Full' ? 'Stoch' : 'S')
    array.set(indicators_name, 4, showindis == 'Full' ? 'CCI' : 'C')
    array.set(indicators_name, 5, showindis == 'Full' ? 'MOM' : 'M')
    array.set(indicators_name, 6, showindis == 'Full' ? 'OBV(v)' : 'O*')
    array.set(indicators_name, 7, showindis == 'Full' ? 'VWMACD(v)' : 'V*')
    array.set(indicators_name, 8, showindis == 'Full' ? 'CMF(v)' : 'C*')
    array.set(indicators_name, 9, showindis == 'Full' ? 'MFI(v)' : 'M*')
    array.set(indicators_name, 10, showindis == 'Full' ? 'CVD(v)' : 'C*')
    array.set(indicators_name, 11, showindis == 'Full' ? 'U/D(v)' : 'U*')
    array.set(indicators_name, 12, showindis == 'Full' ? 'Extrn' : 'X')
    //colors
    array.set(div_colors, 0, pos_reg_div_col)
    array.set(div_colors, 1, neg_reg_div_col)
    array.set(div_colors, 2, pos_hid_div_col)
    array.set(div_colors, 3, neg_hid_div_col)

// Check if we get new Pivot High Or Pivot Low
float ph = ta.pivothigh(source == 'Close' ? close : high, prd, prd)
float pl = ta.pivotlow(source == 'Close' ? close : low, prd, prd)
plotshape(bool(ph) and showpivot, text = 'H', style = shape.labeldown, color = color.new(color.white, 100), textcolor = color.new(color.red, 0), location = location.abovebar, offset = -prd)
plotshape(bool(pl) and showpivot, text = 'L', style = shape.labelup, color = color.new(color.white, 100), textcolor = color.new(color.lime, 0), location = location.belowbar, offset = -prd)

// keep values and positions of Pivot Highs/Lows in the arrays
var int maxarraysize = 20
var ph_positions = array.new_int(maxarraysize, 0)
var pl_positions = array.new_int(maxarraysize, 0)
var ph_vals = array.new_float(maxarraysize, 0.)
var pl_vals = array.new_float(maxarraysize, 0.)

// add PHs to the array
if bool(ph)
    array.unshift(ph_positions, bar_index)
    array.unshift(ph_vals, ph)
    if array.size(ph_positions) > maxarraysize
        array.pop(ph_positions)
        array.pop(ph_vals)

// add PLs to the array
if bool(pl)
    array.unshift(pl_positions, bar_index)
    array.unshift(pl_vals, pl)
    if array.size(pl_positions) > maxarraysize
        array.pop(pl_positions)
        array.pop(pl_vals)

// functions to check Regular Divergences and Hidden Divergences

// function to check positive regular or negative hidden divergence
// cond == 1 => positive_regular, cond == 2=> negative_hidden
positive_regular_positive_hidden_divergence(src, cond) =>
    divlen = 0
    prsc = source == 'Close' ? close : low
    // if indicators higher than last value and close price is higher than las close 
    if dontconfirm or src > src[1] or close > close[1]
        startpoint = dontconfirm ? 0 : 1 // don't check last candle
        // we search last 15 PPs
        for x = 0 to maxpp - 1 by 1
            len = bar_index - array.get(pl_positions, x) + prd
            // if we reach non valued array element or arrived 101. or previous bars then we don't search more
            if array.get(pl_positions, x) == 0 or len > maxbars
                break
            if len > 5 and (cond == 1 and src[startpoint] > src[len] and prsc[startpoint] < nz(array.get(pl_vals, x)) or cond == 2 and src[startpoint] < src[len] and prsc[startpoint] > nz(array.get(pl_vals, x)))
                slope1 = (src[startpoint] - src[len]) / (len - startpoint)
                virtual_line1 = src[startpoint] - slope1
                slope2 = (close[startpoint] - close[len]) / (len - startpoint)
                virtual_line2 = close[startpoint] - slope2
                arrived = true
                for y = 1 + startpoint to len - 1 by 1
                    if src[y] < virtual_line1 or nz(close[y]) < virtual_line2
                        arrived := false
                        break
                    virtual_line1 := virtual_line1 - slope1
                    virtual_line2 := virtual_line2 - slope2
                    virtual_line2

                if arrived
                    divlen := len
                    break
    divlen

// function to check negative regular or positive hidden divergence
// cond == 1 => negative_regular, cond == 2=> positive_hidden
negative_regular_negative_hidden_divergence(src, cond) =>
    divlen = 0
    prsc = source == 'Close' ? close : high
    // if indicators higher than last value and close price is higher than las close 
    if dontconfirm or src < src[1] or close < close[1]
        startpoint = dontconfirm ? 0 : 1 // don't check last candle
        // we search last 15 PPs
        for x = 0 to maxpp - 1 by 1
            len = bar_index - array.get(ph_positions, x) + prd
            // if we reach non valued array element or arrived 101. or previous bars then we don't search more
            if array.get(ph_positions, x) == 0 or len > maxbars
                break
            if len > 5 and (cond == 1 and src[startpoint] < src[len] and prsc[startpoint] > nz(array.get(ph_vals, x)) or cond == 2 and src[startpoint] > src[len] and prsc[startpoint] < nz(array.get(ph_vals, x)))
                slope1 = (src[startpoint] - src[len]) / (len - startpoint)
                virtual_line1 = src[startpoint] - slope1
                slope2 = (close[startpoint] - nz(close[len])) / (len - startpoint)
                virtual_line2 = close[startpoint] - slope2
                arrived = true
                for y = 1 + startpoint to len - 1 by 1
                    if src[y] > virtual_line1 or nz(close[y]) > virtual_line2
                        arrived := false
                        break
                    virtual_line1 := virtual_line1 - slope1
                    virtual_line2 := virtual_line2 - slope2
                    virtual_line2

                if arrived
                    divlen := len
                    break
    divlen

// calculate 4 types of divergence if enabled in the options and return divergences in an array
calculate_divs(cond, indicator_1) =>
    divs = array.new_int(4, 0)
    array.set(divs, 0, cond and (searchdiv == 'Regular' or searchdiv == 'Regular/Hidden') ? positive_regular_positive_hidden_divergence(indicator_1, 1) : 0)
    array.set(divs, 1, cond and (searchdiv == 'Regular' or searchdiv == 'Regular/Hidden') ? negative_regular_negative_hidden_divergence(indicator_1, 1) : 0)
    array.set(divs, 2, cond and (searchdiv == 'Hidden' or searchdiv == 'Regular/Hidden') ? positive_regular_positive_hidden_divergence(indicator_1, 2) : 0)
    array.set(divs, 3, cond and (searchdiv == 'Hidden' or searchdiv == 'Regular/Hidden') ? negative_regular_negative_hidden_divergence(indicator_1, 2) : 0)
    divs

// array to keep all divergences
var all_divergences = array.new_int(52) // 13 indicators * 4 divergence = 52 elements
// set related array elements
array_set_divs(div_pointer, index) =>
    for x = 0 to 3 by 1
        array.set(all_divergences, index * 4 + x, array.get(div_pointer, x))

// set divergences array 
array_set_divs(calculate_divs(calcmacd, macd), 0)
array_set_divs(calculate_divs(calcmacda, deltamacd), 1)
array_set_divs(calculate_divs(calcrsi, rsi), 2)
array_set_divs(calculate_divs(calcstoc, stk), 3)
array_set_divs(calculate_divs(calccci, cci), 4)
array_set_divs(calculate_divs(calcmom, moment), 5)
array_set_divs(calculate_divs(calcobv, Obv), 6)
array_set_divs(calculate_divs(calcvwmacd, vwmacd), 7)
array_set_divs(calculate_divs(calccmf, cmf), 8)
array_set_divs(calculate_divs(calcmfi, Mfi), 9)
array_set_divs(calculate_divs(calcvd, lastVolume),10)
array_set_divs(calculate_divs(caludvol, delta),11)
array_set_divs(calculate_divs(calcext, externalindi), 12)

// check minimum number of divergence, if less than showlimit then delete all divergence
total_div = 0
for x = 0 to array.size(all_divergences) - 1 by 1
    total_div := total_div + math.round(math.sign(array.get(all_divergences, x)))
    total_div

if total_div < showlimit
    array.fill(all_divergences, 0)

// keep line in an array
var pos_div_lines = array.new_line(0)
var neg_div_lines = array.new_line(0)
var pos_div_labels = array.new_label(0)
var neg_div_labels = array.new_label(0)

// remove old lines and labels if showlast option is enabled
delete_old_pos_div_lines() =>
    if array.size(pos_div_lines) > 0
        for j = 0 to array.size(pos_div_lines) - 1 by 1
            line.delete(array.get(pos_div_lines, j))
        array.clear(pos_div_lines)

delete_old_neg_div_lines() =>
    if array.size(neg_div_lines) > 0
        for j = 0 to array.size(neg_div_lines) - 1 by 1
            line.delete(array.get(neg_div_lines, j))
        array.clear(neg_div_lines)

delete_old_pos_div_labels() =>
    if array.size(pos_div_labels) > 0
        for j = 0 to array.size(pos_div_labels) - 1 by 1
            label.delete(array.get(pos_div_labels, j))
        array.clear(pos_div_labels)

delete_old_neg_div_labels() =>
    if array.size(neg_div_labels) > 0
        for j = 0 to array.size(neg_div_labels) - 1 by 1
            label.delete(array.get(neg_div_labels, j))
        array.clear(neg_div_labels)

// delete last creted lines and labels until we met new PH/PV 
delete_last_pos_div_lines_label(n) =>
    if n > 0 and array.size(pos_div_lines) >= n
        asz = array.size(pos_div_lines)
        for j = 1 to n by 1
            line.delete(array.get(pos_div_lines, asz - j))
            array.pop(pos_div_lines)
        if array.size(pos_div_labels) > 0
            label.delete(array.get(pos_div_labels, array.size(pos_div_labels) - 1))
            array.pop(pos_div_labels)

delete_last_neg_div_lines_label(n) =>
    if n > 0 and array.size(neg_div_lines) >= n
        asz = array.size(neg_div_lines)
        for j = 1 to n by 1
            line.delete(array.get(neg_div_lines, asz - j))
            array.pop(neg_div_lines)
        if array.size(neg_div_labels) > 0
            label.delete(array.get(neg_div_labels, array.size(neg_div_labels) - 1))
            array.pop(neg_div_labels)

// variables for Alerts
pos_reg_div_detected = false
neg_reg_div_detected = false
pos_hid_div_detected = false
neg_hid_div_detected = false

// to remove lines/labels until we met new // PH/PL
var last_pos_div_lines = 0
var last_neg_div_lines = 0
var remove_last_pos_divs = false
var remove_last_neg_divs = false
if bool(pl)
    remove_last_pos_divs := false
    last_pos_div_lines := 0
    last_pos_div_lines
if bool(ph)
    remove_last_neg_divs := false
    last_neg_div_lines := 0
    last_neg_div_lines

// draw divergences lines and labels
divergence_text_top = ''
divergence_text_bottom = ''
distances = array.new_int(0)
dnumdiv_top = 0
dnumdiv_bottom = 0
top_label_col = color.white
bottom_label_col = color.white
old_pos_divs_can_be_removed = true
old_neg_divs_can_be_removed = true
startpoint = dontconfirm ? 0 : 1 // used for don't confirm option

for x = 0 to 10 by 1
    div_type = -1
    for y = 0 to 3 by 1
        if array.get(all_divergences, x * 4 + y) > 0 // any divergence?
            div_type := y
            if y % 2 == 1
                dnumdiv_top := dnumdiv_top + 1
                top_label_col := array.get(div_colors, y)
                top_label_col
            if y % 2 == 0
                dnumdiv_bottom := dnumdiv_bottom + 1
                bottom_label_col := array.get(div_colors, y)
                bottom_label_col
            if not array.includes(distances, array.get(all_divergences, x * 4 + y)) // line not exist ?
                array.push(distances, array.get(all_divergences, x * 4 + y))
                new_line = showlines ? line.new(x1 = bar_index - array.get(all_divergences, x * 4 + y), y1 = source == 'Close' ? close[array.get(all_divergences, x * 4 + y)] : y % 2 == 0 ? low[array.get(all_divergences, x * 4 + y)] : high[array.get(all_divergences, x * 4 + y)], x2 = bar_index - startpoint, y2 = source == 'Close' ? close[startpoint] : y % 2 == 0 ? low[startpoint] : high[startpoint], color = array.get(div_colors, y), style = y < 2 ? reg_div_l_style : hid_div_l_style, width = y < 2 ? reg_div_l_width : hid_div_l_width) : na
                if y % 2 == 0
                    if old_pos_divs_can_be_removed
                        old_pos_divs_can_be_removed := false
                        if not showlast and remove_last_pos_divs
                            delete_last_pos_div_lines_label(last_pos_div_lines)
                            last_pos_div_lines := 0
                            last_pos_div_lines
                        if showlast
                            delete_old_pos_div_lines()
                    array.push(pos_div_lines, new_line)
                    last_pos_div_lines := last_pos_div_lines + 1
                    remove_last_pos_divs := true
                    remove_last_pos_divs

                if y % 2 == 1
                    if old_neg_divs_can_be_removed
                        old_neg_divs_can_be_removed := false
                        if not showlast and remove_last_neg_divs
                            delete_last_neg_div_lines_label(last_neg_div_lines)
                            last_neg_div_lines := 0
                            last_neg_div_lines
                        if showlast
                            delete_old_neg_div_lines()
                    array.push(neg_div_lines, new_line)
                    last_neg_div_lines := last_neg_div_lines + 1
                    remove_last_neg_divs := true
                    remove_last_neg_divs

            // set variables for alerts
            if y == 0
                pos_reg_div_detected := true
                pos_reg_div_detected
            if y == 1
                neg_reg_div_detected := true
                neg_reg_div_detected
            if y == 2
                pos_hid_div_detected := true
                pos_hid_div_detected
            if y == 3
                neg_hid_div_detected := true
                neg_hid_div_detected
    // get text for labels
    if div_type >= 0
        divergence_text_top := divergence_text_top + (div_type % 2 == 1 ? showindis != 'Don\'t Show' ? array.get(indicators_name, x) + '\n' : '' : '')
        divergence_text_bottom := divergence_text_bottom + (div_type % 2 == 0 ? showindis != 'Don\'t Show' ? array.get(indicators_name, x) + '\n' : '' : '')
        divergence_text_bottom


// draw labels
if showindis != 'Don\'t Show' or shownum
    if shownum and dnumdiv_top > 0
        divergence_text_top := divergence_text_top + str.tostring(dnumdiv_top)
        divergence_text_top
    if shownum and dnumdiv_bottom > 0
        divergence_text_bottom := divergence_text_bottom + str.tostring(dnumdiv_bottom)
        divergence_text_bottom
    if divergence_text_top != ''
        if showlast
            delete_old_neg_div_labels()
        array.push(neg_div_labels, label.new(x = bar_index, y = math.max(high, high[1]), text = divergence_text_top, color = top_label_col, textcolor = neg_div_text_col, size = size.tiny, style = label.style_label_down))

    if divergence_text_bottom != ''
        if showlast
            delete_old_pos_div_labels()
        array.push(pos_div_labels, label.new(x = bar_index, y = math.min(low, low[1]), text = divergence_text_bottom, color = bottom_label_col, textcolor = pos_div_text_col, size = size.tiny, style = label.style_label_up))

//var cumVol = 0.
//cumVol += nz(volume)
//if barstate.islast and cumVol == 0
  //  runtime.error("The data vendor doesn't provide volume data for this symbol.")

alertcondition(pos_reg_div_detected, title = 'Positive Regular Divergence Detected', message = 'Positive Regular Divergence Detected')
alertcondition(neg_reg_div_detected, title = 'Negative Regular Divergence Detected', message = 'Negative Regular Divergence Detected')
alertcondition(pos_hid_div_detected, title = 'Positive Hidden Divergence Detected', message = 'Positive Hidden Divergence Detected')
alertcondition(neg_hid_div_detected, title = 'Negative Hidden Divergence Detected', message = 'Negative Hidden Divergence Detected')

alertcondition(pos_reg_div_detected or pos_hid_div_detected, title = 'Positive Divergence Detected', message = 'Positive Divergence Detected')
alertcondition(neg_reg_div_detected or neg_hid_div_detected, title = 'Negative Divergence Detected', message = 'Negative Divergence Detected')
````
