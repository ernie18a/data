# ATR Stop & Position Size Planner

- url: https://www.tradingview.com/script/WZiNRLIw-ATR-Stop-Position-Size-Planner/
- type: indicator
- pine_id: PUB;cd00f2a8a0e04e34908dca137ec717b2
- version: 1.0

## Description

OVERVIEW
This indicator turns the symbol's current volatility into a suggested stop distance and converts your chosen account risk percentage into a position size in lots and units. It handles the steps that are easy to get wrong when sizing CFD, forex, gold or oil positions by hand: contract size per lot, converting quote-currency profit and loss into your account currency, and rounding to your broker's lot step. It also plots an ATR trailing volatility stop with flip markers on confirmed bars.

WHAT MAKES IT DIFFERENT
Most ATR tools stop at drawing bands. This one goes further and works out the full chain on the chart: ATR -> stop distance in price and in pips/points -> money at risk -> loss per 1.00 lot in your account currency -> lot size rounded down to your broker's step -> the risk that actually remains after rounding. Projected stop and target levels for a hypothetical long and short are drawn to the right of the last bar.

HOW IT WORKS
- ATR is the selected moving average (RMA, SMA, EMA or WMA) of the true range over the chosen length.
- Stop distance = ATR x the stop multiplier, measured from the reference price (the bar close).
- Risk budget = account balance x risk %.
- Loss per 1.00 lot at the stop = stop distance x contract size x conversion rate (quote currency to account currency).
- Suggested lots = risk budget / loss per lot, rounded DOWN to the lot step and capped at the maximum lot. The panel then shows the actual risk at that rounded size.
- Conversion uses TradingView's daily currency rate from the symbol's quote currency to your account currency (for example JPY to USD on USDJPY). You can enter a manual rate instead.
- Targets are placed at the chosen R multiple of the stop distance.
- Trailing volatility stop: a close-based stop that ratchets in the trend direction at a distance of ATR x the trailing multiplier and flips when price closes through it.

HOW TO USE
1. Choose the instrument preset that matches your broker's contract size (or select Custom), then set the lot step, minimum lot and maximum lot from your broker's contract specification.
2. Enter your account balance, account currency and risk per trade.
3. Choose an ATR length and stop multiplier that suit your timeframe and style. Wider multipliers give wider stops and smaller positions.
4. Read the panel: stop distance, risk budget, suggested lots/units and the risk remaining after rounding. The projected SL/TP lines show where those levels sit relative to the current price.
5. Always check the suggested size against your trading platform's own margin and risk calculator before you place an order.

INPUTS
ATR stop
- ATR length, ATR smoothing, Stop distance (x ATR), Target (R multiple; 0 hides targets).
- Use last closed bar: while a bar is still forming, the panel uses the last confirmed bar's ATR and close so the numbers do not change tick by tick.
Account & risk
- Account balance, Risk per trade (%), Account currency.
- Quote-to-account conversion: Automatic (TradingView daily rate) or Manual, plus the manual rate (value of 1 unit of the quote currency in account currency).
Contract specification
- Instrument preset: Forex 100,000; Gold 100 oz; Silver 5,000 oz; Crude oil 1,000 bbl; Index/share CFD 1 unit; Symbol point value; or Custom.
- Custom contract size, Lot step, Minimum lot, Maximum lot.
- Pip / point size: 0 = automatic (10 x tick size for 3/5-decimal forex pairs, otherwise tick size). Override it if you use a different convention, for example 0.1 for gold.
Trailing volatility stop
- Show trailing stop, Trailing distance (x ATR), colors, and flip markers.
Display
- Panel on/off, position, text size, which projected levels to show (Both/Long/Short/None) and their colors.

ALERTS
- "Trailing stop flipped to long bias" and "Trailing stop flipped to short bias". Both conditions only trigger on a confirmed bar close.

NON-REPAINTING NOTES
All values on historical bars are final. The trailing stop and flip markers are based on closes, and flips are only marked after the bar closes. With "Use last closed bar" enabled, the panel and projected levels do not move while the current bar forms.

LIMITATIONS
- Contract sizes, lot steps, pip definitions and margin rules differ between brokers and account types. The presets are common conventions, not guarantees. Confirm them with your broker.
- Spread, commission, swap and slippage are not included, so real losses at the stop can be larger than the risk shown.
- The automatic currency conversion uses a daily rate that may differ from your broker's live rate and can change during the day. If no rate is available, the panel shows a warning and uses 1.0 until you set a manual rate.
- When the calculated size is below the minimum lot, the panel shows a warning: trading the minimum lot would risk more than your budget.
- The ATR-based stop is a volatility estimate, not a support or resistance level, and it does not predict where price will go.

This script is for educational and informational purposes only and is not financial advice. Trading CFDs and forex involves significant risk of loss.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0
// Â© cfdtools
//
// ATR Stop & Position Size Planner
// Turns current volatility (ATR) into a suggested stop distance, then converts
// an account risk percentage into a position size in lots and units for the
// chart symbol, including quote-to-account currency conversion and broker lot
// rounding. Also plots an ATR trailing volatility stop with confirmed flips.

indicator("ATR Stop & Position Size Planner", shorttitle = "ATR Risk Planner", overlay = true, max_lines_count = 50, max_labels_count = 50)

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Inputs
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
GRP_ATR = "ATR stop"
GRP_ACC = "Account & risk"
GRP_CON = "Contract specification"
GRP_TRL = "Trailing volatility stop"
GRP_DSP = "Display"

atrLen    = input.int(14, "ATR length", minval = 1, group = GRP_ATR, tooltip = "Number of bars used to average the true range.")
atrMa     = input.string("RMA", "ATR smoothing", options = ["RMA", "SMA", "EMA", "WMA"], group = GRP_ATR, tooltip = "Moving average applied to the true range. RMA is the classic Wilder ATR used by most platforms.")
stopMult  = input.float(1.5, "Stop distance (x ATR)", minval = 0.1, step = 0.1, group = GRP_ATR, tooltip = "Suggested stop distance = ATR x this multiplier, measured from the reference price (the bar close).")
rrTarget  = input.float(2.0, "Target (R multiple)", minval = 0.0, step = 0.25, group = GRP_ATR, tooltip = "Target distance as a multiple of the stop distance (R). Set to 0 to hide targets.")
useClosed = input.bool(true, "Use last closed bar", group = GRP_ATR, tooltip = "While a bar is still forming, use the ATR and close of the last confirmed bar so the panel does not change tick by tick. Historical values never change either way.")

balance  = input.float(10000.0, "Account balance", minval = 0.0, step = 100.0, group = GRP_ACC, tooltip = "Account balance or equity in the account currency selected below.")
riskPct  = input.float(1.0, "Risk per trade (%)", minval = 0.01, maxval = 100.0, step = 0.05, group = GRP_ACC, tooltip = "Percentage of the balance you are willing to lose if the suggested stop is hit (spread, commission and slippage not included).")
acctCcy  = input.string("USD", "Account currency", options = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "NZD", "SGD", "HKD", "INR", "ZAR", "AED"], group = GRP_ACC)
fxMode   = input.string("Automatic", "Quote-to-account conversion", options = ["Automatic", "Manual"], group = GRP_ACC, tooltip = "Profit and loss of a CFD or forex pair is in the symbol's quote currency. 'Automatic' converts it with TradingView's daily currency rate. Use 'Manual' if the rate is unavailable or you want to use your broker's rate.")
fxManual = input.float(1.0, "Manual rate (1 quote unit = x account units)", minval = 0.0, step = 0.0001, group = GRP_ACC, tooltip = "Only used in Manual mode. Example: chart USDJPY (quote JPY) with a USD account -> enter the value of 1 JPY in USD (about 1 / USDJPY).")

preset   = input.string("Forex (100,000 units)", "Instrument preset", options = ["Forex (100,000 units)", "Gold XAU (100 oz)", "Silver XAG (5,000 oz)", "Crude oil (1,000 bbl)", "Index / share CFD (1 unit)", "Symbol point value", "Custom"], group = GRP_CON, tooltip = "Units per 1.00 lot. Contract sizes differ between brokers, so always confirm with your broker's contract specification. 'Symbol point value' uses TradingView's point value for the symbol (useful for futures).")
customCs = input.float(100000.0, "Custom contract size (units per 1.00 lot)", minval = 0.000001, group = GRP_CON, tooltip = "Only used when the preset is 'Custom'.")
lotStep  = input.float(0.01, "Lot step", minval = 0.0001, step = 0.01, group = GRP_CON, tooltip = "Smallest lot increment your broker allows. The suggested size is always rounded DOWN to this step so the risk never exceeds the budget.")
minLot   = input.float(0.01, "Minimum lot", minval = 0.0, step = 0.01, group = GRP_CON)
maxLot   = input.float(50.0, "Maximum lot", minval = 0.0001, step = 1.0, group = GRP_CON)
pipIn    = input.float(0.0, "Pip / point size (0 = auto)", minval = 0.0, step = 0.00001, group = GRP_CON, tooltip = "Price increment used to express the stop distance in pips/points. Auto: forex symbols quoted with 3 or 5 decimals use 10 x tick size; everything else uses the tick size. Example: enter 0.1 for gold if you count gold pips as 0.10.")

showTrail = input.bool(true, "Show trailing stop", group = GRP_TRL, tooltip = "ATR trailing volatility stop calculated from closes. It ratchets in the trend direction and flips when a bar closes through it.")
trailMult = input.float(3.0, "Trailing distance (x ATR)", minval = 0.1, step = 0.1, group = GRP_TRL)
colUp     = input.color(#26A69A, "Long bias", inline = "tc", group = GRP_TRL)
colDn     = input.color(#EF5350, "Short bias", inline = "tc", group = GRP_TRL)
showFlips = input.bool(true, "Show flip markers", group = GRP_TRL, tooltip = "Markers appear only after the flip bar has closed.")

showPanel = input.bool(true, "Show panel", group = GRP_DSP)
panelPos  = input.string("Top right", "Panel position", options = ["Top right", "Top left", "Middle right", "Bottom right", "Bottom left"], group = GRP_DSP)
panelTxt  = input.string("Small", "Panel text size", options = ["Tiny", "Small", "Normal"], group = GRP_DSP)
levelSide = input.string("Both", "Projected levels", options = ["Both", "Long", "Short", "None"], group = GRP_DSP, tooltip = "Draws the suggested stop and target levels to the right of the last bar for a hypothetical long and/or short entered at the reference price.")
colStop   = input.color(#EF5350, "Stop", inline = "lv", group = GRP_DSP)
colTgt    = input.color(#26A69A, "Target", inline = "lv", group = GRP_DSP)
colRef    = input.color(color.gray, "Reference", inline = "lv", group = GRP_DSP)

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Helpers
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
fmt(float v, string f) =>
    na(v) ? "-" : str.tostring(v, f)

addLevel(array<line> lines, array<label> labels, float price, string name, color col, string st) =>
    if not na(price)
        lines.push(line.new(bar_index, price, bar_index + 12, price, color = col, style = st, width = 1))
        labels.push(label.new(bar_index + 12, price, name + "  " + str.tostring(price, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = col, size = size.small))

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// ATR (all variants calculated on every bar for consistency, one is selected)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
float trueRange = ta.tr(true)
float atrRma    = ta.rma(trueRange, atrLen)
float atrSma    = ta.sma(trueRange, atrLen)
float atrEma    = ta.ema(trueRange, atrLen)
float atrWma    = ta.wma(trueRange, atrLen)
float atrRaw    = switch atrMa
    "SMA" => atrSma
    "EMA" => atrEma
    "WMA" => atrWma
    => atrRma

// On historical bars barstate.isconfirmed is always true, so history is identical
// in both modes; the switch only matters on the forming realtime bar.
bool  useCurrent = barstate.isconfirmed or not useClosed
float atrNow     = useCurrent ? atrRaw : atrRaw[1]
float refPrice   = useCurrent ? close : close[1]

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Contract, pip size and currency conversion
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
float contractSize = switch preset
    "Forex (100,000 units)"      => 100000.0
    "Gold XAU (100 oz)"          => 100.0
    "Silver XAG (5,000 oz)"      => 5000.0
    "Crude oil (1,000 bbl)"      => 1000.0
    "Index / share CFD (1 unit)" => 1.0
    "Symbol point value"         => syminfo.pointvalue
    => customCs

bool   isFx     = syminfo.type == "forex"
int    tickDec  = math.round(-math.log10(syminfo.mintick))
float  pipAuto  = isFx and (tickDec == 3 or tickDec == 5) ? syminfo.mintick * 10.0 : syminfo.mintick
float  pipSize  = pipIn > 0.0 ? pipIn : pipAuto
string pipName  = isFx ? "pips" : "points"

// Daily conversion rate from the symbol's quote currency to the account currency.
float fxAuto = request.currency_rate(syminfo.currency, acctCcy, ignore_invalid_currency = true)
bool  fxOk   = fxMode == "Manual" ? fxManual > 0.0 : not na(fxAuto) and fxAuto > 0.0
float fxRate = fxMode == "Manual" ? fxManual : fxOk ? fxAuto : 1.0

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Risk & position size
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
float stopDist   = atrNow * stopMult
float riskMoney  = balance * riskPct / 100.0
float lossPerLot = stopDist * contractSize * fxRate
float rawLots    = not na(lossPerLot) and lossPerLot > 0.0 ? riskMoney / lossPerLot : na
float lots       = na(rawLots) ? na : math.min(math.floor(rawLots / lotStep + 1e-9) * lotStep, maxLot)
bool  belowMin   = not na(lots) and lots < minLot
float units      = na(lots) ? na : lots * contractSize
float actualRisk = na(lots) ? na : lots * lossPerLot
float stopPips   = pipSize > 0.0 ? stopDist / pipSize : na

float longStop  = refPrice - stopDist
float shortStop = refPrice + stopDist
float longTgt   = rrTarget > 0.0 ? refPrice + stopDist * rrTarget : na
float shortTgt  = rrTarget > 0.0 ? refPrice - stopDist * rrTarget : na

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// ATR trailing volatility stop (close-based)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var float tsMax = na
var float tsMin = na
var float ts    = na
var bool  tsUp  = true

float trailAtr = nz(atrRaw * trailMult, trueRange)
tsMax := na(tsMax) ? close : math.max(tsMax, close)
tsMin := na(tsMin) ? close : math.min(tsMin, close)
ts    := nz(tsUp ? math.max(ts, tsMax - trailAtr) : math.min(ts, tsMin + trailAtr), close)

bool prevUp = tsUp
tsUp := close - ts >= 0.0
if tsUp != prevUp
    tsMax := close
    tsMin := close
    ts    := tsUp ? tsMax - trailAtr : tsMin + trailAtr

bool flipUp = barstate.isconfirmed and tsUp and not prevUp
bool flipDn = barstate.isconfirmed and not tsUp and prevUp

plot(showTrail and tsUp == prevUp ? ts : na, "Trailing stop", color = tsUp ? colUp : colDn, style = plot.style_linebr, linewidth = 2)
plotshape(showTrail and showFlips and flipUp, "Trailing stop flip up", shape.triangleup, location.belowbar, colUp, size = size.tiny)
plotshape(showTrail and showFlips and flipDn, "Trailing stop flip down", shape.triangledown, location.abovebar, colDn, size = size.tiny)

alertcondition(flipUp, "Trailing stop flipped to long bias", "{{ticker}}: ATR trailing stop flipped to long bias on a confirmed close.")
alertcondition(flipDn, "Trailing stop flipped to short bias", "{{ticker}}: ATR trailing stop flipped to short bias on a confirmed close.")

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Projected levels (last bar only)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var array<line>  lvLines  = array.new<line>()
var array<label> lvLabels = array.new<label>()

if barstate.islast
    for ln in lvLines
        ln.delete()
    for lb in lvLabels
        lb.delete()
    lvLines.clear()
    lvLabels.clear()
    if levelSide != "None" and not na(stopDist)
        addLevel(lvLines, lvLabels, refPrice, "Ref", colRef, line.style_dotted)
        if levelSide == "Both" or levelSide == "Long"
            addLevel(lvLines, lvLabels, longStop, "Long SL", colStop, line.style_dashed)
            addLevel(lvLines, lvLabels, longTgt, "Long TP", colTgt, line.style_dashed)
        if levelSide == "Both" or levelSide == "Short"
            addLevel(lvLines, lvLabels, shortStop, "Short SL", colStop, line.style_dashed)
            addLevel(lvLines, lvLabels, shortTgt, "Short TP", colTgt, line.style_dashed)

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Panel
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
string tblPos = switch panelPos
    "Top left"     => position.top_left
    "Middle right" => position.middle_right
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_right

string tblTxt = switch panelTxt
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

color TBL_BG   = color.new(#131722, 5)
color TBL_HEAD = color.new(#2A2E39, 0)
color TBL_TXT  = color.new(#D1D4DC, 0)
color TBL_WARN = color.new(#FF9800, 0)

var table panel = table.new(tblPos, 2, 13, bgcolor = TBL_BG, frame_color = TBL_HEAD, frame_width = 1, border_color = TBL_HEAD, border_width = 1)

panelRow(table t, int row, string k, string v, color vCol) =>
    table.cell(t, 0, row, k, text_color = TBL_TXT, text_size = tblTxt, text_halign = text.align_left)
    table.cell(t, 1, row, v, text_color = vCol, text_size = tblTxt, text_halign = text.align_right)

if barstate.islast and showPanel
    array<string> stepParts = str.split(str.tostring(lotStep), ".")
    int    lotDec = stepParts.size() > 1 ? str.length(stepParts.get(1)) : 0
    string lotFmt = lotDec > 0 ? "0." + str.repeat("0", lotDec) : "0"
    string money  = "#,##0.00"

    string note = "OK"
    color  noteCol = TBL_TXT
    if na(atrNow)
        note    := "Not enough bars for ATR yet"
        noteCol := TBL_WARN
    else if not fxOk
        note    := "No " + syminfo.currency + "/" + acctCcy + " rate - using 1.0, set Manual"
        noteCol := TBL_WARN
    else if belowMin
        note    := "Size below minimum lot - risk budget too small"
        noteCol := TBL_WARN

    table.cell(panel, 0, 0, "ATR Risk Planner", text_color = TBL_TXT, bgcolor = TBL_HEAD, text_size = tblTxt, text_halign = text.align_left)
    table.cell(panel, 1, 0, syminfo.ticker + (useCurrent ? "" : " (last close)"), text_color = TBL_TXT, bgcolor = TBL_HEAD, text_size = tblTxt, text_halign = text.align_right)
    panelRow(panel, 1, "ATR(" + str.tostring(atrLen) + ") " + atrMa, fmt(atrNow, format.mintick), TBL_TXT)
    panelRow(panel, 2, "Stop distance (" + str.tostring(stopMult) + " x ATR)", fmt(stopDist, format.mintick) + "  (" + fmt(stopPips, "#,##0.0") + " " + pipName + ")", TBL_TXT)
    panelRow(panel, 3, "Risk budget (" + str.tostring(riskPct) + "%)", fmt(riskMoney, money) + " " + acctCcy, TBL_TXT)
    panelRow(panel, 4, "Contract size", fmt(contractSize, "#,##0.####") + " units / lot", TBL_TXT)
    panelRow(panel, 5, "Loss per 1.00 lot at stop", fmt(lossPerLot, money) + " " + acctCcy, TBL_TXT)
    panelRow(panel, 6, "Suggested size", fmt(lots, lotFmt) + " lots", belowMin ? TBL_WARN : colUp)
    panelRow(panel, 7, "Units", fmt(units, "#,##0.####"), TBL_TXT)
    panelRow(panel, 8, "Risk at rounded size", fmt(actualRisk, money) + " " + acctCcy + "  (" + fmt(balance > 0.0 ? actualRisk / balance * 100.0 : na, "0.00") + "%)", TBL_TXT)
    panelRow(panel, 9, "Long  SL / TP", fmt(longStop, format.mintick) + " / " + fmt(longTgt, format.mintick), TBL_TXT)
    panelRow(panel, 10, "Short SL / TP", fmt(shortStop, format.mintick) + " / " + fmt(shortTgt, format.mintick), TBL_TXT)
    panelRow(panel, 11, "Trailing stop", fmt(ts, format.mintick) + (tsUp ? "  (long bias)" : "  (short bias)"), tsUp ? colUp : colDn)
    panelRow(panel, 12, syminfo.currency + " -> " + acctCcy + " rate", fmt(fxRate, "0.######") + "  |  " + note, noteCol)
````
