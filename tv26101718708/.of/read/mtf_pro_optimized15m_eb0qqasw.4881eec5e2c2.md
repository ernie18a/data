Calculation: Strong candle = absolute(close − open) > max(high − low, minimum tick size) × body-fraction parameter
Calculation: Bullish setup = all higher-timeframe closes are above their respective EMAs, RSI is above its midpoint, strong candle, close > chart-timeframe EMA, and previous close ≤ previous chart-timeframe EMA
Calculation: Bearish setup = all higher-timeframe closes are below their respective EMAs, RSI is below its midpoint, strong candle, close < chart-timeframe EMA, and previous close ≥ previous chart-timeframe EMA
Calculation: Higher-timeframe EMA and close = EMA and close on the last completed higher-timeframe bar
Long: No open position AND a bullish setup has been recorded AND current high > the recorded setup candle's high
Short: No open position AND a bearish setup has been recorded AND current low < the recorded setup candle's low
Exit: Long, low ≤ stop OR high ≥ target; initial stop = low of the bar before the setup candle, moved to entry price when high ≥ entry price + initial risk; target = entry price + initial risk × reward-risk parameter
Exit: Short, high ≥ stop OR low ≤ target; initial stop = high of the bar before the setup candle, moved to entry price when low ≤ entry price − initial risk; target = entry price − initial risk × reward-risk parameter