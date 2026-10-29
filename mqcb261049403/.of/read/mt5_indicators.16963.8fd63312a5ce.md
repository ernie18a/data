Calculation: Inverse Fisher RSI = tanh(smoothed(0.1 × (RSI − 50)))
Calculation: Floating upper, middle, and lower levels = rolling minimum plus the configured upper percentage, 50%, or lower percentage of the rolling Inverse Fisher RSI range; fixed levels use 2 × configured percentage − 1
Long: Inverse Fisher RSI > upper level in level mode, OR > middle level in middle mode, OR > its previous value in slope mode
Short: Inverse Fisher RSI < lower level in level mode, OR < middle level in middle mode, OR < its previous value in slope mode