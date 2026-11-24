Calculation: HannFIR(source, lookback) = Σ[i=0..lookback−1](source[i] × (1 − cos(2π(i+1)/(lookback+1)))) / Σ[i=0..lookback−1](1 − cos(2π(i+1)/(lookback+1)))
Long: HannFIR(close, ribbon base length) > HannFIR(close, ribbon base length + ribbon spacing) AND HannFIR(close, ribbon base length + ribbon spacing) > HannFIR(close, ribbon base length + 2 × ribbon spacing)
Short: HannFIR(close, ribbon base length) < HannFIR(close, ribbon base length + ribbon spacing) AND HannFIR(close, ribbon base length + ribbon spacing) < HannFIR(close, ribbon base length + 2 × ribbon spacing)
Long: HannFIR(close, ribbon base length) crosses above HannFIR(close, ribbon base length + ribbon spacing)
Short: HannFIR(close, ribbon base length) crosses below HannFIR(close, ribbon base length + ribbon spacing)
Long: low < lowest(low, sweep lookback)[1] − ATR(ATR lookback) × pool tolerance × sweep threshold AND close > lowest(low, sweep lookback)[1]
Short: high > highest(high, sweep lookback)[1] + ATR(ATR lookback) × pool tolerance × sweep threshold AND close < highest(high, sweep lookback)[1]