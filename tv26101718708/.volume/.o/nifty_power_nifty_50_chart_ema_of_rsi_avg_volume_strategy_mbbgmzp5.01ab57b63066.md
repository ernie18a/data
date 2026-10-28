Calculation: RSI = Relative strength index of close using the shorter lookback.
Calculation: RSI EMA = Exponential moving average of RSI using a longer lookback than the RSI calculation.
Calculation: Volume average = Simple moving average of volume.
Calculation: Intraday bar count = Count of bars since the start of the current calendar day, reset to one on the first bar of each day.
Long: RSI crosses above RSI EMA AND volume > Volume average AND Intraday bar count != scheduled exit-bar index
Short: RSI < RSI EMA AND Intraday bar count != scheduled exit-bar index
Exit: Long position, RSI < RSI EMA AND Intraday bar count != scheduled exit-bar index OR Intraday bar count = scheduled exit-bar index
Exit: Short position, RSI crosses above RSI EMA AND volume > Volume average AND Intraday bar count != scheduled exit-bar index OR Intraday bar count = scheduled exit-bar index