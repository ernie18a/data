Calculation: Selected Hull moving average = selected SMA, EMA, RMA, WMA, VWMA, or Hull moving average of the selected source
Calculation: SSL exit line = selected moving average of lows when close is above the selected moving average of highs, selected moving average of highs when close is below the selected moving average of lows, otherwise the prior state (initial state: lows)
Calculation: ATR-adaptive Jurik moving average = Jurik filter of the selected source using a period scaled between half and full base period according to the current ATR’s position between its highest and lowest values over the base period
Calculation: Rapid Hull value = WMA of (2 × WMA(close, rounded half lookback) − WMA(close, lookback)) over the rounded square root of the lookback
Calculation: Confirmed swing high/low = a high/low greater/less than the highs/lows of the specified number of bars before and after it; the pivot is recognized after the bars following it complete
Long: On the selected signal timeframe (chart timeframe if none selected), the selected Hull moving average changes from falling to rising; suppress repeats while the prior raw signal is long; require the signal bar to close if close-wait is enabled
Short: On the selected signal timeframe (chart timeframe if none selected), the selected Hull moving average changes from rising to falling; suppress repeats while the prior raw signal is short; require the signal bar to close if close-wait is enabled
Long: On the selected signal timeframe (chart timeframe if none selected), close crosses above the SSL exit line; suppress repeats while the prior raw signal is long; require the signal bar to close if close-wait is enabled
Short: On the selected signal timeframe (chart timeframe if none selected), close crosses below the SSL exit line; suppress repeats while the prior raw signal is short; require the signal bar to close if close-wait is enabled
Long: On the selected signal timeframe (chart timeframe if none selected), rapid Hull value produces a long turn (current difference < prior difference AND prior difference ≥ the difference two bars earlier, where difference = prior rapid Hull value − 2 × current rapid Hull value); suppress repeats while the prior raw signal is long; require the signal bar to close if close-wait is enabled
Short: On the selected signal timeframe (chart timeframe if none selected), rapid Hull value produces a short turn (current difference < prior difference AND prior difference ≥ the difference two bars earlier, where difference = 2 × current rapid Hull value − prior rapid Hull value); suppress repeats while the prior raw signal is short; require the signal bar to close if close-wait is enabled
Long: On the selected signal timeframe (chart timeframe if none selected), the ATR-adaptive Jurik moving average crosses above its one-bar-lagged value; suppress repeats while the prior raw signal is long; require the signal bar to close if close-wait is enabled
Short: On the selected signal timeframe (chart timeframe if none selected), the ATR-adaptive Jurik moving average crosses below its one-bar-lagged value; suppress repeats while the prior raw signal is short; require the signal bar to close if close-wait is enabled
Long: Current low > high two bars earlier AND prior close > high two bars earlier
Short: Current high < low two bars earlier AND prior close < low two bars earlier
Long: Confirmed swing low
Short: Confirmed swing high
Long: Hull long signal AND SSL long signal AND rapid Hull long signal
Short: Hull short signal AND SSL short signal AND rapid Hull short signal