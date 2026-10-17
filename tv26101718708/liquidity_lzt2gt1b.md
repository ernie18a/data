# Liquidity

- url: https://www.tradingview.com/script/lZt2gT1b/
- type: indicator
- pine_id: PUB;ef4d0d6f71d54f5f9b2a853271f68142
- version: 2.0

## Description

# Liquidity

Liquidity is a market structure indicator designed to identify and visualize key liquidity levels across multiple timeframes.

The indicator automatically detects significant swing highs and swing lows using pivot-based logic, helping traders locate potential liquidity pools where stop-loss orders and resting liquidity are likely concentrated.

## Key Features

### Multi-Timeframe Liquidity Detection

The indicator tracks liquidity levels from both:

* Lower Timeframe (LTF)
* Higher Timeframe (HTF)

This allows traders to monitor both local and major liquidity zones simultaneously.

### Pivot-Based Liquidity Mapping

Liquidity levels are generated from confirmed pivot highs and pivot lows.

These areas often represent:

* Buy-Side Liquidity (BSL)
* Sell-Side Liquidity (SSL)
* Stop-Loss Clusters
* Liquidity Pools

### Dynamic Liquidity Updates

Liquidity levels automatically update as new market structure forms, ensuring that traders always have access to the most relevant liquidity references.

### Short-Term Liquidity Tracking

In addition to confirmed pivots, the indicator monitors recent highs and lows to provide faster reactions to developing market conditions.

### Clean Chart Visualization

Liquidity zones are displayed directly on the chart using separate colors for:

* LTF Liquidity Levels
* HTF Liquidity Levels

allowing traders to quickly distinguish between local and higher-timeframe liquidity.

## Practical Uses

### Liquidity Sweep Analysis

Identify areas where the market may seek liquidity before reversing direction.

### AMD Framework Support

The indicator works particularly well with the Accumulation-Manipulation-Distribution (AMD) model.

Common observations include:

* Accumulation near liquidity zones
* Manipulation through liquidity sweeps
* Distribution following liquidity collection

### Entry Confirmation

Use liquidity levels as confluence points when combining:

* Market Structure
* Trend Bias
* Volatility Expansion
* AMD Setups

### Target Projection

Liquidity levels can also be used as potential profit targets, as price frequently moves toward external liquidity.

## Suitable Markets

* Forex
* Gold (XAUUSD)
* Indices
* Stocks
* Cryptocurrency

## Recommended Timeframes

Compatible with all timeframes.

For best results, combine lower-timeframe execution with higher-timeframe liquidity analysis.

## Interpretation Guide

* Orange Lines → Lower Timeframe Liquidity
* Red Lines → Higher Timeframe Liquidity

When price approaches a liquidity level, traders should monitor for:

* Liquidity Sweeps
* Rejections
* Breakouts
* Market Structure Shifts

## Disclaimer

This indicator identifies potential liquidity locations based on market structure and pivot formations. Liquidity levels should not be interpreted as guaranteed support or resistance and should be used alongside additional market analysis and risk management techniques.

## Source Code

````pine
//@version=6
indicator("Liquidity", overlay=true, max_labels_count=500, max_lines_count=500)
import TradingView/ta/12

// === 時區大小 ===
ltf_lenght = input.int(1, "ltf pivot lenght", group="使用者輸入")
htf_lenght = ltf_lenght * 4

// === Pivot 計算 ===
// LTF Liquidity
ltf_high_pivot = ta.pivothigh(high,ltf_lenght,ltf_lenght)
ltf_low_pivot  = ta.pivotlow(low,ltf_lenght,ltf_lenght)

// HTF Liquidity
htf_high_pivot = ta.pivothigh(high,htf_lenght,htf_lenght)
htf_low_pivot  = ta.pivotlow(low,htf_lenght,htf_lenght)

// 靈敏 pivot
fast_low_sl = ta.lowest(low, 5)
fast_high_sl = ta.highest(high, 5)

fast_htf_high_pivot = ta.highest(high, 10)
fast_htf_low_pivot = ta.lowest(low, 10)

// === Pivot 延伸保存 ===
var float htf_high_prev = na
var float htf_low_prev  = na
var float ltf_high_curr = na
var float ltf_low_curr  = na

update(prev, p) =>
    not na(p) ? p : prev

htf_high_prev  := update(htf_high_prev,  htf_high_pivot)
htf_low_prev   := update(htf_low_prev,   htf_low_pivot)

ltf_high_curr  := update(ltf_high_curr,  ltf_high_pivot)
ltf_low_curr   := update(ltf_low_curr,   ltf_low_pivot)

ltf_range = (ltf_high_curr - ltf_low_curr)
htf_range = (htf_high_prev - htf_low_prev)

// === 顯示群組開關 ===
show_pivot_group = input.bool(true, "Pivot 線群組", group="顯示控制")
color_or_p   = show_pivot_group        ? color.new(color.orange, 30) : color.new(color.orange, 100)
color_red_p  = show_pivot_group        ? color.new(color.red, 30)   : color.new(color.red, 100)

// === Pivot 線 ===
plot(ltf_high_curr, "LTF liq_high", color=color_or_p, linewidth=1)
plot(ltf_low_curr, "LTF liq_low", color=color_or_p, linewidth=1)
plot(htf_high_prev, "HTF liq_high", color=color_red_p, linewidth=1)
plot(htf_low_prev, "HTF liq_low", color=color_red_p, linewidth=1)
````
