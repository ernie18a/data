Calculation: Dow swing trend = initialize neutral; update the latest swing high to high[swing lookback] when it equals highest(high, 2 × swing lookback + 1), and the latest swing low analogously using lowest(low, 2 × swing lookback + 1); each bar, set trend up if close > latest swing high, then set trend down if close < latest swing low, retaining the prior trend otherwise
Calculation: unrealized PnL percentage = 100 × (close − entry price) / entry price for a long position, or 100 × (entry price − close) / entry price for a short position
Calculation: target levels = for a long position, entry price + ATR(ATR lookback) × target factor × three successively increasing target multiples; for a short position, entry price − the same distance
Calculation: break-even stop price = entry price × (1 + buffer percentage / 100) for a long position, or entry price × (1 − buffer percentage / 100) for a short position
Long: position is flat or short AND EMA(close, EMA lookback) > EMA(close, EMA lookback)[1] AND Dow swing trend is up AND ADX(DI lookback, smoothing lookback) > ADX threshold AND (delta filter is disabled OR SMA(reference instrument footprint buy volume − sell volume, delta lookback) is unavailable OR that SMA > 0)
Short: position is flat or long AND EMA(close, EMA lookback) < EMA(close, EMA lookback)[1] AND Dow swing trend is down AND ADX(DI lookback, smoothing lookback) > ADX threshold AND (delta filter is disabled OR SMA(reference instrument footprint buy volume − sell volume, delta lookback) is unavailable OR that SMA < 0)
Exit: Long, unrealized PnL percentage < stop-loss threshold
Exit: Short, unrealized PnL percentage < stop-loss threshold
Exit: Long, first target is active AND high > first long target level
Exit: Long, second target is active AND high > second long target level
Exit: Long, third target is active AND high > third long target level
Exit: Short, first target is active AND low < first short target level
Exit: Short, second target is active AND low < second short target level
Exit: Short, third target is active AND low < third short target level
Exit: Long, break-even stop is enabled AND active after close-based unrealized PnL percentage reaches the break-even trigger AND low <= break-even stop price
Exit: Short, break-even stop is enabled AND active after close-based unrealized PnL percentage reaches the break-even trigger AND high >= break-even stop price
Exit: Long, Dow swing trend is down
Exit: Short, Dow swing trend is up