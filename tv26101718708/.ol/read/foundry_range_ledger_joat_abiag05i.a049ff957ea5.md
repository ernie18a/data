Calculation: Confirmed pivot high/low = a high/low that is an extreme over the configured number of chart bars before and after it; knowable after the bars after it complete.
Calculation: Active supply zone = the latest confirmed pivot high, or the average of it and the previous pivot high when their distance is within the ATR-based cluster tolerance; zone extends downward from that anchor by an ATR-based width. Replace it on each new confirmed pivot high.
Calculation: Active demand zone = the latest confirmed pivot low, or the average of it and the previous pivot low when their distance is within the ATR-based cluster tolerance; zone extends upward from that anchor by an ATR-based width. Replace it on each new confirmed pivot low.
Calculation: Break body quality = abs(close - open) / max(high - low, minimum tick size).
Long: confirmed pivot low
Long: active demand zone AND high >= demand zone bottom AND low <= demand zone top
Long: active supply zone AND bar is confirmed AND zone age >= minimum zone age AND (close > supply zone top when body-close breaks are enabled, otherwise high > supply zone top) AND (body quality >= minimum threshold when the body quality filter is enabled)
Long: supply zone is inactive after an upper break AND low <= supply zone top AND close >= supply zone bottom
Short: confirmed pivot high
Short: active supply zone AND high >= supply zone bottom AND low <= supply zone top
Short: active demand zone AND bar is confirmed AND zone age >= minimum zone age AND (close < demand zone bottom when body-close breaks are enabled, otherwise low < demand zone bottom) AND (body quality >= minimum threshold when the body quality filter is enabled)
Short: demand zone is inactive after a lower break AND high >= demand zone bottom AND close <= demand zone top