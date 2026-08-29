<!-- tradingview-pine-id: PUB;f3dd43b3dde44503be90ce99e6418d5d -->
<!-- tradingviewscripts-format: 1 -->
# MAHQuant_IND_Divergence_v1.0

Source: https://www.tradingview.com/script/U9OQUFv6-MAHQuant-IND-Divergence-v1-0/

## Description

MAHQuant Divergence for Many Indicators v1.0

A professional multi-indicator divergence detection system with advanced risk management features. This indicator combines powerful divergence scanning across 10+ technical indicators with automated Entry/SL/TP calculation and smart confluence filtering.

✨ Key Features:

1️⃣ Multi-Indicator Divergence Detection:
• Simultaneously scans for divergences across 10+ indicators:

MACD, MACD Histogram, RSI, Stochastic, CCI
Momentum, OBV, VW-MACD, CMF, MFI
Custom external indicator support
• Detects both Regular and Hidden divergences
• Bullish and Bearish divergence identification
• Visual divergence lines with customizable styles

2️⃣ Advanced Risk Management (NEW):
• Automatic SL/TP Calculation

Entry price based on signal candle close
Stop Loss using ATR-based dynamic calculation
Two Take Profit levels (TP1 = 1:1 RR, TP2 = 1:2 RR)
Visual horizontal lines for Entry, SL, TP1, TP2

• Max SL Distance Protection

Configurable maximum stop loss limit (default: 800 points)
Prevents excessive risk in high-volatility conditions
Automatically caps SL if ATR-based distance exceeds limit

3️⃣ Smart Confluence Filter (NEW):
• Option to show signals ONLY when both Regular AND Hidden divergences appear together
• Significantly reduces false signals
• Increases signal reliability and probability

4️⃣ Professional Visualization:
• Signal Label: Shows Entry, SL, TP1, TP2 prices directly on chart
• Auto-Clean Mode: Automatically removes old signal lines to keep chart clean
• Customizable line lengths, colors, and styles
• Pivot point markers (optional)
• Divergence count display

5️ Alert System:
• Built-in alerts for all divergence types
• Separate alerts for Regular Bullish/Bearish
• Separate alerts for Hidden Bullish/Bearish
• Combined positive/negative divergence alerts

⚙️ How to Use:

Basic Setup:
Add indicator to your chart
Select which indicators to scan (MACD, RSI, Stoch, etc.)
Choose divergence type: Regular, Hidden, or Both
Adjust Pivot Period (default: 5) based on your timeframe

Risk Management:
5. Set ATR Length (default: 14) for SL calculation
6. Adjust ATR Multiplier (default: 0.1-1.0) for SL distance
7. Configure Max SL Distance to limit maximum risk
8. Enable "Show SL/TP Lines" to visualize levels

Advanced Filtering:
9. Enable "Show Only Confluence" to filter for highest-probability signals
10. Use "Show Only Last Signal Lines" to keep chart clean
11. Adjust SL/TP Lines Length for visual preference

Trading Strategy:
• Entry: Enter on signal candle close or next candle open
• Stop Loss: Use the calculated SL level (below/above divergence pivot)
• Take Profit 1: Close 50% position at TP1 (1:1 RR)
• Take Profit 2: Close remaining 50% at TP2 (1:2 RR)

📊 Indicator Settings Explained:

• Pivot Period: Number of bars for pivot detection (higher = fewer but stronger signals)
• Source for Pivots: Use Close or High/Low for pivot calculation
• Divergence Type: Regular (reversal), Hidden (continuation), or Both
• Min Number of Divergence: Filter out weak signals (show only if X+ divergences detected)
• Max Pivot Points to Check: How far back to search for divergences
• ATR Multiplier: Higher = wider SL, lower = tighter SL
• Max SL Distance: Maximum allowed SL in points (prevents excessive risk)

🎯 Best Practices:

✅ Use on higher timeframes (1H, 4H, Daily) for more reliable signals
✅ Combine with trend analysis and support/resistance levels
✅ Enable Confluence filter for higher probability setups
✅ Always use proper position sizing and risk management
✅ Backtest on your preferred market before live trading

⚠️ Important Notes:

• This indicator provides signals based on divergence detection
• Not all signals will be profitable - always use stop loss
• Market conditions affect divergence reliability
• Past performance does not guarantee future results
• This is a tool to assist your analysis, not a standalone trading system

Credits & Acknowledgment:
• Original divergence detection logic inspired by LonesomeTheBlue's open-source "Divergence for Many Indicators v4" indicator
• Enhanced with professional risk management features, SL/TP automation, and confluence filtering by MAHQuant Trading System
• Thank you to the TradingView community for open-source collaboration and continuous learning

⚠️ Disclaimer:
This script is for educational and informational purposes only. It does not constitute financial, investment, or trading advice. The author is not responsible for any losses incurred from using this indicator. Past performance is not indicative of future results. Always conduct your own research and manage your risk appropriately. Trade at your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MAHQuant

// ============================================
// CREDITS & ACKNOWLEDGMENT
// ============================================
// Original divergence detection logic inspired by:
// LonesomeTheBlue's open-source "Divergence for Many Indicators v4" indicator
// 
// Enhancements and additional features developed by:
// MAHQuant Trading System
// - SL/TP calculation and visualization
// - Signal labeling with Entry/SL/TP prices
// - Confluence filter (Regular + Hidden together)
// - Auto-clean functionality for signal lines
// - Max SL distance protection
// ============================================

//@version=6
indicator('MAHQuant_IND_Divergence_v1.0', overlay = true, max_bars_back = 1000, max_lines_count = 400, max_labels_count = 400)

// ===== INPUTS =====
prd = input.int(defval = 5, title = 'Pivot Period', minval = 1, maxval = 50)
source = input.string(defval = 'Close', title = 'Source for Pivot Points', options = ['Close', 'High/Low'])
searchdiv = input.string(defval = 'Regular', title = 'Divergence Type', options = ['Regular', 'Hidden', 'Regular/Hidden'])
showindis = input.string(defval = 'Full', title = 'Show Indicator Names', options = ['Full', 'First Letter', 'Don\'t Show'])
showlimit = input.int(1, title = 'Minimum Number of Divergence', minval = 1, maxval = 11)
maxpp = input.int(defval = 10, title = 'Maximum Pivot Points to Check', minval = 1, maxval = 20)
maxbars = input.int(defval = 100, title = 'Maximum Bars to Check', minval = 30, maxval = 200)
shownum = input(defval = true, title = 'Show Divergence Number')
showlast = input(defval = false, title = 'Show Only Last Divergence')
dontconfirm = input(defval = false, title = 'Don\'t Wait for Confirmation')
showlines = input(defval = true, title = 'Show Divergence Lines')
showpivot = input(defval = false, title = 'Show Pivot Points')
calcmacd = input(defval = true, title = 'MACD')
calcmacda = input(defval = true, title = 'MACD Histogram')
calcrsi = input(defval = true, title = 'RSI')
calcstoc = input(defval = true, title = 'Stochastic')
calccci = input(defval = true, title = 'CCI')
calcmom = input(defval = true, title = 'Momentum')
calcobv = input(defval = true, title = 'OBV')
calcvwmacd = input(true, title = 'VWmacd')
calccmf = input(true, title = 'Chaikin Money Flow')
calcmfi = input(true, title = 'Money Flow Index')
calcext = input(false, title = 'Check External Indicator')
externalindi = input(defval = close, title = 'External Indicator')
pos_reg_div_col = input(defval = color.yellow, title = 'Positive Regular Divergence')
neg_reg_div_col = input(defval = color.navy, title = 'Negative Regular Divergence')
pos_hid_div_col = input(defval = color.lime, title = 'Positive Hidden Divergence')
neg_hid_div_col = input(defval = color.red, title = 'Negative Hidden Divergence')
pos_div_text_col = input(defval = color.black, title = 'Positive Divergence Text Color')
neg_div_text_col = input(defval = color.white, title = 'Negative Divergence Text Color')
reg_div_l_style_ = input.string(defval = 'Solid', title = 'Regular Divergence Line Style', options = ['Solid', 'Dashed', 'Dotted'])
hid_div_l_style_ = input.string(defval = 'Dashed', title = 'Hidden Divergence Line Style', options = ['Solid', 'Dashed', 'Dotted'])
reg_div_l_width = input.int(defval = 2, title = 'Regular Divergence Line Width', minval = 1, maxval = 5)
hid_div_l_width = input.int(defval = 1, title = 'Hidden Divergence Line Width', minval = 1, maxval = 5)
showmas = input.bool(defval = false, title = 'Show MAs 50 & 200', inline = 'ma12')
cma1col = input.color(defval = color.lime, title = '', inline = 'ma12')
cma2col = input.color(defval = color.red, title = '', inline = 'ma12')

// ===== SL/TP SETTINGS =====
show_sl_tp = input.bool(defval = true, title = 'Show SL/TP Lines')
show_signal_label = input.bool(defval = true, title = 'Show Signal Label (Entry/SL/TP)')
show_only_last_signal_lines = input.bool(defval = true, title = 'Show Only Last Signal Lines (Auto Clean)')
sl_tp_length = input.int(defval = 10, title = 'SL/TP Lines Length (candles)', minval = 5, maxval = 50)
atr_length = input.int(defval = 14, title = 'ATR Length for SL', minval = 1)
atr_multiplier = input.float(defval = 0.1, title = 'ATR Multiplier', minval = 0.1, maxval = 3.0, step = 0.1)

// ===== MAX SL SETTINGS =====
max_sl_pips = input.float(defval = 800.0, title = 'Max SL Distance (in points)', minval = 10, maxval = 800, step = 5)

// ===== CONFLUENCE FILTER =====
show_only_confluence = input.bool(defval = false, title = 'Show Only Confluence (Regular+Hidden Together)')

// ===== MOVING AVERAGES =====
plot(showmas ? ta.sma(close, 50) : na, color = showmas ? cma1col : na)
plot(showmas ? ta.sma(close, 200) : na, color = showmas ? cma2col : na)

// ===== LINE STYLES =====
var reg_div_l_style = reg_div_l_style_ == 'Solid' ? line.style_solid : reg_div_l_style_ == 'Dashed' ? line.style_dashed : line.style_dotted
var hid_div_l_style = hid_div_l_style_ == 'Solid' ? line.style_solid : hid_div_l_style_ == 'Dashed' ? line.style_dashed : line.style_dotted

// ===== INDICATORS CALCULATION =====
rsi = ta.rsi(close, 14)
[macd, signal, deltamacd] = ta.macd(close, 12, 26, 9)
moment = ta.mom(close, 10)
cci = ta.cci(close, 10)
Obv = ta.obv
stk = ta.sma(ta.stoch(close, high, low, 14), 3)
maFast = ta.vwma(close, 12)
maSlow = ta.vwma(close, 26)
vwmacd = maFast - maSlow
Cmfm = (close - low - (high - close)) / (high - low)
Cmfv = Cmfm * volume
cmf = ta.sma(Cmfv, 21) / ta.sma(volume, 21)
Mfi = ta.mfi(close, 14)

// ===== INDICATOR NAMES AND COLORS ARRAYS =====
var indicators_name = array.new_string(11)
var div_colors = array.new_color(4)
if barstate.isfirst
    array.set(indicators_name, 0, showindis == 'Full' ? 'MACD' : 'M')
    array.set(indicators_name, 1, showindis == 'Full' ? 'Hist' : 'H')
    array.set(indicators_name, 2, showindis == 'Full' ? 'RSI' : 'E')
    array.set(indicators_name, 3, showindis == 'Full' ? 'Stoch' : 'S')
    array.set(indicators_name, 4, showindis == 'Full' ? 'CCI' : 'C')
    array.set(indicators_name, 5, showindis == 'Full' ? 'MOM' : 'M')
    array.set(indicators_name, 6, showindis == 'Full' ? 'OBV' : 'O')
    array.set(indicators_name, 7, showindis == 'Full' ? 'VWMACD' : 'V')
    array.set(indicators_name, 8, showindis == 'Full' ? 'CMF' : 'C')
    array.set(indicators_name, 9, showindis == 'Full' ? 'MFI' : 'M')
    array.set(indicators_name, 10, showindis == 'Full' ? 'Extrn' : 'X')
    
    array.set(div_colors, 0, pos_reg_div_col)
    array.set(div_colors, 1, neg_reg_div_col)
    array.set(div_colors, 2, pos_hid_div_col)
    array.set(div_colors, 3, neg_hid_div_col)

// ===== PIVOT DETECTION =====
float ph = ta.pivothigh(source == 'Close' ? close : high, prd, prd)
float pl = ta.pivotlow(source == 'Close' ? close : low, prd, prd)
plotshape(bool(ph) and showpivot, text = 'H', style = shape.labeldown, color = color.new(color.white, 100), textcolor = color.new(color.red, 0), location = location.abovebar, offset = -prd)
plotshape(bool(pl) and showpivot, text = 'L', style = shape.labelup, color = color.new(color.white, 100), textcolor = color.new(color.lime, 0), location = location.belowbar, offset = -prd)

// ===== PIVOT ARRAYS =====
var int maxarraysize = 20
var ph_positions = array.new_int(maxarraysize, 0)
var pl_positions = array.new_int(maxarraysize, 0)
var ph_vals = array.new_float(maxarraysize, 0.)
var pl_vals = array.new_float(maxarraysize, 0.)

if bool(ph)
    array.unshift(ph_positions, bar_index)
    array.unshift(ph_vals, ph)
    if array.size(ph_positions) > maxarraysize
        array.pop(ph_positions)
        array.pop(ph_vals)

if bool(pl)
    array.unshift(pl_positions, bar_index)
    array.unshift(pl_vals, pl)
    if array.size(pl_positions) > maxarraysize
        array.pop(pl_positions)
        array.pop(pl_vals)

// ===== DIVERGENCE FUNCTIONS =====
positive_regular_positive_hidden_divergence(src, cond) =>
    divlen = 0
    prsc = source == 'Close' ? close : low
    if dontconfirm or src > src[1] or close > close[1]
        startpoint = dontconfirm ? 0 : 1
        for x = 0 to maxpp - 1 by 1
            len = bar_index - array.get(pl_positions, x) + prd
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
                if arrived
                    divlen := len
                    break
    divlen

negative_regular_negative_hidden_divergence(src, cond) =>
    divlen = 0
    prsc = source == 'Close' ? close : high
    if dontconfirm or src < src[1] or close < close[1]
        startpoint = dontconfirm ? 0 : 1
        for x = 0 to maxpp - 1 by 1
            len = bar_index - array.get(ph_positions, x) + prd
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
                if arrived
                    divlen := len
                    break
    divlen

// ===== CALCULATE DIVERGENCES =====
calculate_divs(cond, indicator_1) =>
    divs = array.new_int(4, 0)
    array.set(divs, 0, cond and (searchdiv == 'Regular' or searchdiv == 'Regular/Hidden') ? positive_regular_positive_hidden_divergence(indicator_1, 1) : 0)
    array.set(divs, 1, cond and (searchdiv == 'Regular' or searchdiv == 'Regular/Hidden') ? negative_regular_negative_hidden_divergence(indicator_1, 1) : 0)
    array.set(divs, 2, cond and (searchdiv == 'Hidden' or searchdiv == 'Regular/Hidden') ? positive_regular_positive_hidden_divergence(indicator_1, 2) : 0)
    array.set(divs, 3, cond and (searchdiv == 'Hidden' or searchdiv == 'Regular/Hidden') ? negative_regular_negative_hidden_divergence(indicator_1, 2) : 0)
    divs

// ===== ALL DIVERGENCES ARRAY =====
var all_divergences = array.new_int(44)
array_set_divs(div_pointer, index) =>
    for x = 0 to 3 by 1
        array.set(all_divergences, index * 4 + x, array.get(div_pointer, x))

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
array_set_divs(calculate_divs(calcext, externalindi), 10)

// ===== MINIMUM DIVERGENCE CHECK =====
total_div = 0
for x = 0 to array.size(all_divergences) - 1 by 1
    total_div := total_div + math.round(math.sign(array.get(all_divergences, x)))

if total_div < showlimit
    array.fill(all_divergences, 0)

// ===== LINE AND LABEL ARRAYS =====
var pos_div_lines = array.new_line(0)
var neg_div_lines = array.new_line(0)
var pos_div_labels = array.new_label(0)
var neg_div_labels = array.new_label(0)

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

// ===== ALERT VARIABLES =====
pos_reg_div_detected = false
neg_reg_div_detected = false
pos_hid_div_detected = false
neg_hid_div_detected = false

var last_pos_div_lines = 0
var last_neg_div_lines = 0
var remove_last_pos_divs = false
var remove_last_neg_divs = false

if bool(pl)
    remove_last_pos_divs := false
    last_pos_div_lines := 0
if bool(ph)
    remove_last_neg_divs := false
    last_neg_div_lines := 0

// ===== CONFLUENCE FILTER LOGIC =====
var bool has_reg_bull = false
var bool has_hid_bull = false
var bool has_reg_bear = false
var bool has_hid_bear = false

has_reg_bull := false
has_hid_bull := false
has_reg_bear := false
has_hid_bear := false

for x = 0 to 10 by 1
    if array.get(all_divergences, x * 4 + 0) > 0
        has_reg_bull := true
    if array.get(all_divergences, x * 4 + 2) > 0
        has_hid_bull := true
    if array.get(all_divergences, x * 4 + 1) > 0
        has_reg_bear := true
    if array.get(all_divergences, x * 4 + 3) > 0
        has_hid_bear := true

// ===== SIGNAL VARIABLES =====
var float entry_price = na
var float sl_price = na
var float tp1_price = na
var float tp2_price = na
var float risk = na
var int signal_bar = 0
var bool has_signal = false

// ===== LINE AND LABEL VARIABLES FOR AUTO CLEAN =====
var line entry_line = na
var line sl_line = na
var line tp1_line = na
var line tp2_line = na
var label signal_label = na
var label sl_txt_label = na
var label tp1_txt_label = na
var label tp2_txt_label = na

// ===== DRAW DIVERGENCES WITH SIGNAL INFO =====
divergence_text_top = ''
divergence_text_bottom = ''
distances = array.new_int(0)
dnumdiv_top = 0
dnumdiv_bottom = 0
top_label_col = color.white
bottom_label_col = color.white
old_pos_divs_can_be_removed = true
old_neg_divs_can_be_removed = true
startpoint = dontconfirm ? 0 : 1

has_signal := false
entry_price := na
sl_price := na
tp1_price := na
tp2_price := na
risk := na
signal_bar := 0

for x = 0 to 10 by 1
    div_type = -1
    for y = 0 to 3 by 1
        div_len = array.get(all_divergences, x * 4 + y)
        if div_len > 0
            should_draw = true
            if show_only_confluence
                if y == 0 or y == 2
                    should_draw := has_reg_bull and has_hid_bull
                else if y == 1 or y == 3
                    should_draw := has_reg_bear and has_hid_bear

            if should_draw
                div_type := y
                if y % 2 == 1
                    dnumdiv_top := dnumdiv_top + 1
                    top_label_col := array.get(div_colors, y)
                if y % 2 == 0
                    dnumdiv_bottom := dnumdiv_bottom + 1
                    bottom_label_col := array.get(div_colors, y)
                    
                if not array.includes(distances, div_len)
                    array.push(distances, div_len)
                    
                    new_line = showlines ? line.new(
                        x1 = bar_index - div_len, 
                        y1 = source == 'Close' ? close[div_len] : y % 2 == 0 ? low[div_len] : high[div_len], 
                        x2 = bar_index - startpoint, 
                        y2 = source == 'Close' ? close[startpoint] : y % 2 == 0 ? low[startpoint] : high[startpoint], 
                        color = array.get(div_colors, y), 
                        style = y < 2 ? reg_div_l_style : hid_div_l_style, 
                        width = y < 2 ? reg_div_l_width : hid_div_l_width
                    ) : na
                    
                    if y % 2 == 0
                        if old_pos_divs_can_be_removed
                            old_pos_divs_can_be_removed := false
                            if not showlast and remove_last_pos_divs
                                delete_last_pos_div_lines_label(last_pos_div_lines)
                                last_pos_div_lines := 0
                            if showlast
                                delete_old_pos_div_lines()
                        array.push(pos_div_lines, new_line)
                        last_pos_div_lines := last_pos_div_lines + 1
                        remove_last_pos_divs := true
                    else
                        if old_neg_divs_can_be_removed
                            old_neg_divs_can_be_removed := false
                            if not showlast and remove_last_neg_divs
                                delete_last_neg_div_lines_label(last_neg_div_lines)
                                last_neg_div_lines := 0
                            if showlast
                                delete_old_neg_div_lines()
                        array.push(neg_div_lines, new_line)
                        last_neg_div_lines := last_neg_div_lines + 1
                        remove_last_neg_divs := true

                    // ===== CALCULATE SIGNAL VALUES =====
                    if not has_signal
                        has_signal := true
                        signal_bar := bar_index
                        
                        entry_price := close
                        
                        float raw_sl_price = na
                        float sl_distance = 0.0
                        
                        if y == 0 or y == 2
                            raw_sl_price := math.min(low[div_len], low) - (ta.atr(atr_length) * atr_multiplier)
                            sl_distance := entry_price - raw_sl_price
                        else if y == 1 or y == 3
                            raw_sl_price := math.max(high[div_len], high) + (ta.atr(atr_length) * atr_multiplier)
                            sl_distance := raw_sl_price - entry_price
                        
                        float pip_value = syminfo.mintick * 10
                        float max_sl_price_distance = max_sl_pips * pip_value
                        
                        if sl_distance > max_sl_price_distance
                            if y == 0 or y == 2
                                sl_price := entry_price - max_sl_price_distance
                            else if y == 1 or y == 3
                                sl_price := entry_price + max_sl_price_distance
                        else
                            sl_price := raw_sl_price
                        
                        risk := math.abs(entry_price - sl_price)
                        
                        if y == 0 or y == 2
                            tp1_price := entry_price + risk
                            tp2_price := entry_price + (2 * risk)
                        else if y == 1 or y == 3
                            tp1_price := entry_price - risk
                            tp2_price := entry_price - (2 * risk)

                if y == 0
                    pos_reg_div_detected := true
                if y == 1
                    neg_reg_div_detected := true
                if y == 2
                    pos_hid_div_detected := true
                if y == 3
                    neg_hid_div_detected := true
                    
    if div_type >= 0
        divergence_text_top := divergence_text_top + (div_type % 2 == 1 and showindis != 'Don\'t Show' ? array.get(indicators_name, x) + '\n' : '')
        divergence_text_bottom := divergence_text_bottom + (div_type % 2 == 0 and showindis != 'Don\'t Show' ? array.get(indicators_name, x) + '\n' : '')

// ===== DRAW DIVERGENCE LABELS =====
if showindis != 'Don\'t Show' or shownum
    if shownum and dnumdiv_top > 0
        divergence_text_top := divergence_text_top + str.tostring(dnumdiv_top)
    if shownum and dnumdiv_bottom > 0
        divergence_text_bottom := divergence_text_bottom + str.tostring(dnumdiv_bottom)
        
    if divergence_text_top != ''
        if showlast
            delete_old_neg_div_labels()
        array.push(neg_div_labels, label.new(x = bar_index, y = math.max(high, high[1]), text = divergence_text_top, color = top_label_col, textcolor = neg_div_text_col, style = label.style_label_down))

    if divergence_text_bottom != ''
        if showlast
            delete_old_pos_div_labels()
        array.push(pos_div_labels, label.new(x = bar_index, y = math.min(low, low[1]), text = divergence_text_bottom, color = bottom_label_col, textcolor = pos_div_text_col, style = label.style_label_up))

// ===== DRAW SIGNAL LINES WITH PIP TEXT =====
if has_signal and show_sl_tp
    if show_only_last_signal_lines
        if not na(entry_line)
            line.delete(entry_line)
        if not na(sl_line)
            line.delete(sl_line)
        if not na(tp1_line)
            line.delete(tp1_line)
        if not na(tp2_line)
            line.delete(tp2_line)
        if not na(signal_label)
            label.delete(signal_label)
        if not na(sl_txt_label)
            label.delete(sl_txt_label)
        if not na(tp1_txt_label)
            label.delete(tp1_txt_label)
        if not na(tp2_txt_label)
            label.delete(tp2_txt_label)
    
    // ✅ FIX: Divide by 10 to correct the pip calculation
    float pip_value = syminfo.mintick * 10
    string sl_pips_txt = str.tostring(math.round((risk / pip_value) / 10))
    string tp1_pips_txt = str.tostring(math.round((risk / pip_value) / 10))
    string tp2_pips_txt = str.tostring(math.round(((2 * risk) / pip_value) / 10))
    
    entry_line := line.new(x1 = signal_bar, y1 = entry_price, x2 = signal_bar + sl_tp_length, y2 = entry_price, color = color.blue, width = 2, style = line.style_dashed)
    
    sl_line := line.new(x1 = signal_bar, y1 = sl_price, x2 = signal_bar + sl_tp_length, y2 = sl_price, color = color.red, width = 2, style = line.style_dashed)
    
    tp1_line := line.new(x1 = signal_bar, y1 = tp1_price, x2 = signal_bar + sl_tp_length, y2 = tp1_price, color = color.green, width = 2, style = line.style_dashed)
    
    tp2_line := line.new(x1 = signal_bar, y1 = tp2_price, x2 = signal_bar + sl_tp_length, y2 = tp2_price, color = color.lime, width = 2, style = line.style_dashed)
    
    sl_txt_label := label.new(x = signal_bar + sl_tp_length, y = sl_price, text = sl_pips_txt + " pips", color = color.new(color.red, 100), textcolor = color.red, style = label.style_label_left, size = size.small, xloc = xloc.bar_index)
    
    tp1_txt_label := label.new(x = signal_bar + sl_tp_length, y = tp1_price, text = tp1_pips_txt + " pips", color = color.new(color.green, 100), textcolor = color.green, style = label.style_label_left, size = size.small, xloc = xloc.bar_index)
    
    tp2_txt_label := label.new(x = signal_bar + sl_tp_length, y = tp2_price, text = tp2_pips_txt + " pips", color = color.new(color.lime, 100), textcolor = color.lime, style = label.style_label_left, size = size.small, xloc = xloc.bar_index)
    
    if show_signal_label
        signal_label := label.new(
            x = signal_bar,
            y = entry_price,
            text = "Entry: " + str.tostring(entry_price, "#.##") + 
                   "\nSL: " + str.tostring(sl_price, "#.##") + 
                   "\nTP1: " + str.tostring(tp1_price, "#.##") + 
                   "\nTP2: " + str.tostring(tp2_price, "#.##"),
            color = color.new(color.black, 80),
            textcolor = color.white,
            style = label.style_label_left,
            size = size.small,
            xloc = xloc.bar_index
        )

// ===== ALERTS =====
alertcondition(pos_reg_div_detected, title = 'Positive Regular Divergence Detected', message = 'Positive Regular Divergence Detected')
alertcondition(neg_reg_div_detected, title = 'Negative Regular Divergence Detected', message = 'Negative Regular Divergence Detected')
alertcondition(pos_hid_div_detected, title = 'Positive Hidden Divergence Detected', message = 'Positive Hidden Divergence Detected')
alertcondition(neg_hid_div_detected, title = 'Negative Hidden Divergence Detected', message = 'Negative Hidden Divergence Detected')

alertcondition(pos_reg_div_detected or pos_hid_div_detected, title = 'Positive Divergence Detected', message = 'Positive Divergence Detected')
alertcondition(neg_reg_div_detected or neg_hid_div_detected, title = 'Negative Divergence Detected', message = 'Negative Divergence Detected')
````
