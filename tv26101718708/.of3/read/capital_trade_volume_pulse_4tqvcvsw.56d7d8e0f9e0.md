Calculation: BodyMax = max(open, close)
Calculation: BodyMin = min(open, close)
Long: ROC(volume, L) > P1 AND close >= open
Long: (BodyMin[K] < BodyMin[K-i] AND (BodyMin[K] < BodyMin[K+i] OR (BodyMin[K] = BodyMin[K+i] AND E))) for every i from 1 to K
Short: ROC(volume, L) > P1 AND close < open
Short: (BodyMax[K] > BodyMax[K-i] AND (BodyMax[K] > BodyMax[K+i] OR (BodyMax[K] = BodyMax[K+i] AND E))) for every i from 1 to K