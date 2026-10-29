Calculation: Smoothed %K = stochastic %K, smoothed by two successive exponential moving averages
Calculation: %D = simple moving average of smoothed %K, using a shorter lookback than the stochastic lookback
Calculation: Net pressure = 100 × EMA of [(close − low)/max(high − low, minimum tick) − (high − close)/max(high − low, minimum tick)] × (volume / its moving average)
Calculation: Bullish armed state = smoothed %K reached the extreme oversold threshold within the arming window
Calculation: Bearish armed state = smoothed %K reached the extreme overbought threshold within the arming window
Calculation: Bullish strength = count of: %K crosses above %D; bullish armed state or %K at/below the oversold threshold; %K rises on each of the last two bars; net pressure > 0
Calculation: Bearish strength = count of: %K crosses below %D; bearish armed state or %K at/above the overbought threshold; %K falls on each of the last two bars; net pressure < 0
Long: %K crosses above %D AND (bullish armed state, if explosion-first is required) AND bullish strength ≥ minimum strength AND (mid-range noise filter is disabled OR %K is outside the mid-range noise band) AND (MTF bias filter is disabled OR higher-timeframe %K > its midline AND higher-timeframe %K > higher-timeframe %D AND higher-timeframe net pressure > 0) AND (MTF slope filter is disabled OR higher-timeframe %K slope > 0 AND higher-timeframe %D slope ≥ 0)
Short: %K crosses below %D AND (bearish armed state, if explosion-first is required) AND bearish strength ≥ minimum strength AND (mid-range noise filter is disabled OR %K is outside the mid-range noise band) AND (MTF bias filter is disabled OR higher-timeframe %K < its midline AND higher-timeframe %K < higher-timeframe %D AND higher-timeframe net pressure < 0) AND (MTF slope filter is disabled OR higher-timeframe %K slope < 0 AND higher-timeframe %D slope ≤ 0)
Long: %K > its midline AND %K > %D AND net pressure > 0
Short: %K < its midline AND %K < %D AND net pressure < 0
Long: bullish armed state AND %K < its oversold threshold
Short: bearish armed state AND %K > its overbought threshold
Long: net pressure > 10 OR net pressure crosses above 0
Short: net pressure < −10 OR net pressure crosses below 0