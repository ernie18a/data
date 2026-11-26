Long: VWMA(close, shorter lookback) > VWMA(close, medium lookback) > VWMA(close, longer lookback) AND RSI(close, lookback) < long threshold, with this condition changing from false to true
Short: VWMA(close, shorter lookback) < VWMA(close, medium lookback) < VWMA(close, longer lookback) AND RSI(close, lookback) > short threshold, with this condition changing from false to true
Exit: long, the long-entry signal occurred three bars ago
Exit: short, the short-entry signal occurred three bars ago