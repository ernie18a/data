Calculation: ShortX = RSI(ALMA(price, fast lookback) - ALMA(price, slow lookback), RSI lookback) - 50, where price is a weighted mix of open/high/low/close and the fast ALMA lookback is shorter than the slow one
Calculation: Signal = ALMA(ShortX, lookback much shorter than the ALMA lookbacks used in ShortX)
Calculation: LongX = RSI(ALMA(price, lookback), RSI lookback) - 50, with the same price as ShortX
Long: Signal > Signal[1] AND Signal[1] < Signal[2] (Signal turns up after a local bottom)
Short: Signal < Signal[1] AND Signal[1] > Signal[2] (Signal turns down after a local peak)
Long: LongX computed on a higher timeframe than the chart, using the bar still forming, > 0
Short: LongX computed on a higher timeframe than the chart, using the bar still forming, <= 0