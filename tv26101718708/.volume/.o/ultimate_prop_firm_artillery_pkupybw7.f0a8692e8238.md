Calculation: Demand zone upper boundary = latest confirmed pivot low + ATR × zone-width multiplier
Calculation: Supply zone lower boundary = latest confirmed pivot high − ATR × zone-width multiplier
Calculation: Long stop = entry-bar close − ATR × stop multiplier; long targets = entry-bar close + ATR × each of three target multipliers
Calculation: Short stop = entry-bar close + ATR × stop multiplier; short targets = entry-bar close − ATR × each of three target multipliers
Long: a pivot low is confirmed on this bar AND low <= demand zone upper boundary AND RSI >= long RSI floor AND close > open AND volume >= volume SMA × volume multiplier AND bar time is within the session AND daily trade count < maximum AND daily drawdown < maximum AND position is flat
Short: a pivot high is confirmed on this bar AND high >= supply zone lower boundary AND RSI <= short RSI ceiling AND close < open AND volume >= volume SMA × volume multiplier AND bar time is within the session AND daily trade count < maximum AND daily drawdown < maximum AND position is flat
Exit: long, low <= long stop OR high >= any of the three long targets OR bar time >= session end
Exit: short, high >= short stop OR low <= any of the three short targets OR bar time >= session end