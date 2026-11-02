Calculation: Up/down volume ratio = sum of volume on bars where close > open divided by sum of volume on bars where close < open over the same lookback; if the denominator is zero, use the numerator.
Calculation: Flow score = bullish count minus bearish count, with equal weight for each condition. Bullish count conditions: RSI > bullish RSI threshold; MFI > bullish MFI threshold; up/down volume ratio > bullish ratio threshold; close > SMA of close; close > every close in a preceding lookback. Bearish count conditions: RSI < weak RSI threshold; MFI < MFI midpoint; up/down volume ratio < bearish ratio threshold; close < SMA of close; close < every close in the same preceding lookback.
Calculation: Volume delta = EMA of volume on bars where close > open, with zero on other bars, minus EMA of volume on bars where close < open, with zero on other bars; both EMAs use the same length.
Calculation: Signed volume flow = EMA of volume multiplied by (close - open) / (high - low); replace a zero high-low denominator with 1.
Calculation: Bullish expansion state = EMA of max(RSI - RSI midpoint, 0) divided by the RSI midpoint and expressed as a percentage > expansion pressure threshold AND (volume / SMA of volume - 1), expressed as a percentage, > expansion run-rate threshold.
Long: low = lowest low over the divergence lookback AND RSI > lowest RSI over the same lookback AND RSI one divergence lookback ago = that lowest RSI.
Short: high = highest high over the divergence lookback AND RSI < highest RSI over the same lookback AND RSI one divergence lookback ago = that highest RSI.
Long: close > session VWAP of typical price.
Short: close <= session VWAP of typical price.
Long: up/down volume ratio >= bullish ratio threshold.
Short: up/down volume ratio <= bearish ratio threshold AND up/down volume ratio < bullish ratio threshold.
Long: RSI > bullish RSI threshold AND MFI > bullish MFI threshold.
Short: RSI < weak RSI threshold AND MFI < MFI midpoint AND (RSI <= bullish RSI threshold OR MFI <= bullish MFI threshold).
Long: flow score >= positive display threshold.
Short: flow score <= negative display threshold.
Long: RSI > bullish RSI threshold.
Short: RSI < weak RSI threshold AND RSI <= bullish RSI threshold AND RSI <= strong RSI threshold.
Long: higher- or lower-timeframe RSI >= bullish RSI threshold; use the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar.
Short: higher- or lower-timeframe RSI <= weak RSI threshold AND higher- or lower-timeframe RSI < bullish RSI threshold; use the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar.
Long: chart-timeframe or higher- or lower-timeframe short-term RSI >= upper short-term RSI threshold; for another timeframe use the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar.
Short: chart-timeframe or higher- or lower-timeframe short-term RSI <= lower short-term RSI threshold; for another timeframe use the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar.
Long: MFI >= bullish MFI threshold.
Short: MFI <= MFI midpoint AND MFI < bullish MFI threshold.
Long: signed volume flow > 0.
Short: signed volume flow <= 0.
Long: volume delta > 0.
Short: volume delta <= 0.
Long: bullish expansion state is true AND bullish expansion state on the preceding bar is false.
Long: flow score > positive alert threshold AND preceding flow score <= positive alert threshold.
Short: flow score < negative alert threshold AND preceding flow score >= negative alert threshold.