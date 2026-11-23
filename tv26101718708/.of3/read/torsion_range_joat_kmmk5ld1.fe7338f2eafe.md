Calculation: Range = high - low
Calculation: Body = abs(close - open)
Calculation: Impulse balance = SUM(sign(close - close[1]), directional lookback)
Calculation: Pressure average = EMA((signal price - open) / Range, pressure length)
Calculation: Blended score = Impulse balance * impulse weight + Pressure average * score scale * pressure weight
Calculation: Threshold direction(score, threshold) = 1 if score > threshold, -1 if score < -threshold, else 0
Calculation: Method direction = Threshold direction(Impulse balance, impulse threshold) if direction method is impulse, Threshold direction(Pressure average, pressure threshold) if direction method is pressure, otherwise Threshold direction(Blended score, impulse threshold)
Calculation: Direction = Method direction if Method direction != 0, otherwise Direction[1]
Calculation: Energy = (Body * body weight + Range * range weight) * (relative-volume switch is on ? volume / SMA(volume, volume length) : 1) / ATR(ATR length)
Calculation: Accumulator = (Direction != Direction[1] ? 0 : Accumulator[1]) + EMA(Energy, energy smoothing length) * Direction
Calculation: Bars since flip = (Direction != Direction[1] ? 0 : Bars since flip[1]) + 1
Calculation: Core = EMA(clamp(score scale * Accumulator / Highest(abs(Accumulator), normalization lookback), -score scale, score scale), core smoothing length)
Calculation: Absolute core = abs(Core)
Calculation: Upper band = clamp(base band level + EMA(Absolute core, adaptive band length) * expansion band boost * band boost scale, band floor, band ceiling)
Calculation: Stretch = Absolute core - EMA(Absolute core, stretch length)
Calculation: Release side = 1 if Core > EMA(Core, core signal length), -1 if Core < EMA(Core, core signal length), otherwise Direction
Calculation: Fast energy = EMA(Energy, compression fast length)
Calculation: Compression composite = EMA(Range, compression fast length) / EMA(Range, compression slow length) * compression range weight + EMA(Body, compression fast length) / EMA(Body, compression slow length) * compression body weight + Fast energy / EMA(Energy, compression slow length) * compression energy weight
Calculation: Compression score = clamp(compression scale * (compression base - Compression composite), 0, score scale)
Calculation: Compressed = Compression score >= compression threshold
Calculation: Consecutive compressed bars = Compressed ? Consecutive compressed bars[1] + 1 : 0
Calculation: Energy surge = Fast energy - EMA(Fast energy, surge length)
Calculation: Qualified release = (not Compressed AND Compressed[1] AND Consecutive compressed bars[1] >= minimum compression bars) AND abs(Energy surge) >= surge threshold
Calculation: Confirmed-bar gate = bar is closed if confirmed-event mode is on, otherwise true
Long: Confirmed-bar gate AND Direction crosses above 0
Short: Confirmed-bar gate AND Direction crosses below 0
Long: Direction = 1
Short: Direction = -1
Long: Confirmed-bar gate AND Qualified release AND Release side = 1
Short: Confirmed-bar gate AND Qualified release AND Release side = -1
Exit: long, Confirmed-bar gate AND Direction = 1 AND Bars since flip >= minimum wave age AND Core >= Upper band + exhaustion band offset AND Core < Core[1] AND Stretch >= stretch threshold
Exit: short, Confirmed-bar gate AND Direction = -1 AND Bars since flip >= minimum wave age AND Core <= -(Upper band + exhaustion band offset) AND Core > Core[1] AND Stretch >= stretch threshold