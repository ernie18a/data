Calculation: Energy = EMA of the 0–100 normalization of (π × ATR² × signed square root of OBV ROC); normalization uses the rolling minimum and maximum, with 50 when they are equal
Calculation: Signed square root of OBV ROC = square root of its absolute value, with its sign
Calculation: OBV ROC = rate of change of OBV
Calculation: Energy average = EMA of Energy
Calculation: Energy trend = EMA of Energy, using a longer lookback than the Energy average
Calculation: Momentum Z-score = (close ROC − its longer-lookback SMA) / its longer-lookback standard deviation; use 0 if the standard deviation is 0
Calculation: Squeeze = standard deviation of Energy < its longer-lookback SMA × squeeze factor
Calculation: Recent squeeze = a squeeze occurred within the current or previous six bars
Long: Energy > Energy average
Long: Energy > Energy trend
Long: Recent squeeze AND (Energy < bottom-zone threshold OR its rolling 8-bar minimum < bottom-zone threshold) AND Energy > previous-bar Energy AND previous-bar Energy ≤ two-bars-ago Energy AND signed square root of OBV ROC > its previous-bar value AND (light filter disabled OR (ATR percent rank ≥ minimum ATR rank AND volume percent rank ≥ minimum volume rank AND Momentum Z-score ≥ minimum Z-score)) AND (Energy > Energy trend OR energy trend filter disabled)
Long: Energy crosses above Energy average AND Recent squeeze AND (light filter disabled OR (ATR percent rank ≥ minimum ATR rank AND volume percent rank ≥ minimum volume rank AND Momentum Z-score ≥ minimum Z-score)) AND (Energy > Energy trend OR energy trend filter disabled)
Long: Energy > Energy average AND absolute difference between Energy and Energy average ≥ power threshold AND Energy > previous-bar Energy AND signed square root of OBV ROC > its previous-bar value AND (light filter disabled OR (ATR percent rank ≥ minimum ATR rank AND volume percent rank ≥ minimum volume rank AND Momentum Z-score ≥ minimum Z-score)) AND (Energy > Energy trend OR energy trend filter disabled)
Short: Energy < Energy average