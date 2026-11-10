Calculation: Confirmed pivot high = a high greater than or equal to the highs of a configurable number of preceding bars and greater than the highs of the same number of subsequent bars; it is confirmed on the last subsequent bar.
Calculation: Confirmed pivot low = a low less than or equal to the lows of a configurable number of preceding bars and less than the lows of the same number of subsequent bars; it is confirmed on the last subsequent bar.
Calculation: Pivot interval = the number of bars since the previous pivot high or low confirmation, using bar index zero as the previous confirmation index until the first confirmation.
Calculation: Pivot profile range = the highest high minus the lowest low from the confirmed pivot bar back through the bar pivot interval bars earlier, inclusive.
Long: volume > 0 AND close > open
Long: confirmed pivot low exists AND volume > 0 AND pivot interval > 0 AND bar index > pivot interval AND pivot profile range > 0
Short: volume > 0 AND close <= open
Short: confirmed pivot high exists AND volume > 0 AND pivot interval > 0 AND bar index > pivot interval AND pivot profile range > 0