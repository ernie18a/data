Calculation: Volume-weighted CCI candle close = smooth CCI of close multiplied by volume, using the selected moving-average method and its parameters.
Calculation: Volume-weighted CCI candle open = smooth CCI of open multiplied by volume, using the same moving-average method and parameters as the candle close; if abs(open - close) is at most the gap threshold, use the previous bar's volume-weighted CCI candle close instead.
Calculation: Higher-timeframe candle values = apply the same calculations to higher-timeframe bars; sample the still-forming higher-timeframe bar on its first chart bar and hold that sample until the next higher-timeframe bar.
Long: Volume-weighted CCI candle close >= volume-weighted CCI candle open.
Short: Volume-weighted CCI candle close < volume-weighted CCI candle open.
Long: Previous volume-weighted CCI candle close < 0 AND current volume-weighted CCI candle close >= 0.
Short: Previous volume-weighted CCI candle close > 0 AND current volume-weighted CCI candle close <= 0.
Long: Higher-timeframe candle close >= higher-timeframe candle open.
Short: Higher-timeframe candle close < higher-timeframe candle open.
Long: Previous higher-timeframe volume-weighted CCI candle close < 0 AND current higher-timeframe volume-weighted CCI candle close >= 0.
Short: Previous higher-timeframe volume-weighted CCI candle close > 0 AND current higher-timeframe volume-weighted CCI candle close <= 0.