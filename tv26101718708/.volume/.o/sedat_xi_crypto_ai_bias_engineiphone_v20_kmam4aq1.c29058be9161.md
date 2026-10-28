Calculation: Scan bars = bars aggregated to the scan timeframe; use the bar still forming.
Calculation: Relative volume = current scan-bar volume divided by its simple average over a shorter lookback.
Calculation: Active volume = relative volume >= its threshold.
Calculation: Extreme volume = relative volume >= a higher threshold than active volume.
Calculation: Bullish breakout = current scan-bar close > the highest high of the prior breakout lookback bars, excluding the current bar, AND active volume.
Calculation: Bearish breakdown = current scan-bar close < the lowest low of the prior breakout lookback bars, excluding the current bar, AND active volume.
Calculation: Trend = bullish when the short-lookback EMA > the medium-lookback EMA > the long-lookback EMA; bearish when the reverse ordering holds.
Calculation: Score = +2 for bullish trend, -2 for bearish trend, otherwise 0; add +1 when close > the long-lookback EMA, otherwise -1; add +1 when RSI > 55, -1 when RSI < 45, otherwise 0; add +2 for bullish breakout, -2 for bearish breakdown; add +1 for active volume; add +1 for extreme volume with bullish trend, or -1 for extreme volume with bearish trend.
Long: Bullish breakout OR score > 0
Short: Bearish breakdown OR score < 0