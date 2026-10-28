Calculation: ATR = Wilder moving average of true range
Calculation: Session VWAP = volume-weighted average of HLC3 ( (high + low + close) / 3 ) for the current session
Calculation: Confirmed pivot high/low = a high/low greater/less than the highs/lows of the preceding and following bars over the pivot lookback; it becomes available after the following bars complete
Calculation: Pivot center = initialize with the first confirmed pivot high or low; whenever a new pivot is confirmed, use the pivot high if both types confirm on the same bar, otherwise use the confirmed pivot; update as (2 × previous center + new pivot) / 3
Calculation: Pivot SuperTrend = use pivot center ± ATR × a multiplier as upper/lower bands; trail the lower band upward using the prior lower band when the previous close is above it, and trail the upper band downward using the prior upper band when the previous close is below it; trend is bullish when close exceeds the prior upper band, bearish when close falls below the prior lower band, and otherwise retains the prior trend (initially bullish)
Calculation: VWAP buffer = ATR(14) × a percentage; the VWAP filter requires close above session VWAP plus the buffer for bullish conditions, or below session VWAP minus the buffer for bearish conditions
Calculation: Active structure levels = the latest confirmed pivot high and pivot low, each retained until close breaks above the high or below the low, respectively; clear a level when broken
Long: Pivot SuperTrend trend is bullish AND close > session VWAP + VWAP buffer AND no earlier main long signal has occurred during the current uninterrupted bullish trend
Long: Pivot SuperTrend trend is bullish AND low <= session VWAP + 3 × VWAP buffer AND close > open AND close > previous close AND main long condition is false
Short: Pivot SuperTrend trend is bearish AND close < session VWAP - VWAP buffer AND no earlier main short signal has occurred during the current uninterrupted bearish trend
Short: Pivot SuperTrend trend is bearish AND high >= session VWAP - 3 × VWAP buffer AND close < open AND close < previous close AND main short condition is false
Exit: long, Pivot SuperTrend trend is bullish AND close < the active confirmed pivot low
Exit: short, Pivot SuperTrend trend is bearish AND close > the active confirmed pivot high