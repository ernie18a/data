Calculation: Pivot = (high(T1, last completed bar) + low(T1, last completed bar) + close(T1, last completed bar)) / 3, sampled on chart bars
Calculation: Resistance 1 = 2 × Pivot − low(T1, last completed bar), sampled on chart bars
Calculation: Support 1 = 2 × Pivot − high(T1, last completed bar), sampled on chart bars
Calculation: Resistance 2 = Pivot + high(T1, last completed bar) − low(T1, last completed bar), sampled on chart bars
Calculation: Support 2 = Pivot − high(T1, last completed bar) + low(T1, last completed bar), sampled on chart bars
Long: up-arrow signal AND green Guppy MMA lines above red lines AND all green, red, and yellow Guppy MMA lines rising AND Laguerre crosses above its lower threshold AND EMA(close, shorter lookback) crosses above EMA(close, longer lookback) AND MACD main line(close, fast lookback, slow lookback, signal lookback) > 0
Short: down-arrow signal AND green Guppy MMA lines below red lines AND all green, red, and yellow Guppy MMA lines falling AND Laguerre crosses below its upper threshold AND EMA(close, shorter lookback) crosses below EMA(close, longer lookback) AND MACD main line(close, fast lookback, slow lookback, signal lookback) < 0
Exit: long, close > Resistance 1 AND close > entry price
Exit: long, HMA(close, lookback, last completed chart bar) buffer 1 is present AND close > entry price
Exit: long, close < Support 1 AND close > entry price
Exit: long, close < Support 2 AND close > entry price
Exit: long, open[1] < SMA(low, lookback, last completed chart bar) AND close > entry price
Exit: long, Slope Direction line turns red
Exit: short, close < Support 1 AND close < entry price
Exit: short, HMA(close, lookback, last completed chart bar) buffer 0 is present AND close < entry price
Exit: short, open[1] > SMA(high, lookback, last completed chart bar) AND close < entry price
Exit: short, Slope Direction line turns blue