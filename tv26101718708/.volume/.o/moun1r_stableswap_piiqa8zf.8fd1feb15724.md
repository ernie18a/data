Calculation: Renko close = close of Renko bars built from the chart symbol using open prices and ATR sizing; use the bar aligned with the current chart bar, which is still forming.
Calculation: LSMA = linear regression of the simple moving average of Renko close, using current and earlier chart bars; the current bar is still forming.
Long: LSMA crosses below VWAP AND close > Renko close OR previous Renko close < current Renko close AND close > Renko close
Exit: long, close crosses below VWAP