Calculation: pivots = time-ordered sequence of confirmed Pivot high(pivot lookback, pivot lookback) and Pivot low(pivot lookback, pivot lookback) values, each with type (high or low) and price; type[n] and price[n] are of the n-th most recent pivot, n=0 newest
Calculation: pivot event = a new element is appended to pivots on this bar
Calculation: alternating = type[3] != type[2] AND type[2] != type[1] AND type[1] != type[0]
Calculation: high change = (later high - earlier high) / earlier high, where earlier high and later high are the prices of the two high pivots among the four most recent pivots, in time order
Calculation: low change = (later low - earlier low) / earlier low, where earlier low and later low are the prices of the two low pivots among the four most recent pivots, in time order
Long: SMA(close, shorter lookback A) crosses above SMA(close, longer lookback B)
Short: SMA(close, shorter lookback A) crosses below SMA(close, longer lookback B)
Long: SMA(close, shorter lookback A) crosses above SMA(close, longer lookback C)
Short: SMA(close, shorter lookback A) crosses below SMA(close, longer lookback C)
Long: SMA(close, shorter lookback B) crosses above SMA(close, longer lookback C)
Short: SMA(close, shorter lookback B) crosses below SMA(close, longer lookback C)
Long: SMA(close, shorter lookback C) crosses above SMA(close, longer lookback D)
Short: SMA(close, shorter lookback C) crosses below SMA(close, longer lookback D)
Long: pivot event AND type[2] = low AND type[1] = high AND type[0] = low AND |price[0] - price[2]| / price[2] <= pattern tolerance AND price[1] > max(price[2], price[0])
Short: pivot event AND type[2] = high AND type[1] = low AND type[0] = high AND |price[0] - price[2]| / price[2] <= pattern tolerance AND price[1] < min(price[2], price[0])
Short: pivot event AND type[4] = high AND type[3] = low AND type[2] = high AND type[1] = low AND type[0] = high AND price[2] > price[4] AND price[2] > price[0] AND |price[0] - price[4]| / price[4] <= pattern tolerance AND |price[1] - price[3]| / price[3] <= neckline factor * pattern tolerance
Long: pivot event AND type[4] = low AND type[3] = high AND type[2] = low AND type[1] = high AND type[0] = low AND price[2] < price[4] AND price[2] < price[0] AND |price[0] - price[4]| / price[4] <= pattern tolerance AND |price[1] - price[3]| / price[3] <= neckline factor * pattern tolerance
Long: pivot event AND alternating AND |high change| < flat tolerance AND low change > flat tolerance
Short: pivot event AND alternating AND |low change| < flat tolerance AND high change < -flat tolerance
Short: pivot event AND alternating AND high change > flat tolerance AND low change > flat tolerance AND low change > high change
Long: pivot event AND alternating AND high change < -flat tolerance AND low change < -flat tolerance AND |high change| > |low change|