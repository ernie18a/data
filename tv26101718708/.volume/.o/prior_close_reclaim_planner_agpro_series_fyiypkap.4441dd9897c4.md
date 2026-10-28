Calculation: Prior close = close of the last completed bar on the selected reference timeframe
Calculation: Reference ATR = ATR over the selected lookback on the last completed bar of the selected reference timeframe
Calculation: Upper/lower pocket = prior close ± (reference ATR × pocket-width parameter)
Calculation: Reclaim score = round(clamp(18 + close quality + wick quality + volume quality + magnet quality + volatility fit + confirmation bonus − distance penalty, 0, 100))
Calculation: Close quality = above upper pocket: clamp((close − upper pocket) / chart ATR × 50, 0, 24); below lower pocket: clamp((lower pocket − close) / chart ATR × 50, 0, 24); otherwise 8
Calculation: Wick quality = above upper pocket: clamp((close − low) / max(high − low, minimum tick) × 20, 0, 20); below lower pocket: clamp((high − close) / max(high − low, minimum tick) × 20, 0, 20); otherwise clamp(abs(close − open) / max(high − low, minimum tick) × 12, 0, 12)
Calculation: Volume quality = clamp((current volume / its simple moving average over the relative-volume lookback) × 14, 0, 18)
Calculation: Magnet quality = clamp((magnet-distance parameter − distance in reference ATRs) / max(magnet-distance parameter, 0.01) × 16, 0, 16)
Calculation: Volatility fit = clamp(16 − abs(chart ATR / its simple moving average over the relative-volume lookback − 1) × 18, 0, 16)
Calculation: Distance penalty = if distance in reference ATRs exceeds the magnet-distance parameter, clamp((distance in reference ATRs − magnet-distance parameter) × 12, 0, 42); otherwise 0
Calculation: Distance in reference ATRs = abs(close − prior close) / reference ATR
Calculation: Confirmation bonus = 10 when confirmation mode is Wick + Close and a bullish or bearish pocket rejection occurs; otherwise 0
Long: On a confirmed bar, the reference is not old, reclaim score ≥ minimum-ready-score, and relative volume ≥ minimum-relative-volume, AND (close crosses above upper pocket OR low ≤ upper pocket AND close > upper pocket AND close > open OR close > upper pocket AND distance in reference ATRs ≤ magnet-distance parameter × 1.25)
Short: On a confirmed bar, the reference is not old, reclaim score ≥ minimum-ready-score, and relative volume ≥ minimum-relative-volume, AND (close crosses below lower pocket OR high ≥ lower pocket AND close < lower pocket AND close < open OR close < lower pocket AND distance in reference ATRs ≤ magnet-distance parameter × 1.25)
Exit: long, after the most recent qualified bullish reclaim, a later confirmed bar closes below the lower pocket
Exit: short, after the most recent qualified bearish reclaim, a later confirmed bar closes above the upper pocket