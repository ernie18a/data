Calculation: Range = high − low
Calculation: Body = close − open
Calculation: Body ratio = ABS(Body) / Range
Calculation: Upper wick ratio = (high − MAX(open, close)) / Range
Calculation: Lower wick ratio = (MIN(open, close) − low) / Range
Calculation: Close location = ((close − low) − (high − close)) / Range
Calculation: Bull context = close > EMA(source, baseline lookback) AND EMA(source, baseline lookback) > EMA(source, baseline lookback)[1]
Calculation: Bear context = close < EMA(source, baseline lookback) AND EMA(source, baseline lookback) < EMA(source, baseline lookback)[1]
Calculation: Z-score(x, n) = (x − SMA(x, n)) / STDEV(x, n)
Calculation: Relative volume = volume / SMA(volume, volume lookback)
Calculation: Result = tanh(clamp(result scale × Body / ATR(range lookback), −result limit, result limit))
Calculation: Pressure = EMA(pressure scale × (effort weight × Body / Range + result weight × Result + location weight × clamp(Close location + wick weight × (Lower wick ratio − Upper wick ratio), −location limit, location limit)) × Relative volume, smoothing shorter lookback)
Calculation: Pressure signal = EMA(Pressure, smoothing longer lookback)
Calculation: Drive quality = participation weight × clamp(Z-score(Relative volume, range lookback), −participation limit, participation limit) × participation scale + location quality weight × Close location × location quality scale + efficiency weight × Result × efficiency scale
Long: bar is closed AND Pressure > drive threshold AND Pressure > Pressure signal AND Close location > 0 AND NOT Bear context
Long: bar is closed AND Z-score(volume, volume lookback) > absorption volume z threshold AND Lower wick ratio > Upper wick ratio AND Body ratio < absorption range cap AND Close location > absorption close location threshold AND Pressure > 0 AND NOT Bear context
Long: bar is closed AND Pressure crosses above Pressure signal
Long: bar is closed AND Drive quality crosses above 0
Short: bar is closed AND Pressure < −drive threshold AND Pressure < Pressure signal AND Close location < 0 AND NOT Bull context
Short: bar is closed AND Z-score(volume, volume lookback) > absorption volume z threshold AND Upper wick ratio > Lower wick ratio AND Body ratio < absorption range cap AND Close location < −absorption close location threshold AND Pressure < 0 AND NOT Bull context
Short: bar is closed AND Pressure crosses below Pressure signal
Short: bar is closed AND Drive quality crosses below 0
Exit: long, bar is closed AND HIGHEST(Pressure, exhaustion lookback) > drive threshold AND Pressure > drive threshold × exhaustion threshold fraction AND Pressure < HIGHEST(Pressure, exhaustion lookback) × exhaustion retrace fraction AND EMA(Body, momentum shorter lookback) − EMA(Body, momentum longer lookback) < 0 AND Close location < exhaustion close location threshold
Exit: short, bar is closed AND LOWEST(Pressure, exhaustion lookback) < −drive threshold AND Pressure < −drive threshold × exhaustion threshold fraction AND Pressure > LOWEST(Pressure, exhaustion lookback) × exhaustion retrace fraction AND EMA(Body, momentum shorter lookback) − EMA(Body, momentum longer lookback) > 0 AND Close location > −exhaustion close location threshold