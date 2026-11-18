Calculation: score = tanh(Σ[k=1..33] w[k] × tanh(Σ[j=1..5] v[k,j] × tanh(u[j] × ((OHLC4(chart bar) − OHLC4(T1, last completed bar)) / OHLC4(T1, last completed bar))))), evaluated on chart bars, where OHLC4 = (open + high + low + close) / 4 and each u, v, and w is a parameter
Calculation: direction = long if score > 0, short if score < 0, otherwise the previous chart-bar direction
Long: direction = long
Short: direction = short