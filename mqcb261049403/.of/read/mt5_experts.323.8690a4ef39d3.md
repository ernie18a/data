Calculation: Index i denotes the ith completed chart bar, with i=1 the latest completed bar; O, H, L and C denote open, high, low and close.
Calculation: Average body A(i) = mean of abs(O(j)-C(j)) over the configured lookback beginning at bar i and extending into older bars; its lookback equals the close SMA lookback.
Calculation: Range midpoint R(i) = (H(i)+L(i))/2; body midpoint B(i) = (O(i)+C(i))/2.
Long: C(3)-O(3)>A(1) AND C(2)-O(2)>A(1) AND C(1)-O(1)>A(1) AND R(2)>R(3) AND R(1)>R(2).
Long: C(1)-O(1)>A(1) AND O(2)-C(2)>A(1) AND C(2)>C(1) AND C(1)<O(2) AND B(2)<close SMA(2) AND O(1)<L(2).
Long: O(3)-C(3)>A(1) AND A(2)<A(1)*small-body ratio AND C(2)<C(3) AND O(2)<O(3) AND O(1)>C(2) AND C(1)>C(2).
Long: O(2)>C(2) AND C(1)-O(1)>A(1) AND C(1)>O(2) AND B(2)<close SMA(2) AND O(1)<C(2).
Long: O(3)-C(3)>A(1) AND abs(C(2)-O(2))<A(1)*star-body ratio AND C(2)<C(3) AND O(2)<O(3) AND C(1)>B(3).
Long: R(1)<close SMA(2) AND min(O(1),C(1))>H(1)-(H(1)-L(1))*upper-range fraction AND C(1)<C(2) AND O(1)<O(2).
Long: C(1)>O(1) AND O(2)-C(2)>A(1) AND C(1)<O(2) AND O(1)>C(2) AND R(2)<close SMA(2).
Long: O(2)-C(2)>A(1) AND C(1)-O(1)>A(1) AND abs(C(1)-C(2))<A(1)*meeting tolerance.
Short: O(3)-C(3)>A(1) AND O(2)-C(2)>A(1) AND O(1)-C(1)>A(1) AND R(2)<R(3) AND R(1)<R(2).
Short: C(2)-O(2)>A(1) AND C(1)<C(2) AND C(1)>O(2) AND B(2)>close SMA(1) AND O(1)>H(2).
Short: C(3)-O(3)>A(1) AND A(2)<A(1)*small-body ratio AND C(2)>C(3) AND O(2)>O(3) AND O(1)<C(2) AND C(1)<C(2).
Short: O(2)<C(2) AND O(1)-C(1)>A(1) AND C(1)<O(2) AND B(2)>close SMA(2) AND O(1)>C(2).
Short: C(3)-O(3)>A(1) AND abs(C(2)-O(2))<A(1)*star-body ratio AND C(2)>C(3) AND O(2)>O(3) AND C(1)<B(3).
Short: R(1)>close SMA(2) AND min(O(1), numeric value of C(1)>H(1)-(H(1)-L(1))*upper-range fraction) != 0 AND C(1)>C(2) AND O(1)>O(2).
Short: C(1)<O(1) AND C(2)-O(2)>A(1) AND C(1)>O(2) AND O(1)<C(2) AND R(2)>close SMA(2).
Short: C(2)-O(2)>A(1) AND O(1)-C(1)>A(1) AND abs(C(1)-C(2))<A(1)*meeting tolerance.
Long: O(3)-C(3)>A(1) AND abs(C(2)-O(2))<A(1)*star-body ratio AND C(2)<C(3) AND O(2)<O(3) AND C(1)>B(3) AND MFI(1)<long-entry MFI threshold.
Short: C(3)-O(3)>A(1) AND abs(C(2)-O(2))<A(1)*star-body ratio AND C(2)>C(3) AND O(2)>O(3) AND C(1)<B(3) AND MFI(1)>short-entry MFI threshold.
Exit: short, (MFI(1)>lower MFI exit level AND MFI(2)<lower MFI exit level) OR (MFI(1)>upper MFI exit level AND MFI(2)<upper MFI exit level).
Exit: long, (MFI(1)>upper MFI exit level AND MFI(2)<upper MFI exit level) OR (MFI(1)<lower MFI exit level AND MFI(2)>lower MFI exit level).
Exit: short, O(3)-C(3)>A(1) AND abs(C(2)-O(2))<A(1)*star-body ratio AND C(2)<C(3) AND O(2)<O(3) AND C(1)>B(3) AND MFI(1)<long-entry MFI threshold.
Exit: long, C(3)-O(3)>A(1) AND abs(C(2)-O(2))<A(1)*star-body ratio AND C(2)>C(3) AND O(2)>O(3) AND C(1)<B(3) AND MFI(1)>short-entry MFI threshold.