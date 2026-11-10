Calculation: Confirmed swing high/low = a high/low at the center of a symmetric swing-detection window, confirmed after the same number of later bars. Retain the most recently confirmed high and low separately; replace each when a new one is confirmed. Clear the high after an enabled bearish sweep or bullish structure break, and clear the low after an enabled bullish sweep or bearish structure break. Process new confirmations, sweeps, and structure breaks in that order on each bar.
Calculation: Structure bias = initially neutral; set to bullish on an enabled bullish structure break and bearish on an enabled bearish structure break, retaining the last value otherwise.
Calculation: Volume profile = on the last chart bar only, divide the highest-high to lowest-low range over the profile lookback into equal price bins. Assign each available lookback bar's entire volume to the bin containing its high-low midpoint, clamping the bin index to the valid range; exclude the first chart bar. The point of control is the midpoint of the first bin with maximum volume. Starting at that bin, expand the value area one adjacent bin at a time toward the larger adjacent volume, choosing the upper bin on ties when available, until the included volume reaches the specified fraction of total volume or no further bin can be added. Value area high and low are the outer edges of the included bins. These levels are undefined before the last chart bar in a historical calculation.
Long: low < retained swing low AND close > retained swing low
Long: close > retained swing high
Long: structure bias = bullish
Long: low > high two bars ago AND previous close > high two bars ago
Long: close < value area low
Long: close > point of control AND previous close <= previous point of control
Long: close > value area low AND previous close <= previous value area low AND previous close < current value area low
Short: high > retained swing high AND close < retained swing high
Short: close < retained swing low
Short: structure bias = bearish
Short: high < low two bars ago AND previous close < low two bars ago
Short: close > value area high
Short: close < point of control AND previous close >= previous point of control
Short: close < value area high AND previous close >= previous value area high AND previous close > current value area high