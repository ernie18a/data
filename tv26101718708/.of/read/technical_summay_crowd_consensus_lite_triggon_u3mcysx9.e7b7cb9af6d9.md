Calculation: Oscillator votes = each enabled oscillator casts +1 (bullish), −1 (bearish), or 0 (neutral): RSI, Stochastic, Williams %R, Stochastic RSI, and Ultimate Oscillator use their overbought/oversold cutoffs, otherwise vote by comparison with their midpoint or signal line as applicable; CCI uses its extreme cutoffs, otherwise its sign; MACD compares its line with its signal line; Awesome Oscillator compares with zero; Momentum compares close with its lagged close; Bull/Bear Power compares close with its EMA.
Calculation: Moving-average votes = each enabled EMA, SMA, VWMA, or HMA casts +1 when close is above it, −1 when close is below it, and 0 when equal.
Calculation: Consensus = the larger of total bullish and bearish votes divided by all enabled votes, including neutral votes; dominant side is bullish when bullish votes are at least bearish votes, otherwise bearish. Raw bias is neutral when consensus is below the configured neutral cutoff; otherwise it is the dominant side.
Calculation: Daily phase = on intraday charts, reset to unset at each new day; set to the first non-neutral raw bias of that day, retain it through neutral raw bias, and change it when raw bias becomes the opposite side. A phase change requires a previously set, opposite phase. No phase decisions occur on daily-or-higher charts.
Calculation: Consensus gate = the configured flip cutoff, applied as consensus at least the cutoff in At Least mode or at most the cutoff in At Most mode.
Calculation: EMA alignment = when enabled, bullish only if the entire bar is above the configured EMA, and bearish only if the entire bar is below it.
Long: daily phase changes to bullish
Short: daily phase changes to bearish
Long: daily phase changes to bullish AND consensus gate passes AND EMA alignment is bullish when enabled
Short: daily phase changes to bearish AND consensus gate passes AND EMA alignment is bearish when enabled
Exit: long, a short entry condition occurs
Exit: short, a long entry condition occurs