# ATR_RSI_Strategy v2 with no repaint [liwei666]

- url: https://www.tradingview.com/script/mqh6UJ9p-ATR-RSI-Strategy-v2-with-no-repaint-liwei666/
- type: strategy
- pine_id: PUB;4eb69f4b1eac466bb974ad22a095428b
- version: 5.0

## Description

🎲 Overview

🎯 this is a optimized version based on ATR_RSI_Strategy with no-repaint. 
Sharpe ratio: 1.4, trade times: 116 ,
trade symbol: [symbol="BINANCE:BTCUSDTPERP"]BINANCE:BTCUSDTPERP[/symbol] 15M
you can get same backtesting result with the correct settings.

🎲 Strategy Logic

🎯 the core logic is quite simple, use ATR and RSI and SMA
1. when price is in high volatility ( atr_value > atr_ma);
2. wait for a break signal (rsi_value > rsi_buy or rsi_value < rsi_sell);
3. entry Long or Short,use trailing stop-loss to max security and percent TP to keep profit.

🎲 Settings

🎯 there are 7 input properties in script, but I only[b] finetune 4 of them[/b] ([b]bold field below[/b]),
you may change other parameter to get better result by yourself.

[list]
[*]atr_length: length to get atr value
[*][b]atr_ma_length[/b]: length of smoothing atr value
[*][b]atr_ma_norm_min[/b]: atr_ma normalized min value, filter high volatility ranges
[*][b]atr_ma_norm_max[/b]: atr_ma normalized max value, filter high volatility ranges
[*][b]rsi_length[/b]: length to get rsi value
[*]rsi_entry: 50 +/- rsi_entry to get entry threshold
[*]trailing_percent: trailing stop-loss percent
[/list]

🎲 Usage

🎯 the [b]commission set to 0.05%[/b], part of exchange the commission is less than 0.05% in reality,
but I will still use 0.05% in my next script.

🎯 this script use 50% of equity to size positions follow general script position,
you can adjust the value to fix size or 100% of equity to compare result with other strategy,
but I still suggest you use 5-10% of equity for each strategy in reality.

🎯any questions please comment below. if there are any words violate House Rule, please tell me below and i will revise immediately
don't want be hiddened again 😂😂

Additionally, I plan to publish 20 profitable strategies in 2023;
let‘s witness it together!

Hope this strategy will be usefull for you :)

enjoy!   🚀🚀🚀

## Source Code

````pine
// © liwei666
//@version=5
// # ========================================================================= #
// #                   |   Strategy  |
// # ========================================================================= #
strategy(
 title                = "ATR_RSI_Strategy v2[liwei666]",
 shorttitle           = "ATR_RSI_Strategy",
 overlay              =  true,
 max_lines_count                 =  500, 
 max_labels_count                =  500, 
 max_boxes_count                 =  500,
 max_bars_back = 5000,
 initial_capital = 10000,
 default_qty_type=strategy.percent_of_equity, 
 default_qty_value=10, commission_type=strategy.commission.percent, pyramiding=1, 
 commission_value=0.05
 )
// # ========================================================================= #
// #                   |   Strategy  |
// # ========================================================================= #

atr_length  = input.int(26, "atr_length", minval = 6, maxval = 100, step=1)
atr_ma_length = input.int(45, "atr_ma_length", minval = 6, maxval = 100, step=1)
rsi_length = input.int(15, "rsi_length", minval = 6, maxval = 100, step=1)
rsi_entry = input.int(10, "rsi_entry", minval = 6, maxval = 100, step=1)
atr_ma_norm_min = input.float(0.3, "atr_ma_norm_min", minval = 0.1, maxval = 0.5, step=0.1)
atr_ma_norm_max = input.float(0.7, "atr_ma_norm_max", minval = 0.5, maxval = 1, step=0.1)
trailing_percent= input.float(1.5, "trailing_stop_percent", minval = 0.1, maxval = 2, step=0.1)

var rsi_buy = 50 + rsi_entry
var rsi_sell = 50 - rsi_entry

sma_norm_h_45() => 
    source = high
    n = 45
    sma = ta.sma(source, n) 
    sma_norm = (sma - ta.lowest(sma, n)) / (ta.highest(sma,n) - ta.lowest(sma, n))
    sma_norm

atr_value = ta.atr(atr_length)
atr_ma = ta.sma(atr_value, atr_ma_length) 
rsi_value = ta.rsi(close, length = rsi_length) 
atr_ma_norm = atr_ma / close * 100
sma_norm = sma_norm_h_45()

var intra_trade_high = 0.0
var intra_trade_low = 0.0
var long_sl = 0.0
var long_tp = 0.0
var short_sl = 0.0
var short_tp = 0.0

if strategy.position_size == 0
    intra_trade_high := high
    intra_trade_low := low
    // when in living trading, enter after freq_once_per_bar_close
    if atr_ma_norm >= atr_ma_norm_min and atr_ma_norm <= atr_ma_norm_max
        if atr_value > atr_ma
            if rsi_value > rsi_buy
                strategy.entry("B1", strategy.long, limit = close + 5 )
                alert("Long B1", alert.freq_once_per_bar_close)
            else if rsi_value < rsi_sell
                strategy.entry("S1", strategy.short, limit = close - 5 )
                alert("Short S1", alert.freq_once_per_bar_close)

else if strategy.position_size > 0
    intra_trade_high := math.max(intra_trade_high, high)
    intra_trade_low := low

    long_sl := intra_trade_high * (1 - trailing_percent / 100)
    long_tp := strategy.position_avg_price * 1.03
    strategy.exit("Exit B1", from_entry="B1", stop = long_sl, limit = long_tp)

else if strategy.position_size < 0
    intra_trade_high := high
    intra_trade_low := math.min(intra_trade_low, low) 

    short_sl := intra_trade_low * (1 + trailing_percent / 100)
    short_tp := strategy.position_avg_price * 0.94
    strategy.exit("Exit S1", from_entry="S1", stop = short_sl, limit = short_tp)


// when in living trading, SL and TP should use freq_once_per_bar
// you can compare with trade_list of backtest result
// long Exit alert
if strategy.position_size > 0 and low < long_sl
    alert("B1 Stop_loss", alert.freq_once_per_bar)
else if strategy.position_size > 0 and high > long_tp
    alert("B1 Take_profit", alert.freq_once_per_bar) 

// short Exit alert
if strategy.position_size < 0 and high > short_sl
    alert("S1 Stop_loss", alert.freq_once_per_bar)
else if strategy.position_size > 0 and low < short_tp
    alert("S1 Take_profit", alert.freq_once_per_bar)
````
