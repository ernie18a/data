Calculation: excess return = log(close / close[N]) − (drift adjustment enabled and drift SMA available ? N × SMA(log(close / close[1]), drift lookback) : 0)
Calculation: upper threshold = adaptive k × STDEV(log(close / close[1]), volatility lookback) × √N in adaptive mode; fixed upper threshold (%) / 100 in fixed mode
Calculation: lower threshold = adaptive k × STDEV(log(close / close[1]), volatility lookback) × √N in adaptive mode; fixed lower threshold (%) / 100 in fixed mode
Calculation: oscillator = clip(oscillator scale × excess return / (excess return ≥ 0 ? upper threshold : lower threshold), ±oscillator clip limit)
Calculation: oscillator velocity = oscillator − oscillator[velocity lookback]
Calculation: regime = Bull if excess return > upper threshold and (momentum filter disabled or oscillator velocity > 0); Bear if excess return < −lower threshold and (momentum filter disabled or oscillator velocity < 0); otherwise Sideways
Calculation: confirmed regime change = confirmed chart bar where the regime has persisted for the minimum hold and differs from the last regime recorded after that hold; the first recorded regime emits no change
Calculation: signal line = selected EMA, HMA, ALMA(oscillator, signal lookback, ALMA offset, ALMA sigma), or SMA of oscillator
Long: oscillator ≥ oscillator pending boundary
Short: oscillator ≤ −oscillator pending boundary
Long: confirmed regime change to Bull
Short: confirmed regime change to Bear
Exit: long, confirmed regime change to Sideways
Exit: short, confirmed regime change to Sideways
Long: signal line enabled and oscillator > signal line
Short: signal line enabled and oscillator < signal line
Long: signal line enabled and oscillator crosses above signal line on a confirmed chart bar and (HTF cross filter disabled or HTF confluence disabled or regime calculated on T1 bars equals chart-bar regime; T1 values are mapped to chart bars with lookahead off, using the last completed T1 bar historically and the still-forming T1 bar in real time)
Short: signal line enabled and oscillator crosses below signal line on a confirmed chart bar and (HTF cross filter disabled or HTF confluence disabled or regime calculated on T1 bars equals chart-bar regime; T1 values are mapped to chart bars with lookahead off, using the last completed T1 bar historically and the still-forming T1 bar in real time)