Calculation: StrangleHighN = Ceil(FirstHourHigh / StepN) * StepN
Calculation: StrangleLowN = Floor(FirstHourLow / StepN) * StepN
Calculation: StraddleN = (StrangleHighN + StrangleLowN) / 2
Calculation: StrangleHighB = Ceil(FirstHourHigh / StepB) * StepB
Calculation: StrangleLowB = Floor(FirstHourLow / StepB) * StepB
Calculation: StraddleB = (StrangleHighB + StrangleLowB) / 2
Option: sell call, Abs(Price - StraddleN) <= Near
Option: sell put, Abs(Price - StraddleN) <= Near
Option: sell call, Abs(Price - StraddleN) <= Near AND FirstHourHigh - FirstHourLow >= MinRange AND Strike = StrangleHighN
Option: sell put, Abs(Price - StraddleN) <= Near AND FirstHourHigh - FirstHourLow >= MinRange AND Strike = StrangleLowN
Option: sell call, Abs(Price - StraddleB) <= Near
Option: sell put, Abs(Price - StraddleB) <= Near
Option: sell call, Abs(Price - StraddleB) <= Near AND FirstHourHigh - FirstHourLow >= MinRange AND Strike = StrangleHighB
Option: sell put, Abs(Price - StraddleB) <= Near AND FirstHourHigh - FirstHourLow >= MinRange AND Strike = StrangleLowB