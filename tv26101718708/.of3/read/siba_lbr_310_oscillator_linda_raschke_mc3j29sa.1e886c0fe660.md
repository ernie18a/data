Calculation: Osc = APO(close, shorter lookback, longer lookback, SMA)
Calculation: OscSig = SMA(Osc, signal lookback)
Calculation: HtfSig = SMA(APO(close, shorter lookback, longer lookback, SMA), signal lookback, T1, last completed bar)
Calculation: Band = band multiplier * StdDev(Osc, band lookback)
Calculation: DownStreak = if Osc < Osc[1] then DownStreak[1] + 1 else 0
Calculation: UpStreak = if Osc > Osc[1] then UpStreak[1] + 1 else 0
Long: OscSig crosses above 0
Long: Osc crosses above OscSig AND OscSig > 0 AND (HTF filter disabled OR HtfSig > 0) AND (strict first cross disabled OR no earlier Long from this condition on or after the most recent OscSig cross above 0)
Long: Osc > Osc[1] AND OscSig > OscSig[1] AND DownStreak[1] >= min pullback bars AND (HTF filter disabled OR HtfSig > 0)
Long: Osc[1] < -Band[1] AND Osc > Osc[1]
Long: PivotLow(Osc, left lookback, right lookback) occurs AND Osc[right lookback] > ValueWhen(PivotLow occurs, Osc[right lookback], 1) AND min bars between pivots <= BarsSince(PivotLow occurs[1]) <= max bars between pivots AND Low[right lookback] < ValueWhen(PivotLow occurs, Low[right lookback], 1)
Long: OscSig > 0
Long: Osc >= OscSig
Short: OscSig crosses below 0
Short: Osc crosses below OscSig AND OscSig < 0 AND (HTF filter disabled OR HtfSig < 0) AND (strict first cross disabled OR no earlier Short from this condition on or after the most recent OscSig cross below 0)
Short: Osc < Osc[1] AND OscSig < OscSig[1] AND UpStreak[1] >= min pullback bars AND (HTF filter disabled OR HtfSig < 0)
Short: Osc[1] > Band[1] AND Osc < Osc[1]
Short: PivotHigh(Osc, left lookback, right lookback) occurs AND Osc[right lookback] < ValueWhen(PivotHigh occurs, Osc[right lookback], 1) AND min bars between pivots <= BarsSince(PivotHigh occurs[1]) <= max bars between pivots AND High[right lookback] > ValueWhen(PivotHigh occurs, High[right lookback], 1)
Short: OscSig < 0
Short: Osc < OscSig