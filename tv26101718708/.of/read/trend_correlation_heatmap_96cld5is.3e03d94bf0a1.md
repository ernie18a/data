Calculation: Trend correlation = Pearson correlation of close and bar opening datetime over a lookback, calculated for each selected lookback and timeframe; use the last completed bar for higher timeframes and the last completed intrabar within the chart bar for lower timeframes.
Calculation: Maximum correlation = maximum trend correlation across all selected lookbacks and timeframes.
Calculation: Minimum correlation = minimum trend correlation across all selected lookbacks and timeframes.
Long: Trend correlation >= positive correlation threshold.
Short: Trend correlation <= negative correlation threshold.
Long: Maximum correlation > maximum correlation a specified number of chart bars ago AND minimum correlation > minimum correlation the same number of chart bars ago.
Short: Maximum correlation <= maximum correlation a specified number of chart bars ago AND minimum correlation <= minimum correlation the same number of chart bars ago.