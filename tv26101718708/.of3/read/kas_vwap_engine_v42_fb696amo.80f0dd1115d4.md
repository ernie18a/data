Calculation: Anchor reset = first chart bar or high > highest(high[1], structure lookback) or low < lowest(low[1], structure lookback)
Calculation: Anchored VWAP = volume-weighted HLC3 accumulated since the most recent anchor reset; on a reset bar it equals HLC3
Calculation: ATR base = SMA(ATR(ATR lookback), ATR statistics lookback) when available, otherwise ATR(ATR lookback)
Calculation: ATR z-score = (ATR(ATR lookback) - SMA(ATR(ATR lookback), ATR statistics lookback)) / STDEV(ATR(ATR lookback), ATR statistics lookback); unavailable when the inputs are unavailable or standard deviation is zero
Calculation: Upper outer band = Anchored VWAP + outer multiplier * ATR base
Calculation: Lower outer band = Anchored VWAP - outer multiplier * ATR base
Calculation: Outer touch tolerance = touch tolerance parameter * ATR base
Calculation: VWAP wick touch = low <= Anchored VWAP and high >= Anchored VWAP
Calculation: Armed direction = long when low <= Lower outer band + Outer touch tolerance; otherwise short when high >= Upper outer band - Outer touch tolerance; otherwise retain prior direction; clear after a VWAP wick touch, anchor reset, or either entry signal, with clearing taking precedence and lower touch taking precedence over upper touch
Calculation: VWAP exit = VWAP wick touch when body-exit mode is disabled; otherwise abs(close - Anchored VWAP) <= exit tolerance parameter * ATR base
Long: Flat and cooldown elapsed since the prior entry signal (or no prior signal) and armed direction is long and close > Anchored VWAP - inner multiplier * ATR base and (ATR filter disabled or ATR z-score unavailable or ATR z-score >= low-volatility threshold) and (HTF filter disabled or chart close > EMA(close, HTF EMA lookback) computed on higher-timeframe T1 bars and sampled on chart bars with lookahead off: last completed T1 bar historically, current forming T1 bar in real time)
Short: Flat and cooldown elapsed since the prior entry signal (or no prior signal) and armed direction is short and close < Anchored VWAP + inner multiplier * ATR base and (ATR filter disabled or ATR z-score unavailable or ATR z-score >= low-volatility threshold) and (HTF filter disabled or chart close < EMA(close, HTF EMA lookback) computed on higher-timeframe T1 bars and sampled on chart bars with lookahead off: last completed T1 bar historically, current forming T1 bar in real time)
Exit: Long, VWAP exit or low <= Lower outer band + Outer touch tolerance or anchor reset
Exit: Short, VWAP exit or high >= Upper outer band - Outer touch tolerance or anchor reset