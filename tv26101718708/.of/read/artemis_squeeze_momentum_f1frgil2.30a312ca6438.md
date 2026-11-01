Calculation: Momentum = linear-regression endpoint over the momentum lookback of 100 × (close − ((highest high + lowest low) / 2 + SMA((high + low) / 2)) / 2) / channel true range. Highest, lowest, SMA, and regression use the momentum lookback. Channel true range is max(highest high − lowest low, abs(highest high − previous close), abs(lowest low − previous close)); if nearly zero, use the current bar's true range.
Calculation: Momentum signal = SMA of momentum over a shorter signal lookback.
Calculation: Directional flux = 100 × RMA((up − down) / (up + down), half the flux lookback), where up = RMA(max(change in high, 0), flux lookback) and down = RMA(max(−change in low, 0), flux lookback); use zero for the ratio when its denominator is nearly zero. Optionally calculate flux from standard Heikin Ashi bars instead of raw bars.
Calculation: Squeeze = sample standard deviation of close over the momentum lookback < ATR over that lookback × loose squeeze threshold, with the threshold scaled by the square root of the momentum lookback.
Calculation: Active confluence threshold = the baseline threshold, optionally increased by a fixed offset when ADX exceeds the trend threshold or decreased by that offset when ADX is below the lower range threshold; clamp to a positive minimum. ADX uses equal directional-movement and smoothing lookbacks.
Calculation: Divergence anchors = maintain separate bullish and bearish anchors for regular and hidden divergences. On each momentum cross above its signal, compare low and momentum signal with the bullish anchor; on each cross below, compare high and momentum signal with the bearish anchor. Regular anchors update only when momentum is below the negative sensitivity on an upward cross or above the positive sensitivity on a downward cross; hidden anchors update on every corresponding cross. After comparison, clear the corresponding anchor when its divergence passes the optional filter; otherwise replace it with the current price and momentum signal. The optional filter requires absolute momentum-signal change >= a minimum AND absolute price change >= a minimum fraction of the recent high-low range over a lookback longer than the momentum lookback AND, if flux confirmation is enabled, flux > 0 for bullish divergence or flux < 0 for bearish divergence.
Calculation: Trend strength score = round(0.30 × clamp(50 + momentum / 2, 0, 100) + 0.30 × clamp(50 + flux / 2, 0, 100) + 0.15 × (70 if momentum > momentum signal else 30) + 0.25 × confluence score), where confluence score is 90 for momentum > 0 AND flux > 0, 65 for momentum > 0 AND flux <= 0, 10 for momentum < 0 AND flux < 0, 35 for momentum < 0 AND flux >= 0, and 50 otherwise.
Long: Momentum > momentum signal.
Short: Momentum <= momentum signal.
Long: Momentum > 0.
Short: Momentum <= 0.
Long: Directional flux > 0.
Short: Directional flux <= 0.
Long: Momentum > previous momentum.
Short: Momentum < previous momentum.
Long: Directional flux > previous directional flux.
Short: Directional flux < previous directional flux.
Long: Trend strength score >= bullish score threshold.
Short: Trend strength score <= bearish score threshold, where the bearish threshold is lower than the bullish threshold.
Long: ADX > trend threshold AND positive directional indicator > negative directional indicator.
Short: ADX > trend threshold AND positive directional indicator <= negative directional indicator.
Long: Momentum crosses above momentum signal AND momentum < −active confluence threshold AND directional flux < 0 AND (volume confirmation is disabled OR volume or its SMA is missing or nonpositive OR volume > its SMA).
Short: Momentum crosses below momentum signal AND momentum > active confluence threshold AND directional flux > 0 AND (volume confirmation is disabled OR volume or its SMA is missing or nonpositive OR volume > its SMA).
Long: Previous bar is in squeeze AND current bar is not in squeeze AND momentum − momentum at the predictor lookback > positive predictor threshold.
Short: Previous bar is in squeeze AND current bar is not in squeeze AND momentum − momentum at the predictor lookback < negative predictor threshold.
Long: Momentum crosses above momentum signal AND momentum < −sensitivity AND low < regular bullish anchor price AND momentum signal > regular bullish anchor signal AND the optional divergence filter passes.
Short: Momentum crosses below momentum signal AND momentum > sensitivity AND high > regular bearish anchor price AND momentum signal < regular bearish anchor signal AND the optional divergence filter passes.
Long: Momentum crosses above momentum signal AND low > hidden bullish anchor price AND momentum signal < hidden bullish anchor signal AND the optional divergence filter passes.
Short: Momentum crosses below momentum signal AND high < hidden bearish anchor price AND momentum signal > hidden bearish anchor signal AND the optional divergence filter passes.
Long: Momentum > 0 on a selected higher timeframe, using its last completed bar; apply independently to each of four ordered timeframes, allowing a selected timeframe equal to the chart timeframe.
Short: Momentum < 0 on a selected higher timeframe, using its last completed bar; apply independently to each of four ordered timeframes, allowing a selected timeframe equal to the chart timeframe.
Long: Momentum > 0 on all four selected timeframes, using the last completed bar of each higher timeframe and the current chart bar for any timeframe equal to the chart timeframe.
Short: Momentum < 0 on all four selected timeframes, using the last completed bar of each higher timeframe and the current chart bar for any timeframe equal to the chart timeframe.
Exit: short, momentum crosses above momentum signal.
Exit: long, momentum crosses below momentum signal.