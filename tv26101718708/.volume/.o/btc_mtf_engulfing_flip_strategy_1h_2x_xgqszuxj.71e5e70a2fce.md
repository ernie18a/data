Calculation: Bullish engulfing = prior bar closes below its open, current bar closes above its open, current close ≥ prior open, current open ≤ prior close, and current body > prior body × body multiplier
Calculation: Bearish engulfing = prior bar closes above its open, current bar closes below its open, current open ≥ prior close, current close ≤ prior open, and current body > prior body × body multiplier
Calculation: Long stop = max(min(current low, prior low) × (1 − stop buffer), entry-bar close × (1 − stop cap))
Calculation: Short stop = min(max(current high, prior high) × (1 + stop buffer), entry-bar close × (1 + stop cap))
Calculation: Flip long stop = max(lowest low over the flip swing lookback × (1 − stop buffer), broken short stop × (1 − flip stop cap))
Calculation: Flip short stop = min(highest high over the flip swing lookback × (1 + stop buffer), broken long stop × (1 + flip stop cap))
Long: 1H RSI > long threshold AND 1H MACD line > signal line AND bullish engulfing AND 1H ATR > its longer-lookback SMA AND 1H volume > its shorter-lookback SMA × volume multiplier AND last completed daily close > last completed daily EMA AND last completed 4H RSI > midpoint AND flat position AND no pending flip AND no long-side stop cooldown AND no post-exit cooldown AND no drawdown halt AND entry close > long stop
Long: flat position AND pending flip is long after a main short stop-out AND flip wait elapsed AND no post-exit cooldown AND no drawdown halt AND entry close > flip long stop
Short: 1H RSI < short threshold AND 1H MACD line < signal line AND bearish engulfing AND 1H ATR > its longer-lookback SMA AND 1H volume > its shorter-lookback SMA × volume multiplier AND last completed daily close < last completed daily EMA AND last completed 4H RSI < midpoint AND flat position AND no pending flip AND no short-side stop cooldown AND no post-exit cooldown AND no drawdown halt AND entry close < short stop
Short: flat position AND pending flip is short after a main long stop-out AND flip wait elapsed AND no post-exit cooldown AND no drawdown halt AND entry close < flip short stop
Exit: long, low ≤ stored stop
Exit: short, high ≥ stored stop
Exit: long, (close − entry price) / initial stop distance ≥ partial-profit R threshold
Exit: short, (entry price − close) / initial stop distance ≥ partial-profit R threshold
Exit: long, short entry signal is true
Exit: short, long entry signal is true
Exit: long or short flip position, elapsed time since flip entry ≥ flip time-stop