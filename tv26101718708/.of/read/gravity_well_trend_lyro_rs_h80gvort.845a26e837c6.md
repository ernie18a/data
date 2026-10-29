Calculation: Gravity center = SMA(close × volume, lookback) / SMA(volume, same lookback)
Calculation: Lowest band = gravity center − band width × ATR
Calculation: Highest band = gravity center + band width × ATR
Calculation: Normalized distance = (close − gravity center) / ATR
Long: In Trend mode, normalized distance > escape threshold AND gravity center > its previous-bar value AND previous trend state is not long OR in Midline mode, close > gravity center AND previous trend state is not long OR in Bands mode, close crosses above the lowest band AND previous trend state is not long
Short: In Trend mode, normalized distance < −escape threshold AND gravity center < its previous-bar value AND previous trend state is not short OR in Midline mode, close < gravity center AND previous trend state is not short OR in Bands mode, close crosses below the highest band AND previous trend state is not short