Calculation: Bezier line = binomially weighted sum of a selected OHLC-derived price over the current bar and preceding bars, with weights determined by a smoothing parameter; calculate on the selected indicator timeframe (which may be higher or lower than the chart timeframe) using completed bars.
Long: Bezier[t-2] > Bezier[t-1] AND Bezier[t-1] < Bezier[t]
Short: Bezier[t-2] < Bezier[t-1] AND Bezier[t-1] > Bezier[t]
Exit: Long, Bezier[t] < Bezier[t-1]
Exit: Short, Bezier[t] > Bezier[t-1]