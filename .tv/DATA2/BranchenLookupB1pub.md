<!-- tradingview-pine-id: PUB;cba9bd1f1ceb4cb58c6cde9899900ba1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BranchenLookup_B1_pub

Source: https://www.tradingview.com/script/4ZyiOg4W/

## Description

Library  "BranchenLookup_B1_pub"

is_member(t)
  Parameters:
    t (simple string)

get_z1(t)
  Parameters:
    t (simple string)

get_z2(t)
  Parameters:
    t (simple string)

get_z3(t)
  Parameters:
    t (simple string)

get_z4(t)
  Parameters:
    t (simple string)

---

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  BranchenLookup_B1_pub  ·  Basiskonsumgüter                                ║
// ║  Publish as: S-Schmidt/BranchenLookup_B1_pub/1                             ║
// ║  Usage:   import S-Schmidt/BranchenLookup_B1_pub/1 as bl_b1                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
// Lookbacks: Z1=0.75J  Z2=2.00J  Z3=4.00J  Z4=8.00J
// Tickers  : 35 Werte (US, CH, GB, FR, DE, JP)
// ─────────────────────────────────────────────────────────────────────────────

library("BranchenLookup_B1_pub", overlay = false)

export is_member(simple string t) =>
    (t == "BATS:PG"               or t == "BATS:KO"               or
     t == "BATS:PEP"              or t == "BATS:CL"               or
     t == "BATS:HRL"              or t == "BATS:MO"               or
     t == "BATS:PM"               or t == "BATS:KHC"              or
     t == "BATS:GIS"              or t == "BATS:K"                or
     t == "BATS:SJM"              or t == "BATS:CLX"              or
     t == "BATS:CHD"              or t == "BATS:STZ"              or
     t == "SIX_DLY:NESN"          or t == "LSE_DLY:ULVR"          or
     t == "LSE_DLY:DGE"           or t == "LSE_DLY:BATS"          or
     t == "LSE_DLY:IMB"           or t == "LSE_DLY:RKT"           or
     t == "EURONEXT_DLY:BN"       or t == "EURONEXT_DLY:RI"       or
     t == "EURONEXT_DLY:OR"       or t == "EURONEXT_DLY:HEIA"     or
     t == "XETR_DLY:HEN3"         or t == "XETR_DLY:BEI"          or
     t == "SIX_DLY:ABBN"          or t == "SIX_DLY:GIVN"          or
     t == "TSE_DLY:4452"          or t == "TSE_DLY:2802"          or
     t == "TSE_DLY:2801"          or t == "TSE_DLY:2503"          or
     t == "TSE_DLY:2502"          or t == "TSE_DLY:4911"          or
     t == "TSE_DLY:2269")

export get_z1(simple string t) => is_member(t) ? 0.75 : na
export get_z2(simple string t) => is_member(t) ? 2.00 : na
export get_z3(simple string t) => is_member(t) ? 4.00 : na
export get_z4(simple string t) => is_member(t) ? 8.00 : na
````
