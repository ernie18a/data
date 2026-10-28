Calculation: Volume SMA = simple moving average of volume over a lookback; use the same lookback for each intraday bar series.
Calculation: SG visit = at least one close below chop low in the recent lookback of that bar series, excluding its current bar.
Calculation: NG visit = at least one close above chop high in the recent lookback of that bar series, excluding its current bar.
Long: On either the faster or slower intraday bar series, close is within [chop low, chop high], close > previous close, SG visit is true, and current volume > its volume SMA × expansion threshold; setup has not already fired since chart close last left the chop zone.
Long: On either intraday bar series, previous close < chop low and current close >= chop low, and preceding volume > the preceding bar's volume SMA × exhaustion threshold and current volume < preceding volume × contraction threshold.
Long: On either intraday bar series, previous close < chop high and current close > chop high, SG visit is true, and current volume > its volume SMA × expansion threshold.
Long: On the faster intraday bar series, previous close < long trigger and current close >= long trigger.
Short: On either the faster or slower intraday bar series, close is within [chop low, chop high], close < previous close, NG visit is true, and current volume > its volume SMA × expansion threshold; setup has not already fired since chart close last left the chop zone.
Short: On either intraday bar series, previous close > chop high and current close <= chop high, NG visit is true, and current volume > its volume SMA × expansion threshold.
Short: On either intraday bar series, previous close > chop low and current close < chop low, NG visit is true, and current volume > its volume SMA × expansion threshold.
Short: On the faster intraday bar series, previous close > short trigger and current close <= short trigger.