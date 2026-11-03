Calculation: Price source = a configurable source derived from the bar’s price fields.
Calculation: Hull moving average = WMA(2 × WMA(price source, half length) − WMA(price source, full length), rounded square-root length), with each derived length at least one bar.
Calculation: Directional confluence score = the sum of four indicators, each equal to 1 when its condition holds and 0 otherwise: (1) Hull moving average rises and price source is above a longer-length WMA for bullish, or Hull moving average falls and price source is below that WMA for bearish; (2) RSI of price source exceeds its higher threshold and MACD histogram is positive and rising for bullish, or RSI is below its lower threshold and MACD histogram is negative and falling for bearish; (3) volume exceeds its SMA multiplied by a volume threshold and a shorter-term volume SMA exceeds a longer-term volume SMA; (4) ATR percentile rank is between its lower and upper thresholds, inclusive. MACD uses a shorter-length EMA minus a longer-length EMA of price source, with an EMA signal line.
Calculation: Signal state = initially no previous signal; evaluate both signal conditions using the state before the current bar, then record the direction and bar of each signal. If both occur on the same bar, record short as the last signal.
Long: Hull moving average > previous Hull moving average.
Short: Hull moving average <= previous Hull moving average.
Long: Hull moving average > previous Hull moving average AND price source > longer-length WMA of price source.
Short: Hull moving average < previous Hull moving average AND price source < longer-length WMA of price source.
Long: RSI of price source > higher RSI threshold AND MACD histogram > 0 AND MACD histogram > previous MACD histogram.
Short: RSI of price source < lower RSI threshold AND MACD histogram < 0 AND MACD histogram < previous MACD histogram.
Long: bullish confluence score >= bearish confluence score.
Short: bearish confluence score > bullish confluence score.
Long: bullish confluence score >= minimum confluence threshold.
Short: bearish confluence score >= minimum confluence threshold.
Long: bullish confluence score >= minimum confluence threshold AND previous bullish confluence score < minimum confluence threshold AND last signal direction != long AND bars since last signal >= cooldown.
Short: bearish confluence score >= minimum confluence threshold AND previous bearish confluence score < minimum confluence threshold AND last signal direction != short AND bars since last signal >= cooldown.