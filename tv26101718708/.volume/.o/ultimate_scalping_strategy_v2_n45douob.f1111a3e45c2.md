Calculation: Bullish engulfing = current close > current open AND previous close < previous open AND current close > previous open AND current open < previous close
Calculation: Bearish engulfing = current close < current open AND previous close > previous open AND current close < previous open AND current open > previous close
Calculation: Stop loss = average entry price minus (long) or plus (short) current-bar ATR × stop multiplier
Calculation: Take profit = average entry price plus (long) or minus (short) current-bar ATR × target multiplier
Long: fast EMA crosses above slow EMA AND close > session VWAP AND (price-action filter disabled OR bullish engulfing) AND (volume filter disabled OR volume > its moving average) AND long trading enabled
Short: fast EMA crosses below slow EMA AND close < session VWAP AND (price-action filter disabled OR bearish engulfing) AND (volume filter disabled OR volume > its moving average) AND short trading enabled
Exit: long, low <= stop loss OR (trailing-stop mode disabled AND high >= take profit) OR (opposite-signal exit enabled AND Short condition) OR (trailing-stop mode enabled AND the active ATR trailing stop is reached)
Exit: short, high >= stop loss OR (trailing-stop mode disabled AND low <= take profit) OR (opposite-signal exit enabled AND Long condition) OR (trailing-stop mode enabled AND the active ATR trailing stop is reached)