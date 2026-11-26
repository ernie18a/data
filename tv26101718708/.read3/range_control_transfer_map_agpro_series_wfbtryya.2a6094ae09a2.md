Calculation: Safe ATR = max(ATR(ATR lookback), minimum price increment)
Calculation: Range High = highest(high, range lookback)
Calculation: Range Low = lowest(low, range lookback)
Calculation: Range Height = max(Range High - Range Low, minimum price increment)
Calculation: Range ATR = Range Height / Safe ATR
Calculation: Control Midpoint = mean(Range High, Range Low)
Calculation: Control Band Lower, Control Band Upper = Control Midpoint - control-band half-width in ATR × Safe ATR, Control Midpoint + control-band half-width in ATR × Safe ATR
Calculation: Edge Touch Count = count over range lookback bars of high >= Range High - edge-touch tolerance in ATR × Safe ATR, plus count of low <= Range Low + edge-touch tolerance in ATR × Safe ATR
Calculation: Mature Range = Range ATR >= minimum range height in ATR AND Range ATR <= (if intraday adaptive range is enabled on an intraday chart, maximum range height in ATR × intraday range multiplier; otherwise maximum range height in ATR) AND Edge Touch Count >= minimum edge touches
Calculation: Candle Body Ratio = abs(close - open) / max(high - low, minimum price increment)
Calculation: Range Health = round(clamp(height weight × height balance + touch weight × clamp(Edge Touch Count / max(minimum edge touches × touch target multiplier, touch-count denominator floor) × score maximum, 0, score maximum) + midpoint weight × clamp(score maximum - abs(close - Control Midpoint) / max(Range Height × midpoint range fraction, minimum price increment) × midpoint-distance penalty, 0, score maximum), 0, score maximum)), where height balance = if Range ATR < minimum range height in ATR then Range ATR / minimum range height in ATR × undersized-range score multiplier; if Range ATR > unadjusted maximum range height in ATR then max(0, score maximum - (Range ATR - unadjusted maximum range height in ATR) / unadjusted maximum range height in ATR × score maximum); otherwise score maximum
Calculation: Transfer Quality = round(clamp(range-health weight × Range Health + body weight × clamp(Candle Body Ratio / max(minimum body ratio, score denominator floor) × score maximum, 0, score maximum) + volume weight × clamp(volume ratio / max(volume confirmation ratio, score denominator floor) × score maximum, 0, score maximum), 0, score maximum)), where volume ratio = if SMA(volume, volume-average lookback) is unavailable or <= 0 then fallback volume ratio; otherwise volume / SMA(volume, volume-average lookback)
Calculation: Buyer Failure Threshold = Control Band Lower - failure buffer in ATR × Safe ATR
Calculation: Seller Failure Threshold = Control Band Upper + failure buffer in ATR × Safe ATR
Calculation: Active Control Side = initially neutral; a qualifying Long transfer sets buyer and a qualifying Short transfer sets seller and restarts transfer age; otherwise retain the prior side, except when transfer age exceeds maximum transfer age, then set buyer if close > Control Midpoint, seller if close < Control Midpoint, or neutral if equal; set neutral if the prior side was buyer and close < Buyer Failure Threshold or the prior side was seller and close > Seller Failure Threshold
Long: Mature Range AND close > Control Band Upper AND Candle Body Ratio >= minimum body ratio AND prior-bar Active Control Side is neutral or seller AND Transfer Quality >= max(minimum transfer score - transfer-score discount, minimum qualifying transfer score)
Short: Mature Range AND close < Control Band Lower AND Candle Body Ratio >= minimum body ratio AND prior-bar Active Control Side is neutral or buyer AND Transfer Quality >= max(minimum transfer score - transfer-score discount, minimum qualifying transfer score)
Long: Mature Range AND close > Control Band Upper AND Candle Body Ratio >= minimum body ratio AND prior-bar Active Control Side is neutral or seller AND Transfer Quality >= minimum transfer score
Short: Mature Range AND close < Control Band Lower AND Candle Body Ratio >= minimum body ratio AND prior-bar Active Control Side is neutral or buyer AND Transfer Quality >= minimum transfer score
Long: Active Control Side is buyer
Short: Active Control Side is seller
Long: Mature Range AND low <= Range Low + edge-touch tolerance in ATR × Safe ATR AND close > open AND close > Range Low + edge-touch tolerance in ATR × Safe ATR
Short: Mature Range AND high >= Range High - edge-touch tolerance in ATR × Safe ATR AND close < open AND close < Range High - edge-touch tolerance in ATR × Safe ATR
Exit: long, prior-bar Active Control Side is buyer AND close < Buyer Failure Threshold
Exit: short, prior-bar Active Control Side is seller AND close > Seller Failure Threshold