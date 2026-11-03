Calculation: Anchored VWAP = cumulative sum of volume × typical price divided by cumulative volume since the selected higher-timeframe boundary or selected date, including the current bar; begin accumulating at the first available bar and reset on the first bar at each selected boundary or crossing the selected date. Typical price is (high + low + close) / 3. If cumulative volume is zero, use current typical price. The higher-timeframe anchor period is still forming.
Calculation: Anchored deviation = square root of max(0, cumulative sum of volume × typical price squared / cumulative volume − anchored VWAP squared), using the same accumulation period; use zero if cumulative volume is zero.
Calculation: Inner upper and lower bands = anchored VWAP plus or minus anchored deviation × sensitivity parameter × inner-band multiplier parameter. Outer upper and lower bands use the same formula with the outer-band multiplier parameter, which is larger than the inner-band multiplier.
Calculation: Order flow score = 40 × body ratio + 35 × volume participation + 25 × wick rejection. Body ratio is abs(close − open) / (high − low), or zero if the range is zero. Volume participation is min(volume / EMA(volume), 3) / 3, or 0.5 if the volume EMA is not positive. Wick rejection is (close − low) / (high − low) when close > open, otherwise (high − close) / (high − low); use 0.5 if the range is zero.
Calculation: Anchored Z-score = (close − anchored VWAP) / anchored deviation if anchored deviation > 0, otherwise zero.
Long: Close crosses above anchored VWAP AND order flow score >= threshold.
Short: Close crosses below anchored VWAP AND order flow score >= threshold.
Short: Close crosses above outer upper band AND NOT (close crosses above anchored VWAP AND order flow score >= threshold).
Long: Close crosses below outer lower band AND NOT (close crosses below anchored VWAP AND order flow score >= threshold).
Long: Close > inner upper band.
Short: Close < inner lower band.
Long: Anchored Z-score > 0.
Short: Anchored Z-score <= 0.