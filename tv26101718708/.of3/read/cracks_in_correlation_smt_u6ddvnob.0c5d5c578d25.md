Calculation: Pv = ZigZag(length, memory size) of the chart bars, pivots listed newest first; P(n) = price of pivot n, B(n) = bar index of pivot n, n = 0 for the newest pivot; count(Pv) = number of pivots
Calculation: Ext1(n) = high of I1 at bar B(n) if the newest pivot is high, else low of I1 at bar B(n)
Calculation: Ext2(n) = high of I2 at bar B(n) if the newest pivot is high, else low of I2 at bar B(n)
Calculation: Div1(k) = (P(0) > P(k) AND Ext1(0) <= Ext1(k)) OR (P(0) < P(k) AND Ext1(0) >= Ext1(k))
Calculation: Div2(k) = (P(0) >= P(k) AND Ext2(0) < Ext2(k)) OR (P(0) <= P(k) AND Ext2(0) > Ext2(k))
Calculation: Valid(k) = for every even j with 2 <= j <= k - 2: P(j) >= max(P(0), P(k)) if the newest pivot is low, P(j) <= min(P(0), P(k)) if the newest pivot is high
Long: the newest pivot is low AND count(Pv) >= minimum pivot count AND for some even k with 2 <= k <= count(Pv) - 1, Div1(k) AND Valid(k)
Long: the newest pivot is low AND count(Pv) >= minimum pivot count AND for some even k with 2 <= k <= count(Pv) - 1, Div2(k) AND Valid(k)
Short: the newest pivot is high AND count(Pv) >= minimum pivot count AND for some even k with 2 <= k <= count(Pv) - 1, Div1(k) AND Valid(k)
Short: the newest pivot is high AND count(Pv) >= minimum pivot count AND for some even k with 2 <= k <= count(Pv) - 1, Div2(k) AND Valid(k)