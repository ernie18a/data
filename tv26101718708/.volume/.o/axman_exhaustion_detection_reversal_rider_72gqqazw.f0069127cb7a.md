Calculation: Prior swing high = highest high over the liquidity lookback, ending on the last completed bar
Calculation: Prior swing low = lowest low over the liquidity lookback, ending on the last completed bar
Calculation: Bullish liquidity grab = current low < prior swing low AND current close > prior swing low
Calculation: Bearish liquidity grab = current high > prior swing high AND current close < prior swing high
Calculation: Bullish exhaustion = RSI < oversold threshold AND current volume > moving average of volume over its lookback × volume multiplier AND (current low < previous bar low OR bullish liquidity grab)
Calculation: Bearish exhaustion = RSI > overbought threshold AND current volume > moving average of volume over its lookback × volume multiplier AND (current high > previous bar high OR bearish liquidity grab)
Calculation: Bullish active window = a bullish exhaustion occurred within the entry-window lookback bars, and has not been reset by a long entry
Calculation: Bearish active window = a bearish exhaustion occurred within the entry-window lookback bars, and has not been reset by a short entry
Long: Bullish exhaustion
Long: Bullish active window AND close crosses above the previous bar's high AND RSI > previous bar RSI AND position is flat
Short: Bearish exhaustion
Short: Bearish active window AND close crosses below the previous bar's low AND RSI < previous bar RSI AND position is flat
Exit: long, bearish exhaustion
Exit: short, bullish exhaustion