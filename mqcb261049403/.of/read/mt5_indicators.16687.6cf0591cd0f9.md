Calculation: Selected price = a selectable raw OHLC price, median (high+low)/2, typical (high+low+close)/3, weighted (high+low+2*close)/4, average (open+high+low+close)/4, body midpoint (open+close)/2, trend-biased price (high+close)/2 when close>open and (low+close)/2 otherwise, or trend-biased extreme high when close>open, low when close<open and close otherwise. The same choices may use Heikin-Ashi OHLC: close=(open+high+low+close)/4; open=(previous Heikin-Ashi open+previous Heikin-Ashi close)/2, initialized to (open+close)/2; high=max(high, Heikin-Ashi open, Heikin-Ashi close); low=min(low, Heikin-Ashi open, Heikin-Ashi close).
Calculation: Passband = (a1-a2)*price + (a2*(1-a1)-a1*(1-a2))*previous price + ((1-a1)+(1-a2))*previous passband - (1-a1)*(1-a2)*passband two bars ago, where a1=5/first period and a2=5/second period; initialize the first two passband values to their selected prices. Calculate on the chart timeframe or on the still-forming bar of a higher timeframe.
Calculation: RMS envelope = square root of the sum of squared passband values over the lookback divided by the lookback length; use available values when fewer than the lookback are present. Calculate on the passband timeframe.
Long: Passband crosses above the negative RMS envelope.
Short: Passband crosses below the positive RMS envelope.
Long: In outer-level mode, passband > positive RMS envelope.
Short: In outer-level mode, passband < negative RMS envelope.
Long: In middle-level mode, passband > 0.
Short: In middle-level mode, passband < 0.
Long: In slope mode, passband > previous passband.
Short: In slope mode, passband < previous passband.