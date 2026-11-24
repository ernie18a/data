Calculation: Confirmed Bar = the current chart bar is confirmed when the confirm-on-close parameter is enabled; otherwise true
Calculation: Range Upper = Highest(high[1], range lookback)
Calculation: Range Lower = Lowest(low[1], range lookback)
Calculation: Valid Range = Range Upper and Range Lower are available and Range Upper > Range Lower
Calculation: Range Midpoint = (Range Upper + Range Lower) / 2
Calculation: Range Height = max(Range Upper - Range Lower, instrument minimum tick)
Calculation: Effective ATR = max(nz(ATR(ATR length), high - low), instrument minimum tick)
Calculation: Probe Buffer = Effective ATR * failure-probe ATR parameter * sensitivity-selected probe factor
Calculation: Shelf Half-Width = Effective ATR * retest/shelf ATR parameter
Calculation: Upper Failure Candidate = Confirmed Bar AND Valid Range AND high > Range Upper + Probe Buffer AND close < Range Upper AND close > Range Lower AND clamp((Range Upper - close) / Range Height, 0, 1) >= sensitivity-selected minimum inside depth
Calculation: Lower Failure Candidate = Confirmed Bar AND Valid Range AND low < Range Lower - Probe Buffer AND close < Range Upper AND close > Range Lower AND clamp((close - Range Lower) / Range Height, 0, 1) >= sensitivity-selected minimum inside depth
Calculation: Active Failure = the latest upper or lower failure candidate accepted by the tie rule, storing its direction, boundary, Range Midpoint, failure-inside score, and event bar; retain it until replaced, including after the recovery window expires
Calculation: Failure Age = current chart bar count minus the active failure event bar
Calculation: Failure Inside Score = at the accepted failure bar, 100 * clamp((Range Upper - close) / Range Height, 0, 1) for an upper failure, or 100 * clamp((close - Range Lower) / Range Height, 0, 1) for a lower failure
Calculation: Recovery Candle = active upper failure AND close >= open, or active lower failure AND close <= open
Calculation: Reclaim = active upper failure AND close >= stored boundary + Probe Buffer, or active lower failure AND close <= stored boundary - Probe Buffer
Calculation: Failure Confirmed = active failure AND NOT Reclaim AND ((Failure Age > 0 AND ((upper failure AND high >= stored boundary AND close < stored boundary - Shelf Half-Width) OR (lower failure AND low <= stored boundary AND close > stored boundary + Shelf Half-Width))) OR (Failure Age >= deep-move confirmation bars AND ((upper failure AND close < stored Range Midpoint) OR (lower failure AND close > stored Range Midpoint)))
Calculation: Relative Volume = (na(volume) ? 0 : volume) / nz(SMA(volume, volume-baseline length), na(volume) ? 0 : volume), or 1 when the resulting volume baseline is not positive
Calculation: Relative Volume Slope = Relative Volume - nz(Relative Volume[relative-volume slope lag], Relative Volume)
Calculation: Speed Score = clamp(100 - Failure Age / max(recovery-window bars, positive denominator floor) * 100, 0, 100)
Calculation: Retest Response Score = let D = +1 for an upper failure and -1 for a lower failure; let bar range = max(high - low, instrument minimum tick), close location = clamp((close - low) / bar range, 0, 1), favorable close location = close location for an upper failure and 1 - close location for a lower failure, body efficiency = abs(close - open) / bar range, and candle score = Recovery Candle ? body efficiency * recovery-body weight + favorable close location * constructive-close weight : favorable close location * weak-close weight; clamp(D * (close - stored boundary) / max(Probe Buffer + Shelf Half-Width, instrument minimum tick) * retest-progress weight + retest-score baseline + candle score * retest-candle weight, 0, 100), capped at the rejection response cap when Failure Confirmed
Calculation: Reclaim Speed Score = Reclaim ? Speed Score : clamp(Speed Score * pre-reclaim speed weight + Retest Response Score * pre-reclaim retest weight, 0, 100)
Calculation: Time Decay Score = clamp(100 - Failure Age / max(recovery-window bars * time-decay multiplier, positive denominator floor) * 100, 0, 100)
Calculation: Volume Score = let current volume = na(volume) ? 0 : volume, volume baseline = nz(SMA(volume, volume-baseline length), current volume), and relative-volume level score = clamp((Relative Volume - relative-volume level floor) / max(volume-support level - relative-volume level floor, minimum relative-volume span) * volume-level multiplier, 0, volume-level score cap; then clamp(relative-volume level score + Relative Volume Slope * relative-volume slope multiplier + (Recovery Candle ? recovery-candle volume bonus : 0), 0, 100)
Calculation: Recovery Score = clamp(Failure Inside Score * inside-score weight + Reclaim Speed Score * reclaim-speed weight + Retest Response Score * retest-response weight + Volume Score * volume weight + Time Decay Score * time-decay weight, 0, 100)
Calculation: Recovery Active = Valid Range AND active failure AND Reclaim AND Recovery Score >= active-score threshold
Calculation: Recovery Watch = Valid Range AND active failure AND Recovery Score >= watch-score threshold AND Failure Age <= recovery-window bars AND NOT Recovery Active AND NOT Failure Confirmed
Long: Lower Failure Candidate AND (NOT Upper Failure Candidate OR close > Range Midpoint)
Short: Upper Failure Candidate AND (NOT Lower Failure Candidate OR close <= Range Midpoint)
Long: active upper failure AND Reclaim AND Reclaim was false on the previous chart bar AND Confirmed Bar
Short: active lower failure AND Reclaim AND Reclaim was false on the previous chart bar AND Confirmed Bar
Long: active lower failure AND Failure Confirmed
Short: active upper failure AND Failure Confirmed
Long: active upper failure AND Recovery Active
Short: active lower failure AND Recovery Active
Long: active upper failure AND Recovery Watch
Short: active lower failure AND Recovery Watch
Long: active upper failure AND Recovery Active AND Recovery Score >= alert-score threshold AND Recovery Active was not true on the previous chart bar
Short: active lower failure AND Recovery Active AND Recovery Score >= alert-score threshold AND Recovery Active was not true on the previous chart bar
Long: active upper failure AND Recovery Watch AND Recovery Watch was not true on the previous chart bar
Short: active lower failure AND Recovery Watch AND Recovery Watch was not true on the previous chart bar
Long: active lower failure AND Failure Confirmed AND Confirmed Bar AND Failure Confirmed was false on the previous chart bar
Short: active upper failure AND Failure Confirmed AND Confirmed Bar AND Failure Confirmed was false on the previous chart bar
Long: active lower failure AND Valid Range AND Failure Confirmed AND Failure Confirmed State was false on the previous chart bar
Short: active upper failure AND Valid Range AND Failure Confirmed AND Failure Confirmed State was false on the previous chart bar