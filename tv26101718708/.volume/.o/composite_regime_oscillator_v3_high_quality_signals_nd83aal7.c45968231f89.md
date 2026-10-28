Calculation: ATR ratio = shorter-lookback ATR / longer-lookback ATR
Calculation: Drawdown = (lookback high − close) / lookback high
Calculation: Rebound = (close − lookback low) / lookback low
Calculation: Distance from EMA in ATRs = (close − EMA) / shorter-lookback ATR
Calculation: Range position = (close − lookback low) / (lookback high − lookback low)
Calculation: Relative volume = volume / moving average of volume
Calculation: Scaled value = clamp((value − lower bound) / (upper bound − lower bound), 0, 1) × 100
Calculation: Regime stress = smoothed weighted average of scaled ATR ratio, drawdown, and rebound
Calculation: Stretch = smoothed weighted average of scaled absolute distance from EMA in ATRs and absolute range-position distance from 0.5
Calculation: Price location = smoothed weighted average of scaled range position, scaled distance above lookback low, and 100 minus scaled distance below lookback high
Calculation: Bull overreaction = smoothed weighted average of scaled (100 − RSI) and scaled negative distance from EMA in ATRs
Calculation: Bear overreaction = smoothed weighted average of scaled RSI and scaled distance from EMA in ATRs
Calculation: Pressure = smoothed weighted average of scaled relative volume and scaled ATR ratio
Calculation: Bull exhaustion = smoothed weighted average of (100 − price location), bull overreaction, regime stress, and pressure
Calculation: Bear exhaustion = smoothed weighted average of price location, bear overreaction, (100 − regime stress), and pressure
Calculation: Bull reversal trigger = close above prior bar high OR bullish candle after bearish candle OR RSI crossing above oversold level OR close rising for two bars
Calculation: Bear reversal trigger = close below prior bar low OR bearish candle after bullish candle OR RSI crossing below overbought level OR close falling for two bars
Calculation: Bull setup = bull exhaustion at or above configurable exhaustion threshold
Calculation: Bear setup = bear exhaustion at or above configurable exhaustion threshold
Long: Bull setup AND (reversal-trigger confirmation disabled OR bull reversal trigger) AND previous bar did not meet the same setup-and-trigger condition AND no bull signal occurred within the cooldown lookback
Short: Bear setup AND (reversal-trigger confirmation disabled OR bear reversal trigger) AND previous bar did not meet the same setup-and-trigger condition AND no bear signal occurred within the cooldown lookback
Long: Bull setup AND bull exhaustion falling over the recent lookback AND exhaustion oscillator below its lower regime threshold
Short: Bear setup AND bear exhaustion falling over the recent lookback AND exhaustion oscillator above its upper regime threshold
Long: Bull exhaustion above the exhaustion threshold minus an early-warning margin AND bull overreaction above its threshold
Short: Bear exhaustion above the exhaustion threshold minus an early-warning margin AND bear overreaction above its threshold