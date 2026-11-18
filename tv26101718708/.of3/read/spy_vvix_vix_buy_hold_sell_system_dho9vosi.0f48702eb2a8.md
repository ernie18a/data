Calculation: Risk series A chart values = close from data series A on T1, requested with lookahead off and projected onto chart bars (last completed T1 bar historically; current forming T1 bar in real time)
Calculation: Risk series B chart values = close from data series B on T1, requested with lookahead off and projected onto chart bars (last completed T1 bar historically; current forming T1 bar in real time)
Calculation: Smoothed range = EMA(EMA(abs(primary source - primary source[1]), range lookback), 2 × range lookback − 1) × range multiplier
Calculation: Range filter = if primary source > nz(Range filter[1]), max(primary source − Smoothed range, nz(Range filter[1])), else min(primary source + Smoothed range, nz(Range filter[1])); prior value defaults to 0
Calculation: Rising-filter count = if Range filter > Range filter[1] then nz(Rising-filter count[1]) + 1 else if Range filter < Range filter[1] then 0 else nz(Rising-filter count[1])
Calculation: Falling-filter count = if Range filter < Range filter[1] then nz(Falling-filter count[1]) + 1 else if Range filter > Range filter[1] then 0 else nz(Falling-filter count[1])
Calculation: Primary bullish trend = primary source > EMA(primary source, trend lookback)
Calculation: Range bullish = primary source > Range filter AND Rising-filter count > 0
Calculation: Risk series A rising = Risk series A chart values > EMA(Risk series A chart values, series A EMA lookback) on chart bars AND Risk series A chart values > Risk series A chart values[1]
Calculation: Risk series A falling = Risk series A chart values < EMA(Risk series A chart values, series A EMA lookback) on chart bars AND Risk series A chart values < Risk series A chart values[1]
Calculation: Risk series B rising = Risk series B chart values > EMA(Risk series B chart values, series B EMA lookback) on chart bars AND Risk series B chart values > Risk series B chart values[1]
Calculation: Panic condition = Risk series A chart values >= panic level OR (Risk series A rising AND Risk series B rising)
Calculation: Long setup = Primary bullish trend AND Range bullish AND Risk series A chart values < caution level AND NOT Risk series B rising AND Risk series A falling
Calculation: Sell setup = Panic condition OR (Risk series A chart values >= danger level AND Risk series A rising) OR (primary source < EMA(primary source, trend lookback) AND primary source < Range filter AND Falling-filter count > 0)
Calculation: Signal state = if Long setup then 1 else if Sell setup then −1 else if (Primary bullish trend AND Range bullish AND NOT Panic condition) then 0 else nz(Signal state[1])
Long: Long setup AND nz(Signal state[1]) != 1
Exit: long, NOT Long setup AND Sell setup AND nz(Signal state[1]) != −1