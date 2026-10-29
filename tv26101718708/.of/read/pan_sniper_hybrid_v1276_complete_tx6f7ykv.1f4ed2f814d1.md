Calculation: Bullish volume fraction = sum of lower-timeframe volume where close > open within the current chart bar / total lower-timeframe volume within that bar; use the lower timeframe, including its still-forming bar when available
Calculation: Gaussian filter = EMA of close with a long lookback
Calculation: Bullish reversal candle = lower-wick length > 0.5 × true range AND upper-wick length < 0.2 × true range, OR close > prior open AND open < prior close AND close − open > 0.3 × true range
Calculation: Bearish reversal candle = upper-wick length > 0.5 × true range AND lower-wick length < 0.2 × true range, OR close < prior open AND open > prior close AND open − close > 0.3 × true range
Calculation: Volume surge = volume > a multiple of its moving average
Calculation: Projected daily high/low = current daily open ± the average range of the last five completed daily bars
Long: MACD line crosses above its signal line AND close > Gaussian filter AND bullish volume fraction > threshold
Long: low < last confirmed pivot low AND close > last confirmed pivot low AND bullish volume fraction > threshold
Long: low <= previous completed daily low + 0.5 × true range OR low <= projected daily low; bullish reversal candle; volume surge; and more bars have elapsed since the last buy or sell signal than the cooldown
Long: close crosses above the prior stored swing high OR close crosses above the latest bearish fair value gap's upper boundary; and a bearish target zone is active
Short: MACD line crosses below its signal line AND close < Gaussian filter AND bullish volume fraction < threshold
Short: high > last confirmed pivot high AND close < last confirmed pivot high AND bullish volume fraction < threshold
Short: high >= previous completed daily high − 0.5 × true range OR high >= projected daily high; bearish reversal candle; volume surge; and more bars have elapsed since the last buy or sell signal than the cooldown