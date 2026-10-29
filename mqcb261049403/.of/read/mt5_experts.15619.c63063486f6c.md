Calculation: Upper channel = smoothed bar high + range offset; when the previous trend is short, it cannot increase from its previous value
Calculation: Lower channel = smoothed bar low + range offset; when the previous trend is long, it cannot decrease from its previous value
Calculation: Trend = long if bar high > upper channel; otherwise short if bar low < lower channel; otherwise retain the previous trend. Evaluate on the MaChannel timeframe, which may be higher or lower than the chart timeframe, using the last completed bar.
Long: current trend is long AND previous trend was neutral or short
Short: current trend is short AND previous trend was neutral or long
Exit: long, current trend is short
Exit: short, current trend is long