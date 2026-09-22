<!-- tradingview-pine-id: PUB;ebe1bb7419f5416abb824397f56ffda2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BranchenLookup_B3_pub

Source: https://www.tradingview.com/script/05c6bMwa/

## Description

Library  "BranchenLookup_B3_pub"

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
// ║  BranchenLookup_B3_pub  ·  Telekommunikation                               ║
// ║  Publish as: S-Schmidt/BranchenLookup_B3_pub/1                             ║
// ║  Usage:   import S-Schmidt/BranchenLookup_B3_pub/1 as bl_b3                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
// Lookbacks: Z1=0.75J  Z2=2.00J  Z3=5.00J  Z4=10.0J
// Tickers  : 35 Werte (US, DE, GB, FR, ES, IT, CH, BE, FI, SE, AT, CA, JP, KR, SG, AU, HK)
// ─────────────────────────────────────────────────────────────────────────────

library("BranchenLookup_B3_pub", overlay = false)

export is_member(simple string t) =>
    (t == "BATS:VZ"               or t == "BATS:T"                or
     t == "BATS:TMUS"             or t == "BATS:LUMN"             or
     t == "BATS:USM"              or t == "BATS:SHEN"             or
     t == "BATS:CABO"             or t == "BATS:CHTR"             or
     t == "XETR_DLY:DTE"          or t == "LSE_DLY:VOD"           or
     t == "LSE_DLY:BT.A"          or t == "EURONEXT_DLY:ORA"      or
     t == "BME_DLY:TEF"           or t == "MIL_LS:TIM"            or
     t == "SIX_DLY:SCMN"          or t == "EURONEXT_DLY:PROX"     or
     t == "OMXHEX_DLY:ELISA"      or t == "OMXSTO_DLY:TEL2-B"     or
     t == "OMXSTO_DLY:TELIA"      or t == "EURONEXT_DLY:KPN"      or
     t == "VIE_DLY:TKA"           or t == "LSE_DLY:MTNN"          or
     t == "TSX_DLY:BCE"           or t == "TSE_DLY:9432"          or
     t == "TSE_DLY:9433"          or t == "TSE_DLY:9434"          or
     t == "KRX_DLY:017670"        or t == "KRX_DLY:030200"        or
     t == "SGX_DLY:Z74"           or t == "SGX_DLY:B2F"           or
     t == "ASX_DLY:TLS"           or t == "ASX_DLY:TPG"           or
     t == "BATS:CHL"              or t == "BATS:CHU"              or
     t == "HKEX_DLY:728")

export get_z1(simple string t) => is_member(t) ? 0.75 : na
export get_z2(simple string t) => is_member(t) ? 2.00 : na
export get_z3(simple string t) => is_member(t) ? 5.00 : na
export get_z4(simple string t) => is_member(t) ? 10.0 : na
````
