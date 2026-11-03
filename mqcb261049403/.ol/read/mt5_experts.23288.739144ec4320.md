Calculation: Rolling high and low = highest high and lowest low over the configured number of work-timeframe bars, including the currently forming bar and preceding completed bars; the work timeframe may be higher or lower than the chart timeframe.
Long: bar high >= rolling high + entry indent AND (time control is disabled OR datetime is within 30 minutes before or after the configured start time)
Short: bar low <= rolling low - entry indent AND (time control is disabled OR datetime is within 30 minutes before or after the configured start time)
Exit: Long, price <= active stop loss OR price >= take profit
Exit: Short, price >= active stop loss OR price <= take profit