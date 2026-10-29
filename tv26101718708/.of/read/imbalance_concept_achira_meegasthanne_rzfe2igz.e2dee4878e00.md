Calculation: Bullish market-structure state = bullish after close exceeds the highest high of the preceding lookback; bearish after close falls below the lowest low of the preceding lookback; otherwise retain the previous state, initially neutral
Calculation: Sell absorption index = (volume / abs(open - close) / close on down bars, otherwise 0) divided by the lookback standard deviation of that series
Calculation: Buy absorption index = (volume / abs(open - close) / close on up bars, otherwise 0) divided by the lookback standard deviation of that series
Long: low two bars ago > current high AND low two bars ago <= previous open AND current high >= previous close
Long: round(sell absorption index) is from 1 through 7 AND sell absorption index >= threshold AND close < open
Long: bullish market-structure state
Long: On the higher-timeframe last completed bar, low three bars ago > high one bar ago AND low three bars ago differs from its previous sampled value
Short: high two bars ago < current low AND high two bars ago >= previous open AND current low <= previous close
Short: round(buy absorption index) is from 1 through 7 AND buy absorption index >= threshold AND close > open
Short: bearish market-structure state
Short: On the higher-timeframe last completed bar, high three bars ago < low one bar ago AND high three bars ago differs from its previous sampled value