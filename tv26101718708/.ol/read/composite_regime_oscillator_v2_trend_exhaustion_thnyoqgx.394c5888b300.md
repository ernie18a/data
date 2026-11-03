Calculation: Normalize(x,a,b) = 100 × clamp((x−a)/(b−a),0,1)
Calculation: Regime stress = 0.45×Normalize(ATR_fast/ATR_slow,1,1.5) + 0.30×Normalize((highest high over a lookback−close)/highest high over that lookback,0,0.12) + 0.25×Normalize((close−lowest low over a lookback)/lowest low over that lookback,0,0.10); ATR_fast uses a shorter lookback than ATR_slow.
Calculation: Stretch = 0.70×Normalize((close−EMA(close, lookback))/ATR_fast,0,2.8) + 0.30×Normalize((close−lowest low over a lookback)/(highest high−lowest low over that lookback),0.5,1).
Calculation: Price location = 0.60×Normalize(range position,0,1) + 0.25×Normalize((close−lowest low over a lookback)/lowest low over that lookback,0,0.10) + 0.15×(100−Normalize((highest high over a lookback−close)/highest high over that lookback,0,0.08)); range position = (close−lowest low)/(highest high−lowest low) over the same lookback.
Calculation: Overreaction = 0.75×Normalize(RSI(close),50,80) + 0.25×Normalize((close−EMA(close, lookback))/ATR_fast,0.5,2.8).
Calculation: Pressure = 0.70×Normalize(volume/SMA(volume, lookback),0.8,2) + 0.30×Normalize(ATR_fast/ATR_slow,1,1.5).
Calculation: Composite oscillator = EMA of the weighted average of regime stress, stretch, price location, overreaction, and pressure; weights are configurable.
Calculation: Bullish reversal score = EMA of [0.35×(100−price location) + 0.25×(100−overreaction) + 0.20×regime stress + 0.20×pressure].
Calculation: Bearish exhaustion score = EMA of [0.35×price location + 0.25×overreaction + 0.20×(100−regime stress) + 0.20×pressure].
Long: composite oscillator crosses above 80 OR (composite oscillator < 20 AND rises for 2 bars) OR (composite oscillator < 20 AND bullish reversal score rises for 2 bars)
Short: composite oscillator crosses below 20 OR (composite oscillator ≥ 80 AND falls for 2 bars) OR (composite oscillator ≥ 80 AND bearish exhaustion score rises for 2 bars)
Exit: long, composite oscillator ≥ 65 AND falls for 3 bars