Calculation: Short-term SMA = simple moving average of close over a shorter lookback than the long-term SMA
Calculation: Long-term SMA = simple moving average of close over a longer lookback than the short-term SMA
Calculation: Uptrend = close > long-term SMA AND short-term SMA > long-term SMA AND long-term SMA > its value on the prior bar
Calculation: Downtrend = close < long-term SMA AND short-term SMA < long-term SMA AND long-term SMA < its value on the prior bar
Calculation: Swing low = low equals the lowest low over the swing lookback
Calculation: Swing high = high equals the highest high over the swing lookback
Calculation: Green diamond = Uptrend AND Swing low
Calculation: Red diamond = Downtrend AND Swing high
Calculation: Long setup = a green diamond occurred within the pullback lookback AND (Uptrend OR (close > long-term SMA AND long-term SMA > its value on the prior bar)) AND close > short-term SMA
Calculation: Short setup = a red diamond occurred within the pullback lookback AND (Downtrend OR (close < long-term SMA AND long-term SMA < its value on the prior bar)) AND close < short-term SMA
Calculation: Long stop = on a Long setup, the lowest low over the pullback lookback plus the setup bar; while long, update to the current low on a Green diamond if Uptrend, no Short setup, and current low > long stop
Calculation: Long target = on a Long setup, the highest high over the pullback lookback plus the setup bar
Calculation: Short stop = on a Short setup, the highest high over the pullback lookback plus the setup bar; while short, update to the current high on a Red diamond if Downtrend, no Long setup, and current high < short stop
Calculation: Short target = on a Short setup, the lowest low over the pullback lookback plus the setup bar
Long: Green diamond OR Long setup OR (Swing low AND NOT Uptrend AND close > long-term SMA)
Short: Red diamond OR Short setup OR (Swing high AND NOT Downtrend AND close < long-term SMA)
Exit: long, Short setup OR low <= long stop OR high >= long target
Exit: short, Long setup OR high >= short stop OR low <= short target