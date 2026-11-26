Calculation: ZScore(x) = clamp((x - SMA(x, NORM_LEN)) / STDEV(x, NORM_LEN), -Z_CLAMP, Z_CLAMP)
Calculation: MomentumDriver = ZScore((EMA(close, MOM_LEN) - EMA(close, SLOW_MULT * MOM_LEN)) / ATR(ATR_LEN))
Calculation: VolatilityDriver = ZScore(ATR(VOLA_LEN) / SMA(ATR(VOLA_LEN), NORM_LEN) - 1)
Calculation: VolumeDriver = ZScore(volume / SMA(volume, VOL_LEN) - 1)
Calculation: RangeDriver = ZScore((high - low) / SMA(high - low, RANGE_LEN) - 1)
Calculation: BarReturn = (close - close[1]) / close[1]
Calculation: GrangerLift(d) = max(0, abs(Correlation(d[LAG], BarReturn, WINDOW)) - BASE_WEIGHT * abs(Correlation(BarReturn[LAG], BarReturn, WINDOW))), for each driver d
Calculation: NetOutput = tanh(b2 + sum over h in 1..HIDDEN of W2[h] * tanh(b1[h] + sum over d of W1[h,d] * x_d)), where x_d is driver d at the current bar; weights start from pseudo-random values seeded by SEED and are trained online: at each closed bar the pair (x at the previous closed bar, Target at the current closed bar) is added to a buffer keeping the latest BUFFER pairs, then STEPS stochastic gradient steps on squared error (rate LEARN_RATE) use pseudo-randomly drawn pairs from the buffer; Target = clamp((close - close[OUTCOME]) / ATR(ATR_LEN), -1, 1)
Calculation: Importance(d) = abs(NetOutput - NetOutput with x_d set to 0), for each driver d
Calculation: DominantLift = GrangerLift(d*), where d* is the driver with the largest Importance(d)
Calculation: TopShare = largest Importance(d) / sum of Importance(d) over all drivers d
Calculation: BlendedConfidence = max(0, min(1, BLEND * min(1, DominantLift / (LIFT_SCALE * MIN_LIFT)) + (1 - BLEND) * min(1, (TopShare - SHARE_OFFSET) / SHARE_SCALE)))
Calculation: CausalConfidence = EMA(BlendedConfidence, SMOOTH)
Calculation: CausalDirection = (1 if NetOutput > DIR_THRESHOLD, -1 if NetOutput < -DIR_THRESHOLD, else 0) if CausalConfidence >= CONF_GATE, else 0
Calculation: PrevNonzeroDirection = most recent nonzero CausalDirection on an earlier bar, or 0 if none
Long: CausalDirection = 1
Long: CausalDirection = 1 AND PrevNonzeroDirection != 1
Short: CausalDirection = -1
Short: CausalDirection = -1 AND PrevNonzeroDirection != -1
Long: CausalConfidence > GLOW_MULT * CONF_GATE AND NetOutput >= -DIR_THRESHOLD
Short: CausalConfidence > GLOW_MULT * CONF_GATE AND NetOutput < -DIR_THRESHOLD