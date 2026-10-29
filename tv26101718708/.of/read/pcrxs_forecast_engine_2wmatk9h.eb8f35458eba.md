Calculation: WMA oscillator = 100 × (shorter-lookback WMA of close − longer-lookback WMA of close) / ATR
Calculation: Oscillator threshold = rolling standard deviation of the WMA oscillator
Calculation: BTC dominance bias = BTC dominance > its EMA for BTC charts; BTC dominance < its EMA for other charts
Calculation: USDT dominance bias = USDT dominance < its EMA; bearish = USDT dominance > its EMA
Calculation: Dry powder = USDT dominance > 0.85 × its rolling highest value AND USDT dominance < its value 3 bars ago
Calculation: CME futures basis = 100 × (CME futures close − chart close) / chart close
Calculation: Over-leveraged long = CME futures basis > 0.8%
Calculation: Halving cycle value = cos(2π × max(datetime − 2024-04-20, 0) / four-year cycle duration − π/4)
Calculation: H4 bullish structure = last completed higher-timeframe bar close > its EMA(50) AND EMA(50) > EMA(200); bearish structure = close < EMA(50) AND EMA(50) < EMA(200)
Long: WMA oscillator crosses above −1 × its rolling standard deviation AND H4 bullish structure AND RSI < its overbought threshold AND MACD histogram >= its prior value AND CMF > −0.05 AND volume > 0.8 × its 20-bar average AND halving cycle value > −0.70 AND USDT dominance <= its EMA AND BTC dominance bias is bullish AND NOT over-leveraged long
Short: WMA oscillator crosses below its rolling standard deviation AND H4 bearish structure AND RSI > its oversold threshold AND MACD histogram <= its prior value AND CMF < 0.05 AND volume > 0.8 × its 20-bar average AND halving cycle value < 0.70 AND USDT dominance >= its EMA AND BTC dominance bias is bearish AND NOT dry powder
Exit: Long, WMA oscillator crosses below zero OR (RSI > its overbought threshold AND RSI crosses below its overbought threshold AND H4 bearish structure) OR short-entry condition
Exit: Short, WMA oscillator crosses above zero OR (RSI < its oversold threshold AND RSI crosses above its oversold threshold AND H4 bullish structure) OR long-entry condition