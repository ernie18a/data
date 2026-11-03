Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than the fast EMA
Calculation: Volume average = simple moving average of volume over a short lookback
Calculation: Long stop = lowest low over a short lookback, set on the entry bar
Calculation: Long target = entry price + (entry price − long stop) × configured reward multiple
Long: Flat AND within the configured date window AND ((close > VWAP AND close > slow EMA AND low <= fast EMA × (1 + configured buffer) AND close > open AND close > prior close) OR (close > VWAP AND close > slow EMA AND close crosses above the highest high of the preceding lookback bars AND volume > volume average × configured multiplier) OR (close > open AND prior close < prior open AND close > prior high AND volume > volume average × configured multiplier)) AND (close − long stop) > close × configured minimum risk fraction
Exit: Long, close < slow EMA OR low <= long stop OR high >= long target