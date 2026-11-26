# Sensex 500-Point Institutional Breakout

- url: https://www.tradingview.com/script/9ivEXFNq-Sensex-500-Point-Institutional-Breakout/
- type: strategy
- pine_id: PUB;f982bc462f844becb595ab84dae9d0f6
- version: 1.0

## Description

[b]The Concept[/b]
This strategy is built for the BSE Sensex, specifically targeting institutional liquidity clusters at 500-point round numbers (e.g., 72,000, 72,500, 73,000). These psychological levels often act as "magnets" or "break points" for large-scale orders.

The script captures the momentum once the initial 30 minutes of market "noise" settles, identifying a clear range and executing trades based on clean 5-minute candle breakouts.

[b]📈 Backtest Performance (SENSEX 5M)[/b]

Net Profit: +14.37% 

Profit Factor: 1.474 (Gross profits are ~1.5x gross losses)

Max Drawdown: 3.51% (High capital protection)

Avg Win/Loss Ratio: 3.167 

[b]Key Takeaways[/b]

Extreme Reward-to-Risk: This strategy operates on a 1:5 initial R/R. Even with a 29% win rate, the system is highly profitable because the average winning trade is 3x larger than the average loss.

Disciplined Recovery: The 5-trade daily limit acts as a circuit breaker. It allows enough attempts to catch a genuine breakout while capping daily risk at ~500 points during "choppy" sessions.

Capital Efficiency: The low drawdown (3.51%) makes this suitable for larger capital allocation, focusing on high-conviction institutional levels rather than over-trading.

[b]Core Logic[/b]
The 9:45 AM Level Lock: At exactly 9:45 AM IST, the script calculates the two nearest 500-point round numbers based on the current price. These become your North and South "Battle Lines" for the day.

Momentum Entry: Unlike standard breakout scripts that wait for a "retest," this script enters a Long the moment a candle closes at or above the upper level, or Short when it closes at or below the lower level.

Profit Target: A fixed 500-point target (the next major round number).

[b]Risk Management (The "Smart Guard")[/b]
Initial Stop Loss: 100 points (1:5 Risk/Reward ratio).

The 200-Point Break-Even Rule: Once the trade moves 200 points in your favor, the Stop Loss automatically moves to the Entry Price. This ensures that a "near-hit" on your target doesn't turn into a losing trade.

The 5-Trade Circuit Breaker: To prevent "getting chopped" on sideways days, the script allows a maximum of 5 trades per day. If the market hits your SL 5 times, the script shuts down for the session to preserve capital.

Intraday Square-off: All positions are automatically closed at 3:25 PM IST to avoid overnight gap risks.

[b]Visual Features[/b]
Dynamic Labels: Every trade is labeled on the chart (e.g., "Trade 1/5") so you can see your daily limit status at a glance.

Visual SL Marker: A red cross follows your active Stop Loss, showing you exactly when the Break-Even trigger has been activated.

Target Lines: Clear blue/orange lines indicate your 500-point profit zones.

[b]How to Use[/b]
Timeframe: 5-Minute (Best for Sensex volatility).

Instrument: SENSEX / BSN.

Inputs: You can customize the number of trades (2, 3, or 5) and the point increments in the settings menu.

[b]Author's Note[/b]
This strategy is designed for traders who believe in "fighting for the level." On trending days, it catches the 500-point move early. On choppy days, the 5-trade limit ensures you don't over-trade your account into the ground. Best used in conjunction with Volume analysis.

## Source Code

````pine
//@version=5
strategy("Sensex 9:45 3-Trade Limit Breakout", overlay=true, initial_capital=100000)

// --- Inputs ---
increment = input.int(500, "Round Number Increment")
sl_points = input.int(100, "Initial SL")
be_trigger = input.int(200, "Move to BE Trigger")
max_trades = input.int(3, "Max Trades Per Day") // Default set to 3
session_start_hour = input.int(9, "Start Hour")
session_start_min = input.int(45, "Start Minute")

// --- Variables ---
var float upper_level = na
var float lower_level = na
var float tp_upper = na
var float tp_lower = na
var float active_sl = na
var bool trail_activated = false
var int trade_count = 0 

// --- Time Logic ---
is_start_time = hour == session_start_hour and minute == session_start_min
can_trade = time(timeframe.period, "0945-1515") 
is_new_day = ta.change(time("D")) != 0

// --- Level Calculation & Daily Reset ---
if is_start_time
    current_price = open
    lower_level := math.floor(current_price / increment) * increment
    upper_level := math.ceil(current_price / increment) * increment
    tp_upper := upper_level + increment
    tp_lower := lower_level - increment
    trail_activated := false 
    trade_count := 0 

// --- Strategy Conditions ---
longCondition = not is_start_time and close >= upper_level and can_trade and strategy.position_size == 0 and trade_count < max_trades
shortCondition = not is_start_time and close <= lower_level and can_trade and strategy.position_size == 0 and trade_count < max_trades

// --- Entry Logic ---
if (longCondition)
    strategy.entry("Long", strategy.long)
    active_sl := close - sl_points
    trail_activated := false
    trade_count += 1 
    label.new(bar_index, high, "Trade " + str.tostring(trade_count) + "/" + str.tostring(max_trades), color=color.green, textcolor=color.white, style=label.style_label_down)

if (shortCondition)
    strategy.entry("Short", strategy.short)
    active_sl := close + sl_points
    trail_activated := false
    trade_count += 1 
    label.new(bar_index, low, "Trade " + str.tostring(trade_count) + "/" + str.tostring(max_trades), color=color.red, textcolor=color.white, style=label.style_label_up)

// --- Trailing SL Logic ---
if strategy.position_size > 0 
    if not trail_activated and high >= strategy.position_avg_price + be_trigger
        active_sl := strategy.position_avg_price 
        trail_activated := true

if strategy.position_size < 0 
    if not trail_activated and low <= strategy.position_avg_price - be_trigger
        active_sl := strategy.position_avg_price 
        trail_activated := true

// --- Exits ---
if strategy.position_size != 0
    strategy.exit("Exit", limit=(strategy.position_size > 0 ? tp_upper : tp_lower), stop=active_sl)

if time(timeframe.period, "1525-1530")
    strategy.close_all("EOD")

// --- Plotting ---
plot(upper_level, "Entry High", color=color.new(color.green, 0), style=plot.style_linebr, linewidth=2)
plot(lower_level, "Entry Low", color=color.new(color.red, 0), style=plot.style_linebr, linewidth=2)
plot(strategy.position_size != 0 ? active_sl : na, "SL", color=color.red, style=plot.style_cross, linewidth=3)
````
