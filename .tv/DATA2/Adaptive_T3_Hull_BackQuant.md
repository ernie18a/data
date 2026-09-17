<!-- tradingview-pine-id: PUB;fc16431c5d044f97b847696942c09080 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive T3 Hull [BackQuant]

Source: https://www.tradingview.com/script/to9JMbUI-Adaptive-T3-Hull-BackQuant/

## Description

Adaptive T3 Hull [BackQuant]

Overview
Adaptive T3 Hull is a configurable trend-following overlay that combines the lag-compensation structure of a Hull-style moving average with T3 smoothing and several optional mechanisms designed specifically to control overshoot, hooks and oscillating tails.

A conventional Hull construction gains responsiveness by comparing a faster and slower smoother, extrapolating their difference, and then smoothing the result again. This can produce a very responsive trend estimate, but the same lag compensation responsible for that responsiveness can also create exaggerated curvature around sharp reversals.

Adaptive T3 Hull makes that trade-off directly controllable.

The indicator replaces the traditional weighted-moving-average Hull stages with T3 smoothers and expands the basic Hull architecture with:

[*]Adjustable fast/slow length relationships.
[*]Adjustable Hull lag compensation.
[*]Configurable final smoothing geometry.
[*]Curvature-sensitive tail damping.
[*]Optional asymmetric damping around turns.
[*]An adaptive T3 volume factor.
[*]An optional ATR-based velocity limiter.
[*]Optional final lag compensation.
[*]Trend-strength-dependent ribbon intensity.
[*]Tail and curvature diagnostics in the Data Window.

The result is not intended to reproduce a standard HMA exactly. It is a generalized Hull-style framework in which the user can explicitly control the balance between responsiveness, smoothness and overshoot.

Core idea
Most trend smoothers face the same fundamental compromise:

[*]More smoothing reduces noise but increases lag.
[*]More lag compensation improves responsiveness but can create overshoot.

The Hull concept addresses lag by comparing a fast smoother with a slower smoother and projecting the difference forward.

A generalized form can be written as:

[*]Hull Raw = Fast + Compensation × (Fast - Slow)

If Compensation is zero:

[*]Hull Raw = Fast

No additional lag compensation is applied.

If Compensation is one:

[*]Hull Raw = 2 × Fast - Slow

This reproduces the familiar compensation structure used in the standard Hull Moving Average.

Values between zero and one provide partial compensation.

Adaptive T3 Hull defaults to a substantially smaller compensation value. This is deliberate. It reduces the tendency for the projected line to extend beyond the fast smoother during sharp changes in direction.

The remaining responsiveness can then be controlled using the fast-length ratio, T3 characteristics and optional final generalization rather than relying entirely on aggressive Hull extrapolation.

Processing chain
The complete indicator can be understood as the following sequence:

[*]Select the source and main Hull Length.
[*]Derive a fast T3 length from the Fast Length Ratio.
[*]Derive a final smoothing length from a configurable power-law relationship.
[*]Calculate fast and slow T3 smoothers.
[*]Measure velocity and curvature of the fast T3.
[*]Normalize curvature using ATR.
[*]Optionally reduce the active T3 Volume Factor during high curvature.
[*]Recalculate the fast and slow T3 legs with the adaptive factor.
[*]Measure the active curvature state.
[*]Optionally reduce Hull compensation when curvature increases.
[*]Construct the compensated fast-minus-slow T3 Hull.
[*]Smooth that result through another T3 stage.
[*]Optionally apply a final generalized lag-compensation stage.
[*]Optionally limit extreme one-bar movement using ATR.
[*]Determine trend from the final line slope.
[*]Build a smoothed one-bar-offset ribbon around the result.

Each stage affects a different part of the lag-versus-overshoot problem.

T3 smoothing
The T3 is a multi-stage recursive smoother constructed from a sequence of exponential moving averages.

The script calculates six EMA stages:

[*]E1 = EMA(Source)
[*]E2 = EMA(E1)
[*]E3 = EMA(E2)
[*]E4 = EMA(E3)
[*]E5 = EMA(E4)
[*]E6 = EMA(E5)

Those stages are then combined using coefficients derived from the T3 Volume Factor.

The final T3 has the general form:

[*]T3 = C1×E6 + C2×E5 + C3×E4 + C4×E3

where C1 through C4 change with the Volume Factor.

This construction allows T3 smoothing to maintain substantial smoothness while using coefficient-based compensation to reduce some of the lag created by repeated EMA filtering.

Important: T3 Volume Factor does not use trading volume
Despite its name, the T3 Volume Factor is not calculated from market volume.

It is a coefficient controlling the internal T3 response.

Changing it does not incorporate:

[*]Exchange volume.
[*]Volume profile.
[*]OBV.
[*]Money flow.

It changes how aggressively the internal EMA stages are combined.

Higher values generally increase compensation and responsiveness, but can also increase overshoot.

Lower values generally produce a more restrained and smoother response.

This relationship is particularly important in this indicator because Hull compensation and T3 compensation can interact.

An aggressive T3 followed by aggressive Hull extrapolation can produce substantially more tail behaviour than either technique alone.

Why combine T3 and Hull logic?
Hull-style smoothing and T3 smoothing approach lag reduction differently.

The Hull architecture uses:

[*]A fast smoother.
[*]A slow smoother.
[*]The difference between them.
[*]A final smoothing stage.

T3 uses:

[*]Multiple recursive EMA stages.
[*]A coefficient-controlled combination of those stages.

Adaptive T3 Hull combines both ideas.

Instead of:

[*]Fast WMA.
[*]Slow WMA.
[*]Final WMA.

the indicator uses:

[*]Fast T3.
[*]Slow T3.
[*]Compensated difference.
[*]Final T3.

This produces a smoother underlying structure while retaining the ability to compensate for lag.

However, combining two lag-reduction mechanisms also makes overshoot control more important. Much of the indicator is therefore devoted to regulating that compensation dynamically.

Hull Length
Hull Length establishes the main smoothing horizon.

It is used to derive:

[*]The slow T3 length.
[*]The fast T3 length.
[*]The final smoothing length.

Lower values:

[*]React more quickly.
[*]Track shorter trend changes.
[*]Increase sensitivity to local curvature.
[*]Can generate more frequent directional flips.

Higher values:

[*]Produce broader trend estimates.
[*]Reduce short-term variation.
[*]Increase response delay.
[*]Generally produce more persistent regimes.

Unlike a standard HMA, the relationship between these three smoothing stages is not fixed.

Fast Length Ratio
The fast T3 length is calculated as:

[*]Fast Length = Hull Length × Fast Length Ratio

with the result rounded to a valid integer.

In a conventional Hull structure, the fast stage normally uses approximately half the main length.

Therefore:

[*]Fast Length Ratio = 0.50

reproduces the familiar half-length relationship.

The default configuration uses a larger ratio, making the fast leg closer in length to the slow leg.

This matters because the difference:

[*]Fast T3 - Slow T3

is the quantity used for lag compensation.

If the fast and slow stages are very different:

[*]Their separation can become larger.
[*]Hull compensation becomes stronger.
[*]The resulting line can react faster.
[*]Overshoot potential increases.

If their lengths are closer:

[*]Their separation becomes smaller.
[*]The compensation term becomes more restrained.
[*]The final line generally becomes smoother.

Fast Length Ratio is therefore another direct control over the aggressiveness of the Hull projection.

Hull Compensation
Hull Compensation controls how much of the fast-versus-slow difference is added back to the fast T3.

The underlying formula is:

[*]Hull Raw = Fast T3 + Effective Compensation × (Fast T3 - Slow T3)

Before adaptive damping is applied, Effective Compensation begins from the Hull Compensation input.

Compensation = 0
The raw line becomes the fast T3 itself.

No Hull-style extrapolation occurs.

Compensation = 1
The calculation becomes:

[*]2 × Fast T3 - Slow T3

which matches the standard Hull lag-compensation form.

Compensation between 0 and 1
Only part of the fast-slow separation is extrapolated.

This creates a middle ground between:

[*]Pure fast smoothing.
[*]Full Hull compensation.

Compensation above 1
The difference is extrapolated even more aggressively than a conventional Hull construction.

This can create a highly responsive line, but it also increases the likelihood of:

[*]Overshoot.
[*]Hooks.
[*]Large tails after sharp turns.

The default is intentionally conservative relative to a standard Hull.

What are Hull tails?
Hull-style moving averages can develop a distinctive oscillating or hooked appearance around strong reversals.

This occurs because the lag-compensation term is effectively extrapolating the difference between two smoothers.

Imagine the fast smoother accelerating upward while the slow smoother is still catching up.

The difference:

[*]Fast - Slow

becomes positive.

Adding that difference to the fast smoother projects the result even further upward.

When price abruptly reverses, the fast smoother begins turning first while the slow smoother remains elevated.

The compensation term can then change rapidly and cause the completed Hull to:

[*]Extend beyond the fast line.
[*]Hook sharply.
[*]Reverse with excessive curvature.

This is not necessarily an error in the Hull formula. It is a consequence of aggressive lag compensation.

Adaptive T3 Hull includes several independent tools for reducing this behaviour.

Final Hull smoothing
After the fast and slow T3 legs are combined, the raw Hull is smoothed again.

The final smoothing length is calculated from:

[*]Length^Hull Smoothing Exponent × Final Smoothing Multiplier

This generalizes the standard Hull square-root stage.

A conventional HMA normally uses approximately:

[*]sqrt(Length)

which is equivalent to:

[*]Length^0.50

before rounding.

Hull Smoothing Exponent
The Hull Smoothing Exponent controls how strongly the final smoothing length grows as the main Hull Length increases.

Exponent = 0.50
Reproduces the square-root relationship used in the conventional Hull construction.

Exponent below 0.50
Produces a shorter final smoothing stage, particularly at larger main lengths.

This generally:

[*]Increases responsiveness.
[*]Allows more of the compensated movement through.

Exponent above 0.50
Creates a longer final smoothing stage.

This generally:

[*]Reduces local variation.
[*]Smooths more aggressively.
[*]Adds response delay.

The script allows this relationship to be generalized instead of forcing the standard square-root rule.

Final Smoothing
Final Smoothing applies an additional multiplier to the derived root length:

[*]Final Length = Length^Exponent × Root Multiplier

This gives a second level of control over the final stage without changing the underlying power-law relationship.

Higher values:

[*]Increase final smoothing.
[*]Reduce local hooks.
[*]Slow the line.

Lower values:

[*]Decrease final smoothing.
[*]Increase responsiveness.
[*]Allow more short-term curvature through.

The Smoothing Exponent controls how smoothing scales with Hull Length.

The Final Smoothing multiplier controls the overall magnitude of that final stage.

Curvature measurement
Adaptive tail damping requires a way to determine when the fast T3 is changing direction unusually quickly.

The indicator first calculates velocity:

[*]Velocity = Fast T3 - Previous Fast T3

Previous velocity is:

[*]Previous Velocity = Previous Fast T3 - Fast T3 two bars ago

Curvature is then approximated as the absolute change in velocity:

[*]Curvature = |Velocity - Previous Velocity|

This is a discrete second-difference concept.

Velocity describes how quickly the smoother is moving.

Curvature describes how quickly that velocity itself is changing.

For example:

[*]A steadily rising line can have positive velocity but low curvature.
[*]A line suddenly flattening after a strong rise can have high curvature.
[*]A sharp reversal can produce very high curvature.

This makes curvature particularly useful for detecting the conditions in which Hull overshoot tends to appear.

ATR normalization
Raw curvature is not directly comparable across instruments.

A $10 curvature movement is enormous for one market and negligible for another.

The script therefore normalizes curvature using ATR:

[*]Normalized Curvature = Curvature / ATR

The result is capped at 1.

This creates an adaptive pressure measure between approximately:

[*]0 = little curvature relative to recent range.
[*]1 = very large curvature relative to recent range.

ATR is calculated using the Damping Normalization length.

This normalized curvature drives several optional adaptive mechanisms.

Damping Normalization
Damping Normalization controls the ATR period used when converting curvature into a relative value.

Short values:

[*]Make the normalization respond rapidly to current volatility.
[*]Allow damping pressure to change quickly.

Longer values:

[*]Create a more stable volatility baseline.
[*]Reduce rapid changes in normalized curvature.

This setting does not smooth the final T3 Hull directly.

It changes how the adaptive systems interpret curvature.

Adaptive Tail Damping
Adaptive Tail Damping dynamically reduces Hull Compensation when curvature becomes large.

The process can be summarized as:

[*]Effective Compensation = Hull Compensation × (1 - Damping Pressure × Damping Strength)

When curvature is low:

[*]Damping Pressure approaches zero.
[*]Effective Compensation remains close to the selected Hull Compensation.

When curvature becomes large:

[*]Damping Pressure increases.
[*]Effective Compensation is reduced.

This means the indicator deliberately removes some of its lag compensation precisely when the fast T3 is bending sharply.

Why reduce compensation during curvature?
Hull compensation is most useful when the fast and slow smoothers are moving consistently in the same directional structure.

During a smooth trend:

[*]The fast line leads the slow line.
[*]Their separation can be used to reduce lag.

During a sharp turn:

[*]The fast line may reverse before the slow line.
[*]Their separation can become a poor estimate of useful forward compensation.
[*]Extrapolating the full difference can create overshoot.

Adaptive damping therefore treats high curvature as a reason to trust the Hull extrapolation less.

Damping Strength
Damping Strength determines how much curvature can reduce Hull compensation.

At zero:

[*]Curvature has no effect on compensation.

As the value increases:

[*]High-curvature events remove progressively more compensation.
[*]The line becomes more restrained around sharp turns.

At a Damping Strength of 1 and maximum normalized curvature, compensation can theoretically be reduced all the way toward zero.

This does not stop the underlying T3 from moving.

It removes the additional Hull extrapolation.

Asymmetric Turn Damping
By default, curvature damping can apply whenever the fast T3 experiences significant curvature.

Asymmetric Turn Damping makes the condition more selective.

When enabled, damping pressure is only applied when the current velocity is moving against the previous directional pace.

Conceptually:

[*]A previously rising fast T3 is damped when its upward velocity begins weakening or reversing.
[*]A previously falling fast T3 is damped when its downward velocity begins weakening or reversing.

This allows strong acceleration in the existing direction to retain more compensation while focusing the damping mechanism around deceleration and turning behaviour.

The purpose is to distinguish:

[*]Curvature caused by trend acceleration.
[*]Curvature caused by trend exhaustion or reversal.

This can preserve responsiveness during strong continuation while still suppressing tails around turns.

Adaptive T3 Volume Factor
Adaptive T3 Volume Factor provides a second curvature-sensitive damping mechanism.

Instead of changing the Hull compensation, this feature changes the internal T3 coefficient itself.

The active factor is approximately:

[*]Active VF = Base VF × (1 - Normalized Curvature × VF Damping Strength)

subject to the configured minimum.

When curvature is low:

[*]Active VF remains near the selected T3 Volume Factor.

When curvature rises:

[*]Active VF is reduced.
[*]The T3 becomes less aggressively compensated.

This attacks overshoot earlier in the processing chain.

Hull damping versus VF damping
The two mechanisms affect different stages.

Adaptive Tail Damping
changes how much:

[*]Fast T3 - Slow T3

is extrapolated.

Adaptive T3 Volume Factor
changes how the T3 smoothers themselves are constructed.

Using both means curvature can reduce:

[*]The aggressiveness of each T3 leg.
[*]The aggressiveness of the Hull compensation between those legs.

This can strongly suppress tails but may also reduce responsiveness.

The controls are therefore optional and independently adjustable.

VF Damping Strength
VF Damping Strength controls how strongly curvature reduces the T3 Volume Factor.

Higher values:

[*]Produce larger reductions during sharp curvature.
[*]Increase smoothing around turns.
[*]Can reduce T3 overshoot more aggressively.

Lower values:

[*]Keep Active VF closer to the base setting.
[*]Preserve more of the original T3 response.

Minimum VF
Minimum VF prevents the adaptive mechanism from reducing the active coefficient indefinitely.

It defines the lower bound used when Adaptive T3 Volume Factor is active.

This keeps the filter within a controlled response range during extreme curvature.

If the selected base Volume Factor is already below the requested minimum, the script does not force it upward above the base value.

Generalize Final Hull
Generalize Final Hull adds another optional lag-compensation stage after the main T3 Hull has already been completed.

A second smoothed version of the completed Hull is calculated.

The final target then becomes:

[*]Hull Target = Hull Base + Generalization × (Hull Base - Second Hull)

This uses the same broad idea as Hull compensation:

[*]Compare a faster estimate with a slower version.
[*]Add part of their difference back to the faster estimate.

At zero Generalization:

[*]The stage has no effect.

As Generalization increases:

[*]The final result becomes more responsive.
[*]Lag is reduced further.
[*]Overshoot potential increases.

This option exists because the earlier tail controls allow the user to reduce aggressive compensation in the main Hull construction and, if desired, reintroduce a smaller amount of controlled responsiveness at the end.

Generalization
Generalization controls the amount of final compensation.

Lower values create subtle lag reduction.

Higher values increasingly extrapolate the difference between the first and second completed Hull smoothers.

This feature should be considered one of the more aggressive responsiveness controls in the indicator.

If the objective is maximum tail suppression, it can be left disabled.

Velocity Limiter
The Velocity Limiter addresses a different problem.

Curvature damping changes how the line is calculated.

The Velocity Limiter places a direct cap on how far the completed line is allowed to move in one bar.

The maximum permitted movement is:

[*]Maximum Step = ATR × Max ATR / Bar

The desired change is:

[*]Delta = Hull Target - Previous T3 Hull

That change is clamped between:

[*]-Maximum Step
[*]+Maximum Step

The final T3 Hull then advances by only the permitted amount.

Why use a velocity limiter?
Occasionally, a large price shock or a combination of aggressive settings can cause the completed Hull target to jump sharply.

The limiter acts as a final mechanical speed limit.

It can reduce:

[*]Single-bar jumps.
[*]Extreme hooks.
[*]Shock-driven movement.

However, this comes with a clear trade-off.

If the market genuinely reprices very quickly, the limiter deliberately prevents the trend line from following the full move immediately.

It therefore introduces controlled lag.

Max ATR / Bar
This setting determines the maximum permitted single-bar movement in ATR units.

For example:

[*]0.35 allows the completed line to move by no more than 0.35 ATR in one bar.

Lower values:

[*]Create stronger movement suppression.
[*]Produce smoother transitions.
[*]Can significantly delay response to genuine breaks.

Higher values:

[*]Interfere less often.
[*]Allow larger legitimate moves.

The limiter is disabled by default because it is a strong constraint.

How the tail controls work together
The script provides several different ways to reduce tail behaviour because overshoot can originate at multiple stages.

Fast Length Ratio
Reduces fast-versus-slow separation.

Hull Compensation
Directly controls extrapolation of that separation.

Final Smoothing
Smooths the compensated output more heavily.

Adaptive Tail Damping
Reduces Hull compensation during curvature.

Asymmetric Turn Damping
Restricts that damping mainly to deceleration and turning behaviour.

Adaptive T3 Volume Factor
Makes the underlying T3 calculations more conservative during curvature.

Velocity Limiter
Caps the final single-bar movement.

Generalization
Moves in the opposite direction by optionally adding some final lag compensation back.

These controls are intentionally modular.

A user does not need to enable all of them.

Default design philosophy
The default settings intentionally do not reproduce a standard Hull Moving Average.

A standard Hull-like configuration would approximately use:

[*]Fast Length Ratio near 0.50.
[*]Hull Compensation near 1.00.
[*]Hull Smoothing Exponent near 0.50.
[*]Final Smoothing near 1.00.

The default Adaptive T3 Hull uses a much more restrained compensation structure.

This shifts the design away from maximum lag cancellation and toward smoother trend tracking with reduced tail behaviour.

The advanced controls then allow users to progressively move the model toward either:

[*]More responsiveness.
[*]More stability.

Trend determination
Trend direction is determined directly from the slope of the completed T3 Hull.

If:

[*]Current T3 Hull > Previous T3 Hull

the direction becomes bullish.

If:

[*]Current T3 Hull < Previous T3 Hull

the direction becomes bearish.

If the line is unchanged:

[*]The previous state persists.

The trend does not depend on price crossing the line.

It depends on whether the adaptive T3 Hull itself is rising or falling.

Long and short signals
A long signal occurs when direction changes into the bullish state.

A short signal occurs when direction changes into the bearish state.

The markers therefore identify:

[*]A change in slope regime.

They do not represent:

[*]Guaranteed entries.
[*]Price targets.
[*]Stop levels.

Because the signal is based on local slope, more responsive configurations will naturally produce more flips during sideways conditions.

Ribbon construction
The optional band is not a conventional upper-and-lower volatility channel.

The main line is the current T3 Hull.

The secondary ribbon reference is calculated from a smoothed version of the previous-bar T3 Hull:

[*]Ribbon Reference = WMA(T3 Hull[1], Band Smoothing)

The area between these two lines is filled with a gradient.

This creates visual separation between:

[*]The current adaptive trend estimate.
[*]A delayed and smoothed reference to its prior values.

The band therefore functions as a trend ribbon rather than a statistical volatility envelope.

Band Smoothing
Band Smoothing controls the WMA applied to the one-bar-offset Hull series.

Lower values:

[*]Keep the ribbon reference close to the main line.
[*]Produce a tighter band.
[*]Respond quickly to direction changes.

Higher values:

[*]Create a slower reference.
[*]Widen the visual separation during sustained movement.
[*]Create a smoother ribbon.

This input affects the visualization only.

It does not change:

[*]The T3 Hull calculation.
[*]Trend direction.
[*]Signals.

Trend Strength
The indicator also calculates a normalized trend-velocity measure for visualization.

Raw strength is based on:

[*]|Current T3 Hull - Previous T3 Hull| / ATR

and is multiplied by the Strength Sensitivity input.

The result is capped at 1 and then smoothed with an EMA.

This produces a normalized value from approximately:

[*]0 = very little line movement relative to ATR.
[*]1 = strong line movement relative to ATR.

This is a measure of trend-line velocity, not a statistical probability that the trend will continue.

Strength Smoothing
Strength Smoothing controls how quickly the visual strength estimate changes.

Lower values:

[*]React quickly to acceleration and deceleration.
[*]Create faster ribbon-intensity changes.

Higher values:

[*]Produce steadier strength visualization.
[*]Reduce flickering in the gradient.

It does not affect the underlying trend calculation.

Strength Sensitivity
Strength Sensitivity determines how quickly line velocity reaches the maximum normalized strength.

Higher values:

[*]Cause smaller ATR-normalized movement to appear strong.
[*]Increase gradient intensity more easily.

Lower values:

[*]Require greater movement before maximum visual intensity is reached.

Strength-Weighted Gradient
When disabled, the ribbon uses a fixed gradient transparency.

When enabled, gradient intensity changes with Trend Strength.

As the T3 Hull moves more quickly relative to ATR:

[*]The near portion of the ribbon becomes more visible.
[*]The broader gradient becomes stronger.

When trend velocity is weak:

[*]The ribbon becomes more subdued.

This is purely a visualization feature.

It does not alter:

[*]Direction.
[*]Signals.
[*]Smoothing.
[*]Tail damping.

Trend candles
The indicator can recolor the main chart candles according to the active T3 Hull slope state.

[*]Bullish trend = selected Long Color.
[*]Bearish trend = selected Short Color.

The candle colour describes the indicator regime, not the individual candle’s own open-to-close direction.

A bearish candle can therefore remain bullish-coloured while the T3 Hull is still rising.

Tail diagnostics
Several internal values are exposed in TradingView’s Data Window.

These provide insight into how the adaptive model is currently behaving.

Effective Hull Compensation
Shows the compensation actually being used after adaptive tail damping.

If adaptive damping is disabled:

[*]It remains equal to Hull Compensation.

If damping is active:

[*]It falls below the base value when curvature pressure increases.

This is useful for seeing when the indicator is automatically becoming more conservative.

Active T3 Volume Factor
Shows the T3 coefficient currently being used.

If Adaptive T3 Volume Factor is disabled:

[*]It remains equal to the base Volume Factor.

When enabled:

[*]It can decrease during high curvature.

Normalized Curvature
Shows the current curvature estimate after ATR normalization.

Values closer to 1 represent greater changes in fast-T3 velocity relative to recent range.

Trend Strength
Shows the smoothed normalized T3 Hull velocity as a percentage.

This is the same quantity used by the optional Strength-Weighted Gradient.

Tail Overshoot
The script also measures whether the final T3 Hull has extended beyond the fast T3 in the direction of the fast/slow separation.

An upper overshoot occurs when:

[*]Fast T3 is above Slow T3.
[*]Completed T3 Hull is above Fast T3.

A lower overshoot occurs when:

[*]Fast T3 is below Slow T3.
[*]Completed T3 Hull is below Fast T3.

When this happens, Tail Overshoot reports:

[*]|T3 Hull - Fast T3| / ATR

This expresses the size of the overshoot in ATR units.

A value of zero means the completed Hull is not currently beyond the fast T3 under that definition.

This diagnostic is particularly useful when tuning:

[*]Hull Compensation.
[*]Damping Strength.
[*]Fast Length Ratio.
[*]Adaptive VF.
[*]Final Smoothing.
[*]Generalization.

How to interpret the indicator

Rising T3 Hull
A rising line indicates a bullish trend state.

The model’s completed combination of T3 smoothing, Hull compensation and any active damping controls is moving upward.

Falling T3 Hull
A falling line indicates a bearish trend state.

Smooth persistent slope
A stable slope with few direction changes generally indicates a cleaner trend environment for this style of filter.

Frequent colour changes
Rapid bullish/bearish transitions generally indicate:

[*]Sideways price action.
[*]A very responsive configuration.
[*]Insufficient smoothing for the current market.

High normalized curvature
High curvature means the fast T3’s velocity is changing rapidly relative to ATR.

If adaptive controls are enabled, this is where:

[*]Hull compensation may decrease.
[*]T3 Volume Factor may decrease.

High tail overshoot
A larger Tail Overshoot value indicates the completed Hull has moved materially beyond the fast T3.

If the objective is a less tail-heavy line, possible adjustments include:

[*]Reduce Hull Compensation.
[*]Increase Final Smoothing.
[*]Increase Fast Length Ratio.
[*]Increase Damping Strength.
[*]Enable Adaptive T3 Volume Factor.
[*]Reduce or disable Generalization.
[*]Enable the Velocity Limiter.

How to use the indicator

1. Trend regime filter
The most direct use is as a slope-based regime filter:

[*]Rising T3 Hull = bullish trend state.
[*]Falling T3 Hull = bearish trend state.

This can be combined with independent entry logic.

2. Trend transition signals
Long and short markers identify when the adaptive line changes slope direction.

These can be used as:

[*]Regime-change alerts.
[*]Confirmation for another setup.
[*]Potential trailing-exit conditions.

They are not standalone guarantees of a sustained reversal.

3. Pullback reference
During a persistent trend, the T3 Hull can act as a smoothed directional reference.

Price returning toward the line while the line continues to slope in the original direction may represent a pullback within the existing regime.

4. Ribbon expansion
The distance between the current T3 Hull and its delayed WMA reference can visually highlight persistent movement.

A stronger ribbon separation can occur when the current adaptive trend estimate is moving away from its delayed historical reference.

5. Tail tuning
The Data Window diagnostics allow the indicator to be treated as a filter-design tool.

Users can observe:

[*]When compensation is being damped.
[*]How strongly curvature is elevated.
[*]Whether the completed line is overshooting.
[*]How the active T3 coefficient changes.

This can make parameter changes easier to understand than tuning solely by appearance.

Suggested tuning approaches

Smooth / reduced-tail configuration
For a calmer trend line:

[*]Use lower Hull Compensation.
[*]Use a larger Fast Length Ratio.
[*]Increase Final Smoothing.
[*]Enable Adaptive Tail Damping.
[*]Use moderate or higher Damping Strength.
[*]Leave Generalization disabled.

If strong shocks still create large movements:

[*]Enable the Velocity Limiter.

Responsive configuration
For faster behaviour:

[*]Reduce Fast Length Ratio toward the traditional half-length relationship.
[*]Increase Hull Compensation.
[*]Reduce Final Smoothing.
[*]Reduce the Hull Smoothing Exponent.
[*]Use a more aggressive T3 Volume Factor.

These changes generally increase overshoot risk.

Adaptive configuration
For responsiveness in normal conditions with additional protection near turns:

[*]Use moderate Hull Compensation.
[*]Enable Adaptive Tail Damping.
[*]Enable Asymmetric Turn Damping.
[*]Optionally enable Adaptive T3 Volume Factor.

This allows stronger compensation during smooth directional movement while automatically reducing it when the line begins to decelerate or turn.

Maximum tail-control configuration
For very aggressive tail suppression:

[*]Low Hull Compensation.
[*]Higher Final Smoothing.
[*]Adaptive Tail Damping enabled.
[*]Higher Damping Strength.
[*]Adaptive T3 Volume Factor enabled.
[*]Generalization disabled.
[*]Velocity Limiter enabled.

This can create a very stable line, but the cost is additional lag.

How this differs from a standard Hull Moving Average
A conventional HMA normally uses:

[*]WMA at half length.
[*]WMA at full length.
[*]2 × Fast - Slow lag compensation.
[*]Final WMA around sqrt(Length).

Adaptive T3 Hull changes every major part of that architecture:

[*]T3 replaces WMA.
[*]Fast Length Ratio is configurable.
[*]Hull Compensation is configurable.
[*]The final smoothing exponent is configurable.
[*]Final smoothing has an additional multiplier.
[*]Compensation can adapt to curvature.
[*]T3 behaviour can adapt to curvature.
[*]Final movement can be ATR-limited.
[*]An additional generalized compensation stage can be enabled.

It is therefore better understood as a generalized adaptive Hull framework than as a conventional HMA with a different smoothing length.

How this differs from a normal T3
A standard T3 produces one smoothed price estimate from repeated EMA stages and a fixed Volume Factor.

Adaptive T3 Hull uses multiple T3 calculations in a Hull-style structure:

[*]Fast T3.
[*]Slow T3.
[*]Compensated fast-slow projection.
[*]Final T3 smoothing.

It can also dynamically alter the T3 factor according to curvature.

The T3 is therefore a building block inside the larger trend model.

How this differs from simply smoothing an HMA
Applying an additional moving average to an HMA can reduce its tails, but it also adds lag after the overshoot has already occurred.

Adaptive T3 Hull attacks the problem at several earlier stages.

It can:

[*]Reduce the fast-slow separation.
[*]Reduce compensation itself.
[*]Reduce compensation specifically around sharp turns.
[*]Reduce the T3 factor during curvature.
[*]Change the final Hull smoothing geometry.
[*]Limit extreme final movement.

This provides more control than applying one additional smoothing layer to a completed HMA.

Parameter interaction
Many settings interact strongly.

Fast Ratio + Hull Compensation
A low Fast Ratio creates greater separation between fast and slow legs.

Combining that with high Hull Compensation can produce aggressive extrapolation.

Hull Compensation + Adaptive Damping
Hull Compensation defines the maximum starting compensation.

Adaptive damping determines how much of it survives during curvature.

T3 Volume Factor + Hull Compensation
Both can contribute to lag reduction.

High values in both stages may amplify overshoot.

Final Smoothing + Generalization
Final Smoothing adds lag and stability.

Generalization removes some of that lag again.

Using both allows the user to create a smooth base and then selectively reintroduce responsiveness.

Adaptive VF + Adaptive Hull Damping
Both respond to curvature but at different stages.

Enabling both can create strong protection around turns.

Velocity Limiter + all other controls
The Velocity Limiter is applied near the end of the pipeline.

It can therefore override an aggressive target generated by the preceding calculations.

Input guide

Source
Price series used by the complete indicator.

Hull Length
Primary calculation horizon.

T3 Volume Factor
Controls the internal T3 coefficient structure. It does not use trading volume.

Hull Compensation
Controls how much of the fast-minus-slow T3 separation is added to the fast T3.

Final Smoothing
Multiplies the final Hull smoothing length.

Adaptive Tail Damping
Reduces Hull Compensation during high curvature.

Damping Strength
Controls the amount of compensation reduction.

Damping Normalization
ATR horizon used to normalize curvature.

Fast Length Ratio
Controls the fast T3 length relative to the main Hull Length.

Hull Smoothing Exponent
Controls the power-law relationship used to derive the final smoothing length.

Asymmetric Turn Damping
Restricts curvature damping primarily to deceleration and turning behaviour.

Adaptive T3 Volume Factor
Reduces the T3 coefficient during high curvature.

VF Damping Strength
Controls how strongly curvature reduces the active T3 factor.

Minimum VF
Limits how far the adaptive T3 factor can be reduced.

Velocity Limiter
Caps final one-bar T3 Hull movement using ATR.

Max ATR / Bar
Defines the maximum movement allowed by the Velocity Limiter.

Generalize Final Hull
Enables an additional lag-compensation stage after the main T3 Hull.

Generalization
Controls the strength of that final compensation.

Strength-Weighted Gradient
Allows ribbon intensity to vary with normalized T3 Hull velocity.

Strength Smoothing
Smooths the visual trend-strength measure.

Sensitivity
Controls how quickly ATR-normalized movement reaches maximum visual strength.

Band Smoothing
Controls the delayed WMA reference used to build the ribbon.

Strengths

[*]Combines T3 smoothing with a generalized Hull framework.
[*]Directly exposes Hull lag compensation as a user control.
[*]Provides multiple independent methods for reducing oscillating tails.
[*]Uses ATR-normalized curvature for adaptive behaviour.
[*]Can distinguish general curvature from decelerating/turning curvature.
[*]Can adapt the T3 coefficient as well as Hull compensation.
[*]Allows the standard Hull square-root smoothing relationship to be generalized.
[*]Includes an optional ATR-based velocity limiter.
[*]Provides optional final lag compensation for advanced tuning.
[*]Includes real-time tail and curvature diagnostics.
[*]Provides trend-strength-reactive visualization without altering signals.

Limitations

[*]The indicator remains a reactive trend filter rather than a predictive model.
[*]Increasing lag compensation generally increases overshoot risk.
[*]Aggressive tail suppression generally increases lag.
[*]Slope-based signals can whipsaw in ranging markets.
[*]The large number of controls creates many interacting parameter combinations.
[*]Over-tuning parameters to one asset or historical period can reduce robustness elsewhere.
[*]The Velocity Limiter can delay response to genuine price shocks.
[*]Generalization can reintroduce overshoot that earlier damping stages removed.
[*]Trend Strength measures line velocity, not probability of continuation.
[*]Tail Overshoot is a diagnostic relative to the fast T3, not a trading signal.

Causality and real-time behaviour
The calculations use current and historical data without intentional future references.

The indicator can therefore be evaluated causally on completed bars.

However, on a live unfinished candle:

[*]The source can change.
[*]The T3 stages can change.
[*]Curvature can change.
[*]Adaptive compensation can change.
[*]The final slope can change.
[*]A long or short signal can appear or disappear before bar close.

Users requiring confirmed trend transitions should evaluate signals on completed candles.

Alerts
The indicator includes three alert conditions:

[*]T3 Hull Long: the completed T3 Hull changes into a rising trend state.
[*]T3 Hull Short: the completed T3 Hull changes into a falling trend state.
[*]T3 Hull Signal: either directional transition occurs.

Summary
Adaptive T3 Hull is a generalized trend smoother built around the idea that Hull-style lag compensation does not need to be fixed.

The model begins with fast and slow T3 smoothers rather than traditional WMAs. Their difference is used to compensate the fast T3 for lag, but the amount of compensation is directly configurable.

This alone allows the user to move continuously between:

[*]A restrained fast T3.
[*]A partially compensated Hull structure.
[*]A conventional 2×fast-minus-slow construction.
[*]More aggressive extrapolation.

The final smoothing stage is also generalized. Instead of forcing the conventional square-root Hull relationship, the user can control both the smoothing exponent and a separate multiplier.

The adaptive systems then focus specifically on the behaviour that often makes Hull-style smoothers difficult to tune: oscillating tails around sharp turns.

The script measures changes in fast-T3 velocity, normalizes that curvature using ATR, and can use the result to:

[*]Reduce Hull compensation.
[*]Reduce the T3 Volume Factor.
[*]Apply damping only around deceleration and turns.

An optional velocity limiter provides a final ATR-based cap on extreme one-bar movement, while an optional generalized compensation stage can reintroduce controlled responsiveness after the main smoothing process.

The final line determines trend through its slope, while a delayed WMA reference forms the optional ribbon. Ribbon intensity can also respond to normalized trend velocity.

Adaptive T3 Hull is therefore designed less as one fixed moving-average formula and more as a configurable filter architecture for exploring the trade-off between lag, smoothness, responsiveness and overshoot.

Its default configuration intentionally favors a less tail-heavy response than a conventional Hull construction, while the advanced controls allow users to move the model toward either greater responsiveness or stronger damping depending on the behaviour they want from the trend filter.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

import TradingView/ta/12 as ta

//@version=6
indicator("Adaptive T3 Hull [BackQuant]", overlay = true)

// Constants
const string calc = "Calculation Settings"
const string tail = "Tail Control"
const string adv  = "Advanced Controls"
const string plt  = "Plotting Settings"

const color GREEN = #00ff00
const color RED   = #ff0000

// User Inputs
float src = input.source(close, "Source", group = calc)
int len = input.int(28, "Hull Length", group = calc, inline = "1")
float vf = input.float(0.7, "T3 Volume Factor", step = 0.05, group = calc, inline = "1")

float hullComp = input.float(0.30, "Hull Compensation", minval = 0.0, maxval = 1.5, step = 0.05, group = tail, tooltip = "Controls Hull lag compensation. 1.0 is the standard 2× fast - slow construction. Lower values reduce overshoot and oscillating tails.")
float rootMult = input.float(1.20, "Final Smoothing", minval = 0.5, maxval = 3.0, step = 0.1, group = tail, tooltip = "Multiplier applied to the final Hull smoothing stage.")
bool adaptiveDamp = input.bool(true, "Adaptive Tail Damping", group = tail, tooltip = "Reduces Hull compensation during sharp curvature to suppress hooks and overshoot.")
float dampStrength = input.float(0.60, "Damping Strength", minval = 0.0, maxval = 1.0, step = 0.05, group = tail)
int dampLen = input.int(3, "Damping Normalization", minval = 2, maxval = 100, group = tail)

// Advanced Controls
float fastRatio = input.float(0.80, "Fast Length Ratio", minval = 0.20, maxval = 0.80, step = 0.05, group = adv, tooltip = "Controls the fast T3 length as a fraction of the main length. 0.50 reproduces the standard Hull half-length.")
float hullExponent = input.float(0.25, "Hull Smoothing Exponent", minval = 0.25, maxval = 1.00, step = 0.05, group = adv, tooltip = "Controls the final Hull smoothing length using Length^Exponent. 0.50 reproduces sqrt(length).")

bool asymmetricDamp = input.bool(false, "Asymmetric Turn Damping", group = adv, tooltip = "Only applies curvature damping when the fast T3 is decelerating or turning against its previous direction.")

bool adaptiveVF = input.bool(false, "Adaptive T3 Volume Factor", group = adv, tooltip = "Reduces the T3 volume factor around sharp curvature to further suppress overshoot.")
float vfDamp = input.float(0.25, "VF Damping Strength", minval = 0.0, maxval = 1.0, step = 0.05, group = adv, inline = "vf")
float minVF = input.float(0.20, "Minimum VF", minval = 0.0, maxval = 1.0, step = 0.05, group = adv, inline = "vf")

bool velocityDamp = input.bool(false, "Velocity Limiter", group = adv, tooltip = "Limits extreme single-bar movement of the completed T3 Hull using ATR.")
float velocityLimit = input.float(0.35, "Max ATR / Bar", minval = 0.05, maxval = 2.0, step = 0.05, group = adv)

bool generalizeHull = input.bool(false, "Generalize Final Hull", group = adv, tooltip = "Applies a final lag-compensation stage to the completed T3 Hull.")
float genFactor = input.float(0.15, "Generalization", minval = 0.0, maxval = 1.0, step = 0.05, group = adv)

bool strengthGradient = input.bool(false, "Strength-Weighted Gradient", group = adv, tooltip = "Makes ribbon intensity respond to normalized trend velocity.")
int strengthLen = input.int(10, "Strength Smoothing", minval = 1, maxval = 100, group = adv, inline = "str")
float strengthSensitivity = input.float(8.0, "Sensitivity", minval = 1.0, maxval = 30.0, step = 0.5, group = adv, inline = "str")

// Plotting
bool showband = input.bool(true, "Plot as Band?", group = plt)
int bandSmooth = input.int(10, "Band Smoothing", minval = 1, maxval = 50, group = plt)
int width = input.int(2, "Line Width", minval = 1, maxval = 6, group = plt)
bool showCandles = input.bool(true, "Show Trend Candles?", group = plt)
bool showsig = input.bool(true, "Show Signals?", group = plt)
color longcol = input.color(GREEN, "Long Color", group = plt, inline = "cols")
color shortcol = input.color(RED, "Short Color", group = plt, inline = "cols")

// Dynamic T3
t3Dynamic(src, len, factor) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    e3 = ta.ema(e2, len)
    e4 = ta.ema(e3, len)
    e5 = ta.ema(e4, len)
    e6 = ta.ema(e5, len)
    c1 = -factor * factor * factor
    c2 = 3.0 * factor * factor + 3.0 * factor * factor * factor
    c3 = -6.0 * factor * factor - 3.0 * factor - 3.0 * factor * factor * factor
    c4 = 1.0 + 3.0 * factor + 3.0 * factor * factor + factor * factor * factor
    c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3

// Hull Lengths
int fastLen = math.max(1, int(math.round(len * fastRatio)))
int rootLen = math.max(1, int(math.round(math.pow(len, hullExponent) * rootMult)))

// Base T3
float baseFastT3 = ta.t3(src, fastLen, vf)
float baseSlowT3 = ta.t3(src, len, vf)

// Base Curvature
float baseVelocity = baseFastT3 - baseFastT3[1]
float baseCurvature = math.abs(baseVelocity - baseVelocity[1])
float atr = ta.atr(dampLen)
float baseCurvatureNorm = atr > 0 ? math.min(baseCurvature / atr, 1.0) : 0.0

// Adaptive T3 Volume Factor
float vfFloor = math.min(vf, minVF)
float activeVF = adaptiveVF ? math.max(vfFloor, vf * (1.0 - baseCurvatureNorm * vfDamp)) : vf

// Active T3 Legs
float fastT3 = adaptiveVF ? t3Dynamic(src, fastLen, activeVF) : baseFastT3
float slowT3 = adaptiveVF ? t3Dynamic(src, len, activeVF) : baseSlowT3

// Tail Control
float velocity = fastT3 - fastT3[1]
float prevVelocity = fastT3[1] - fastT3[2]
float curvature = math.abs(velocity - prevVelocity)
float curvatureNorm = atr > 0 ? math.min(curvature / atr, 1.0) : 0.0

bool opposingTurn = prevVelocity > 0 ? velocity < prevVelocity : prevVelocity < 0 ? velocity > prevVelocity : false
float dampPressure = asymmetricDamp ? (opposingTurn ? curvatureNorm : 0.0) : curvatureNorm
float effectiveComp = adaptiveDamp ? hullComp * (1.0 - dampPressure * dampStrength) : hullComp

// T3 Hull
float hullRaw = fastT3 + effectiveComp * (fastT3 - slowT3)
float hullBase = adaptiveVF ? t3Dynamic(hullRaw, rootLen, activeVF) : ta.t3(hullRaw, rootLen, vf)

// Final Generalization
float hullSecond = generalizeHull ? (adaptiveVF ? t3Dynamic(hullBase, rootLen, activeVF) : ta.t3(hullBase, rootLen, vf)) : hullBase
float hullTarget = generalizeHull ? hullBase + genFactor * (hullBase - hullSecond) : hullBase

// Velocity Limiter
var float t3Hull = na

if velocityDamp and not na(t3Hull[1]) and atr > 0
    float delta = hullTarget - t3Hull[1]
    float maxStep = atr * velocityLimit
    float limitedDelta = math.max(-maxStep, math.min(maxStep, delta))
    t3Hull := t3Hull[1] + limitedDelta
else
    t3Hull := hullTarget

// Ribbon
float onebar_off = ta.wma(t3Hull[1], bandSmooth)

// Trend
var int direction = 0
direction := t3Hull > t3Hull[1] ? 1 : t3Hull < t3Hull[1] ? -1 : direction

bool longSignal = direction == 1 and direction[1] != 1
bool shortSignal = direction == -1 and direction[1] != -1
color trend = direction == 1 ? longcol : shortcol

// Trend Strength
float rawStrength = atr > 0 ? math.min(math.abs(t3Hull - t3Hull[1]) / atr * strengthSensitivity, 1.0) : 0.0
float trendStrength = ta.ema(rawStrength, strengthLen)

int nearAlpha = strengthGradient ? int(math.round(55.0 - trendStrength * 50.0)) : 15
int farAlpha = strengthGradient ? int(math.round(95.0 - trendStrength * 15.0)) : 85

// Tail Diagnostics
bool upperOvershoot = fastT3 > slowT3 and t3Hull > fastT3
bool lowerOvershoot = fastT3 < slowT3 and t3Hull < fastT3
float tailDistance = atr > 0 and (upperOvershoot or lowerOvershoot) ? math.abs(t3Hull - fastT3) / atr : 0.0

// Plotting
v1 = plot(t3Hull, "T3 Hull", color = trend, linewidth = width)
v2 = plot(showband ? onebar_off : na, "1 Bar Offset", color = color.new(trend, 100), linewidth = 1)

fill(
     v2, v1,
     t3Hull > onebar_off ? t3Hull : onebar_off,
     t3Hull > onebar_off ? onebar_off : t3Hull,
     t3Hull > onebar_off ? color.new(trend, nearAlpha) : color.new(trend, farAlpha),
     t3Hull > onebar_off ? color.new(trend, farAlpha) : color.new(trend, nearAlpha),
     title = "Trend Gradient")

plotcandle(open, high, low, close, "Trend Candles", trend, trend, true, bordercolor = trend, display = showCandles ? display.all : display.none)

plotshape(longSignal, title = "Long", text = "𝕃", style = shape.triangleup, location = location.belowbar, color = trend, textcolor = trend, size = size.tiny, display = showsig ? display.all : display.none)
plotshape(shortSignal, title = "Short", text = "𝕊", style = shape.triangledown, location = location.abovebar, color = trend, textcolor = trend, size = size.tiny, display = showsig ? display.all : display.none)

// Data Window
plot(effectiveComp, "Effective Hull Compensation", display = display.data_window, editable = false)
plot(activeVF, "Active T3 Volume Factor", display = display.data_window, editable = false)
plot(curvatureNorm, "Normalized Curvature", display = display.data_window, editable = false)
plot(trendStrength * 100.0, "Trend Strength", display = display.data_window, editable = false)
plot(tailDistance, "Tail Overshoot (ATR)", display = display.data_window, editable = false)

// Alerts
alertcondition(longSignal, "T3 Hull Long", "T3 Hull Long {{exchange}}:{{ticker}}")
alertcondition(shortSignal, "T3 Hull Short", "T3 Hull Short {{exchange}}:{{ticker}}")
alertcondition(longSignal or shortSignal, "T3 Hull Signal", "T3 Hull Signal {{exchange}}:{{ticker}}")
````
