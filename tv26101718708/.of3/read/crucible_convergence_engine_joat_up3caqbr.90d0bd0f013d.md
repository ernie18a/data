Calculation: Directional balance = (EMA(+DM, regime ATR lookback) - EMA(-DM, regime ATR lookback)) / (EMA(+DM, regime ATR lookback) + EMA(-DM, regime ATR lookback))
Calculation: Normalized EMA spread = (EMA(close, regime shorter lookback) - EMA(close, regime longer lookback)) / ATR(regime ATR lookback)
Calculation: ATR percentile = PercentRank(ATR(regime ATR lookback), regime rank lookback)
Calculation: Raw market state = 2 if ATR percentile > turbulence threshold, else 1 if ATR percentile > kinetic threshold AND Directional balance > bias threshold AND Normalized EMA spread > spread threshold, else -1 if ATR percentile > kinetic threshold AND Directional balance < -bias threshold AND Normalized EMA spread < -spread threshold, else 0
Calculation: Market state = Raw market state if Raw market state == Raw market state[1], else Market state[1]
Calculation: Volume ratio(long lookback) = SMA(volume, short volume lookback) / SMA(volume, long lookback)
Calculation: Volume-weighted change = (close - close[1]) * LN(1 + Volume ratio(momentum volume lookback) * momentum volume sensitivity)
Calculation: Momentum index = EMA(EMA(Volume-weighted change, momentum shorter lookback) - EMA(Volume-weighted change, momentum longer lookback), momentum smoothing lookback)
Calculation: Ceiling level = grid increment * ceil(EMA(close, grid lookback) / grid increment)
Calculation: Floor level = grid increment * floor(EMA(close, grid lookback) / grid increment)
Calculation: Rail tolerance = (Ceiling level - Floor level) * proximity radius
Calculation: Long setup = Market state == 1 AND MA(close, trend shorter lookback, MA type) > MA(close, trend longer lookback, MA type) AND Momentum index > EMA(Momentum index, momentum signal lookback) AND close < Bollinger upper band(close, band lookback, band multiplier) AND Volume ratio(average volume lookback) >= volume threshold
Calculation: Short setup = Market state == -1 AND MA(close, trend shorter lookback, MA type) < MA(close, trend longer lookback, MA type) AND Momentum index < EMA(Momentum index, momentum signal lookback) AND close > Bollinger lower band(close, band lookback, band multiplier) AND Volume ratio(average volume lookback) >= volume threshold
Calculation: Long trail = close - ATR(risk ATR lookback) * trail multiple on the first bar of a long position, else MAX(Long trail[1], close - ATR(risk ATR lookback) * trail multiple)
Calculation: Short trail = close + ATR(risk ATR lookback) * trail multiple on the first bar of a short position, else MIN(Short trail[1], close + ATR(risk ATR lookback) * trail multiple)
Long: Long setup AND NOT Long setup[1]
Short: Short setup AND NOT Short setup[1]
Exit: long, low <= Long trail
Exit: long, low <= entry price - ATR(risk ATR lookback) * stop multiple
Exit: long, high >= entry price + ATR(risk ATR lookback) * target multiple
Exit: long, Market state == -1
Exit: long, close >= Bollinger upper band(close, band lookback, band multiplier)
Exit: long, ABS(high - Ceiling level) <= Rail tolerance
Exit: short, high >= Short trail
Exit: short, high >= entry price + ATR(risk ATR lookback) * stop multiple
Exit: short, low <= entry price - ATR(risk ATR lookback) * target multiple
Exit: short, Market state == 1
Exit: short, close <= Bollinger lower band(close, band lookback, band multiplier)
Exit: short, ABS(low - Floor level) <= Rail tolerance