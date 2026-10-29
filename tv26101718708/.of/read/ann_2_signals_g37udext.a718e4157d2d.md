Calculation: OHLC4 = (open + high + low + close) / 4
Calculation: Higher-timeframe return = (OHLC4 of the last completed higher-timeframe bar − OHLC4 of the preceding completed higher-timeframe bar) / OHLC4 of the preceding completed higher-timeframe bar
Calculation: Lower-timeframe return = (OHLC4 of the last completed lower-timeframe bar − OHLC4 of the preceding completed lower-timeframe bar) / OHLC4 of the preceding completed lower-timeframe bar
Calculation: ANN prediction = tanh feed-forward neural network with one scalar input replicated across 15 input nodes, followed by 30 tanh nodes, 9 tanh nodes, and one tanh output; weights are parameters
Long: ANN prediction of the higher-timeframe return < −threshold AND ANN prediction of the lower-timeframe return < −threshold
Short: ANN prediction of the higher-timeframe return > threshold AND ANN prediction of the lower-timeframe return > threshold
Exit: Long, ANN prediction of the lower-timeframe return ≥ threshold OR ANN prediction of the higher-timeframe return ≥ threshold
Exit: Short, ANN prediction of the lower-timeframe return ≤ −threshold OR ANN prediction of the higher-timeframe return ≤ threshold