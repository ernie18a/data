Calculation: Zigzag trend = switch from up to down when the current low is at or below the lowest low over the zigzag lookback; switch from down to up when the current high is at or above the highest high over that lookback; otherwise retain the prior trend.
Calculation: Swing high/low = the highest high/lowest low since the prior opposite zigzag trend change; retain each newly confirmed swing point in sequence.
Calculation: Bullish market-structure break = market state changes from bearish to bullish when the latest swing high exceeds the prior swing high by more than the fib factor times the distance from the prior swing high to the latest swing low, provided the latest swing points differ from those at the prior market-state change.
Calculation: Bearish market-structure break = market state changes from bullish to bearish when the latest swing low is below the prior swing low by more than the fib factor times the distance from the latest swing high to the prior swing low, provided the latest swing points differ from those at the prior market-state change.
Calculation: Top liquidity = the higher of the latest swing high and the current day's highest high.
Calculation: Bottom liquidity = the lower of the latest swing low and the current day's lowest low.
Calculation: Bullish sweep state = set when low is below bottom liquidity and close is above bottom liquidity; retain until a market-structure break or bullish signal resets it.
Calculation: Bearish sweep state = set when high is above top liquidity and close is below top liquidity; retain until a market-structure break or bearish signal resets it.
Long: bullish market-structure break
Long: bullish sweep state AND close > prior open AND close > prior high AND open < prior close AND low <= bottom liquidity × 1.005
Short: bearish market-structure break
Short: bearish sweep state AND close < prior open AND close < prior low AND open > prior close AND high >= top liquidity × 0.995