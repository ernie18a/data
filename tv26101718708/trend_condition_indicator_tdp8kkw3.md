# Trend Condition Indicator

- url: https://www.tradingview.com/script/TDP8kKw3/
- type: indicator
- pine_id: PUB;bf1431b36fb546bcaed969d2f76e4f2c
- version: 1.0

## Description

日足、4時間足におすすめ。
基準線、20SMAとローソク足終値の位置関係からトレンドかレンジかを判定し、チャートに表示します。
執行足だけ見てて、基準線に逆らったトレードをしてしまう自分への戒めのために作りました。

## Source Code

````pine
//@version=6
indicator("Trend Condition Indicator", shorttitle = "Trend Condition", overlay = true)
const int TREND_DOWN = -1
const int TREND_RANGE = 0
const int TREND_UP = 1
const int TREND_NONE = 2
const int TREND_WAIT = 3
groupConditions = "Conditions"
bool useKijun = input.bool(true, "基準線判定を使用", group = groupConditions)
int kijunLength = input.int(26, "基準線期間", minval = 1, group = groupConditions)
float kijunRangePips = input.float(5.0, "基準線レンジ判定幅 (pips)", minval = 0.0, step = 0.1, group = groupConditions)
bool useSma = input.bool(true, "20SMA判定を使用", group = groupConditions)
int smaLength = input.int(20, "SMA期間", minval = 1, group = groupConditions)
float smaSlopeRangePips = input.float(1.0, "SMA傾きレンジ判定幅 (pips)", minval = 0.0, step = 0.1, group = groupConditions)
groupPips = "Pip Settings"
string pipSizeMode = input.string("Auto", "1 pipの価格幅", options = ["Auto", "Manual"], group = groupPips)
float manualPipSize = input.float(0.0001, "Manual時の1 pip価格幅", minval = 0.00000001, step = 0.00000001, group = groupPips)
groupDisplay = "Display"
bool showKijunLine = input.bool(true, "基準線を表示", group = groupDisplay)
bool showSmaLine = input.bool(true, "SMAを表示", group = groupDisplay)
string tableSizeInput = input.string("Large", "表示サイズ", options = ["Small", "Normal", "Large", "Huge"], group = groupDisplay)
float autoPipSize = syminfo.type == "forex" ? (syminfo.currency == "JPY" ? 0.01 : 0.0001) : syminfo.mintick
float pipSize = pipSizeMode == "Auto" ? autoPipSize : manualPipSize
float kijunTolerance = kijunRangePips * pipSize
float smaSlopeTolerance = smaSlopeRangePips * pipSize
float kijun = (ta.highest(high, kijunLength) + ta.lowest(low, kijunLength)) / 2.0
float smaValue = ta.sma(close, smaLength)
float smaSlope = smaValue - smaValue[1]
f_kijunTrend(float closeValue, float lineValue, float tolerance) =>
    if na(lineValue)
        TREND_WAIT
    else if math.abs(closeValue - lineValue) <= tolerance
        TREND_RANGE
    else if closeValue > lineValue
        TREND_UP
    else
        TREND_DOWN
f_smaTrend(float slopeValue, float tolerance) =>
    if na(slopeValue)
        TREND_WAIT
    else if math.abs(slopeValue) <= tolerance
        TREND_RANGE
    else if slopeValue > 0
        TREND_UP
    else
        TREND_DOWN
f_textSize(string sizeInput) =>
    switch sizeInput
        "Small" => size.small
        "Normal" => size.normal
        "Huge" => size.huge
        => size.large
f_trendText(int trend) =>
    switch trend
        TREND_UP => "上昇トレンド"
        TREND_DOWN => "下降トレンド"
        TREND_RANGE => "レンジ"
        TREND_NONE => "条件未選択"
        => "計算中"
f_trendColor(int trend) =>
    switch trend
        TREND_UP => color.new(color.green, 0)
        TREND_DOWN => color.new(color.red, 0)
        TREND_RANGE => color.new(color.gray, 0)
        TREND_NONE => color.new(color.gray, 35)
        => color.new(color.orange, 0)
int kijunTrend = f_kijunTrend(close, kijun, kijunTolerance)
int smaTrend = f_smaTrend(smaSlope, smaSlopeTolerance)
int activeConditionCount = (useKijun ? 1 : 0) + (useSma ? 1 : 0)
bool hasWaitingCondition = (useKijun and kijunTrend == TREND_WAIT) or (useSma and smaTrend == TREND_WAIT)
int finalTrend = TREND_NONE
if activeConditionCount == 0
    finalTrend := TREND_NONE
else if hasWaitingCondition
    finalTrend := TREND_WAIT
else if useKijun and useSma
    finalTrend := kijunTrend == smaTrend ? kijunTrend : TREND_RANGE
else
    finalTrend := useKijun ? kijunTrend : smaTrend
plot(showKijunLine ? kijun : na, "基準線", color = color.new(color.orange, 0), linewidth = 2)
plot(showSmaLine ? smaValue : na, "SMA", color = color.new(color.blue, 0), linewidth = 2)
var table trendTable = table.new(position.top_right, 1, 1, border_width = 1, border_color = color.new(color.white, 50))
if barstate.islast
    table.cell(
         trendTable,
         0,
         0,
         f_trendText(finalTrend),
         text_color = color.white,
         text_size = f_textSize(tableSizeInput),
         bgcolor = f_trendColor(finalTrend))
````
