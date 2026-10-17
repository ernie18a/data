# Traded Value & Rolling Turnover

- url: https://www.tradingview.com/script/m52KTDZw/
- type: indicator
- pine_id: PUB;70157d543e614ce0ab184accab564035
- version: 3.0

## Description

Turnover Value

Description:
Displays estimated traded value per bar, moving average, and rolling N-bar turnover in a separate pane.

Traded value is calculated from volume and a selectable price basis such as Close, HLC3, or OHLC4. The script also supports quote-volume symbols and optional futures point value adjustment.

Values are based on available OHLCV data and may differ from exact tick-by-tick turnover depending on the symbol, exchange, and volume data source.

## Source Code

````pine
//@version=6
indicator("Traded Value & Rolling Turnover", shorttitle="Turnover Value", overlay=false, format=format.volume, precision=0)

basisInput = input.string("HLC3", "계산 기준 가격", options=["Close", "HLC3", "OHLC4"])
len = input.int(20, "누적/평균 기간", minval=1)
autoQuote = input.bool(true, "볼륨이 Quote 통화면 그대로 사용")
usePointValue = input.bool(true, "선물은 point value 반영")
showMA = input.bool(true, "이동평균 표시")

upColor = input.color(color.new(#26A69A, 0), "양봉 거래대금 색상")
downColor = input.color(color.new(#EF5350, 0), "음봉 거래대금 색상")
maColor = input.color(color.new(color.orange, 0), "이동평균 색상")

basis = switch basisInput
    "Close" => close
    "OHLC4" => ohlc4
    => hlc3

mult = (usePointValue and syminfo.type == "futures") ? syminfo.pointvalue : 1.0

tradedValue = autoQuote and syminfo.volumetype == "quote" ? volume : volume * basis * mult

rollingValue = math.sum(tradedValue, len)
maValue = ta.sma(tradedValue, len)

// 기본 거래량 지표처럼 양봉/음봉에 따라 색상 변경
barColor = close >= open ? upColor : downColor

// 숫자를 K / M / B / T 형식으로 줄이고 소수점 제거
formatCompact(float value) =>
    if na(value)
        "n/a"
    else
        absValue = math.abs(value)
        sign = value < 0 ? "-" : ""

        scaled = absValue
        suffix = ""

        if absValue >= 999500000000
            scaled := absValue / 1000000000000
            suffix := "T"
        else if absValue >= 999500000
            scaled := absValue / 1000000000
            suffix := "B"
        else if absValue >= 999500
            scaled := absValue / 1000000
            suffix := "M"
        else if absValue >= 999.5
            scaled := absValue / 1000
            suffix := "K"

        sign + str.tostring(math.round(scaled), "#") + suffix

formatMoney(float value) =>
    currencyText = syminfo.currency != "" ? " " + syminfo.currency : ""
    formatCompact(value) + currencyText

plot(tradedValue, "봉별 거래대금", style=plot.style_columns, color=barColor)
plot(showMA ? maValue : na, "거래대금 이동평균", color=maColor)
plot(rollingValue, "최근 N봉 누적 거래대금", display=display.data_window + display.status_line)

var table t = table.new(position.top_right, 1, 2)

if barstate.islast
    table.cell(t, 0, 0, "현재 봉 거래대금\n" + formatMoney(tradedValue))
    table.cell(t, 0, 1, "최근 " + str.tostring(len) + "봉 누적\n" + formatMoney(rollingValue))
````
