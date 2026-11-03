Calculation: Synthetic delta = volume × (buy share − sell share), where buy share is candle close position, multiplied by 1.05 on green candles; sell share is 1 − close position, multiplied by the red-candle delta amplifier on red candles
Calculation: Synthetic CVD = cumulative synthetic delta
Calculation: Distribution zone = high-effort absorption near a local high OR high-effort failed breakout OR high-effort upper-wick rejection OR high-effort failed sweep above the prior high
Calculation: Liquidity vacuum = red candle AND close near the low of its range AND candle range large relative to ATR AND ATR expanded relative to its baseline
Calculation: Support break = close below the lowest low of the preceding support lookback
Calculation: Cascade setup = support break AND liquidity vacuum AND abnormal volume, dollar volume, or negative delta
Calculation: Sell-pressure score = smoothed, weighted aggregate of volume and dollar-volume anomalies, synthetic delta/CVD pressure, distribution, structure, VWAP/OBV pressure, higher-timeframe bearishness, ETF basket weakness, macro/stablecoin/miner stress, market stress, optional external flow/open-interest pressure, manual panic inputs, confluence bonuses, and volatility-regime weighting
Calculation: Sell-risk state = score-based state (normal, watch, warning, critical, or cascade); cascade additionally requires cascade setup and at least one bearish higher-timeframe close below its EMA. State increases immediately and decreases only when score falls below the prior state's threshold minus the hysteresis gap
Calculation: Higher-timeframe bearish count = count of configured higher-timeframe closes below their EMAs; use the last completed higher-timeframe bars
Calculation: Session VWAP = cumulative volume-weighted typical price since the start of the current day
Calculation: Institutional trap = price is at/above the fast EMA or previous close, AND ETF basket distribution or macro stress or miner stress or total-market-cap stress, AND absorption or distribution near a local high or sweep distribution
Calculation: Sweep distribution = high above the preceding sweep-lookback high AND close below that prior high AND close in the lower part of its range AND high effort
Calculation: Compression breakdown = previous bar was compressed AND support break AND red candle AND ATR expansion
Short: sell-risk state increases into watch, warning, critical, or cascade OR institutional trap OR sweep distribution OR compression breakdown OR exchange-price spread reaches its critical threshold
Exit: short, previous state was warning or higher AND close above fast EMA AND close above session VWAP AND score below warning threshold AND no support break