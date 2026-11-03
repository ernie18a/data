Calculation: Rounded moving average = round to a configurable price increment the sum 8E1 − 28E2 + 56E3 − 70E4 + 56E5 − 28E6 + 8E7 − E8, where E1 is the EMA of a configurable OHLC-derived price and each subsequent En is the EMA of E(n−1), all with the same length; initialize each EMA from its first valid input, with successive stages starting on successive bars.
Calculation: Trend = the sign of the latest nonzero bar-to-bar change in the rounded moving average; retain the previous trend when the change is zero.
Long: Chart-timeframe trend > 0.
Short: Chart-timeframe trend < 0.
Long: Long-system trend on the last completed higher-timeframe bar > 0 AND its trend on the preceding higher-timeframe bar <= 0.
Short: Short-system trend on the last completed higher-timeframe bar < 0 AND its trend on the preceding higher-timeframe bar >= 0.
Exit: long, long-system trend on the last completed higher-timeframe bar < 0.
Exit: short, short-system trend on the last completed higher-timeframe bar > 0.
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.