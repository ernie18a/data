Calculation: Index 1 is the last completed chart bar; higher indices are successively older bars. O, H, L and C denote open, high, low and close. B(i) is the mean of abs(O(j)-C(j)) over a configurable number of bars starting at i and extending backwards; use the same lookback for all B values. M(i) = (H(i)+L(i))/2. D(i) = (O(i)+C(i))/2. S(i) is the simple moving average of close with the same lookback as B. F(i) is the money flow index using volume. For F thresholds, use exit-low < entry-low < entry-high < exit-high.
Long: C(3)-O(3)>B(1) AND C(2)-O(2)>B(1) AND C(1)-O(1)>B(1) AND M(2)>M(3) AND M(1)>M(2)
Short: O(3)-C(3)>B(1) AND O(2)-C(2)>B(1) AND O(1)-C(1)>B(1) AND M(2)<M(3) AND M(1)<M(2)
Short: C(2)-O(2)>B(1) AND C(1)<C(2) AND C(1)>O(2) AND D(2)>S(1) AND O(1)>H(2)
Long: C(1)-O(1)>B(1) AND O(2)-C(2)>B(1) AND C(2)>C(1) AND C(1)<O(2) AND D(2)<S(2) AND O(1)<L(2)
Long: O(3)-C(3)>B(1) AND B(2)<B(1)*doji factor AND C(2)<C(3) AND O(2)<O(3) AND O(1)>C(2) AND C(1)>C(2)
Short: C(3)-O(3)>B(1) AND B(2)<B(1)*doji factor AND C(2)>C(3) AND O(2)>O(3) AND O(1)<C(2) AND C(1)<C(2)
Short: O(2)<C(2) AND O(1)-C(1)>B(1) AND C(1)<O(2) AND D(2)>S(2) AND O(1)>C(2)
Long: O(2)>C(2) AND C(1)-O(1)>B(1) AND C(1)>O(2) AND D(2)<S(2) AND O(1)<C(2)
Short: C(3)-O(3)>B(1) AND abs(C(2)-O(2))<B(1)*star factor AND C(2)>C(3) AND O(2)>O(3) AND C(1)<D(3)
Long: O(3)-C(3)>B(1) AND abs(C(2)-O(2))<B(1)*star factor AND C(2)<C(3) AND O(2)<O(3) AND C(1)>D(3)
Long: M(1)<S(2) AND min(O(1),C(1))>H(1)-(H(1)-L(1))/3 AND C(1)<C(2) AND O(1)<O(2)
Short: M(1)>S(2) AND min(O(1), numeric value of (C(1)>H(1)-(H(1)-L(1))/3 AND C(1)>C(2) AND O(1)>O(2)))!=0
Short: C(1)<O(1) AND C(2)-O(2)>B(1) AND C(1)>O(2) AND O(1)<C(2) AND M(2)>S(2)
Long: C(1)>O(1) AND O(2)-C(2)>B(1) AND C(1)<O(2) AND O(1)>C(2) AND M(2)<S(2)
Short: C(2)-O(2)>B(1) AND O(1)-C(1)>B(1) AND abs(C(1)-C(2))<meeting factor*B(1)
Long: O(2)-C(2)>B(1) AND C(1)-O(1)>B(1) AND abs(C(1)-C(2))<meeting factor*B(1)
Long: C(3)-O(3)>B(1) AND C(2)-O(2)>B(1) AND C(1)-O(1)>B(1) AND M(2)>M(3) AND M(1)>M(2) AND F(1)<entry-low
Short: O(3)-C(3)>B(1) AND O(2)-C(2)>B(1) AND O(1)-C(1)>B(1) AND M(2)<M(3) AND M(1)<M(2) AND F(1)>entry-high
Exit: short, (F(1)>exit-low AND F(2)<exit-low) OR (F(1)>exit-high AND F(2)<exit-high)
Exit: long, (F(1)>exit-high AND F(2)<exit-high) OR (F(1)<exit-low AND F(2)>exit-low)
Exit: long, low<=entry price-stop distance OR high>=entry price+target distance
Exit: short, high>=entry price+stop distance OR low<=entry price-target distance