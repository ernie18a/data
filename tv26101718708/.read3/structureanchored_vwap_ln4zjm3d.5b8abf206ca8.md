Calculation: Anchored VWAP = cumulative(source × volume) / cumulative(volume) from the selected reset bar, including that bar; session resets use timeframe.change(T1) on chart bars
Calculation: Prior structure direction = neutral before the first structure break, then the direction of the most recent structure break
Calculation: Upward structure break = confirmed close > latest unbroken confirmed PivotHigh(high, swing lookback, swing lookback) + break buffer × ATR(lookback); classify as CHoCH if prior structure direction is bearish, otherwise BOS
Calculation: Downward structure break = confirmed close < latest unbroken confirmed PivotLow(low, swing lookback, swing lookback) − break buffer × ATR(lookback); classify as CHoCH if prior structure direction is bullish, otherwise BOS
Calculation: Low sweep = confirmed low < latest unswept confirmed PivotLow(low, swing lookback, swing lookback) AND close > that pivot
Calculation: High sweep = confirmed high > latest unswept confirmed PivotHigh(high, swing lookback, swing lookback) AND close < that pivot
Long: close >= Anchored VWAP OR the selected anchor event is an upward structure break OR the selected anchor event is a low sweep
Short: close < Anchored VWAP OR the selected anchor event is a downward structure break OR the selected anchor event is a high sweep