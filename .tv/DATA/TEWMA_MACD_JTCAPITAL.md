<!-- tradingview-pine-id: PUB;d274868e72a644268deb073b3d1e8b4f -->
<!-- tradingviewscripts-format: 1 -->
# TEWMA MACD - [JTCAPITAL]

Source: https://www.tradingview.com/script/RRi6RJbJ-TEWMA-MACD-JTCAPITAL/

## Description

TEWMA MACD - [JTCAPITAL]

TEWMA MACD - [JTCAPITAL] is a modified way to use the Moving Average Convergence Divergence (MACD) by replacing the traditional EMA calculations with Triple Exponential Weighted Moving Averages (TEWMA) for Trend-Following.

Instead of relying on conventional exponential moving averages, this indicator first smooths price using a Weighted Moving Average (WMA), followed by a Triple Exponential Moving Average (TEMA). This creates a significantly more responsive moving average while still maintaining smoothness. The result is a MACD that reacts quicker to changing market conditions without becoming excessively noisy.

The indicator works by calculating in the following steps:

[*] Source Selection

The script begins by selecting the desired price source. By default this is the Close price, but users may choose any TradingView supported source such as Open, High, Low, HL2, HLC3, OHLC4, or any custom source.

Every calculation performed afterwards originates from this selected source.

[*] Weighted Moving Average (WMA) Smoothing

Before calculating the actual trend averages, the source is first smoothed using a Weighted Moving Average.

Unlike a Simple Moving Average, a WMA assigns progressively larger weights to newer prices while still considering older data. This allows the moving average to respond faster to changing market conditions without becoming overly sensitive.

This initial smoothing stage reduces market noise before the Triple EMA calculation begins.

[*] Triple Exponential Moving Average (TEMA) Calculation

After the WMA has been calculated, the script applies a Triple Exponential Moving Average.

Unlike a normal EMA, the TEMA combines multiple exponential averages in a mathematical way that largely removes the lag introduced by exponential smoothing.

This process produces a moving average that follows price much more closely while maintaining excellent smoothness.

The first TEWMA uses the user-selected base period.

[*] Second TEWMA Calculation

A second TEWMA is then created using a longer lookback period.

Instead of manually selecting this second length, the script multiplies the original period by the chosen Multiplier.

For example:

Base Length = 20
Multiplier = 1.5
Second Length = 30

This automatically creates a slower moving average that represents the longer-term trend.

[*] MACD Line Calculation

The MACD line is calculated by subtracting the slower TEWMA from the faster TEWMA.

MACD = Fast TEWMA − Slow TEWMA

When the faster average rises above the slower average, the MACD becomes positive.

When the faster average falls below the slower average, the MACD becomes negative.

The distance between both averages represents the current momentum of the market.

[*] Signal Line Calculation

The script then calculates an Exponential Moving Average of the MACD itself.

This creates the Signal Line.

The Signal Line smooths the MACD values and provides a reference that can be compared against the MACD to determine whether momentum is increasing or decreasing.

The Signal Length is fully customizable.

[*] Histogram Calculation

The histogram is calculated as:

Histogram = MACD − Signal Line

This measures the difference between both lines.

When the histogram is positive, bullish momentum dominates.

When the histogram is negative, bearish momentum dominates.

The larger the histogram becomes, the stronger the momentum.

[*] Momentum Acceleration Detection

Besides determining whether momentum is positive or negative, the indicator also checks whether the histogram itself is increasing or decreasing compared to the previous candle.

This creates four unique momentum states:

Bullish and strengthening
Bullish but weakening
Bearish but recovering
Bearish and strengthening

These states are reflected through different histogram colors, making it significantly easier to judge the current momentum without manually comparing bars.

[*] Dynamic Coloring

Both the MACD line and Signal Line automatically change color depending on which line currently dominates.

When the MACD remains above the Signal Line, both lines adopt the bullish color.

When the MACD falls below the Signal Line, both lines switch to the bearish color.

This immediately visualizes the current trend direction.

[*] Background Momentum Visualization

Finally, the indicator colors the background using two separate conditions.

The first background coloring reflects whether momentum is bullish or bearish.

The second background coloring reflects whether momentum is increasing or decreasing.

Together these background colors provide an additional visual confirmation of the current market state without affecting the indicator calculations themselves.

Buy and Sell Conditions:

The indicator itself does not generate explicit Buy or Sell signals. Instead, it provides a momentum framework that traders can interpret according to their own trading style.

Common bullish confirmations include:

The MACD crossing above the Signal Line.
The histogram moving from negative to positive.
Increasing positive histogram bars.
Both MACD and Signal Line remaining above zero.
Background shifting toward bullish momentum.

Common bearish confirmations include:

The MACD crossing below the Signal Line.
The histogram moving from positive to negative.
Increasing negative histogram bars.
Both MACD and Signal Line remaining below zero.
Background shifting toward bearish momentum.

Additional confirmation filters may be added, such as:

Higher timeframe trend confirmation.
Volume confirmation.
RSI filters.
ADX trend strength filters.
ATR volatility filters.
Market structure confirmation.
Support and resistance confluence.

Combining multiple filters generally reduces false signals while increasing the quality of confirmed trend reversals.

Features and Parameters:
Source
Determines which price series is used for every calculation.
Length
Controls the period used for the fast TEWMA.
Multiplier
Automatically determines the slow TEWMA length by multiplying the base Length.
MACD Length
Controls the EMA smoothing period used for the Signal Line.
Dual TEWMA System
Creates a fast and slow trend measurement using Triple Exponential Weighted Moving Averages.
Dynamic MACD
Uses TEWMA instead of traditional EMA calculations to reduce lag while maintaining smoothness.
Adaptive Signal Line
Smooths the MACD using a configurable EMA.
Momentum Histogram
Displays the distance between MACD and Signal Line.
Four-State Histogram Coloring
Shows whether momentum is bullish, bearish, strengthening, or weakening.
Dynamic Line Colors
Both MACD and Signal Line automatically reflect current momentum direction.
Background Momentum Visualization
Provides additional visual confirmation of trend direction and momentum acceleration.
Specifications:

Weighted Moving Average (WMA)

The Weighted Moving Average assigns progressively larger weights to more recent price data while gradually reducing the influence of older prices. Compared to a Simple Moving Average, the WMA reacts faster to new market information without becoming excessively sensitive. Within this indicator, the WMA serves as the initial smoothing stage before the Triple Exponential Moving Average is applied. This helps reduce random price fluctuations while preserving meaningful trend information.

Triple Exponential Moving Average (TEMA)

The Triple Exponential Moving Average is designed to minimize the lag commonly associated with exponential moving averages. Rather than relying on a single exponential smoothing calculation, TEMA combines multiple exponential averages into one formula that effectively compensates for delay. This produces a moving average that closely follows price while remaining smooth. In this indicator, TEMA is applied after the WMA, creating the TEWMA calculation that forms the foundation of the entire oscillator.

TEWMA

TEWMA stands for Triple Exponential Weighted Moving Average. It combines the stability of the Weighted Moving Average with the responsiveness of the Triple Exponential Moving Average. By smoothing the source with a WMA before applying TEMA, the resulting average filters out short-term market noise while still responding rapidly to genuine trend changes. Using TEWMA instead of traditional EMAs creates a more responsive MACD without sacrificing smoothness.

MACD (Moving Average Convergence Divergence)

The MACD measures the distance between a faster moving average and a slower moving average. This difference provides insight into market momentum. As the fast average accelerates away from the slow average, momentum increases. When both averages converge, momentum weakens. By replacing the traditional EMAs with TEWMAs, this indicator produces a MACD that reacts more quickly to evolving market conditions while maintaining reliable trend identification.

Signal Line

The Signal Line is an Exponential Moving Average applied directly to the MACD values. Its purpose is to smooth the often volatile MACD line, making momentum shifts easier to identify. Crossovers between the MACD and Signal Line are among the most widely used momentum signals in technical analysis because they indicate potential changes in buying or selling pressure.

Histogram

The histogram measures the difference between the MACD and the Signal Line. Rather than simply indicating bullish or bearish momentum, it also reveals the strength of that momentum. Expanding histogram bars indicate accelerating momentum, while shrinking bars suggest that momentum is fading. This often provides an early warning before actual MACD crossovers occur.

Momentum Acceleration

Beyond measuring whether momentum is positive or negative, this indicator continuously evaluates whether momentum itself is increasing or decreasing. This additional layer allows traders to distinguish between strong trends, weakening trends, recovering markets, and accelerating reversals. Monitoring momentum acceleration often provides earlier insight into changing market conditions than observing crossovers alone.

Trend Following

Trend-following strategies attempt to participate in sustained market movements rather than predicting exact tops or bottoms. By combining fast and slow TEWMAs, the indicator naturally aligns with prevailing market direction while filtering much of the short-term noise that frequently causes false signals.

Moving Average Convergence and Divergence

The core principle behind MACD is that the relationship between two moving averages reflects the strength and direction of a trend. As the averages separate, momentum increases. As they converge, momentum decreases. Measuring this continuously provides valuable insight into both existing trends and potential reversals.

Multiplier

Instead of manually selecting both moving average lengths, this indicator derives the slower TEWMA by multiplying the fast length by a user-defined multiplier. This ensures that the relationship between both averages remains proportional regardless of the chosen settings, making optimization more intuitive while preserving the intended behavior of the oscillator.

Dynamic Coloring

Color changes are not merely cosmetic. They immediately communicate whether bullish or bearish momentum currently dominates and whether momentum is strengthening or weakening. This allows traders to interpret the oscillator at a glance without carefully examining individual values or comparing multiple bars manually.

Why combine WMA with TEMA?

The Weighted Moving Average prioritizes recent price action while still filtering random fluctuations. The Triple Exponential Moving Average then removes much of the lag traditionally introduced by smoothing techniques. Combining both methods produces a moving average that remains smooth during consolidation while responding rapidly once genuine momentum develops. This makes the resulting MACD more responsive than the traditional EMA-based implementation without becoming excessively noisy.

Why use a TEWMA-based MACD instead of a traditional MACD?

Traditional MACD indicators rely entirely on Exponential Moving Averages, which inevitably introduce lag as markets change direction. By replacing those averages with TEWMAs, this indicator detects shifts in momentum earlier while still maintaining smooth trend behavior. The result is an oscillator that remains familiar to MACD users but offers faster responsiveness, improved trend tracking, and clearer visualization of changing momentum.

Enjoy!

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JTCapitalNL
//@version=6
//       ______                                                                                          ______          
//    .-'      `-.                                                                                    .-'      `-.        
//   /            \                                                                                  /            \      
//  |              |      ████████╗████████╗ ██████╗ █████╗ ██████╗ ██╗████████╗ █████╗ ██╗         |              |      
//  |,  .-.  .-.  ,|      ╚═════██║╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██║╚══██╔══╝██╔══██╗██║         |,  .-.  .-.  ,|     
//  | )(_o/  \o_)( |            ██║   ██║   ██║     ███████║██████╔╝██║   ██║   ███████║██║         | )(_o/  \o_)( |      
//  |/     /\     \|      ██║   ██║   ██║   ██║     ██╔══██║██╔═══╝ ██║   ██║   ██╔══██║██║         |/     /\     \|      
//  (_     ^^     _)      ████████║   ██║   ╚██████╗██║  ██║██║     ██║   ██║   ██║  ██║███████╗    (_     ^^     _)      
//   \__|IIIIII|__/       ╚═══════╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝     \__|IIIIII|__/       
//    | \IIIIII/ |                                                                                    | \IIIIII/ |        
//    \          /                               ☠️ |JTCapitalNL| ☠️                                 \          /        
//     `--------`                                                                                       `--------`

   

indicator("TEWMA MACD - [JTCAPITAL]", overlay = false)
import TradingView/ta/10

//-----Defining Parameters
src = input.source(close)
MACDLength = input.int(9)
len = input.int(20)
multi = input.float(1.5, step = 0.05)
len22 = len * multi
len2 = math.round(len22)


//-----Calculating the TEWMA
TEWMA1 = ta.tema(ta.wma(src, len), len)
TEWMA2 = ta.tema(ta.wma(src, len2), len2)

//-----Calculating MACD
MACD = TEWMA1 - TEWMA2
aMACD = ta.ema(MACD, MACDLength)
delta = MACD - aMACD


//-----Assigning line color based on trend direction
BullColor = color.rgb(49, 132, 228)
Bearcolor = color.rgb(132, 3, 158)
lineColor = MACD > aMACD ? BullColor : Bearcolor
hColor = delta >= 0 ? delta > delta[1] ? color.rgb(49, 132, 228) : color.rgb(161, 188, 219) : delta > delta[1] ? color.rgb(154, 119, 161) : color.rgb(132, 3, 158)

plot2 = plot(MACD, color=lineColor, linewidth=1)
plot22 = plot(MACD * 0.9, color = lineColor, display = display.none)
fill(plot1 = plot2,plot2 = plot22, top_value = MACD, bottom_value = MACD * 0.9, top_color = lineColor, bottom_color = color.new(color.black, 100))

plot3 = plot(aMACD, color=lineColor, linewidth=1)
plot32 = plot(aMACD * 0.9, color = lineColor, display = display.none)
fill(plot1 = plot3,plot2 = plot32, top_value = aMACD, bottom_value = aMACD * 0.9, top_color = lineColor, bottom_color = color.new(color.black, 100))

plot(delta, color = hColor, style = plot.style_columns)


bgcolor(delta > 0 ? color.rgb(49, 132, 228, 85) : delta < 0 ? color.rgb(132, 3, 158, 85) : color.rgb(0, 0, 0), force_overlay = true)
bgcolor(delta > delta[1] ? color.rgb(49, 132, 228, 85) : delta < delta[1] ? color.rgb(132, 3, 158, 85) : color.rgb(0, 0, 0), force_overlay = true)
````
