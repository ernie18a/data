Calculation: RMI = 50 − 100 / (1 + INC / DEC), where INC is the EMA of max(close − close[momentum lookback], 0) and DEC is the EMA of max(close[momentum lookback] − close, 0); use 0 when DEC is 0
Calculation: ARMI = the same calculation as RMI, using shorter momentum and EMA lookbacks than RMI
Calculation: RMI lower event close = most recent close when RMI crosses upward through its lower boundary
Calculation: RMI upper event close = most recent close when RMI crosses downward through its upper boundary
Calculation: Force = one-bar change in the simple moving average of close divided by the previous bar’s simple moving average of the selected volume source, scaled by 10,000
Calculation: Fast force = shorter-lookback simple moving average of Force; slow force = longer-lookback simple moving average of Force
Calculation: Bull phase = state set true when fast force crosses above slow force while slow force is below zero; set false when fast force crosses below slow force while slow force is below zero or when bear phase initializes
Calculation: Bear phase = state set true when fast force crosses below slow force while slow force is above zero; set false when fast force crosses above slow force while slow force is above zero or when bull phase initializes
Calculation: Bull exit finalization = the previous bar’s bull exit sweep was falling and bull phase is false; bull exit sweep is true when the rolling average of the bull phase exit condition over the exit lookback is above zero and bull phase is false
Calculation: Bear exit finalization = the previous bar’s bear exit sweep was falling and bear phase is false; bear exit sweep is true when the rolling average of the bear phase exit condition over the exit lookback is above zero and bear phase is false
Long: ARMI is below its lower boundary AND close is below the RMI lower event close
Long: ARMI is below its lower boundary AND RMI is below its lower boundary AND bull phase is true
Short: ARMI is above its upper boundary AND close is above the RMI upper event close
Short: ARMI is above its upper boundary AND RMI is above its upper boundary AND bear phase is true
Exit: short, bull exit finalization is true
Exit: long, bear exit finalization is true