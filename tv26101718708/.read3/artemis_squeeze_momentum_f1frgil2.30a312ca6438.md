Calculation: MOM = LinearRegression((close - avg(avg(Highest(high, momentum length), Lowest(low, momentum length)), SMA(avg(high, low), momentum length))) / max(Highest(high, momentum length) - Lowest(low, momentum length), abs(Highest(high, momentum length) - close[1]), abs(Lowest(low, momentum length) - close[1])), momentum length, 0), on chart bars
Calculation: MTF_MOM(T) = MOM formula on bars of T, read at the last completed bar of T
Calculation: SIGNAL = SMA(MOM, signal length), where signal length is shorter than momentum length
Calculation: FLUX = RMA((UP - DN) / (UP + DN), flux smoothing length), where UP = RMA(max(high - high[1], 0), flux length), DN = RMA(max(low[1] - low, 0), flux length), on Heikin-Ashi bars if Heikin-Ashi flux is on and chart bars otherwise, where flux smoothing length is shorter than flux length
Calculation: SQUEEZE_LOOSE = sample STDEV(close, momentum length) < ATR(momentum length) * max(tight multiplier, mid multiplier, loose multiplier) * sqrt(momentum length / calibration length)
Calculation: ACTIVE_THRESHOLD = max(1, confluence threshold + (trending offset if ADX(ADX length) > trend threshold, else ranging offset if ADX(ADX length) < range threshold, else 0))
Calculation: VOLUME_PASS = volume filter is off OR volume > SMA(volume, volume MA length) OR NOT (volume > 0 AND SMA(volume, volume MA length) > 0)
Calculation: MTF_BULL = T1 >= chart timeframe AND MTF_MOM(T1) > 0 AND T2 >= chart timeframe AND MTF_MOM(T2) > 0 AND T3 >= chart timeframe AND MTF_MOM(T3) > 0 AND T4 >= chart timeframe AND MTF_MOM(T4) > 0
Calculation: MTF_BEAR = T1 >= chart timeframe AND MTF_MOM(T1) < 0 AND T2 >= chart timeframe AND MTF_MOM(T2) < 0 AND T3 >= chart timeframe AND MTF_MOM(T3) < 0 AND T4 >= chart timeframe AND MTF_MOM(T4) < 0
Calculation: MTF_DIV = (MOM > 0 AND at least contrarian HTF count of T1, T2, T3, T4 satisfy (Ti >= chart timeframe AND MTF_MOM(Ti) < 0)) OR (MOM < 0 AND at least contrarian HTF count of T1, T2, T3, T4 satisfy (Ti >= chart timeframe AND MTF_MOM(Ti) > 0))
Calculation: REG_BULL_SETUP = MOM < -divergence sensitivity AND MOM crosses above SIGNAL AND bar confirmed
Calculation: REG_BEAR_SETUP = MOM > divergence sensitivity AND MOM crosses below SIGNAL AND bar confirmed
Calculation: HID_BULL_SETUP = MOM crosses above SIGNAL AND bar confirmed
Calculation: HID_BEAR_SETUP = MOM crosses below SIGNAL AND bar confirmed
Calculation: MIN_PRICE_SWING = min price swing percent / 100 * (Highest(high, range window length) - Lowest(low, range window length))
Calculation: SMART_BULL(P) = smart filter is off OR (abs(SIGNAL - P.signal) >= min momentum swing AND abs(low - P.price) >= MIN_PRICE_SWING AND (flux confirmation is off OR FLUX > 0))
Calculation: SMART_BEAR(P) = smart filter is off OR (abs(SIGNAL - P.signal) >= min momentum swing AND abs(high - P.price) >= MIN_PRICE_SWING AND (flux confirmation is off OR FLUX < 0))
Calculation: REG_BULL_PIVOT = (price = low, signal = SIGNAL) at the latest earlier bar where REG_BULL_SETUP is true, if REG_BULL_DIV is false on that bar, otherwise none
Calculation: REG_BEAR_PIVOT = (price = high, signal = SIGNAL) at the latest earlier bar where REG_BEAR_SETUP is true, if REG_BEAR_DIV is false on that bar, otherwise none
Calculation: HID_BULL_PIVOT = (price = low, signal = SIGNAL) at the latest earlier bar where HID_BULL_SETUP is true, if HID_BULL_DIV is false on that bar, otherwise none
Calculation: HID_BEAR_PIVOT = (price = high, signal = SIGNAL) at the latest earlier bar where HID_BEAR_SETUP is true, if HID_BEAR_DIV is false on that bar, otherwise none
Calculation: REG_BULL_DIV = REG_BULL_SETUP AND REG_BULL_PIVOT exists AND low < REG_BULL_PIVOT.price AND SIGNAL > REG_BULL_PIVOT.signal AND SMART_BULL(REG_BULL_PIVOT)
Calculation: REG_BEAR_DIV = REG_BEAR_SETUP AND REG_BEAR_PIVOT exists AND high > REG_BEAR_PIVOT.price AND SIGNAL < REG_BEAR_PIVOT.signal AND SMART_BEAR(REG_BEAR_PIVOT)
Calculation: HID_BULL_DIV = HID_BULL_SETUP AND HID_BULL_PIVOT exists AND low > HID_BULL_PIVOT.price AND SIGNAL < HID_BULL_PIVOT.signal AND SMART_BULL(HID_BULL_PIVOT)
Calculation: HID_BEAR_DIV = HID_BEAR_SETUP AND HID_BEAR_PIVOT exists AND high < HID_BEAR_PIVOT.price AND SIGNAL > HID_BEAR_PIVOT.signal AND SMART_BEAR(HID_BEAR_PIVOT)
Long: MOM crosses above SIGNAL AND MOM < -ACTIVE_THRESHOLD AND FLUX < 0 AND VOLUME_PASS
Short: MOM crosses below SIGNAL AND MOM > ACTIVE_THRESHOLD AND FLUX > 0 AND VOLUME_PASS
Long: MOM crosses above SIGNAL
Short: MOM crosses below SIGNAL
Long: MOM crosses above 0
Short: MOM crosses below 0
Long: FLUX crosses above 0
Short: FLUX crosses below 0
Long: MOM > 0 AND FLUX > 0 AND NOT (MOM[1] > 0 AND FLUX[1] > 0)
Short: MOM < 0 AND FLUX < 0 AND NOT (MOM[1] < 0 AND FLUX[1] < 0)
Long: MOM > 0 AND FLUX <= 0 AND NOT (MOM[1] > 0 AND FLUX[1] <= 0)
Short: MOM < 0 AND FLUX >= 0 AND NOT (MOM[1] < 0 AND FLUX[1] >= 0)
Long: SQUEEZE_LOOSE[1] AND NOT SQUEEZE_LOOSE AND direction predictor is on AND MOM - MOM[predictor lookback] > predictor threshold
Short: SQUEEZE_LOOSE[1] AND NOT SQUEEZE_LOOSE AND direction predictor is on AND MOM - MOM[predictor lookback] < -predictor threshold
Long: MTF_BULL AND NOT (MTF_BULL[1] OR MTF_BEAR[1])
Short: MTF_BEAR AND NOT (MTF_BULL[1] OR MTF_BEAR[1])
Long: MOM > 0
Short: MOM < 0
Long: MOM > SIGNAL
Short: MOM < SIGNAL
Long: FLUX > 0
Short: FLUX < 0
Long: ADX(ADX length) > trend threshold AND PLUS_DI(ADX length) > MINUS_DI(ADX length)
Short: ADX(ADX length) > trend threshold AND PLUS_DI(ADX length) <= MINUS_DI(ADX length)
Exit: long, MTF_DIV AND MOM > 0 AND NOT MTF_DIV[1]
Exit: short, MTF_DIV AND MOM < 0 AND NOT MTF_DIV[1]
Long: REG_BULL_DIV
Short: REG_BEAR_DIV
Long: HID_BULL_DIV
Short: HID_BEAR_DIV