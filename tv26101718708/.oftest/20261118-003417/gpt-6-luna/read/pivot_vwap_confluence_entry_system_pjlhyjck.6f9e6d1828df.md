Calculation: Pivot levels = P=(high+low+close)/3, R1=2*P-low, R2=P+(high-low), R3=high+2*(P-low), S1=2*P-high, S2=P-(high-low), S3=low-2*(high-P), using high, low, and close of the last completed T1 bar; R4=R3+(R1-S1), R5=R4+(R1-S1), S4=S3-(R1-S1), S5=S4-(R1-S1)
Calculation: VWAP = cumulative sum(hlc3*volume)/cumulative sum(volume), reset at each T1 boundary and calculated on chart bars
Long: within session S1 on T2 AND current T1 entry count < parameter AND for any L in {P,R1,R2,R3,R4,R5,S1,S2,S3,S4,S5}, low < L AND low < VWAP AND close > L AND close > VWAP
Short: within session S1 on T2 AND current T1 entry count < parameter AND for any L in {P,R1,R2,R3,R4,R5,S1,S2,S3,S4,S5}, high > L AND high > VWAP AND close < L AND close < VWAP
Exit: long, consecutive chart-bar closes below VWAP > parameter
Exit: short, consecutive chart-bar closes above VWAP > parameter