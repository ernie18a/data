Calculation: Body size = |close - open|
Calculation: ATR = average true range over a lookback
Calculation: Relative volume = volume / simple moving average of volume over a lookback
Calculation: Body/range = body size / (high - low)
Calculation: Opposing-wick fraction = upper wick / (high - low) for a bullish candle; lower wick / (high - low) for a bearish candle
Calculation: Total-wick/body ratio = (upper wick + lower wick) / body size
Calculation: Absorption event = volume >= its moving average × an absorption threshold, body size <= ATR × an absorption maximum, and body/range <= an absorption maximum; its volume threshold is independently set and higher than the body-driven volume threshold by default
Calculation: Body-driven event = body size >= ATR × a minimum, relative volume >= a minimum, and, when the wick filter is enabled, total-wick/body ratio <= a maximum
Calculation: Event class = absorption takes precedence; otherwise, for a body-driven event, reversal if opposing-wick fraction >= its threshold, else continuation if body/range >= its threshold, else exhaustion
Long: Absorption event AND close < open OR Body-driven event AND ((Event class = continuation OR Event class = exhaustion) AND close > open OR Event class = reversal AND close < open)
Short: Absorption event AND close > open OR Body-driven event AND ((Event class = continuation OR Event class = exhaustion) AND close < open OR Event class = reversal AND close > open)