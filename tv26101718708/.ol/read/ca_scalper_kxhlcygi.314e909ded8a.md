Calculation: Bullish daily bias = close of the first chart bar of the day > its open
Calculation: Bearish daily bias = close of the first chart bar of the day < its open
Calculation: Support = lowest low over the chart-timeframe lookback, including the current bar
Calculation: Resistance = highest high over the chart-timeframe lookback, including the current bar
Calculation: Bullish order-block zone = range from low to high of the previous bar, updated when that bar closes below its open and the current close is above its high
Calculation: Bearish order-block zone = range from low to high of the previous bar, updated when that bar closes above its open and the current close is below its low
Long: bullish daily bias AND 9-period EMA > 21-period EMA AND close > 21-period EMA AND RSI(14) > 65 AND close crosses above 9-period EMA AND (close <= support × 1.002 OR close is within the latest bullish order-block zone)
Short: bearish daily bias AND 9-period EMA < 21-period EMA AND close < 21-period EMA AND RSI(14) < 35 AND close crosses below 9-period EMA AND (close >= resistance × 0.998 OR close is within the latest bearish order-block zone)