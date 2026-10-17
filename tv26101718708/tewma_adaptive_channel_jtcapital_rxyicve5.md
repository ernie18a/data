# TEWMA Adaptive Channel - [JTCAPITAL]

- url: https://www.tradingview.com/script/RXyicVE5-TEWMA-Adaptive-Channel-JTCAPITAL/
- type: indicator
- pine_id: PUB;33c78f48237944e3bf766b7a3d63484f
- version: 1.0

## Description

[b]TEWMA Adaptive Channel - [JTCAPITAL][/b] is a modified way to use Weighted Moving Averages (WMA), Triple Exponential Moving Averages (TEMA), and Average True Range (ATR) for adaptive Trend-Following.

Instead of relying solely on a moving average to estimate trend direction, the indicator combines multiple layers of smoothing with volatility-adjusted boundaries to distinguish between ordinary price fluctuations and genuine momentum expansions. By requiring price to exceed an adaptive volatility threshold before establishing directional bias, the indicator aims to filter insignificant market noise while remaining responsive to meaningful changes in trend.

The result is an adaptive channel that not only reflects the current trend structure but also highlights moments where volatility expands enough to suggest the beginning or continuation of directional movement.

The indicator works by calculating in the following steps:

[list=1]

[*] [b]Source Selection[/b]

The script begins by selecting a price source. By default this is the closing price, although any TradingView supported source can be used, including Open, High, Low, HL2, HLC3, OHLC4 or any custom input.

Every calculation within the indicator originates from this selected source, allowing traders to tailor the responsiveness of the channel to their preferred price representation.                                           


[*] [b]Weighted Moving Average Pre-Smoothing[/b]

Before calculating the final trend estimate, the selected source is first smoothed using a Weighted Moving Average (WMA).

Unlike a Simple Moving Average, which treats every observation equally, the WMA assigns progressively larger weights to more recent price data. This allows the average to respond faster to changing market conditions while still filtering a significant portion of short-term market noise.

The indicator calculates two independent WMAs:

• A primary WMA using the selected Length.

• A secondary WMA whose Length is automatically determined by multiplying the primary Length by the selected Multiplier.

Using two separate smoothing horizons allows the indicator to simultaneously observe both intermediate and broader market structure.


[*] [b]Triple Exponential Moving Average Processing[/b]

Each Weighted Moving Average is then processed using a Triple Exponential Moving Average (TEMA).

The purpose of TEMA is to dramatically reduce the lag normally associated with moving averages while maintaining smooth trend estimation.

Rather than simply averaging prices multiple times, TEMA mathematically combines several exponential averages in a way that removes much of the delay introduced by conventional smoothing techniques.

The result is two independent TEWMAs:

• A faster trend estimate.

• A slower trend estimate.

Each provides a different perspective on the underlying market direction.


[*] [b]Adaptive Trend Estimation[/b]

Instead of selecting either the fast or slow trend estimate individually, the script averages both together.

This creates the final TEWMA centerline.

Combining two smoothing horizons provides several advantages:

• Faster reaction than relying solely on a long-period average.

• Less sensitivity than relying only on a short-period average.

• Better stability during consolidations.

• Smoother representation of sustained directional movement.

The centerline therefore serves as the primary estimate of the underlying market trend.


[*] [b]Average True Range (ATR) Calculation[/b]

While the trend estimate is being constructed, the script also calculates the Average True Range (ATR).

ATR measures current market volatility by evaluating the True Range over the selected ATR Length.

Unlike indicators that only observe closing prices, ATR incorporates:

• Current High

• Current Low

• Previous Close

This enables volatility to be measured even when markets gap between candles.

Higher ATR values indicate expanding volatility, while lower values indicate quieter market conditions.


[*] [b]Adaptive Channel Construction[/b]

The ATR is multiplied by the selected Multiplier and added to both sides of the TEWMA centerline.

Upper Channel:

TEWMA + ATR × Multiplier

Lower Channel:

TEWMA − ATR × Multiplier

Unlike fixed-width envelopes, these boundaries continuously adapt to changing market conditions.

During volatile periods the channel naturally expands.

During quieter periods it contracts.

This adaptive behavior allows the indicator to maintain consistent sensitivity across different market environments.


[*] [b]Trend Confirmation Logic[/b]

Rather than determining trend direction simply by whether price is above or below the moving average, the indicator waits for price to demonstrate sufficient strength to move beyond the adaptive volatility envelope.

A close above the Upper Adaptive Channel confirms bullish momentum.

A close below the Lower Adaptive Channel confirms bearish momentum.

Once one of these conditions has been established, that directional bias remains active until price proves enough strength to invalidate it by exceeding the opposite side of the channel.

Because the trend state is preserved during ordinary pullbacks inside the channel, the indicator produces a much smoother representation of prevailing market direction and avoids unnecessary fluctuations caused by short-term noise.


[*] [b]Momentum Expansion Detection[/b]

Whenever price closes beyond either adaptive boundary, the corresponding channel immediately changes color.

These colored channel boundaries are not intended to signal overbought or oversold conditions.

Instead, they highlight moments where price has travelled beyond its statistically expected volatility range.

Such events frequently occur during:

• Breakout candles

• Strong trend continuation

• Volatility expansion

• Momentum acceleration

• Periods of increased market participation

Because the adaptive bands are volatility-adjusted, these highlighted moments naturally become rarer during quiet markets while remaining meaningful during highly active conditions.

[/list]

Buy and Sell Conditions:

This indicator is designed as an adaptive trend-following framework rather than a fixed signal generator.

Instead of producing mechanical Buy and Sell arrows, it continuously evaluates whether market momentum is strong enough to establish or maintain a directional trend.

Bullish market conditions are identified when price successfully closes above the Upper Adaptive Channel. This indicates that buying pressure has expanded beyond recent normal volatility and confirms bullish directional strength. Once confirmed, the TEWMA centerline represents this bullish market bias until sufficient bearish momentum develops.

Bearish market conditions are identified when price closes below the Lower Adaptive Channel. This reflects selling pressure strong enough to exceed recent market volatility and establishes a bearish directional bias that remains active until the opposite condition occurs.

Because ordinary pullbacks inside the adaptive channel do not immediately alter the prevailing trend, the indicator naturally filters much of the short-term market noise that frequently causes false directional changes in conventional moving average systems.

Additional confirmation can always be incorporated using tools such as RSI, MACD, ADX, Volume, Higher Timeframe analysis, Price Action, or Market Structure depending on individual trading style.

Features and Parameters:
Source
Selects the price series used throughout every calculation.
Length
Determines the primary smoothing period used for the first Weighted Moving Average and TEMA calculation.
Multiplier
Controls two adaptive mechanisms simultaneously:
Determines the secondary smoothing period.
Determines the width of the ATR channel.
Automatic Dual-Length Trend Estimation
Creates a second smoothing period automatically by multiplying the primary Length with the selected Multiplier, allowing the indicator to blend both intermediate and longer-term market structure.
ATR Length
Determines the sensitivity of volatility measurements.
Adaptive Volatility Channel
Expands automatically during volatile markets.
Contracts automatically during quieter markets.
Persistent Trend Detection
Maintains the prevailing directional bias until an opposing volatility-confirmed breakout occurs, reducing unnecessary trend reversals during temporary retracements.
Momentum Expansion Visualization
Highlights periods where price exceeds its adaptive volatility envelope, drawing attention to moments of exceptional directional strength.
Specifications:
[b]Weighted Moving Average (WMA)[/b]

The Weighted Moving Average is a price smoothing technique that places progressively greater emphasis on the most recent observations while still incorporating historical price data.

Compared to a Simple Moving Average, this produces a faster response to changing market conditions without sacrificing the overall stability of the trend estimate.

Within this indicator, the WMA serves as the initial smoothing stage before the more advanced Triple Exponential calculations are performed.

[b]Triple Exponential Moving Average (TEMA)[/b]

The Triple Exponential Moving Average was specifically developed to minimize one of the largest weaknesses of traditional moving averages: lag.

Rather than simply averaging prices repeatedly, TEMA combines multiple exponential calculations in a mathematical way that significantly reduces delay while maintaining smooth trend estimation.

This allows the indicator to remain responsive during changing market conditions without becoming excessively sensitive to short-term fluctuations.

[b]Dual Adaptive Trend Estimation[/b]

One of the defining characteristics of this indicator is that it does not rely upon a single smoothing horizon.

Instead, it combines both a faster and slower TEWMA into one balanced trend estimate.

This provides a centerline capable of reacting to developing market conditions while still filtering much of the erratic behavior commonly associated with shorter moving averages.

The result is a smoother and more reliable representation of the prevailing market direction.

[b]Average True Range (ATR)[/b]

Average True Range is one of the most widely recognized volatility measurements in technical analysis.

Rather than measuring whether price is bullish or bearish, ATR measures the magnitude of price movement.

By incorporating both intraday movement and overnight price gaps, ATR provides a realistic estimate of current market volatility that continuously adapts as conditions change.

[b]Adaptive Volatility Channels[/b]

The upper and lower channel boundaries are constructed by adding and subtracting an ATR-based volatility measurement from the TEWMA centerline.

Unlike static envelopes, these bands constantly adjust their width according to prevailing market conditions.

This allows the channel to remain proportionate regardless of whether markets are experiencing low-volatility consolidation or high-volatility expansion.

[b]Trend Confirmation[/b]

The indicator uses the adaptive channel as a confirmation mechanism rather than allowing minor fluctuations around the moving average to dictate trend direction.

By requiring price to exceed the adaptive volatility threshold before establishing a directional bias, the indicator focuses on movements that demonstrate sufficient conviction to stand out from normal market behavior.

This approach significantly reduces frequent directional changes during ranging markets while preserving responsiveness during genuine trend development.

[b]Momentum Expansion[/b]

When price moves beyond either adaptive channel boundary, it has exceeded what recent volatility would generally consider normal price behavior.

These moments often coincide with expanding participation, increasing momentum and stronger directional conviction.

Rather than predicting reversals or guaranteeing continuation, the adaptive channel simply highlights that the market is currently experiencing an unusually energetic price movement relative to its recent volatility profile.

[b]Persistent Trend Representation[/b]

The TEWMA centerline serves as a continuously updated representation of the prevailing market bias.

Because the underlying trend state only changes after price has demonstrated sufficient strength to exceed the adaptive channel in the opposite direction, temporary retracements and ordinary market noise have less influence on the overall trend indication.

This allows traders to focus on the broader directional structure instead of reacting to every short-lived fluctuation.

[b]Combining Trend and Volatility[/b]

One of the primary strengths of this indicator lies in the combination of adaptive smoothing with adaptive volatility.

The TEWMA centerline estimates the underlying direction of the market, while the ATR channel continuously evaluates whether price movement possesses enough momentum to confirm that direction.

By combining these two independent measurements, the indicator delivers a framework that simultaneously monitors trend, volatility, momentum, and market structure, making it particularly effective across a wide variety of market conditions while remaining intuitive to interpret.

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

   

indicator("TEWMA Adaptive Channel - [JTCAPITAL]", overlay = true)
import TradingView/ta/10

//-----Defining Parameters
src = input.source(close)
len = input.int(50)
multi = input.float(1.75, step = 0.05)
len22 = len * multi
len2 = math.round(len22)
atrlength = input.int(20)

//-----Defining ATR
ATR = ta.atr(atrlength)


//-----Calculating the TEWMA
TEWMA1 = ta.tema(ta.wma(src, len), len)
TEWMA2 = ta.tema(ta.wma(src, len2), len2)
TEWMA = math.avg(TEWMA1, TEWMA2)

//-----Defining upper lower limits
upper = TEWMA + (ATR * multi)
lower = TEWMA - (ATR * multi)

//-----Assigning line color based on upper lower passes
BullColor = color.rgb(49, 132, 228)
Bearcolor = color.rgb(132, 3, 158)

linecolorup = close > upper ? Bearcolor : BullColor
linecolordown = close < lower ? Bearcolor : BullColor


//-----Defining var scoring for middle line
var score = 0

if close > upper
    score := 1

if close < lower
    score := -1


//-----Showing trend based on middle line color
lineColor = color.black
if score > 0
    lineColor := BullColor

if score < 0
    lineColor := Bearcolor

//-----Plotting
plot1 = plot(TEWMA, color=lineColor, linewidth=3)
plot12 = plot(TEWMA * 0.9, color = lineColor, display = display.none)
fill(plot1 = plot1,plot2 = plot12, top_value = TEWMA, bottom_value = TEWMA * 0.9, top_color = lineColor, bottom_color = color.new(color.black, 100))

plot2 = plot(lower, color=linecolordown, linewidth=1)
plot22 = plot(lower * 0.9, color = linecolordown, display = display.none)
fill(plot1 = plot2,plot2 = plot22, top_value = lower, bottom_value = lower * 0.9, top_color = linecolordown, bottom_color = color.new(color.black, 100))

plot3 = plot(upper, color=linecolorup, linewidth=1)
plot32 = plot(upper * 0.9, color = linecolorup, display = display.none)
fill(plot1 = plot3,plot2 = plot32, top_value = upper, bottom_value = upper * 0.9, top_color = linecolorup, bottom_color = color.new(color.black, 100))
````
