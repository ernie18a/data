Calculation: Bollinger Band width = (upper band − lower band) / abs(SMA(close)); upper/lower bands = SMA(close) ± standard deviation(close) × Bollinger multiplier
Calculation: Keltner Channel width = (upper channel − lower channel) / abs(EMA(hlc3)); upper/lower channels = EMA(hlc3) ± ATR × Keltner multiplier
Calculation: Confirmed squeeze event = current Bollinger Band width < current Keltner Channel width AND prior chart bar’s Bollinger Band width ≥ its Keltner Channel width
Calculation: Similar prior squeezes = up to N earlier confirmed squeeze events with 10-bar forward returns fully observed, ranked by weighted Euclidean distance between their and the current event’s (ATR / abs(close), RSI / 100, volume / SMA(volume)) features
Calculation: Median 10-bar return = median of the similar prior squeezes’ ((close 10 chart bars after event / event close) − 1) × 100
Calculation: Bullish outcome probability = percentage of similar prior squeezes whose 10-bar forward return is > 0
Long: confirmed squeeze event AND at least 3 similar prior squeezes AND median 10-bar return > the positive edge threshold AND bullish outcome probability ≥ the probability threshold
Short: confirmed squeeze event AND at least 3 similar prior squeezes AND median 10-bar return < the negative edge threshold AND bullish outcome probability ≤ 100% − the probability threshold