Calculation: Upper wick percentage = high > low ? (high - max(open, close)) / (high - low) * 100 : 0
Calculation: Lower wick percentage = high > low ? (min(open, close) - low) / (high - low) * 100 : 0
Long: close >= open AND (range coloring is disabled OR (upper wick percentage <= wick threshold AND lower wick percentage <= wick threshold))
Short: close < open AND (range coloring is disabled OR (upper wick percentage <= wick threshold AND lower wick percentage <= wick threshold))
Calculation: Bullish pullback pending = set when low < low[1]; reset at session start or when high > high[1] while pending
Calculation: Bearish pullback pending = set when high > high[1]; reset at session start or when low < low[1] while pending
Long: during the configured session, after the chart-history warm-up, bullish pullback pending AND high > high[1]
Short: during the configured session, after the chart-history warm-up, bearish pullback pending AND low < low[1]