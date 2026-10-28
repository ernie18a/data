Calculation: Composite = 3-bar weighted moving average of the weighted mean of RSI, MFI, Stochastic, Williams %R + 100, CCI scaled from [-250,250] to [0,100], ROC scaled from [-10,10] to [0,100], Bull/Bear Power scaled by ±3 ATR, Awesome Oscillator scaled by ±2 ATR(34), Momentum scaled by ±5 ATR, and Fisher Transform scaled from [-2.5,2.5] to [0,100]; use configurable component weights.
Calculation: Signal = 9-bar EMA of Composite.
Calculation: Bull consensus = count of RSI, MFI, Stochastic, and normalized CCI above 50.
Calculation: Bear consensus = count of RSI, MFI, Stochastic, and normalized CCI below 50.
Calculation: Higher-timeframe Composite = Composite calculated on the higher-timeframe bar still forming.
Long: Composite crosses above Signal AND Composite < oversold threshold AND Higher-timeframe Composite > 50 AND Bull consensus >= 3 of 4.
Short: Composite crosses below Signal AND Composite > overbought threshold AND Higher-timeframe Composite < 50 AND Bear consensus >= 3 of 4.