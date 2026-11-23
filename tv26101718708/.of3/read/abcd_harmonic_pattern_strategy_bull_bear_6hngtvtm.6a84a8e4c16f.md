Calculation: SwingHighPivot = max(high, high[1]) if close[1] >= open[1] AND close < open, otherwise na
Calculation: SwingLowPivot = min(low, low[1]) if close[1] < open[1] AND close >= open, otherwise na
Calculation: LastSwingHigh = ValueWhen(SwingHighPivot is not na, SwingHighPivot, 0)
Calculation: PrevSwingHigh = ValueWhen(SwingHighPivot is not na, SwingHighPivot, 1)
Calculation: LastSwingLow = ValueWhen(SwingLowPivot is not na, SwingLowPivot, 0)
Calculation: PrevSwingLow = ValueWhen(SwingLowPivot is not na, SwingLowPivot, 1)
Calculation: UpBCRatio = 100 * (LastSwingHigh - PrevSwingLow) / (PrevSwingHigh - PrevSwingLow)
Calculation: UpCDRatio = 100 * (LastSwingHigh - LastSwingLow) / (LastSwingHigh - PrevSwingLow)
Calculation: DownBCRatio = 100 * (PrevSwingHigh - LastSwingLow) / (PrevSwingHigh - PrevSwingLow)
Calculation: DownCDRatio = 100 * (LastSwingHigh - LastSwingLow) / (PrevSwingHigh - LastSwingLow)
Calculation: UpABCD = SwingLowPivot is not na AND LastSwingLow < PrevSwingLow AND LastSwingHigh < PrevSwingHigh AND UpBCRatio >= BC low ratio - BC lower tolerance AND UpBCRatio <= BC high ratio + BC upper tolerance AND UpCDRatio >= CD low ratio - CD lower tolerance AND UpCDRatio <= CD high ratio + CD upper tolerance
Calculation: DownABCD = SwingHighPivot is not na AND LastSwingHigh > PrevSwingHigh AND LastSwingLow > PrevSwingLow AND DownBCRatio >= BC low ratio - BC lower tolerance AND DownBCRatio <= BC high ratio + BC upper tolerance AND DownCDRatio >= CD low ratio - CD lower tolerance AND DownCDRatio <= CD high ratio + CD upper tolerance
Calculation: BodyToRange = ABS(close - open) / (high - low)
Calculation: TakeCareLatch = TakeCareLatch[1] OR (((position is long AND close - entry price >= take-care profit threshold) OR (position is short AND entry price - close >= take-care profit threshold)) AND bars since entry > take-care bars)
Long: UpABCD is true
Long: UpABCD is true AND position is flat
Long: UpABCD is true AND close > open AND BodyToRange >= minimum body ratio AND (close - LastSwingLow) / LastSwingLow * 100 >= minimum bounce percent AND volume >= SMA(volume, volume lookback) * volume multiplier AND ATR(high, low, close, ATR lookback) / close * 100 >= minimum ATR percent AND RSI(close, RSI lookback) <= long RSI maximum AND close > EMA(close, HTF lookback, T1, last completed bar)
Long: UpABCD is true AND position is flat AND position[1] is flat AND position[2] is flat
Short: DownABCD is true
Short: DownABCD is true AND position is flat
Short: DownABCD is true AND close < open AND BodyToRange >= minimum body ratio AND (LastSwingHigh - close) / LastSwingHigh * 100 >= minimum bounce percent AND volume >= SMA(volume, volume lookback) * volume multiplier AND ATR(high, low, close, ATR lookback) / close * 100 >= minimum ATR percent AND RSI(close, RSI lookback) >= short RSI minimum AND close < EMA(close, HTF lookback, T1, last completed bar)
Short: DownABCD is true AND position is flat AND position[1] is flat AND position[2] is flat
Exit: long, low <= entry price * (1 - stop loss percent / 100) OR (trailing stop is enabled AND low <= (highest high from the first bar of the current position on which high >= entry price * (1 + take-profit percent / 100) through the current bar) - entry price * trailing offset percent / 100) OR (trailing stop is disabled AND high >= entry price * (1 + take-profit percent / 100)) OR TakeCareLatch is true
Exit: short, high >= entry price * (1 + stop loss percent / 100) OR (trailing stop is enabled AND high >= (lowest low from the first bar of the current position on which low <= entry price * (1 - take-profit percent / 100) through the current bar) + entry price * trailing offset percent / 100) OR (trailing stop is disabled AND low <= entry price * (1 - take-profit percent / 100)) OR TakeCareLatch is true