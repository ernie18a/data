Calculation: VolumeConfirmed = volume > SMA(volume, VOLUME_LEN) * VOLUME_THRESHOLD
Calculation: PivotHigh = high[PIVOT_LEN] if (NOT VOLUME_VALIDATE OR VolumeConfirmed[PIVOT_LEN]) AND high[PIVOT_LEN] > high[i] for every i in [0, 2*PIVOT_LEN] other than PIVOT_LEN, else NA
Calculation: PivotLow = low[PIVOT_LEN] if (NOT VOLUME_VALIDATE OR VolumeConfirmed[PIVOT_LEN]) AND low[PIVOT_LEN] < low[i] for every i in [0, 2*PIVOT_LEN] other than PIVOT_LEN, else NA
Calculation: RefHigh = most recent PivotHigh value, or high if none
Calculation: RefLow = most recent PivotLow value, or low if none
Calculation: AuctionDown = true if close < RefLow, else false if close > RefHigh, else the bar of the most recent PivotLow is later than the bar of the most recent PivotHigh
Calculation: BaseDown = NOT AuctionDown if REVERSE_MAP, else AuctionDown
Calculation: FibRetrace(r) = RefLow + (RefHigh - RefLow) * r if BaseDown, else RefHigh - (RefHigh - RefLow) * r
Calculation: ZoneTop = max(FibRetrace(ZONE_RATIO_1), FibRetrace(ZONE_RATIO_2))
Calculation: ZoneBottom = min(FibRetrace(ZONE_RATIO_1), FibRetrace(ZONE_RATIO_2))
Calculation: ZoneDistance = max(close - ZoneTop, ZoneBottom - close, 0)
Calculation: HigherBarDown = close(T1, last completed bar) < open(T1, last completed bar)
Calculation: TrendEMA = EMA(close, TREND_LEN)
Calculation: ResponseThreshold = ATR(ATR_LEN) * RESPONSE_BUFFER
Long: NOT BaseDown AND ZoneDistance = 0 AND (NOT SHOW_HTF OR NOT REQUIRE_HTF OR AuctionDown = HigherBarDown) AND (NOT USE_TREND_FILTER OR close >= TrendEMA) AND (NOT REQUIRE_VOLUME_SPONSOR OR VolumeConfirmed) AND close >= FibRetrace(MID_RATIO) AND close > open
Long: NOT BaseDown AND close crosses above FibRetrace(MID_RATIO) AND ZoneDistance <= ResponseThreshold AND (NOT USE_TREND_FILTER OR close >= TrendEMA)
Long: NOT BaseDown AND close > RefHigh
Short: BaseDown AND ZoneDistance = 0 AND (NOT SHOW_HTF OR NOT REQUIRE_HTF OR AuctionDown = HigherBarDown) AND (NOT USE_TREND_FILTER OR close <= TrendEMA) AND (NOT REQUIRE_VOLUME_SPONSOR OR VolumeConfirmed) AND close <= FibRetrace(MID_RATIO) AND close < open
Short: BaseDown AND close crosses below FibRetrace(MID_RATIO) AND ZoneDistance <= ResponseThreshold AND (NOT USE_TREND_FILTER OR close <= TrendEMA)
Short: BaseDown AND close < RefLow
Exit: long, NOT BaseDown AND close < RefLow
Exit: short, BaseDown AND close > RefHigh