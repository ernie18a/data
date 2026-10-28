Calculation: Confirmed pivot high/low = a local high/low using a configurable lookback before the pivot and one completed bar after it
Calculation: Bullish/bearish break = close crosses above the latest confirmed pivot high / below the latest confirmed pivot low; bullish/bearish change of character = corresponding break while the prior structure trend is bearish/bullish; update trend and clear the broken pivot on each break
Calculation: Long/short score = sum of configurable points, capped at 100, for the matching conditions: with trend filter on, fast EMA above/below medium EMA and close above/below slow EMA; with trend filter off, baseline points; RSI below oversold / above overbought, or otherwise below/above a secondary threshold; stochastic K below/above an extreme threshold, or otherwise below/above a secondary threshold; change of character or otherwise break of structure; bullish engulfing or otherwise hammer or otherwise strong bullish candle / bearish engulfing or otherwise shooting star or otherwise strong bearish candle; volume above its moving average by a configured expansion factor when volume filter is on, otherwise baseline points; price near the low/high of the recent configured high-low range; and ADX above its minimum when ADX filter is on, otherwise baseline points
Calculation: Near support/resistance = close lies in the lower/upper configured fraction of the range between the highest high and lowest low over a lookback
Calculation: Smart trail = close minus/plus ATR times a configurable multiplier in bullish/bearish trail state; ratchet the trail toward price while that state continues, and switch state when close crosses the trail
Long: Confirmed pivot low
Long: Bullish break or bullish change of character
Long: Long score >= configured signal threshold AND more bars have elapsed since the previous long signal than the configured cooldown AND NOT (ADX filter is on AND ADX < its minimum)
Long: Long score >= configured fraction of signal threshold AND long score < signal threshold AND cooldown condition holds AND NOT (ADX filter is on AND ADX < its minimum)
Long: Smart trail state changes from bearish to bullish
Short: Confirmed pivot high
Short: Bearish break or bearish change of character
Short: Short score >= configured signal threshold AND more bars have elapsed since the previous short signal than the configured cooldown AND NOT (ADX filter is on AND ADX < its minimum)
Short: Short score >= configured fraction of signal threshold AND short score < signal threshold AND cooldown condition holds AND NOT (ADX filter is on AND ADX < its minimum)
Short: Smart trail state changes from bullish to bearish