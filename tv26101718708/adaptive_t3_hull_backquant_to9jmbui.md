# Adaptive T3 Hull [BackQuant]

- url: https://www.tradingview.com/script/to9JMbUI-Adaptive-T3-Hull-BackQuant/
- type: indicator
- pine_id: PUB;fc16431c5d044f97b847696942c09080
- version: 1.0

## Description

[b]Adaptive T3 Hull [BackQuant][/b]

[b]Overview[/b]
Adaptive T3 Hull is a configurable trend-following overlay that combines the lag-compensation structure of a Hull-style moving average with T3 smoothing and several optional mechanisms designed specifically to control overshoot, hooks and oscillating tails.

A conventional Hull construction gains responsiveness by comparing a faster and slower smoother, extrapolating their difference, and then smoothing the result again. This can produce a very responsive trend estimate, but the same lag compensation responsible for that responsiveness can also create exaggerated curvature around sharp reversals.

Adaptive T3 Hull makes that trade-off directly controllable.

The indicator replaces the traditional weighted-moving-average Hull stages with T3 smoothers and expands the basic Hull architecture with:
[list]
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
[/list]

The result is not intended to reproduce a standard HMA exactly. It is a generalized Hull-style framework in which the user can explicitly control the balance between responsiveness, smoothness and overshoot.

[b]Core idea[/b]
Most trend smoothers face the same fundamental compromise:

[list]
[*]More smoothing reduces noise but increases lag.
[*]More lag compensation improves responsiveness but can create overshoot.
[/list]

The Hull concept addresses lag by comparing a fast smoother with a slower smoother and projecting the difference forward.

A generalized form can be written as:

[list]
[*]Hull Raw = Fast + Compensation × (Fast - Slow)
[/list]

If Compensation is zero:

[list]
[*]Hull Raw = Fast
[/list]

No additional lag compensation is applied.

If Compensation is one:

[list]
[*]Hull Raw = 2 × Fast - Slow
[/list]

This reproduces the familiar compensation structure used in the standard Hull Moving Average.

Values between zero and one provide partial compensation.

Adaptive T3 Hull defaults to a substantially smaller compensation value. This is deliberate. It reduces the tendency for the projected line to extend beyond the fast smoother during sharp changes in direction.

The remaining responsiveness can then be controlled using the fast-length ratio, T3 characteristics and optional final generalization rather than relying entirely on aggressive Hull extrapolation.

[b]Processing chain[/b]
The complete indicator can be understood as the following sequence:

[list=1]
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
[/list]

Each stage affects a different part of the lag-versus-overshoot problem.

[b]T3 smoothing[/b]
The T3 is a multi-stage recursive smoother constructed from a sequence of exponential moving averages.

The script calculates six EMA stages:

[list]
[*]E1 = EMA(Source)
[*]E2 = EMA(E1)
[*]E3 = EMA(E2)
[*]E4 = EMA(E3)
[*]E5 = EMA(E4)
[*]E6 = EMA(E5)
[/list]

Those stages are then combined using coefficients derived from the T3 Volume Factor.

The final T3 has the general form:

[list]
[*]T3 = C1×E6 + C2×E5 + C3×E4 + C4×E3
[/list]

where C1 through C4 change with the Volume Factor.

This construction allows T3 smoothing to maintain substantial smoothness while using coefficient-based compensation to reduce some of the lag created by repeated EMA filtering.

[b]Important: T3 Volume Factor does not use trading volume[/b]
Despite its name, the T3 [b]Volume Factor[/b] is not calculated from market volume.

It is a coefficient controlling the internal T3 response.

Changing it does not incorporate:
[list]
[*]Exchange volume.
[*]Volume profile.
[*]OBV.
[*]Money flow.
[/list]

It changes how aggressively the internal EMA stages are combined.

Higher values generally increase compensation and responsiveness, but can also increase overshoot.

Lower values generally produce a more restrained and smoother response.

This relationship is particularly important in this indicator because Hull compensation and T3 compensation can interact.

An aggressive T3 followed by aggressive Hull extrapolation can produce substantially more tail behaviour than either technique alone.

[b]Why combine T3 and Hull logic?[/b]
Hull-style smoothing and T3 smoothing approach lag reduction differently.

The Hull architecture uses:
[list]
[*]A fast smoother.
[*]A slow smoother.
[*]The difference between them.
[*]A final smoothing stage.
[/list]

T3 uses:
[list]
[*]Multiple recursive EMA stages.
[*]A coefficient-controlled combination of those stages.
[/list]

Adaptive T3 Hull combines both ideas.

Instead of:

[list]
[*]Fast WMA.
[*]Slow WMA.
[*]Final WMA.
[/list]

the indicator uses:

[list]
[*]Fast T3.
[*]Slow T3.
[*]Compensated difference.
[*]Final T3.
[/list]

This produces a smoother underlying structure while retaining the ability to compensate for lag.

However, combining two lag-reduction mechanisms also makes overshoot control more important. Much of the indicator is therefore devoted to regulating that compensation dynamically.

[b]Hull Length[/b]
Hull Length establishes the main smoothing horizon.

It is used to derive:
[list]
[*]The slow T3 length.
[*]The fast T3 length.
[*]The final smoothing length.
[/list]

Lower values:
[list]
[*]React more quickly.
[*]Track shorter trend changes.
[*]Increase sensitivity to local curvature.
[*]Can generate more frequent directional flips.
[/list]

Higher values:
[list]
[*]Produce broader trend estimates.
[*]Reduce short-term variation.
[*]Increase response delay.
[*]Generally produce more persistent regimes.
[/list]

Unlike a standard HMA, the relationship between these three smoothing stages is not fixed.

[b]Fast Length Ratio[/b]
The fast T3 length is calculated as:

[list]
[*]Fast Length = Hull Length × Fast Length Ratio
[/list]

with the result rounded to a valid integer.

In a conventional Hull structure, the fast stage normally uses approximately half the main length.

Therefore:

[list]
[*]Fast Length Ratio = 0.50
[/list]

reproduces the familiar half-length relationship.

The default configuration uses a larger ratio, making the fast leg closer in length to the slow leg.

This matters because the difference:

[list]
[*]Fast T3 - Slow T3
[/list]

is the quantity used for lag compensation.

If the fast and slow stages are very different:
[list]
[*]Their separation can become larger.
[*]Hull compensation becomes stronger.
[*]The resulting line can react faster.
[*]Overshoot potential increases.
[/list]

If their lengths are closer:
[list]
[*]Their separation becomes smaller.
[*]The compensation term becomes more restrained.
[*]The final line generally becomes smoother.
[/list]

Fast Length Ratio is therefore another direct control over the aggressiveness of the Hull projection.

[b]Hull Compensation[/b]
Hull Compensation controls how much of the fast-versus-slow difference is added back to the fast T3.

The underlying formula is:

[list]
[*]Hull Raw = Fast T3 + Effective Compensation × (Fast T3 - Slow T3)
[/list]

Before adaptive damping is applied, Effective Compensation begins from the Hull Compensation input.

[b]Compensation = 0[/b]
The raw line becomes the fast T3 itself.

No Hull-style extrapolation occurs.

[b]Compensation = 1[/b]
The calculation becomes:

[list]
[*]2 × Fast T3 - Slow T3
[/list]

which matches the standard Hull lag-compensation form.

[b]Compensation between 0 and 1[/b]
Only part of the fast-slow separation is extrapolated.

This creates a middle ground between:
[list]
[*]Pure fast smoothing.
[*]Full Hull compensation.
[/list]

[b]Compensation above 1[/b]
The difference is extrapolated even more aggressively than a conventional Hull construction.

This can create a highly responsive line, but it also increases the likelihood of:
[list]
[*]Overshoot.
[*]Hooks.
[*]Large tails after sharp turns.
[/list]

The default is intentionally conservative relative to a standard Hull.

[b]What are Hull tails?[/b]
Hull-style moving averages can develop a distinctive oscillating or hooked appearance around strong reversals.

This occurs because the lag-compensation term is effectively extrapolating the difference between two smoothers.

Imagine the fast smoother accelerating upward while the slow smoother is still catching up.

The difference:

[list]
[*]Fast - Slow
[/list]

becomes positive.

Adding that difference to the fast smoother projects the result even further upward.

When price abruptly reverses, the fast smoother begins turning first while the slow smoother remains elevated.

The compensation term can then change rapidly and cause the completed Hull to:
[list]
[*]Extend beyond the fast line.
[*]Hook sharply.
[*]Reverse with excessive curvature.
[/list]

This is not necessarily an error in the Hull formula. It is a consequence of aggressive lag compensation.

Adaptive T3 Hull includes several independent tools for reducing this behaviour.

[b]Final Hull smoothing[/b]
After the fast and slow T3 legs are combined, the raw Hull is smoothed again.

The final smoothing length is calculated from:

[list]
[*]Length^Hull Smoothing Exponent × Final Smoothing Multiplier
[/list]

This generalizes the standard Hull square-root stage.

A conventional HMA normally uses approximately:

[list]
[*]sqrt(Length)
[/list]

which is equivalent to:

[list]
[*]Length^0.50
[/list]

before rounding.

[b]Hull Smoothing Exponent[/b]
The Hull Smoothing Exponent controls how strongly the final smoothing length grows as the main Hull Length increases.

[b]Exponent = 0.50[/b]
Reproduces the square-root relationship used in the conventional Hull construction.

[b]Exponent below 0.50[/b]
Produces a shorter final smoothing stage, particularly at larger main lengths.

This generally:
[list]
[*]Increases responsiveness.
[*]Allows more of the compensated movement through.
[/list]

[b]Exponent above 0.50[/b]
Creates a longer final smoothing stage.

This generally:
[list]
[*]Reduces local variation.
[*]Smooths more aggressively.
[*]Adds response delay.
[/list]

The script allows this relationship to be generalized instead of forcing the standard square-root rule.

[b]Final Smoothing[/b]
Final Smoothing applies an additional multiplier to the derived root length:

[list]
[*]Final Length = Length^Exponent × Root Multiplier
[/list]

This gives a second level of control over the final stage without changing the underlying power-law relationship.

Higher values:
[list]
[*]Increase final smoothing.
[*]Reduce local hooks.
[*]Slow the line.
[/list]

Lower values:
[list]
[*]Decrease final smoothing.
[*]Increase responsiveness.
[*]Allow more short-term curvature through.
[/list]

The Smoothing Exponent controls how smoothing scales with Hull Length.

The Final Smoothing multiplier controls the overall magnitude of that final stage.

[b]Curvature measurement[/b]
Adaptive tail damping requires a way to determine when the fast T3 is changing direction unusually quickly.

The indicator first calculates velocity:

[list]
[*]Velocity = Fast T3 - Previous Fast T3
[/list]

Previous velocity is:

[list]
[*]Previous Velocity = Previous Fast T3 - Fast T3 two bars ago
[/list]

Curvature is then approximated as the absolute change in velocity:

[list]
[*]Curvature = |Velocity - Previous Velocity|
[/list]

This is a discrete second-difference concept.

Velocity describes how quickly the smoother is moving.

Curvature describes how quickly that velocity itself is changing.

For example:
[list]
[*]A steadily rising line can have positive velocity but low curvature.
[*]A line suddenly flattening after a strong rise can have high curvature.
[*]A sharp reversal can produce very high curvature.
[/list]

This makes curvature particularly useful for detecting the conditions in which Hull overshoot tends to appear.

[b]ATR normalization[/b]
Raw curvature is not directly comparable across instruments.

A $10 curvature movement is enormous for one market and negligible for another.

The script therefore normalizes curvature using ATR:

[list]
[*]Normalized Curvature = Curvature / ATR
[/list]

The result is capped at 1.

This creates an adaptive pressure measure between approximately:
[list]
[*]0 = little curvature relative to recent range.
[*]1 = very large curvature relative to recent range.
[/list]

ATR is calculated using the Damping Normalization length.

This normalized curvature drives several optional adaptive mechanisms.

[b]Damping Normalization[/b]
Damping Normalization controls the ATR period used when converting curvature into a relative value.

Short values:
[list]
[*]Make the normalization respond rapidly to current volatility.
[*]Allow damping pressure to change quickly.
[/list]

Longer values:
[list]
[*]Create a more stable volatility baseline.
[*]Reduce rapid changes in normalized curvature.
[/list]

This setting does not smooth the final T3 Hull directly.

It changes how the adaptive systems interpret curvature.

[b]Adaptive Tail Damping[/b]
Adaptive Tail Damping dynamically reduces Hull Compensation when curvature becomes large.

The process can be summarized as:

[list]
[*]Effective Compensation = Hull Compensation × (1 - Damping Pressure × Damping Strength)
[/list]

When curvature is low:

[list]
[*]Damping Pressure approaches zero.
[*]Effective Compensation remains close to the selected Hull Compensation.
[/list]

When curvature becomes large:

[list]
[*]Damping Pressure increases.
[*]Effective Compensation is reduced.
[/list]

This means the indicator deliberately removes some of its lag compensation precisely when the fast T3 is bending sharply.

[b]Why reduce compensation during curvature?[/b]
Hull compensation is most useful when the fast and slow smoothers are moving consistently in the same directional structure.

During a smooth trend:
[list]
[*]The fast line leads the slow line.
[*]Their separation can be used to reduce lag.
[/list]

During a sharp turn:
[list]
[*]The fast line may reverse before the slow line.
[*]Their separation can become a poor estimate of useful forward compensation.
[*]Extrapolating the full difference can create overshoot.
[/list]

Adaptive damping therefore treats high curvature as a reason to trust the Hull extrapolation less.

[b]Damping Strength[/b]
Damping Strength determines how much curvature can reduce Hull compensation.

At zero:
[list]
[*]Curvature has no effect on compensation.
[/list]

As the value increases:
[list]
[*]High-curvature events remove progressively more compensation.
[*]The line becomes more restrained around sharp turns.
[/list]

At a Damping Strength of 1 and maximum normalized curvature, compensation can theoretically be reduced all the way toward zero.

This does not stop the underlying T3 from moving.

It removes the additional Hull extrapolation.

[b]Asymmetric Turn Damping[/b]
By default, curvature damping can apply whenever the fast T3 experiences significant curvature.

Asymmetric Turn Damping makes the condition more selective.

When enabled, damping pressure is only applied when the current velocity is moving against the previous directional pace.

Conceptually:

[list]
[*]A previously rising fast T3 is damped when its upward velocity begins weakening or reversing.
[*]A previously falling fast T3 is damped when its downward velocity begins weakening or reversing.
[/list]

This allows strong acceleration in the existing direction to retain more compensation while focusing the damping mechanism around deceleration and turning behaviour.

The purpose is to distinguish:

[list]
[*]Curvature caused by trend acceleration.
[*]Curvature caused by trend exhaustion or reversal.
[/list]

This can preserve responsiveness during strong continuation while still suppressing tails around turns.

[b]Adaptive T3 Volume Factor[/b]
Adaptive T3 Volume Factor provides a second curvature-sensitive damping mechanism.

Instead of changing the Hull compensation, this feature changes the internal T3 coefficient itself.

The active factor is approximately:

[list]
[*]Active VF = Base VF × (1 - Normalized Curvature × VF Damping Strength)
[/list]

subject to the configured minimum.

When curvature is low:
[list]
[*]Active VF remains near the selected T3 Volume Factor.
[/list]

When curvature rises:
[list]
[*]Active VF is reduced.
[*]The T3 becomes less aggressively compensated.
[/list]

This attacks overshoot earlier in the processing chain.

[b]Hull damping versus VF damping[/b]
The two mechanisms affect different stages.

[b]Adaptive Tail Damping[/b]
changes how much:

[list]
[*]Fast T3 - Slow T3
[/list]

is extrapolated.

[b]Adaptive T3 Volume Factor[/b]
changes how the T3 smoothers themselves are constructed.

Using both means curvature can reduce:
[list]
[*]The aggressiveness of each T3 leg.
[*]The aggressiveness of the Hull compensation between those legs.
[/list]

This can strongly suppress tails but may also reduce responsiveness.

The controls are therefore optional and independently adjustable.

[b]VF Damping Strength[/b]
VF Damping Strength controls how strongly curvature reduces the T3 Volume Factor.

Higher values:
[list]
[*]Produce larger reductions during sharp curvature.
[*]Increase smoothing around turns.
[*]Can reduce T3 overshoot more aggressively.
[/list]

Lower values:
[list]
[*]Keep Active VF closer to the base setting.
[*]Preserve more of the original T3 response.
[/list]

[b]Minimum VF[/b]
Minimum VF prevents the adaptive mechanism from reducing the active coefficient indefinitely.

It defines the lower bound used when Adaptive T3 Volume Factor is active.

This keeps the filter within a controlled response range during extreme curvature.

If the selected base Volume Factor is already below the requested minimum, the script does not force it upward above the base value.

[b]Generalize Final Hull[/b]
Generalize Final Hull adds another optional lag-compensation stage after the main T3 Hull has already been completed.

A second smoothed version of the completed Hull is calculated.

The final target then becomes:

[list]
[*]Hull Target = Hull Base + Generalization × (Hull Base - Second Hull)
[/list]

This uses the same broad idea as Hull compensation:

[list]
[*]Compare a faster estimate with a slower version.
[*]Add part of their difference back to the faster estimate.
[/list]

At zero Generalization:
[list]
[*]The stage has no effect.
[/list]

As Generalization increases:
[list]
[*]The final result becomes more responsive.
[*]Lag is reduced further.
[*]Overshoot potential increases.
[/list]

This option exists because the earlier tail controls allow the user to reduce aggressive compensation in the main Hull construction and, if desired, reintroduce a smaller amount of controlled responsiveness at the end.

[b]Generalization[/b]
Generalization controls the amount of final compensation.

Lower values create subtle lag reduction.

Higher values increasingly extrapolate the difference between the first and second completed Hull smoothers.

This feature should be considered one of the more aggressive responsiveness controls in the indicator.

If the objective is maximum tail suppression, it can be left disabled.

[b]Velocity Limiter[/b]
The Velocity Limiter addresses a different problem.

Curvature damping changes how the line is calculated.

The Velocity Limiter places a direct cap on how far the completed line is allowed to move in one bar.

The maximum permitted movement is:

[list]
[*]Maximum Step = ATR × Max ATR / Bar
[/list]

The desired change is:

[list]
[*]Delta = Hull Target - Previous T3 Hull
[/list]

That change is clamped between:

[list]
[*]-Maximum Step
[*]+Maximum Step
[/list]

The final T3 Hull then advances by only the permitted amount.

[b]Why use a velocity limiter?[/b]
Occasionally, a large price shock or a combination of aggressive settings can cause the completed Hull target to jump sharply.

The limiter acts as a final mechanical speed limit.

It can reduce:
[list]
[*]Single-bar jumps.
[*]Extreme hooks.
[*]Shock-driven movement.
[/list]

However, this comes with a clear trade-off.

If the market genuinely reprices very quickly, the limiter deliberately prevents the trend line from following the full move immediately.

It therefore introduces controlled lag.

[b]Max ATR / Bar[/b]
This setting determines the maximum permitted single-bar movement in ATR units.

For example:

[list]
[*]0.35 allows the completed line to move by no more than 0.35 ATR in one bar.
[/list]

Lower values:
[list]
[*]Create stronger movement suppression.
[*]Produce smoother transitions.
[*]Can significantly delay response to genuine breaks.
[/list]

Higher values:
[list]
[*]Interfere less often.
[*]Allow larger legitimate moves.
[/list]

The limiter is disabled by default because it is a strong constraint.

[b]How the tail controls work together[/b]
The script provides several different ways to reduce tail behaviour because overshoot can originate at multiple stages.

[b]Fast Length Ratio[/b]
Reduces fast-versus-slow separation.

[b]Hull Compensation[/b]
Directly controls extrapolation of that separation.

[b]Final Smoothing[/b]
Smooths the compensated output more heavily.

[b]Adaptive Tail Damping[/b]
Reduces Hull compensation during curvature.

[b]Asymmetric Turn Damping[/b]
Restricts that damping mainly to deceleration and turning behaviour.

[b]Adaptive T3 Volume Factor[/b]
Makes the underlying T3 calculations more conservative during curvature.

[b]Velocity Limiter[/b]
Caps the final single-bar movement.

[b]Generalization[/b]
Moves in the opposite direction by optionally adding some final lag compensation back.

These controls are intentionally modular.

A user does not need to enable all of them.

[b]Default design philosophy[/b]
The default settings intentionally do not reproduce a standard Hull Moving Average.

A standard Hull-like configuration would approximately use:
[list]
[*]Fast Length Ratio near 0.50.
[*]Hull Compensation near 1.00.
[*]Hull Smoothing Exponent near 0.50.
[*]Final Smoothing near 1.00.
[/list]

The default Adaptive T3 Hull uses a much more restrained compensation structure.

This shifts the design away from maximum lag cancellation and toward smoother trend tracking with reduced tail behaviour.

The advanced controls then allow users to progressively move the model toward either:
[list]
[*]More responsiveness.
[*]More stability.
[/list]

[b]Trend determination[/b]
Trend direction is determined directly from the slope of the completed T3 Hull.

If:

[list]
[*]Current T3 Hull > Previous T3 Hull
[/list]

the direction becomes bullish.

If:

[list]
[*]Current T3 Hull < Previous T3 Hull
[/list]

the direction becomes bearish.

If the line is unchanged:
[list]
[*]The previous state persists.
[/list]

The trend does not depend on price crossing the line.

It depends on whether the adaptive T3 Hull itself is rising or falling.

[b]Long and short signals[/b]
A long signal occurs when direction changes into the bullish state.

A short signal occurs when direction changes into the bearish state.

The markers therefore identify:
[list]
[*]A change in slope regime.
[/list]

They do not represent:
[list]
[*]Guaranteed entries.
[*]Price targets.
[*]Stop levels.
[/list]

Because the signal is based on local slope, more responsive configurations will naturally produce more flips during sideways conditions.

[b]Ribbon construction[/b]
The optional band is not a conventional upper-and-lower volatility channel.

The main line is the current T3 Hull.

The secondary ribbon reference is calculated from a smoothed version of the [b]previous-bar T3 Hull[/b]:

[list]
[*]Ribbon Reference = WMA(T3 Hull[1], Band Smoothing)
[/list]

The area between these two lines is filled with a gradient.

This creates visual separation between:
[list]
[*]The current adaptive trend estimate.
[*]A delayed and smoothed reference to its prior values.
[/list]

The band therefore functions as a trend ribbon rather than a statistical volatility envelope.

[b]Band Smoothing[/b]
Band Smoothing controls the WMA applied to the one-bar-offset Hull series.

Lower values:
[list]
[*]Keep the ribbon reference close to the main line.
[*]Produce a tighter band.
[*]Respond quickly to direction changes.
[/list]

Higher values:
[list]
[*]Create a slower reference.
[*]Widen the visual separation during sustained movement.
[*]Create a smoother ribbon.
[/list]

This input affects the visualization only.

It does not change:
[list]
[*]The T3 Hull calculation.
[*]Trend direction.
[*]Signals.
[/list]

[b]Trend Strength[/b]
The indicator also calculates a normalized trend-velocity measure for visualization.

Raw strength is based on:

[list]
[*]|Current T3 Hull - Previous T3 Hull| / ATR
[/list]

and is multiplied by the Strength Sensitivity input.

The result is capped at 1 and then smoothed with an EMA.

This produces a normalized value from approximately:
[list]
[*]0 = very little line movement relative to ATR.
[*]1 = strong line movement relative to ATR.
[/list]

This is a measure of [b]trend-line velocity[/b], not a statistical probability that the trend will continue.

[b]Strength Smoothing[/b]
Strength Smoothing controls how quickly the visual strength estimate changes.

Lower values:
[list]
[*]React quickly to acceleration and deceleration.
[*]Create faster ribbon-intensity changes.
[/list]

Higher values:
[list]
[*]Produce steadier strength visualization.
[*]Reduce flickering in the gradient.
[/list]

It does not affect the underlying trend calculation.

[b]Strength Sensitivity[/b]
Strength Sensitivity determines how quickly line velocity reaches the maximum normalized strength.

Higher values:
[list]
[*]Cause smaller ATR-normalized movement to appear strong.
[*]Increase gradient intensity more easily.
[/list]

Lower values:
[list]
[*]Require greater movement before maximum visual intensity is reached.
[/list]

[b]Strength-Weighted Gradient[/b]
When disabled, the ribbon uses a fixed gradient transparency.

When enabled, gradient intensity changes with Trend Strength.

As the T3 Hull moves more quickly relative to ATR:
[list]
[*]The near portion of the ribbon becomes more visible.
[*]The broader gradient becomes stronger.
[/list]

When trend velocity is weak:
[list]
[*]The ribbon becomes more subdued.
[/list]

This is purely a visualization feature.

It does not alter:
[list]
[*]Direction.
[*]Signals.
[*]Smoothing.
[*]Tail damping.
[/list]

[b]Trend candles[/b]
The indicator can recolor the main chart candles according to the active T3 Hull slope state.

[list]
[*]Bullish trend = selected Long Color.
[*]Bearish trend = selected Short Color.
[/list]

The candle colour describes the indicator regime, not the individual candle’s own open-to-close direction.

A bearish candle can therefore remain bullish-coloured while the T3 Hull is still rising.

[b]Tail diagnostics[/b]
Several internal values are exposed in TradingView’s Data Window.

These provide insight into how the adaptive model is currently behaving.

[b]Effective Hull Compensation[/b]
Shows the compensation actually being used after adaptive tail damping.

If adaptive damping is disabled:
[list]
[*]It remains equal to Hull Compensation.
[/list]

If damping is active:
[list]
[*]It falls below the base value when curvature pressure increases.
[/list]

This is useful for seeing when the indicator is automatically becoming more conservative.

[b]Active T3 Volume Factor[/b]
Shows the T3 coefficient currently being used.

If Adaptive T3 Volume Factor is disabled:
[list]
[*]It remains equal to the base Volume Factor.
[/list]

When enabled:
[list]
[*]It can decrease during high curvature.
[/list]

[b]Normalized Curvature[/b]
Shows the current curvature estimate after ATR normalization.

Values closer to 1 represent greater changes in fast-T3 velocity relative to recent range.

[b]Trend Strength[/b]
Shows the smoothed normalized T3 Hull velocity as a percentage.

This is the same quantity used by the optional Strength-Weighted Gradient.

[b]Tail Overshoot[/b]
The script also measures whether the final T3 Hull has extended beyond the fast T3 in the direction of the fast/slow separation.

An upper overshoot occurs when:
[list]
[*]Fast T3 is above Slow T3.
[*]Completed T3 Hull is above Fast T3.
[/list]

A lower overshoot occurs when:
[list]
[*]Fast T3 is below Slow T3.
[*]Completed T3 Hull is below Fast T3.
[/list]

When this happens, Tail Overshoot reports:

[list]
[*]|T3 Hull - Fast T3| / ATR
[/list]

This expresses the size of the overshoot in ATR units.

A value of zero means the completed Hull is not currently beyond the fast T3 under that definition.

This diagnostic is particularly useful when tuning:
[list]
[*]Hull Compensation.
[*]Damping Strength.
[*]Fast Length Ratio.
[*]Adaptive VF.
[*]Final Smoothing.
[*]Generalization.
[/list]

[b]How to interpret the indicator[/b]

[b]Rising T3 Hull[/b]
A rising line indicates a bullish trend state.

The model’s completed combination of T3 smoothing, Hull compensation and any active damping controls is moving upward.

[b]Falling T3 Hull[/b]
A falling line indicates a bearish trend state.

[b]Smooth persistent slope[/b]
A stable slope with few direction changes generally indicates a cleaner trend environment for this style of filter.

[b]Frequent colour changes[/b]
Rapid bullish/bearish transitions generally indicate:
[list]
[*]Sideways price action.
[*]A very responsive configuration.
[*]Insufficient smoothing for the current market.
[/list]

[b]High normalized curvature[/b]
High curvature means the fast T3’s velocity is changing rapidly relative to ATR.

If adaptive controls are enabled, this is where:
[list]
[*]Hull compensation may decrease.
[*]T3 Volume Factor may decrease.
[/list]

[b]High tail overshoot[/b]
A larger Tail Overshoot value indicates the completed Hull has moved materially beyond the fast T3.

If the objective is a less tail-heavy line, possible adjustments include:
[list]
[*]Reduce Hull Compensation.
[*]Increase Final Smoothing.
[*]Increase Fast Length Ratio.
[*]Increase Damping Strength.
[*]Enable Adaptive T3 Volume Factor.
[*]Reduce or disable Generalization.
[*]Enable the Velocity Limiter.
[/list]

[b]How to use the indicator[/b]

[b]1. Trend regime filter[/b]
The most direct use is as a slope-based regime filter:
[list]
[*]Rising T3 Hull = bullish trend state.
[*]Falling T3 Hull = bearish trend state.
[/list]

This can be combined with independent entry logic.

[b]2. Trend transition signals[/b]
Long and short markers identify when the adaptive line changes slope direction.

These can be used as:
[list]
[*]Regime-change alerts.
[*]Confirmation for another setup.
[*]Potential trailing-exit conditions.
[/list]

They are not standalone guarantees of a sustained reversal.

[b]3. Pullback reference[/b]
During a persistent trend, the T3 Hull can act as a smoothed directional reference.

Price returning toward the line while the line continues to slope in the original direction may represent a pullback within the existing regime.

[b]4. Ribbon expansion[/b]
The distance between the current T3 Hull and its delayed WMA reference can visually highlight persistent movement.

A stronger ribbon separation can occur when the current adaptive trend estimate is moving away from its delayed historical reference.

[b]5. Tail tuning[/b]
The Data Window diagnostics allow the indicator to be treated as a filter-design tool.

Users can observe:
[list]
[*]When compensation is being damped.
[*]How strongly curvature is elevated.
[*]Whether the completed line is overshooting.
[*]How the active T3 coefficient changes.
[/list]

This can make parameter changes easier to understand than tuning solely by appearance.

[b]Suggested tuning approaches[/b]

[b]Smooth / reduced-tail configuration[/b]
For a calmer trend line:
[list]
[*]Use lower Hull Compensation.
[*]Use a larger Fast Length Ratio.
[*]Increase Final Smoothing.
[*]Enable Adaptive Tail Damping.
[*]Use moderate or higher Damping Strength.
[*]Leave Generalization disabled.
[/list]

If strong shocks still create large movements:
[list]
[*]Enable the Velocity Limiter.
[/list]

[b]Responsive configuration[/b]
For faster behaviour:
[list]
[*]Reduce Fast Length Ratio toward the traditional half-length relationship.
[*]Increase Hull Compensation.
[*]Reduce Final Smoothing.
[*]Reduce the Hull Smoothing Exponent.
[*]Use a more aggressive T3 Volume Factor.
[/list]

These changes generally increase overshoot risk.

[b]Adaptive configuration[/b]
For responsiveness in normal conditions with additional protection near turns:
[list]
[*]Use moderate Hull Compensation.
[*]Enable Adaptive Tail Damping.
[*]Enable Asymmetric Turn Damping.
[*]Optionally enable Adaptive T3 Volume Factor.
[/list]

This allows stronger compensation during smooth directional movement while automatically reducing it when the line begins to decelerate or turn.

[b]Maximum tail-control configuration[/b]
For very aggressive tail suppression:
[list]
[*]Low Hull Compensation.
[*]Higher Final Smoothing.
[*]Adaptive Tail Damping enabled.
[*]Higher Damping Strength.
[*]Adaptive T3 Volume Factor enabled.
[*]Generalization disabled.
[*]Velocity Limiter enabled.
[/list]

This can create a very stable line, but the cost is additional lag.

[b]How this differs from a standard Hull Moving Average[/b]
A conventional HMA normally uses:
[list]
[*]WMA at half length.
[*]WMA at full length.
[*]2 × Fast - Slow lag compensation.
[*]Final WMA around sqrt(Length).
[/list]

Adaptive T3 Hull changes every major part of that architecture:
[list]
[*]T3 replaces WMA.
[*]Fast Length Ratio is configurable.
[*]Hull Compensation is configurable.
[*]The final smoothing exponent is configurable.
[*]Final smoothing has an additional multiplier.
[*]Compensation can adapt to curvature.
[*]T3 behaviour can adapt to curvature.
[*]Final movement can be ATR-limited.
[*]An additional generalized compensation stage can be enabled.
[/list]

It is therefore better understood as a [b]generalized adaptive Hull framework[/b] than as a conventional HMA with a different smoothing length.

[b]How this differs from a normal T3[/b]
A standard T3 produces one smoothed price estimate from repeated EMA stages and a fixed Volume Factor.

Adaptive T3 Hull uses multiple T3 calculations in a Hull-style structure:
[list]
[*]Fast T3.
[*]Slow T3.
[*]Compensated fast-slow projection.
[*]Final T3 smoothing.
[/list]

It can also dynamically alter the T3 factor according to curvature.

The T3 is therefore a building block inside the larger trend model.

[b]How this differs from simply smoothing an HMA[/b]
Applying an additional moving average to an HMA can reduce its tails, but it also adds lag after the overshoot has already occurred.

Adaptive T3 Hull attacks the problem at several earlier stages.

It can:
[list]
[*]Reduce the fast-slow separation.
[*]Reduce compensation itself.
[*]Reduce compensation specifically around sharp turns.
[*]Reduce the T3 factor during curvature.
[*]Change the final Hull smoothing geometry.
[*]Limit extreme final movement.
[/list]

This provides more control than applying one additional smoothing layer to a completed HMA.

[b]Parameter interaction[/b]
Many settings interact strongly.

[b]Fast Ratio + Hull Compensation[/b]
A low Fast Ratio creates greater separation between fast and slow legs.

Combining that with high Hull Compensation can produce aggressive extrapolation.

[b]Hull Compensation + Adaptive Damping[/b]
Hull Compensation defines the maximum starting compensation.

Adaptive damping determines how much of it survives during curvature.

[b]T3 Volume Factor + Hull Compensation[/b]
Both can contribute to lag reduction.

High values in both stages may amplify overshoot.

[b]Final Smoothing + Generalization[/b]
Final Smoothing adds lag and stability.

Generalization removes some of that lag again.

Using both allows the user to create a smooth base and then selectively reintroduce responsiveness.

[b]Adaptive VF + Adaptive Hull Damping[/b]
Both respond to curvature but at different stages.

Enabling both can create strong protection around turns.

[b]Velocity Limiter + all other controls[/b]
The Velocity Limiter is applied near the end of the pipeline.

It can therefore override an aggressive target generated by the preceding calculations.

[b]Input guide[/b]

[b]Source[/b]
Price series used by the complete indicator.

[b]Hull Length[/b]
Primary calculation horizon.

[b]T3 Volume Factor[/b]
Controls the internal T3 coefficient structure. It does not use trading volume.

[b]Hull Compensation[/b]
Controls how much of the fast-minus-slow T3 separation is added to the fast T3.

[b]Final Smoothing[/b]
Multiplies the final Hull smoothing length.

[b]Adaptive Tail Damping[/b]
Reduces Hull Compensation during high curvature.

[b]Damping Strength[/b]
Controls the amount of compensation reduction.

[b]Damping Normalization[/b]
ATR horizon used to normalize curvature.

[b]Fast Length Ratio[/b]
Controls the fast T3 length relative to the main Hull Length.

[b]Hull Smoothing Exponent[/b]
Controls the power-law relationship used to derive the final smoothing length.

[b]Asymmetric Turn Damping[/b]
Restricts curvature damping primarily to deceleration and turning behaviour.

[b]Adaptive T3 Volume Factor[/b]
Reduces the T3 coefficient during high curvature.

[b]VF Damping Strength[/b]
Controls how strongly curvature reduces the active T3 factor.

[b]Minimum VF[/b]
Limits how far the adaptive T3 factor can be reduced.

[b]Velocity Limiter[/b]
Caps final one-bar T3 Hull movement using ATR.

[b]Max ATR / Bar[/b]
Defines the maximum movement allowed by the Velocity Limiter.

[b]Generalize Final Hull[/b]
Enables an additional lag-compensation stage after the main T3 Hull.

[b]Generalization[/b]
Controls the strength of that final compensation.

[b]Strength-Weighted Gradient[/b]
Allows ribbon intensity to vary with normalized T3 Hull velocity.

[b]Strength Smoothing[/b]
Smooths the visual trend-strength measure.

[b]Sensitivity[/b]
Controls how quickly ATR-normalized movement reaches maximum visual strength.

[b]Band Smoothing[/b]
Controls the delayed WMA reference used to build the ribbon.

[b]Strengths[/b]
[list]
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
[/list]

[b]Limitations[/b]
[list]
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
[/list]

[b]Causality and real-time behaviour[/b]
The calculations use current and historical data without intentional future references.

The indicator can therefore be evaluated causally on completed bars.

However, on a live unfinished candle:
[list]
[*]The source can change.
[*]The T3 stages can change.
[*]Curvature can change.
[*]Adaptive compensation can change.
[*]The final slope can change.
[*]A long or short signal can appear or disappear before bar close.
[/list]

Users requiring confirmed trend transitions should evaluate signals on completed candles.

[b]Alerts[/b]
The indicator includes three alert conditions:
[list]
[*][b]T3 Hull Long:[/b] the completed T3 Hull changes into a rising trend state.
[*][b]T3 Hull Short:[/b] the completed T3 Hull changes into a falling trend state.
[*][b]T3 Hull Signal:[/b] either directional transition occurs.
[/list]

[b]Summary[/b]
Adaptive T3 Hull is a generalized trend smoother built around the idea that Hull-style lag compensation does not need to be fixed.

The model begins with fast and slow T3 smoothers rather than traditional WMAs. Their difference is used to compensate the fast T3 for lag, but the amount of compensation is directly configurable.

This alone allows the user to move continuously between:
[list]
[*]A restrained fast T3.
[*]A partially compensated Hull structure.
[*]A conventional 2×fast-minus-slow construction.
[*]More aggressive extrapolation.
[/list]

The final smoothing stage is also generalized. Instead of forcing the conventional square-root Hull relationship, the user can control both the smoothing exponent and a separate multiplier.

The adaptive systems then focus specifically on the behaviour that often makes Hull-style smoothers difficult to tune: oscillating tails around sharp turns.

The script measures changes in fast-T3 velocity, normalizes that curvature using ATR, and can use the result to:
[list]
[*]Reduce Hull compensation.
[*]Reduce the T3 Volume Factor.
[*]Apply damping only around deceleration and turns.
[/list]

An optional velocity limiter provides a final ATR-based cap on extreme one-bar movement, while an optional generalized compensation stage can reintroduce controlled responsiveness after the main smoothing process.

The final line determines trend through its slope, while a delayed WMA reference forms the optional ribbon. Ribbon intensity can also respond to normalized trend velocity.

Adaptive T3 Hull is therefore designed less as one fixed moving-average formula and more as a configurable filter architecture for exploring the trade-off between [b]lag, smoothness, responsiveness and overshoot[/b].

Its default configuration intentionally favors a less tail-heavy response than a conventional Hull construction, while the advanced controls allow users to move the model toward either greater responsiveness or stronger damping depending on the behaviour they want from the trend filter.

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
