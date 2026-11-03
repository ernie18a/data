Calculation: Trend layer = +1 when close > shorter-lookback EMA > longer-lookback EMA and the linear-regression slope of close is positive; -1 when all inequalities are reversed; otherwise 0
Calculation: Momentum layer = +1 when close ROC > 0, RSI > 52, and efficiency ratio > 0.35; -1 when close ROC < 0, RSI < 48, and efficiency ratio > 0.35; otherwise 0
Calculation: Efficiency ratio = absolute net close change over its lookback divided by the sum of absolute close-to-close changes over that lookback
Calculation: Structure layer = +1 when (close - lowest low) / (highest high - lowest low) over its lookback > 0.62; -1 when this range position < 0.38; otherwise 0
Calculation: Volume layer = +1 when clamped volume z-score / 3 > 0.25 and the linear-regression slope of OBV is positive; -1 when clamped volume z-score / 3 < -0.25 and the OBV slope is negative; otherwise 0
Calculation: OBV = cumulative volume added when close rises, subtracted when close falls, and unchanged when close is unchanged
Calculation: Higher-timeframe score = average of ten biases from two higher timeframes, using the last completed bar of each: for each timeframe, trend bias is +1 when close > shorter-lookback EMA > longer-lookback EMA and close slope is positive, -1 for the reverse, otherwise 0; momentum bias is the sign of close ROC; volatility bias is +1 when ATR / its SMA > 1.08, -1 when < 0.92, otherwise 0; directional movement bias is the sign of +DI minus -DI; ADX bias is +1 when ADX exceeds the strong threshold, -1 when below the weak threshold, otherwise 0
Calculation: Volatility composite = average of ATR / its SMA and Garman-Klass realized volatility / its SMA, using the same volatility lookback for each measure
Calculation: Garman-Klass realized volatility = square root of the SMA of max(0, 0.5 × ln(high/low)^2 - (2 × ln(2) - 1) × ln(close/open)^2)
Calculation: Base direction = +1 when trend layer + momentum layer + structure layer + volume layer + higher-timeframe score >= 0; otherwise -1
Calculation: Volatility layer = 0.40 × base direction when volatility composite > 1.08; -0.25 × base direction when volatility composite < 0.92; otherwise 0
Calculation: Regime score = clamp(100 × (0.24 × trend layer + 0.18 × momentum layer + 0.14 × structure layer + 0.12 × volume layer + 0.12 × volatility layer + 0.20 × higher-timeframe score), -100, 100)
Long: Regime score >= soft bullish threshold
Short: Regime score <= soft bearish threshold