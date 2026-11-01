Calculation: Selected price P = a configurable choice of open, high, low, close, (high+low)/2, (high+low+close)/3, (high+low+2*close)/4, (open+close)/2, (open+high+low+close)/4, high if close>open else low if close<open else close, (high+close)/2 if close>open else (low+close)/2 if close<open else close, or (high+low+close+X)/2-(high+low)/2 where X is low if close<open, high if close>open, and close otherwise.
Calculation: Bézier value B[t] = sum from i=0 to N of P[t-i] * binomial(N,i) * s^i * (1-s)^(N-i), with sensitivity s constrained to the interval from zero to one. For indicator markings use chart bars; for expert decisions use a configurable chart, higher, or lower timeframe and a configurable signal-bar offset, including either the last completed bar or the bar still forming. Index t denotes the selected signal bar.
Calculation: Change D[t] = B[t]-B[t-1]. Threshold F[t] = a configurable multiplier times the population standard deviation of D over a configurable lookback ending at t. Round D[t] and F[t] separately to the configured price precision plus two decimal places.
Long: B[t]>B[t-1]
Short: B[t]<B[t-1]
Long: D[t]>F[t] AND B[t]!=0
Short: D[t]<-F[t] AND B[t]!=0
Long: B[t-2]>B[t-1] AND B[t-1]<B[t]
Short: B[t-2]<B[t-1] AND B[t-1]>B[t]
Exit: long, B[t]<B[t-1] OR (D[t]>F[t] AND B[t]!=0)
Exit: short, B[t]>B[t-1] OR (D[t]<-F[t] AND B[t]!=0)
Exit: long, low<=entry price minus configured stop distance OR high>=entry price plus configured profit distance
Exit: short, high>=entry price plus configured stop distance OR low<=entry price minus configured profit distance