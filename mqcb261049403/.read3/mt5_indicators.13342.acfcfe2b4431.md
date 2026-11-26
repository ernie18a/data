Calculation: Chart weighted momentum = chart factor 1 * Momentum(close, chart momentum lookback 1) + chart factor 2 * Momentum(close, chart momentum lookback 2) + chart factor 2 * Momentum(close, chart momentum lookback 3) + chart factor 4 * Momentum(close, chart momentum lookback 4) + chart factor 5 * Momentum(close, chart momentum lookback 5)
Calculation: Chart oscillator = SMMA(chart weighted momentum - SMMA(chart weighted momentum, chart smoothing 1), chart smoothing 2)
Calculation: MTF weighted momentum = MTF factor 1 * Momentum(close, MTF momentum lookback 1) + MTF factor 2 * Momentum(close, MTF momentum lookback 2) + MTF factor 2 * Momentum(close, MTF momentum lookback 3) + MTF factor 4 * Momentum(close, MTF momentum lookback 4) + MTF factor 5 * Momentum(close, MTF momentum lookback 5)
Calculation: MTF oscillator = SMMA(MTF weighted momentum - SMMA(MTF weighted momentum, MTF smoothing 1), MTF smoothing 2)
Long: Chart oscillator on the current forming chart bar > Chart oscillator on the preceding chart bar
Short: Chart oscillator on the current forming chart bar < Chart oscillator on the preceding chart bar
Long: MTF oscillator on T1 bars, last completed bar > MTF oscillator on T1 bars, preceding completed bar
Short: MTF oscillator on T1 bars, last completed bar < MTF oscillator on T1 bars, preceding completed bar
Long: MTF oscillator on T2 bars, last completed bar > MTF oscillator on T2 bars, preceding completed bar
Short: MTF oscillator on T2 bars, last completed bar < MTF oscillator on T2 bars, preceding completed bar
Long: MTF oscillator on T3 bars, last completed bar > MTF oscillator on T3 bars, preceding completed bar
Short: MTF oscillator on T3 bars, last completed bar < MTF oscillator on T3 bars, preceding completed bar
Long: MTF oscillator on T4 bars, last completed bar > MTF oscillator on T4 bars, preceding completed bar
Short: MTF oscillator on T4 bars, last completed bar < MTF oscillator on T4 bars, preceding completed bar
Long: MTF oscillator on T5 bars, last completed bar > MTF oscillator on T5 bars, preceding completed bar
Short: MTF oscillator on T5 bars, last completed bar < MTF oscillator on T5 bars, preceding completed bar
Long: MTF oscillator on T6 bars, last completed bar > MTF oscillator on T6 bars, preceding completed bar
Short: MTF oscillator on T6 bars, last completed bar < MTF oscillator on T6 bars, preceding completed bar
Long: MTF oscillator on T7 bars, last completed bar > MTF oscillator on T7 bars, preceding completed bar
Short: MTF oscillator on T7 bars, last completed bar < MTF oscillator on T7 bars, preceding completed bar
Long: MTF oscillator on T8 bars, last completed bar > MTF oscillator on T8 bars, preceding completed bar
Short: MTF oscillator on T8 bars, last completed bar < MTF oscillator on T8 bars, preceding completed bar
Long: MTF oscillator on T9 bars, last completed bar > MTF oscillator on T9 bars, preceding completed bar
Short: MTF oscillator on T9 bars, last completed bar < MTF oscillator on T9 bars, preceding completed bar
Long: MTF oscillator on T10 bars, last completed bar > MTF oscillator on T10 bars, preceding completed bar
Short: MTF oscillator on T10 bars, last completed bar < MTF oscillator on T10 bars, preceding completed bar