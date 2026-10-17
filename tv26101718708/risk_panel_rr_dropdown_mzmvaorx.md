# Risk Panel (RR Dropdown)

- url: https://www.tradingview.com/script/MzMvaORX-Risk-Panel-RR-Dropdown/
- type: indicator
- pine_id: PUB;60103e9669a34446b184874228973ad9
- version: 1.0

## Description

**Risk Panel PRO — Trade Smarter, Not Harder**

Turn your TradingView chart into a complete decision-making dashboard.

This tool combines a precision risk calculator with a structured trading checklist, helping you stay disciplined, consistent, and in control — no matter your experience level.

🔹 **Instant Risk Clarity**
Know exactly how much you’re risking on every trade with real-time percentage calculations.

🔹 **Structured Rule-Based Trading**
Follow a clear checklist including session, bias, timeframe alignment, liquidity, stop placement, and risk-to-reward.

🔹 **Traffic Light Feedback System**
Simple green/red signals let you instantly see if your setup meets your rules — no overthinking.

🔹 **Custom Risk-to-Reward Control**
Quickly select between 1:1, 1:2, and 1:3 setups to maintain high-quality trades.

🔹 **Built for All Traders**
Whether you’re just starting out or refining a professional system, this panel keeps your process clean and consistent.

---

**Trade with confidence.
Eliminate guesswork.
Stick to your edge.**

## Source Code

````pine
//@version=5
indicator("Risk Panel (RR Dropdown)", overlay=true)

// === INPUTS ===
account = input.float(1000, "Account Size ($)")
stop    = input.float(100, "Stop Distance")
size    = input.float(0.1, "Position Size")

// === DROPDOWNS ===
session = input.string("London", "Session", options=["London", "New York"])
bias    = input.string("Bullish", "Bias", options=["Bullish", "Bearish", "Consolidating"])

tf  = input.string("No", "TF Alignment", options=["Yes", "No"])
liq = input.string("No", "Liquidity Sweep", options=["Yes", "No"])
sl  = input.string("No", "SL Placement", options=["Yes", "No"])
rr  = input.string("1:1", "R:R", options=["1:1", "1:2", "1:3"])

// === COLORS ===
bg1    = input.color(color.rgb(15,15,15), "Background 1")
bg2    = input.color(color.rgb(25,25,25), "Background 2")
txt    = input.color(color.white, "Text Color")
accent = input.color(color.rgb(0,200,255), "Accent Color")

green = color.rgb(0, 200, 0)
red   = color.rgb(255, 60, 60)

// === SYMBOL ===
symbol = syminfo.ticker

isForex = syminfo.type == "forex"
isMetal = str.contains(symbol, "XAU") or str.contains(symbol, "XAG")

// === VALUE ===
tickSize = syminfo.mintick
pointVal = syminfo.pointvalue

pipSize = (isForex and not isMetal) ? (str.contains(symbol, "JPY") ? 0.01 : 0.0001) : tickSize
pipValue = (isForex and not isMetal) ? (pipSize / close) * 100000 : pointVal
valuePerUnit = (isForex and not isMetal) ? pipValue : pointVal

// === RISK ===
loss = stop * size * valuePerUnit
riskPercent = (loss / account) * 100
riskColor = riskPercent <= 1 ? green : red

// === RULE LOGIC ===
tfOK  = tf  == "Yes"
liqOK = liq == "Yes"
slOK  = sl  == "Yes"

// R:R LOGIC (NEW)
rrOK = rr == "1:2" or rr == "1:3"

// Bias rule
biasOK = bias != "Consolidating"

// === COLORS (TEXT) ===
biasColor = biasOK ? green : red
tfColor   = tfOK ? green : red
liqColor  = liqOK ? green : red
slColor   = slOK ? green : red
rrColor   = rrOK ? green : red

// === ENTRY ===
allRulesOK = biasOK and tfOK and liqOK and slOK and rrOK
entryText = allRulesOK ? "TAKE TRADE" : "NO TRADE"
entryColor = allRulesOK ? green : red

// === TABLE ===
var table t = table.new(position.top_right, 2, 14)

if barstate.islast

    // ===== RISK =====
    table.cell(t, 0, 0, "RISK", text_color=accent, bgcolor=bg1)
    table.cell(t, 1, 0, "", bgcolor=bg1)

    table.cell(t, 0, 1, "Loss %", text_color=txt, bgcolor=bg1)
    table.cell(t, 1, 1, str.tostring(riskPercent, "#.##") + "%", text_color=riskColor, bgcolor=bg2)

    table.cell(t, 0, 2, "Size", text_color=txt, bgcolor=bg1)
    table.cell(t, 1, 2, str.tostring(size, "#.###"), text_color=accent, bgcolor=bg2)

    table.cell(t, 0, 3, "Symbol", text_color=txt, bgcolor=bg1)
    table.cell(t, 1, 3, symbol, text_color=accent, bgcolor=bg2)

    // ===== RULES =====
    table.cell(t, 0, 5, "RULES", text_color=accent, bgcolor=bg1)
    table.cell(t, 1, 5, "", bgcolor=bg1)

    table.cell(t, 0, 6, "Session", text_color=txt, bgcolor=bg1)
    table.cell(t, 1, 6, session, text_color=accent, bgcolor=bg2)

    table.cell(t, 0, 7, "Bias", text_color=txt, bgcolor=bg1)
    table.cell(t, 1, 7, bias, text_color=biasColor, bgcolor=bg2)

    table.cell(t, 0, 8, "TF Align", text_color=txt, bgcolor=bg1)
    table.cell(t, 1, 8, tf, text_color=tfColor, bgcolor=bg2)

    table.cell(t, 0, 9, "Liquidity", text_color=txt, bgcolor=bg1)
    table.cell(t, 1, 9, liq, text_color=liqColor, bgcolor=bg2)

    table.cell(t, 0, 10, "SL", text_color=txt, bgcolor=bg1)
    table.cell(t, 1, 10, sl, text_color=slColor, bgcolor=bg2)

    table.cell(t, 0, 11, "R:R", text_color=txt, bgcolor=bg1)
    table.cell(t, 1, 11, rr, text_color=rrColor, bgcolor=bg2)

    // ===== ENTRY =====
    table.cell(t, 0, 13, "ENTRY", text_color=accent, bgcolor=bg1)
    table.cell(t, 1, 13, entryText, text_color=entryColor, bgcolor=bg2)
````
