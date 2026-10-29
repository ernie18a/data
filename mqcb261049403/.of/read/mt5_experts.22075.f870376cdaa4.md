Calculation: Volume-weighted DeMarker histogram = smooth (100 × DeMarker − 50) × volume and smooth volume separately with the same method and length; the inner and outer upper and lower levels are their respective threshold parameters multiplied by smoothed volume. The outer upper threshold is above the inner upper threshold; the outer lower threshold is below the inner lower threshold.
Long: Histogram > inner upper level
Short: Histogram < inner lower level
Long: On the last completed higher-timeframe bar, histogram > inner upper level AND histogram ≤ outer upper level AND on the preceding higher-timeframe bar histogram ≤ inner upper level
Long: On the last completed higher-timeframe bar, histogram > outer upper level AND on the preceding higher-timeframe bar histogram ≤ outer upper level
Short: On the last completed higher-timeframe bar, histogram < inner lower level AND histogram ≥ outer lower level AND on the preceding higher-timeframe bar histogram ≥ inner lower level
Short: On the last completed higher-timeframe bar, histogram < outer lower level AND on the preceding higher-timeframe bar histogram ≥ outer lower level
Exit: short, last completed higher-timeframe histogram > inner upper level
Exit: long, last completed higher-timeframe histogram < inner lower level
Exit: long, low ≤ entry price − stop-loss distance OR high ≥ entry price + take-profit distance
Exit: short, high ≥ entry price + stop-loss distance OR low ≤ entry price − take-profit distance