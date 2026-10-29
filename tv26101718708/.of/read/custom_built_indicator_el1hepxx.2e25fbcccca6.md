Calculation: Baseline = RMA of the configured source
Calculation: Upper band = baseline + Average True Range × upper multiplier
Calculation: Lower band = baseline − Average True Range × lower multiplier
Calculation: Trend state = initialize at 0; set to 1 when the configured long condition is true and the configured short condition is false; then set to −1 when the configured short condition is true
Long: trend state > previous bar’s trend state
Short: trend state < previous bar’s trend state