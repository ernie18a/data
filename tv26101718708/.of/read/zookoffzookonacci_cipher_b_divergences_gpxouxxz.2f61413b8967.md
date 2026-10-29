Calculation: Fast WaveTrend and slow WaveTrend = From the chart timeframe's HLC3, calculate CI = (HLC3 − EMA(HLC3, channel lookback)) / (0.015 × EMA(abs(HLC3 − EMA(HLC3, channel lookback)), same lookback)); fast WaveTrend is EMA(CI, longer smoothing lookback), and slow WaveTrend is SMA(fast WaveTrend, shorter smoothing lookback).
Calculation: Confirmed 5-bar pivot = A center bar is a pivot high if its value exceeds the two bars before and after it, or a pivot low if below those four bars; it is confirmed two bars after the center bar.
Calculation: Regular bearish divergence = At a confirmed oscillator pivot high, price makes a higher high than at the preceding matching pivot high while the oscillator makes a lower high. Regular bullish divergence = At a confirmed oscillator pivot low, price makes a lower low than at the preceding matching pivot low while the oscillator makes a higher low. Apply the configured oscillator threshold at the pivot when threshold filtering is enabled.
Calculation: RSI = Relative Strength Index of close.
Calculation: RSI at the preceding WaveTrend pivot low = RSI on the bar two bars before the latest confirmed WaveTrend pivot low.
Calculation: Higher-timeframe Fast-WaveTrend gap = Fast WaveTrend minus slow WaveTrend calculated on a higher timeframe, using its bar still forming.
Calculation: Higher-timeframe Heikin-Ashi direction = Close above open is bullish; close below open is bearish, on each of the two configured higher timeframes, using their bars still forming.
Long: Fast WaveTrend crosses above slow WaveTrend AND slow WaveTrend is at or below the oversold threshold.
Long: Regular bullish WaveTrend divergence.
Long: Regular bullish RSI divergence.
Long: Sommi bullish flag: Money Flow is above its configured threshold AND slow WaveTrend is below its configured threshold AND fast WaveTrend crosses above slow WaveTrend AND higher-timeframe Fast-WaveTrend gap is above its configured threshold.
Long: Sommi bullish diamond: Slow WaveTrend is at or below its configured threshold AND fast WaveTrend crosses above slow WaveTrend AND both higher-timeframe Heikin-Ashi directions are bullish.
Long: (Regular bullish WaveTrend divergence OR regular bullish RSI divergence) AND the preceding WaveTrend pivot low is at or below the deepest oversold threshold AND current slow WaveTrend is above that threshold AND preceding WaveTrend pivot low minus current slow WaveTrend is at most the configured negative separation AND RSI at the preceding WaveTrend pivot low is below its oversold threshold.
Short: Fast WaveTrend crosses below slow WaveTrend AND slow WaveTrend is at or above the overbought threshold.
Short: Regular bearish WaveTrend divergence.
Short: Regular bearish RSI divergence.
Short: Sommi bearish flag: Money Flow is below its configured threshold AND slow WaveTrend is above its configured threshold AND fast WaveTrend crosses below slow WaveTrend AND higher-timeframe Fast-WaveTrend gap is below its configured threshold.
Short: Sommi bearish diamond: Slow WaveTrend is at or above its configured threshold AND fast WaveTrend crosses below slow WaveTrend AND both higher-timeframe Heikin-Ashi directions are bearish.