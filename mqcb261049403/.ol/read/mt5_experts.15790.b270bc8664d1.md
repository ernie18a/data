Calculation: JFATL line = the JMA-smoothed 39-bar FATL weighted sum of selected applied prices, rounded to configured precision
Calculation: Trend state = sign of the JFATL line’s change from the prior bar; when unchanged, carry forward the prior nonzero state, initially neutral
Long: On the configured indicator timeframe (higher or lower than the chart timeframe), using last completed bars: current trend state is rising AND prior trend state is not rising
Short: On the configured indicator timeframe (higher or lower than the chart timeframe), using last completed bars: current trend state is falling AND prior trend state is not falling
Exit: long, On the configured indicator timeframe (higher or lower than the chart timeframe), current last-completed-bar trend state is falling
Exit: short, On the configured indicator timeframe (higher or lower than the chart timeframe), current last-completed-bar trend state is rising