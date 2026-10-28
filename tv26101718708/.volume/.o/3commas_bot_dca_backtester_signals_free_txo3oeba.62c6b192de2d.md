Calculation: MACD = 12-period SMA(close) − 26-period SMA(close); signal line = 9-period SMA(MACD)
Calculation: Stochastic RSI %K = 3-period SMA of the 14-period stochastic of 14-period RSI(close); %D = 3-period SMA(%K)
Calculation: DCA deviation = initial deviation for the first safety order; each later deviation = prior deviation × multiplier + initial deviation. DCA price = first entry price × (1 − deviation)
Long: no open position AND selected signal is true: MFI(close, volume) ≤ threshold OR RSI(close) ≤ threshold OR MACD crosses above its signal line OR Stochastic RSI %K crosses above %D
Long: long position open AND open order count is below the configured maximum AND low ≤ next DCA price
Exit: long, high ≥ position average entry price × (1 + take-profit percentage) OR (stop loss enabled AND open order count equals configured maximum AND low ≤ last order entry price × (1 − stop-loss percentage))