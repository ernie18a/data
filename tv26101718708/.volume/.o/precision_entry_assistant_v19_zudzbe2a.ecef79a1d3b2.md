Calculation: VWAP slope filter = absolute difference between current VWAP and VWAP 5 bars earlier > ATR × minimum VWAP slope multiplier
Calculation: 8-bar expansion filter = highest high over 8 bars − lowest low over 8 bars > ATR × minimum range multiplier
Calculation: Flat VWAP avoidance = absolute difference between close and VWAP < ATR × VWAP avoidance multiplier
Calculation: Bullish displacement = close > open AND close − open > ATR × minimum body multiplier AND (close − low) / (high − low) × 100 ≥ minimum directional close percentage; when high = low, use 50%
Calculation: Bearish displacement = close < open AND open − close > ATR × minimum body multiplier AND (close − low) / (high − low) × 100 ≤ 100 − minimum directional close percentage; when high = low, use 50%
Calculation: VWAP cross count = number of close/VWAP crosses between consecutive bars over the chop lookback
Calculation: EMA cross count = number of crosses between the fast and slow EMAs over the chop lookback
Calculation: Market ready = VWAP slope filter AND 8-bar expansion filter AND NOT flat VWAP avoidance AND VWAP cross count ≤ maximum VWAP crosses AND EMA cross count ≤ maximum EMA crosses
Calculation: ORB high and low = highest high and lowest low during the ORB window, accumulated from its bars and locked when that window ends; reset each day
Calculation: Long ORB breakout = ORB locked AND close > ORB high
Calculation: Short ORB breakout = ORB locked AND close < ORB low
Calculation: Long ORB retest = ORB locked AND low ≤ ORB high AND close > ORB high
Calculation: Short ORB retest = ORB locked AND high ≥ ORB low AND close < ORB low
Calculation: VWAP bounce = low ≤ VWAP AND close > VWAP AND close > open
Calculation: VWAP rejection = high ≥ VWAP AND close < VWAP AND close < open
Calculation: Low sweep = low < lowest low of the previous 8 bars AND close > low
Calculation: High sweep = high > highest high of the previous 8 bars AND close < high
Long: Market ready AND bullish displacement AND close > VWAP AND ((during NY AM session AND fast EMA > slow EMA AND NY signal count < NY signal limit AND bars since prior signal > cooldown AND (long ORB retest OR VWAP bounce OR long ORB breakout)) OR (during Asia or London session AND off-session signal count < off-session signal limit AND bars since prior signal > cooldown AND (low sweep OR VWAP bounce)))
Short: Market ready AND bearish displacement AND close < VWAP AND ((during NY AM session AND fast EMA < slow EMA AND NY signal count < NY signal limit AND bars since prior signal > cooldown AND (short ORB retest OR VWAP rejection OR short ORB breakout)) OR (during Asia or London session AND off-session signal count < off-session signal limit AND bars since prior signal > cooldown AND (high sweep OR VWAP rejection)))