Calculation: Swing trend = Initially neutral. A swing high or low is confirmed when the high or low N bars ago equals the highest high or lowest low over the latest 2N+1 bars; retain the latest confirmed level of each kind. Set trend bullish when close > latest swing high, then set it bearish when close < latest swing low; otherwise retain the previous trend.
Calculation: Higher-timeframe swing trend = Apply the swing trend calculation to higher-timeframe bars using the last completed bar, with the same swing lookback as the chart timeframe.
Calculation: ADX threshold = In manual mode, a parameter; in automatic mode, the nearest-rank median of ADX over a lookback, falling back to a parameter when unavailable.
Calculation: Volatility ratio = ATR as a percentage of close divided by its longer-lookback SMA, or a neutral parameter when that SMA is unavailable or nonpositive.
Calculation: ATR factor = In manual mode, a parameter; in automatic mode, a base parameter plus a scaling parameter times the volatility ratio's distance below a neutral parameter, clamped between lower and upper adjustment parameters.
Calculation: Stop-loss percentage = In manual mode, a parameter; in automatic mode, negative SMA of ATR as a percentage of close times a parameter, clamped between negative bounds, with a fallback parameter when the SMA is unavailable.
Calculation: Take-profit levels = At the entry signal bar, fix levels at its close plus or minus ATR times the ATR factor times successive increasing distance parameters. Each level can trigger once per position and closes a specified fraction of the remaining position.
Calculation: Break-even activation = When enabled, activate for the current position once close-based profit as a percentage of entry price reaches the trigger parameter; remain active until the position is closed.
Long: EMA > previous EMA
Short: EMA <= previous EMA
Long: Swing trend = bullish
Short: Swing trend = bearish
Long: Higher-timeframe swing trend = bullish
Short: Higher-timeframe swing trend = bearish
Long: Position side = flat AND EMA > previous EMA AND swing trend = bullish AND ADX > ADX threshold
Short: Position side = flat AND EMA < previous EMA AND swing trend = bearish AND ADX > ADX threshold
Exit: long, (close - entry price) / entry price × 100 < stop-loss percentage OR break-even activation = active AND low <= entry price OR swing trend = bearish
Exit: short, (entry price - close) / entry price × 100 < stop-loss percentage OR break-even activation = active AND high >= entry price OR swing trend = bullish
Exit: long, high > an untriggered long take-profit level
Exit: short, low < an untriggered short take-profit level