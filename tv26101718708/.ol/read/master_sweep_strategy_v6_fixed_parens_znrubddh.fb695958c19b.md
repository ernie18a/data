Calculation: Previous Asian high = highest high among bars with hour >= 20 on the previous day
Calculation: Previous Asian low = lowest low among bars with hour >= 20 on the previous day
Calculation: Previous daily, weekly, and monthly high/low = high and low of the last completed bar from each higher timeframe
Long: hour = 8 AND minute = 30 AND close > open AND (low < previous Asian low OR low < previous daily low OR low < previous weekly low OR low < previous monthly low)
Short: hour = 8 AND minute = 30 AND close < open AND (high > previous Asian high OR high > previous daily high OR high > previous weekly high OR high > previous monthly high)
Exit: long, low <= entry price - ATR × stop multiplier OR high >= entry price + ATR × target multiplier
Exit: short, high >= entry price + ATR × stop multiplier OR low <= entry price - ATR × target multiplier