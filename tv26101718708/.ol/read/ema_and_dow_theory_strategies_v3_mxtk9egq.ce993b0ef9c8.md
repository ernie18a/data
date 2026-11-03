Calculation: Swing high/low = a bar’s high/low is the highest/lowest within a symmetric window extending the swing detection period before and after that bar; retain the latest confirmed swing high and low.
Calculation: Dow trend = bullish when close > the latest confirmed swing high; bearish when close < the latest confirmed swing low; otherwise retain the previous trend, initially neutral.
Long: EMA > its previous-bar value AND Dow trend is bullish AND ADX > threshold
Short: EMA < its previous-bar value AND Dow trend is bearish AND ADX > threshold
Exit: long, close < latest confirmed swing low
Exit: short, close > latest confirmed swing high
Exit: long, percentage loss from entry price < stop-loss threshold
Exit: short, percentage loss from entry price < stop-loss threshold
Exit: long, high > entry price + ATR × target multiplier
Exit: long, high > entry price + 2 × ATR × target multiplier
Exit: long, high > entry price + 3 × ATR × target multiplier
Exit: short, low < entry price − ATR × target multiplier
Exit: short, low < entry price − 2 × ATR × target multiplier
Exit: short, low < entry price − 3 × ATR × target multiplier