Calculation: VSTOXX Frankfurt change = current VSTOXX value minus its value at premarket start during the premarket hour; VSTOXX value at cash open minus its value at premarket start afterward
Calculation: VSTOXX session change = current VSTOXX value minus its value at cash open
Calculation: VSTOXX change since previous session close = current VSTOXX value minus its value at previous session close
Calculation: Brent percentage change = (current Brent price - Brent price at premarket start) / Brent price at premarket start × 100
Calculation: German 10-year yield change in basis points = (current yield - yield at premarket start) × 100
Calculation: DAX expected change = round(-P6 × VSTOXX session change + P7)
Long: VSTOXX Frankfurt change < 0
Short: VSTOXX Frankfurt change > 0
Long: VSTOXX Frankfurt change < -(P1 + P2)
Long: VSTOXX Frankfurt change >= -(P1 + P2) AND VSTOXX Frankfurt change < -P1
Short: VSTOXX Frankfurt change > P1 AND VSTOXX Frankfurt change <= P1 + P2
Short: VSTOXX Frankfurt change > P1 + P2
Long: VSTOXX Frankfurt change < -P1 AND prior-bar VSTOXX Frankfurt change >= -P1
Short: VSTOXX Frankfurt change > P1 AND prior-bar VSTOXX Frankfurt change <= P1
Long: VSTOXX session change < 0
Short: VSTOXX session change > 0
Long: VSTOXX session change < -P3
Long: VSTOXX session change >= -P3 AND VSTOXX session change < -P4
Long: VSTOXX session change >= -P4 AND VSTOXX session change < -P5
Short: VSTOXX session change > P5 AND VSTOXX session change <= P4
Short: VSTOXX session change > P4 AND VSTOXX session change <= P3
Short: VSTOXX session change > P3
Long: VSTOXX change since previous session close < 0
Short: VSTOXX change since previous session close > 0
Long: Brent percentage change < 0
Short: Brent percentage change > 0
Long: German 10-year yield change in basis points < 0
Short: German 10-year yield change in basis points > 0
Long: DAX expected change > 0
Short: DAX expected change < 0