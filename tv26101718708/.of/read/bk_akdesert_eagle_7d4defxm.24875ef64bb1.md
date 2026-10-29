Calculation: Yang-Zhang volatility = the square root of the weighted sum of the variances of log open versus prior close, log close versus open, and the Rogers–Satchell range term over a lookback.
Calculation: Block geometric mean = the square root of the highest high multiplied by the lowest low in a block; compare consecutive blocks of equal length.
Calculation: Structural trend direction = compare the latest block geometric mean with the prior one; extend that direction through consecutive older blocks that continue monotonically in the same direction. Compute the angle between the latest and oldest block centers in that segment using log price divided by Yang-Zhang volatility; direction is up if the angle exceeds the range threshold, down if it is below the negative threshold, otherwise flat. The primary trend uses one block length; six additional trend directions use progressively longer block lengths.
Calculation: Structural channel rails = project channel boundaries to the current bar in log-price divided by Yang-Zhang volatility space. For an uptrend, the upper rail joins the lowest block high to the highest block high, and the lower rail joins the lowest block low to the highest block low. For a downtrend, the upper rail joins the highest block high to the lowest block high, and the lower rail joins the highest block low to the lowest block low. Use the extreme blocks in the monotonic trend segment.
Calculation: Channel position = (log(close) − log(lower rail)) / (log(upper rail) − log(lower rail)).
Calculation: Fast and slow consensus signs = sign of the sum of the three shortest and three longest of the six trend directions, respectively; zero sums have sign zero.
Long: Structural trend direction is up AND its previous value was not up
Long: Channel position > 1 while the breakout state is inside
Long: Breakout state is up breakout AND price has first moved at least one Yang-Zhang volatility above the upper rail and then returned to less than one Yang-Zhang volatility above it
Long: Breakout state is up retest AND channel position > 1 AND price is at least one Yang-Zhang volatility above the upper rail
Long: At least five of six trend directions are up AND the prior up-count was not the current count
Long: Fast consensus sign = 1 AND slow consensus sign = −1
Long: The prior channel-width-to-its-lookback-average ratio < 0.8 AND the current ratio > 1.2 AND structural trend direction is up AND fast consensus sign = 1
Short: Structural trend direction is down AND its previous value was not down
Short: Channel position < 0 while the breakout state is inside
Short: Breakout state is down breakout AND price has first moved at least one Yang-Zhang volatility below the lower rail and then returned to less than one Yang-Zhang volatility below it
Short: Breakout state is down retest AND channel position < 0 AND price is at least one Yang-Zhang volatility below the lower rail
Short: At least five of six trend directions are down AND the prior down-count was not the current count
Short: Fast consensus sign = −1 AND slow consensus sign = 1
Short: The prior channel-width-to-its-lookback-average ratio < 0.8 AND the current ratio > 1.2 AND structural trend direction is down AND fast consensus sign = −1