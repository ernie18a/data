# MTF Trend Table 

- url: https://www.tradingview.com/script/sUvG9Uw2-MTF-Trend-Table/
- type: indicator
- pine_id: PUB;ff774ff43efe4b75b71ade8b2597e5ef
- version: 1.0

## Description

On chart table for keeping track of multi time frame structure bias.

Not automated, will need to update table manually after confirming bullish/bearish break.

Cheers.

## Source Code

````pine
//@version=6
indicator("TF Trend Table – Manual (inline)", overlay = true, shorttitle = "TF‑Table")

// ────────────────────────
// 1️⃣ Inputs – drop‑downs per TF
// ────────────────────────
tfWeek  = input.string(title="1W",  defval="Bullish", options=["Bullish","Bearish"])
tfDay   = input.string(title="1D",  defval="Bullish", options=["Bullish","Bearish"])
tfH4    = input.string(title="4H",  defval="Bullish", options=["Bullish","Bearish"])
tfHour  = input.string(title="1H",  defval="Bullish", options=["Bullish","Bearish"])
tfM15   = input.string(title="15m",defval="Bullish", options=["Bullish","Bearish"])
tfM5    = input.string(title="5m",  defval="Bullish", options=["Bullish","Bearish"])

// ────────────────────────
// 2️⃣ Create the table (once)
// ────────────────────────
var table tfTable = na

if barstate.isfirst
    tfTable := table.new(position.top_right, 2, 7,
                         frame_color=color.gray,
                         border_width=1)

    // Header
    table.cell(tfTable, 0, 0, "Time‑frame", text_color=color.white, bgcolor=color.black)
    table.cell(tfTable, 1, 0, "Trend"      , text_color=color.white, bgcolor=color.black)

    // TF labels (rows 1–6)
    string[] tfs = array.from("1W","1D","4H","1H","15m","5m")
    for i = 0 to array.size(tfs) - 1
        table.cell(tfTable, 0, i + 1, array.get(tfs,i))

// ────────────────────────
// 3️⃣ Write the values into the table (each bar)
// ────────────────────────
if not na(tfTable)
    // ──────────────────────────────
    //   Trend column – rows 1‑6
    // ──────────────────────────────
    table.cell(tfTable, 1, 1,
        tfWeek,
        bgcolor = (tfWeek  == "Bullish" ? color.new(color.green,0) : color.new(color.red,0)),
        text_color=color.white)

    table.cell(tfTable, 1, 2,
        tfDay,
        bgcolor = (tfDay   == "Bullish" ? color.new(color.green,0) : color.new(color.red,0)),
        text_color=color.white)

    table.cell(tfTable, 1, 3,
        tfH4,
        bgcolor = (tfH4    == "Bullish" ? color.new(color.green,0) : color.new(color.red,0)),
        text_color=color.white)

    table.cell(tfTable, 1, 4,
        tfHour,
        bgcolor = (tfHour  == "Bullish" ? color.new(color.green,0) : color.new(color.red,0)),
        text_color=color.white)

    table.cell(tfTable, 1, 5,
        tfM15,
        bgcolor = (tfM15   == "Bullish" ? color.new(color.green,0) : color.new(color.red,0)),
        text_color=color.white)

    table.cell(tfTable, 1, 6,
        tfM5,
        bgcolor = (tfM5    == "Bullish" ? color.new(color.green,0) : color.new(color.red,0)),
        text_color=color.white)

// ────────────────────────
// 4️⃣ Hide the indicator’s plot (no line)
// ────────────────────────
plot(na)
````
