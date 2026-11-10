Calculation: Bull score = count of these true conditions: close > session VWAP of typical price; RSI > midpoint; MACD line > signal line; shorter EMA > longer EMA; ADX > strength threshold AND close > shorter EMA; volume > volume SMA AND close > open; reference-timeframe RSI > midpoint. The reference timeframe may be higher or lower than the chart timeframe; use its last completed bar on historical data and its still-forming bar in real time.
Calculation: Bear score = count of these true conditions: close < session VWAP of typical price; RSI < midpoint; MACD line < signal line; shorter EMA < longer EMA; ADX > strength threshold AND close < shorter EMA; volume > volume SMA AND close < open; reference-timeframe RSI < midpoint. Use the same reference timeframe and bar selection as the bull score.
Calculation: Last signal direction = direction of the most recent qualifying EMA-cross entry signal, initially neither; retain it until an opposite qualifying signal occurs.
Calculation: Target distance = ATR on the entry signal bar multiplied by a risk multiplier and by a target multiplier; use each of the ordered target multipliers.
Long: Shorter close EMA crosses above longer close EMA AND last signal direction is not long AND (volume filter is disabled OR volume >= previous bar volume multiplied by volume multiplier).
Short: Shorter close EMA crosses below longer close EMA AND last signal direction is not short AND (volume filter is disabled OR volume >= previous bar volume multiplied by volume multiplier).
Long: Bull score > bear score.
Short: Bear score >= bull score.
Long: Shorter close EMA > longer close EMA AND close > session VWAP of typical price.
Short: Shorter close EMA < longer close EMA AND close < session VWAP of typical price.
Long: RSI <= overbought threshold AND RSI > midpoint.
Short: RSI >= oversold threshold AND RSI <= midpoint.
Long: Shorter close EMA > longer close EMA.
Short: Shorter close EMA <= longer close EMA.
Long: Close > session VWAP of typical price.
Short: Close <= session VWAP of typical price.
Long: Last signal direction is long AND low <= shorter close EMA AND low > longer close EMA.
Short: Last signal direction is short AND high >= shorter close EMA AND high < longer close EMA.
Exit: long, high >= entry price + target distance.
Exit: short, low <= entry price - target distance.