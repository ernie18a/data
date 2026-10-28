Calculation: TFO = smoothed flow of candle pressure: normalize the current bar’s body and lower-minus-upper wick by the prior completed bar’s ATR, weight by relative volume (square root of current volume divided by the prior rolling median, capped above and floored below; use price geometry alone when volume is unavailable), then accumulate torque with exponentially fading memory. Use the current bar’s OHLCV; prior bars supply the ATR, volume baseline, and flow history.
Calculation: TFO signal = a smoothed TFO baseline.
Calculation: Directional extreme = the rolling percentile of absolute TFO values from prior completed bars; the upper extreme is positive and the lower extreme is its negative.
Long: TFO > 0 OR TFO crosses above TFO signal
Short: TFO < 0 OR TFO crosses below TFO signal