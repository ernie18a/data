Calculation: Demand zone = confirmed pivot low ± zone padding; retain the latest zone
Calculation: Supply zone = confirmed pivot high ± zone padding; retain the latest zone
Calculation: Long stop = demand-zone bottom at entry
Calculation: Short stop = supply-zone top at entry
Calculation: Long target = entry price + (entry price − long stop) × risk-reward multiple
Calculation: Short target = entry price − (short stop − entry price) × risk-reward multiple
Long: low ≤ demand-zone top AND close > demand-zone top AND (low < lowest low of the preceding sweep-lookback bars AND close > preceding lowest low OR low < prior bar low AND close > open) AND close > open AND close − open > ATR × displacement multiple AND close > EMA AND highest high − lowest low over the chop lookback > ATR × chop multiple AND daily realized PnL > −daily loss limit AND position size ≤ 0 AND close > demand-zone bottom
Short: high ≥ supply-zone bottom AND close < supply-zone bottom AND (high > highest high of the preceding sweep-lookback bars AND close < preceding highest high OR high > prior bar high AND close < open) AND close < open AND open − close > ATR × displacement multiple AND close < EMA AND highest high − lowest low over the chop lookback > ATR × chop multiple AND daily realized PnL > −daily loss limit AND position size ≥ 0 AND supply-zone top > close
Exit: long, low ≤ long stop OR high ≥ long target OR daily realized PnL ≤ −daily loss limit
Exit: short, high ≥ short stop OR low ≤ short target OR daily realized PnL ≤ −daily loss limit