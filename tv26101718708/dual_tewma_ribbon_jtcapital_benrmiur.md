# Dual TEWMA Ribbon - [JTCAPITAL]

- url: https://www.tradingview.com/script/beNRmIur-Dual-TEWMA-Ribbon-JTCAPITAL/
- type: indicator
- pine_id: PUB;9c5fae8725a142d99523a8dc8c0c6fc9
- version: 1.0

## Description

'[b]Dual TEWMA Ribbon - [JTCAPITAL][/b]' is a modified way to use [b]multiple Triple Exponential Moving Average calculations, Weighted Moving Average smoothing, proportional length scaling, and multi-timeframe-style trend confirmation[/b] for Trend-Following.

Instead of relying on a single Moving Average, this indicator calculates [b]six separate TEWMA-based trend lines[/b]. Each line operates at a progressively longer calculation length, allowing the ribbon to represent different levels of market responsiveness. The shorter calculations react more quickly to changes in price, while the longer calculations respond more slowly and can help represent the broader underlying trend.

The core idea behind the indicator is that a trend can be evaluated across multiple smoothing speeds at the same time. When the faster and slower TEWMA calculations begin pointing in the same direction, the ribbon can provide a broader view of directional momentum. When the individual lines disagree, this can visually represent a market where shorter-term and longer-term trend calculations are not aligned.

The indicator also calculates an overall score based on the directional state of all six TEWMA lines. This score is then used to determine the script's overall bullish or bearish signal state. BUY and SELL labels are only plotted when the overall state transitions from bearish to bullish or from bullish to bearish according to the specific thresholds defined in the code.

The indicator works by calculating in the following steps:

[list=1]

[*] [b]Selecting the Price Source[/b]

The first step is selecting the price source used for all calculations. The default source is the closing price, but TradingView allows the source to be changed to other available price series.

Every subsequent calculation in the indicator begins with this selected source. This means that changing the source changes the underlying data used by all six TEWMA calculations.

[*] [b]Defining the Base Length and Multiplier[/b]

The script uses two primary parameters:

-The base length, which defaults to 36.
-The multiplier, which defaults to 1.4.

The multiplier is applied to the base length to create a second adjusted calculation length.

The first adjusted length is calculated as:

[i]Adjusted Length = Base Length × Multiplier[/i]

The result is rounded to the nearest whole number because Moving Average lengths must be used as integer values.

With the default settings:

[i]36 × 1.4 = 50.4[/i]

After rounding, the second length becomes approximately 50.

[*] [b]Creating Progressively Longer Ribbon Lengths[/b]

The script does not only use the original base length. It progressively scales the base length from one times the base value to six times the base value.

The six primary lengths are:

-1 × Base Length
-2 × Base Length
-3 × Base Length
-4 × Base Length
-5 × Base Length
-6 × Base Length

Each of these lengths is then multiplied by the selected multiplier to create a corresponding second calculation length.

This creates six pairs of Moving Average calculations.

The first pair represents the fastest portion of the ribbon, while the sixth pair represents the slowest portion.

[*] [b]Weighted Moving Average Smoothing[/b]

For every individual calculation length, the selected source is first processed using a Weighted Moving Average, or WMA.

The WMA gives greater weight to more recent price data and less weight to older observations.

This creates an initial layer of smoothing while still allowing newer price information to have a stronger influence on the result.

[*] [b]Applying the Triple Exponential Moving Average[/b]

After the WMA is calculated, the result is passed into TradingView's Triple Exponential Moving Average function.

This creates the TEWMA structure used throughout the indicator:

[i]TEWMA = TEMA(WMA(Source, Length), Length)[/i]

The same length is used for both the initial WMA and the following TEMA calculation.

Each individual TEWMA therefore applies two stages of smoothing:

-First, the source is smoothed with a WMA.
-Second, the WMA output is processed through a TEMA.

The combination is designed to create a smoothed trend-following calculation while using TEMA as the final smoothing stage.

[*] [b]Calculating Two TEWMAs for Each Ribbon Level[/b]

Each of the six ribbon levels contains two separate TEWMA calculations.

The first uses the primary length.

The second uses the same primary length multiplied by the selected multiplier.

For example, the first ribbon level calculates:

-TEWMA using the base length.
-TEWMA using the base length multiplied by the multiplier.

These two TEWMA values are then averaged together.

The calculation is:

[i]Final TEWMA = Average(TEWMA Primary Length, TEWMA Adjusted Length)[/i]

This same process is repeated for all six progressively longer ribbon levels.

[*] [b]Creating the Six Final Ribbon Lines[/b]

After the paired calculations are averaged, the indicator produces six final TEWMA lines.

These lines represent increasingly slower trend calculations.

The first line uses the shortest pair of lengths and is therefore the most responsive.

The following lines use progressively longer lengths:

-Ribbon 1: Base Length and Base Length × Multiplier
-Ribbon 2: Base Length × 2 and Adjusted Length × 2
-Ribbon 3: Base Length × 3 and Adjusted Length × 3
-Ribbon 4: Base Length × 4 and Adjusted Length × 4
-Ribbon 5: Base Length × 5 and Adjusted Length × 5
-Ribbon 6: Base Length × 6 and Adjusted Length × 6

Because the lengths become progressively larger, the ribbon contains calculations that can respond to both relatively recent price movement and more slowly developing directional movement.

[*] [b]Measuring the Direction of Every TEWMA[/b]

The trend direction of each ribbon line is determined by comparing its current value with its value one bar earlier.

A line is considered bullish when:

[i]Current TEWMA > Previous TEWMA[/i]

A line is considered bearish when:

[i]Current TEWMA < Previous TEWMA[/i]

This means the script is not using the position of price above or below the TEWMA to determine the trend direction.

Instead, it specifically evaluates the [b]slope of the TEWMA itself[/b].

If the TEWMA is rising, the corresponding signal is bullish.

If the TEWMA is falling, the corresponding signal is bearish.

[*] [b]Assigning a Persistent Directional State[/b]

Each of the six ribbon lines receives its own persistent signal variable.

When a TEWMA is rising, its signal is assigned a value of 1.

When a TEWMA is falling, its signal is assigned a value of -1.

These values are stored using Pine Script's [i]var[/i] functionality.

The persistent signal state is used to control both the visual color of the ribbon and the overall directional score.

[*] [b]Coloring the Ribbon According to Direction[/b]

Every ribbon line changes color depending on whether its corresponding TEWMA is currently rising or falling.

A rising TEWMA is assigned the bullish blue color.

A falling TEWMA is assigned the bearish purple color.

The transparency differs between the ribbon levels.

The outer portions of the ribbon are displayed with greater transparency, while the central lines are displayed with less or no transparency.

This creates a visual ribbon structure in which the middle calculations are more prominent and the surrounding calculations create a layered trend display.

[*] [b]Creating the Ribbon Fill[/b]

Each TEWMA line is also paired with a hidden secondary plot.

The hidden plot is calculated as:

[i]TEWMA × 0.9[/i]

The area between the TEWMA and this lower hidden plot is then filled using the color assigned to that particular TEWMA.

The lower fill is fully transparent, which causes the visual emphasis to remain closer to the main TEWMA line.

This calculation is repeated individually for all six ribbon levels.

[*] [b]Calculating the Overall Trend Score[/b]

After all six directional states have been determined, the indicator calculates an overall score.

Every bullish ribbon signal contributes:

[i]+1[/i]

Every bearish ribbon signal contributes:

[i]-1[/i]

Since there are six TEWMA lines, the total score can range from:

[i]+6[/i]

when all six lines are bullish, to:

[i]-6[/i]

when all six lines are bearish.

This creates a simple directional consensus measurement across the complete TEWMA ribbon.

[*] [b]Defining the Overall Bullish State[/b]

The overall signal is set to bullish when the score is greater than 3.

Because each bullish line contributes +1 and each bearish line contributes -1, a score above 3 requires a strong bullish majority.

The possible bullish scores that satisfy this condition are:

+4, +5, and +6.

This means that at least five of the six ribbon calculations must be bullish before the script assigns the overall bullish state.

[*] [b]Defining the Overall Bearish State[/b]

The overall signal is set to bearish when the score is less than -5.

The only possible score satisfying this condition is -6.

Therefore, all six TEWMA lines must be bearish before the script assigns the overall bearish state.

This creates an asymmetric signal structure.

The bullish state requires a strong bullish majority, while the bearish state requires complete bearish agreement across all six ribbon calculations.

[*] [b]Generating BUY Labels[/b]

A BUY label is plotted when the overall signal becomes bullish while the previous overall signal was bearish.

The exact transition condition is:

[i]Current Signal > 0 AND Previous Signal < 0[/i]

This means a BUY label is not continuously plotted while the bullish state remains active.

It is only plotted at the moment the stored overall signal transitions directly from bearish to bullish.

[*] [b]Generating SELL Labels[/b]

A SELL label is plotted when the overall signal becomes bearish while the previous overall signal was bullish.

The exact transition condition is:

[i]Current Signal < 0 AND Previous Signal > 0[/i]

Like the BUY condition, this prevents continuous label generation while the bearish state remains active.

The SELL label is only created when the overall directional state transitions directly from bullish to bearish.

[/list]

[b]Buy and Sell Conditions:[/b]

The indicator uses the directional slope of six individual TEWMA calculations to determine its overall trend state.

[b]Bullish Direction[/b]

Each TEWMA line is considered bullish when its current value is higher than its value on the previous bar.

Every bullish line contributes +1 to the overall score.

The script assigns a bullish overall signal when:

[i]Score > 3[/i]

Because the score can only move in whole-number increments, this means the score must be +4, +5, or +6.

In practical terms, at least five of the six TEWMA calculations must be rising before the bullish overall state is assigned.

A BUY label is only plotted when this bullish state is reached directly after the previous stored overall state was bearish.

[b]Bearish Direction[/b]

Each TEWMA line is considered bearish when its current value is lower than its value on the previous bar.

Every bearish line contributes -1 to the overall score.

The script assigns a bearish overall signal when:

[i]Score < -5[/i]

Since the minimum possible score is -6, all six TEWMA calculations must be falling simultaneously for the bearish overall state to be assigned.

A SELL label is only plotted when this bearish state is reached directly after the previous stored overall state was bullish.

[b]Signal Persistence[/b]

The overall signal uses a persistent variable.

The script explicitly changes the overall signal to bullish when the bullish threshold is met and changes it to bearish when the bearish threshold is met.

When the score falls between these thresholds, the script does not assign a new neutral value.

As a result, the previously assigned overall state remains stored until one of the opposite threshold conditions is met.

This means the indicator can continue displaying its previously established overall direction during periods where the six TEWMA calculations are mixed and neither threshold is currently satisfied.

[b]Features and Parameters:[/b]

* [b]Source[/b] - Selects the price source used for every WMA and TEWMA calculation. The default setting is Close.

* [b]Length[/b] - Defines the base calculation period used to construct the fastest TEWMA pair and acts as the foundation for all progressively longer ribbon calculations.

* [b]Multiplier[/b] - Multiplies every primary calculation length to create the second TEWMA in each pair. The default value is 1.4.

* [b]Six TEWMA Ribbon Levels[/b] - The indicator calculates six progressively slower trend lines using multiples of the base length from 1× through 6×.

* [b]Dual-Length Averaging[/b] - Every ribbon level averages two separate TEWMAs: one based on the primary length and one based on the multiplier-adjusted length.

* [b]WMA Pre-Smoothing[/b] - Every TEWMA begins by applying a Weighted Moving Average to the selected source.

* [b]TEMA Processing[/b] - The WMA output is subsequently processed using a Triple Exponential Moving Average.

* [b]Slope-Based Trend Detection[/b] - Trend direction is determined by whether each final TEWMA is rising or falling compared with the previous bar.

* [b]Individual Ribbon Direction[/b] - Each of the six TEWMA lines independently receives a bullish value of +1 or bearish value of -1.

* [b]Consensus Score[/b] - The directional values of all six TEWMA lines are added together to create a score ranging from -6 to +6.

* [b]Bullish Threshold[/b] - The overall bullish state is activated when the score is greater than +3.

* [b]Bearish Threshold[/b] - The overall bearish state is activated when the score is less than -5.

* [b]Persistent Overall Signal[/b] - The most recent bullish or bearish overall state remains active until the opposite threshold condition is explicitly met.

* [b]BUY Labels[/b] - A BUY label is plotted when the persistent overall signal transitions from bearish to bullish.

* [b]SELL Labels[/b] - A SELL label is plotted when the persistent overall signal transitions from bullish to bearish.

* [b]Dynamic Ribbon Colors[/b] - Every TEWMA line changes between bullish blue and bearish purple according to its individual directional state.

* [b]Layered Transparency[/b] - Different ribbon levels use different transparency values to create a layered visual structure.

* [b]Ribbon Fill[/b] - Each TEWMA line is paired with a hidden plot at 90% of its value, creating a filled area beneath the line.

[b]Specifications:[/b]

[b]Weighted Moving Average (WMA)[/b]

The Weighted Moving Average is the first smoothing calculation applied to the selected source.

Unlike a Simple Moving Average, where every value inside the lookback period receives equal weight, a WMA assigns progressively greater importance to more recent data.

This means recent price movement has a larger influence on the resulting average than older observations.

Within this indicator, the WMA acts as the first smoothing layer before the data is passed into the TEMA calculation.

Using a WMA before the TEMA means that the Triple Exponential Moving Average is not applied directly to raw price data. Instead, it processes an already smoothed representation of the selected source.

[b]Triple Exponential Moving Average (TEMA)[/b]

The Triple Exponential Moving Average is the second major smoothing component used by the indicator.

TEMA is designed as a Moving Average calculation that uses multiple Exponential Moving Average stages and combines them to reduce the lag commonly associated with traditional smoothing methods.

In this script, the TEMA is applied directly to the output of the Weighted Moving Average.

The resulting structure can therefore be represented as:

[i]Source → WMA → TEMA[/i]

This creates the TEWMA calculation used throughout the ribbon.

The benefit of combining these two stages is that the initial WMA gives more importance to recent price movement, while the subsequent TEMA provides the final trend-following calculation.

[b]TEWMA Structure[/b]

The core calculation of the indicator is:

[i]TEMA(WMA(Source, Length), Length)[/i]

The same calculation length is used for both the WMA and TEMA stages.

This process is repeated multiple times using different lengths.

Rather than using only one TEWMA, the indicator creates twelve individual TEWMA calculations in total: two for every one of the six ribbon levels.

Those pairs are subsequently averaged to produce the six displayed TEWMA lines.

[b]Base Length[/b]

The base length is the fundamental period from which the entire ribbon structure is built.

The first ribbon level uses the base length directly.

The remaining ribbon levels use multiples of the base length.

The progression is:

[i]Length[/i]

[i]Length × 2[/i]

[i]Length × 3[/i]

[i]Length × 4[/i]

[i]Length × 5[/i]

[i]Length × 6[/i]

Changing the base length therefore changes the responsiveness of the complete ribbon rather than only changing one individual Moving Average.

A shorter base length causes all six ribbon calculations to use shorter periods, while a longer base length increases the smoothing periods throughout the entire structure.

[b]Length Multiplier[/b]

The multiplier creates a second calculation length for every ribbon level.

For each primary length, the script calculates:

[i]Primary Length × Multiplier[/i]

The result is rounded to the nearest whole number.

This produces a second TEWMA calculation that operates at a proportionally adjusted smoothing speed.

The two TEWMA calculations are then averaged.

Because the multiplier is applied to every primary ribbon length, it affects the complete ribbon consistently.

For example, with a multiplier above 1, the second TEWMA in every pair uses a longer period than the first.

[b]Progressive Length Scaling[/b]

The six ribbon levels are constructed using progressively larger multiples of the base length.

This creates a spectrum of trend calculations ranging from relatively responsive to progressively slower.

The shorter TEWMA calculations can react earlier to changes in price direction.

The longer calculations require movement to influence a larger smoothing window and therefore represent a slower directional calculation.

Combining multiple calculation lengths allows the script to evaluate whether directional movement is limited to the faster part of the ribbon or whether it is also present across the slower calculations.

[b]Dual TEWMA Averaging[/b]

Each displayed ribbon line is created by averaging two separate TEWMAs.

The calculation is:

[i]Final Ribbon Line = (TEWMA Primary + TEWMA Adjusted) ÷ 2[/i]

The primary TEWMA uses the standard length for that ribbon level.

The adjusted TEWMA uses that length multiplied by the selected multiplier.

Averaging the two calculations creates a single line positioned between the two underlying TEWMA values.

This also means that each ribbon level is not dependent on only one specific calculation period.

Instead, it incorporates two proportionally related smoothing periods.

[b]The Six Ribbon Calculations[/b]

The script creates six final averaged TEWMA calculations.

The first is based on the base length and multiplier-adjusted base length.

The second is based on twice the base length and its multiplier-adjusted equivalent.

This pattern continues until the sixth calculation, which uses six times the base length and six times the multiplier-adjusted length.

As a result, the indicator evaluates directional movement across six progressively slower trend calculations.

[b]Slope-Based Trend Direction[/b]

The indicator determines the direction of each TEWMA by comparing the current value with the previous value.

The bullish condition is:

[i]Current Value > Previous Value[/i]

The bearish condition is:

[i]Current Value < Previous Value[/i]

This makes the directional logic slope-based.

The indicator does not require price to cross a TEWMA in order for that TEWMA to become bullish or bearish.

Instead, the TEWMA itself must change direction.

This approach focuses on whether the underlying smoothed calculation is rising or falling.

[b]Individual Signal Values[/b]

Every one of the six ribbon levels receives a directional value.

A rising line receives:

[i]+1[/i]

A falling line receives:

[i]-1[/i]

These values are stored individually and later combined into the overall score.

The use of individual directional values makes it possible to measure the degree of agreement across the entire ribbon.

[b]Multi-Line Consensus[/b]

The overall score is created by adding together the directional values of all six ribbon lines.

If all six are rising:

[i]+1 + +1 + +1 + +1 + +1 + +1 = +6[/i]

If all six are falling:

[i]-1 + -1 + -1 + -1 + -1 + -1 = -6[/i]

Mixed directional conditions produce values between these two extremes.

This creates a simple consensus measurement showing whether bullish or bearish directional movement dominates across the ribbon.

[b]Bullish Consensus Threshold[/b]

The bullish overall state requires:

[i]Score > 3[/i]

Since each line contributes either +1 or -1, the script requires at least five bullish lines.

A score of +4 represents five rising lines and one falling line.

A score of +6 represents complete bullish agreement.

This threshold allows one of the six calculations to remain bearish while the overall bullish state can still be activated.

[b]Bearish Consensus Threshold[/b]

The bearish overall state requires:

[i]Score < -5[/i]

The only possible score below -5 is -6.

Therefore, every TEWMA line must be falling.

This means the bearish threshold requires complete agreement across the full ribbon.

The bullish and bearish thresholds are intentionally not symmetrical in the code.

The script therefore applies different consensus requirements to establish bullish and bearish states.

[b]Persistent Signal Logic[/b]

The overall signal variable is declared using [i]var[/i].

This allows the value to persist from one bar to the next.

The signal changes to +1 when the bullish threshold is satisfied.

It changes to -1 when the bearish threshold is satisfied.

When neither threshold is satisfied, the script does not reset the signal to zero.

Instead, the previously assigned value remains active.

This means that mixed ribbon conditions do not automatically remove the existing bullish or bearish overall state.

A new opposite state must satisfy its own threshold before the stored signal changes.

[b]BUY Signal Transition[/b]

The BUY label requires two conditions simultaneously:

-The current persistent signal must be bullish.
-The previous persistent signal must have been bearish.

The label is therefore event-based.

It marks the transition rather than continuously marking every bar during an existing bullish state.

The BUY label is placed above the corresponding candle using the script's defined label settings.

[b]SELL Signal Transition[/b]

The SELL label also requires a transition.

The current persistent signal must be bearish while the previous persistent signal was bullish.

The label is therefore only created when the stored directional state switches directly from bullish to bearish.

The SELL label is placed below the corresponding candle according to the label settings used in the script.

[b]Bullish and Bearish Colors[/b]

The indicator defines a blue color for bullish conditions and a purple color for bearish conditions.

Each individual ribbon line uses its own directional state to determine which color is displayed.

This means it is possible for different parts of the ribbon to display different colors when the faster and slower TEWMA calculations are not aligned.

The ribbon therefore visually communicates both directional agreement and directional disagreement between the different calculation lengths.

[b]Transparency Structure[/b]

The ribbon does not apply identical transparency to every line.

The fastest and slowest outer lines use greater transparency.

The next inner lines use less transparency.

The central lines are displayed without additional transparency.

This creates a layered visual appearance in which the middle portion of the ribbon is emphasized more strongly.

The transparency does not affect the underlying calculations. It is purely a visual representation method.

[b]Ribbon Fill Calculation[/b]

Every displayed TEWMA line is accompanied by a hidden plot calculated at:

[i]TEWMA × 0.9[/i]

The script fills the area between the main TEWMA line and this lower hidden value.

The fill uses the directional color assigned to the TEWMA.

The lower side of the fill is fully transparent.

This creates a visual extension beneath each line while keeping the calculation itself hidden from the chart.

[b]Combining Fast and Slow Trend Calculations[/b]

One of the central characteristics of the indicator is the combination of multiple calculation speeds.

The shorter calculations respond more quickly because they use fewer historical bars.

The longer calculations change more gradually because they incorporate longer lookback periods.

When several calculations begin rising together, the score can move toward the bullish threshold.

When all six calculations are falling, the score reaches the bearish threshold.

This structure allows the indicator to compare directional movement across different smoothing horizons without using separate chart timeframes.

[b]Combining WMA and TEMA[/b]

The TEWMA structure combines two different smoothing stages.

The WMA emphasizes more recent observations during the initial smoothing process.

The TEMA then processes this smoothed series.

The result is used as the trend measurement for each calculation length.

Because this process is repeated across twelve separate TEWMA calculations, the final ribbon combines both multi-stage smoothing and progressive length scaling.

[b]Combining Dual-Length Calculations[/b]

Every ribbon level combines a primary TEWMA with a multiplier-adjusted TEWMA.

Instead of selecting only one length for each level, the script averages two related calculation periods.

The multiplier maintains a proportional relationship between the two lengths.

Changing the multiplier therefore changes the distance between the primary and adjusted calculations across all six ribbon levels simultaneously.

[b]Combining Individual Signals Into a Score[/b]

The six directional states are converted into numerical values and summed.

This converts the visual ribbon into a measurable consensus value.

A higher positive score represents greater bullish agreement.

A lower negative score represents greater bearish agreement.

The score is then used to control the persistent overall signal.

This creates a distinction between the individual direction of each TEWMA and the overall directional state used for the BUY and SELL labels.

[b]Asymmetric Signal Requirements[/b]

The script uses different thresholds for bullish and bearish states.

The bullish threshold can be reached with five or six rising TEWMAs.

The bearish threshold can only be reached when all six TEWMAs are falling.

This asymmetry is directly defined by the conditions:

[i]scores > 3[/i]

and:

[i]scores < -5[/i]

Users should be aware that these exact thresholds mean bullish and bearish state changes do not require the same degree of ribbon agreement.

[b]What the BUY and SELL Labels Represent[/b]

The BUY and SELL labels are generated from the overall persistent signal rather than from an individual Moving Average crossover.

A BUY label represents a transition from the script's stored bearish state to its stored bullish state.

A SELL label represents a transition from the stored bullish state to the stored bearish state.

The labels therefore depend on:

-The directional slope of all six averaged TEWMA lines.
-The numerical score created from those six directional states.
-The bullish and bearish thresholds defined in the script.
-The previous value of the persistent overall signal.

[b]Important Interpretation of the Signals[/b]

The indicator is designed to visualize directional changes and agreement across multiple smoothed calculations.

The BUY and SELL labels are generated according to the exact mathematical conditions defined in the script and should be interpreted within the context of the selected source, base length, multiplier, market, and timeframe.

Different parameter values will change the lengths used by every TEWMA calculation and can therefore change the responsiveness of the complete ribbon.

The indicator does not use future price data in its calculations. Each WMA, TEMA, directional comparison, score, and label condition is calculated from the available chart data at the corresponding bar.

As with any trend-following calculation, the behavior of the indicator can differ depending on market conditions. Strong directional movement and mixed or rapidly changing price movement can produce different levels of agreement between the faster and slower components of the ribbon.

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

   

indicator("Dual TEWMA Ribbon - [JTCAPITAL]", overlay = true)
import TradingView/ta/10

//-----Defining Parameters
src = input.source(close)
len = input.int(36)
multi = input.float(1.4, step = 0.05)
len22 = len * multi
len2 = math.round(len22)


//-----Calculating adjusted ribbons
len11 = len * 2
len31 = math.round(len11 * multi)
len12 = len * 3
len32 = math.round(len12 * multi)
len13 = len * 4
len33 = math.round(len13 * multi)
len14 = len * 5
len34 = math.round(len14 * multi)
len15 = len * 6
len35 = math.round(len15 * multi)


//-----Calculating the TEWMAs
TEWMA11 = ta.tema(ta.wma(src, len), len)
TEWMA21 = ta.tema(ta.wma(src, len2), len2)
TEWMA1 = (math.avg(TEWMA11, TEWMA21))

TEWMA111 = ta.tema(ta.wma(src, len11), len11)
TEWMA121 = ta.tema(ta.wma(src, len31), len31)
TEWMA101 = (math.avg(TEWMA111, TEWMA121))

TEWMA112 = ta.tema(ta.wma(src, len12), len12)
TEWMA122 = ta.tema(ta.wma(src, len32), len32)
TEWMA102 = (math.avg(TEWMA112, TEWMA122))

TEWMA113 = ta.tema(ta.wma(src, len13), len13)
TEWMA123 = ta.tema(ta.wma(src, len33), len33)
TEWMA103 = (math.avg(TEWMA113, TEWMA123))

TEWMA114 = ta.tema(ta.wma(src, len14), len14)
TEWMA124 = ta.tema(ta.wma(src, len34), len34)
TEWMA104 = (math.avg(TEWMA114, TEWMA124))

TEWMA115 = ta.tema(ta.wma(src, len15), len15)
TEWMA125 = ta.tema(ta.wma(src, len35), len35)
TEWMA105 = (math.avg(TEWMA115, TEWMA125))


//-----Defining trend conditions
Long1 = TEWMA1 > TEWMA1[1]
Short1 = TEWMA1 < TEWMA1[1]
Long2 = TEWMA101 > TEWMA101[1]
Short2 = TEWMA101 < TEWMA101[1]
Long3 = TEWMA102 > TEWMA102[1]
Short3 = TEWMA102 < TEWMA102[1]
Long4 = TEWMA103 > TEWMA103[1]
Short4 = TEWMA103 < TEWMA103[1]
Long5 = TEWMA104 > TEWMA104[1]
Short5 = TEWMA104 < TEWMA104[1]
Long6 = TEWMA105 > TEWMA105[1]
Short6 = TEWMA105 < TEWMA105[1]

//-----Applying a var to determine trend direction
var Signal1 = 0
if Long1
    Signal1 := 1
if Short1
    Signal1 := -1

var Signal2 = 0
if Long2
    Signal2 := 1
if Short2
    Signal2 := -1

var Signal3 = 0
if Long3
    Signal3 := 1
if Short3
    Signal3 := -1

var Signal4 = 0
if Long4
    Signal4 := 1
if Short4
    Signal4 := -1

var Signal5 = 0
if Long5
    Signal5 := 1
if Short5
    Signal5 := -1

var Signal6 = 0
if Long6
    Signal6 := 1
if Short6
    Signal6 := -1


//-----Assigning line color based on trend direction
BullColor = color.rgb(49, 133, 228)
Bearcolor = color.rgb(132, 3, 158)
lineColor1 = Signal1 > 0 ? color.rgb(49, 133, 228,60) : color.rgb(132, 3, 158,60)
lineColor2 = Signal2 > 0 ? color.rgb(49, 133, 228,30) : color.rgb(132, 3, 158,30)
lineColor3 = Signal3 > 0 ? color.rgb(49, 133, 228) : color.rgb(132, 3, 158)
lineColor4 = Signal4 > 0 ? color.rgb(49, 133, 228) : color.rgb(132, 3, 158)
lineColor5 = Signal5 > 0 ? color.rgb(49, 133, 228,30) : color.rgb(132, 3, 158,30)
lineColor6 = Signal6 > 0 ? color.rgb(49, 133, 228,60) : color.rgb(132, 3, 158,60)


//-----Plotting
plot1 = plot(TEWMA1, color=lineColor1, linewidth=3)
plot12 = plot(TEWMA1 * 0.9, color = lineColor1, display = display.none)
fill(plot1 = plot1,plot2 = plot12, top_value = TEWMA1, bottom_value = TEWMA1 * 0.9, top_color = lineColor1, bottom_color = color.new(color.black, 100))

plot21 = plot(TEWMA101, color=lineColor2, linewidth=3)
plot212 = plot(TEWMA101 * 0.9, color = lineColor2, display = display.none)
fill(plot1 = plot21,plot2 = plot212, top_value = TEWMA101, bottom_value = TEWMA101 * 0.9, top_color = lineColor2, bottom_color = color.new(color.black, 100))

plot31 = plot(TEWMA102, color=lineColor3, linewidth=3)
plot312 = plot(TEWMA102 * 0.9, color = lineColor3, display = display.none)
fill(plot1 = plot31,plot2 = plot312, top_value = TEWMA102, bottom_value = TEWMA102 * 0.9, top_color = lineColor3, bottom_color = color.new(color.black, 100))

plot41 = plot(TEWMA103, color=lineColor4, linewidth=3)
plot412 = plot(TEWMA103 * 0.9, color = lineColor4, display = display.none)
fill(plot1 = plot41,plot2 = plot412, top_value = TEWMA103, bottom_value = TEWMA103 * 0.9, top_color = lineColor4, bottom_color = color.new(color.black, 100))

plot51 = plot(TEWMA104, color=lineColor5, linewidth=3)
plot512 = plot(TEWMA104 * 0.9, color = lineColor5, display = display.none)
fill(plot1 = plot51,plot2 = plot512, top_value = TEWMA104, bottom_value = TEWMA104 * 0.9, top_color = lineColor5, bottom_color = color.new(color.black, 100))

plot61 = plot(TEWMA105, color=lineColor6, linewidth=3)
plot612 = plot(TEWMA105 * 0.9, color = lineColor6, display = display.none)
fill(plot1 = plot61,plot2 = plot612, top_value = TEWMA105, bottom_value = TEWMA105 * 0.9, top_color = lineColor6, bottom_color = color.new(color.black, 100))

//-----Defining overall score
scores = 0
if Signal1 > 0
    scores += 1
if Signal2 > 0
    scores += 1
if Signal3 > 0
    scores += 1
if Signal4 > 0
    scores += 1
if Signal5 > 0
    scores += 1
if Signal6 > 0
    scores += 1
if Signal1 < 0
    scores += -1
if Signal2 < 0
    scores += -1
if Signal3 < 0
    scores += -1
if Signal4 < 0
    scores += -1
if Signal5 < 0
    scores += -1
if Signal6 < 0
    scores += -1




//-----Calculating overall signal from overall score
var signal = 0

if scores > 3
    signal := 1

if scores < -5
    signal := -1



//-----Plotting labels
if signal > 0 and signal[1] < 0
    label.new(
     bar_index,
     high,
     "BUY",
     yloc=yloc.abovebar,
     style=label.style_label_down,
     color=BullColor,
     textcolor=color.white
     )

if signal < 0 and signal[1] > 0
    label.new(
     bar_index,
     low,
     "SELL",
     yloc=yloc.belowbar,
     style=label.style_label_up,
     color=Bearcolor,
     textcolor=color.white
     )
````
