Calculation: Fast EMA = EMA of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = EMA of close with a longer lookback than the fast EMA
Calculation: Higher-timeframe fast and slow EMAs = the corresponding EMAs of higher-timeframe closes, using the last completed higher-timeframe bar
Calculation: Bullish pin bar = lower wick >= 0.66 × (high − low) AND close > open
Calculation: Bearish pin bar = upper wick >= 0.66 × (high − low) AND close < open
Calculation: Bullish engulfing = close > open AND previous close < previous open AND close > previous open AND open < previous close
Calculation: Bearish engulfing = close < open AND previous close > previous open AND close < previous open AND open > previous close
Long: An unconsumed fast EMA crossover above the slow EMA has occurred since the latest opposite crossover AND fast EMA > slow EMA AND higher-timeframe fast EMA > higher-timeframe slow EMA AND datetime is within the configured session AND low <= fast EMA <= high AND (bullish pin bar OR bullish engulfing) AND low < previous low AND previous low = low two bars ago AND high > previous high
Short: An unconsumed fast EMA crossover below the slow EMA has occurred since the latest opposite crossover AND fast EMA < slow EMA AND higher-timeframe fast EMA < higher-timeframe slow EMA AND datetime is within the configured session AND low <= fast EMA <= high AND (bearish pin bar OR bearish engulfing) AND high > previous high AND previous high = high two bars ago AND low < previous low