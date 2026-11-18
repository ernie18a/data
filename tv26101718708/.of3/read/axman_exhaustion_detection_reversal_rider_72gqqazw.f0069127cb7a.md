Calculation: Bullish exhaustion pattern = RSI(close, RSI period) < low RSI threshold AND volume > SMA(volume, volume-average lookback) * volume sensitivity AND (low < low[1] OR (low < LOWEST(low, liquidity lookback)[1] AND close > LOWEST(low, liquidity lookback)[1]))
Calculation: Bearish exhaustion pattern = RSI(close, RSI period) > high RSI threshold AND volume > SMA(volume, volume-average lookback) * volume sensitivity AND (high > high[1] OR (high > HIGHEST(high, liquidity lookback)[1] AND close < HIGHEST(high, liquidity lookback)[1]))
Long: Bullish exhaustion pattern
Short: Bearish exhaustion pattern
Long: The most recent bullish exhaustion pattern occurred no more than the entry-window bars ago AND no long entry has occurred since that pattern AND close crosses above high[1] AND RSI(close, RSI period) > RSI(close, RSI period)[1] AND the position is flat
Short: The most recent bearish exhaustion pattern occurred no more than the entry-window bars ago AND no short entry has occurred since that pattern AND close crosses below low[1] AND RSI(close, RSI period) < RSI(close, RSI period)[1] AND the position is flat
Exit: long, Bearish exhaustion pattern
Exit: short, Bullish exhaustion pattern