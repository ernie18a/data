Calculation: Kernel estimate(source, lookback, bandwidth, kernel type) = the weighted mean of source[i] for lags from zero through lookback minus one; weights are exp(−lag²/(2 × bandwidth²)) for Gaussian, max(0, 1 − (lag/bandwidth)²) for Epanechnikov, or max(0, (1 − |lag/bandwidth|³)³) for tricube.
Calculation: Effective slow bandwidth = base bandwidth × (minimum adaptive scale + (maximum adaptive scale − minimum adaptive scale) × normalized PercentileRank(ATR(source bars, ATR lookback), ATR percentile lookback)) when adaptive bandwidth is enabled; otherwise it equals base bandwidth. The rank and ATR use chart bars.
Calculation: Slow kernel = EMA(Kernel estimate(close, kernel lookback, effective slow bandwidth, kernel type), output smoothing length); fast bandwidth = effective slow bandwidth × fast bandwidth multiplier; fast kernel = EMA(Kernel estimate(close, kernel lookback, fast bandwidth, kernel type), output smoothing length minus fast smoothing decrement, floored at minimum smoothing length). These calculations use chart bars.
Calculation: Kernel spread = fast kernel − slow kernel.
Calculation: Residual sigma = EMA(STDEV(close − slow kernel, residual lookback), sigma smoothing length); upper residual band = slow kernel + band multiplier × residual sigma; lower residual band = slow kernel − band multiplier × residual sigma; residual Z-score = (close − slow kernel) / residual sigma, or zero when residual sigma is zero.
Calculation: Regime = Chop when Choppiness Index(high, low, chop lookback) is at least the chop threshold; otherwise Trend when Efficiency Ratio(close, trend lookback) is at least the trend threshold and absolute kernel spread exceeds residual sigma × minimum spread factor, classified Bull when spread is positive and Bear when negative; otherwise Balance.
Calculation: Bullish spread = fast kernel > slow kernel AND kernel spread > kernel spread[1]; bearish spread = fast kernel < slow kernel AND kernel spread < kernel spread[1].
Calculation: Candle range = max(high − low, minimum price increment).
Calculation: Bullish rejection = close > open AND (close − low) / candle range > rejection fraction; bearish rejection = close < open AND (high − close) / candle range > rejection fraction.
Calculation: Bull pivot divergence = divergence enabled AND current low < the latest confirmed pivot low AND current slow kernel > slow kernel at that pivot bar AND close <= lower residual band + residual sigma AND at least the divergence cooldown has elapsed since the previous bull divergence. Pivot highs and lows use equal left and right pivot lookbacks; their slow kernel values are recorded at the pivot bar.
Calculation: Bear pivot divergence = divergence enabled AND current high > the latest confirmed pivot high AND current slow kernel < slow kernel at that pivot bar AND close >= upper residual band − residual sigma AND at least the divergence cooldown has elapsed since the previous bear divergence. Pivot highs and lows use equal left and right pivot lookbacks; their slow kernel values are recorded at the pivot bar.
Calculation: HTF bullish bias = EMA(close, HTF fast lookback, T1) > EMA(close, HTF slow lookback, T1) AND close(T1) > EMA(close, HTF fast lookback, T1); HTF bearish bias = EMA(close, HTF fast lookback, T1) < EMA(close, HTF slow lookback, T1) AND close(T1) < EMA(close, HTF fast lookback, T1). These values are computed on T1 bars and sampled on chart bars with lookahead off: the last completed T1 bar historically and the forming T1 bar in real time.
Calculation: Volume pass = volume filter disabled OR volume >= SMA(volume, volume lookback) × volume multiplier.
Calculation: Long setup = (Flow Break enabled AND Regime is Trend Bull AND close crosses above the upper residual band AND bullish spread AND bullish rejection) OR (Kernel Pullback enabled AND Regime is Trend Bull AND low <= slow kernel + ATR × pullback tolerance AND close > slow kernel AND bullish spread AND bullish rejection) OR (Z-Score Fade enabled AND Regime is Balance AND residual Z-score <= −fade threshold AND bullish rejection) OR (Divergence Reversal enabled AND bull pivot divergence AND bullish rejection AND (Regime is Balance OR Trend Bear)).
Calculation: Short setup = (Flow Break enabled AND Regime is Trend Bear AND close crosses below the lower residual band AND bearish spread AND bearish rejection) OR (Kernel Pullback enabled AND Regime is Trend Bear AND high >= slow kernel − ATR × pullback tolerance AND close < slow kernel AND bearish spread AND bearish rejection) OR (Z-Score Fade enabled AND Regime is Balance AND residual Z-score >= fade threshold AND bearish rejection) OR (Divergence Reversal enabled AND bear pivot divergence AND bearish rejection AND (Regime is Balance OR Trend Bull)).
Calculation: Long confluence score = number of satisfied layers: (Regime is Trend Bull OR bullish spread); (residual Z-score > 0 OR kernel spread > 0); (HTF filter disabled OR HTF bullish bias); volume pass; bullish rejection; Regime is not Chop; long setup.
Calculation: Short confluence score = number of satisfied layers: (Regime is Trend Bear OR bearish spread); (residual Z-score < 0 OR kernel spread < 0); (HTF filter disabled OR HTF bearish bias); volume pass; bearish rejection; Regime is not Chop; short setup.
Long: Regime is Trend Bull.
Short: Regime is Trend Bear.
Long: HTF bullish bias.
Short: HTF bearish bias.
Long: kernel spread >= 0.
Short: kernel spread < 0.
Long: bullish spread.
Short: bearish spread.
Long: bias bar coloring is enabled AND kernel spread > residual sigma × bias-color threshold.
Short: bias bar coloring is enabled AND kernel spread < −residual sigma × bias-color threshold.
Long: long confluence score >= minimum confluence AND Regime is not Chop.
Short: short confluence score >= minimum confluence AND Regime is not Chop.
Long: bull pivot divergence.
Short: bear pivot divergence.
Long: long setup AND long confluence score >= minimum confluence AND (HTF filter disabled OR HTF bullish bias) AND volume pass AND (session filter disabled OR the chart bar is within the configured session) AND at least the signal cooldown has elapsed since the previous long or short signal AND entry signals are enabled AND the chart bar is confirmed.
Short: short setup AND short confluence score >= minimum confluence AND (HTF filter disabled OR HTF bearish bias) AND volume pass AND (session filter disabled OR the chart bar is within the configured session) AND at least the signal cooldown has elapsed since the previous long or short signal AND entry signals are enabled AND the chart bar is confirmed.
Exit: long, Regime is Chop AND the previous chart bar's Regime was not Chop.
Exit: short, Regime is Chop AND the previous chart bar's Regime was not Chop.
Exit: long, position is a Trend Bull trade AND kernel spread > 0 AND kernel spread < kernel spread[1].
Exit: short, position is a Trend Bear trade AND kernel spread < 0 AND kernel spread > kernel spread[1].