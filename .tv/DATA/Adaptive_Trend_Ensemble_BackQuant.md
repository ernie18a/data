<!-- tradingview-pine-id: PUB;86b24f8848d74a3992f97eb14b867102 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Trend Ensemble [BackQuant]

Source: https://www.tradingview.com/script/hnrtyc7O-Adaptive-Trend-Ensemble-BackQuant/

## Description

Adaptive Trend Ensemble [BackQuant]

Overview
Adaptive Trend Ensemble is an online-learning trend filter that combines eight different moving-average methods into one continuously weighted trend estimate.

Instead of selecting one moving average permanently, the indicator treats each method as an independent forecasting expert. Every bar, each expert is evaluated according to whether its previous slope correctly anticipated the direction of the latest price move.

Experts that were directionally correct retain more influence. Experts that were wrong lose influence through a multiplicative penalty. The weights are then normalised and used to blend all eight moving-average values into one adaptive ensemble line.

The indicator therefore attempts to answer two separate questions:

[*]Which smoothing method has recently aligned best with price direction?*
[*]How strongly do the weighted methods currently agree on the direction of trend?

The final output includes:

[*]A dynamically weighted ensemble trend line.
[*]Bullish and bearish trend-state colouring.
[*]A gradient between price and the ensemble.
[*]A consensus-driven glow.
[*]Trend-coloured candles.
[*]A live label showing the leading expert and its current weight.
[*]Alerts when the ensemble trend changes direction.

This is not a fixed moving average and it is not a simple average of several indicators. The contribution of each expert changes over time according to its recent directional performance.

Core idea
Moving averages respond differently to the same market.

A Hull Moving Average may respond quickly during a sharp transition, while an RMA may remain stable through temporary noise. A linear-regression estimate may follow a smooth directional move well, while a conventional EMA may perform better during a more ordinary trend.

No individual smoothing method is consistently superior across every environment.

Markets alternate between:

[*]Persistent trends.
[*]Fast breakouts.
[*]Slow directional drift.
[*]Volatile reversals.
[*]Compressed ranges.
[*]Noisy transitions.

A fixed indicator cannot change its mathematical personality when the environment changes. It continues using the same weighting structure regardless of whether that structure currently suits the market.

Adaptive Trend Ensemble addresses this by maintaining a bank of different smoothing methods and changing their influence through time.

The model does not attempt to decide in advance which method is best. It allows recent realised price action to determine which experts should currently receive more weight.

Prediction with expert advice
The indicator is based on a class of online-learning methods commonly described as:

Prediction with Expert Advice

In this framework:

[*]Several experts produce predictions.
[*]The actual outcome is observed.
[*]Each expert receives a loss based on its prediction.
[*]Expert weights are updated.
[*]The combined model places more influence on better-performing experts.

The term “expert” does not imply that each method is intelligent by itself. An expert is simply an individual forecasting rule.

In this indicator, the eight experts are eight moving-average methods.

The model uses a multiplicative-weights process closely related to the Hedge and Weighted Majority families of online-learning algorithms.

The central principle is:

[*]Do not commit permanently to one model.
[*]Track several models simultaneously.
[*]Reduce the weight of models that make mistakes.
[*]Allow the combined forecast to adapt as relative performance changes.

Online learning
The model learns sequentially, one bar at a time.

It does not train on a separate historical dataset and then freeze its parameters.

At each new bar:

[*]The previous slope of each moving average is treated as that expert's prediction.
[*]The realised close-to-close direction is observed.
[*]Each expert receives a loss.
[*]Weights are updated multiplicatively.
[*]Weights are normalised.
[*]The current expert values are blended using the new weights.

This makes the process online and adaptive.

The weight state is carried forward from bar to bar, meaning the current ensemble reflects the accumulated results of earlier expert decisions.

The expert bank
The ensemble contains eight moving-average experts:

[*]Simple Moving Average - SMA*
[*]Exponential Moving Average - EMA
[*]Weighted Moving Average - WMA*
[*]Hull Moving Average - HMA
[*]Double Exponential Moving Average - DEMA*
[*]Running Moving Average - RMA
[*]Arnaud Legoux Moving Average - ALMA*
[*]Least-Squares Moving Average - LSMA

All experts use the same Base Length.

This is important because it keeps their nominal observation horizon comparable. The ensemble is comparing different mathematical treatments of approximately the same lookback rather than comparing completely unrelated time horizons.

Even with an identical length, the experts behave differently because they assign weight to historical observations in different ways.

Simple Moving Average - SMA
The SMA applies equal weight to every observation inside the selected window.

Its general form is:

[*]SMA = Sum of observations / Number of observations

The SMA is stable and easy to interpret, but every included observation has the same importance.

This can make it slower to react when a new trend begins because older prices continue to influence the average until they leave the window.

Within the ensemble, the SMA acts as a neutral equal-weight baseline.

Exponential Moving Average - EMA
The EMA assigns progressively greater weight to recent observations.

Its recursive form is based on:

[*]EMA = α × Current Price + (1 - α) × Previous EMA

where α is determined by the selected length.

Compared with an SMA of the same length, an EMA generally responds more quickly to recent movement.

Its recursive weighting makes it useful during ordinary directional markets, although it can still turn repeatedly when price oscillates in a range.

Weighted Moving Average - WMA
The WMA assigns linearly increasing weight to more recent observations.

For example, in a simplified four-period WMA, the newest value receives four units of weight, while the oldest receives one.

This makes the WMA more responsive than an equal-weight SMA while retaining a finite lookback window.

Within the ensemble, it provides a direct recency-weighted alternative to the exponential behaviour of the EMA.

Hull Moving Average - HMA
The Hull Moving Average was designed to reduce lag while preserving a relatively smooth output.

Its construction combines weighted moving averages over different horizons, applies a lag-compensation step, and then smooths the result over approximately the square root of the original length.

Conceptually:

[*]Calculate a faster WMA.
[*]Calculate a slower WMA.
[*]Use their difference to compensate for lag.
[*]Smooth the compensated result.

The HMA often reacts quickly to changes in trend direction.

That responsiveness can make it valuable during strong transitions, but it may also make it more sensitive to short-term oscillation.

Double Exponential Moving Average - DEMA
Despite its name, DEMA is not simply an EMA calculated twice.

Its general construction is:

[*]DEMA = 2 × EMA - EMA of EMA

The second EMA estimates some of the lag in the first EMA. Subtracting it attempts to create a smoother with less delay.

DEMA can respond quickly to directional changes, although reduced lag may also increase sensitivity during unstable conditions.

Running Moving Average - RMA
RMA is commonly associated with Wilder-style smoothing.

It uses a slower recursive update than a typical EMA of the same nominal length.

Its general form places substantial influence on the previous RMA value, producing a persistent and stable estimate.

The RMA expert often changes direction less aggressively than the faster methods.

Within the ensemble, it acts as one of the more conservative smoothing models.

Arnaud Legoux Moving Average - ALMA
ALMA applies a Gaussian-style weighting curve across the observation window.

The weighting distribution can be shifted toward more recent observations while maintaining a smooth bell-shaped profile.

The script uses a recent-weighted offset and a fixed Gaussian width.

ALMA attempts to balance:

[*]Smoothness.
[*]Reduced lag.
[*]Controlled weighting of the observation window.

It provides a different weighting structure from the linear, exponential and lag-compensated experts.

Least-Squares Moving Average - LSMA
The LSMA is based on linear regression.

Instead of averaging historical prices directly, it fits a straight line through the selected window and evaluates the regression estimate at the current bar.

The method attempts to represent the local directional path of price.

LSMA can follow smooth trends closely because it models slope explicitly. However, it may respond strongly when the local regression direction changes abruptly.

Within the indicator, the LSMA is produced using the rolling linear-regression output.

Base Length
The Base Length is shared by all eight experts.

Lower values:

[*]Make every expert more responsive.
[*]Increase sensitivity to short-term changes.
[*]Produce faster weight and trend changes.
[*]Increase the possibility of whipsaws.

Higher values:

[*]Create smoother expert outputs.
[*]Focus the ensemble on broader trend structure.
[*]Reduce short-term changes.
[*]Increase lag during sudden reversals.

Because all experts share the same length, changing this setting adjusts the entire ensemble horizon.

It does not change the number of experts or their relative starting weights.

Expert predictions
The model evaluates each expert using the direction of its slope.

For each moving average:

[*]Rising slope is represented as +1.
[*]Falling or non-rising slope is represented as -1.

To evaluate the latest completed move, the script uses the expert's slope from the previous bar.

For example:

[*]If the expert was rising from two bars ago to the previous bar, it predicted a positive current move.
[*]If the expert was falling, it predicted a negative current move.

The realised outcome is determined from the current close relative to the previous close:

[*]Close above previous close = positive realised direction.
[*]Close below previous close = negative realised direction.
[*]Unchanged close = zero realised direction.

The model therefore scores directional slope prediction, not the numerical distance between each moving average and price.

An expert is rewarded for getting direction right, even if its plotted value is relatively far from the market.

Likewise, an expert is penalised for getting direction wrong even if its line remains visually close to price.

Loss functions
The indicator provides two loss functions:

[*]Directional 0/1*
[*]Magnitude-weighted

The selected loss determines how strongly incorrect experts are penalised.

Correct experts receive zero loss under both modes.

Directional 0/1 loss
Directional mode treats every incorrect prediction equally.

The loss is:

[*]0 when the expert predicted the realised direction correctly.
[*]1 when the expert predicted incorrectly.

This means that an incorrect prediction on a very small move receives the same loss as an incorrect prediction on a large move.

Directional mode answers a simple question:

Was the expert right or wrong?

It does not consider how important the move was.

This mode can produce consistent learning because every directional observation is treated equally, but it may respond to small and insignificant price changes as strongly as major moves.

Magnitude-weighted loss
Magnitude-weighted mode scales the penalty according to the size of the realised move.

The move is normalised using ATR:

[*]Move = Absolute close-to-close change / ATR

The ATR uses the shared Base Length.

The incorrect expert's loss becomes:

[*]Loss = Normalised Move

with the magnitude capped at 3.

The cap prevents a single extreme bar from creating an unlimited penalty.

This mode gives greater importance to mistakes during large movements.

For example:

[*]An incorrect expert during a 0.10 ATR move receives a small penalty.
[*]An incorrect expert during a 1.00 ATR move receives a larger penalty.
[*]An incorrect expert during a move above 3 ATR receives the capped penalty of 3.

Magnitude-weighted mode answers:

How costly was the directional mistake relative to current volatility?

This can make the ensemble adapt more strongly after significant movements while paying less attention to small fluctuations.

Flat price bars
If the current close is unchanged from the previous close, the realised direction is zero.

Because expert directions are encoded as either positive or negative, no expert can exactly match a zero realised direction.

Under Directional mode, all experts receive the same incorrect classification.

Because every weight is multiplied by the same penalty factor, their relative weight distribution remains effectively unchanged after normalisation.

Under Magnitude-weighted mode, the realised move is zero, so the resulting penalty is also zero.

In both cases, a completely flat close-to-close bar does not materially change the relative ranking of the experts.

Multiplicative weight update
Each expert begins with an equal weight:

[*]Initial Weight = 1 / 8

After the loss is calculated, the weight is updated using:

[*]New Unnormalised Weight = Old Weight × exp(-η × Loss)

where η is the Learning Rate.

This is the central Hedge or multiplicative-weights update.

Correct experts have zero loss:

[*]exp(-η × 0) = 1

Their unnormalised weight is unchanged.

Incorrect experts have a positive loss, so their weight is multiplied by a value below one.

For example, in Directional mode with a Learning Rate of 2:

[*]Incorrect Weight Multiplier = exp(-2) ≈ 0.135

An incorrect expert retains only about 13.5% of its previous unnormalised weight before the weight set is normalised again.

This does not mean its final displayed weight will necessarily fall by exactly 86.5%, because all expert weights are subsequently rescaled so they sum to one.

Why multiplicative updates are used
An additive system might subtract a fixed quantity from each incorrect expert.

That can create problems:

[*]Weights can become negative.
[*]The same penalty has a different effect on large and small weights.
[*]The model may not adapt proportionally.

A multiplicative update preserves non-negative weights and penalises experts proportionally to their current influence.

It also allows the distribution to become concentrated around consistently successful methods.

Learning Rate - η
The Learning Rate controls how aggressively the ensemble shifts weight after mistakes.

Higher values:

[*]Penalise incorrect experts more strongly.
[*]Move influence rapidly toward recent winners.
[*]Can produce winner-take-all behaviour.
[*]Can make the leader change abruptly after a few important bars.

Lower values:

[*]Produce gradual weight changes.
[*]Keep the expert distribution more diversified.
[*]Reduce sensitivity to short-term performance.
[*]Make the model slower to adapt.

The Learning Rate does not change the moving averages themselves. It changes only how quickly their relative influence evolves.

High Learning Rate behaviour
At high settings, a wrong expert may lose most of its weight after one or two mistakes.

This can be beneficial when one smoothing method is clearly better suited to the current regime.

It can also create instability:

[*]A recent winner can dominate the ensemble.
[*]A temporary performance streak can cause excessive concentration.
[*]The model can switch leaders quickly when conditions reverse.

Low Learning Rate behaviour
At low settings, the ensemble behaves more like a slowly adapting average of the expert bank.

No single observation dramatically changes the distribution.

This produces smoother adaptation, but a poorly suited expert may retain substantial influence for longer.

Weight normalisation
After all expert weights are updated, they are normalised:

[*]Normalised Weight = Expert Weight / Sum of All Expert Weights

This ensures that the complete weight set sums to one.

The weights can then be interpreted as each expert's share of the ensemble.

For example:

[*]A 25% weight means that expert contributes one quarter of the weighted output.
[*]A 5% weight means its current influence is relatively small.

The weights are not probabilities that the experts will be correct on the next bar.

They are adaptive influence coefficients based on accumulated relative loss.

Weight Floor
The optional Weight Floor preserves a minimum allocation for every expert.

After normalisation, the adjusted weight is calculated so that:

[*]Every expert receives at least the selected floor.
[*]The remaining weight is distributed according to the normalised Hedge weights.
[*]The full set continues to sum to one.

For eight experts, a floor of 0.01 reserves at least 1% for each expert.

This assigns:

[*]A minimum combined mass of 8%.
[*]The remaining 92% according to relative performance.

A floor of 0.05 reserves at least 5% for each of the eight experts, using 40% of the total distribution as minimum allocations.

The remaining 60% is distributed according to current performance.

Why use a floor?
Without a floor, repeatedly incorrect experts can approach a weight extremely close to zero.

Because the update only reduces weights after losses, an expert with almost no weight may require a long period of relative outperformance before it becomes influential again.

A positive floor keeps all methods alive.

This allows an expert that performed poorly in the previous regime to recover more quickly when the market environment changes.

Weight Floor set to zero
With a zero floor:

[*]The model is free to concentrate almost entirely in one expert.
[*]Recent winners can dominate strongly.
[*]The ensemble can become highly specialised.

This produces the purest multiplicative-weights behaviour but increases the risk of weight collapse.

Positive Weight Floor
With a positive floor:

[*]The expert bank remains diversified.
[*]Cold experts retain some influence.
[*]The model can recover more easily after regime changes.
[*]The leading expert's maximum possible weight is reduced.

The floor therefore controls the balance between specialisation and diversity.

Ensemble output
After the weight update, the current values of the eight experts are blended:

[*]Ensemble = Sum of Expert Weight × Expert Value

This is a weighted average in which the weights are determined by online directional performance.

If the HMA currently has the greatest weight, the ensemble will behave more like the HMA.

If the RMA and SMA dominate, the output will become smoother and more conservative.

If the weights are distributed evenly, the line represents a broad blend of all eight methods.

The output can therefore change its effective smoothing behaviour without changing the user-selected Base Length.

Line Smoothing
The weighted ensemble may be passed through an optional EMA for visual smoothing.

A setting of 1 effectively disables this additional stage.

Higher settings:

[*]Create a smoother displayed line.
[*]Reduce small slope changes.
[*]Delay bullish and bearish flips.

This smoothing is cosmetic in the sense that it occurs after the online expert weighting.

It does not affect:

[*]Expert predictions.
[*]Expert losses.
[*]Weight updates.
[*]Consensus.
[*]Leader selection.

It does affect the final plotted line and the trend state derived from that line.

Trend state
Trend direction is determined from the slope of the smoothed ensemble line.

[*]If the line is above its previous value, trend becomes bullish.
[*]If the line is below its previous value, trend becomes bearish.
[*]If the line is unchanged, the previous trend persists.

This creates a persistent two-state regime.

A bullish flip occurs when the trend changes from bearish to bullish.

A bearish flip occurs when it changes from bullish to bearish.

The trend state is based on the ensemble's slope, not on price crossing the ensemble.

Price may be above or below the line without immediately changing its direction.

Consensus calculation
The indicator calculates a separate weighted directional vote.

Each expert's current slope direction is multiplied by its current weight:

[*]Weighted Vote = Sum of Weight × Direction

Because each direction is either +1 or -1 and the weights sum to one, the vote lies between -1 and +1.

Examples:

[*]+1 means all meaningful weight is assigned to rising experts.
[*]-1 means all meaningful weight is assigned to falling experts.
[*]0 means bullish and bearish weighted influence is evenly balanced.

The displayed consensus strength is:

[*]Consensus Strength = Absolute Value of Weighted Vote

This converts the result to a range from zero to one.

[*]0% means the weighted expert bank is evenly divided.
[*]100% means the weighted influence is entirely aligned in one direction.

Weighted consensus versus expert count
Consensus is not calculated by simply counting how many of the eight experts are rising.

An expert with a 40% weight contributes more than one with a 2% weight.

For example:

[*]Five low-weight experts may be bullish.
[*]Three high-weight experts may be bearish.
[*]The final weighted vote can still be bearish.

This means consensus measures the agreement of the current weighted model, not the raw number of methods on each side.

With a zero Weight Floor, consensus may become very high when one expert dominates, even if several near-zero-weight experts disagree.

With a positive floor, disagreement from the remaining experts has more influence on the consensus value.

Consensus is not confidence
The consensus percentage should not be interpreted as a probability that the trend will continue.

It measures only the current alignment of weighted expert slopes.

High consensus means:

[*]The influential experts point in the same direction.

It does not guarantee:

[*]Future price continuation.
[*]A profitable entry.
[*]Low reversal risk.

Strong agreement can occur late in a mature trend as well as early in a new one.

Leading method
The live information label identifies the expert with the highest current weight.

It displays:

[*]The expert name.
[*]Its current percentage weight.
[*]The weighted consensus strength.
[*]The current ensemble direction.

For example:

[*]Leading: HMA (34.5%)*
[*]Consensus: 78% ▲

This means the HMA currently has the largest share of the ensemble and the weighted expert bank is strongly aligned upward.

The leader percentage is not a win probability.

It is only the experts share of the current normalised weight distribution.

Leader changes
The leading method can change when:

[*]The current leader makes directional mistakes.
[*]Another expert remains correct while competitors are penalised.
[*]A large magnitude-weighted move strongly changes relative weights.
[*]The market transitions into a regime better suited to another smoother.

Leader changes can help reveal how the ensemble is adapting.

For example:

[*]A shift toward HMA or DEMA may reflect stronger preference for responsive methods.
[*]A shift toward SMA or RMA may reflect better recent performance from slower methods.
[*]A shift toward LSMA may occur during a smooth local directional path.

These interpretations are contextual and should not be treated as fixed rules.

Gradient fill
The indicator fills the area between price and the ensemble line.

When price is above the line:

[*]A bullish gradient is displayed.

When price is below the line:

[*]A bearish gradient is displayed.

The gradient visually separates price from the adaptive trend estimate.

The fill reflects price location, while the line colour reflects the slope-derived ensemble trend.

These can temporarily disagree.

For example:

[*]Price may fall below a still-rising ensemble during a pullback.
[*]Price may rise above a still-falling ensemble during a counter-trend rally.

This disagreement can provide useful context.

Consensus glow
A glow is drawn around the ensemble line.

Its brightness changes according to weighted consensus.

When consensus is high:

[*]The glow becomes brighter and more visible.

When the experts are divided:

[*]The glow becomes more transparent.

The glow width is scaled using ATR based on the Base Length, helping the effect remain proportional across instruments and volatility environments.

The glow is a visual representation of model agreement. It does not modify the line or trend calculation.

Candle colouring
Candles can be coloured according to the current ensemble trend:

[*]Bullish trend uses the selected bullish colour.
[*]Bearish trend uses the selected bearish colour.

Candle colouring is based on the direction of the ensemble line, not the direction of each individual candle.

A bearish candle can therefore remain green during a bullish ensemble regime, and a bullish candle can remain red during a bearish regime.

How to interpret the indicator

Bullish ensemble trend
A bullish state means the final ensemble line is rising.

This indicates that the current weighted combination of experts is moving upward.

It does not require all individual experts to be bullish.

Bearish ensemble trend
A bearish state means the final ensemble line is falling.

The weighted combination is moving downward, even if one or more individual experts remain bullish.

High bullish consensus
A strongly positive vote means most influential expert weight is assigned to rising methods.

This can indicate broad directional alignment.

High bearish consensus
A strongly negative vote means the influential experts are predominantly falling.

Low consensus
A consensus near zero means weighted expert directions are divided.

This can occur during:

[*]Trend transitions.
[*]Sideways ranges.
[*]Pullbacks.
[*]Disagreement between faster and slower methods.

Low consensus does not automatically mean price will remain sideways. It means the ensemble's components are not currently aligned.

High leader weight and high consensus
This indicates that:

[*]One method currently dominates.
[*]The broader weighted bank is aligned with it.

The model is highly concentrated and directionally unified.

This can produce a responsive and decisive ensemble, but it also means the output depends heavily on the current leader.

Distributed weights and high consensus
This means several experts maintain meaningful weights while pointing in the same direction.

The trend is supported by a more diversified group of methods.

Leader weight high but consensus low
This can occur when the dominant expert points one way while several remaining experts point the other way.

The ensemble may still follow the leader, but internal disagreement is present.

How to use the indicator

1. Trend regime filter
Use the ensemble slope as directional context:

[*]Prioritise long setups during bullish regimes.
[*]Prioritise short setups during bearish regimes.

The indicator does not define entry price, stop placement or profit targets.

2. Consensus filter
A user may require stronger consensus before acting on the trend state.

For example:

[*]A bullish flip with low consensus may represent an early or uncertain transition.
[*]A bullish regime with high consensus indicates broader weighted alignment.

No universal consensus threshold is appropriate for every market.

3. Pullback analysis
During a bullish ensemble regime:

[*]Price moving toward or below the line may represent a pullback.
[*]The ensemble remaining bullish suggests its trend estimate has not yet reversed.

During a bearish regime:

[*]Price moving toward or above the line may represent a counter-trend rally.

Price interaction with the line should be combined with structure and risk management.

4. Regime adaptation observation
The Leading Method label can be used to study how different smoothers perform through changing environments.

Rather than assuming one moving average is always best, the user can observe:

[*]Which expert gains weight during trends.
[*]Which expert takes over during transitions.
[*]How concentrated the model becomes.
[*]How quickly weights change under different Learning Rates.

5. Bullish and bearish flips
Trend flips can be used as:

[*]Regime-change alerts.
[*]Confirmation for another setup.
[*]Potential exit conditions.
[*]A directional filter for discretionary trades.

Because flips are based on line slope, responsive settings can generate repeated changes during ranges.

Suggested configurations

Balanced adaptive configuration

[*]Moderate Base Length.
[*]Moderate Learning Rate.
[*]Directional loss.
[*]Small positive Weight Floor.
[*]Minimal Line Smoothing.

This keeps the model adaptive while preserving some expert diversity.

Fast adaptation configuration

[*]Shorter Base Length.
[*]Higher Learning Rate.
[*]Magnitude-weighted loss.
[*]Zero or very small Weight Floor.
[*]Line Smoothing of 1 or 2.

This allows rapid concentration around recent winners but can create unstable leader changes.

Conservative diversified configuration

[*]Longer Base Length.
[*]Lower Learning Rate.
[*]Directional loss.
[*]Positive Weight Floor.
[*]Additional Line Smoothing.

This creates slower and more diversified adaptation.

Large-move-focused configuration
Magnitude-weighted loss can be used when mistakes during large ATR-normalised moves should matter more than errors during minor fluctuations.

This may reduce the influence of small alternating bars on the weight distribution.

Pure directional configuration
Directional loss is useful when every close-to-close directional observation should be treated equally.

It creates a straightforward right-or-wrong scoring process.

How this differs from averaging moving averages
A normal moving-average ribbon or composite may calculate:

[*]Average of SMA, EMA, HMA and other methods.

If every method receives equal weight permanently, its influence never changes.

Adaptive Trend Ensemble instead calculates:

[*]Performance-dependent weights.
[*]Sequential loss updates.
[*]A dynamically changing weighted output.

Two bars with the same expert values can produce different ensemble values if the weight distributions differ.

How this differs from selecting the current fastest average
The indicator does not select whichever moving average is currently closest to price or whichever has moved the most.

Weights are based on whether previous expert slopes correctly anticipated realised price direction.

An expert can therefore lead even if it is not the fastest or closest line.

How this differs from an optimisation
The model does not search historical data for one set of parameters with the best backtest result.

It does not change the shared length of each expert.

Instead, it performs continuous online adaptation of the expert weights.

This avoids permanently selecting one historical winner, but it also means recent performance can strongly influence the current model.

How this differs from a machine-learning forecast
The indicator uses a genuine online-learning algorithm, but it is not a neural network or a price-target forecasting model.

It does not estimate the size of the next move.

The experts make binary directional predictions derived from their slopes.

The learning system then adjusts how much influence each moving-average value receives.

It is therefore best understood as an adaptive model-selection and blending process.

Causality and real-time behaviour
The learning update uses:

[*]The prior-bar slope of each expert.
[*]The current close-to-close realised direction.

It does not use future bars.

On historical completed candles, the update is fully causal.

On the current live candle:

[*]The close can continue changing.
[*]The realised direction can change.
[*]Expert values can change.
[*]Weights and consensus can update intrabar.
[*]A bullish or bearish flip may appear before the candle closes.

Users requiring confirmed signals should evaluate the indicator at bar close.

Strengths

[*]Combines eight distinct smoothing methods.
[*]Adapts expert influence through online learning.
[*]Supports directional and magnitude-sensitive losses.
[*]Uses multiplicative updates rather than fixed weighting.
[*]Provides optional protection against permanent weight collapse.
[*]Separates ensemble direction from expert consensus.
[*]Displays the currently leading method.
[*]Uses one shared horizon for a fairer expert comparison.
[*]Requires no offline training process.
[*]Provides transparent open-source calculations.

Summary
Adaptive Trend Ensemble combines eight moving-average experts using a multiplicative online-learning model.

Each expert uses the same Base Length but applies a different smoothing method. The previous slope of each expert acts as its directional prediction for the latest close-to-close move.

After the realised direction is observed, incorrect experts receive either a fixed directional loss or an ATR-normalised magnitude-weighted loss. Their weights are reduced using an exponential Hedge update, then normalised and optionally adjusted using a minimum Weight Floor.

The current expert values are blended according to these adaptive weights, producing one ensemble line whose effective behaviour changes as different methods gain or lose influence.

A separate weighted vote measures current directional agreement. This consensus controls the visual glow and is displayed beside the current leading expert.

The result is a transparent adaptive trend model that does not assume one moving average will remain optimal. Instead, it continuously redistributes influence toward the methods that have recently aligned better with realised price direction while retaining configurable control over responsiveness, diversity and visual smoothing.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

import TradingView/ta/12 as ta

//@version=6
indicator(
 "Adaptive Trend Ensemble [BackQuant]", 
 overlay=true
 )

// Inputs
const string g1 = "Ensemble"
const string g2 = "Online Learning"
const string g3 = "UI Settings"

float  src = input.source(close, "Source", group = g1)
int    len = input.int(30, "Base Length", minval = 2, maxval = 400, group = g1, tooltip = "Shared lookback for every expert in the bank.")

float  eta = input.float(2.0, "Learning Rate (η)", minval = 0.05, maxval = 10.0, step = 0.05, group = g2, tooltip = "How hard weight shifts toward recently-correct experts. Higher = faster adaptation, more winner-take-all.")
string lossMode = input.string("Directional (0/1)", "Loss Function", options = ["Directional (0/1)", "Magnitude-weighted"], group = g2, tooltip = "How each expert is scored per bar. Directional = right/wrong. Magnitude = penalty scales with the size of the move it got wrong.")
float  floorW = input.float(0.0, "Weight Floor", minval = 0.0, maxval = 0.05, step = 0.001, group = g2, tooltip = "Minimum weight kept for every expert so a cold one can recover. 0 = allow pure winner-take-all.")

int    smooth = input.int(25, "Line Smoothing", minval = 1, maxval = 50, group = g3, tooltip = "Cosmetic EMA on the ensemble output. 1 = raw weighted line.")
bool   showFill = input.bool(true, "Gradient Fill", group = g3)
bool   showGlow = input.bool(true, "Consensus Glow", group = g3, tooltip = "Glow brightness scales with how strongly the weighted experts agree on direction.")
bool   paintBar = input.bool(true, "Color Bars", group = g3)
bool   showInfo = input.bool(true, "Show Leading Method", group = g3)
int    lineW = input.int(3, "Line Width", minval = 1, maxval = 6, group = g3)
color  longCol  = input.color(#00ff00, "Bullish", inline = "c", group = g3)
color  shortCol = input.color(#ff0000, "Bearish", inline = "c", group = g3)

// Hedge / Multiplicative-Weights model
// Prediction with expert advice. Each bar every expert incurs a loss; weights update
// multiplicatively w_i *= exp(-η·loss_i) then renormalize. Classic online-learning
// algorithm (Weighted Majority / Hedge).
type Hedge
    array<float> w
    int          k

method update(Hedge this, array<int> pdirs, float realized, float move, float eta, string mode, float floorW) =>
    for i = 0 to this.k - 1
        int   pd    = array.get(pdirs, i)
        float wrong = pd == realized ? 0.0 : 1.0
        float loss  = mode == "Directional (0/1)" ? wrong : wrong * math.min(move, 3.0)
        array.set(this.w, i, array.get(this.w, i) * math.exp(-eta * loss))
    float s = array.sum(this.w)
    if s > 0
        for i = 0 to this.k - 1
            float normalized = array.get(this.w, i) / s
            float adjusted   = floorW + (1.0 - floorW * this.k) * normalized
            array.set(this.w, i, adjusted)
    this

method blend(Hedge this, array<float> vals) =>
    float acc = 0.0
    for i = 0 to this.k - 1
        acc += array.get(this.w, i) * array.get(vals, i)
    acc

method consensus(Hedge this, array<int> dirs) =>
    float acc = 0.0
    for i = 0 to this.k - 1
        acc += array.get(this.w, i) * array.get(dirs, i)
    acc

method leader(Hedge this) =>
    int   top  = 0
    float best = -1.0
    for i = 0 to this.k - 1
        if array.get(this.w, i) > best
            best := array.get(this.w, i)
            top  := i
    [top, best]

// Expert bank - 8 moving-average methods, shared length
float e0 = ta.sma(src, len)
float e1 = ta.ema(src, len)
float e2 = ta.wma(src, len)
float e3 = ta.hma(src, len)
float e4 = ta.dema(src, len)
float e5 = ta.rma(src, len)
float e6 = ta.alma(src, len, 0.85, 6)
float e7 = ta.linreg(src, len, 0)

var array<string> names = array.from("SMA", "EMA", "WMA", "HMA", "DEMA", "RMA", "ALMA", "LSMA")
var Hedge model = Hedge.new(array.new_float(8, 1.0 / 8.0), 8)

// current expert values + current slope directions + previous-bar directions (what "predicted" this bar)
array<float> vals  = array.from(e0, e1, e2, e3, e4, e5, e6, e7)
array<int>   dirs  = array.from(e0 > e0[1] ? 1 : -1, e1 > e1[1] ? 1 : -1, e2 > e2[1] ? 1 : -1, e3 > e3[1] ? 1 : -1, e4 > e4[1] ? 1 : -1, e5 > e5[1] ? 1 : -1, e6 > e6[1] ? 1 : -1, e7 > e7[1] ? 1 : -1)
array<int>   pdirs = array.from(e0[1] > e0[2] ? 1 : -1, e1[1] > e1[2] ? 1 : -1, e2[1] > e2[2] ? 1 : -1, e3[1] > e3[2] ? 1 : -1, e4[1] > e4[2] ? 1 : -1, e5[1] > e5[2] ? 1 : -1, e6[1] > e6[2] ? 1 : -1, e7[1] > e7[2] ? 1 : -1)

float realized = math.sign(close - close[1])
float atrN     = ta.atr(len)
float move     = atrN > 0 ? math.abs(close - close[1]) / atrN : 0.0

// learn (only once experts are valid)
if bar_index > len + 2
    model.update(pdirs, realized, move, eta, lossMode, floorW)

float ens  = model.blend(vals)
float vote = model.consensus(dirs)
float line = ta.ema(ens, smooth)

// Trend + consensus strength
var int trend = 0
if line > line[1]
    trend := 1
else if line < line[1]
    trend := -1

color trendCol = trend == 1 ? longCol : trend == -1 ? shortCol : color.gray
float strength = nz(math.abs(vote), 0.0)               // 0 = split, 1 = all weight agrees
bool  bullFlip = trend == 1 and trend[1] == -1
bool  bearFlip = trend == -1 and trend[1] == 1

// Plots
pLine  = plot(line, "Ensemble", color = trendCol, linewidth = lineW)
pPrice = plot(close, "Price ref", display = display.none, editable = false)

// gradient fill between line and price
fill(pPrice, pLine, close > line ? close : line, close > line ? line : close, showFill and close > line ? color.new(longCol, 92) : na,  showFill and close > line ? color.new(longCol, 20) : na,  title = "Bull Fill")
fill(pPrice, pLine, close < line ? line : close, close < line ? close : line, showFill and close < line ? color.new(shortCol, 20) : na, showFill and close < line ? color.new(shortCol, 92) : na, title = "Bear Fill")

// consensus-driven glow: brighter when experts agree, faint when they fight
int   glowAlpha = int(math.max(20, math.min(90, 88 - strength * 58)))
float glow      = atrN * 0.06
pGlowUp = plot(line - glow, "Glow lower", display = display.none, editable = false)
pGlowDn = plot(line + glow, "Glow upper", display = display.none, editable = false)
fill(pLine, pGlowUp, showGlow ? color.new(trendCol, glowAlpha) : na, title = "Glow Lower")
fill(pLine, pGlowDn, showGlow ? color.new(trendCol, glowAlpha) : na, title = "Glow Upper")

// candles
barcolor(paintBar ? color.new(trendCol, 10) : na, title = "Trend Candles")

// live "leading method" label (single label, not a table)
var label lb = na
if showInfo and barstate.islast
    [top, best] = model.leader()
    string txt = "Leading: " + array.get(names, top) + "  (" + str.tostring(best * 100, "#.#") + "%)" + "\nConsensus: " + str.tostring(strength * 100, "#") + "%  " + (trend == 1 ? "▲" : "▼")
    label.delete(lb)
    lb := label.new(bar_index + 2, line, txt, xloc.bar_index, yloc.price, color.new(trendCol, 20), label.style_label_left, color.white, size = size.normal)

// Alerts
alertcondition(bullFlip, "Ensemble Bullish", "Adaptive Trend Ensemble turned bullish on {{ticker}}")
alertcondition(bearFlip, "Ensemble Bearish", "Adaptive Trend Ensemble turned bearish on {{ticker}}")
````
