Calculation: Bullish FVG size (%) = if low > high[2] then ((low - high[2]) / close) * 100 else 0
Calculation: Bearish FVG size (%) = if high < low[2] then ((low[2] - high) / close) * 100 else 0
Calculation: Valid bullish FVG = low > high[2] AND Bullish FVG size (%) >= minimum gap percentage
Calculation: Valid bearish FVG = high < low[2] AND Bearish FVG size (%) >= minimum gap percentage
Long: Valid bullish FVG
Short: Valid bearish FVG
Long: For each screener symbol, on chart bars using T1 values computed on T1 bars (the forming bar in real time; the completed bar historically), bars since the latest Valid bullish FVG <= lookback bars AND (bars since the latest Valid bearish FVG is unavailable or > lookback bars OR bars since the latest Valid bullish FVG <= bars since the latest Valid bearish FVG)
Short: For each screener symbol, on chart bars using T1 values computed on T1 bars (the forming bar in real time; the completed bar historically), bars since the latest Valid bearish FVG <= lookback bars AND (bars since the latest Valid bullish FVG is unavailable or > lookback bars OR bars since the latest Valid bearish FVG < bars since the latest Valid bullish FVG)