# Hourly Candle Open Tracker (R2F)

- url: https://www.tradingview.com/script/sSl4pKAw-Hourly-Candle-Open-Tracker-R2F/
- type: indicator
- pine_id: PUB;a067cc67963a410bbf6c1acf8ce25f7b
- version: 1.0

## Description

[b]Hourly Candle Start & Formation Tracker
[/b]
This indicator is designed to help traders clearly identify which hourly candle has started during the current hour, as well as which hourly candle is forming for the next hour.

The tool tracks hourly candle cycles from Hour 1 through Hour 12, making it easier to follow time-based market structure, session rhythm, and candle sequencing directly on your chart.

It provides a simple visual reference for traders who use hourly candle timing as part of their strategy, whether for entries, exits, confirmations, or observing how price behaves as each hourly candle opens and develops.

[b]Key Features[/b]
Identifies the current hourly candle that has started
Shows which hourly candle is forming next
Covers hourly cycles from 1 to 12
Helps improve awareness of candle timing and session flow
Useful for intraday traders, scalpers, and time-based strategies
Clean and easy-to-read display directly on the chart

[b]How It Can Be Used[/b]
This indicator can help traders stay aligned with hourly candle changes and prepare for the next candle formation before it begins. It may be useful for traders who watch specific hourly candles for volatility, reversals, continuation moves, liquidity grabs, or session-based setups.

[b]Disclaimer[/b]
This indicator is intended for informational and educational purposes only. It does not provide buy or sell signals and should not be used as financial advice. Always combine it with your own analysis, risk management, and trading plan.

## Source Code

````pine
// ─────────────────────────────────────────────────────────
// Hourly Candle Open Tracker v4
// Shows which hourly timeframes (1H–12H) have a new candle
// opening in the current hour and which open next.
// Green = new candle | Red = no new candle
//
// Logic: Anchored to the exchange's ACTUAL daily candle
// open time — not a timezone setting. Counts hours elapsed
// since the daily open and checks divisibility.
// Works on any asset, any market, any chart timeframe.
// ─────────────────────────────────────────────────────────
//@version=6
indicator("Hourly Candle Open Tracker", overlay = true)

// ── INPUTS ──────────────────────────────────────────────
i_textSize    = input.string("tiny", "Text Size", options = ["tiny", "small", "normal", "large", "huge"])
i_position    = input.string("top_right", "Table Position", options = ["top_right", "top_center", "top_left", "bottom_right", "bottom_center", "bottom_left"])
i_colorOpen   = input.color(color.new(#00C853, 0), "New Candle (Open)")
i_colorClosed = input.color(color.new(#FF1744, 0), "No New Candle")
i_headerBg    = input.color(color.new(#1E1E1E, 0), "Header Background")
i_headerTxt   = input.color(color.new(#FFFFFF, 0), "Header Text")
i_cellTxt     = input.color(color.new(#FFFFFF, 0), "Cell Text")

// ── RESOLVE ENUMS ───────────────────────────────────────
_pos = switch i_position
    "top_right"     => position.top_right
    "top_center"    => position.top_center
    "top_left"      => position.top_left
    "bottom_right"  => position.bottom_right
    "bottom_center" => position.bottom_center
    "bottom_left"   => position.bottom_left
    => position.top_right

_size = switch i_textSize
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    "huge"   => size.huge
    => size.tiny

// ── CANDLE OPEN DETECTION ───────────────────────────────
// Anchor to the exchange's daily candle open time.
// This is set by the exchange/broker, not by user timezone.
// For forex: typically 17:00 EST/New York close convention
// For crypto: typically 00:00 UTC
// For stocks: market open time
dailyOpenTime = request.security(syminfo.tickerid, "D", time)

// Hours elapsed since the daily candle opened
int msPerHour    = 60 * 60 * 1000
int hoursElapsed = int(math.floor((timenow - dailyOpenTime) / msPerHour))
int nextElapsed  = hoursElapsed + 1

// A new N-hour candle opens when elapsed hours is divisible by N
isNewCandle(int elapsed, int period) =>
    elapsed % period == 0

// ── BUILD TABLE ─────────────────────────────────────────
// 14 columns: label + 1H..12H + elapsed counter
var table t = table.new(_pos, 14, 3, border_width = 1, border_color = color.new(#444444, 0))

if barstate.islast
    // Row 0: Header
    table.cell(t, 0, 0, "", bgcolor = i_headerBg, text_color = i_headerTxt, text_size = _size)

    for i = 1 to 12
        table.cell(t, i, 0, str.tostring(i) + "H", bgcolor = i_headerBg, text_color = i_headerTxt, text_size = _size)

    table.cell(t, 13, 0, "HRS", bgcolor = i_headerBg, text_color = i_headerTxt, text_size = _size)

    // Row 1: Current hour
    table.cell(t, 0, 1, "NOW", bgcolor = i_headerBg, text_color = i_headerTxt, text_size = _size)

    for i = 1 to 12
        bool opens = isNewCandle(hoursElapsed, i)
        color bgColor = opens ? i_colorOpen : i_colorClosed
        string label = opens ? "●" : "○"

        table.cell(t, i, 1, label, bgcolor = bgColor, text_color = i_cellTxt, text_size = _size)

    table.cell(t, 13, 1, str.tostring(hoursElapsed), bgcolor = i_headerBg, text_color = color.new(#FFD600, 0), text_size = _size)

    // Row 2: Next hour
    table.cell(t, 0, 2, "NEXT", bgcolor = i_headerBg, text_color = i_headerTxt, text_size = _size)

    for i = 1 to 12
        bool opens = isNewCandle(nextElapsed, i)
        color bgColor = opens ? i_colorOpen : i_colorClosed
        string label = opens ? "●" : "○"

        table.cell(t, i, 2, label, bgcolor = bgColor, text_color = i_cellTxt, text_size = _size)

    table.cell(t, 13, 2, str.tostring(nextElapsed), bgcolor = i_headerBg, text_color = color.new(#FFD600, 0), text_size = _size)

// ── END ─────────────────────────────────────────────────
````
