Calculation: Kernel regression = weighted average of the current close and the preceding lookback bars’ closes, with each bar i bars back weighted by exp(−i² / (2 × (lookback / 2)²))
Calculation: Buy setup count = consecutive bars where close < close four bars earlier; reset to zero when false
Calculation: Sell setup count = consecutive bars where close > close four bars earlier; reset to zero when false
Calculation: Heikin-Ashi bars = bars derived from chart-timeframe OHLC
Calculation: Higher low = latest confirmed pivot low is higher than the preceding confirmed pivot low; each pivot uses the same left- and right-side lookbacks
Long: EMA with shorter lookback crosses above kernel regression OR buy setup count = 9 OR Heikin-Ashi close crosses above the higher of the shorter-lookback EMA and kernel regression AND Heikin-Ashi close > Heikin-Ashi open OR a new higher low is confirmed AND close > the latest pivot low
Short: EMA with shorter lookback crosses below kernel regression OR sell setup count = 9