Calculation: MA1, MA2, MA3 = McGinley Dynamic of close, computed on aggregated higher-timeframe bars (mg = previous mg + (close - previous mg) / (N * (close / previous mg)^4), seeded with EMA of close); each uses the higher-timeframe bar still forming at the current chart bar, and its value is held across the chart bars inside that higher-timeframe bar. MA1 timeframe is higher than the chart timeframe, MA2 timeframe is higher than MA1 timeframe, MA3 timeframe is higher than MA2 timeframe; MA3 lookback N is longer than MA1 and MA2 lookback
Calculation: MA3s = simple moving average of MA3 (sampled once per chart bar) over a number of chart bars equal to MA3 timeframe length divided by chart timeframe length
Long: MA1 crosses above MA2 AND MA3s > MA3s one chart bar earlier
Short: MA1 crosses below MA2 AND MA3s < MA3s one chart bar earlier
Exit: long, MA1 crosses below MA2
Exit: short, MA1 crosses above MA2