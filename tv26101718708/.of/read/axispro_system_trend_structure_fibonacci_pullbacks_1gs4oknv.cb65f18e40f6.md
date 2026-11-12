Calculation: ATRratio = ATR / SMA(ATR) where the SMA lookback is longer than the ATR lookback
Calculation: SwingHigh = most recent confirmed pivot high (high is the highest over N bars left and N bars right); SwingLow = most recent confirmed pivot low (mirror)
Calculation: LongBOS = (last completed bar of a higher timeframe: close > EMA of that timeframe's close, long lookback) AND ATRratio >= min ratio AND close crosses above SwingHigh on this bar AND close > SwingHigh + k*ATR
Calculation: ShortBOS = (last completed bar of a higher timeframe: close < EMA of that timeframe's close, long lookback) AND ATRratio >= min ratio AND close crosses below SwingLow on this bar AND close < SwingLow - k*ATR
Calculation: LongZone, fixed at the latest LongBOS bar: Start = lowest low over an impulse lookback, End = high of the BOS bar, rng = End - Start; ZoneHi = End - rng*f1, ZoneLo = End - rng*f2, Inv = End - rng*f3, with f1 < f2 < f3
Calculation: ShortZone, fixed at the latest ShortBOS bar: Start = highest high over an impulse lookback, End = low of the BOS bar, rng = Start - End; ZoneLo = End + rng*f1, ZoneHi = End + rng*f2, Inv = End + rng*f3, with f1 < f2 < f3
Calculation: LongArmed = latest BOS is LongBOS (not superseded by a later ShortBOS) AND no bar since it (including the BOS bar) had low < LongZone Inv AND no Long entry since it
Calculation: ShortArmed = latest BOS is ShortBOS (not superseded by a later LongBOS) AND no bar since it (including the BOS bar) had high > ShortZone Inv AND no Short entry since it
Calculation: Stop0 long = min(entry - m*ATR, lowest low over a swing lookback), then if entry - Stop0 > M*ATR (M > m) set Stop0 = entry - M*ATR; Stop0 short = max(entry + m*ATR, highest high over a swing lookback), then if Stop0 - entry > M*ATR set Stop0 = entry + M*ATR. ATR, lowest low and highest high are taken at the entry signal bar; entry = close of the signal bar
Calculation: R = |entry - Stop0|; TP1 = entry +/- a*R; TP2 = entry +/- b*R (+ for long, - for short, b > a)
Calculation: StopLevel = Stop0 until TP1 has been touched (long: high >= TP1; short: low <= TP1); after that, long: running max of (StopLevel, entry price, fast EMA of close), short: running min of (StopLevel, entry price, fast EMA of close)
Long: flat AND LongArmed AND low <= LongZone ZoneHi AND high >= LongZone ZoneLo AND close > fast EMA AND close > previous bar high AND close is between fast EMA and mid EMA (fast EMA lookback shorter than mid) AND close > EMA of long lookback (longer than mid) AND bars since last entry > cooldown
Short: flat AND ShortArmed AND high >= ShortZone ZoneLo AND low <= ShortZone ZoneHi AND close < fast EMA AND close < previous bar low AND close is between fast EMA and mid EMA (fast EMA lookback shorter than mid) AND close < EMA of long lookback (longer than mid) AND bars since last entry > cooldown
Exit: long, low <= StopLevel OR high >= TP2 (close all)
Exit: long, high >= TP1 (close partial portion once)
Exit: short, high >= StopLevel OR low <= TP2 (close all)
Exit: short, low <= TP1 (close partial portion once)