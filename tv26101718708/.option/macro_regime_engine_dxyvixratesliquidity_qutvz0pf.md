# Macro Regime Engine (DXY/VIX/Rates/Liquidity)

- url: https://www.tradingview.com/script/QUTVZ0pF/
- type: indicator
- pine_id: PUB;2e597651752c4a789fc4f3dede417477
- version: 1.0

## Description

Analyzes M2, vix, dxy, US10y, CPI to automate a fundamental regime analysis.

## Source Code

````pine
//@version=5
indicator("Macro Regime Engine (DXY/VIX/Rates/Liquidity) – Fixed", overlay=true, max_labels_count=500)

// ─────────────────────────────
// DATA INPUTS (korrekte Symbole)
// ─────────────────────────────
dxy   = request.security("TVC:DXY",   timeframe.period, close, ignore_invalid_symbol=true)
vix   = request.security("TVC:VIX",   timeframe.period, close, ignore_invalid_symbol=true)
us10y = request.security("TVC:US10Y", timeframe.period, close, ignore_invalid_symbol=true)
m2    = request.security("ECONOMICS:USM2", timeframe.period, close, ignore_invalid_symbol=true)
cpi   = request.security("ECONOMICS:USCPI", timeframe.period, close, ignore_invalid_symbol=true)

// ─────────────────────────────
// BASELINES (50 SMA)
// ─────────────────────────────
len = 50

dxy_ma   = ta.sma(dxy, len)
vix_ma   = ta.sma(vix, len)
us10y_ma = ta.sma(us10y, len)
m2_ma    = ta.sma(m2, len)
cpi_ma   = ta.sma(cpi, len)

// NaN-Behandlung für monatliche Daten
dxy_ma   := na(dxy_ma)   ? dxy   : dxy_ma
vix_ma   := na(vix_ma)   ? vix   : vix_ma
us10y_ma := na(us10y_ma) ? us10y : us10y_ma
m2_ma    := na(m2_ma)    ? m2    : m2_ma
cpi_ma   := na(cpi_ma)   ? cpi   : cpi_ma

// ─────────────────────────────
// SCORE SYSTEM
// ─────────────────────────────
var float score = 0.0
score := 0.0

score += vix > vix_ma ? 1.0 : 0.0
score += dxy > dxy_ma ? 1.0 : 0.0
score += us10y > us10y_ma ? 1.0 : 0.0
score += m2 < m2_ma ? 1.0 : 0.0
score += cpi > cpi_ma ? 0.5 : 0.0

score := math.max(score, 0.0)

// ─────────────────────────────
// REGIME CLASSIFICATION (einzeilig, um Einrückungsfehler zu vermeiden)
// ─────────────────────────────
regime = score <= 1.0 ? "🟢 RISK ON (Liquidity Market)" : score <= 3.0 ? "🟡 TRANSITION (Choppy / Mixed)" : "🔴 RISK OFF (Tight Conditions)"

// Strategy Suggestion
strategySuggestion = score <= 1.0 ? "Trend / Calendars / Long Risk" : score <= 3.0 ? "Reduced Size / Selective Trades" : "Long Vol / Breakouts / Defensive"

// ─────────────────────────────
// TABLE
// ─────────────────────────────
var table t = table.new(position.middle_right, 1, 3, border_width=1, frame_color=color.gray)

if barstate.islast
    table.cell(t, 0, 0, "MACRO REGIME", text_color=color.white, bgcolor=color.black, text_size=size.normal)
    
    table.cell(t, 0, 1, regime,
         text_color=color.white,
         bgcolor = score <= 1.0 ? color.new(color.green, 60) : 
                   score <= 3.0 ? color.new(color.orange, 60) : 
                                  color.new(color.red, 60),
         text_size=size.normal)

    table.cell(t, 0, 2, "Strategy: " + strategySuggestion,
         text_color=color.white,
         bgcolor=color.new(color.gray, 80),
         text_size=size.small)

// Optional: Score anzeigen
plotchar(score, title="Macro Score", char="", location=location.top, color=color.yellow, size=size.small)
````
