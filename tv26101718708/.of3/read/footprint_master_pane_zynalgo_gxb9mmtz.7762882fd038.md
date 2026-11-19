Calculation: Grid size = automatic sizing ? max(minimum tick size, round(ATR(lookback, chart timeframe, last completed bar) / number of levels / minimum tick size) * minimum tick size) : manual grid size
Calculation: Buy volume per price bin = for each chart bar, sum the volume of T1 bars within it (including any T1 bar still forming), assigning each bar to clamp(floor(T1 close / grid size) - floor(chart-bar low / grid size), 0, number of levels - 1); count full volume when T1 close > T1 open, half when equal, and zero when lower
Calculation: Sell volume per price bin = for each chart bar, sum the volume of T1 bars within it (including any T1 bar still forming), assigning each bar to clamp(floor(T1 close / grid size) - floor(chart-bar low / grid size), 0, number of levels - 1); count full volume when T1 close < T1 open, half when equal, and zero when higher
Calculation: Bar delta = sum of buy volume across price bins - sum of sell volume across price bins
Long: Buy volume per price bin > Sell volume per price bin
Short: Sell volume per price bin > Buy volume per price bin
Long: Bar delta > 0
Short: Bar delta <= 0