Calculation: Relative volume = current volume / moving average of volume over a lookback
Calculation: Body efficiency = absolute(close - open) / candle range
Calculation: Close position = (close - low) / candle range
Calculation: Buyer strength = close position × body efficiency
Calculation: Seller strength = (1 - close position) × body efficiency
Calculation: Upper wick share = upper wick length / candle range
Calculation: Lower wick share = lower wick length / candle range
Long: Relative volume >= elevated-volume threshold AND buyer strength >= dominance threshold AND buyer strength > seller strength
Long: Relative volume >= bubble-volume threshold AND ((buyer strength >= dominance threshold AND buyer strength > seller strength) OR (relative volume >= battle-volume threshold AND body efficiency <= battle-body limit AND lower wick share >= meaningful-wick threshold))
Long: The current and preceding bar each have a lower wick longer than the upper wick AND their lows are within the wick-level tolerance
Long: EMA with the shorter lookback crosses above EMA with the longer lookback
Short: Relative volume >= elevated-volume threshold AND seller strength >= dominance threshold AND seller strength > buyer strength
Short: Relative volume >= bubble-volume threshold AND ((seller strength >= dominance threshold AND seller strength > buyer strength) OR (relative volume >= battle-volume threshold AND body efficiency <= battle-body limit AND upper wick share >= meaningful-wick threshold))
Short: The current and preceding bar each have an upper wick longer than the lower wick AND their highs are within the wick-level tolerance
Short: EMA with the shorter lookback crosses below EMA with the longer lookback