# VIX Allocation Regime Pro - Risk ON / OFF

- url: https://www.tradingview.com/script/Zlj9jhOV/
- type: indicator
- pine_id: PUB;77b783ef817d4f328e63a7cd1f75dc79
- version: 1.0

## Description

smart portfolio allocation with vix arbitrage auto rebalance when fear and greed freeze

## Source Code

````pine
//@version=5
indicator("VIX Allocation Regime Pro - Risk ON / OFF", overlay=false)

// ===== PARAMÈTRES =====
vixSymbol = input.symbol("CBOE:VIX", "Indice VIX")
tf        = input.timeframe("D", "Timeframe VIX")

emaLen    = input.int(50, "EMA VIX")
riskOnLvl = input.float(18.5, "Seuil Risk ON")
riskOffLvl = input.float(22.0, "Seuil Risk OFF")
panicLvl  = input.float(30.0, "Seuil Panique")

// ===== DATA VIX =====
vix = request.security(vixSymbol, tf, close)
emaVix = request.security(vixSymbol, tf, ta.ema(close, emaLen))

// ===== RÉGIMES =====
riskOn = vix < riskOnLvl and vix < emaVix
riskOff = vix > riskOffLvl and vix > emaVix
panic = vix > panicLvl
neutral = not riskOn and not riskOff and not panic

// 1 = ON / 0 = NEUTRE / -1 = OFF / -2 = PANIC
regime = panic ? -2 : riskOff ? -1 : riskOn ? 1 : 0
regimeChanged = regime != regime[1]

// ===== COULEURS =====
regimeColor =
     regime == 1 ? color.new(color.green, 82) :
     regime == 0 ? color.new(color.yellow, 84) :
     regime == -1 ? color.new(color.red, 82) :
     color.new(color.purple, 78)

bgcolor(regimeColor)

// ===== PLOTS =====
plot(vix, "VIX", color=color.white, linewidth=2)
plot(emaVix, "EMA VIX", color=color.orange, linewidth=2)

hline(riskOnLvl, "Risk ON threshold", color=color.green)
hline(riskOffLvl, "Risk OFF threshold", color=color.red)
hline(panicLvl, "Panic threshold", color=color.purple)

// ===== SIGNAUX UNIQUEMENT AU CHANGEMENT =====
plotshape(regimeChanged and regime == 1,
     title="Passage Risk ON",
     style=shape.labelup,
     location=location.bottom,
     color=color.green,
     text="RISK ON",
     textcolor=color.white,
     size=size.small)

plotshape(regimeChanged and regime == -1,
     title="Passage Risk OFF",
     style=shape.labeldown,
     location=location.top,
     color=color.red,
     text="RISK OFF",
     textcolor=color.white,
     size=size.small)

plotshape(regimeChanged and regime == -2,
     title="Panique",
     style=shape.labeldown,
     location=location.top,
     color=color.purple,
     text="PANIC",
     textcolor=color.white,
     size=size.small)

// ===== DASHBOARD =====
var table dashboard = table.new(position.top_right, 2, 5, border_width=1)

regimeText =
     regime == 1 ? "RISK ON" :
     regime == 0 ? "NEUTRE" :
     regime == -1 ? "RISK OFF" :
     "PANIC"

allocationText =
     regime == 1 ? "70% SPY/QQQ | 20% SOXX | 10% Cash" :
     regime == 0 ? "40% SPY | 30% GLD | 20% TLT | 10% Cash" :
     regime == -1 ? "40% TLT | 30% GLD | 30% Cash" :
     "60% Cash | 25% TLT | 15% GLD"

if barstate.islast
    table.cell(dashboard, 0, 0, "VIX", text_color=color.white)
    table.cell(dashboard, 1, 0, str.tostring(vix, "#.##"), text_color=color.white)

    table.cell(dashboard, 0, 1, "EMA VIX", text_color=color.white)
    table.cell(dashboard, 1, 1, str.tostring(emaVix, "#.##"), text_color=color.orange)

    table.cell(dashboard, 0, 2, "Régime", text_color=color.white)
    table.cell(dashboard, 1, 2, regimeText, text_color=color.white, bgcolor=regimeColor)

    table.cell(dashboard, 0, 3, "Allocation", text_color=color.white)
    table.cell(dashboard, 1, 3, allocationText, text_color=color.white)

    table.cell(dashboard, 0, 4, "Action", text_color=color.white)
    table.cell(dashboard, 1, 4, regimeChanged ? "REBALANCE" : "HOLD", text_color=color.white)

// ===== ALERTES =====
alertcondition(regimeChanged and regime == 1, "Risk ON", "Passage en Risk ON")
alertcondition(regimeChanged and regime == -1, "Risk OFF", "Passage en Risk OFF")
alertcondition(regimeChanged and regime == -2, "PANIC", "Passage en régime PANIC")
````
