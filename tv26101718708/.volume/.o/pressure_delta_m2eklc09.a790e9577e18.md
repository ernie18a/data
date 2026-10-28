Calculation: Pressure = 100 × clamp(0, 1, 0.6 × (close − low) / safeRange + 0.4 × ((lowerWick − upperWick) / safeRange + 1) / 2), where safeRange = high − low, except use 0.0001 when high = low; upperWick = high − max(open, close); lowerWick = min(open, close) − low
Calculation: Relative Volume Delta = (buyPressure − sellPressure) × volume / average volume over a parameterized lookback, where buyPressure = Pressure / 100 and sellPressure = 1 − buyPressure
Calculation: Relative Volume Percentage = Relative Volume Delta / (volume / average volume over the same lookback) × 100
Long: Pressure ≥ 80
Long: Pressure ≥ 60
Long: Pressure ≥ 70
Long: Pressure ≥ 50
Long: Pressure ≥ 20
Long: Pressure ≥ 0
Long: Relative Volume Delta ≥ 7
Long: Relative Volume Delta ≥ 6
Long: Relative Volume Delta ≥ 5
Long: Relative Volume Percentage ≥ 50
Long: Relative Volume Percentage ≥ 40
Long: Pressure > 60
Long: Relative Volume Delta > 0
Long: Relative Volume Percentage > 50
Long: Relative Volume Delta / average of the absolute Relative Volume Delta over a parameterized 5-bar lookback > 2
Short: Pressure < 80
Short: Pressure < 60
Short: Pressure < 70
Short: Pressure < 50
Short: Pressure < 20
Short: Pressure < 0
Short: Relative Volume Delta < 7
Short: Relative Volume Delta < 6
Short: Relative Volume Delta < 5
Short: Relative Volume Percentage < 50
Short: Relative Volume Percentage < 40
Short: Pressure < 40
Short: Relative Volume Delta < 0
Short: Relative Volume Percentage < 0
Short: Relative Volume Delta / average of the absolute Relative Volume Delta over a parameterized 5-bar lookback < 0