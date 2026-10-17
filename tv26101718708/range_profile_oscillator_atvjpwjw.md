# Range Profile Oscillator

- url: https://www.tradingview.com/script/atvJpWjW-Range-Profile-Oscillator/
- type: indicator
- pine_id: PUB;2bb4bf3f99fd49808e17c5d888e41e1f
- version: 1.0

## Description

█ OVERVIEW
Range Profile Oscillator is a momentum oscillator that analyzes the position of price relative to a dynamic price range profile (Range Profile). Within a defined historical window the script builds a profile of price activity, locates its point of highest activity concentration and the boundaries of the overbought and oversold zones, then measures how far the current price has moved away from this equilibrium area.
Unlike traditional oscillators, the reference levels are neither fixed nor based solely on price changes. They are calculated from the distribution of price activity across the entire analyzed range, so they automatically adapt to the current market structure. As a result, signals appear only when price truly leaves the area considered typical for recent market activity.
The indicator generates BUY and SELL signals when the oscillator line breaks out beyond the dynamic Overbought (OB) and Oversold (OS) zones. It can also color candles according to the current oscillator direction, highlight the background on breakouts, and automatically plot Entry, Stop Loss and Take Profit levels using either ATR or a fixed percentage risk.
The result is a tool that combines price location analysis, momentum and adaptive market equilibrium levels. This helps distinguish ordinary price fluctuations from moments when the market genuinely breaks out of its characteristic range.

█ CONCEPTS
Range Profile
The foundation of the indicator is the Range Profile — an analysis of the distribution of price activity within the selected historical range. The entire price range is divided into many small intervals (bins), and the candle activity falling into each of them is counted. This creates a profile that shows the levels where price spent the most time.
Instead of assuming that the market center lies exactly halfway between the highest and lowest price, the indicator locates it at the level of highest activity concentration. This provides a much more accurate reflection of true market equilibrium.

Dynamic equilibrium line (Midline)
The Midline represents the level around which the market spent the most time in the analyzed period. The oscillator value is calculated from this level.
When price is close to the Midline it remains in the equilibrium area. The farther it moves away from this level, the stronger the momentum becomes and the higher the probability of entering the overbought or oversold zone.

Dynamic Overbought and Oversold zones
The overbought and oversold boundaries are not fixed. They are derived from the current market profile and automatically expand or contract with changes in volatility and price structure.
This allows the indicator to adapt its sensitivity to market conditions. In quiet markets the zones become narrower; during high volatility they widen, reducing the number of random signals.

Price location oscillator
The oscillator line shows how far the current price is from the point of highest activity concentration (Midline) relative to the width of the entire profile.
Values near zero indicate trading inside the equilibrium area, while a rising or falling oscillator reflects an increasing distance from the typical range. Crossing the OB or OS boundaries means the market has reached an extreme position relative to its current profile.

Breakout signals
A BUY signal is generated when the oscillator breaks above the Overbought zone; a SELL signal appears when it breaks below the Oversold zone.
An optional signal filter prevents repeated signals in the same direction. A new BUY can appear only after a previous SELL (and vice versa), which limits the number of consecutive same-direction signals during strong trends.

Momentum visualization
The color of the oscillator line and, optionally, the candles reflects the current market state:
* bullish color indicates a breakout above the Overbought zone,
* bearish color indicates a breakout below the Oversold zone,
* neutral color shows that price is still inside the normal range.

In addition, the gradient and background highlighting visualize the strength of the breakout beyond the profile boundaries, making the most dynamic moves immediately visible on the chart.

█ FEATURES
Calculation Settings
• Lookback Bars – number of historical bars used to build the range profile, determine the Midline and the OB/OS channel boundaries
• OB/OS Level – distance from the Midline (as a % of half the channel width) that defines the Overbought and Oversold zones; a breakout beyond this level triggers a signal

Signals
• Highlight Background on Breakout – colors the chart background when the oscillator line breaks above/below the OB/OS channel
• Background Highlight Transparency – adjusts the transparency of the background breakout highlight
• Show BUY/SELL Labels – plots BUY or SELL labels on the main chart whenever a breakout signal fires
• Signal Filter – blocks repeated signals in the same direction (a new BUY only after a SELL and vice versa)

Appearance
• Show Breakout Gradient – fills the area between the signal line and the OB/OS boundary with a gradient whenever price is outside the channel
• Color Candles by Signal Line – colors the main-chart candles using the same color as the signal line (bullish / bearish / neutral)

Colors
• Bullish Color, Bearish Color, Neutral Color – three consistent colors used throughout the indicator for lines, fills, labels, signals and candles

TP/SL
• Show TP/SL – automatically draws Entry, Stop Loss and Take Profit levels on the main chart whenever a breakout signal fires
• SL = ATR × instead of % – choice between an ATR-based stop-loss (ATR × multiplier) or a fixed percentage of the entry price
• ATR Period and SL ATR Multiplier – parameters for the ATR-based stop-loss
• SL % from Entry – percentage stop-loss distance (used when ATR is disabled)
• TP1 RR / TP2 RR / TP3 RR – Risk:Reward multiples for the three Take Profit levels
• Independent on/off switches for displaying SL, TP1, TP2 and TP3

Alerts
• Alert on breakout above the Overbought zone
• Alert on breakout below the Oversold zone

█ APPLICATIONS
Identifying breakouts beyond the equilibrium area
The indicator helps distinguish ordinary price fluctuations inside the typical range from moments when the market leaves the zone of highest activity. Signals appear only when the oscillator breaks the dynamic OB/OS boundaries.

Breakouts as a potential start of a stronger move
Breakouts beyond the OB/OS zone often mark the beginning of a stronger move or a new trend, so the signals can serve a role similar to classic trend indicators. They should not, however, be treated automatically as entry points. Before acting it is advisable to examine the broader context: whether the signal occurs near a significant support/resistance zone and whether it is confirmed by other technical analysis tools (e.g. market structure, momentum, volume).

Risk management directly on the chart
The automatic Entry, SL and TP levels allow a quick assessment of the potential risk-to-reward ratio for each signal. You can use either ATR or a fixed percentage, adjusting the parameters to your trading style and the instrument’s volatility.

Visual assessment of momentum strength
The color of the oscillator line, the candles and the breakout gradient immediately show whether the market is still inside the equilibrium zone or has already entered overbought/oversold territory. Background highlighting further draws attention to the moment of the breakout.

Complementing other analysis methods
Range Profile Oscillator signals can act as a filter or confirmation for strategies based on market structure, support/resistance, order flow or classic momentum oscillators.

Matching lookback to trading style
The lookback value should be chosen according to the timeframe and trading horizon. A shorter lookback reacts faster to local structural changes; a longer one better reflects the broader market context.

█ NOTES
• The Midline and OB/OS zones are recalculated on every bar from the most recent lookback window — the indicator automatically adapts to the current market structure.
• BUY/SELL signals and alerts mark the moment price breaks out of the current range profile. They are not automatic entry points — before taking a decision it is recommended to check alignment with other tools (market structure, momentum, volume, etc.).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator('Range Profile Oscillator', overlay = false, max_bars_back = 5000, max_labels_count=500)

// INPUTS
lookback     = input.int(110, 'Lookback Bars', minval = 30, group = 'Calculation Settings', tooltip = 'Number of past bars used to calculate the price range, the midline and the channel boundaries.')
ob_os_level  = input.float(80.0, 'OB/OS Level', minval = 30, maxval = 100, step = 0.5, group = 'Calculation Settings', tooltip = 'Distance from the midline (as % of half the channel width) that defines the overbought/oversold channel boundaries. A breakout beyond this level triggers a signal.')

// SIGNALS
show_signals  = input.bool(true, 'Highlight Background on Breakout', group = 'Signals', tooltip = 'Colors the chart background when the signal line breaks above/below the OB/OS channel.')
bgTransp      = input.int(50, 'Background Highlight Transparency', minval = 0, maxval = 100, group = 'Signals', tooltip = 'Transparency of the background breakout highlight (0 = solid, 100 = invisible).')
show_buy_sell_labels = input.bool(true, 'Show BUY/SELL Labels', group = 'Signals', tooltip = 'Plots a BUY or SELL label on the main chart whenever a breakout signal fires.')
sig_filter    = input.bool(false, 'Signal Filter', group = 'Signals', tooltip = 'When enabled, blocks repeated signals in the same direction — a new BUY (or SELL) will only fire after an opposite signal has occurred. Prevents multiple same-direction signals in a row.')


show_breakout_fill = input.bool(true, 'Show Breakout Gradient (outside channel)', group = 'Appearance', tooltip = 'Fills the area between the signal line and the OB/OS boundary with a gradient whenever price is outside the channel.')
color_bars          = input.bool(true, 'Color Candles by Signal Line', group = 'Appearance', tooltip = 'Colors the main chart candles using the same color as the signal line (bullish/bearish/neutral).')

// Colors (only 3 — used consistently for lines, fills, signal line, breakout shapes and candles)
colBull    = input.color(color.rgb(22, 196, 6), 'Bullish Color', group = 'Colors')
colBear    = input.color(color.rgb(202, 2, 2), 'Bearish Color', group = 'Colors')
colNeutral = input.color(color.rgb(175, 175, 175), 'Neutral Color (Midline / Inside Channel)', group = 'Colors')

// TP/SL SETTINGS
showTargets   = input.bool(true, 'Show TP/SL', group = 'TP/SL', tooltip = 'Draws entry, stop-loss and take-profit levels on the main chart whenever a breakout signal fires.')
useAtrForSl   = input.bool(true, 'SL = ATR × instead of %', group = 'TP/SL', tooltip = 'If enabled, the stop-loss distance is based on ATR × multiplier. If disabled, it is based on a fixed % of the entry price.')
atrPeriod     = input.int(14, 'ATR Period', minval = 1, group = 'TP/SL', tooltip = 'Number of bars used to calculate the Average True Range for stop-loss sizing.')
slAtrMult     = input.float(1.5, 'SL ATR Multiplier', step = 0.1, group = 'TP/SL', tooltip = 'Multiplies the ATR value to determine the stop-loss distance from entry.')
slPercent     = input.float(1.0, 'SL % from Entry', step = 0.1, group = 'TP/SL', tooltip = 'Stop-loss distance as a percentage of the entry price (used only if ATR-based SL is disabled).')
rrTp1         = input.float(1.0, 'TP1 RR', step = 0.1, group = 'TP/SL', tooltip = 'Take-Profit 1 distance, expressed as a multiple of the risk (SL distance).')
rrTp2         = input.float(2.0, 'TP2 RR', step = 0.1, group = 'TP/SL', tooltip = 'Take-Profit 2 distance, expressed as a multiple of the risk (SL distance).')
rrTp3         = input.float(3.0, 'TP3 RR', step = 0.1, group = 'TP/SL', tooltip = 'Take-Profit 3 distance, expressed as a multiple of the risk (SL distance).')
showSlLevel   = input.bool(true, 'SL', group = 'TP/SL Display', tooltip = 'Show the stop-loss line and label.')
showTp1Level  = input.bool(true, 'TP1', group = 'TP/SL Display', tooltip = 'Show the take-profit 1 line and label.')
showTp2Level  = input.bool(true, 'TP2', group = 'TP/SL Display', tooltip = 'Show the take-profit 2 line and label.')
showTp3Level  = input.bool(true, 'TP3', group = 'TP/SL Display', tooltip = 'Show the take-profit 3 line and label.')

// TP/SL COLORS (derived from the 3 main colors)
buyLabelColor  = colBull
sellLabelColor = colBear
buyColorLight  = color.new(buyLabelColor, 40)
sellColorLight = color.new(sellLabelColor, 40)
buyFill        = color.new(buyLabelColor, 85)
sellFill       = color.new(sellLabelColor, 85)

// ATR (for SL sizing)
atr_val = ta.atr(atrPeriod)

// VARIABLES
const int bins = 50

var array<float> bull_weight = array.new_float(bins, 0.0)
var array<float> bear_weight = array.new_float(bins, 0.0)

var float range_high = na
var float range_low  = na
var float mid_price  = na

// TP/SL STATE
var int   trade_dir     = 0
var int   entry_bar     = na
var float sl_level      = na
var float extreme_level = na
var line  entry_line    = na
var label entry_label   = na
var line  sl_line       = na
var label sl_label      = na
var line  tp1_line      = na
var label tp1_label     = na
var line  tp2_line      = na
var label tp2_label     = na
var line  tp3_line      = na
var label tp3_label     = na
var line  extreme_line  = na
var linefill risk_fill  = na
var linefill reward_fill = na

// RANGE / MIDLINE CALCULATION
if bar_index >= lookback
    float minL = low
    float maxH = high
    for i = 1 to lookback - 1
        minL := math.min(minL, low[i])
        maxH := math.max(maxH, high[i])

    float price_range = maxH - minL
    if price_range > syminfo.mintick * 5
        float bin_size = price_range / bins
        array.fill(bull_weight, 0.0)
        array.fill(bear_weight, 0.0)

        for i = 0 to lookback - 1
            float h = high[i]
            float l = low[i]
            float candle_size = h - l
            if candle_size > 0
                float frac = bin_size / candle_size
                int b1 = math.max(0, math.min(bins-1, math.floor((l - minL) / bin_size)))
                int b2 = math.max(0, math.min(bins-1, math.floor((h - minL) / bin_size)))

                bool is_bull = close[i] >= open[i]
                float add = candle_size * frac

                for b = b1 to b2
                    if is_bull
                        array.set(bull_weight, b, array.get(bull_weight, b) + add)
                    else
                        array.set(bear_weight, b, array.get(bear_weight, b) + add)

        // Midline 
        int mid_bin = 0
        float max_total = -1e10
        for i = 0 to bins - 1
            float total_bin = array.get(bull_weight, i) + array.get(bear_weight, i)
            if total_bin > max_total
                max_total := total_bin
                mid_bin := i

        mid_price := minL + bin_size * (mid_bin + 0.5)

        // Channel (Range High/Low)
        float total = 0.0
        for i = 0 to bins - 1
            total += array.get(bull_weight, i) + array.get(bear_weight, i)

        if total > 0
            float mid_total = array.get(bull_weight, mid_bin) + array.get(bear_weight, mid_bin)
            float remaining = total * (ob_os_level / 100) - mid_total
            int lowB = mid_bin
            int highB = mid_bin
            while remaining > 0 and (lowB > 0 or highB < bins - 1)
                float upper = highB < bins-1 ? array.get(bull_weight, highB+1) + array.get(bear_weight, highB+1) : -1
                float lower = lowB > 0 ? array.get(bull_weight, lowB-1) + array.get(bear_weight, lowB-1) : -1
                if upper >= lower and upper >= 0
                    highB += 1
                    remaining -= upper
                else if lower >= 0
                    lowB -= 1
                    remaining -= lower
                else
                    break

            range_low  := minL + lowB * bin_size
            range_high := minL + (highB + 1) * bin_size

// OSCILLATOR VALUE
float half_range = (not na(range_high) and not na(range_low)) ? (range_high - range_low) / 2 : na
float osc = (not na(half_range) and half_range > 0 and not na(mid_price)) ? (close - mid_price) / half_range * ob_os_level : na

// OB / OS / ZERO — transparent plots (needed for fill)
p_ob   = plot(ob_os_level,  "OB",   color = color.new(colBull, 100),    style = plot.style_line)
p_os   = plot(-ob_os_level, "OS",   color = color.new(colBear, 100),    style = plot.style_line)
p_zero = plot(0,            "Zero", color = color.new(colNeutral, 100), style = plot.style_line)

// Visible dashed lines
hline(ob_os_level,  "OB (Range High)", color = colBull,    linestyle = hline.style_dashed, linewidth = 1)
hline(-ob_os_level, "OS (Range Low)",  color = colBear,    linestyle = hline.style_dashed, linewidth = 1)
hline(0,            "Midline",         color = colNeutral, linestyle = hline.style_dashed, linewidth = 1)

// SIGNAL LINE
sig_color = osc > ob_os_level ? colBull : osc < -ob_os_level ? colBear : colNeutral
p_osc = plot(osc, "Price (Signal Line)", color = sig_color, linewidth = 2)

// CHANNEL INTERIOR 
// Upper half: strongest near OB → fades to zero (same logic as bull breakout)
fill(p_ob, p_zero,
     top_value    = ob_os_level,
     bottom_value = 0,
     top_color    = color.new(colNeutral, 90),
     bottom_color = color.new(colNeutral, 95),
     title = "Upper Channel Gradient")

// Lower half: strongest near OS → fades to zero (same logic as bear breakout)
fill(p_os, p_zero,
     top_value    = 0,
     bottom_value = -ob_os_level,
     top_color    = color.new(colNeutral, 95),
     bottom_color = color.new(colNeutral, 90),
     title = "Lower Channel Gradient")

// BREAKOUT GRADIENTS
bull_break = show_breakout_fill and osc > ob_os_level
bear_break = show_breakout_fill and osc < -ob_os_level

fill(p_ob, p_osc,
     top_value    = bull_break ? osc         : na,
     bottom_value = bull_break ? ob_os_level : na,
     top_color    = bull_break ? color.new(colBull, 70) : na,
     bottom_color = bull_break ? color.new(colBull, 95) : na,
     title = "Bull Breakout Gradient")

fill(p_os, p_osc,
     top_value    = bear_break ? -ob_os_level : na,
     bottom_value = bear_break ? osc          : na,
     top_color    = bear_break ? color.new(colBear, 95) : na,
     bottom_color = bear_break ? color.new(colBear, 70) : na,
     title = "Bear Breakout Gradient")

// BREAKOUT SIGNALS
raw_breakout_up   = ta.crossover(osc, ob_os_level)
raw_breakout_down = ta.crossunder(osc, -ob_os_level)

var int last_signal_dir = 0

breakout_up   = sig_filter ? (raw_breakout_up   and last_signal_dir != 1)  : raw_breakout_up
breakout_down = sig_filter ? (raw_breakout_down and last_signal_dir != -1) : raw_breakout_down

if breakout_up
    last_signal_dir := 1
if breakout_down
    last_signal_dir := -1

bgcolor(show_signals and breakout_up   ? color.new(colBull, bgTransp) : na, title = "OB Breakout Highlight")
bgcolor(show_signals and breakout_down ? color.new(colBear, bgTransp) : na, title = "OS Breakout Highlight")

plot(breakout_up   ? 1 : na, "bt_score_buy",   display = display.none)
plot(breakout_down ? 1 : na, "bt_score_sell",  display = display.none)

// INDEPENDENT BUY/SELL LABELS (on the main chart)
if breakout_up and show_buy_sell_labels
    label.new(bar_index, low, 'BUY', style = label.style_label_up, color = color.new(buyLabelColor, 40), textcolor = color.white, size = size.small, force_overlay = true)
if breakout_down and show_buy_sell_labels
    label.new(bar_index, high, 'SELL', style = label.style_label_down, color = color.new(sellLabelColor, 40), textcolor = color.white, size = size.small, force_overlay = true)

// TP/SL 

if (breakout_up or breakout_down) and showTargets

    line.delete(entry_line)
    label.delete(entry_label)
    line.delete(sl_line)
    label.delete(sl_label)
    line.delete(tp1_line)
    label.delete(tp1_label)
    line.delete(tp2_line)
    label.delete(tp2_label)
    line.delete(tp3_line)
    label.delete(tp3_label)
    line.delete(extreme_line)
    linefill.delete(risk_fill)
    linefill.delete(reward_fill)

    int dir = breakout_up ? 1 : -1
    trade_dir := dir
    entry_bar := bar_index
    float entry_price = close
    float risk_dist = useAtrForSl ? atr_val * slAtrMult : entry_price * (slPercent / 100)
    float sl_level_local = dir == 1 ? entry_price - risk_dist : entry_price + risk_dist
    float tp1_p = dir == 1 ? entry_price + risk_dist * rrTp1 : entry_price - risk_dist * rrTp1
    float tp2_p = dir == 1 ? entry_price + risk_dist * rrTp2 : entry_price - risk_dist * rrTp2
    float tp3_p = dir == 1 ? entry_price + risk_dist * rrTp3 : entry_price - risk_dist * rrTp3
    float extreme_level_local = na
    if showTp3Level
        extreme_level_local := tp3_p
    if showTp2Level
        extreme_level_local := na(extreme_level_local) ? tp2_p : dir == 1 ? math.max(extreme_level_local, tp2_p) : math.min(extreme_level_local, tp2_p)
    if showTp1Level
        extreme_level_local := na(extreme_level_local) ? tp1_p : dir == 1 ? math.max(extreme_level_local, tp1_p) : math.min(extreme_level_local, tp1_p)

    // entry 
    entry_line := line.new(bar_index, entry_price, bar_index, entry_price, color = dir == 1 ? buyLabelColor : sellLabelColor, width = 2, extend = extend.none, force_overlay = true)
    entry_label := label.new(bar_index, entry_price, (dir == 1 ? "BUY " : "SELL ") + str.tostring(entry_price, format.mintick), style = label.style_label_left, color = dir == 1 ? buyLabelColor : sellLabelColor, textcolor = color.white, size = size.small, force_overlay = true)
    // SL
    if showSlLevel
        sl_line := line.new(bar_index, sl_level_local, bar_index, sl_level_local, color = sellColorLight, width = 1, style = line.style_dashed, extend = extend.none, force_overlay = true)
        sl_label := label.new(bar_index, sl_level_local, "SL " + str.tostring(sl_level_local, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small, force_overlay = true)
    // TP
    if showTp1Level
        tp1_line := line.new(bar_index, tp1_p, bar_index, tp1_p, color = buyColorLight, width = 1, extend = extend.none, force_overlay = true)
        tp1_label := label.new(bar_index, tp1_p, "TP1 " + str.tostring(tp1_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small, force_overlay = true)
    if showTp2Level
        tp2_line := line.new(bar_index, tp2_p, bar_index, tp2_p, color = buyColorLight, width = 1, extend = extend.none, force_overlay = true)
        tp2_label := label.new(bar_index, tp2_p, "TP2 " + str.tostring(tp2_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small, force_overlay = true)
    if showTp3Level
        tp3_line := line.new(bar_index, tp3_p, bar_index, tp3_p, color = buyColorLight, width = 1, style = line.style_dotted, extend = extend.none, force_overlay = true)
        tp3_label := label.new(bar_index, tp3_p, "TP3 " + str.tostring(tp3_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small, force_overlay = true)

    // fill risk / reward
    if showSlLevel
        risk_fill := linefill.new(entry_line, sl_line, sellFill)
    float extreme_for_fill = entry_price
    if showTp1Level
        extreme_for_fill := dir == 1 ? math.max(extreme_for_fill, tp1_p) : math.min(extreme_for_fill, tp1_p)
    if showTp2Level
        extreme_for_fill := dir == 1 ? math.max(extreme_for_fill, tp2_p) : math.min(extreme_for_fill, tp2_p)
    if showTp3Level
        extreme_for_fill := dir == 1 ? math.max(extreme_for_fill, tp3_p) : math.min(extreme_for_fill, tp3_p)
    if (dir == 1 and extreme_for_fill > entry_price) or (dir == -1 and extreme_for_fill < entry_price)
        extreme_line := line.new(bar_index, extreme_for_fill, bar_index, extreme_for_fill, color = na, extend = extend.none, force_overlay = true)
        reward_fill := linefill.new(entry_line, extreme_line, buyFill)

    sl_level := sl_level_local
    extreme_level := extreme_level_local

// MOVE LABELS + EXTEND TO LATEST BAR + CLOSE ON SL/TP
if trade_dir != 0
    line.set_x2(entry_line, bar_index)
    label.set_x(entry_label, bar_index)
    if not na(sl_line)
        line.set_x2(sl_line, bar_index)
        label.set_x(sl_label, bar_index)
    if not na(tp1_line)
        line.set_x2(tp1_line, bar_index)
        label.set_x(tp1_label, bar_index)
    if not na(tp2_line)
        line.set_x2(tp2_line, bar_index)
        label.set_x(tp2_label, bar_index)
    if not na(tp3_line)
        line.set_x2(tp3_line, bar_index)
        label.set_x(tp3_label, bar_index)
    if not na(extreme_line)
        line.set_x2(extreme_line, bar_index)

    bool sl_hit = trade_dir == 1 ? low <= sl_level : high >= sl_level
    bool tp_hit = not na(extreme_level) and (trade_dir == 1 ? high >= extreme_level : low <= extreme_level)
    if bar_index > entry_bar and (sl_hit or tp_hit)
        trade_dir := 0

// COLOR CANDLES
barcolor(color_bars ? sig_color : na)

// ALERTS
alertcondition(breakout_up,   "OB Breakout", "Price broke above the range (OB)!")
alertcondition(breakout_down, "OS Breakout", "Price broke below the range (OS)!")
````
