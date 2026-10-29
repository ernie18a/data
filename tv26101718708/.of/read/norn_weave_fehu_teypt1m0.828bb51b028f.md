Calculation: Dow Theory trend = track the latest swing high and swing low, each detected when the high or low from one swing-length bars ago is the highest or lowest across the centered window of 2 × swing length + 1 bars; switch trend to bullish when close exceeds the latest swing high, switch to bearish when close falls below the latest swing low, and otherwise retain the prior trend
Long: EMA(close) > its prior-bar value AND Dow Theory trend is bullish AND ADX is above its threshold
Short: EMA(close) < its prior-bar value AND Dow Theory trend is bearish AND ADX is above its threshold
Exit: long, close is below entry price by more than the stop-loss percentage
Exit: short, close is above entry price by more than the stop-loss percentage
Exit: long, after close-based floating profit reaches the break-even trigger, low <= the break-even stop price (entry price adjusted slightly upward)
Exit: short, after close-based floating profit reaches the break-even trigger, high >= the break-even stop price (entry price adjusted slightly downward)
Exit: long, Dow Theory trend is bearish
Exit: short, Dow Theory trend is bullish
Exit: long, high > entry price + ATR(50) × ATR factor × 1
Exit: long, high > entry price + ATR(50) × ATR factor × 2
Exit: long, high > entry price + ATR(50) × ATR factor × 3
Exit: short, low < entry price - ATR(50) × ATR factor × 1
Exit: short, low < entry price - ATR(50) × ATR factor × 2
Exit: short, low < entry price - ATR(50) × ATR factor × 3