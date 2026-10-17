# Advanced DCA Bot

- url: https://www.tradingview.com/script/0GhXXwWS-Advanced-DCA-Bot/
- type: strategy
- pine_id: PUB;5f5d5f7165304e528c7b64e8f9243ae5
- version: 1.0

## Description

A DCA (Dollar Cost Averaging) bot is designed to "average down" on a losing position. Instead of selling when the price drops, the bot buys more at lower prices, which lowers your Break-Even Price. When the price eventually bounces, the bot sells the entire "bag" for a profit.

Because Pine Script is primarily for visualization, a "bot" here means a Strategy that you can backtest or connect to a real exchange via Webhooks.
The DCA Strategy Logic:
Entry: Enter a trade based on an indicator (e.g., RSI Oversold).
DCA Trigger: If the price drops by X% set by user
DCA Multiplier: Each subsequent buy can be larger than the previous one (e.g., 1x, 1.5x, 2x) to move the break-even point faster.
Take Profit: Sell the entire position when the average price reaches a  profit target.
Max Safety: Stop buying after # number of attempts to prevent blowing the account  set by the user


Key Features Explained:
1. The DCA Multiplier (The "Martingale" Lite)
The dca_multiplier is crucial. If you buy $100 worth of Bitcoin:

DCA 1: You buy $150 worth (1.5x).
DCA 2: You buy $225 worth ($150 * 1.5). This aggressively lowers your average price. If the price only recovers a little bit, you are already in profit because your "heavy" buys were at the bottom.
2. The last_entry_price Variable
The bot doesn't just buy every time the price is low. It looks for a specific drop from your last action. This prevents the bot from "stacking" 5 trades in a single second during a flash crash.

3. Break-Even Visualization
I added plot commands so you can see three lines on your chart when a trade is active:

White Line: Your current Average Entry Price.
Green Line: Your Target Profit.
Red Line: Where the bot is "waiting" to trigger the next DCA buy.
How to test this properly:
Backtesting: Use the "Strategy Tester" tab in TradingView. Look for Max Drawdown. DCA bots can have very high drawdowns because they hold losing positions for a long time.
Paper Trading: Run it on TradingView's Paper Trading feature for a week to ensure the DCA levels trigger exactly where you expect.
Live Execution: To make this a real "bot," you need to:
Create an Alert on the Strategy.
Use a Webhook URL from a service 
The script will send a JSON payload to the service, which will then execute the buy/sell on your exchange .

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fullmax


//@version=6
strategy('Advanced DCA Bot', overlay = true,pyramiding = 20)

// --- INPUTS ---
// Initial Entry Settings
rsi_length = input.int(14, 'RSI Length')
rsi_oversold = input.int(30, 'RSI Oversold Level')

// DCA Settings
base_qty = input.int(100, 'Start order qty in usdc-usdt', minval = 1)
dca_drop_pct = input.float(5.0, 'Price Drop to Trigger DCA (%)', minval = 0.1) / 100
dca_multiplier = input.float(1.5, 'DCA Multiplier (Size of next buy)', minval = 1.0)
max_dcas = input.int(5, 'Maximum DCA Steps', minval = 1)

// Take Profit Settings
tp_pct = input.float(3.0, 'Take Profit % from Average Price', minval = 0.1) / 100

// --- STATE VARIABLES ---
var float last_entry_price = na
var int dca_count = 0
var float current_base_qty = base_qty// Starting % of equity

// --- CALCULATIONS ---
rsi = ta.rsi(close, rsi_length)
avg_price = strategy.position_avg_price

// --- STRATEGY LOGIC ---

// 1. INITIAL ENTRY
// Enter the first trade when RSI is oversold and we have no open position
if ta.crossunder(rsi, rsi_oversold) and strategy.position_size == 0
    strategy.entry('Initial_Entry', strategy.long, qty = current_base_qty)
    last_entry_price := close
    dca_count := 0
    dca_count

// 2. DCA LOGIC
// If we are in a trade and the price drops by X% from the last entry
if strategy.position_size > 0 and dca_count < max_dcas
    float drop_threshold = last_entry_price * (1 - dca_drop_pct)

    if close <= drop_threshold
        dca_count := dca_count + 1
        // Calculate new quantity based on multiplier
        float next_qty = current_base_qty * math.pow(dca_multiplier, dca_count)

        strategy.entry('DCA_' + str.tostring(dca_count), strategy.long, qty = next_qty)
        last_entry_price := close

        // Log to chart for debugging
        label.new(bar_index, high, 'DCA #' + str.tostring(dca_count), color = color.orange, textcolor = color.white)

// 3. TAKE PROFIT LOGIC
// Exit everything when the current price is X% above the average entry price
if strategy.position_size > 0
    float tp_price = avg_price * (1 + tp_pct)

    if close >= tp_price
        strategy.close_all(comment = 'Take Profit Hit')
        // Reset variables for the next cycle
        dca_count := 0
        last_entry_price := na
        last_entry_price

// --- VISUALIZATION ---
plot(strategy.position_size > 0 ? avg_price : na, 'Average Price', color = color.white, style = plot.style_linebr, linewidth = 2)
plot(strategy.position_size > 0 ? avg_price * (1 + tp_pct) : na, 'Take Profit Level', color = color.green, style = plot.style_linebr, linewidth = 2)
plot(strategy.position_size > 0 ? last_entry_price * (1 - dca_drop_pct) : na, 'Next DCA Level', color = color.red, style = plot.style_linebr, linewidth = 1)
````
