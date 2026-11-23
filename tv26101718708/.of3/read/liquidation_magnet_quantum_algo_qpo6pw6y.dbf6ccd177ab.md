Calculation: LiqPool = estimated liquidation level with a side (short-liquidation above price or long-liquidation below price) and a mass; levels are created from price structure, except that a candidate on the same side within ATR(high, low, close, ATR lookback) * merge tolerance of an existing level adds its mass to that level; each level's mass is multiplied by decay on each confirmed bar; a level is removed when its mass is below floor, when the level count exceeds pool limit and the level has the lowest mass, or when price trades through it
Calculation: NetPull = sum over LiqPool of mass * sign(level - close) / (1 + ((level - close) / (ATR(high, low, close, ATR lookback) * pull scale))^2)
Calculation: ReversalRate(purge type) = (wins + shrinkage strength * one half) / (count + shrinkage strength), where the samples of a purge type are the last sample cap purges of that type, each recorded reversal horizon bars after its purge as (close / close[reversal horizon] - 1) * direction, with direction = -1 for upward purges and +1 for downward purges; wins = count of samples with recorded value > 0; count = number of samples
Short: high >= level of any short-liquidation LiqPool
Long: low <= level of any long-liquidation LiqPool
Long: NetPull > color threshold
Long: NetPull >= arrow threshold
Short: NetPull < -color threshold
Short: NetPull <= -arrow threshold
Short: count(upward purge samples) >= minimum samples AND ReversalRate(upward purge) >= rate threshold
Long: count(downward purge samples) >= minimum samples AND ReversalRate(downward purge) >= rate threshold