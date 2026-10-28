Calculation: Session VWAP = cumulative ((high + low + close) / 3 × volume) / cumulative volume since the current session began
Calculation: Session meridian = midpoint of the current session’s running high and low
Calculation: Prior session high and low = high and low of the last completed session
Calculation: Opening range high and low = highest high and lowest low during the configured opening period of the current London or New York session
Calculation: Bull rejection = close > open AND (close − low) / (high − low) > 0.5
Calculation: Bear rejection = close < open AND (high − close) / (high − low) > 0.5
Long: Close crosses above prior session high
Short: Close crosses below prior session low
Long: Within the configured retest window after crossing above prior session high, low ≤ prior session high + ATR × retest tolerance AND close > prior session high AND bull rejection
Short: Within the configured retest window after crossing below prior session low, high ≥ prior session low − ATR × retest tolerance AND close < prior session low AND bear rejection
Long: Opening range is set AND close crosses above opening range high AND bull rejection
Short: Opening range is set AND close crosses below opening range low AND bear rejection
Long: Close > session VWAP AND close > session meridian AND low ≤ session meridian + ATR × retest tolerance AND close > session meridian AND bull rejection
Short: Close < session VWAP AND close < session meridian AND high ≥ session meridian − ATR × retest tolerance AND close < session meridian AND bear rejection
Long: At least the configured minimum of these seven conditions is true: bullish session bias (close above session VWAP and meridian); close above session VWAP; higher-timeframe fast EMA > slow EMA AND higher-timeframe close > fast EMA; current session is enabled for trading; volume ≥ volume moving average × configured multiplier; bull rejection; at least one enabled long setup above. A long setup signal also requires volume ≥ volume moving average × configured multiplier and the configured signal cooldown to have elapsed.
Short: At least the configured minimum of these seven conditions is true: bearish session bias (close below session VWAP and meridian); close below session VWAP; higher-timeframe fast EMA < slow EMA AND higher-timeframe close < fast EMA; current session is enabled for trading; volume ≥ volume moving average × configured multiplier; bear rejection; at least one enabled short setup above. A short setup signal also requires volume ≥ volume moving average × configured multiplier and the configured signal cooldown to have elapsed.