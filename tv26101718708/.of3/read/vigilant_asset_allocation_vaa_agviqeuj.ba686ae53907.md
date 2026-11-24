Calculation: momentum = w1*(close/close[k1]-1) + w2*(close/close[k2]-1) + w3*(close/close[k3]-1) + w4*(close/close[k4]-1), where k1<k2<k3<k4 and w1>w2>w3>w4; compute on T1 bars when the current and lagged closes are present and positive, and carry the current T1 value to chart bars
Long: momentum > 0
Short: momentum <= 0
Long: momentum > momentum[trend lookback] on chart bars
Short: momentum < momentum[trend lookback] on chart bars
Long: At a rebalance, the number of offensive assets with momentum <= 0 is < B; select the offensive asset with the highest momentum, using the first-listed asset for ties
Short: At a rebalance, the number of offensive assets with momentum <= 0 is >= B; select the defensive asset with the highest momentum, using the first-listed asset for ties
Long: The number of offensive assets with momentum > 0 is a strict majority
Short: The number of offensive assets with momentum > 0 is a strict minority
At interval-end rebalances, use the previous completed chart bar's T1 values; at each-chart-bar rebalances, use the current chart bar's T1 values