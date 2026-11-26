# 10Y Yield Spread - Auto FX Pair

- url: https://www.tradingview.com/script/tPZKdrud-10Y-Yield-Spread-Auto-FX-Pair/
- type: indicator
- pine_id: PUB;680396a81ab046788484b49bb4d95ee2
- version: 2.0

## Description

[b]10Y Yield Spread — Auto FX Pair[/b]

Automatically displays the 10-year government bond yield spread for the FX pair currently on your chart. Switch from EURUSD to USDJPY to GBPAUD and the indicator instantly recalculates — no manual reconfiguration needed.

[b]What it shows[/b]

The spread between the base currency's 10Y yield and the quote currency's 10Y yield, expressed in basis points. For example:
[list]
[*][b]USD/JPY[/b] → US10Y minus JP10Y
[*][b]EUR/USD[/b] → DE10Y (Bund) minus US10Y
[*][b]GBP/AUD[/b] → GB10Y minus AU10Y
[/list]

A positive spread (green) means the base currency offers a yield premium — historically a tailwind for the pair. A negative spread (red) means the opposite. The wider the spread, the stronger the rates differential pushing the pair.

[b]Why it matters[/b]

Yield differentials are one of the most reliable medium-term drivers of major FX pairs. When the spread trends one way and the pair trends the other, you're often looking at a setup waiting to resolve — either the pair catches up, or the spread breaks. Particularly powerful for:
[list]
[*]Carry trade decisions (positive spreads = positive carry on the long side)
[*]Filtering FX trades against the macro backdrop
[*]Spotting divergences between price and rates
[*]Anticipating central bank repricing impact across pairs
[*]Confirming or fading reactions to CPI, NFP, and rate decisions
[/list]

[b]Supported pairs[/b]

All combinations of the 8 majors: USD, EUR, JPY, GBP, AUD, NZD, CAD, CHF. Auto-detection works on standard naming (EURUSD, EUR/USD, OANDA:USDJPY, FX:GBPJPY, etc.). For exotic symbols or futures, switch to Manual mode and pick base/quote from the dropdowns.

[b]Yield benchmarks used[/b]

[list]
[*][b]USD[/b] → US10Y (US Treasury)
[*][b]EUR[/b] → DE10Y (German Bund, eurozone benchmark)
[*][b]JPY[/b] → JP10Y (JGB)
[*][b]GBP[/b] → GB10Y (Gilt)
[*][b]AUD[/b] → AU10Y
[*][b]NZD[/b] → NZ10Y
[*][b]CAD[/b] → CA10Y
[*][b]CHF[/b] → CH10Y
[/list]

[b]Settings[/b]

[list]
[*][b]Moving average[/b]: configurable SMA overlay (default 50) to smooth the spread trend
[*][b]Zero line[/b]: visual reference for spread sign change
[*][b]Background fill[/b]: green above zero, red below — instant regime read
[*][b]End label[/b]: shows current pair and live spread value in bps
[*][b]Pair detection[/b]: Auto (reads chart ticker) or Manual (override with dropdowns)
[/list]

[b]Recommended setup[/b]

Works on any FX chart timeframe from 15m to daily. For best results, pair this with my companion indicator [b]Bond Yield Strength — 10Y Majors[/b] to see the full rates landscape alongside the specific spread of your pair.

[b]Notes[/b]

DE10Y (German Bund) is used as the EUR proxy — it's the de facto eurozone benchmark used by rates desks globally. Data availability for some symbols depends on your TradingView plan; if a yield doesn't render, your plan may not include that exchange.

Feedback and suggestions welcome.

## Source Code

````pine
//@version=6
indicator("10Y Yield Spread Overlay — Auto FX Pair", overlay=true, precision=2)

// === Inputs ===
lookback    = input.int(200, "Scaling lookback (bars)", minval=20, tooltip="Number of bars used to compute the scaling range. Larger = more stable but less reactive.")
lw          = input.int(2, "Line thickness", minval=1, maxval=4)
showLabel   = input.bool(true, "Show end label")
manualOverride = input.string("Auto", "Pair detection", options=["Auto", "Manual"])
manualBase  = input.string("USD", "Manual base",  options=["USD","EUR","JPY","GBP","AUD","NZD","CAD","CHF"])
manualQuote = input.string("JPY", "Manual quote", options=["USD","EUR","JPY","GBP","AUD","NZD","CAD","CHF"])

// === Map currency code to 10Y yield symbol ===
yieldSymbol(cur) =>
    switch cur
        "USD" => "TVC:US10Y"
        "EUR" => "TVC:DE10Y"
        "JPY" => "TVC:JP10Y"
        "GBP" => "TVC:GB10Y"
        "AUD" => "TVC:AU10Y"
        "NZD" => "TVC:NZ10Y"
        "CAD" => "TVC:CA10Y"
        "CHF" => "TVC:CH10Y"
        => "TVC:US10Y"

// === Auto-detect pair from chart ticker ===
ticker = syminfo.ticker
clean  = str.upper(str.replace_all(str.replace_all(str.replace_all(ticker, "/", ""), ".", ""), "_", ""))

autoBase  = str.length(clean) >= 6 ? str.substring(clean, 0, 3) : "USD"
autoQuote = str.length(clean) >= 6 ? str.substring(clean, 3, 6) : "JPY"

isValid(c) => c == "USD" or c == "EUR" or c == "JPY" or c == "GBP" or c == "AUD" or c == "NZD" or c == "CAD" or c == "CHF"

base  = manualOverride == "Manual" ? manualBase  : (isValid(autoBase)  ? autoBase  : "USD")
quote = manualOverride == "Manual" ? manualQuote : (isValid(autoQuote) ? autoQuote : "JPY")

// === Fetch yields ===
baseY  = request.security(yieldSymbol(base),  timeframe.period, close)
quoteY = request.security(yieldSymbol(quote), timeframe.period, close)

// === Raw spread in basis points ===
spreadBps = (baseY - quoteY) * 100

// === Rescale spread to fit the price range ===
priceHigh  = ta.highest(close,    lookback)
priceLow   = ta.lowest(close,     lookback)
spreadHigh = ta.highest(spreadBps, lookback)
spreadLow  = ta.lowest(spreadBps,  lookback)

priceRange  = priceHigh  - priceLow
spreadRange = spreadHigh - spreadLow

spreadNorm   = spreadRange != 0 ? (spreadBps - spreadLow) / spreadRange : 0.5
spreadScaled = priceLow + spreadNorm * priceRange

// === Plot ===
spreadColor = spreadBps >= 0 ? color.rgb(34,197,94) : color.rgb(239,68,68)
plot(spreadScaled, "Scaled Spread", color=spreadColor, linewidth=lw)

// === End label (shows REAL spread value in bps, not the scaled position) ===
var label endLbl = na
if showLabel and barstate.islast
    label.delete(endLbl)
    pairTxt = base + "/" + quote
    valTxt  = str.tostring(spreadBps, "+#.#;-#.#") + " bps"
    endLbl := label.new(bar_index, spreadScaled, pairTxt + "  " + valTxt, xloc=xloc.bar_index, color=spreadColor, textcolor=color.white, style=label.style_label_left, size=size.normal)
````
