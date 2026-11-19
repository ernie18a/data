Calculation: Smoothed ATR = ATR(ATR lookback) + 0.5^(1 / shock half-life) × max(previous smoothed ATR − ATR(ATR lookback), 0), initialized to ATR(ATR lookback)
Calculation: Envelope edges = EMA(close, EMA lookback) ± min(smoothed ATR × band multiplier, abs(close) × price cap)
Calculation: Track direction = bullish after a confirmed close crossover above the upper envelope, bearish after a confirmed close crossunder below the lower envelope, and unchanged until the opposite confirmed crossing; neutral before either crossing
Long: Confirmed close crosses above the upper envelope
Short: Confirmed close crosses below the lower envelope
Long: Track direction on chart-timeframe bars is bullish
Short: Track direction on chart-timeframe bars is bearish
Long: Track direction on each enabled T1–T4 is bullish, calculated on that timeframe’s bars and read on chart bars from its last completed bar when higher than the chart timeframe, its latest completed intrabar when lower, or the confirmed chart bar when equal
Short: Track direction on each enabled T1–T4 is bearish, calculated on that timeframe’s bars and read on chart bars from its last completed bar when higher than the chart timeframe, its latest completed intrabar when lower, or the confirmed chart bar when equal
Long: Close on the still-forming chart bar > EMA(close, EMA lookback)
Short: Close on the still-forming chart bar < EMA(close, EMA lookback)