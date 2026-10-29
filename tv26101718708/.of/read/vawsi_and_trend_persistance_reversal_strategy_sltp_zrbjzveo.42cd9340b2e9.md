Calculation: Heikin-Ashi close = close of the Heikin-Ashi bar on the chart timeframe.
Calculation: Dynamic lookback = ceiling of cycle multiplier × smoothed dominant cycle from an Ehlers Hilbert homodyne period calculation; clamp to 1–34 bars.
Calculation: VAWSI = 100 − 100/(1 + upward VAWMA / downward VAWMA), where upward and downward inputs are respectively the positive and negative parts of the change in Heikin-Ashi close. VAWMA weights each input bar by the mean of its volume divided by its lookback average volume and its one-bar ATR divided by its lookback average one-bar ATR.
Calculation: Trend Persistence = RSI of the change in a weighted moving average of the greater of (a) the weighted moving average of the distance from Heikin-Ashi close to its lookback high and (b) the weighted moving average of its distance to its lookback low. Use the dynamic lookback for the RSI and lookback extrema; use the smoothing parameter for the weighted moving averages.
Calculation: Normalized ATR = 100 × absolute change in the lookback RMA of max(chart high − chart low, absolute change in Heikin-Ashi close) ÷ Heikin-Ashi close.
Calculation: Combined factor = combination multiplier × (VAWSI weight × 1/max(2 × abs(VAWSI − 50), 20) + Trend Persistence weight × 1/Trend Persistence − ATR weight × Normalized ATR).
Calculation: Signal age = number of chart bars since the most recent long or short signal; before any signal, count bars from the start of available history. Cap at 4999.
Calculation: Lower threshold = highest over signal age + 1 bars of min(max(highest chart close over signal age + 1 bars × (1 − Combined factor), close × (1 − minimum SL/TP percentage)), chart open).
Calculation: Upper threshold = lowest over signal age + 1 bars of max(min(lowest chart close over signal age + 1 bars × (1 + Combined factor), close × (1 + minimum SL/TP percentage)), chart open).
Calculation: Active threshold = lower threshold while direction is long, upper threshold while direction is short; initialize direction as long and switch it to short after a short signal or long after a long signal.
Long: Heikin-Ashi close crosses above the active threshold AND the chart bar is closed.
Short: Heikin-Ashi close crosses below the active threshold AND the chart bar is closed.
Exit: long, Heikin-Ashi close crosses below the active threshold AND the chart bar is closed.
Exit: short, Heikin-Ashi close crosses above the active threshold AND the chart bar is closed.