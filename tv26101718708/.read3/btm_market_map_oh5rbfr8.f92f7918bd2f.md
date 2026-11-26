Long: A newly confirmed PivotHigh(high, structure left lookback, structure right lookback) exceeds the preceding confirmed PivotHigh, OR a newly confirmed PivotLow(low, structure left lookback, structure right lookback) exceeds the preceding confirmed PivotLow
Short: A newly confirmed PivotHigh(high, structure left lookback, structure right lookback) is less than or equal to the preceding confirmed PivotHigh, OR a newly confirmed PivotLow(low, structure left lookback, structure right lookback) is less than or equal to the preceding confirmed PivotLow
Long: The structure is bearish, no bullish CHOCH has printed in its current state, and close > the latest LH
Short: The structure is bullish, no bearish CHOCH has printed in its current state, and close < the latest HL
Long: After a bullish CHOCH and before the next BOS, close > the latest HH
Short: After a bearish CHOCH and before the next BOS, close < the latest LL
Calculation: Bullish flow = true after a bull BOS; remains true until a bear BOS or bear CHOCH; initially false
Calculation: Bearish flow = true after a bear BOS; remains true until a bull BOS or bull CHOCH; initially false
Long: Bullish flow is true
Short: Bearish flow is true
Long: On chart bars, EMA(close, fast lookback) > EMA(close, slow lookback), both calculated on T1 bars and taken from the last completed T1 bar; fast lookback < slow lookback
Short: On chart bars, EMA(close, fast lookback) < EMA(close, slow lookback), both calculated on T1 bars and taken from the last completed T1 bar; fast lookback < slow lookback
Long: close > VWAP(hlc3, anchored at the London-session start)
Short: close < VWAP(hlc3, anchored at the London-session start)
Calculation: Bull zone bounds = the HL at the latest bull-zone setup, extending ATR(zone ATR lookback) × zone-size parameter above and below it
Calculation: Bear zone bounds = the LH at the latest bear-zone setup, extending ATR(zone ATR lookback) × zone-size parameter above and below it
Long: A bull BOS occurs while an HL exists, OR bullish flow is true when a new HL is confirmed and the latest HH pivot-bar age is within the recent-structure lookback
Short: A bear BOS occurs while an LH exists, OR bearish flow is true when a new LH is confirmed and the latest LL pivot-bar age is within the recent-structure lookback
Long: The current bar is the first overlap with an active bull zone since its latest setup: low <= zone top AND high >= zone bottom AND bars since setup <= zone-expiry parameter
Short: The current bar is the first overlap with an active bear zone since its latest setup: low <= zone top AND high >= zone bottom AND bars since setup <= zone-expiry parameter
Short: On chart bars, high > the previous completed T2 high AND close < that high AND it has not been swept today
Long: On chart bars, low < the previous completed T2 low AND close > that low AND it has not been swept today
Short: high > the Asian-session high AND close < that high AND it has not been swept today AND the bar is in the London session
Long: low < the Asian-session low AND close > that low AND it has not been swept today AND the bar is in the London session
Short: high > the London-session high AND close < that high AND it has not been swept today AND the bar is in the New York window
Long: low < the London-session low AND close > that low AND it has not been swept today AND the bar is in the New York window
Calculation: Equal-high level = the maximum of a qualifying pair of confirmed PivotHigh(high, equal-level pivot lookback, equal-level pivot lookback) values whose difference is <= equal-level tolerance × ATR(equal-level ATR lookback); retain until replaced by a later qualifying pair, swept, or closed above
Calculation: Equal-low level = the minimum of a qualifying pair of confirmed PivotLow(low, equal-level pivot lookback, equal-level pivot lookback) values whose difference is <= equal-level tolerance × ATR(equal-level ATR lookback); retain until replaced by a later qualifying pair, swept, or closed below
Short: An active equal-high level exists AND high > that level AND close < that level
Long: An active equal-low level exists AND low < that level AND close > that level