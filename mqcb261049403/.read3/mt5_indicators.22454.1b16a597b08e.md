Calculation: Histogram direction = rising if histogram > histogram[1]; falling if histogram < histogram[1]; otherwise histogram direction[1]
Calculation: Histogram zone = 0 if histogram > upper outer level; else 1 if histogram > upper inner level; else 4 if histogram < lower outer level; else 3 if histogram < lower inner level; else 2
Long: histogram[N] > 0 AND histogram[N+1] <= 0
Long: histogram direction[N] = rising AND histogram direction[N+1] != rising
Long: histogram zone[N+1] > 1 AND histogram zone[N] = 1
Long: histogram zone[N+1] > 0 AND histogram zone[N] = 0
Long: histogram zone[N+1] = 3 AND histogram zone[N] < 3
Long: histogram zone[N+1] = 4 AND histogram zone[N] < 4
Short: histogram[N] < 0 AND histogram[N+1] >= 0
Short: histogram direction[N] = falling AND histogram direction[N+1] != falling
Short: histogram zone[N+1] < 3 AND histogram zone[N] = 3
Short: histogram zone[N+1] < 4 AND histogram zone[N] = 4
Short: histogram zone[N+1] = 1 AND histogram zone[N] > 1
Short: histogram zone[N+1] = 0 AND histogram zone[N] > 0