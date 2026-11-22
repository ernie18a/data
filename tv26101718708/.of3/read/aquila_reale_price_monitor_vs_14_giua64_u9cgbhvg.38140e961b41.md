Calculation: Chart-Bar Percent Change = 100 × (close − close[1]) / close[1] on chart bars
Calculation: Gold Driver Score = (1 if short-yield percent change < −sensitivity, −1 if > sensitivity, otherwise 0) + (1 if dollar percent change < −sensitivity, −1 if > sensitivity, otherwise 0)
Calculation: Yield-Curve Change = long-yield Chart-Bar Percent Change − short-yield Chart-Bar Percent Change
Long: current T1 close of the 10-year yield series − current T1 close of the 10-year breakeven series < real-yield threshold, using current T1 values mapped to chart bars (T1 bar still forming in real time)
Short: current T1 close of the 10-year yield series − current T1 close of the 10-year breakeven series ≥ real-yield threshold, using current T1 values mapped to chart bars (T1 bar still forming in real time)
Long: Gold Driver Score > 0
Short: Gold Driver Score < 0
Long: Yield-Curve Change > sensitivity AND short-yield Chart-Bar Percent Change < −sensitivity
Short: (Yield-Curve Change > sensitivity AND short-yield Chart-Bar Percent Change ≥ −sensitivity AND long-yield Chart-Bar Percent Change > sensitivity) OR (Yield-Curve Change < −sensitivity AND short-yield Chart-Bar Percent Change ≥ −sensitivity)
Calculation: chart-timeframe percentage change in an external series = (current chart-timeframe close - previous chart-timeframe close) / previous chart-timeframe close * 100
Calculation: gold-bias score = sum for US 2Y yield and DXY of +1 when chart-timeframe percentage change < -bias sensitivity, -1 when chart-timeframe percentage change > bias sensitivity, and 0 otherwise
Calculation: yield-change differential = chart-timeframe percentage change in US 10Y yield - chart-timeframe percentage change in US 2Y yield
Long: US 10Y yield at T1 close - 10Y breakeven yield at T1 close < real-yield threshold
Short: US 10Y yield at T1 close - 10Y breakeven yield at T1 close >= real-yield threshold
Long: gold-bias score > 0
Short: gold-bias score < 0
Long: yield-change differential > bias sensitivity AND chart-timeframe percentage change in US 2Y yield < -bias sensitivity
Short: yield-change differential > bias sensitivity AND chart-timeframe percentage change in US 2Y yield >= -bias sensitivity AND chart-timeframe percentage change in US 10Y yield > bias sensitivity
Short: yield-change differential < -bias sensitivity AND chart-timeframe percentage change in US 2Y yield >= -bias sensitivity