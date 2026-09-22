<!-- tradingview-pine-id: PUB;87fa06aa77d44083afdb786e103bd0a2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BreakScan FX

Source: https://www.tradingview.com/script/SCaO4O65/

## Description

# BreakScan FX — User Manual
Pine Script v6 · Overlay Indicator · 7-symbol range-break monitor

## 1. OVERVIEW
BreakScan FX is a flat, white-background monitoring panel that tracks 7 manually
configurable FX / gold symbols and tells you, at a glance, whether each one is
BREAKING, TESTING, or IDLE against its own recent high/low range.

Instead of flipping between 7 charts, you get one compact table in the top-right
corner of your chart that ranks symbols by urgency — the ones actually doing
something float to the top.

## 2. WHAT EACH ROW TELLS YOU
Columns: SYMBOL / GIMIC / MEANING

States:
  BREAK    Close above range high (up) or below range low (down)
  BREAK+   Same as BREAK, but occurred within last N bars (flash)
  TEST     Not breaking, but within proximity threshold of a boundary
  IDLE     Neither — mid-range

Row ordering: BREAK first, then TEST, then IDLE.
Header row sits above everything in crimson red.

## 3. SETTINGS REFERENCE

### Group 1 — Symbols (7)
Each slot: Symbol N (EXCHANGE:TICKER) + Display N (table label).
Defaults: EURUSD / GBPUSD / AUDUSD / NZDUSD / USDJPY / USDCHF / USDCAD (all OANDA:).
Display label is free text — cosmetic only, no effect on detection.

### Group 2 — Detection
  Detection Timeframe     default 60 (1H)
    Timeframe on which the range is measured. INDEPENDENT of chart timeframe.
  Range Lookback Bars     default 20
    Bars back the range high/low is calculated from.
  Test Proximity (%)      default 0.15
    How close to a boundary (in %) counts as TEST.

Range is built from the PREVIOUS N bars, EXCLUDING the current bar ([1] offset) —
prevents the current bar from defining its own breakout level.

Tuning:
  Tighter proximity (0.05–0.10) → fewer TEST rows. Quiet markets.
  Looser proximity (0.20–0.30)  → more TEST rows, earlier warning. Volatile sessions.
  Shorter lookback (10)         → minor swing breaks; more noise.
  Longer lookback (50–100)      → significant breaks only; higher quality.

### Group 3 — Display
  Text Size                            default small (tiny/small/normal/large)
  Show Parameter Values on Status Line default OFF
    NOT YET IMPLEMENTED — toggling has no effect. Leave off.

### Group 4 — Gimmick (all cosmetic)
  Enable Gimmick              default ON — master switch
  Pulse Period (bars)         default 6, range 2–20
  Blink Period (bars)         default 2, range 1–10
  Break Flash Duration (bars) default 3, range 1–20
    After this many bars, BREAK+ reverts to plain BREAK.
  For a completely static panel, turn Enable Gimmick OFF.

## 4. READING THE PANEL
1. Top row first — a fresh BREAK flash is your immediate candidate.
2. Count TEST rows. Multiple correlated TESTs (EURUSD + GBPUSD highs) = broad
   USD weakness, not a single-pair move.
3. Ignore IDLE rows unless hunting range-bound setups.
4. Direction glyph: up = testing/breaking the HIGH; down = the LOW.

Combinations:
  EURUSD up-TEST + GBPUSD up-TEST + USDCHF down-TEST → broad USD weakness
  USDJPY BREAK up alone                              → idiosyncratic JPY move
  All 7 IDLE                                         → dead session
  Multiple BREAK rows                                → momentum / trend day

## 5. DETECTION LOGIC (TECHNICAL)
  rangeHigh = highest(high, lookback)[1]   // excludes current bar
  rangeLow  = lowest(low,  lookback)[1]
  isBreakUp = close > rangeHigh
  isBreakDn = close < rangeLow
  isBreak   = isBreakUp or isBreakDn
  distHighPct = abs(close - rangeHigh) / rangeHigh * 100
  distLowPct  = abs(close - rangeLow)  / rangeLow  * 100
  isTest = not isBreak AND (distHighPct <= proximity OR distLowPct <= proximity)

State code: 2 = BREAK, 1 = TEST, 0 = IDLE.
gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off → no repaint, no leakage.

## 6. LIMITATIONS
- 7 symbols maximum (hard-coded).
- Single detection timeframe shared by all 7 slots.
- Table is top-right and overlays price. Move via source if it obscures candles.
- Rounded corners NOT possible in Pine (table has no border radius).
- Status line not yet implemented.
- Short title now "BreakScan" (9 chars) — 0 compile warnings.

## 7. QUICK-START
1. Add BreakScan FX to any chart (panel is symbol-independent).
2. Settings → 1. Symbols (7): set instruments + labels.
3. Settings → 2. Detection: timeframe, lookback, proximity.
4. Gimmick ON for pulse, OFF for static.
5. Read the top row first.

---
Educational tool for range-break monitoring. Flags where price sits relative to a
recent range — does not generate buy/sell signals or place orders.
Verify all levels independently before acting.

---

## Source Code

````pine
//@version=6
indicator("BreakScan FX", shorttitle="BreakScan", overlay=true)

//#region Concept
// Flat, white-background monitoring panel for 7 manually configurable FX/gold symbols.
// Each row shows whether price is BREAKING, TESTING, or IDLE against a recent high/low range.
//#endregion

//#region Inputs
sym1 = input.symbol("OANDA:EURUSD", "Symbol 1", group="1. Symbols (7)")
name1 = input.string("EURUSD", "Display 1", group="1. Symbols (7)")
sym2 = input.symbol("OANDA:GBPUSD", "Symbol 2", group="1. Symbols (7)")
name2 = input.string("GBPUSD", "Display 2", group="1. Symbols (7)")
sym3 = input.symbol("OANDA:AUDUSD", "Symbol 3", group="1. Symbols (7)")
name3 = input.string("AUDUSD", "Display 3", group="1. Symbols (7)")
sym4 = input.symbol("OANDA:NZDUSD", "Symbol 4", group="1. Symbols (7)")
name4 = input.string("NZDUSD", "Display 4", group="1. Symbols (7)")
sym5 = input.symbol("OANDA:USDJPY", "Symbol 5", group="1. Symbols (7)")
name5 = input.string("USDJPY", "Display 5", group="1. Symbols (7)")
sym6 = input.symbol("OANDA:USDCHF", "Symbol 6", group="1. Symbols (7)")
name6 = input.string("USDCHF", "Display 6", group="1. Symbols (7)")
sym7 = input.symbol("OANDA:USDCAD", "Symbol 7", group="1. Symbols (7)")
name7 = input.string("USDCAD", "Display 7", group="1. Symbols (7)")

detectionTF = input.timeframe("60", "Detection Timeframe", group="2. Detection")
brkLen = input.int(20, "Range Lookback Bars", group="2. Detection", minval=1)
proximityPct = input.float(0.15, "Test Proximity (%)", group="2. Detection", step=0.05, minval=0.0)
textSizeInput = input.string("small", "Text Size", options=["tiny", "small", "normal", "large"], group="3. Display")
showStatusParams = input.bool(false, "Show Parameter Values on Status Line", group="3. Display")

gimicOn = input.bool(true, "Enable Gimmick", group="4. Gimmick")
pulsePeriod = input.int(6, "Pulse Period (bars)", group="4. Gimmick", minval=2, maxval=20)
blinkPeriod = input.int(2, "Blink Period (bars)", group="4. Gimmick", minval=1, maxval=10)
breakFlashBars = input.int(3, "Break Flash Duration (bars)", group="4. Gimmick", minval=1, maxval=20)

textSize = textSizeInput == "tiny" ? size.tiny : textSizeInput == "small" ? size.small : textSizeInput == "normal" ? size.normal : size.large
pulseOn = bar_index % pulsePeriod < math.max(1, math.round(pulsePeriod / 2))
blinkOn = bar_index % blinkPeriod == 0
//#endregion

//#region Functions
//@function Returns break/test/idle state for the current symbol on the detection timeframe.
//@param _len Lookback bars for range high/low.
//@param _prox Proximity threshold in percent.
//@returns A tuple containing stateCode, levelPrice, and isUpper.
f_state(_len, _prox) =>
    rangeHigh = ta.highest(high, _len)[1]
    rangeLow = ta.lowest(low, _len)[1]
    isBreakUp = not na(rangeHigh) and close > rangeHigh
    isBreakDn = not na(rangeLow) and close < rangeLow
    isBreak = isBreakUp or isBreakDn
    distHighPct = (not na(rangeHigh) and rangeHigh != 0.0) ? math.abs(close - rangeHigh) / rangeHigh * 100.0 : na
    distLowPct = (not na(rangeLow) and rangeLow != 0.0) ? math.abs(close - rangeLow) / rangeLow * 100.0 : na
    isTest = not isBreak and ((not na(distHighPct) and distHighPct <= _prox) or (not na(distLowPct) and distLowPct <= _prox))
    stateCode = isBreak ? 2 : isTest ? 1 : 0
    levelPrice = isBreakUp or (isTest and not na(distHighPct) and (na(distLowPct) or distHighPct <= distLowPct)) ? rangeHigh : rangeLow
    isUpper = isBreakUp or (isTest and not na(distHighPct) and (na(distLowPct) or distHighPct <= distLowPct))
    [stateCode, levelPrice, isUpper]

//@function Returns display row data for a symbol.
//@param symbolName Display symbol name.
//@param stateCode State code.
//@param isUpper Whether the active level is upper.
//@param breakAge Bars since break occurred.
//@returns A tuple containing priority, symbol text, gimmick text, and meaning text.
f_rowData(symbolName, stateCode, isUpper, breakAge) =>
    priority = stateCode == 2 ? 0 : stateCode == 1 ? 1 : 2
    gimmicText = stateCode == 2 ? (isUpper ? "▲" : "▼") : stateCode == 1 ? "◆" : "─"
    meaningText = stateCode == 2 ? (breakAge < breakFlashBars ? "BREAK⚡" : "BREAK") : stateCode == 1 ? "TEST" : "-"
    [priority, symbolName, gimmicText, meaningText]
//#endregion

//#region Table
var table panel = table.new(position.top_right, 3, 8)
//#endregion

//#region Data
[state1, level1, upper1] = request.security(sym1, detectionTF, f_state(brkLen, proximityPct), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[state2, level2, upper2] = request.security(sym2, detectionTF, f_state(brkLen, proximityPct), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[state3, level3, upper3] = request.security(sym3, detectionTF, f_state(brkLen, proximityPct), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[state4, level4, upper4] = request.security(sym4, detectionTF, f_state(brkLen, proximityPct), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[state5, level5, upper5] = request.security(sym5, detectionTF, f_state(brkLen, proximityPct), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[state6, level6, upper6] = request.security(sym6, detectionTF, f_state(brkLen, proximityPct), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[state7, level7, upper7] = request.security(sym7, detectionTF, f_state(brkLen, proximityPct), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

breakAge1 = ta.barssince(state1 == 2)
breakAge2 = ta.barssince(state2 == 2)
breakAge3 = ta.barssince(state3 == 2)
breakAge4 = ta.barssince(state4 == 2)
breakAge5 = ta.barssince(state5 == 2)
breakAge6 = ta.barssince(state6 == 2)
breakAge7 = ta.barssince(state7 == 2)

[prio1, symText1, gimicText1, meaningText1] = f_rowData(name1, state1, upper1, breakAge1)
[prio2, symText2, gimicText2, meaningText2] = f_rowData(name2, state2, upper2, breakAge2)
[prio3, symText3, gimicText3, meaningText3] = f_rowData(name3, state3, upper3, breakAge3)
[prio4, symText4, gimicText4, meaningText4] = f_rowData(name4, state4, upper4, breakAge4)
[prio5, symText5, gimicText5, meaningText5] = f_rowData(name5, state5, upper5, breakAge5)
[prio6, symText6, gimicText6, meaningText6] = f_rowData(name6, state6, upper6, breakAge6)
[prio7, symText7, gimicText7, meaningText7] = f_rowData(name7, state7, upper7, breakAge7)
//#endregion

//#region Render
if barstate.islast

    panel.cell(0, 0, "SYMBOL", bgcolor=#DC143C, text_color=color.white, text_size=size.normal)
    panel.cell(1, 0, "GIMIC", bgcolor=#DC143C, text_color=color.white, text_size=size.normal)
    panel.cell(2, 0, "MEANING", bgcolor=#DC143C, text_color=color.white, text_size=size.normal)

    int rowIndex = 1
    for priority = 0 to 2
        if prio1 == priority
            panel.cell(0, rowIndex, symText1, bgcolor=color.white, text_color=color.black, text_size=textSize)
            panel.cell(1, rowIndex, gimicText1, bgcolor=color.white, text_color=#00008B, text_size=textSize)
            panel.cell(2, rowIndex, meaningText1, bgcolor=color.white, text_color=color.black, text_size=textSize)
            rowIndex := rowIndex + 1
        if prio2 == priority
            panel.cell(0, rowIndex, symText2, bgcolor=color.white, text_color=color.black, text_size=textSize)
            panel.cell(1, rowIndex, gimicText2, bgcolor=color.white, text_color=#00008B, text_size=textSize)
            panel.cell(2, rowIndex, meaningText2, bgcolor=color.white, text_color=color.black, text_size=textSize)
            rowIndex := rowIndex + 1
        if prio3 == priority
            panel.cell(0, rowIndex, symText3, bgcolor=color.white, text_color=color.black, text_size=textSize)
            panel.cell(1, rowIndex, gimicText3, bgcolor=color.white, text_color=#00008B, text_size=textSize)
            panel.cell(2, rowIndex, meaningText3, bgcolor=color.white, text_color=color.black, text_size=textSize)
            rowIndex := rowIndex + 1
        if prio4 == priority
            panel.cell(0, rowIndex, symText4, bgcolor=color.white, text_color=color.black, text_size=textSize)
            panel.cell(1, rowIndex, gimicText4, bgcolor=color.white, text_color=#00008B, text_size=textSize)
            panel.cell(2, rowIndex, meaningText4, bgcolor=color.white, text_color=color.black, text_size=textSize)
            rowIndex := rowIndex + 1
        if prio5 == priority
            panel.cell(0, rowIndex, symText5, bgcolor=color.white, text_color=color.black, text_size=textSize)
            panel.cell(1, rowIndex, gimicText5, bgcolor=color.white, text_color=#00008B, text_size=textSize)
            panel.cell(2, rowIndex, meaningText5, bgcolor=color.white, text_color=color.black, text_size=textSize)
            rowIndex := rowIndex + 1
        if prio6 == priority
            panel.cell(0, rowIndex, symText6, bgcolor=color.white, text_color=color.black, text_size=textSize)
            panel.cell(1, rowIndex, gimicText6, bgcolor=color.white, text_color=#00008B, text_size=textSize)
            panel.cell(2, rowIndex, meaningText6, bgcolor=color.white, text_size=textSize)
            rowIndex := rowIndex + 1
        if prio7 == priority
            panel.cell(0, rowIndex, symText7, bgcolor=color.white, text_color=color.black, text_size=textSize)
            panel.cell(1, rowIndex, gimicText7, bgcolor=color.white, text_color=#00008B, text_size=textSize)
            panel.cell(2, rowIndex, meaningText7, bgcolor=color.white, text_color=color.black, text_size=textSize)
            rowIndex := rowIndex + 1
//#endregion
````
