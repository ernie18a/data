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