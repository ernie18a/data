# Chande Momentum Oscillator (CMO) Buy Sell Strategy [TradeDots]

- url: https://www.tradingview.com/script/MNBZqC72-Chande-Momentum-Oscillator-CMO-Buy-Sell-Strategy-TradeDots/
- type: strategy
- pine_id: PUB;c149f82984b94f7cbd9e16146cc31034
- version: 4.0

## Description

The "Chande Momentum Oscillator (CMO) Buy Sell Strategy" leverages the CMO indicator to identify short-term buy and sell opportunities.

[b]HOW DOES IT WORK[/b]

The standard CMO indicator measures the difference between recent gains and losses, divided by the total price movement over the same period. However, this version of the CMO has some limitations.

The primary disadvantage of the original CMO is its responsiveness to short-term volatility, making the signals less smooth and more erratic, especially in fluctuating markets. This instability can lead to misleading buy or sell signals.

To address this, we integrated the concept from the Moving Average Convergence Divergence (MACD) indicator. By applying a 9-period exponential moving average (EMA) to the CMO line, we obtained a smoothed signal line. This line acts as a filter, identifying confirmed overbought or oversold states, thereby reducing the number of false signals.

Similar to the MACD histogram, we generate columns representing the difference between the CMO and its signal line, reflecting market momentum. We use this momentum indicator as a criterion for entry and exit points. Trades are executed when there's a convergence of CMO and signal lines during an oversold state, and they are closed when the CMO line diverges from the signal line, indicating increased selling pressure.

[b]APPLICATION[/b]

Since the 9-period EMA smooths the CMO line, it's less susceptible to extreme price fluctuations. However, this smoothing also makes it more challenging to breach the original +50 and -50 benchmarks.

To increase trading opportunities, we've tightened the boundary ranges. Users can customize the target benchmark lines in the settings to adjust for the volatility of the underlying asset.

The 'cool down period' is essentially the number of bars that await before the next signal generation. This feature is employed to dodge the occurrence of multiple signals in a short period.

[b]DEFAULT SETUP[/b]

Commission: 0.01%
Initial Capital: $10,000
Equity per Trade: 80%
Signal Cool Down Period: 5

[b]RISK DISCLAIMER[/b]

Trading entails substantial risk, and most day traders incur losses. All content, tools, scripts, articles, and education provided by TradeDots serve purely informational and educational purposes. Past performances are not definitive predictors of future results.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradedots

//@version=5
strategy("Chande Momentum Oscillator (CMO) Buy Sell Strategy [TradeDots]", overlay=false, max_lines_count = 500, max_boxes_count = 100, initial_capital = 10000, currency = currency.USD, commission_type = strategy.commission.percent, commission_value = 0.01, default_qty_type = strategy.percent_of_equity, default_qty_value = 80)

// user input
enable_backtest     = input.bool(defval = true, title = "Enable Backtest")
source              = input(close, "Source", group = "Chande Momentum Oscillator")
length              = input(9, "CMO Length", group = "Chande Momentum Oscillator")
order_direction     = input.string("Long & Short", "Order Direction", ["Long & Short", "Long Only", "Short Only"], group = "Strategy")
cool_down_period    = input.int(defval = 5, title = "Signal Cool Down Period", minval = 1, step = 1, group = "Strategy")
overbought_tresh    = input(40, "Selling Threshold", group = "Strategy")
oversold_tresh      = input(-40, "Buying Threshold", group = "Strategy")

// var
var int buy_counter  = cool_down_period
var int sell_counter = cool_down_period

// cmo 
cmo                 = ta.cmo(source, length)

// EMA 
signal              = ta.ema(cmo, 9)

// hist
hist                = cmo - signal

//hist coloring
histA_IsUp          = hist > hist[1] and hist > 0
histA_IsDown        = hist < hist[1] and hist > 0
histB_IsDown        = hist < hist[1] and hist <= 0
histB_IsUp          = hist > hist[1] and hist <= 0
hist_color          = histA_IsUp ? #38a3a5 : histA_IsDown ? #cbf3f0 : histB_IsDown ? #0096c7 : histB_IsUp ? #ade8f4 : color.gray

// plotting
plot(cmo, "CMO Line", color = #9cff87)
plot(signal, "CMO Signal Line", color = #f9396a)
plot(hist, "CMO Hist", color = hist_color, style=plot.style_columns,  linewidth = 5)

plot(overbought_tresh, "Selling Threshold", color = color.from_gradient(cmo, 0, overbought_tresh, color.new(color.gray, 70), color.new(#f9396a, 0)), linewidth = 2)
plot(oversold_tresh, "Buying Threshold", color = color.from_gradient(cmo, oversold_tresh, 0, color.new(#9cff87, 0), color.new(color.gray, 70)), linewidth = 2)

// reference line
hline(overbought_tresh, title = "Overbought Threshold")
hline(0, title = "0 Line")
hline(oversold_tresh, title = "Oversold Threshold")

// Strategy entry condition
if signal > overbought_tresh and histA_IsDown and order_direction != "Long Only"
    if sell_counter >= cool_down_period
        label.new(bar_index, signal, text = "🔴", style = label.style_label_down, color = #f9396a, textcolor = #ffffff)
        if enable_backtest
            strategy.entry("Sell", strategy.short, comment = "Open Short Position")
        
        sell_counter := 0
        buy_counter := cool_down_period 
    else 
        sell_counter := sell_counter + 1

else if signal < oversold_tresh and histB_IsUp and order_direction != "Short Only"
    if buy_counter >= cool_down_period
        label.new(bar_index, signal, text = "🟢", style = label.style_label_up, color = #9cff87)
        if enable_backtest
            strategy.entry("Buy", strategy.long, comment = "Open Long Position")
        buy_counter := 0
        sell_counter := cool_down_period
    else
        buy_counter := buy_counter + 1

// Stategy exit
if enable_backtest
    if signal > overbought_tresh and strategy.opentrades.size(strategy.opentrades - 1) > 0
        strategy.close("Buy", qty_percent = 100, comment = "Close Long Position")
        label.new(bar_index, signal, text = "Close", style = label.style_label_down, color = #f9396a, textcolor = #ffffff)
        buy_counter := cool_down_period 
        
    else if signal < oversold_tresh and strategy.opentrades.size(strategy.opentrades - 1) < 0
        strategy.close("Sell", qty_percent = 100, comment = "Close Short Position")
        label.new(bar_index, signal, text = "Close", style = label.style_label_up, color = #9cff87)
        sell_counter := cool_down_period

//reset cool down period after signal line back to normal state
if signal < overbought_tresh 
    sell_counter := cool_down_period

if signal > oversold_tresh
    buy_counter := cool_down_period
````
