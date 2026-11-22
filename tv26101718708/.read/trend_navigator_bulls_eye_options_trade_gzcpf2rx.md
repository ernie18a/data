# Trend Navigator - Bulls Eye - Options Trade

- url: https://www.tradingview.com/script/gZCPF2rx-Trend-Navigator-Bulls-Eye-Options-Trade/
- type: indicator
- pine_id: PUB;2ecd67a951a341d3a64d295a8a8cdd28
- version: 2.0

## Description

# GN-CE-PE State Engine

## Overview

GN-CE-PE State Engine is a market participation and synchronization tool designed to help traders assess directional conviction across multiple related instruments.

The indicator monitors the relationship between:

* Gift Nifty
* At-The-Money Call Options
* At-The-Money Put Options

and transforms their combined behavior into a set of actionable market states.

Rather than analyzing a single chart in isolation, the engine focuses on whether bullish or bearish participation is developing in a coordinated manner across the underlying market and its options.

---

## Market States

### Bull Trend

Indicates broad bullish participation and directional alignment across the monitored instruments.

---

### Bear Trend

Indicates broad bearish participation and directional alignment across the monitored instruments.

---

### Reset

Represents a pause, pullback, or temporary loss of momentum within an existing directional move.

This state can help traders identify periods where the market is rebalancing before a potential continuation.

---

### CE Ready

Highlights conditions where bullish participation is strengthening and directional alignment is improving.

---

### PE Ready

Highlights conditions where bearish participation is strengthening and directional alignment is improving.

---

## Dashboard

The built-in dashboard provides a real-time summary of:

* Market bias
* Participation strength
* Momentum state
* Directional alignment
* Confidence score
* Current market condition

This allows traders to quickly assess market structure without switching between multiple charts.

---

## Confidence Score

The confidence score reflects the degree of alignment between the monitored instruments.

Higher scores suggest stronger participation and greater directional agreement, while lower scores often indicate mixed conditions or transitional phases.

The score is intended as a contextual aid and should not be used as a standalone trading signal.

---

## Alerts

The indicator includes alert conditions for:

* CE Ready
* PE Ready

allowing traders to monitor potential opportunities without continuously watching the chart.

---

## Recommended Usage

GN-CE-PE State Engine is designed to complement the **Trend Navigator - BullsEye** indicator.

Suggested workflow:

### Step 1

Use **Trend Navigator - BullsEye** to determine the prevailing market structure and directional bias.

### Step 2

Use **GN-CE-PE State Engine** to evaluate whether participation across the underlying market and options is supporting that directional view.

### Step 3

Focus on opportunities where both indicators are aligned.

This combination helps traders distinguish between isolated price movements and moves that are supported by broader market participation.

---

## Notes

* Designed primarily for intraday market analysis.
* Option symbols should be updated to match the active trading series.
* Intended as an analytical and decision-support tool.
* Not financial advice.

## Disclaimer

This indicator is intended for educational and analytical purposes only. It is designed to assist traders in evaluating market participation, directional alignment, and market structure across the monitored instruments.

The indicator does not predict future price movements and should not be considered a recommendation to buy, sell, or hold any financial instrument. All trading decisions should be made using independent analysis, proper risk management, and personal judgment.

Past market behavior does not guarantee future results. Users are solely responsible for their trading decisions and any resulting gains or losses.

## Source Code

````pine
//@version=6
indicator("Trends Navigator BullsEye Options Trade", shorttitle="BullsEyeOptions", overlay=true, max_labels_count=200)

//=====================================================
// INPUTS
//=====================================================

grp_sym = "Symbols"

gnSymbol = input.symbol("NSE:NIFTY", "NIFTY", group=grp_sym)
ceSymbol = input.symbol("NSE:NIFTY2602005C24100", "Call Option", group=grp_sym)
peSymbol = input.symbol("NSE:NIFTY2602005P24100", "Put Option", group=grp_sym)

grp_ema = "Trend Settings"

fastLen  = input.int(100, "Fast EMA", minval=5, group=grp_ema)
trendLen = input.int(200, "Trend EMA", minval=10, group=grp_ema)

//=====================================================
// DATA
//=====================================================

gnClose = request.security(gnSymbol, timeframe.period, close)
ceClose = request.security(ceSymbol, timeframe.period, close)
peClose = request.security(peSymbol, timeframe.period, close)

//=====================================================
// EMAs
//=====================================================

gnFast  = ta.ema(gnClose, fastLen)
gnTrend = ta.ema(gnClose, trendLen)

ceFast  = ta.ema(ceClose, fastLen)
ceTrend = ta.ema(ceClose, trendLen)

peFast  = ta.ema(peClose, fastLen)
peTrend = ta.ema(peClose, trendLen)

//=====================================================
// TREND STATES
//=====================================================

gnBull = gnClose > gnTrend and gnFast > gnTrend
gnBear = gnClose < gnTrend and gnFast < gnTrend

ceBull = ceClose > ceTrend and ceFast > ceTrend
ceBear = ceClose < ceTrend and ceFast < ceTrend

peBull = peClose > peTrend and peFast > peTrend
peBear = peClose < peTrend and peFast < peTrend

//=====================================================
// MOMENTUM
//=====================================================

gnMomUp = gnFast > gnFast[1]
gnMomDn = gnFast < gnFast[1]

ceMomUp = ceFast > ceFast[1]
ceMomDn = ceFast < ceFast[1]

peMomUp = peFast > peFast[1]
peMomDn = peFast < peFast[1]

//=====================================================
// STATE ENGINE
//=====================================================

bullTrend =
     gnBull and
     ceBull and
     peBear

bearTrend =
     gnBear and
     ceBear and
     peBull

resetState =
     gnBull and
     ceBull and
     gnMomDn and
     ceMomDn and
     peMomUp

ceReady =
     gnBull and
     ceBull and
     gnMomUp and
     ceMomUp and
     peMomDn

peReady =
     gnBear and
     ceBear and
     gnMomDn and
     ceMomDn and
     peMomUp

//=====================================================
// CONFIDENCE SCORE
//=====================================================

score = 0

score += gnBull ? 100 : 0
score += ceBull ? 100 : 0
score += peBear ? 100 : 0

score += gnMomUp ? 15 : 0
score += ceMomUp ? 15 : 0
score += peMomDn ? 10 : 0

//=====================================================
// MARKET STATE
//=====================================================

string state = "NO TRADE"
string action = "WAIT"

if bullTrend
    state := "BULL TREND"

if bearTrend
    state := "BEAR TREND"

if resetState
    state := "RESET"
    action := "WAIT"

if ceReady
    state := "CE READY"
    action := "BUY CE"

if peReady
    state := "PE READY"
    action := "BUY PE"

//=====================================================
// DASHBOARD
//=====================================================

var table dash = table.new(position.top_right, 2, 8, border_width=1)

if barstate.islast

    table.cell(dash, 0, 0, "GN", text_color=color.white)
table.cell(dash, 1, 0, gnBull ? "BULLISH" : "BEARISH", text_color=color.white)

table.cell(dash, 0, 1, "CE", text_color=color.white)
table.cell(dash, 1, 1, ceBull ? "BULLISH" : "BEARISH", text_color=color.white)

table.cell(dash, 0, 2, "PE", text_color=color.white)
table.cell(dash, 1, 2, peBear ? "WEAK" : "STRONG", text_color=color.white)

table.cell(dash, 0, 3, "STATE", text_color=color.white)
table.cell(dash, 1, 3, state, text_color=color.white)

table.cell(dash, 0, 4, "ACTION", text_color=color.white)
table.cell(dash, 1, 4, action, text_color=color.white)

table.cell(dash, 0, 5, "SCORE", text_color=color.white)
table.cell(dash, 1, 5, str.tostring(score), text_color=color.white)

table.cell(dash, 0, 6, "GN MOM", text_color=color.white)
table.cell(dash, 1, 6, gnMomUp ? "UP" : "DOWN", text_color=color.white)

table.cell(dash, 0, 7, "CE MOM", text_color=color.white)
table.cell(dash, 1, 7, ceMomUp ? "UP" : "DOWN", text_color=color.white)

//=====================================================
// ALERTS
//=====================================================

alertcondition(ceReady,
     title="CE READY",
     message="GN-CE-PE Engine: BUY CE")

alertcondition(peReady,
     title="PE READY",
     message="GN-CE-PE Engine: BUY PE")

//=====================================================
// CHART MARKERS
//=====================================================

plotshape(
     ceReady,
     title="CE READY",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.small)

plotshape(
     peReady,
     title="PE READY",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.small)
````
