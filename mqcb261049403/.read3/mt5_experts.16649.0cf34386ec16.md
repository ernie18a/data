Calculation: XMACandles candle color = 2 when XMACandles candle close > XMACandles candle open, 0 when XMACandles candle close < XMACandles candle open, 1 otherwise
Long: On T1 bars, XMACandles candle color on the latest completed bar = 2 AND XMACandles candle color on the preceding bar < 2
Short: On T1 bars, XMACandles candle color on the latest completed bar = 0 AND XMACandles candle color on the preceding bar > 0
Exit: long, on T1 bars XMACandles candle color on the latest completed bar = 0 AND XMACandles candle color on the preceding bar = 0
Exit: short, on T1 bars XMACandles candle color on the latest completed bar = 2 AND XMACandles candle color on the preceding bar = 2