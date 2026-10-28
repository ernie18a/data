Calculation: Volume-weighted center = rolling sum(close × volume) ÷ rolling sum(volume) over one configurable lookback
Calculation: Normalized distance = (close − volume-weighted center) ÷ ATR
Calculation: Lowest band = volume-weighted center − band width × ATR
Calculation: Highest band = volume-weighted center + band width × ATR
Long: Trend mode AND normalized distance > escape distance AND volume-weighted center > its previous-bar value AND previous trend was not long OR Midline mode AND close > volume-weighted center AND previous trend was not long OR Bands mode AND close crosses above the lowest band AND previous trend was not long
Short: Trend mode AND normalized distance < −escape distance AND volume-weighted center < its previous-bar value AND previous trend was not short OR Midline mode AND close < volume-weighted center AND previous trend was not short OR Bands mode AND close crosses below the highest band AND previous trend was not short