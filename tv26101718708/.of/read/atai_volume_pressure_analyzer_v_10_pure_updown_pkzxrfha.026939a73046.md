Calculation: Estimated up volume = volume × (close − low) / (high − low); when high = low, volume / 2
Calculation: Estimated down volume = volume × (high − close) / (high − low); when high = low, volume / 2
Calculation: Directional volume spike = volume / its simple moving average ≥ spike ratio OR (volume − its simple moving average) / its standard deviation ≥ z-score threshold
Calculation: Oscillator vote count = number of overbought or oversold conditions among RSI, stochastic, Williams %R, CCI, MFI, DeMarker, and stochastic RSI; use the maximum count from the current bar and the configured number of preceding bars
Calculation: Wing slope angle = arctangent of ((later high or low − earlier high or low) / bars between the two points / ATR), in degrees; the left wing spans the older half of the lookback window and the right wing spans the newer half
Long: Estimated up volume has a directional volume spike AND the oversold oscillator vote count ≥ minimum votes
Long: Right-wing high and low slope angles are both ≥ the near-zero angle threshold
Short: Estimated down volume has a directional volume spike AND the overbought oscillator vote count ≥ minimum votes
Short: Right-wing high and low slope angles are both ≤ − the near-zero angle threshold