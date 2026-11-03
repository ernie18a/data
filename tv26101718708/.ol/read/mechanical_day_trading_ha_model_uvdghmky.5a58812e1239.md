Calculation: Heikin Ashi close = (open + high + low + close) / 4
Calculation: Heikin Ashi open = (previous Heikin Ashi open + previous Heikin Ashi close) / 2; initialize with (open + close) / 2
Calculation: Heikin Ashi high = maximum of high, Heikin Ashi open, and Heikin Ashi close
Calculation: Heikin Ashi low = minimum of low, Heikin Ashi open, and Heikin Ashi close
Calculation: Heikin Ashi body = absolute difference between Heikin Ashi close and Heikin Ashi open; Heikin Ashi range = Heikin Ashi high − Heikin Ashi low
Calculation: Daily VWAP = cumulative volume-weighted average of (high + low + close) / 3, reset at the start of each day
Long: position side = flat AND Heikin Ashi close > Heikin Ashi open AND Heikin Ashi body > configured neutral-body percentage of Heikin Ashi range AND short-lookback EMA > medium-lookback EMA AND medium-lookback EMA > long-lookback EMA AND close > short-lookback EMA AND Supertrend direction is bullish AND close > Daily VWAP
Short: position side = flat AND Heikin Ashi close < Heikin Ashi open AND Heikin Ashi body > configured neutral-body percentage of Heikin Ashi range AND short-lookback EMA < medium-lookback EMA AND medium-lookback EMA < long-lookback EMA AND close < short-lookback EMA AND Supertrend direction is bearish AND close < Daily VWAP
Exit: long, Supertrend direction flips bearish OR Heikin Ashi close < Heikin Ashi open OR close crosses below the medium-lookback EMA
Exit: short, Supertrend direction flips bullish OR Heikin Ashi close > Heikin Ashi open OR close crosses above the medium-lookback EMA