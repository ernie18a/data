# UT Bot v2 - ATR Trailing Stop

- url: https://www.tradingview.com/script/lDGmh7ou-UT-Bot-v2-ATR-Trailing-Stop/
- type: strategy
- pine_id: PUB;d51b224c4a994fa2bbe7165b17e46741
- version: 2.0

## Description

If you're familiar with the original UT Bot: the core logic is the same. This version focuses on cleaner visuals, improved code quality, better customization, built-in alerts, and integrated strategy support, while preserving the underlying ATR trailing stop methodology.

UT Bot v2 is a modernized implementation of the original UT Bot, built around the same ATR-based trailing stop logic that made the original popular.

The indicator uses an adaptive trailing stop based on the Average True Range (ATR). When price crosses the stop level, the trend state flips and a new trailing stop begins to form in the opposite direction.

Rather than changing the algorithm, this release focuses on making it clearer, easier to configure, and more practical for everyday use.

[b]Features[/b]
[list]
[*] Classic ATR trailing stop logic
[*] Clean and intuitive trend visualization
[*] Buy and sell signal markers
[*] Configurable ATR period and multiplier
[*] Customizable price source
[*] Built-in TradingView alerts
[*] Integrated strategy for backtesting
[*] Lightweight and easy to understand
[/list]
[b]Methodology[/b]

UT Bot v2 is not a predictive indicator. It does not attempt to forecast future price movements or identify exact market tops and bottoms.

Instead, it is a trend-following and risk management tool that dynamically adjusts its trailing stop using market volatility measured by ATR.

Like most trend-following systems, it tends to perform best during sustained directional moves and may generate whipsaws during ranging or low-volatility conditions.

[b]Philosophy[/b]

The goal of UT Bot has always been to provide a simple, transparent, and systematic trailing stop framework, rather than a "holy grail" trading system.

This version preserves that philosophy while improving readability, customization, visualization, and integration with TradingView alerts and strategy testing.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © QuantNomad

//@version=6
strategy(title = 'UT Bot v2 — ATR Trailing Stop', shorttitle = "UT Bot v2", overlay = true)

////////////
// INPUTS /{

mult        = input.float(1,      title = 'Multipier',  minval = 0.1, step = 0.1, tooltip = 'Controls the distance of the trailing stop. Higher values create wider stops and fewer trend flips.', group = "Config")
atr_len     = input.int(10,       title = 'ATR Period', minval = 1, tooltip = 'Number of bars used to calculate ATR volatility.', group = "Config")
source      = input.source(close, title = "Source", tooltip = 'Price source used for trailing stop calculations.', group = "Config")

// Backtest range
use_date_filter = input.bool(true, "Use Backtest Date Range", group = "Backtesting Range")

start_time = input.time(
     timestamp("2020-01-01 00:00"),
     "Start Date", 
     group = "Backtesting Range"
)

end_time = input.time(
     timestamp("2030-01-01 00:00"),
     "End Date", 
     group = "Backtesting Range"
)


show_signals = input.bool(true,  'Show Buy/Sell Signals',   group = "Display")
color_bars   = input.bool(false, 'Color Bars by Trend',     group = "Display")
show_tsl     = input.bool(true,  'Show Trailing Stop Line', group = "Display")



//}

//////////////////
// CALCULATUONS /{

atr = ta.atr(atr_len)
sl_value = mult * atr

tsl_price = 0.0
tsl_price :=  source > tsl_price[1] and source[1] > tsl_price[1] ? math.max(nz(tsl_price[1]), source - sl_value) : 
              source < tsl_price[1] and source[1] < tsl_price[1] ? math.min(nz(tsl_price[1]), source + sl_value) : 
              source > tsl_price[1] ? source - sl_value : 
              source + sl_value

in_date_range = not use_date_filter or (time >= start_time and time <= end_time)

buy  = ta.crossover(source, tsl_price) and barstate.isconfirmed
sell = ta.crossover(tsl_price, source) and barstate.isconfirmed

//}

///////////
// PLOTS /{

bull_color = color.new(color.green, 0)
bear_color = color.new(color.red, 0)

tsl_color  = bull_color
tsl_color := sell ? bear_color : buy ? bull_color : tsl_color[1]

barcolor(tsl_color, display = color_bars ? display.all : display.none)

plot(tsl_price, color = tsl_color, linewidth = 2, display = show_tsl ?  display.all : display.none )

plotshape(buy,  title = 'Buy',  text = 'Buy',  style = shape.labelup,   location = location.belowbar, 
 color = color.new(color.green, 0), textcolor = color.new(color.white, 0), size = size.tiny, display = show_signals ? display.all : display.none)

plotshape(sell, title = 'Sell', text = 'Sell', style = shape.labeldown, location = location.abovebar, 
 color = color.new(color.red, 0),   textcolor = color.new(color.white, 0), size = size.tiny, display = show_signals ? display.all : display.none)


//}

////////////
// ALERTS /{

if buy
    alert('UT Bot Buy', alert.freq_once_per_bar_close)

if sell 
    alert('UT Bot Sell', alert.freq_once_per_bar_close)

//}

//////////////
// STRATEGY /{

if buy and in_date_range
    strategy.entry("Long", strategy.long)

if sell and in_date_range
    strategy.entry('Short', strategy.short)

//}
````
