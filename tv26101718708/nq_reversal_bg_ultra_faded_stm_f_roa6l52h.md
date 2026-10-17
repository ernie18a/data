# NQ Reversal BG Ultra Faded STM F

- url: https://www.tradingview.com/script/RoA6l52h-NQ-Reversal-BG-Ultra-Faded-STM-F/
- type: indicator
- pine_id: PUB;62d29f0822e040358a6335aaaaf94ed6
- version: 2.0

## Description

## ⚠️ DISCLAIMER

This indicator is for educational and informational use only. It does not provide financial advice. Trading futures and leveraged instruments carries significant risk, including potential loss of capital. Users are fully responsible for their trading decisions and risk management.

---

## 🧠 Overview

**NQ Reversal BG Ultra Faded STM** is a precision timing overlay that highlights key **intraday reversal windows** where market behavior historically shifts in liquidity and volatility.

Rather than generating trade signals, this tool focuses on:

* ⏱️ Time-based market structure awareness
* 🌊 Liquidity expansion & contraction cycles
* 🔁 Intraday reversal probability zones
* 🧠 Behavioral session mapping

The indicator uses ultra-faded visual backgrounds to keep charts clean while still marking **high-impact timing clusters**.

---

## ⏰ Core Concept

Markets do not move randomly — they move in **time clusters**.

This tool highlights key windows where:

* Institutional participation increases or decreases
* Liquidity is injected or withdrawn
* Short-term reversals are statistically more likely
* Intraday trend shifts often originate

Each highlighted time zone acts as a **context layer**, not a signal.

---

## 📊 Key Time Windows Covered

The indicator marks the following NY time zones:

* 3:00 AM – Early liquidity positioning
* 4:00 AM – London expansion continuation
* 6:00 AM – Pre-New York buildup phase
* 8:00 AM – Institutional pre-market positioning
* 9:45 AM – Post-open rotation zone
* 10:30 AM – First major intraday shift window
* 11:30 AM – Midday exhaustion / continuation test
* 1:30 PM – Afternoon liquidity repositioning
* 2:00 PM – Late-session structural shift window

Each zone is displayed with a **soft fade background** to maintain chart clarity while preserving awareness.

---

## 🎯 Strategy Purpose

This tool is designed to help traders identify:

* 📍 When NOT to trade (low probability chop zones)
* 📍 When volatility is likely to expand or reverse
* 📍 When institutional flow typically repositions
* 📍 Where intraday reversals often cluster

It is best used as a **context filter layered over price action systems** such as:

* SMC / Liquidity models
* VWAP-based strategies
* Breakout & reversal systems
* Order flow confirmation setups

---

## 🧪 Visual Philosophy

Unlike signal-heavy indicators, this system is intentionally minimal:

* Ultra-faded backgrounds (non-intrusive)
* Clean time-based labeling
* No repainting signals or predictive arrows
* Pure structural timing awareness

The goal is **chart clarity + behavioral timing insight**, not noise.

---

## 🧠 How Traders Use It

Common applications include:

* Avoiding entries during low-quality time windows
* Waiting for high-probability reversal periods
* Aligning setups with liquidity expansion phases
* Timing entries around institutional rotation periods

---

## ⚡ Final Note

This indicator is built around a simple edge:

> **“Time is a structural variable in price movement.”**

Understanding *when* price is most reactive is often more powerful than predicting *direction*.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StanTheTradingMan

//@version=6
indicator("NQ Reversal BG Ultra Faded STM F", shorttitle="RevBG", overlay=true, max_lines_count=500, max_labels_count=500)

// ================================================
//  DISCLAIMER
// ================================================
// This script is for educational and personal use only.
// It is not financial advice. Trading involves substantial risk of loss.
// Always use proper risk management and trade at your own responsibility.
// Created by @StanTheTradingMan

// ──────────────────────────────────────────────────────────────
// INPUTS - More Transparent Defaults
// ──────────────────────────────────────────────────────────────
show_bg          = input.bool(true, "Show Faded Backgrounds")
bg_transparency  = input.int(94, "Background Transparency (Higher = Fainter)", minval=80, maxval=98, step=1)

highlight_300    = input.bool(true, "Highlight 3:00 AM ET")
highlight_400    = input.bool(true, "Highlight 4:00 AM ET")
highlight_600    = input.bool(true, "Highlight 6:00 AM ET")
highlight_800    = input.bool(true, "Highlight 8:00 AM ET")
highlight_945    = input.bool(true, "Highlight 9:45 AM ET")
highlight_1030   = input.bool(true, "Highlight 10:30 AM ET")
highlight_1130   = input.bool(true, "Highlight 11:30 AM ET")
highlight_130    = input.bool(true, "Highlight 1:30 PM ET")
highlight_200    = input.bool(true, "Highlight 2:00 PM ET")

window_minutes   = input.int(10, "Highlight Window ± Minutes", minval=1, maxval=30)

// Colors - All start with very high transparency
color_300  = input.color(color.new(color.gray, 94), "3:00 AM Color")
color_400  = input.color(color.new(color.gray, 94), "4:00 AM Color")
color_600  = input.color(color.new(color.gray, 94), "6:00 AM Color")
color_800  = input.color(color.new(color.gray, 94), "8:00 AM Color")
color_945  = input.color(color.new(color.gray, 94), "9:45 AM Color")
color_1030 = input.color(color.new(color.gray, 94), "10:30 AM Color")
color_1130 = input.color(color.new(color.gray, 94), "11:30 AM Color")
color_130  = input.color(color.new(color.gray, 94), "1:30 PM Color")
color_200  = input.color(color.new(color.gray, 94), "2:00 PM Color")

// ──────────────────────────────────────────────────────────────
// TIME WINDOW FUNCTION
// ──────────────────────────────────────────────────────────────
is_time_window(t_hour, t_min) =>
    tz = "America/New_York"
    cur_h = hour(time, tz)
    cur_m = minute(time, tz)
    half = math.round(window_minutes / 2)
    target_min = t_hour * 60 + t_min
    current_min = cur_h * 60 + cur_m
    math.abs(current_min - target_min) <= half

// ──────────────────────────────────────────────────────────────
// CHECK TIMES
// ──────────────────────────────────────────────────────────────
bg_300  = highlight_300  and is_time_window(3,  0)
bg_400  = highlight_400  and is_time_window(4,  0)
bg_600  = highlight_600  and is_time_window(6,  0)
bg_800  = highlight_800  and is_time_window(8,  0)
bg_945  = highlight_945  and is_time_window(9,  45)
bg_1030 = highlight_1030 and is_time_window(10, 30)
bg_1130 = highlight_1130 and is_time_window(11, 30)
bg_130  = highlight_130  and is_time_window(13, 30)
bg_200  = highlight_200  and is_time_window(14,  0)

// ──────────────────────────────────────────────────────────────
// ULTRA-FADED BACKGROUND
// ──────────────────────────────────────────────────────────────
bg_color = bg_300  ? color.new(color_300,  bg_transparency) :
           bg_400  ? color.new(color_400,  bg_transparency) :
           bg_600  ? color.new(color_600,  bg_transparency) :
           bg_800  ? color.new(color_800,  bg_transparency) :
           bg_945  ? color.new(color_945,  bg_transparency) :
           bg_1030 ? color.new(color_1030, bg_transparency) :
           bg_1130 ? color.new(color_1130, bg_transparency) :
           bg_130  ? color.new(color_130,  bg_transparency) :
           bg_200  ? color.new(color_200,  bg_transparency) : na

bgcolor(show_bg ? bg_color : na, title="Reversal Times")

// ──────────────────────────────────────────────────────────────
// LABELS
// ──────────────────────────────────────────────────────────────
if barstate.islast
    if bg_300
        label.new(bar_index, high, "3:00", style=label.style_label_down, color=color_300, textcolor=color.white, size=size.small)
    if bg_400
        label.new(bar_index, high, "4:00", style=label.style_label_down, color=color_400, textcolor=color.white, size=size.small)
    if bg_600
        label.new(bar_index, high, "6:00", style=label.style_label_down, color=color_600, textcolor=color.white, size=size.small)
    if bg_800
        label.new(bar_index, high, "8:00", style=label.style_label_down, color=color_800, textcolor=color.white, size=size.small)
    if bg_945
        label.new(bar_index, high, "9:45", style=label.style_label_down, color=color_945, textcolor=color.white, size=size.small)
    if bg_1030
        label.new(bar_index, high, "10:30", style=label.style_label_down, color=color_1030, textcolor=color.white, size=size.small)
    if bg_1130
        label.new(bar_index, high, "11:30", style=label.style_label_down, color=color_1130, textcolor=color.white, size=size.small)
    if bg_130
        label.new(bar_index, high, "1:30", style=label.style_label_down, color=color_130, textcolor=color.white, size=size.small)
    if bg_200
        label.new(bar_index, high, "2:00", style=label.style_label_down, color=color_200, textcolor=color.white, size=size.small)
````
