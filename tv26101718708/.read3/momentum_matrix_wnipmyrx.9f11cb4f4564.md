Calculation: Smoothed stochastic = SMA(100 * (ZLEMA(close, wave ZLEMA length) - Lowest(low, stochastic length)) / max(Highest(high, stochastic length) - Lowest(low, stochastic length), minimum tick), wave smoothing length)
Calculation: Normalized money flow = 100 * EMA(volume * (close - open) / max(high - low, minimum tick), money flow length) / max(EMA(volume, money flow length), epsilon)
Calculation: Relative volume = if SMA(volume, volume average length)[1] > 0 then volume / SMA(volume, volume average length)[1] else 0
Calculation: Confluence score = (Smoothed stochastic > midpoint ? 1 : -1) + (Smoothed stochastic > Smoothed stochastic[1] ? 1 : -1) + (Normalized money flow > 0 ? 1 : -1) + (close > ZLEMA(close, trend ZLEMA length) ? 1 : -1)
Long: Smoothed stochastic > SMA(Smoothed stochastic, wave signal length)
Short: Smoothed stochastic <= SMA(Smoothed stochastic, wave signal length)
Long: Normalized money flow > 0
Short: Normalized money flow <= 0
Long: Confluence score > 0
Short: Confluence score < 0
Long: Smoothed stochastic > midpoint AND Smoothed stochastic <= overbought level
Short: Smoothed stochastic <= midpoint AND Smoothed stochastic >= oversold level
Long: Latest confirmed Wave pivot low > preceding Wave pivot low AND low at latest pivot bar < low at preceding pivot bar AND latest Wave pivot value < midpoint AND pivot gap <= maximum pivot gap; each pivot uses pivot length bars on each side
Short: Latest confirmed Wave pivot high < preceding Wave pivot high AND high at latest pivot bar > high at preceding pivot bar AND latest Wave pivot value > midpoint AND pivot gap <= maximum pivot gap; each pivot uses pivot length bars on each side
Long: Crossover(Smoothed stochastic, oversold level) AND Normalized money flow > 0 AND close > open
Short: Crossunder(Smoothed stochastic, overbought level) AND Normalized money flow <= 0 AND close < open
Long: Crossover(Smoothed stochastic, midpoint) AND Normalized money flow > 0 AND Relative volume >= volume multiplier
Short: Crossunder(Smoothed stochastic, midpoint) AND Normalized money flow <= 0 AND Relative volume >= volume multiplier
Long: Smoothed stochastic < oversold level AND Crossunder(Abs(Normalized money flow), money flow overflow level)
Short: Smoothed stochastic > overbought level AND Crossunder(Abs(Normalized money flow), money flow overflow level)