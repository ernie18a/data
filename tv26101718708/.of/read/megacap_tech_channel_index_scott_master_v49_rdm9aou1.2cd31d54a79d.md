Calculation: EMA = exponential moving average of chart-timeframe closes.
Calculation: ATR = average true range of chart-timeframe bars.
Calculation: Smoothed RSI = RSI averaged over a shorter lookback; use a shorter RSI lookback on intraday charts than on other charts.
Calculation: Active oversold threshold = lower rolling percentile of smoothed RSI over a long lookback; during warm-up use a higher percentile over a shorter lookback, then use a configured fallback until that shorter lookback is available.
Calculation: Active overbought threshold = upper rolling percentile of smoothed RSI over a long lookback; during warm-up use a lower percentile over a shorter lookback, then use a configured fallback until that shorter lookback is available.
Calculation: Reset gate = initially armed, disarmed after a long entry, and rearmed when close returns to or below EMA plus a configured percentage.
Calculation: Initial stop = signal-bar close minus either a configured ATR multiple or a configured percentage of signal-bar close.
Calculation: Trailing stop = highest value so far of chart-timeframe close minus a configured ATR multiple; once unrealized profit exceeds a configured threshold, also floor it at entry price plus a configured ATR fraction.
Long: low <= EMA - ATR × configured channel multiplier AND close > open AND Smoothed RSI <= Active oversold threshold AND Reset gate = armed AND close < EMA + configured chase allowance AND NY regular-session bar is confirmed.
Exit: Long, low <= max(Initial stop, Trailing stop)
Exit: Long, (Smoothed RSI >= Active overbought threshold OR close >= EMA + ATR × configured exhaustion multiple) AND minimum configured holding period has elapsed AND NY regular-session bar is confirmed