# NQ Liquidity Zones (Pro Cluster - Ultimate) STM V1

- url: https://www.tradingview.com/script/E6nhQvx0-NQ-Liquidity-Zones-Pro-Cluster-Ultimate-STM-V1/
- type: indicator
- pine_id: PUB;b0037378c083411595d423d0aa54b779
- version: 1.0

## Description

# 📊 Liquidity Zones (Pro Cluster – Ultimate)

## 🧠 Overview

This indicator is a **multi-factor liquidity clustering engine** designed to identify high-probability price reaction zones using:

* Price density clustering (HLC3-based)
* Volume-weighted confirmation
* Relative volume filtering
* Multi-timeframe aggregation
* Session-aware liquidity separation (RTH vs overnight)
* Dynamic zone scoring + ranking system

Instead of drawing arbitrary support/resistance lines, it builds **statistically validated liquidity zones** based on repeated price interaction and participation strength.

---

## ⚙️ Core Concept

Markets tend to rotate around areas where:

* Price revisits frequently (liquidity accumulation)
* Volume participation increases (order concentration)
* Sessions overlap or transition (structural imbalance zones)

This tool identifies those regions by scoring price levels based on:

* Touch frequency (price clustering)
* Volume intensity (relative participation)
* Freshness (recency of interaction)
* Session behavior (RTH vs overnight separation)

---

## 📈 How It Works

### 1. Multi-Timeframe Data Engine

The indicator optionally pulls higher timeframe data to build **institutional-grade zones** that reflect broader liquidity structure, not just local noise.

---

### 2. Cluster Detection

Each price level is evaluated across a rolling lookback window:

* Prices within ATR-based proximity are grouped
* Each cluster accumulates:

  * Touch count
  * Relative volume contribution
  * Session-based participation bias

---

### 3. Scoring System

Every cluster receives a composite strength score based on:

* Density of price interaction
* Volume weighting (optional)
* Session behavior (regular vs overnight liquidity)
* Recency of last interaction

Only clusters above a **minimum strength threshold** are promoted to active zones.

---

### 4. Zone Classification

Zones are automatically categorized as:

* **Support Zones (Demand)** → price below current market
* **Resistance Zones (Supply)** → price above current market
* **ETH King Zone (optional highlight)** → highest overnight liquidity concentration

---

### 5. Dynamic Filtering

To remove noise, the system filters zones using:

* Minimum strength score
* Minimum relative volume threshold
* Age-based decay (zones lose relevance over time)
* Sensitivity cutoff for stale liquidity

---

### 6. Visual Structure

Each zone is rendered as:

* A shaded liquidity band (not a thin line)
* Color-coded by type (supply/demand)
* Optional “King Zone” highlight for dominant liquidity clusters
* Transparent aging effect to show weakening levels over time

---

### 7. Alert Engine

The script generates real-time alerts for:

* **Zone Entry**
  → Price enters a liquidity zone from outside

* **Zone Break**
  → Price breaks through a liquidity zone boundary

Alerts are ranked so only the strongest zones trigger notifications (configurable top-N filtering).

---

## 🧩 What Makes It “Pro Grade”

Unlike standard support/resistance tools, this model:

* Uses **statistical clustering instead of manual pivots**
* Incorporates **volume-weighted liquidity strength**
* Separates **session-based liquidity regimes**
* Ranks zones dynamically instead of treating all levels equally
* Applies **aging decay to reflect real market relevance**

---

## 📌 Best Use Cases

* Intraday liquidity tracking (scalping / day trading)
* Breakout confirmation zones
* Reversal reaction areas
* Session transition analysis (Asia → London → NY)
* Institutional-style liquidity mapping

---

## ⚠️ Important Note

This tool does not predict direction.

It identifies **where liquidity is concentrated**, not what price will do — allowing traders to align entries around statistically significant reaction zones rather than arbitrary levels.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("NQ Liquidity Zones (Pro Cluster - Ultimate) STM V1", overlay=true, max_boxes_count=50, max_labels_count=50, explicit_plot_zorder = true)

// ──────────────────────────────────────
// DISCLAIMER
// ──────────────────────────────────────
// Created by @StanTheTradingMan
// This indicator is for educational and entertainment purposes only.
// It is not financial advice. Always do your own research and trade responsibly.
// Past performance does not guarantee future results.

// ──────────────────────────────────────
// INPUTS
// ──────────────────────────────────────
// --- Discovery ---
lookbackInput = input.int(120, "Lookback Period", minval=20, group="Discovery")
tfInput = input.timeframe("5", "Multi-Timeframe", group="Discovery")
sessionInput = input.session("0930-1600:23456", "RTH Session String", group="Discovery")
rthOnlyInput = input.bool(false, "Filter: RTH Only", group="Discovery")
widthInput = input.float(0.42, "Zone Width (ATR %)", minval=0.1, step=0.05, group="Discovery")

// --- Weighting & Filtering ---
useVolWeight = input.bool(true, "Use Volume Weighting", group="Filtering")
minScoreInput = input.float(3.0, "Min Strength Score", minval=1.0, step=0.1, group="Filtering")
minRelVolInput = input.float(1.1, "Min Relative Volume", minval=0.5, step=0.1, group="Filtering")
useSepVolInput = input.bool(false, "Use Separate Volume Lookback", group="Filtering", inline="vol")
volLookInput = input.int(50, "", minval=10, inline="vol", group="Filtering")
sensitivityInput = input.int(80, "Sensitivity (Max Age)", minval=0, group="Filtering")

// --- Display & Alerts ---
maxZonesInput = input.int(8, "Max Zones to Display", minval=1, maxval=30, group="Display")
highlightETH = input.bool(true, "Highlight 'Overnight King' Zone", group="Display")
alertTopXInput = input.int(3, "Alert on Top N Zones", minval=1, maxval=10, group="Display")

// --- Style ---
colSup = input.color(#ace5dc, "Support (Demand) Color", inline="col", group="Style")
colRes = input.color(#faa1a4, "Resistance (Supply) Color", inline="col", group="Style")
colETH = input.color(#ecdd61, "ETH King Color", group="Style")
txtCol = input.color(#000000, "Text Color", group="Style")

// ──────────────────────────────────────
// DATA FETCHING (Robust MTF)
// ──────────────────────────────────────
fetchMTF() =>
    float _vAvgPrice = ta.sma(volume, lookbackInput)
    float _vAvgVol = ta.sma(volume, volLookInput)
    [hlc3, volume, time, bar_index, ta.atr(14), close, not na(time(timeframe.period, sessionInput, "America/New_York")), _vAvgPrice, _vAvgVol]

[mHlc3, mVol, mTime, mBarIdx, mATR, mClose, mRTH, mVAvgPrice, mVAvgVol] = request.security(syminfo.tickerid, tfInput, fetchMTF(), gaps = barmerge.gaps_off)

currentVAvg = useSepVolInput ? mVAvgVol : mVAvgPrice

// Persistent Containers
var box[] zoneBoxes = array.new_box()
var label[] zoneLabels = array.new_label()
var float[] alertTops = array.new_float()
var float[] alertBots = array.new_float()
var float[] alertScrs = array.new_float()

// ──────────────────────────────────────
// CORE LOGIC
// ──────────────────────────────────────
if barstate.islast and not na(mATR)
    // Cleanup
    for b in zoneBoxes
        box.delete(b)
    for lb in zoneLabels
        label.delete(lb)
    array.clear(zoneBoxes)
    array.clear(zoneLabels)
    array.clear(alertTops)
    array.clear(alertBots)
    array.clear(alertScrs)

    float thickness = mATR * widthInput
    float volAvg = math.max(nz(currentVAvg), 1.0)
   
    int mIndex = nz(mBarIdx)
    int actualLB = math.min(lookbackInput, mIndex)
    int oldestMTFIdx = mIndex - actualLB

    float[] zones = array.new_float()
    float[] scores = array.new_float()
    float[] ethScores = array.new_float()
    int[] lastTouch = array.new_int()

    // --- Discovery ---
    for i = 0 to actualLB - 1
        float p = nz(mHlc3[i])
        if p == 0
            continue
           
        bool alreadyCovered = false
        if array.size(zones) > 0
            for k = 0 to array.size(zones) - 1
                if math.abs(array.get(zones, k) - p) <= thickness
                    alreadyCovered := true
                    break
        if alreadyCovered
            continue
        if rthOnlyInput and not mRTH[i]
            continue

        float clusterRelVolSum = 0.0
        float clusterETHScore = 0.0
        int priceCount = 0
        int lb = oldestMTFIdx

        for j = 0 to actualLB - 1
            if rthOnlyInput and not mRTH[j]
                continue
               
            float pj = nz(mHlc3[j])
            if math.abs(pj - p) <= thickness
                float relVol = nz(mVol[j]) / volAvg
                clusterRelVolSum += relVol
                if not mRTH[j]
                    clusterETHScore += relVol
                priceCount += 1
                lb := math.max(lb, mIndex - j)

        float score = useVolWeight ? clusterRelVolSum : float(priceCount)
        float avgRelVol = priceCount > 0 ? clusterRelVolSum / priceCount : 0.0
        bool isFresh = sensitivityInput == 0 or (mIndex - lb) <= sensitivityInput

        if score >= minScoreInput and isFresh and avgRelVol >= minRelVolInput
            array.push(zones, p)
            array.push(scores, score)
            array.push(ethScores, clusterETHScore)
            array.push(lastTouch, lb)

    // --- Identification of ETH King ---
    int ethKingIdx = -1
    float maxETH = -1.0
    if highlightETH and array.size(ethScores) > 0
        for i = 0 to array.size(ethScores) - 1
            float s = array.get(ethScores, i)
            if s > maxETH
                maxETH := s
                ethKingIdx := i

    // --- Drawing ---
    if array.size(zones) > 0
        int[] sortedIdx = array.sort_indices(scores, order.descending)
        int drawCount = math.min(array.size(sortedIdx), maxZonesInput)

        for i = 0 to drawCount - 1
            int idx = array.get(sortedIdx, i)
            float mid = array.get(zones, idx)
            float score = array.get(scores, idx)
            int lastB = array.get(lastTouch, idx)
           
            bool isETHKing = idx == ethKingIdx
            float top = mid + thickness / 2
            float bot = mid - thickness / 2
            bool isRes = mid > close
           
            color baseC = isETHKing ? colETH : (isRes ? colRes : colSup)
            color labelCol = isETHKing ? #8B8000 : txtCol

            if i < alertTopXInput
                array.push(alertTops, top)
                array.push(alertBots, bot)
                array.push(alertScrs, score)

            float ageF = math.min(1.0, (mIndex - lastB) / float(actualLB))
            int transp = isETHKing ? int(35 + 40 * ageF) : int(70 + 20 * ageF)
            int startBoxTime = int(nz(mTime[actualLB - 1], time[math.min(actualLB - 1, bar_index)]))
           
            box b = box.new(startBoxTime, top, time, bot,
                 xloc=xloc.bar_time,
                 bgcolor=color.new(baseC, transp),
                 border_color=color.new(baseC, isETHKing ? 0 : 100),
                 border_width=isETHKing ? 2 : 0,
                 extend=extend.right)
            array.push(zoneBoxes, b)

            label lbObj = label.new(time, mid, (isETHKing ? "★ ETH KING: " : "LQ: ") + str.tostring(score, "#.#"),
                 xloc=xloc.bar_time,
                 style=label.style_label_left,
                 textcolor=labelCol,
                 color=color.new(chart.bg_color, 100),
                 size=size.small)
            array.push(zoneLabels, lbObj)

// ──────────────────────────────────────
// REAL-TIME ALERTS
// ──────────────────────────────────────
if array.size(alertTops) > 0
    for i = 0 to array.size(alertTops) - 1
        float t = array.get(alertTops, i)
        float b = array.get(alertBots, i)
        float s = array.get(alertScrs, i)
        float m = (t + b) / 2
        string zType = m > close ? "Resistance" : "Support"
        string msg = " (Score: " + str.tostring(s, "#.#") + ")"

        if (close > b and close < t) and (close[1] <= b or close[1] >= t)
            alert("Price entered " + zType + " Liquidity Zone @ " + str.tostring(m, "#.##") + msg, alert.freq_once_per_bar_close)

        if (close > t and close[1] <= t) or (close < b and close[1] >= b)
            alert("Price broke through " + zType + " Liquidity Zone @ " + str.tostring(m, "#.##") + msg, alert.freq_once_per_bar_close)
````
