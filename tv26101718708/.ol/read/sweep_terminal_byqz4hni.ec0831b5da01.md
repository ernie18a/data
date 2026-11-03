Calculation: Daily open = open of the higher-timeframe daily bar still forming
Calculation: Weekly open = open of the higher-timeframe weekly bar still forming
Calculation: Session VWAP = volume-weighted average of (high + low + close) / 3, anchored to the current session
Calculation: Confirmed pivot high/low = a chart bar’s high/low is a pivot when it is an extreme over equal lookback bars on both sides; use the most recently confirmed pivot of each type until replaced or broken
Calculation: Bullish FVG = current chart-bar low > high two chart bars earlier; bearish FVG = current chart-bar high < low two chart bars earlier
Long: Close >= daily open
Long: Close >= weekly open
Long: Close >= session VWAP
Long: RSI >= 50
Long: DI+ > DI-
Long: After a chart bar closes below the low of the last completed higher-timeframe bar, a later chart bar closes >= that low and the lowest low since the breach is below it; OR the same condition holds for another enabled higher timeframe
Long: Configured break price (close when body confirmation is enabled, otherwise high) > latest confirmed, unbroken pivot high
Long: Bullish FVG exists and its size >= ATR × configured threshold
Short: Close < daily open
Short: Close < weekly open
Short: Close < session VWAP
Short: RSI < 50
Short: DI- > DI+
Short: After a chart bar closes above the high of the last completed higher-timeframe bar, a later chart bar closes <= that high and the highest high since the breach is above it; OR the same condition holds for another enabled higher timeframe
Short: Configured break price (close when body confirmation is enabled, otherwise low) < latest confirmed, unbroken pivot low
Short: Bearish FVG exists and its size >= ATR × configured threshold