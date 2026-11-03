Calculation: HTF trend = current higher-timeframe close and EMA of higher-timeframe closes, both using the higher-timeframe bar still forming
Calculation: Bullish FVG zone = higher-timeframe low[1] > high[2]; bounds are high[2] to low[1], using the two preceding completed higher-timeframe bars
Calculation: Bearish FVG zone = higher-timeframe high[1] < low[2]; bounds are high[1] to low[2], using the two preceding completed higher-timeframe bars
Calculation: Bullish order-block zone = higher-timeframe open[1] > close[1] AND current higher-timeframe close > high[1]; bounds are low[1] to open[1]
Calculation: Bearish order-block zone = higher-timeframe open[1] < close[1] AND current higher-timeframe close < low[1]; bounds are open[1] to high[1]
Calculation: In zone = chart close lies within the latest FVG or order-block zone, expanded above and below by close times the zone-tolerance percentage; include each zone type only when its display switch is enabled
Calculation: Liquidity low sweep = chart low < the prior chart bar's lowest low over the structure lookback AND chart close > the current lowest low over that lookback
Calculation: Liquidity high sweep = chart high > the prior chart bar's highest high over the structure lookback AND chart close < the current highest high over that lookback
Calculation: Bullish CISD = chart high > the prior chart bar's highest high over the same structure lookback AND chart close > chart open
Calculation: Bearish CISD = chart low < the prior chart bar's lowest low over the same structure lookback AND chart close < chart open
Long: Liquidity low sweep AND Bullish CISD AND In zone AND current higher-timeframe close > its EMA
Short: Liquidity high sweep AND Bearish CISD AND In zone AND current higher-timeframe close < its EMA