Calculation: Volume delta = volume × ((close - low) - (high - close)) ÷ (high - low), or 0 when high = low
Calculation: CVD = start at zero; reset to Volume delta at a reset boundary selected by the reset-period parameter; otherwise prior CVD + Volume delta
Calculation: Absorption = volume > SMA(volume, volume-average lookback) × volume-multiple AND ABS(close - open) < ATR(ATR lookback) × maximum-body fraction
Calculation: Bullish pivot divergence = a confirmed pivot low(low, divergence swing length, divergence swing length) is below the previous confirmed pivot low AND CVD at the current pivot is above CVD at the previous pivot
Calculation: Bearish pivot divergence = a confirmed pivot high(high, divergence swing length, divergence swing length) is above the previous confirmed pivot high AND CVD at the current pivot is below CVD at the previous pivot
Long: Volume delta >= 0
Short: Volume delta < 0
Long: CVD >= 0
Short: CVD < 0
Long: Bullish pivot divergence
Short: Bearish pivot divergence
Long: Absorption AND Volume delta >= 0
Short: Absorption AND Volume delta < 0
Long: CVD crosses above 0
Short: CVD crosses below 0
Long: NOT Bearish pivot divergence AND NOT Bullish pivot divergence AND NOT Absorption AND CVD >= CVD[1]
Short: NOT Bearish pivot divergence AND NOT Bullish pivot divergence AND NOT Absorption AND CVD < CVD[1]