Calculation: Bullish context score = count of close above session VWAP, EMA(close, shorter EMA lookback) above EMA(close, longer EMA lookback), close above intermediate SMA(close), close above longer SMA(close), close above the last completed T1 close, and advance-decline reading above zero on the still-forming T1 bar, sampled on chart bars.
Calculation: Bearish context score = six minus bullish context score.
Calculation: Premarket high and low = highest high and lowest low of current-day premarket chart bars.
Calculation: Opening-range high and low = highest high and lowest low of chart bars from regular-session open through opening-range duration.
Calculation: Day RVOL = chart-bar cumulative volume since the current T1 period began divided by SMA(volume, volume-average lookback, T1, last completed bar).
Calculation: Normalized MACD histogram change = 100 × (MACD histogram(close, fast lookback, slow lookback, signal lookback) − its value at slope lookback bars ago) / ATR(ATR lookback).
Calculation: Bias-aligned momentum = normalized MACD histogram change when bullish context score ≥ bearish context score; otherwise its negative.
Calculation: Momentum gate passes = gate disabled OR (gate blocks fading AND bias-aligned momentum is not below negative flat-zone parameter) OR (gate requires acceleration AND bias-aligned momentum is above flat-zone parameter).
Calculation: A+ long setup = bullish context score ≥ conviction threshold AND Day RVOL ≥ day-RVOL threshold AND momentum gate passes.
Calculation: A+ short setup = bearish context score ≥ conviction threshold AND Day RVOL ≥ day-RVOL threshold AND momentum gate passes.
Long: bullish context score ≥ conviction threshold.
Short: bearish context score ≥ conviction threshold.
Long: close crosses above the high of the last completed T1 bar.
Short: close crosses below the low of the last completed T1 bar.
Long: close crosses above premarket high.
Short: close crosses below premarket low.
Long: during the regular session after opening-range duration, close crosses above opening-range high.
Short: during the regular session after opening-range duration, close crosses below opening-range low.
Long: close crosses above session VWAP.
Short: close crosses below session VWAP.
Long: A+ long setup AND A+ long setup was false on the preceding chart bar.
Short: A+ short setup AND A+ short setup was false on the preceding chart bar.
Long: bullish context score ≥ bearish context score AND bias-aligned momentum is above flat-zone parameter AND it was not above that parameter on the preceding chart bar.
Short: bearish context score > bullish context score AND bias-aligned momentum is above flat-zone parameter AND it was not above that parameter on the preceding chart bar.
Exit: long, bullish context score ≥ conviction threshold AND bias-aligned momentum is below negative flat-zone parameter AND it was not below that parameter on the preceding chart bar.
Exit: short, bearish context score ≥ conviction threshold AND bias-aligned momentum is below negative flat-zone parameter AND it was not below that parameter on the preceding chart bar.