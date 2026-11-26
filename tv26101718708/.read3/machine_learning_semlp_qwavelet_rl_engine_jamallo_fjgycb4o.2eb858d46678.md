Calculation: features = wavelet features of the chart bars' data fields plus agent-state values
Calculation: score(a) = output unit a of a feed-forward network applied to features, with a first hidden layer of hidden-width-1 units and a second hidden layer of hidden-width-2 units, LeakyReLU with negative-slope parameter on both hidden layers, linear output layer, learned weights and biases; a is buy, sell, or hold
Calculation: chosen action = current action if max(score(buy), score(sell), score(hold)) <= score(current action) + inertia, otherwise the action with the highest score, ties resolved in the order buy, sell, hold; current action = buy if long, sell if short, hold if flat
Long: chosen action = buy
Short: chosen action = sell
Exit: long, chosen action = hold
Exit: short, chosen action = hold