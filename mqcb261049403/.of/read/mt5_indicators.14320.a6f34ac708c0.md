Calculation: Smoothed bear power = a separately parameterized moving average of (low minus a moving average of a selected bar price); the two moving averages may use different methods and lengths.
Calculation: Higher-timeframe bear power = smoothed bear power calculated on the higher timeframe using the still-forming higher-timeframe bar, sampled on its first chart bar and held until the next higher-timeframe bar.
Long: Chart-timeframe smoothed bear power > its previous-bar value.
Short: Chart-timeframe smoothed bear power < its previous-bar value.
Long: Higher-timeframe bear power > its preceding higher-timeframe-bar value.
Short: Higher-timeframe bear power < its preceding higher-timeframe-bar value.
Long: At the selected chart-bar offset, higher-timeframe bear power > its preceding higher-timeframe-bar value AND on the preceding chart bar, higher-timeframe bear power = its preceding higher-timeframe-bar value.
Short: At the selected chart-bar offset, higher-timeframe bear power = its preceding higher-timeframe-bar value AND on the preceding chart bar, higher-timeframe bear power > its preceding higher-timeframe-bar value.