Calculation: Premarket high = maximum traded-instrument high during P9
Calculation: Premarket low = minimum traded-instrument low during P9
Option: buy put, during P8 AND close > open AND EMA(close, P1) < EMA(close, P2) < EMA(close, P4) AND abs(close - EMA(close, P1)) / EMA(close, P1) <= P5 AND EMA(close, P2) < EMA(close, P3) AND close < Premarket low
Option: buy put, during P8 AND close > open AND EMA(close, P1) < EMA(close, P2) < EMA(close, P4) AND abs(close - EMA(close, P1)) / EMA(close, P1) <= P6 AND EMA(close, P2) < EMA(close, P3) AND close < Premarket low
Option: buy call, during P8 AND close < open AND EMA(close, P1) > EMA(close, P2) > EMA(close, P4) AND abs(close - EMA(close, P1)) / EMA(close, P1) <= P5 AND EMA(close, P2) > EMA(close, P3) AND close > Premarket high
Option: buy call, during P8 AND close < open AND EMA(close, P1) > EMA(close, P2) > EMA(close, P4) AND abs(close - EMA(close, P1)) / EMA(close, P1) <= P6 AND EMA(close, P2) > EMA(close, P3) AND close > Premarket high
Option: buy put, during P8 AND EMA(close, P2) < EMA(close, P3) < EMA(close, P4) AND close > open AND abs(close - EMA(close, P3)) / EMA(close, P3) <= P7 AND close < Premarket low
Option: buy call, during P8 AND EMA(close, P2) > EMA(close, P3) > EMA(close, P4) AND close < open AND abs(close - EMA(close, P3)) / EMA(close, P3) <= P7 AND close > Premarket high