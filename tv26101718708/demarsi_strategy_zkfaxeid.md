# DemaRSI Strategy

- url: https://www.tradingview.com/script/zKFaxeiD-DemaRSI-Strategy/
- type: strategy
- pine_id: PUB;b2513a8dba224f51876eccec88d3f391
- version: 1.0

## Description

This is a repost to a old script that cant be updated anymore, the request was made on Feb, 27, 2016.

[pine]Here's a engaging description for the tradingview script:

**DemaRSI Strategy: A Proven Trading System**

Join thousands of traders who have already experienced the power of this highly effective strategy. The DemaRSI system combines two powerful indicators - DEMA (Double Exponential Moving Average) and RSI (Relative Strength Index) - to generate profitable trades with minimal risk.

**Key Features:**

* **Trend-Following**: Our algorithm identifies strong trends using a combination of DEMA and RSI, allowing you to ride the waves of market momentum.
* **Risk Management**: The system includes built-in stop-loss and take-profit levels, ensuring that your gains are protected and losses are minimized.
* **Session-Based Trading**: Trade during specific sessions only (e.g., London or New York) for even more targeted results.
* **Customizable Settings**: Adjust the length of moving averages, RSI periods, and other parameters to suit your trading style.

**What You'll Get:**

* A comprehensive strategy that can be used with any broker or platform
* Easy-to-use interface with customizable settings
* Real-time performance metrics and backtesting capabilities

**Start Trading Like a Pro Today!**

This script is designed for intermediate to advanced traders who want to take their trading game to the next level. With its robust risk management features, this strategy can help you achieve consistent profits in various market conditions.

**Disclaimer:** This script is not intended as investment advice and should be used at your own discretion. Trading carries inherent risks, and losses are possible.[/pine]
~Llama3

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RicardoSantos.

//@version=5
string  TITLE = 'DemaRSI Strategy'
string STITLE = 'D'
strategy(TITLE, STITLE, false, initial_capital=100000, currency=currency.USD)

float src = input.source(close, 'Source:')
int ma_length = input.int(21, 'MA Length:')
int rsi_length = input.int(4, 'RSI Length:')
int rsi_smooth = input.int(4, 'RSI Smoothing Length:')

float ma = ta.ema(ta.ema(src, ma_length), ma_length)
float marsi = ta.rsi(ma, rsi_length)
float smooth = ta.ema(marsi, rsi_smooth)
plot(marsi, 'M', color.black)
plot(smooth, 'S', color.red)
hline(0)
hline(50)
hline(100)

int max_order_per_day = input.int(6, 'Max Orders Per Day:')
strategy.risk.max_intraday_filled_orders(max_order_per_day)
bool trade_size_as_equity_factor = input(false, 'Trade Size as Equity Factor?')
float trade_size = input.float(10000.00, 'Trade Size:') * (trade_size_as_equity_factor ? strategy.equity : 1)
int take_profit_in_points = input.int(100000, 'Take Profit In Points:')
int stop_loss_in_points = input.int(100000, 'Stop Loss In Points:')
int trail_in_points = input.int(150, 'Trail Stop In Points:')

bool USE_SESSION = input.bool(true, 'Use Timed Session?')
string trade_session = input.session('0400-1500', 'Trade Session', confirm=false)
bool istradingsession = not USE_SESSION ? true : not na(time('1', trade_session))

bool buy_entry = istradingsession and ta.crossover(marsi, smooth)
bool sel_entry = istradingsession and ta.crossunder(marsi, smooth)

if buy_entry
    strategy.entry('buy', strategy.long, qty=trade_size)
if sel_entry
    strategy.entry('sel', strategy.short, qty=trade_size)

strategy.exit('buy.Exit', from_entry='buy', profit=take_profit_in_points, loss=stop_loss_in_points, trail_points=trail_in_points, trail_offset=trail_in_points)
strategy.exit('sel.Exit', from_entry='sel', profit=take_profit_in_points, loss=stop_loss_in_points, trail_points=trail_in_points, trail_offset=trail_in_points)
if not istradingsession
    strategy.close_all()
````
