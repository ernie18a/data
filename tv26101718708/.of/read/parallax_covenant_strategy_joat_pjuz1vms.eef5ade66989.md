Calculation: Baseline = mean of the short, medium and long lookback Donchian midpoints and the mean of the short and medium midpoints; each midpoint is (highest high + lowest low) / 2.
Calculation: Regime bounds = max(baseline − multiplier × SMA(abs(close − open)), SMA((high + low) / 2) − multiplier × SMA(high − low)) for the floor, and min(baseline + multiplier × SMA(abs(close − open)), SMA((high + low) / 2) + multiplier × SMA(high − low)) for the ceiling; the range and midpoint SMAs use the same lookback.
Calculation: Regime = 1 when close > regime ceiling AND close > baseline; otherwise −1 when close < regime floor AND close < baseline; otherwise the preceding regime, initially 0.
Calculation: Compression ratio = SMA(high − low) / SMA(SMA(high − low)), using the same lookback for both SMAs; compressed means the ratio <= a threshold.
Calculation: Pressure = EMA(0.55 × weighted candle pressure + 0.45 × channel position). Weighted candle pressure = 100 × rolling sum of sign(close − open) × min(abs(close − open) / SMA(abs(close − open)), weight cap), divided by lookback × weight cap; use zero weight when the body SMA is zero. Channel position = clamp(100 × (close − channel lower) / (channel upper − channel lower) − 50, −100, 100), where channel bounds are the regime midpoint SMA ± multiplier × SMA(high − low) × (1 + SMA(abs(close − open)) / SMA(high − low)); the body and range SMAs use the pressure lookback. Guard zero denominators with a small positive value. Pressure signal = SMA(pressure).
Calculation: Mapped midpoint = lowest low over a mapping lookback + EMA(RSI(close)) × (highest high − lowest low over that lookback) / 100 × a stretch multiplier. Mapped slope = EMA(mapped midpoint − previous mapped midpoint).
Calculation: Bull pressure = pressure > positive threshold AND pressure > pressure signal; bear pressure = pressure < negative threshold AND pressure < pressure signal. Bull mapping = close > mapped midpoint AND mapped slope >= 0; bear mapping = close < mapped midpoint AND mapped slope <= 0.
Calculation: Support and resistance = most recently confirmed pivot low and high, respectively, each requiring the same number of bars on both sides; each remains active until its pivot bar is older than a decay lookback. Demand zone = [max(low, close − ATR × multiplier), high] of the latest bar where volume > multiplier × SMA(volume) AND close > open. Supply zone = [low, min(high, close + ATR × multiplier)] of the latest bar where volume > multiplier × SMA(volume) AND close < open. Each zone remains active until its creation bar is older than the decay lookback.
Calculation: Bull structure = active support AND close > support OR active demand zone AND close within its inclusive bounds. Bear structure = active resistance AND close < resistance OR active supply zone AND close within its inclusive bounds.
Calculation: Wave direction = sign(close − previous close) in directional mode; in impulse mode it is the sign of the rolling sum of those signs, or the preceding bar's sign when the sum is zero. Wave state retains its previous value when wave direction is zero, initially 0. Wave size = abs(close − open), optionally plus half the high − low range. Wave total accumulates wave size while wave state is unchanged and resets to current wave size when it changes. Wave strength = wave total / SMA(wave total) over twice the wave-direction lookback, or zero when that average is zero. Bull wave = wave state = 1 AND wave strength >= 1; bear wave = wave state = −1 AND wave strength >= 1.
Calculation: Higher-timeframe bias = sign(close − EMA(close)) calculated on the last completed higher-timeframe bar.
Calculation: Bias score = regime + pressure contribution + mapping contribution + structure contribution + wave contribution + optional higher-timeframe bias; each contribution is 1 for its bull condition, otherwise −1 for its bear condition, otherwise 0. For structure, bull takes precedence if both conditions hold.
Calculation: Initial risk = ATR at position entry × stop multiplier, floored by a small positive price increment. Long target = entry price + initial risk × reward multiplier; short target = entry price − initial risk × reward multiplier. Long stop starts at entry price − initial risk; short stop starts at entry price + initial risk. On each bar where high >= entry price + initial risk × activation multiplier, update the long trailing candidate to the maximum of its previous value and close − current ATR × trail multiplier. On each bar where low <= entry price − initial risk × activation multiplier, update the short trailing candidate to the minimum of its previous value and close + current ATR × trail multiplier. The effective stop is the more protective of the initial stop and the trailing candidate, if one exists.
Long: Regime = 1 AND previous regime != 1.
Short: Regime = −1 AND previous regime != −1.
Long: Previous bar compressed AND current bar not compressed AND bull wave.
Short: Previous bar compressed AND current bar not compressed AND bear wave.
Long: Pressure >= pressure signal.
Short: Pressure < pressure signal.
Long: Bull mapping.
Short: Bear mapping.
Long: Bias score >= 3.
Short: Bias score <= −3.
Long: Wave state = 1.
Short: Wave state = −1.
Long: Higher-timeframe bias = 1 when the higher-timeframe filter is enabled.
Short: Higher-timeframe bias = −1 when the higher-timeframe filter is enabled.
Long: Bull structure.
Short: Bear structure AND NOT bull structure.
Long: Long entries enabled AND regime >= 0 AND at least two of bull pressure, bull mapping, bull structure and bull wave are true AND (higher-timeframe filter disabled OR higher-timeframe bias >= 0) AND (bull pressure OR (bull wave AND (release required OR current bar not compressed))) AND (if zone contact is required, close is within the active demand zone; otherwise bull structure OR close > baseline) AND (pressure crosses above pressure signal OR close crosses above mapped midpoint OR close crosses above baseline).
Short: Short entries enabled AND regime <= 0 AND at least two of bear pressure, bear mapping, bear structure and bear wave are true AND (higher-timeframe filter disabled OR higher-timeframe bias <= 0) AND (bear pressure OR (bear wave AND (release required OR current bar not compressed))) AND (if zone contact is required, close is within the active supply zone; otherwise bear structure OR close < baseline) AND (pressure crosses below pressure signal OR close crosses below mapped midpoint OR close crosses below baseline).
Exit: long, low <= effective long stop OR high >= long target.
Exit: short, high >= effective short stop OR low <= short target.
Exit: long, regime-failure exit enabled AND (regime < 0 OR pressure < 0 OR bear mapping).
Exit: short, regime-failure exit enabled AND (regime > 0 OR pressure > 0 OR bull mapping).
Exit: long, bars since entry >= maximum holding period.
Exit: short, bars since entry >= maximum holding period.