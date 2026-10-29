Calculation: Short-term EMA = EMA of close with a shorter lookback, calculated on the chart timeframe.
Calculation: Long-term EMA = EMA of close with a longer lookback than the short-term EMA, calculated on a lower timeframe using its bar still forming.
Calculation: Controller EMA = EMA of close with the same lookback as the long-term EMA, calculated on a lower timeframe using its bar still forming.
Long: Long-term EMA crosses above Controller EMA OR (Short-term EMA crosses above Long-term EMA AND Long-term EMA >= Controller EMA)
Short: Long-term EMA crosses below Controller EMA OR (Short-term EMA crosses below Long-term EMA AND Long-term EMA <= Controller EMA)
Exit: Long, Long-term EMA crosses below Controller EMA OR (Short-term EMA crosses below Long-term EMA AND Long-term EMA >= Controller EMA)
Exit: Short, Long-term EMA crosses above Controller EMA OR (Short-term EMA crosses above Long-term EMA AND Long-term EMA <= Controller EMA)