Calculation: BodyHigh = max(open, close)
Calculation: BodyLow = min(open, close)
Calculation: BearImmediate = close[1] > open[1] AND close < open
Calculation: BullImmediate = close[1] < open[1] AND close > open
Calculation: PullbackValid = abs(close[1] - open[1]) >= P1 * abs(close[2] - open[2]) AND abs(close[2] - open[2]) > 0
Calculation: TopPbStart = PullbackValid AND close[1] > open[1] AND NOT TopPb[1]
Calculation: TopPbOn = TopPb[1] OR TopPbStart
Calculation: TopPbLevelS = IF TopPbStart THEN open[1] ELSE TopPbLevel[1]
Calculation: TopPbMove = TopPbOn AND (open > TopPbLevelS OR (close > open AND open < TopPbLevelS))
Calculation: TopPbLevel = IF TopPbMove THEN open ELSE TopPbLevelS
Calculation: TopPbIdx = IF TopPbMove THEN bar index ELSE IF TopPbStart THEN bar index - 1 ELSE TopPbIdx[1]
Calculation: BotPbStart = PullbackValid AND close[1] < open[1] AND NOT BotPb[1]
Calculation: BotPbOn = BotPb[1] OR BotPbStart
Calculation: BotPbLevelS = IF BotPbStart THEN open[1] ELSE BotPbLevel[1]
Calculation: BotPbMove = BotPbOn AND (open < BotPbLevelS OR (close < open AND open > BotPbLevelS))
Calculation: BotPbLevel = IF BotPbMove THEN open ELSE BotPbLevelS
Calculation: BotPbIdx = IF BotPbMove THEN bar index ELSE IF BotPbStart THEN bar index - 1 ELSE BotPbIdx[1]
Calculation: TopPbBranch = TopPbOn AND TopPbIdx != bar index
Calculation: BotPbBranch = BotPbOn AND BotPbIdx != bar index
Calculation: BearBreak = BodyLow < RunLow[1]
Calculation: RunHighAfterBear = IF BearBreak AND TopPbBranch THEN max(BodyHigh[bar index - TopPbIdx], BodyHigh[bar index - TopPbIdx + 1]) ELSE IF BearBreak AND BearImmediate THEN BodyHigh[1] ELSE RunHigh[1]
Calculation: BullBreak = BodyHigh > RunHighAfterBear
Calculation: RunHigh = IF BullBreak THEN BodyHigh ELSE RunHighAfterBear
Calculation: RunLow = IF BullBreak AND BotPbBranch THEN min(BodyLow[bar index - BotPbIdx], BodyLow[bar index - BotPbIdx + 1]) ELSE IF BullBreak AND BullImmediate THEN BodyLow[1] ELSE IF BearBreak THEN BodyLow ELSE RunLow[1]
Calculation: TopPb = TopPbOn AND NOT (BearBreak AND (TopPbBranch OR BearImmediate))
Calculation: BotPb = BotPbOn AND NOT (BullBreak AND (BotPbBranch OR BullImmediate))
Calculation: UpFound = BearBreak AND (TopPbBranch OR BearImmediate) AND TopPbLevel is set
Calculation: UpRef = IF UpFound THEN TopPbLevel ELSE UpRef[1]
Calculation: DownFound = BullBreak AND (BotPbBranch OR BullImmediate) AND BotPbLevel is set
Calculation: DownRef = IF DownFound THEN BotPbLevel ELSE DownRef[1]
Calculation: UpRefresh = UpFound AND Phase[1] != 1 AND (Mark[1] != 1 OR MarkLevel[1] != UpRef)
Calculation: DownRefresh = DownFound AND Phase[1] != -1 AND NOT UpRefresh AND (Mark[1] != -1 OR MarkLevel[1] != DownRef)
Calculation: UpConf = Phase[1] = -1 AND (UpRefresh OR Mark[1] = 1) AND close > (IF UpRefresh THEN UpRef ELSE MarkLevel[1])
Calculation: DownConf = Phase[1] = 1 AND (DownRefresh OR Mark[1] = -1) AND close < (IF DownRefresh THEN DownRef ELSE MarkLevel[1])
Calculation: Phase = IF Phase[1] = 0 AND UpFound THEN -1 ELSE IF Phase[1] = 0 AND DownFound THEN 1 ELSE IF UpConf THEN 1 ELSE IF DownConf THEN -1 ELSE Phase[1]
Calculation: Mark = IF UpConf THEN (IF DownRef is set THEN -1 ELSE 0) ELSE IF DownConf THEN (IF UpRef is set THEN 1 ELSE 0) ELSE IF UpRefresh THEN 1 ELSE IF DownRefresh THEN -1 ELSE Mark[1]
Calculation: MarkLevel = IF UpConf THEN DownRef ELSE IF DownConf THEN UpRef ELSE IF UpRefresh THEN UpRef ELSE IF DownRefresh THEN DownRef ELSE MarkLevel[1]
Calculation: Serial = IF UpRefresh OR DownRefresh OR UpConf OR DownConf THEN Serial[1] + 1 ELSE Serial[1]
Long: Serial(T1 bars, last completed bar) != Serial(T1 bars, last completed bar)[1 chart bar] AND Mark(T1 bars, last completed bar) = 1
Long: Serial(T2 bars, last completed bar) != Serial(T2 bars, last completed bar)[1 chart bar] AND Mark(T2 bars, last completed bar) = 1
Short: Serial(T1 bars, last completed bar) != Serial(T1 bars, last completed bar)[1 chart bar] AND Mark(T1 bars, last completed bar) = -1
Short: Serial(T2 bars, last completed bar) != Serial(T2 bars, last completed bar)[1 chart bar] AND Mark(T2 bars, last completed bar) = -1