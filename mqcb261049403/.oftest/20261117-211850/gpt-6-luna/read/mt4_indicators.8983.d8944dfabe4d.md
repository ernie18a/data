Calculation: prior average spread = sum of the ranges of the preceding spread-lookback bars divided by (spread-lookback minus one)
Calculation: wide spread = current bar range is at least the wide-spread multiple of prior average spread
Calculation: narrow spread = current bar range is at most the narrow-spread multiple of prior average spread
Calculation: prior average volume = sum of the volumes of the preceding volume-lookback bars divided by (volume-lookback minus one)
Calculation: high volume = current bar volume is at least prior average volume
Calculation: low volume = current bar volume is less than prior average volume
Calculation: down close = current bar close is at or below its low plus its range times the close-zone fraction
Calculation: up close = current bar close is at or above its high minus its range times the close-zone fraction
Calculation: mid close = current bar close is above its low plus its range times the close-zone fraction and below its high minus its range times the close-zone fraction
Short: wide spread AND high volume AND down close AND previous bar close > the close of the bar before it AND current bar high > previous bar high
Short: narrow spread AND (low volume OR current bar volume < previous bar volume) AND (down close OR mid close) AND current bar close > previous bar close
Long: high volume AND up close AND current bar close < previous bar close
Long: wide spread AND high volume AND up close AND current bar close > previous bar close AND current bar low < previous bar low
Long: narrow spread AND low volume AND down close AND current bar close < previous bar close
Long: wide spread AND current bar close > previous bar close AND up close AND (high volume OR current bar volume > previous bar volume)
Short: wide spread AND current bar close < previous bar close AND down close AND (high volume OR current bar volume > previous bar volume)