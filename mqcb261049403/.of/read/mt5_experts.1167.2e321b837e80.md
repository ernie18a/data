Calculation: Ideal smoother S(x; a, b) = initialize S to the first input x; for each subsequent bar, d = x[current] - x[previous], q = d² - 1, and S[current] = (a × (x[current] - S[previous]) + S[previous] + b × S[previous] × q) / (1 + b × q), where a and b are independently adjustable reciprocal smoothing periods.
Calculation: Histogram = Jurik moving average of the difference between a single ideal smoother of close and three ideal smoothers of close applied in sequence; each of the four ideal smoothers has independent smoothing parameters. For the expert's decisions, calculate on a selectable timeframe that may be higher, lower, or equal to the chart timeframe; use a selectable signal bar, either the last completed bar or the still-forming bar, and its two preceding bars. For histogram markings, use the chart timeframe.
Long: Histogram on the signal bar > histogram on the preceding bar AND histogram on the bar before that > histogram on the preceding bar.
Short: Histogram on the signal bar < histogram on the preceding bar AND histogram on the bar before that < histogram on the preceding bar.
Long: Chart-timeframe histogram > 0 AND chart-timeframe histogram > its previous value.
Long: Chart-timeframe histogram < 0 AND chart-timeframe histogram > its previous value.
Short: Chart-timeframe histogram > 0 AND chart-timeframe histogram < its previous value.
Short: Chart-timeframe histogram < 0 AND chart-timeframe histogram < its previous value.
Exit: short, histogram on the signal bar > histogram on the preceding bar.
Exit: long, histogram on the signal bar < histogram on the preceding bar.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.