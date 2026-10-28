Calculation: Session VWAP = cumulative sum of ((high + low + close) / 3 × volume) divided by cumulative volume, reset each session
Calculation: Volume average = simple moving average of volume over a lookback
Long: close < session VWAP - ATR × distance AND volume < volume average AND time is 09:45–15:14 ET AND position is flat
Short: close > session VWAP + ATR × distance AND volume < volume average AND time is 09:45–15:14 ET AND position is flat
Exit: long, low <= entry-signal close - ATR at entry × stop multiplier OR high >= session VWAP at entry
Exit: short, high >= entry-signal close + ATR at entry × stop multiplier OR low <= session VWAP at entry