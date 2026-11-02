Calculation: Bullish confluence = close > VWMA(close) AND shorter-period EMA(close) > longer-period EMA(close) AND RSI(close) > bullish threshold AND Supertrend direction is bullish AND (ADX filter disabled OR ADX > threshold).
Calculation: Bearish confluence = close < VWMA(close) AND shorter-period EMA(close) < longer-period EMA(close) AND RSI(close) < bearish threshold AND Supertrend direction is bearish AND (ADX filter disabled OR ADX > threshold).
Calculation: Trend state = initially neutral; on each bar set bullish if bullish confluence, otherwise bearish if bearish confluence, otherwise neutral if the previous state is bullish AND close < Supertrend line OR the previous state is bearish AND close > Supertrend line; otherwise retain the previous state.
Calculation: Bullish signal = bullish confluence AND previous trend state is not bullish AND bars since either signal >= cooldown. Bearish signal = bearish confluence AND previous trend state is not bearish AND bars since either signal >= cooldown. Initially the cooldown is satisfied; reset the count on either signal. Update trend state even when cooldown blocks a signal.
Calculation: Initial stop distance = abs(entry close - entry-bar Supertrend line) in Supertrend mode; min(abs(entry close - entry-bar Supertrend line), entry-bar ATR multiplied by the ATR cap multiplier) in ATR cap mode; entry close multiplied by the fixed stop percentage in fixed-percentage mode. ATR uses the Supertrend ATR period.
Calculation: Stop = on a signal initialize to entry price minus initial stop distance for a long, or entry price plus initial stop distance for a short. On every bar including the signal bar, before checking the current bar's target hit, update it as follows: if the first target was hit on an earlier bar, for a long use max(previous stop, Supertrend line) when Supertrend is bullish and max(previous stop, entry price) otherwise; for a short use min(previous stop, Supertrend line) when Supertrend is bearish and min(previous stop, entry price) otherwise. If the first target was not hit on an earlier bar and stop mode is Supertrend, set the stop to the Supertrend line when its direction agrees with the position; otherwise retain the stop. The first target is entry price plus the initial stop distance multiplied by the first target risk-reward parameter for a long, or entry price minus that distance multiplied by the parameter for a short; it is hit when high >= the target for a long or low <= the target for a short, including on the signal bar. A new signal replaces the existing trade state.
Long: Bullish signal.
Short: Bearish signal.
Long: Trend state is bullish.
Short: Trend state is bearish.
Long: close > VWMA(close).
Short: close <= VWMA(close).
Long: shorter-period EMA(close) > longer-period EMA(close).
Short: shorter-period EMA(close) <= longer-period EMA(close).
Long: RSI(close) > bullish threshold.
Short: RSI(close) <= bullish threshold AND RSI(close) < bearish threshold.
Long: Supertrend direction is bullish.
Short: Supertrend direction is bearish.
Exit: long, (low <= stop OR Supertrend direction is bearish) AND bullish signal is false AND bearish signal is false.
Exit: short, (high >= stop OR Supertrend direction is bullish) AND bullish signal is false AND bearish signal is false.