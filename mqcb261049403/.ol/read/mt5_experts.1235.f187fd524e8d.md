Calculation: Extremum histogram = On each indicator-timeframe bar, take the maximum of 0 and the current high minus each high in the lookback; add 0 if no lookback low is below the current low, otherwise add the current high minus the low from the last qualifying lookback bar in the indicator’s loop order. Use completed bars on the configured indicator timeframe, which may be higher or lower than the chart timeframe.
Long: Extremum histogram on the signal bar > 0 AND Extremum histogram on the immediately preceding bar < 0
Short: Extremum histogram on the signal bar < 0 AND Extremum histogram on the immediately preceding bar > 0
Exit: Long, Extremum histogram on the signal bar < 0
Exit: Short, Extremum histogram on the signal bar > 0