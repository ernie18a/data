Calculation: buy-volume weight = IF high = low THEN neutral-volume weight ELSE (close - low) / (high - low)
Calculation: composite score = IF RSI(close, RSI lookback) > RSI score lower threshold AND RSI(close, RSI lookback) < RSI score upper threshold THEN RSI score weight ELSE 0, plus IF MACD(close, shorter lookback, longer lookback, signal lookback).line > MACD(close, shorter lookback, longer lookback, signal lookback).signal THEN MACD score weight ELSE 0, plus IF Fisher Transform(close, Fisher lookback) > Fisher Transform(close, Fisher lookback)[previous bar] THEN Fisher score weight ELSE 0, plus IF buy-volume weight > buying-pressure score threshold THEN buying-pressure score weight ELSE 0, plus IF MFI(close, MFI lookback) > MFI midpoint threshold THEN MFI score weight ELSE 0, plus IF close > VWAP(close, T1-period anchor, current T1 period, calculated on chart bars) THEN VWAP score weight ELSE 0, plus IF (SMA(volume, relative-volume lookback) is unavailable or zero THEN relative-volume fallback ELSE volume / SMA(volume, relative-volume lookback)) > relative-volume threshold THEN relative-volume score weight ELSE 0, plus IF Bollinger Bands(close, Bollinger lookback, Bollinger deviation).upper < EMA(close, channel EMA lookback) + ATR(channel ATR lookback) * channel multiplier AND Bollinger Bands(close, Bollinger lookback, Bollinger deviation).lower > EMA(close, channel EMA lookback) - ATR(channel ATR lookback) * channel multiplier THEN squeeze score weight ELSE 0
Long: close crosses above the latest confirmed pivot high not yet crossed, where PivotHigh(high, left pivot lookback, right pivot lookback) is calculated on chart bars
Short: close crosses below the latest confirmed pivot low not yet crossed, where PivotLow(low, left pivot lookback, right pivot lookback) is calculated on chart bars
Long: FVG display enabled AND low > high[gap lookback] AND close[previous-bar lag] > high[gap lookback]
Short: FVG display enabled AND high < low[gap lookback] AND close[previous-bar lag] < low[gap lookback]
Long: volume-based candle colors enabled AND buy-volume weight > upper volume-color threshold
Long: (volume-based candle colors enabled AND buy-volume weight >= lower volume-color threshold AND buy-volume weight <= upper volume-color threshold OR volume-based candle colors disabled) AND close >= open
Short: volume-based candle colors enabled AND buy-volume weight < lower volume-color threshold
Short: (volume-based candle colors enabled AND buy-volume weight >= lower volume-color threshold AND buy-volume weight <= upper volume-color threshold OR volume-based candle colors disabled) AND close < open
Long: RSI(close, RSI lookback) < RSI lower color threshold
Short: RSI(close, RSI lookback) > RSI upper color threshold
Long: MACD(close, shorter lookback, longer lookback, signal lookback).line > MACD(close, shorter lookback, longer lookback, signal lookback).signal
Short: MACD(close, shorter lookback, longer lookback, signal lookback).line <= MACD(close, shorter lookback, longer lookback, signal lookback).signal
Long: Fisher Transform(close, Fisher lookback) > Fisher Transform(close, Fisher lookback)[previous bar]
Short: Fisher Transform(close, Fisher lookback) <= Fisher Transform(close, Fisher lookback)[previous bar]
Long: buy-volume weight > volume-dominance threshold
Short: buy-volume weight <= volume-dominance threshold
Long: MFI(close, MFI lookback) > MFI midpoint threshold
Exit: long, MFI(close, MFI lookback) <= MFI midpoint threshold
Long: close > VWAP(close, T1-period anchor, current T1 period, calculated on chart bars)
Short: close <= VWAP(close, T1-period anchor, current T1 period, calculated on chart bars)
Long: composite score >= upper score-color threshold
Short: composite score < lower score-color threshold