Calculation: Shorter-lookback moving average = configured moving average; its lookback is shorter than the longer-lookback moving average
Calculation: Longer-lookback moving average = configured moving average
Calculation: Long stop = lowest low over the configured swing lookback at entry minus ATR times the configured risk adjustment
Calculation: Short stop = highest high over the configured swing lookback at entry plus ATR times the configured risk adjustment
Calculation: Long target = entry-signal close + reward-to-risk ratio × (entry-signal close − long stop)
Calculation: Short target = entry-signal close − reward-to-risk ratio × (short stop − entry-signal close)
Calculation: Long trailing stop = maximum of its prior value and the configured trail source minus ATR times the trail multiplier; trail source is the current rolling swing low, prior close, or prior open, according to configuration
Calculation: Short trailing stop = minimum of its prior value and the configured trail source plus ATR times the trail multiplier; trail source is the current rolling swing high, prior close, or prior open, according to configuration
Long: shorter-lookback moving average crosses above longer-lookback moving average AND ATR is available AND bar is confirmed AND time and date filters pass AND long trades are enabled AND position is flat or short with reversal enabled
Short: shorter-lookback moving average crosses below longer-lookback moving average AND ATR is available AND bar is confirmed AND time and date filters pass AND short trades are enabled AND position is flat or long with reversal enabled
Exit: Long, bar low is at or below the fixed long stop or active long trailing stop, or bar high is at or above the long target when limit exits are enabled
Exit: Short, bar high is at or above the fixed short stop or active short trailing stop, or bar low is at or below the short target when limit exits are enabled