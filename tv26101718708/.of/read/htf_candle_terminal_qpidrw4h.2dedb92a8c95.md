Calculation: Current higher-timeframe open = open of the higher-timeframe bar still forming
Calculation: Previous higher-timeframe high/low = high/low of the last completed higher-timeframe bar
Calculation: Bullish/bearish volume POC = price bin with the greatest cumulative volume in the current higher-timeframe period, for chart bars whose HLC3 is respectively at/above or below the current higher-timeframe open; bin size is parameterized
Calculation: Higher-timeframe anchored VWAP = cumulative chart-bar HLC3 × volume since the current higher-timeframe bar began, divided by cumulative volume since it began
Long: chart close > current higher-timeframe open
Long: chart close > higher-timeframe anchored VWAP
Long: chart low <= bearish volume POC AND chart close > bullish volume POC
Long: chart low < previous higher-timeframe low AND previous chart-bar low >= previous higher-timeframe low
Long: current higher-timeframe low >= current higher-timeframe open
Long: chart close > current higher-timeframe open AND chart close > bullish volume POC
Short: chart close < current higher-timeframe open
Short: chart close < higher-timeframe anchored VWAP
Short: chart high >= bullish volume POC AND chart close < bearish volume POC
Short: chart high > previous higher-timeframe high AND previous chart-bar high <= previous higher-timeframe high
Short: current higher-timeframe high <= current higher-timeframe open
Short: chart close < current higher-timeframe open AND chart close < bearish volume POC