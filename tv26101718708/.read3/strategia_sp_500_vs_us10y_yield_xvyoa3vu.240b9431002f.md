Calculation: normalized range position = (close(T1, still-forming bar) - lowest(close(T1, still-forming bar), lookback, on chart bars using T1 values)) / (highest(close(T1, still-forming bar), lookback, on chart bars using T1 values) - lowest(close(T1, still-forming bar), lookback, on chart bars using T1 values))
Long: normalized range position <= threshold
Exit: long, normalized range position > threshold
Long: Stochastic of 10-Year Treasury yield close over T1 lookback parameter <= threshold parameter
Exit: long, Stochastic of 10-Year Treasury yield close over T1 lookback parameter > threshold parameter