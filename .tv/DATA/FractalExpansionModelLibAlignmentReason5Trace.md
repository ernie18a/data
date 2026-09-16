<!-- tradingview-pine-id: PUB;01082d7fd3954e98b5c8f3b8adab9cd9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FractalExpansionModel_Lib_AlignmentReason5Trace

Source: https://www.tradingview.com/script/fCHxLNt7-FractalExpansionModel-Lib-AlignmentReason5Trace/

## Description

Library  "FractalExpansionModel_Lib_AlignmentReason5Trace"

emptyProbe()
  Return an empty route result when C18 never entered a route fold.

lowerProbe(dT, dTC, rOT, rCT, semantic, order, maxRecords, minimumHead, maximumHead)
  Mirror C18 foldLower exactly and expose its first rejected pair or
unique selected packet. Main calls this only after the unchanged fold and only
for the first live reason-5 observation in one context epoch.
  Parameters:
    dT (array<int>)
    dTC (array<int>)
    rOT (array<int>)
    rCT (array<int>)
    semantic (array<int>)
    order (array<int>)
    maxRecords (int)
    minimumHead (int)
    maximumHead (int)

scalarProbe(cdT, cdTC, crOT, crCT, cSemantic, cOrder, pdT, pdTC, prOT, prCT, pSemantic, pOrder, minimumHead, maximumHead)
  Mirror C18 foldScalar exactly, including delivered/shape/selection,
exact-repeat/conflict/strict-advance, and boundary co-release precedence.
  Parameters:
    cdT (int)
    cdTC (int)
    crOT (int)
    crCT (int)
    cSemantic (int)
    cOrder (int)
    pdT (int)
    pdTC (int)
    prOT (int)
    prCT (int)
    pSemantic (int)
    pOrder (int)
    minimumHead (int)
    maximumHead (int)

classifyOrigin(preReason, storedReason, storedReadiness, storedDT, storedDTC, storedROT, storedRCT, storedSemantic, storedOrder, postReason, postReadiness, probe)
  Classify only a proven route. A new-identity emitter is never chosen
by elimination; soft retention and unresolved paths remain explicit.
  Parameters:
    preReason (int)
    storedReason (int)
    storedReadiness (int)
    storedDT (int)
    storedDTC (int)
    storedROT (int)
    storedRCT (int)
    storedSemantic (int)
    storedOrder (int)
    postReason (int)
    postReadiness (int)
    probe (ProbeResult)

eventClass(priorReason, priorReadiness, currentReason, currentReadiness)
  Classify row transitions without weakening the normal resolved-row
contract. Recovery is exactly reason 0/readiness 1.
  Parameters:
    priorReason (int)
    priorReadiness (int)
    currentReason (int)
    currentReadiness (int)

ProbeResult
  Fields:
    foldReason (series int)
    origin (series int)
    selected (series bool)
    selectedIndex (series int)
    priorDT (series int)
    priorDTC (series int)
    priorROT (series int)
    priorRCT (series int)
    priorSemantic (series int)
    priorOrder (series int)
    nextDT (series int)
    nextDTC (series int)
    nextROT (series int)
    nextRCT (series int)
    nextSemantic (series int)
    nextOrder (series int)
    selectedDT (series int)
    selectedDTC (series int)
    selectedROT (series int)
    selectedRCT (series int)
    selectedSemantic (series int)
    selectedOrder (series int)
    compareEligible (series bool)
    exactRepeat (series bool)
    boundaryCoRelease (series bool)
    transitionReason (series int)

---

## Source Code

````pine
//@version=6
library("FractalExpansionModel_Lib_AlignmentReason5Trace")

// PHASE2R82 proof-only companion. This library is pure and stateless. It mirrors
// the unchanged C18 fold/admission predicates only when Main requests one bounded
// live observation; it owns no request, lifecycle, ledger, table, or model state.

const int PACK_STATE_BASE = 32
const int PACK_PAYLOAD_BASE = 8192

// Provenance codes consumed only by the R82 observer.
const int ORIGIN_NONE = 0
const int ORIGIN_LOWER_PAIR = 1
const int ORIGIN_SCALAR_PAIR = 2
const int ORIGIN_STORED_ADMISSION = 3
const int ORIGIN_HEAD_PREFIX = 4
const int ORIGIN_INHERITED_OR_RETAINED = 5
const int ORIGIN_UNRESOLVED = 6

// Event codes consumed only by the R82 observer.
const int EVENT_WAITING = 0
const int EVENT_AVAILABLE_TO_ERROR = 1
const int EVENT_IMMEDIATE_OR_INHERITED_ERROR = 2
const int EVENT_GENUINE_RECOVERY = 3
const int EVENT_ERROR_ACTIVE = 4
const int EVENT_STILL_UNAVAILABLE_OR_DIFFERENT_ERROR = 5

// One source-matched result. Identity and semantic/order fields expose the exact
// pair or selected packet; the flags prove which C18 predicates were eligible.
export type ProbeResult
    int foldReason
    int origin
    bool selected
    int selectedIndex
    int priorDT
    int priorDTC
    int priorROT
    int priorRCT
    int priorSemantic
    int priorOrder
    int nextDT
    int nextDTC
    int nextROT
    int nextRCT
    int nextSemantic
    int nextOrder
    int selectedDT
    int selectedDTC
    int selectedROT
    int selectedRCT
    int selectedSemantic
    int selectedOrder
    bool compareEligible
    bool exactRepeat
    bool boundaryCoRelease
    int transitionReason

f_causalClose(int dTC, int rOT, int semanticWord) =>
    int packedFlags = int(math.floor(semanticWord / (PACK_STATE_BASE * PACK_PAYLOAD_BASE))) % 16
    packedFlags >= 8 ? rOT : dTC

f_shapeReason(int dT, int dTC, int rOT, int rCT) =>
    na(dT) or na(dTC) or dT >= dTC ? 8 : na(rOT) or na(rCT) or rOT >= rCT ? 9 : dT < rOT or dTC > rCT ? 10 : 0

// @function Return an empty route result when C18 never entered a route fold.
export emptyProbe() =>
    ProbeResult.new(0, ORIGIN_NONE, false, int(na), int(na), int(na), int(na), int(na), 0, 0, int(na), int(na), int(na), int(na), 0, 0, int(na), int(na), int(na), int(na), 0, 0, false, false, false, 0)

// @function Mirror C18 foldLower exactly and expose its first rejected pair or
// unique selected packet. Main calls this only after the unchanged fold and only
// for the first live reason-5 observation in one context epoch.
export lowerProbe(array<int> dT, array<int> dTC, array<int> rOT, array<int> rCT, array<int> semantic, array<int> order, int maxRecords, int minimumHead, int maximumHead) =>
    int origin = ORIGIN_NONE
    int priorDT = na
    int priorDTC = na
    int priorROT = na
    int priorRCT = na
    int priorSemantic = 0
    int priorOrder = 0
    int nextDT = na
    int nextDTC = na
    int nextROT = na
    int nextRCT = na
    int nextSemantic = 0
    int nextOrder = 0
    int selectedDT = na
    int selectedDTC = na
    int selectedROT = na
    int selectedRCT = na
    int selectedSemantic = 0
    int selectedOrder = 0
    bool rejectedCompareEligible = false
    bool rejectedExactRepeat = false
    bool rejectedBoundaryCoRelease = false
    int rejectedTransitionReason = 0
    int n = array.size(dT)
    bool parallel = array.size(dTC) == n and array.size(rOT) == n and array.size(rCT) == n and array.size(semantic) == n and array.size(order) == n
    int foldReason = 0
    int minIndex = na
    int maxIndex = na
    int lastDT = na
    int lastDTC = na
    int lastROT = na
    int lastRCT = na
    int lastSemantic = 0
    int lastOrder = 0
    int lastClose = na
    if parallel and n > 0 and n <= maxRecords
        for i = 0 to n - 1
            int candidateDT = array.get(dT, i)
            int candidateDTC = array.get(dTC, i)
            int candidateROT = array.get(rOT, i)
            int candidateRCT = array.get(rCT, i)
            int candidateSemantic = array.get(semantic, i)
            int candidateOrder = array.get(order, i)
            int candidateClose = f_causalClose(candidateDTC, candidateROT, candidateSemantic)
            if candidateClose <= maximumHead
                int candidateShape = f_shapeReason(candidateDT, candidateDTC, candidateROT, candidateRCT)
                bool previous = not na(lastDTC)
                bool sameIdentity = previous and lastDT == candidateDT and lastDTC == candidateDTC and lastROT == candidateROT and lastRCT == candidateRCT
                bool exactRepeat = sameIdentity and lastSemantic == candidateSemantic and lastOrder == candidateOrder
                int transitionReason = exactRepeat ? 0 : sameIdentity ? 7 : lastDT < candidateDT and lastDTC < candidateDTC ? 0 : 5
                bool boundaryCoRelease = previous and lastDT < candidateDT and lastDTC < candidateDTC and candidateShape == 0 and int(math.floor(lastSemantic / (PACK_STATE_BASE * PACK_PAYLOAD_BASE))) % 16 < 8 and int(math.floor(candidateSemantic / (PACK_STATE_BASE * PACK_PAYLOAD_BASE))) % 16 >= 8 and candidateDT == candidateROT and candidateDTC > candidateROT and lastClose == candidateClose
                if foldReason == 0 and candidateShape != 0
                    foldReason := candidateShape
                else if foldReason == 0 and not exactRepeat
                    if previous and (transitionReason != 0 or lastClose == candidateClose and not boundaryCoRelease)
                        foldReason := lastClose == candidateClose and not boundaryCoRelease ? 7 : transitionReason
                        if foldReason == 5
                            origin := ORIGIN_LOWER_PAIR
                            priorDT := lastDT
                            priorDTC := lastDTC
                            priorROT := lastROT
                            priorRCT := lastRCT
                            priorSemantic := lastSemantic
                            priorOrder := lastOrder
                            nextDT := candidateDT
                            nextDTC := candidateDTC
                            nextROT := candidateROT
                            nextRCT := candidateRCT
                            nextSemantic := candidateSemantic
                            nextOrder := candidateOrder
                            rejectedCompareEligible := true
                            rejectedExactRepeat := exactRepeat
                            rejectedBoundaryCoRelease := boundaryCoRelease
                            rejectedTransitionReason := transitionReason
                    else
                        lastDT := candidateDT
                        lastDTC := candidateDTC
                        lastROT := candidateROT
                        lastRCT := candidateRCT
                        lastSemantic := candidateSemantic
                        lastOrder := candidateOrder
                        lastClose := candidateClose
                        maxIndex := i
                        if candidateClose <= minimumHead
                            minIndex := i
    int reason = n == 0 ? 4 : not parallel or n > maxRecords ? 12 : foldReason != 0 ? foldReason : na(minIndex) or na(maxIndex) ? 6 : minIndex != maxIndex ? 3 : 0
    bool selected = reason == 0
    int selectedIndex = selected ? minIndex : int(na)
    if selected
        selectedDT := array.get(dT, selectedIndex)
        selectedDTC := array.get(dTC, selectedIndex)
        selectedROT := array.get(rOT, selectedIndex)
        selectedRCT := array.get(rCT, selectedIndex)
        selectedSemantic := array.get(semantic, selectedIndex)
        selectedOrder := array.get(order, selectedIndex)
    ProbeResult.new(reason, origin, selected, selectedIndex, priorDT, priorDTC, priorROT, priorRCT, priorSemantic, priorOrder, nextDT, nextDTC, nextROT, nextRCT, nextSemantic, nextOrder, selectedDT, selectedDTC, selectedROT, selectedRCT, selectedSemantic, selectedOrder, rejectedCompareEligible, rejectedExactRepeat, rejectedBoundaryCoRelease, rejectedTransitionReason)

// @function Mirror C18 foldScalar exactly, including delivered/shape/selection,
// exact-repeat/conflict/strict-advance, and boundary co-release precedence.
export scalarProbe(int cdT, int cdTC, int crOT, int crCT, int cSemantic, int cOrder, int pdT, int pdTC, int prOT, int prCT, int pSemantic, int pOrder, int minimumHead, int maximumHead) =>
    int currentClose = f_causalClose(cdTC, crOT, cSemantic)
    int priorClose = f_causalClose(pdTC, prOT, pSemantic)
    bool currentEligible = currentClose <= maximumHead
    bool priorEligible = priorClose <= maximumHead
    bool anyDelivered = not na(cdT) or not na(pdT) or currentEligible or priorEligible
    int currentShape = currentEligible ? f_shapeReason(cdT, cdTC, crOT, crCT) : 0
    int priorShape = priorEligible ? f_shapeReason(pdT, pdTC, prOT, prCT) : 0
    bool currentMinimum = currentEligible and currentClose <= minimumHead
    bool priorMinimum = priorEligible and priorClose <= minimumHead
    int minimumChoice = currentMinimum and (not priorMinimum or currentClose > priorClose) ? 1 : priorMinimum and (not currentMinimum or priorClose > currentClose) ? 2 : currentMinimum and priorMinimum ? -1 : 0
    int maximumChoice = currentEligible and (not priorEligible or currentClose > priorClose) ? 1 : priorEligible and (not currentEligible or priorClose > currentClose) ? 2 : currentEligible and priorEligible ? -1 : 0
    bool sameIdentity = pdT == cdT and pdTC == cdTC and prOT == crOT and prCT == crCT
    bool exactRepeat = sameIdentity and pSemantic == cSemantic and pOrder == cOrder
    int transitionReason = exactRepeat ? 0 : sameIdentity ? 7 : pdT < cdT and pdTC < cdTC ? 0 : 5
    bool compareEligible = currentEligible and priorEligible and currentShape == 0 and priorShape == 0
    bool boundaryCoRelease = compareEligible and pdT < cdT and pdTC < cdTC and int(math.floor(pSemantic / (PACK_STATE_BASE * PACK_PAYLOAD_BASE))) % 16 < 8 and int(math.floor(cSemantic / (PACK_STATE_BASE * PACK_PAYLOAD_BASE))) % 16 >= 8 and cdT == crOT and cdTC > crOT and priorClose == currentClose
    minimumChoice := boundaryCoRelease ? 1 : compareEligible and exactRepeat ? (currentClose <= minimumHead ? 1 : 0) : minimumChoice
    maximumChoice := boundaryCoRelease or compareEligible and exactRepeat ? 1 : maximumChoice
    int reason = not anyDelivered ? 4 : not currentEligible and not priorEligible ? 6 : currentShape != 0 ? currentShape : priorShape != 0 ? priorShape : compareEligible and transitionReason != 0 ? transitionReason : minimumChoice == -1 or maximumChoice == -1 ? 7 : minimumChoice == 0 or maximumChoice == 0 ? 12 : minimumChoice != maximumChoice ? 3 : 0
    bool selected = reason == 0
    bool useCurrent = minimumChoice == 1
    int selectedIndex = selected ? (useCurrent ? 1 : 2) : int(na)
    int origin = reason == 5 and compareEligible and transitionReason == 5 ? ORIGIN_SCALAR_PAIR : ORIGIN_NONE
    ProbeResult.new(reason, origin, selected, selectedIndex, pdT, pdTC, prOT, prCT, pSemantic, pOrder, cdT, cdTC, crOT, crCT, cSemantic, cOrder, useCurrent ? cdT : pdT, useCurrent ? cdTC : pdTC, useCurrent ? crOT : prOT, useCurrent ? crCT : prCT, useCurrent ? cSemantic : pSemantic, useCurrent ? cOrder : pOrder, compareEligible, exactRepeat, boundaryCoRelease, transitionReason)

// @function Classify only a proven route. A new-identity emitter is never chosen
// by elimination; soft retention and unresolved paths remain explicit.
export classifyOrigin(int preReason, int storedReason, int storedReadiness, int storedDT, int storedDTC, int storedROT, int storedRCT, int storedSemantic, int storedOrder, int postReason, int postReadiness, ProbeResult probe) =>
    bool hardPrefix = preReason == 5 and postReason == 5
    bool routePair = preReason == 0 and postReason == 5 and postReadiness == 2 and probe.foldReason == 5 and (probe.origin == ORIGIN_LOWER_PAIR or probe.origin == ORIGIN_SCALAR_PAIR)
    bool compareStored = preReason == 0 and probe.foldReason == 0 and probe.selected and storedReadiness == 1
    bool sameStoredIdentity = compareStored and storedDT == probe.selectedDT and storedDTC == probe.selectedDTC and storedROT == probe.selectedROT and storedRCT == probe.selectedRCT
    bool exactStoredRepeat = sameStoredIdentity and storedSemantic == probe.selectedSemantic and storedOrder == probe.selectedOrder
    int storedTransitionReason = exactStoredRepeat ? 0 : sameStoredIdentity ? 7 : storedDT < probe.selectedDT and storedDTC < probe.selectedDTC ? 0 : 5
    bool storedAdmission = postReason == 5 and postReadiness == 2 and compareStored and storedTransitionReason == 5
    bool softRetained = (preReason == 4 or preReason == 6 or preReason == 12 or probe.foldReason == 4 or probe.foldReason == 6 or probe.foldReason == 12) and storedReason == 5 and storedReadiness == 2 and postReason == 5 and postReadiness == 2
    int origin = hardPrefix ? ORIGIN_HEAD_PREFIX : routePair ? probe.origin : storedAdmission ? ORIGIN_STORED_ADMISSION : softRetained or storedReason == 5 and storedReadiness == 2 ? ORIGIN_INHERITED_OR_RETAINED : postReason == 5 ? ORIGIN_UNRESOLVED : ORIGIN_NONE
    [origin, storedTransitionReason, compareStored, exactStoredRepeat]

// @function Classify row transitions without weakening the normal resolved-row
// contract. Recovery is exactly reason 0/readiness 1.
export eventClass(int priorReason, int priorReadiness, int currentReason, int currentReadiness) =>
    bool enteredReason5 = currentReason == 5 and currentReadiness == 2 and (na(priorReason) or priorReason != 5)
    bool reason5Continues = priorReason == 5 and priorReadiness == 2 and currentReason == 5 and currentReadiness == 2
    bool genuineRecovery = priorReason == 5 and priorReadiness == 2 and currentReason == 0 and currentReadiness == 1
    bool leavesReason5Unavailable = priorReason == 5 and priorReadiness == 2 and not reason5Continues and not genuineRecovery
    enteredReason5 ? (priorReadiness == 1 ? EVENT_AVAILABLE_TO_ERROR : EVENT_IMMEDIATE_OR_INHERITED_ERROR) : genuineRecovery ? EVENT_GENUINE_RECOVERY : reason5Continues ? EVENT_ERROR_ACTIVE : leavesReason5Unavailable ? EVENT_STILL_UNAVAILABLE_OR_DIFFERENT_ERROR : EVENT_WAITING
````
