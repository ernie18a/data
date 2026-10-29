Calculation: Volume-adjusted momentum = NVI − EMA(NVI), multiplied by 100 and divided by the rolling highest minus rolling lowest of EMA(NVI). NVI starts at 0; when volume is lower than the previous bar’s volume, add (close − previous close) / previous close to the previous NVI; otherwise carry it forward. The EMA uses a shorter lookback than the rolling highest and lowest.
Long: Volume-adjusted momentum > previous bar’s value AND volume-adjusted momentum > 0 AND previous bar’s value < 0
Short: Volume-adjusted momentum < previous bar’s value AND volume-adjusted momentum < 0 AND previous bar’s value > 0
Exit: Long, the long condition was true two bars earlier
Exit: Short, the short condition was true two bars earlier