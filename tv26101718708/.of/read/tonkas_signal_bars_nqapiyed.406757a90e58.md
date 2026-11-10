Calculation: Session high and low = highest high and lowest low of chart bars in the most recently completed configured session, retained until the next session completes.
Long: Low < low of the last completed daily bar AND close > that low.
Long: Low < session low AND close > session low.
Long: At least one of the preceding long conditions occurred within the configured lookback, including the current bar, and since the start of the current daily bar.
Short: High > high of the last completed daily bar AND close < that high.
Short: High > session high AND close < session high.
Short: At least one of the preceding short conditions occurred within the configured lookback, including the current bar, and since the start of the current daily bar.