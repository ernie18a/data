# Put Credit Spread Combined Price Tracker

- url: https://www.tradingview.com/script/bdGgYOyC-Put-Credit-Spread-Combined-Price-Tracker/
- type: indicator
- pine_id: PUB;2ec40dcaf72142cdb7137d53836c257f
- version: 1.0

## Description

📊 Description
The Put Credit Spread Combined Price Tracker is an advanced options visualization and risk assessment workspace designed specifically for multi-position credit spread sellers. Instead of guessing your proximity to risk, this indicator maps your mathematical break-even thresholds directly onto your live asset candle chart while maintaining a real-time Black-Scholes Options Pricing Matrix Dashboard.
This tool is ideal for tracking individual or nested index options structures (such as SPX, NDX, or RUT) where precision risk boundary management is critical.
________________________________________
⚙️ How to Set Up Your Spreads
1.	Add to Chart: Load the indicator on your target ticker (e.g., SPX).
2.	Open Settings: Click the gear icon on the indicator name to open the configuration menu.
3.	Configure Your Engine:
o	Keep Enable Automated Volatility checked to let the script automatically extract a continuous historical volatility proxy, or uncheck it to key in your broker's implied volatility (IV %) reading manually.
4.	Input Your Positions (Supports up to 4 Parallel Trades):
o	Check the Box to enable a specific spread position.
o	Short/Long Put Strike: Key in your exact leg boundaries.
o	Premium Received: Enter the net premium collected per spread block (e.g., 5.00 for a $500 credit).
o	Contracts Quantity: Enter your position size.
o	Start/Exp Date: Key in your precise calendar execution parameters. The indicator automatically bounds the line drawings to your trade's specific lifecycle window.
________________________________________
📉 Reading the Chart Visuals
•	Dashed Break-Even Lines: The script removes clutter by stripping out raw strike lines. Instead, it plots the absolute net financial break-even floor for each position (Short Strike - Premium Collected). If the market candles drop below this dashed line at expiration, the position enters a net loss state.
•	Right-End Anchored Labels: Each active position features a dedicated text flag pinned directly to the right margin of your screen, letting you instantly match a specific break-even line to its designated position entry.
________________________________________
🧮 Understanding the Dashboard Table (Bottom-Right)
The tracking matrix evaluates your positions dynamically using a full Black-Scholes Options Pricing model loop on every price tick:
•	Strikes (S/L): Displays your structured position boundaries for quick auditing.
•	Current Mark: Shows what the option spread is worth right now in the open market before expiry, modeling continuous time decay (\(\theta \)) and underlying spot movements.
•	Live Open P&L: Replicates your broker's dashboard. It dynamically updates using (Net Credit - Current Mark Value) * 100 * Qty. Cells turn Green for an open profit and Red for an open loss.
•	Position Delta: Displays your aggregate Greeks exposure. Since put credit spreads are directionally bullish, this value will calculate as a net positive number.
•	Current IV: Shows the exact annualized volatility proxy percentage fueling your options pricing calculations.
•	Days Left: Counts down the exact localized time window remaining before contract expiration.
________________________________________

## Source Code

````pine
//@version=6
indicator("Put Credit Spread Combined Price Tracker", overlay=true, precision=2)

// ==========================================
// VOLATILITY & ENGINE PARAMETERS
// ==========================================
grp_engine = "Volatility Settings"
useAutoIV    = input.bool(true, title="Enable Automated Volatility (Proxy IV)?", group=grp_engine)
manualIV     = input.float(25.0, title="Fallback Manual IV (%)", minval=1.0, group=grp_engine)
rInput       = input.float(4.5, title="Risk-Free Interest Rate (%)", group=grp_engine) / 100.0

// Live Historical Volatility tracking for the Black-Scholes pricing engine
logReturns   = math.log(close / close)
annualizedHV = ta.stdev(logReturns, 20) * math.sqrt(252)
float currentIV = useAutoIV ? (na(annualizedHV) or annualizedHV == 0 ? manualIV / 100.0 : annualizedHV) : (manualIV / 100.0)

// ==========================================
// POSITION SELECTION BLOCKS (1 - 4)
// ==========================================
grp_sp1 = "Spread Position #1"
enableSp1  = input.bool(true, title="Enable Spread #1?", group=grp_sp1)
shortK1    = input.float(7175.0, title="Short Put Strike", group=grp_sp1)
longK1     = input.float(7125.0, title="Long Put Strike", group=grp_sp1)
premium1   = input.float(5.00, title="Premium Received ($)", group=grp_sp1)
qty1       = input.int(1, title="Contracts Quantity", minval=1, group=grp_sp1)
stY1 = input.int(2026, "Start Year", inline="st1", group=grp_sp1), stM1 = input.int(5, "Month", inline="st1", group=grp_sp1), stD1 = input.int(1, "Day", inline="st1", group=grp_sp1)
exY1 = input.int(2026, "Exp Year", inline="ex1", group=grp_sp1), expM1 = input.int(6, "Month", inline="ex1", group=grp_sp1), expD1 = input.int(19, "Day", inline="ex1", group=grp_sp1)

grp_sp2 = "Spread Position #2"
enableSp2  = input.bool(false, title="Enable Spread #2?", group=grp_sp2)
shortK2    = input.float(410.0, title="Short Put Strike", group=grp_sp2)
longK2     = input.float(400.0, title="Long Put Strike", group=grp_sp2)
premium2   = input.float(3.00, title="Premium Received ($)", group=grp_sp2)
qty2       = input.int(1, title="Contracts Quantity", minval=1, group=grp_sp2)
stY2 = input.int(2026, "Start Year", inline="st2", group=grp_sp2), stM2 = input.int(5, "Month", inline="st2", group=grp_sp2), stD2 = input.int(1, "Day", inline="st2", group=grp_sp2)
exY2 = input.int(2026, "Exp Year", inline="ex2", group=grp_sp2), expM2 = input.int(6, "Month", inline="ex2", group=grp_sp2), expD2 = input.int(19, "Day", inline="ex2", group=grp_sp2)

grp_sp3 = "Spread Position #3"
enableSp3  = input.bool(false, title="Enable Spread #3?", group=grp_sp3)
shortK3    = input.float(500.0, title="Short Put Strike", group=grp_sp3)
longK3     = input.float(490.0, title="Long Put Strike", group=grp_sp3)
premium3   = input.float(2.50, title="Premium Received ($)", group=grp_sp3)
qty3       = input.int(1, title="Contracts Quantity", minval=1, group=grp_sp3)
stY3 = input.int(2026, "Start Year", inline="st3", group=grp_sp3), stM3 = input.int(5, "Month", inline="st3", group=grp_sp3), stD3 = input.int(1, "Day", inline="st3", group=grp_sp3)
exY3 = input.int(2026, "Exp Year", inline="ex3", group=grp_sp3), expM3 = input.int(6, "Month", inline="ex3", group=grp_sp3), expD3 = input.int(19, "Day", inline="ex3", group=grp_sp3)

grp_sp4 = "Spread Position #4"
enableSp4  = input.bool(false, title="Enable Spread #4?", group=grp_sp4)
shortK4    = input.float(150.0, title="Short Put Strike", group=grp_sp4)
longK4     = input.float(140.0, title="Long Put Strike", group=grp_sp4)
premium4   = input.float(1.50, title="Premium Received ($)", group=grp_sp4)
qty4       = input.int(1, title="Contracts Quantity", minval=1, group=grp_sp4)
stY4 = input.int(2026, "Start Year", inline="st4", group=grp_sp4), stM4 = input.int(5, "Month", inline="st4", group=grp_sp4), stD4 = input.int(1, "Day", inline="st4", group=grp_sp4)
exY4 = input.int(2026, "Exp Year", inline="ex4", group=grp_sp4), expM4 = input.int(6, "Month", inline="ex4", group=grp_sp4), expD4 = input.int(19, "Day", inline="ex4", group=grp_sp4)

// ==========================================
// DATE CONVERSIONS & TIME TO MATURITY (T)
// ==========================================
getT(exY, exM, exD) =>
    expiryTime = timestamp(exY, exM, exD, 16, 0)
    timeLeft   = expiryTime - time
    math.max(timeLeft / (365.0 * 24 * 60 * 60 * 1000), 0.00001)

t1 = getT(exY1, expM1, expD1)
t2 = getT(exY2, expM2, expD2)
t3 = getT(exY3, expM3, expD3)
t4 = getT(exY4, expM4, expD4)

// ==========================================
// BLACK-SCHOLES OPTIONS PRICING ENGINE
// ==========================================
cnd(x) =>
    a1 = 0.319381530, a2 = -0.356563782, a3 = 1.781477937, a4 = -1.821255978, a5 = 1.330274429
    L = math.abs(x)
    K = 1.0 / (1.0 + 0.2316419 * L)
    approx = 1.0 - 1.0 / math.sqrt(2 * math.pi) * math.exp(-x * x / 2.0) * (a1 * K + a2 * math.pow(K, 2) + a3 * math.pow(K, 3) + a4 * math.pow(K, 4) + a5 * math.pow(K, 5))
    x >= 0 ? approx : 1.0 - approx

bsPutPrice(S, K, T, r, sigma) =>
    d1 = (math.log(S / K) + (r + (sigma * sigma) / 2.0) * T) / (sigma * math.sqrt(T))
    d2 = d1 - sigma * math.sqrt(T)
    K * math.exp(-r * T) * cnd(-d2) - S * cnd(-d1)

bsPutDelta(S, K, T, r, sigma) =>
    d1 = (math.log(S / K) + (r + (sigma * sigma) / 2.0) * T) / (sigma * math.sqrt(T))
    cnd(d1) - 1.0

// ==========================================
// LIVE SPREAD METRICS GENERATOR
// ==========================================
getSpreadValue(shortK, longK, T, r, iv) =>
    shortPutValue = bsPutPrice(close, shortK, T, r, iv)
    longPutValue  = bsPutPrice(close, longK, T, r, iv)
    math.max(shortPutValue - longPutValue, 0.0)

getNetDelta(S, shortK, longK, T, r, iv, qty) =>
    shortD = bsPutDelta(S, shortK, T, r, iv)
    longD  = bsPutDelta(S, longK, T, r, iv)
    (longD - shortD) * qty

mark1 = getSpreadValue(shortK1, longK1, t1, rInput, currentIV)
mark2 = getSpreadValue(shortK2, longK2, t2, rInput, currentIV)
mark3 = getSpreadValue(shortK3, longK3, t3, rInput, currentIV)
mark4 = getSpreadValue(shortK4, longK4, t4, rInput, currentIV)

delta1 = getNetDelta(close, shortK1, longK1, t1, rInput, currentIV, qty1)
delta2 = getNetDelta(close, shortK2, longK2, t2, rInput, currentIV, qty2)
delta3 = getNetDelta(close, shortK3, longK3, t3, rInput, currentIV, qty3)
delta4 = getNetDelta(close, shortK4, longK4, t4, rInput, currentIV, qty4)

livePnl1 = (premium1 - mark1) * qty1 * 100
livePnl2 = (premium2 - mark2) * qty2 * 100
livePnl3 = (premium3 - mark3) * qty3 * 100
livePnl4 = (premium4 - mark4) * qty4 * 100

getPnlColor(pnlVal) => pnlVal > 0 ? color.green : pnlVal < 0 ? color.red : color.white
be1 = shortK1 - premium1, be2 = shortK2 - premium2, be3 = shortK3 - premium3, be4 = shortK4 - premium4

// ==========================================
// DATE WINDOWS FOR PLOTS
// ==========================================
startTime1 = timestamp(stY1, stM1, stD1, 0, 0), endTime1 = timestamp(exY1, expM1, expD1, 23, 59), inWindow1 = time >= startTime1 and time <= endTime1
startTime2 = timestamp(stY2, stM2, stD2, 0, 0), endTime2 = timestamp(exY2, expM2, expD2, 23, 59), inWindow2 = time >= startTime2 and time <= endTime2
startTime3 = timestamp(stY3, stM3, stD3, 0, 0), endTime3 = timestamp(exY3, expM3, expD3, 23, 59), inWindow3 = time >= startTime3 and time <= endTime3
startTime4 = timestamp(stY4, stM4, stD4, 0, 0), endTime4 = timestamp(exY4, expM4, expD4, 23, 59), inWindow4 = time >= startTime4 and time <= endTime4

// ==========================================
// DYNAMIC PLOTTING ENGINE (BREAK-EVEN ONLY)
// ==========================================
plot(enableSp1 and inWindow1 ? be1 : na, title="SP1 Break-Even", color=color.orange, linewidth=2, style=plot.style_linebr, linestyle=plot.linestyle_dashed, display=display.all)
plot(enableSp2 and inWindow2 ? be2 : na, title="SP2 Break-Even", color=color.yellow, linewidth=2, style=plot.style_linebr, linestyle=plot.linestyle_dashed, display=display.all)
plot(enableSp3 and inWindow3 ? be3 : na, title="SP3 Break-Even", color=color.fuchsia, linewidth=2, style=plot.style_linebr, linestyle=plot.linestyle_dashed, display=display.all)
plot(enableSp4 and inWindow4 ? be4 : na, title="SP4 Break-Even", color=color.olive, linewidth=2, style=plot.style_linebr, linestyle=plot.linestyle_dashed, display=display.all)

// ==========================================
// DYNAMIC RIGHT-SIDE LINE LABELS
// ==========================================
var label lblBe1 = na
var label lblBe2 = na
var label lblBe3 = na
var label lblBe4 = na

if barstate.islast
    // Clear old label objects to prevent chart cluttering
    label.delete(lblBe1)
    label.delete(lblBe2)
    label.delete(lblBe3)
    label.delete(lblBe4)

    // Render Clean Active Break-Even Labels
    if enableSp1 and inWindow1
        lblBe1 := label.new(bar_index, be1, "SP1 Break-Even (" + str.tostring(be1) + ")", style=label.style_none, textcolor=color.orange, textalign=text.align_left)

    if enableSp2 and inWindow2
        lblBe2 := label.new(bar_index, be2, "SP2 Break-Even (" + str.tostring(be2) + ")", style=label.style_none, textcolor=color.yellow, textalign=text.align_left)

    if enableSp3 and inWindow3
        lblBe3 := label.new(bar_index, be3, "SP3 Break-Even (" + str.tostring(be3) + ")", style=label.style_none, textcolor=color.fuchsia, textalign=text.align_left)

    if enableSp4 and inWindow4
        lblBe4 := label.new(bar_index, be4, "SP4 Break-Even (" + str.tostring(be4) + ")", style=label.style_none, textcolor=color.olive, textalign=text.align_left)

// ==========================================
// METRICS & PARAMETERS METADATA DASHBOARD
// ==========================================
var table matrixDisplay = table.new(position.bottom_right, 7, 5, bgcolor=color.new(color.black, 20), border_color=color.gray, border_width=1)

if barstate.isfirst
    table.cell(matrixDisplay, 0, 0, "Spread",       text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(matrixDisplay, 1, 0, "Strikes (S/L)", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(matrixDisplay, 2, 0, "Current Mark",  text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(matrixDisplay, 3, 0, "Live Open P&L", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(matrixDisplay, 4, 0, "Position Delta",text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(matrixDisplay, 5, 0, "Current IV",    text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(matrixDisplay, 6, 0, "Days Left",     text_color=color.white, text_size=size.small, bgcolor=color.gray)

if barstate.islast
    // Position 1
    table.cell(matrixDisplay, 0, 1, "Position #1", text_color=enableSp1 ? color.green : color.gray, text_size=size.small)
    table.cell(matrixDisplay, 1, 1, enableSp1 ? str.tostring(shortK1) + " / " + str.tostring(longK1) : "-", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 2, 1, enableSp1 ? "$" + str.tostring(mark1, "#.00") : "-", text_color=color.orange, text_size=size.small)
    table.cell(matrixDisplay, 3, 1, enableSp1 ? "$" + str.tostring(livePnl1, "#.00") : "-", text_color=getPnlColor(livePnl1), text_size=size.small)
    table.cell(matrixDisplay, 4, 1, enableSp1 ? str.tostring(delta1, "#.00") : "-", text_color=color.blue, text_size=size.small)
    table.cell(matrixDisplay, 5, 1, enableSp1 ? str.tostring(currentIV * 100, "#.0") + "%" : "-", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 6, 1, enableSp1 ? str.tostring(math.round(t1 * 365)) : "-", text_color=color.white, text_size=size.small)

    // Position 2
    table.cell(matrixDisplay, 0, 2, "Position #2", text_color=enableSp2 ? color.teal : color.gray, text_size=size.small)
    table.cell(matrixDisplay, 1, 2, enableSp2 ? str.tostring(shortK2) + " / " + str.tostring(longK2) : "-", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 2, 2, enableSp2 ? "$" + str.tostring(mark2, "#.00") : "-", text_color=color.orange, text_size=size.small)
    table.cell(matrixDisplay, 3, 2, enableSp2 ? "$" + str.tostring(livePnl2, "#.00") : "-", text_color=getPnlColor(livePnl2), text_size=size.small)
    table.cell(matrixDisplay, 4, 2, enableSp2 ? str.tostring(delta2, "#.00") : "-", text_color=color.blue, text_size=size.small)
    table.cell(matrixDisplay, 5, 2, enableSp2 ? str.tostring(currentIV * 100, "#.0") + "%" : "-", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 6, 2, enableSp2 ? str.tostring(math.round(t2 * 365)) : "-", text_color=color.white, text_size=size.small)

    // Position 3
    table.cell(matrixDisplay, 0, 3, "Position #3", text_color=enableSp3 ? color.blue : color.gray, text_size=size.small)
    table.cell(matrixDisplay, 1, 3, enableSp3 ? str.tostring(shortK3) + " / " + str.tostring(longK3) : "-", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 2, 3, enableSp3 ? "$" + str.tostring(mark3, "#.00") : "-", text_color=color.orange, text_size=size.small)
    table.cell(matrixDisplay, 3, 3, enableSp3 ? "$" + str.tostring(livePnl3, "#.00") : "-", text_color=getPnlColor(livePnl3), text_size=size.small)
    table.cell(matrixDisplay, 4, 3, enableSp3 ? str.tostring(delta3, "#.00") : "-", text_color=color.blue, text_size=size.small)
    table.cell(matrixDisplay, 5, 3, enableSp3 ? str.tostring(currentIV * 100, "#.0") + "%" : "-", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 6, 3, enableSp3 ? str.tostring(math.round(t3 * 365)) : "-", text_color=color.white, text_size=size.small)

    // Position 4
    table.cell(matrixDisplay, 0, 4, "Position #4", text_color=enableSp4 ? color.lime : color.gray, text_size=size.small)
    table.cell(matrixDisplay, 1, 4, enableSp4 ? str.tostring(shortK4) + " / " + str.tostring(longK4) : "-", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 2, 4, enableSp4 ? "$" + str.tostring(mark4, "#.00") : "-", text_color=color.orange, text_size=size.small)
    table.cell(matrixDisplay, 3, 4, enableSp4 ? "$" + str.tostring(livePnl4, "#.00") : "-", text_color=getPnlColor(livePnl4), text_size=size.small)
    table.cell(matrixDisplay, 4, 4, enableSp4 ? str.tostring(delta4, "#.00") : "-", text_color=color.blue, text_size=size.small)
    table.cell(matrixDisplay, 5, 4, enableSp4 ? str.tostring(currentIV * 100, "#.0") + "%" : "-", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 6, 4, enableSp4 ? str.tostring(math.round(t4 * 365)) : "-", text_color=color.white, text_size=size.small)
````
