# Unemployment Shock (UNRATE FIXED)

- url: https://www.tradingview.com/script/yH1Jd9Xq/
- type: indicator
- pine_id: PUB;583cc69a3af44875bf56914b90ccf9d9
- version: 1.0

## Description

Unemployment RATE regime signal
In the bottom right corner is a symbol that indicates whether the unemployment rate is rising too quickly.

## Source Code

````pine
//@version=5
indicator("Unemployment Shock (UNRATE FIXED)", overlay=true)

// ─────────────────────────────
// DATA (WICHTIG: FRED PREFIX)
// ─────────────────────────────
unemp = request.security("FRED:UNRATE", "M", close)

// Falls Daten fehlen → absichern
unemp_valid = not na(unemp)

// ─────────────────────────────
// LOGIK
// ─────────────────────────────
change_1m = unemp_valid ? (unemp - unemp[1]) : 0
change_3m = unemp_valid ? (unemp - unemp[3]) : 0

ma = ta.sma(unemp, 12)

// Bedingungen
fast_rise = change_1m > 0.3
acceleration = change_3m > 0.8
trend_break = unemp > ma

warning = unemp_valid and ((fast_rise and trend_break) or acceleration)

// ─────────────────────────────
// VISUAL (unten rechts)
// ─────────────────────────────
var table t = table.new(position.bottom_right, 1, 1)

if barstate.islast
    table.cell(t, 0, 0, warning ? "⚠️ UNRATE SHOCK" : "UNRATE OK", text_color=color.white, bgcolor = warning ? color.new(color.red, 0) : color.new(color.green, 70))

// ─────────────────────────────
// ALERT
// ─────────────────────────────
alertcondition(warning, "Unemployment Shock", "UNRATE rising fast")
````
