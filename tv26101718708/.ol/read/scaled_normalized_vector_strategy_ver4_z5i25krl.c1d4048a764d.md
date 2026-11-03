Calculation: Relative close change = shorter requested-timeframe close / longer requested-timeframe close - 1; each timeframe is relative to the other and may be higher or lower than the chart timeframe. Use each requested bar’s current value (forming in realtime, last completed historically).
Calculation: Transformed relative close change = apply the selected transform to relative close change: identity; leaky ReLU max(x,0) - 0.8×max(-x,0); step (1 if x≥0, otherwise -1); swish x/(1+exp(-x)); or (x−mean)/|x−mean/(bar index−1)|, where mean is cumulative x divided by bar index.
Calculation: Normalized Karobein oscillator = min-max scale to [-1,1] the value 2r/(r+ca)−1, where d=EMA(source,p), r=d/d[1], a=EMA(r if d<d[1] else 0,p), b=EMA(r if d>d[1] else 0,p), and c=r/(r+b); source defaults to close and all EMAs use the same period p.
Long: Transformed relative close change crosses above sensitivity AND Normalized Karobein oscillator > 0 AND current signal is not long
Short: Transformed relative close change crosses below −sensitivity AND Normalized Karobein oscillator < 0 AND current signal is not short
Exit: Long, bars since entry = holding period
Exit: Short, bars since entry = holding period
Exit: Long, short decision occurs
Exit: Short, long decision occurs