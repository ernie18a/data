Calculation: Renko direction = up when the synthetic Renko close rises from the prior value, down when it falls; update that value when the selected price source exceeds the prior value by the brick size, which is derived from the selected ATR, fixed-size, or close-relative method.
Long: Close > upper Bollinger Band AND Renko direction is up
Short: Close < lower Bollinger Band AND Renko direction is down
Exit: long, High >= entry price + take-profit distance OR Low <= entry price - stop-loss distance