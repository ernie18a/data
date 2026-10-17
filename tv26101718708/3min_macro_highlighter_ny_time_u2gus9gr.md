# 3min Macro Highlighter (NY Time)

- url: https://www.tradingview.com/script/U2GuS9Gr-3min-Macro-Highlighter-NY-Time/
- type: indicator
- pine_id: PUB;8a32760d8a3f48ada66bb3c93f5ac6c7
- version: 1.0

## Description

saucey j3w. only profitable way is this j3wosh method

## Source Code

````pine
//@version=6
indicator("3min Macro Highlighter (NY Time)", overlay=true)

// --- Function to convert time to NY hour/minute ---
nyH = hour(time, "America/New_York")
nyM = minute(time, "America/New_York")
currentCode = nyH * 100 + nyM

// --- Define base macro times as hours and target minutes ---
baseMacros = array.from(
    // 09xx
    902, 908, 920, 926, 932, 938, 944, 950,
    // 10xx
    1001, 1007, 1013, 1019, 1031, 1037, 1043, 1049,
    // 14xx
    1433, 1439, 1445, 1457,
    // 15xx
    1502, 1514, 1526, 1532, 1538, 1544, 1556
)

// Create array of all expanded codes (minute‑1, minute, minute+1)
macroRange = array.new_int()

for i = 0 to array.size(baseMacros) - 1
    base = array.get(baseMacros, i)
    h = math.floor(base / 100)
    m = base % 100

    // define the three minutes (before, target, after)
    before = h * 100 + (m - 1)
    center = h * 100 + m
    after  = h * 100 + (m + 1)
    
    // add only valid values
    if before >= 0
        array.push(macroRange, before)
    array.push(macroRange, center)
    array.push(macroRange, after)

// --- Check if current minute is in macroRange ---
isMacro = array.includes(macroRange, currentCode)

// --- Highlight Background ---
bgcolor(isMacro ? color.new(color.purple, 85) : na)
````
