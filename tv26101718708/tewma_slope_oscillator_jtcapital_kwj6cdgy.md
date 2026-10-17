# TEWMA Slope Oscillator - [JTCAPITAL]

- url: https://www.tradingview.com/script/kwj6cdgY-TEWMA-Slope-Oscillator-JTCAPITAL/
- type: indicator
- pine_id: PUB;c33dbf4d41bd4e22b34bad7906c481e3
- version: 1.0

## Description

[b]TEWMA Slope Oscillator - [JTCAPITAL][/b] is a modified way to use [b]a Triple Exponential Weighted Moving Average (TEWMA), normalized slope analysis, ATR volatility normalization, and exponential smoothing[/b] for Trend-Following and Momentum Analysis.

Unlike traditional oscillators that are derived directly from price, this indicator measures the [b]rate of change (slope)[/b] of a custom TEWMA trend line. By normalizing this slope with the Average True Range (ATR), the oscillator becomes volatility-adjusted, allowing trend strength to be compared across different market conditions. This makes the indicator useful for identifying whether trends are merely moving, or accelerating with meaningful momentum.

The indicator works by calculating in the following steps:

[list=1]

[*][b]Weighted Price Smoothing[/b]

The selected price source (Close by default, although any TradingView source can be selected) is first smoothed using a Weighted Moving Average (WMA). Unlike a Simple Moving Average, the WMA gives progressively greater importance to the most recent price bars while still considering historical data. This reduces market noise while allowing the moving average to react faster to recent changes.

Rather than relying on a single smoothing period, the script prepares two separate smoothing lengths:

The original TEWMA Length.
A second length calculated as the original length multiplied by the user-defined Length Multiplier.

This creates two trend measurements that represent both medium-term and slower market behavior.

[*][b]Triple Exponential Processing (TEMA)[/b]

Each Weighted Moving Average is then processed using a Triple Exponential Moving Average (TEMA).

The Triple Exponential Moving Average is specifically designed to reduce lag while maintaining smoothness. Traditional moving averages often delay reactions because every layer of smoothing introduces additional latency. TEMA compensates for much of this lag mathematically by combining multiple exponential averages into a single result.

Applying TEMA on top of the Weighted Moving Average creates a very responsive yet smooth trend estimate that filters insignificant fluctuations while remaining sensitive to genuine trend changes.

[*][b]Dual TEWMA Construction[/b]

Instead of relying on only one moving average, the indicator calculates two separate TEWMAs:

One using the original period.
One using the multiplied period.

The final TEWMA becomes the average of these two curves.

Averaging both trend estimates balances responsiveness with stability. The shorter TEWMA reacts more quickly to new market information, while the longer TEWMA filters larger amounts of noise. Combining both produces a smoother trend representation that avoids becoming overly reactive while still responding efficiently to changing market conditions.

[*][b]Trend Direction Detection[/b]

The script continuously compares the current TEWMA with its previous value.

If today's TEWMA is higher than the previous value, the trend is considered bullish.
If today's TEWMA is lower than the previous value, the trend is considered bearish.

The indicator stores this direction internally and uses it for its visual coloring, making bullish periods immediately recognizable in blue while bearish periods appear in purple.

[*][b]Slope Calculation[/b]

After constructing the final TEWMA, the script measures its slope.

Rather than measuring price itself, the oscillator calculates:

"The difference between today's TEWMA and yesterday's TEWMA."

This produces a measurement of how quickly the trend itself is changing.

Positive values indicate the trend is rising.

Negative values indicate the trend is falling.

Larger absolute values indicate stronger acceleration.

Smaller values near zero indicate slowing momentum or sideways conditions.

[*][b]ATR Normalization[/b]

Instead of using the raw slope, the script divides the slope by the Average True Range (ATR).

This normalization is one of the defining characteristics of the indicator.

Without ATR normalization, identical price movements would appear much larger on low-priced assets than on expensive assets.

By dividing by ATR:

Large volatility environments become comparable with quiet markets.
Different assets become easier to compare.
Oscillator values represent trend strength relative to current market volatility rather than raw price movement.

The result is a dimensionless momentum measurement that remains much more consistent across instruments and timeframes.

[*][b]EMA Signal Smoothing[/b]

Although the normalized slope already provides valuable information, short-term fluctuations may still produce rapid oscillations.

To improve readability, the script applies an Exponential Moving Average (EMA) directly to the slope values.

This smoothed line acts as a slower confirmation curve.

The raw slope reflects immediate momentum.

The EMA reflects sustained momentum.

Comparing these two allows traders to distinguish between temporary spikes and persistent trend acceleration.

[*][b]Momentum Zone Detection[/b]

The indicator introduces user-defined upper and lower threshold levels.

When the normalized slope exceeds the upper threshold:

-The market is considered to have unusually strong bullish momentum.

When the normalized slope falls below the lower threshold:

-The market is considered to have unusually strong bearish momentum.

The same logic is independently applied to the smoothed EMA line.

Whenever either condition is satisfied, the background color changes to highlight periods of exceptional trend strength.

These zones do not generate trading signals by themselves, but instead emphasize moments where momentum has reached statistically significant levels relative to recent volatility.

[/list]

[b]Buy and Sell Conditions:[/b]

This indicator is intentionally designed as a momentum and trend-strength oscillator rather than a direct entry generator.

Typical bullish interpretation includes:

The TEWMA begins rising.
The normalized slope crosses above zero.
The smoothed EMA also moves above zero.
The oscillator continues accelerating toward or above the upper threshold.

Typical bearish interpretation includes:

The TEWMA begins falling.
The normalized slope crosses below zero.
The smoothed EMA confirms the move below zero.
The oscillator continues toward or below the lower threshold.

Because both the raw slope and its EMA are displayed simultaneously, traders can judge whether momentum is strengthening, weakening, or beginning to reverse before the underlying trend itself changes direction.

The threshold values can be adjusted depending on trading style:

Lower threshold values produce earlier but more frequent momentum alerts.
Higher threshold values require stronger momentum before highlighting extreme conditions, reducing market noise.

The smoothing period can also be increased or decreased depending on whether faster or more conservative confirmation is preferred.

[b]Features and Parameters:[/b]

[b]Source[/b]
Selects which price source is used for all calculations.
[b]TEWMA Length[/b]
Controls the primary Weighted Moving Average and TEMA calculation period.
[b]Length Multiplier[/b]
Creates the second TEWMA period by multiplying the original length, allowing the indicator to combine two different trend horizons.
[b]Smoothed Length[/b]
Determines the EMA period applied to the normalized slope.
[b]Upper Threshold[/b]
Defines the bullish momentum level where background highlighting begins.
[b]Lower Threshold[/b]
Defines the bearish momentum level where background highlighting begins.
[b]ATR Length[/b]
Controls the Average True Range period used to normalize slope values.
[b]Dual Oscillator Display[/b]
Shows both the raw normalized slope and its EMA simultaneously.
[b]Dynamic Coloring[/b]
Automatically colors bullish momentum blue and bearish momentum purple.
[b]Background Momentum Zones[/b]
Highlights periods where either the raw slope or smoothed slope exceeds user-defined strength thresholds.

[b]Specifications:[/b]

[b]Weighted Moving Average (WMA)[/b]

The Weighted Moving Average assigns progressively larger weights to newer prices while assigning smaller weights to older observations. This allows the moving average to respond faster than a Simple Moving Average while still maintaining smoothness. Because recent market activity receives greater influence, the WMA provides an excellent foundation for responsive trend calculations.

[b]Triple Exponential Moving Average (TEMA)[/b]

The Triple Exponential Moving Average is designed to significantly reduce lag compared to traditional moving averages. Instead of relying on a single exponential smoothing process, TEMA mathematically combines multiple exponential averages to compensate for the delay introduced by smoothing. This produces a trend line that reacts quickly while maintaining a clean appearance.

[b]TEWMA (Triple Exponential Weighted Moving Average)[/b]

The TEWMA combines the advantages of a Weighted Moving Average with the lag-reduction properties of the Triple Exponential Moving Average. The result is a trend estimate that reacts rapidly to meaningful price movement while filtering much of the short-term market noise that can affect conventional moving averages.

[b]Dual-Length Averaging[/b]

Instead of relying on one smoothing horizon, the indicator averages two independently calculated TEWMAs. Combining a faster and slower trend estimate helps reduce false directional changes while preserving responsiveness. This dual-length construction creates a more balanced representation of market structure than either length would provide individually.

[b]Slope[/b]

Slope measures how quickly the TEWMA itself changes from one bar to the next. Rather than evaluating where price is located, the indicator evaluates how rapidly the trend line is moving. Increasing positive slope reflects accelerating bullish momentum, while increasingly negative slope reflects accelerating bearish momentum.

[b]Average True Range (ATR)[/b]

Average True Range measures recent market volatility by considering both daily ranges and price gaps. ATR does not indicate trend direction but instead measures how much price typically moves. Dividing the slope by ATR converts raw movement into a volatility-adjusted measurement, making momentum readings far more consistent across different instruments and market environments.

[b]ATR Normalization[/b]

Normalization removes much of the distortion caused by differing price scales and volatility regimes. A movement that appears large on one market may be insignificant on another. By scaling the slope using ATR, the oscillator expresses momentum relative to current market conditions rather than absolute price movement.

[b]Exponential Moving Average (EMA)[/b]

The EMA applied to the slope acts as a momentum confirmation filter. Because exponential averages place greater emphasis on recent observations, the smoothed oscillator follows changes efficiently while filtering much of the short-term fluctuation present in the raw slope.

[b]Momentum Oscillator[/b]

Unlike oscillators derived directly from price, this oscillator measures the strength and speed of the underlying trend itself. Positive readings indicate bullish trend acceleration, negative readings indicate bearish acceleration, and values near zero indicate weakening momentum or balanced market conditions.

[b]Threshold Levels[/b]

The upper and lower thresholds define momentum zones where the normalized slope has become unusually strong relative to recent volatility. These levels are fully customizable, allowing traders to adapt the indicator to different markets, trading styles, and volatility environments.

[b]Trend Momentum Confirmation[/b]

Displaying both the raw normalized slope and its smoothed EMA provides two perspectives on market momentum. The raw slope captures immediate changes, while the EMA reflects sustained movement. Together they help distinguish short-lived fluctuations from genuine trend acceleration, making it easier to evaluate the quality and persistence of directional momentum.

Enjoy!

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

   

indicator("TEWMA Slope Oscillator - [JTCAPITAL]", overlay = false)
import TradingView/ta/10

//-----Defining Parameters
src = input.source(close)
len = input.int(50)
multi = input.float(1.75, step = 0.05)
len22 = len * multi
len2 = math.round(len22)
smoothlen = input.int(20)
upper = input.float(0.2, step = 0.01)
lower = input.float(-0.2, step = 0.01)
atrlength = input.int(20)

ATR = ta.atr(atrlength)

//-----Calculating the TEWMA
TEWMA1 = ta.tema(ta.wma(src, len), len)
TEWMA2 = ta.tema(ta.wma(src, len2), len2)
TEWMA = math.avg(TEWMA1, TEWMA2)

//-----Defining trend conditions
Long = TEWMA > TEWMA[1]
Short = TEWMA < TEWMA[1]

//-----Applying a var to determine trend direction
var Signal = 0

if Long
    Signal := 1

if Short
    Signal := -1


//-----Assigning line color based on trend direction
BullColor = color.rgb(49, 132, 228)
Bearcolor = color.rgb(132, 3, 158)
lineColor = Signal > 0 ? BullColor : Bearcolor


//-----Defining slope
slope = (TEWMA - TEWMA[1]) / ATR

//-----Calculating Smoothing Values
smoothed = ta.ema(slope, smoothlen)


//-----Defining colors and plotting
colorzz = slope > 0 ? BullColor : Bearcolor
colorz = smoothed > 0 ? BullColor : Bearcolor

scores1 = plot(slope, linewidth = 2, color = colorzz)
scores2 = plot(0, linewidth = 2, color = colorzz,display = display.none)
fill(plot1 = scores1, plot2 = scores2, top_value = slope, bottom_value = 0, top_color = colorzz, bottom_color = color.new(color.black, 100))

smoothed1 = plot(smoothed,  linewidth = 1, color = colorz)
smoothed2 = plot(0,  linewidth = 1, color = colorz, display = display.none)
fill(plot1 = smoothed1, plot2 = smoothed2, top_value = smoothed, bottom_value = 0, top_color = colorz, bottom_color = color.new(color.black, 100))

bgcolor(slope > upper ? color.rgb(49, 132, 228, 85) : slope < lower ? color.rgb(132, 3, 158, 85) : color.rgb(0, 0, 0), force_overlay = true)
bgcolor(smoothed > upper ? color.rgb(49, 132, 228, 85) : smoothed < lower ? color.rgb(132, 3, 158, 85) : color.rgb(0, 0, 0), force_overlay = true)
````
