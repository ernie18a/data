Calculation: ORB high = highest high during the current session's opening range
Calculation: ORB low = lowest low during the current session's opening range
Calculation: Session high = highest high since the active session began
Calculation: Session low = lowest low since the active session began
Calculation: Long swing high = highest high since the breakout direction most recently changed to long
Calculation: Short swing low = lowest low since the breakout direction most recently changed to short
Calculation: Long retracement(fraction) = Long swing high - (Long swing high - Session low) * fraction
Calculation: Short retracement(fraction) = Short swing low + (Session high - Short swing low) * fraction
Calculation: Long stop level = Long retracement(stop retracement fraction) - ATR(lookback) * stop buffer multiplier, captured at entry
Calculation: Short stop level = Short retracement(stop retracement fraction) + ATR(lookback) * stop buffer multiplier, captured at entry
Long: opening range is ready AND the latest valid ORB boundary cross in the current session is a close crossover above ORB high
Short: opening range is ready AND the latest valid ORB boundary cross in the current session is a close crossunder below ORB low
Long: opening range is ready AND current bar is in the active signal session AND long breakout direction is active AND the low has touched or crossed Long retracement(entry retracement fraction) since Long swing high was last set or raised AND no long signal has already fired this session AND close > open AND close > Long retracement(entry retracement fraction) AND (MACD agreement is not required OR MACD(close, fast lookback, slow lookback, signal lookback) line > signal line) AND (volume filter is disabled OR volume > SMA(volume, volume lookback) * volume multiplier) AND (strong-body filter is disabled OR close - open > SMA(abs(close - open), body lookback))
Short: opening range is ready AND current bar is in the active signal session AND short breakout direction is active AND the high has touched or crossed Short retracement(entry retracement fraction) since Short swing low was last set or lowered AND no short signal has already fired this session AND close < open AND close < Short retracement(entry retracement fraction) AND (MACD agreement is not required OR MACD(close, fast lookback, slow lookback, signal lookback) line < signal line) AND (volume filter is disabled OR volume > SMA(volume, volume lookback) * volume multiplier) AND (strong-body filter is disabled OR open - close > SMA(abs(close - open), body lookback))
Exit: Long, high >= Long swing high captured at entry OR low <= Long stop level
Exit: Short, low <= Short swing low captured at entry OR high >= Short stop level