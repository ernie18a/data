Calculation: Saved long trigger = (close > VWAP AND previous close <= VWAP AND close <= SWMA AND previous close <= SWMA) OR (previous saved long trigger AND close > VWAP)
Long: close > SWMA AND saved long trigger
Calculation: Configured loss distance = reward/risk multiplier × configured profit distance
Exit: Long, high >= entry price + configured profit distance OR low <= entry price − configured loss distance