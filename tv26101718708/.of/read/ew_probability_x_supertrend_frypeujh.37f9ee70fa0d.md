Calculation: ATR trailing trend = Use a selectable source (hl2, close, ohlc4, or hlc3) and ATR; raw upper/lower bands are source ± ATR × multiplier. Carry the upper band forward unless the new raw upper band is lower or the previous close was above the previous upper band; carry the lower band forward unless the new raw lower band is higher or the previous close was below the previous lower band. Trend is up if the previous trend was up and close ≥ current lower band, or if the previous trend was down and close > current upper band; otherwise trend is down.
Long: ATR trailing trend changes from down to up
Short: ATR trailing trend changes from up to down
Exit: long, close < ATR trailing trend line
Exit: short, close > ATR trailing trend line