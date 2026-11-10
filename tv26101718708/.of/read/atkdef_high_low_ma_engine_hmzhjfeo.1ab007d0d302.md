Calculation: Bullish vote count = number of these conditions that are true: short-term, medium-term and long-term close SMA each greater than its previous-bar value; current close greater than close at a configurable lookback.
Calculation: Bearish vote count = number of these conditions that are true: short-term, medium-term and long-term close SMA each less than or equal to its previous-bar value; current close less than or equal to close at the same configurable lookback.
Calculation: Overall score = sum of configurable weights for each true condition: short-term close SMA > medium-term close SMA > long-term close SMA; both short-term and medium-term close SMAs > their previous-bar values; current close > close at the configurable momentum lookback; volume > its SMA; close > short-term close SMA. The arrangement weight is largest, the volume weight is smallest, and the other three weights are equal.
Long: Short-term close SMA > medium-term close SMA AND medium-term close SMA > long-term close SMA.
Long: Bullish vote count >= configurable vote threshold.
Long: Overall score >= upper score threshold.
Short: Short-term close SMA < medium-term close SMA AND medium-term close SMA < long-term close SMA.
Short: Bearish vote count >= configurable vote threshold.
Short: Overall score < lower score threshold.