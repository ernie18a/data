Calculation: Bullish EMA alignment = scan-direction setting permits bullish AND (match mode selects all enabled and every enabled T1–T6 has close > EMA(close, alignment lookback), or match mode selects required count and at least the required-count parameter of enabled T1–T6 has close > EMA(close, alignment lookback)); calculate EMA on each timeframe’s bars and use the current mapped bar on chart bars (last completed historically, forming in realtime)
Calculation: Bearish EMA alignment = scan-direction setting permits bearish AND (match mode selects all enabled and every enabled T1–T6 has close < EMA(close, alignment lookback), or match mode selects required count and at least the required-count parameter of enabled T1–T6 has close < EMA(close, alignment lookback)); calculate EMA on each timeframe’s bars and use the current mapped bar on chart bars (last completed historically, forming in realtime)
Calculation: FVG direction on a timeframe’s bars = bullish when low > high[2] AND close[1] > high[2] AND low - high[2] >= ATR(ATR lookback) * FVG size multiplier; otherwise bearish when high < low[2] AND close[1] < low[2] AND low[2] - high >= ATR(ATR lookback) * FVG size multiplier; otherwise neutral. For T7 and T8, use the current mapped timeframe bar on chart bars (last completed historically, forming in realtime)
Calculation: Bullish IFVG = the latest bearish FVG is within the IFVG validity lookback and close > its top (low[2] on its creation bar); bearish IFVG = the latest bullish FVG is within that lookback and close < its bottom (high[2] on its creation bar)
Calculation: Bullish BOS = close > the latest confirmed Pivot high(high, BOS swing lookback, BOS swing lookback); bearish BOS = close < the latest confirmed Pivot low(low, BOS swing lookback, BOS swing lookback)
Calculation: Bullish BOS-watch setup = BOS watch is enabled AND bullish EMA alignment AND (EMA-stack requirement is disabled OR EMA(close, alignment lookback) > EMA(close, middle lookback) > EMA(close, slow lookback)) AND (pullback requirement is disabled OR low <= max of those three EMAs + ATR(ATR lookback) * EMA-zone buffer AND close >= EMA(close, alignment lookback))
Calculation: Bearish BOS-watch setup = BOS watch is enabled AND bearish EMA alignment AND (EMA-stack requirement is disabled OR EMA(close, alignment lookback) < EMA(close, middle lookback) < EMA(close, slow lookback)) AND (pullback requirement is disabled OR high >= min of those three EMAs - ATR(ATR lookback) * EMA-zone buffer AND close <= EMA(close, alignment lookback))
Calculation: BOS-watch state = while bullish, clear first if bullish EMA alignment fails, else if bearish BOS occurs, else if bullish BOS occurs; while bearish, clear first if bearish EMA alignment fails, else if bullish BOS occurs, else if bearish BOS occurs; when flat after that check, start bullish if bullish setup and not bearish setup, else start bearish if bearish setup and not bullish setup; otherwise persist. A watch-start flag is set when either setup starts a watch
Calculation: Nearest DOL direction = bullish if an eligible level above close exists and either no eligible level below close exists or the nearest above level is no farther than the nearest below level; bearish if an eligible level below close exists and either no above level exists or the nearest below level is closer; neutral if neither exists. Levels are the previous completed T9 and T10 highs and lows, and the latest confirmed chart Pivot high/low using the DOL swing lookback
Calculation: Continuation direction = when the direction-source setting selects EMA alignment, bullish if bullish EMA alignment, otherwise bearish if bearish EMA alignment, otherwise neutral; when it selects manual bias, use the manual-bias setting; otherwise, for DOL plus structure, use bullish if bullish IFVG or bullish BOS, otherwise bearish if bearish IFVG or bearish BOS, otherwise Nearest DOL direction
Long: any enabled T1–T6 has close > EMA(close, alignment lookback), using the current mapped timeframe bar on chart bars (last completed historically, forming in realtime)
Short: any enabled T1–T6 has close < EMA(close, alignment lookback), using the current mapped timeframe bar on chart bars (last completed historically, forming in realtime)
Long: bullish EMA alignment
Short: bearish EMA alignment
Long: bullish EMA alignment AND NOT (bullish EMA alignment[1] OR bearish EMA alignment[1])
Short: NOT bullish EMA alignment AND bearish EMA alignment AND NOT (bullish EMA alignment[1] OR bearish EMA alignment[1])
Long: bullish BOS-watch state is active
Short: bearish BOS-watch state is active
Long: bullish BOS watch-start flag
Short: bearish BOS watch-start flag
Long: BOS-watch state entering the bar is bullish AND bullish EMA alignment AND NOT bearish BOS AND bullish BOS
Short: BOS-watch state entering the bar is bearish AND bearish EMA alignment AND NOT bullish BOS AND bearish BOS
Long: bullish IFVG
Short: bearish IFVG AND NOT bullish IFVG
Long: FVG direction on T7 is bullish OR (FVG direction on T7 is neutral AND FVG direction on T8 is bullish)
Short: FVG direction on T7 is bearish OR (FVG direction on T7 is neutral AND FVG direction on T8 is bearish)
Long: continuation direction is bullish
Short: continuation direction is bearish
Long: continuation direction is bullish AND bullish IFVG AND (HTF-FVG requirement is disabled OR selected HTF FVG direction is bullish)
Short: continuation direction is bearish AND bearish IFVG AND (HTF-FVG requirement is disabled OR selected HTF FVG direction is bearish)