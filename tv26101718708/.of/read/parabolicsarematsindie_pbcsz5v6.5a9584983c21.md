Calculation: Fast and slow moving averages = independently selected SMA, EMA, RMA, WMA, or VWMA of a selected price source; the fast average has a shorter lookback than the slow average.
Calculation: Long setup = a persistent Boolean, initially false. Set it true when it is false, the position is flat, close <= fast moving average, and fast moving average > slow moving average. Set it false when fast moving average < slow moving average, or when it is true and close >= fast moving average, fast moving average > slow moving average, current Parabolic SAR < low, and previous Parabolic SAR > previous high. Apply these updates in the stated order.
Calculation: Short setup = a persistent Boolean, initially false. Set it true when it is false, the position is flat, close >= fast moving average, and fast moving average < slow moving average. Set it false when fast moving average > slow moving average, or when it is true and close <= fast moving average, fast moving average < slow moving average, current Parabolic SAR > high, and previous Parabolic SAR < previous low. Apply these updates in the stated order.
Calculation: Long confirmation = long setup is true immediately before its confirmation reset AND close >= fast moving average AND fast moving average > slow moving average AND current Parabolic SAR < low AND previous Parabolic SAR > previous high.
Calculation: Short confirmation = short setup is true immediately before its confirmation reset AND close <= fast moving average AND fast moving average < slow moving average AND current Parabolic SAR > high AND previous Parabolic SAR < previous low.
Calculation: Stop buffer = EMA of true range multiplied by a configurable factor.
Calculation: Long stop = Parabolic SAR on the signal bar minus the stop buffer on that bar; hold it fixed for the trade.
Calculation: Short stop = Parabolic SAR on the signal bar plus the stop buffer on that bar; hold it fixed for the trade.
Calculation: Long target = signal-bar close + (signal-bar close - long stop) multiplied by a configurable risk-reward ratio; hold it fixed for the trade.
Calculation: Short target = signal-bar close - (short stop - signal-bar close) multiplied by a configurable risk-reward ratio; hold it fixed for the trade.
Long: Long setup = true after its updates.
Short: Short setup = true after its updates.
Long: Long confirmation = true AND long entries enabled = true AND position = flat AND bar is completed AND datetime >= configured start AND datetime <= configured end AND (no sessions enabled OR bar time is within an enabled UTC session).
Short: Short confirmation = true AND short entries enabled = true AND position = flat AND bar is completed AND datetime >= configured start AND datetime <= configured end AND (no sessions enabled OR bar time is within an enabled UTC session).
Exit: long, low <= long stop OR high >= long target.
Exit: short, high >= short stop OR low <= short target.