Calculation: rolling return spread = 100 * ((asset close from T1 on chart bars, current T1 bar while forming / that series return lookback chart bars ago - 1) - (benchmark close from T1 on chart bars, current T1 bar while forming / that series return lookback chart bars ago - 1))
Calculation: spread average = SMA(rolling return spread, deviation lookback chart bars)
Calculation: spread standard deviation = standard deviation(rolling return spread, deviation lookback chart bars)
Long: rolling return spread > spread average + deviation multiplier * spread standard deviation
Short: rolling return spread < spread average - deviation multiplier * spread standard deviation