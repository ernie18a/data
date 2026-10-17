# Smart RSI Crossover

- url: https://www.tradingview.com/script/LXlVzdLf-Smart-RSI-Crossover/
- type: indicator
- pine_id: PUB;fefc3f9e74c845e0bf8dd23e998df1ba
- version: 1.0

## Description

█ OVERVIEW
Smart RSI Crossover is an indicator designed for traders who use RSI crossovers with its moving average as momentum change signals. Instead of generating a signal immediately after the crossover, the indicator requires additional confirmation in the form of a price breakout from a box created at the moment the RSI signal occurs. This eliminates a large portion of false signals that appear during consolidations and chaotic market movements.

An additional filter is the RSI position relative to the 50 level. Bullish signals can only be generated when RSI is above the 50 level, while bearish signals can only be generated when RSI is below the 50 level. This allows signals to better align with the dominant market momentum.

The script also includes candle coloring, multi-layer trend visualization in the form of RSI Regime Fog, automatic Take Profit / Stop Loss levels, and a table displaying current RSI and RSI MA values.

█ CONCEPTS
Classic RSI crossovers with its moving average often appear too early and generate many false signals, especially during sideways price action. Smart RSI Crossover solves this problem by adding a breakout confirmation mechanism.

For a crossover to be considered valid:
• Bullish signal requires:
- RSI above the 50 level
- RSI rising compared to the previous candle
• Bearish signal requires:
- RSI below the 50 level
- RSI falling compared to the previous candle

Once these conditions are met, a signal box is created:
• A green box is drawn for bullish signals
• A red box is drawn for bearish signals

The default height of the box corresponds to the signal candle’s range (High–Low). It can optionally be extended by a multiple of the average candle size.
A BUY signal is generated only when price closes above the upper boundary of the bullish box.
A SELL signal is generated only when price closes below the lower boundary of the bearish box.
If price invalidates the box structure before a breakout occurs, or if the box remains active for too long, it is automatically removed without generating a signal.
This approach filters out many weak RSI crossovers and focuses only on situations where momentum has been confirmed by actual price movement.

█ FEATURES
RSI Settings
• Fully customizable RSI (default length: 14)
• Selectable data source for RSI calculation
• Choice of moving average type for RSI
• Adjustable RSI moving average length

Signal Settings
• BUY is generated only after price closes above the upper boundary of the bullish box
• SELL is generated only after price closes below the lower boundary of the bearish box
• Two signal visualization styles:
- Triangles
- BUY / SELL labels

Breakout Boxes
• A box is created at every valid RSI crossover that meets the filter conditions
• Default box height = signal candle range (High–Low)
• Optional extension: average candle size × Box Extension Multiplier
• Box color depends on signal direction
• Box remains active until:
- Price breaks out
- Box structure is invalidated
- Maximum box age is exceeded
• Adjustable border width and fill transparency
• Configurable maximum number of candles the box can stay active

RSI Regime Filter
• BUY signals can only occur when RSI > 50
• SELL signals can only occur when RSI < 50
• RSI must move in the direction of the signal:
- Rising for BUY
- Falling for SELL
• Additional filtering that reduces signals during consolidations and neutral market conditions

Candle Coloring
• Automatic candle coloring based on the current relationship between RSI and its moving average
• Bullish color when: RSI ≥ RSI MA
• Bearish color when: RSI < RSI MA
• Option to completely disable candle coloring

RSI Regime Fog
This is a visual representation of the current market regime based on the position of RSI relative to its moving average.
• Height of each layer = average candle size × Fog Height Multiplier
• Gradually increasing transparency to create a depth effect
• Immediate visual identification of dominant momentum

RSI Information Table
Real-time table displaying:
• Current RSI value
• Current RSI MA value
• Direction of change for both indicators

Take Profit / Stop Loss
After every confirmed BUY or SELL signal, the indicator automatically plots position management levels.

Stop Loss:
• ATR × Multiplier, or
• Fixed percentage from entry price

Take Profit:
• TP1 based on RR 1
• TP2 based on RR 2
• TP3 based on RR 3
• All risk-reward ratios are fully adjustable
• Individual TP and SL levels can be enabled/disabled independently

Built-in alerts:
• BUY Alert
• SELL Alert

█ APPLICATIONS
Smart RSI Crossover is primarily a signal indicator used to identify potential trading opportunities after confirmed breakouts driven by RSI momentum.

It performs best when combined with other technical analysis tools that help assess signal quality and increase the probability of successful trades.

Before entering a position, it is recommended to check:
• Whether price is not sitting directly below a major resistance (for BUY) or above a major support (for SELL)
• Whether the signal direction aligns with the dominant trend on a higher timeframe (HTF)
• Whether significant supply/demand zones are nearby
• Whether market structure supports the trade direction
• Whether the potential risk-to-reward ratio is attractive

█ NOTES
• Signals appear only after a box breakout, therefore several candles may pass after the actual RSI crossover.
• The 50 level acts as an additional momentum filter, ensuring that bullish and bearish signals are generated only in appropriate market conditions.
• RSI Regime Fog is a purely visual element and does not affect signal generation logic.
• TP1–TP3 and SL levels are auxiliary and serve as visual references only. Traders can freely apply their own position management rules, partial profit taking, trailing stops, or any other risk management methods.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter
//@version=6
indicator('Smart RSI Crossover', overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// RSI SETTINGS
lenRSI = input.int(14, 'RSI Length', group='RSI SETTINGS', tooltip='Calculation period for the Relative Strength Index (RSI) indicator')
lenMA = input.int(9, 'RSI MA Length', group='RSI SETTINGS', tooltip='Period of the moving average used to smooth RSI values')
maType = input.string('SMA', 'RSI MA Type', options=['SMA', 'EMA'], group='RSI SETTINGS', tooltip='Type of moving average used for RSI calculations (SMA – Simple, EMA – Exponential)')
src = input.source(close, 'Source', group='RSI SETTINGS', tooltip='Price data source used for RSI calculation')

// SIGNAL & BOX SETTINGS
signal_type = input.string('Labels (BUY/SELL)', 'Signal Type', options=['Triangles', 'Labels (BUY/SELL)'], group='SIGNAL SETTINGS', tooltip='How trade signals are displayed on the chart')
use_box_extension = input.bool(false, 'Extend box by average candle range', group='SIGNAL SETTINGS', tooltip='Whether to extend signal box height by a multiple of the average candle range')
box_extension_mult = input.float(0.5, 'Box Extension Multiplier', minval=0.1, step=0.1, group='SIGNAL SETTINGS', tooltip='Multiplier of average candle range used when extending the box')

// VISUAL SETTINGS
color_candles = input.bool(true, 'Color candles based on RSI regime', group='VISUAL SETTINGS', tooltip='Automatically color candle bodies depending on current RSI position relative to its moving average')
box_border_width = input.int(1, 'Box border width', minval=1, maxval=5, group='VISUAL SETTINGS', tooltip='Thickness of signal box borders')
box_bg_transp = input.int(85, 'Box fill transparency', minval=0, maxval=100, group='VISUAL SETTINGS', tooltip='Transparency level of signal box background (0 = opaque, 100 = fully transparent)')
box_max_age = input.int(50, 'Max box age (bars)', minval=5, group='VISUAL SETTINGS', tooltip='Maximum number of bars after which a signal box is removed from the chart')


// RSI REGIME FOG
show_fog = input.bool(true, 'Show RSI Regime Fog', group='RSI REGIME FOG', tooltip='Display gradient fog zone indicating current market regime based on RSI position relative to MA')
offset_mult = input.float(0.7, 'Fog Height × Average Candle', minval=0.2, step=0.1, group='RSI REGIME FOG', tooltip='Multiplier of average candle range that determines fog layer height')
base_transp = input.int(80, 'Base Fog Transparency', minval=0, maxval=100, group='RSI REGIME FOG', tooltip='Initial transparency level of fog fill')
transp_inc = input.int(4, 'Fog Transparency Increment', minval=0, group='RSI REGIME FOG', tooltip='Transparency increase for each subsequent fog layer')
col_up = input.color(color.new(#24a3ac, 0), 'Bull Color (Fog)', group='RSI REGIME FOG', tooltip='Color of bullish zone (RSI above MA)')
col_dn = input.color(color.new(#FF5252, 0), 'Bear Color (Fog)', group='RSI REGIME FOG', tooltip='Color of bearish zone (RSI below MA)')

// RSI TABLE
tablePosition = input.string('Top Right', 'Table Position',
     options=['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right', 'Top Center', 'Bottom Center', 'Middle Left', 'Middle Right'],
     group='RSI TABLE', tooltip='Position of the RSI information table on the chart')
tableTextSize = input.string('Small', 'Table text size',
     options=['Tiny', 'Small', 'Normal', 'Large'],
     group='RSI TABLE', tooltip='Font size used in the RSI information table')

// TP/SL LEVELS
showTPSL = input.bool(true, 'Show TP/SL Levels', group='TP/SL LEVELS', tooltip='Enable display of Take Profit and Stop Loss levels after entry signal')
use_atr_sl = input.bool(true, 'SL = ATR × instead of %', group='TP/SL LEVELS',
     tooltip='When enabled, Stop Loss is calculated as ATR multiplied by a multiplier. When disabled, a fixed percentage from entry price is used.')
tp_atr_period = input.int(14, 'ATR Period for TP/SL', group='TP/SL LEVELS', minval=1, tooltip='Period of Average True Range (ATR) indicator used to calculate TP/SL levels')
sl_atr_mult = input.float(1.5, 'ATR Multiplier for SL', group='TP/SL LEVELS', step=0.1, tooltip='ATR multiplier that determines Stop Loss distance from entry price')
sl_percent = input.float(1.0, 'SL % from Entry', group='TP/SL LEVELS', step=0.1, tooltip='Percentage distance of Stop Loss from entry price when using percentage method')
rr_tp1 = input.float(1.0, 'RR for TP1', group='TP/SL LEVELS', step=0.1, tooltip='Risk-Reward ratio for the first Take Profit level')
rr_tp2 = input.float(2.0, 'RR for TP2', group='TP/SL LEVELS', step=0.1, tooltip='Risk-Reward ratio for the second Take Profit level')
rr_tp3 = input.float(3.0, 'RR for TP3', group='TP/SL LEVELS', step=0.1, tooltip='Risk-Reward ratio for the third Take Profit level')

// TP/SL LEVELS DISPLAY
show_sl_level = input.bool(true, 'Show SL Level', group='TP/SL LEVELS DISPLAY', tooltip='Display line and label for Stop Loss level')
show_tp1_level = input.bool(true, 'Show TP1 Level', group='TP/SL LEVELS DISPLAY', tooltip='Display line and label for first Take Profit level')
show_tp2_level = input.bool(true, 'Show TP2 Level', group='TP/SL LEVELS DISPLAY', tooltip='Display line and label for second Take Profit level')
show_tp3_level = input.bool(true, 'Show TP3 Level', group='TP/SL LEVELS DISPLAY', tooltip='Display line and label for third Take Profit level')

// TABLE SETTINGS CONVERSION
finalTablePos =
     tablePosition == 'Top Left' ? position.top_left :
     tablePosition == 'Top Right' ? position.top_right :
     tablePosition == 'Bottom Left' ? position.bottom_left :
     tablePosition == 'Bottom Right' ? position.bottom_right :
     tablePosition == 'Top Center' ? position.top_center :
     tablePosition == 'Bottom Center' ? position.bottom_center :
     tablePosition == 'Middle Left' ? position.middle_left :
     tablePosition == 'Middle Right' ? position.middle_right : position.top_right

tableSize =
     tableTextSize == 'Tiny' ? size.tiny :
     tableTextSize == 'Small' ? size.small :
     tableTextSize == 'Large' ? size.large : size.normal

// RSI CALCULATIONS
rsiValue = ta.rsi(src, lenRSI)
maRSI = maType == "SMA" ? ta.sma(rsiValue, lenMA) : ta.ema(rsiValue, lenMA)

bull_cross = ta.crossover(rsiValue, maRSI) and rsiValue > 50 and rsiValue > rsiValue[1]
bear_cross = ta.crossunder(rsiValue, maRSI) and rsiValue < 50 and rsiValue < rsiValue[1]

// Candle coloring
barcolor(color_candles ? (rsiValue >= maRSI ? col_up : col_dn) : na)

// RSI REGIME FOG
avg_candle_size = ta.sma(math.abs(close - open), 50)
offset = avg_candle_size * offset_mult
bullRegime = rsiValue >= maRSI

pu0 = plot(show_fog and bullRegime ? hl2 : na, color=color.new(col_up,100), display=display.none)
pu1 = plot(show_fog and bullRegime ? hl2 - offset : na, color=color.new(col_up,100), display=display.none)
pu2 = plot(show_fog and bullRegime ? hl2 - 2*offset : na, color=color.new(col_up,100), display=display.none)
pu3 = plot(show_fog and bullRegime ? hl2 - 3*offset : na, color=color.new(col_up,100), display=display.none)
pu4 = plot(show_fog and bullRegime ? hl2 - 4*offset : na, color=color.new(col_up,100), display=display.none)
pu5 = plot(show_fog and bullRegime ? hl2 - 5*offset : na, color=color.new(col_up,100), display=display.none)
pu6 = plot(show_fog and bullRegime ? hl2 - 6*offset : na, color=color.new(col_up,100), display=display.none)

pd0 = plot(show_fog and not bullRegime ? hl2 : na, color=color.new(col_dn,100), display=display.none)
pd1 = plot(show_fog and not bullRegime ? hl2 + offset : na, color=color.new(col_dn,100), display=display.none)
pd2 = plot(show_fog and not bullRegime ? hl2 + 2*offset : na, color=color.new(col_dn,100), display=display.none)
pd3 = plot(show_fog and not bullRegime ? hl2 + 3*offset : na, color=color.new(col_dn,100), display=display.none)
pd4 = plot(show_fog and not bullRegime ? hl2 + 4*offset : na, color=color.new(col_dn,100), display=display.none)
pd5 = plot(show_fog and not bullRegime ? hl2 + 5*offset : na, color=color.new(col_dn,100), display=display.none)
pd6 = plot(show_fog and not bullRegime ? hl2 + 6*offset : na, color=color.new(col_dn,100), display=display.none)

fill(pu0, pu1, color.new(col_up, base_transp))
fill(pu1, pu2, color.new(col_up, base_transp + transp_inc))
fill(pu2, pu3, color.new(col_up, base_transp + 2*transp_inc))
fill(pu3, pu4, color.new(col_up, base_transp + 3*transp_inc))
fill(pu4, pu5, color.new(col_up, base_transp + 4*transp_inc))
fill(pu5, pu6, color.new(col_up, base_transp + 5*transp_inc))

fill(pd0, pd1, color.new(col_dn, base_transp))
fill(pd1, pd2, color.new(col_dn, base_transp + transp_inc))
fill(pd2, pd3, color.new(col_dn, base_transp + 2*transp_inc))
fill(pd3, pd4, color.new(col_dn, base_transp + 3*transp_inc))
fill(pd4, pd5, color.new(col_dn, base_transp + 4*transp_inc))
fill(pd5, pd6, color.new(col_dn, base_transp + 5*transp_inc))

// SIGNAL BOXES
var array<box> boxes = array.new<box>()
var array<int> dirs = array.new<int>()

if bull_cross
    float sig_high = high
    float sig_low = low
    float top = use_box_extension ? sig_high + avg_candle_size * box_extension_mult : sig_high
    float bot = use_box_extension ? sig_low - avg_candle_size * box_extension_mult : sig_low
    box b = box.new(bar_index, top, bar_index + 2, bot,
         bgcolor = color.new(col_up, box_bg_transp),
         border_color = col_up,
         border_width = box_border_width,
         extend = extend.right)
    array.push(boxes, b)
    array.push(dirs, 1)

if bear_cross
    float sig_high = high
    float sig_low = low
    float top = use_box_extension ? sig_high + avg_candle_size * box_extension_mult : sig_high
    float bot = use_box_extension ? sig_low - avg_candle_size * box_extension_mult : sig_low
    box b = box.new(bar_index, top, bar_index + 2, bot,
         bgcolor = color.new(col_dn, box_bg_transp),
         border_color = col_dn,
         border_width = box_border_width,
         extend = extend.right)
    array.push(boxes, b)
    array.push(dirs, -1)

// BOX CONFIRMATION AND INVALIDATION
var bool bull_event = false
var bool bear_event = false
bull_event := false
bear_event := false

if array.size(boxes) > 0
    for i = array.size(boxes) - 1 to 0
        box b = array.get(boxes, i)
        int dir = array.get(dirs, i)
        float top = box.get_top(b)
        float bot = box.get_bottom(b)
        int age = bar_index - box.get_left(b)
        if dir == 1
            if close > top
                box.set_extend(b, extend.none)
                box.set_right(b, bar_index)
                bull_event := true
                array.remove(boxes, i)
                array.remove(dirs, i)
            else if close < bot or age >= box_max_age
                box.delete(b)
                array.remove(boxes, i)
                array.remove(dirs, i)
        else if dir == -1
            if close < bot
                box.set_extend(b, extend.none)
                box.set_right(b, bar_index)
                bear_event := true
                array.remove(boxes, i)
                array.remove(dirs, i)
            else if close > top or age >= box_max_age
                box.delete(b)
                array.remove(boxes, i)
                array.remove(dirs, i)

// TRADE SIGNALS
plotshape(bull_event and signal_type == 'Triangles', location=location.belowbar, color=col_up, style=shape.triangleup, size=size.tiny)
plotshape(bear_event and signal_type == 'Triangles', location=location.abovebar, color=col_dn, style=shape.triangledown, size=size.tiny)

if bull_event and signal_type == 'Labels (BUY/SELL)'
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.new(col_up, 40), textcolor=color.white, yloc=yloc.belowbar, size=size.small)

if bear_event and signal_type == 'Labels (BUY/SELL)'
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.new(col_dn, 40), textcolor=color.white, yloc=yloc.abovebar, size=size.small)

// TP/SL LEVELS
atr_val = ta.atr(tp_atr_period)

var int tpsl_dir = 0
var line tpsl_entry_ln = na
var label tpsl_entry_lb = na
var line tpsl_sl_ln = na
var label tpsl_sl_lb = na
var line tpsl_tp1_ln = na
var label tpsl_tp1_lb = na
var line tpsl_tp2_ln = na
var label tpsl_tp2_lb = na
var line tpsl_tp3_ln = na
var label tpsl_tp3_lb = na
var line tpsl_ext_ln = na
var linefill tpsl_risk_fill = na
var linefill tpsl_reward_fill = na
var int tpsl_entry_bar = na
var float tpsl_sl_price = na
var float tpsl_extreme = na

bool tpsl_trigger_buy = bull_event
bool tpsl_trigger_sell = bear_event

if showTPSL and (tpsl_trigger_buy or tpsl_trigger_sell)
    line.delete(tpsl_entry_ln)
    label.delete(tpsl_entry_lb)
    line.delete(tpsl_sl_ln)
    label.delete(tpsl_sl_lb)
    line.delete(tpsl_tp1_ln)
    label.delete(tpsl_tp1_lb)
    line.delete(tpsl_tp2_ln)
    label.delete(tpsl_tp2_lb)
    line.delete(tpsl_tp3_ln)
    label.delete(tpsl_tp3_lb)
    line.delete(tpsl_ext_ln)
    linefill.delete(tpsl_risk_fill)
    linefill.delete(tpsl_reward_fill)

    bool is_buy_trade = not tpsl_trigger_sell
    tpsl_dir := is_buy_trade ? 1 : -1
    tpsl_entry_bar := bar_index
    float entry_p = close
    float risk_dist = use_atr_sl ? atr_val * sl_atr_mult : entry_p * (sl_percent / 100.0)
    color entry_col = is_buy_trade ? col_up : col_dn
    color sl_col = color.new(col_dn, 40)
    color tp_col = color.new(col_up, 40)
    color risk_fill_c = color.new(col_dn, 70)
    color reward_fill_c = color.new(col_up, 70)

    float sl_p = is_buy_trade ? entry_p - risk_dist : entry_p + risk_dist
    float tp1_p = is_buy_trade ? entry_p + risk_dist * rr_tp1 : entry_p - risk_dist * rr_tp1
    float tp2_p = is_buy_trade ? entry_p + risk_dist * rr_tp2 : entry_p - risk_dist * rr_tp2
    float tp3_p = is_buy_trade ? entry_p + risk_dist * rr_tp3 : entry_p - risk_dist * rr_tp3

    tpsl_sl_price := sl_p
    tpsl_extreme := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na

    tpsl_entry_ln := line.new(bar_index, entry_p, bar_index + 1, entry_p,
         color = entry_col, width = 2, extend = extend.none)
    tpsl_entry_lb := label.new(bar_index, entry_p,
         (is_buy_trade ? 'BUY ' : 'SELL ') + str.tostring(entry_p, format.mintick),
         style = label.style_label_left, color = entry_col,
         textcolor = color.white, size = size.small)

    if show_sl_level
        tpsl_sl_ln := line.new(bar_index, sl_p, bar_index + 1, sl_p,
             color = sl_col, width = 1, style = line.style_dashed, extend = extend.none)
        tpsl_sl_lb := label.new(bar_index, sl_p,
             'SL ' + str.tostring(sl_p, format.mintick),
             style = label.style_label_left, color = sl_col,
             textcolor = color.white, size = size.small)

    if show_tp1_level
        tpsl_tp1_ln := line.new(bar_index, tp1_p, bar_index + 1, tp1_p,
             color = tp_col, width = 1, extend = extend.none)
        tpsl_tp1_lb := label.new(bar_index, tp1_p,
             'TP1 ' + str.tostring(tp1_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_tp2_level
        tpsl_tp2_ln := line.new(bar_index, tp2_p, bar_index + 1, tp2_p,
             color = tp_col, width = 1, extend = extend.none)
        tpsl_tp2_lb := label.new(bar_index, tp2_p,
             'TP2 ' + str.tostring(tp2_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_tp3_level
        tpsl_tp3_ln := line.new(bar_index, tp3_p, bar_index + 1, tp3_p,
             color = tp_col, width = 1, style = line.style_dotted, extend = extend.none)
        tpsl_tp3_lb := label.new(bar_index, tp3_p,
             'TP3 ' + str.tostring(tp3_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_sl_level
        tpsl_risk_fill := linefill.new(tpsl_entry_ln, tpsl_sl_ln, risk_fill_c)

    float fill_extreme = entry_p
    if is_buy_trade
        if show_tp1_level
            fill_extreme := math.max(fill_extreme, tp1_p)
        if show_tp2_level
            fill_extreme := math.max(fill_extreme, tp2_p)
        if show_tp3_level
            fill_extreme := math.max(fill_extreme, tp3_p)
        if fill_extreme > entry_p
            tpsl_ext_ln := line.new(bar_index, fill_extreme, bar_index + 1, fill_extreme, color=na, extend=extend.none)
            tpsl_reward_fill := linefill.new(tpsl_entry_ln, tpsl_ext_ln, reward_fill_c)
    else
        if show_tp1_level
            fill_extreme := math.min(fill_extreme, tp1_p)
        if show_tp2_level
            fill_extreme := math.min(fill_extreme, tp2_p)
        if show_tp3_level
            fill_extreme := math.min(fill_extreme, tp3_p)
        if fill_extreme < entry_p
            tpsl_ext_ln := line.new(bar_index, fill_extreme, bar_index + 1, fill_extreme, color=na, extend=extend.none)
            tpsl_reward_fill := linefill.new(tpsl_entry_ln, tpsl_ext_ln, reward_fill_c)

// UPDATE LINE AND LABEL POSITIONS
if tpsl_dir != 0
    if not na(tpsl_entry_lb)
        label.set_x(tpsl_entry_lb, bar_index)
    if not na(tpsl_sl_lb)
        label.set_x(tpsl_sl_lb, bar_index)
    if not na(tpsl_tp1_lb)
        label.set_x(tpsl_tp1_lb, bar_index)
    if not na(tpsl_tp2_lb)
        label.set_x(tpsl_tp2_lb, bar_index)
    if not na(tpsl_tp3_lb)
        label.set_x(tpsl_tp3_lb, bar_index)

    if not na(tpsl_entry_ln)
        line.set_x2(tpsl_entry_ln, bar_index + 1)
    if not na(tpsl_sl_ln)
        line.set_x2(tpsl_sl_ln, bar_index + 1)
    if not na(tpsl_tp1_ln)
        line.set_x2(tpsl_tp1_ln, bar_index + 1)
    if not na(tpsl_tp2_ln)
        line.set_x2(tpsl_tp2_ln, bar_index + 1)
    if not na(tpsl_tp3_ln)
        line.set_x2(tpsl_tp3_ln, bar_index + 1)
    if not na(tpsl_ext_ln)
        line.set_x2(tpsl_ext_ln, bar_index + 1)

    bool sl_hit = tpsl_dir == 1 ? low <= tpsl_sl_price : high >= tpsl_sl_price
    bool tp_hit = not na(tpsl_extreme) and
         (tpsl_dir == 1 ? high >= tpsl_extreme : low <= tpsl_extreme)

    if bar_index > tpsl_entry_bar and (sl_hit or tp_hit)
        if not na(tpsl_entry_ln)
            line.set_x2(tpsl_entry_ln, bar_index)
        if not na(tpsl_sl_ln)
            line.set_x2(tpsl_sl_ln, bar_index)
        if not na(tpsl_tp1_ln)
            line.set_x2(tpsl_tp1_ln, bar_index)
        if not na(tpsl_tp2_ln)
            line.set_x2(tpsl_tp2_ln, bar_index)
        if not na(tpsl_tp3_ln)
            line.set_x2(tpsl_tp3_ln, bar_index)
        if not na(tpsl_ext_ln)
            line.set_x2(tpsl_ext_ln, bar_index)
        tpsl_dir := 0

// RSI INFORMATION TABLE
var table rsiTable = na
if barstate.islast
    if not na(rsiTable)
        table.delete(rsiTable)
        rsiTable := na

    rsiTable := table.new(finalTablePos, 3, 3,
         frame_color = color.gray, frame_width = 1, border_width = 1)

    string rsiArrow = rsiValue > rsiValue[1] ? "▲" : "▼"
    string maArrow = maRSI > maRSI[1] ? "▲" : "▼"
    color rsiArrowCol = rsiValue > rsiValue[1] ? col_up : col_dn
    color maArrowCol = maRSI > maRSI[1] ? col_up : col_dn

    // Headers
    table.cell(rsiTable, 0, 0, "Indicator", text_color=color.white, bgcolor=color.gray, text_size=tableSize)
    table.cell(rsiTable, 1, 0, "Value", text_color=color.white, bgcolor=color.gray, text_size=tableSize)
    table.cell(rsiTable, 2, 0, "Direction", text_color=color.white, bgcolor=color.gray, text_size=tableSize)

    // RSI
    table.cell(rsiTable, 0, 1, "RSI(" + str.tostring(lenRSI) + ")",
         text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=tableSize)
    table.cell(rsiTable, 1, 1, str.tostring(rsiValue, "#.##"),
         text_color=rsiValue >= 50 ? col_up : col_dn,
         bgcolor=color.new(color.gray, 80), text_size=tableSize)
    table.cell(rsiTable, 2, 1, rsiArrow,
         text_color=rsiArrowCol, bgcolor=color.new(color.gray, 80), text_size=tableSize)

    // RSI MA
    table.cell(rsiTable, 0, 2, maType + "(" + str.tostring(lenMA) + ")",
         text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=tableSize)
    table.cell(rsiTable, 1, 2, str.tostring(maRSI, "#.##"),
         text_color=maRSI >= 50 ? col_up : col_dn,
         bgcolor=color.new(color.gray, 80), text_size=tableSize)
    table.cell(rsiTable, 2, 2, maArrow,
         text_color=maArrowCol, bgcolor=color.new(color.gray, 80), text_size=tableSize)

// ALERTS
alertcondition(bull_event, title='BUY Alert', message='Smart RSI Crossover: BUY - confirmed by upward breakout')
alertcondition(bear_event, title='SELL Alert', message='Smart RSI Crossover: SELL - confirmed by downward breakout')
````
