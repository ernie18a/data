Calculation: Return(T) = (OHLC4 of the last completed T bar - OHLC4 of the preceding completed T bar) / OHLC4 of the preceding completed T bar, using T values on chart bars
Calculation: NetworkOutput(x) = tanh(W3 × tanh(W2 × tanh(W1 × (x repeated N0 times)))); W1, W2, W3, N0, and the hidden layer widths are parameters; input activations are identity and there are no biases
Long: NetworkOutput(Return(T1)) < -threshold AND NetworkOutput(Return(T2)) < -threshold, with T1 longer than T2
Short: NetworkOutput(Return(T1)) > threshold AND NetworkOutput(Return(T2)) > threshold, with T1 longer than T2
Exit: long, NetworkOutput(Return(T2)) >= threshold OR NetworkOutput(Return(T1)) >= threshold
Exit: short, NetworkOutput(Return(T2)) <= -threshold OR NetworkOutput(Return(T1)) <= threshold