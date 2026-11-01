Calculation: Braid spread = maximum minus minimum of the short-period moving average of close, the medium-period moving average of open, and the long-period moving average of close; use the same moving-average type for all three.
Calculation: Demand pressure = moving average of volume × max(close − open, 0); supply pressure = moving average of volume × max(open − close, 0), using the same lookback. Demand share and supply share are their respective pressures divided by their sum; if the sum is zero, both shares are equal.
Calculation: Net directional volume = sum, across three selected timeframes, of rolling bullish-candle volume minus rolling bearish-candle volume; bullish candles include close = open. Use the same lookback in each timeframe. For a higher timeframe use the last completed bar; for a lower timeframe use the last completed intrabar within the chart bar; a selected timeframe may also equal the chart timeframe.
Calculation: Confirmed pivot high or low = a high or low that is the extreme among the same number of bars before and after it; recognize it on the confirmation bar. Temporary pivots use a shorter lookback than major pivots. Retain the previous temporary pivot of each kind, initialized to zero.
Calculation: Order-block swings = start with upward trend; switch to downward trend when the low at the swing lookback is less than or equal to every subsequent low through the current bar, and switch to upward trend when the high at that lookback is greater than or equal to every subsequent high through the current bar. Record the low or high at the lookback on the respective switch. After at least two recorded swing lows, the first close below the latest swing low creates a supply block whose value is the maximum high from the bar after that swing low through the current bar; permit another supply block only after a subsequent upward swing when at least two swing highs exist. After at least two recorded swing highs, the first close above the latest swing high creates a demand block whose value is the minimum low from the bar after that swing high through the current bar; permit another demand block only after a subsequent downward swing when at least two swing lows exist. Retain blocks in creation order, discard the oldest when the retention limit is exceeded, and inspect only the configured number of newest blocks per side on each bar. Delete an inspected demand block when close < its value and an inspected supply block when close > its value.
Calculation: Rolling-extreme direction = bullish when the most recent bar attaining the rolling highest high is later than the most recent bar attaining the rolling lowest low; bearish otherwise.
Long: Supertrend direction changes from bearish to bullish.
Short: Supertrend direction changes from bullish to bearish.
Long: Supertrend direction is bullish.
Short: Supertrend direction is bearish.
Long: Short-period moving average of close > medium-period moving average of open AND braid spread > ATR × separation factor.
Short: Medium-period moving average of open > short-period moving average of close AND braid spread > ATR × separation factor.
Long: Close > open.
Short: Close < open.
Long: RSI > upper threshold.
Short: RSI < lower threshold.
Long: Demand share > its neutral threshold.
Short: Supply share > its neutral threshold.
Long: Net directional volume >= 0.
Short: Net directional volume < 0.
Long: A major pivot low is confirmed.
Short: A major pivot high is confirmed.
Long: A temporary pivot low is confirmed AND its value < the preceding temporary pivot low.
Short: A temporary pivot high is confirmed AND its value > the preceding temporary pivot high.
Long: Each of the current and two preceding candles closes below its open.
Short: Each of the current and two preceding candles closes above its open.
Long: Close >= an inspected surviving demand-block value AND close <= that value + current ATR.
Short: Close <= an inspected surviving supply-block value AND close >= that value − current ATR.
Long: The latest confirmed trendline pivot low > the preceding confirmed trendline pivot low.
Short: The latest confirmed trendline pivot high < the preceding confirmed trendline pivot high.
Long: Rolling-extreme direction changes from bearish to bullish.
Short: Rolling-extreme direction changes from bullish to bearish.