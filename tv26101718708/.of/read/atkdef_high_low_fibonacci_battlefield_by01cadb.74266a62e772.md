Calculation: Confirmed pivot high = the high of the bar a configurable number of bars ago that is greater than or equal to every high in a configurable number of preceding bars and greater than every high in the intervening bars.
Calculation: Confirmed pivot low = the low of the bar a configurable number of bars ago that is less than or equal to every low in a configurable number of preceding bars and less than every low in the intervening bars.
Calculation: Range position = (close - lowest low over a lookback) / (highest high over the same lookback - lowest low over the same lookback).
Calculation: Balance flow = min(100, 50 * buying pressure / selling pressure), where buying pressure = (close - low) / (high - low) * 100 and selling pressure = (high - close) / (high - low) * 100; both pressures are 50 when high equals low, and balance flow is 100 when selling pressure is zero.
Long: Confirmed pivot low exists.
Long: Confirmed pivot high exists AND range position > bullish-zone lower threshold AND range position <= bullish-zone upper threshold.
Long: Balance flow > bullish threshold.
Long: Close equals the lowest low over a lookback AND (RSI < oversold threshold OR RSI > lowest RSI over the same lookback).
Short: Confirmed pivot high exists.
Short: Balance flow <= bearish threshold.
Short: Close equals the highest high over a lookback AND (RSI > overbought threshold OR RSI < highest RSI over the same lookback).