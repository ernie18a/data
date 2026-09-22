<!-- tradingview-pine-id: PUB;8761e1725a01414ebaff714d9b105b39 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BranchenLookup_B2_pub

Source: https://www.tradingview.com/script/71xNvaWB/

## Description

Library  "BranchenLookup_B2_pub"

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
// ║  BranchenLookup_B2_pub  ·  Versorger / Utilities                           ║
// ║  Publish as: S-Schmidt/BranchenLookup_B2_pub/1                             ║
// ║  Usage:   import S-Schmidt/BranchenLookup_B2_pub/1 as bl_b2                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
// Lookbacks: Z1=1.00J  Z2=3.00J  Z3=7.00J  Z4=15.0J
// Tickers  : 35 Werte (US, DE, ES, FR, IT, GB, FI, AT, JP, AU)
// ─────────────────────────────────────────────────────────────────────────────

library("BranchenLookup_B2_pub", overlay = false)

export is_member(simple string t) =>
    (t == "BATS:NEE"              or t == "BATS:DUK"              or
     t == "BATS:SO"               or t == "BATS:D"                or
     t == "BATS:AEP"              or t == "BATS:EXC"              or
     t == "BATS:XEL"              or t == "BATS:WEC"              or
     t == "BATS:ES"               or t == "BATS:ETR"              or
     t == "BATS:PPL"              or t == "BATS:CMS"              or
     t == "BATS:ATO"              or t == "BATS:NI"               or
     t == "XETR_DLY:EOAN"         or t == "XETR_DLY:RWE"          or
     t == "BME_DLY:IBE"           or t == "BME_DLY:ELE"           or
     t == "BME_DLY:REE"           or t == "EURONEXT_DLY:ENGI"     or
     t == "MIL_LS:ENEL"           or t == "MIL_LS:SRG"            or
     t == "MIL_LS:TRN"            or t == "LSE_DLY:NG"            or
     t == "LSE_DLY:SSE"           or t == "LSE_DLY:CNA"           or
     t == "OMXHEX_DLY:FORTUM"     or t == "VIE_DLY:VER"           or
     t == "TSE_DLY:9501"          or t == "TSE_DLY:9503"          or
     t == "TSE_DLY:9502"          or t == "TSE_DLY:9531"          or
     t == "ASX_DLY:AGL"           or t == "ASX_DLY:ORG"           or
     t == "ASX_DLY:APA")

export get_z1(simple string t) => is_member(t) ? 1.00 : na
export get_z2(simple string t) => is_member(t) ? 3.00 : na
export get_z3(simple string t) => is_member(t) ? 7.00 : na
export get_z4(simple string t) => is_member(t) ? 15.0 : na
````
