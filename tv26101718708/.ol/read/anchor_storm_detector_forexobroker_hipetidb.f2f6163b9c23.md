Calculation: Daily anchored VWAP = cumulative (HLC3 × volume) / cumulative volume since the start of the current calendar day, resetting at each new day
Calculation: Weekly anchored VWAP = cumulative (HLC3 × volume) / cumulative volume since the start of the current calendar week, resetting at each new week
Calculation: Monthly anchored VWAP = cumulative (HLC3 × volume) / cumulative volume since the start of the current calendar month, resetting at each new month
Calculation: ATR expansion ratio = current ATR using a shorter lookback / the simple moving average of that ATR using a longer lookback
Calculation: Upward anchor break count = number of enabled anchored VWAPs for which the current close is above the VWAP plus an ATR fraction, and the previous close was at or below the previous VWAP plus that same current ATR fraction
Calculation: Downward anchor break count = number of enabled anchored VWAPs for which the current close is below the VWAP minus an ATR fraction, and the previous close was at or above the previous VWAP minus that same current ATR fraction
Calculation: Storm score = round(min(100, 25 × max(upward anchor break count, downward anchor break count) + min(max(ATR expansion ratio − 1, 0) × 60, 30) + min(abs(sum of enabled-anchor positions) / number of enabled anchors × 25, 25))), where each enabled-anchor position is +1 when close is above its VWAP, −1 when below, and 0 when equal
Long: upward anchor break count ≥ 2
Long: sum of enabled-anchor positions ≥ 2
Long: upward anchor break count ≥ 2 AND ATR expansion ratio > threshold AND close > EMA(close) AND the EMA is higher than it was three bars ago AND storm score ≥ threshold AND cooldown has elapsed AND the current bar is confirmed AND the corresponding short condition is false
Short: downward anchor break count ≥ 2
Short: downward anchor break count ≥ 2 AND ATR expansion ratio > threshold AND close < EMA(close) AND the EMA is lower than it was three bars ago AND storm score ≥ threshold AND cooldown has elapsed AND the current bar is confirmed AND the corresponding long condition is false