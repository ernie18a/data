# BTC Aggregated Funding Rate

- url: https://www.tradingview.com/script/1MqGqSHa-BTC-Aggregated-Funding-Rate/
- type: indicator
- pine_id: PUB;da1256f2032946efa9afe0c11d198c02
- version: 4.0

## Description

BTC Aggregated Funding Rate

Funding across Binance, Bybit, OKX and Hyperliquid, put on a common basis and combined into one line — so you see what the whole perpetual market is paying, not one exchange.

WHAT IT SHOWS
- Funding line: green when positive (longs pay shorts), red when negative (shorts pay longs), shaded to zero.
- Neutral baseline (dotted): 0.01% per 8 hours (about 10.95% a year), the standard rate most exchanges settle at when neither side is crowded.
- Summary (top right): current funding per 8 hours and annualized.

WHAT MAKES IT DIFFERENT
- Common basis across exchanges. Hyperliquid pays funding every hour while the others pay every 8 hours. Averaging those raw rates together understates funding roughly eightfold; here every exchange is converted to a per-8-hour rate first.
- OI-weighted. Each exchange's funding is weighted by its open interest, so larger markets count for more. A simple average is available as an option.
- Unit detection. Funding data can arrive as a fraction (0.0001) or a percent (0.01); the script detects which and converts automatically, with a manual override.

HOW TO READ IT
- Near the baseline: balanced positioning.
- Well above the baseline: longs paying up to hold positions — leverage is leaning long.
- Below zero: shorts paying — leverage is leaning short.
- Funding describes how positioning leans, not when it will unwind. Crowded readings can persist for weeks in a strong trend. Read it alongside open interest and price structure rather than as a signal on its own.

SETTINGS
- Exchanges: toggle each one, change the symbol, set its OI unit (used for weighting) and its funding interval in hours.
- Show funding per 8 hours or annualized.
- OI-weighted or simple average.
- Optional smoothing, shading and baseline.

NOTES
- Funding data is retrieved with TradingView's open-source Request library (cryptoDerivativeMetric); open interest for weighting uses TradingView's "_OI" feeds.
- Values are taken at each bar's close; on the daily chart each point is that day's closing funding reading.
- Exchange histories start at different dates; early values may include fewer exchanges.
- This is an analysis tool, not financial advice or a trading signal.

## Source Code

````pine
//@version=6
indicator("BTC Aggregated Funding Rate", shorttitle = "BTC FR", overlay = false, scale = scale.right, precision = 4)
import TradingView/Request/3 as req

// Funding across the same four exchanges LiqVP uses, converted to a common 8-hour basis
// (Hyperliquid pays hourly) and OI-weighted.

COINS = "Coins (BTC)"
USDU  = "USD"

grpX = "Exchanges  (on / perp / OI unit / funding hours)"
x1on = input.bool(true, "X1", inline = "x1", group = grpX), x1sym = input.symbol("BINANCE:BTCUSDT.P",     "", inline = "x1", group = grpX), x1u = input.string(COINS, "", options = [COINS, USDU], inline = "x1", group = grpX), x1h = input.int(8, "h", minval = 1, maxval = 24, inline = "x1", group = grpX)
x2on = input.bool(true, "X2", inline = "x2", group = grpX), x2sym = input.symbol("BYBIT:BTCUSDT.P",       "", inline = "x2", group = grpX), x2u = input.string(COINS, "", options = [COINS, USDU], inline = "x2", group = grpX), x2h = input.int(8, "h", minval = 1, maxval = 24, inline = "x2", group = grpX)
x3on = input.bool(true, "X3", inline = "x3", group = grpX), x3sym = input.symbol("OKX:BTCUSDT.P",         "", inline = "x3", group = grpX), x3u = input.string(USDU,  "", options = [COINS, USDU], inline = "x3", group = grpX), x3h = input.int(8, "h", minval = 1, maxval = 24, inline = "x3", group = grpX)
x4on = input.bool(true, "X4", inline = "x4", group = grpX), x4sym = input.symbol("HYPERLIQUID:BTCUSDC.P", "", inline = "x4", group = grpX), x4u = input.string(USDU,  "", options = [COINS, USDU], inline = "x4", group = grpX), x4h = input.int(1, "h", minval = 1, maxval = 24, inline = "x4", group = grpX)
fUnits = input.string("Auto", "Funding units in source data", options = ["Auto", "Fraction", "Percent"], group = grpX)

grpV     = "Display"
showAs   = input.string("Per 8h %", "Show funding as", options = ["Per 8h %", "Annualized %"], group = grpV)
weightM  = input.string("OI-weighted", "Average across exchanges", options = ["OI-weighted", "Simple"], group = grpV)
smooth   = input.int(1, "Smoothing (EMA bars, 1 = off)", minval = 1, group = grpV)
shade    = input.bool(true, "Shade to zero", group = grpV)
posCol   = input.color(color.new(color.lime, 0), "Positive (longs pay)", group = grpV)
negCol   = input.color(color.new(color.red, 0), "Negative (shorts pay)", group = grpV)
showTbl  = input.bool(true, "Show funding summary", group = grpV)

grpB     = "Neutral baseline (0.01% per 8h)"
showBase = input.bool(true, "Show neutral baseline", group = grpB, tooltip = "0.01% per 8 hours (about 10.95% a year) is the standard rate most exchanges settle at when neither side is crowded.")
baseSty  = input.string("Dotted", "Style", options = ["Dotted", "Dashed"], group = grpB)
baseCol  = input.color(color.new(color.silver, 0), "Color", group = grpB)
baseW    = input.int(2, "Width", minval = 1, maxval = 4, group = grpB)

f_fund(bool on, string sym) =>
    float f = na
    if on
        f := req.cryptoDerivativeMetric(sym, "Funding Rate", timeframe.period, false, true)
    f

f_oi(bool on, string sym, string unit) =>
    float oi = request.security(sym + "_OI", timeframe.period, close, ignore_invalid_symbol = true)
    on ? (unit == USDU ? oi / close : oi) : na

f_w(float f, float oi) =>
    bool ok = not na(f) and not na(oi) and oi > 0
    [ok ? f * oi : 0.0, ok ? oi : 0.0]

// raw funding per exchange, unit-detected, converted to % per 8 hours
r1 = f_fund(x1on, x1sym)
r2 = f_fund(x2on, x2sym)
r3 = f_fund(x3on, x3sym)
r4 = f_fund(x4on, x4sym)
var float maxAbsRaw = 0.0
maxAbsRaw := math.max(maxAbsRaw, math.abs(nz(r1)), math.abs(nz(r2)), math.abs(nz(r3)), math.abs(nz(r4)))
bool  isFraction = fUnits == "Fraction" or (fUnits == "Auto" and maxAbsRaw > 0 and maxAbsRaw < 0.005)
float fMult = isFraction ? 100.0 : 1.0
f1 = r1 * fMult * 8.0 / x1h
f2 = r2 * fMult * 8.0 / x2h
f3 = r3 * fMult * 8.0 / x3h
f4 = r4 * fMult * 8.0 / x4h

// OI for weighting (BTC)
o1 = f_oi(x1on, x1sym, x1u)
o2 = f_oi(x2on, x2sym, x2u)
o3 = f_oi(x3on, x3sym, x3u)
o4 = f_oi(x4on, x4sym, x4u)
[a1, w1] = f_w(f1, o1)
[a2, w2] = f_w(f2, o2)
[a3, w3] = f_w(f3, o3)
[a4, w4] = f_w(f4, o4)
wSum    = w1 + w2 + w3 + w4
cntF    = (na(f1) ? 0 : 1) + (na(f2) ? 0 : 1) + (na(f3) ? 0 : 1) + (na(f4) ? 0 : 1)
simpleF = cntF > 0 ? (nz(f1) + nz(f2) + nz(f3) + nz(f4)) / cntF : na
fund8h  = weightM == "Simple" ? simpleF : (wSum > 0 ? (a1 + a2 + a3 + a4) / wSum : simpleF)

annual  = showAs == "Annualized %"
fDisp   = annual ? fund8h * 3 * 365 : fund8h
fS      = ta.ema(fDisp, smooth)

pF = plot(fS, "Funding", color = fS >= 0 ? posCol : negCol, linewidth = 2)
pZ = plot(0, "Zero", color = color.new(color.gray, 50), display = display.pane)
fill(pF, pZ, color = shade ? (fS >= 0 ? color.new(posCol, 85) : color.new(negCol, 85)) : na, title = "Shade")

// neutral baseline as a true dotted (or dashed) horizontal line
hline(annual ? 10.95 : 0.01, "Neutral baseline", color = showBase ? baseCol : color.new(color.gray, 100), linestyle = baseSty == "Dashed" ? hline.style_dashed : hline.style_dotted, linewidth = baseW)

var table tbl = table.new(position.top_right, 1, 1, bgcolor = color.new(color.black, 30))
if showTbl and barstate.islast
    string txt = na(fund8h) ? "Funding: no data" : "Funding " + (fund8h >= 0 ? "+" : "") + str.tostring(fund8h, "#.####") + "% / 8h · " + (fund8h >= 0 ? "+" : "") + str.tostring(fund8h * 1095, "#.#") + "% / yr"
    table.cell(tbl, 0, 0, txt, text_color = fund8h >= 0 ? posCol : negCol, text_size = size.small)
````
