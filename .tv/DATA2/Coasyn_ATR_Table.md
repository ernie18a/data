<!-- tradingview-pine-id: PUB;61d289f6e9d94e57bbf1e9d938f82786 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Coasyn ATR Table

Source: https://www.tradingview.com/script/74UQxwrD-Coasyn-ATR-Table/

## Description

Coasyn ATR Table is a simple multi-timeframe volatility reference for FX traders.

The indicator displays Average True Range across up to four user-selected timeframes and converts the ATR values into pips.

It does not generate signals, determine direction, score setups, or execute trades.

Its purpose is simply to answer:

How much is this market actually moving on the timeframes I trade?

How to use it

Open the indicator settings and configure:

ATR Length
Controls the ATR calculation period. The default is 14.

Number of Timeframes
Choose between 1 and 4 active timeframe rows.

Timeframe 1–4
Select the chart intervals you want to monitor.

For example:

Daily
4H
1H
15M

Or any other combination appropriate to your trading process.

Reading the table

The left column shows the selected timeframe.

The right column shows the current ATR expressed in pips.

For example:

Daily — 86.4 pips
means the current Daily ATR is approximately 86.4 pips.

15M — 12.7 pips
means the current 15-minute ATR is approximately 12.7 pips.

ATR measures movement range. It does not indicate bullish or bearish direction.

A larger ATR means the market is currently covering more distance on that timeframe.

A smaller ATR means the market is currently covering less distance.

Raw ATR

Enable Show Raw ATR Value if you also want to see the instrument's native ATR price value beside the pip conversion.

This is optional and is disabled by default.

Table position

The panel can be placed in:

Top Right
Top Left
Bottom Right
Bottom Left
Intended use

The table can be used as a quick volatility ruler when evaluating:

stop distance
expected movement
timeframe selection
current market activity
relative volatility between trading horizons

The trader remains responsible for interpreting that information within their own strategy and risk process.

Important

Coasyn ATR Table is an informational tool only.

It does not provide trade signals, entries, targets, position sizing, automated execution, or directional recommendations.

ATR is the ruler.

Built by Coasyn Market Systems.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/
//
// © Coasyn Market Systems

//@version=6
indicator("Coasyn ATR Table", overlay=true)

// ============================================================
// COASYN ATR TABLE
// ------------------------------------------------------------
// Purpose:
//
// Display ATR across up to four operator-selected timeframes.
//
// No signal logic.
// No composite score.
// No directional interpretation.
// No execution.
//
// ATR is the ruler.
// ============================================================


// ============================================================
// SETTINGS
// ============================================================

groupATR = "ATR"

atrLength = input.int(
     14,
     "ATR Length",
     minval=1,
     group=groupATR
)

timeframeCount = input.int(
     4,
     "Number of Timeframes",
     minval=1,
     maxval=4,
     group=groupATR
)

tf1 = input.timeframe(
     "1D",
     "Timeframe 1",
     group=groupATR
)

tf2 = input.timeframe(
     "240",
     "Timeframe 2",
     group=groupATR
)

tf3 = input.timeframe(
     "120",
     "Timeframe 3",
     group=groupATR
)

tf4 = input.timeframe(
     "15",
     "Timeframe 4",
     group=groupATR
)


// ============================================================
// TABLE SETTINGS
// ============================================================

groupPanel = "TABLE"

panelPosition = input.string(
     "Top Right",
     "Position",
     options=[
         "Top Right",
         "Top Left",
         "Bottom Right",
         "Bottom Left"
     ],
     group=groupPanel
)

showRawATR = input.bool(
     false,
     "Show Raw ATR Value",
     group=groupPanel
)


// ============================================================
// HELPERS
// ============================================================

// Standard FX pip handling.
//
// 5-digit quote example:
// mintick = 0.00001 → pip = 0.0001
//
// 3-digit JPY quote example:
// mintick = 0.001 → pip = 0.01
//
// Other quoting structures fall back to mintick.
f_pip_size() =>
    float pip = syminfo.mintick

    if syminfo.type == "forex"
        pip :=
             syminfo.mintick == 0.00001 or
             syminfo.mintick == 0.001
             ? syminfo.mintick * 10.0
             : syminfo.mintick

    pip


f_atr_pips(float atrValue) =>
    float pip = f_pip_size()

    not na(atrValue) and pip > 0.0
         ? atrValue / pip
         : na


f_fmt_pips(float value) =>
    na(value)
         ? "N/A"
         : str.tostring(value, "#.0")


f_fmt_raw(float value) =>
    na(value)
         ? "N/A"
         : str.tostring(value, format.mintick)


// Convert TradingView timeframe codes into cleaner display labels.
f_tf_label(string tf) =>
    float numericTf = str.tonumber(tf)

    string label = tf

    if not na(numericTf)
        int minutes = int(numericTf)

        label :=
             minutes >= 60 and minutes % 60 == 0
             ? str.tostring(int(minutes / 60)) + "H"
             : str.tostring(minutes) + "M"

    else
        label :=
             tf == "1D" or tf == "D" ? "DAILY" :
             tf == "1W" or tf == "W" ? "WEEKLY" :
             tf == "1M" or tf == "M" ? "MONTHLY" :
             tf

    label


// ============================================================
// MULTI-TIMEFRAME ATR
// ============================================================

atr1 = request.security(
     syminfo.tickerid,
     tf1,
     ta.atr(atrLength),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

atr2 = request.security(
     syminfo.tickerid,
     tf2,
     ta.atr(atrLength),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

atr3 = request.security(
     syminfo.tickerid,
     tf3,
     ta.atr(atrLength),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

atr4 = request.security(
     syminfo.tickerid,
     tf4,
     ta.atr(atrLength),
     barmerge.gaps_off,
     barmerge.lookahead_off
)


atr1Pips = f_atr_pips(atr1)
atr2Pips = f_atr_pips(atr2)
atr3Pips = f_atr_pips(atr3)
atr4Pips = f_atr_pips(atr4)


// ============================================================
// COLORS
// ============================================================

bg = color.rgb(8, 11, 16)

header = color.rgb(18, 24, 34)

border = color.rgb(70, 76, 84)

gold = color.rgb(218, 173, 78)

textColor = color.rgb(235, 238, 244)

muted = color.rgb(145, 150, 156)

accent = color.rgb(70, 210, 245)


// ============================================================
// TABLE POSITION
// ============================================================

pos = switch panelPosition
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right


// ============================================================
// TABLE
// ============================================================

var table panel = table.new(
     pos,
     3,
     5,
     border_width=1,
     border_color=border
)


// ============================================================
// TABLE RENDER
// ============================================================

if barstate.islast

    // Clear previous state first.
    table.clear(panel, 0, 0, 2, 4)

    // --------------------------------------------------------
    // HEADER
    // --------------------------------------------------------

    table.cell(
         panel,
         0,
         0,
         "TIMEFRAME",
         bgcolor=header,
         text_color=gold,
         text_size=size.tiny
    )

    table.cell(
         panel,
         1,
         0,
         "ATR " + str.tostring(atrLength) + " PIPS",
         bgcolor=header,
         text_color=gold,
         text_size=size.tiny
    )

    table.cell(
         panel,
         2,
         0,
         showRawATR ? "RAW" : "",
         bgcolor=header,
         text_color=muted,
         text_size=size.tiny
    )


    // --------------------------------------------------------
    // TIMEFRAME 1
    // --------------------------------------------------------

    if timeframeCount >= 1

        table.cell(
             panel,
             0,
             1,
             f_tf_label(tf1),
             bgcolor=bg,
             text_color=textColor,
             text_size=size.small
        )

        table.cell(
             panel,
             1,
             1,
             f_fmt_pips(atr1Pips),
             bgcolor=bg,
             text_color=textColor,
             text_size=size.small
        )

        table.cell(
             panel,
             2,
             1,
             showRawATR ? f_fmt_raw(atr1) : "",
             bgcolor=bg,
             text_color=muted,
             text_size=size.tiny
        )


    // --------------------------------------------------------
    // TIMEFRAME 2
    // --------------------------------------------------------

    if timeframeCount >= 2

        table.cell(
             panel,
             0,
             2,
             f_tf_label(tf2),
             bgcolor=bg,
             text_color=textColor,
             text_size=size.small
        )

        table.cell(
             panel,
             1,
             2,
             f_fmt_pips(atr2Pips),
             bgcolor=bg,
             text_color=textColor,
             text_size=size.small
        )

        table.cell(
             panel,
             2,
             2,
             showRawATR ? f_fmt_raw(atr2) : "",
             bgcolor=bg,
             text_color=muted,
             text_size=size.tiny
        )


    // --------------------------------------------------------
    // TIMEFRAME 3
    // --------------------------------------------------------

    if timeframeCount >= 3

        table.cell(
             panel,
             0,
             3,
             f_tf_label(tf3),
             bgcolor=bg,
             text_color=accent,
             text_size=size.small
        )

        table.cell(
             panel,
             1,
             3,
             f_fmt_pips(atr3Pips),
             bgcolor=bg,
             text_color=accent,
             text_size=size.small
        )

        table.cell(
             panel,
             2,
             3,
             showRawATR ? f_fmt_raw(atr3) : "",
             bgcolor=bg,
             text_color=muted,
             text_size=size.tiny
        )


    // --------------------------------------------------------
    // TIMEFRAME 4
    // --------------------------------------------------------

    if timeframeCount >= 4

        table.cell(
             panel,
             0,
             4,
             f_tf_label(tf4),
             bgcolor=bg,
             text_color=textColor,
             text_size=size.small
        )

        table.cell(
             panel,
             1,
             4,
             f_fmt_pips(atr4Pips),
             bgcolor=bg,
             text_color=textColor,
             text_size=size.small
        )

        table.cell(
             panel,
             2,
             4,
             showRawATR ? f_fmt_raw(atr4) : "",
             bgcolor=bg,
             text_color=muted,
             text_size=size.tiny
        )
````
