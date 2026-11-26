# TrendSync Pro (SMC)

- url: https://www.tradingview.com/script/5gjSs3NM-TrendSync-Pro-SMC/
- type: strategy
- pine_id: PUB;5c737d20bbd4491db73d8ccc660f9430
- version: 1.0

## Description

[b]📊 TrendSync Pro (SMC) – Advanced Trend-Following Strategy with HTF Alignment[/b]
Created by [i]Shubham Singh[/i]

[b]🔍 Strategy Overview[/b]
TrendSync Pro (SMC) is a precision-based smart trend-following strategy inspired by Smart Money Concepts (SMC). It combines: [list] [] Real-time pivot-based trendline detection
[] Higher Time Frame (HTF) filtering to align trades with dominant trend
[] Risk management via adjustable Stop Loss (SL) and Take Profit (TP)
[] Directional control — trade only bullish, bearish, or both setups
[] Realistic backtesting using commissions and slippage
[] Pre-optimized profiles for scalpers, intraday, swing, and long-term traders
[/list]

[b]🧠 How It Works:[/b]

[b]🔧 Strategy Settings Image:[/b]  
[url=https://beeimg.com/images/i24866300893.png]https://beeimg.com/images/i24866300893.png[/url]


The strategy dynamically identifies trend direction by using swing high/low pivots. When a new pivot forms: [list] [] It draws a trendline from the last significant pivot
[] Detects whether the trend is up (based on pivot lows) or down (based on pivot highs)
[] Waits for price to break above/below the trendline
[] Confirms with HTF price direction (HTF close > previous HTF close = bullish)
[] Only then it triggers a long or short trade
[] It exits either at TP, SL, or a manual trendline break
[/list]

[b]🛠️ Adjustable Parameters:[/b]
[list] [] [b]Trend Period:[/b] Length for pivot detection (affects sensitivity of trendlines)
[] [b]HTF Timeframe:[/b] Aligns lower timeframe entries with higher timeframe direction
[] [b]SL% and TP%:[/b] Customize your risk-reward profile
[] [b]Commission & Slippage:[/b] Make backtests more realistic
[*] [b]Trade Direction:[/b] Choose to trade: [i]Long only, Short only, or Both[/i]
[/list]

[b]🎛️ Trade Direction Control:[/b]
In settings, you can choose: [list] [] [b]Bullish Only:[/b] Executes only long entries
[] [b]Bearish Only:[/b] Executes only short entries
[*] [b]Both:[/b] Executes both long and short entries when conditions are met
[/list]

[i]This allows you to align trades with your own market bias or external analysis.[/i]

[b]📈 Entry Logic:[/b] [list] [*] [b]Long Entry:[/b]
 • Price crosses above trendline
 • HTF is bullish (HTF close > previous close)
 • Latest pivot is a [i]low[/i] (trend is considered up)

[*] [b]Short Entry:[/b]
 • Price crosses below trendline
 • HTF is bearish (HTF close < previous close)
 • Latest pivot is a [i]high[/i] (trend is considered down)
[/list]

[b]📉 Exit Logic:[/b] [list] [] Hit Take Profit or Stop Loss
[] Manual trendline invalidation: If price crosses opposite of the trend direction
[/list]

[b]⏰ Best Timeframes & Recommended Settings:[/b]

[list] [*][b]Scalping (1m to 5m):[/b]
 HTF = 15m | Trend Period = 7
 SL = 0.5% | TP = 1% to 2%

[*][b]Intraday (15m to 30m):[/b]
 HTF = 1H | Trend Period = 10–14
 SL = 0.75% | TP = 2% to 3%

[*][b]6 Hour Trading (30m to 1H):[/b]
 HTF = 4H | Trend Period = 20
 SL = 1% | TP = 4% to 6%

[*][b]Swing Trading (4H to 1D):[/b]
 HTF = 1D | Trend Period = 35
 SL = 2% | TP = 8% to 12%

[*][b]Long-Term Investing (1D+):[/b]
 HTF = 1W | Trend Period = 50
 SL = 3% | TP = 15%+
[/list]

[i]Note: These are recommended base settings. Adjust based on volatility, asset class, or personal trading style.[/i]

[b]📸 Testing Note:[/b]

[url=https://beeimg.com/images/n08397397562.png]https://beeimg.com/images/n08397397562.png[/url]

TradingView limits test length to 20k bars (~40 trades on smaller timeframes). To show long-term results: [list] [] Test on higher timeframes (e.g., 1H, 4H, 1D)
[] Share images of backtest result in description
[*] Host longer test result screenshots on Imgur or any public drive
[/list]

[b]📍 Asset Behavior Insight:[/b]
This strategy works on multiple assets, including BTC, ETH, etc.
Performance varies by trend strength:
[list] [] Sometimes BTC performs better than ETH
[] Other times ETH gives better results
[*] That’s normal as both assets follow different volatility and trend behavior
[/list]
[i]It’s a trend-following setup. Longer and clearer the trend → better the results.[/i]

[b]✅ Best Practices:[/b] [list] [] Avoid ranging markets
[] Use proper SL/TP for each timeframe
[] Use directional filter if you already have a directional bias
[] Always forward test before going live
[/list]

[b]⚠️ Trading Disclaimer:[/b]
This script is for educational and backtesting purposes only. Trading involves risk. Always use risk management and never invest more than you can afford to lose.

## Source Code

````pine
//@version=6
strategy('TrendSync Pro (SMC)', overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=1, commission_type=strategy.commission.percent, commission_value=0.075)

// === Created by Shubham Singh ===

// === Strategy Mode ===
strategy_type = input.string("6H Trading", title="Strategy Type", options=["Scalping", "6H Trading", "Long-Term"], group="Strategy Mode")

// === Default Values Based on Strategy Type ===
default_trend_period = strategy_type == "Scalping"   ? 7  :
                       strategy_type == "Long-Term"  ? 35 :
                                                       20
default_htf         = strategy_type == "Scalping"   ? "15"  :
                       strategy_type == "Long-Term" ? "D"   :
                                                       "60"
default_sl_percent  = strategy_type == "Scalping"   ? 0.5  :
                       strategy_type == "Long-Term" ? 2.0  :
                                                       1.0
default_tp_percent  = strategy_type == "Scalping"   ? 1.0  :
                       strategy_type == "Long-Term" ? 10.0 :
                                                       5.0

// === Manual Overrides ===
override_trend = input.bool(false, "Override Trend Period", group="Manual Settings")
trend_period   = override_trend ? input.int(20, "Manual Trend Period", minval=1, group="Manual Settings") : default_trend_period

override_htf = input.bool(false, "Override HTF", group="Manual Settings")
htf          = override_htf ? input.timeframe("60", "Manual HTF", group="Manual Settings") : default_htf

override_risk = input.bool(false, "Override SL/TP", group="Manual Settings")
sl_percent    = override_risk ? input.float(1.0, "Manual Stop Loss (%)", minval=0.1, maxval=10, step=0.1, group="Manual Settings") : default_sl_percent
tp_percent    = override_risk ? input.float(2.0, "Manual Take Profit (%)", minval=0.1, maxval=20, step=0.1, group="Manual Settings") : default_tp_percent

// === Trade Direction Option ===
trade_dir = input.string("Both", title="Trade Direction", options=["Both", "Bullish Only", "Bearish Only"], group="Strategy Mode")

// === Visual Settings ===
show_trendlines = input.bool(true, "Show Trendlines", group="Visual Settings")

// === Trendline Detection ===
var line trendline = na
var float trend_value = na
var bool trend_direction_up = false

pivot_high = ta.pivothigh(high, trend_period, trend_period)
pivot_low = ta.pivotlow(low, trend_period, trend_period)

if not na(pivot_high)
    trend_value := pivot_high
    trend_direction_up := false
    if show_trendlines
        trendline := line.new(bar_index[trend_period], pivot_high, bar_index, high, color=color.new(color.blue, 50), width=2)

if not na(pivot_low)
    trend_value := pivot_low
    trend_direction_up := true
    if show_trendlines
        trendline := line.new(bar_index[trend_period], pivot_low, bar_index, low, color=color.new(color.red, 50), width=2)

// === Higher Timeframe Trend ===
htf_close = request.security(syminfo.tickerid, htf, close)
htf_trend_up = htf_close > htf_close[1]
htf_trend_down = htf_close < htf_close[1]

// === Trade Logic ===
long_condition = ta.crossover(close, trend_value) and htf_trend_up and trend_direction_up
short_condition = ta.crossunder(close, trend_value) and htf_trend_down and not trend_direction_up

take_long = (trade_dir == "Both" or trade_dir == "Bullish Only") and long_condition
take_short = (trade_dir == "Both" or trade_dir == "Bearish Only") and short_condition

// === Entry/Exit ===
if strategy.position_size == 0
    if take_long
        strategy.entry("Long", strategy.long)
        strategy.exit("Long Exit", "Long", stop=close * (1 - sl_percent / 100), limit=close * (1 + tp_percent / 100))
    
    if take_short
        strategy.entry("Short", strategy.short)
        strategy.exit("Short Exit", "Short", stop=close * (1 + sl_percent / 100), limit=close * (1 - tp_percent / 100))

// === Manual Exit ===
if strategy.position_size > 0 and ta.crossunder(close, trend_value)
    strategy.close("Long")
if strategy.position_size < 0 and ta.crossover(close, trend_value)
    strategy.close("Short")
````
