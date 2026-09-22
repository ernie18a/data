<!-- tradingview-pine-id: PUB;c7ca87040c704e55a45ba25ac683af15 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Global Net Liquidity

Source: https://www.tradingview.com/script/kOattZkS-Global-Net-Liquidity-Giovanni-Fork/

## Description

Hello traders. This plots the combined balance sheets of the Fed, ECB, BoJ, PBoC and Bank of England, converted to dollars, with the US Treasury General Account and the Fed's reverse repo facility subtracted.

There are already a lot of global liquidity scripts on here, so I want to be clear about what this one does differently rather than just adding another overlay to the pile. Three things.

First, this is a net measure.

Gross central bank assets tell you how much money has been created. They do not tell you how much of it is actually available, because some of it gets created and then taken straight back out of circulation. Money sitting in the Treasury's account at the Fed is not in the system. Nor is cash parked overnight in the reverse repo facility. Subtracting those gives you what is genuinely out there, and that is what net means here. At the time of writing it is 0.97tn in the TGA coming off a gross of 22.37tn.

It is also worth saying that this is built from central bank balance sheets rather than M2. Those are related but they are not the same measure, so if you are comparing this against something else, check which one you are looking at.

Units are worth paying attention to when you combine feeds like this. The underlying sources do not agree with each other: FRED publishes the Fed balance sheet in millions and the reverse repo facility in billions, and the China balance sheet is reported in hundred millions of yuan. TradingView appears to normalise all of them to absolute units before serving them, which is why every scale factor in this script is 1.

I would still rather you checked than took my word for it. Every series has its own visible scale factor and the table prints each component in USD trillions, so you can compare the numbers against what you know the Fed and the ECB are actually running. If a row looks wrong by orders of magnitude, that series' scale input is wrong and you can correct it in the settings without touching the code.

Second, China is measured properly.

The PBoC balance sheet is a poor gauge of Chinese liquidity and most aggregates include it anyway. Its growth up to 2014 was foreign exchange accumulation rather than stimulus, so the series has meant different things in different decades. More importantly, the PBoC's main easing tool is the reserve requirement ratio, and that is balance sheet neutral. Cutting the RRR reclassifies required reserves as excess reserves, releasing roughly 1 trillion yuan per 50bp, while total assets do not move at all. The biggest thing the PBoC does is invisible to a balance sheet aggregate.

The default here subtracts required reserves, estimated as the reserve ratio applied to M2 as a deposit proxy, so an RRR cut registers as the easing it actually is. You can switch back to the plain balance sheet or to the commercial bank balance sheet in the settings. It is an approximation because China's RRR is tiered across large, small and rural banks and the headline rate only covers the large ones, but it responds to the right events.

Third, and this is the part I think adds most, the currency effect is separated out.

Every aggregate that converts foreign balance sheets at spot has dollar moves baked into it. A stronger dollar shrinks the line even when no central bank has done anything, and that gets reported as tightening.

The purple line is the same aggregate chain linked at constant currency. Each period's balance sheet change is converted at that period's own opening rate and accumulated, so it shows what the balance sheets did without the currency. The shaded gap between the two lines is the currency effect, and the table gives it as a number. Since January 2016 it is 1.56tn, meaning that much of the apparent decline in global liquidity was dollar strength rather than central bank action.

The BoJ is the clearest example. Its assets have grown in yen over recent years while its reported dollar contribution has fallen sharply. A gross liquidity chart reads that as the BoJ tightening. It didn't tighten, the yen moved.

A few things to be aware of before you use it.

The chain start date is January 2016 by default and it matters. The constant currency line is accumulated rather than measured, so it seeds at that date and the two lines are identical there by construction. The currency figure is always cumulative since the start date, so 1.56tn means since January 2016, not in absolute terms. Set the date later if you find a component with no data at the start.

The TGA and RRP are US specific drains applied to a global gross, which is slightly inconsistent. Everybody does it, few say so, so I am saying so.

The underlying data updates weekly at best and the PBoC monthly, so use this on daily or higher. Intraday just repeats the last print.

I built this because I wanted to know how much of the last three years of liquidity contraction was real and how much was the dollar. If it is useful to you, say so, and if you think I have got something wrong let me know.

---

## Source Code

````pine
//@version=6
// =============================================================================
// Global Net Liquidity — chain-linked constant currency
//   Fed + BoJ + PBoC + BoE + ECB, converted to USD, less US RRP and TGA.
//
// Two departures from the usual global liquidity aggregate.
//
// NET, not gross. Most published versions plot M2 or raw balance sheets.
// This subtracts the Treasury General Account and the Fed's reverse repo
// facility — genuine drains on available liquidity.
//
// CURRENCY EFFECT SEPARATED, not buried. Converting foreign balance sheets
// at spot means dollar moves enter the "liquidity" line: a stronger dollar
// shrinks it even when no central bank has acted. Reported dollar value
// decomposes exactly:
//
//     A1*X1 - A0*X0  =  (A1-A0)*X0      balance sheet effect
//                    +  A0*(X1-X0)      currency effect
//                    +  (A1-A0)(X1-X0)  interaction
//
// Accumulating only the first term bar by bar gives a constant-currency
// series that never depends on an arbitrary base date:
//
//     C[0] = A[0]*X[0]
//     C[t] = C[t-1] + (A[t]-A[t-1]) * X[t-1]
//
// Computed per bar, each step's change is small, so the interaction term
// rounds away and the split is clean. The gap between the reported line and
// the chain-linked line is accumulated currency effect.
//
// Worked example (illustrative). BoJ assets ¥700tn in 2020 at 0.0094 = $6.58tn;
// ¥740tn in 2026 at 0.00667 = $4.94tn. The headline reads a $1.64tn
// contraction — but assets ROSE ¥40tn. Chain-linked, the BoJ added ~$0.35tn
// and the yen accounted for the rest. Gross liquidity indicators report that
// as central bank tightening. It wasn't.
//
// A units note. The underlying sources disagree with each other: FRED
// publishes WALCL and WTREGEN in millions and RRPONTSYD in billions, and the
// China balance sheet is reported in hundred millions of yuan. TradingView
// appears to normalise all of them to absolute units, which is why every
// scale below is 1 — verified against the table rather than assumed. Each
// series still carries an explicit factor, and the table prints every
// converted component, so magnitudes can be checked rather than trusted.
// If you rebuild this outside TradingView, against FRED's own API or CSVs,
// the published units apply and the scales change.
//
// Use on daily or higher. These series update weekly at best (PBoC monthly).
// =============================================================================

// Separate pane: the reader gets an unconstrained y-axis and can scale it
// independently of whatever instrument is on the chart.
indicator("Global Net Liquidity", "GNL", overlay = false, precision = 2)

// ── Components ───────────────────────────────────────────────────────────────
gC = "Components"
useFed = input.bool(true, "Fed (US)",  group = gC)
useEcb = input.bool(true, "ECB (EU)",  group = gC)
useBoj = input.bool(true, "BoJ (JP)",  group = gC)
usePbc = input.bool(true, "PBoC (CN)", group = gC)
useBoe = input.bool(true, "BoE (UK)",  group = gC)
useRrp = input.bool(true, "Subtract RRP (US)", group = gC)
useTga = input.bool(true, "Subtract TGA (US)", group = gC)

// The PBoC balance sheet is a weak liquidity gauge. Its growth to 2014 was FX
// accumulation, not stimulus, and the PBoC's main easing lever — the reserve
// requirement ratio — is balance-sheet-neutral: cutting it reclassifies
// required reserves as excess ones, releasing roughly CNY 1tn per 50bp while
// total assets do not move. "RRR-adjusted" subtracts required reserves
// (RRR x deposit base, M2 as the proxy) so easing registers. Approximate:
// China's RRR is tiered and the headline rate covers only the large banks.
cnMode = input.string("RRR-adjusted", "China measure", options = ["Balance sheet", "RRR-adjusted", "Bank balance sheet"], group = gC)

// ── Currency ─────────────────────────────────────────────────────────────────
gF = "Currency effect"
showConst = input.bool(true, "Show constant-currency line", group = gF, tooltip = "Chain-linked: each period's balance sheet change is converted at that period's own opening rate. The gap to the reported line is accumulated currency effect, not liquidity.")
chainStart = input.time(timestamp("01 Jan 2016 00:00 +0000"), "Chain start", group = gF, tooltip = "The chain seeds here at true reported value. Fixed by date rather than by chart start, so the line is reproducible however far back you scroll. Set it after every component has data — check the table for a date where no component reads zero.")

// ── Scale factors: raw value x factor = absolute native currency ─────────────
gS = "Unit scaling (check against the table)"
sFed = input.float(1.0, "Fed scale",  group = gS)
sEcb = input.float(1.0, "ECB scale",  group = gS)
sBoj = input.float(1.0, "BoJ scale",  group = gS)
sPbc = input.float(1.0, "PBoC scale", group = gS, tooltip = "Also applied to CNM2 and CNBBS. If the RRR-adjusted row goes negative or absurd, those series use a different unit to CNCBBS.")
sBoe = input.float(1.0, "BoE scale",  group = gS)
sRrp = input.float(1.0, "RRP scale",  group = gS, tooltip = "1.0 for TradingView's feed, which serves absolute dollars. Note FRED itself publishes this series in billions, so if you pull it directly rather than through TradingView the factor is 1e9.")
sTga = input.float(1.0, "TGA scale",  group = gS)

// ── Display ──────────────────────────────────────────────────────────────────
gD = "Display"
smoothLen = input.int(1, "Smoothing (bars)", minval = 1, group = gD)
showTable = input.bool(true, "Show component table", group = gD)
showYoY   = input.bool(false, "Plot 1-year change instead of level", group = gD)

// ── Data ─────────────────────────────────────────────────────────────────────
// lookahead_off matters: lookahead_on pulls values in before their real
// release date, flattering anything built on this.
f(sym) =>
    request.security(sym, "D", close, barmerge.gaps_off, barmerge.lookahead_off)

rFed = f("ECONOMICS:USCBBS")
rEcb = f("ECONOMICS:EUCBBS")
rBoj = f("ECONOMICS:JPCBBS")
rPbc = f("ECONOMICS:CNCBBS")
rBoe = f("ECONOMICS:GBCBBS")
rRrp = f("FRED:RRPONTSYD")
rTga = f("FRED:WTREGEN")

rCnRrr = f("ECONOMICS:CNCRR")   // reserve requirement ratio, percent
rCnM2  = f("ECONOMICS:CNM2")    // deposit base proxy
rCnBbs = f("ECONOMICS:CNBBS")   // commercial bank balance sheet

xEur = f("FX:EURUSD")
xGbp = f("FX:GBPUSD")
xJpy = f("FX_IDC:JPYUSD")
xCny = f("FX_IDC:CNYUSD")

// ── Native-currency aggregates ───────────────────────────────────────────────
TN = 1e12

natFed = nz(rFed) * sFed
natEcb = nz(rEcb) * sEcb
natBoj = nz(rBoj) * sBoj
natBoe = nz(rBoe) * sBoe

// China per the selected mode. Required reserves come off in CNY before the
// FX conversion, so the RRR adjustment is not distorted by currency moves.
cnyPbc = nz(rPbc) * sPbc
cnyReq = nz(rCnRrr) / 100.0 * nz(rCnM2) * sPbc
natPbc = cnMode == "RRR-adjusted" ? math.max(cnyPbc - cnyReq, 0.0) : cnMode == "Bank balance sheet" ? nz(rCnBbs) * sPbc : cnyPbc

usdRrp = nz(rRrp) * sRrp
usdTga = nz(rTga) * sTga
drains = (useRrp ? usdRrp : 0.0) + (useTga ? usdTga : 0.0)

// ── Chain-linked constant currency ───────────────────────────────────────────
// Seeds once at true reported value, then adds each period's balance sheet
// change converted at that period's OPENING rate. Previous values are passed
// in explicitly rather than read as history inside the function, and a step
// is skipped unless both the current and previous bar hold real data — that
// guard is what stops a component switching on mid-history from registering
// its entire balance sheet as a one-bar expansion.
chainLink(float nat, float prevNat, float fx, float prevFx, bool started) =>
    var float c = na
    if na(c)
        if started and nat > 0 and fx > 0
            c := nat * fx
    else if nat > 0 and prevNat > 0 and prevFx > 0
        c := c + (nat - prevNat) * prevFx
    c

started = time >= chainStart

cFed = chainLink(natFed, natFed[1], 1.0,  1.0,      started)  // already USD
cEcb = chainLink(natEcb, natEcb[1], xEur, xEur[1],  started)
cBoj = chainLink(natBoj, natBoj[1], xJpy, xJpy[1],  started)
cPbc = chainLink(natPbc, natPbc[1], xCny, xCny[1],  started)
cBoe = chainLink(natBoe, natBoe[1], xGbp, xGbp[1],  started)

// ── Reported (spot) versus constant currency ─────────────────────────────────
usdFed = natFed
usdEcb = natEcb * nz(xEur)
usdBoj = natBoj * nz(xJpy)
usdPbc = natPbc * nz(xCny)
usdBoe = natBoe * nz(xGbp)

grossSpot  = (useFed ? usdFed : 0.0) + (useEcb ? usdEcb : 0.0) + (useBoj ? usdBoj : 0.0) + (usePbc ? usdPbc : 0.0) + (useBoe ? usdBoe : 0.0)
grossConst = (useFed ? nz(cFed) : 0.0) + (useEcb ? nz(cEcb) : 0.0) + (useBoj ? nz(cBoj) : 0.0) + (usePbc ? nz(cPbc) : 0.0) + (useBoe ? nz(cBoe) : 0.0)

netSpot  = (grossSpot  - drains) / TN
netConst = (grossConst - drains) / TN
fxEffect = netSpot - netConst   // the part of the line that is currency, not liquidity

sSpot  = smoothLen > 1 ? ta.sma(netSpot,  smoothLen) : netSpot
sConst = smoothLen > 1 ? ta.sma(netConst, smoothLen) : netConst

ySpot  = bar_index >= 252 ? sSpot  - sSpot[252]  : na
yConst = bar_index >= 252 ? sConst - sConst[252] : na

vSpot  = showYoY ? ySpot  : sSpot
vConst = showYoY ? yConst : sConst

// ── Plot ─────────────────────────────────────────────────────────────────────
cSpotCol  = color.new(#26a69a, 0)
cConstCol = color.new(#7E57C2, 0)

plSpot  = plot(vSpot, "Net liquidity (reported)", cSpotCol, 2)
plConst = plot(showConst and started ? vConst : na, "Net liquidity (constant currency)", cConstCol, 1)
fill(plSpot, plConst, color.new(#7E57C2, 88), "Currency effect")

// Only meaningful in 1-year-change mode, where the sign is the whole point:
// above zero is expansion, below is contraction.
hline(showYoY ? 0 : na, "Zero", color.new(color.gray, 50), hline.style_dashed)

// ── Verification table ───────────────────────────────────────────────────────
// If a row's magnitude is implausible, its scale input is wrong. Do not
// publish a number you cannot defend.
row(t, r, string lbl, float usd, bool on, bool neg) =>
    share = grossSpot > 0 ? math.abs(usd) / grossSpot * 100 : 0.0
    table.cell(t, 0, r, lbl, text_color = on ? color.white : color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, r, (neg ? "-" : "") + str.tostring(usd / TN, "#.##"), text_color = on ? (neg ? #ef5350 : color.white) : color.gray, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 2, r, on ? str.tostring(share, "#.#") + "%" : "off", text_color = color.gray, text_size = size.small, text_halign = text.align_right)

plain(t, r, string lbl, string val, string note, color col) =>
    table.cell(t, 0, r, lbl, text_color = col, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, r, val, text_color = col, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 2, r, note, text_color = color.gray, text_size = size.small, text_halign = text.align_right)

if showTable and barstate.islast
    var t = table.new(position.top_right, 3, 12, bgcolor = color.new(#1e222d, 10), border_width = 1, border_color = color.new(color.gray, 70))
    plain(t, 0, "Component", "USD tn", "Share", color.gray)
    row(t, 1, "Fed",  usdFed, useFed, false)
    row(t, 2, "ECB",  usdEcb, useEcb, false)
    row(t, 3, "BoJ",  usdBoj, useBoj, false)
    row(t, 4, "PBoC", usdPbc, usePbc, false)
    row(t, 5, "BoE",  usdBoe, useBoe, false)
    row(t, 6, "RRP",  usdRrp, useRrp, true)
    row(t, 7, "TGA",  usdTga, useTga, true)
    plain(t, 8,  "Gross", str.tostring(grossSpot / TN, "#.##"), "", color.gray)
    plain(t, 9,  "Constant ccy", str.tostring(netConst, "#.##"), "chain-linked", cConstCol)
    plain(t, 10, "FX effect", str.tostring(fxEffect, "#.##"), "currency only", cConstCol)
    plain(t, 11, "NET", str.tostring(netSpot, "#.##"), "reported", color.white)
````
