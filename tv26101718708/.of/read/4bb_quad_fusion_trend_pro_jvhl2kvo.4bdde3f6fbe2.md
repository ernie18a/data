Calculation: Analysis bars = bars from four ordered timeframes: the chart timeframe and three progressively higher timeframes; use the last completed bar of each higher timeframe. The weekly bar is also higher than the chart timeframe; use its last completed bar.
Calculation: Bollinger bands = simple moving average of close plus or minus a multiplier times the standard deviation of close over the same lookback.
Calculation: Bullish Bollinger condition = previous low <= previous lower Bollinger band AND close > lower Bollinger band OR close > upper Bollinger band AND previous close <= previous upper Bollinger band.
Calculation: Bearish Bollinger condition = previous high >= previous upper Bollinger band AND close < upper Bollinger band OR close < lower Bollinger band AND previous close >= previous lower Bollinger band.
Calculation: Upper trendline = on a confirmed pivot high, set the line to the pivot high and its slope to ATR divided by the pivot lookback times a multiplier; on each subsequent bar without a confirmed pivot high, subtract that stored slope. A pivot high has equal left and right lookbacks.
Calculation: Lower trendline = on a confirmed pivot low, set the line to the pivot low and its slope to ATR divided by the pivot lookback times a multiplier; on each subsequent bar without a confirmed pivot low, add that stored slope. A pivot low has equal left and right lookbacks.
Calculation: Upper break state = 0 on a confirmed pivot high; otherwise 1 when close > upper trendline minus its stored slope times the pivot lookback; otherwise retain the previous state. Initialize to 0.
Calculation: Lower break state = 0 on a confirmed pivot low; otherwise 1 when close < lower trendline plus its stored slope times the pivot lookback; otherwise retain the previous state. Initialize to 0.
Calculation: Shooting star condition = high minus close >= a wick multiplier times close minus open AND close > open.
Calculation: Hammer condition = close minus low >= a wick multiplier times open minus close AND close < open.
Calculation: Bull engulf condition = close > previous open AND open < previous close AND previous close < previous open.
Calculation: Bear engulf condition = close < previous open AND open > previous close AND previous close > previous open.
Long: Upper break state > previous upper break state.
Short: Lower break state > previous lower break state.
Long: On any analysis timeframe, short-lookback EMA of close > long-lookback EMA of close.
Short: On any analysis timeframe, short-lookback EMA of close <= long-lookback EMA of close.
Long: On any analysis timeframe, bullish Bollinger condition.
Short: On any analysis timeframe, bearish Bollinger condition AND bullish Bollinger condition is false.
Short: On any of the three shorter analysis timeframes, shooting star condition.
Long: On any of the three shorter analysis timeframes, hammer condition AND shooting star condition is false.
Long: On any of the three shorter analysis timeframes, bull engulf condition AND shooting star condition is false AND hammer condition is false.
Short: On any of the three shorter analysis timeframes, bear engulf condition AND shooting star condition is false AND hammer condition is false AND bull engulf condition is false.
Long: Chart bar is on Monday or Tuesday AND weekly close > weekly open AND weekly absolute body >= a fraction of weekly high minus weekly low.
Short: Chart bar is on Monday or Tuesday AND (weekly close < weekly open OR weekly high minus the greater of weekly open and close >= a multiplier times the weekly absolute body).
Long: At least one of the three higher analysis timeframes satisfies the bullish Bollinger condition AND none of those timeframes satisfies the bearish Bollinger condition.
Short: At least one of the three higher analysis timeframes satisfies the bearish Bollinger condition AND none of those timeframes satisfies the bullish Bollinger condition.