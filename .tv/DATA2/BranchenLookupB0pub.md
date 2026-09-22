<!-- tradingview-pine-id: PUB;9b2f14821a26408ca2bf51475a486285 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BranchenLookup_B0_pub

Source: https://www.tradingview.com/script/CIvUX2xI/

## Description

Library  "BranchenLookup_B0_pub"

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
// ║  BranchenLookup_B0_pub  ·  Transport & Logistik                            ║
// ║  Publish as: S-Schmidt/BranchenLookup_B0_pub/1                             ║
// ║  Usage:   import S-Schmidt/BranchenLookup_B0_pub/1 as bl_b0                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
// Lookbacks: Z1=0.50J  Z2=1.50J  Z3=4.00J  Z4=10.0J
// Tickers  : 38 Werte (US, CA, DE, DK, JP, KR, HK, CH)
// ─────────────────────────────────────────────────────────────────────────────

library("BranchenLookup_B0_pub", overlay = false)

export is_member(simple string t) =>
    (t == "BATS:UPS"              or t == "BATS:FDX"              or
     t == "BATS:XPO"              or t == "BATS:ODFL"             or
     t == "BATS:UNP"              or t == "BATS:CSX"              or
     t == "BATS:NSC"              or t == "BATS:SAIA"             or
     t == "BATS:JBHT"             or t == "BATS:KNX"              or
     t == "BATS:CHRW"             or t == "BATS:EXPD"             or
     t == "BATS:GXO"              or t == "BATS:R"                or
     t == "BATS:GATX"             or t == "TSX_DLY:CP"            or
     t == "TSX_DLY:CN"            or t == "XETR_DLY:DHL"          or
     t == "XETR_DLY:HHLA"         or t == "BATS:ZTO"              or
     t == "HKEX_DLY:6618"         or t == "HKEX_DLY:368"          or
     t == "TSE_DLY:9064"          or t == "TSE_DLY:9065"          or
     t == "TSE_DLY:6178"          or t == "TSE_DLY:9147"          or
     t == "KRX_DLY:003490"        or t == "KRX_DLY:011200"        or
     t == "OMXCOP_DLY:MAERSK-B"   or t == "OMXCOP_DLY:DSV"        or
     t == "SIX_DLY:KNIN"          or t == "XETR_DLY:HLAG"         or
     t == "HKEX_DLY:753"          or t == "HKEX_DLY:670"          or
     t == "TSE_DLY:9101"          or t == "TSE_DLY:9104"          or
     t == "TSE_DLY:9107"          or t == "XETR_DLY:LHA")

export get_z1(simple string t) => is_member(t) ? 0.50 : na
export get_z2(simple string t) => is_member(t) ? 1.50 : na
export get_z3(simple string t) => is_member(t) ? 4.00 : na
export get_z4(simple string t) => is_member(t) ? 10.0 : na
````
