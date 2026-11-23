Calculation: Range = high - low
Calculation: BodyPct = abs(close - open) / Range * 100
Calculation: BullWickPct = (min(open, close) - low) / Range * 100
Calculation: BearWickPct = (high - max(open, close)) / Range * 100
Calculation: BullClosePct = (close - low) / Range * 100
Calculation: BearClosePct = (high - close) / Range * 100
Calculation: Part = min(100, volume / SMA(volume, lookback) * part_scale)
Calculation: BullQ = wick_w * BullWickPct + close_w * BullClosePct + part_w * Part + body_w * BodyPct
Calculation: BearQ = wick_w * BearWickPct + close_w * BearClosePct + part_w * Part + body_w * BodyPct
Calculation: Dir = sign(BullQ - BearQ)
Calculation: Strength = max(BullQ, BearQ)
Calculation: Volatility = ATR(atr_len)
Calculation: Move = Momentum(close, follow_len)
Calculation: Hi = Highest(high, lookback)
Calculation: Lo = Lowest(low, lookback)
Calculation: FollowQ = 0 if Dir = 0; min(100, abs(Move) / Volatility * up_scale + up_base) if (Dir = 1 and Move > deadband * Volatility) or (Dir = -1 and Move < -deadband * Volatility); max(0, down_base - abs(Move) / Volatility * down_scale) otherwise
Calculation: Failure = (if Dir > 0 then BearWickPct * abs_wick_w + (100 - BullClosePct) * abs_close_w else if Dir < 0 then BullWickPct * abs_wick_w + (100 - BearClosePct) * abs_close_w else neutral_abs) * fail_abs_w + (100 - FollowQ) * fail_follow_w + (100 - Strength) * fail_strength_w
Calculation: Heat = Strength * heat_strength_w + FollowQ * heat_follow_w + Part * heat_part_w + heat_bound_w * max(0, 100 - abs(close - (if Dir > 0 then Lo else if Dir < 0 then Hi else (Hi + Lo) / 2)) / Volatility * bound_scale)
Calculation: CleanState = Heat >= heat_thr and Failure < fail_thr
Calculation: FollowState = Heat >= heat_thr and FollowQ >= follow_thr and Failure < fail_thr
Calculation: FailedState = Failure >= fail_thr and Heat < heat_thr
Long: ((CleanState and not CleanState[1]) or (FollowState and not FollowState[1])) and Dir >= 0
Short: ((CleanState and not CleanState[1]) or (FollowState and not FollowState[1])) and Dir < 0
Exit: long, (FailedState and not FailedState[1]) and Dir >= 0
Exit: short, (FailedState and not FailedState[1]) and Dir < 0