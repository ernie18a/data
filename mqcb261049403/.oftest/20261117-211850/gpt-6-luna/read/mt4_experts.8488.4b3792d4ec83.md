Calculation: Short EMA = short-lookback exponential moving average of close on the chart timeframe, using the last completed bar.
Calculation: Long EMA = long-lookback exponential moving average of close on the chart timeframe, using the last completed bar; its lookback is longer than the short EMA lookback.
Calculation: Correlation measure = sum of paired deviations from each instrument’s simple moving average on the fixed higher timeframe, divided by the square root of the product of each instrument’s summed squared deviations; use the chart timeframe’s period value as both the moving-average lookback and the number of shifts, including the still-forming higher-timeframe bar.
Long: Short EMA > Long EMA AND RSI of close on the chart timeframe at the still-forming bar is at or below its lower threshold AND Correlation measure < 0.
Short: Short EMA < Long EMA AND RSI of close on the chart timeframe at the still-forming bar is at or above its upper threshold AND Correlation measure < 0.
Exit: long, total open-order profit including swaps > take-profit threshold.
Exit: short, total open-order profit including swaps > take-profit threshold.