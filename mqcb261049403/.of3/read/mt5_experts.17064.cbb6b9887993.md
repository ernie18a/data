Calculation: Risk offset = risk base parameter − risk parameter
Calculation: Trend state = down when Williams %R(high, low, close, lookback, T1, last completed bar) < Williams %R minimum + risk offset, up when it is > Williams %R maximum − risk offset, and otherwise its prior state; initialize as down
Long: Trend state changes from down to up on the last completed T1 bar selected by the signal-bar offset parameter
Short: Trend state changes from up to down on the last completed T1 bar selected by the signal-bar offset parameter
Long: Position side is long AND current price is more than the add-on distance parameter, in points, above the most recent long entry price
Short: Position side is short AND current price is more than the add-on distance parameter, in points, below the most recent short entry price