Calculation: Volume ratio = current bar volume divided by volume on the selected prior comparison bar
Calculation: Volume change % = (volume ratio − 1) × 100
Calculation: Price change % = (current close − close on the selected prior comparison bar) / that prior close × 100
Calculation: Score = max(0, weighted sum of volume change %, absolute price change %, and volume ratio capped at its configured cap)
Long: Volume ratio exceeds the activity threshold AND price change % > 0 AND score ≥ the weak-signal threshold
Short: Volume ratio exceeds the activity threshold AND price change % < 0 AND score ≥ the weak-signal threshold