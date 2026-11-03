Calculation: Neural network prediction = sigmoid output of a feedforward network using the current signal-timeframe bar’s open, high, low, close, and volume as inputs; hidden units use ReLU. The network is trained to predict whether the next bar’s close is above the current bar’s close.
Long: Neural network prediction > 0.6
Short: Neural network prediction < 0.4
Exit: long, low <= entry price - ATR
Exit: long, high >= entry price + 2 × ATR
Exit: short, high >= entry price + ATR
Exit: short, low <= entry price - 2 × ATR