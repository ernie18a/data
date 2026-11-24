Calculation: tick score(x) = 2 if x >= tick extreme buy or x >= tick climax buy; 1 if x >= tick buying; -2 if x <= -tick extreme sell or x <= -tick capitulation; -1 if x <= -tick selling; else 0
Calculation: NYSE breadth score(x) = 0 if x >= breadth climax; 2 if x >= breadth strong bull; 1 if x >= breadth bullish; -2 if x <= -breadth capitulation or x <= -breadth strong bear; -1 if x <= -breadth bearish; else 0
Calculation: NASDAQ breadth score(x) = 2 if x >= nasdaq breadth strong bull; 1 if x >= nasdaq breadth bullish; -2 if x <= -nasdaq breadth strong bear; -1 if x <= -nasdaq breadth bearish; else 0
Calculation: volume score(x) = 2 if x >= volume strong bull; 1 if x >= volume bullish; -2 if x <= -volume strong bear; -1 if x <= -volume bearish; else 0
Calculation: arms score(x) = 2 if x <= arms strong bullish; 1 if x <= arms bullish; -2 if x >= arms strong bearish; -1 if x >= arms bearish; else 0
Calculation: VIX MA = SMA, EMA, or WMA of VIX close over VIX MA length, or Nadaraya-Watson estimate of VIX close with NWE bandwidth h, NWE ratio r, and NWE length, selected by VIX MA type
Calculation: VIX score = 0 if VIX MA or VIX MA[1] is missing; 1 if VIX MA < VIX MA[1]; else -1
Calculation: VWAP distance = (close - VWAP(VWAP source)) / VWAP(VWAP source) * 100
Calculation: VWAP slope = (VWAP(VWAP source) - VWAP(VWAP source)[1]) / VWAP(VWAP source)[1] * 100
Calculation: VWAP score = 2 if VWAP distance > VWAP at threshold and VWAP slope > VWAP flat threshold; 1 if VWAP distance > VWAP at threshold and abs(VWAP slope) <= VWAP flat threshold; -2 if VWAP distance < -VWAP at threshold and VWAP slope < -VWAP flat threshold; -1 if VWAP distance < -VWAP at threshold and abs(VWAP slope) <= VWAP flat threshold; else 0
Calculation: composite score = tick weight * tick score(NYSE tick(T1, last completed bar)) + breadth weight * NYSE breadth score(NYSE advance-decline(T1, last completed bar)) + VIX weight * VIX score + volume weight * volume score(NYSE up-down volume(T1, last completed bar)) + arms weight * arms score(NYSE Arms index(T1, last completed bar)) + nasdaq breadth weight * NASDAQ breadth score(NASDAQ advance-decline(T1, last completed bar)) + VWAP weight * VWAP score
Long: composite score >= composite bull threshold and composite score[1] < composite bull threshold
Long: composite score >= composite strong bull threshold and composite score[1] < composite strong bull threshold
Short: composite score <= -composite bear threshold and composite score[1] > -composite bear threshold
Short: composite score <= -composite strong bear threshold and composite score[1] > -composite strong bear threshold