Calculation: FastWMA = WMA(ohlc4, fast lookback)
Calculation: SlowWMA = WMA(ohlc4, slow lookback), slow lookback longer than fast lookback
Calculation: T1RSI = RSI(ohlc4, RSI lookback, T1, last completed bar)[1]
Calculation: FastSupertrend = direction of Supertrend(FastWMA, ATR lookback, multiplier)
Calculation: UpperEnvSupertrend = direction of Supertrend(FastWMA * (1 + fast envelope %), ATR lookback, multiplier)
Calculation: LowerEnvSupertrend = direction of Supertrend(FastWMA * (1 - fast envelope %), ATR lookback, multiplier)
Calculation: RawLong = IF (PA module enabled AND (body trigger enabled OR wick trigger enabled)) THEN ((body trigger enabled AND (crossover(close, FastWMA) OR crossover(close, SlowWMA))) OR (wick trigger enabled AND (crossover(high, FastWMA) OR crossover(high, SlowWMA)))) ELSE (crossover(close, FastWMA) OR crossover(close, SlowWMA))
Calculation: RawShort = IF (PA module enabled AND (body trigger enabled OR wick trigger enabled)) THEN ((body trigger enabled AND (crossunder(close, FastWMA) OR crossunder(close, SlowWMA))) OR (wick trigger enabled AND (crossunder(low, FastWMA) OR crossunder(low, SlowWMA)))) ELSE (crossunder(close, FastWMA) OR crossunder(close, SlowWMA))
Calculation: FastUpBounce = BarsSince(crossover(close, FastWMA)) within [fast minimum bars, fast maximum bars] AND low within [FastWMA * (1 - fast touch depth), FastWMA * (1 + fast proximity)] AND close > open AND close > FastWMA
Calculation: FastUpFirst = FastUpBounce AND COUNT(FastUpBounce from last crossover(close, FastWMA) through current bar) = 1
Calculation: FastDownBounce = BarsSince(crossunder(close, FastWMA)) within [fast minimum bars, fast maximum bars] AND high within [FastWMA * (1 - fast proximity), FastWMA * (1 + fast touch depth)] AND close < open AND close < FastWMA
Calculation: FastDownFirst = FastDownBounce AND COUNT(FastDownBounce from last crossunder(close, FastWMA) through current bar) = 1
Calculation: SlowUpBounce = BarsSince(crossover(close, SlowWMA)) within [slow minimum bars, slow maximum bars] AND low within [SlowWMA * (1 - slow touch depth), SlowWMA * (1 + slow proximity)] AND close > open AND close > SlowWMA
Calculation: SlowUpFirst = SlowUpBounce AND COUNT(SlowUpBounce from last crossover(close, SlowWMA) through current bar) = 1
Calculation: SlowDownBounce = BarsSince(crossunder(close, SlowWMA)) within [slow minimum bars, slow maximum bars] AND high within [SlowWMA * (1 - slow proximity), SlowWMA * (1 + slow touch depth)] AND close < open AND close < SlowWMA
Calculation: SlowDownFirst = SlowDownBounce AND COUNT(SlowDownBounce from last crossunder(close, SlowWMA) through current bar) = 1
Calculation: LongTp1Reached = ANY(high >= entry price * (1 + TP1 target), bars from entry through current bar)
Calculation: ShortTp1Reached = ANY(low <= entry price * (1 - TP1 target), bars from entry through current bar)
Calculation: PeakClose = MAX(close, bars from entry through current bar)
Calculation: TroughClose = MIN(close, bars from entry through current bar)
Long: ((baseline execution selected AND RawLong) OR (B&R execution selected AND ((micro B&R enabled AND FastUpFirst) OR (macro B&R enabled AND SlowUpFirst)))) AND close > SMA(ohlc4, sensitivity lookback) AND (macro tide disabled OR close > SlowWMA) AND (RSI filter disabled OR (T1RSI >= RSI long minimum AND T1RSI <= RSI long maximum)) AND (Supertrend link disabled OR FastSupertrend = bullish)
Short: ((baseline execution selected AND RawShort) OR (B&R execution selected AND ((micro B&R enabled AND FastDownFirst) OR (macro B&R enabled AND SlowDownFirst)))) AND close < SMA(ohlc4, sensitivity lookback) AND (macro tide disabled OR close < SlowWMA) AND (RSI filter disabled OR (T1RSI <= RSI short maximum AND T1RSI >= RSI short minimum)) AND (Supertrend link disabled OR FastSupertrend = bearish)
Long: FastUpFirst
Long: SlowUpFirst
Short: FastDownFirst
Short: SlowDownFirst
Long: FastSupertrend = bullish
Long: UpperEnvSupertrend = bullish
Long: LowerEnvSupertrend = bullish
Short: FastSupertrend = bearish
Short: UpperEnvSupertrend = bearish
Short: LowerEnvSupertrend = bearish
Exit: Long, trigger-extreme anchor selected AND low <= trigger-bar low * (1 - stop buffer)
Exit: Long, execution-price anchor selected AND low <= entry price * (1 - stop buffer)
Exit: Long, Module 1 selected AND high >= entry price * (1 + TP1 target)
Exit: Long, Module 1 selected AND high >= entry price * (1 + TP2 target)
Exit: Long, Module 1 selected AND high >= entry price * (1 + TP3 target)
Exit: Long, Module 1 selected AND breakeven enabled AND LongTp1Reached[1] AND low <= entry price
Exit: Long, Module 2 selected AND low <= WMA(low, trail lookback)[1] * (1 - trail buffer)
Exit: Long, Module 3 selected AND low <= PeakClose[1] * (1 - candle trail)
Exit: Short, trigger-extreme anchor selected AND high >= trigger-bar high * (1 + stop buffer)
Exit: Short, execution-price anchor selected AND high >= entry price * (1 + stop buffer)
Exit: Short, Module 1 selected AND low <= entry price * (1 - TP1 target)
Exit: Short, Module 1 selected AND low <= entry price * (1 - TP2 target)
Exit: Short, Module 1 selected AND low <= entry price * (1 - TP3 target)
Exit: Short, Module 1 selected AND breakeven enabled AND ShortTp1Reached[1] AND high >= entry price
Exit: Short, Module 2 selected AND high >= WMA(high, trail lookback)[1] * (1 + trail buffer)
Exit: Short, Module 3 selected AND high >= TroughClose[1] * (1 + candle trail)