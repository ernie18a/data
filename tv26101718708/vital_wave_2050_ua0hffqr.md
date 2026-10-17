# Vital Wave 20-50

- url: https://www.tradingview.com/script/Ua0HFFQR/
- type: strategy
- pine_id: PUB;06403f2babdb44d9a5892012948a67b2
- version: 1.0

## Description

Simplicity is almost always the most effective approach, and here I’m giving you a trend-following system that exploits the bullish bias of traditional markets and their trending nature, with very basic rules.


[b]Rules (long entries only)  [/b]

[b]• Market entry:[/b] When the EMA 20 crosses above the EMA 50 (from below)  

[b]• Main market exit:[/b] When the EMA 20 crosses below the EMA 50 (from above)  

[b]• Fixed Stop Loss:[/b] Placed at the price level of the Lower Bollinger Band at the moment the trade is entered.

In my strategy, the primary exit is when the EMA 20 crosses below the EMA 50. However, this crossover can sometimes take a while to occur, and in the meantime the price may have already dropped significantly. The Stop Loss based on the Lower Bollinger Band is designed to limit losses in case the market moves sharply against the position without giving the bearish crossover signal in time. Having two exit conditions makes the strategy much more robust in terms of risk management.


[b]Risk Management:[/b]

•[b] Initial capital:[/b] $10,000

• [b]Position size:[/b] 10% of available capital per trade

• [b]Commissions:[/b] 0.1% on traded volume

• [b]Stop Loss:[/b] Based on the Lower Bollinger Band

• [b]Take Profit / Exit:[/b] When EMA 20 crosses below EMA 50


Recommended Markets:

[b]XAUUSD (OANDA) (Daily)[/b]

Period: January 3, 1833 – November 23, 2025
Total Profit & Loss: +$6,030.62 USD (+57.57%)
Maximum Drawdown: $541.53 USD (3.83%)
Total Trades: 136
Winning Trades (Win Rate): 36.03% (49/136)
Profit Factor: 2.483

[b]XAUUSD (OANDA) (12-hour)[/b]
Period: March 19, 2006 – November 23, 2025
Total Profit & Loss: +$1,209.56 USD (+11.89%)
Maximum Drawdown: $384.58 USD (3.61%)
Total Trades: 97
Winning Trades (Win Rate): 35.05% (34/97)
Profit Factor: 1.676

[b]XAUUSD (OANDA) (8-hour)[/b]
Period: March 19, 2006 – November 23, 2025
Total Profit & Loss: +$1,179.36 USD (+11.81%)
Maximum Drawdown: $246.88 USD (2.32%)
Total Trades: 147
Winning Trades (Win Rate): 31.97% (47/147)
Profit Factor: 1.626

[b]Tesla (NASDAQ) (4-hour)[/b]
Period: June 29, 2010 – November 23, 2025
Total Profit & Loss (Absolute): +$11,687.90 USD (+116.88%)
Maximum Drawdown: $922.05 USD (6.50%)
Total Trades: 68
Winning Trades (Win Rate): 39.71% (27/68)
Profit Factor: 4.156

[b]Tesla (NASDAQ) (3-hour)[/b]
Total Profit & Loss: +$11,522.33 USD (+115.22%)
Maximum Drawdown: $1,247.60 USD (8.80%)
Total Trades: 114
Winning Trades: 33.33% (38/114)
Profit Factor: 2.811


[b]Additional Recommendations[/b]

(These assets have shown good trending behavior with the same strategy across multiple timeframes):  

•[b]NVDA[/b] (15 min, 30 min, 1h, 2h, 3h, 4h, 6h, 8h, 12h, Daily)  

•[b]NFLX[/b] (1h, 2h, 3h, 4h, 6h, 8h, 12h, Daily)  

•[b]MA[/b] (1h, 2h, 3h, 4h, 6h, 8h, 12h, Daily)  

•[b]META[/b] (1h, 2h, 3h, 4h, 6h, 8h, 12h, Daily)  

•[b]AAPL [/b](1h, 2h, 3h, 4h, 6h, 8h, 12h, Daily)  

•[b]SPY[/b] (12h, Daily)


[b]About the Code[/b]

The user can modify:
• EMA periods (20 and 50 by default)
• Bollinger Bands length (20 periods)
• Standard deviation (2.0)

[b]Visualization[/b]

• EMA 20: Blue line
• EMA 50: Red line
• Green background when EMA20 > EMA50 (bullish trend)
• Red background when EMA20 < EMA50 (bearish trend)


[b]Important Note:[/b]

We can significantly increase the profit factor and overall profitability by risking a fixed percentage per trade instead of a fixed amount. This would prevent losses from fluctuating with changes in volatility.

This could be implemented by reducing position size or adjusting leverage based on the volatility percentage required for each trade, but I’m not sure if this is fully possible in Pine Script. In my other script, “[b]Golden Cross 50/200 EMA[/b],” I go deeper into this topic and provide examples.

I hope you enjoy this contribution. Best regards!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Especulador96

// @version=5
strategy("Vital Wave 20-50", 
     overlay=true, 
     initial_capital=10000, 
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=10,
     commission_type=strategy.commission.percent, 
     commission_value=0.1)

// Inputs
ema20_length = input.int(20, "EMA 20 Period")
ema50_length = input.int(50, "EMA 50 Period")
bb_length = input.int(20, "Bollinger Bands Length")
bb_std = input.float(2.0, "Bollinger Bands Std Dev")

// Calculating EMAs
ema20 = ta.ema(close, ema20_length)
ema50 = ta.ema(close, ema50_length)

// Bollinger Bands
bb_basis = ta.sma(close, bb_length)
bb_dev = bb_std * ta.stdev(close, bb_length)
bb_lower = bb_basis - bb_dev

// Crossover conditions
ema20_cross_above_ema50 = ta.crossover(ema20, ema50)
ema20_cross_below_ema50 = ta.crossunder(ema20, ema50)

// Stop Loss Level
var float stopLossLevel = na

// Strategy Logic
if (ema20_cross_above_ema50)
    strategy.entry("Long", strategy.long)
    stopLossLevel := bb_lower
    label.new(bar_index, bb_lower, "SL", color=color.red, style=label.style_label_up, 
             textcolor=color.white, size=size.small)

if (ema20_cross_below_ema50)
    strategy.close("Long")
    stopLossLevel := na

// Stop Loss on TOUCH (using intrabar low)
if (strategy.position_size > 0 and low <= stopLossLevel)
    strategy.close("Long", comment="Stop Loss")
    stopLossLevel := na

// Plotting
plot(ema20, color=color.rgb(10, 94, 163), linewidth=2, title="EMA 20")
plot(ema50, color=color.rgb(187, 22, 22), linewidth=2, title="EMA 50")
bgcolor(ema20 > ema50 ? color.new(color.green, 95) : color.new(color.red, 95))
````
