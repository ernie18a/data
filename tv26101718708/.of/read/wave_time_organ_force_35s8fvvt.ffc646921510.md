Calculation: Organ Value = EMA of the sum of the z-scores of the one-bar change in EMA(close), close rate of change, one-bar change in On-Balance Volume, and one-bar change in ATR multiplied by direction (+1 when close is above EMA(close), otherwise −1)
Calculation: Organ Flow = EMA of Organ Value
Calculation: Signal line = EMA of Organ Flow
Calculation: Timeframe Force = EMA of a weighted sum of Organ Values from six configured timeframe layers, each using its last completed bar; layers may be higher or lower than the chart timeframe
Calculation: Bullish layer count = number of the six timeframe Organ Values greater than zero
Calculation: Bearish layer count = number of the six timeframe Organ Values less than zero
Long: Organ Flow crosses above Signal line AND Organ Flow > 0 AND Timeframe Force > 0 AND Bullish layer count >= 4
Short: Organ Flow crosses below Signal line AND Organ Flow < 0 AND Timeframe Force < 0 AND Bearish layer count >= 4