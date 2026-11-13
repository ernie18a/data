Calculation: PriorHigh/PriorLow = highest high / lowest low of the previous N bars, excluding the current bar
Calculation: BullSweep = low < PriorLow AND close > PriorLow
Calculation: BearSweep = high > PriorHigh AND close < PriorHigh
Calculation: VWAP = session-reset cumulative sum(typical price (high+low+close)/3 * volume) / cumulative sum(volume)
Calculation: HighVol = volume > a multiple (>1) of the simple moving average of volume
Calculation: ActiveDealer = HighVol AND close within VWAP +/- a fraction of ATR
Calculation: FastEMA, SlowEMA = EMAs of close, FastEMA has the shorter lookback, SlowEMA the longer
Calculation: BullScore = count of true among: BullSweep; (BullSweep AND close > open); (close > VWAP AND close > FastEMA); HighVol; FastEMA > SlowEMA; (close > open AND |close - open| > a fraction of ATR); ActiveDealer
Calculation: BearScore = count of true among: BearSweep; (BearSweep AND close < open); (close < VWAP AND close < FastEMA); HighVol; FastEMA < SlowEMA; (close < open AND |close - open| > a fraction of ATR); ActiveDealer
Calculation: DealerCeiling = high of the most recent bar where BearSweep AND close < open
Calculation: DealerFloor = low of the most recent bar where BullSweep AND close > open
Long: BullSweep
Long: BullSweep AND close > open
Long: BullSweep AND close > open AND BullScore >= a minimum score threshold AND FastEMA > SlowEMA AND the number of bars since the previous bar on which this entire Long condition was satisfied > a cooldown bar count
Long: close crosses above DealerCeiling (previous close <= DealerCeiling AND close > DealerCeiling)
Short: BearSweep
Short: BearSweep AND close < open
Short: BearSweep AND close < open AND BearScore >= a minimum score threshold AND FastEMA < SlowEMA AND the number of bars since the previous bar on which this entire Short condition was satisfied > a cooldown bar count
Short: close crosses below DealerFloor (previous close >= DealerFloor AND close < DealerFloor)