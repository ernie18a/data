Calculation: Tick imbalance = on chart bars, classify each available T1 intrabar close against the previous T1 intrabar close (rising is an uptick, falling is a downtick, unchanged carries the prior direction); retain the prior close and direction across chart bars, and leave ticks unassigned until a direction exists. Using available T1 intrabars, including the one still forming in real time, blend the signed tick-count imbalance and signed volume imbalance with separate count and volume blend weights; return zero for a zero denominator. If there are no T1 ticks, use (close − open) / max(high − low, minimum price increment) for both imbalances. Apply tanh(Z-score(blend, tick Z-score lookback)) when tick normalization is enabled, otherwise use the blend.
Calculation: Spread range Z-score = Z-score(EMA((high − low) / close, spread EMA lookback), spread Z-score lookback), calculated on chart bars.
Calculation: Micro momentum = tanh(Z-score(EMA(close, shorter EMA lookback) − EMA(close, longer EMA lookback), momentum Z-score lookback)), calculated on chart bars.
Calculation: Edge = clamp(decay coefficient × prior chart-bar Edge (initially zero) + tick weight × clamp(Tick imbalance, component clamp bounds) + spread weight × sign(clamp(Micro momentum, component clamp bounds)) × abs(clamp(−Spread range Z-score / spread scaling divisor, component clamp bounds)) + momentum weight × clamp(Micro momentum, component clamp bounds), edge-state clamp bounds), calculated on chart bars; optionally divide each of the separate tick, spread, and momentum weights by their sum according to the weight-normalization setting.
Long: Edge crosses above the edge threshold AND bars since the last long signal are at least the cooldown when asymmetric opposite lockout is enabled, otherwise bars since any signal are at least the cooldown.
Short: Edge crosses below the negative edge threshold AND bars since the last short signal are at least the cooldown when asymmetric opposite lockout is enabled, otherwise bars since any signal are at least the cooldown.
Long: Edge is at least the edge threshold AND its sign has remained positive for at least the sustained-bar count consecutive chart bars AND this condition was false on the prior chart bar.
Short: Edge is at most the negative edge threshold AND its sign has remained negative for at least the sustained-bar count consecutive chart bars AND this condition was false on the prior chart bar.
Long: Tick imbalance is at least zero.
Short: Tick imbalance is below zero.
Long: Spread range Z-score is at most zero.
Short: Spread range Z-score is above zero.
Long: Micro momentum is at least zero.
Short: Micro momentum is below zero.
Long: Edge is at least zero.
Short: Edge is below zero.