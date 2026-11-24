Calculation: Bullish ribbon = at least (ribbon alignment threshold - 1) of MA(close, ribbon type, ribbon lookback 1) > MA(close, ribbon type, ribbon lookback 2), ..., MA(close, ribbon type, ribbon lookback 7) > MA(close, ribbon type, ribbon lookback 8)
Calculation: Bearish ribbon = at least (ribbon alignment threshold - 1) of MA(close, ribbon type, ribbon lookback 1) < MA(close, ribbon type, ribbon lookback 2), ..., MA(close, ribbon type, ribbon lookback 7) < MA(close, ribbon type, ribbon lookback 8)
Calculation: Volume spike = volume > SMA(volume, volume spike lookback) * volume multiplier
Calculation: CVD = cumulative sum of (volume when close > open minus volume when close < open)
Calculation: Buy/sell volume ratio = volume when close > open / max(volume when close < open, 1)
Calculation: Bullish BOS = close > the latest confirmed Pivot High(high, BOS pivot lookback, BOS pivot lookback) and close[1] <= that pivot high
Calculation: Bearish BOS = close < the latest confirmed Pivot Low(low, BOS pivot lookback, BOS pivot lookback) and close[1] >= that pivot low
Calculation: T4 bullish = on chart bars using T4 values (last completed T4 bar historically; still-forming T4 bar in real time), EMA(close, T4 fast lookback) > EMA(close, T4 slow lookback) and close > EMA(close, T4 fast lookback)
Calculation: T4 bearish = on chart bars using T4 values (last completed T4 bar historically; still-forming T4 bar in real time), EMA(close, T4 fast lookback) < EMA(close, T4 slow lookback) and close < EMA(close, T4 fast lookback)
Calculation: Long MTF gate = MTF filter disabled or T4 bullish
Calculation: Short MTF gate = MTF filter disabled or T4 bearish
Calculation: Long ribbon gate = ribbon filter disabled or bullish ribbon
Calculation: Short ribbon gate = ribbon filter disabled or bearish ribbon
Calculation: Bullish order flow = order flow enabled and ((CVD > SMA(CVD, CVD lookback) and close < close[1] and CVD > CVD[1]) or Buy/sell volume ratio > 1 + CVD threshold) and (close crosses above VWAP or close > VWAP)
Calculation: Bearish order flow = order flow enabled and ((CVD < SMA(CVD, CVD lookback) and close > close[1] and CVD < CVD[1]) or Buy/sell volume ratio < 1 - CVD threshold) and (close crosses below VWAP or close < VWAP)
Calculation: Long order-flow gate = order flow disabled or Bullish order flow or close > VWAP
Calculation: Short order-flow gate = order flow disabled or Bearish order flow or close < VWAP
Calculation: Bullish SMC = smart-money analysis enabled and ((close > open and close[1] < open[1] and high - close < (high - low) * order-block body fraction) or (low > high[2] and low - high[2] > ATR(ATR lookback) * FVG minimum size) or (low < lowest(low, liquidity lookback)[1] and close > open and close > lowest(low, liquidity lookback)[1]) or Bullish BOS)
Calculation: Bearish SMC = smart-money analysis enabled and ((close < open and close[1] > open[1] and close - low < (high - low) * order-block body fraction) or (high < low[2] and low[2] - high > ATR(ATR lookback) * FVG minimum size) or (high > highest(high, liquidity lookback)[1] and close < open and close < highest(high, liquidity lookback)[1]) or Bearish BOS)
Calculation: Long SMC gate = smart-money analysis disabled or Bullish SMC
Calculation: Short SMC gate = smart-money analysis disabled or Bearish SMC
Calculation: Long signal score = sum of 1 for each true condition: Long MTF gate, Long ribbon gate, Long order-flow gate, Long SMC gate, ADX(ADX lookback) > ADX threshold
Calculation: Short signal score = sum of 1 for each true condition: Short MTF gate, Short ribbon gate, Short order-flow gate, Short SMC gate, ADX(ADX lookback) > ADX threshold
Calculation: Trend status(T) = on chart bars using T values (last completed T bar historically; still-forming T bar in real time), 0 when abs(EMA(close, shorter trend lookback) - EMA(close, longer trend lookback)) < ATR(T, ATR lookback) * neutral ATR multiplier; otherwise 1 when the shorter-lookback EMA is greater, else -1
Calculation: Volume buy percentage = 100 * sum over the volume pressure lookback of volume when close > open / sum over that lookback of volume when close > open or close < open
Long: Bullish ribbon
Short: Bearish ribbon
Long: Bullish order flow
Short: Bearish order flow
Long: Bullish SMC
Short: Bearish SMC
Long: Bullish BOS
Short: Bearish BOS
Long: Volume buy percentage > buying pressure threshold
Short: Volume buy percentage < selling pressure threshold
Long: Trend status(T1) > 0 or Trend status(T2) > 0 or Trend status(T3) > 0
Short: Trend status(T1) < 0 or Trend status(T2) < 0 or Trend status(T3) < 0
Long: Trend status(T1) + Trend status(T2) + Trend status(T3) > 0
Short: Trend status(T1) + Trend status(T2) + Trend status(T3) < 0
Long: Long signal score > Short signal score
Short: Short signal score > Long signal score
Long: RSI(close, gradient RSI lookback) > upper gradient threshold and close > open
Short: RSI(close, gradient RSI lookback) < lower gradient threshold and close < open
Long: ((ADX(ADX lookback) > ADX threshold and EMA(close, trend fast lookback) > EMA(close, trend slow lookback) and close > EMA(close, trend filter lookback) and EMA(close, trend fast lookback) crosses above EMA(close, trend slow lookback) and Volume spike) or (close > highest(high, breakout lookback)[1] and Volume spike and close > EMA(close, trend filter lookback))) and (MTF filter disabled or T4 bullish) and Long ribbon gate and Long order-flow gate and Long SMC gate and (trading-hours filter disabled or current bar is within the selected session)
Short: ((ADX(ADX lookback) > ADX threshold and EMA(close, trend fast lookback) < EMA(close, trend slow lookback) and close < EMA(close, trend filter lookback) and EMA(close, trend fast lookback) crosses below EMA(close, trend slow lookback) and Volume spike) or (close < lowest(low, breakout lookback)[1] and Volume spike and close < EMA(close, trend filter lookback))) and (MTF filter disabled or T4 bearish) and Short ribbon gate and Short order-flow gate and Short SMC gate and (trading-hours filter disabled or current bar is within the selected session)
Exit: long, low <= signal-bar close - ATR(signal bar, ATR lookback) * stop multiplier or (trailing stop enabled and long trailing stop is hit, with activation points and offset each equal to ATR(signal bar, ATR lookback) * trailing multiplier) or (trailing stop disabled and high >= signal-bar close + ATR(signal bar, ATR lookback) * take-profit multiplier)
Exit: short, high >= signal-bar close + ATR(signal bar, ATR lookback) * stop multiplier or (trailing stop enabled and short trailing stop is hit, with activation points and offset each equal to ATR(signal bar, ATR lookback) * trailing multiplier) or (trailing stop disabled and low <= signal-bar close - ATR(signal bar, ATR lookback) * take-profit multiplier)