# Forex Strong Weak Analysis (FX SW)

- url: https://www.tradingview.com/script/cP9tErtS-Forex-Strong-Weak-Analysis-FX-SW/
- type: indicator
- pine_id: PUB;befd945c9a6b40f1ada543c940fe4f74
- version: 1.0

## Description

[b]Overview[/b]
[quote]This indicator measures and ranks the relative strength of the 8 major forex currencies (EUR, USD, GBP, AUD, CAD, CHF, NZD, and JPY) by analysing price deviations from a moving average on each of the 28 currency pairings.[/quote]
[b]How It Works[/b]
The indicator measures momentum by calculating each pair’s percentage deviation from an exponential moving average (EMA). This value is then given to both the base and quote currencies as shown:
Base currency gains strength (+) when price is above its EMA.
Quote currency loses strength (-) when price is above its EMA.
Base currency loses strength (-) when price is below its EMA.
Quote currency gains strength (+) when price is below its EMA.

Each currency’s final strength value is derived by averaging its performance across all its pairs, ensuring a balanced and normalised result.

[b]Key Features[/b]
[list]
[*]Choose the broker for the 28 currency pairs.
[*]Change the EMA length (default: 200).
[*]Change the EMA timeframe (default: 4H).
[*]Strength lines and table:
- Strength lines are real-time for each currency.
- Ranking table displays strongest to weakest currencies, based on the last candle that closed.
[*]Changeable colours.
[*]Open Source.[/list]

[b]How to Use[/b]
Great if you use an Exponential Moving Average as part of a trend trading system.
Identify the strongest and weakest currencies with the indicator.
And look to trade pairs that combine them.
Typical workflow example:
[list=1]
[*]Check the ranking table.
[*]Identify strongest currency (e.g., AUD)
[*]Identify weakest currency (e.g., JPY)
[*]Trade: AUDJPY[/list]

I recommend also enabling indicator name and value labels on the price scale, if you like that.

[b]Important Notes[/b]
This indicator measures relative strength, not absolute direction.
Best used in trending or expanding market conditions.
Read the information buttons in the indicator settings.

[b]Disclaimer[/b]

This tool is intended for analysis and educational purposes only. It does not provide financial advice and should be used in conjunction with other forms of analysis and risk management.

## Source Code

````pine
//@version=6

indicator('Forex Strong Weak Analysis', shorttitle = 'FX SW', precision = 2)

// === BROKER PREFIX ===
broker = input.string('OANDA', 'Broker Prefix', tooltip = 'You must use this indicator on the forex pairs its set to. For example, not on other assets, or a forex pair from a different broker, or a forex pair outside of these 28 major pairs.')

// === SETTINGS ===
calc_tf = input.timeframe('240', 'Calculation Timeframe')
len = input.int(200, 'EMA Length')
display_tf_2 = input.timeframe('D', 'Second Display Timeframe', tooltip = 'Optional second timeframe to display the indicator on. Always make sure it is divisable by the Calculation Timeframe, or else it wont be accurate')

// === COLOR SETTINGS ===
colEUR = input.color(#f23645, 'EUR Color')
colUSD = input.color(#ff9800, 'USD Color')
colGBP = input.color(#ffee58, 'GBP Color')
colAUD = input.color(#4caf50, 'AUD Color')
colCAD = input.color(#26c6da, 'CAD Color')
colCHF = input.color(#3179f5, 'CHF Color')
colNZD = input.color(#ab47bc, 'NZD Color')
colJPY = input.color(#787b86, 'JPY Color')

// === DISPLAY SETTINGS ===
show_calc_tf = input.bool(true, 'Display Timeframe')
use_display_tf_2 = input.bool(true, 'Display Second Timeframe')

// === TIMEFRAME FILTERS ===
is_selected_tf = timeframe.period == calc_tf

tf_current  = timeframe.in_seconds(timeframe.period)
tf_selected = timeframe.in_seconds(display_tf_2)
is_display_tf_2 = tf_current == tf_selected

// === DISPLAY CONDITION ===
show_plot = (show_calc_tf and is_selected_tf) or (use_display_tf_2 and is_display_tf_2)

// === ARRAYS ===
var array<string> curr = array.from('EUR', 'USD', 'GBP', 'AUD', 'CAD', 'CHF', 'NZD', 'JPY')
var array<float> strength = array.new_float(array.size(curr), 0)
var array<float> count = array.new_float(array.size(curr), 0)
var array<color> currColors = array.from(colEUR, colUSD, colGBP, colAUD, colCAD, colCHF, colNZD, colJPY)

// === RESET STRENGTH EACH BAR ===
for i = 0 to array.size(strength) - 1 by 1
    array.set(strength, i, 0)
    array.set(count, i, 0)

// === INDEX LOOKUP ===
idx(sym) =>
    switch sym
        'EUR' => 0
        'USD' => 1
        'GBP' => 2
        'AUD' => 3
        'CAD' => 4
        'CHF' => 5
        'NZD' => 6
        'JPY' => 7

// === STRENGTH CALCULATION FUNCTION ===
calc(base, quote, val) =>
    bi = idx(base)
    qi = idx(quote)

    // base currency
    array.set(strength, bi, array.get(strength, bi) + val)
    array.set(count, bi, array.get(count, bi) + 1)

    // quote currency
    array.set(strength, qi, array.get(strength, qi) - val)
    array.set(count, qi, array.get(count, qi) + 1)

// === PAIR CALCULATION FUNCTION ===
pair(sym, base, quote) =>
    val = request.security(sym, calc_tf, (close - ta.ema(close, len)) / ta.ema(close, len) * 100)
    calc(base, quote, val)

// === SYMBOL BUILDER ===
sym(pair) =>
    broker + ':' + pair

// === 28 MAJOR PAIRS ===
pair(sym('EURUSD'), 'EUR', 'USD')
pair(sym('GBPUSD'), 'GBP', 'USD')
pair(sym('AUDUSD'), 'AUD', 'USD')
pair(sym('NZDUSD'), 'NZD', 'USD')
pair(sym('USDCAD'), 'USD', 'CAD')
pair(sym('USDCHF'), 'USD', 'CHF')
pair(sym('USDJPY'), 'USD', 'JPY')
pair(sym('EURGBP'), 'EUR', 'GBP')
pair(sym('EURAUD'), 'EUR', 'AUD')
pair(sym('EURNZD'), 'EUR', 'NZD')
pair(sym('EURCAD'), 'EUR', 'CAD')
pair(sym('EURCHF'), 'EUR', 'CHF')
pair(sym('EURJPY'), 'EUR', 'JPY')
pair(sym('GBPAUD'), 'GBP', 'AUD')
pair(sym('GBPNZD'), 'GBP', 'NZD')
pair(sym('GBPCAD'), 'GBP', 'CAD')
pair(sym('GBPCHF'), 'GBP', 'CHF')
pair(sym('GBPJPY'), 'GBP', 'JPY')
pair(sym('AUDNZD'), 'AUD', 'NZD')
pair(sym('AUDCAD'), 'AUD', 'CAD')
pair(sym('AUDCHF'), 'AUD', 'CHF')
pair(sym('AUDJPY'), 'AUD', 'JPY')
pair(sym('NZDCAD'), 'NZD', 'CAD')
pair(sym('NZDCHF'), 'NZD', 'CHF')
pair(sym('NZDJPY'), 'NZD', 'JPY')
pair(sym('CADCHF'), 'CAD', 'CHF')
pair(sym('CADJPY'), 'CAD', 'JPY')
pair(sym('CHFJPY'), 'CHF', 'JPY')

// === CALCULATE AVERAGE STRENGTH ===
for i = 0 to array.size(strength) - 1 by 1
    c = array.get(count, i)
    if c > 0
        array.set(strength, i, array.get(strength, i) / c)

// === PLOTS ===
plot(show_plot ? array.get(strength, 0) : na, 'EUR', color.new(colEUR, 0))
plot(show_plot ? array.get(strength, 1) : na, 'USD', color.new(colUSD, 0))
plot(show_plot ? array.get(strength, 2) : na, 'GBP', color.new(colGBP, 0))
plot(show_plot ? array.get(strength, 3) : na, 'AUD', color.new(colAUD, 0))
plot(show_plot ? array.get(strength, 4) : na, 'CAD', color.new(colCAD, 0))
plot(show_plot ? array.get(strength, 5) : na, 'CHF', color.new(colCHF, 0))
plot(show_plot ? array.get(strength, 6) : na, 'NZD', color.new(colNZD, 0))
plot(show_plot ? array.get(strength, 7) : na, 'JPY', color.new(colJPY, 0))

// === STORE LAST BAR STRENGTH BEFORE RESET ===
var array<float> last_strength = array.new_float(array.size(curr), 0)
if barstate.isconfirmed
    for i = 0 to array.size(strength) - 1 by 1
        array.set(last_strength, i, array.get(strength, i))

// === SORT STRONG → WEAK ===
names = array.copy(curr)
vals = array.copy(last_strength)
cols = array.copy(currColors)

if barstate.islast
    for i = 0 to array.size(vals) - 2 by 1
        for j = 0 to array.size(vals) - i - 2 by 1
            if array.get(vals, j) < array.get(vals, j + 1)
                // swap values
                v = array.get(vals, j)
                array.set(vals, j, array.get(vals, j + 1))
                array.set(vals, j + 1, v)

                // swap names
                n = array.get(names, j)
                array.set(names, j, array.get(names, j + 1))
                array.set(names, j + 1, n)

                // swap colors
                c = array.get(cols, j)
                array.set(cols, j, array.get(cols, j + 1))
                array.set(cols, j + 1, c)

// === TIMEFRAME LABEL ===
tfLabel = switch timeframe.period
    '15'  => '15m'
    '30'  => '30m'
    '60'  => '1h'
    '120' => '2h'
    '180' => '3h'
    '240' => '4h'
    '360' => '6h'
    '480' => '8h'
    '720' => '12h'
    'D'   => 'D'
    '2D'  => '2D'
    '3D'  => '3D'
    '5D'  => '5D'
    'W'   => 'W'
    '2W'  => '2W'
    '3W'  => '3W'
    'M'   => '1MO'
    => timeframe.period

// === TABLE ===
var table t = table.new(position.top_right, 9, 1, border_width = 1)

if barstate.islast and show_plot

    table.cell(
        t,
        0,
        0,
        tfLabel,
        text_color = color.white,
        bgcolor = color.black,
        width = 4
    )

    for i = 0 to array.size(names) - 1 by 1
        name = array.get(names, i)
        val = array.get(vals, i)
        col = array.get(cols, i)

        formatted = name + '\n' + str.tostring(val, '0.00')

        table.cell(
            t,
            i + 1,
            0,
            formatted,
            width = 5,
            text_color = color.black,
            bgcolor = col
        )
````
