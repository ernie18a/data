Calculation: Reverse-flip close = 2 × (Heikin-Ashi open + Heikin-Ashi close from two completed chart-timeframe bars ago) − (open + high + low of the immediately preceding completed chart-timeframe bar); if below that bar’s low, average the result with its low; if above its high, average the result with its high.
Calculation: Smoothed reverse-flip close = selected moving average of reverse-flip close, using a configurable lookback.
Long: Chart-timeframe close crosses above the smoothed reverse-flip close.
Short: Chart-timeframe close crosses below the smoothed reverse-flip close.
Exit: Long, low ≤ entry price × (1 − configurable stop percentage).
Exit: Short, high ≥ entry price × (1 + configurable stop percentage).