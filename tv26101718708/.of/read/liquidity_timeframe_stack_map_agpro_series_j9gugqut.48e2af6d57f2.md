Calculation: Previous pivot high and low = the most recently confirmed chart-timeframe pivot high and low, respectively, as of the previous bar; each pivot uses the same number of bars on both sides.
Calculation: Sweep reaction = (high - max(open, close)) / (high - low) when high > previous pivot high AND close < previous pivot high; otherwise (min(open, close) - low) / (high - low).
Long: low < previous pivot low AND close > previous pivot low AND sweep reaction >= reaction threshold.
Short: high > previous pivot high AND close < previous pivot high AND sweep reaction >= reaction threshold.