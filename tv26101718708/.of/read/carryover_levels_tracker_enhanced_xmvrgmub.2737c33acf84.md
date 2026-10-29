Calculation: Asia high/low = highest high and lowest low during the Asia session
Calculation: London high/low = highest high and lowest low during the London session
Calculation: ALN pattern = LPU if London high > Asia high and London low >= Asia low; LPD if London low < Asia low and London high <= Asia high; LEA if London high > Asia high and London low < Asia low; AEL if London high < Asia high and London low > Asia low
Calculation: NY break = NY-session high >= a session high, or NY-session low <= a session low
Calculation: First NY break = the first Asia or London high/low reached by NY-session price
Calculation: LPU edge erosion = historical rate of NY breaking London high in LPU sessions minus the rate of NY breaking London high when London low breaks first in LPU sessions
Calculation: LPD edge erosion = historical rate of NY breaking London low in LPD sessions minus the rate of NY breaking London low when London high breaks first in LPD sessions
Calculation: Asia/London color bucket = whether each session close is above its session open
Calculation: NY-green rate = fraction of previously completed NY sessions that closed above their opens, among sessions with the same Asia/London color bucket
Long: ALN pattern = LPU AND NOT (LPU edge erosion >= the kill-switch threshold AND first NY break = London low) AND NOT (NY-green rate <= 100% minus the confirmation threshold AND sample size meets the minimum)
Short: ALN pattern = LPD AND NOT (LPD edge erosion >= the kill-switch threshold AND first NY break = London high) AND NOT (NY-green rate >= the confirmation threshold AND sample size meets the minimum)