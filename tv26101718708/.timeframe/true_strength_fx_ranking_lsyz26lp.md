# True Strength FX Ranking

- url: https://www.tradingview.com/script/lSyZ26Lp-True-Strength-FX-Ranking/
- type: indicator
- pine_id: PUB;b041d66ec4a047d794bd3e92f66692d6
- version: 1.0

## Description

True Strength FX Ranking ranks the 8 major currencies from strongest to weakest on four timeframes at once: 4H, Daily, Weekly and Monthly.

One glance at the table tells you which currencies are leading, which are lagging, and whether that picture is the same across short-term and longer-term timeframes.

WHAT IT SHOWS

The table has four columns: 4H, Daily, Weekly and Monthly. Each column lists USD, EUR, GBP, JPY, CHF, CAD, AUD and NZD from strongest (top) to weakest (bottom), with the % change of each currency on that timeframe's candle.

- Green = the currency's candle closed higher (bullish).
- Red = the currency's candle closed lower (bearish).
- The stronger the colour, the bigger the move compared to the other currencies in that column.

The % change is measured from the previous candle's close to the current candle's close, the same way TradingView's Chg% column works.

HOW IT WORKS: EQUAL-WEIGHTED CURRENCY INDEXES

The ranking isn't based on a single pair. Each currency is measured with its own equal-weighted index against the other 7 majors, so every currency in the basket counts exactly the same.

Most currency indexes are unevenly weighted. The euro makes up more than half of the DXY, for example, so the DXY often says more about EUR/USD than about the dollar as a whole. Simple strength meters that add up pair prices have a similar problem: pairs with higher prices (like USD/JPY at around 150) end up counting more than pairs with lower prices (like USD/GBP at around 0.75).

This indicator avoids both problems by combining the pairs' percentage moves instead of their prices. Example for the US dollar:

USD index = USDCAD × USDCHF × USDJPY ÷ (EURUSD × GBPUSD × AUDUSD × NZDUSD)

- Pairs with the dollar first (USD/CAD, USD/CHF, USD/JPY) are multiplied. When they rise, the dollar is stronger.
- Pairs with the dollar second (EUR/USD, GBP/USD, AUD/USD, NZD/USD) are divided. When they rise, the dollar is weaker, so dividing flips them around.
- Multiplying means each pair adds its own % move, whatever its price, so all 7 count equally.
- The indicator then takes the average of the 7 moves, so the % you see is the dollar's average move against the whole basket.

The same method is used for all 8 currencies. Because every cross pair (such as EUR/JPY or GBP/AUD) is a combination of two dollar pairs, all 8 indexes are calculated from the 7 main dollar pairs. This gives the same equal-weighted result while keeping the indicator fast and reliable.

The calculation is identical to my True Strength FX indicator, so the two always agree.

HOW I USE IT

I trade mostly from a macro and fundamental bias. Once I have a bias, for example "the US dollar should strengthen after a hawkish Fed," I use this table to choose the best pair to express it.

If I'm bullish on a currency, I look for the currency that has performed worst over the past hours, days or weeks, and I sell that one against the currency I'm buying. Pairing a strong currency with a weak one means both sides of the trade work in my favour, instead of trading a pair where the other currency is just as strong and the move stalls.

It's also useful as a simple live dashboard. Make the table small, put it in a corner of your chart, and you can see at a glance which currencies are leading right now and which are falling behind.

Other ideas:
- Weekly preparation: switch to "Last closed candle" to review last week's and last month's strongest and weakest currencies.
- Event reactions: after a central bank decision or major data release, check whether the currency moved to the top or bottom of the 4H and Daily columns.
- Trend consistency: a currency that sits near the top (or bottom) across all four timeframes is showing strength (or weakness) that is more than a one-day move.

SETTINGS

- Data source: the price feed used for the calculation. Choose from OANDA (default), ICE, FOREX.com, Saxo or Pepperstone. All five give practically the same rankings. Keep the same source across your indicators.
- Measure:
  – Current candle (live): the current 4H candle, today, this week and this month so far. Updates live as prices move.
  – Last closed candle: the last finished candle on each timeframe, such as the previous 4H candle, yesterday, last week and last month. These values don't change, which makes this mode ideal for weekly reviews and preparation.
- Table position: place the table in any corner, at the top or bottom centre, or at the middle left or right of the chart.
- Text size: Tiny, Small, Normal or Large. Tiny or Small works well for a compact live dashboard.

NOTES

- Works on any chart and any symbol. The table always shows the 8 major currencies, whatever chart you have open.
- All values come from TradingView data for the selected feed. Small differences between feeds are normal.
- This is an analysis tool, not a buy or sell signal. Use it alongside your own analysis and risk management.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  True Strength FX Ranking
//  Built by Jake Koel  ·  © jakekoel
// ─────────────────────────────────────────────────────────────
// Ranks the 8 major currencies from strongest to weakest on the 4H, Daily, Weekly and Monthly candle.
// Each currency is measured with an equal-weighted index against the other 7 majors
// (same calculation as True Strength FX), and the table shows how much each index candle
// rose or fell in %, from the previous candle's close to this candle's close.
indicator("True Strength FX Ranking", shorttitle = "TSFX Rank", overlay = true)

// ───────────────────────── Inputs ─────────────────────────
string srcIn   = input.string("OANDA", "Data source", options = ["OANDA", "ICE", "FOREX.com", "Saxo", "Pepperstone"], tooltip = "Price feed used for the calculation. Keep the same source across your indicators.")
// Map the names in the dropdown to TradingView's feed prefixes
string src = switch srcIn
    "ICE"         => "FX_IDC"
    "FOREX.com"   => "FOREXCOM"
    "Saxo"        => "SAXO"
    "Pepperstone" => "PEPPERSTONE"
    => "OANDA"
string mode    = input.string("Current candle (live)", "Measure", options = ["Current candle (live)", "Last closed candle"], tooltip = "Current candle: today / this week / this month so far, updates live.\nLast closed candle: the previous finished candle, e.g. last week or last month. Good for weekly prep.")
string posIn   = input.string("Top right", "Table position", options = ["Top right", "Top center", "Top left", "Middle right", "Middle left", "Bottom right", "Bottom center", "Bottom left"])
string sizeIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large"])

// ───────────────────────── Setup ─────────────────────────
var NAMES = array.from("USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "NZD")

tablePos = switch posIn
    "Top right"     => position.top_right
    "Top center"    => position.top_center
    "Top left"      => position.top_left
    "Middle right"  => position.middle_right
    "Middle left"   => position.middle_left
    "Bottom right"  => position.bottom_right
    "Bottom center" => position.bottom_center
    => position.bottom_left

textSize = switch sizeIn
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Large"  => size.large
    => size.normal

bool live = mode == "Current candle (live)"

// Log value of one currency in US dollars on a given timeframe:
// [this candle, previous candle, candle before that]
usdLeg(string pair, bool invert, string tf) =>
    [c0, c1, c2] = request.security(src + ":" + pair, tf, [math.log(close), math.log(close[1]), math.log(close[2])], ignore_invalid_symbol = true)
    float s = invert ? -1.0 : 1.0
    [s * c0, s * c1, s * c2]

// % change of all 8 equal-weighted currency indexes on one timeframe.
// Every currency is valued in USD through the 7 dollar pairs; each index is then that currency
// against the average of the other 7, which is exactly the equal-weight basket of its 7 pairs.
tfChanges(string tf) =>
    [e0, e1, e2] = usdLeg("EURUSD", false, tf)
    [g0, g1, g2] = usdLeg("GBPUSD", false, tf)
    [a0, a1, a2] = usdLeg("AUDUSD", false, tf)
    [n0, n1, n2] = usdLeg("NZDUSD", false, tf)
    [d0, d1, d2] = usdLeg("USDCAD", true, tf)
    [f0, f1, f2] = usdLeg("USDCHF", true, tf)
    [j0, j1, j2] = usdLeg("USDJPY", true, tf)
    // Order matches NAMES: USD, EUR, GBP, JPY, CHF, CAD, AUD, NZD
    array<float> nowV  = live ? array.from(0.0, e0, g0, j0, f0, d0, a0, n0) : array.from(0.0, e1, g1, j1, f1, d1, a1, n1)
    array<float> prevV = live ? array.from(0.0, e1, g1, j1, f1, d1, a1, n1) : array.from(0.0, e2, g2, j2, f2, d2, a2, n2)
    float sumNow  = 0.0
    float sumPrev = 0.0
    for i = 0 to 7
        sumNow  += nowV.get(i)
        sumPrev += prevV.get(i)
    float mNow  = sumNow / 8
    float mPrev = sumPrev / 8
    array<float> out = array.new_float(8, na)
    for i = 0 to 7
        float idxNow  = 8.0 / 7.0 * (nowV.get(i) - mNow)
        float idxPrev = 8.0 / 7.0 * (prevV.get(i) - mPrev)
        out.set(i, (math.exp(idxNow - idxPrev) - 1) * 100)
    out

array<float> ch4H = tfChanges("240")
array<float> chD  = tfChanges("D")
array<float> chW  = tfChanges("W")
array<float> chM  = tfChanges("M")

// ───────────────────────── Table ─────────────────────────
color UP   = #26A69A
color DOWN = #EF5350

// Stronger moves get stronger colour; values near 0% stay pale
cellColor(float p, float maxAbs) =>
    na(p) ? color.new(color.gray, 80) : p >= 0 ? color.from_gradient(p, 0, maxAbs, color.new(UP, 85), color.new(UP, 25)) : color.from_gradient(p, -maxAbs, 0, color.new(DOWN, 25), color.new(DOWN, 85))

fmt(float p) =>
    na(p) ? "n/a" : (p >= 0 ? "+" : "") + str.tostring(p, "0.00") + "%"

var table t = table.new(tablePos, 5, 10, border_width = 1, border_color = color.new(color.gray, 70), frame_width = 1, frame_color = color.new(color.gray, 60))

fillColumn(int col, string title, array<float> ch) =>
    table.cell(t, col, 0, title, bgcolor = color.new(color.gray, 70), text_color = chart.fg_color, text_size = textSize)
    array<int> ranks = ch.sort_indices(order.descending)
    float maxAbs = math.max(math.abs(nz(ch.max())), math.abs(nz(ch.min())), 0.0001)
    for r = 0 to 7
        int   i = ranks.get(r)
        float p = ch.get(i)
        table.cell(t, col, r + 1, NAMES.get(i) + "  " + fmt(p), bgcolor = cellColor(p, maxAbs), text_color = chart.fg_color, text_size = textSize)

if barstate.islast
    table.cell(t, 0, 0, live ? "Live" : "Closed", bgcolor = color.new(color.gray, 70), text_color = chart.fg_color, text_size = textSize)
    for r = 1 to 8
        table.cell(t, 0, r, str.tostring(r), bgcolor = color.new(color.gray, 85), text_color = chart.fg_color, text_size = textSize)
    fillColumn(1, "4H", ch4H)
    fillColumn(2, "Daily", chD)
    fillColumn(3, "Weekly", chW)
    fillColumn(4, "Monthly", chM)
    // Signature
    table.cell(t, 0, 9, "@jakekoel", text_color = color.new(color.gray, 30), text_size = size.tiny, text_halign = text.align_right)
    table.merge_cells(t, 0, 9, 4, 9)
````
