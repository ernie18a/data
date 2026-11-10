Calculation: Period low and period high = running lowest low and highest high of chart bars in the still-forming higher-timeframe bar, initialized at the first chart bar observed after a higher-timeframe boundary.
Calculation: Mitigation low test = current low <= the low of any of three last-completed higher-timeframe bars, ordered from shorter to longer timeframe, OR current low <= period low.
Calculation: Mitigation high test = current high >= the high of any of the same three last-completed higher-timeframe bars OR current high >= period high.
Calculation: Reference bar = the most recent chart bar satisfying either mitigation low test AND close > open, or mitigation high test AND close < open; initialize to the first chart bar and update before evaluating the current bar. Its body low and body high are the minimum and maximum of its open and close.
Calculation: Bullish rejection = bars since reference bar > 0 AND bars since reference bar <= a lookback limit AND close > open AND one selected grade holds: grade 1, close >= reference body low + lower fraction of reference body size AND close <= reference body low + higher fraction of reference body size; grade 2, open < reference body low AND close > reference body high; grade 3, open < reference body low AND close <= reference bar low.
Calculation: Bearish rejection = bars since reference bar > 0 AND bars since reference bar <= the same lookback limit AND close < open AND one selected grade holds: grade 1, close <= reference body high - lower fraction of reference body size AND close >= reference body high - higher fraction of reference body size; grade 2, open > reference body high AND close < reference body low; grade 3, open > reference body high AND close >= reference bar high.
Long: mitigation low test AND close > open
Short: mitigation high test AND close < open
Long: bullish rejection
Short: bearish rejection
Long: previous chart bar's bullish rejection AND low < previous chart bar's low AND close > previous chart bar's low AND configured bias != sell
Short: previous chart bar's bearish rejection AND high > previous chart bar's high AND close < previous chart bar's high AND configured bias != buy