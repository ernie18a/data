Calculation: Up2 = high > high[1] AND low >= low[1]
Calculation: Dn2 = low < low[1] AND high <= high[1]
Calculation: Inside = high <= high[1] AND low >= low[1]
Calculation: Outside = high > high[1] AND low < low[1]
Calculation: LongSetup = (Dn2 AND close > open) OR (Dn2[1] AND Up2) OR (Dn2[2] AND Inside[1] AND Up2) OR (Outside[2] AND Inside[1] AND Up2) OR (Up2[1] AND Up2) OR (Up2[2] AND Inside[1] AND Up2)
Calculation: ShortSetup = (Up2 AND close < open) OR (Up2[1] AND Dn2) OR (Up2[2] AND Inside[1] AND Dn2) OR (Outside[2] AND Inside[1] AND Dn2) OR (Dn2[1] AND Dn2) OR (Dn2[2] AND Inside[1] AND Dn2)
Calculation: SetupDir = 1 if LongSetup AND NOT ShortSetup; -1 if ShortSetup AND NOT LongSetup; else 0
Calculation: ActiveDir = SetupDir[k], where k is the smallest value in [0, resolution window] with SetupDir[k] != 0; 0 if no such k exists, or if low[j] < low[k] - stop buffer (SetupDir[k] = 1) or high[j] > high[k] + stop buffer (SetupDir[k] = -1) for some j in [0, k-1]
Calculation: HtfDir = 1 if close of last completed T1 bar >= open of last completed T1 bar, else -1 (T1 bars; chart bars take this value)
Calculation: StructHigh = highest high over structure lookback bars of T1 ending with last completed T1 bar (T1 bars; chart bars take this value)
Calculation: StructLow = lowest low over structure lookback bars of T1 ending with last completed T1 bar (T1 bars; chart bars take this value)
Calculation: BullLevel = MIN(MAX(STDEV(ROC(close, 1), volatility lookback) * SQRT(regime lookback) * band multiplier, minimum band), maximum band) in auto mode, fixed bull level in custom mode
Calculation: BearLevel = -BullLevel in auto mode, fixed bear level in custom mode
Calculation: RegimeState = 1 if ROC(close, regime lookback) >= BullLevel; -1 if ROC(close, regime lookback) <= BearLevel; else 0
Calculation: TransitionProb(from, to) = Count(from, to) / (Count(from, 1) + Count(from, 0) + Count(from, -1)), where Count(from, to) = number of k in [1, transition lookback] with RegimeState[k] = from AND RegimeState[k-1] = to
Calculation: MarkovSignal = 100 * (1/3) * SUM over k in {1, 3, 5} of (M^k[RegimeState[0], 1] - M^k[RegimeState[0], -1]), where M is the 3x3 matrix of TransitionProb over states {1, 0, -1}
Calculation: Samples = number of k in [1, transition lookback] with RegimeState[k] = RegimeState[0]
Calculation: MarkovDir = 1 if Samples >= minimum sample AND MarkovSignal > weak level; -1 if Samples >= minimum sample AND MarkovSignal < -weak level; else 0
Long: LongSetup
Short: ShortSetup
Long: MarkovDir = 1
Short: MarkovDir = -1
Long: ActiveDir = 1 AND MarkovDir = 0
Long: ActiveDir = 1 AND MarkovDir = 1
Long: ActiveDir = -1 AND MarkovDir = 1 AND HtfDir = 1
Short: ActiveDir = -1 AND MarkovDir = 0
Short: ActiveDir = -1 AND MarkovDir = -1
Short: ActiveDir = 1 AND MarkovDir = -1 AND HtfDir = -1
Exit: long, low < entry-bar low - stop buffer
Exit: long, high >= StructHigh at entry AND entry price <= StructHigh at entry
Exit: long, high >= StructHigh at entry AND low <= StructHigh at entry AND entry price > StructHigh at entry
Exit: long, high >= forming T1 bar high at entry AND entry price > StructHigh at entry
Exit: short, high > entry-bar high + stop buffer
Exit: short, low <= StructLow at entry AND entry price >= StructLow at entry
Exit: short, low <= StructLow at entry AND high >= StructLow at entry AND entry price < StructLow at entry
Exit: short, low <= forming T1 bar low at entry AND entry price < StructLow at entry