Calculation: EMA = exponential moving average of close with a lookback longer than the swing-detection lookback
Calculation: Dow trend = retain the latest confirmed swing high and low; confirm a swing using a centered window with the swing-detection lookback on each side; set trend up when close > latest swing high, down when close < latest swing low, otherwise retain the prior trend
Calculation: ADX threshold = rolling median of ADX over a longer lookback, or a configurable threshold when automatic calibration is off
Calculation: ATR factor = base factor adjusted inversely to current ATR as a percentage of close relative to its longer-lookback average
Calculation: Stop-loss percentage = negative smoothed ATR percentage multiplied by a factor, clamped to a configurable minimum and maximum loss; or a configurable percentage when automatic calibration is off
Calculation: Footprint delta = footprint buy volume − footprint sell volume; smooth it with a shorter lookback
Long: EMA > its prior value AND Dow trend is up AND ADX > ADX threshold AND (footprint filter is disabled OR footprint delta SMA is unavailable OR footprint delta SMA > 0)
Short: EMA < its prior value AND Dow trend is down AND ADX > ADX threshold AND (footprint filter is disabled OR footprint delta SMA is unavailable OR footprint delta SMA < 0)
Exit: Long, long return percentage < stop-loss percentage OR break-even stop is active AND low <= entry price OR Dow trend is down OR high > entry price + entry-bar ATR × ATR factor
Exit: Long, long return percentage < stop-loss percentage OR break-even stop is active AND low <= entry price OR Dow trend is down OR high > entry price + 2 × entry-bar ATR × ATR factor
Exit: Long, long return percentage < stop-loss percentage OR break-even stop is active AND low <= entry price OR Dow trend is down OR high > entry price + 3 × entry-bar ATR × ATR factor
Exit: Short, short return percentage < stop-loss percentage OR break-even stop is active AND high >= entry price OR Dow trend is up OR low < entry price − entry-bar ATR × ATR factor
Exit: Short, short return percentage < stop-loss percentage OR break-even stop is active AND high >= entry price OR Dow trend is up OR low < entry price − 2 × entry-bar ATR × ATR factor
Exit: Short, short return percentage < stop-loss percentage OR break-even stop is active AND high >= entry price OR Dow trend is up OR low < entry price − 3 × entry-bar ATR × ATR factor