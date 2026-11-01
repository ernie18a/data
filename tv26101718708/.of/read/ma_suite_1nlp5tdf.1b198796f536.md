Calculation: A, B, C, and D = four independently configured moving averages of the selected price source, ordered by their default lookbacks from shortest to longest; each may use SMA, EMA, RMA, WMA, HMA, or linear-regression moving average. Each uses chart-timeframe bars or independently selected higher- or lower-timeframe bars; for a higher timeframe use the last completed bar, and for a lower timeframe use the last completed intrabar within the chart bar.
Calculation: WaveTrend fast = EMA((source - EMA(source, channel lookback)) / (scaling factor × EMA(abs(source - EMA(source, channel lookback)), channel lookback)), averaging lookback); WaveTrend slow = SMA(WaveTrend fast, smoothing lookback).
Calculation: Candle-body oscillator = SMA(multiplier × (close - open) / (high - low), lookback).
Long: B > D
Short: B <= D
Long: B crosses above D
Short: D crosses above B
Short: A crosses below B
Long: B crosses above C
Short: WaveTrend fast crosses WaveTrend slow AND WaveTrend slow >= WaveTrend fast
Long: open > B AND open > D AND previous close > previous open AND close > open AND A does not cross below B AND NOT (WaveTrend fast crosses WaveTrend slow AND WaveTrend slow >= WaveTrend fast)
Short: WaveTrend fast crosses WaveTrend slow AND WaveTrend slow >= WaveTrend fast AND A crosses below B
Long: WaveTrend fast crosses WaveTrend slow AND WaveTrend slow >= WaveTrend fast AND WaveTrend slow < upper threshold AND WaveTrend slow > lower threshold AND RSI of the selected price source < upper RSI threshold AND RSI > lower RSI threshold AND candle-body oscillator < threshold