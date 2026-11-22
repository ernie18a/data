Calculation: Session bars = number of consecutive in-session bars ending at the current bar, or 0 on an out-of-session bar
Calculation: Close efficiency = EMA(ER(close, VWAP ER length), VWAP ER smoothing length)
Calculation: VWAP efficiency = EMA(ER(VWAP, VWAP ER length), VWAP ER smoothing length)
Calculation: VWAP slope = IF ATR(ATR length) > 0 THEN (VWAP - VWAP[VWAP slope lookback]) / ATR(ATR length) ELSE 0
Calculation: Slope threshold = MAX(slope threshold multiplier * STDEV(VWAP slope, slope stdev length), slope threshold floor)
Calculation: KAMA efficiency = EMA(ER(close, KAMA ER length), KAMA ER smoothing length)
Calculation: KAMA = IF KAMA[1] is unavailable THEN close ELSE KAMA[1] + SC * (close - KAMA[1]), where SC = (KAMA efficiency * (2 / (KAMA fast length + 1) - 2 / (KAMA slow length + 1)) + 2 / (KAMA slow length + 1))^2
Calculation: CPI = CLV(high, low, close) IF (high - low) > 0 AND (high - low) >= minimum bar range ELSE 0
Calculation: Volume ratio(up, down) = 0 IF up = 0 OR down = 0; up / down IF up >= down; -(down / up) OTHERWISE
Calculation: NYSE ratio = Volume ratio(NYSE up-volume, NYSE down-volume)
Calculation: NASDAQ ratio = Volume ratio(NASDAQ up-volume, NASDAQ down-volume)
Calculation: Internal score = NYSE weight * NYSE ratio + NASDAQ weight * NASDAQ ratio
Calculation: Effective body = MAX(ABS(close - open), ATR(ATR length) * minimum body ATR fraction)
Calculation: Candle score = IF close > open THEN bull zone score + body score; IF close < open THEN bear zone score - body score; ELSE 0; bull zone score = high zone points IF close >= low + upper zone fraction * (high - low), middle zone points IF low + lower zone fraction * (high - low) < close < low + upper zone fraction * (high - low), ELSE 0; bear zone score = high zone points IF close <= low + lower zone fraction * (high - low), middle zone points IF low + lower zone fraction * (high - low) < close < low + upper zone fraction * (high - low), ELSE 0; body score = strong body points IF ABS(close - open) >= strong body ratio * (high - low), ELSE moderate body points IF ABS(close - open) >= moderate body ratio * (high - low), ELSE 0
Calculation: Final score = (Candle score[1] + Candle score[0] + (IF close > high[1] OR close < low[1] THEN outside-range points * SIGN(close - open) ELSE 0)) * (IF ATR(ATR length) > 0 THEN MIN((high - low) / ATR(ATR length), range weight cap) ELSE 1)
Calculation: Slope-adaptive score = (LinReg(Final score, score regression length, 0) - LinReg(Final score, score regression length, 1)) * ER(Final score, score efficiency length)
Calculation: Bull alignment state = in session AND CPI >= CPI threshold AND Close efficiency >= minimum efficiency AND NYSE ratio > alignment ratio threshold AND NASDAQ ratio > alignment ratio threshold
Calculation: Bear alignment state = in session AND CPI <= -CPI threshold AND Close efficiency >= minimum efficiency AND NYSE ratio < -alignment ratio threshold AND NASDAQ ratio < -alignment ratio threshold
Calculation: Previous T1 high = high of the last completed T1 bar
Long: Bull alignment state
Long: in session AND Internal score > 0 AND VWAP slope <= 0 AND sign(NYSE ratio) = sign(NASDAQ ratio)
Long: in session AND NYSE ratio > effort ratio threshold AND NASDAQ ratio > effort ratio threshold AND Close efficiency < effort efficiency threshold
Long: in session AND Close efficiency < minimum efficiency AND MIN(open, close) - low > Effective body * wick multiple AND close > low + (high - low) * close position fraction AND (NYSE tick index > absorption tick threshold OR NYSE ratio > absorption ratio threshold)
Long: KAMA - KAMA[1] > 0 AND KAMA efficiency > KAMA efficiency threshold
Long: close > VWAP AND ((Session bars >= VWAP ER length + VWAP ER smoothing length AND Session bars > slope warm-up bars AND VWAP slope > Slope threshold AND VWAP efficiency > VWAP efficiency threshold) OR (Session bars < VWAP ER length + VWAP ER smoothing length AND Session bars >= early bar count AND CPI > early CPI threshold))
Long: NASDAQ ratio >= volume dominance threshold
Long: NYSE ratio >= volume dominance threshold
Long: NYSE tick index >= tick threshold
Long: round((CPI + 1) / 2 * 100) >= upper display threshold
Long: Slope-adaptive score > 0
Long: KAMA - VWAP > 0
Long: close crosses above Previous T1 high AND Bull alignment state
Short: Bear alignment state
Short: in session AND Internal score < 0 AND VWAP slope >= 0 AND sign(NYSE ratio) = sign(NASDAQ ratio)
Short: in session AND NYSE ratio < -effort ratio threshold AND NASDAQ ratio < -effort ratio threshold AND Close efficiency < effort efficiency threshold
Short: in session AND Close efficiency < minimum efficiency AND (high - MAX(open, close)) > Effective body * wick multiple AND close < high - (high - low) * close position fraction AND (NYSE tick index < -absorption tick threshold OR NYSE ratio < -absorption ratio threshold)
Short: KAMA - KAMA[1] < 0 AND KAMA efficiency > KAMA efficiency threshold
Short: close < VWAP AND ((Session bars >= VWAP ER length + VWAP ER smoothing length AND Session bars > slope warm-up bars AND VWAP slope < -Slope threshold AND VWAP efficiency > VWAP efficiency threshold) OR (Session bars < VWAP ER length + VWAP ER smoothing length AND Session bars >= early bar count AND CPI < -early CPI threshold))
Short: NASDAQ ratio <= -volume dominance threshold
Short: NYSE ratio <= -volume dominance threshold
Short: NYSE tick index <= -tick threshold
Short: round((CPI + 1) / 2 * 100) <= lower display threshold
Short: Slope-adaptive score < 0
Short: out of session OR KAMA - VWAP <= 0
Short: high >= Previous T1 high AND in session AND ((Internal score < 0 AND VWAP slope >= 0 AND sign(NYSE ratio) = sign(NASDAQ ratio) AND NOT Bear alignment state) OR (NYSE ratio < -effort ratio threshold AND NASDAQ ratio < -effort ratio threshold AND Close efficiency < effort efficiency threshold))