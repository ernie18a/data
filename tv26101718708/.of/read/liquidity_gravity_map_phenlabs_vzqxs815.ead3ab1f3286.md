Calculation: Bar range = max(high - low, minimum price increment).
Calculation: Upper wick ratio = (high - max(open, close)) / bar range.
Calculation: Lower wick ratio = (min(open, close) - low) / bar range.
Long: A swing low is confirmed using equal numbers of bars before and after the pivot.
Long: Low < lowest low of the preceding lookback bars AND close > low + bar range × threshold AND lower wick ratio >= threshold.
Short: A swing high is confirmed using equal numbers of bars before and after the pivot.
Short: High > highest high of the preceding lookback bars AND close < high - bar range × threshold AND upper wick ratio >= threshold.