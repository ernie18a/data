Calculation: ADX = average directional index calculated from directional movement
Calculation: DMI = positive and negative directional indicators calculated from directional movement
Calculation: Volume threshold = selected manual threshold, average volume over a lookback multiplied by a multiplier, or the greater of those two, according to the selected volume filter mode
Calculation: Moving average = selected EMA or SMA of close
Calculation: Lower ATR trail = ratchet low minus ATR times a multiplier upward; reset to low minus ATR times multiplier when the selected price trigger hits it
Calculation: Upper ATR trail = ratchet high plus ATR times a multiplier downward; reset to high plus ATR times multiplier when the selected price trigger hits it
Long: ADX > its value at the longer entry lookback AND ADX > key level AND positive DMI > negative DMI AND time > start time AND time < finish time AND (MA filter disabled OR close >= moving average) AND (volume filter disabled OR volume > volume threshold)
Short: ADX > its value at the longer entry lookback AND ADX > key level AND positive DMI < negative DMI AND time > start time AND time < finish time AND (MA filter disabled OR close <= moving average) AND (short trades enabled) AND (volume filter disabled OR volume > volume threshold)
Exit: long, ADX < its value at the shorter exit lookback OR (ATR stop enabled AND selected price trigger <= lower ATR trail) OR (SAR stop enabled AND selected price trigger <= parabolic SAR)
Exit: short, ADX < its value at the shorter exit lookback OR (ATR stop enabled AND selected price trigger >= upper ATR trail) OR (SAR stop enabled AND selected price trigger >= parabolic SAR)