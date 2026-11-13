Calculation: P = selected price per bar (default close)
Calculation: X, Y = X is bar timestamp, Y = P (variant: X = P, Y = ln(|P^2-1|+0.5))
Calculation: L = rolling sum over p bars of (rolling sum over p bars of Y*(1-ln2-Y)); p = short lookback window
Calculation: Q = sigmoid(w*sum(X,p)), w = -k*sum(X*(0.5-Y),p)/p, k a positive constant, sums over the last p bars
Calculation: norm(v) = min(P,n) + (max(P,n)-min(P,n))*(v-min(v,n))/(max(v,n)-min(v,n)), all min/max over the last n bars
Calculation: SL = norm(L); SP = norm(Q)
Calculation: F = always true by default; optional variants: ATR with short lookback > ATR with long lookback, and/or HMA-smoothed RSI of volume > threshold
Long: (P > SL OR SL crosses above SP; two selectable variants, use one) AND F AND current state is not long (state persists and flips only on the opposite condition; when neither condition holds, the previous state is kept)
Short: (P < SL OR SL crosses below SP; same variant as Long) AND F AND current state is not short
Exit: long, bars since entry bar == holding period OR Short condition is true
Exit: short, bars since entry bar == holding period OR Long condition is true