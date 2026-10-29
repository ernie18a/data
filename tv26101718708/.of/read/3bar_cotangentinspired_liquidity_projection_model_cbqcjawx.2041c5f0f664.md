Calculation: Projected cloud = close ± (projection force), plotted projection length bars after the bar used to calculate it
Calculation: Projection force = EMA(sin(G) + cotangent, smoothing) × ATR × strength
Calculation: G = (abs(close − prior close) × volume × (high − low)) / max(abs(close − order-block anchor), minimum tick)²
Calculation: Order-block anchor = low on a bar whose low is the lowest low over the lookback and whose close > open; high on a bar whose high is the highest high over the lookback and whose close < open; otherwise the previous anchor, initially close
Calculation: Cotangent = 1 / tan(arctan(close − prior close)) when abs(tan(arctan(close − prior close))) > 0.0001; otherwise 0
Long: close > both projected cloud boundaries
Short: close < both projected cloud boundaries