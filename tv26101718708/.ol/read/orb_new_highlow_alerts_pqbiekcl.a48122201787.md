Calculation: Opening-range high = highest high during the initial configured interval of the regular session
Calculation: Opening-range low = lowest low during the initial configured interval of the regular session
Calculation: Confirm close = close of the confirm-timeframe bar; when that timeframe is higher than the chart, use its last completed bar, otherwise use the completed chart bar
Calculation: Consecutive closes beyond a level = count of consecutive completed confirm closes above the level for long breaks, or below it for short breaks; reset to zero when a close does not remain beyond the level
Calculation: Trail EMA = exponential moving average of confirm closes
Calculation: Short-lookback high = highest high over the shorter rolling window, excluding the current bar
Calculation: Long-lookback high = highest high over the longer rolling window, excluding the current bar
Long: regular session and opening range complete AND (high > opening-range high OR consecutive closes beyond opening-range high >= configured count) OR (regular session and opening range complete AND high > long-lookback high AND no new high for at least the configured pause interval) OR (regular session and opening range complete AND high > short-lookback high AND no new high for at least the configured pause interval)
Short: regular session and opening range complete AND (low < opening-range low OR consecutive closes beyond opening-range low >= configured count)
Exit: long position, confirm close < trail EMA from the preceding confirm bar
Exit: short position, confirm close > trail EMA from the preceding confirm bar