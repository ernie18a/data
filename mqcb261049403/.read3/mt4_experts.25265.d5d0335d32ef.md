Calculation: High-pivot age = greatest bar index within the scan lookback where ZigZag(high, depth, deviation, backstep) equals the latest ZigZag high pivot price; 0 if none
Calculation: Low-pivot age = greatest bar index within the scan lookback where ZigZag(low, depth, deviation, backstep) equals the latest ZigZag low pivot price; 0 if none
Long: High-pivot age >= Low-pivot age AND no open position from this strategy
Short: High-pivot age < Low-pivot age AND no open position from this strategy