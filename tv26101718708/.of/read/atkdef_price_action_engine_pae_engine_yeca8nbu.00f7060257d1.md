Calculation: Body strength = (close − open) / (high − low); 0 when high = low
Calculation: CMF = Chaikin Money Flow
Calculation: Volume ratio = volume / 20-bar simple moving average of volume
Calculation: Turn strength = clamp to [−1, 1] of 1.5 × (current price direction + current CMF direction) / 2 when both directions turn, volume ratio > 1.2, and |body strength| > 0.1; otherwise 0.7 × that direction average when either direction turns and the same volume and body conditions hold; otherwise 0. Price direction is the sign of close versus prior close; CMF direction is the sign of CMF versus prior CMF. A turn occurs when that sign differs from its prior-bar sign and is nonzero.
Calculation: Net momentum = clamp to [−2, 2] of the 3-bar SMA of positive body strength × clamped volume ratio minus the 3-bar SMA of absolute negative body strength × clamped volume ratio; clamp volume ratio to [0.3, 3]
Calculation: Trend direction = sign of EMA(20) − EMA(60)
Calculation: Price momentum short = (close − close 3 bars ago) / close × 100
Calculation: Price momentum medium = (close − close 10 bars ago) / close × 100
Calculation: Price acceleration = price momentum short − (close 3 bars ago − close 6 bars ago) / close 3 bars ago × 100
Calculation: Volume momentum = (20-bar volume SMA − its value 5 bars ago) / current 20-bar volume SMA × 100
Calculation: Behavior index = clamp to [−5, 5] of 0.3 × price momentum short + 0.2 × price momentum medium + 0.2 × price acceleration + 0.15 × volume momentum + 3 × CMF
Calculation: Bullish consistent = price momentum short > 0 AND price momentum medium > 0 AND price acceleration > 0 AND CMF > 0
Calculation: Bearish consistent = price momentum short < 0 AND price momentum medium < 0 AND price acceleration < 0 AND CMF < 0
Calculation: New 20-bar high = close > highest high of prior 20 bars
Calculation: New 20-bar low = close < lowest low of prior 20 bars
Calculation: Upper wick ratio = (high − max(open, close)) / (high − low); 0 when high = low
Calculation: Lower wick ratio = (min(open, close) − low) / (high − low); 0 when high = low
Long: turn strength > 0.15 OR net momentum > 0.2 OR trend direction > 0 OR CMF > 0.08 OR (bullish consistent AND behavior index > 0.5) OR (behavior index > 1 AND NOT bearish consistent) OR (body strength > 0.2 AND volume ratio > 1.2 AND upper wick ratio < 0.35 AND (trend direction ≥ 0 OR new 20-bar high)) OR (body strength > 0.2 AND volume ratio > 1.2 AND upper wick ratio > 0.4 AND (trend direction ≤ 0 OR NOT new 20-bar high)) OR (CMF > 0 AND body strength > 0)
Short: turn strength < −0.15 OR net momentum < −0.2 OR trend direction < 0 OR CMF < −0.08 OR (bearish consistent AND behavior index < −0.5) OR (behavior index < −1 AND NOT bullish consistent) OR (body strength < −0.2 AND volume ratio > 1.2 AND lower wick ratio < 0.35 AND (trend direction ≤ 0 OR new 20-bar low)) OR (body strength < −0.2 AND volume ratio > 1.2 AND lower wick ratio > 0.4 AND (trend direction ≥ 0 OR NOT new 20-bar low)) OR (CMF < 0 AND body strength < 0)