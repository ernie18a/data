# Gold Macro Bias Table

- url: https://www.tradingview.com/script/C1QscdBi/
- type: indicator
- pine_id: PUB;56090ca7c9304439b16fd825fa8946b0
- version: 1.0

## Description

Gold Macro Bias Table

Gold Macro Bias Table is designed to provide a fast, structured and multi-dimensional overview of the current gold market environment. The main goal is to help traders quickly assess how different macroeconomic, intermarket, risk, volatility, volume and technical factors are currently aligned.

Gold is influenced by many different drivers. Real yields, the US dollar, Treasury yields, bond-market behavior, foreign exchange dynamics, silver, gold miners, credit markets, volatility and technical momentum can all affect price behavior. Instead of analyzing every related market separately, this indicator brings the most relevant inputs together in one compact dashboard.

The indicator is not intended to predict future price movement. It is a decision-support tool that helps traders understand whether the current market background is more supportive, neutral or opposing for gold.

Data Sources and Market Inputs

The script uses TradingView market data based on the symbols selected in the settings. The default symbols can be adjusted by the user.

Real Yield:
The real yield input is used to represent inflation-adjusted interest-rate pressure. Rising real yields are generally negative for gold because they increase the opportunity cost of holding a non-yielding asset. Falling real yields are generally supportive for gold.

DXY:
The US Dollar Index is used as a broad measure of US dollar strength. A stronger dollar is usually a headwind for gold, while a weaker dollar can support gold prices.

US10Y and US02Y:
US Treasury yields are used to measure interest-rate pressure across different parts of the yield curve. Rising yields can pressure gold, while falling yields can support gold, especially when combined with a weaker US dollar.

TLT:
TLT is used as a proxy for long-duration US Treasury bonds. Strength in TLT often reflects falling long-term yields, which can be supportive for gold.

USDJPY:
USDJPY is included as a rate-sensitive and dollar-sensitive FX input. A rising USDJPY can often reflect stronger US rate pressure or broader US dollar strength, which may be negative for gold.

Silver:
Silver is used as a precious-metals confirmation factor. Strength in silver can confirm broader demand for precious metals, while weakness may indicate a lack of confirmation.

GDX:
GDX represents gold miners. Miner strength can confirm institutional appetite for the gold sector, while miner weakness can warn that gold strength is not broadly supported.

VIX:
The VIX is used as a volatility and risk-sentiment input. Higher volatility can increase safe-haven demand, but very elevated volatility also means higher trading risk.

HYG:
HYG is used as a credit-risk proxy. Strength in high-yield credit usually points to more risk-on conditions, while weakness can indicate stress in credit markets.

Scoring and Weighting

The table compares each selected input with its moving average and assigns a score depending on whether the current condition is considered supportive or opposing for gold.

The score values and weightings are fully adjustable in the settings. This allows each trader to adapt the model according to personal experience, trading style and individual interpretation of how important each factor is for the current market environment.

The total score is displayed as the Macro Gold Bias.

Volatility

The volatility section compares the current ATR percentage with its own average. This helps identify whether the market is currently calm, normal, elevated or extreme. The volatility reading is used as additional context, especially when market conditions become unstable or risk expands quickly.

Volume and Delta

The volume section provides a quick overview of session volume, estimated session ask volume, estimated session bid volume and estimated session delta.

The intraday delta values for 1m, 5m, 15m and 1h are calculated from the available TradingView chart data. These values are not true exchange bid/ask volume and should not be interpreted as real order-book flow.

They are tick-volume-based approximations designed to give the trader a practical feeling for current market behavior, volume pressure and whether recent activity appears more buy-side or sell-side dominated.

Average Volume and Delta

The average row compares the current session and intraday delta behavior with configurable lookback periods. The session average volume lookback and the delta lookbacks for 1m, 5m, 15m and 1h can be adjusted in the settings.

This helps put current activity into context instead of relying on isolated volume or delta values.

Technical Gold Bias

The technical section uses TradingView’s built-in Technical Ratings, often known from the TradingView Technical Rating gauge. It combines information from multiple moving averages and oscillators into a normalized technical reading.

This separates the technical condition of gold from the broader macro and intermarket environment.

Market Regime

The market regime section classifies the current environment into broader categories such as:

Safe Haven
Yield Pressure
Dollar Pressure
Inflation Hedge
Yield Relief
Mixed

This gives additional context behind the raw score and helps explain why the current environment may be supportive, opposing or mixed for gold.

Final Gold Bias

The final bias combines the macro score, technical rating, market regime and volatility context into one final interpretation. It is designed to provide a fast overview of whether current conditions are bullish, bearish, mixed or high risk.

Trend Strength

The trend strength score ranges from -10 to +10. It combines macro direction, technical direction and market regime support into a simple strength reading.

A positive value indicates a more supportive environment for gold, while a negative value indicates a more opposing environment.

Price Movement Alerts

The indicator includes configurable price movement alerts for gold and the selected macro symbols.

The purpose of these alerts is not to generate buy or sell signals. They are designed as warning signals when one or more monitored symbols exceed the user-defined percentage threshold.

This can be useful because related markets do not always react at the same speed. Some symbols may move earlier and provide a warning that the market environment is changing, while others may react later. These alerts can help traders recognize fast market movement, unstable conditions or situations where it may be necessary to reduce exposure or step out of the market.

TradingView alerts can be configured through the normal TradingView alert menu. Depending on the user’s TradingView settings, notifications can be sent by app, pop-up, email, webhook or other available alert actions.

Important Note

This indicator is not a standalone trading system and does not provide financial advice. It should be used together with price action, market structure, risk management and personal trade planning.

All readings depend on the selected symbols, the active data feed, the chosen timeframes and the user-defined settings.

## Source Code

````pine
//@version=6
import TradingView/TechnicalRating/3 as TechnicalRating

indicator("Gold Macro Bias Table", overlay=true)

RealYieldSymbol = input.symbol("FRED:DFII10", "Real Yield")
DxySymbol = input.symbol("TVC:DXY", "DXY")
Us10YSymbol = input.symbol("TVC:US10Y", "US10Y")
Us02YSymbol = input.symbol("TVC:US02Y", "US02Y")
TltSymbol = input.symbol("NASDAQ:TLT", "TLT")
UsdJpySymbol = input.symbol("FX:USDJPY", "USDJPY")
SilverSymbol = input.symbol("OANDA:XAGUSD", "Silver")
GdxSymbol = input.symbol("AMEX:GDX", "GDX")
VixSymbol = input.symbol("CBOE:VIX", "VIX")
HygSymbol = input.symbol("AMEX:HYG", "HYG")

MacroTimeframe = input.timeframe("60", "Macro Timeframe")
RealYieldTimeframe = input.timeframe("D", "Real Yield Timeframe")
TechnicalRatingTimeframe = input.timeframe("15", "Technical Rating Timeframe")
PriceAlertTimeframe = input.timeframe("1", "Price Alert Timeframe")
PriceAlertThresholdPercent = input.float(1.0, "Price Alert Threshold %", minval=0.0, step=0.1)
EnablePriceAlertSignals = input.bool(true, "Enable Price Movement Alerts")
AverageLength = input.int(8, "Average Periods", minval=1)
AtrLength = input.int(14, "ATR Length", minval=1)
SessionAverageVolumeLookback = input.int(5, "Session Average Volume Lookback", minval=1)
AverageDelta1mLookback = input.int(20, "1m Average Delta Lookback", minval=1)
AverageDelta5mLookback = input.int(20, "5m Average Delta Lookback", minval=1)
AverageDelta15mLookback = input.int(20, "15m Average Delta Lookback", minval=1)
AverageDelta1hLookback = input.int(20, "1h Average Delta Lookback", minval=1)
SpacerHeight = input.float(0.5, "Spacer Row Height", minval=0.1)
TablePosition = input.string("top_right", "Table Position", options=["top_right", "top_left", "bottom_right", "bottom_left"])
TableTextSize = input.string("tiny", "Table Text Size", options=["tiny", "small", "normal", "large", "huge"])

RealYieldWeight = input.int(4, "Real Yield Weight", minval=0)
DxyWeight = input.int(4, "DXY Weight", minval=0)
Us10YWeight = input.int(3, "US10Y Weight", minval=0)
Us02YWeight = input.int(3, "US02Y Weight", minval=0)
TltWeight = input.int(2, "TLT Weight", minval=0)
UsdJpyWeight = input.int(2, "USDJPY Weight", minval=0)
SilverWeight = input.int(2, "Silver Weight", minval=0)
GdxWeight = input.int(2, "GDX Weight", minval=0)
VixWeight = input.int(1, "VIX Weight", minval=0)
HygWeight = input.int(1, "HYG Weight", minval=0)

GroupWidth = input.float(5.0, "Group Column Width", minval=1.0)
SymbolWidth = input.float(5.0, "Symbol Column Width", minval=1.0)
CurrentWidth = input.float(7.0, "Current Column Width", minval=1.0)
AverageWidth = input.float(7.0, "Average Column Width", minval=1.0)
ScoreWidth = input.float(5.0, "Score Column Width", minval=1.0)
BiasWidth = input.float(8.0, "Bias Column Width", minval=1.0)
DurationWidth = input.float(6.0, "Duration Column Width", minval=1.0)
PriceAlertWidth = input.float(8.0, "Price Alert Column Width", minval=1.0)

TextColor = input.color(color.white, "Text Color")
LineColor = input.color(color.white, "Line Color")
HeaderBgColor = input.color(color.new(color.black, 0), "Header Background")
GroupBgColor = input.color(color.new(color.blue, 75), "Group Background")
BullishBgColor = input.color(color.new(color.green, 70), "Bullish Background")
BearishBgColor = input.color(color.new(color.red, 70), "Bearish Background")
NeutralBgColor = input.color(color.new(color.gray, 75), "Neutral Background")
TechnicalNeutralBgColor = input.color(color.new(color.yellow, 80), "Technical Neutral Background")
VolatilityHeaderBgColor = input.color(color.new(color.black, 0), "Volatility Header Background")
LowVolatilityBgColor = input.color(color.new(color.gray, 75), "Low Volatility Background")
ElevatedVolatilityBgColor = input.color(color.new(color.orange, 70), "Elevated Volatility Background")
ExtremeVolatilityBgColor = input.color(color.new(color.red, 65), "Extreme Volatility Background")
PriceAlertBullishBgColor = input.color(color.new(color.green, 70), "Price Alert Bullish Background")
PriceAlertBearishBgColor = input.color(color.new(color.red, 70), "Price Alert Bearish Background")
PriceAlertNeutralBgColor = input.color(color.new(color.yellow, 80), "Price Alert Neutral Background")
SpacerBgColor = input.color(color.new(color.black, 100), "Spacer Background")

var DirectionStateArray = array.new<int>(16, na)
var DirectionStartTimeArray = array.new<int>(16, na)
var SessionAskVolumeHistory = array.new<float>()
var SessionBidVolumeHistory = array.new<float>()
var SessionDeltaVolumeHistory = array.new<float>()

GetPosition(PositionText) =>
    PositionText == "top_right" ? position.top_right :
     PositionText == "top_left" ? position.top_left :
     PositionText == "bottom_right" ? position.bottom_right :
     position.bottom_left

GetTextSize(SizeText) =>
    SizeText == "tiny" ? size.tiny :
     SizeText == "small" ? size.small :
     SizeText == "normal" ? size.normal :
     SizeText == "large" ? size.large :
     size.huge

GetValue(Symbol, TimeframeValue) =>
    request.security(Symbol, TimeframeValue, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

GetAverage(Symbol, TimeframeValue, Length) =>
    request.security(Symbol, TimeframeValue, ta.sma(close, Length), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

GetPriceAlertPercent(Symbol, TimeframeValue) =>
    request.security(Symbol, TimeframeValue, na(close[1]) or close[1] == 0.0 ? na : (close - close[1]) / close[1] * 100.0, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

GetChartPriceAlertPercent(TimeframeValue) =>
    request.security(syminfo.tickerid, TimeframeValue, na(close[1]) or close[1] == 0.0 ? na : (close - close[1]) / close[1] * 100.0, barmerge.gaps_off, barmerge.lookahead_off)

GetArrayAverage(FloatArray, LengthValue) =>
    CountValue = math.min(array.size(FloatArray), LengthValue)
    SumValue = 0.0
    if CountValue > 0
        for IndexValue = 0 to CountValue - 1
            SumValue += array.get(FloatArray, IndexValue)
    CountValue == 0 ? na : SumValue / CountValue

GetScore(CurrentValue, AverageValue, BullishWhenAbove, Weight) =>
    na(CurrentValue) or na(AverageValue) ? 0 :
     BullishWhenAbove ?
      CurrentValue > AverageValue ? Weight : CurrentValue < AverageValue ? -Weight : 0 :
      CurrentValue < AverageValue ? Weight : CurrentValue > AverageValue ? -Weight : 0

GetStatus(Score) =>
    Score >= 15 ? "Strong Bullish" :
     Score >= 7 ? "Bullish" :
     Score <= -15 ? "Strong Bearish" :
     Score <= -7 ? "Bearish" :
     "Neutral"

GetShortStatus(Score) =>
    Score > 0 ? "Bullish" :
     Score < 0 ? "Bearish" :
     "Neutral"

GetBg(Score) =>
    Score > 0 ? BullishBgColor :
     Score < 0 ? BearishBgColor :
     TechnicalNeutralBgColor

GetVolatilityStatus(VolatilityRatio) =>
    na(VolatilityRatio) ? "n/a" :
     VolatilityRatio >= 1.6 ? "Extreme" :
     VolatilityRatio >= 1.2 ? "Elevated" :
     VolatilityRatio <= 0.8 ? "Low" :
     "Normal"

GetVolatilityBg(VolatilityRatio) =>
    na(VolatilityRatio) ? NeutralBgColor :
     VolatilityRatio >= 1.6 ? ExtremeVolatilityBgColor :
     VolatilityRatio >= 1.2 ? ElevatedVolatilityBgColor :
     VolatilityRatio <= 0.8 ? LowVolatilityBgColor :
     TechnicalNeutralBgColor

GetTechnicalRatingStatus(RatingValue) =>
    na(RatingValue) ? "n/a" :
     RatingValue >= 0.5 ? "Strong Buy" :
     RatingValue >= 0.1 ? "Buy" :
     RatingValue <= -0.5 ? "Strong Sell" :
     RatingValue <= -0.1 ? "Sell" :
     "Neutral"

GetTechnicalRatingBg(RatingValue) =>
    na(RatingValue) ? NeutralBgColor :
     RatingValue >= 0.1 ? BullishBgColor :
     RatingValue <= -0.1 ? BearishBgColor :
     TechnicalNeutralBgColor

GetBoolScore(Condition) =>
    Condition == true ? 1 : 0

GetMarketRegime(SafeHavenScore, YieldPressureScore, DollarPressureScore, InflationHedgeScore, YieldReliefScore) =>
    MaxScore = math.max(math.max(math.max(math.max(SafeHavenScore, YieldPressureScore), DollarPressureScore), InflationHedgeScore), YieldReliefScore)
    MaxScore < 2 ? "Mixed" :
     SafeHavenScore == MaxScore ? "Safe Haven" :
     YieldPressureScore == MaxScore ? "Yield Pressure" :
     DollarPressureScore == MaxScore ? "Dollar Pressure" :
     InflationHedgeScore == MaxScore ? "Inflation Hedge" :
     "Yield Relief"

GetMarketRegimeStatus(Regime) =>
    Regime == "Safe Haven" ? "Supportive" :
     Regime == "Inflation Hedge" ? "Supportive" :
     Regime == "Yield Relief" ? "Supportive" :
     Regime == "Yield Pressure" ? "Opposing" :
     Regime == "Dollar Pressure" ? "Opposing" :
     "Mixed"

GetMarketRegimeConfirmation(MaxScore) =>
    MaxScore >= 5 ? "Strong" :
     MaxScore >= 4 ? "Confirmed" :
     MaxScore >= 2 ? "Weak" :
     "Mixed"

GetMarketRegimeBg(Status) =>
    Status == "Supportive" ? BullishBgColor :
     Status == "Opposing" ? BearishBgColor :
     TechnicalNeutralBgColor

GetTechnicalDirection(RatingValue) =>
    na(RatingValue) ? 0 :
     RatingValue >= 0.1 ? 1 :
     RatingValue <= -0.1 ? -1 :
     0

GetRegimeDirection(RegimeStatus) =>
    RegimeStatus == "Supportive" ? 1 :
     RegimeStatus == "Opposing" ? -1 :
     0

GetFinalDirectionValue(TotalScoreValue, RatingValue, RegimeStatus) =>
    TotalDirection = TotalScoreValue > 0 ? 1 : TotalScoreValue < 0 ? -1 : 0
    TechnicalDirection = GetTechnicalDirection(RatingValue)
    RegimeDirection = GetRegimeDirection(RegimeStatus)
    FinalDirectionScore = TotalDirection * 2 + TechnicalDirection + RegimeDirection
    FinalDirectionScore > 0 ? 1 :
     FinalDirectionScore < 0 ? -1 :
     0

GetFinalBias(TotalScoreValue, RatingValue, RegimeStatus, VolatilityRatioValue) =>
    TotalDirection = TotalScoreValue > 0 ? 1 : TotalScoreValue < 0 ? -1 : 0
    TechnicalDirection = GetTechnicalDirection(RatingValue)
    RegimeDirection = GetRegimeDirection(RegimeStatus)
    FinalDirectionScore = TotalDirection * 2 + TechnicalDirection + RegimeDirection
    BaseBias = FinalDirectionScore >= 3 ? "Bullish / Confirmed" :
     FinalDirectionScore == 2 ? "Bullish / Partial" :
     FinalDirectionScore == 1 ? "Bullish / Weak" :
     FinalDirectionScore <= -3 ? "Bearish / Confirmed" :
     FinalDirectionScore == -2 ? "Bearish / Partial" :
     FinalDirectionScore == -1 ? "Bearish / Weak" :
     "Neutral / Mixed"
    na(VolatilityRatioValue) ? BaseBias :
     VolatilityRatioValue >= 1.6 ? BaseBias + " / High Risk" :
     BaseBias

GetFinalBiasBg(TotalScoreValue, RatingValue, RegimeStatus) =>
    TotalDirection = TotalScoreValue > 0 ? 1 : TotalScoreValue < 0 ? -1 : 0
    TechnicalDirection = GetTechnicalDirection(RatingValue)
    RegimeDirection = GetRegimeDirection(RegimeStatus)
    FinalDirectionScore = TotalDirection * 2 + TechnicalDirection + RegimeDirection
    FinalDirectionScore >= 2 ? BullishBgColor :
     FinalDirectionScore <= -2 ? BearishBgColor :
     TechnicalNeutralBgColor

GetTrendStrengthScore(TotalScoreValue, MaxMacroScoreValue, RatingValue, RegimeStatus) =>
    MacroComponent = MaxMacroScoreValue == 0.0 ? 0.0 : TotalScoreValue / MaxMacroScoreValue * 6.0
    TechnicalComponent = na(RatingValue) ? 0.0 : RatingValue * 2.0
    RegimeComponent = RegimeStatus == "Supportive" ? 2.0 :
     RegimeStatus == "Opposing" ? -2.0 :
     0.0
    RawScore = MacroComponent + TechnicalComponent + RegimeComponent
    int(math.round(math.max(math.min(RawScore, 10.0), -10.0)))

GetTrendStrengthText(TrendStrengthScore) =>
    TrendStrengthScore > 0 ? "+" + str.tostring(TrendStrengthScore) + " / 10" :
     str.tostring(TrendStrengthScore) + " / 10"

GetTrendStrengthStatus(TrendStrengthScore) =>
    TrendStrengthScore >= 8 ? "Very Strong Bullish" :
     TrendStrengthScore >= 5 ? "Strong Bullish" :
     TrendStrengthScore >= 2 ? "Moderate Bullish" :
     TrendStrengthScore <= -8 ? "Very Strong Bearish" :
     TrendStrengthScore <= -5 ? "Strong Bearish" :
     TrendStrengthScore <= -2 ? "Moderate Bearish" :
     "Neutral / Weak"

GetTrendStrengthBg(TrendStrengthScore) =>
    TrendStrengthScore > 0 ? BullishBgColor :
     TrendStrengthScore < 0 ? BearishBgColor :
     TechnicalNeutralBgColor

GetScoreDirection(Score) =>
    Score > 0 ? 1 :
     Score < 0 ? -1 :
     0

GetVolatilityDirection(Status) =>
    Status == "Extreme" ? 3 :
     Status == "Elevated" ? 2 :
     Status == "Normal" ? 1 :
     Status == "Low" ? -1 :
     0

GetTrackedDuration(Index, DirectionValue) =>
    PreviousDirection = array.get(DirectionStateArray, Index)
    PreviousStartTime = array.get(DirectionStartTimeArray, Index)
    Changed = na(PreviousDirection) or na(PreviousStartTime) or PreviousDirection != DirectionValue
    if Changed
        array.set(DirectionStateArray, Index, DirectionValue)
        array.set(DirectionStartTimeArray, Index, time)
        0
    else
        int(time - PreviousStartTime)

GetPriceAlertBg(PriceAlertPercentValue) =>
    na(PriceAlertPercentValue) ? NeutralBgColor :
     PriceAlertPercentValue > 0 ? PriceAlertBullishBgColor :
     PriceAlertPercentValue < 0 ? PriceAlertBearishBgColor :
     PriceAlertNeutralBgColor

GetVolumeDeltaBg(DeltaValue) =>
    na(DeltaValue) ? NeutralBgColor :
     DeltaValue > 0.0 ? PriceAlertBullishBgColor :
     DeltaValue < 0.0 ? PriceAlertBearishBgColor :
     PriceAlertNeutralBgColor

GetPriceAlertText(PriceAlertPercentValue, ThresholdPercent) =>
    na(PriceAlertPercentValue) ? "n/a" :
     PriceAlertPercentValue >= ThresholdPercent ? "+" + str.tostring(PriceAlertPercentValue, "#.##") + "% ALERT" :
     PriceAlertPercentValue <= -ThresholdPercent ? str.tostring(PriceAlertPercentValue, "#.##") + "% ALERT" :
     PriceAlertPercentValue > 0 ? "+" + str.tostring(PriceAlertPercentValue, "#.##") + "%" :
     str.tostring(PriceAlertPercentValue, "#.##") + "%"

GetPriceAlertMessagePart(SymbolName, PriceAlertPercentValue, ThresholdPercent, ExistingMessage) =>
    IsTriggered = not na(PriceAlertPercentValue) and math.abs(PriceAlertPercentValue) >= ThresholdPercent
    PrefixValue = str.length(ExistingMessage) > 0 ? " | " : ""
    SignedText = PriceAlertPercentValue > 0 ? "+" + str.tostring(PriceAlertPercentValue, "#.##") + "%" : str.tostring(PriceAlertPercentValue, "#.##") + "%"
    IsTriggered ? ExistingMessage + PrefixValue + SymbolName + " " + SignedText : ExistingMessage

FormatDuration(DurationMs) =>
    MinutesTotal = na(DurationMs) ? 0 : int(math.floor(DurationMs / 60000.0))
    DaysValue = int(math.floor(MinutesTotal / 1440.0))
    HoursValue = int(math.floor((MinutesTotal - DaysValue * 1440) / 60.0))
    MinutesValue = MinutesTotal - DaysValue * 1440 - HoursValue * 60
    na(DurationMs) ? "n/a" :
     DaysValue > 0 ? str.tostring(DaysValue) + "d " + str.tostring(HoursValue) + "h" :
     HoursValue > 0 ? str.tostring(HoursValue) + "h " + str.tostring(MinutesValue) + "m" :
     str.tostring(MinutesValue) + "m"

FormatValue(Value) =>
    na(Value) ? "n/a" : str.tostring(Value, "#.####")

FormatValueWithUnit(Value, UnitText) =>
    na(Value) ? "n/a" : str.tostring(Value, "#.####") + " " + UnitText

FormatPercent(Value) =>
    na(Value) ? "n/a" : str.tostring(Value, "#.##") + "%"

FormatRatio(Value) =>
    na(Value) ? "n/a" : str.tostring(Value, "#.##") + "x"

FormatRating(Value) =>
    na(Value) ? "n/a" : str.tostring(Value, "#.##")

FormatVolume(Value) =>
    na(Value) ? "n/a" :
     Value >= 1000000000.0 ? str.tostring(Value / 1000000000.0, "#.##") + "B" :
     Value >= 1000000.0 ? str.tostring(Value / 1000000.0, "#.##") + "M" :
     Value >= 1000.0 ? str.tostring(Value / 1000.0, "#.##") + "K" :
     str.tostring(Value, "#")

FormatSignedVolume(Value) =>
    na(Value) ? "n/a" :
     Value > 0.0 ? "+" + FormatVolume(Value) :
     Value < 0.0 ? "-" + FormatVolume(math.abs(Value)) :
     "0"

TextSize = GetTextSize(TableTextSize)

RealYield = GetValue(RealYieldSymbol, RealYieldTimeframe)
RealYieldAverage = GetAverage(RealYieldSymbol, RealYieldTimeframe, AverageLength)
Dxy = GetValue(DxySymbol, MacroTimeframe)
DxyAverage = GetAverage(DxySymbol, MacroTimeframe, AverageLength)
Us10Y = GetValue(Us10YSymbol, MacroTimeframe)
Us10YAverage = GetAverage(Us10YSymbol, MacroTimeframe, AverageLength)
Us02Y = GetValue(Us02YSymbol, MacroTimeframe)
Us02YAverage = GetAverage(Us02YSymbol, MacroTimeframe, AverageLength)
Tlt = GetValue(TltSymbol, MacroTimeframe)
TltAverage = GetAverage(TltSymbol, MacroTimeframe, AverageLength)
UsdJpy = GetValue(UsdJpySymbol, MacroTimeframe)
UsdJpyAverage = GetAverage(UsdJpySymbol, MacroTimeframe, AverageLength)
Silver = GetValue(SilverSymbol, MacroTimeframe)
SilverAverage = GetAverage(SilverSymbol, MacroTimeframe, AverageLength)
Gdx = GetValue(GdxSymbol, MacroTimeframe)
GdxAverage = GetAverage(GdxSymbol, MacroTimeframe, AverageLength)
Vix = GetValue(VixSymbol, MacroTimeframe)
VixAverage = GetAverage(VixSymbol, MacroTimeframe, AverageLength)
Hyg = GetValue(HygSymbol, MacroTimeframe)
HygAverage = GetAverage(HygSymbol, MacroTimeframe, AverageLength)

GoldPriceAlert = GetChartPriceAlertPercent(PriceAlertTimeframe)
RealYieldPriceAlert = GetPriceAlertPercent(RealYieldSymbol, PriceAlertTimeframe)
DxyPriceAlert = GetPriceAlertPercent(DxySymbol, PriceAlertTimeframe)
Us10YPriceAlert = GetPriceAlertPercent(Us10YSymbol, PriceAlertTimeframe)
Us02YPriceAlert = GetPriceAlertPercent(Us02YSymbol, PriceAlertTimeframe)
TltPriceAlert = GetPriceAlertPercent(TltSymbol, PriceAlertTimeframe)
UsdJpyPriceAlert = GetPriceAlertPercent(UsdJpySymbol, PriceAlertTimeframe)
SilverPriceAlert = GetPriceAlertPercent(SilverSymbol, PriceAlertTimeframe)
GdxPriceAlert = GetPriceAlertPercent(GdxSymbol, PriceAlertTimeframe)
VixPriceAlert = GetPriceAlertPercent(VixSymbol, PriceAlertTimeframe)
HygPriceAlert = GetPriceAlertPercent(HygSymbol, PriceAlertTimeframe)

GoldPriceMovementAlert = EnablePriceAlertSignals and not na(GoldPriceAlert) and math.abs(GoldPriceAlert) >= PriceAlertThresholdPercent
RealYieldPriceMovementAlert = EnablePriceAlertSignals and not na(RealYieldPriceAlert) and math.abs(RealYieldPriceAlert) >= PriceAlertThresholdPercent
DxyPriceMovementAlert = EnablePriceAlertSignals and not na(DxyPriceAlert) and math.abs(DxyPriceAlert) >= PriceAlertThresholdPercent
Us10YPriceMovementAlert = EnablePriceAlertSignals and not na(Us10YPriceAlert) and math.abs(Us10YPriceAlert) >= PriceAlertThresholdPercent
Us02YPriceMovementAlert = EnablePriceAlertSignals and not na(Us02YPriceAlert) and math.abs(Us02YPriceAlert) >= PriceAlertThresholdPercent
TltPriceMovementAlert = EnablePriceAlertSignals and not na(TltPriceAlert) and math.abs(TltPriceAlert) >= PriceAlertThresholdPercent
UsdJpyPriceMovementAlert = EnablePriceAlertSignals and not na(UsdJpyPriceAlert) and math.abs(UsdJpyPriceAlert) >= PriceAlertThresholdPercent
SilverPriceMovementAlert = EnablePriceAlertSignals and not na(SilverPriceAlert) and math.abs(SilverPriceAlert) >= PriceAlertThresholdPercent
GdxPriceMovementAlert = EnablePriceAlertSignals and not na(GdxPriceAlert) and math.abs(GdxPriceAlert) >= PriceAlertThresholdPercent
VixPriceMovementAlert = EnablePriceAlertSignals and not na(VixPriceAlert) and math.abs(VixPriceAlert) >= PriceAlertThresholdPercent
HygPriceMovementAlert = EnablePriceAlertSignals and not na(HygPriceAlert) and math.abs(HygPriceAlert) >= PriceAlertThresholdPercent

AnyPriceMovementAlert = GoldPriceMovementAlert or RealYieldPriceMovementAlert or DxyPriceMovementAlert or Us10YPriceMovementAlert or Us02YPriceMovementAlert or TltPriceMovementAlert or UsdJpyPriceMovementAlert or SilverPriceMovementAlert or GdxPriceMovementAlert or VixPriceMovementAlert or HygPriceMovementAlert

PriceAlertMessage = ""
PriceAlertMessage := GetPriceAlertMessagePart("Gold", GoldPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)
PriceAlertMessage := GetPriceAlertMessagePart("Real Yield", RealYieldPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)
PriceAlertMessage := GetPriceAlertMessagePart("DXY", DxyPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)
PriceAlertMessage := GetPriceAlertMessagePart("US10Y", Us10YPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)
PriceAlertMessage := GetPriceAlertMessagePart("US02Y", Us02YPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)
PriceAlertMessage := GetPriceAlertMessagePart("TLT", TltPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)
PriceAlertMessage := GetPriceAlertMessagePart("USDJPY", UsdJpyPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)
PriceAlertMessage := GetPriceAlertMessagePart("Silver", SilverPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)
PriceAlertMessage := GetPriceAlertMessagePart("GDX", GdxPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)
PriceAlertMessage := GetPriceAlertMessagePart("VIX", VixPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)
PriceAlertMessage := GetPriceAlertMessagePart("HYG", HygPriceAlert, PriceAlertThresholdPercent, PriceAlertMessage)

alertcondition(AnyPriceMovementAlert, "Gold Macro Price Movement Alert", "At least one monitored symbol exceeded the configured percentage threshold.")
alertcondition(GoldPriceMovementAlert, "Gold Price Movement Alert", "Gold exceeded the configured percentage threshold.")
alertcondition(RealYieldPriceMovementAlert, "Real Yield Price Movement Alert", "Real Yield exceeded the configured percentage threshold.")
alertcondition(DxyPriceMovementAlert, "DXY Price Movement Alert", "DXY exceeded the configured percentage threshold.")
alertcondition(Us10YPriceMovementAlert, "US10Y Price Movement Alert", "US10Y exceeded the configured percentage threshold.")
alertcondition(Us02YPriceMovementAlert, "US02Y Price Movement Alert", "US02Y exceeded the configured percentage threshold.")
alertcondition(TltPriceMovementAlert, "TLT Price Movement Alert", "TLT exceeded the configured percentage threshold.")
alertcondition(UsdJpyPriceMovementAlert, "USDJPY Price Movement Alert", "USDJPY exceeded the configured percentage threshold.")
alertcondition(SilverPriceMovementAlert, "Silver Price Movement Alert", "Silver exceeded the configured percentage threshold.")
alertcondition(GdxPriceMovementAlert, "GDX Price Movement Alert", "GDX exceeded the configured percentage threshold.")
alertcondition(VixPriceMovementAlert, "VIX Price Movement Alert", "VIX exceeded the configured percentage threshold.")
alertcondition(HygPriceMovementAlert, "HYG Price Movement Alert", "HYG exceeded the configured percentage threshold.")

if AnyPriceMovementAlert and barstate.isconfirmed
    alert("Gold Macro Price Movement Alert: " + PriceAlertMessage, alert.freq_once_per_bar_close)

[AskVolume1m, BidVolume1m, DeltaVolume1m, AverageDeltaVolume1m] = request.security(syminfo.tickerid, "1", [high == low ? volume * 0.5 : volume * (close - low) / (high - low), high == low ? volume * 0.5 : volume * (high - close) / (high - low), high == low ? 0.0 : volume * ((close - low) - (high - close)) / (high - low), ta.sma(high == low ? 0.0 : volume * ((close - low) - (high - close)) / (high - low), AverageDelta1mLookback)], barmerge.gaps_off, barmerge.lookahead_off)
[AskVolume5m, BidVolume5m, DeltaVolume5m, AverageDeltaVolume5m] = request.security(syminfo.tickerid, "5", [high == low ? volume * 0.5 : volume * (close - low) / (high - low), high == low ? volume * 0.5 : volume * (high - close) / (high - low), high == low ? 0.0 : volume * ((close - low) - (high - close)) / (high - low), ta.sma(high == low ? 0.0 : volume * ((close - low) - (high - close)) / (high - low), AverageDelta5mLookback)], barmerge.gaps_off, barmerge.lookahead_off)
[AskVolume15m, BidVolume15m, DeltaVolume15m, AverageDeltaVolume15m] = request.security(syminfo.tickerid, "15", [high == low ? volume * 0.5 : volume * (close - low) / (high - low), high == low ? volume * 0.5 : volume * (high - close) / (high - low), high == low ? 0.0 : volume * ((close - low) - (high - close)) / (high - low), ta.sma(high == low ? 0.0 : volume * ((close - low) - (high - close)) / (high - low), AverageDelta15mLookback)], barmerge.gaps_off, barmerge.lookahead_off)
[AskVolume1h, BidVolume1h, DeltaVolume1h, AverageDeltaVolume1h] = request.security(syminfo.tickerid, "60", [high == low ? volume * 0.5 : volume * (close - low) / (high - low), high == low ? volume * 0.5 : volume * (high - close) / (high - low), high == low ? 0.0 : volume * ((close - low) - (high - close)) / (high - low), ta.sma(high == low ? 0.0 : volume * ((close - low) - (high - close)) / (high - low), AverageDelta1hLookback)], barmerge.gaps_off, barmerge.lookahead_off)

NewSession = timeframe.change("D")
SessionAskBarVolume = high == low ? volume * 0.5 : volume * (close - low) / (high - low)
SessionBidBarVolume = high == low ? volume * 0.5 : volume * (high - close) / (high - low)

var float SessionVolume = na
var float SessionAskVolume = na
var float SessionBidVolume = na

if NewSession and not na(SessionAskVolume[1]) and not na(SessionBidVolume[1])
    array.unshift(SessionAskVolumeHistory, SessionAskVolume[1])
    array.unshift(SessionBidVolumeHistory, SessionBidVolume[1])
    array.unshift(SessionDeltaVolumeHistory, SessionAskVolume[1] - SessionBidVolume[1])
    if array.size(SessionAskVolumeHistory) > 500
        array.pop(SessionAskVolumeHistory)
    if array.size(SessionBidVolumeHistory) > 500
        array.pop(SessionBidVolumeHistory)
    if array.size(SessionDeltaVolumeHistory) > 500
        array.pop(SessionDeltaVolumeHistory)

SessionVolume := NewSession or na(SessionVolume[1]) ? volume : SessionVolume[1] + volume
SessionAskVolume := NewSession or na(SessionAskVolume[1]) ? SessionAskBarVolume : SessionAskVolume[1] + SessionAskBarVolume
SessionBidVolume := NewSession or na(SessionBidVolume[1]) ? SessionBidBarVolume : SessionBidVolume[1] + SessionBidBarVolume

SessionDeltaVolume = SessionAskVolume - SessionBidVolume
AverageSessionAskVolume = GetArrayAverage(SessionAskVolumeHistory, SessionAverageVolumeLookback)
AverageSessionBidVolume = GetArrayAverage(SessionBidVolumeHistory, SessionAverageVolumeLookback)
AverageSessionVolume = na(AverageSessionAskVolume) or na(AverageSessionBidVolume) ? na : AverageSessionAskVolume + AverageSessionBidVolume
AverageSessionDeltaVolume = GetArrayAverage(SessionDeltaVolumeHistory, SessionAverageVolumeLookback)

[TechnicalRatingTotal, TechnicalRatingOscillators, TechnicalRatingMovingAverages] = request.security(syminfo.tickerid, TechnicalRatingTimeframe, TechnicalRating.calcRatingAll(), barmerge.gaps_off, barmerge.lookahead_off)

VolatilityAtrPercent = request.security(syminfo.tickerid, MacroTimeframe, ta.atr(AtrLength) / close * 100.0, barmerge.gaps_off, barmerge.lookahead_off)
VolatilityAtrPercentAverage = request.security(syminfo.tickerid, MacroTimeframe, ta.sma(ta.atr(AtrLength) / close * 100.0, AverageLength), barmerge.gaps_off, barmerge.lookahead_off)
VolatilityRatio = na(VolatilityAtrPercent) or na(VolatilityAtrPercentAverage) or VolatilityAtrPercentAverage == 0.0 ? na : VolatilityAtrPercent / VolatilityAtrPercentAverage
VolatilityStatus = GetVolatilityStatus(VolatilityRatio)

RealYieldScore = GetScore(RealYield, RealYieldAverage, false, RealYieldWeight)
DxyScore = GetScore(Dxy, DxyAverage, false, DxyWeight)
Us10YScore = GetScore(Us10Y, Us10YAverage, false, Us10YWeight)
Us02YScore = GetScore(Us02Y, Us02YAverage, false, Us02YWeight)
TltScore = GetScore(Tlt, TltAverage, true, TltWeight)
UsdJpyScore = GetScore(UsdJpy, UsdJpyAverage, false, UsdJpyWeight)
SilverScore = GetScore(Silver, SilverAverage, true, SilverWeight)
GdxScore = GetScore(Gdx, GdxAverage, true, GdxWeight)
VixScore = GetScore(Vix, VixAverage, true, VixWeight)
HygScore = GetScore(Hyg, HygAverage, true, HygWeight)

TotalScore = RealYieldScore + DxyScore + Us10YScore + Us02YScore + TltScore + UsdJpyScore + SilverScore + GdxScore + VixScore + HygScore
MacroGoldStatus = GetStatus(TotalScore)
MaxMacroScore = RealYieldWeight + DxyWeight + Us10YWeight + Us02YWeight + TltWeight + UsdJpyWeight + SilverWeight + GdxWeight + VixWeight + HygWeight

RealYieldStrong = RealYield > RealYieldAverage
RealYieldWeak = RealYield < RealYieldAverage
DxyStrong = Dxy > DxyAverage
DxyWeak = Dxy < DxyAverage
Us10YStrong = Us10Y > Us10YAverage
Us10YWeak = Us10Y < Us10YAverage
Us02YStrong = Us02Y > Us02YAverage
Us02YWeak = Us02Y < Us02YAverage
TltStrong = Tlt > TltAverage
TltWeak = Tlt < TltAverage
UsdJpyStrong = UsdJpy > UsdJpyAverage
UsdJpyWeak = UsdJpy < UsdJpyAverage
SilverStrong = Silver > SilverAverage
SilverWeak = Silver < SilverAverage
GdxStrong = Gdx > GdxAverage
GdxWeak = Gdx < GdxAverage
VixStrong = Vix > VixAverage
VixWeak = Vix < VixAverage
HygStrong = Hyg > HygAverage
HygWeak = Hyg < HygAverage

SafeHavenScore = GetBoolScore(VixStrong) + GetBoolScore(HygWeak) + GetBoolScore(GdxStrong) + GetBoolScore(DxyStrong) + GetBoolScore(TltStrong)
YieldPressureScore = GetBoolScore(RealYieldStrong) + GetBoolScore(Us10YStrong) + GetBoolScore(Us02YStrong) + GetBoolScore(TltWeak) + GetBoolScore(UsdJpyStrong) + GetBoolScore(DxyStrong)
DollarPressureScore = GetBoolScore(DxyStrong) + GetBoolScore(UsdJpyStrong) + GetBoolScore(RealYieldStrong)
InflationHedgeScore = GetBoolScore(SilverStrong) + GetBoolScore(GdxStrong) + GetBoolScore(DxyWeak) + GetBoolScore(RealYieldWeak)
YieldReliefScore = GetBoolScore(RealYieldWeak) + GetBoolScore(Us10YWeak) + GetBoolScore(Us02YWeak) + GetBoolScore(TltStrong) + GetBoolScore(UsdJpyWeak) + GetBoolScore(DxyWeak)

MarketRegimeMaxScore = math.max(math.max(math.max(math.max(SafeHavenScore, YieldPressureScore), DollarPressureScore), InflationHedgeScore), YieldReliefScore)
MarketRegime = GetMarketRegime(SafeHavenScore, YieldPressureScore, DollarPressureScore, InflationHedgeScore, YieldReliefScore)
MarketRegimeStatus = GetMarketRegimeStatus(MarketRegime)
MarketRegimeConfirmation = GetMarketRegimeConfirmation(MarketRegimeMaxScore)

FinalGoldBias = GetFinalBias(TotalScore, TechnicalRatingTotal, MarketRegimeStatus, VolatilityRatio)
FinalGoldBiasBg = GetFinalBiasBg(TotalScore, TechnicalRatingTotal, MarketRegimeStatus)
GoldTrendStrengthScore = GetTrendStrengthScore(TotalScore, MaxMacroScore, TechnicalRatingTotal, MarketRegimeStatus)
GoldTrendStrengthStatus = GetTrendStrengthStatus(GoldTrendStrengthScore)
GoldTrendStrengthBg = GetTrendStrengthBg(GoldTrendStrengthScore)

RealYieldDuration = GetTrackedDuration(0, GetScoreDirection(RealYieldScore))
DxyDuration = GetTrackedDuration(1, GetScoreDirection(DxyScore))
Us10YDuration = GetTrackedDuration(2, GetScoreDirection(Us10YScore))
Us02YDuration = GetTrackedDuration(3, GetScoreDirection(Us02YScore))
TltDuration = GetTrackedDuration(4, GetScoreDirection(TltScore))
UsdJpyDuration = GetTrackedDuration(5, GetScoreDirection(UsdJpyScore))
SilverDuration = GetTrackedDuration(6, GetScoreDirection(SilverScore))
GdxDuration = GetTrackedDuration(7, GetScoreDirection(GdxScore))
VixDuration = GetTrackedDuration(8, GetScoreDirection(VixScore))
HygDuration = GetTrackedDuration(9, GetScoreDirection(HygScore))
MacroGoldDuration = GetTrackedDuration(10, GetScoreDirection(TotalScore))
VolatilityDuration = GetTrackedDuration(11, GetVolatilityDirection(VolatilityStatus))
TechnicalGoldDuration = GetTrackedDuration(12, GetTechnicalDirection(TechnicalRatingTotal))
MarketRegimeDuration = GetTrackedDuration(13, GetRegimeDirection(MarketRegimeStatus))
FinalGoldDirection = GetFinalDirectionValue(TotalScore, TechnicalRatingTotal, MarketRegimeStatus)
FinalGoldTrendState = FinalGoldDirection * 100 + GoldTrendStrengthScore
FinalGoldTrendDuration = GetTrackedDuration(14, FinalGoldTrendState)

var BiasTable = table.new(GetPosition(TablePosition), 8, 24, border_width=1, frame_width=1, border_color=LineColor, frame_color=LineColor)

if barstate.islast
    table.cell(BiasTable, 0, 0, "Volatility", text_color=TextColor, bgcolor=GroupBgColor, text_halign=text.align_center, text_valign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 0, 1, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 0, 0, 0, 1)
    table.cell(BiasTable, 1, 0, "Current ATR %", width=CurrentWidth, text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 2, 0, "Average ATR %", width=AverageWidth, text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 3, 0, "Current / Average", width=CurrentWidth, text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 4, 0, "Condition", width=BiasWidth, text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 5, 0, "", bgcolor=VolatilityHeaderBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 4, 0, 5, 0)
    table.cell(BiasTable, 6, 0, "Duration", width=DurationWidth, text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 7, 0, "", bgcolor=VolatilityHeaderBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 6, 0, 7, 0)
    table.cell(BiasTable, 1, 1, FormatPercent(VolatilityAtrPercent), text_color=TextColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 2, 1, FormatPercent(VolatilityAtrPercentAverage), text_color=TextColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 3, 1, FormatRatio(VolatilityRatio), text_color=TextColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 4, 1, VolatilityStatus, text_color=TextColor, bgcolor=GetVolatilityBg(VolatilityRatio), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 5, 1, "", bgcolor=GetVolatilityBg(VolatilityRatio), text_size=TextSize)
    table.merge_cells(BiasTable, 4, 1, 5, 1)
    table.cell(BiasTable, 6, 1, FormatDuration(VolatilityDuration), text_color=TextColor, bgcolor=GetVolatilityBg(VolatilityRatio), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 7, 1, "", bgcolor=GetVolatilityBg(VolatilityRatio), text_size=TextSize)
    table.merge_cells(BiasTable, 6, 1, 7, 1)

    table.cell(BiasTable, 0, 2, "Volume", text_color=TextColor, bgcolor=GroupBgColor, text_halign=text.align_center, text_valign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 0, 3, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.cell(BiasTable, 0, 4, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 0, 2, 0, 4)
    table.cell(BiasTable, 1, 2, "Session Ask", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 2, 2, "Session Bid", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 3, 2, "Session Delta", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 4, 2, "1m Delta", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 5, 2, "5m Delta", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 6, 2, "15m Delta", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 7, 2, "1h Delta", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)

    table.cell(BiasTable, 1, 3, FormatVolume(SessionAskVolume), text_color=TextColor, bgcolor=PriceAlertBullishBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 2, 3, FormatVolume(SessionBidVolume), text_color=TextColor, bgcolor=PriceAlertBearishBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 3, 3, FormatSignedVolume(SessionDeltaVolume), text_color=TextColor, bgcolor=GetVolumeDeltaBg(SessionDeltaVolume), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 4, 3, FormatSignedVolume(DeltaVolume1m), text_color=TextColor, bgcolor=GetVolumeDeltaBg(DeltaVolume1m), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 5, 3, FormatSignedVolume(DeltaVolume5m), text_color=TextColor, bgcolor=GetVolumeDeltaBg(DeltaVolume5m), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 6, 3, FormatSignedVolume(DeltaVolume15m), text_color=TextColor, bgcolor=GetVolumeDeltaBg(DeltaVolume15m), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 7, 3, FormatSignedVolume(DeltaVolume1h), text_color=TextColor, bgcolor=GetVolumeDeltaBg(DeltaVolume1h), text_halign=text.align_center, text_size=TextSize)

    table.cell(BiasTable, 1, 4, "Avg Session Vol " + str.tostring(SessionAverageVolumeLookback) + "S: " + FormatVolume(AverageSessionVolume), text_color=TextColor, bgcolor=NeutralBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 2, 4, "", bgcolor=NeutralBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 1, 4, 2, 4)
    table.cell(BiasTable, 3, 4, "Avg Δ " + str.tostring(SessionAverageVolumeLookback) + "S: " + FormatSignedVolume(AverageSessionDeltaVolume), text_color=TextColor, bgcolor=GetVolumeDeltaBg(AverageSessionDeltaVolume), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 4, 4, "Avg Δ " + str.tostring(AverageDelta1mLookback) + ": " + FormatSignedVolume(AverageDeltaVolume1m), text_color=TextColor, bgcolor=GetVolumeDeltaBg(AverageDeltaVolume1m), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 5, 4, "Avg Δ " + str.tostring(AverageDelta5mLookback) + ": " + FormatSignedVolume(AverageDeltaVolume5m), text_color=TextColor, bgcolor=GetVolumeDeltaBg(AverageDeltaVolume5m), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 6, 4, "Avg Δ " + str.tostring(AverageDelta15mLookback) + ": " + FormatSignedVolume(AverageDeltaVolume15m), text_color=TextColor, bgcolor=GetVolumeDeltaBg(AverageDeltaVolume15m), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 7, 4, "Avg Δ " + str.tostring(AverageDelta1hLookback) + ": " + FormatSignedVolume(AverageDeltaVolume1h), text_color=TextColor, bgcolor=GetVolumeDeltaBg(AverageDeltaVolume1h), text_halign=text.align_center, text_size=TextSize)

    table.cell(BiasTable, 0, 5, "", height=SpacerHeight, bgcolor=SpacerBgColor, text_size=size.tiny)
    table.cell(BiasTable, 1, 5, "", height=SpacerHeight, bgcolor=SpacerBgColor, text_size=size.tiny)
    table.cell(BiasTable, 2, 5, "", height=SpacerHeight, bgcolor=SpacerBgColor, text_size=size.tiny)
    table.cell(BiasTable, 3, 5, "", height=SpacerHeight, bgcolor=SpacerBgColor, text_size=size.tiny)
    table.cell(BiasTable, 4, 5, "", height=SpacerHeight, bgcolor=SpacerBgColor, text_size=size.tiny)
    table.cell(BiasTable, 5, 5, "", height=SpacerHeight, bgcolor=SpacerBgColor, text_size=size.tiny)
    table.cell(BiasTable, 6, 5, "", height=SpacerHeight, bgcolor=SpacerBgColor, text_size=size.tiny)
    table.cell(BiasTable, 7, 5, "", height=SpacerHeight, bgcolor=SpacerBgColor, text_size=size.tiny)
    table.merge_cells(BiasTable, 0, 5, 7, 5)

    table.cell(BiasTable, 0, 6, "Group", width=GroupWidth, text_color=TextColor, bgcolor=HeaderBgColor, text_size=TextSize)
    table.cell(BiasTable, 1, 6, "Symbol", width=SymbolWidth, text_color=TextColor, bgcolor=HeaderBgColor, text_size=TextSize)
    table.cell(BiasTable, 2, 6, "Current", width=CurrentWidth, text_color=TextColor, bgcolor=HeaderBgColor, text_size=TextSize)
    table.cell(BiasTable, 3, 6, "Average", width=AverageWidth, text_color=TextColor, bgcolor=HeaderBgColor, text_size=TextSize)
    table.cell(BiasTable, 4, 6, "Score", width=ScoreWidth, text_color=TextColor, bgcolor=HeaderBgColor, text_size=TextSize)
    table.cell(BiasTable, 5, 6, "Bias", width=BiasWidth, text_color=TextColor, bgcolor=HeaderBgColor, text_size=TextSize)
    table.cell(BiasTable, 6, 6, "Duration", width=DurationWidth, text_color=TextColor, bgcolor=HeaderBgColor, text_size=TextSize)
    table.cell(BiasTable, 7, 6, "Price Alert", width=PriceAlertWidth, text_color=TextColor, bgcolor=HeaderBgColor, text_size=TextSize)

    table.cell(BiasTable, 0, 7, "Core Macro", text_color=TextColor, bgcolor=GroupBgColor, text_halign=text.align_center, text_valign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 0, 8, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.cell(BiasTable, 0, 9, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.cell(BiasTable, 0, 10, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.cell(BiasTable, 0, 11, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.cell(BiasTable, 0, 12, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 0, 7, 0, 12)

    table.cell(BiasTable, 1, 7, "Real Yield", text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 2, 7, FormatValueWithUnit(RealYield, "%"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 3, 7, FormatValueWithUnit(RealYieldAverage, "%"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 4, 7, str.tostring(RealYieldScore), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 5, 7, GetShortStatus(RealYieldScore), text_color=TextColor, bgcolor=GetBg(RealYieldScore), text_size=TextSize)
    table.cell(BiasTable, 6, 7, FormatDuration(RealYieldDuration), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 7, 7, GetPriceAlertText(RealYieldPriceAlert, PriceAlertThresholdPercent), text_color=TextColor, bgcolor=GetPriceAlertBg(RealYieldPriceAlert), text_size=TextSize)

    table.cell(BiasTable, 1, 8, "DXY", text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 2, 8, FormatValueWithUnit(Dxy, "idx"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 3, 8, FormatValueWithUnit(DxyAverage, "idx"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 4, 8, str.tostring(DxyScore), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 5, 8, GetShortStatus(DxyScore), text_color=TextColor, bgcolor=GetBg(DxyScore), text_size=TextSize)
    table.cell(BiasTable, 6, 8, FormatDuration(DxyDuration), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 7, 8, GetPriceAlertText(DxyPriceAlert, PriceAlertThresholdPercent), text_color=TextColor, bgcolor=GetPriceAlertBg(DxyPriceAlert), text_size=TextSize)

    table.cell(BiasTable, 1, 9, "US10Y", text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 2, 9, FormatValueWithUnit(Us10Y, "%"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 3, 9, FormatValueWithUnit(Us10YAverage, "%"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 4, 9, str.tostring(Us10YScore), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 5, 9, GetShortStatus(Us10YScore), text_color=TextColor, bgcolor=GetBg(Us10YScore), text_size=TextSize)
    table.cell(BiasTable, 6, 9, FormatDuration(Us10YDuration), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 7, 9, GetPriceAlertText(Us10YPriceAlert, PriceAlertThresholdPercent), text_color=TextColor, bgcolor=GetPriceAlertBg(Us10YPriceAlert), text_size=TextSize)

    table.cell(BiasTable, 1, 10, "US02Y", text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 2, 10, FormatValueWithUnit(Us02Y, "%"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 3, 10, FormatValueWithUnit(Us02YAverage, "%"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 4, 10, str.tostring(Us02YScore), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 5, 10, GetShortStatus(Us02YScore), text_color=TextColor, bgcolor=GetBg(Us02YScore), text_size=TextSize)
    table.cell(BiasTable, 6, 10, FormatDuration(Us02YDuration), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 7, 10, GetPriceAlertText(Us02YPriceAlert, PriceAlertThresholdPercent), text_color=TextColor, bgcolor=GetPriceAlertBg(Us02YPriceAlert), text_size=TextSize)

    table.cell(BiasTable, 1, 11, "TLT", text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 2, 11, FormatValueWithUnit(Tlt, "USD"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 3, 11, FormatValueWithUnit(TltAverage, "USD"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 4, 11, str.tostring(TltScore), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 5, 11, GetShortStatus(TltScore), text_color=TextColor, bgcolor=GetBg(TltScore), text_size=TextSize)
    table.cell(BiasTable, 6, 11, FormatDuration(TltDuration), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 7, 11, GetPriceAlertText(TltPriceAlert, PriceAlertThresholdPercent), text_color=TextColor, bgcolor=GetPriceAlertBg(TltPriceAlert), text_size=TextSize)

    table.cell(BiasTable, 1, 12, "USDJPY", text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 2, 12, FormatValueWithUnit(UsdJpy, "JPY"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 3, 12, FormatValueWithUnit(UsdJpyAverage, "JPY"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 4, 12, str.tostring(UsdJpyScore), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 5, 12, GetShortStatus(UsdJpyScore), text_color=TextColor, bgcolor=GetBg(UsdJpyScore), text_size=TextSize)
    table.cell(BiasTable, 6, 12, FormatDuration(UsdJpyDuration), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 7, 12, GetPriceAlertText(UsdJpyPriceAlert, PriceAlertThresholdPercent), text_color=TextColor, bgcolor=GetPriceAlertBg(UsdJpyPriceAlert), text_size=TextSize)

    table.cell(BiasTable, 0, 13, "Confirmation", text_color=TextColor, bgcolor=GroupBgColor, text_halign=text.align_center, text_valign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 0, 14, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 0, 13, 0, 14)

    table.cell(BiasTable, 1, 13, "Silver", text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 2, 13, FormatValueWithUnit(Silver, "USD/oz"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 3, 13, FormatValueWithUnit(SilverAverage, "USD/oz"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 4, 13, str.tostring(SilverScore), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 5, 13, GetShortStatus(SilverScore), text_color=TextColor, bgcolor=GetBg(SilverScore), text_size=TextSize)
    table.cell(BiasTable, 6, 13, FormatDuration(SilverDuration), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 7, 13, GetPriceAlertText(SilverPriceAlert, PriceAlertThresholdPercent), text_color=TextColor, bgcolor=GetPriceAlertBg(SilverPriceAlert), text_size=TextSize)

    table.cell(BiasTable, 1, 14, "GDX", text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 2, 14, FormatValueWithUnit(Gdx, "USD"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 3, 14, FormatValueWithUnit(GdxAverage, "USD"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 4, 14, str.tostring(GdxScore), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 5, 14, GetShortStatus(GdxScore), text_color=TextColor, bgcolor=GetBg(GdxScore), text_size=TextSize)
    table.cell(BiasTable, 6, 14, FormatDuration(GdxDuration), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 7, 14, GetPriceAlertText(GdxPriceAlert, PriceAlertThresholdPercent), text_color=TextColor, bgcolor=GetPriceAlertBg(GdxPriceAlert), text_size=TextSize)

    table.cell(BiasTable, 0, 15, "Risk Context", text_color=TextColor, bgcolor=GroupBgColor, text_halign=text.align_center, text_valign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 0, 16, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 0, 15, 0, 16)

    table.cell(BiasTable, 1, 15, "VIX", text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 2, 15, FormatValueWithUnit(Vix, "idx"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 3, 15, FormatValueWithUnit(VixAverage, "idx"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 4, 15, str.tostring(VixScore), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 5, 15, GetShortStatus(VixScore), text_color=TextColor, bgcolor=GetBg(VixScore), text_size=TextSize)
    table.cell(BiasTable, 6, 15, FormatDuration(VixDuration), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 7, 15, GetPriceAlertText(VixPriceAlert, PriceAlertThresholdPercent), text_color=TextColor, bgcolor=GetPriceAlertBg(VixPriceAlert), text_size=TextSize)

    table.cell(BiasTable, 1, 16, "HYG", text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 2, 16, FormatValueWithUnit(Hyg, "USD"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 3, 16, FormatValueWithUnit(HygAverage, "USD"), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 4, 16, str.tostring(HygScore), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 5, 16, GetShortStatus(HygScore), text_color=TextColor, bgcolor=GetBg(HygScore), text_size=TextSize)
    table.cell(BiasTable, 6, 16, FormatDuration(HygDuration), text_color=TextColor, text_size=TextSize)
    table.cell(BiasTable, 7, 16, GetPriceAlertText(HygPriceAlert, PriceAlertThresholdPercent), text_color=TextColor, bgcolor=GetPriceAlertBg(HygPriceAlert), text_size=TextSize)

    table.cell(BiasTable, 0, 17, "Macro Gold Bias: " + str.tostring(TotalScore) + " | " + MacroGoldStatus + " | Duration: " + FormatDuration(MacroGoldDuration), width=GroupWidth + SymbolWidth + CurrentWidth + AverageWidth + ScoreWidth + BiasWidth + DurationWidth, text_color=TextColor, bgcolor=GetBg(TotalScore), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 1, 17, "", bgcolor=GetBg(TotalScore), text_size=TextSize)
    table.cell(BiasTable, 2, 17, "", bgcolor=GetBg(TotalScore), text_size=TextSize)
    table.cell(BiasTable, 3, 17, "", bgcolor=GetBg(TotalScore), text_size=TextSize)
    table.cell(BiasTable, 4, 17, "", bgcolor=GetBg(TotalScore), text_size=TextSize)
    table.cell(BiasTable, 5, 17, "", bgcolor=GetBg(TotalScore), text_size=TextSize)
    table.cell(BiasTable, 6, 17, "", bgcolor=GetBg(TotalScore), text_size=TextSize)
    table.merge_cells(BiasTable, 0, 17, 6, 17)
    table.cell(BiasTable, 7, 17, GetPriceAlertText(GoldPriceAlert, PriceAlertThresholdPercent), width=PriceAlertWidth, text_color=TextColor, bgcolor=GetPriceAlertBg(GoldPriceAlert), text_halign=text.align_center, text_size=TextSize)

    table.cell(BiasTable, 0, 18, "Technical Gold Bias", text_color=TextColor, bgcolor=GroupBgColor, text_halign=text.align_center, text_valign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 0, 19, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 0, 18, 0, 19)

    table.cell(BiasTable, 1, 18, "Combined", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 2, 18, "Oscillators", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 3, 18, "Moving Averages", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 4, 18, "Condition", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 5, 18, "", bgcolor=VolatilityHeaderBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 4, 18, 5, 18)
    table.cell(BiasTable, 6, 18, "Duration", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 7, 18, "", bgcolor=VolatilityHeaderBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 6, 18, 7, 18)

    table.cell(BiasTable, 1, 19, FormatRating(TechnicalRatingTotal), text_color=TextColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 2, 19, FormatRating(TechnicalRatingOscillators), text_color=TextColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 3, 19, FormatRating(TechnicalRatingMovingAverages), text_color=TextColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 4, 19, GetTechnicalRatingStatus(TechnicalRatingTotal), text_color=TextColor, bgcolor=GetTechnicalRatingBg(TechnicalRatingTotal), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 5, 19, "", bgcolor=GetTechnicalRatingBg(TechnicalRatingTotal), text_size=TextSize)
    table.merge_cells(BiasTable, 4, 19, 5, 19)
    table.cell(BiasTable, 6, 19, FormatDuration(TechnicalGoldDuration), text_color=TextColor, bgcolor=GetTechnicalRatingBg(TechnicalRatingTotal), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 7, 19, "", bgcolor=GetTechnicalRatingBg(TechnicalRatingTotal), text_size=TextSize)
    table.merge_cells(BiasTable, 6, 19, 7, 19)

    table.cell(BiasTable, 0, 20, "Market Regime", text_color=TextColor, bgcolor=GroupBgColor, text_halign=text.align_center, text_valign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 0, 21, "", bgcolor=GroupBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 0, 20, 0, 21)

    table.cell(BiasTable, 1, 20, "Regime", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 2, 20, "Confirmation", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 3, 20, "Score", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 4, 20, "Condition", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 5, 20, "", bgcolor=VolatilityHeaderBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 4, 20, 5, 20)
    table.cell(BiasTable, 6, 20, "Duration", text_color=TextColor, bgcolor=VolatilityHeaderBgColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 7, 20, "", bgcolor=VolatilityHeaderBgColor, text_size=TextSize)
    table.merge_cells(BiasTable, 6, 20, 7, 20)

    table.cell(BiasTable, 1, 21, MarketRegime, text_color=TextColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 2, 21, MarketRegimeConfirmation, text_color=TextColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 3, 21, str.tostring(MarketRegimeMaxScore), text_color=TextColor, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 4, 21, MarketRegimeStatus, text_color=TextColor, bgcolor=GetMarketRegimeBg(MarketRegimeStatus), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 5, 21, "", bgcolor=GetMarketRegimeBg(MarketRegimeStatus), text_size=TextSize)
    table.merge_cells(BiasTable, 4, 21, 5, 21)
    table.cell(BiasTable, 6, 21, FormatDuration(MarketRegimeDuration), text_color=TextColor, bgcolor=GetMarketRegimeBg(MarketRegimeStatus), text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 7, 21, "", bgcolor=GetMarketRegimeBg(MarketRegimeStatus), text_size=TextSize)
    table.merge_cells(BiasTable, 6, 21, 7, 21)

    table.cell(BiasTable, 0, 22, "Final Gold Bias: " + FinalGoldBias, width=GroupWidth + SymbolWidth + CurrentWidth + AverageWidth + ScoreWidth + BiasWidth, text_color=TextColor, bgcolor=FinalGoldBiasBg, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 1, 22, "", bgcolor=FinalGoldBiasBg, text_size=TextSize)
    table.cell(BiasTable, 2, 22, "", bgcolor=FinalGoldBiasBg, text_size=TextSize)
    table.cell(BiasTable, 3, 22, "", bgcolor=FinalGoldBiasBg, text_size=TextSize)
    table.cell(BiasTable, 4, 22, "", bgcolor=FinalGoldBiasBg, text_size=TextSize)
    table.cell(BiasTable, 5, 22, "", bgcolor=FinalGoldBiasBg, text_size=TextSize)
    table.merge_cells(BiasTable, 0, 22, 5, 22)

    table.cell(BiasTable, 0, 23, "Gold Trend Strength: " + GetTrendStrengthText(GoldTrendStrengthScore) + " | " + GoldTrendStrengthStatus, width=GroupWidth + SymbolWidth + CurrentWidth + AverageWidth + ScoreWidth + BiasWidth, text_color=TextColor, bgcolor=GoldTrendStrengthBg, text_halign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 1, 23, "", bgcolor=GoldTrendStrengthBg, text_size=TextSize)
    table.cell(BiasTable, 2, 23, "", bgcolor=GoldTrendStrengthBg, text_size=TextSize)
    table.cell(BiasTable, 3, 23, "", bgcolor=GoldTrendStrengthBg, text_size=TextSize)
    table.cell(BiasTable, 4, 23, "", bgcolor=GoldTrendStrengthBg, text_size=TextSize)
    table.cell(BiasTable, 5, 23, "", bgcolor=GoldTrendStrengthBg, text_size=TextSize)
    table.merge_cells(BiasTable, 0, 23, 5, 23)

    table.cell(BiasTable, 6, 22, "Duration: " + FormatDuration(FinalGoldTrendDuration), width=DurationWidth + PriceAlertWidth, text_color=TextColor, bgcolor=FinalGoldBiasBg, text_halign=text.align_center, text_valign=text.align_center, text_size=TextSize)
    table.cell(BiasTable, 7, 22, "", bgcolor=FinalGoldBiasBg, text_size=TextSize)
    table.cell(BiasTable, 6, 23, "", bgcolor=GoldTrendStrengthBg, text_size=TextSize)
    table.cell(BiasTable, 7, 23, "", bgcolor=GoldTrendStrengthBg, text_size=TextSize)
    table.merge_cells(BiasTable, 6, 22, 7, 23)
````
