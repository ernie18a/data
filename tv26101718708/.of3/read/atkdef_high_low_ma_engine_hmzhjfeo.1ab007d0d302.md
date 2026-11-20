Calculation: Momentum percentage = (close - close[momentum lookback]) / close[momentum lookback] * 100
Calculation: Upward signal count = number of true conditions among SMA(close, shortest lookback) > SMA(close, shortest lookback)[lag], SMA(close, middle lookback) > SMA(close, middle lookback)[lag], SMA(close, longest lookback) > SMA(close, longest lookback)[lag], and momentum percentage > momentum-neutral threshold
Calculation: Downward signal count = number of true conditions among SMA(close, shortest lookback) <= SMA(close, shortest lookback)[lag], SMA(close, middle lookback) <= SMA(close, middle lookback)[lag], SMA(close, longest lookback) <= SMA(close, longest lookback)[lag], and momentum percentage <= momentum-neutral threshold
Calculation: Trend score = arrangement weight if SMA(close, shortest lookback) > SMA(close, middle lookback) AND SMA(close, middle lookback) > SMA(close, longest lookback), plus shared weight if SMA(close, shortest lookback) > SMA(close, shortest lookback)[lag] AND SMA(close, middle lookback) > SMA(close, middle lookback)[lag], plus shared weight if momentum percentage > momentum-neutral threshold, plus volume weight if volume > SMA(volume, volume lookback), plus shared weight if close > SMA(close, shortest lookback), with each contribution zero when its condition is false
Long: SMA(close, shortest lookback) > SMA(close, middle lookback) AND SMA(close, middle lookback) > SMA(close, longest lookback)
Short: SMA(close, shortest lookback) < SMA(close, middle lookback) AND SMA(close, middle lookback) < SMA(close, longest lookback)
Long: SMA(close, shortest lookback) crosses above SMA(close, middle lookback) AND SMA(close, middle lookback) > SMA(close, longest lookback)
Short: SMA(close, shortest lookback) crosses below SMA(close, middle lookback) AND SMA(close, middle lookback) < SMA(close, longest lookback)
Long: Upward signal count >= signal-count threshold
Short: Downward signal count >= signal-count threshold
Long: SMA(close, shortest lookback) > SMA(close, shortest lookback)[lag] OR SMA(close, middle lookback) > SMA(close, middle lookback)[lag] OR SMA(close, longest lookback) > SMA(close, longest lookback)[lag]
Short: SMA(close, shortest lookback) <= SMA(close, shortest lookback)[lag] OR SMA(close, middle lookback) <= SMA(close, middle lookback)[lag] OR SMA(close, longest lookback) <= SMA(close, longest lookback)[lag]
Long: Momentum percentage > momentum band
Short: Momentum percentage <= -momentum band
Long: PivotLow(low, left lookback, right lookback) is present
Short: PivotHigh(high, left lookback, right lookback) is present
Long: Trend score >= upper score threshold
Short: Trend score < lower score threshold