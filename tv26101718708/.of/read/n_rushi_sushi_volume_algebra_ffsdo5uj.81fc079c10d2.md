Calculation: volumeRatio = volume / volume N bars ago on the chart timeframe (1 if the earlier volume is 0)
Calculation: priceChangePct = (close - close N bars ago) / close N bars ago * 100, with the same N as in volumeRatio
Calculation: score = max(0, wV*(volumeRatio-1)*100 + wP*abs(priceChangePct) + wR*min(volumeRatio, cap)), with wV > wP > wR and the weights summing to 1
Calculation: ATR = Average True Range over a lookback on the chart timeframe, taken at the entry bar
Long: volumeRatio > 1 + small margin AND priceChangePct > 0 AND score >= minimum score threshold, evaluated on the last completed bar
Short: volumeRatio > 1 + small margin AND priceChangePct < 0 AND score >= minimum score threshold, evaluated on the last completed bar
Exit: long, low <= entry price - k*ATR
Exit: short, high >= entry price + k*ATR