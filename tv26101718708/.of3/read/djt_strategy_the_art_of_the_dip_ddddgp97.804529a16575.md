Calculation: volatility change percent = 100 * (volatility index close - volatility index close of the last completed T1 bar, on chart bars) / volatility index close of the last completed T1 bar, on chart bars
Calculation: volatility spike = (volatility change percent >= spike threshold OR ROC(volatility index close, flash lookback) >= flash spike threshold) AND volatility index close >= volatility floor AND (NOT term filter OR short-dated volatility index close > volatility index close)
Calculation: volatility drop = volatility change percent <= -drop threshold
Long: ((volatility spike AND NOT reverse mode) OR (volatility drop AND drop mode AND NOT volatility spike AND reverse mode)) AND no open position AND bars since last exit >= cooldown bars AND (NOT session filter OR bar time within session window) AND (NOT heat filter OR bar time within prime hours window)
Short: ((volatility drop AND drop mode AND NOT volatility spike AND NOT reverse mode) OR (volatility spike AND reverse mode)) AND no open position AND bars since last exit >= cooldown bars AND (NOT session filter OR bar time within session window) AND (NOT heat filter OR bar time within prime hours window)
Exit: long, low <= entry price * (1 - stop distance) OR high >= entry price * (1 + target distance)
Exit: short, high >= entry price * (1 + stop distance) OR low <= entry price * (1 - target distance)
Exit: long, NOT reverse mode AND volatility change percent <= full reversion threshold
Exit: long, NOT reverse mode AND volatility change percent > full reversion threshold AND no prior partial exit AND volatility change percent <= partial reversion threshold
Exit: long, NOT reverse mode AND volatility change percent > full reversion threshold AND (prior partial exit OR volatility change percent > partial reversion threshold) AND bars since entry >= max holding bars
Exit: long, reverse mode AND (bars since entry >= max holding bars OR volatility spike)
Exit: short, reverse mode AND volatility change percent <= full reversion threshold
Exit: short, reverse mode AND volatility change percent > full reversion threshold AND no prior partial exit AND volatility change percent <= partial reversion threshold
Exit: short, reverse mode AND volatility change percent > full reversion threshold AND (prior partial exit OR volatility change percent > partial reversion threshold) AND bars since entry >= max holding bars
Exit: short, NOT reverse mode AND (bars since entry >= max holding bars OR volatility spike)