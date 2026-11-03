Calculation: Weighted price = 3-bar weighted moving average of session VWAP plus HLC3
Calculation: Oscillator = (weighted price − EMA(weighted price, lookback)) / standard deviation(weighted price, same lookback)
Calculation: Long setup = oscillator < −threshold AND oscillator is rising
Calculation: Short setup = oscillator > threshold AND oscillator is falling
Calculation: Long area active = prior bar had a long setup OR prior bar's long area was active; reset when support area ≤ max(open, close) OR a short setup occurs OR prior bar's short-side Fibonacci buying level < close
Calculation: Short area active = prior bar had a short setup OR prior bar's short area was active; reset when resistance area ≥ min(open, close) OR a long setup occurs OR prior bar's long-side Fibonacci selling level > close
Calculation: Support area = while long area is active, prior support area; otherwise max(OHLC4, HLC3, HL2, open, close)
Calculation: Resistance area = while short area is active, prior resistance area; otherwise min(OHLC4, HLC3, HL2, open, close)
Calculation: Long range low = while long area is active, the lower of prior long range low and current low; otherwise current low
Calculation: Short range high = while short area is active, the higher of prior short range high and current high; otherwise current high
Calculation: Range high = while long area is active, support area; while short area is active, short range high; otherwise HLC3
Calculation: Range low = while short area is active, resistance area; while long area is active, long range low; otherwise HLC3
Calculation: Range verified = range high has not changed from prior bar AND range high / range low > 1 + tolerance
Calculation: Fibonacci rate = (close − range low) / (range high − range low)
Calculation: Long-side Fibonacci buying level = 0.763 × (support area − long range low) + long range low
Calculation: Short-side Fibonacci selling level = 0.236 × (short range high − resistance area) + resistance area
Long: (long setup AND long area inactive) OR (long area active AND range verified AND no open position AND Fibonacci rate > 0.236 AND Fibonacci rate < 0.382 AND oscillator is rising)
Short: (short setup AND short area inactive) OR (short area active AND range verified AND no open position AND Fibonacci rate > 0.618 AND Fibonacci rate < 0.764 AND oscillator is falling)
Exit: long, close > entry price + 0.618 × (range high − range low)
Exit: short, close < entry price + 0.382 × (range high − range low)