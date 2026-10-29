Calculation: Ensemble exposure = average of four values, one per SMA with progressively longer lookbacks: clamp((close − SMA) / (ATR × 2 × √(lookback / longest lookback)), 0, 1)
Calculation: Target exposure = the ensemble exposure after the sell-side smoother gate and exposure scaling
Long: Target exposure > previous target exposure
Exit: long, Target exposure < previous target exposure