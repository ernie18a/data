# NQ-GC Macro Dashboard (Strong / Weak)

- url: https://www.tradingview.com/script/MP0VOLbC-NQ-GC-Macro-Dashboard-Strong-Weak/
- type: indicator
- pine_id: PUB;bf4c865fd4cc493995e0787a8c17229c
- version: 1.0

## Description

For NQ and GC Futures traders. Have an idea where market might go for news events. "Strong" / "Weak" means if the forecast is stronger or weaker compared to the actual. Ex. Forecast CPI 2.8% Actual CPI 3.1%. I've done some research to come to this conclusion. Let me know how it works for you guys.

## Source Code

````pine
 //@version=6
indicator("NQ-GC Macro Dashboard (Strong / Weak)", overlay=true)

var table t = table.new(position.top_right, 4, 12, border_width=1)

if barstate.islast
    // Header
    table.cell(t, 0, 0, "EVENT", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 1, 0, "RESULT", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 2, 0, "NQ", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 3, 0, "GC", bgcolor=color.blue, text_color=color.white)

    // CPI
    table.cell(t, 0, 1, "CPI")
    table.cell(t, 1, 1, "STRONG")
    table.cell(t, 2, 1, "BEARISH", bgcolor=color.red)
    table.cell(t, 3, 1, "BEARISH", bgcolor=color.red)

    table.cell(t, 0, 2, "CPI")
    table.cell(t, 1, 2, "WEAK")
    table.cell(t, 2, 2, "BULLISH", bgcolor=color.green)
    table.cell(t, 3, 2, "BULLISH", bgcolor=color.green)

    // NFP
    table.cell(t, 0, 3, "NFP")
    table.cell(t, 1, 3, "STRONG")
    table.cell(t, 2, 3, "BEARISH", bgcolor=color.red)
    table.cell(t, 3, 3, "BEARISH", bgcolor=color.red)

    table.cell(t, 0, 4, "NFP")
    table.cell(t, 1, 4, "WEAK")
    table.cell(t, 2, 4, "BULLISH", bgcolor=color.green)
    table.cell(t, 3, 4, "BULLISH", bgcolor=color.green)

    // PCE
    table.cell(t, 0, 5, "PCE")
    table.cell(t, 1, 5, "STRONG")
    table.cell(t, 2, 5, "BEARISH", bgcolor=color.red)
    table.cell(t, 3, 5, "BEARISH", bgcolor=color.red)

    table.cell(t, 0, 6, "PCE")
    table.cell(t, 1, 6, "WEAK")
    table.cell(t, 2, 6, "BULLISH", bgcolor=color.green)
    table.cell(t, 3, 6, "BULLISH", bgcolor=color.green)

    // FOMC
    table.cell(t, 0, 7, "FOMC")
    table.cell(t, 1, 7, "STRONG")
    table.cell(t, 2, 7, "BEARISH", bgcolor=color.red)
    table.cell(t, 3, 7, "BEARISH", bgcolor=color.red)

    table.cell(t, 0, 8, "FOMC")
    table.cell(t, 1, 8, "WEAK")
    table.cell(t, 2, 8, "BULLISH", bgcolor=color.green)
    table.cell(t, 3, 8, "BULLISH", bgcolor=color.green)

    // 10Y Yield
    table.cell(t, 0, 9, "10Y")
    table.cell(t, 1, 9, "STRONG")
    table.cell(t, 2, 9, "BEARISH", bgcolor=color.red)
    table.cell(t, 3, 9, "BEARISH", bgcolor=color.red)

    table.cell(t, 0, 10, "10Y")
    table.cell(t, 1, 10, "WEAK")
    table.cell(t, 2, 10, "BULLISH", bgcolor=color.green)
    table.cell(t, 3, 10, "BULLISH", bgcolor=color.green)

    // DXY
    table.cell(t, 0, 11, "DXY")
    table.cell(t, 1, 11, "STRONG")
    table.cell(t, 2, 11, "BEARISH", bgcolor=color.red)
    table.cell(t, 3, 11, "BEARISH", bgcolor=color.red)
````
