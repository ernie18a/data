Calculation: Volume-weighted DeMarker = smooth((100 × DeMarker(high, low) − 50) × volume), using a selected smoothing method and lookback.
Calculation: Smoothed volume = smooth(volume), using the same smoothing method and lookback as volume-weighted DeMarker.
Long: Volume-weighted DeMarker > upper threshold × smoothed volume.
Short: Volume-weighted DeMarker < lower threshold × smoothed volume.
Long: On a higher timeframe, volume-weighted DeMarker > upper threshold × smoothed volume, using the bar still forming at the first chart bar of that higher-timeframe bar and holding that result until the next higher-timeframe bar.
Short: On a higher timeframe, volume-weighted DeMarker < lower threshold × smoothed volume, using the bar still forming at the first chart bar of that higher-timeframe bar and holding that result until the next higher-timeframe bar.