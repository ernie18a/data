Calculation: RSI = RSI(close, RSI length, T1, last completed bar)
Calculation: Smoothed MFI = EMA(MFI(hlc3, MFI length), MFI smoothing length, T1, last completed bar)
Calculation: DI+ = DI+(ADX length, ADX length, T1, last completed bar)
Calculation: DI- = DI-(ADX length, ADX length, T1, last completed bar)
Calculation: Raw regime = 1 if (ordered AND spread wide AND fast outer SMMA >= slow outer SMMA), -1 if (ordered AND spread wide AND fast outer SMMA < slow outer SMMA), else 0, where fast outer SMMA = SMMA(reference index hl2, fast outer length), fast inner SMMA = SMMA(reference index hl2, fast inner length), slow inner SMMA = SMMA(reference index hl2, slow inner length), slow outer SMMA = SMMA(reference index hl2, slow outer length), with fast outer length < fast inner length < slow inner length < slow outer length, ordered = ((fast outer SMMA < fast inner SMMA) == (fast outer SMMA < slow outer SMMA)) AND ((slow inner SMMA < slow outer SMMA) == (fast outer SMMA < slow outer SMMA)), spread wide = abs(fast outer SMMA - slow outer SMMA) / slow outer SMMA * 100 >= neutral zone; on T1 bars of the reference index, read at last completed T1 bar
Calculation: Confirmed regime = V when Raw regime has equaled V, with V different from the previous Confirmed regime, for confirmation bars consecutive chart bars; otherwise the previous Confirmed regime
Calculation: RSI vote = clamp((RSI - RSI midline) / RSI vote scale, -1, 1)
Calculation: MFI vote = clamp((MFI(hlc3, MFI length, T1, last completed bar) - MFI vote midpoint) / MFI vote scale, -1, 1)
Calculation: OBV vote = clamp(slope / (OBV vote scale * stdev(slope, OBV stdev lookback)), -1, 1), where slope = OBV - OBV[OBV slope lag] and the vote is 0 if that stdev is not positive; on T1 bars, read at last completed T1 bar
Calculation: ADX conviction = ADX conviction base + min(1, ADX(ADX length, ADX length, T1, last completed bar) / ADX conviction scale)
Calculation: Market score = clamp(score midpoint + score half-range * ADX conviction * (regime weight * Confirmed regime + RSI weight * RSI vote + MFI weight * MFI vote + OBV weight * OBV vote) / (regime weight + RSI weight + MFI weight + OBV weight), 0, 100)
Calculation: Bullish divergence(S, O) = on T1 bars, a pivot low of the low of S, with pivot left length and pivot right length, is confirmed on the current bar, is below the previous confirmed pivot low, that previous pivot was confirmed no more than max pivot lookback bars ago, and O at this pivot bar is above O at the previous pivot bar; read at last completed T1 bar
Calculation: Bearish divergence(S, O) = on T1 bars, a pivot high of the high of S, with pivot left length and pivot right length, is confirmed on the current bar, is above the previous confirmed pivot high, that previous pivot was confirmed no more than max pivot lookback bars ago, and O at this pivot bar is below O at the previous pivot bar; read at last completed T1 bar
Calculation: Bullish ADX exhaustion = on T1 bars of the chart symbol, a pivot low of the low, with pivot left length and pivot right length, is confirmed on the current bar, is below the previous confirmed pivot low, that previous pivot was confirmed no more than max pivot lookback bars ago, and ADX[pivot right length] < ADX[pivot right length + 1] with ADX = ADX(ADX length, ADX length); read at last completed T1 bar
Calculation: Bearish ADX exhaustion = on T1 bars of the chart symbol, a pivot high of the high, with pivot left length and pivot right length, is confirmed on the current bar, is above the previous confirmed pivot high, that previous pivot was confirmed no more than max pivot lookback bars ago, and ADX[pivot right length] < ADX[pivot right length + 1] with ADX = ADX(ADX length, ADX length); read at last completed T1 bar
Long: Bullish divergence(chart symbol, RSI(close, RSI length))
Long: Bullish divergence(open interest, close of open interest)
Long: Bullish ADX exhaustion
Long: Smoothed MFI >= MFI midline
Long: RSI >= RSI midline
Long: DI+ >= DI-
Long: Market score > score midpoint
Long: Market score >= long threshold
Short: Bearish divergence(chart symbol, RSI(close, RSI length))
Short: Bearish divergence(open interest, close of open interest)
Short: Bearish ADX exhaustion
Short: Smoothed MFI < MFI midline
Short: RSI < RSI midline
Short: DI+ < DI-
Short: Market score < score midpoint
Short: Market score <= short threshold