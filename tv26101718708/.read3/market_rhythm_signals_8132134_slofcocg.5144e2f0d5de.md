Calculation: PriorHigh = highest(high, Bias Shift lookback)[1]
Calculation: PriorLow = lowest(low, Bias Shift lookback)[1]
Calculation: OutsideExhaustion = close < highest(high, exhaustion lookback) - (highest(high, exhaustion lookback) - lowest(low, exhaustion lookback)) * exhaustion-zone fraction AND close > lowest(low, exhaustion lookback) + (highest(high, exhaustion lookback) - lowest(low, exhaustion lookback)) * exhaustion-zone fraction
Calculation: ATRPercent = ATR(ATR lookback) / close * 100
Calculation: BullTrendFilter = trend filter disabled OR ((close > EMA(close, EMA lookback) OR aggressive profile AND close = EMA(close, EMA lookback)) AND (nonconservative profile OR EMA(close, EMA lookback) >= EMA(close, EMA lookback)[1]))
Calculation: BearTrendFilter = trend filter disabled OR ((close < EMA(close, EMA lookback) OR aggressive profile AND close = EMA(close, EMA lookback)) AND (nonconservative profile OR EMA(close, EMA lookback) <= EMA(close, EMA lookback)[1]))
Calculation: VolatilityFilter = volatility filter disabled OR ATRPercent >= minimum ATR percent
Calculation: BullHTFConfirmation = HTF confirmation disabled OR, on chart bars using the last completed T1 bar, close > EMA(close, HTF EMA lookback, T1, last completed bar)
Calculation: BearHTFConfirmation = HTF confirmation disabled OR, on chart bars using the last completed T1 bar, close < EMA(close, HTF EMA lookback, T1, last completed bar)
Calculation: BiasCooldownAvailable = cooldown disabled OR no Bias Shift signal in the preceding Bias Shift cooldown lookback chart bars
Calculation: GoldenCooldownAvailable = cooldown disabled OR no Golden signal in the preceding Golden cooldown lookback chart bars
Long: On confirmed chart-bar close, close > PriorHigh AND BullTrendFilter AND VolatilityFilter AND BiasCooldownAvailable AND (Bias Shift outside-exhaustion filter disabled OR OutsideExhaustion) AND BullHTFConfirmation
Short: On confirmed chart-bar close, close < PriorLow AND BearTrendFilter AND VolatilityFilter AND BiasCooldownAvailable AND (Bias Shift outside-exhaustion filter disabled OR OutsideExhaustion) AND BearHTFConfirmation
Long: On confirmed chart-bar close, close > PriorHigh AND OutsideExhaustion AND GoldenCooldownAvailable AND BullHTFConfirmation AND ((Golden strict filters enabled AND BullTrendFilter AND VolatilityFilter) OR (Golden strict filters disabled AND close > EMA(close, EMA lookback)))
Short: On confirmed chart-bar close, close < PriorLow AND OutsideExhaustion AND GoldenCooldownAvailable AND BearHTFConfirmation AND ((Golden strict filters enabled AND BearTrendFilter AND VolatilityFilter) OR (Golden strict filters disabled AND close < EMA(close, EMA lookback)))