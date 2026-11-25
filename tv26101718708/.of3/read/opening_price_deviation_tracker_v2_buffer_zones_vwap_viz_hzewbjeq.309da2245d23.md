Calculation: PeriodOpen = open of the T1 bar still forming, taken on chart bars
Calculation: Level(k) = PeriodOpen * (1 + k * Step / 100), for signed integer k
Calculation: FirstReach(k) = current chart bar is the first chart bar of the current T1 period where high >= Level(k) when k > 0, or low <= Level(k) when k < 0
Calculation: Delta(T) = (close - O) / O * 100, where O = open of the T bar still forming, taken on chart bars
Calculation: RangeShare(T) = (close - Lo) / (Hi - Lo) * 100, where Hi and Lo = running high and low of the T bar still forming, taken on chart bars; 50 when Hi = Lo
Calculation: Bias(T) = clip(Delta(T) / Step, -3, 3) + 1.5 * (RangeShare(T) - 50) / 50
Calculation: CumVolume = running sum of volume from the first chart bar
Calculation: InnerUpper = smallest of VWAP(hlc3, T5) + m_j * sigma over j in {1, 2} with m_j > 0, or NA if none; in percentage mode the term is VWAP(hlc3, T5) * (1 + m_j / 100); sigma = volume-weighted standard deviation of hlc3 around VWAP(hlc3, T5) since the last T5 boundary
Calculation: InnerLower = largest of VWAP(hlc3, T5) - m_j * sigma over j in {1, 2} with m_j > 0, or NA if none; in percentage mode the term is VWAP(hlc3, T5) * (1 - m_j / 100); sigma as in InnerUpper
Long: close > Level(1)
Short: close < Level(-1)
Long: T5 is longer than the chart timeframe AND CumVolume > 0 AND close > InnerUpper
Long: T5 is longer than the chart timeframe AND CumVolume > 0 AND InnerUpper is NA AND close >= VWAP(hlc3, T5)
Short: T5 is longer than the chart timeframe AND CumVolume > 0 AND close < InnerLower
Short: T5 is longer than the chart timeframe AND CumVolume > 0 AND InnerLower is NA AND close < VWAP(hlc3, T5)
Long: for some k from 1 to MaxK, FirstReach(k) AND low <= Level(k) AND close > Level(k)
Long: for some k from 1 to MaxK, FirstReach(-k) AND close - Level(-k) >= RejectShare * (high - low)
Short: for some k from 1 to MaxK, FirstReach(-k) AND high >= Level(-k) AND close < Level(-k)
Short: for some k from 1 to MaxK, FirstReach(k) AND Level(k) - close >= RejectShare * (high - low)
Long: T2 is at least the chart timeframe AND Delta(T2) >= 0
Long: T2 is at least the chart timeframe AND Delta(T2) >= Step
Long: T2 is at least the chart timeframe AND Bias(T2) > 1
Short: T2 is at least the chart timeframe AND Delta(T2) < 0
Short: T2 is at least the chart timeframe AND Delta(T2) < -Step
Short: T2 is at least the chart timeframe AND Bias(T2) < -1
Long: T3 is at least the chart timeframe AND Delta(T3) >= 0
Long: T3 is at least the chart timeframe AND Delta(T3) >= Step
Long: T3 is at least the chart timeframe AND Bias(T3) > 1
Short: T3 is at least the chart timeframe AND Delta(T3) < 0
Short: T3 is at least the chart timeframe AND Delta(T3) < -Step
Short: T3 is at least the chart timeframe AND Bias(T3) < -1
Long: T4 is at least the chart timeframe AND Delta(T4) >= 0
Long: T4 is at least the chart timeframe AND Delta(T4) >= Step
Long: T4 is at least the chart timeframe AND Bias(T4) > 1
Short: T4 is at least the chart timeframe AND Delta(T4) < 0
Short: T4 is at least the chart timeframe AND Delta(T4) < -Step
Short: T4 is at least the chart timeframe AND Bias(T4) < -1