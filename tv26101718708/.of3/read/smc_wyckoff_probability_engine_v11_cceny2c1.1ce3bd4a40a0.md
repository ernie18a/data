Calculation: upward BOS = close crosses above the latest confirmed PivotHigh(high, pivot lookback, pivot lookback) AND close − pivot high >= ATR(ATR lookback) × displacement parameter
Calculation: downward BOS = close crosses below the latest confirmed PivotLow(low, pivot lookback, pivot lookback) AND pivot low − close >= ATR(ATR lookback) × displacement parameter
Calculation: structure bias = direction of the latest upward or downward BOS, or neutral before the first BOS
Calculation: T1 bias = on chart bars, using the last completed T1 bar, bullish if its close > EMA(close, T1 EMA lookback) and that EMA > its value one completed T1 bar earlier; bearish if both comparisons are reversed; otherwise neutral
Calculation: Wyckoff phase = Accumulation if ADX(DMI lookback, DMI lookback) < range ADX threshold AND Bollinger Band Width(close, Bollinger lookback) < SMA(Bollinger Band Width(close, Bollinger lookback), width smoothing lookback) AND (close − Lowest(low, range-position lookback)) / (Highest(high, range-position lookback) − Lowest(low, range-position lookback)) × 100 < lower range-position threshold; Distribution if the same range conditions hold and range position > upper range-position threshold; Markup if ADX >= trend ADX threshold AND DI+ > DI−; Markdown if ADX >= trend ADX threshold AND DI− > DI+; otherwise Transition
Calculation: premium-discount zone = using the configured method, midpoint of latest confirmed pivot high and low or midpoint of Highest(high, discount range lookback) and Lowest(low, discount range lookback); Premium if close > midpoint, otherwise Discount, when midpoint is available
Calculation: high liquidity sweep = high > Highest(high, sweep lookback)[1] AND close < Highest(high, sweep lookback)[1]
Calculation: low liquidity sweep = low < Lowest(low, sweep lookback)[1] AND close > Lowest(low, sweep lookback)[1]
Calculation: high-sweep reversal rate = 100 × cumulative high sweeps reversed within the evaluation window by low <= sweep high − ATR(ATR lookback) × reversal magnitude / cumulative high sweeps
Calculation: low-sweep reversal rate = 100 × cumulative low sweeps reversed within the evaluation window by high >= sweep low + ATR(ATR lookback) × reversal magnitude / cumulative low sweeps
Calculation: recent high sweep = a high liquidity sweep occurred fewer than the recent-sweep window bars ago
Calculation: recent low sweep = a low liquidity sweep occurred fewer than the recent-sweep window bars ago
Calculation: bullish FVG = low > high[2] AND low − high[2] > ATR(ATR lookback) × minimum FVG size
Calculation: bearish FVG = high < low[2] AND low[2] − high > ATR(ATR lookback) × minimum FVG size
Calculation: bullish FVG fill rate = 100 × filled bullish FVGs / retained bullish FVGs, retaining up to FVG statistics capacity; a bullish FVG fills when low <= its high[2] edge
Calculation: bearish FVG fill rate = 100 × filled bearish FVGs / retained bearish FVGs, retaining up to FVG statistics capacity; a bearish FVG fills when high >= its low[2] edge
Calculation: unfilled bullish FVG below close = an unfilled bullish FVG edge < close
Calculation: unfilled bearish FVG above close = an unfilled bearish FVG edge > close
Calculation: normalized probabilities = normalize each component after clamping it to [0,100]: base up/down/chop probabilities; add (structure bonus, −structure penalty, −structure chop penalty) for bullish structure bias and the mirrored tuple for bearish bias; when the HTF gate is enabled, add (HTF bonus, −HTF penalty, −HTF penalty) for bullish T1 bias and the mirrored tuple for bearish bias; add (phase trend bonus, −phase trend penalty, −phase chop penalty) for Markup and the mirrored tuple for Markdown; add (range phase bonus, 0, −range phase chop penalty) for Accumulation and the mirrored tuple for Distribution; add (−transition penalty, −transition penalty, transition bonus) for Transition; add (discount bonus, −zone penalty, −zone penalty) for Discount and the mirrored tuple for Premium; for each recent high sweep add (−sweep penalty × high-sweep reversal rate / 100, sweep bonus × rate / 100, −sweep penalty × rate / 100), and for each recent low sweep add the mirrored tuple; if an unfilled bullish FVG is below close and its fill rate > FVG rate gate, let f = min((rate − gate) / FVG rate scale, FVG factor cap) and add (−FVG probability penalty × f, FVG probability bonus × f, −FVG chop penalty × f); apply the mirrored tuple for an unfilled bearish FVG above close using its fill rate
Calculation: setup direction = long if normalized up probability > normalized down probability + direction margin; short if normalized down probability > normalized up probability + direction margin; otherwise neutral
Calculation: long setup score = 0 unless setup direction is long; otherwise sum the HTF score if the HTF gate is enabled and T1 bias is bullish, structure score if structure bias is bullish, phase score if phase is Markup or Accumulation, zone score if zone is Discount, sweep score if a recent low sweep occurred, probability score if normalized up probability >= probability score threshold, and historical success score if low-sweep reversal rate > sweep score threshold OR bearish FVG fill rate > FVG score threshold
Calculation: short setup score = 0 unless setup direction is short; otherwise sum the HTF score if the HTF gate is enabled and T1 bias is bearish, structure score if structure bias is bearish, phase score if phase is Markdown or Distribution, zone score if zone is Premium, sweep score if a recent high sweep occurred, probability score if normalized down probability >= probability score threshold, and historical success score if high-sweep reversal rate > sweep score threshold OR bullish FVG fill rate > FVG score threshold
Long: upward BOS
Short: downward BOS
Long: upward BOS AND a bearish candle occurs within the preceding OB lookback bars
Short: downward BOS AND a bullish candle occurs within the preceding OB lookback bars
Long: structure bias is bullish
Short: structure bias is bearish
Long: HTF gate enabled AND T1 bias is bullish
Short: HTF gate enabled AND T1 bias is bearish
Long: Wyckoff phase is Markup
Short: Wyckoff phase is Markdown
Long: low liquidity sweep
Short: high liquidity sweep
Long: bullish FVG
Short: bearish FVG
Long: setup direction is long
Short: setup direction is short
Long: setup direction is long AND long setup score >= top-grade threshold
Short: setup direction is short AND short setup score >= top-grade threshold
Long: setup direction is long AND lower-grade threshold <= long setup score < top-grade threshold
Short: setup direction is short AND lower-grade threshold <= short setup score < top-grade threshold