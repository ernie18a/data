Calculation: Fast direction = whether the fast-timeframe ColorDM filtered value is rising, falling, or unchanged; the value is the difference between two weighted finite-impulse-response filters of applied price, with a longer and a shorter lookback. Use completed bars on a timeframe lower than the slow-trend timeframe.
Calculation: Slow direction = whether the slow-timeframe line, formed by smoothing applied price twice in succession, is rising, falling, or unchanged. Use the last completed bar on a timeframe higher than the fast-entry timeframe.
Long: Slow direction is rising AND fast direction changes from not rising to rising
Short: Slow direction is falling AND fast direction changes from not falling to falling
Exit: long, Fast direction is falling OR Slow direction is falling
Exit: short, Fast direction is rising OR Slow direction is rising