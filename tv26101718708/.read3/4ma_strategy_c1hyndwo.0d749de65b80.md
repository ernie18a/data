Calculation: Fast Hull MA = HMA(close, HullMA lookback)
Calculation: Slow Hull-derived average = WMA(2 * WMA(close, round(HullMA lookback / 2)) - WMA(close, HullMA lookback), HullMA lookback)
Long: no open position AND Fast Hull MA > Slow Hull-derived average AND Fast Hull MA < WMA(close, Base Weighted MA lookback) AND Fast Hull MA > VWMA(close, Volume-Weighted MA lookback)
Short: no open position AND Fast Hull MA < Slow Hull-derived average AND Fast Hull MA > WMA(close, Base Weighted MA lookback) AND Fast Hull MA < VWMA(close, Volume-Weighted MA lookback)