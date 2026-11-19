Calculation: volatility multiplier = automatic adjustment ? nz(EMA(ATR(volatility lookback) / SMA(ATR(volatility lookback), volatility lookback), smoothing lookback), fallback ratio) ^ volatility exponent : fixed multiplier
Calculation: short-term pivot lookback = max(minimum lookback, round((sensitivity offset − sensitivity) × volatility multiplier))
Calculation: medium-term pivot lookback = short-term pivot lookback × term scale
Calculation: long-term pivot lookback = medium-term pivot lookback × term scale
Calculation: KNN confidence = full-confidence score when the prior same-term, same-side pivot history has more than k points; otherwise fallback-confidence score; each history is capped at the history-limit parameter
Calculation: selected term = explicitly selected term, or the first enabled term in long-, medium-, short-term order when automatic selection is used; none if no term is selected
Calculation: latest selected-term pivot levels = the most recent confirmed pivot high and pivot low using the selected-term lookback, without KNN filtering
Calculation: selected-range position = (close − latest selected-term pivot low) / max(denominator floor, latest selected-term pivot high − latest selected-term pivot low)
Calculation: metadata cumulative delta = cumulative sum since the active metadata label was created, adding volume when close > open and subtracting volume otherwise
Long: close > the active, unbroken pivot-high level from any structure term, where the confirmed pivot's KNN confidence ≥ the confidence threshold
Short: close < the active, unbroken pivot-low level from any structure term, where the confirmed pivot's KNN confidence ≥ the confidence threshold
Long: both latest selected-term pivot levels exist AND close ≥ latest selected-term pivot low AND (close > latest selected-term pivot high OR selected-range position > midpoint)
Short: both latest selected-term pivot levels exist AND (close < latest selected-term pivot low OR (close ≥ latest selected-term pivot low AND close ≤ latest selected-term pivot high AND selected-range position < midpoint))
Long: an active selected-term metadata label exists AND its cumulative delta ≥ 0
Short: an active selected-term metadata label exists AND its cumulative delta < 0