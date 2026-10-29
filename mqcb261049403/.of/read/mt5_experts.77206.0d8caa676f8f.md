Calculation: price velocity = change in tick midpoint since the previous tick, multiplied by the price scale
Calculation: curvature = 0.5 × price velocity
Calculation: entropy = tick spread × tick volume
Calculation: Causal Price Dynamics (CPD) = 0.95 × previous smoothed CPD + 0.05 × min(abs(price velocity / (entropy + 0.0001)), 10)
Calculation: Hamiltonian = price velocity² + 0.5 × entropy
Calculation: neural confidence = sigmoid output of an online-trained 5-input, 12-hidden-node tanh network; inputs are atan(price velocity), atan(curvature), atan(entropy), CPD / 10, and atan(Hamiltonian)
Long: CPD ≥ 0.60 AND price velocity > 0 AND neural confidence > veto threshold
Short: CPD ≥ 0.60 AND price velocity ≤ 0 AND neural confidence < 1 − veto threshold
Exit: long, unrealized profit < 0 AND neural confidence < cut-loss threshold
Exit: short, unrealized profit < 0 AND neural confidence > 1 − cut-loss threshold
Exit: long or short, unrealized profit in points ≥ risk-reward ratio × stop-loss distance in points