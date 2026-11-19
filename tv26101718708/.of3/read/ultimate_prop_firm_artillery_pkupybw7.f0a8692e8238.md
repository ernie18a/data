Calculation: demand zone = latest confirmed pivot low +/- ATR(ATR lookback) * zone-width multiplier
Calculation: supply zone = latest confirmed pivot high +/- ATR(ATR lookback) * zone-width multiplier
Calculation: daily drawdown percentage = (day-start equity - current equity) / day-start equity * 100 when day-start equity > 0, otherwise 0
Long: PivotLow(low, left pivot lookback, right confirmation bars) is confirmed on the current chart bar
Short: PivotHigh(high, left pivot lookback, right confirmation bars) is confirmed on the current chart bar
Long: EMA(close, shorter lookback) > EMA(close, longer lookback) AND close > EMA(close, shorter lookback) AND ADX(DMI length, ADX smoothing length) > trend threshold
Short: EMA(close, shorter lookback) < EMA(close, longer lookback) AND close < EMA(close, shorter lookback) AND ADX(DMI length, ADX smoothing length) > trend threshold
Long: PivotLow(low, left pivot lookback, right confirmation bars) is confirmed on the current chart bar AND low <= latest confirmed pivot low + ATR(ATR lookback) * zone-width multiplier AND RSI(close, RSI lookback) >= long RSI floor AND close > open AND volume >= SMA(volume, volume lookback) * volume multiplier AND New York HHMM >= session start AND New York HHMM <= session end AND entries today < daily trade limit AND daily drawdown percentage < daily drawdown limit AND position is flat
Short: PivotHigh(high, left pivot lookback, right confirmation bars) is confirmed on the current chart bar AND high >= latest confirmed pivot high - ATR(ATR lookback) * zone-width multiplier AND RSI(close, RSI lookback) <= short RSI ceiling AND close < open AND volume >= SMA(volume, volume lookback) * volume multiplier AND New York HHMM >= session start AND New York HHMM <= session end AND entries today < daily trade limit AND daily drawdown percentage < daily drawdown limit AND position is flat
Exit: long, low <= entry price - ATR(ATR lookback at entry) * stop multiplier
Exit: long, high >= entry price + ATR(ATR lookback at entry) * near-target multiplier
Exit: long, high >= entry price + ATR(ATR lookback at entry) * middle-target multiplier
Exit: long, high >= entry price + ATR(ATR lookback at entry) * far-target multiplier
Exit: short, high >= entry price + ATR(ATR lookback at entry) * stop multiplier
Exit: short, low <= entry price - ATR(ATR lookback at entry) * near-target multiplier
Exit: short, low <= entry price - ATR(ATR lookback at entry) * middle-target multiplier
Exit: short, low <= entry price - ATR(ATR lookback at entry) * far-target multiplier
Exit: long, New York HHMM >= session end
Exit: short, New York HHMM >= session end