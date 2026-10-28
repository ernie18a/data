# MA High / Low + WAD vs MA(WAD) zones

- url: https://www.tradingview.com/script/MJnJSvQe-MA-High-Low-WAD-vs-MA-WAD-zones/
- type: indicator
- pine_id: PUB;6276c95614204eb4b3b83f907a92c00d
- version: 2.0

## Description

// MA High / MA Low lines + background zones where Williams Accumulation/Distribution (WAD)
// minus MA(WAD) is positive vs negative.

## Source Code

````pine
//@version=5
// MA High / MA Low lines + background zones where Williams Accumulation/Distribution (WAD)
// minus MA(WAD) is positive vs negative. Paste into TradingView Pine Editor (v5).

indicator(
     title = "MA High / Low + WAD vs MA(WAD) zones",
     shorttitle = "MA-HL · WAD",
     overlay = true
 )

// ─── Moving averages of High / Low ───────────────────────────────────────────
grpMa = "Moving averages (price)"
maHighLen = input.int(20, "MA High — length (bars)", minval = 1, group = grpMa)
maLowLen  = input.int(20, "MA Low — length (bars)",  minval = 1, group = grpMa)
maType    = input.string("SMA", "MA type (High & Low)", options = ["SMA", "EMA", "WMA", "VWMA"], group = grpMa)

colMaHigh = input.color(color.new(#089981, 0), "MA High — color", group = grpMa)
colMaLow  = input.color(color.new(#2962FF, 0), "MA Low — color",  group = grpMa)
widthMa   = input.int(2, "MA line width", minval = 1, maxval = 5, group = grpMa)

maPrice(float src, int len) =>
    switch maType
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        =>        ta.sma(src, len)

maHighLine = maPrice(high, maHighLen)
maLowLine  = maPrice(low, maLowLen)

plot(maHighLine, title = "MA High", color = colMaHigh, linewidth = widthMa)
plot(maLowLine,  title = "MA Low",  color = colMaLow,  linewidth = widthMa)

// ─── Williams Accumulation / Distribution (WAD), cumulative ─────────────────
// Larry Williams: TRH = max(prev close, high), TRL = min(prev close, low);
// if close > prev: add (close - TRL); if close < prev: add (close - TRH); else 0.
grpWad = "WAD vs MA(WAD) background"
wadMaLen   = input.int(57, "MA(WAD) — length (bars)", minval = 1, group = grpWad)
wadMaType  = input.string("SMA", "MA(WAD) type", options = ["SMA", "EMA", "WMA", "VWMA"], group = grpWad)
showWadBg  = input.bool(true, "Show background zones", group = grpWad)
colWadPos  = input.color(color.new(#26A69A, 82), "Zone: WAD − MA(WAD) ≥ 0", group = grpWad)
colWadNeg  = input.color(color.new(#EF5350, 82), "Zone: WAD − MA(WAD) < 0",  group = grpWad)

wadAd() =>
    if bar_index == 0
        0.0
    else if close > close[1]
        close - math.min(low, close[1])
    else if close < close[1]
        close - math.max(high, close[1])
    else
        0.0

wad = 0.0
wad := nz(wad[1], 0.0) + wadAd()

wadSmooth(float src, int len) =>
    switch wadMaType
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        =>        ta.sma(src, len)

wadSmoothed = wadSmooth(wad, wadMaLen)
wadDiff     = wad - wadSmoothed

bgcolor(
     showWadBg ? (wadDiff >= 0 ? colWadPos : colWadNeg) : na,
     title = "WAD − MA(WAD)"
 )
````
