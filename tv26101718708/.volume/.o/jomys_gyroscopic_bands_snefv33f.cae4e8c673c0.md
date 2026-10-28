Calculation: Gyroscopic line = let n be the bar number from the start; let trajectory = (previous bar’s close − close from two bars ago + previous trajectory × smoothing parameter) / (smoothing parameter + 1); let gravity = scale factor / abs(close); let intermediate = close when n ≤ 5, otherwise the previous gyroscopic line; the line is the previous gyroscopic line + gravity + trajectory when intermediate < close, otherwise the previous gyroscopic line − gravity + trajectory. Treat unavailable prior values as zero.
Long: close > gyroscopic line
Short: close < gyroscopic line
Exit: Long, close ≤ gyroscopic line
Exit: Short, close ≥ gyroscopic line