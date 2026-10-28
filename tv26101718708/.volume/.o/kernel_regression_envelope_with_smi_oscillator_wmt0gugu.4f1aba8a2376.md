Calculation: Nadaraya-Watson estimate = rational-quadratic-kernel weighted regression of the source over its lookback window, starting at the specified bar; calculate separately for close, high, and low.
Calculation: Envelope ATR = RMA of true range calculated from the Nadaraya-Watson high, low, and close estimates.
Calculation: Lower and upper bands = Nadaraya-Watson close estimate minus or plus the Envelope ATR multiplied by the ATR factor.
Calculation: SMI = 200 × double-EMA-smoothed (chart close minus midpoint of the highest high and lowest low) divided by double-EMA-smoothed (highest high minus lowest low); highest high and lowest low use the higher-timeframe bars over the SMI lookback, using the last completed higher-timeframe bar. The double EMA uses the chart timeframe.
Calculation: SMI signal = EMA of SMI using the chart timeframe.
Long: close is below the lower band AND SMI crosses above its signal AND SMI is below -50
Short: close is above the upper band AND SMI crosses below its signal AND SMI is above 50
Exit: long, close crosses above the upper band OR low reaches the fixed stop-loss price below the entry price
Exit: short, close crosses below the lower band OR high reaches the fixed stop-loss price above the entry price