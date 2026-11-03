Calculation: Bullish engulfing = previous close < previous open AND close > open AND close >= previous open AND open <= previous close AND abs(close - open) > body multiplier × abs(previous close - previous open)
Calculation: Bearish engulfing = previous close > previous open AND close < open AND open >= previous close AND close <= previous open AND abs(close - open) > body multiplier × abs(previous close - previous open)
Calculation: Main long stop = max(min(entry-bar low, previous low) × (1 - stop buffer), entry-bar close × (1 - main stop cap))
Calculation: Main short stop = min(max(entry-bar high, previous high) × (1 + stop buffer), entry-bar close × (1 + main stop cap))
Calculation: Flip long stop = max(lowest low over the swing lookback × (1 - stop buffer), broken stop × (1 - flip stop cap))
Calculation: Flip short stop = min(highest high over the swing lookback × (1 + stop buffer), broken stop × (1 + flip stop cap))
Calculation: Initial risk = distance between the main entry-bar close and its main stop
Calculation: Stored stop = main stop calculated on the first bar where a new position is observed, including for a flip; after a pyramid add, entry price plus a fixed multiple of initial risk for a long or minus that multiple for a short; after a partial exit, the tighter of the existing stored stop and entry price adjusted favorably by the break-even buffer
Long: Last completed longer higher-timeframe close > its EMA
Short: Last completed longer higher-timeframe close < its EMA
Long: MACD line > MACD signal line
Short: MACD line <= MACD signal line
Long: Bullish engulfing
Short: Bearish engulfing
Long: Position is flat AND no flip is pending AND bars since the last exit >= exit cooldown AND bars since the last long stop >= same-direction cooldown AND close > main long stop AND last completed longer higher-timeframe close > its EMA AND last completed shorter higher-timeframe RSI > momentum threshold AND chart-timeframe RSI > long threshold AND MACD line > MACD signal line AND bullish engulfing AND ATR > SMA of ATR AND volume > volume multiplier × SMA of volume
Short: Position is flat AND no flip is pending AND bars since the last exit >= exit cooldown AND bars since the last short stop >= same-direction cooldown AND close < main short stop AND last completed longer higher-timeframe close < its EMA AND last completed shorter higher-timeframe RSI < momentum threshold AND chart-timeframe RSI < short threshold AND MACD line < MACD signal line AND bearish engulfing AND ATR > SMA of ATR AND volume > volume multiplier × SMA of volume
Long: Position is flat AND a short non-flip position has exited AND its exit-bar high >= its stored stop AND bars since that exit >= flip wait AND bars since the last exit >= exit cooldown AND close > flip long stop
Short: Position is flat AND a long non-flip position has exited AND its exit-bar low <= its stored stop AND bars since that exit >= flip wait AND bars since the last exit >= exit cooldown AND close < flip short stop
Long: Position is long AND position is not a flip AND no pyramid add has occurred AND initial risk > 0 AND (close - entry price) / initial risk >= pyramid threshold
Short: Position is short AND position is not a flip AND no pyramid add has occurred AND initial risk > 0 AND (entry price - close) / initial risk >= pyramid threshold
Exit: long, low <= active long stop
Exit: short, high >= active short stop
Exit: long, no partial exit has occurred AND entry price - stored stop > 0 AND (close - entry price) / (entry price - stored stop) >= partial-exit threshold; close the configured fraction of the main or flip entry
Exit: short, no partial exit has occurred AND stored stop - entry price > 0 AND (entry price - close) / (stored stop - entry price) >= partial-exit threshold; close the configured fraction of the main or flip entry
Exit: long, last completed longer higher-timeframe close < its EMA AND last completed shorter higher-timeframe RSI < momentum threshold AND chart-timeframe RSI < short threshold AND MACD line < MACD signal line AND bearish engulfing AND ATR > SMA of ATR AND volume > volume multiplier × SMA of volume
Exit: short, last completed longer higher-timeframe close > its EMA AND last completed shorter higher-timeframe RSI > momentum threshold AND chart-timeframe RSI > long threshold AND MACD line > MACD signal line AND bullish engulfing AND ATR > SMA of ATR AND volume > volume multiplier × SMA of volume
Exit: long, position is a flip AND bars since flip entry >= flip time limit
Exit: short, position is a flip AND bars since flip entry >= flip time limit