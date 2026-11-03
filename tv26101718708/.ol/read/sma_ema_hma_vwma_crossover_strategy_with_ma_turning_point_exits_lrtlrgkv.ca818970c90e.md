Long: the shorter-lookback moving average crosses above the longer-lookback moving average
Short: the shorter-lookback moving average crosses below the longer-lookback moving average
Calculation: Rate of change = percentage change in the shorter-lookback moving average over a lookback period
Calculation: Slope state = Up when rate of change crosses above a positive slope threshold; Down when it crosses below the corresponding negative threshold; otherwise retain the prior state
Exit: Short, rate of change crosses above the positive slope threshold AND the prior slope state was Down
Exit: Long, rate of change crosses below the negative slope threshold AND the prior slope state was Up