Calculation: Zero Point Force (ZPF) = volume moving average × (short-term moving average of the selected applied price − longer-term moving average of the selected applied price) ÷ 2; the two price averages use the same smoothing method, and the longer lookback is twice the shorter lookback. Calculate on the indicator timeframe, which may be higher or lower than the chart timeframe, using completed bars.
Long: previous completed ZPF ≤ 0 AND latest completed ZPF > 0
Short: previous completed ZPF ≥ 0 AND latest completed ZPF < 0
Exit: long, latest completed ZPF < 0
Exit: short, latest completed ZPF > 0