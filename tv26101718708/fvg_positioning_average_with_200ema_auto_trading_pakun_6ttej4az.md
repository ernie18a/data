# FVG Positioning Average with 200EMA Auto Trading [Pakun]

- url: https://www.tradingview.com/script/6TTej4aZ/
- type: strategy
- pine_id: PUB;4b97f84d2f4d48b2aedde7338f4a8d0b
- version: 1.0

## Description

Description
Strategy Name and Purpose
FVG Positioning Average with 200EMA Auto Trading [Pakun]

This strategy uses Fair Value Gaps (FVG) combined with a 200-period Exponential Moving Average (EMA) and Average True Range (ATR) to generate trend-based trading signals. It is designed to help traders identify high-probability entry points by leveraging the gaps between fair value prices and current market prices.

Originality and Usefulness
This script combines multiple indicators to create a cohesive trading strategy that is greater than the sum of its parts. While FVG is a powerful tool on its own, combining it with the EMA and ATR adds layers of confirmation and risk management, enhancing its effectiveness. Here’s how the components work together:

Fair Value Gap (FVG): Identifies gaps in the market where price action has not fully filled, indicating potential reversal or continuation points.
200-period Exponential Moving Average (EMA): Acts as a trend filter to ensure trades are taken in the direction of the overall trend, improving the probability of success.
Average True Range (ATR): Used to filter out insignificant gaps and set dynamic stop-loss levels based on market volatility, enhancing risk management.

Entry Conditions

Long Entry
The close price crosses above the downtrend FVG.
The close price, FVG up average, and down average are all above the 200 EMA, indicating a strong bullish trend.

Short Entry
The close price crosses below the uptrend FVG.
The close price, FVG up average, and down average are all below the 200 EMA, indicating a strong bearish trend.

Exit Conditions
For long positions, the stop loss is set at the recent low, and the take profit is set at a point with a risk-reward ratio of 1:1.5.
For short positions, the stop loss is set at the recent high, and the take profit is set at a point with a risk-reward ratio of 1:1.5.

Risk Management
Account Size: 1,000,000 yen
Commission and Slippage: 2 pips commission and 1 pip slippage per trade
Risk per Trade: 10% of account equity
The stop loss is based on the recent low or recent high, ensuring trades are exited when the market moves against the position.

Settings Options
FVG Lookback: Set the lookback period for calculating FVGs.
Lookback Type: Choose the type of lookback (Bar Count or FVG Count).
ATR Multiplier: Set the multiplier for ATR to filter significant gaps.
EMA Period: Set the period for the EMA to adjust the trend filter sensitivity.
Show FVGs on Chart: Choose whether to display FVGs on the chart for visual confirmation.
Bullish/Bearish Color: Set the color for bullish and bearish FVGs to distinguish them easily.
Show Gradient Areas: Choose whether to display gradient areas to highlight the zones of interest.

Sufficient Sample Size
The strategy has been backtested with 113 trades, providing a sufficient sample size to evaluate its performance.

Notes
This strategy is based on historical data and does not guarantee future results.
Thoroughly backtest and validate results before using in live trading.
Market volatility and other external factors can affect performance and may not yield expected results.

Acknowledgment
This strategy uses the FVG Positioning Average Strategy [LuxAlgo] indicator. Thanks to [LuxAlgo] for their contribution.

Clean Chart Explanation
The script is published with a clean chart to ensure that its output is readily identifiable and easy to understand. No other scripts are included on the chart, and any drawings or images used are specifically to illustrate how the script works.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PakkunFX

//@version=5
strategy("FVG Positioning Average with 200EMA Auto Trading [Pakun]", overlay=true)

//---------------------------------------------------------------------------------------------------------------------
// User Inputs
//---------------------------------------------------------------------------------------------------------------------
lb = input.int(30, title = "FVG Lookback", tooltip = "Determines how many FVGs to consider for calculating the averages.", group = "Settings")
lbType = input.string("Bar Count", title = "Lookback Type", options = ["Bar Count","FVG Count"], tooltip = "Bar Count => Uses any FVGs within this Bar Lookback\nFVG Count => Uses only this amount of recent FVGs", group = "Settings")
atrMulti = input.float(0.25, step = 0.25, title = "ATR Multiplier", tooltip = "Only uses FVGs that are greater than ATR * Multiplier.", group = "Settings")
lookbackPeriod = input.int(20, title="Lookback Period", tooltip="The number of bars to look back for the recent low", group = "Settings")
emaPeriod = input.int(200, title="EMA Period", tooltip="The period for the EMA", group = "Settings")

fvgTog = input.bool(false, title = "Show FVGs on Chart", group = "Style")
green =  input.color(#089981, title = "Bullish Color", group = "Style")
red = input.color(#f23645, title = "Bearish Color", group = "Style")
showFill = input.bool(false, title = "Show Gradient Areas", group = "Style")

invis = color.rgb(0,0,0,100)

//---------------------------------------------------------------------------------------------------------------------
// Constants
//---------------------------------------------------------------------------------------------------------------------
atr = nz(ta.atr(200)*atrMulti, ta.cum(high - low) / (bar_index+1))

// FVG Detection
fvg_up = low > high[2] and close[1] > high[2] and (low-high[2]) > atr
fvg_down = high < low[2] and close[1] < low[2] and (low[2]-high) > atr

// Highest/Lowest
hst = ta.highest(high,5)
lst = ta.lowest(low,5)

//---------------------------------------------------------------------------------------------------------------------
// Calculations
//---------------------------------------------------------------------------------------------------------------------
var up_ary = array.new_box(na)
var down_ary = array.new_box(na)

if fvg_up
    up_ary.push(
      box.new(bar_index[2], low, bar_index, high[2]
      , border_color = fvgTog?color.new(green,50):na
      , bgcolor = fvgTog?color.new(green,50):na))

if fvg_down
    down_ary.push(
      box.new(bar_index[2],  low[2], bar_index, high
      , border_color = fvgTog?color.new(red,50):na
      , bgcolor = fvgTog?color.new(red,50):na))

// Array Size Management
if lbType == "FVG Count"
    if up_ary.size() > lb
        box.delete(up_ary.shift())
    if down_ary.size() > lb 
        box.delete(down_ary.shift())

if lbType == "Bar Count"
    for [index,bx] in up_ary
        left = bx.get_left()
        if left < bar_index-lb
            bx.delete()
            up_ary.remove(index)

    for [index,bx] in down_ary
        left = bx.get_left()
        if left < bar_index-lb
            bx.delete()
            down_ary.remove(index)

// Value Accumulation
up_vals = array.new_float(na)
down_vals = array.new_float(na)

for bx in up_ary
    up_vals.push(bx.get_bottom())
for bx in down_ary
    down_vals.push(bx.get_top())

// Averages
up_avg = array.avg(up_vals)
down_avg = array.avg(down_vals)

// Points to use for gradients
c_mid_h = math.max(math.avg(open,close),up_avg)
c_mid_l = math.min(math.avg(open,close),down_avg)

//---------------------------------------------------------------------------------------------------------------------
// Display 
//---------------------------------------------------------------------------------------------------------------------
ua = plot(up_avg
  , color = (hst<up_avg?invis:green)
  , title = "Bull Average"
  , display = display.none)  // Default to not displayed

da = plot(down_avg
  , color = (lst>down_avg?invis:red)
  , title = "Bear Average"
  , display = display.none)  // Default to not displayed

ul = plot(c_mid_h, display = display.none, editable = false)
dl = plot(c_mid_l, display = display.none, editable = false)

fill(ua, ul
  , c_mid_h
  , math.min(ta.sma(up_avg,10),up_avg)
  , color.new(chart.bg_color,100)
  , c_mid_h<=up_avg?invis:color.new(green,50)
  , display = showFill ? display.all : display.none)

fill(da, dl
  , math.max(ta.sma(down_avg,10),down_avg)
  , c_mid_l 
  , c_mid_l>=down_avg?invis:color.new(red,50)
  , color.new(chart.bg_color,100)
  , display = showFill ? display.all : display.none)

//---------------------------------------------------------------------------------------------------------------------
// EMA Calculation
//---------------------------------------------------------------------------------------------------------------------
ema = ta.ema(close, emaPeriod)

//---------------------------------------------------------------------------------------------------------------------
// Detect Recent Lows and Highs
//---------------------------------------------------------------------------------------------------------------------
recentLow = ta.lowest(low, lookbackPeriod)
recentHigh = ta.highest(high, lookbackPeriod)

//---------------------------------------------------------------------------------------------------------------------
// Trading Conditions
//---------------------------------------------------------------------------------------------------------------------
longCondition = ta.crossover(close, down_avg) and close > ema and up_avg > ema and down_avg > ema
shortCondition = ta.crossunder(close, up_avg) and close < ema and up_avg < ema and down_avg < ema

// Risk-Reward Setup
riskRewardRatio = 1.5

// Long Trade Setup
if (longCondition)
    longStopLoss = recentLow
    longTakeProfit = close + (close - longStopLoss) * riskRewardRatio
    strategy.entry("Long", strategy.long)
    strategy.exit("Take Profit/Stop Loss", "Long", stop=longStopLoss, limit=longTakeProfit)

// Short Trade Setup
if (shortCondition)
    shortStopLoss = recentHigh
    shortTakeProfit = close - (shortStopLoss - close) * riskRewardRatio
    strategy.entry("Short", strategy.short)
    strategy.exit("Take Profit/Stop Loss", "Short", stop=shortStopLoss, limit=shortTakeProfit)
````
