Calculation: Swing pivots = confirmed pivot highs and lows using separate left and right lookbacks; retain alternating pivots only when the new pivot is at least ATR(ATR lookback) × swing-filter multiplier from the last pivot, and replace a same-side pivot only with a more extreme pivot.
Calculation: Structural trend(T) = chronological state over swing pivots: turn bullish when a pivot high exceeds the prior high while flat or the protected high while bearish; turn bearish symmetrically when a pivot low falls below the prior low or protected low; while bullish, each new higher high protects the preceding pivot low, and while bearish, each new lower low protects the preceding pivot high. Compute on T bars and sample the last completed T bar; on chart bars use the current state.
Calculation: Impulse score(leg) = the equal-weight mean of efficiency and displacement percentile, expressed as a percentage; efficiency = absolute leg movement divided by absolute close-to-close path between pivot-recognition bars, capped at its natural maximum; displacement percentile = the fraction of other stored legs with smaller absolute movement divided by mean ATR at the leg's pivot-recognition bars, using the midpoint rank when there are no other legs.
Calculation: Qualified impulse = a leg whose direction does not oppose a nonflat Structural trend at its ending pivot and whose Impulse score is at least the impulse-score threshold.
Calculation: Higher-timeframe bias = bullish when the count of positive Structural trends among valid configured T1, T2, and T3 exceeds the count of negative trends; bearish when the negative count exceeds the positive count; otherwise neutral.
Calculation: Trade direction = Higher-timeframe bias when nonneutral, otherwise chart Structural trend.
Calculation: Selected impulse = the latest Qualified impulse matching nonneutral Trade direction, or the latest Qualified impulse of either direction when Trade direction is neutral; none when nonneutral Trade direction has no matching Qualified impulse.
Calculation: Setup levels for selected impulse with origin O, endpoint E, range R = |E−O|, and direction D (+1 upward, −1 downward): zone bounds span E−D×R×lower-retracement parameter through E−D×R×upper-retracement parameter; TP1 = E+D×R×TP1-extension parameter; stop = O−D×ATR(chart bars, ATR lookback)×stop-ATR-offset parameter.
Calculation: Setup unresolved = neither stop nor TP1 has been touched since the selected impulse's endpoint anchor; the first touch is latched until the anchor changes, with stop taking priority if both are touched on one bar.
Calculation: Normalized ADX strength(T) = ADX(high, low, close, ADX lookback, T, last completed bar) normalized between separate ADX floor and ceiling parameters and expressed as a percentage; compute on T bars and sample the last completed T bar.
Calculation: Higher-timeframe conviction = average Normalized ADX strength among valid T1, T2, and T3 whose Structural trend agrees with nonneutral Higher-timeframe bias.
Calculation: Low conviction = Higher-timeframe bias is nonneutral AND low-conviction threshold is greater than zero AND Higher-timeframe conviction is below that threshold.
Calculation: Price in zone = a selected setup exists AND close is between its zone bounds.
Long: Structural trend on chart bars > 0.
Long: Structural trend(T1, last completed bar) > 0 OR Structural trend(T2, last completed bar) > 0 OR Structural trend(T3, last completed bar) > 0.
Long: Higher-timeframe bias > 0.
Long: At least one valid configured higher timeframe exists AND every valid configured higher-timeframe Structural trend is > 0.
Long: Low conviction is false AND Higher-timeframe bias > 0.
Long: A Qualified impulse points upward.
Long: The Selected impulse points upward AND Setup unresolved.
Long: The Selected impulse points upward AND Price in zone AND Price in zone on the prior chart bar is false AND the current chart bar is confirmed.
Short: Structural trend on chart bars < 0.
Short: Structural trend(T1, last completed bar) < 0 OR Structural trend(T2, last completed bar) < 0 OR Structural trend(T3, last completed bar) < 0.
Short: Higher-timeframe bias < 0.
Short: At least one valid configured higher timeframe exists AND every valid configured higher-timeframe Structural trend is < 0.
Short: Low conviction is false AND Higher-timeframe bias < 0.
Short: A Qualified impulse points downward.
Short: The Selected impulse points downward AND Setup unresolved.
Short: The Selected impulse points downward AND Price in zone AND Price in zone on the prior chart bar is false AND the current chart bar is confirmed.
Exit: long, the selected upward setup is unresolved AND (low <= its stop OR high >= its TP1).
Exit: short, the selected downward setup is unresolved AND (high >= its stop OR low <= its TP1).