Calculation: 1-minute price range = highest high minus lowest low over the lookback; recent volume = average volume over that lookback; baseline volume = 20-bar average volume
Calculation: 2-hour move (%) = (current close − close 120 chart bars ago) / close 120 chart bars ago × 100
Calculation: Daily range = highest high minus lowest low since the current day opened; daily open = open of the first bar of the current day
Calculation: Morning Star = a bearish candle two bars ago, followed by a candle body less than half the first candle's body, followed by a bullish candle closing above the first candle's midpoint
Calculation: Recent pivot low/high = confirmed pivot using configurable left and right lookbacks
Calculation: Major low nearby = a confirmed pivot low occurred within the configurable lookback
Calculation: Bullish squeeze momentum = linear regression of close minus the average of the midpoint between the lookback high and low and the lookback close average; value > 0
Calculation: Bearish squeeze momentum = bullish squeeze momentum value ≤ 0
Long: Confirmed pivot low AND ATR ≥ threshold AND current bar range ≤ 5-bar ATR × multiplier AND Tuesday or Wednesday in GMT+7, excluding Tuesday from 15:00 onward and Wednesday at 08:00 or 22:00 AND the open from two completed hourly bars ago is below that bar's close AND 50-bar SMA slope (current SMA minus its value five bars ago) > −flat threshold AND close is not above the current day's low plus 95% of its range AND 2-hour move ≤ maximum threshold AND position is flat AND no post-TP wait remains AND no squeeze-release wait is active
Long: Confirmed pivot low AND 50-bar SMA is red AND close is below the SMA, subject to the same entry filters
Long: Close > 50-bar SMA AND RSI(14) > 55 AND volume > 20-bar average volume × volume multiplier AND close > last confirmed pivot high
Long: Trending ADX AND close > 50-bar SMA AND RSI(14) crosses above 55 AND volume > 20-bar average volume × volume multiplier AND close > last confirmed pivot high
Long: Bullish 1-minute spike = 1-minute price range ≥ threshold AND recent 1-minute average volume > baseline volume × multiplier AND 1-minute close > open from the first bar in the lookback
Short: Confirmed pivot high AND close < 50-bar SMA AND RSI(14) < 50, subject to the same entry filters
Short: Close < 50-bar SMA AND RSI(14) < 45 AND volume > 20-bar average volume × volume multiplier AND close < last confirmed pivot low
Short: Trending ADX AND close < 50-bar SMA AND RSI(14) crosses below 45 AND volume > 20-bar average volume × volume multiplier AND close < last confirmed pivot low
Short: Bearish 1-minute spike = 1-minute price range ≥ threshold AND recent 1-minute average volume > baseline volume × multiplier AND 1-minute close ≤ open from the first bar in the lookback
Exit: Long, close ≥ entry price + 30-bar close SMA × take-profit percentage
Exit: Long, close ≤ entry price − 30-bar close SMA × stop-loss percentage
Exit: Long, bearish 1-minute spike OR bearish breakdown
Exit: Short, close ≤ entry price − 30-bar close SMA × take-profit percentage
Exit: Short, close ≥ entry price + 30-bar close SMA × stop-loss percentage
Exit: Long or short, bullish 1-minute spike OR bearish 1-minute spike