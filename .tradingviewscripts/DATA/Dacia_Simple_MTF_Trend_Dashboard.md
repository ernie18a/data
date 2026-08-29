<!-- tradingview-pine-id: PUB;ac127a2af3a2459580554d3fd2b3f9a0 -->
<!-- tradingviewscripts-format: 1 -->
# Dacia Simple MTF Trend Dashboard

Source: https://www.tradingview.com/script/5pPbg6gu-Dacia-Simple-MTF-Trend-Dashboard/

## Description

Dacia Simple MTF Trend Dashboard
Dacia Simple MTF Trend Dashboard
Dacia Simple MTF Trend Dashboard
Dacia Simple MTF Trend Dashboard

---

## Source Code

````pine
//@version=6
indicator("Dacia Simple MTF Trend Dashboard", shorttitle="Dacia MTF Trend", overlay=true)

string trendGroup = "Trend Settings"
int fastEmaLength = input.int(21, "Fast EMA", minval=1, group=trendGroup)
int slowEmaLength = input.int(50, "Slow EMA", minval=2, group=trendGroup)
bool requirePricePosition = input.bool(true, "Require Price Above/Below Slow EMA", group=trendGroup)
bool useClosedCandles = input.bool(true, "Use Closed Timeframe Candles", group=trendGroup)

string displayGroup = "Display"
string tablePositionInput = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=displayGroup)
string tableSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=displayGroup)
bool showEmaValues = input.bool(false, "Show EMA Values", group=displayGroup)
bool enableAlerts = input.bool(true, "Enable Alignment Alerts", group="Alerts")

f_tablePosition(string positionName) =>
    switch positionName
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_textSize(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

f_trendState(float tfClose, float fastEma, float slowEma) =>
    bool bull = fastEma > slowEma and (not requirePricePosition or tfClose > slowEma)
    bool bear = fastEma < slowEma and (not requirePricePosition or tfClose < slowEma)
    bull ? 1 : bear ? -1 : 0

f_stateText(int state) =>
    state == 1 ? "BULL ▲" : state == -1 ? "BEAR ▼" : "MIXED •"

f_stateColor(int state) =>
    state == 1 ? color.lime : state == -1 ? color.red : color.gray

f_securityData(string tf) =>
    int offset = useClosedCandles ? 1 : 0
    request.security(
         syminfo.tickerid,
         tf,
         [close[offset], ta.ema(close, fastEmaLength)[offset], ta.ema(close, slowEmaLength)[offset]],
         gaps=barmerge.gaps_off,
         lookahead=useClosedCandles ? barmerge.lookahead_on : barmerge.lookahead_off)

[close4H, fast4H, slow4H] = f_securityData("240")
[close1H, fast1H, slow1H] = f_securityData("60")
[close15M, fast15M, slow15M] = f_securityData("15")
[close5M, fast5M, slow5M] = f_securityData("5")

int trend4H = f_trendState(close4H, fast4H, slow4H)
int trend1H = f_trendState(close1H, fast1H, slow1H)
int trend15M = f_trendState(close15M, fast15M, slow15M)
int trend5M = f_trendState(close5M, fast5M, slow5M)

int bullCount = (trend4H == 1 ? 1 : 0) + (trend1H == 1 ? 1 : 0) + (trend15M == 1 ? 1 : 0) + (trend5M == 1 ? 1 : 0)
int bearCount = (trend4H == -1 ? 1 : 0) + (trend1H == -1 ? 1 : 0) + (trend15M == -1 ? 1 : 0) + (trend5M == -1 ? 1 : 0)

string overallText =
     bullCount == 4 ? "BUY BIAS" :
     bearCount == 4 ? "SELL BIAS" :
     bullCount == 3 ? "LEAN BULL" :
     bearCount == 3 ? "LEAN BEAR" :
     "WAIT / MIXED"

color overallColor =
     bullCount == 4 ? color.lime :
     bearCount == 4 ? color.red :
     bullCount == 3 ? color.new(color.lime, 25) :
     bearCount == 3 ? color.new(color.red, 25) :
     color.gray

int columnCount = showEmaValues ? 4 : 2

var table dashboard = table.new(
     f_tablePosition(tablePositionInput),
     columnCount,
     6,
     border_width=1,
     frame_color=color.new(color.gray, 60),
     border_color=color.new(color.gray, 70))

if barstate.islast
    string txtSize = f_textSize(tableSizeInput)

    table.cell(dashboard, 0, 0, "TIME", bgcolor=color.new(color.black, 10), text_color=color.white, text_size=txtSize)
    table.cell(dashboard, 1, 0, "TREND", bgcolor=color.new(color.black, 10), text_color=color.white, text_size=txtSize)

    if showEmaValues
        table.cell(dashboard, 2, 0, "EMA " + str.tostring(fastEmaLength), bgcolor=color.new(color.black, 10), text_color=color.white, text_size=txtSize)
        table.cell(dashboard, 3, 0, "EMA " + str.tostring(slowEmaLength), bgcolor=color.new(color.black, 10), text_color=color.white, text_size=txtSize)

    string[] tfNames = array.from("4H", "1H", "15M", "5M")
    int[] states = array.from(trend4H, trend1H, trend15M, trend5M)
    float[] fastValues = array.from(fast4H, fast1H, fast15M, fast5M)
    float[] slowValues = array.from(slow4H, slow1H, slow15M, slow5M)

    for i = 0 to 3
        int row = i + 1
        int state = array.get(states, i)
        color stateColor = f_stateColor(state)

        table.cell(dashboard, 0, row, array.get(tfNames, i), bgcolor=color.new(color.black, 15), text_color=color.white, text_size=txtSize)
        table.cell(dashboard, 1, row, f_stateText(state), bgcolor=color.new(stateColor, 82), text_color=stateColor, text_size=txtSize)

        if showEmaValues
            table.cell(dashboard, 2, row, str.tostring(array.get(fastValues, i), format.mintick), bgcolor=color.new(color.black, 15), text_color=color.white, text_size=txtSize)
            table.cell(dashboard, 3, row, str.tostring(array.get(slowValues, i), format.mintick), bgcolor=color.new(color.black, 15), text_color=color.white, text_size=txtSize)

    table.cell(dashboard, 0, 5, "OVERALL", bgcolor=color.new(color.black, 5), text_color=color.white, text_size=txtSize)
    table.cell(dashboard, 1, 5, overallText, bgcolor=color.new(overallColor, 75), text_color=overallColor, text_size=txtSize)

    if showEmaValues
        table.cell(dashboard, 2, 5, str.tostring(bullCount) + " Bull", bgcolor=color.new(color.black, 5), text_color=color.lime, text_size=txtSize)
        table.cell(dashboard, 3, 5, str.tostring(bearCount) + " Bear", bgcolor=color.new(color.black, 5), text_color=color.red, text_size=txtSize)

bool fullBullAlignment = bullCount == 4
bool fullBearAlignment = bearCount == 4
bool newFullBullAlignment = enableAlerts and fullBullAlignment and not fullBullAlignment[1]
bool newFullBearAlignment = enableAlerts and fullBearAlignment and not fullBearAlignment[1]

alertcondition(newFullBullAlignment, title="All Timeframes Bullish", message="{{ticker}}: 4H, 1H, 15M, and 5M are all bullish.")
alertcondition(newFullBearAlignment, title="All Timeframes Bearish", message="{{ticker}}: 4H, 1H, 15M, and 5M are all bearish.")

if newFullBullAlignment
    alert(syminfo.ticker + " | 4H + 1H + 15M + 5M ALL BULLISH | BUY BIAS — check entry confirmation.", alert.freq_once_per_bar_close)

if newFullBearAlignment
    alert(syminfo.ticker + " | 4H + 1H + 15M + 5M ALL BEARISH | SELL BIAS — check entry confirmation.", alert.freq_once_per_bar_close)
````
