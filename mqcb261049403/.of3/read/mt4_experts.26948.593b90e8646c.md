Long: SMA(close, shorter lookback, last completed chart bar) < SMA(close, longer lookback, last completed chart bar)
Short: SMA(close, shorter lookback, last completed chart bar) > SMA(close, longer lookback, last completed chart bar)
Long: lower Envelopes(close, lookback, moving-average shift, deviation, SMA, current chart bar) < Ask
Short: lower Envelopes(close, lookback, moving-average shift, deviation, SMA, current chart bar) >= Ask AND upper Envelopes(close, lookback, moving-average shift, deviation, SMA, current chart bar) > Ask
Exit: long, close[1] = upper Bollinger Band(close, lookback, deviation, previous completed chart bar)
Exit: short, close[1] = lower Bollinger Band(close, lookback, deviation, previous completed chart bar)
Calculation: basket profit = sum(open-position profit + swap + commission)
Exit: long, basket profit <= -balance * hard-stop percentage / 100
Exit: short, basket profit <= -balance * hard-stop percentage / 100
Exit: long, basket profit <= -balance * loss-limit percentage / 100 AND open trade count >= minimum trade count
Exit: short, basket profit <= -balance * loss-limit percentage / 100 AND open trade count >= minimum trade count