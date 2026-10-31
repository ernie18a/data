Calculation: Volume-weighted RSI histogram = apply the selected smoothing method to (RSI of the selected price − 50) × volume; apply the same method and parameters separately to volume.
Calculation: Direction state = up when the histogram is greater than its previous value, down when it is less, and otherwise the previous direction state.
Long: Direction state = up
Long: Volume-weighted RSI histogram > higher upper threshold × smoothed volume OR volume-weighted RSI histogram > lower upper threshold × smoothed volume
Short: Direction state = down
Short: Volume-weighted RSI histogram ≤ higher upper threshold × smoothed volume AND volume-weighted RSI histogram ≤ lower upper threshold × smoothed volume AND (volume-weighted RSI histogram < lower lower threshold × smoothed volume OR volume-weighted RSI histogram < higher lower threshold × smoothed volume)