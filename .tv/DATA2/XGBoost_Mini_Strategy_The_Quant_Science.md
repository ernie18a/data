<!-- tradingview-pine-id: PUB;ff7254d98ef349e795fbc38e0ebce119 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# XGBoost Mini Strategy [The Quant Science]

Source: https://www.tradingview.com/script/69ZFfJ5L-XGBoost-Mini-Strategy-The-Quant-Science/

## Description

This strategy implements a predictive XGBoost machine learning system using our proprietary XGBoostMini library. It's a simple test to demonstrate how to use the library within a strategic framework. Notably, with just a few lines of Pine Script, it was possible to develop an algorithm that learns in real time from recent historical data to decide when to enter the market.

👉 XGBoostMini: [https://www.tradingview.com/script/SQ2QIdN6-XGBoostMini/](https://www.tradingview.com/script/SQ2QIdN6-XGBoostMini/)

[image]https://www.tradingview.com/x/j5jFkm7N/[/image]
[image]https://www.tradingview.com/x/2qZ312LD/[/image]

🔷 Key Features Extraction
Before making decisions, the system calculates six normalized features metrics to describe the current market state:

[*]14-period RSI on a scale from zero to one
[*]Percentage distance between the price and the 50-period Exponential Moving Average (EMA)
[*]5-period Rate of Change (ROC)
[*]Normalized ATR relative to the price to estimate volatility
[*]Volume variation compared to its 20-period moving average
[*]Current price position relative to the highs and lows of the last 14 bars

🔷 Dynamic Model Training
Starting from bar 300 onwards, every 50 bars the code collects a historical sample consisting of 50 past observations. For each observation, the system checks whether the price increased or decreased two bars later, generating a binary target variable. Based on this recent data, a mini decision tree is trained using the XGBoost model.

🔷 Real-Time Prediction
On every bar following the training, the model analyzes the 6 current indicators and calculates a numerical probability between 0 and 1, representing the estimated likelihood of a future bullish market movement.

🔷 Order and Risk Management
A Long position entry is triggered if the model's estimated probability exceeds the configured reference threshold, set by default to 51%. The position is closed as soon as the probability falls below the opposite threshold. Finally, for capital protection, a safety exit system based on a percentage-based dynamic trailing stop is activated.

🔷 Key Stats & Profitability

[*]Total PnL: +2,010 USDT (+20.10%). A positive return, though it must be evaluated relative to the time horizon visible in the charts (2018 to 2026).
[*]Profit Factor: 1.36. This is a solid value above 1, indicating that gross profits exceed gross losses.
[*]Profitable Trades Percentage: Approximately 54.88%. Over half of the operations close in profit, a robust percentage for a medium-to-high frequency algorithmic trading system.

🔷 Risk Management and Drawdown
Max Drawdown: 361.87 USDT, equal to 3.34%. 
This is an exceptionally positive metric. A drawdown of less than 3.50% over such an extensive historical dataset demonstrates outstanding capital protection and very tight risk management driven by the dynamic trailing stop.

🔷 Trades Analysis & Distribution
Expectancy: +0.20% per trade. 
This means that, on average, each operation has a positive expected return of 0.20%.

🔷 Risk/Reward Ratio:

[*]Average loss: -0.78%.
[*]Average profit: +1.21%.

Positive Note: The average profit exceeds the average loss, which helps keep the strategy profitable even with a win rate of around 55%.

🔷 Outliers and Extremes

[*]Largest loss: 94.60  USDT.
[*]Largest profit:169.25 USDT. 

It's worth noting that the maximum single loss exceeds the maximum single profit, which means that the strategy's profitability does not rely on isolated "lucky shots," but rather on the consistency of many small profits.

🔷 Equity Curve Analysis

[*]Cumulative PnL Curve: Observing the cumulative PnL chart, a steady and gradual growth phase is visible, especially from 2020 onwards, accompanied by strong stability during sideways or bear market phases (such as in 2022).
[*]Commission Load: The commission load is very low at 0.08%, indicating that transaction costs have a minimal impact on the final result.

🔷 Overall Assessment
The strategy demonstrates solid quantitative metrics: a low drawdown, a good profit factor and a favorable risk/reward ratio. However, as this strategy was developed to test the features of the XGBoost library, it should be considered exclusively for research purposes. Do not treat this strategy as ready for live deployment, but rather as a starting point for your experiments.

---

## Source Code

````pine
//@version=6
strategy(
     "XGBoost Mini Strategy [The Quant Science]",
     overlay = false,
     default_qty_type = strategy.cash,
     initial_capital = 10000,
     default_qty_value = 500,
     pyramiding = 1,
     currency = currency.USDT,
     commission_type = strategy.commission.percent,
     commission_value = 0.05,
     slippage = 5,
     process_orders_on_close = true,
     close_entries_rule = "ANY"
     )

import thequantscience/XGBoostMini/1 as xgb

i_threshold  = input.float(defval = 0.51, title = "Probability Threshold", minval = 0.50, maxval = 0.55, step = 0.01, group="Settings")

f1 = ta.rsi(close, 14) / 100.0                      
f2 = (close - ta.ema(close, 50)) / close            
f3 = ta.roc(close, 5) / 10.0                        
f4 = ta.atr(14) / close                             
f5 = nz(volume / ta.sma(volume, 20)) - 1.0          
float h_high = ta.highest(high, 14)
float h_low  = ta.lowest(low, 14)
f6 = (h_high - h_low) > 0 ? (close - h_low) / (h_high - h_low) : 0.5 

int n_features = 6
int n_samples  = 50

var xgb.XGBModel model = na

bool can_trade = bar_index > 300
bool condition_train = can_trade and (bar_index % 50 == 0)

if condition_train
    matrix<float> temp_X = matrix.new<float>(n_samples, n_features, 0.0)
    array<float>  temp_y = array.new_float(n_samples, 0.0)
    
    for i = 0 to n_samples - 1
        int offset = n_samples - i + 10
        matrix.set(temp_X, i, 0, nz(f1[offset]))
        matrix.set(temp_X, i, 1, nz(f2[offset]))
        matrix.set(temp_X, i, 2, nz(f3[offset]))
        matrix.set(temp_X, i, 3, nz(f4[offset]))
        matrix.set(temp_X, i, 4, nz(f5[offset]))
        matrix.set(temp_X, i, 5, nz(f6[offset]))
        
        float future_return = close[offset - 2] - close[offset]
        array.set(temp_y, i, future_return > 0 ? 1.0 : 0.0)
        
    model := xgb.train_model(temp_X, temp_y, 3, 0.1, 1.0, 4, 10, 1.0, 1.0, 0.0, 1)

array<float> current_features = array.new_float(0)
array.push(current_features, nz(f1))
array.push(current_features, nz(f2))
array.push(current_features, nz(f3))
array.push(current_features, nz(f4))
array.push(current_features, nz(f5))
array.push(current_features, nz(f6))

float prob = 0.5
if not na(model) and can_trade
    prob := xgb.predict_probability(model, current_features, 0.1)

var int last_exit_bar = -999
if nz(strategy.position_size[1]) > 0 and strategy.position_size == 0
    last_exit_bar := bar_index

bool cool_down = (bar_index - last_exit_bar) > 1

bool long_cond  = not na(model) and can_trade and (prob > i_threshold) and cool_down
bool close_cond = not na(model) and can_trade and (prob < (1.0 - i_threshold))

if long_cond
    strategy.entry(id = "XGB-Mini", direction = strategy.long)
if close_cond
    strategy.close("XGB-Mini")

float ts_ticks = (close * (1.0 / 100.0)) / syminfo.mintick

if strategy.position_size > 0
    strategy.exit(id = "Trailing Exit", from_entry = "XGB-Mini", trail_offset = ts_ticks, trail_points = 0)

hline(0.50, title="Neutral Midline", color=#bcbcbe59, linestyle=hline.style_dotted)
h_upper = hline(i_threshold, title="Upper Threshold", color=color.new(#00ff00, 35), linestyle=hline.style_dashed)
h_lower = hline(1.0 - i_threshold, title="Lower Threshold", color=color.new(#ff0000, 35), linestyle=hline.style_dashed)

color line_col = prob >= i_threshold ? #00ff00 : prob <= (1.0 - i_threshold) ? #ff0000 : #bcbcbe59

p_prob = plot(prob, title="Main Probability Line", color=line_col, linewidth=2, style=plot.style_line)
p_mid  = plot(0.50, title="Zero Baseline", display=display.none)

fill(p_prob, p_mid, color=color.new(line_col, 88), title="Probability Momentum Fill")
plot(prob, title="Glow Outer Layer", color=color.new(line_col, 75), linewidth=5, style=plot.style_line)

plotshape(long_cond and strategy.opentrades==0, title="Long Entry Signal", style=shape.circle, location=location.bottom, color=#00ff00, size=size.tiny, text="[XGB]", textcolor=#00ff00)
plotshape(close_cond and strategy.opentrades==1, title="Model Exit Signal", style=shape.circle, location=location.top, color=#ff0000, size=size.tiny, text="[XGB]", textcolor=#ff0000)

bgcolor(prob > i_threshold ? color.new(#00ff00, 95) : prob < (1.0 - i_threshold) ? color.new(#ff0000, 95) : na, title="Zone Background Highlight")
````
