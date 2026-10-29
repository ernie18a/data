Long: chart close > open of each of the four configured higher-timeframe bars (use each still-forming bar) AND datetime is within the configured trading session
Short: chart close <= open of each of the four configured higher-timeframe bars (use each still-forming bar) AND datetime is within the configured trading session
Calculation: Long trailing stop = maximum of the previous long trailing stop and current close × (1 − configured long loss percentage)
Calculation: Short trailing stop = minimum of the previous short trailing stop and current close × (1 + configured short loss percentage)
Exit: Long, low <= long trailing stop
Exit: Short, high >= short trailing stop
Exit: Long or short, datetime equals the configured daily close time