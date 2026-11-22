Calculation: Volume spike = volume > SMA(volume, volume MA period) * herd threshold
Calculation: Institutional volume = volume > SMA(volume, volume MA period) * institutional volume multiplier
Calculation: Smart money = (close - open) / (high - low) * volume
Calculation: Smart money positive = Smart money > SMA(Smart money, smart money MA period)
Calculation: Herd buying = RSI(close, RSI period) > RSI overbought level AND Volume spike AND Momentum(close, momentum lookback) > SMA(Momentum(close, momentum lookback), momentum MA period)
Calculation: Herd selling = RSI(close, RSI period) < RSI oversold level AND Volume spike AND Momentum(close, momentum lookback) < SMA(Momentum(close, momentum lookback), momentum MA period)
Calculation: Liquidity trap up = high > Highest(high, liquidity lookback)[1] AND close < Highest(high, liquidity lookback)[1] AND Volume spike
Calculation: Liquidity trap down = low < Lowest(low, liquidity lookback)[1] AND close > Lowest(low, liquidity lookback)[1] AND Volume spike
Calculation: Accumulation = A/D line(close, low, high, volume) > SMA(A/D line(close, low, high, volume), institutional MA period) AND Institutional volume
Calculation: Distribution = A/D line(close, low, high, volume) < SMA(A/D line(close, low, high, volume), institutional MA period) AND Institutional volume
Long: Herd selling AND (Accumulation OR Liquidity trap down)
Long: close < Bollinger lower band(close, Nash period, Nash deviation) AND Smart money positive AND NOT Herd buying
Long: close < Bollinger lower band(close, Nash period, Nash deviation) AND close > close[1] AND volume > SMA(volume, volume MA period)
Long: Herd selling
Long: Liquidity trap down
Short: Herd buying AND (Distribution OR Liquidity trap up)
Short: close > Bollinger upper band(close, Nash period, Nash deviation) AND NOT Smart money positive AND NOT Herd selling
Short: close > Bollinger upper band(close, Nash period, Nash deviation) AND close < close[1] AND volume > SMA(volume, volume MA period)
Short: Herd buying
Short: Liquidity trap up
Exit: long, low <= entry price * (1 - stop-loss percent / 100)
Exit: long, high >= entry price * (1 + take-profit percent / 100)
Exit: short, high >= entry price * (1 + stop-loss percent / 100)
Exit: short, low <= entry price * (1 - take-profit percent / 100)