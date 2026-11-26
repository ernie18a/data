Calculation: Prior-period high = high[1] of T6's last completed bar, carried onto chart bars
Calculation: Prior-period low = low[1] of T6's last completed bar, carried onto chart bars
Calculation: Active FVGs = bullish gaps [high[2], low] formed when a confirmed chart bar has low > high[2], and bearish gaps [high, low[2]] formed when a confirmed chart bar has high < low[2]; remove bullish gaps on confirmed closes below their lower boundary and bearish gaps on confirmed closes above their upper boundary, pruning the oldest when the configured combined active-gap limit is exceeded
Calculation: Latest bearish-run level = open of the first confirmed bearish bar in the latest consecutive bearish run, with doji bars inheriting the prior run direction; replace at each new bearish run and keep active until crossed above
Calculation: Latest bullish-run level = open of the first confirmed bullish bar in the latest consecutive bullish run, with doji bars inheriting the prior run direction; replace at each new bullish run and keep active until crossed below
Long: EMA(close, shorter lookback) > EMA(close, longer lookback) on chart bars OR, for any of T1, T2, T3, T4, T5, or T6, EMA(close, shorter lookback, still-forming T bar) > EMA(close, longer lookback, still-forming T bar), sampled on chart bars
Short: EMA(close, shorter lookback) <= EMA(close, longer lookback) on chart bars OR, for any of T1, T2, T3, T4, T5, or T6, EMA(close, shorter lookback, still-forming T bar) <= EMA(close, longer lookback, still-forming T bar), sampled on chart bars
Long: close crosses above EMA(close, shorter lookback) on chart bars
Short: close crosses below EMA(close, shorter lookback) on chart bars
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback) on chart bars
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback) on chart bars
Long: On a confirmed chart bar, close > prior-period low after an unsignaled chart-bar low < prior-period low since the current T6 period began
Short: On a confirmed chart bar, close < prior-period high after an unsignaled chart-bar high > prior-period high since the current T6 period began
Long: On a confirmed chart bar, close > the active latest bearish-run level
Short: On a confirmed chart bar, close < the active latest bullish-run level
Long: A bullish FVG forms on a confirmed chart bar
Short: A bearish FVG forms on a confirmed chart bar
Long: On a confirmed chart bar, close > the upper boundary of an active bearish FVG, creating a bullish iFVG
Short: On a confirmed chart bar, close < the lower boundary of an active bullish FVG, creating a bearish iFVG