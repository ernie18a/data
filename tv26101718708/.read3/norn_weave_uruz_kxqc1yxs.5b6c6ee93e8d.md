Calculation: EmaLine = EMA(close, swing period * EMA scale ratio)
Calculation: AdxLine = ADX(ADX period)
Calculation: AdxCutoff = PercentileNearestRank(AdxLine, percentile window, percentile rank) if auto calibration and available, fallback ADX threshold if auto calibration and unavailable, else manual ADX threshold
Calculation: DowTrend = -1 if close < latest non-na PivotLow(low, swing period, swing period), else 1 if close > latest non-na PivotHigh(high, swing period, swing period), else DowTrend[1]
Calculation: RefDeltaSma = SMA(reference buy-minus-sell volume, footprint delta SMA period)
Calculation: VolatilityPct = ATR(volatility ATR period) / close * 100
Calculation: VolatilityRatio = VolatilityPct / SMA(VolatilityPct, volatility baseline period) if that SMA is available and positive, else 1
Calculation: VolatilityAdjustment = min(max(1 - VolatilityRatio, -adjustment limit), adjustment limit)
Calculation: AtrMultiplier = ATR base multiplier + VolatilityAdjustment * ATR sensitivity if auto calibration, else manual ATR multiplier
Calculation: StopLossPct = clamp(raw, most negative stop loss, least negative stop loss) if auto calibration, else manual stop loss, where raw = -stop loss multiplier * SMA(VolatilityPct, stop loss smoothing period), or fallback stop loss if that SMA is unavailable
Calculation: TpDistance = ATR(TP ATR period, longer than volatility ATR period) * AtrMultiplier, evaluated on the entry bar
Calculation: TradeReturn = (close - entry price) / entry price * 100 for a long position, (entry price - close) / entry price * 100 for a short position
Calculation: MaxTradeReturn = max(MaxTradeReturn[1], TradeReturn), 0 on the entry bar
Calculation: MaxUpMove = max(MaxUpMove[1], high - entry price), 0 on the entry bar
Calculation: MaxDownMove = max(MaxDownMove[1], entry price - low), 0 on the entry bar
Long: EmaLine > EmaLine[1] AND DowTrend = 1 AND AdxLine > AdxCutoff AND (footprint filter disabled OR RefDeltaSma is unavailable OR RefDeltaSma > 0)
Short: EmaLine < EmaLine[1] AND DowTrend = -1 AND AdxLine > AdxCutoff AND (footprint filter disabled OR RefDeltaSma is unavailable OR RefDeltaSma < 0)
Exit: Long, TradeReturn < StopLossPct
Exit: Short, TradeReturn < StopLossPct
Exit: Long, BE stop enabled AND MaxTradeReturn >= BE trigger AND low <= entry price
Exit: Short, BE stop enabled AND MaxTradeReturn >= BE trigger AND high >= entry price
Exit: Long, DowTrend = -1
Exit: Short, DowTrend = 1
Exit: Long, MaxUpMove crosses above TP1 multiple * TpDistance
Exit: Long, MaxUpMove crosses above TP2 multiple * TpDistance
Exit: Long, MaxUpMove crosses above TP3 multiple * TpDistance
Exit: Short, MaxDownMove crosses above TP1 multiple * TpDistance
Exit: Short, MaxDownMove crosses above TP2 multiple * TpDistance
Exit: Short, MaxDownMove crosses above TP3 multiple * TpDistance