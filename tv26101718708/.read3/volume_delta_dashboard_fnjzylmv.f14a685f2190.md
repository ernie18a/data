Calculation: Lookback delta percentage = 100 × lookback-weight parameter × (sum(volume where close > open) − sum(volume where close < open)) / sum(volume) over the latest lookback-length chart bars, or 0 if total volume is 0; includes the forming chart bar.
Calculation: Intrabar delta percentage = 100 × (sum(volume where close > open) − sum(volume where close < open)) / sum(volume) for lower-timeframe T1 bars within the current chart bar, or 0 if total volume is 0; evaluated on chart bars using the forming chart bar and its T1 bars.
Calculation: CVD delta = sum(volume where close > open) − sum(volume where close < open) over chart bars in the current CVD accumulation period through the forming chart bar, limited by the CVD history-limit parameter; doji bars contribute zero.
Calculation: Prior CVD delta = sum(volume where close > open) − sum(volume where close < open) over chart bars in the current CVD accumulation period through the prior completed chart bar, limited by the CVD history-limit parameter; 0 if there are no prior bars in the period.
Long: Lookback delta percentage > up-bias threshold
Short: Lookback delta percentage < down-bias threshold
Long: Lookback delta percentage >= 0
Short: Lookback delta percentage < 0
Long: Intrabar delta percentage >= 0
Short: Intrabar delta percentage < 0
Long: Intrabar delta percentage > up-bias threshold AND Lookback delta percentage < down-bias threshold
Short: Intrabar delta percentage < down-bias threshold AND Lookback delta percentage > up-bias threshold
Long: CVD delta >= 0
Short: CVD delta < 0
Long: CVD delta < 0 AND CVD delta > Prior CVD delta AND abs(CVD delta) >= abs(Prior CVD delta) × CVD thinning ratio
Short: CVD delta > 0 AND CVD delta < Prior CVD delta AND abs(CVD delta) >= abs(Prior CVD delta) × CVD thinning ratio