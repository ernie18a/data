Calculation: Net volume delta = buying volume minus selling volume across lower-timeframe bars within the current chart bar.
Calculation: Volume cluster = current volume meets the configured lowest cluster percentile in the configured consensus number of short-, medium-, and long-lookback rolling volume percentiles.
Calculation: Delta cluster = absolute current net volume delta meets the same lowest cluster percentile and consensus rule across matching short-, medium-, and long-lookback rolling percentiles of absolute delta.
Long: (volume cluster OR delta cluster) AND close >= open AND (net volume delta > 0 OR delta unavailable)
Short: (volume cluster OR delta cluster) AND close < open AND (net volume delta < 0 OR delta unavailable)