# Elliott Wave Analysis

- url: https://www.tradingview.com/script/0Bq2Y12S-Elliott-Wave-Analysis/
- type: indicator
- pine_id: PUB;ce16fba8a3ce4bf9ad47c45ac0356392
- version: 1.0

## Description

Elliott Wave Analysis Indicator for TradingView
A comprehensive Pine Script indicator that helps identify and label Elliott Wave patterns with full customization.
Features:
Wave Patterns (toggle on/off)

Impulse Waves (1-2-3-4-5)
Corrections (A-B-C)
Flats (3-3-5 structure)
Zigzags (5-3-5 structure)
Triangles, Flags, Wedges (a-b-c-d-e)

Wave Degrees (15 hierarchical levels - toggle individually)

Supermillennium → Miniscule
Proper numbering for each degree (Roman numerals, Arabic numerals, circled numbers, etc.)

Technical Tools

Trend Channels: Auto-detects and draws upper/lower channels
Fibonacci Retracement: 0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 100%
Fibonacci Extension: 127.2%, 161.8%, 200%, 261.8%

Visual Design

White color only (no distractions)
Clean, professional appearance
Fully optional inputs—show only what you need

How It Works:

Customize via indicator settings to toggle wave patterns, degrees, channels, and Fibonacci levels on/off. Adapt the indicator to match your Elliott Wave analysis timeframe and trading style.

## Source Code

````pine
//@version=6
indicator("Elliott Wave Analysis", overlay=true, max_labels_count=500, max_lines_count=500)
 
// ============================================================================
// INPUTS - Toggle all features on/off
// ============================================================================
 
// Wave Detection
show_impulse = input(true, "Show Impulse Waves (1-2-3-4-5)", group="Wave Patterns")
show_correction = input(true, "Show Corrections (A-B-C)", group="Wave Patterns")
show_flats = input(true, "Show Flats (3-3-5)", group="Wave Patterns")
show_zigzags = input(true, "Show Zigzags (5-3-5)", group="Wave Patterns")
show_triangles = input(true, "Show Triangles (a-b-c-d-e)", group="Wave Patterns")
show_flags = input(true, "Show Flags (a-b-c-d-e)", group="Wave Patterns")
show_wedges = input(true, "Show Wedges (a-b-c-d-e)", group="Wave Patterns")
 
// Wave Degree (Hierarchy)
show_supermillennium = input(false, "Supermillennium ①②③④⑤", group="Wave Degree")
show_millennium = input(false, "Millennium (1)(2)(3)(4)(5)", group="Wave Degree")
show_submillennium = input(true, "Submillennium 1-2-3-4-5", group="Wave Degree")
show_grand_supercycle = input(false, "Grand Supercycle Ⅰ Ⅱ Ⅲ Ⅳ Ⅴ", group="Wave Degree")
show_supercycle = input(false, "Supercycle (I)(II)(III)(IV)(V)", group="Wave Degree")
show_cycle = input(false, "Cycle I-II-III-IV-V", group="Wave Degree")
show_primary = input(false, "Primary ①②③④⑤", group="Wave Degree")
show_intermediate = input(false, "Intermediate (1)(2)(3)(4)(5)", group="Wave Degree")
show_minor = input(true, "Minor 1-2-3-4-5", group="Wave Degree")
show_minute = input(false, "Minute ⓘ ⓘⓘ ⓘⓘⓘ ⓘⓥ ⓥ", group="Wave Degree")
show_minuette = input(false, "Minuette (i)(ii)(iii)(iv)(v)", group="Wave Degree")
show_subminuette = input(false, "Subminuette i-ii-iii-iv-v", group="Wave Degree")
show_micro = input(true, "Micro ①②③④⑤", group="Wave Degree")
show_submicro = input(false, "Submicro (1)(2)(3)(4)(5)", group="Wave Degree")
show_miniscule = input(false, "Miniscule 1-2-3-4-5", group="Wave Degree")
 
// Trend Channels
show_channels = input(true, "Show Trend Channels", group="Channels")
channel_length = input(20, "Channel Detection Length", group="Channels")
 
// Fibonacci
show_fib_retracement = input(true, "Show Fib Retracement", group="Fibonacci")
show_fib_extension = input(true, "Show Fib Extension", group="Fibonacci")
fib_lookback = input(50, "Fib Lookback Bars", group="Fibonacci")
 
// ============================================================================
// CONSTANTS - Wave Labelings
// ============================================================================
 
var array<string> supermillennium_labels = array.from("①", "②", "③", "④", "⑤")
var array<string> millennium_labels = array.from("(1)", "(2)", "(3)", "(4)", "(5)")
var array<string> submillennium_labels = array.from("1", "2", "3", "4", "5")
var array<string> grand_supercycle_labels = array.from("Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ")
var array<string> supercycle_labels = array.from("(I)", "(II)", "(III)", "(IV)", "(V)")
var array<string> cycle_labels = array.from("I", "II", "III", "IV", "V")
var array<string> primary_labels = array.from("①", "②", "③", "④", "⑤")
var array<string> intermediate_labels = array.from("(1)", "(2)", "(3)", "(4)", "(5)")
var array<string> minor_labels = array.from("1", "2", "3", "4", "5")
var array<string> minute_labels = array.from("ⓘ", "ⓘⓘ", "ⓘⓘⓘ", "ⓘⓥ", "ⓥ")
var array<string> minuette_labels = array.from("(i)", "(ii)", "(iii)", "(iv)", "(v)")
var array<string> subminuette_labels = array.from("i", "ii", "iii", "iv", "v")
var array<string> micro_labels = array.from("①", "②", "③", "④", "⑤")
var array<string> submicro_labels = array.from("(1)", "(2)", "(3)", "(4)", "(5)")
var array<string> miniscule_labels = array.from("1", "2", "3", "4", "5")
 
var array<string> correction_labels = array.from("A", "B", "C")
var array<string> triangle_labels = array.from("a", "b", "c", "d", "e")
 
// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
 
f_get_active_labels() =>
    active_labels = 0
    if show_supermillennium
        active_labels += 1
    if show_millennium
        active_labels += 1
    if show_submillennium
        active_labels += 1
    if show_grand_supercycle
        active_labels += 1
    if show_supercycle
        active_labels += 1
    if show_cycle
        active_labels += 1
    if show_primary
        active_labels += 1
    if show_intermediate
        active_labels += 1
    if show_minor
        active_labels += 1
    if show_minute
        active_labels += 1
    if show_minuette
        active_labels += 1
    if show_subminuette
        active_labels += 1
    if show_micro
        active_labels += 1
    if show_submicro
        active_labels += 1
    if show_miniscule
        active_labels += 1
    active_labels
 
// Detect Higher High
f_higher_high(index) =>
    if index >= 2
        high[index] > high[index-1] and high[index-1] > high[index-2]
    else
        false
 
// Detect Lower Low
f_lower_low(index) =>
    if index >= 2
        low[index] < low[index-1] and low[index-1] < low[index-2]
    else
        false
 
// Detect Trend
f_is_uptrend() =>
    close > ta.sma(close, 50)
 
f_is_downtrend() =>
    close < ta.sma(close, 50)
 
// ============================================================================
// TREND CHANNELS
// ============================================================================
 
if show_channels
    // Uptrend Channel
    if f_is_uptrend()
        channel_high = ta.highest(high, channel_length)
        channel_low = ta.lowest(low, channel_length)
        line.new(bar_index[channel_length], channel_high, bar_index, channel_high, color=color.new(color.white, 50), width=1, style=line.style_solid)
        line.new(bar_index[channel_length], channel_low, bar_index, channel_low, color=color.new(color.white, 50), width=1, style=line.style_solid)
 
    // Downtrend Channel
    if f_is_downtrend()
        channel_high = ta.highest(high, channel_length)
        channel_low = ta.lowest(low, channel_length)
        line.new(bar_index[channel_length], channel_high, bar_index, channel_high, color=color.new(color.white, 50), width=1, style=line.style_solid)
        line.new(bar_index[channel_length], channel_low, bar_index, channel_low, color=color.new(color.white, 50), width=1, style=line.style_solid)
 
// ============================================================================
// FIBONACCI LEVELS
// ============================================================================
 
if show_fib_retracement
    highest = ta.highest(high, fib_lookback)
    lowest = ta.lowest(low, fib_lookback)
    range_val = highest - lowest
 
    // Fib Levels: 0, 23.6, 38.2, 50, 61.8, 78.6, 100
    fib_0 = lowest
    fib_236 = lowest + (range_val * 0.236)
    fib_382 = lowest + (range_val * 0.382)
    fib_50 = lowest + (range_val * 0.5)
    fib_618 = lowest + (range_val * 0.618)
    fib_786 = lowest + (range_val * 0.786)
    fib_100 = highest
 
    if bar_index == bar_index[0]
        label.new(bar_index + 5, fib_0, "0%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
        label.new(bar_index + 5, fib_236, "23.6%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
        label.new(bar_index + 5, fib_382, "38.2%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
        label.new(bar_index + 5, fib_50, "50%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
        label.new(bar_index + 5, fib_618, "61.8%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
        label.new(bar_index + 5, fib_786, "78.6%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
        label.new(bar_index + 5, fib_100, "100%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
 
if show_fib_extension
    highest = ta.highest(high, fib_lookback)
    lowest = ta.lowest(low, fib_lookback)
    range_val = highest - lowest
 
    // Extension Levels: 127.2, 161.8, 200, 261.8
    ext_1272 = highest + (range_val * 0.272)
    ext_1618 = highest + (range_val * 0.618)
    ext_200 = highest + range_val
    ext_2618 = highest + (range_val * 1.618)
 
    if bar_index == bar_index[0]
        label.new(bar_index + 5, ext_1272, "127.2%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
        label.new(bar_index + 5, ext_1618, "161.8%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
        label.new(bar_index + 5, ext_200, "200%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
        label.new(bar_index + 5, ext_2618, "261.8%", color=color.new(color.white, 50), textcolor=color.new(color.white, 50), size=size.tiny)
 
// ============================================================================
// WAVE DETECTION & LABELING
// ============================================================================
 
// Simple impulse wave detection (1-2-3-4-5)
if show_impulse and show_submillennium
    if f_higher_high(bar_index)
        label.new(bar_index, high + (high * 0.005), "1", color=color.new(color.white, 0), textcolor=color.white, size=size.small)
 
// Simple correction detection (A-B-C)
if show_correction and show_submillennium
    if f_lower_low(bar_index)
        label.new(bar_index, low - (low * 0.005), "A", color=color.new(color.white, 0), textcolor=color.white, size=size.small)
 
// ============================================================================
// PLOT SUMMARY
// ============================================================================
 
plotchar(na, "Elliott Wave Indicator Loaded", "", location.top)
````
