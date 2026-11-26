Calculation: Fast MA = selected fast MA type of MA source with the shorter, anchor-scaled lookback
Calculation: Slow MA = selected slow MA type of MA source with the longer, anchor-scaled lookback
Calculation: Fast MA line state = bullish when HLC3 > Fast MA, bearish when HLC3 < Fast MA, otherwise its previous state, initially bullish
Calculation: Slow MA line state = bullish when HLC3 > Slow MA, bearish when HLC3 < Slow MA, otherwise its previous state, initially bullish
Calculation: Bullish bar zone = HLC3 > Fast MA AND HLC3 > Slow MA AND (open-outside-ribbon filter disabled OR open > Fast MA AND open > Slow MA)
Calculation: Bearish bar zone = HLC3 < Fast MA AND HLC3 < Slow MA AND (open-outside-ribbon filter disabled OR open < Fast MA AND open < Slow MA)
Calculation: Bullish swing count = consecutive bars in the bullish bar zone that pass enabled filters requiring Fast MA >= Slow MA and Fast MA not falling over the slope lookback; otherwise zero
Calculation: Bearish swing count = consecutive bars in the bearish bar zone that pass enabled filters requiring Fast MA <= Slow MA and Fast MA not rising over the slope lookback; otherwise zero
Calculation: Bullish continuation count = zero when Fast MA < Slow MA or when the count is zero and close <= close[1]; one on the first bar with Fast MA > Slow MA and close > close[1]; otherwise the previous positive count plus one
Calculation: Bearish continuation count = zero when Fast MA > Slow MA or when the count is zero and close >= close[1]; one on the first bar with Fast MA < Slow MA and close < close[1]; otherwise the previous positive count plus one
Calculation: Main resistance = latest confirmed pivot high of high using separate left and quick-right lookbacks, calculated on chart bars or on last-completed T1 bars with chart bars taking T1 values when higher-timeframe S/R is enabled
Calculation: Main support = latest confirmed pivot low of low using separate left and quick-right lookbacks, calculated on chart bars or on last-completed T1 bars with chart bars taking T1 values when higher-timeframe S/R is enabled
Long: Fast MA line state is bullish
Short: Fast MA line state is bearish
Long: Slow MA line state is bullish
Short: Slow MA line state is bearish
Long: Fast MA > Slow MA
Short: Fast MA <= Slow MA
Long: Bullish bar zone
Short: Bearish bar zone
Long: Six-tone bar coloring enabled AND NOT Bullish bar zone AND NOT Bearish bar zone AND close >= open
Short: Six-tone bar coloring enabled AND NOT Bullish bar zone AND NOT Bearish bar zone AND close < open
Long: Fast MA > Slow MA AND Fast MA[1] < Slow MA[1]
Short: Fast MA < Slow MA AND Fast MA[1] > Slow MA[1]
Long: Bullish swing count = 1
Short: Bearish swing count = 1
Exit: Long, Bullish swing count[1] > 0 AND Bullish swing count = 0 AND Bearish swing count != 1
Exit: Short, Bearish swing count[1] > 0 AND Bearish swing count = 0 AND Bullish swing count != 1
Long: Bullish continuation count = 1
Short: Bearish continuation count = 1
Long: close[1] <= Main resistance AND close > Main resistance * (1 + breakout margin)
Short: close[1] >= Main support AND close < Main support * (1 - breakout margin)
Long: Main resistance was previously broken upward and not yet retested AND low is within level-touch tolerance of Main resistance AND close > Main resistance
Short: Main support was previously broken downward and not yet retested AND high is within level-touch tolerance of Main support AND close < Main support
Short: high > Main resistance * (1 + level-touch tolerance) AND close < Main resistance
Long: low < Main support * (1 - level-touch tolerance) AND close > Main support