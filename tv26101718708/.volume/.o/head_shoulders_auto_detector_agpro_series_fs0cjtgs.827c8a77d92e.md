Calculation: Confirmed pivot high/low = a local high/low confirmed after the configured number of bars on its right; use the latest three same-side pivots as left shoulder, head, and right shoulder.
Calculation: Neckline = the line through the latest opposite-side pivot between left shoulder and head and the latest opposite-side pivot between head and right shoulder; evaluate its interpolated price at the current bar.
Calculation: Shoulder symmetry score = the average of 100 × (1 − |left-to-head span − head-to-right span| / max(span)) and the price score 100 × (1 − shoulder height difference / max(head extension beyond either shoulder, ATR)), with the price score clamped to 0–100.
Calculation: Valid bearish H&S = three pivot highs with the head above both shoulders by at least the configured ATR multiple, shoulder height difference within its configured ATR tolerance, each time span at least the pivot length and below 200 bars, both intervening pivot lows present, neckline-anchor difference within its configured ATR tolerance, and shoulder symmetry score at or above its configured minimum.
Calculation: Valid inverse H&S = the same conditions using three pivot lows with the head below both shoulders and intervening pivot highs.
Calculation: TP1 = confirmation-bar neckline price projected by the head-to-neckline distance; that distance is measured from the average neckline anchors or from the sloped neckline at the head, according to the selected method.
Calculation: Stop = head price plus (bearish H&S) or minus (inverse H&S) the configured ATR buffer.
Long: A valid inverse H&S is detected OR a forming inverse H&S closes above its interpolated neckline after the right-shoulder pivot.
Short: A valid bearish H&S is detected OR a forming bearish H&S closes below its interpolated neckline after the right-shoulder pivot.
Exit: Long, high ≥ TP1 OR low ≤ stop.
Exit: Short, low ≤ TP1 OR high ≥ stop.