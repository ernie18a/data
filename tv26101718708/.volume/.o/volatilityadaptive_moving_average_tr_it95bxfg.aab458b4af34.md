Calculation: Volatility-adaptive moving average = selected EMA, DEMA, RMA, or TEMA with a variable period, applied to close
Calculation: Variable period = clamp the selected dynamic-period length minus (current ATR divided by its selected moving average × ratio length), between the current ATR-to-average ratio and the selected dynamic-period length; optionally smooth this period with an SMA
Long: Close crosses above the volatility-adaptive moving average
Short: Close crosses below the volatility-adaptive moving average