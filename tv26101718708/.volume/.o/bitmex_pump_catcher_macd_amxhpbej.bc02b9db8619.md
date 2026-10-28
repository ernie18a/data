Calculation: Relative volume = current rolling 24-bar volume sum divided by the average of the 50 preceding, non-overlapping 24-bar volume sums
Calculation: MACD = shorter-lookback EMA of close − longer-lookback EMA of close
Calculation: MACD change = current MACD − previous bar’s MACD
Calculation: Fast volume EMA = shorter-lookback EMA of relative volume
Calculation: Slow volume EMA = longer-lookback EMA of relative volume
Long: Relative volume crosses above its threshold AND slow volume EMA is rising AND MACD change > 0
Short: Relative volume crosses above its threshold AND slow volume EMA is rising AND MACD change < 0
Exit: Long, slow volume EMA > fast volume EMA OR MACD change < 0 AND relative volume crosses above its threshold AND slow volume EMA is rising OR low <= entry price − (entry price / leverage × stop-loss percentage / 100)
Exit: Short, slow volume EMA > fast volume EMA OR MACD change > 0 AND relative volume crosses above its threshold AND slow volume EMA is rising OR high >= entry price + (entry price / leverage × stop-loss percentage / 100)