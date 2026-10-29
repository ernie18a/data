Calculation: Volume-weighted oscillator = Jurik moving average with maximum phase of volume × (100 × (close − (longer-lookback SMA of close − shorter-lookback Jurik moving average of high − low)) / (2 × denominator) − 50), where denominator is the shorter-lookback average of high − low, or 1 if that average is zero. For the trading system, calculate on the last completed higher-timeframe bar; for indicator markings, calculate on the chart bar.
Calculation: Oscillator direction = up if the oscillator is greater than its previous-bar value, down if it is less, and otherwise the previous direction.
Long: Chart-timeframe oscillator direction = up
Long: Last completed higher-timeframe oscillator direction = up AND previous higher-timeframe oscillator direction = down
Short: Chart-timeframe oscillator direction = down
Short: Last completed higher-timeframe oscillator direction = down AND previous higher-timeframe oscillator direction = up
Exit: long, last completed higher-timeframe oscillator direction = down OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, last completed higher-timeframe oscillator direction = up OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance