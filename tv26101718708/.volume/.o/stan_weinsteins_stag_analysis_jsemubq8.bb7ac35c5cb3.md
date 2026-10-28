Calculation: WMA = weighted moving average of close over the base lookback
Calculation: WMA slope (%) = (current WMA - WMA from the slope lookback ago) / WMA from the slope lookback ago × 100
Calculation: Stage = start at Stage 1; transition from Stage 1 to Stage 2 when WMA slope > flat threshold and close > WMA, or to Stage 4 when WMA slope < negative flat threshold and close < WMA; from Stage 2 to Stage 3 when absolute WMA slope ≤ flat threshold or when WMA slope < negative flat threshold and close > WMA, or to Stage 4 when WMA slope < negative flat threshold and close < WMA; from Stage 3 to Stage 4 when WMA slope < negative flat threshold and close < WMA, or to Stage 2 when WMA slope > flat threshold and close > WMA; from Stage 4 to Stage 1 when absolute WMA slope ≤ flat threshold or when WMA slope > flat threshold and close < WMA, or to Stage 2 when WMA slope > flat threshold and close > WMA; otherwise retain the current stage
Calculation: Volume spike = volume > simple moving average of volume over the same lookback as the WMA × volume multiplier
Calculation: Spring low = lowest low over the liquidity lookback, excluding the current bar
Calculation: Upthrust high = highest high over the liquidity lookback, excluding the current bar
Calculation: ATR trailing stop = during consecutive Stage 2 bars, the higher of the prior bar's stop and current close minus ATR × stop multiplier; initialize to current close minus ATR × stop multiplier upon entering Stage 2, and reset outside Stage 2
Long: (Stage = 2 AND prior bar's Stage ≠ 2 AND volume spike) OR (low < Spring low AND close > Spring low AND Stage = 1)
Short: high > Upthrust high AND close < Upthrust high AND Stage = 3
Exit: long, close < ATR trailing stop