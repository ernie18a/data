Calculation: MACD candle difference = selected MACD component calculated on close minus the same component calculated on open, using the same shorter and longer EMA periods for both. The component is either the MACD main line or its simple moving average signal line. Calculate on the chart timeframe for the indicator, or on a selectable higher, lower, or equal timeframe for the expert; the expert uses a selectable bar offset, including the still-forming bar or a completed bar, and the preceding bar on that timeframe.
Long: MACD candle difference > 0
Long: selected expert bar's MACD candle difference > 0 AND preceding bar's MACD candle difference <= 0
Short: MACD candle difference < 0
Short: selected expert bar's MACD candle difference < 0 AND preceding bar's MACD candle difference >= 0
Exit: long, selected expert bar's MACD candle difference < 0 OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, selected expert bar's MACD candle difference > 0 OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance