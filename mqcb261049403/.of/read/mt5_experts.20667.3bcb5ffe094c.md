Calculation: Composite = moving average of (stochastic oscillator signal line × RSI / momentum); use 100 as the input to the moving average when momentum is zero. Momentum is 100 × selected price / selected price at the momentum lookback. Calculate on the chart timeframe or a configurable higher or lower timeframe; for another timeframe use the last completed bar, or the still-forming bar if the signal-bar setting selects it. Previous values refer to preceding bars of that same timeframe.
Long: Composite > previous Composite
Short: Composite < previous Composite
Long: Composite > previous Composite AND previous Composite <= Composite two bars ago
Short: Composite < previous Composite AND previous Composite >= Composite two bars ago
Exit: long, Composite < previous Composite OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, Composite > previous Composite OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance