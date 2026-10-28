Calculation: Prior swing high/low = highest high / lowest low over the lookback bars before the current bar
Calculation: Volume spike = current volume > its simple moving average over the lookback bars × a multiplier
Calculation: High sweep = current high > prior swing high minus a tolerance percentage of that swing high AND current close < prior swing high AND current low < current open
Calculation: Low sweep = current low < prior swing low plus a tolerance percentage of that swing low AND current close > prior swing low AND current high > current open
Calculation: Bullish FVG = current low > high two bars earlier AND the gap is at least a minimum size
Calculation: Bearish FVG = low two bars earlier > current high AND the gap is at least a minimum size
Calculation: Bullish rejection wick = (min(current close, current open) − current low) / (current high − current low) ≥ a minimum ratio AND current close > current open
Calculation: Bearish rejection wick = (current high − max(current close, current open)) / (current high − current low) ≥ a minimum ratio AND current close < current open
Calculation: Higher-timeframe bullish bias = current still-forming higher-timeframe close > its shorter-lookback EMA > its longer-lookback EMA
Calculation: Higher-timeframe bearish bias = current still-forming higher-timeframe close < its shorter-lookback EMA < its longer-lookback EMA
Long: Low sweep AND volume spike
Long: Bullish FVG
Long: Bullish rejection wick
Long: Volume spike AND current close > current open
Long: Higher-timeframe bullish bias AND low sweep on the previous bar AND bullish FVG AND bullish rejection wick AND volume spike
Short: High sweep AND volume spike
Short: Bearish FVG
Short: Bearish rejection wick
Short: Volume spike AND current close < current open
Short: Higher-timeframe bearish bias AND high sweep on the previous bar AND bearish FVG AND bearish rejection wick AND volume spike