Calculation: Range = mean of high minus low over a lookback ending at the current bar.
Calculation: Selected lookback = the shorter Williams %R lookback if, within a scan ending at the current bar, any absolute difference between a close and an earlier close at a fixed lag is at least Range multiplied by a threshold; otherwise the longer Williams %R lookback. The earlier-close lag is shorter than the scan lookback.
Calculation: Oscillator = 100 minus the absolute value of Williams %R calculated with the current bar's selected lookback. Use that same lookback for all historical oscillator values examined for the current decision.
Calculation: Prior extreme = the most recent earlier oscillator value strictly outside the lower and upper thresholds; values equal to either threshold are inside the range. The lower threshold is below the upper threshold.
Long: Oscillator > upper threshold AND prior extreme < lower threshold.
Short: Oscillator < lower threshold AND prior extreme > upper threshold.
Long: On the first chart bar of a higher-timeframe bar, the same long condition is true using the still-forming higher-timeframe bar and higher-timeframe history.
Short: On the first chart bar of a higher-timeframe bar, the same short condition is true using the still-forming higher-timeframe bar and higher-timeframe history.