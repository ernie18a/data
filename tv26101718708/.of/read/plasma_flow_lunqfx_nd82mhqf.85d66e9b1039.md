Calculation: Typical price = (high + low + close) / 3.
Calculation: Rolling VWAP = rolling sum of typical price × volume divided by rolling sum of volume; use typical price when the volume sum is zero.
Calculation: Rolling VWAP deviation = square root of the rolling sum of volume × (typical price on each bar − current rolling VWAP)² divided by the greater of the rolling volume sum and a positive denominator floor.
Calculation: Pressure = EMA of (typical price − rolling VWAP) / rolling VWAP deviation; use zero for the ratio when deviation is zero.
Calculation: Velocity = EMA of the percentage rate of change of rolling VWAP divided by the greater of rolling VWAP deviation and a positive price floor.
Calculation: Turbulence = rolling standard deviation of velocity divided by its longer-period SMA; use one when that SMA is not positive.
Calculation: Bullish reversal candle = lower wick > body × a wick-to-body threshold AND lower wick > candle range × a range threshold OR close > open AND previous close < previous open AND close > previous open AND open <= previous close. Lower wick = min(open, close) − low; body = abs(close − open); candle range = high − low.
Calculation: Bearish reversal candle = upper wick > body × a wick-to-body threshold AND upper wick > candle range × a range threshold OR close < open AND previous close > previous open AND close < previous open AND open >= previous close. Upper wick = high − max(open, close); body = abs(close − open); candle range = high − low.
Long: Typical price crosses above rolling VWAP minus rolling VWAP deviation × inner-band multiplier AND pressure < negative pressure threshold AND turbulence < calm threshold AND bars since the most recent long or short signal >= cooldown OR no previous signal exists, AND the reversal filter is disabled OR a bullish reversal candle occurs on the current or previous bar.
Short: Typical price crosses below rolling VWAP plus rolling VWAP deviation × inner-band multiplier AND pressure > positive pressure threshold AND turbulence < calm threshold AND bars since the most recent long or short signal >= cooldown OR no previous signal exists, AND the reversal filter is disabled OR a bearish reversal candle occurs on the current or previous bar.
Long: Chart-timeframe velocity > chart-timeframe bullish threshold.
Short: Chart-timeframe velocity < negative chart-timeframe directional threshold.
Long: Chart-timeframe velocity > chart-timeframe flow-bias threshold.
Short: Chart-timeframe velocity <= chart-timeframe flow-bias threshold.
Long: Velocity on either higher timeframe, using its last completed bar, > that timeframe's flow-bias threshold.
Short: Velocity on either higher timeframe, using its last completed bar, <= that timeframe's flow-bias threshold.
Calculation: Higher-timeframe velocity uses the same velocity formula with its own rolling VWAP window; the chart-timeframe flow-bias threshold is higher than the threshold for the shorter higher timeframe, which is higher than the threshold for the longer higher timeframe.
Exit: long, turbulence > turbulent threshold OR abs(pressure) > breakout threshold.
Exit: short, turbulence > turbulent threshold OR abs(pressure) > breakout threshold.