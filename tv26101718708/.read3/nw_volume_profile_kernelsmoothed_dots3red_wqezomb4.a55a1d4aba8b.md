Calculation: Kernel-smoothed volume profile levels = on each chart bar, use the available bars in the lookback window; divide the window’s lowest low to highest high into a parameterized number of equal bins; distribute each bar’s volume equally across the bins touched by its high-to-low range, or its open-to-close body if enabled; Gaussian-smooth bin volumes using the bandwidth parameter; set POC to the midpoint of the bin with greatest smoothed volume, and set value-area high and low to the bounds of the region grown outward from POC toward the larger adjacent smoothed-volume bin until it contains the parameterized share of total smoothed volume
Long: close crosses above POC
Short: close crosses below POC
Long: close crosses above value-area high
Short: close crosses below value-area low