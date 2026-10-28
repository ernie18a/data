Calculation: Relative volume = current volume / simple moving average of volume over a shorter lookback
Calculation: Candle body efficiency = abs(close - open) / max(high - low, minimum tick)
Calculation: Close location = (close - low) / max(high - low, minimum tick)
Calculation: Buy strength = close location × candle body efficiency
Calculation: Sell strength = (1 - close location) × candle body efficiency
Calculation: Buy-dominance candle = relative volume >= event-volume threshold AND close != open AND buy strength >= dominance threshold AND buy strength > sell strength
Calculation: Sell-dominance candle = relative volume >= event-volume threshold AND close != open AND sell strength >= dominance threshold AND sell strength > buy strength
Calculation: Battle candle = relative volume >= event-volume threshold AND neither dominance condition is true AND candle body efficiency <= battle threshold
Calculation: Lower-wick fraction = (min(open, close) - low) / max(high - low, minimum tick)
Calculation: Upper-wick fraction = (high - max(open, close)) / max(high - low, minimum tick)
Calculation: Upper-wick sequence = the last two consecutive bars each have an upper wick longer than their lower wick, and the range of their highs <= wick tolerance
Calculation: Lower-wick sequence = the last two consecutive bars each have a lower wick longer than their upper wick, and the range of their lows <= wick tolerance
Long: Buy-dominance candle OR relative volume >= bubble-volume threshold AND (Buy-dominance candle OR Battle candle AND lower-wick fraction >= bubble-wick threshold) OR Lower-wick sequence OR short-lookback EMA crosses above long-lookback EMA OR close > both EMAs
Short: Sell-dominance candle OR relative volume >= bubble-volume threshold AND (Sell-dominance candle OR Battle candle AND upper-wick fraction >= bubble-wick threshold) OR Upper-wick sequence OR short-lookback EMA crosses below long-lookback EMA OR close < both EMAs