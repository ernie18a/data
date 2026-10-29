Calculation: prior swing high = highest high over the lookback bars before the current bar
Calculation: prior swing low = lowest low over the lookback bars before the current bar
Calculation: volume spike = current volume > its moving average × the volume multiplier
Calculation: bullish sweep = current low < prior swing low × (1 + sweep tolerance) AND current close > prior swing low AND current high > current open AND volume spike
Calculation: bearish sweep = current high > prior swing high × (1 − sweep tolerance) AND current close < prior swing high AND current low < current open AND volume spike
Calculation: bullish FVG = current low > high two bars ago AND current low − high two bars ago ≥ minimum gap size
Calculation: bearish FVG = low two bars ago > current high AND low two bars ago − current high ≥ minimum gap size
Calculation: bullish rejection wick = (min(current open, current close) − current low) / (current high − current low) ≥ wick ratio AND current close > current open
Calculation: bearish rejection wick = (current high − max(current open, current close)) / (current high − current low) ≥ wick ratio AND current close < current open
Calculation: bullish higher-timeframe bias = higher-timeframe close > its shorter-lookback EMA AND that EMA > its longer-lookback EMA; use the last completed higher-timeframe bar
Calculation: bearish higher-timeframe bias = higher-timeframe close < its shorter-lookback EMA AND that EMA < its longer-lookback EMA; use the last completed higher-timeframe bar
Long: bullish sweep OR (bullish higher-timeframe bias AND bullish sweep on the previous bar AND bullish FVG AND bullish rejection wick AND volume spike)
Short: bearish sweep OR (bearish higher-timeframe bias AND bearish sweep on the previous bar AND bearish FVG AND bearish rejection wick AND volume spike)