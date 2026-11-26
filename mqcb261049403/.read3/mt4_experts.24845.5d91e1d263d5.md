Calculation: Fibonacci line value at bar n = the chart Fibonacci line's value at bar n
Calculation: Instrument open profit = sum of open positions' profit in account currency
Calculation: Instrument net open profit = sum of open positions' profit, commission, and swap
Calculation: Reverse cumulative net position profit = running sum of each open position's profit, commission, and swap in reverse order
Long: open trade count < maximum trade count AND abs(close - close[2]) > point size × retrace-distance parameter AND LWMA(typical price, shorter lookback, chart timeframe, forming bar) > LWMA(typical price, longer lookback, chart timeframe, forming bar) AND low[2] < high[1] AND (in strategy testing OR (outside strategy testing AND open[2] > Fibonacci line value at bar 2 AND (close[2] < Fibonacci line value at bar 1 OR close[1] <= Fibonacci line value at bar 1)))
Short: open trade count < maximum trade count AND abs(close - close[2]) > point size × retrace-distance parameter AND LWMA(typical price, shorter lookback, chart timeframe, forming bar) < LWMA(typical price, longer lookback, chart timeframe, forming bar) AND low[1] < high[2] AND (in strategy testing OR (outside strategy testing AND open[2] < Fibonacci line value at bar 2 AND (close[2] > Fibonacci line value at bar 1 OR close[1] >= Fibonacci line value at bar 1)))
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance
Exit: long, move-to-break-even is enabled AND price has risen above entry price by the stop-move trigger distance AND low <= entry price + stop adjustment distance
Exit: short, move-to-break-even is enabled AND price has fallen below entry price by the stop-move trigger distance AND high >= entry price - stop adjustment distance
Exit: long, candle trailing is enabled AND low <= lowest(low, lookback)[1] - trailing pad distance
Exit: short, candle trailing is enabled AND high >= highest(high, lookback)[2] + trailing pad distance
Exit: long, candle trailing is disabled AND price has risen above entry price by the trailing activation distance AND low <= highest(high since entry) - trailing distance
Exit: short, candle trailing is disabled AND price has fallen below entry price by the trailing activation distance AND high >= lowest(low since entry) + trailing distance
Exit: long or short, money take-profit is enabled AND instrument open profit >= money profit target
Exit: long or short, money trailing is enabled AND instrument net open profit > 0 AND instrument net open profit < money profit target AND reverse cumulative net position profit <= instrument net open profit - money stop amount
Exit: long or short, money trailing is enabled AND instrument net open profit < 0 AND abs(instrument open profit) > account equity reference × equity-risk parameter / 100 × loss multiplier AND sum of absolute per-position net open profits >= money stop amount