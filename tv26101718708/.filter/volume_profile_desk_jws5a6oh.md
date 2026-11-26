# Volume Profile Desk

- url: https://www.tradingview.com/script/JWs5A6oH-Volume-Profile-Desk/
- type: indicator
- pine_id: PUB;6d0a083d45a34100a1c1d32dc620cd0f
- version: 1.0

## Description

# 📊 volume profile desk

volume profile desk is an advanced market auction and volume analysis tool designed to show where trading activity is actually concentrated across price.

instead of looking only at candles, the indicator organizes volume by price and combines visible-range profiling, session structure, order-flow estimation, value areas, developing levels, naked poc tracking, high-volume and low-volume nodes, fixed-range analysis, and an integrated market desk.

the objective is to provide a structured view of **value, acceptance, rejection, participation and volume distribution** directly on the chart.

## 🔹 visible range volume profile

the main profile automatically analyzes the portion of the chart currently visible.

when the chart is moved or zoomed, the analyzed range changes with it.

three display modes are available:

**buy and sell** — separates estimated buying and selling participation inside each price row.

**volume** — displays the total volume distribution by price.

**delta** — highlights the difference between estimated buying and selling pressure.

the number of profile rows, profile width, offset and value-area percentage can all be adjusted.

## 🟡 poc — point of control

the poc represents the price row containing the highest concentration of volume inside the analyzed profile.

it can be used as a reference for the market's dominant area of activity.

price repeatedly interacting with the poc can indicate balance, while movement away from it can help identify a developing auction outside established value.

## 🔷 vah and val

the indicator calculates the value area around the poc.

**vah — value area high** represents the upper boundary of value.

**val — value area low** represents the lower boundary of value.

the default value area is 70%, but it can be adjusted from the settings.

price inside the value area represents trading within the established distribution. sustained trading outside vah or val can indicate that the market is attempting to establish value at a different level.

## ◆ hvn — high-volume nodes

high-volume nodes identify areas where significant volume accumulated.

these zones represent strong participation and established acceptance.

hvn areas can become important reference zones because the market previously spent substantial activity there.

## ◇ lvn — low-volume nodes

low-volume nodes identify thin sections of the profile where relatively little volume was exchanged.

these areas represent lower acceptance compared with surrounding prices.

because participation is thinner, price can sometimes travel rapidly through an lvn until it reaches another area of stronger volume concentration.

## 🧭 session profiles

the indicator can maintain individual profiles for previous market sessions.

session selection can operate automatically according to the chart timeframe or use a custom timeframe.

this makes it possible to compare how value develops from one session to another instead of analyzing every session as an isolated price move.

the number of historical session profiles displayed can also be controlled.

## ⚡ developing poc / vah / val

the current session is analyzed dynamically.

the developing poc, vah and val evolve as new volume enters the market.

this provides an important additional dimension: **value migration**.

a developing poc moving higher shows that the dominant volume concentration is shifting upward.

a developing poc moving lower shows that it is shifting downward.

a relatively stable developing poc suggests a more balanced auction.

## 🎯 naked poc

when a session finishes, its poc can remain untested.

the indicator tracks these historical naked pocs and extends them forward until price trades through them.

the closest untested levels can therefore remain visible as historical market references.

when price eventually reaches a naked poc, the indicator records the event.

## 📐 fixed range profile

a second independent profile can be created over a specific section of the market.

two anchoring methods are available:

**last n bars** — analyzes a configurable number of recent candles.

**time anchors** — analyzes the market between two selected timestamps.

this is useful for isolating a specific impulse, consolidation, breakout structure, trading session or other area without changing the main visible-range profile.

the fixed range calculates its own poc, vah, val, volume distribution, buy/sell participation and profile structure.

## ⚖️ order flow

the indicator estimates buying and selling participation using lower-timeframe intrabar information.

an automatic lower timeframe can be selected by the script, or the intrabar timeframe can be manually configured.

a candle-geometry method is also available as an alternative source.

the resulting information is used for buy/sell distribution, net delta and buy-share measurements.

## 📊 profile shapes

the desk automatically classifies the structure of the volume distribution.

**d profile** — relatively balanced distribution around a central poc.

**p profile** — volume concentrated toward the upper part of the distribution.

**b profile** — volume concentrated toward the lower part of the distribution.

**b / double distribution structure** — two important volume distributions separated by a low-volume area.

these structures provide additional context for understanding how the auction developed inside the analyzed range.

## 🖥️ desk panel

the integrated desk summarizes the important information without requiring every level to be interpreted manually.

depending on the enabled options, it can display:

• poc, vah and val  
• value-area width  
• current price location  
• total analyzed volume  
• net delta  
• buy share  
• profile shape  
• auction context  
• developing value migration  
• nearest low-volume node  
• closest untested poc  
• key levels  
• recent level events

## 🔔 level events

the script monitors interactions with important completed-session levels.

crosses of the previous session poc, vah and val are evaluated on confirmed bars.

naked poc fills are also detected and recorded.

these events can be used with tradingview alerts to monitor important changes without constantly watching the chart.

# 🎓 mini tutorial

### 1. start with the visible profile

load the indicator and keep the default **buy and sell** mode.

use approximately **70% value area** and enough rows to obtain useful detail without making the profile unnecessarily fragmented.

identify the three primary references:

**poc = highest-volume price**  
**vah = upper boundary of value**  
**val = lower boundary of value**

### 2. locate the current price

first determine whether price is:

**above vah** — the market is trading above established visible value.

**below val** — the market is trading below established visible value.

**inside value** — price remains within the main accepted distribution.

this gives immediate auction context before looking for a trade.

### 3. study value migration

compare the developing session poc with the previous session poc.

if developing value progressively moves higher, the market is building volume at higher prices.

if it moves lower, value is developing downward.

if both pocs remain close together, the auction is comparatively balanced.

### 4. mark hvn and lvn areas

use hvns as important accepted-volume references.

use lvns to identify thin areas separating larger distributions.

instead of treating every horizontal level equally, this helps distinguish heavily traded areas from zones where the market previously showed limited participation.

### 5. check order flow

compare **net delta** and **buy share** with the position of price.

strong buying participation while value migrates higher provides different information from strong buying activity occurring while price fails to establish higher value.

the same principle applies to selling pressure.

### 6. monitor naked pocs

keep the nearest naked pocs visible.

they represent previous session points of control that have not yet been revisited.

use them as contextual reference levels rather than automatic entry signals.

### 7. isolate important structures

activate **fixed range profile** when you want to analyze one specific market segment.

for example, anchor it to a consolidation before a breakout and compare its poc, value area and volume nodes with the current market structure.

### 8. combine the information

the strongest use of volume profile desk comes from confluence rather than from one isolated metric.

for example:

**price above vah + developing poc moving higher + positive buy participation**

shows a very different auction structure from:

**price above vah + poc remaining lower + weak or negative delta**

the first shows price and value developing in the same direction, while the second shows a potential disagreement between price location, value and participation.

## 🧠 practical workflow

**structure → value → location → migration → nodes → order flow → reaction**

start by identifying the profile structure.

locate poc, vah and val.

check where current price trades relative to value.

observe whether developing value is migrating.

identify nearby hvns, lvns and naked pocs.

then use delta and buy/sell participation to evaluate the activity occurring around those locations.

volume profile desk is designed to turn raw volume distribution into a structured auction map, allowing the trader to see not only where price moved, but **where the market actually conducted business while it moved**.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6

indicator("Volume Profile Desk", shorttitle = "VP Desk", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 100)

// ─────────────────────────────── Inputs ───────────────────────────────────
const string G_PROF  = "Range profile"
const string G_SESS  = "Session profiles"
const string G_LVL   = "Naked POCs and developing levels"
const string G_FR    = "Fixed range"
const string G_FLOW  = "Order flow"
const string G_PANEL = "Desk panel"
const string G_STYLE = "Style"

string profMode   = input.string("Buy and sell", "Mode", options = ["Buy and sell", "Volume", "Delta"], group = G_PROF)
int    rowsIn     = input.int(150, "Rows", minval = 20, maxval = 150, group = G_PROF)
int    vaIn       = input.int(70, "Value area %", minval = 50, maxval = 90, group = G_PROF)
int    profWidth  = input.int(45, "Width (bars)", minval = 10, maxval = 150, group = G_PROF, inline = "w")
int    profOff    = input.int(6, "Offset", minval = 0, maxval = 100, group = G_PROF, inline = "w")
bool   showVP     = input.bool(true, "Range profile", group = G_PROF, inline = "b")
bool   showVABand = input.bool(true, "Value band", group = G_PROF, inline = "b")
bool   showNodes  = input.bool(true, "HVN / LVN", group = G_PROF, inline = "b")

bool   showSess   = input.bool(true, "Session profiles", group = G_SESS)
string sessMode   = input.string("Auto", "Session", options = ["Auto", "Custom"], group = G_SESS, inline = "s")
string sessCustom = input.timeframe("D", "", group = G_SESS, inline = "s")
int    sessCount  = input.int(6, "Sessions drawn", minval = 1, maxval = 12, group = G_SESS)

bool   showNaked  = input.bool(true, "Naked POCs", group = G_LVL, inline = "n")
int    nakedMax   = input.int(6, "Max", minval = 1, maxval = 12, group = G_LVL, inline = "n")
bool   showDev    = input.bool(true, "Developing POC / VAH / VAL", group = G_LVL)

bool   showFR     = input.bool(false, "Fixed range profile", group = G_FR)
string frMode     = input.string("Last N bars", "Anchor", options = ["Last N bars", "Time anchors"], group = G_FR)
int    frBars     = input.int(60, "Last N bars", minval = 5, maxval = 1000, group = G_FR)
int    frStart    = input.time(timestamp("01 Sep 2026 00:00 +0000"), "Start", group = G_FR, inline = "t")
int    frEnd      = input.time(timestamp("02 Sep 2026 00:00 +0000"), "End", group = G_FR, inline = "t")

string deltaSrc   = input.string("Intrabar", "Delta source", options = ["Intrabar", "Candle geometry"], group = G_FLOW)
string ltfIn      = input.string("Auto", "Intrabar timeframe", options = ["Auto", "1", "3", "5", "15", "60"], group = G_FLOW)
int    maxStore   = input.int(3000, "Bars kept in memory", minval = 500, maxval = 5000, group = G_FLOW)

bool   showPanel  = input.bool(true, "Desk panel", group = G_PANEL)
string panelPos   = input.string("Top right", "Position", options = ["Top right", "Middle right", "Bottom right", "Top left", "Bottom left"], group = G_PANEL)
bool   showRead   = input.bool(true, "Auction read", group = G_PANEL, inline = "p")
bool   showLevels = input.bool(true, "Key levels", group = G_PANEL, inline = "p")
bool   showEvents = input.bool(true, "Level events", group = G_PANEL, inline = "p")

bool   deskCandles = input.bool(true, "Desk candles", group = G_STYLE, inline = "d")
bool   showMark    = input.bool(true, "Watermark", group = G_STYLE, inline = "d")
bool   glowOn      = input.bool(true, "Glow", group = G_STYLE, inline = "d")
color  cUp   = input.color(#00FFD1, "Buy", group = G_STYLE, inline = "c1")
color  cDn   = input.color(#FF3B5C, "Sell", group = G_STYLE, inline = "c1")
color  cGold = input.color(#FFD23F, "POC", group = G_STYLE, inline = "c1")
color  cVA   = input.color(#8FA3B8, "Value", group = G_STYLE, inline = "c2")
color  cLVN  = input.color(#A08CFF, "LVN", group = G_STYLE, inline = "c2")
color  cBg   = input.color(#0A0E14, "Desk", group = G_STYLE, inline = "c2")

const color C_PANEL = #0D1219
const color C_HEAD  = #121923
const color C_NOW   = #18212D
const color C_LINE  = #1A2330
const color C_TEXT  = #D6DEE8
const color C_SOFT  = #AEBBCB
const color C_MUTED = #738396
const color C_DIM   = #435163
const color C_GRID  = #8092AA
const color C_CREAM = #FFFAE1

float vaFrac = vaIn / 100.0

// ─────────────────────────── Sessions and flow ────────────────────────────
int    tfSec    = timeframe.in_seconds()
string sessAuto = tfSec <= 60 ? "120" : tfSec <= 300 ? "480" : tfSec <= 3600 ? "D" : "W"
string sessTf   = sessMode == "Auto" ? sessAuto : sessCustom
string sessName = sessTf == "120" ? "2-hour" : sessTf == "480" ? "8-hour" : sessTf == "D" ? "daily" : sessTf == "W" ? "weekly" : sessTf
bool   newSess  = timeframe.change(sessTf)

string ltfAuto = tfSec <= 300 ? "1" : tfSec <= 3600 ? "5" : tfSec <= 14400 ? "15" : "60"
string ltf     = ltfIn == "Auto" ? ltfAuto : ltfIn
[ltfO, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, ltf, [open, close, volume], ignore_invalid_timeframe = true)

// ───────────────────────────── Storage ────────────────────────────────────
var array<int>   aI = array.new<int>()
var array<int>   aT = array.new<int>()
var array<float> aO = array.new<float>()
var array<float> aH = array.new<float>()
var array<float> aL = array.new<float>()
var array<float> aC = array.new<float>()
var array<float> aV = array.new<float>()
var array<float> aB = array.new<float>()

var array<int>   sBi = array.new<int>()
var array<int>   sT  = array.new<int>()
var array<float> cPoc   = array.new<float>()
var array<float> cVah   = array.new<float>()
var array<float> cVal   = array.new<float>()
var array<int>   cStart = array.new<int>()
var array<int>   cEnd   = array.new<int>()
var array<bool>  cNaked = array.new<bool>()

var array<string> evTime = array.new<string>()
var array<string> evMsg  = array.new<string>()
var array<color>  evCol  = array.new<color>()

var array<box>      gBoxes  = array.new<box>()
var array<line>     gLines  = array.new<line>()
var array<label>    gLabels = array.new<label>()
var array<polyline> gPolys  = array.new<polyline>()

var array<string> rA  = array.new<string>()
var array<string> rB  = array.new<string>()
var array<string> rC  = array.new<string>()
var array<color>  rCa = array.new<color>()
var array<color>  rCb = array.new<color>()
var array<color>  rCc = array.new<color>()
var array<int>    rK  = array.new<int>()

var table deskTbl = na
var table markTbl = na
var float pocTag = na
var float vahTag = na
var float valTag = na

// ───────────────────────────── Helpers ────────────────────────────────────
f_p(float x) =>
    str.tostring(x, format.mintick)

f_pct(float x) =>
    string sg = x > 0 ? "+" : ""
    sg + str.tostring(x, "0.00") + "%"

f_v(float v) =>
    float a = math.abs(v)
    string sg = v < 0 ? "-" : ""
    string out = a >= 1e9 ? sg + str.tostring(a / 1e9, "0.00") + "B" : a >= 1e6 ? sg + str.tostring(a / 1e6, "0.00") + "M" : a >= 1e3 ? sg + str.tostring(a / 1e3, a >= 1e5 ? "0" : "0.0") + "K" : sg + str.tostring(a, a < 10 ? "0.00" : "0")
    out

f_sv(float v) =>
    string sg = v > 0 ? "+" : ""
    sg + f_v(v)

f_day(int t) =>
    str.format_time(t, "MMM d", "UTC")

f_pos(string s) =>
    s == "Top right" ? position.top_right : s == "Middle right" ? position.middle_right : s == "Bottom right" ? position.bottom_right : s == "Top left" ? position.top_left : position.bottom_left

f_intrabar(array<float> ao, array<float> ac, array<float> av) =>
    float b = 0.0
    float t = 0.0
    float prevDir = 0.0
    int n = na(av) ? 0 : array.size(av)
    if n > 0
        for i = 0 to n - 1
            float vi = nz(array.get(av, i))
            float oi = array.get(ao, i)
            float ci = array.get(ac, i)
            float d = ci > oi ? 1.0 : ci < oi ? -1.0 : prevDir
            if d > 0
                b := b + vi
            else if d == 0
                b := b + vi * 0.5
            prevDir := d
            t := t + vi
    [b, t]

// Distributes one stored bar across price rows: overlap weighted, peaked on the body
f_addBar(array<float> vol, array<float> buy, array<float> wt, int i, float lo, float step, int n) =>
    float bh  = array.get(aH, i)
    float bl  = array.get(aL, i)
    float bo  = array.get(aO, i)
    float bc  = array.get(aC, i)
    float bvv = array.get(aV, i)
    float bbv = array.get(aB, i)
    float rng = bh - bl
    if bvv > 0
        float bf  = bbv / bvv
        float dir = bc > bo ? 1.0 : bc < bo ? -1.0 : 0.0
        if rng <= 0
            int k = int(math.max(0, math.min(n - 1, math.floor((bc - lo) / step))))
            array.set(vol, k, array.get(vol, k) + bvv)
            array.set(buy, k, array.get(buy, k) + bbv)
        else
            int k0 = int(math.max(0, math.min(n - 1, math.floor((bl - lo) / step))))
            int k1 = int(math.max(0, math.min(n - 1, math.floor((bh - lo) / step))))
            float mid = (bo + bc) / 2.0
            float sg  = rng / 2.6
            float ws  = 0.0
            for k = k0 to k1
                float a  = math.max(bl, lo + k * step)
                float z  = math.min(bh, lo + (k + 1) * step)
                float ov = z - a
                float wv = 0.0
                if ov > 0
                    float d = ((a + z) / 2.0 - mid) / sg
                    wv := ov * (0.4 + 0.6 * math.exp(-0.5 * d * d))
                array.set(wt, k, wv)
                ws := ws + wv
            if ws > 0
                for k = k0 to k1
                    float w2 = array.get(wt, k)
                    if w2 > 0
                        float v   = bvv * w2 / ws
                        float pos = (lo + (k + 0.5) * step - bl) / rng
                        float q   = math.max(0.02, math.min(0.98, bf + 0.18 * (pos - 0.5) * dir))
                        array.set(vol, k, array.get(vol, k) + v)
                        array.set(buy, k, array.get(buy, k) + v * q)
            else
                array.set(vol, k0, array.get(vol, k0) + bvv)
                array.set(buy, k0, array.get(buy, k0) + bbv)
    true

// CBOT value area: expand from POC toward the heavier neighbour
f_va(array<float> vol, int n, float frac) =>
    float total = 0.0
    float mx    = -1.0
    int   poc   = 0
    for k = 0 to n - 1
        float v = array.get(vol, k)
        total := total + v
        if v > mx
            mx  := v
            poc := k
    int   a    = poc
    int   b    = poc
    float acc  = array.get(vol, poc)
    float tgt  = total * frac
    bool  done = false
    for s = 0 to n
        if not done
            if acc >= tgt or (a <= 0 and b >= n - 1)
                done := true
            else
                float up = b < n - 1 ? array.get(vol, b + 1) : -1.0
                float dn = a > 0 ? array.get(vol, a - 1) : -1.0
                if up >= dn
                    b   := b + 1
                    acc := acc + array.get(vol, b)
                else
                    a   := a - 1
                    acc := acc + array.get(vol, a)
    [poc, a, b, total, mx]

f_profile(int i0, int i1, int nRows, float frac) =>
    float lo = na
    float hi = na
    if i1 >= i0 and i0 >= 0
        for i = i0 to i1
            float h = array.get(aH, i)
            float l = array.get(aL, i)
            lo := na(lo) ? l : math.min(lo, l)
            hi := na(hi) ? h : math.max(hi, h)
    array<float> vol = array.new<float>(nRows, 0.0)
    array<float> buy = array.new<float>(nRows, 0.0)
    array<float> wt  = array.new<float>(nRows, 0.0)
    bool  ok   = not na(lo) and hi > lo
    float step = ok ? (hi - lo) / nRows : 1.0
    if ok
        for i = i0 to i1
            f_addBar(vol, buy, wt, i, lo, step, nRows)
    [poc, a, b, total, mx] = f_va(vol, nRows, frac)
    [vol, buy, nz(lo), step, poc, a, b, total, mx, ok]

f_sumArr(array<float> x) =>
    float s = 0.0
    int n = array.size(x)
    if n > 0
        for i = 0 to n - 1
            s := s + array.get(x, i)
    s

f_maxAbsD(array<float> vol, array<float> buy, int n) =>
    float m = 0.0
    for k = 0 to n - 1
        m := math.max(m, math.abs(2 * array.get(buy, k) - array.get(vol, k)))
    math.max(m, 1e-10)

// HVN, LVN and profile shape
f_nodes(array<float> vol, int n, int poc) =>
    array<float> s = array.new<float>(n, 0.0)
    float smax = 0.0
    for k = 0 to n - 1
        float acc = 0.0
        int   c   = 0
        for j = k - 2 to k + 2
            if j >= 0 and j < n
                acc := acc + array.get(vol, j)
                c   := c + 1
        float sv = acc / c
        array.set(s, k, sv)
        smax := math.max(smax, sv)
    int kmin = -1
    int kmax = -1
    for k = 0 to n - 1
        if array.get(vol, k) > 0
            if kmin < 0
                kmin := k
            kmax := k
    if kmin < 0
        kmin := 0
        kmax := n - 1
    int w = int(math.max(3, math.round(n / 22.0)))
    array<int>   hvK = array.new<int>()
    array<float> hvS = array.new<float>()
    array<int>   lvK = array.new<int>()
    array<float> lvS = array.new<float>()
    for k = kmin to kmax
        bool isMax = true
        bool isMin = true
        float sk = array.get(s, k)
        for j = k - w to k + w
            if j != k and j >= 0 and j < n
                float sj = array.get(s, j)
                if sj > sk or (sj == sk and j < k)
                    isMax := false
                if sj < sk or (sj == sk and j < k)
                    isMin := false
        if isMax and sk >= 0.42 * smax
            array.push(hvK, k)
            array.push(hvS, sk)
        if isMin and sk <= 0.4 * smax and k - kmin >= w and kmax - k >= w
            array.push(lvK, k)
            array.push(lvS, sk)
    array<int> hOrd = array.sort_indices(hvS, order.descending)
    array<int> lOrd = array.sort_indices(lvS, order.ascending)
    array<int> outH = array.new<int>()
    array<int> outL = array.new<int>()
    int nh = int(math.min(4, array.size(hOrd)))
    int nl = int(math.min(4, array.size(lOrd)))
    if nh > 0
        for j = 0 to nh - 1
            int oi = array.get(hOrd, j)
            array.push(outH, array.get(hvK, oi))
    if nl > 0
        for j = 0 to nl - 1
            int oi2 = array.get(lOrd, j)
            array.push(outL, array.get(lvK, oi2))
    float span = math.max(1, kmax - kmin)
    float pos  = (poc - kmin) / span
    string shape = "D"
    string desc  = "Balanced, two-sided trade around a central POC"
    if array.size(hOrd) >= 2
        int o0 = array.get(hOrd, 0)
        int o1 = array.get(hOrd, 1)
        int k0 = array.get(hvK, o0)
        int k1 = array.get(hvK, o1)
        float s0 = array.get(hvS, o0)
        float s1 = array.get(hvS, o1)
        if s1 >= 0.7 * s0 and math.abs(k0 - k1) >= n * 0.18
            int lo_ = int(math.min(k0, k1))
            int hi_ = int(math.max(k0, k1))
            bool gapFound = false
            int nlv = array.size(lvK)
            if nlv > 0
                for j = 0 to nlv - 1
                    int kl = array.get(lvK, j)
                    if kl > lo_ and kl < hi_
                        gapFound := true
            if gapFound
                shape := "B"
                desc  := "Double distribution: two value zones split by a low-volume gap"
    if shape == "D"
        if pos > 0.64
            shape := "P"
            desc  := "Volume built at the highs: short covering or initiative buying"
        else if pos < 0.36
            shape := "b"
            desc  := "Volume built at the lows: long liquidation or initiative selling"
    [outH, outL, shape, desc]

// ─────────────────────────── Drawing helpers ──────────────────────────────
f_clearAll() =>
    int nb = array.size(gBoxes)
    if nb > 0
        for i = 0 to nb - 1
            box.delete(array.get(gBoxes, i))
    array.clear(gBoxes)
    int nl = array.size(gLines)
    if nl > 0
        for i = 0 to nl - 1
            line.delete(array.get(gLines, i))
    array.clear(gLines)
    int nlb = array.size(gLabels)
    if nlb > 0
        for i = 0 to nlb - 1
            label.delete(array.get(gLabels, i))
    array.clear(gLabels)
    int np = array.size(gPolys)
    if np > 0
        for i = 0 to np - 1
            polyline.delete(array.get(gPolys, i))
    array.clear(gPolys)
    true

f_box(int l, float t, int r, float b, color bg) =>
    box bx = box.new(l, t, r, b, border_color = color(na), border_width = 0, bgcolor = bg)
    array.push(gBoxes, bx)
    bx

f_line(int x1, float y1, int x2, float y2, color col, int w, string st) =>
    line ln = line.new(x1, y1, x2, y2, color = col, width = w, style = st)
    array.push(gLines, ln)
    ln

f_label(int x, float y, string txt, color tc, color bg, string st) =>
    label lb = label.new(x, y, txt, color = bg, textcolor = tc, style = st, size = size.tiny, text_font_family = font.family_monospace)
    array.push(gLabels, lb)
    lb

// Layered glow: outer aura, halo, beam, core
f_glow(int x1, float y1, int x2, float y2, color col, string st, float k) =>
    if glowOn
        f_line(x1, y1, x2, y2, color.new(col, 100 - 10 * k), 9, st)
        f_line(x1, y1, x2, y2, color.new(col, 100 - 22 * k), 6, st)
        f_line(x1, y1, x2, y2, color.new(col, 100 - 50 * k), 3, st)
    f_line(x1, y1, x2, y2, col, 1, st)
    true

f_poly(array<chart.point> pts, color lc, color fc, int w, string st, bool closed) =>
    polyline pl = polyline.new(pts, curved = false, closed = closed, xloc = xloc.bar_index, line_color = lc, fill_color = fc, line_style = st, line_width = w)
    array.push(gPolys, pl)
    pl

f_tr(float alpha) =>
    100.0 - 100.0 * math.max(0.0, math.min(1.0, alpha))

// Profile rows as boxes. grow = -1 grows left from x0, +1 grows right
f_drawRows(array<float> vol, array<float> buy, float lo, float step, int n, int vaA, int vaB, float mx, float mad, int x0, int maxLen, int grow, string md, float aIn, float aOut) =>
    float gap = step * 0.09
    for k = 0 to n - 1
        float v = array.get(vol, k)
        if v > 0 and mx > 0
            float top = lo + (k + 1) * step - gap
            float bot = lo + k * step + gap
            bool  inV = k >= vaA and k <= vaB
            float a   = inV ? aIn : aOut
            if md == "Volume"
                float r   = v / mx
                int   len = int(math.round(r * maxLen))
                if len > 0
                    int l1 = grow > 0 ? x0 : x0 - len
                    int r1 = grow > 0 ? x0 + len : x0
                    f_box(l1, top, r1, bot, color.new(cUp, f_tr(a * (0.25 + 0.6 * r))))
            else if md == "Delta"
                float d    = 2 * array.get(buy, k) - v
                int   half = int(math.round(maxLen / 2.0))
                int   xc   = x0 + grow * half
                int   len  = int(math.round(math.abs(d) / mad * half))
                if len > 0
                    if d >= 0
                        f_box(xc, top, xc + len, bot, color.new(cUp, f_tr(a * 0.8)))
                    else
                        f_box(xc - len, top, xc, bot, color.new(cDn, f_tr(a * 0.8)))
            else
                int len = int(math.round(v / mx * maxLen))
                int bl  = int(math.round(len * array.get(buy, k) / v))
                int sl  = len - bl
                if bl > 0
                    int l2 = grow > 0 ? x0 : x0 - bl
                    int r2 = grow > 0 ? x0 + bl : x0
                    f_box(l2, top, r2, bot, color.new(cUp, f_tr(a * 0.62)))
                if sl > 0
                    int l3 = grow > 0 ? x0 + bl : x0 - len
                    int r3 = grow > 0 ? x0 + len : x0 - bl
                    f_box(l3, top, r3, bot, color.new(cDn, f_tr(a * 0.62)))
    true

f_pocRow(float lo, float step, int poc, float v, float mx, int x0, int maxLen, int grow, string md) =>
    int   len = md == "Delta" ? maxLen : int(math.round(v / mx * maxLen))
    float top = lo + (poc + 1) * step
    float bot = lo + poc * step
    int   l1  = grow > 0 ? x0 : x0 - len
    int   r1  = grow > 0 ? x0 + len : x0
    if glowOn
        f_box(l1 - grow, top + step * 0.45, r1 + grow, bot - step * 0.45, color.new(cGold, 84))
    f_box(l1, top - step * 0.05, r1, bot + step * 0.05, color.new(cGold, 10))
    int hl = int(math.round(len * 0.92))
    int l2 = grow > 0 ? x0 : x0 - hl
    int r2 = grow > 0 ? x0 + hl : x0
    f_line(l2, (top + bot) / 2.0, r2, (top + bot) / 2.0, color.new(C_CREAM, 40), 1, line.style_solid)
    true

f_event(string msg, color col) =>
    array.unshift(evTime, str.format_time(time_close, "HH:mm", "UTC"))
    array.unshift(evMsg, msg)
    array.unshift(evCol, col)
    if array.size(evMsg) > 5
        array.pop(evTime)
        array.pop(evMsg)
        array.pop(evCol)
    true

f_cross(float prev, float cur, float lvl, string name) =>
    if not na(lvl) and (prev - lvl) * (cur - lvl) < 0
        bool up = cur > lvl
        string msg = "Crossed " + (up ? "above " : "below ") + name + " " + f_p(lvl)
        f_event(msg, up ? cUp : cDn)
        alert(syminfo.ticker + ": " + msg, alert.freq_once_per_bar_close)
    true

f_row(string a, string b, string c, color ca, color cb, color cc, int k) =>
    array.push(rA, a)
    array.push(rB, b)
    array.push(rC, c)
    array.push(rCa, ca)
    array.push(rCb, cb)
    array.push(rCc, cc)
    array.push(rK, k)
    true

f_statRows(float pocP, float vah, float val, float tot, float buyT, string shape, string desc, float px) =>
    float dlt = 2 * buyT - tot
    float bs  = tot > 0 ? buyT / tot : 0.5
    string loc = px > vah ? "Above value" : px < val ? "Below value" : "Inside value"
    color  lc  = px > vah ? cUp : px < val ? cDn : C_TEXT
    int    nb  = int(math.round(bs * 10))
    string meter = str.repeat("▰", nb) + str.repeat("▱", 10 - nb)
    f_row("Point of control", f_p(pocP), f_pct((px - pocP) / pocP * 100), C_MUTED, cGold, C_MUTED, 0)
    f_row("Value area high", f_p(vah), "", C_MUTED, C_TEXT, C_MUTED, 0)
    f_row("Value area low", f_p(val), "", C_MUTED, C_TEXT, C_MUTED, 0)
    f_row("Value width", str.tostring((vah - val) / pocP * 100, "0.00") + "%", "", C_MUTED, C_TEXT, C_MUTED, 0)
    f_row("Price location", loc, "", C_MUTED, lc, C_MUTED, 0)
    f_row("Volume", f_v(tot), "", C_MUTED, C_TEXT, C_MUTED, 0)
    f_row("Net delta", f_sv(dlt), "", C_MUTED, dlt >= 0 ? cUp : cDn, C_MUTED, 0)
    f_row("Buy share", str.tostring(bs * 100, "0.0") + "%", meter, C_MUTED, C_TEXT, bs >= 0.5 ? cUp : cDn, 0)
    f_row("Profile shape", shape, "", C_MUTED, C_TEXT, C_MUTED, 0)
    f_row(desc, "", "", C_MUTED, C_MUTED, C_MUTED, 2)
    true

// ───────────────────────── Per-bar computation ────────────────────────────
[ibBuy, ibTot] = f_intrabar(ltfO, ltfC, ltfV)
float geoFrac = high > low ? (close - low) / (high - low) : 0.5
float buyFrac = deltaSrc == "Intrabar" and ibTot > 0 ? ibBuy / ibTot : geoFrac
float vol0    = nz(volume)
float bv0     = vol0 * buyFrac

array.push(aI, bar_index)
array.push(aT, time)
array.push(aO, open)
array.push(aH, high)
array.push(aL, low)
array.push(aC, close)
array.push(aV, vol0)
array.push(aB, bv0)
if array.size(aI) > maxStore
    array.shift(aI)
    array.shift(aT)
    array.shift(aO)
    array.shift(aH)
    array.shift(aL)
    array.shift(aC)
    array.shift(aV)
    array.shift(aB)

// Session rollover: freeze the finished session's POC / VAH / VAL
if newSess or array.size(sBi) == 0
    int nS = array.size(sBi)
    if nS > 0
        int base0 = array.get(aI, 0)
        int ps    = array.get(sBi, nS - 1)
        int i0f   = int(math.max(0, ps - base0))
        int i1f   = bar_index - 1 - base0
        if i1f >= i0f
            [fVol, fBuy, fLo, fStep, fPoc, fA, fB, fTot, fMx, fOk] = f_profile(i0f, i1f, 48, vaFrac)
            if fOk
                array.push(cPoc, fLo + (fPoc + 0.5) * fStep)
                array.push(cVah, fLo + (fB + 1) * fStep)
                array.push(cVal, fLo + fA * fStep)
                array.push(cStart, array.get(sT, nS - 1))
                array.push(cEnd, bar_index - 1)
                array.push(cNaked, true)
                if array.size(cPoc) > 60
                    array.shift(cPoc)
                    array.shift(cVah)
                    array.shift(cVal)
                    array.shift(cStart)
                    array.shift(cEnd)
                    array.shift(cNaked)
    array.push(sBi, bar_index)
    array.push(sT, time)
    if array.size(sBi) > 80
        array.shift(sBi)
        array.shift(sT)

// Naked POC fills
int nC = array.size(cPoc)
if nC > 0
    for j = 0 to nC - 1
        bool isN  = array.get(cNaked, j)
        int  endB = array.get(cEnd, j)
        if isN and bar_index > endB
            float pp = array.get(cPoc, j)
            if low <= pp and high >= pp
                array.set(cNaked, j, false)
                if barstate.isconfirmed
                    string fmsg = "Naked POC from " + f_day(array.get(cStart, j)) + " filled at " + f_p(pp)
                    f_event(fmsg, cGold)
                    alert(syminfo.ticker + ": " + fmsg, alert.freq_once_per_bar_close)

// Prior session level crosses (confirmed bars only, non-repainting)
float prevClose = close[1]
if barstate.isconfirmed and nC > 0 and bar_index > 0
    f_cross(prevClose, close, array.get(cPoc, nC - 1), "prior session POC")
    f_cross(prevClose, close, array.get(cVah, nC - 1), "prior session VAH")
    f_cross(prevClose, close, array.get(cVal, nC - 1), "prior session VAL")

// ─────────────────────────────── Candles ──────────────────────────────────
bool  upBar = close >= open
color bodyC = upBar ? color.new(cUp, 18) : color.new(cDn, 14)
color wickC = upBar ? color.new(cUp, 25) : color.new(cDn, 25)
plotcandle(deskCandles ? open : na, deskCandles ? high : na, deskCandles ? low : na, deskCandles ? close : na, "Desk candles", color = bodyC, wickcolor = wickC, bordercolor = bodyC, display = display.pane)

// ───────────────────────────── Redraw ─────────────────────────────────────
if barstate.islast
    f_clearAll()
    array.clear(rA)
    array.clear(rB)
    array.clear(rC)
    array.clear(rCa)
    array.clear(rCb)
    array.clear(rCc)
    array.clear(rK)

    int   n      = array.size(aT)
    int   base   = array.get(aI, 0)
    float px     = close
    int   xRight = bar_index + profOff + profWidth
    int   xb     = xRight - profWidth - 2

    // Visible range indices
    int leftT  = chart.left_visible_bar_time
    int rightT = chart.right_visible_bar_time
    int vi0 = -1
    int vi1 = -1
    for i = 0 to n - 1
        int ti = array.get(aT, i)
        if ti >= leftT and ti <= rightT
            if vi0 < 0
                vi0 := i
            vi1 := i
    if vi0 < 0
        vi0 := int(math.max(0, n - 150))
        vi1 := n - 1
    int leftBi = array.get(aI, vi0)

    [vVol, vBuy, vLo, vStep, vPoc, vA, vB, vTot, vMx, vOk] = f_profile(vi0, vi1, rowsIn, vaFrac)
    float vPocP = vLo + (vPoc + 0.5) * vStep
    float vVah  = vLo + (vB + 1) * vStep
    float vVal  = vLo + vA * vStep
    float vBuyT = f_sumArr(vBuy)
    [hvK, lvK, vShape, vDesc] = f_nodes(vVol, rowsIn, vPoc)

    // Session profiles
    int nSess = array.size(sBi)
    if showSess and nSess > 0
        int cnt = int(math.min(sessCount, nSess))
        for j = 0 to cnt - 1
            int sIdx  = nSess - cnt + j
            int sb0   = array.get(sBi, sIdx)
            int sb1   = sIdx < nSess - 1 ? array.get(sBi, sIdx + 1) - 1 : bar_index
            int si0   = int(math.max(0, sb0 - base))
            int si1   = sb1 - base
            if si1 >= si0 and si1 >= 0
                [sVol, sBuy, sLo, sStep, sPoc, sA, sB, sTot, sMx, sOk] = f_profile(si0, si1, 48, vaFrac)
                int x0s = array.get(aI, si0)
                int x1s = array.get(aI, si1)
                float sHi = sLo + 48 * sStep
                int sw = x1s - x0s + 1
                if sOk
                    f_line(x0s, sLo, x0s, sHi, color.new(C_GRID, 80), 1, line.style_dotted)
                    f_label(x0s + 2, sLo, sessTf == "D" or sessTf == "W" ? f_day(array.get(sT, sIdx)) : f_day(array.get(sT, sIdx)) + " " + str.format_time(array.get(sT, sIdx), "HH:mm", "UTC"), C_DIM, color.new(cBg, 100), label.style_label_up)
                if sOk and sw >= 8 and sMx > 0
                    int mL = int(math.round(sw * 0.55))
                    array<chart.point> ptsAll = array.new<chart.point>()
                    array<chart.point> ptsVA  = array.new<chart.point>()
                    array.push(ptsAll, chart.point.from_index(x0s, sLo))
                    array.push(ptsVA, chart.point.from_index(x0s, sLo + sA * sStep))
                    for k = 0 to 47
                        int xl = x0s + int(math.round(array.get(sVol, k) / sMx * mL))
                        array.push(ptsAll, chart.point.from_index(xl, sLo + k * sStep))
                        array.push(ptsAll, chart.point.from_index(xl, sLo + (k + 1) * sStep))
                        if k >= sA and k <= sB
                            array.push(ptsVA, chart.point.from_index(xl, sLo + k * sStep))
                            array.push(ptsVA, chart.point.from_index(xl, sLo + (k + 1) * sStep))
                    array.push(ptsAll, chart.point.from_index(x0s, sHi))
                    array.push(ptsVA, chart.point.from_index(x0s, sLo + (sB + 1) * sStep))
                    f_poly(ptsAll, color.new(cVA, 100), color.new(cVA, 92), 1, line.style_solid, true)
                    f_poly(ptsVA, color.new(cVA, 100), color.new(cVA, 86), 1, line.style_solid, true)
                    float sPocP = sLo + (sPoc + 0.5) * sStep
                    f_line(x0s, sPocP, x1s, sPocP, color.new(cGold, 45), 1, line.style_solid)
                    f_line(x0s, sLo + (sB + 1) * sStep, x1s, sLo + (sB + 1) * sStep, color.new(cVA, 72), 1, line.style_dashed)
                    f_line(x0s, sLo + sA * sStep, x1s, sLo + sA * sStep, color.new(cVA, 72), 1, line.style_dashed)

    // Naked POCs, nearest to price first
    int nakedDrawn = 0
    array<float> nkDist = array.new<float>()
    array<int>   nkIdx  = array.new<int>()
    if nC > 0
        for j = 0 to nC - 1
            if array.get(cNaked, j)
                array.push(nkDist, math.abs(array.get(cPoc, j) - px))
                array.push(nkIdx, j)
    array<int> nkOrd = array.sort_indices(nkDist, order.ascending)
    int nNk = int(math.min(nakedMax, array.size(nkOrd)))
    if showNaked and nNk > 0
        for j = 0 to nNk - 1
            int oj  = array.get(nkOrd, j)
            int cj  = array.get(nkIdx, oj)
            float np = array.get(cPoc, cj)
            int  nx  = array.get(cEnd, cj) + 1
            f_glow(nx, np, xRight, np, cGold, line.style_dashed, 0.45)
            f_label(nx, np, "nPOC " + f_day(array.get(cStart, cj)), cGold, color.new(cBg, 8), label.style_label_left)
            nakedDrawn := nakedDrawn + 1

    // Developing POC / VAH / VAL for the running session
    float devPoc = na
    if nSess > 0
        int di0 = int(math.max(0, array.get(sBi, nSess - 1) - base))
        float dLo = na
        float dHi = na
        for i = di0 to n - 1
            dLo := na(dLo) ? array.get(aL, i) : math.min(dLo, array.get(aL, i))
            dHi := na(dHi) ? array.get(aH, i) : math.max(dHi, array.get(aH, i))
        if dHi > dLo
            float dStep = (dHi - dLo) / 64.0
            array<float> dVol = array.new<float>(64, 0.0)
            array<float> dBuy = array.new<float>(64, 0.0)
            array<float> dWt  = array.new<float>(64, 0.0)
            array<chart.point> pP = array.new<chart.point>()
            array<chart.point> pH = array.new<chart.point>()
            array<chart.point> pL = array.new<chart.point>()
            for i = di0 to n - 1
                f_addBar(dVol, dBuy, dWt, i, dLo, dStep, 64)
                [dp, da, db, dt, dm] = f_va(dVol, 64, vaFrac)
                int bi = array.get(aI, i)
                float yP = dLo + (dp + 0.5) * dStep
                float yH = dLo + (db + 1) * dStep
                float yL = dLo + da * dStep
                array.push(pP, chart.point.from_index(bi, yP))
                array.push(pP, chart.point.from_index(bi + 1, yP))
                array.push(pH, chart.point.from_index(bi, yH))
                array.push(pH, chart.point.from_index(bi + 1, yH))
                array.push(pL, chart.point.from_index(bi, yL))
                array.push(pL, chart.point.from_index(bi + 1, yL))
                devPoc := yP
            if showDev
                f_poly(pH, color.new(cUp, 50), color(na), 1, line.style_dotted, false)
                f_poly(pL, color.new(cUp, 50), color(na), 1, line.style_dotted, false)
                if glowOn
                    f_poly(pP, color.new(cGold, 82), color(na), 5, line.style_solid, false)
                    f_poly(pP, color.new(cGold, 62), color(na), 3, line.style_solid, false)
                f_poly(pP, color.new(cGold, 12), color(na), 1, line.style_solid, false)

    // Fixed range profile
    float frPocP = na
    float frVahP = na
    float frValP = na
    float frTotV = na
    float frBuyV = na
    string frShape = ""
    string frDesc  = ""
    int fr0 = -1
    int fr1 = -1
    if showFR
        if frMode == "Last N bars"
            fr1 := n - 1
            fr0 := int(math.max(0, n - frBars))
        else
            for i = 0 to n - 1
                int tf_ = array.get(aT, i)
                if tf_ >= frStart and tf_ <= frEnd
                    if fr0 < 0
                        fr0 := i
                    fr1 := i
        if fr0 >= 0 and fr1 - fr0 >= 2
            int frRows = int(math.min(rowsIn, 48))
            [fVol2, fBuy2, fLo2, fSt2, fPoc2, fA2, fB2, fTot2, fMx2, fOk2] = f_profile(fr0, fr1, frRows, vaFrac)
            if fOk2
                int fx0 = array.get(aI, fr0)
                int fx1 = array.get(aI, fr1)
                float fHi2 = fLo2 + frRows * fSt2
                box frb = box.new(fx0, fHi2, fx1, fLo2, border_color = color.new(cUp, 55), border_width = 1, border_style = line.style_dashed, bgcolor = color.new(cUp, 97))
                array.push(gBoxes, frb)
                f_label(fx0, fLo2, "Fixed range  " + str.tostring(fr1 - fr0 + 1) + " bars", cUp, color.new(cBg, 100), label.style_label_upper_left)
                f_box(fx0, fLo2 + (fB2 + 1) * fSt2, fx1, fLo2 + fA2 * fSt2, color.new(cUp, 96))
                int fMax = int(math.max(3, math.min((fx1 - fx0) * 0.72, 60)))
                f_drawRows(fVol2, fBuy2, fLo2, fSt2, frRows, fA2, fB2, fMx2, f_maxAbsD(fVol2, fBuy2, frRows), fx0, fMax, 1, profMode, 0.95, 0.38)
                f_pocRow(fLo2, fSt2, fPoc2, array.get(fVol2, fPoc2), fMx2, fx0, fMax, 1, profMode)
                frPocP := fLo2 + (fPoc2 + 0.5) * fSt2
                frVahP := fLo2 + (fB2 + 1) * fSt2
                frValP := fLo2 + fA2 * fSt2
                frTotV := fTot2
                frBuyV := f_sumArr(fBuy2)
                [fh_, fl_, fs_, fd_] = f_nodes(fVol2, frRows, fPoc2)
                frShape := fs_
                frDesc  := fd_
                f_glow(fx0, frPocP, xRight, frPocP, cGold, line.style_solid, 0.6)
                f_line(fx0, frVahP, fx1, frVahP, color.new(cUp, 40), 1, line.style_dashed)
                f_line(fx0, frValP, fx1, frValP, color.new(cUp, 40), 1, line.style_dashed)

    // Visible range profile
    if showVP and vOk
        if showVABand
            f_box(leftBi, vVah, xRight, vVal, color.new(cUp, 97))
        f_line(leftBi, vVah, xb, vVah, color.new(cVA, 45), 1, line.style_dashed)
        f_line(leftBi, vVal, xb, vVal, color.new(cVA, 45), 1, line.style_dashed)
        f_glow(leftBi, vPocP, xRight, vPocP, cGold, line.style_solid, 0.8)
        float vHi = vLo + rowsIn * vStep
        f_box(xb - 4, vHi, xb + int(profWidth * 0.3), vLo, color.new(cBg, 62))
        f_box(xb + int(profWidth * 0.3), vHi, xRight + 1, vLo, color.new(cBg, 30))
        f_drawRows(vVol, vBuy, vLo, vStep, rowsIn, vA, vB, vMx, f_maxAbsD(vVol, vBuy, rowsIn), xRight, profWidth, -1, profMode, 1.0, 0.4)
        f_pocRow(vLo, vStep, vPoc, array.get(vVol, vPoc), vMx, xRight, profWidth, -1, profMode)
        if profMode == "Delta"
            int xc = xRight - int(math.round(profWidth / 2.0))
            f_line(xc, vLo, xc, vHi, color.new(C_MUTED, 60), 1, line.style_solid)
        // Value area bracket
        f_line(xb, vVah, xb, vVal, color.new(cVA, 40), 1, line.style_solid)
        f_line(xb, vVah, xb + 2, vVah, color.new(cVA, 40), 1, line.style_solid)
        f_line(xb, vVal, xb + 2, vVal, color.new(cVA, 40), 1, line.style_solid)
        if showNodes
            int nhv = array.size(hvK)
            if nhv > 0
                for j = 0 to nhv - 1
                    float hp = vLo + (array.get(hvK, j) + 0.5) * vStep
                    f_label(xb - 2, hp, "HVN ◆", cUp, color.new(cBg, 100), label.style_label_right)
            int nlv = array.size(lvK)
            if nlv > 0
                for j = 0 to nlv - 1
                    float lp = vLo + (array.get(lvK, j) + 0.5) * vStep
                    f_label(xb - 2, lp, "LVN ◇", cLVN, color.new(cBg, 100), label.style_label_right)
                    f_line(leftBi, lp, xb - 12, lp, color.new(cLVN, 72), 1, line.style_dotted)
        pocTag := vPocP
        vahTag := vVah
        valTag := vVal
    else
        pocTag := na
        vahTag := na
        valTag := na

    // Last price line
    f_line(bar_index - 1, px, bar_index, px, color.new(upBar ? cUp : cDn, 20), 1, line.style_dotted).set_extend(extend.both)

    // Watermark
    if showMark
        if na(markTbl)
            markTbl := table.new(position.middle_center, 1, 2)
        table.cell(markTbl, 0, 0, syminfo.basecurrency + "/" + syminfo.currency, text_color = color.new(C_TEXT, 96), text_size = size.huge, text_formatting = text.format_bold)
        table.cell(markTbl, 0, 1, "Wizard Alpha  " + timeframe.period + "  " + syminfo.type, text_color = color.new(C_TEXT, 95), text_size = size.normal)

    // ───────────────────────── Desk panel ─────────────────────────
    if showPanel and vOk
        f_row("Visible range profile", "", "", C_TEXT, C_TEXT, C_TEXT, 1)
        f_row(str.tostring(vi1 - vi0 + 1) + " bars, " + str.tostring(rowsIn) + " rows, " + str.tostring(vaIn) + "% value area", "", "", C_MUTED, C_MUTED, C_MUTED, 2)
        f_statRows(vPocP, vVah, vVal, vTot, vBuyT, vShape, vDesc, px)

        if showFR and not na(frPocP)
            f_row("Fixed range profile", "", "", C_TEXT, C_TEXT, C_TEXT, 1)
            f_row(str.tostring(fr1 - fr0 + 1) + " bars from " + f_day(array.get(aT, fr0)) + " " + str.format_time(array.get(aT, fr0), "HH:mm", "UTC") + " to " + f_day(array.get(aT, fr1)) + " " + str.format_time(array.get(aT, fr1), "HH:mm", "UTC") + " UTC", "", "", C_MUTED, C_MUTED, C_MUTED, 2)
            f_statRows(frPocP, frVahP, frValP, frTotV, frBuyV, frShape, frDesc, px)

        if showRead
            f_row("Auction read", "", "", C_TEXT, C_TEXT, C_TEXT, 1)
            if px > vVah
                f_row("▎ Trading above visible value (" + f_p(vVah) + ").\n   Holding above VAH signals acceptance higher.", "", "", cUp, C_TEXT, C_TEXT, 3)
            else if px < vVal
                f_row("▎ Trading below visible value (" + f_p(vVal) + ").\n   Holding below VAL signals acceptance lower.", "", "", cDn, C_TEXT, C_TEXT, 3)
            else
                f_row("▎ Inside visible value, " + f_pct((px - vPocP) / vPocP * 100) + " from POC.\n   Edges " + f_p(vVal) + " / " + f_p(vVah) + " frame responsive trade.", "", "", C_SOFT, C_TEXT, C_TEXT, 3)
            if not na(devPoc) and nC > 0
                float pp0 = array.get(cPoc, nC - 1)
                float mg  = (devPoc - pp0) / pp0 * 100
                if math.abs(mg) < 0.05
                    f_row("▎ Developing " + sessName + " POC overlaps prior POC " + f_p(pp0) + ".\n   Value is not migrating: balance.", "", "", cGold, C_TEXT, C_TEXT, 3)
                else
                    f_row("▎ Developing " + sessName + " POC migrating " + (mg > 0 ? "higher" : "lower") + ",\n   " + f_pct(mg) + " vs prior session POC " + f_p(pp0) + ".", "", "", mg > 0 ? cUp : cDn, C_TEXT, C_TEXT, 3)
            float bsv = vTot > 0 ? vBuyT / vTot : 0.5
            if bsv > 0.52
                f_row("▎ Aggressive buyers lead the range, " + str.tostring(bsv * 100, "0.0") + "% buy share.", "", "", cUp, C_TEXT, C_TEXT, 3)
            else if bsv < 0.48
                f_row("▎ Aggressive sellers lead the range, " + str.tostring((1 - bsv) * 100, "0.0") + "% sell share.", "", "", cDn, C_TEXT, C_TEXT, 3)
            else
                f_row("▎ Aggressor flow is balanced (" + str.tostring(bsv * 100, "0.0") + "% buy).", "", "", C_SOFT, C_TEXT, C_TEXT, 3)
            int nlv2 = array.size(lvK)
            if nlv2 > 0
                float best = na
                for j = 0 to nlv2 - 1
                    float lp2 = vLo + (array.get(lvK, j) + 0.5) * vStep
                    if na(best) or math.abs(lp2 - px) < math.abs(best - px)
                        best := lp2
                f_row("▎ Nearest low-volume node " + f_p(best) + " (" + f_pct((best - px) / px * 100) + ").\n   Price tends to move fast through thin areas.", "", "", cGold, C_TEXT, C_TEXT, 3)
            if array.size(nkOrd) > 0
                int o0n = array.get(nkOrd, 0)
                int c0n = array.get(nkIdx, o0n)
                float np0 = array.get(cPoc, c0n)
                f_row("▎ Closest untested POC " + f_p(np0) + " from " + f_day(array.get(cStart, c0n)) + ",\n   " + f_pct((np0 - px) / px * 100) + " away.", "", "", cGold, C_TEXT, C_TEXT, 3)

        if showLevels
            f_row("Key levels", "", "", C_TEXT, C_TEXT, C_TEXT, 1)
            array<string> lvN = array.new<string>()
            array<float>  lvP = array.new<float>()
            array<color>  lvC = array.new<color>()
            array.push(lvN, "■ Visible POC")
            array.push(lvP, vPocP)
            array.push(lvC, cGold)
            array.push(lvN, "■ Visible VAH")
            array.push(lvP, vVah)
            array.push(lvC, cVA)
            array.push(lvN, "■ Visible VAL")
            array.push(lvP, vVal)
            array.push(lvC, cVA)
            if showNodes
                int nh3 = array.size(hvK)
                if nh3 > 0
                    for j = 0 to nh3 - 1
                        array.push(lvN, "■ High-volume node")
                        array.push(lvP, vLo + (array.get(hvK, j) + 0.5) * vStep)
                        array.push(lvC, cUp)
                int nl3 = array.size(lvK)
                if nl3 > 0
                    for j = 0 to nl3 - 1
                        array.push(lvN, "■ Low-volume node")
                        array.push(lvP, vLo + (array.get(lvK, j) + 0.5) * vStep)
                        array.push(lvC, cLVN)
            if not na(devPoc)
                array.push(lvN, "■ Developing POC")
                array.push(lvP, devPoc)
                array.push(lvC, cGold)
            if nC > 0
                array.push(lvN, "□ Prior POC")
                array.push(lvP, array.get(cPoc, nC - 1))
                array.push(lvC, cVA)
                array.push(lvN, "□ Prior VAH")
                array.push(lvP, array.get(cVah, nC - 1))
                array.push(lvC, cVA)
                array.push(lvN, "□ Prior VAL")
                array.push(lvP, array.get(cVal, nC - 1))
                array.push(lvC, cVA)
            int nk5 = int(math.min(5, array.size(nkOrd)))
            if nk5 > 0
                for j = 0 to nk5 - 1
                    int o5 = array.get(nkOrd, j)
                    int c5 = array.get(nkIdx, o5)
                    array.push(lvN, "□ Naked POC " + f_day(array.get(cStart, c5)))
                    array.push(lvP, array.get(cPoc, c5))
                    array.push(lvC, cGold)
            if showFR and not na(frPocP)
                array.push(lvN, "□ Fixed range POC")
                array.push(lvP, frPocP)
                array.push(lvC, cUp)
            array<int> lvOrd = array.sort_indices(lvP, order.descending)
            bool placed = false
            int nLv = array.size(lvOrd)
            if nLv > 0
                for j = 0 to nLv - 1
                    int oL = array.get(lvOrd, j)
                    float pL = array.get(lvP, oL)
                    if not placed and pL < px
                        f_row("Last price", f_p(px), "", C_TEXT, C_TEXT, C_TEXT, 4)
                        placed := true
                    float dL = (pL - px) / px * 100
                    f_row(array.get(lvN, oL), f_p(pL), f_pct(dL), array.get(lvC, oL), C_TEXT, dL >= 0 ? cUp : cDn, 0)
            if not placed
                f_row("Last price", f_p(px), "", C_TEXT, C_TEXT, C_TEXT, 4)

        if showEvents
            f_row("Level events", "", "", C_TEXT, C_TEXT, C_TEXT, 1)
            int nEv = array.size(evMsg)
            if nEv > 0
                for j = 0 to nEv - 1
                    f_row(array.get(evTime, j), array.get(evMsg, j), "", array.get(evCol, j), C_SOFT, C_SOFT, 5)
            else
                f_row("Prior-session level crosses and naked POC fills log here.", "", "", C_MUTED, C_MUTED, C_MUTED, 2)

        // Build table
        int nR = array.size(rA)
        if not na(deskTbl)
            table.delete(deskTbl)
        deskTbl := table.new(f_pos(panelPos), 3, int(math.max(1, nR)), bgcolor = C_PANEL, frame_color = C_LINE, frame_width = 1, border_color = C_LINE, border_width = 1)
        if nR > 0
            for r = 0 to nR - 1
                int    kd = array.get(rK, r)
                string ta_ = array.get(rA, r)
                string tb_ = array.get(rB, r)
                string tc_ = array.get(rC, r)
                color  ca_ = array.get(rCa, r)
                color  cb_ = array.get(rCb, r)
                color  cc_ = array.get(rCc, r)
                if kd == 1
                    table.cell(deskTbl, 0, r, ta_, text_color = ca_, text_size = size.tiny, text_halign = text.align_left, bgcolor = C_HEAD, text_formatting = text.format_bold)
                    table.merge_cells(deskTbl, 0, r, 2, r)
                else if kd == 2 or kd == 3
                    table.cell(deskTbl, 0, r, ta_, text_color = ca_, text_size = size.tiny, text_halign = text.align_left)
                    table.merge_cells(deskTbl, 0, r, 2, r)
                else if kd == 5
                    table.cell(deskTbl, 0, r, ta_, text_color = ca_, text_size = size.tiny, text_halign = text.align_left, text_font_family = font.family_monospace)
                    table.cell(deskTbl, 1, r, tb_, text_color = cb_, text_size = size.tiny, text_halign = text.align_left)
                    table.merge_cells(deskTbl, 1, r, 2, r)
                else
                    color rowBg = kd == 4 ? C_NOW : C_PANEL
                    table.cell(deskTbl, 0, r, ta_, text_color = ca_, text_size = size.tiny, text_halign = text.align_left, bgcolor = rowBg, text_formatting = kd == 4 ? text.format_bold : text.format_none)
                    table.cell(deskTbl, 1, r, tb_, text_color = cb_, text_size = size.tiny, text_halign = text.align_right, bgcolor = rowBg, text_font_family = font.family_monospace)
                    table.cell(deskTbl, 2, r, tc_, text_color = cc_, text_size = size.tiny, text_halign = text.align_right, bgcolor = rowBg, text_font_family = font.family_monospace)
    else if not na(deskTbl)
        table.delete(deskTbl)
        deskTbl := na

// Price-scale tags for the visible range levels
plot(pocTag, "Visible POC", color = cGold, display = display.price_scale)
plot(vahTag, "Visible VAH", color = cVA, display = display.price_scale)
plot(valTag, "Visible VAL", color = cVA, display = display.price_scale)
````
