Calculation: Upper band = VWAP(source, reset event) + standard deviation(source, lookback) * multiplier
Calculation: Lower band = VWAP(source, reset event) - standard deviation(source, lookback) * multiplier
Calculation: Long peak = maximum high from the long-entry bar through the current bar
Calculation: Short trough = minimum low from the short-entry bar through the current bar
Long: EMA(close, EMA lookback) crosses above VWAP(source, reset event) at chart-bar close
Short: EMA(close, EMA lookback) crosses below VWAP(source, reset event) at chart-bar close
Exit: long, (high >= Upper band AND low <= Upper band, immediately intrabar) OR ((Long peak - entry price) / entry price * 100 >= activation-profit percentage AND close <= Long peak * (1 - trailing-distance percentage / 100))
Exit: short, (high >= Lower band AND low <= Lower band, immediately intrabar) OR ((entry price - Short trough) / entry price * 100 >= activation-profit percentage AND close >= Short trough * (1 + trailing-distance percentage / 100))