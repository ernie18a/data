Calculation: Volume-weighted range = (abs(close - open) in body mode, or high - low in full-range mode) × (volume selected by the volume-type parameter, or 1 in no-volume mode)
Long: close < open AND Volume-weighted range > size parameter
Short: close >= open AND Volume-weighted range > size parameter
Long: source indicator close >= source indicator open AND (source indicator close != 0 OR source indicator open != 0), using the still-forming T1 bar sampled on chart bars
Short: source indicator open > source indicator close AND (source indicator close != 0 OR source indicator open != 0), using the still-forming T1 bar sampled on chart bars