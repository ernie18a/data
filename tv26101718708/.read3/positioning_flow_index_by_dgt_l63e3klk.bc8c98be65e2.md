Calculation: Price Z-score = Z-score(log(close / close[1]), PFI lookback), or 0 when its standard deviation is 0
Calculation: Open Interest Z-score = Z-score(log(Open Interest / Open Interest[1]), PFI lookback), or 0 when its standard deviation is 0
Calculation: Flow State = Neutral if Open Interest is unavailable or either absolute Z-score is below the minimum state Z-score; otherwise Long Buildup if close rises and Open Interest rises, Short Buildup if close falls and Open Interest rises, Short Covering if close rises and Open Interest falls, or Long Unwinding if close falls and Open Interest falls
Calculation: Signal Strength = sqrt(min(abs(Open Interest Z-score), 2) / 2 × min(abs(Price Z-score), 2) / 2)
Calculation: Positioning Flow Index = EMA(100 × tanh(clamp(Flow, -20, 20)), PFI smoothing), where Flow is selected from: OI Z-score × sign(log(close / close[1])); OI Z-score × Price Z-score; or sign(log(close / close[1])) × abs(OI Z-score) × min(abs(Price Z-score), 1)
Long: Open Interest is available AND Positioning Flow Index >= 0
Short: Open Interest is available AND Positioning Flow Index < 0
Long: Flow State is Long Buildup or Short Covering
Short: Flow State is Short Buildup or Long Unwinding
Long: Flow State changes to Long Buildup or Short Covering AND Signal Strength >= minimum marker strength, on a confirmed bar close or provisionally while the bar is forming
Short: Flow State changes to Short Buildup or Long Unwinding AND Signal Strength >= minimum marker strength, on a confirmed bar close or provisionally while the bar is forming
Long: A confirmed pivot low using the pivot length on each side is lower than the previous confirmed pivot low AND Open Interest at that pivot is lower than Open Interest at the previous confirmed pivot low
Short: A confirmed pivot high using the pivot length on each side is higher than the previous confirmed pivot high AND Open Interest at that pivot is lower than Open Interest at the previous confirmed pivot high