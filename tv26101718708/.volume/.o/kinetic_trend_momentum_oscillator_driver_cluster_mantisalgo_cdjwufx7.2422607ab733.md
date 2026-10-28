Calculation: Filtered price = 2-pole Ehlers SuperSmoother of (high + low + close) / 3
Calculation: Normalized velocity = short EMA of the 1-bar change in filtered price divided by ATR
Calculation: Smoothed acceleration = EMA of the 1-bar change in normalized velocity
Calculation: Acceleration score = smoothed acceleration divided by its rolling standard deviation
Calculation: Traction = absolute change in filtered price over the traction lookback divided by the sum of absolute 1-bar changes in filtered price over that lookback
Calculation: Relative volume = volume divided by its rolling average
Long: warmup complete AND normalized velocity > positive deadband AND acceleration score > positive launch threshold AND traction >= minimum traction AND (volume unavailable OR relative volume >= minimum volume ratio) AND regime is neutral or short AND cooldown elapsed
Short: warmup complete AND normalized velocity < negative deadband AND acceleration score < negative launch threshold AND traction >= minimum traction AND (volume unavailable OR relative volume >= minimum volume ratio) AND regime is neutral or long AND cooldown elapsed
Exit: long, warmup complete AND long regime active AND (smoothed acceleration < negative brake threshold OR normalized velocity crosses below half the positive deadband OR normalized velocity crosses below zero OR (normalized velocity <= positive deadband AND smoothed acceleration < 0))
Exit: short, warmup complete AND short regime active AND (smoothed acceleration > positive brake threshold OR normalized velocity crosses above half the negative deadband OR normalized velocity crosses above zero OR (normalized velocity >= negative deadband AND smoothed acceleration > 0))