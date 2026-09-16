<!-- tradingview-pine-id: PUB;e29092a9c80440a6af606c8f849b58d4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# TEWMA Momentum Cloud - [JTCAPITAL]

Source: https://www.tradingview.com/script/GyPVnzxI-TEWMA-Momentum-Cloud-JTCAPITAL/

## Description

TEWMA Momentum Cloud - [JTCAPITAL] is a modified way to use dual-length Triple Exponential Weighted Moving Averages (TEWMA), momentum, and the rate of change of the TEWMA spread for Trend-Following and trend-state analysis.

The indicator is designed to do more than simply determine whether price is above or below a moving average. It compares two differently scaled TEWMA calculations to determine the current directional bias, while simultaneously measuring whether the distance between the two TEWMAs is expanding or contracting.

This creates four primary trend states:

* Bullish + Accelerating — the faster TEWMA is above the slower TEWMA and the difference between them is increasing.
* Bullish + Decelerating — the faster TEWMA remains above the slower TEWMA, but the difference between them is decreasing.
* Bearish + Accelerating — the faster TEWMA is below the slower TEWMA and the difference between them is becoming more negative.
* Bearish + Decelerating — the faster TEWMA remains below the slower TEWMA, but the difference between them is becoming less negative.

A fifth state, Neutral / Flattening, is used when the directional relationship between the two TEWMAs remains bullish or bearish, but the averaged TEWMA is moving in the opposite direction. This helps identify situations where the prevailing directional structure is losing momentum.

The result is a visual trend cloud in which the color of the TEWMA lines changes according to both direction and momentum expansion or contraction.

The indicator works by calculating in the following steps:

[*] Selecting the Price Source

The script begins with a user-selected price source. By default, the source is the Close price.

This source is then used as the raw input for both TEWMA calculations. Because the two TEWMAs use the same source but different lengths, the difference between them primarily reflects the way the market is behaving across two different smoothing horizons.

[*] Determining the Second TEWMA Length

The user specifies the primary Length, which defaults to 50.

The second length is dynamically derived from this value using the Multiplier:

Second Length = Length x Multiplier

The result is rounded to the nearest whole number because moving-average lengths must be represented as integer values.

With the default settings:

50 x 2.50 = 125

Therefore, the two TEWMA calculations use lengths of 50 and 125.

This creates a faster and slower version of the same underlying smoothing methodology. The shorter TEWMA reacts more quickly to changes in price, while the longer TEWMA provides a slower representation of the broader price direction.

[*] Weighted Moving Average Calculation

Before the TEMA calculation is applied, the selected source is first processed through a Weighted Moving Average (WMA).

The WMA assigns greater importance to more recent observations within its calculation period and progressively less importance to older observations.

This makes the resulting moving average more responsive to recent price changes than a conventional SMA.

The script performs this process separately for both lengths:

WMA(source, Length)

and

WMA(source, Second Length)

The resulting WMA series are then passed into the TEMA calculations.

[*] Triple Exponential Moving Average Calculation

The WMA output is then processed through a Triple Exponential Moving Average (TEMA).

TEMA is designed to reduce the lag that can occur when repeatedly smoothing a data series.

Conceptually, TEMA uses three levels of exponential smoothing and combines them in a way that reduces a substantial portion of the lag introduced by traditional moving averages.

The general TEMA structure can be represented as:

TEMA = 3 x EMA1 - 3 x EMA2 + EMA3

where EMA1 is the first exponential smoothing, EMA2 is an EMA of EMA1, and EMA3 is an EMA of EMA2.

In this script, TEMA is applied to the WMA rather than directly to price.

This produces:

TEWMA1 = TEMA(WMA(source, Length), Length)

and

TEWMA2 = TEMA(WMA(source, Second Length), Second Length)

The combination of WMA followed by TEMA is what gives the indicator its TEWMA construction.

The purpose of combining these smoothing methods is to create a trend representation that remains substantially smoother than raw price while retaining responsiveness to directional changes.

[*] Creating the Average TEWMA

The two TEWMA calculations are then averaged:

TEWMA = (TEWMA1 + TEWMA2) / 2

This average represents the central line of the indicator.

Instead of relying exclusively on either the faster or slower TEWMA, the average provides a combined representation of both time horizons.

This can make the central trend representation less dependent on one specific smoothing length.

[*] Calculating TEWMA Momentum / Spread

The script then calculates the difference between the two TEWMA values:

Momentum = TEWMA1 - TEWMA2

This is one of the most important calculations in the indicator.

The value is positive when TEWMA1 is above TEWMA2 and negative when TEWMA1 is below TEWMA2.

However, the script does not only look at whether this value is positive or negative. It also compares the current value with its previous value.

Therefore, the indicator is effectively examining the direction and rate of change of the spread between the two TEWMAs.

[*] Detecting Bullish Acceleration

Bullish acceleration occurs when:

TEWMA1 > TEWMA2

and

Momentum > Momentum[1]

The first condition establishes that the faster TEWMA is above the slower TEWMA.

The second condition establishes that the difference between the two TEWMAs is increasing.

Therefore, bullish acceleration means that the bullish separation between the two trend filters is expanding.

This is represented by Signal = 2.

[*] Detecting Bullish Deceleration

Bullish deceleration occurs when:

TEWMA1 > TEWMA2

and

Momentum < Momentum[1]

The faster TEWMA is still above the slower TEWMA, so the overall directional relationship remains bullish.

However, the spread between the two TEWMAs is shrinking.

This means the bullish structure is becoming less expansive, even though the bullish relationship between the two trend measurements has not necessarily disappeared.

This is represented by Signal = 1.

[*] Detecting Bearish Acceleration

Bearish acceleration occurs when:

TEWMA1 < TEWMA2

and

Momentum < Momentum[1]

The faster TEWMA is below the slower TEWMA, establishing a bearish relationship.

At the same time, the momentum difference is becoming increasingly negative.

Therefore, the separation between the two TEWMAs is expanding in the bearish direction.

This is represented by Signal = -2.

[*] Detecting Bearish Deceleration

Bearish deceleration occurs when:

TEWMA1 < TEWMA2

and

Momentum > Momentum[1]

The faster TEWMA remains below the slower TEWMA, so the broader directional relationship remains bearish.

However, the difference between the two TEWMAs is becoming less negative.

This means the bearish separation is contracting.

This is represented by Signal = -1.

[*] Detecting Neutral / Flattening Conditions

The neutral condition is different from simply checking whether the two TEWMAs have crossed.

The script checks whether the directional relationship between TEWMA1 and TEWMA2 conflicts with the movement of their average.

A neutral state occurs when either:

TEWMA1 > TEWMA2 while TEWMA is falling

or

TEWMA1 < TEWMA2 while TEWMA is rising.

In other words, the two TEWMAs may still maintain a bullish or bearish relationship, but the combined TEWMA is beginning to move in the opposite direction.

This provides an additional way of identifying a loss of directional momentum before relying solely on a crossover.

The neutral state is represented by Signal = 0.

[*] Assigning the Persistent Trend State

The script stores the current signal state in a persistent variable.

The possible states are:

2 = Bullish + Accelerating

1 = Bullish + Decelerating

-1 = Bearish + Decelerating

-2 = Bearish + Accelerating

0 = Neutral / Flattening

Because the signal variable is persistent, it retains its previous value when none of the explicitly defined conditions changes the state.

This means the indicator is not simply recalculating an independent label on every bar; it maintains the latest identified trend state until another condition updates it.

[*] Assigning the Visual Trend Color

The signal state determines the color used by the plotted TEWMA lines.

Bullish acceleration receives one color, bullish deceleration another, bearish acceleration another, bearish deceleration another, and neutral conditions receive a separate neutral color.

The visual distinction therefore communicates two dimensions simultaneously:

1. Direction — bullish or bearish

2. Momentum behavior — accelerating or decelerating

This allows the user to distinguish between a bullish trend that is strengthening and a bullish trend that is losing expansion, rather than treating both situations as identical.

[*] Plotting the Central TEWMA

The averaged TEWMA is plotted as the primary, thicker line.

This line represents the combined trend estimate derived from the faster and slower TEWMA calculations.

Its color changes according to the current signal state.

[*] Creating the Visual Cloud

The script creates an additional hidden plot at:

TEWMA x 0.9

and fills the area between the primary TEWMA and this lower reference level.

The same visual technique is also applied to TEWMA1 and TEWMA2.

These fills create the visual cloud/ribbon appearance of the indicator.

It is important to understand that these filled regions are primarily visual enhancements. They are not additional volatility bands, standard-deviation bands, ATR bands, or independent support/resistance calculations.

The 0.9 multiplier simply places the second boundary at 90% of the corresponding TEWMA value, creating a proportional visual area beneath the plotted line.

[*] Plotting the Fast and Slow TEWMA

In addition to the averaged TEWMA, the script plots TEWMA1 and TEWMA2 individually.

TEWMA1 uses the shorter user-defined length and therefore represents the faster component.

TEWMA2 uses the multiplied length and therefore represents the slower component.

Viewing both lines allows the user to see the underlying relationship that produces the momentum classification.

[*] Optional State-Change Labels

The script contains an optional Show Labels setting.

When enabled, labels are displayed when the signal changes from its previous state.

The available label descriptions are:

Rising + Widening

Rising + Compressing

Falling + Widening

Falling + Compressing

Flattening

The labels are only created when the current signal is different from the previous signal. This prevents a new label from being printed on every bar while the same state remains active.

The labels therefore focus attention on state transitions rather than continuously repeating the same information.

Buy and Sell Conditions:

This indicator does not contain conventional buy or sell conditions, strategy orders, entries, exits, or backtesting logic.

Instead, it identifies trend states.

The bullish states are:

* Bullish + Accelerating — TEWMA1 is above TEWMA2 and the TEWMA spread is increasing.
* Bullish + Decelerating — TEWMA1 is above TEWMA2 and the TEWMA spread is decreasing.

The bearish states are:

* Bearish + Accelerating — TEWMA1 is below TEWMA2 and the TEWMA spread is becoming more negative.
* Bearish + Decelerating — TEWMA1 is below TEWMA2 and the TEWMA spread is becoming less negative.

The neutral state occurs when the averaged TEWMA moves against the current directional relationship between TEWMA1 and TEWMA2.

This distinction is important because a decelerating trend is not automatically a reversal. For example, a bullish trend can begin compressing while remaining bullish. Likewise, a bearish trend can begin compressing while remaining bearish.

Users can therefore interpret the states according to their own trading methodology. For example, an external trading approach could use bullish acceleration as a trend-confirmation condition, while treating bullish deceleration as a warning that momentum is becoming less expansive. However, the indicator itself does not impose entries, exits, stop-losses, take-profits, or position sizing.

The same principle applies to bearish conditions.

The indicator is therefore best understood as a trend and momentum-state visualization tool, rather than a complete trading strategy.

Features and Parameters:

[*] Source — Selects the price series used as the foundation of both TEWMA calculations. The default is Close.

[*] Length — Defines the primary length used by the faster TEWMA. The default value is 50.

[*] Multiplier — Determines the relationship between the faster and slower TEWMA lengths. The default is 2.50.

[*] Second TEWMA Length — Calculated automatically as Length multiplied by Multiplier and rounded to the nearest integer.

[*] Show Labels — Enables or disables the optional state-transition labels displayed on the chart.

[*] Dual TEWMA Structure — Uses two differently scaled TEWMA calculations to compare shorter-term and longer-term trend behavior.

[*] Momentum Spread — Measures the difference between the fast and slow TEWMA.

[*] Acceleration / Deceleration Detection — Determines whether the TEWMA spread is expanding or contracting.

[*] Five-State Classification — Separates the market into bullish acceleration, bullish deceleration, bearish acceleration, bearish deceleration, and neutral/flattening conditions.

[*] Dynamic Color Coding — Changes the plotted line colors according to the current trend state.

[*] Visual Cloud — Adds proportional filled regions around the plotted TEWMA lines to improve visual trend identification.

Specifications:

Price Source

The price source is the raw market data supplied to the indicator.

The default source is Close, meaning each calculation begins with the closing price of every bar.

The script allows TradingView's standard source selector to be used, so the calculation can be based on another available price series if desired.

The selected source is important because every subsequent calculation is derived from it.

Weighted Moving Average (WMA)

A Weighted Moving Average is a moving average that assigns different weights to observations within its calculation window.

More recent observations receive greater weight than older observations.

Compared with an SMA, this allows the WMA to react more strongly to recent price changes.

In this indicator, the WMA is not the final trend line. It is the first smoothing stage before the TEMA calculation.

This creates a two-stage smoothing structure in which the price data is first weighted toward recent observations and then processed through the TEMA.

Triple Exponential Moving Average (TEMA)

TEMA is a moving-average construction that uses three levels of exponential smoothing.

The purpose is to reduce lag compared with simply applying multiple layers of conventional exponential smoothing.

Its conceptual formula is:

TEMA = 3 x EMA1 - 3 x EMA2 + EMA3

where:

EMA1 = EMA(source)

EMA2 = EMA(EMA1)

EMA3 = EMA(EMA2)

The resulting TEMA attempts to retain smoothness while responding more quickly to changes than a heavily smoothed conventional moving average.

TEWMA

The TEWMA used by this indicator can be understood as a WMA-preprocessed TEMA.

Instead of applying TEMA directly to price, the script first calculates a WMA and then applies TEMA to that WMA.

This combines the weighting characteristics of WMA with the lag-reduction characteristics of TEMA.

The script creates two versions of this construction with different lengths.

Fast TEWMA — TEWMA1

TEWMA1 is calculated using the primary user-defined length.

With the default settings:

TEWMA1 = TEMA(WMA(Close, 50), 50)

Because the length is shorter, this component reacts more quickly to changes in the source than TEWMA2.

It therefore serves as the faster component of the trend comparison.

Slow TEWMA — TEWMA2

TEWMA2 uses the automatically calculated second length.

With the default settings:

50 x 2.50 = 125

Therefore:

TEWMA2 = TEMA(WMA(Close, 125), 125)

The larger length causes this component to respond more slowly to changes in the source.

It therefore represents the slower trend component.

Length Multiplier

The multiplier controls how far apart the two TEWMA horizons are.

The formula is:

Second Length = round(Length x Multiplier)

A larger multiplier creates a greater difference between the fast and slow calculations.

A smaller multiplier brings the two calculations closer together.

This parameter therefore directly influences how sensitive the spread is to changes in market direction.

TEWMA Average

The central TEWMA is calculated as:

TEWMA = (TEWMA1 + TEWMA2) / 2

This creates a central representation of the two trend horizons.

Rather than selecting either the fast or slow calculation as the primary line, the indicator combines both into one average.

This can provide a more balanced representation of the underlying trend structure.

TEWMA Spread / Momentum

The indicator defines momentum as:

Momentum = TEWMA1 - TEWMA2

This is effectively the spread between the fast and slow trend measurements.

When the value is positive, the fast TEWMA is above the slow TEWMA.

When the value is negative, the fast TEWMA is below the slow TEWMA.

The absolute size of the spread also provides information about how far apart the two trend estimates have moved.

Most importantly, the script compares the current spread with the previous spread to determine whether that separation is expanding or contracting.

Widening Momentum

When the TEWMA spread increases in the direction of the prevailing trend, the two TEWMAs are moving farther apart.

During a bullish state, this means TEWMA1 is moving further above TEWMA2.

During a bearish state, this means TEWMA1 is moving further below TEWMA2.

The indicator refers to these conditions as acceleration because the directional separation between the two trend measurements is increasing.

Compressing Momentum

Compression occurs when the spread between the two TEWMAs becomes smaller.

During a bullish state, TEWMA1 can remain above TEWMA2 while moving closer to it.

During a bearish state, TEWMA1 can remain below TEWMA2 while moving closer to it.

This is why deceleration does not necessarily mean that the trend has already reversed.

It means that the separation supporting the current directional structure is becoming less pronounced.

Bullish Acceleration

Bullish acceleration requires:

TEWMA1 > TEWMA2

and:

TEWMA1 - TEWMA2 > previous(TEWMA1 - TEWMA2)

This combines directional positioning with expanding momentum.

The first condition identifies the direction.

The second condition identifies whether that directional separation is strengthening.

Bullish Deceleration

Bullish deceleration requires:

TEWMA1 > TEWMA2

and:

TEWMA1 - TEWMA2 < previous(TEWMA1 - TEWMA2)

The fast TEWMA is still above the slow TEWMA, but the spread is shrinking.

This identifies a bullish structure that is losing expansion.

Bearish Acceleration

Bearish acceleration requires:

TEWMA1 < TEWMA2

and:

TEWMA1 - TEWMA2 < previous(TEWMA1 - TEWMA2)

The spread is becoming increasingly negative.

This means the fast TEWMA is moving farther below the slow TEWMA, strengthening the bearish separation.

Bearish Deceleration

Bearish deceleration requires:

TEWMA1 < TEWMA2

and:

TEWMA1 - TEWMA2 > previous(TEWMA1 - TEWMA2)

The spread remains negative but is becoming less negative.

This means the bearish separation is contracting.

Neutral / Flattening

The neutral condition is designed to detect situations where the average TEWMA is moving against the existing fast/slow directional relationship.

For a bullish relationship, neutral occurs when:

TEWMA1 > TEWMA2

but:

TEWMA < TEWMA[1]

For a bearish relationship, neutral occurs when:

TEWMA1 < TEWMA2

but:

TEWMA > TEWMA[1]

This is useful because a market can remain structurally bullish or bearish according to the relationship between the two TEWMAs while the combined trend measure begins moving in the opposite direction.

The neutral state therefore represents a loss of alignment between directional structure and movement of the combined trend.

Signal States

The script converts the detected conditions into numerical states:

2 = Bullish Acceleration

1 = Bullish Deceleration

0 = Neutral / Flattening

-1 = Bearish Deceleration

-2 = Bearish Acceleration

These numerical values are used internally to determine the visual state of the indicator.

Persistent Signal Variable

The signal is stored in a persistent variable.

This means the current state can remain active across multiple bars until another condition changes it.

The script therefore does not require every bar to generate a completely new classification.

This is particularly useful for the visual presentation because a trend state can remain visible until a meaningful change in the underlying conditions occurs.

Color Coding

The indicator uses different colors for the five states.

The colors are not additional calculations and do not affect the mathematical output.

They are a visual encoding system designed to allow the user to recognize both directional bias and momentum behavior without having to inspect the numerical relationships manually.

Primary TEWMA Line

The averaged TEWMA is displayed as the main, thicker line.

Because it combines the fast and slow TEWMA, it acts as the central visual representation of the indicator's trend structure.

Fast and Slow TEWMA Lines

TEWMA1 and TEWMA2 are also plotted individually.

The difference between these two lines is fundamental to the indicator's state classification.

When they separate, the spread changes.

When they move closer together, the spread contracts.

Their relative position determines whether the market is classified as bullish or bearish, while the change in their separation determines whether that trend is accelerating or decelerating.

Cloud / Fill Calculation

The script creates hidden secondary plots using:

TEWMA x 0.9

TEWMA1 x 0.9

TEWMA2 x 0.9

The area between each original line and its corresponding 90% reference is then filled.

This creates the cloud-like visual appearance.

These fills should not be interpreted as statistical probability bands or volatility envelopes.

They are proportional visual regions derived directly from the corresponding TEWMA value.

Optional Labels

The label system is disabled by default.

When enabled, the script checks whether the current signal state differs from the previous signal state.

A label is then created only at the transition into the new state.

This makes the labels useful for visually identifying when the market changes from one momentum regime to another without placing repetitive labels on every bar.

No ATR or Standard Deviation Component

This indicator does not use ATR, standard deviation, Bollinger Bands, RSI, MACD, volume, or other conventional volatility/momentum indicators.

Its momentum classification comes specifically from the difference between two differently smoothed TEWMA calculations and the change in that difference over time.

This is an important part of the design because the indicator is intentionally focused on the relationship between two trend estimates rather than combining unrelated technical indicators.

Why Combine WMA and TEMA?

WMA and TEMA perform different roles within the calculation.

WMA gives greater emphasis to recent observations.

TEMA then applies a triple-exponential smoothing structure designed to reduce lag compared with repeated conventional smoothing.

Combining them creates a trend filter that attempts to balance smoothness and responsiveness.

The objective is not simply to make the moving average smoother. Excessive smoothing can make a trend indicator slow to react.

Instead, the construction uses multiple forms of smoothing while maintaining a relatively responsive relationship with recent price behavior.

Why Use Two TEWMAs Instead of One?

A single moving average can provide information about direction, but it does not directly provide the same contextual information about how the market behaves across different trend horizons.

Using two TEWMAs creates a relative comparison.

The shorter TEWMA reacts faster.

The longer TEWMA reacts more slowly.

When the faster calculation moves above the slower calculation, the short-term trend representation has moved ahead of the longer-term representation.

When it moves below it, the opposite relationship exists.

This relative structure is the foundation of the indicator's directional classification.

Why Measure the Spread Between Them?

Simply knowing that one moving average is above another can be insufficient.

A bullish relationship can exist while the two averages are rapidly separating, or while they are slowly moving back toward each other.

Those are materially different conditions.

The spread calculation captures this distinction.

An expanding spread indicates increasing separation between the two trend horizons.

A contracting spread indicates decreasing separation.

The indicator therefore adds a second layer of information to the basic fast-versus-slow relationship.

Why Separate Acceleration From Deceleration?

A trend does not necessarily change direction immediately when its momentum begins to weaken.

For example, TEWMA1 can remain above TEWMA2 while the spread starts contracting.

The market can therefore remain structurally bullish while the bullish separation is losing strength.

Likewise, a bearish trend can remain structurally bearish while the bearish separation begins to contract.

Separating acceleration and deceleration allows the indicator to communicate this transition instead of treating every bullish or bearish condition equally.

Why Include a Neutral / Flattening State?

The neutral state provides another layer of information beyond the fast/slow relationship.

If TEWMA1 remains above TEWMA2 but the averaged TEWMA begins declining, the underlying directional relationship and the movement of the combined trend measure are no longer aligned.

The same principle applies in reverse during bearish conditions.

This gives the indicator a mechanism for visually highlighting situations in which the prevailing trend structure may be losing alignment.

How the Components Work Together

The indicator can therefore be viewed as a sequence of three major analytical layers:

Layer 1 — Trend Smoothing

The source is processed through WMA and TEMA to create two TEWMA trend estimates.

Layer 2 — Multi-Horizon Comparison

The faster TEWMA is compared with the slower TEWMA to establish the directional relationship.

Layer 3 — Momentum Expansion / Contraction

The difference between the two TEWMAs is monitored over time to determine whether the directional separation is widening or compressing.

The additional neutral logic then evaluates whether the average TEWMA is moving against the established fast/slow relationship.

This creates a compact framework that attempts to answer two related questions:

What is the current directional relationship?

and

Is that relationship becoming more expansive or less expansive?

How to Interpret the Indicator

Bullish + Accelerating

The faster TEWMA is above the slower TEWMA and the spread is expanding.

This is the strongest bullish state within the indicator's classification system because both directional positioning and spread expansion point in the same direction.

Bullish + Decelerating

The faster TEWMA remains above the slower TEWMA, but the spread is contracting.

The bullish structure remains present, but the separation between the two trend horizons is decreasing.

Bearish + Accelerating

The faster TEWMA is below the slower TEWMA and the spread is expanding negatively.

Both directional positioning and spread behavior are aligned with the bearish side.

Bearish + Decelerating

The faster TEWMA remains below the slower TEWMA, but the bearish spread is contracting.

The bearish structure remains present, but the separation is becoming less pronounced.

Neutral / Flattening

The fast/slow relationship remains directional, but the averaged TEWMA is moving against that relationship.

This represents a loss of alignment and can be interpreted as a transition or weakening state rather than an automatic reversal.

Limitations and Important Considerations:

This indicator is a technical-analysis tool and does not predict future price movements.

It does not contain a strategy engine, position sizing, stop-loss calculation, take-profit calculation, risk management system, or backtesting logic.

The bullish and bearish states should therefore not automatically be interpreted as guaranteed entry or exit signals.

Moving averages are inherently derived from historical price data. Even though the WMA/TEMA construction is designed to remain responsive, the indicator can still react after a price movement has already begun.

The Length and Multiplier settings materially affect the behavior of the indicator. Shorter lengths generally make the calculations more responsive, while longer lengths generally make them slower and smoother.

The indicator does not use a volatility normalization mechanism. The TEWMA spread is measured directly in the price units of the underlying instrument.

The cloud fills are visual representations and should not be interpreted as probability bands, volatility bands, or statistically calculated support/resistance areas.

The neutral state does not guarantee that a reversal will occur. It identifies a specific loss of alignment between the directional TEWMA relationship and the movement of the averaged TEWMA.

Likewise, deceleration does not automatically mean that a trend is ending. It only indicates that the spread between the two TEWMAs is contracting according to the script's calculation.

Users should therefore interpret the indicator within the context of their broader market analysis and risk-management process.

Originality and Design Purpose

The distinctive element of this indicator is not simply the use of moving averages.

The script combines a WMA-preprocessed TEMA structure with two different time horizons and then uses the spread between those two TEWMAs as a momentum-state measurement.

Instead of producing only a binary bullish/bearish classification, the indicator separates directional conditions into acceleration and deceleration states.

This provides a more detailed visualization of the relationship between short-term and longer-term trend behavior.

The purpose of the design is therefore to make the changing relationship between two trend horizons easier to interpret visually, while keeping the underlying calculations focused specifically on TEWMA structure and its momentum spread.

Summary

TEWMA Momentum Cloud combines two differently scaled TEWMAs to create a multi-horizon view of trend direction.

The source is first processed through a Weighted Moving Average and then through a Triple Exponential Moving Average.

The resulting fast and slow TEWMAs are averaged to create the central TEWMA.

The difference between the fast and slow TEWMAs is then calculated as the momentum spread.

The sign of that spread determines the bullish or bearish relationship, while the change in the spread determines whether that relationship is accelerating or decelerating.

An additional neutral condition identifies situations where the averaged TEWMA moves against the prevailing fast/slow relationship.

The result is a five-state trend classification:

Bullish + Accelerating

Bullish + Decelerating

Neutral / Flattening

Bearish + Decelerating

Bearish + Accelerating

The visual cloud, line colors, and optional transition labels are then used to make these states easier to identify directly on the chart.

TEWMA Momentum Cloud is therefore designed as a trend-structure and momentum-state visualization tool, helping users distinguish not only between bullish and bearish conditions, but also between trends that are expanding and trends that are beginning to compress.

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

   

indicator("TEWMA Momentum Cloud - [JTCAPITAL]", overlay = true)
import TradingView/ta/10

//-----Defining Parameters
src = input.source(close)
len = input.int(50)
multi = input.float(2.50, step = 0.05)
len22 = len * multi
len2 = math.round(len22)
Showlabels = input.bool(false)

//-----Calculating the TEWMA
TEWMA1 = ta.tema(ta.wma(src, len), len)
TEWMA2 = ta.tema(ta.wma(src, len2), len2)
TEWMA = math.avg(TEWMA1, TEWMA2)
mom = TEWMA1 - TEWMA2

//-----Defining trend conditions
BullAccel = TEWMA1 > TEWMA2 and mom > mom[1]
BullDecel = TEWMA1 > TEWMA2 and mom < mom[1]
BearAccel = TEWMA1 < TEWMA2 and mom < mom[1]
BearDecel = TEWMA1 < TEWMA2 and mom > mom[1]

neutral = (TEWMA1 > TEWMA2 and TEWMA < TEWMA[1]) or (TEWMA1 < TEWMA2 and TEWMA > TEWMA[1])


//-----Applying a var to determine trend direction
var Signal = 0

if BullAccel
    Signal := 2

if BullDecel
    Signal := 1

if BearAccel
    Signal := -2

if BearDecel
    Signal := -1

if neutral
    Signal := 0


//-----Assigning line color based on trend direction
BullColorAccel = color.rgb(49, 132, 228)
BullColorDecel = color.rgb(70, 100, 215)
neutralcolor   = color.rgb(90, 68, 193)
BearcolorAccel = color.rgb(132, 3, 158)
BearcolorDecel = color.rgb(110, 30, 175)

lineColor = Signal == 2 ? BullColorAccel : Signal == -2 ? BearcolorAccel : Signal == 1 ? BullColorDecel : Signal == -1 ? BearcolorDecel : neutralcolor


//-----Plotting
plot1 = plot(TEWMA, color=lineColor, linewidth=3)
plot12 = plot(TEWMA * 0.9, color = lineColor, display = display.none)
fill(plot1 = plot1,plot2 = plot12, top_value = TEWMA, bottom_value = TEWMA * 0.9, top_color = lineColor, bottom_color = color.new(color.black, 100))

plot2 = plot(TEWMA1, color=lineColor, linewidth=1)
plot22 = plot(TEWMA1 * 0.9, color = lineColor, display = display.none)
fill(plot1 = plot2,plot2 = plot22, top_value = TEWMA1, bottom_value = TEWMA1 * 0.9, top_color = lineColor, bottom_color = color.new(color.black, 100))

plot3 = plot(TEWMA2, color=lineColor, linewidth=1)
plot32 = plot(TEWMA2 * 0.9, color = lineColor, display = display.none)
fill(plot1 = plot3,plot2 = plot32, top_value = TEWMA2, bottom_value = TEWMA2 * 0.9, top_color = lineColor, bottom_color = color.new(color.black, 100))


//-----Making optional labels
if Showlabels

    if Signal == 2 and Signal[1] != 2
        label.new(
        bar_index,
        TEWMA2,
        "Rising + Widening",
        style=label.style_label_up,
        color=BullColorAccel,
        textcolor=color.white
        )

    if Signal == 1 and Signal[1] != 1
        label.new(
        bar_index,
        TEWMA2,
        "Rising + Compressing",
        style=label.style_label_up,
        color=BullColorDecel,
        textcolor=color.white
        )

    if Signal == -2 and Signal[1] != -2
        label.new(
        bar_index,
        TEWMA1,
        "Falling + Widening",
        style=label.style_label_down,
        color=BearcolorAccel,
        textcolor=color.white
        )

    if Signal == -1 and Signal[1] != -1
        label.new(
        bar_index,
        TEWMA1,
        "Falling + Compressing",
        style=label.style_label_down,
        color=BearcolorAccel,
        textcolor=color.white
        )

    if Signal == 0 and Signal[1] != 0
        label.new(
        bar_index,
        TEWMA,
        "Flattening",
        style=label.style_label_up,
        color=neutralcolor,
        textcolor=color.white
        )
````
