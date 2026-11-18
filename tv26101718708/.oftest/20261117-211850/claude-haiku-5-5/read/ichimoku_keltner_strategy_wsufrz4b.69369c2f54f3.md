Calculation: band midline = simple moving average of close over band length
Calculation: average band range = simple moving average over band length of (true range if true-range switch is on, otherwise high minus low)
Calculation: upper band = band midline + band multiplier × average band range
Calculation: lower band = band midline − band multiplier × average band range
Calculation: conversion line = (highest high over conversion length including current bar + lowest low over conversion length including current bar) / 2
Calculation: base line = (highest high over base length including current bar + lowest low over base length including current bar) / 2, where base length is longer than conversion length
Calculation: volume change = volume / volume of previous bar
Calculation: average volume change = simple average of volume change over volume lookback bars including current bar
Calculation: long signal = close > upper band AND conversion line > base line AND volume change > volume factor × average volume change
Calculation: short signal = close < lower band AND conversion line < base line AND volume change > volume factor × average volume change
Calculation: breakout price = high + one minimum price tick on the most recent bar where long signal is true
Calculation: breakdown price = low − one minimum price tick on the most recent bar where short signal is true
Long: high >= breakout price
Short: low <= breakdown price
Exit: long, close < lower band AND conversion line < base line
Exit: short, close > upper band AND conversion line > base line