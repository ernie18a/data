<!-- tradingview-pine-id: PUB;eac978b23b2942cdac56eec8480a6c46 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Guassian Filtered TEWMA - [JTCAPITAL]

Source: https://www.tradingview.com/script/R9rxW2u2-Guassian-Filtered-TEWMA-JTCAPITAL/

## Description

Guassian Filtered TEWMA - [JTCAPITAL] is a modified way to use Gaussian filtering, Weighted Moving Averages (WMA), Triple Exponential Moving Averages (TEMA), and a dual-length averaging structure for Trend-Following.

The indicator is designed to create a smoother representation of market direction by processing price through multiple layers of smoothing. Instead of relying on a single moving average, the script first applies a Gaussian filter to the selected price source, then builds two separate TEWMA calculations using different lengths, averages those two calculations together, and finally applies another Gaussian filter to the combined result.

The result is a visually smooth trend-following structure that attempts to reduce short-term price noise while retaining the underlying directional movement of the market.

The indicator does not use future price data in its calculations. The BUY and SELL labels are generated when the detected direction changes from bullish to bearish or from bearish to bullish.

The indicator works by calculating in the following steps:

[*] Price Source Selection

The script begins with the selected price source, which is set to Close by default. TradingView's input.source allows the user to select another available price series if desired.

This selected source becomes the raw input for the first Gaussian filtering stage.

The purpose of beginning with a configurable source is to allow the smoothing process to be applied to different representations of price rather than forcing the entire calculation to use only the closing price.

[*] First Gaussian Filter

The selected price source is passed through a custom Gaussian filter.

The Gaussian filter looks backward over a user-defined number of bars, controlled by the Length parameter. For every historical bar inside this window, the script calculates a Gaussian weight using the following mathematical relationship:

Weight = exp(-0.5 * (i / Sigma)^2)

Here, i represents how many bars back the calculation is looking, while Sigma controls how quickly the weighting decreases as the calculation moves further into the past.

The current bar receives the largest weight because i = 0. As the script moves further backward, the Gaussian weight becomes progressively smaller.

Each historical source value is multiplied by its corresponding Gaussian weight. These weighted values are then added together and divided by the total sum of all weights.

In simplified form:

Gaussian Filter = Sum(Source × Weight) / Sum(Weight)

This produces a weighted average where more recent data has greater influence than older data.

Unlike a simple moving average, where every observation inside the window receives the same weight, the Gaussian filter gradually reduces the influence of older observations.

This makes the first filtering stage useful for reducing short-term fluctuations before the data enters the TEWMA calculations.

[*] Defining the Primary TEWMA Length

The script defines a primary TEWMA length using the Length input.

By default, this value is 84.

This length is used as the basis for the first TEWMA calculation and determines how much historical information is incorporated into that moving average structure.

A larger value generally produces a slower and smoother response, while a smaller value generally produces a faster and more responsive response.

[*] Creating the Secondary TEWMA Length

The script does not simply use one TEWMA length.

Instead, it creates a second length by multiplying the primary length by the Multi parameter.

The calculation is:

Secondary Length = Primary Length × Multi

With the default settings:

84 × 1.75 = 147

The result is then rounded to the nearest whole number because moving-average lengths must be integer values.

Therefore, the default secondary length is 147.

This creates two different trend speeds: one relatively faster TEWMA and one slower TEWMA.

[*] Weighted Moving Average Calculation

The first TEWMA structure begins by calculating a Weighted Moving Average of the Gaussian-filtered source.

The WMA gives greater importance to more recent observations and progressively less importance to older observations inside its calculation window.

This provides another layer of directional smoothing while maintaining more responsiveness to recent price changes than a simple moving average would normally provide.

The WMA therefore forms the first stage of each TEWMA calculation.

[*] Triple Exponential Moving Average Calculation

After calculating the WMA, the script passes that result through TradingView's TEMA function.

TEMA stands for Triple Exponential Moving Average.

TEMA is designed to reduce the lag that can occur with conventional moving averages by combining multiple exponential moving-average calculations.

Conceptually, a TEMA can be represented as:

TEMA = 3 × EMA1 - 3 × EMA2 + EMA3

where EMA1 is the first exponential moving average, EMA2 is an EMA of EMA1, and EMA3 is an EMA of EMA2.

In this script, TEMA is applied to the WMA output rather than directly to raw price.

This creates the TEWMA structure used by the indicator.

[*] Fast TEWMA

The first complete TEWMA calculation uses the primary Length.

The calculation can therefore be represented conceptually as:

TEWMA1 = TEMA(WMA(Gaussian-filtered source, Length), Length)

With the default parameters, the Gaussian-filtered source is first processed with an 84-period WMA and that result is then processed through an 84-period TEMA.

The purpose is to combine the weighting characteristics of WMA with the lag-reduction characteristics of TEMA.

[*] Slow TEWMA

The second TEWMA uses the calculated secondary length.

The calculation is:

TEWMA2 = TEMA(WMA(Gaussian-filtered source, Secondary Length), Secondary Length)

With the default settings, the secondary length is 147.

Because this calculation uses a longer period, TEWMA2 generally reacts more slowly to changes in price than TEWMA1.

This gives the indicator two different representations of the underlying trend.

[*] Dual TEWMA Averaging

The two TEWMA calculations are then combined using an arithmetic average:

TEWMA = (TEWMA1 + TEWMA2) / 2

The script uses math.avg to perform this calculation.

This is an important part of the indicator's structure.

Instead of allowing the shorter TEWMA or longer TEWMA to independently determine the final trend representation, both are given equal weight.

The faster TEWMA contributes responsiveness, while the slower TEWMA contributes additional stability.

Averaging them creates an intermediate representation between the two trend speeds.

[*] Second Gaussian Filter

After the two TEWMA calculations are averaged, the resulting TEWMA is passed through the Gaussian filter again.

This creates the final Gaussian series.

The second Gaussian filtering stage further smooths the already-smoothed TEWMA structure.

The resulting sequence is therefore:

Price Source → Gaussian Filter → WMA → TEMA → TEWMA1

and simultaneously:

Price Source → Gaussian Filter → WMA → TEMA → TEWMA2

The two TEWMAs are then averaged:

TEWMA1 + TEWMA2 → Average TEWMA

and finally:

Average TEWMA → Gaussian Filter → Final Gaussian Trend Line

This multi-stage architecture is the central concept of the indicator.

[*] Trend Direction Detection

Once the final Gaussian-filtered TEWMA has been calculated, the script compares its current value with its previous value.

The bullish condition is:

Gaussian > Gaussian[1]

If the current Gaussian value is higher than the previous bar's value, the indicator considers the trend to be bullish.

The bearish condition is:

Gaussian < Gaussian[1]

If the current Gaussian value is lower than the previous bar's value, the indicator considers the trend to be bearish.

Therefore, the trend direction is determined by the slope of the final Gaussian-filtered TEWMA, rather than by a price crossing a traditional moving average.

[*] Persistent Trend State

The script uses a persistent variable called Signal to maintain the current trend state.

A bullish condition sets:

Signal = 1

A bearish condition sets:

Signal = -1

Because the variable is declared using var, its previous value is retained until a new bullish or bearish condition updates it.

This creates a persistent binary trend state:

1 = Bullish

-1 = Bearish

This state is subsequently used to determine the colors of the plotted lines and to identify actual transitions between bullish and bearish conditions.

[*] Trend Visualization

When the signal is bullish, the script uses the defined BullColor.

When the signal is bearish, the script uses the defined BearColor.

The same trend state is applied to the Gaussian line, both TEWMA lines, and the averaged TEWMA line.

This means the entire indicator structure changes color together when the detected trend direction changes.

The visual design therefore allows the user to identify the current directional state without having to inspect the numerical values of the individual calculations.

[*] BUY Signal Detection

A BUY label is only created when the persistent signal changes from bearish to bullish.

The condition is:

Signal > 0 and Signal[1] < 0

This means the indicator must have been bearish on the previous bar and bullish on the current bar.

The BUY label is therefore not printed on every bullish bar.

Instead, it is printed only at the transition from a bearish state to a bullish state.

The label is positioned using the lowest value among the four primary plotted lines:

Gaussian

TEWMA

TEWMA1

TEWMA2

This places the BUY label below the lowest part of the indicator structure for that bar.

[*] SELL Signal Detection

The SELL condition works in the opposite direction.

A SELL label is created when:

Signal < 0 and Signal[1] > 0

This means the previous bar was bullish while the current bar is bearish.

Like the BUY label, the SELL label is only generated at a trend-state transition.

The SELL label is positioned using the highest value among the Gaussian line, TEWMA, TEWMA1, and TEWMA2.

This places the SELL label above the highest part of the indicator structure.

Buy and Sell Conditions:

The indicator's directional logic is deliberately straightforward.

Bullish Trend

A bullish trend is detected whenever the final Gaussian-filtered TEWMA is rising compared with the previous bar.

Gaussian > Gaussian[1]

When this condition occurs, the persistent signal state becomes 1, and the indicator structure is displayed using the bullish color.

Bearish Trend

A bearish trend is detected whenever the final Gaussian-filtered TEWMA is falling compared with the previous bar.

Gaussian < Gaussian[1]

When this condition occurs, the persistent signal state becomes -1, and the indicator structure is displayed using the bearish color.

BUY Label

A BUY label is only generated when the signal changes from:

Bearish → Bullish

This prevents a BUY label from appearing on every bar during an already-established bullish trend.

SELL Label

A SELL label is only generated when the signal changes from:

Bullish → Bearish

This similarly prevents repeated SELL labels during an established bearish trend.

It is important to understand that these labels represent changes in the calculated trend direction. They are not entries generated by a backtested strategy, and the indicator does not calculate position size, stop-loss levels, take-profit levels, risk/reward ratios, or trade performance.

The script also does not contain an additional momentum, volume, volatility, or market-regime filter. The signal is determined specifically by the direction of the final Gaussian-filtered TEWMA.

Features and Parameters:

* Source - Selects the price series used as the initial input. The default source is Close.

* Gaussian Length - Determines how many historical bars are included in each Gaussian filtering calculation. The default is 30.

* Sigma - Controls the shape and decay of the Gaussian weighting function. The default is 6.0. Higher values make the weighting decay more gradually, allowing older observations to retain more influence. Lower values concentrate the weighting more strongly toward recent observations.

* TEWMA Length - Defines the primary length used by the first WMA and TEMA stages. The default is 84.

* Multi - Multiplies the primary TEWMA length to create the second TEWMA length. The default is 1.75.

* Secondary TEWMA Length - Automatically calculated as the primary length multiplied by Multi and rounded to the nearest integer. With the default settings, this produces 147.

* TEWMA1 - The faster of the two TEWMA calculations.

* TEWMA2 - The slower of the two TEWMA calculations.

* TEWMA - The arithmetic average of TEWMA1 and TEWMA2.

* Final Gaussian - A second Gaussian-filtered version of the averaged TEWMA and the primary trend line used for determining direction.

* Trend Coloring - All major plotted lines use the same bullish or bearish color according to the current Signal state.

* BUY Labels - Appear when the calculated trend state changes from bearish to bullish.

* SELL Labels - Appear when the calculated trend state changes from bullish to bearish.

* Visual Ribbon - The script uses filled areas beneath the Gaussian, TEWMA1, TEWMA2, and averaged TEWMA lines to create a layered visual representation of the trend structure.

Specifications:

Gaussian Filter

A Gaussian filter is a weighted smoothing method based on the Gaussian, or normal, distribution.

Instead of assigning identical importance to every observation in the lookback window, the Gaussian filter gives the most recent observation the greatest weight and progressively reduces the influence of observations further in the past.

In this script, the Gaussian weighting is calculated using:

Weight = exp(-0.5 × (i / Sigma)^2)

The weighted observations are then normalized by dividing their weighted sum by the total sum of the weights.

This normalization is important because it ensures that the output remains on a comparable price scale rather than simply becoming the sum of the weighted observations.

The Gaussian filter is used twice in this indicator.

The first application smooths the selected price source before it enters the TEWMA calculations.

The second application smooths the averaged TEWMA after both trend calculations have been combined.

This creates a multi-stage smoothing architecture in which the raw price is progressively transformed into a smoother representation of directional movement.

Gaussian Length

Gaussian Length determines the number of historical observations included in each Gaussian filter.

With a default value of 30, the filter examines the current observation and the preceding 29 observations.

Increasing the length expands the historical window and can produce a smoother result.

Reducing the length shortens the window and generally allows the filter to respond more quickly to changes in price.

Length therefore represents the time window over which the Gaussian smoothing is performed.

Sigma

Sigma controls the distribution of the Gaussian weights.

The weighting function is:

exp(-0.5 × (i / Sigma)^2)

When Sigma increases, the weight decreases more slowly as the calculation moves backward through history.

Consequently, older observations retain more relative influence.

When Sigma decreases, the weight falls more rapidly, concentrating more of the calculation around recent observations.

Sigma therefore controls the shape of the smoothing kernel, while Length determines the size of the historical window.

These two parameters work together rather than independently.

Weighted Moving Average (WMA)

A Weighted Moving Average assigns progressively different weights to observations within its lookback period.

Recent observations receive greater importance than older observations.

Compared with an SMA, this allows the average to react more strongly to recent changes in the underlying series.

The WMA is used here after the initial Gaussian filtering.

This means the WMA does not operate directly on raw price. It operates on an already-smoothed price series.

The combination therefore uses two different weighting mechanisms: Gaussian weighting in the first stage and WMA weighting in the TEWMA construction.

Triple Exponential Moving Average (TEMA)

TEMA stands for Triple Exponential Moving Average.

It is designed to reduce some of the lag associated with traditional moving averages by combining three levels of exponential averaging.

Conceptually:

EMA1 = EMA(Source)

EMA2 = EMA(EMA1)

EMA3 = EMA(EMA2)

and:

TEMA = 3 × EMA1 - 3 × EMA2 + EMA3

The subtraction terms help compensate for some of the lag introduced by repeated exponential smoothing.

In this indicator, the TEMA is applied to the WMA output, creating the TEWMA structure.

TEWMA

TEWMA in this script refers to the combination of a Weighted Moving Average followed by a Triple Exponential Moving Average.

The basic structure is:

Gaussian Filter → WMA → TEMA

This is not simply a conventional moving average. It is a layered smoothing process.

The Gaussian filter reduces short-term fluctuations first.

The WMA then applies recency-weighted averaging.

The TEMA subsequently processes the WMA output with a lag-reduction-oriented exponential structure.

The resulting TEWMA therefore combines several different approaches to smoothing and weighting price data.

Dual-Length TEWMA Structure

One of the defining characteristics of this indicator is that it does not rely on one TEWMA.

It calculates two.

TEWMA1 uses the primary length.

TEWMA2 uses a longer length determined by the Multi parameter.

The shorter calculation is generally more responsive to directional changes, while the longer calculation incorporates a broader historical window and therefore generally changes more slowly.

Combining these two speeds creates a balance between responsiveness and stability.

Multi

The Multi parameter controls the relationship between the two TEWMA lengths.

The calculation is:

Secondary Length = Primary Length × Multi

For example, with a primary length of 84 and Multi of 1.75:

84 × 1.75 = 147

This means the user can control the separation between the faster and slower TEWMA without manually entering two separate lengths.

A larger Multi creates a larger difference between the two smoothing speeds.

A smaller Multi brings the two TEWMA lengths closer together.

Averaged TEWMA

After TEWMA1 and TEWMA2 are calculated, the script takes their arithmetic mean:

TEWMA = (TEWMA1 + TEWMA2) / 2

This gives both TEWMA calculations equal influence.

The purpose is to prevent the final intermediate trend representation from depending exclusively on either the faster or slower calculation.

The averaged TEWMA acts as a central representation between the two trend speeds.

Second Gaussian Smoothing Stage

The averaged TEWMA is passed through another Gaussian filter.

This creates the final Gaussian series that drives the trend-state calculation.

The second Gaussian stage is particularly important because the TEWMA average has already combined two different smoothing speeds.

Applying Gaussian smoothing afterward further reduces short-term fluctuations in that combined signal.

The final result is therefore substantially more processed than the original price source.

Slope-Based Trend Detection

The indicator does not determine direction using a price crossover.

Instead, it evaluates whether the final Gaussian series is increasing or decreasing.

Rising Gaussian = Bullish

Falling Gaussian = Bearish

This makes the indicator fundamentally a slope-based trend detector.

The actual numerical distance between price and the trend line is not used for determining the signal.

The critical variable is whether the final filtered series is moving upward or downward from one bar to the next.

Persistent Signal State

The Signal variable stores either 1 or -1.

A value of 1 represents bullish direction.

A value of -1 represents bearish direction.

This persistent state is what allows the script to distinguish between an ongoing trend and an actual transition.

For example, if the indicator remains bullish for 20 consecutive bars, it does not generate 20 BUY labels.

Instead, the BUY label is generated when the state changes from -1 to 1.

Likewise, a SELL label is generated only when the state changes from 1 to -1.

Trend Colors

The script defines a bullish blue color and a bearish purple color.

The same color state is applied to the Gaussian line, TEWMA1, TEWMA2, and the averaged TEWMA.

This makes the indicator function visually as a unified trend structure rather than presenting each component as an independently colored indicator.

Indicator Ribbon

The script creates filled regions underneath each of the four main lines.

The visible upper boundary is the respective indicator line, while the lower boundary is calculated as:

Indicator Value × 0.9

This creates a visual area beneath each line.

These fills are primarily a visualization feature. The 0.9 multiplication does not participate in the trend calculation, signal generation, or Gaussian filtering.

The BUY and SELL logic is based on the actual Gaussian and TEWMA values, not on these filled areas.

Highest and Lowest Values

The script calculates:

Lowest = minimum of Gaussian, TEWMA, TEWMA1, and TEWMA2

and:

Highest = maximum of Gaussian, TEWMA, TEWMA1, and TEWMA2

These values are used only to determine the vertical placement of the BUY and SELL labels.

The lowest value is used for BUY labels so that they appear beneath the indicator structure.

The highest value is used for SELL labels so that they appear above the indicator structure.

These calculations do not influence the actual trend state.

Why Combine Gaussian Filtering, WMA, and TEMA?

The main purpose of combining these calculations is to approach the problem of trend detection from several different smoothing perspectives.

A single moving average can be relatively sensitive to price fluctuations or relatively slow depending on its length.

The Gaussian filter introduces a smooth, gradually declining weighting structure.

The WMA places greater emphasis on recent observations.

The TEMA introduces a different smoothing mechanism designed to reduce some of the lag associated with repeated exponential averaging.

By combining these methods sequentially, the indicator does not depend on one type of smoothing alone.

The first Gaussian filter reduces noise before the TEWMA calculations begin.

The WMA emphasizes more recent information.

The TEMA processes that weighted series through a multi-stage exponential structure.

Two different TEWMA lengths then provide two different trend speeds.

Averaging those two speeds creates an intermediate trend representation.

Finally, a second Gaussian filter smooths that combined result.

The overall architecture can therefore be summarized as:

Price → Gaussian Filter → Dual WMA/TEMA → Average → Gaussian Filter → Trend Direction

The objective is not to predict the future price with certainty. Instead, the design attempts to produce a smoother representation of directional movement that can make broader trend changes easier to observe.

Why Use Two TEWMA Speeds?

The use of two TEWMA lengths provides a balance between responsiveness and stability.

The shorter TEWMA reacts more quickly to changes in the filtered source.

The longer TEWMA reacts more slowly and incorporates a larger historical window.

If only the shorter calculation were used, the trend representation could react more quickly but would also be more exposed to short-term fluctuations.

If only the longer calculation were used, the resulting trend representation would generally be more stable but slower to respond to changes.

Averaging the two creates a middle ground.

This is one of the central design choices of the indicator.

Why Apply Gaussian Filtering Twice?

The first Gaussian filter operates on the source before the TEWMA calculations.

Its role is to prepare the input by reducing short-term fluctuations before the moving-average calculations are performed.

The second Gaussian filter operates after the two TEWMAs have been averaged.

Its role is different: it smooths the final combined trend representation.

Using the filter at both stages creates a layered smoothing process rather than relying on one smoothing operation.

How to Use the Indicator

The indicator can be used primarily as a visual trend-following tool.

When the plotted structure is bullish in color and the final Gaussian line is rising, the calculated trend state is bullish.

When the plotted structure is bearish in color and the final Gaussian line is falling, the calculated trend state is bearish.

The BUY label identifies the transition into a bullish state.

The SELL label identifies the transition into a bearish state.

Users can use these transitions as potential points of interest for further analysis.

However, the indicator should be interpreted within the context of the market, timeframe, and instrument being analyzed. A trend-following calculation can naturally react differently during persistent trends compared with sideways or highly volatile conditions.

Understanding the Parameters

Length controls the Gaussian lookback window.

Sigma controls the distribution of Gaussian weights.

TEWMA Length controls the primary WMA/TEMA smoothing period.

Multi controls the relative distance between the faster and slower TEWMA.

Increasing the Gaussian Length generally increases the amount of historical data included in the filtering process.

Increasing Sigma generally spreads the Gaussian weighting more broadly across the available lookback window.

Increasing the TEWMA Length generally creates a slower and smoother trend representation.

Increasing Multi increases the difference between the two TEWMA speeds.

There is no universally optimal combination of these parameters. Different markets, instruments, and timeframes can exhibit substantially different price behavior, so users should evaluate parameter choices according to their own application.

Limitations and Important Considerations

This indicator is a trend-following tool and should not be interpreted as a prediction mechanism.

Because the script uses several layers of smoothing, changes in the final trend line can occur after the underlying price movement has already begun.

This is an inherent characteristic of smoothing-based trend indicators. More smoothing can reduce short-term fluctuations, but it can also make the resulting trend representation less responsive to sudden price changes.

Conversely, reducing the smoothing parameters can make the indicator respond more quickly while potentially exposing the trend state to more short-term fluctuations.

The BUY and SELL labels should therefore not be interpreted as guaranteed trade entries or exits.

The script is an indicator, not a TradingView strategy. It does not calculate historical strategy performance, win rate, profit factor, drawdown, position sizing, commissions, slippage, stop-losses, take-profit levels, or risk/reward ratios.

No performance or accuracy claims are made by this publication.

The indicator also does not contain a volume filter, volatility filter, momentum filter, market-regime filter, or higher-timeframe confirmation mechanism. The directional state is determined specifically by the slope of the final Gaussian-filtered TEWMA.

The Gaussian filter uses historical indexing based on the selected Length. Consequently, the available historical data and Pine Script's historical-reference limitations can affect how large the Gaussian Length can practically be set on a chart.

As with any moving-average-based calculation, insufficient historical bars can also result in unavailable values during the initial portion of a chart until enough data exists to perform the required calculations.

The script does not intentionally reference future bars. Its Gaussian filter uses the current bar and historical bars only.

On a realtime, still-forming candle, however, the current source value can change as new ticks arrive. Because the final trend calculation depends on the current bar's value, the current trend state and any signal condition can change while the realtime candle is still forming. Users should therefore distinguish between an evolving realtime bar and a confirmed historical bar.

What Makes This Indicator Different?

The purpose of this script is not simply to combine unrelated indicators.

Its components are directly connected to a single objective: constructing a smoother trend representation.

The Gaussian filter is used to reduce noise.

The WMA introduces recency weighting.

The TEMA processes the weighted series through a multi-stage exponential structure.

Two TEWMA lengths provide different trend speeds.

The two TEWMAs are averaged to create a combined trend representation.

A second Gaussian filter smooths that combined representation.

Finally, the slope of that final series determines the bullish or bearish state.

The combination therefore has a specific architectural purpose rather than being a collection of unrelated indicators.

The indicator's core concept can be summarized as:

Smooth the source → build two trend speeds → combine them → smooth the combined trend → detect its direction.

In Summary

Guassian Filtered TEWMA - [JTCAPITAL] is a multi-stage trend-following indicator built around a combination of Gaussian filtering, Weighted Moving Averages, Triple Exponential Moving Averages, and dual-length trend calculations.

The process begins by smoothing the selected price source with a Gaussian filter.

The filtered source is then processed through two separate WMA-to-TEMA structures using different lengths.

The resulting TEWMA1 and TEWMA2 calculations are averaged together.

That average is passed through a second Gaussian filter to produce the final trend line.

The script then compares the current final Gaussian value with its previous value.

A rising final Gaussian represents a bullish trend state.

A falling final Gaussian represents a bearish trend state.

When the state changes from bearish to bullish, a BUY label is generated.

When the state changes from bullish to bearish, a SELL label is generated.

The resulting indicator is therefore designed to provide a visually smooth representation of directional market movement while retaining two different underlying trend speeds within the calculation.

As always, the indicator should be evaluated in the context of the instrument, timeframe, market conditions, and the user's broader analysis rather than being treated as a standalone guarantee of future price direction.

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

   

indicator("Guassian Filtered TEWMA - [JTCAPITAL]", overlay = true)
import TradingView/ta/10



//-----Defining Gaussian Parameters
length = input.int(30, "Length", minval=1)
sigma  = input.float(6.0, "Sigma", minval=0.1)

//-----Gaussian filter
gaussianFilter(src, length, sigma) =>
    float sum = 0.0
    float weightedSum = 0.0

    for i = 0 to length - 1
        weight = math.exp(-0.5 * math.pow(i / sigma, 2))
        weightedSum += src[i] * weight
        sum += weight

    weightedSum / sum

//-----Defining Parameters
src = gaussianFilter(input.source(close), length, sigma)
len = input.int(84)
multi = input.float(1.75, step = 0.05)
len22 = len * multi
len2 = math.round(len22)


//-----Calculating the TEWMA and gaussian filtered TEWMA
TEWMA1 = ta.tema(ta.wma(src, len), len)
TEWMA2 = ta.tema(ta.wma(src, len2), len2)
TEWMA = math.avg(TEWMA1, TEWMA2)
gaussian = gaussianFilter(TEWMA, length, sigma)


//-----Defining trend conditions
Long = gaussian > gaussian[1]
Short = gaussian < gaussian[1]

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


//-----Plotting
plot1 = plot(gaussian, color=lineColor, linewidth=3)
plot12 = plot(gaussian * 0.9, color = lineColor, display = display.none)
fill(plot1 = plot1,plot2 = plot12, top_value = gaussian, bottom_value = gaussian * 0.9, top_color = lineColor, bottom_color = color.new(color.black, 100))

plot2 = plot(TEWMA1, color=lineColor, linewidth=1)
plot22 = plot(TEWMA1 * 0.9, color = lineColor, display = display.none)
fill(plot1 = plot2,plot2 = plot22, top_value = TEWMA1, bottom_value = TEWMA1 * 0.9, top_color = lineColor, bottom_color = color.new(color.black, 100))

plot3 = plot(TEWMA2, color=lineColor, linewidth=1)
plot32 = plot(TEWMA2 * 0.9, color = lineColor, display = display.none)
fill(plot1 = plot3,plot2 = plot32, top_value = TEWMA2, bottom_value = TEWMA2 * 0.9, top_color = lineColor, bottom_color = color.new(color.black, 100))

plot4 = plot(TEWMA, color=lineColor, linewidth=1)
plot42 = plot(TEWMA * 0.9, color = lineColor, display = display.none)
fill(plot1 = plot4,plot2 = plot42, top_value = TEWMA, bottom_value = TEWMA * 0.9, top_color = lineColor, bottom_color = color.new(color.black, 100))


lowest = math.min(gaussian, TEWMA, TEWMA1, TEWMA2)
highest = math.max(gaussian, TEWMA, TEWMA1, TEWMA2)

//-----Plotting labels
if Signal > 0 and Signal[1] < 0
    label.new(
     bar_index,
     lowest,
     "BUY",
     style=label.style_label_up,
     color=BullColor,
     textcolor=color.white
     )

if Signal < 0 and Signal[1] > 0
    label.new(
     bar_index,
     highest,
     "SELL",
     style=label.style_label_down,
     color=Bearcolor,
     textcolor=color.white
     )
````
