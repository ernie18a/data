Calculation: Session open = open of the first chart bar classified as starting an active session; session classification checks configured Asia, then London, then New York sessions, and retains the most recent session open outside active sessions
Calculation: Range score = 100 × min((high − low) / ATR, 2.5) / 2.5
Calculation: Relative volume score = 100 × min(volume / SMA(volume), 2.5) / 2.5
Calculation: Candle efficiency = 100 × abs(close − open) / (high − low)
Calculation: Session displacement score = 100 × min(abs(close − session open) / ATR, 3) / 3
Calculation: Signed strength = EMA of the weighted average of range score, relative volume score, candle efficiency, and session displacement score, multiplied by 0.45 × bar direction + 0.55 × direction of close relative to session open; each direction is 1 when close is above its reference, −1 when below, and 0 when equal
Long: signed strength > strong threshold AND previous-bar signed strength ≤ strong threshold OR signed strength > 0 AND previous-bar signed strength ≤ 0
Short: signed strength < −strong threshold AND previous-bar signed strength ≥ −strong threshold OR signed strength < 0 AND previous-bar signed strength ≥ 0