Calculation: Anchored VWAP = sum(HLC3 × volume) / sum(volume) since the selected anchor boundary
Calculation: Anchored VWAP standard deviation = sqrt(max(sum(HLC3² × volume) / sum(volume) − Anchored VWAP², 0)) since the selected anchor boundary
Calculation: VWAP zone = [Anchored VWAP − VWAP ATR-width parameter × ATR(ATR-lookback parameter), Anchored VWAP + VWAP ATR-width parameter × ATR(ATR-lookback parameter)]
Calculation: SD1 upper zone = [Anchored VWAP + SD1 deviation parameter × Anchored VWAP standard deviation − SD1 ATR-width parameter × ATR(ATR-lookback parameter), Anchored VWAP + SD1 deviation parameter × Anchored VWAP standard deviation + SD1 ATR-width parameter × ATR(ATR-lookback parameter)]
Calculation: SD1 lower zone = [Anchored VWAP − SD1 deviation parameter × Anchored VWAP standard deviation − SD1 ATR-width parameter × ATR(ATR-lookback parameter), Anchored VWAP − SD1 deviation parameter × Anchored VWAP standard deviation + SD1 ATR-width parameter × ATR(ATR-lookback parameter)]
Calculation: SD2 upper zone = [Anchored VWAP + SD2 deviation parameter × Anchored VWAP standard deviation − SD2 ATR-width parameter × ATR(ATR-lookback parameter), Anchored VWAP + SD2 deviation parameter × Anchored VWAP standard deviation + SD2 ATR-width parameter × ATR(ATR-lookback parameter)]
Calculation: SD2 lower zone = [Anchored VWAP − SD2 deviation parameter × Anchored VWAP standard deviation − SD2 ATR-width parameter × ATR(ATR-lookback parameter), Anchored VWAP − SD2 deviation parameter × Anchored VWAP standard deviation + SD2 ATR-width parameter × ATR(ATR-lookback parameter)]
Calculation: T1 volume delta = T1 volume × ((T1 close − T1 low) − (T1 high − T1 close)) / max(T1 high − T1 low, range-floor parameter); calculate on T1 bars and request delta and volume onto chart bars with lookahead off, using the developing T1 bar in realtime and the last completed T1 bar on historical chart bars
Calculation: Zone buy and sell volumes = for each zone separately, on chart bars where close is within the zone and volume is at least the minimum-volume parameter, add requested T1 volume to buy volume if T1 volume delta > 0 or sell volume if T1 volume delta < 0; when the reset parameter is enabled, reset both volumes at the selected anchor boundary or when the T2 boundary changes
Calculation: Zone bullish percentage = 100 × zone buy volume / (zone buy volume + zone sell volume), or 50 when the denominator is zero
Long: VWAP zone bullish percentage ≥ sentiment threshold parameter
Short: VWAP zone bullish percentage ≤ 100 − sentiment threshold parameter AND VWAP zone bullish percentage < sentiment threshold parameter
Long: SD1 upper zone bullish percentage ≥ sentiment threshold parameter
Short: SD1 upper zone bullish percentage ≤ 100 − sentiment threshold parameter AND SD1 upper zone bullish percentage < sentiment threshold parameter
Long: SD1 lower zone bullish percentage ≥ sentiment threshold parameter
Short: SD1 lower zone bullish percentage ≤ 100 − sentiment threshold parameter AND SD1 lower zone bullish percentage < sentiment threshold parameter
Long: SD2 upper zone bullish percentage ≥ sentiment threshold parameter
Short: SD2 upper zone bullish percentage ≤ 100 − sentiment threshold parameter AND SD2 upper zone bullish percentage < sentiment threshold parameter
Long: SD2 lower zone bullish percentage ≥ sentiment threshold parameter
Short: SD2 lower zone bullish percentage ≤ 100 − sentiment threshold parameter AND SD2 lower zone bullish percentage < sentiment threshold parameter
Long: close is within VWAP zone AND volume ≥ minimum-volume parameter AND VWAP zone bullish percentage ≥ sentiment threshold parameter
Short: close is within VWAP zone AND volume ≥ minimum-volume parameter AND VWAP zone bullish percentage ≤ 100 − sentiment threshold parameter
Short: close is within SD1 upper zone AND volume ≥ minimum-volume parameter AND SD1 upper zone bullish percentage ≤ 100 − sentiment threshold parameter
Long: close is within SD1 lower zone AND volume ≥ minimum-volume parameter AND SD1 lower zone bullish percentage ≥ sentiment threshold parameter
Short: close is within SD2 upper zone AND volume ≥ minimum-volume parameter AND SD2 upper zone bullish percentage ≤ 100 − sentiment threshold parameter
Long: close is within SD2 lower zone AND volume ≥ minimum-volume parameter AND SD2 lower zone bullish percentage ≥ sentiment threshold parameter