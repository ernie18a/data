Calculation: MA1[n] = SMMA(median, lookback1, T1, shift1)[n], read on each chart tick from completed T1 bars; n is bars ago
Calculation: MA2[n] = SMMA(median, lookback2, T2, shift2)[n], read on each chart tick from completed T2 bars; n is bars ago
Calculation: MA3[n] = SMMA(median, lookback3, T3, shift3)[n], read on each chart tick from completed T3 bars; n is bars ago
Calculation: score1 = round(rounding scale * (((MA1[1]-MA1[2])/MA1[1])*weight1a + ((MA1[2]-MA1[3])/MA1[3])*weight1b + ((MA1[3]-MA1[4])/MA1[4])*weight1c))
Calculation: score2 = round(rounding scale * (((MA2[1]-MA2[2])/MA2[2])*weight2a + ((MA2[2]-MA2[3])/MA2[3])*weight2b + ((MA2[3]-MA2[4])/MA2[4])*weight2c))
Calculation: score3 = round(rounding scale * (((MA3[1]-MA3[2])/MA3[2])*weight3a + ((MA3[2]-MA3[3])/MA3[3])*weight3b + ((MA3[3]-MA3[4])/MA3[4])*weight3c))
Long: score1 > 0 AND score2 > 0 AND score3 > 0
Short: score1 > 0 AND score2 < 0 AND score3 < 0