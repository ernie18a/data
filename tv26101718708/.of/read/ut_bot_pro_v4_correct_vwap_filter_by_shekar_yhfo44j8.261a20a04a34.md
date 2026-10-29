Calculation: Heikin-Ashi close = (open + high + low + close) / 4
Calculation: Heikin-Ashi open = (prior Heikin-Ashi open + prior Heikin-Ashi close) / 2; on the first bar, (open + close) / 2
Calculation: Heikin-Ashi body = absolute difference between Heikin-Ashi close and Heikin-Ashi open
Calculation: Average Heikin-Ashi body = simple moving average of Heikin-Ashi body
Calculation: VWAP = session VWAP of (high + low + close) / 3, weighted by volume
Calculation: Bullish pullback = Heikin-Ashi close < Heikin-Ashi open OR Heikin-Ashi body < Average Heikin-Ashi body
Calculation: Bearish pullback = Heikin-Ashi close > Heikin-Ashi open OR Heikin-Ashi body < Average Heikin-Ashi body
Calculation: Long readiness = initially true; set true whenever a bullish pullback occurs within the pullback lookback, and set false after a Long
Calculation: Short readiness = initially true; set true whenever a bearish pullback occurs within the pullback lookback, and set false after a Short
Long: close > VWAP AND low > VWAP AND Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi body > Average Heikin-Ashi body × strong-candle multiplier AND Long readiness
Short: close < VWAP AND high < VWAP AND Heikin-Ashi close < Heikin-Ashi open AND Heikin-Ashi body > Average Heikin-Ashi body × strong-candle multiplier AND Short readiness