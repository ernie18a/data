Calculation: Heiken Ashi close = (open + high + low + close) / 4
Calculation: Heiken Ashi open = (previous Heiken Ashi open + previous Heiken Ashi close) / 2
Calculation: Heiken Ashi high = max(high, Heiken Ashi open, Heiken Ashi close)
Calculation: Heiken Ashi low = min(low, Heiken Ashi open, Heiken Ashi close)
Long: chart-timeframe last completed close > Heiken Ashi high of the last completed higher-timeframe bar AND chart-timeframe last completed close < Heiken Ashi open of the last completed higher-timeframe bar AND Heiken Ashi close > Heiken Ashi open on that same higher-timeframe bar
Short: chart-timeframe last completed close < Heiken Ashi low of the last completed higher-timeframe bar AND chart-timeframe last completed close > Heiken Ashi open of the last completed higher-timeframe bar AND Heiken Ashi close < Heiken Ashi open on that same higher-timeframe bar
Exit: long, chart-timeframe last completed close < Heiken Ashi low of the last completed higher-timeframe bar
Exit: short, chart-timeframe last completed close > Heiken Ashi high of the last completed higher-timeframe bar