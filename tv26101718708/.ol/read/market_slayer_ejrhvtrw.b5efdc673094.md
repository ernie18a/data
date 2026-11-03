Calculation: Bullish confirmation = let HLV be 1 when close > WMA(high, lookback), -1 when close < WMA(low, lookback), otherwise its previous value; bullish when the SSL-up line is above the SSL-down line, where SSL-down is WMA(high, lookback) if HLV < 0 and WMA(low, lookback) otherwise, and SSL-up is the opposite line
Calculation: Higher-timeframe bullish confirmation = bullish confirmation on the last completed bar of a higher timeframe
Long: short WMA crosses above long WMA AND higher-timeframe bullish confirmation AND no open trade, OR bullish confirmation changes from false to true
Short: short WMA crosses below long WMA AND higher-timeframe confirmation is bearish AND no open trade, OR bearish confirmation changes from false to true
Exit: long, higher-timeframe confirmation is bearish
Exit: short, higher-timeframe bullish confirmation