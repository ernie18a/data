Calculation: effort = volume when volume is available and nonzero; otherwise (high − low) × effort fallback multiplier
Calculation: relative effort = effort / SMA(effort, effort average lookback), or the zero-average fallback when that SMA is zero
Calculation: close position = the flat-bar fallback when high = low; otherwise (close − low) / (high − low)
Calculation: probe quality score = I((direction is bullish AND close position ≥ probe close-position threshold) OR (direction is bearish AND close position ≤ probe close-position threshold)) + I(relative effort ≤ probe effort threshold) + I((direction is bullish AND close > open) OR (direction is bearish AND close < open)) + I(high − low ≤ probe spread multiple × ATR(shorter lookback))
Calculation: Spring event = active bullish-direction range in Phase B AND range low − low is between the minimum and maximum probe excursion multiples × ATR(shorter lookback) AND close ≥ range low AND probe quality score(bullish) ≥ probe score threshold
Calculation: UTAD event = active bearish-direction range in Phase B AND high − range high is between the minimum and maximum probe excursion multiples × ATR(shorter lookback) AND close ≤ range high AND probe quality score(bearish) ≥ probe score threshold
Calculation: C-test event = active Phase B range has met its minimum duration since the secondary test and required secondary-test count AND no probe has closed back inside the range on this bar AND (bullish direction AND low ≤ range low + terminal-edge tolerance × ATR(shorter lookback) OR bearish direction AND high ≥ range high − terminal-edge tolerance × ATR(shorter lookback)) AND relative effort < terminal-test effort threshold
Calculation: retest event = active Phase C range AND (bullish direction AND a Spring occurred AND low ≥ Spring low OR bearish direction AND a UTAD occurred AND high ≤ UTAD high) AND relative effort < retest effort threshold AND bars since the last event ≥ retest gap
Calculation: SOS event = active bullish-direction Phase C range AND bars since the last event ≥ Phase D gap AND validation score ≥ SOS validation threshold AND maturity score ≥ SOS maturity threshold AND (close position ≥ upper dominance threshold OR close > range high) AND ((high − low ≥ strength spread multiple × ATR(shorter lookback) AND relative effort ≥ strength effort threshold) OR close − close[n] ≥ strength movement multiple × ATR(shorter lookback)) AND relative effort ≥ minimum strength effort
Calculation: SOW event = active bearish-direction Phase C range AND bars since the last event ≥ Phase D gap AND validation score ≥ SOS validation threshold AND maturity score ≥ SOS maturity threshold AND (close position ≤ lower dominance threshold OR close < range low) AND ((high − low ≥ strength spread multiple × ATR(shorter lookback) AND relative effort ≥ strength effort threshold) OR close[n] − close ≥ strength movement multiple × ATR(shorter lookback)) AND relative effort ≥ minimum strength effort
Calculation: LPS event = active bullish-direction Phase D range AND no LPS has occurred in the range AND abs(low − range high) ≤ edge tolerance × ATR(shorter lookback) AND relative effort < LPS effort threshold AND high − low ≤ LPS spread multiple × ATR(shorter lookback) AND low ≥ range high − edge tolerance × ATR(shorter lookback) AND an SOS occurred at least the minimum LPS delay bars ago
Calculation: LPSY event = active bearish-direction Phase D range AND no LPSY has occurred in the range AND abs(high − range low) ≤ edge tolerance × ATR(shorter lookback) AND relative effort < LPS effort threshold AND high − low ≤ LPS spread multiple × ATR(shorter lookback) AND high ≤ range low + edge tolerance × ATR(shorter lookback) AND a SOW occurred at least the minimum LPS delay bars ago
Calculation: entry readiness = I(outcome direction is locked) + I(phase is C or later) + I(a retest has occurred) + I(an SOS or SOW has occurred) + I(an LPS or LPSY has occurred) + I(maturity score ≥ entry maturity threshold) + I(validation score ≥ readiness validation threshold) + I(abs(close − range midpoint) ≤ entry distance × ATR(shorter lookback)) + I(bars since the last event ≤ entry recency)
Calculation: entry eligible = active range AND no entry has occurred in the range AND outcome direction is locked AND maturity score ≥ entry maturity threshold AND entry readiness ≥ required readiness score
Long: Spring event
Short: UTAD event
Long: C-test event AND bullish direction
Short: C-test event AND bearish direction
Long: retest event AND bullish direction
Short: retest event AND bearish direction
Long: SOS event
Short: SOW event
Long: LPS event
Short: LPSY event
Long: entry eligible AND bullish direction AND entry policy permits LPS AND LPS event occurs on this bar
Long: entry eligible AND bullish direction AND entry policy permits probe entries AND Spring event occurs on this bar
Long: entry eligible AND bullish direction AND entry policy permits no-probe strength entries AND SOS event occurs on this bar AND neither a Spring nor a UTAD has occurred in the range
Short: entry eligible AND bearish direction AND entry policy permits LPS AND LPSY event occurs on this bar
Short: entry eligible AND bearish direction AND entry policy permits probe entries AND UTAD event occurs on this bar
Short: entry eligible AND bearish direction AND entry policy permits no-probe strength entries AND SOW event occurs on this bar AND neither a Spring nor a UTAD has occurred in the range