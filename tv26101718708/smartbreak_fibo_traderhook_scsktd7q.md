# SmartBreak Fibo [TraderHook]

- url: https://www.tradingview.com/script/scSKTD7q-SmartBreak-Fibo-TraderHook/
- type: indicator
- pine_id: PUB;36a851b46ff44b3ea42118ff52f669cc
- version: 1.0

## Description

[b]SmartBreak Fibo [TraderHook][/b]

Stop drawing your setups by hand. SmartBreak watches market structure in real time, and the moment price breaks a structural swing — a [b]BOS[/b] (Break of Structure) or [b]CHoCH[/b] (Change of Character) — it instantly maps a full Fibonacci trade plan on your chart: entry, stop, and three targets. No manual fib dragging, no guesswork on where to place levels.

[b]How it works[/b]
[list=1]
[*]The engine tracks swing highs/lows and detects every structural break (BOS / CHoCH).
[*]On each break, a Fibonacci is anchored from the broken swing (level 1) to the opposing swing (level 0).
[*]Entry is plotted at the [b]0.618[/b] retracement, Stop-Loss at level [b]0[/b] (the swing extreme).
[*]Three take-profits sit at fib extensions [b]2.0 / 2.618 / 3.618[/b].
[*]A green box shows the profit zone (entry → TP3), a red box shows the risk zone (entry → SL).
[/list]

[b]Why traders like it[/b]
[list]
[*]Setups appear the instant structure breaks — you decide whether to take them, the levels are already there.
[*]Long breaks are marked green, short breaks red — direction is readable at a glance.
[*]Fully adjustable: entry level, all three TPs, pivot sensitivity, colors, and how many recent setups stay on screen.
[*]"ChoCh only" mode if you prefer to trade reversals over trend continuations.
[/list]

[b]Settings[/b]
[list]
[*][b]Pivot Period[/b] — structure sensitivity (higher = bigger swings only).
[*][b]Entry / TP1 / TP2 / TP3[/b] — every fib level is yours to tune.
[*][b]Number of recent setups[/b] — keep the chart clean with just the latest, or show history.
[*][b]Long / Short setups[/b] — toggle either side on or off.
[/list]

[b]Credits[/b]
The market-structure engine (ZigZag, swing classification, BOS/CHoCH) is based on the open-source work of [b]TFlab[/b], used under the Mozilla Public License 2.0. The Fibonacci trade-box system is by TraderHook. Published open-source — feel free to study and build on it.

[b]Disclaimer[/b]
This is a visualization tool, not financial advice or a signal service. The take-profit levels are mechanical Fibonacci extensions — they do not predict that price will reach any target. Always backtest and manage your own risk before trading.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Market structure engine (ZigZag, swing classification, BoS/CHoCH)
// based on TFlab's open-source script, used under MPL 2.0.
// Fibonacci trade-box system © TraderHook.
//
// BOS/CHoCH Fibo Boxes
// ---------------------
// On every Break of Structure / Change of Character, this indicator draws a
// Fibonacci-based trade setup:
//   - Fib is anchored from the broken swing (level 1) to the opposing swing (level 0).
//   - Entry at the 0.618 retracement, Stop-Loss at level 0 (the swing extreme).
//   - Three take-profits at fib extensions 2.0 / 2.618 / 3.618.
//   - Green box = profit zone (entry -> TP3), red box = risk zone (entry -> SL).
//
// NOTE: This is a visualization tool, not financial advice. Levels are mechanical fib
// extensions and do not guarantee price will reach any target. Backtest before use.

//@version=5
indicator("SmartBreak Fibo [TraderHook]", 'SmartBreak [TH]', overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────────────────────────────────────
//  INPUTS — Structure
// ─────────────────────────────────────────────────────────────
PP = input.int(5, 'Pivot Period of Order Blocks Detector', group = 'Logic Parameter', minval = 1)
ShZ = input.bool(false, 'Show Zig Zag Line', group = 'Zig Zag Line')
showLabels   = input.bool(true,  'Show Labels (break line: BoS/ChoCh)', group = 'Structure View')
showPosType  = input.bool(false, 'Show Position Type (box header: type + side)', group = 'Structure View')

// ─────────────────────────────────────────────────────────────
//  INPUTS — Fibo setup (added layer)
// ─────────────────────────────────────────────────────────────
grpF     = 'Fibo Setup'
entryLvl = input.float(0.618, 'Entry level', step = 0.001, group = grpF)
tp1Lvl   = input.float(2.0,   'TP1', step = 0.001, group = grpF)
tp2Lvl   = input.float(2.618, 'TP2', step = 0.001, group = grpF)
tp3Lvl   = input.float(3.618, 'TP3', step = 0.001, group = grpF)

grpV      = 'Box Display'
maxBoxes  = input.int(1, 'Number of recent setups to show', minval = 1, maxval = 100, group = grpV)
boxLen    = input.int(60, 'Box length (bars to the right)', minval = 5, group = grpV)
useLong   = input.bool(true,  'Long setups (bullish break)', group = grpV)
useShort  = input.bool(true,  'Short setups (bearish break)', group = grpV)
colGreen  = input.color(color.new(color.green, 80), 'Profit zone', group = grpV)
colRed    = input.color(color.new(color.red, 80),   'Risk zone',   group = grpV)
colLongBreak  = input.color(color.rgb(76, 175, 80, 50),  'Long break line (green)', group = grpV)
colShortBreak = input.color(color.rgb(255,0,0, 50), 'Short break line (red)', group = grpV)
showLines = input.bool(true, 'TP/SL/Entry lines', group = grpV)
onlyChoCh = input.bool(false, 'ChoCh only (no BoS)', group = grpV)

// ─────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────
var zzType    = array.new_string()
var zzVal   = array.new_float()
var zzIdx   = array.new_int()
var zzTypeM  = array.new_string()
var zzValM = array.new_float()
var zzIdxM = array.new_int()
var line zzLine = na
var label Label = na

pvHi = ta.pivothigh(PP, PP)
pvLo  = ta.pivotlow(PP, PP)
pvHiVal = ta.valuewhen(pvHi, high[PP], 0)
pvLoVal  = ta.valuewhen(pvLo,  low[PP],  0)
pvHiX = ta.valuewhen(pvHi, bar_index[PP], 0)
pvLoX  = ta.valuewhen(pvLo,  bar_index[PP], 0)

var float hkSwingHi = na
var float hkSwingLo  = na
var int   hkSwingHiX = na
var int   hkSwingLoX  = na
var string hkSwingHiT = na
var string hkSwingLoT  = na

var bool seedLock0 = true
var bool seedLock1 = true

var string hkTrend = 'No Trend'

var int hkBreakLock = 0

// ─────────────────────────────────────────────────────────────
//  SWING / ZIGZAG BUILDER
// ─────────────────────────────────────────────────────────────
if pvHi and pvLo
    if zzType.size() == 0
        na
    else if zzType.size() >= 1
        if ((zzType.get(zzType.size() - 1)) == 'L' or (zzType.get(zzType.size() - 1)) == 'LL')
            if pvLo < zzVal.get(zzType.size() - 1)
                array.remove(zzType, zzType.size() - 1)
                array.remove(zzVal, zzVal.size() - 1)
                array.remove(zzIdx, zzIdx.size() - 1)
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvLoVal ? 'HL' : 'LL' : 'L')
                array.push(zzVal, pvLoVal)
                array.push(zzIdx, pvLoX)
            else
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvHiVal ? 'HH' : 'LH' : 'H')
                array.push(zzVal, pvHiVal)
                array.push(zzIdx, pvHiX)
        else if (zzType.get(zzType.size() - 1)) == 'H' or (zzType.get(zzType.size() - 1)) == 'HH'
            if pvHi > zzVal.get(zzType.size() - 1)
                array.remove(zzType, zzType.size() - 1)
                array.remove(zzVal, zzVal.size() - 1)
                array.remove(zzIdx, zzIdx.size() - 1)
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvHiVal ? 'HH' : 'LH' : 'H')
                array.push(zzVal, pvHiVal)
                array.push(zzIdx, pvHiX)
            else
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvLoVal ? 'HL' : 'LL' : 'L')
                array.push(zzVal, pvLoVal)
                array.push(zzIdx, pvLoX)
        else if (zzType.get(zzType.size() - 1)) == 'LH'
            if pvHi < zzVal.get(zzType.size() - 1)
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvLoVal ? 'HL' : 'LL' : 'L')
                array.push(zzVal, pvLoVal)
                array.push(zzIdx, pvLoX)
            else if pvHi > zzVal.get(zzType.size() - 1)
                if close < zzVal.get(zzType.size() - 1)
                    array.remove(zzType, zzType.size() - 1)
                    array.remove(zzVal, zzVal.size() - 1)
                    array.remove(zzIdx, zzIdx.size() - 1)
                    array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvHiVal ? 'HH' : 'LH' : 'H')
                    array.push(zzVal, pvHiVal)
                    array.push(zzIdx, pvHiX)
                else if close > zzVal.get(zzType.size() - 1)
                    array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvLoVal ? 'HL' : 'LL' : 'L')
                    array.push(zzVal, pvLoVal)
                    array.push(zzIdx, pvLoX)
        else if (zzType.get(zzType.size() - 1)) == 'HL'
            if pvLo > zzVal.get(zzType.size() - 1)
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvHiVal ? 'HH' : 'LH' : 'H')
                array.push(zzVal, pvHiVal)
                array.push(zzIdx, pvHiX)
            else if pvLo < zzVal.get(zzType.size() - 1)
                if close > zzVal.get(zzType.size() - 1)
                    array.remove(zzType, zzType.size() - 1)
                    array.remove(zzVal, zzVal.size() - 1)
                    array.remove(zzIdx, zzIdx.size() - 1)
                    array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvLoVal ? 'HL' : 'LL' : 'L')
                    array.push(zzVal, pvLoVal)
                    array.push(zzIdx, pvLoX)
                else if close < zzVal.get(zzType.size() - 1)
                    array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvHiVal ? 'HH' : 'LH' : 'H')
                    array.push(zzVal, pvHiVal)
                    array.push(zzIdx, pvHiX)
else if pvHi
    if zzType.size() == 0
        array.insert(zzType, 0, 'H')
        array.insert(zzVal, 0, pvHiVal)
        array.insert(zzIdx, 0, pvHiX)
    else if zzType.size() >= 1
        if ((zzType.get(zzType.size() - 1)) == 'L' or (zzType.get(zzType.size() - 1)) == 'HL' or (zzType.get(zzType.size() - 1)) == 'LL')
            if pvHi > zzVal.get(zzType.size() - 1)
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvHiVal ? 'HH' : 'LH' : 'H')
                array.push(zzVal, pvHiVal)
                array.push(zzIdx, pvHiX)
            else if pvHi < zzVal.get(zzType.size() - 1)
                array.remove(zzType, zzType.size() - 1)
                array.remove(zzVal, zzVal.size() - 1)
                array.remove(zzIdx, zzIdx.size() - 1)
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvLoVal ? 'HL' : 'LL' : 'L')
                array.push(zzVal, pvLoVal)
                array.push(zzIdx, pvLoX)
        else if (zzType.get(zzType.size() - 1)) == 'H' or (zzType.get(zzType.size() - 1)) == 'HH' or (zzType.get(zzType.size() - 1)) == 'LH'
            if (zzVal.get(zzVal.size() - 1)) < pvHiVal
                array.remove(zzType, zzType.size() - 1)
                array.remove(zzVal, zzVal.size() - 1)
                array.remove(zzIdx, zzIdx.size() - 1)
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvHiVal ? 'HH' : 'LH' : 'H')
                array.push(zzVal, pvHiVal)
                array.push(zzIdx, pvHiX)
else if pvLo
    if zzType.size() == 0
        array.insert(zzType, 0, 'L')
        array.insert(zzVal, 0, pvLoVal)
        array.insert(zzIdx, 0, pvLoX)
    else if zzType.size() >= 1
        if (zzType.get(zzType.size() - 1)) == 'H' or (zzType.get(zzType.size() - 1)) == 'HH' or (zzType.get(zzType.size() - 1)) == 'LH'
            if pvLo < zzVal.get(zzType.size() - 1)
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvLoVal ? 'HL' : 'LL' : 'L')
                array.push(zzVal, pvLoVal)
                array.push(zzIdx, pvLoX)
            else if pvLo > zzVal.get(zzType.size() - 1)
                array.remove(zzType, zzType.size() - 1)
                array.remove(zzVal, zzVal.size() - 1)
                array.remove(zzIdx, zzIdx.size() - 1)
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvHiVal ? 'HH' : 'LH' : 'H')
                array.push(zzVal, pvHiVal)
                array.push(zzIdx, pvHiX)
        else if (zzType.get(zzType.size() - 1)) == 'L' or (zzType.get(zzType.size() - 1)) == 'HL' or (zzType.get(zzType.size() - 1)) == 'LL'
            if (zzVal.get(zzVal.size() - 1)) > pvLoVal
                array.remove(zzType, zzType.size() - 1)
                array.remove(zzVal, zzVal.size() - 1)
                array.remove(zzIdx, zzIdx.size() - 1)
                array.push(zzType, zzType.size() > 2 ? zzVal.get(zzType.size() - 2) < pvLoVal ? 'HL' : 'LL' : 'L')
                array.push(zzVal, pvLoVal)
                array.push(zzIdx, pvLoX)

// ─────────────────────────────────────────────────────────────
//  Swing seed + structure tracking
// ─────────────────────────────────────────────────────────────
if zzType.size() == 2
    if zzType.get(0) == 'H'
        hkSwingHi := zzVal.get(0)
        hkSwingLo  := zzVal.get(1)
        hkSwingHiX := zzIdx.get(0)
        hkSwingLoX  := zzIdx.get(1)
        hkSwingHiT  := zzType.get(0)
        hkSwingLoT   := zzType.get(1)
    else if zzType.get(0) == 'L'
        hkSwingHi := zzVal.get(1)
        hkSwingLo  := zzVal.get(0)
        hkSwingHiX := zzIdx.get(1)
        hkSwingLoX  := zzIdx.get(0)
        hkSwingHiT  := zzType.get(1)
        hkSwingLoT   := zzType.get(0)

if zzVal.size() == 1
    if seedLock0
        array.insert(zzTypeM, 0, 'M' + zzType.get(0))
        array.insert(zzValM, 0, zzVal.get(0))
        array.insert(zzIdxM, 0, zzIdx.get(0))
        seedLock0 := false

if zzVal.size() == 2
    if seedLock1
        array.insert(zzTypeM, 1, 'M' + zzType.get(1))
        array.insert(zzValM, 1, zzVal.get(1))
        array.insert(zzIdxM, 1, zzIdx.get(1))
        seedLock1 := false

if zzVal.size() > 1
    if zzVal.get(zzVal.size() - 1)[1] != zzVal.get(zzVal.size() - 1)
        if str.substring(zzType.get(zzType.size() - 1)[1], str.length(zzType.get(zzType.size() - 1)) - 1) != str.substring(zzType.get(zzType.size() - 1), str.length(zzType.get(zzType.size() - 1)) - 1)
            array.push(zzTypeM, 'm' + zzType.get(zzType.size() - 1))
            array.push(zzValM, zzVal.get(zzVal.size() - 1))
            array.push(zzIdxM, zzIdx.get(zzIdx.size() - 1))
        else
            array.remove(zzValM, zzValM.size() - 1)
            array.remove(zzIdxM, zzIdxM.size() - 1)
            array.push(zzValM, zzVal.get(zzVal.size() - 1))
            array.push(zzIdxM, zzIdx.get(zzIdx.size() - 1))

// ─────────────────────────────────────────────────────────────
//  STRUCTURE TRACKER
// ─────────────────────────────────────────────────────────────
if zzValM.size() > 1
    // High structure tracking
    if close > hkSwingHi
        if zzTypeM.get(zzTypeM.size() - 1) == 'mL'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('ML')
            hkSwingLo := zzValM.get(zzValM.size() - 1)
            hkSwingLoX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingLoT  := zzTypeM.get(zzTypeM.size() - 1)
        else if zzTypeM.get(zzTypeM.size() - 1) == 'mHL'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('M' + zzType.get(zzType.size() - 1))
            hkSwingLo := zzValM.get(zzValM.size() - 1)
            hkSwingLoX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingLoT  := zzTypeM.get(zzTypeM.size() - 1)
        else if zzTypeM.get(zzTypeM.size() - 1) == 'mLL'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('M' + zzType.get(zzType.size() - 1))
            hkSwingLo := zzValM.get(zzValM.size() - 1)
            hkSwingLoX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingLoT  := zzTypeM.get(zzTypeM.size() - 1)
        else if zzTypeM.get(zzTypeM.size() - 1) == 'mLH' or zzTypeM.get(zzTypeM.size() - 1) == 'mHH' or zzTypeM.get(zzTypeM.size() - 1) == 'MLH' or zzTypeM.get(zzTypeM.size() - 1) == 'MHH'
            if zzTypeM.get(zzTypeM.size() - 2) == 'mHL'
                zzTypeM.remove(zzTypeM.size() - 2)
                zzTypeM.insert(zzValM.size() - 2, 'M' + zzType.get(zzType.size() - 2))
                hkSwingLo := zzValM.get(zzValM.size() - 2)
                hkSwingLoX := zzIdxM.get(zzIdxM.size() - 2)
                hkSwingLoT  := zzTypeM.get(zzTypeM.size() - 2)
            else if zzTypeM.get(zzTypeM.size() - 2) == 'mLL'
                zzTypeM.remove(zzTypeM.size() - 2)
                zzTypeM.insert(zzValM.size() - 2, 'M' + zzType.get(zzType.size() - 2))
                hkSwingLo := zzValM.get(zzValM.size() - 2)
                hkSwingLoX := zzIdxM.get(zzIdxM.size() - 2)
                hkSwingLoT  := zzTypeM.get(zzTypeM.size() - 2)

    if zzValM.get(zzValM.size() - 1) > hkSwingHi
        if zzTypeM.get(zzTypeM.size() - 1) == 'mH'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('MH')
            hkSwingHi := zzValM.get(zzValM.size() - 1)
            hkSwingHiX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingHiT  := zzTypeM.get(zzTypeM.size() - 1)
        else if zzTypeM.get(zzTypeM.size() - 1) == 'mLH'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('M' + zzType.get(zzType.size() - 1))
            hkSwingHi := zzValM.get(zzValM.size() - 1)
            hkSwingHiX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingHiT  := zzTypeM.get(zzTypeM.size() - 1)
        else if zzTypeM.get(zzTypeM.size() - 1) == 'mHH' or zzTypeM.get(zzTypeM.size() - 1) == 'MHH'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('M' + zzType.get(zzType.size() - 1))
            hkSwingHi := zzValM.get(zzValM.size() - 1)
            hkSwingHiX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingHiT  := zzTypeM.get(zzTypeM.size() - 1)

    // Low structure tracking
    if close < hkSwingLo
        if zzTypeM.get(zzTypeM.size() - 1) == 'mH'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('MH')
            hkSwingHi := zzValM.get(zzValM.size() - 1)
            hkSwingHiX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingHiT  := zzTypeM.get(zzTypeM.size() - 1)
        else if zzTypeM.get(zzTypeM.size() - 1) == 'mLH'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('M' + zzType.get(zzType.size() - 1))
            hkSwingHi := zzValM.get(zzValM.size() - 1)
            hkSwingHiX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingHiT  := zzTypeM.get(zzTypeM.size() - 1)
        else if zzTypeM.get(zzTypeM.size() - 1) == 'mHH'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('M' + zzType.get(zzType.size() - 1))
            hkSwingHi := zzValM.get(zzValM.size() - 1)
            hkSwingHiX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingHiT  := zzTypeM.get(zzTypeM.size() - 1)
        else if zzTypeM.get(zzTypeM.size() - 1) == 'mHL' or zzTypeM.get(zzTypeM.size() - 1) == 'mLL' or zzTypeM.get(zzTypeM.size() - 1) == 'MHL' or zzTypeM.get(zzTypeM.size() - 1) == 'MLL'
            if zzTypeM.get(zzTypeM.size() - 2) == 'mLH'
                zzTypeM.remove(zzTypeM.size() - 2)
                zzTypeM.insert(zzValM.size() - 2, 'M' + zzType.get(zzType.size() - 2))
                hkSwingHi := zzValM.get(zzValM.size() - 2)
                hkSwingHiX := zzIdxM.get(zzIdxM.size() - 2)
                hkSwingHiT  := zzTypeM.get(zzTypeM.size() - 2)
            else if zzTypeM.get(zzTypeM.size() - 2) == 'mHH'
                zzTypeM.remove(zzTypeM.size() - 2)
                zzTypeM.insert(zzValM.size() - 2, 'M' + zzType.get(zzType.size() - 2))
                hkSwingHi := zzValM.get(zzValM.size() - 2)
                hkSwingHiX := zzIdxM.get(zzIdxM.size() - 2)
                hkSwingHiT  := zzTypeM.get(zzTypeM.size() - 2)

    if zzValM.get(zzValM.size() - 1) < hkSwingLo
        if zzTypeM.get(zzTypeM.size() - 1) == 'mL'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('ML')
            hkSwingLo := zzValM.get(zzValM.size() - 1)
            hkSwingLoX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingLoT  := zzTypeM.get(zzTypeM.size() - 1)
        else if zzTypeM.get(zzTypeM.size() - 1) == 'mHL'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('M' + zzType.get(zzType.size() - 1))
            hkSwingLo := zzValM.get(zzValM.size() - 1)
            hkSwingLoX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingLoT  := zzTypeM.get(zzTypeM.size() - 1)
        else if zzTypeM.get(zzTypeM.size() - 1) == 'mLL' or zzTypeM.get(zzTypeM.size() - 1) == 'MLL'
            zzTypeM.remove(zzTypeM.size() - 1)
            zzTypeM.push('M' + zzType.get(zzType.size() - 1))
            hkSwingLo := zzValM.get(zzValM.size() - 1)
            hkSwingLoX := zzIdxM.get(zzIdxM.size() - 1)
            hkSwingLoT  := zzTypeM.get(zzTypeM.size() - 1)

// ─────────────────────────────────────────────────────────────
//  ZIGZAG LINE (optional)
// ─────────────────────────────────────────────────────────────
if zzTypeM.size() >= 2
    X1 = zzIdxM.get(zzIdxM.size() - 2)
    Y1 = zzValM.get(zzIdxM.size() - 2)
    X2 = zzIdxM.get(zzIdxM.size() - 1)
    Y2 = zzValM.get(zzIdxM.size() - 1)
    zzLine := line.new(X1, Y1, X2, Y2, color = ShZ ? color.new(#2484bb, 0) : #ffffff00, style = line.style_solid, width = 1)
    if line.get_x1(zzLine) == line.get_x1(zzLine[1])
        line.delete(zzLine[1])

// ─────────────────────────────────────────────────────────────
//  FIBO LAYER: storage and functions
// ─────────────────────────────────────────────────────────────
var array<box>   boxesG  = array.new_box()
var array<box>   boxesR  = array.new_box()
var array<line>  tlines  = array.new_line()
var array<label> tlabels = array.new_label()
var array<label> tHeaders = array.new_label()

f_fib(p0, p1, lvl) => p0 + (p1 - p0) * lvl

// pick break-line color by side only
f_zoneCol(isLong, brkType) =>
    isLong ? colLongBreak : colShortBreak

// elements drawn PER SETUP (update if you change drawSetup)
LINES_PER_SETUP  = 5
LABELS_PER_SETUP = 5

prune() =>
    while array.size(boxesG) > maxBoxes
        box.delete(array.shift(boxesG))
        box.delete(array.shift(boxesR))
    while array.size(tlines) > maxBoxes * LINES_PER_SETUP
        line.delete(array.shift(tlines))
    while array.size(tlabels) > maxBoxes * LABELS_PER_SETUP
        label.delete(array.shift(tlabels))
    while array.size(tHeaders) > maxBoxes
        label.delete(array.shift(tHeaders))

drawSetup(p0, p1, isLong, brkType) =>
    entryP = f_fib(p0, p1, entryLvl)
    slP    = f_fib(p0, p1, 0.0)
    tp1P   = f_fib(p0, p1, tp1Lvl)
    tp2P   = f_fib(p0, p1, tp2Lvl)
    tp3P   = f_fib(p0, p1, tp3Lvl)
    xL = bar_index
    xR = bar_index + boxLen
    bR = box.new(xL, math.max(entryP, slP), xR, math.min(entryP, slP), border_color = color.new(color.red, 50), bgcolor = colRed)
    bG = box.new(xL, math.max(entryP, tp3P), xR, math.min(entryP, tp3P), border_color = color.new(color.green, 50), bgcolor = colGreen)
    array.push(boxesR, bR)
    array.push(boxesG, bG)
    if showLines
        array.push(tlines, line.new(xL, slP,  xR, slP,  color = color.red, width = 2))
        array.push(tlines, line.new(xL, tp1P, xR, tp1P, color = color.new(color.green, 0), style = line.style_dashed))
        array.push(tlines, line.new(xL, tp2P, xR, tp2P, color = color.new(color.green, 0), style = line.style_dashed))
        array.push(tlines, line.new(xL, tp3P, xR, tp3P, color = color.new(color.green, 0), style = line.style_dashed))
        array.push(tlines, line.new(xL, entryP, xR, entryP, color = color.gray, style = line.style_dashed))
        array.push(tlabels, label.new(xR, slP,  'SL '  + str.tostring(slP,  format.mintick), style = label.style_label_left, color = color.new(color.red,20),  textcolor = color.white, size = size.small))
        array.push(tlabels, label.new(xR, tp1P, 'TP1 ' + str.tostring(tp1P, format.mintick), style = label.style_label_left, color = color.new(color.green,20), textcolor = color.white, size = size.small))
        array.push(tlabels, label.new(xR, tp2P, 'TP2 ' + str.tostring(tp2P, format.mintick), style = label.style_label_left, color = color.new(color.green,20), textcolor = color.white, size = size.small))
        array.push(tlabels, label.new(xR, tp3P, 'TP3 ' + str.tostring(tp3P, format.mintick), style = label.style_label_left, color = color.new(color.green,20), textcolor = color.white, size = size.small))
        array.push(tlabels, label.new(xR, entryP, 'Entry ' + str.tostring(entryP, format.mintick), style = label.style_label_left, color = color.new(color.gray,20), textcolor = color.white, size = size.small))
    if showPosType
        arrow = isLong ? '▲' : '▼'
        side  = isLong ? 'Long' : 'Short'
        htxt  = brkType + ' ' + arrow + ' ' + side
        hcol  = color.new(f_zoneCol(isLong, brkType), 0)
        array.push(tHeaders, label.new(xL, entryP, htxt, style = isLong ? label.style_label_down : label.style_label_up, color = hcol, textcolor = color.white, size = size.normal))
    prune()

// ─────────────────────────────────────────────────────────────
//  BREAK DETECTOR + setup builder
// ─────────────────────────────────────────────────────────────
// Bullish: close crosses above hkSwingHi
if ta.crossover(close, hkSwingHi) and hkBreakLock != hkSwingHiX
    isBoS = hkTrend == 'No Trend' or hkTrend == 'Up Trend'
    isChoCh = hkTrend == 'Down Trend'
    if isBoS or isChoCh
        hkBreakLock := hkSwingHiX
        hkTrend := 'Up Trend'
        brkType = isChoCh ? 'ChoCh' : 'BoS'
        if showLabels
            brkCol = f_zoneCol(true, brkType)
            line.new(hkSwingHiX, hkSwingHi, bar_index, hkSwingHi, color = color.new(brkCol, 0))
            label.new(math.floor((hkSwingHiX + bar_index) / 2), hkSwingHi, brkType, color = color.new(color.black, 100), textcolor = color.new(brkCol, 0), style = label.style_label_down, size = size.small)
        // LONG: 0 = low, 1 = broken high
        allow = (isChoCh) or (isBoS and not onlyChoCh)
        if useLong and allow and not na(hkSwingLo)
            drawSetup(hkSwingLo, hkSwingHi, true, brkType)

// Bearish: close crosses below hkSwingLo
if ta.crossunder(close, hkSwingLo) and hkBreakLock != hkSwingLoX
    isBoS = hkTrend == 'No Trend' or hkTrend == 'Down Trend'
    isChoCh = hkTrend == 'Up Trend'
    if isBoS or isChoCh
        hkBreakLock := hkSwingLoX
        hkTrend := 'Down Trend'
        brkType = isChoCh ? 'ChoCh' : 'BoS'
        if showLabels
            brkCol = f_zoneCol(false, brkType)
            line.new(hkSwingLoX, hkSwingLo, bar_index, hkSwingLo, color = color.new(brkCol, 0))
            label.new(math.floor((hkSwingLoX + bar_index) / 2), hkSwingLo, brkType, color = color.new(color.black, 100), textcolor = color.new(brkCol, 0), style = label.style_label_up, size = size.small)
        // SHORT: 0 = high, 1 = broken low
        allow = (isChoCh) or (isBoS and not onlyChoCh)
        if useShort and allow and not na(hkSwingHi)
            drawSetup(hkSwingHi, hkSwingLo, false, brkType)
````
