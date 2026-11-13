Calculation: src = Heikin Ashi close of chart-timeframe bars
Calculation: stop = ATR trailing stop on src with nLoss = multiplier * ATR (short lookback); prev = stop[1] (0 at start); stop = max(prev, src - nLoss) if src > prev AND src[1] > prev; else min(prev, src + nLoss) if src < prev AND src[1] < prev; else src - nLoss if src > prev; else src + nLoss
Calculation: trend(tf) on bars of timeframe tf = Up if EMA(close, fast) > EMA(close, slow) AND EMA(close, fast) > EMA(close, fast) from 3 bars earlier AND abs(fast EMA - slow EMA) / close * 100 > small threshold AND ADX >= ADX lower bound; Down if the mirrored condition holds (fast < slow, fast EMA below its value 3 bars earlier, same difference threshold, ADX >= ADX lower bound); otherwise Side (fast EMA period shorter than slow EMA period)
Calculation: AVG = sum over a fixed set of timeframes (some lower and some higher than the chart timeframe) of score(trend(tf)), score Up = +1, Down = -1, Side = 0, each evaluated at the current chart bar (higher timeframes use the bar still forming); AVG is Up if sum >= N, Down if sum <= -N, otherwise Side
Long: src > stop AND src[1] <= stop[1] AND Supertrend is bullish (price above Supertrend line) AND ADX >= ADX lower bound AND ADX <= ADX upper bound (lower < upper) AND AVG is not Down
Short: src < stop AND src[1] >= stop[1] AND Supertrend is bearish (price below Supertrend line) AND ADX >= ADX lower bound AND ADX <= ADX upper bound AND AVG is not Up
Long: src > stop
Short: src <= stop
Long: AVG is Up
Short: AVG is Down