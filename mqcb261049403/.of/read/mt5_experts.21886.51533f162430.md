Calculation: Short MA = moving average of the selected price with a shorter lookback
Calculation: Long MA = moving average of the selected price with a longer lookback
Long: On the indicator timeframe, the last completed bar's Short MA > Long MA AND the preceding bar's Short MA < Long MA
Short: On the indicator timeframe, the last completed bar's Short MA < Long MA AND the preceding bar's Short MA > Long MA
Exit: long, Short MA < Long MA AND the preceding bar's Short MA > Long MA OR price <= entry price minus stop-loss distance OR price >= entry price plus take-profit distance
Exit: short, Short MA > Long MA AND the preceding bar's Short MA < Long MA OR price >= entry price plus stop-loss distance OR price <= entry price minus take-profit distance