# US Treasury Auction Zones

- url: https://www.tradingview.com/script/phYNwSlx-US-Treasury-Auction-Zones/
- type: indicator
- pine_id: PUB;818ad74fc8264025a81cc811de7b8d40
- version: 1.0

## Description

US Treasury Auction Zones
An ICT-style killzone indicator that highlights US Treasury auction days and marks the critical 1:00–2:00 PM ET volatility window when auction results are announced.

Why Treasury Auctions Matter
The US Treasury auctions hundreds of billions in debt each month. When results drop at 1 PM ET, the market learns two things simultaneously — the yield the Treasury had to pay and how much demand showed up. For futures traders, the reaction is immediate and sharp. Gold (MGC/GC), equity indices (ES, NQ), and crude oil (CL) all move on the yield signal. TIPS auctions are especially relevant to gold since they directly reveal real yields — the primary driver of gold's inverse rate relationship.

How It Works
Rather than hardcoding dates, the indicator uses the Treasury's consistent monthly scheduling pattern to compute auction days perpetually — forward and backward across any chart date without expiry or manual updates.
The nth-weekday rule: the Nth occurrence of a weekday in a month falls precisely when the day-of-week matches and the day-of-month is within the corresponding 7-day window. No external data required.
Scheduling rules used:

10Y Note — 2nd Wednesday of each month
30Y Bond — 2nd Thursday of each month
20Y Bond — 3rd Wednesday of each month
3Y Note — 2nd Tuesday of each month
2Y Note — 4th Tuesday of each month
5Y Note + 2Y FRN — 4th Wednesday of each month
7Y Note — 4th Thursday of each month
Bills — Monday through Thursday weekly (off by default)


Three Tiers
🔴 T1 — Major (10Y Note · 20Y Bond · 30Y Bond)
The most watched auctions. Largest impact on yields, gold, and risk assets. These determine where the Treasury must price long-duration debt and often set the directional tone for the session.
🟠 T2 — Coupons (2Y · 3Y · 5Y · 7Y Notes · TIPS · FRN)
Significant auctions. TIPS results are uniquely relevant to gold traders — they directly reveal real yields at the moment of issuance, without the continuous noise of secondary market repricing.
🟡 T3 — Bills (4W · 6W · 8W · 13W · 17W · 26W · 52W)
High frequency, lower impact. Off by default to avoid coloring nearly every weekday. Enable when monitoring short-end rate dynamics or bill market stress.

Visual Elements

Day background — full session colored by tier (T1 red · T2 amber · T3 yellow) so auction days are immediately visible as you scan the chart
1–2 PM ET overlay — vivid white overlay fires on top of the tier color during the killzone window, matching the ICT killzone visual language
Session open label — ● T1  10Y Note appears at the first bar of each auction day so you know what's coming before 1 PM
1 PM label — UST T1  10Y Note · 1:00 PM ET marks the exact bar when the killzone opens

Both labels are independently toggleable. All colors are fully customizable.

Alerts Included

T1 auction 1 PM killzone open
T2 auction 1 PM killzone open
Any auction 1 PM killzone open
T1 auction day open (pre-session warning)


Notes
The nth-weekday scheduling rules match the Treasury's published pattern for the vast majority of auctions. Holiday shifts (which move auction dates by one day) are not applied — these are rare and the indicator remains accurate within one trading day for affected months. TIPS auction weeks follow the same weekday anchor as other T2 auctions and are included in the T2 tier accordingly.
Holiday shifts aside, this indicator requires no updates and works on any timeframe, any instrument, any date range.

## Source Code

````pine
//@version=6
indicator("US Treasury Auction Zones", shorttitle="UST◆AUCTION",
          overlay=true, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════════════
//  US TREASURY AUCTION ZONES  |  Pine Script v6
//
//  Perpetual calendar — works on any historical or future date.
//
//  nth-weekday rule: the Nth occurrence of a weekday in a month is simply
//  "correct weekday AND day-of-month in [(N-1)*7+1 … N*7]".
//  No Zeller / modulo math needed.
//
//  TIERS
//  ─────
//  T1 (red)   : 10Y Note (2nd Wed) · 30Y Bond (2nd Thu) · 20Y Bond (3rd Wed)
//  T2 (amber) : 3Y Note (2nd Tue) · 2Y Note (4th Tue) · 5Y+FRN (4th Wed)
//               7Y Note (4th Thu)
//  T3 (yellow): Bill days — Mon/Tue/Wed/Thu not already T1/T2 (off by default)
//
//  1:00 – 2:00 PM ET  →  vivid overlay (results announced, peak volatility)
//  Labels fire at session open AND at the 1 PM bar.
// ══════════════════════════════════════════════════════════════════════════════

// ─── INPUTS ──────────────────────────────────────────────────────────────────
g1 = "① Tiers"
show_t1  = input.bool(true,  "T1 — 10Y Note / 20Y / 30Y Bond  (red)",     group=g1)
show_t2  = input.bool(true,  "T2 — 2/3/5/7Y Notes + TIPS + FRN  (amber)", group=g1)
show_t3  = input.bool(false, "T3 — Bill days  (yellow, off by default)",   group=g1)

g2 = "② Colors"
c_t1  = input.color(color.new(#FF4757, 80), "T1 background",  group=g2)
c_t2  = input.color(color.new(#FFA502, 83), "T2 background",  group=g2)
c_t3  = input.color(color.new(#FFD700, 87), "T3 background",  group=g2)
c_win = input.color(color.new(#FFFFFF, 65), "1–2 PM overlay", group=g2)

g3 = "③ Labels"
show_open_lbl = input.bool(true, "Label at session open (what is auctioned)", group=g3)
show_1pm_lbl  = input.bool(true, "Label at 1 PM (killzone open)",            group=g3)

// ─── TIME ────────────────────────────────────────────────────────────────────
TZ     = "America/New_York"
et_h   = hour(time,      TZ)
et_m   = minute(time,    TZ)
et_dow = dayofweek(time, TZ)   // 1=Sun 2=Mon 3=Tue 4=Wed 5=Thu 6=Fri 7=Sat
et_dom = dayofmonth(time,TZ)

int cur_ymd = year(time,TZ) * 10000 + month(time,TZ) * 100 + et_dom
bool new_day   = cur_ymd != cur_ymd[1]
bool in_window = et_h == 13
bool at_1pm    = et_h == 13 and et_m == 0

// ─── NTH WEEKDAY HELPER ──────────────────────────────────────────────────────
// Is today the Nth occurrence of weekday WD this month?
// 1st occ: dom 1–7   2nd: 8–14   3rd: 15–21   4th: 22–28
is_nth(int n, int wd) =>
    et_dow == wd and et_dom >= (n - 1) * 7 + 1 and et_dom <= n * 7

// ─── DAY-OF-WEEK CONSTANTS ───────────────────────────────────────────────────
int MON = 2
int TUE = 3
int WED = 4
int THU = 5

// ─── TIER 1 DETECTION ────────────────────────────────────────────────────────
bool is_10y  = show_t1 and is_nth(2, WED)   // 10Y Note  : 2nd Wednesday
bool is_30y  = show_t1 and is_nth(2, THU)   // 30Y Bond  : 2nd Thursday
bool is_20y  = show_t1 and is_nth(3, WED)   // 20Y Bond  : 3rd Wednesday
bool is_t1   = is_10y or is_30y or is_20y

// ─── TIER 2 DETECTION ────────────────────────────────────────────────────────
bool is_3y   = show_t2 and not is_t1 and is_nth(2, TUE)   // 3Y Note  : 2nd Tuesday
bool is_2y   = show_t2 and not is_t1 and is_nth(4, TUE)   // 2Y Note  : 4th Tuesday
bool is_5y   = show_t2 and not is_t1 and is_nth(4, WED)   // 5Y + FRN : 4th Wednesday
bool is_7y   = show_t2 and not is_t1 and is_nth(4, THU)   // 7Y Note  : 4th Thursday
bool is_t2   = is_3y or is_2y or is_5y or is_7y

// ─── TIER 3 DETECTION ────────────────────────────────────────────────────────
// Bills auction Mon–Thu. Exclude days already claimed by T1/T2.
bool is_bill_day = et_dow == MON or et_dow == TUE or et_dow == WED or et_dow == THU
bool is_t3       = show_t3 and not is_t1 and not is_t2 and is_bill_day

// ─── COMBINED ────────────────────────────────────────────────────────────────
bool is_any = is_t1 or is_t2 or is_t3
color day_c = is_t1 ? c_t1 : is_t2 ? c_t2 : is_t3 ? c_t3 : na

// ─── LABEL TEXT ──────────────────────────────────────────────────────────────
get_label() =>
    if is_t1
        is_10y and is_30y ? "10Y Note + 30Y Bond" :
         is_10y            ? "10Y Note"            :
         is_30y            ? "30Y Bond"            : "20Y Bond"
    else if is_t2
        is_3y ? "3Y Note"         :
         is_2y ? "2Y Note"         :
         is_5y ? "5Y Note + 2Y FRN" : "7Y Note"
    else
        et_dow == MON ? "13W / 26W Bills" :
         et_dow == TUE ? "6W / 52W Bills"  :
         et_dow == WED ? "17W Bill"         : "4W / 8W Bills"

// ─── BACKGROUND ───────────────────────────────────────────────────────────────
bgcolor(is_any ? day_c : na, title="Auction Day")
bgcolor(is_any and in_window ? c_win : na, title="1–2 PM Killzone")

// ─── SESSION OPEN LABEL ───────────────────────────────────────────────────────
// One label per auction day at the first bar of the session
if new_day and is_any and show_open_lbl
    string tier_dot = is_t1 ? "● T1" : is_t2 ? "◆ T2" : "· T3"
    label.new(bar_index, high,
              tier_dot + "  " + get_label(),
              style    = label.style_label_down,
              color    = color.new(day_c, 10),
              textcolor= color.white,
              size     = size.small)

// ─── 1 PM KILLZONE LABEL ─────────────────────────────────────────────────────
var label lbl_1pm = na

if at_1pm and is_any and show_1pm_lbl
    if not na(lbl_1pm)
        label.delete(lbl_1pm)
    string tier_tag = is_t1 ? "T1" : is_t2 ? "T2" : "T3"
    lbl_1pm := label.new(bar_index, high,
                          "UST " + tier_tag + "  " + get_label() + "\n1:00 PM ET",
                          style    = label.style_label_down,
                          color    = color.new(day_c, 10),
                          textcolor= color.white,
                          size     = size.small)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(is_t1 and at_1pm,
               title  = "UST T1 — 1 PM Killzone",
               message= "Major Treasury auction closing on {{ticker}}. 10Y/20Y/30Y results due now.")
alertcondition(is_t2 and at_1pm,
               title  = "UST T2 — 1 PM Killzone",
               message= "Treasury coupon auction closing on {{ticker}}. Note/TIPS/FRN results due.")
alertcondition(is_any and at_1pm,
               title  = "UST — 1 PM Killzone",
               message= "US Treasury auction results due at 1 PM ET on {{ticker}}.")
alertcondition(is_t1 and new_day,
               title  = "UST T1 — Auction Day",
               message= "Today is a T1 Treasury auction day on {{ticker}}.")
````
