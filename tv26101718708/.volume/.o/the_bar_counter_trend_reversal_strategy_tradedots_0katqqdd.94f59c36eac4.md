Calculation: N-bar falling = current close < each of the prior N closes
Calculation: N-bar rising = current close > each of the prior N closes
Calculation: Long-signal flag = set true on a long signal; reset to false when close > prior close
Calculation: Short-signal flag = set true on a short signal; reset to false when close < prior close
Long: N-bar falling using the configured fall count AND (volume confirmation disabled OR current volume > each of the prior fall-count volumes) AND (channel confirmation disabled OR low < lower line of the selected Bollinger Bands or Keltner Channel) AND long-signal flag = false
Short: N-bar rising using the configured rise count AND (volume confirmation disabled OR current volume > each of the prior rise-count volumes) AND (channel confirmation disabled OR high > upper line of the selected Bollinger Bands or Keltner Channel) AND short-signal flag = false
Exit: short, Long condition
Exit: long, Short condition