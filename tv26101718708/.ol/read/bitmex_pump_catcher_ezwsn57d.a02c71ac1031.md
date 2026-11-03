Calculation: Relative volume = current rolling sum of volume divided by the long-term average of rolling volume sums sampled at intervals equal to the rolling window length
Long: Relative volume crosses above the threshold AND close > close N bars ago AND the slower EMA of relative volume > its value on the previous bar
Short: Relative volume crosses above the threshold AND close < close N bars ago AND the slower EMA of relative volume > its value on the previous bar
Exit: Long, slower EMA of relative volume > faster EMA of relative volume
Exit: Short, slower EMA of relative volume > faster EMA of relative volume