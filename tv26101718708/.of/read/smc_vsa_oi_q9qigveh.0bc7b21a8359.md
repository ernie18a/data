Calculation: target high/low = high/low of the most recently completed session; replace with the Asian session’s levels after it ends, then the London session’s levels after it ends, then the New York session’s levels after it ends. Reset to unavailable at the start of each Asian session. Session highs and lows use chart-timeframe bars.
Calculation: short-sweep pivot = high of the most recent bar with high > target high, close < target high, and volume > average volume × threshold; reset at the start of each Asian session and after close exceeds the pivot.
Calculation: long-sweep pivot = low of the most recent bar with low < target low, close > target low, and volume > average volume × threshold; reset at the start of each Asian session and after close falls below the pivot.
Short: target high is available AND high > target high AND close < target high AND volume > average volume × threshold
Short: long-sweep pivot is available AND close < long-sweep pivot
Long: target low is available AND low < target low AND close > target low AND volume > average volume × threshold
Long: short-sweep pivot is available AND close > short-sweep pivot