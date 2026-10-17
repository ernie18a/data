# BullBear with Volume-Percentile TP - Strategy [presentTrading] 

- url: https://www.tradingview.com/script/yk59dFEX/
- type: strategy
- pine_id: PUB;71aff45ee7104de9a0ac72ad59e5f635
- version: 1.0

## Description

Happy New Year, everyone! I hope we have a fantastic year ahead. 
It's been a while since I published an open script, but it's time to return. 

This strategy introduces an indicator called Bull Bear Power, combined with an advanced take-profit system, which is the main innovative and educational aspect of this script. I hope all of you find some useful insights here. Welcome to engage in meaningful exchanges. This is a versatile tool suitable for both novice and experienced traders.

█ Introduction and How it is Different

Unlike traditional strategies that rely solely on price or volume indicators, this approach combines Bull Bear Power (BBP) with volume percentile analysis to identify optimal entry and exit points. It features a dynamic take-profit mechanism based on ATR (Average True Range) multipliers adjusted by volume and percentile factors, ensuring adaptability to diverse market conditions. This multifaceted strategy not only improves signal accuracy but also optimizes risk management, distinguishing it from conventional trading methods.

BTCUSD 6hr performance
[image]https://www.tradingview.com/x/f5XSuxRr/[/image]

Disable the visualization of Bull Bear Power (BBP) to clearly view the Z-Score.
[image]https://www.tradingview.com/x/rsetFf8B/[/image]

 █ Strategy, How it Works: Detailed Explanation

The BBP Strategy with Volume-Percentile TP utilizes several interconnected components to analyze market data and generate trading signals. Here's an overview with essential equations:

🔶 Core Indicators and Calculations
1. Exponential Moving Average (EMA):
   - **Purpose:** Smoothens price data to identify trends.
   - **Formula:**
     [pine]EMA_t = (Close_t * (2 / (lengthInput + 1))) + (EMA_(t-1) * (1 - (2 / (lengthInput + 1))))[/pine]
     
   - Usage: Baseline for Bull and Bear Power.

2. Bull and Bear Power:
   - Bull Power: [pine]`BullPower = High_t - EMA_t`[/pine]
   - Bear Power: [pine]`BearPower = Low_t - EMA_t`[/pine]
   - BBP:** [pine]`BBP = BullPower + BearPower`[/pine]
   - Interpretation: Positive BBP indicates bullish strength, negative indicates bearish.

3. Z-Score Calculation:
   - Purpose: Normalizes BBP to assess deviation from the mean.
   - Formula:
     [pine]Z-Score = (BBP_t - bbp_mean) / bbp_std[/pine]
   - Components:
     - `bbp_mean` = SMA of BBP over `zLength` periods.
     - `bbp_std` = Standard deviation of BBP over `zLength` periods.
   - Usage: Identifies overbought or oversold conditions based on thresholds.

🔶 Volume Analysis

1. Volume Moving Average (`vol_sma`):
   [pine]vol_sma = (Volume_1 + Volume_2 + ... + Volume_vol_period) / vol_period[/pine]
   

2. Volume Multiplier (`vol_mult`):
   [pine]vol_mult = Current Volume / vol_sma[/pine]
   
   - Thresholds:
     - High Volume: `vol_mult > 2.0`
     - Medium Volume: `1.5 < vol_mult ≤ 2.0`
     - Low Volume: `1.0 < vol_mult ≤ 1.5`

🔶 Percentile Analysis

1. Percentile Calculation (`calcPercentile`):
   [pine]Percentile = (Number of values ≤ Current Value / perc_period) * 100[/pine]
   

2. Thresholds:
   - High Percentile: >90%
   - Medium Percentile: >80%
   - Low Percentile: >70%

🔶 Dynamic Take-Profit Mechanism

1. ATR-Based Targets:
[pine]   TP1 Price = Entry Price ± (ATR * atrMult1 * TP_Factor)
   TP2 Price = Entry Price ± (ATR * atrMult2 * TP_Factor)
   TP3 Price = Entry Price ± (ATR * atrMult3 * TP_Factor)[/pine]
   
   - ATR Calculation:
     [pine]ATR_t = (True Range_1 + True Range_2 + ... + True Range_baseAtrLength) / baseAtrLength[/pine]
     
2. Adjustment Factors:
   [pine]TP_Factor = (vol_score + price_score) / 2[/pine]
   
   - **vol_score** and **price_score** are based on current volume and price percentiles.

Local performance
[image]https://www.tradingview.com/x/f5XSuxRr/[/image]

🔶 Entry and Exit Logic
1. Long Entry: If Z-Score crosses above 1.618, then Enter Long.
   
2. Short Entry: If Z-Score crosses below -1.618, then Enter Short.
   
3. Exiting Positions:
   If Long and Z-Score crosses below 0:
       Exit Long
   If Short and Z-Score crosses above 0:
       Exit Short
   
4. Take-Profit Execution:
   - Set multiple exit orders at dynamically calculated TP levels based on ATR and adjusted by `TP_Factor`.

█ Trade Direction
The strategy determines trade direction using the Z-Score from the BBP indicator:

- Long Positions:
  - Condition: Z-Score crosses above 1.618.
- Short Positions:
  - Condition: Z-Score crosses below -1.618.
- Exiting Trades:
  - Long Exit: Z-Score drops below 0.
  - Short Exit: Z-Score rises above 0.

This approach aligns trades with prevailing market trends, increasing the likelihood of successful outcomes.

 █ Usage

Implementing the BBP Strategy with Volume-Percentile TP in TradingView involves:

1. Adding the Strategy:
   - Copy the Pine Script code.
   - Paste it into TradingView's Pine Editor.
   - Save and apply the strategy to your chart.

2. Configuring Settings:
   - Adjust parameters like EMA length, Z-Score thresholds, ATR multipliers, volume periods, and percentile settings to match your trading preferences and asset behavior.

3. Backtesting:
   - Use TradingView’s backtesting tools to evaluate historical performance.
   - Analyze metrics such as profit factor, drawdown, and win rate.

4. Optimization:
   - Fine-tune parameters based on backtesting results.
   - Test across different assets and timeframes to enhance adaptability.

5. Deployment:
   - Apply the strategy in a live trading environment.
   - Continuously monitor and adjust settings as market conditions change.

█ Default Settings

The BBP Strategy with Volume-Percentile TP includes default parameters designed for balanced performance across various markets. Understanding these settings and their impact is essential for optimizing strategy performance:

Bull Bear Power Settings:
- EMA Length (`lengthInput`): 21
  - **Effect:** Balances sensitivity and trend identification; shorter lengths respond quicker but may generate false signals.
- Z-Score Length (`zLength`): 252
  - **Effect:** Long period for stable mean and standard deviation, reducing false signals but less responsive to recent changes.
- Z-Score Threshold (`zThreshold`): 1.618
  - **Effect:** Higher threshold filters out weaker signals, focusing on significant market moves.

Take Profit Settings:
- Use Take Profit (`useTP`): Enabled (`true`)
  - **Effect:** Activates dynamic profit-taking, enhancing profitability and risk management.
- ATR Period (`baseAtrLength`): 20
  - **Effect:** Shorter period for sensitive volatility measurement, allowing tighter profit targets.
- ATR Multipliers:
  - **Effect:** Define conservative to aggressive profit targets based on volatility.
- Position Sizes:
  - **Effect:** Diversifies profit-taking across multiple levels, balancing risk and reward.

Volume Analysis Settings:
- Volume MA Period (`vol_period`): 100
  - **Effect:** Longer period for stable volume average, reducing the impact of short-term spikes.
- Volume Multipliers:
  - **Effect:** Determines volume conditions affecting take-profit adjustments.
- Volume Factors:
  - **Effect:** Adjusts ATR multipliers based on volume strength.

Percentile Analysis Settings:
- Percentile Period (`perc_period`): 100
  - **Effect:** Balances historical context with responsiveness to recent data.
- Percentile Thresholds:
  - **Effect:** Defines price and volume percentile levels influencing take-profit adjustments.
- Percentile Factors:
  - **Effect:** Modulates ATR multipliers based on price percentile strength.

Impact on Performance:

- EMA Length: Shorter EMAs increase sensitivity but may cause more false signals; longer EMAs provide stability but react slower to market changes.
- Z-Score Parameters:*Longer Z-Score periods create more stable signals, while higher thresholds reduce trade frequency but increase signal reliability.
- ATR Multipliers and Position Sizes: Higher multipliers allow for larger profit targets with increased risk, while diversified position sizes help in securing profits at multiple levels.
- Volume and Percentile Settings: These adjustments ensure that take-profit targets adapt to current market conditions, enhancing flexibility and performance across different volatility environments.
- Commission and Slippage: Accurate settings prevent overestimation of profitability and ensure the strategy remains viable after accounting for trading costs.

Conclusion

The BBP Strategy with Volume-Percentile TP offers a robust framework by combining BBP indicators with volume and percentile analyses. Its dynamic take-profit mechanism, tailored through ATR adjustments, ensures that traders can effectively capture profits while managing risks in varying market conditions.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PresentTrading

// The BBP Strategy with Volume-Percentile TP by PresentTrading emerges as a sophisticated approach that integrates multiple analytical layers to enhance trading precision and profitability. 
// Unlike traditional strategies that rely solely on price movements or volume indicators, this strategy synergizes Bollinger Bands Power (BBP) with volume percentile analysis to determine optimal entry and exit points. Additionally, it employs a dynamic take-profit mechanism based on ATR (Average True Range) multipliers adjusted by volume and percentile factors, ensuring adaptability to varying market conditions. 
// This multi-faceted approach not only enhances signal accuracy but also optimizes risk management, setting it apart from conventional trading methodologies.

//@version=5
strategy("BBP Strategy with Volume-Percentile TP - Strategy [presentTrading] ", overlay=false, precision=3, commission_value= 0.1, commission_type=strategy.commission.percent, slippage= 1, currency=currency.USD, default_qty_type = strategy.percent_of_equity, default_qty_value = 10, initial_capital=10000)


// ————————
// Bull Bear Power Strategy Settings
// ————————
lengthInput = input.int(21, "EMA Length")
zLength     = input.int(252, "Z-Score Length")
zThreshold  = input.float(1.618, "Z-Score Threshold")

// ————————
// Take Profit Settings
// ————————
tp_group = "Take Profit Settings"
// Enable/disable take profit function
useTP = input.bool(true, "Use Take Profit", group=tp_group)

// === ATR Base Settings ===
// ATR calculation period for determining base price movement range
baseAtrLength = input.int(20, "ATR Period", minval=1, group=tp_group, tooltip="ATR period for calculating base price movement range. Shorter periods are more sensitive to recent volatility")

// === Take Profit Multiplier Settings ===
// First take profit ATR multiplier, usually the most conservative target
atrMult1 = input.float(1.618, "TP1 ATR Multiplier", minval=0.1, step=0.1, group=tp_group, tooltip="First take profit level ATR multiplier, recommended 1.5-2.0")
// Second take profit ATR multiplier, medium profit target
atrMult2 = input.float(2.382, "TP2 ATR Multiplier", minval=0.1, step=0.1, group=tp_group, tooltip="Second take profit level ATR multiplier, recommended 2.5-3.0")
// Third take profit ATR multiplier, most aggressive target
atrMult3 = input.float(3.618, "TP3 ATR Multiplier", minval=0.1, step=0.1, group=tp_group, tooltip="Third take profit level ATR multiplier, recommended 4.0-5.0")

// === Position Size Allocation ===
// First take profit position size, usually larger for securing basic profits
tp1_size = input.float(13, "TP1 Position %", minval=1, maxval=100, group=tp_group, tooltip="Position size percentage for first take profit, recommended 30-40%")
// Second take profit position size, medium allocation
tp2_size = input.float(13, "TP2 Position %", minval=1, maxval=100, group=tp_group, tooltip="Position size percentage for second take profit, recommended 30-40%")
// Third take profit position size, usually smaller for catching larger moves
tp3_size = input.float(13, "TP3 Position %", minval=1, maxval=100, group=tp_group, tooltip="Position size percentage for third take profit, recommended 20-30%")

// ————————
// Volume Analysis Settings
// ————————
vol_group = "Volume Analysis Settings"
// Volume MA period for determining relative volume levels
vol_period = input.int(100, "Volume MA Period", minval=1, group=vol_group, tooltip="Period for calculating volume moving average, recommended 20-30")

// === Volume Level Thresholds ===
// High volume threshold relative to MA
vol_high = input.float(2.0, "High Volume Multiplier", minval=1.0, step=0.1, group=vol_group, tooltip="High volume threshold multiplier, typically 2x MA or above")
// Medium volume threshold
vol_med = input.float(1.5, "Medium Volume Multiplier", minval=1.0, step=0.1, group=vol_group, tooltip="Medium volume threshold multiplier, typically around 1.5x MA")
// Low volume threshold
vol_low = input.float(1.0, "Low Volume Multiplier", minval=0.5, step=0.1, group=vol_group, tooltip="Low volume threshold multiplier, typically around 1x MA")

// === Volume Adjustment Factors ===
// High volume adjustment factor, usually extends take profit targets
vol_high_mult = input.float(1.5, "High Volume Factor", minval=0.1, step=0.1, group=vol_group, tooltip="Take profit adjustment factor for high volume")
// Medium volume adjustment factor
vol_med_mult = input.float(1.3, "Medium Volume Factor", minval=0.1, step=0.1, group=vol_group, tooltip="Take profit adjustment factor for medium volume")
// Low volume adjustment factor
vol_low_mult = input.float(1.0, "Low Volume Factor", minval=0.1, step=0.1, group=vol_group, tooltip="Take profit adjustment factor for low volume")

// ————————
// Percentile Analysis Settings
// ————————
perc_group = "Percentile Analysis Settings"
// Percentile calculation period for evaluating price position
perc_period = input.int(100, "Percentile Period", minval=20, group=perc_group, tooltip="Historical period for percentile calculations, recommended 100-200")

// === Percentile Thresholds ===
// High percentile threshold, typically indicates relative high levels
perc_high = input.float(90, "High Percentile", minval=50, maxval=100, group=perc_group, tooltip="High level percentile threshold, typically above 90")
// Medium percentile threshold
perc_med = input.float(80, "Medium Percentile", minval=50, maxval=100, group=perc_group, tooltip="Medium level percentile threshold, typically around 80")
// Low percentile threshold
perc_low = input.float(70, "Low Percentile", minval=0, maxval=100, group=perc_group, tooltip="Low level percentile threshold, typically around 70")

// === Percentile Adjustment Factors ===
// High percentile adjustment factor
perc_high_mult = input.float(1.5, "High Percentile Factor", minval=0.1, step=0.1, group=perc_group, tooltip="Take profit adjustment factor for high percentile levels")
// Medium percentile adjustment factor
perc_med_mult = input.float(1.3, "Medium Percentile Factor", minval=0.1, step=0.1, group=perc_group, tooltip="Take profit adjustment factor for medium percentile levels")
// Low percentile adjustment factor
perc_low_mult = input.float(1.0, "Low Percentile Factor", minval=0.1, step=0.1, group=perc_group, tooltip="Take profit adjustment factor for low percentile levels")


// ————————
// Core Bull Bear Power Calculations
// ————————
emaClose  = ta.ema(close, lengthInput)
bullPower = high - emaClose
bearPower = low  - emaClose
bbp       = bullPower + bearPower

bbp_mean  = ta.sma(bbp, zLength)
bbp_std   = ta.stdev(bbp, zLength)
zscore    = (bbp - bbp_mean) / bbp_std

// ————————
// Volume & Percentile Analysis
// ————————
// 成交量分析
vol_sma = ta.sma(volume, vol_period)
vol_mult = volume / vol_sma

// 百分位數計算
calcPercentile(src) =>
    var values = array.new_float(0)
    array.unshift(values, src)
    if array.size(values) > perc_period
        array.pop(values)
    array.size(values) > 0 ? array.percentrank(values, array.size(values)-1) * 100 : 50

price_perc = calcPercentile(close)
vol_perc = calcPercentile(volume)

// 止盈動態調整系數計算
getTpFactor() =>
    vol_score = vol_mult > vol_high ? vol_high_mult : vol_mult > vol_med ? vol_med_mult : vol_mult > vol_low ? vol_low_mult : 0.8
    price_score = price_perc > perc_high ? perc_high_mult :price_perc > perc_med ? perc_med_mult :price_perc > perc_low ? perc_low_mult : 0.8 
    math.avg(vol_score, price_score)

// ————————
// Entry/Exit Logic
// ————————
longCondition  = ta.crossover(zscore,  zThreshold)
shortCondition = ta.crossunder(zscore, -zThreshold)
exitLongCondition  = ta.crossunder(zscore, 0)
exitShortCondition = ta.crossover(zscore,  0)

if (barstate.isconfirmed)
    if longCondition
        strategy.entry("Long", strategy.long)
    if shortCondition
        strategy.entry("Short", strategy.short)
    if exitLongCondition
        strategy.close("Long")
    if exitShortCondition
        strategy.close("Short")

// ————————
// Take Profit Execution
// ————————
if useTP and strategy.position_size != 0
    base_move = ta.atr(baseAtrLength)
    tp_factor = getTpFactor()
    is_long = strategy.position_size > 0
    entry_price = strategy.position_avg_price
    
    if is_long
        tp1_price = entry_price + (base_move * atrMult1 * tp_factor)
        tp2_price = entry_price + (base_move * atrMult2 * tp_factor)
        tp3_price = entry_price + (base_move * atrMult3 * tp_factor)
        
        strategy.exit("TP1", "Long", qty_percent=tp1_size, limit=tp1_price)
        strategy.exit("TP2", "Long", qty_percent=tp2_size, limit=tp2_price)
        strategy.exit("TP3", "Long", qty_percent=tp3_size, limit=tp3_price)
    else
        tp1_price = entry_price - (base_move * atrMult1 * tp_factor)
        tp2_price = entry_price - (base_move * atrMult2 * tp_factor)
        tp3_price = entry_price - (base_move * atrMult3 * tp_factor)
        
        strategy.exit("TP1", "Short", qty_percent=tp1_size, limit=tp1_price)
        strategy.exit("TP2", "Short", qty_percent=tp2_size, limit=tp2_price)
        strategy.exit("TP3", "Short", qty_percent=tp3_size, limit=tp3_price)

// ————————
// Plotting
// ————————
plot(bbp, color=bbp >= 0 ? color.new(color.green, 0) : color.new(color.red, 0), 
     title="BBPower", style=plot.style_columns)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
plot(zscore, title="Z-Score", color=color.blue, linewidth=2)
hline(zThreshold, "Upper Threshold", color=color.orange, linestyle=hline.style_dashed)
hline(-zThreshold, "Lower Threshold", color=color.orange, linestyle=hline.style_dashed)
````
