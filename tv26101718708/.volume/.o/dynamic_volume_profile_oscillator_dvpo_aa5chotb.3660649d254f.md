Calculation: DVPO = EMA of the selected mode’s value: mean-reversion mode is 50 + 25 × (close − rolling volume-weighted mean of close) ÷ (volume-weighted mean absolute deviation of close × sensitivity); volume-intensity mode is smoothed volume’s position, scaled 0–100, within its rolling low–high range
Calculation: Adaptive zones = the SMA of DVPO (or fixed 50) plus or minus DVPO’s standard deviation over the same period, multiplied by zone width
Calculation: Fast and slow signals = shorter- and longer-period EMAs of DVPO
Long: DVPO > midline OR fast signal > slow signal
Short: DVPO <= midline AND fast signal <= slow signal
Long: DVPO crosses above upper zone
Short: DVPO crosses below lower zone
Long: fast signal crosses above slow signal
Short: fast signal crosses below slow signal