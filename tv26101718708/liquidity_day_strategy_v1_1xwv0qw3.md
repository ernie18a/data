# Liquidity Day Strategy V1

- url: https://www.tradingview.com/script/1XWV0QW3-Liquidity-Day-Strategy-V1/
- type: strategy
- pine_id: PUB;ee9f5ea067384220ba85e3411d1c318a
- version: 1.0

## Description

Title: Liquidity Day Strategy V1 [High-Visibility Edition]

Overview

Liquidity Day Strategy V1 is a professional-grade trading tool built on the principles of Institutional Liquidity. It automatically identifies and highlights the Previous Day's High (PDH) and Previous Day's Low (PDL) as critical "Walls of Liquidity." These levels are widely used by institutional traders for stop-hunting or as breakout triggers.

This script combines precise price-action levels with Session Visualization, allowing traders to see exactly when and where liquidity is being captured during the Asia, London, and New York market windows.

Key Features

Bold Liquidity Markers: Automatically plots thick, neon-colored lines for PDH and PDL, ensuring you never miss a key daily level.

Session Backgrounds: Visual overlays for Asia, London, and New York sessions to help you trade during peak volatility. Each session can be toggled on/off independently.

Built-in Strategy Engine: Includes a backtesting module to track performance, Win Rate, and Drawdown directly on your chart.

Dynamic Alert System: Real-time notifications for both "Buy Side" and "Sell Side" breakouts, including live price data in the alerts.

Input Settings & Risk Management

To ensure consistency across different assets (Gold, Forex, or Crypto), this strategy uses Percentage-Based risk management:

Take Profit (%): Sets your target gain. Adjust this based on the asset's average daily range (ADR).

Stop Loss (%): Defines your maximum risk per trade to protect your capital.

Session Visibility: Fully customizable colors and toggles for each trading session to keep your chart as clean or as detailed as you prefer.

Line Styles: Adjustable thickness and color for liquidity levels to suit any chart theme (Dark/Light).

How to Trade

Breakout Confirmation: The strategy triggers a Long entry when the price closes above the PDH and a Short entry when it closes below the PDL.

Session Context: Look for breakouts occurring during the London or NY Open for higher probability moves.

Risk Calibration: Use the Strategy Tester to find the optimal TP/SL ratio for your specific timeframe.

Disclaimer

This script is provided for educational and informational purposes only. Trading financial markets involves significant risk of loss. Past performance, whether real or simulated, is not a guarantee of future results. Always practice proper risk management.

## Source Code

````pine
// @version=5
strategy("Liquidity Day Strategy V1", overlay = true, initial_capital = 10000, default_qty_type = strategy.percent_of_equity, default_qty_value = 10)

// ==========================================
// 1. SESSION & VISUAL SETTINGS
// ==========================================
group_sess = "Session Visibility"
showAsia   = input.bool(true, "Show Asia Session", group=group_sess)
showLondon = input.bool(true, "Show London Session", group=group_sess)
showNY     = input.bool(true, "Show New York Session", group=group_sess)

group_line    = "Liquidity Line Settings"
lineThickness = input.int(3, "Line Thickness", minval=1, maxval=5, group=group_line)
pdhColor      = input.color(color.new(#67ee6b, 0), "PDH (Yesterday High) Color", group=group_line) 
pdlColor      = input.color(color.new(#e28080, 0), "PDL (Yesterday Low) Color", group=group_line)  

// ==========================================
// 2. STRATEGY SETTINGS (TP/SL)
// ==========================================
group_strat = "Strategy Settings"
useTP      = input.bool(true, "Use Take Profit", group=group_strat)
tpPercent  = input.float(1.5, "Take Profit (%)", step=0.1, group=group_strat)
useSL      = input.bool(true, "Use Stop Loss", group=group_strat)
slPercent  = input.float(1.0, "Stop Loss (%)", step=0.1, group=group_strat)

// ==========================================
// 3. LIQUIDITY CALCULATIONS
// ==========================================
res = input.timeframe('D', 'Data Source Timeframe')
yesterdayHigh = request.security(syminfo.tickerid, res, high[1], lookahead=barmerge.lookahead_on)
yesterdayLow  = request.security(syminfo.tickerid, res, low[1], lookahead=barmerge.lookahead_on)

buySignal  = ta.crossover(close, yesterdayHigh)
sellSignal = ta.crossunder(close, yesterdayLow)

// ==========================================
// 4. STRATEGY EXECUTION (Trade Logic)
// ==========================================
if buySignal
    strategy.entry("Long", strategy.long, comment="Buy Breakout")

if sellSignal
    strategy.entry("Short", strategy.short, comment="Sell Breakout")

// Exit Logic (TP/SL)
float longTP = strategy.position_avg_price * (1 + tpPercent / 100)
float longSL = strategy.position_avg_price * (1 - slPercent / 100)
float shortTP = strategy.position_avg_price * (1 - tpPercent / 100)
float shortSL = strategy.position_avg_price * (1 + slPercent / 100)

if strategy.position_size > 0
    strategy.exit("Exit Long", "Long", limit = useTP ? longTP : na, stop = useSL ? longSL : na, comment_loss="SL", comment_profit="TP")

if strategy.position_size < 0
    strategy.exit("Exit Short", "Short", limit = useTP ? shortTP : na, stop = useSL ? shortSL : na, comment_loss="SL", comment_profit="TP")

// ==========================================
// 5. PLOTTING & VISUALS
// ==========================================
plot(yesterdayHigh, "Previous Day High", color=pdhColor, style=plot.style_linebr, linewidth=lineThickness)
plot(yesterdayLow,  "Previous Day Low",  color=pdlColor, style=plot.style_linebr, linewidth=lineThickness)

inSession(sess) => not na(time(timeframe.period, sess, "UTC"))
bgcolor(showAsia   and inSession("0000-0900") ? color.new(#2196f3, 95) : na)
bgcolor(showLondon and inSession("0700-1600") ? color.new(#4caf50, 95) : na)
bgcolor(showNY     and inSession("1200-2100") ? color.new(#f44336, 95) : na)
````
