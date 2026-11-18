Calculation: volume ratio = volume / SMA(volume, volume-average lookback)
Calculation: signal score = IF(volume ratio > upper volume-ratio threshold, upper volume points, IF(volume ratio > lower volume-ratio threshold, lower volume points, 0)) + IF(ROC(close, gap lookback) > upper gap threshold, upper gap points, IF(ROC(close, gap lookback) > lower gap threshold, lower gap points, 0)) + IF(EMA(close, short MA lookback) > EMA(close, mid MA lookback), EMA-alignment points, 0) + IF(close > EMA(close, short MA lookback), price-above-short-EMA points, 0) + IF(100 × Bollinger Band Width(close, Bollinger lookback, standard-deviation multiplier) < maximum band-width threshold, squeeze points, 0) + IF(ROC(close, momentum lookback) > momentum threshold, momentum points, 0)
Long: volume ratio > volume-surge threshold
Long: signal score >= minimum signal score
Long: ROC(close, momentum lookback) > 0
Long: close > EMA(close, short MA lookback) AND RSI(close, RSI lookback) < RSI maximum AND signal score >= minimum signal score
Short: ROC(close, momentum lookback) <= 0
Exit: Long, close < EMA(close, short MA lookback) AND ROC(close, momentum lookback) < momentum-fade threshold
Exit: Long, low <= trailing stop after price reaches entry price + close × trail-activation percentage; the stop follows the highest high since activation by close × trail-offset percentage