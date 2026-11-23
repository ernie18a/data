Calculation: oscillator = external source if external oscillator enabled, else oscillator type(close, high, low, oscillator length)
Calculation: pivot k = bar of the k-th most recent pivot of ZigZag(oscillator, zigzag length), where k = 0 is the last pivot; close(pivot k) and oscillator(pivot k) are the close and oscillator values at that bar
Calculation: new pivot = a pivot is added to ZigZag(oscillator, zigzag length) on this bar
Calculation: trend = sign(close(pivot 2) - close(pivot 4)) if trend method is zigzag; sign(MA(close, MA type, MA length) at pivot 2 - MA(close, MA type, MA length) at pivot 0) if trend method is MA difference; sign(external trend signal at pivot 0) if trend method is external
Calculation: lines hold = for every bar strictly between pivot 2 and pivot 0, dir * close(bar) <= dir * L(bar) AND dir * oscillator(bar) <= dir * M(bar), where dir = 1 if pivot 0 is a high pivot else -1, L is the straight line through close(pivot 2) and close(pivot 0), and M is the straight line through oscillator(pivot 2) and oscillator(pivot 0)
Calculation: stop = close(pivot 2) if market order enabled, or entry type is Cautious and trade is regular, or entry type is not Cautious and trade is hidden; else close(pivot 0); pivots as of entry bar
Calculation: target = E + risk-reward ratio * (E - stop), where E = close(pivot 2) if trade is regular and entry type is Confident, else close(pivot 1); pivots as of entry bar
Calculation: break level = close(pivot 0) as of entry bar
Long: long trades enabled AND regular divergence trading enabled AND new pivot AND pivot 0 is a low pivot AND close(pivot 0) < close(pivot 2) AND oscillator(pivot 0) > oscillator(pivot 2) AND trend = -1 AND lines hold
Long: long trades enabled AND hidden divergence trading enabled AND new pivot AND pivot 0 is a low pivot AND close(pivot 0) > close(pivot 2) AND oscillator(pivot 0) < oscillator(pivot 2) AND trend != -1 AND lines hold
Short: short trades enabled AND regular divergence trading enabled AND new pivot AND pivot 0 is a high pivot AND close(pivot 0) > close(pivot 2) AND oscillator(pivot 0) < oscillator(pivot 2) AND trend = 1 AND lines hold
Short: short trades enabled AND hidden divergence trading enabled AND new pivot AND pivot 0 is a high pivot AND close(pivot 0) < close(pivot 2) AND oscillator(pivot 0) > oscillator(pivot 2) AND trend != 1 AND lines hold
Exit: long, low <= stop
Exit: long, high >= target
Exit: short, high >= stop
Exit: short, low <= target
Exit: long, cancel on break enabled AND close < break level
Exit: short, cancel on break enabled AND close > break level