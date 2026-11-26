# S&P500 ETF Confluence Table

- url: https://www.tradingview.com/script/NamQ5T3x-S-P500-ETF-Confluence-Table/
- type: indicator
- pine_id: PUB;e963be85e105426fb00443e65cf1e314
- version: 1.0

## Description

S&P500 ETF Confluence Signal Table — Indicator Description
This indicator monitors 12 carefully selected ETFs in real time and scores them collectively to determine the directional bias for S&P500 options trading. It displays as a compact table overlay on your chart, updating automatically on every bar close.

How the scoring works
Each ETF is measured by its % change relative to SPY over a configurable lookback period (default 5 bars). Based on that relative strength, each ETF is assigned one of three states: BULL (+1), BEAR (-1), or NEUTRAL (0). The 12 scores are summed into a total confluence score ranging from -12 to +12.

+6 to +12 → Strong bullish confluence — favor call spreads or short puts on SPY/SPX
+3 to +5 → Mild bullish lean — cautious calls, smaller size
-3 to +3 → Mixed / no edge — stay flat or reduce size significantly
-3 to -5 → Mild bearish lean — cautious puts, smaller size
-6 to -12 → Strong bearish confluence — favor put spreads or short calls on SPY/SPX


The 12 ETFs and what they measure
UVXY — Volatility / Fear gauge
Measures market fear directly. Rising UVXY = elevated fear = bearish signal for equities. Falling UVXY = calm market = bullish signal. This is the most sensitive indicator in the table and is measured on an absolute basis, not relative to SPY.
HYG — High yield credit
Junk bonds are the earliest warning system for equity stress. HYG outperforming SPY = credit markets healthy = bullish. HYG diverging lower from SPY = credit stress building = early bearish warning, often before the index itself drops.
TLT — 20+ Year Treasury bonds
Measures flight-to-safety behavior. TLT surging while equities hold or fall = institutions buying safety = bearish. TLT falling alongside SPY = rates-driven selloff rather than a flight to safety, which changes the options strategy context.
UUP — US Dollar index
A strengthening dollar pressures multinational earnings and risk assets broadly. UUP rising = headwind for S&P rally = bearish signal. UUP weakening = tailwind for risk assets = bullish signal.
BITO — Bitcoin / Risk appetite
Crypto acts as a leading edge of risk appetite. BITO outperforming SPY = speculative money flowing into risk = bullish confirmation. BITO collapsing ahead of SPY = early risk-off warning, historically a leading signal for equity pullbacks.
ARKK — Speculative / growth breadth
Measures the breadth of institutional risk-taking in high-growth names. ARKK leading SPY = liquidity is abundant and risk appetite is wide = bullish. ARKK lagging badly while SPY holds = breadth is narrowing = rally is fragile and high-risk for call buyers.
SMH — Semiconductors
Semis are the most cyclically sensitive subsector and historically lead S&P500 turns. SMH outperforming XLK = broad tech momentum is healthy = bullish. SMH breaking while XLK holds = early warning that tech is about to roll over.
XLK — Technology sector weight
Technology represents approximately 30% of the S&P500. XLK leading = the index has its largest engine firing = bullish. XLK lagging = the index is being carried by other sectors, which is a lower-conviction setup for calls.
XLY — Consumer Discretionary vs XLP spread
This row measures the XLY minus XLP relative strength spread — the single most reliable rotation signal in the table. XLY outperforming XLP = consumers are spending on wants, not just needs = risk-on. XLP outperforming XLY = defensive rotation is underway = reduce call exposure immediately.
XLP — Consumer Staples
Confirms the XLY rotation signal from the other side. XLP outperforming SPY = institutions are hiding in defensive names = bearish. XLP lagging SPY = no defensive bid = bullish confirmation.
XLU — Utilities
Rate-sensitive and deeply defensive. XLU surging, especially alongside TLT = flight-to-yield behavior = bearish for growth equities. XLU lagging = no utility bid = market is not in risk-off mode.
XLV — Health Care
The most stable defensive sector. XLV rotating in while tech and cyclicals fade = late-cycle or risk-off institutional behavior = bearish lean. XLV lagging the broader market = no late-cycle rotation = neutral to bullish context.

Special confluence alerts
Beyond the score, the table watches for five specific multi-ETF combinations that historically precede strong directional moves:

Credit stress (UVXY spiking + HYG falling) — highest conviction bearish setup; consider put spreads immediately
Flight to safety (TLT surging + HYG falling) — confirmed risk-off; defensive positioning warranted
Breadth divergence (XLY bullish but ARKK lagging) — rally is narrow and fragile; reduce size, do not chase calls
Semi leading down (SMH breaking while XLK holds) — early warning; watch for XLK to follow semis lower
Clean risk-on (XLP lagging + XLY leading + SMH outperforming) — all three rotation signals aligned bullish; highest conviction call spread setup


Practical usage rules

Only take directional options trades when 8 or more of 12 signals align in one direction
Between 5–7 signals aligned — reduce position size by at least 50%
Below 5 signals in either direction — stay flat or sell premium rather than buy directional
Always check the ALERT row first — a special confluence condition overrides a borderline score
On high-VIX days, prefer spreads over naked directional buying regardless of score — the UVXY signal helps identify this


Settings

Lookback (bars) — default 5. On a 5-minute chart this equals 25 minutes of relative strength. Increase to 10–20 for smoother, less noisy signals on choppy days
Bullish / Bearish threshold (%) — default ±0.3%. Tighten to ±0.15% on low-volatility days for more sensitivity; widen to ±0.5% on high-volatility days to filter noise
Table position — move to any corner to suit your chart layout

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rianala1188

//@version=5
indicator("S&P500 ETF Confluence Table", shorttitle="ETF Signals", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────
lookback     = input.int(5,     "Lookback (bars)",            minval=1, maxval=50)
bull_thresh  = input.float(0.3, "Bullish threshold (%)",      minval=0.05, step=0.05)
bear_thresh  = input.float(-0.3,"Bearish threshold (%)",      maxval=-0.05, step=0.05)
tbl_pos      = input.string("Top Right", "Table position",   options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])

// ─────────────────────────────────────────────
// FETCH ETF DATA
// ─────────────────────────────────────────────
spx  = request.security("SPY",  timeframe.period, close)
uvxy = request.security("UVXY", timeframe.period, close)
hyg  = request.security("HYG",  timeframe.period, close)
tlt  = request.security("TLT",  timeframe.period, close)
uup  = request.security("UUP",  timeframe.period, close)
bito = request.security("BITO", timeframe.period, close)
arkk = request.security("ARKK", timeframe.period, close)
smh  = request.security("SMH",  timeframe.period, close)
xlk  = request.security("XLK",  timeframe.period, close)
xly  = request.security("XLY",  timeframe.period, close)
xlp  = request.security("XLP",  timeframe.period, close)
xlu  = request.security("XLU",  timeframe.period, close)
xlv  = request.security("XLV",  timeframe.period, close)

// ─────────────────────────────────────────────
// RELATIVE STRENGTH vs SPY
// ─────────────────────────────────────────────
pct(src)  => (src / src[lookback] - 1) * 100
spx_chg   = pct(spx)
rel(src)  => pct(src) - spx_chg

uvxy_r = pct(uvxy)   // absolute — VIX proxy
hyg_r  = rel(hyg)
tlt_r  = rel(tlt)
uup_r  = rel(uup)
bito_r = rel(bito)
arkk_r = rel(arkk)
smh_r  = rel(smh)
xlk_r  = rel(xlk)
xly_r  = rel(xly)
xlp_r  = rel(xlp)
xlu_r  = rel(xlu)
xlv_r  = rel(xlv)
xly_xlp = xly_r - xlp_r   // spread for XLY row

// ─────────────────────────────────────────────
// SIGNAL LOGIC  (+1 bull / -1 bear / 0 neutral)
// ─────────────────────────────────────────────
sig(r) => r > bull_thresh ? 1 : r < bear_thresh ? -1 : 0

sig_uvxy = uvxy_r >  bull_thresh ?  -1 : uvxy_r < bear_thresh ? 1 : 0   // inverted: rising UVXY = bearish
sig_hyg  = sig(hyg_r)
sig_tlt  = uvxy_r > bull_thresh ? -1 : tlt_r > bull_thresh ? -1 : tlt_r < bear_thresh ? 1 : 0  // rising TLT = bearish
sig_uup  = uup_r >  bull_thresh ? -1 : uup_r  < bear_thresh ? 1 : 0    // strong USD = bearish
sig_bito = sig(bito_r)
sig_arkk = sig(arkk_r)
sig_smh  = sig(smh_r)
sig_xlk  = sig(xlk_r)
sig_xly  = xly_xlp > bull_thresh * 2 ? 1 : xly_xlp < bear_thresh * 2 ? -1 : 0
sig_xlp  = xlp_r >  bull_thresh ? -1 : xlp_r  < bear_thresh ? 1 : 0    // defensive outperform = bearish
sig_xlu  = xlu_r >  bull_thresh ? -1 : xlu_r  < bear_thresh ? 1 : 0
sig_xlv  = xlv_r >  bull_thresh ? -1 : xlv_r  < bear_thresh ? 1 : 0

// ─────────────────────────────────────────────
// CONFLUENCE SCORE
// ─────────────────────────────────────────────
score = sig_uvxy + sig_hyg + sig_tlt + sig_uup + sig_bito + sig_arkk + sig_smh + sig_xlk + sig_xly + sig_xlp + sig_xlu  + sig_xlv

bull_count = (sig_uvxy==1?1:0)+(sig_hyg==1?1:0)+(sig_tlt==1?1:0)+
             (sig_uup==1?1:0) +(sig_bito==1?1:0)+(sig_arkk==1?1:0)+
             (sig_smh==1?1:0) +(sig_xlk==1?1:0) +(sig_xly==1?1:0)+
             (sig_xlp==1?1:0) +(sig_xlu==1?1:0) +(sig_xlv==1?1:0)

bear_count = (sig_uvxy==-1?1:0)+(sig_hyg==-1?1:0)+(sig_tlt==-1?1:0)+
             (sig_uup==-1?1:0) +(sig_bito==-1?1:0)+(sig_arkk==-1?1:0)+
             (sig_smh==-1?1:0) +(sig_xlk==-1?1:0) +(sig_xly==-1?1:0)+
             (sig_xlp==-1?1:0) +(sig_xlu==-1?1:0) +(sig_xlv==-1?1:0)

// ─────────────────────────────────────────────
// TABLE HELPERS
// ─────────────────────────────────────────────
pos_map(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.middle_left

bg(s)  => s == 1 ? color.new(#1a3a0a, 0) : s == -1 ? color.new(#3a0a0a, 0) : color.new(#2a2000, 0)
tc(s)  => s == 1 ? color.new(#7ecb45, 0) : s == -1 ? color.new(#f06060, 0) : color.new(#d4a017, 0)
lbl(s) => s == 1 ? "▲ BULL" : s == -1 ? "▼ BEAR" : "● NEUT"

hdr_bg = color.new(#1a1a2e, 0)
hdr_tc = color.new(#aaaacc, 0)
sep_bg = color.new(#111122, 0)

// ─────────────────────────────────────────────
// DRAW TABLE  (only on last bar)
// ─────────────────────────────────────────────
var table t = table.new(pos_map(tbl_pos), 4, 18,
     border_color=color.new(#333355, 0), border_width=1,
     frame_color=color.new(#333355,0),   frame_width=1)

if barstate.islast

    // ── Header row ──
    table.cell(t, 0, 0, "ETF",    text_color=hdr_tc, bgcolor=hdr_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 0, "Role",   text_color=hdr_tc, bgcolor=hdr_bg, text_size=size.small)
    table.cell(t, 2, 0, "Signal", text_color=hdr_tc, bgcolor=hdr_bg, text_size=size.small)
    table.cell(t, 3, 0, "Rel %",  text_color=hdr_tc, bgcolor=hdr_bg, text_size=size.small)

    // ── ETF rows ──
    // Row data: ticker, role label, signal int, rel% value
    // [0] UVXY
    table.cell(t, 0, 1, "UVXY", text_color=tc(sig_uvxy), bgcolor=bg(sig_uvxy), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 1, "Volatility",  text_color=tc(sig_uvxy), bgcolor=bg(sig_uvxy), text_size=size.small)
    table.cell(t, 2, 1, lbl(sig_uvxy), text_color=tc(sig_uvxy), bgcolor=bg(sig_uvxy), text_size=size.small)
    table.cell(t, 3, 1, str.tostring(uvxy_r, "#.##") + "%", text_color=tc(sig_uvxy), bgcolor=bg(sig_uvxy), text_size=size.small)

    // [1] HYG
    table.cell(t, 0, 2, "HYG",  text_color=tc(sig_hyg), bgcolor=bg(sig_hyg), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 2, "Credit",       text_color=tc(sig_hyg), bgcolor=bg(sig_hyg), text_size=size.small)
    table.cell(t, 2, 2, lbl(sig_hyg),  text_color=tc(sig_hyg), bgcolor=bg(sig_hyg), text_size=size.small)
    table.cell(t, 3, 2, str.tostring(hyg_r, "#.##") + "%", text_color=tc(sig_hyg), bgcolor=bg(sig_hyg), text_size=size.small)

    // [2] TLT
    table.cell(t, 0, 3, "TLT",  text_color=tc(sig_tlt), bgcolor=bg(sig_tlt), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 3, "Rates",        text_color=tc(sig_tlt), bgcolor=bg(sig_tlt), text_size=size.small)
    table.cell(t, 2, 3, lbl(sig_tlt),  text_color=tc(sig_tlt), bgcolor=bg(sig_tlt), text_size=size.small)
    table.cell(t, 3, 3, str.tostring(tlt_r, "#.##") + "%", text_color=tc(sig_tlt), bgcolor=bg(sig_tlt), text_size=size.small)

    // [3] UUP
    table.cell(t, 0, 4, "UUP",  text_color=tc(sig_uup), bgcolor=bg(sig_uup), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 4, "USD",          text_color=tc(sig_uup), bgcolor=bg(sig_uup), text_size=size.small)
    table.cell(t, 2, 4, lbl(sig_uup),  text_color=tc(sig_uup), bgcolor=bg(sig_uup), text_size=size.small)
    table.cell(t, 3, 4, str.tostring(uup_r, "#.##") + "%", text_color=tc(sig_uup), bgcolor=bg(sig_uup), text_size=size.small)

    // [4] BITO
    table.cell(t, 0, 5, "BITO", text_color=tc(sig_bito), bgcolor=bg(sig_bito), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 5, "Risk appetite", text_color=tc(sig_bito), bgcolor=bg(sig_bito), text_size=size.small)
    table.cell(t, 2, 5, lbl(sig_bito), text_color=tc(sig_bito), bgcolor=bg(sig_bito), text_size=size.small)
    table.cell(t, 3, 5, str.tostring(bito_r, "#.##") + "%", text_color=tc(sig_bito), bgcolor=bg(sig_bito), text_size=size.small)

    // [5] ARKK
    table.cell(t, 0, 6, "ARKK", text_color=tc(sig_arkk), bgcolor=bg(sig_arkk), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 6, "Spec breadth", text_color=tc(sig_arkk), bgcolor=bg(sig_arkk), text_size=size.small)
    table.cell(t, 2, 6, lbl(sig_arkk), text_color=tc(sig_arkk), bgcolor=bg(sig_arkk), text_size=size.small)
    table.cell(t, 3, 6, str.tostring(arkk_r, "#.##") + "%", text_color=tc(sig_arkk), bgcolor=bg(sig_arkk), text_size=size.small)

    // [6] SMH
    table.cell(t, 0, 7, "SMH",  text_color=tc(sig_smh), bgcolor=bg(sig_smh), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 7, "Semis",        text_color=tc(sig_smh), bgcolor=bg(sig_smh), text_size=size.small)
    table.cell(t, 2, 7, lbl(sig_smh),  text_color=tc(sig_smh), bgcolor=bg(sig_smh), text_size=size.small)
    table.cell(t, 3, 7, str.tostring(smh_r, "#.##") + "%", text_color=tc(sig_smh), bgcolor=bg(sig_smh), text_size=size.small)

    // [7] XLK
    table.cell(t, 0, 8, "XLK",  text_color=tc(sig_xlk), bgcolor=bg(sig_xlk), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 8, "Tech weight",  text_color=tc(sig_xlk), bgcolor=bg(sig_xlk), text_size=size.small)
    table.cell(t, 2, 8, lbl(sig_xlk),  text_color=tc(sig_xlk), bgcolor=bg(sig_xlk), text_size=size.small)
    table.cell(t, 3, 8, str.tostring(xlk_r, "#.##") + "%", text_color=tc(sig_xlk), bgcolor=bg(sig_xlk), text_size=size.small)

    // [8] XLY
    table.cell(t, 0, 9, "XLY",  text_color=tc(sig_xly), bgcolor=bg(sig_xly), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 9, "Cyclical",     text_color=tc(sig_xly), bgcolor=bg(sig_xly), text_size=size.small)
    table.cell(t, 2, 9, lbl(sig_xly),  text_color=tc(sig_xly), bgcolor=bg(sig_xly), text_size=size.small)
    table.cell(t, 3, 9, str.tostring(xly_xlp, "#.##") + "%", text_color=tc(sig_xly), bgcolor=bg(sig_xly), text_size=size.small)

    // [9] XLP
    table.cell(t, 0, 10, "XLP", text_color=tc(sig_xlp), bgcolor=bg(sig_xlp), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 10, "Staples",      text_color=tc(sig_xlp), bgcolor=bg(sig_xlp), text_size=size.small)
    table.cell(t, 2, 10, lbl(sig_xlp),  text_color=tc(sig_xlp), bgcolor=bg(sig_xlp), text_size=size.small)
    table.cell(t, 3, 10, str.tostring(xlp_r, "#.##") + "%", text_color=tc(sig_xlp), bgcolor=bg(sig_xlp), text_size=size.small)

    // [10] XLU
    table.cell(t, 0, 11, "XLU", text_color=tc(sig_xlu), bgcolor=bg(sig_xlu), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 11, "Utilities",    text_color=tc(sig_xlu), bgcolor=bg(sig_xlu), text_size=size.small)
    table.cell(t, 2, 11, lbl(sig_xlu),  text_color=tc(sig_xlu), bgcolor=bg(sig_xlu), text_size=size.small)
    table.cell(t, 3, 11, str.tostring(xlu_r, "#.##") + "%", text_color=tc(sig_xlu), bgcolor=bg(sig_xlu), text_size=size.small)

    // [11] XLV
    table.cell(t, 0, 12, "XLV", text_color=tc(sig_xlv), bgcolor=bg(sig_xlv), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 12, "Health care",  text_color=tc(sig_xlv), bgcolor=bg(sig_xlv), text_size=size.small)
    table.cell(t, 2, 12, lbl(sig_xlv),  text_color=tc(sig_xlv), bgcolor=bg(sig_xlv), text_size=size.small)
    table.cell(t, 3, 12, str.tostring(xlv_r, "#.##") + "%", text_color=tc(sig_xlv), bgcolor=bg(sig_xlv), text_size=size.small)

    // ── Separator ──
    table.cell(t, 0, 13, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(t, 1, 13, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(t, 2, 13, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(t, 3, 13, "", bgcolor=sep_bg, text_size=size.tiny)

    // ── Score summary ──
    verdict   = score >= 6  ? "STRONG BULL" : score >= 3  ? "MILD BULL" : score <= -6 ? "STRONG BEAR" : score <= -3 ? "MILD BEAR"   : "MIXED / WAIT"
    v_sig     = score >= 3  ? 1 : score <= -3 ? -1 : 0

    table.cell(t, 0, 14, "SCORE",   text_color=tc(v_sig), bgcolor=bg(v_sig), text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 14, verdict,   text_color=tc(v_sig), bgcolor=bg(v_sig), text_size=size.small)
    table.cell(t, 2, 14, str.tostring(bull_count) + "▲  " + str.tostring(bear_count) + "▼", text_color=tc(v_sig), bgcolor=bg(v_sig), text_size=size.small)
    table.cell(t, 3, 14, str.tostring(score) + " / 12", text_color=tc(v_sig), bgcolor=bg(v_sig), text_size=size.small)

    // ── Special confluence alerts row ──
    cond_credit  = sig_uvxy == -1 and sig_hyg == -1
    cond_safety  = sig_tlt  == -1 and sig_hyg == -1
    cond_breadth = sig_xly  ==  1 and sig_arkk == -1
    cond_semi    = sig_smh  == -1 and sig_xlk  ==  1
    cond_risk_on = sig_xlp  ==  1 and sig_xly  ==  1 and sig_smh == 1

    alert_msg = cond_credit  ? "⚠ Credit stress: UVXY+HYG" : cond_safety  ? "⚠ Flight to safety: TLT+HYG" : cond_breadth ? "⚠ Breadth divergence: XLY/ARKK" : cond_semi    ? "⚠ Semi warning: SMH/XLK split" : cond_risk_on ? "✔ Clean risk-on setup" : "—"

    alert_sig = (cond_credit or cond_safety or cond_semi) ? -1 :  cond_risk_on ? 1 : 0

    table.cell(t, 0, 15, "ALERT",     text_color=tc(alert_sig), bgcolor=bg(alert_sig), text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, 15, alert_msg,   text_color=tc(alert_sig), bgcolor=bg(alert_sig), text_size=size.tiny)
    table.cell(t, 2, 15, "",          text_color=tc(alert_sig), bgcolor=bg(alert_sig), text_size=size.tiny)
    table.cell(t, 3, 15, "",          text_color=tc(alert_sig), bgcolor=bg(alert_sig), text_size=size.tiny)

// ─────────────────────────────────────────────
// ALERT CONDITIONS  (set in TradingView alert panel)
// ─────────────────────────────────────────────
alertcondition(bull_count >= 8,          title="Strong BULL confluence",    message="ETF Table: BULLISH — {{bull_count}} of 12 signals bullish. Score={{score}}. Favor call spreads on SPY/SPX.")
alertcondition(bear_count >= 8,          title="Strong BEAR confluence",    message="ETF Table: BEARISH — {{bear_count}} of 12 signals bearish. Score={{score}}. Favor put spreads on SPY/SPX.")
alertcondition(sig_uvxy==-1 and sig_hyg==-1, title="Credit stress alert",  message="ETF Table: UVXY spiking + HYG falling. Credit stress confirmed. High-conviction bearish.")
alertcondition(sig_tlt==-1  and sig_hyg==-1, title="Flight to safety",     message="ETF Table: TLT surging + HYG falling. Flight to safety. Consider put spreads.")
alertcondition(sig_xly==1   and sig_arkk==-1,title="Breadth divergence",   message="ETF Table: XLY bullish but ARKK lagging. Narrow rally — reduce size.")
alertcondition(sig_smh==-1  and sig_xlk==1,  title="Semis leading down",   message="ETF Table: SMH breaking while XLK holds. Watch for XLK rollover.")
alertcondition(sig_xlp==1 and sig_xly==1 and sig_smh==1, title="Clean risk-on", message="ETF Table: XLP lagging + XLY + SMH leading. Clean risk-on — favor call spreads.")
````
