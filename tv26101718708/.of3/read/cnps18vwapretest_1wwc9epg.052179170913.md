Calculation: candle body = ABS(close - open)
Calculation: bars since bull break = BarsSince(close crosses above VWAP(hlc3))
Calculation: bars since bear break = BarsSince(close crosses below VWAP(hlc3))
Calculation: long setup = bars since bull break <= breakout bar limit AND lowest low over the last (bars since bull break + 1) bars <= VWAP(hlc3) AND close > VWAP(hlc3) AND close > open AND (rejection filter disabled OR MIN(open, close) - low > candle body * wick-to-body ratio) AND (volume spike filter disabled OR volume >= SMA(volume, volume average lookback) * volume spike factor) AND (distance filter disabled OR ABS(close - VWAP(hlc3)) > minimum distance factor * ATR(atr lookback)) AND (T1 bias filter disabled OR close > VWAP(hlc3, T1, last completed bar))
Calculation: short setup = bars since bear break <= breakout bar limit AND highest high over the last (bars since bear break + 1) bars >= VWAP(hlc3) AND close < VWAP(hlc3) AND close < open AND (rejection filter disabled OR high - MAX(open, close) > candle body * wick-to-body ratio) AND (volume spike filter disabled OR volume >= SMA(volume, volume average lookback) * volume spike factor) AND (distance filter disabled OR ABS(close - VWAP(hlc3)) > minimum distance factor * ATR(atr lookback)) AND (T1 bias filter disabled OR close < VWAP(hlc3, T1, last completed bar))
Long: long setup
Long: position side is flat AND (entry session filter disabled OR bar open time in strategy timezone is between session start time and last entry time inclusive) AND bar close time in strategy timezone is before force-close time AND long setup AND NOT short setup
Short: short setup
Short: position side is flat AND (entry session filter disabled OR bar open time in strategy timezone is between session start time and last entry time inclusive) AND bar close time in strategy timezone is before force-close time AND short setup AND NOT long setup
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance
Exit: long, bar open time in strategy timezone is before force-close time AND bar close time in strategy timezone is at or after force-close time
Exit: short, bar open time in strategy timezone is before force-close time AND bar close time in strategy timezone is at or after force-close time