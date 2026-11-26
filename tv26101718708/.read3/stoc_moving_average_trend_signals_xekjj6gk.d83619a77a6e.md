Calculation: ATR trailing stop = entry-bar high - ATR(ATR length) * ATR multiplier; on each later chart bar, the maximum of its prior value and the highest high since entry - current ATR(ATR length) * ATR multiplier
Long: Flat AND ((entry mode is MA Stack AND fast EMA > intermediate EMA > intermediate SMA > long-term SMA AND this alignment was false on the previous chart bar) OR (entry mode is Price vs MA AND close crosses above the selected signal MA AND (MA direction requirement is disabled OR selected signal MA > its value slope-lookback chart bars ago)) OR (entry mode is Fast/Slow Crossover AND fast EMA crosses above intermediate EMA AND (MA direction requirement is disabled OR intermediate EMA > its value slope-lookback chart bars ago))) AND (volume filter is disabled OR volume is unavailable OR SMA(volume, volume lookback) is unavailable OR volume >= SMA(volume, volume lookback) * volume multiplier) AND (chop filter is disabled OR (close = 0 ? 0 : abs(fast EMA - long-term SMA) / close * 100) >= minimum separation) AND (bar-close confirmation is disabled OR chart bar is confirmed)
Long: fast EMA > intermediate EMA > intermediate SMA > long-term SMA
Long: close > selected signal MA AND selected signal MA > its value slope-lookback chart bars ago
Long: close > selected signal MA
Long: selected signal MA > its value slope-lookback chart bars ago
Long: fast EMA > intermediate EMA > intermediate SMA > long-term SMA AND this alignment was false on the previous chart bar
Short: fast EMA < intermediate EMA < intermediate SMA < long-term SMA
Short: close < selected signal MA AND selected signal MA < its value slope-lookback chart bars ago
Short: close < selected signal MA
Short: selected signal MA < its value slope-lookback chart bars ago
Short: fast EMA < intermediate EMA < intermediate SMA < long-term SMA AND this alignment was false on the previous chart bar
Exit: long, (exit mode is ATR Trailing Exit AND close < ATR trailing stop AND (bar-close confirmation is disabled OR chart bar is confirmed)) OR (exit mode is MA Signal Exit AND (entry mode is MA Stack AND bullish alignment is false now AND was true on the previous chart bar OR entry mode is Price vs MA AND close crosses below selected signal MA OR entry mode is Fast/Slow Crossover AND fast EMA crosses below intermediate EMA) AND (bar-close confirmation is disabled OR chart bar is confirmed))