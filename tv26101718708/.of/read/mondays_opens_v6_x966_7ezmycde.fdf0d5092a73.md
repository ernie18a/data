Calculation: Monday high and Monday low = the highest high and lowest low of Monday chart bars in the current exchange-time week; unavailable until a Monday bar occurs and reset at the start of each week.
Calculation: Each sweep latch starts clear each week and is set when its corresponding sweep decision occurs. Clear the high-sweep latch when high < Monday high; clear the low-sweep latch when low > Monday low.
Calculation: Each acceptance latch starts clear each week and is set when its corresponding acceptance decision occurs. Clear both acceptance latches when close >= Monday low AND close <= Monday high.
Long: After Monday in the current week AND low < Monday low AND close >= Monday low AND (sweep latch disabled OR low-sweep latch clear).
Long: After Monday in the current week AND close > Monday high AND (acceptance latch disabled OR upper-acceptance latch clear).
Short: After Monday in the current week AND high > Monday high AND close <= Monday high AND (sweep latch disabled OR high-sweep latch clear).
Short: After Monday in the current week AND close < Monday low AND (acceptance latch disabled OR lower-acceptance latch clear).