Calculation: BullTrend(x) = MA(x, shorter MA lookback, MA type) > MA(x, middle MA lookback, MA type) AND MA(x, middle MA lookback, MA type) > MA(x, longer MA lookback, MA type) AND x > MA(x, middle MA lookback, MA type) AND KaufmanER(x, efficiency lookback) >= low efficiency threshold
Calculation: BearTrend(x) = MA(x, middle MA lookback, MA type) <= MA(x, longer MA lookback, MA type) AND KaufmanER(x, efficiency lookback) >= low efficiency threshold AND (MA(x, shorter MA lookback, MA type) <= MA(x, middle MA lookback, MA type) OR x <= MA(x, middle MA lookback, MA type))
Calculation: DonchianPosition(h, l, x) = (x - (highest(h, Donchian lookback) + lowest(l, Donchian lookback)) / 2) / (highest(h, Donchian lookback) - lowest(l, Donchian lookback))
Calculation: HybridTrend(h, l, x) = 1 if DonchianPosition(h, l, x) >= Donchian sideways band AND NOT (x < MA(x, shorter MA lookback, MA type) AND MA(x, shorter MA lookback, MA type) < MA(x, middle MA lookback, MA type) AND MA(x, middle MA lookback, MA type) < MA(x, longer MA lookback, MA type)); -1 if DonchianPosition(h, l, x) <= -Donchian sideways band AND NOT (x > MA(x, shorter MA lookback, MA type) AND MA(x, shorter MA lookback, MA type) > MA(x, middle MA lookback, MA type) AND MA(x, middle MA lookback, MA type) > MA(x, longer MA lookback, MA type)); otherwise 0
Calculation: ConstructiveShare = (number of monitored series with BullTrend(close, T1, last completed bar)) / (number of monitored series)
Calculation: BearishShare = (number of monitored series with BearTrend(close, T1, last completed bar)) / (number of monitored series)
Calculation: RegimeClass = AggressiveLong if BullTrend(primary market index close, T1, last completed bar) AND primary market index close > MA(primary market index close, shorter MA lookback, MA type, T1, last completed bar) AND ConstructiveShare >= aggressive constructive threshold AND BearishShare <= aggressive bearish ceiling; SelectiveLong if BullTrend(primary market index close, T1, last completed bar) AND ConstructiveShare >= selective constructive threshold AND BearishShare < selective bearish ceiling; Cash if BearTrend(primary market index close, T1, last completed bar) AND BearishShare >= cash bearish threshold; DefensiveShort if BearTrend(primary market index close, T1, last completed bar) OR BearishShare >= risk-off bearish threshold; otherwise Neutral
Long: RegimeClass = AggressiveLong
Long: RegimeClass = SelectiveLong
Long: BullTrend(close, T1, last completed bar)
Long: HybridTrend(high, low, close, T1, last completed bar) = 1 AND KaufmanER(close, efficiency lookback, T1, last completed bar) >= low efficiency threshold
Short: RegimeClass = DefensiveShort
Short: BearTrend(close, T1, last completed bar)
Short: HybridTrend(high, low, close, T1, last completed bar) = -1 AND KaufmanER(close, efficiency lookback, T1, last completed bar) >= low efficiency threshold
Exit: long, RegimeClass = Cash
Exit: short, RegimeClass = Cash