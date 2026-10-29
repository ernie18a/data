Calculation: Fast line = RSI of the selected applied price, smoothed with a shorter lookback on the signal timeframe, which may be higher or lower than the chart timeframe; use completed bars.
Calculation: Slow line = Fast line smoothed with a longer lookback on the signal timeframe; use completed bars.
Long: Fast line on the previous completed signal-timeframe bar <= Slow line on that bar AND Fast line on the latest completed signal-timeframe bar > Slow line on that bar
Short: Fast line on the previous completed signal-timeframe bar >= Slow line on that bar AND Fast line on the latest completed signal-timeframe bar < Slow line on that bar
Exit: Long, Fast line on the latest completed signal-timeframe bar < Slow line on that bar
Exit: Short, Fast line on the latest completed signal-timeframe bar > Slow line on that bar