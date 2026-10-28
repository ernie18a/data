Calculation: Close MA = selected moving average of close on the alternate timeframe
Calculation: Open MA = the same selected moving average of open on the alternate timeframe
Calculation: Current-timeframe ATR = average true range on the chart timeframe
Calculation: Alternate-timeframe ATR = average true range on the alternate timeframe
Calculation: Long trailing stop = maximum of the previous long trailing stop and close × (1 − configured long trail percentage)
Calculation: Short trailing stop = minimum of the previous short trailing stop and close × (1 + configured short trail percentage)
Long: Close MA > Open MA OR Close MA > Open MA + configured ATR multiple × Current-timeframe ATR OR Close MA crosses above Open MA + configured ATR multiple × Current-timeframe ATR OR previous completed alternate-timeframe Close MA > previous completed alternate-timeframe Open MA + configured ATR multiple × Alternate-timeframe ATR
Short: Close MA < Open MA OR Close MA < Open MA − configured ATR multiple × Current-timeframe ATR OR Close MA crosses below Open MA − configured ATR multiple × Current-timeframe ATR OR previous completed alternate-timeframe Close MA < previous completed alternate-timeframe Open MA − configured ATR multiple × Alternate-timeframe ATR
Exit: long, short-entry condition AND trade mode is long-only AND current time is within the configured trading date range OR low ≤ long trailing stop while long trailing stop is enabled
Exit: short, long-entry condition AND trade mode is short-only AND current time is within the configured trading date range OR high ≥ short trailing stop while short trailing stop is enabled