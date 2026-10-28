Calculation: Price above a moving average = close > that moving average
Calculation: Price below a moving average = close < that moving average
Calculation: Bullish moving-average stack = 9-period EMA > 21-period EMA AND 21-period EMA > 50-period SMA AND 50-period SMA > 200-period SMA
Calculation: Bearish moving-average stack = 9-period EMA < 21-period EMA AND 21-period EMA < 50-period SMA AND 50-period SMA < 200-period SMA
Calculation: Reclaimed moving average = close is above the 21-period EMA or 50-period SMA now AND was not above that same average 3 bars ago
Calculation: Lost moving average = close is below the 21-period EMA or 50-period SMA now AND was not below that same average 3 bars ago
Calculation: Golden cross = 50-period SMA > 200-period SMA now AND was not greater 3 bars ago
Calculation: Death cross = 50-period SMA is not greater than 200-period SMA now AND was greater 3 bars ago
Calculation: 50-period SMA approaching 200-period SMA bullishly = 50-period SMA is not above 200-period SMA AND its percentage change over 4 bars is positive AND the absolute percentage distance between them is < 3%
Calculation: 50-period SMA approaching 200-period SMA bearishly = 50-period SMA > 200-period SMA AND its percentage change over 4 bars is negative AND their absolute percentage distance is < 3%
Calculation: Price pressing toward 200-period SMA = close > 50-period SMA AND close is not above 200-period SMA AND close is within 2% of 200-period SMA
Calculation: Bullish early trend = 9-period EMA > 21-period EMA AND (21-period EMA > 50-period SMA now AND was not greater 3 bars ago OR 21-period EMA is not above 50-period SMA AND its percentage change over 4 bars is positive AND it is within 3% of 50-period SMA)
Calculation: Bearish early trend = 9-period EMA is not above 21-period EMA AND 21-period EMA is not above 50-period SMA AND 21-period EMA was greater than 50-period SMA 3 bars ago
Calculation: Long pullback = close > 21-period EMA AND close is between 1.5% below and 3% above 21-period EMA
Calculation: Riding 9-period EMA = close > 9-period EMA AND 9-period EMA is higher than 3 bars ago AND bullish moving-average stack
Calculation: Reversal classification = any moving average was reclaimed or lost
Calculation: Breakout classification = golden cross OR death cross OR either 50-period SMA approach condition OR price pressing toward 200-period SMA
Calculation: Early-trend classification = not reversal classification AND not breakout classification AND bullish early trend OR bearish early trend
Calculation: Trend-continuation classification = not reversal classification AND not breakout classification AND not early-trend classification AND (bullish or bearish moving-average stack OR long pullback OR riding 9-period EMA)
Long: a moving average was reclaimed OR (not reversal classification AND breakout classification AND (golden cross OR bullish 50-period SMA approach OR price pressing toward 200-period SMA)) OR (not reversal classification AND not breakout classification AND early-trend classification AND bullish early trend) OR (not reversal classification AND not breakout classification AND not early-trend classification AND trend-continuation classification AND (bullish moving-average stack OR long pullback OR riding 9-period EMA))
Short: (no moving average was reclaimed AND a moving average was lost) OR (not reversal classification AND breakout classification AND (death cross OR bearish 50-period SMA approach) AND not (golden cross OR bullish 50-period SMA approach OR price pressing toward 200-period SMA)) OR (not reversal classification AND not breakout classification AND early-trend classification AND bearish early trend AND not bullish early trend) OR (not reversal classification AND not breakout classification AND not early-trend classification AND trend-continuation classification AND bearish moving-average stack AND not (bullish moving-average stack OR long pullback OR riding 9-period EMA))