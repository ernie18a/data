Calculation: Close location = (close - low) / (high - low); classify as upper, middle, or lower close location
Calculation: Spread class = narrow, average, or wide, classified relative to average spread
Calculation: Volume class = low, average, high, or extreme, classified relative to average volume and volume standard deviation
Calculation: Local high/low = current bar's high/low equals the highest/lowest value in a rolling lookback window
Long: (Spread class is narrow or average) AND (close location is middle or upper) AND volume class is low AND current volume < previous bar volume AND previous bar volume < volume two bars earlier AND current close < previous bar close
Long: (Spread class is narrow or average) AND close location is upper AND volume class is extreme AND current bar is a local low
Long: close location is upper AND volume class is low
Long: (Spread class is wide or average) AND close location is upper AND current close > previous bar close AND current volume > previous bar volume AND current volume > volume two bars earlier
Long: close location is upper AND (volume class is high or extreme) AND current close < previous bar close
Long: Spread class is wide AND close location is upper AND current bar is a local low AND (volume class is high or extreme)
Long: Previous bar close location is middle or upper AND previous bar close < close two bars earlier AND previous bar volume is at least its average volume plus one standard deviation AND current close > previous bar close
Long: Spread class is wide AND close location is lower
Short: (Spread class is narrow or average) AND current close > previous bar close AND volume class is low
Short: Spread class is wide AND current close < previous bar close AND close location is lower AND volume class is low
Short: (Spread class is narrow or average) AND volume class is extreme AND close location is upper AND current bar is a local high
Short: (Spread class is narrow or average) AND current close > previous bar close AND volume class is low
Short: Previous bar close > close two bars earlier AND previous bar volume is at least its average volume plus one standard deviation AND previous bar is a local high AND current close <= previous bar close
Short: (Spread class is wide or average) AND current close < previous bar close AND current volume > previous bar volume AND current volume > volume two bars earlier AND close location is lower
Short: Previous bar volume is at least its average volume plus one standard deviation AND previous bar close location is middle or lower AND (current close < previous bar close OR (Spread class is narrow AND current close > previous bar close))
Short: Spread class is wide AND close location is lower