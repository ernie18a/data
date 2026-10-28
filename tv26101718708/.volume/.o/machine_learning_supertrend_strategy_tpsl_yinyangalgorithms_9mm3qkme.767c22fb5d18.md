Calculation: SuperTrend = ATR-based trend line using ratcheting upper and lower bands; ATR uses the same lookback as the bands
Calculation: ML SuperTrend = selected average of current and prior SuperTrend values, using either a simple average, an average of fast and slow SuperTrend averages selected by KNN distance bounds, or no averaging; fast lookback is shorter than slow lookback, and KNN retains the nearest configured number of distances from the most recent data
Calculation: Stop-loss level = ML SuperTrend minus ML SuperTrend times the stop-loss multiplier when bullish; plus that amount when bearish
Calculation: Direction = bullish when close > stop-loss level; bearish otherwise
Calculation: Take-profit level = ML SuperTrend plus ML SuperTrend times the take-profit multiplier when bullish; minus that amount when bearish
Long: direction changes from bearish to bullish; place a stop entry at the stop-loss level
Short: direction changes from bullish to bearish; place a stop entry at the stop-loss level
Exit: long, close > take-profit level OR (same-bar entry and exit enabled AND prior direction bullish AND close < prior stop-loss level)
Exit: short, close < take-profit level OR (same-bar entry and exit enabled AND prior direction bearish AND close > prior stop-loss level)