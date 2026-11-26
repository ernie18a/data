# Adaptive MA Fibonacci Zones MTF

- url: https://www.tradingview.com/script/ECRz1cDt/
- type: indicator
- pine_id: PUB;dc0ea300502141f5aae435417b2015b1
- version: 2.0

## Description

# Adaptive MA Fibonacci Zones MTF

Adaptive MA Fibonacci Zones MTF is a multi-timeframe technical analysis tool that projects Fibonacci-based price levels around a selected moving average.

The indicator allows traders to choose from multiple moving average types, including EMA, SMA, WMA, SMMA, DEMA, TEMA, HMA, VWMA, ALMA, and KAMA. Two independent higher timeframes can be analyzed simultaneously, making it easier to compare trend structure and potential reaction zones across different market perspectives.

### Features

• Supports multiple moving average calculation methods

• Displays two configurable higher timeframes on a single chart

• Automatically generates Fibonacci-based projection levels around each moving average

• Dynamic bullish and bearish level calculation depending on price position relative to the selected moving average

• Optional Fibonacci level labels

• Visual trend direction labels for each timeframe

• Useful for identifying potential support, resistance, pullback, and expansion areas

### How It Works

The script calculates a selected moving average on two user-defined timeframes. A customizable percentage range is then applied around each moving average, and Fibonacci ratios are projected within that range. When price is above the moving average, levels are projected upward. When price is below the moving average, levels are projected downward.

### Notes

This indicator is designed as a visual analysis tool and should not be considered financial advice. Fibonacci levels and moving averages are analytical references that may be used alongside other forms of technical analysis and risk management techniques.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano


//@version=6
indicator('Adaptive MA Fibonacci Zones MTF', overlay = true, max_lines_count = 500, max_labels_count = 500)

// === INPUTS ===
tf1 = input.timeframe('60', '1st Timeframe')
tf2 = input.timeframe('240', '2nd Timeframe')

ma_length = input.int(200, 'MA Period', minval = 1)
ma_type = input.string('EMA', 'MA Type', options = ['EMA', 'SMA', 'WMA', 'SMMA', 'DEMA', 'TEMA', 'HMA', 'VWMA', 'ALMA', 'KAMA'])

col1 = input.color(color.new(#00BCD4, 0), '1st TF Color')
col2 = input.color(color.new(#FF9800, 0), '2nd TF Color')

fib_range_pct = input.float(5.0, 'Fibonacci Range (%)', minval = 0.1, maxval = 50.0, step = 0.1)
show_labels = input.bool(true, 'Show Fibonacci Labels')

// === MA CALCULATION FUNCTION ===
get_ma(src, len, mtype) =>
    float result = na
    if mtype == 'EMA'
        result := ta.ema(src, len)
        result
    else if mtype == 'SMA'
        result := ta.sma(src, len)
        result
    else if mtype == 'WMA'
        result := ta.wma(src, len)
        result
    else if mtype == 'SMMA'
        result := ta.rma(src, len)
        result
    else if mtype == 'DEMA'
        e = ta.ema(src, len)
        result := 2 * e - ta.ema(e, len)
        result
    else if mtype == 'TEMA'
        e1 = ta.ema(src, len)
        e2 = ta.ema(e1, len)
        e3 = ta.ema(e2, len)
        result := 3 * e1 - 3 * e2 + e3
        result
    else if mtype == 'HMA'
        result := ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))
        result
    else if mtype == 'VWMA'
        result := ta.vwma(src, len)
        result
    else if mtype == 'ALMA'
        result := ta.alma(src, len, 0.85, 6)
        result
    else if mtype == 'KAMA'
        result := ta.ema(src, len) // fallback, manual KAMA calculation
        fast = 2.0 / (2 + 1)
        slow = 2.0 / (30 + 1)
        direction = math.abs(src - src[len])
        volatility = math.sum(math.abs(src - src[1]), len)
        er = volatility != 0 ? direction / volatility : 0
        sc = math.pow(er * (fast - slow) + slow, 2)
        result := na(result[1]) ? src : result[1] + sc * (src - result[1])
        result
    result

// === MAs WITH REQUEST.SECURITY ===
ma1 = request.security(syminfo.tickerid, tf1, get_ma(close, ma_length, ma_type), lookahead = barmerge.lookahead_off)
ma2 = request.security(syminfo.tickerid, tf2, get_ma(close, ma_length, ma_type), lookahead = barmerge.lookahead_off)

close1 = request.security(syminfo.tickerid, tf1, close, lookahead = barmerge.lookahead_off)
close2 = request.security(syminfo.tickerid, tf2, close, lookahead = barmerge.lookahead_off)

// === FIBONACCI ===
fib_levels = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272, 1.618)
fib_names = array.from('0', '0.236', '0.382', '0.5', '0.618', '0.786', '1.0', '1.272', '1.618')

range1 = ma1 * (fib_range_pct / 100)
range2 = ma2 * (fib_range_pct / 100)

bull1 = close1 >= ma1
bull2 = close2 >= ma2

fib_price(base, rng, level, is_bull) =>
    is_bull ? base + rng * level : base - rng * level

// === DRAWING ===
if barstate.islast
    for i = 0 to array.size(fib_levels) - 1 by 1
        lvl = array.get(fib_levels, i)
        name = array.get(fib_names, i)

        // --- TF1 ---
        price1 = fib_price(ma1, range1, lvl, bull1)
        lw1 = lvl == 0.0 or lvl == 1.0 or lvl == 1.618 ? 2 : 1
        line.new(bar_index - 50, price1, bar_index + 7, price1, color = col1, width = lw1, style = line.style_dashed)
        if show_labels
            label.new(bar_index + 11, price1, text = name + '  (' + str.tostring(math.round(price1, 2)) + ')', style = label.style_label_left, color = color.new(col1, 80), textcolor = col1, size = size.small)

        // --- TF2 ---
        price2 = fib_price(ma2, range2, lvl, bull2)
        lw2 = lvl == 0.0 or lvl == 1.0 or lvl == 1.618 ? 2 : 1
        line.new(bar_index - 50, price2, bar_index + 27, price2, color = col2, width = lw2, style = line.style_dotted)
        if show_labels
            label.new(bar_index + 26, price2, text = name + '  (' + str.tostring(math.round(price2, 2)) + ')', style = label.style_label_left, color = color.new(col2, 80), textcolor = col2, size = size.small)

    // Direction label - TF1
    arrow1 = bull1 ? '▲ UP' : '▼ DOWN'
    label.new(bar_index - 25, ma1, text = ma_type + str.tostring(ma_length) + ' [' + tf1 + '] ' + arrow1, style = bull1 ? label.style_label_up : label.style_label_down, color = col1, textcolor = color.white, size = size.normal)

    // Direction label - TF2
    arrow2 = bull2 ? '▲ UP' : '▼ DOWN'
    label.new(bar_index - 25, ma2, text = ma_type + str.tostring(ma_length) + ' [' + tf2 + '] ' + arrow2, style = bull2 ? label.style_label_up : label.style_label_down, color = col2, textcolor = color.white, size = size.normal)

// MA baseline plots
plot(ma1, title = 'MA TF1', color = col1, linewidth = 2)
plot(ma2, title = 'MA TF2', color = col2, linewidth = 2)
````
