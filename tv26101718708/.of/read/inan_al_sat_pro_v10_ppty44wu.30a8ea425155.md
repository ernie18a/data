Calculation: bullish liquidity sweep = current low < the lowest low in the preceding lookback bars AND current close > current open
Calculation: bearish liquidity sweep = current high > the highest high in the preceding lookback bars AND current close < current open
Calculation: bullish structure break = current close > the most recent confirmed pivot high
Calculation: bearish structure break = current close < the most recent confirmed pivot low
Calculation: high volume = current volume > its moving average × a configurable multiplier
Calculation: bullish order block = previous close < previous open AND current close > previous high
Calculation: bearish order block = previous close > previous open AND current close < previous low
Long: current close > the long-term EMA AND the short-term EMA crosses above the long-term EMA AND RSI > its threshold AND bullish liquidity sweep AND high volume AND bullish structure break
Long: bullish liquidity sweep OR bullish order block
Short: current close < the long-term EMA AND the short-term EMA crosses below the long-term EMA AND RSI < its threshold AND bearish liquidity sweep AND high volume AND bearish structure break
Short: bearish liquidity sweep OR bearish order block