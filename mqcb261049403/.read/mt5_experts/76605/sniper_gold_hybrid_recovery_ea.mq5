//+------------------------------------------------------------------+
//|                                   Sniper Gold Hybrid Recovery EA |
//|                                  Copyright 2026, Waseem Shahrukh |
//|                        https://www.mql5.com/en/users/shahrukhktk |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Waseem Shahrukh"
#property link        "https://www.mql5.com/en/users/shahrukhktk"
#property version     "1.22"
#property description "XAUUSD M15 basket recovery EA with adaptive ATR-based spacing,"
#property description "structure-validated entries (LL/LH), dynamic RSI gating,"
#property description "crash detection, news filter, and smart trade trimming."
#property description "Designed for Gold intraday on 15-minute charts."
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

enum ENUM_NEWS_MODE
  {
   NEWS_OFF      = 0,
   NEWS_CALENDAR = 1,
   NEWS_CSV      = 2,
   NEWS_BOTH     = 3
  };

//--- 1. LOT SETTINGS
input int    MagicNumber          = 888999;
input double FixedLotSize         = 0.01;
input bool   UseCompoundingLot    = true;
input double BalancePer001Lot     = 1000.0;   // 1000=0.01, 2000=0.02
input double MaxLotCap            = 0.20;
input bool   UseRecoveryLotBoost  = false;    // Gold style multiplier, default safe
input double RecoveryLotMultiplier= 1.20;

//--- 2. ENTRY / RECOVERY ENGINE
input int    RSI_Period              = 14;
input int    ATR_Period              = 14;
input int    ATR_AvgBars             = 50;
input double NormalBuyRSI            = 40.0;
input double HighATRBuyRSI           = 35.0;
input double ExtremeATRBuyRSI        = 30.0;
input double HighATRMultiplier       = 1.40;
input double ExtremeATRMultiplier    = 2.00;
input bool   AutoRecoveryDepth  = true;    // True = ATR/DD/LL adaptive depth, False = manual limit
input int    ManualRecoveryTrades    = 6;       // Used only if AutoRecoveryDepth=false
input double RecoveryATRDistanceMult = 1.55;    // wider base ATR gap after 1st trade
input double RecoveryDepthStep       = 0.45;    // each next recovery waits farther
input int    MinSecondTradeDistancePoints = 1800; // hard minimum gap: 1st -> 2nd
input int    MinThirdTradeDistancePoints  = 3000; // hard minimum gap: 2nd -> 3rd
input int    MinDeepRecoveryDistancePoints= 4500; // hard minimum gap after 3rd
input bool   UseCrashGapExpansion    = true;
input int    CrashRecoveryMinPoints  = 1000;  // Gold crash-gap idea

//--- 3. STRUCTURE / QUALITY FILTERS
input int    StructureLookbackBars   = 90;
input int    SwingDepth              = 2;
input bool   RequireBearLLLH         = true;
input bool   RequireLLSupport        = true;
input bool   RequireBullishReversal  = true;
input int    NormalRecoveryMinScore  = 55;
input int    RescueRecoveryStartTrade= 3;       // 3rd trade onward = basket rescue lot
input int    RescueRecoveryMinScore  = 85;      // 3rd/4th must be best support
input bool   UseBasketWeightedRescueLot = true;
input double RescueLotExposurePercent = 100.0; // existing basket lots ka percent
input double RescueLotMaxBaseMultiple = 4.0;   // base lot x cap for rescue
input bool   AllowDeepEmergencyRecovery = true;
input double EmergencyRecoveryDDPercent = 12.0;
input double EmergencyRecoveryATRMult   = 2.50;

//--- 4. PROFIT / TRADE MANAGEMENT
input double TargetProfitUSD         = 15.0;
input double TrailingStepUSD         = 5.0;
input bool   UseRecoveryBasketTrail  = true;
input double RecoveryStartTrailUSD   = 2.0;
input double RecoveryGivebackUSD     = 1.0;
input bool   EnableTrimming          = true;
input double TrimProfitTarget        = 0.0;
input double MinTrimWinnerUSD        = 1.0;

//--- 5. PROTECTION
input int    MaxSpreadPoints         = 100;
input int    MaxSlippagePoints       = 30;
input double MaxEquityLossPercent    = 50.0;
input int    MaxPipsPerSec           = 200;
input int    CrashPauseMinutes       = 60;
input int    PostCrashWideGapMinutes = 180;
input bool   BlockFirstEntryOnCrash  = true;
input bool   ManageCurrentSymbolOnly = true;

//--- 6. NEWS FILTER
input ENUM_NEWS_MODE NewsMode         = NEWS_CALENDAR;
input string NewsCSVFileName          = "News.csv";
input int    NewsMinutesBefore        = 30;
input int    NewsMinutesAfter         = 20;
input bool   NewsHighImpactOnly       = true;
input bool   AutoDetectBrokerGMT      = true;
input int    ManualBrokerGMTOffsetH   = 2;
input string NewsCurrencyFilter       = "AUTO";

//--- 7. DASHBOARD
input bool   DrawDashboard            = true;
input int    DashboardX               = 20;
input int    DashboardY               = 20;

//--- GLOBALS
int      magicNum = 0;
int      rsiHandle = INVALID_HANDLE;
int      atrHandle = INVALID_HANDLE;
double   maxReachedProfit = 0.0;
double   recoveryPeakProfit = 0.0;
bool     trailingStarted = false;
bool     recoveryTrailStarted = false;
bool     isCrashDetected = false;
datetime crashResetTime = 0;
datetime lastCrashTime = 0;
datetime lastCandleTime = 0;
datetime blockTradingUntil = 0;
datetime newsCacheUntil = 0;
bool     newsBlockedCached = false;
bool     newsFileWarned = false;
string   lastNewsTitle = "";

//+------------------------------------------------------------------+
int OnInit()
  {
   magicNum = MagicNumber;
   trade.SetExpertMagicNumber(magicNum);
   trade.SetDeviationInPoints(MaxSlippagePoints);

   rsiHandle = iRSI(_Symbol, PERIOD_M15, RSI_Period, PRICE_CLOSE);
   atrHandle = iATR(_Symbol, PERIOD_M15, ATR_Period);

   if(rsiHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
     {
      Print("Indicator handle error. RSI/ATR not created.");
      return INIT_FAILED;
     }

   Print("Sniper Gold Hybrid Recovery EA v1.22 loaded.");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(rsiHandle != INVALID_HANDLE) IndicatorRelease(rsiHandle);
   if(atrHandle != INVALID_HANDLE) IndicatorRelease(atrHandle);
   ObjectsDeleteAll(0, "HG_");
   Comment("");
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   CheckVolatilityCrash();
   if(isCrashDetected && TimeCurrent() >= crashResetTime)
      isCrashDetected = false;

   ManageBasketProfit();
   TrimStuckTrades();
   if(DrawDashboard) DrawInfoPanel();

   if(TimeCurrent() < blockTradingUntil) return;
   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > MaxSpreadPoints) return;

   datetime currentCandleTime = iTime(_Symbol, PERIOD_M15, 0);
   if(currentCandleTime == lastCandleTime) return;
   lastCandleTime = currentCandleTime;

   if(IsNewsBlocked())
     {
      Print("NEWS FILTER: new trade/recovery blocked. ", lastNewsTitle);
      return;
     }

   int openCount = CountRobotPositions();
   if(openCount > 0)
     {
      ManageAIRecovery();
     }
   else
     {
      maxReachedProfit = 0.0;
      recoveryPeakProfit = 0.0;
      trailingStarted = false;
      recoveryTrailStarted = false;

      if(isCrashDetected && BlockFirstEntryOnCrash) return;
      FindEntry();
     }
  }

//+------------------------------------------------------------------+
//| First trade: same quality model as 2nd/3rd recovery entries       |
//| Note: no recovery distance check because no previous buy exists   |
//+------------------------------------------------------------------+
void FindEntry()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   double rsi = GetRSI(1);
   double rsiLevel = GetDynamicBuyRSI();

   // Same RSI gate used before recovery entries.
   if(rsi > rsiLevel) return;

   // Same structure/reversal quality filters used by recovery trades.
   bool bearStructure = IsBearishLLLHStructure();
   bool nearLLSupport = IsNearLastLLSupport(bid);
   bool reversalOK = IsBullishRejectionCandle() || IsRSIRising();
   bool emergencyOK = false;
   bool rescueMode = false;

   int qualityScore = GetRecoveryQualityScore(rsi, rsiLevel, bearStructure,
                                              nearLLSupport, reversalOK,
                                              emergencyOK, rescueMode);

   if(qualityScore < NormalRecoveryMinScore)
     {
      Print("FIRST WAIT: score=", qualityScore,
            " need=", NormalRecoveryMinScore,
            " LLLH=", bearStructure,
            " LL=", nearLLSupport,
            " reversal=", reversalOK,
            " rsi=", DoubleToString(rsi,2),
            " level=", DoubleToString(rsiLevel,2));
      return;
     }

   if(RequireBearLLLH && !bearStructure) return;
   if(RequireLLSupport && !nearLLSupport) return;
   if(RequireBullishReversal && !reversalOK) return;

   double lot = GetLotSize(0);
   if(!HasSufficientBuyMargin(lot, ask, "FIRST BUY")) return;
   bool ok = trade.Buy(lot, _Symbol, ask, 0, 0, "Hybrid First LL Buy");
   if(ok)
      Print("FIRST BUY: mode=RECOVERY_STYLE",
            " score=", qualityScore,
            " lot=", DoubleToString(lot,2),
            " rsi=", DoubleToString(rsi,2),
            " level=", DoubleToString(rsiLevel,2),
            " LLLH=", bearStructure,
            " LL=", nearLLSupport,
            " reversal=", reversalOK);
  }

//+------------------------------------------------------------------+
//| Adaptive recovery spacing                                         |
//| openTrades=1 means next entry is trade #2                         |
//| openTrades=2 means next entry is trade #3                         |
//+------------------------------------------------------------------+
double GetAdaptiveRecoveryDistance(int openTrades, double atr)
  {
   if(openTrades <= 0 || atr <= 0.0) return 0.0;

   double distance = atr * RecoveryATRDistanceMult * (1.0 + (openTrades - 1) * RecoveryDepthStep);

   int minPoints = 0;
   if(openTrades == 1)
      minPoints = MinSecondTradeDistancePoints;
   else if(openTrades == 2)
      minPoints = MinThirdTradeDistancePoints;
   else
      minPoints = MinDeepRecoveryDistancePoints;

   if(minPoints > 0)
      distance = MathMax(distance, minPoints * _Point);

   if(UseCrashGapExpansion && IsPostCrashWideGap())
      distance = MathMax(distance, CrashRecoveryMinPoints * _Point);

   return distance;
  }

//+------------------------------------------------------------------+
//| Recovery: structure filters + Gold crash distance expansion        |
//+------------------------------------------------------------------+
void ManageAIRecovery()
  {
   int openTrades = CountRobotPositions();
   if(!AutoRecoveryDepth && openTrades >= ManualRecoveryTrades)
     {
      Print("MANUAL RECOVERY LIMIT: open=", openTrades,
            " limit=", ManualRecoveryTrades);
      return;
     }

   double lowestBuyPrice = GetLowestBuyOpenPrice();
   if(lowestBuyPrice <= 0.0) return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double atr = GetATR(1);
   if(atr <= 0.0) return;

   double adaptiveDistance = GetAdaptiveRecoveryDistance(openTrades, atr);
   if(adaptiveDistance <= 0.0) return;

   if(ask > (lowestBuyPrice - adaptiveDistance)) return;

   double rsi = GetRSI(1);
   double rsiLevel = GetDynamicBuyRSI();
   if(rsi > rsiLevel) return;

   bool bearStructure = IsBearishLLLHStructure();
   bool nearLLSupport = IsNearLastLLSupport(bid);
   bool reversalOK = IsBullishRejectionCandle() || IsRSIRising();
   bool emergencyOK = IsEmergencyRecoveryAllowed(ask, lowestBuyPrice, adaptiveDistance);
   bool rescueMode = ((openTrades + 1) >= RescueRecoveryStartTrade);
   int qualityScore = GetRecoveryQualityScore(rsi, rsiLevel, bearStructure,
                                              nearLLSupport, reversalOK,
                                              emergencyOK, rescueMode);

   if(rescueMode && qualityScore < RescueRecoveryMinScore)
     {
      Print("RESCUE WAIT: score=", qualityScore,
            " need=", RescueRecoveryMinScore,
            " LLLH=", bearStructure,
            " LL=", nearLLSupport,
            " reversal=", reversalOK);
      return;
     }

   if(!rescueMode && qualityScore < NormalRecoveryMinScore)
     {
      Print("RECOVERY WAIT: score=", qualityScore,
            " need=", NormalRecoveryMinScore,
            " LLLH=", bearStructure,
            " LL=", nearLLSupport,
            " reversal=", reversalOK);
      return;
     }

   if(!emergencyOK)
     {
     if(RequireBearLLLH && !bearStructure) return;
     if(RequireLLSupport && !nearLLSupport) return;
      if(RequireBullishReversal && !reversalOK) return;
     }

   double lot = GetRecoveryLotSize(openTrades, rescueMode);
   string comment = rescueMode ? "Hybrid Basket Rescue Buy" : (emergencyOK ? "Hybrid Emergency Recovery Buy" : "Hybrid LL Recovery Buy");
   if(!HasSufficientBuyMargin(lot, ask, "RECOVERY BUY")) return;
   bool ok = trade.Buy(lot, _Symbol, ask, 0, 0, comment);
   if(ok)
     {
      Print("RECOVERY BUY: trades=", openTrades + 1,
            " mode=", rescueMode ? "BASKET_RESCUE" : "STRUCT_RECOVERY",
            " score=", qualityScore,
            " lot=", DoubleToString(lot,2),
            " rsi=", DoubleToString(rsi,2),
            " distPts=", DoubleToString(adaptiveDistance/_Point,0),
            " LLLH=", bearStructure,
            " LL=", nearLLSupport,
            " reversal=", reversalOK,
            " emergency=", emergencyOK);
     }
  }

bool IsEmergencyRecoveryAllowed(double ask, double lowestBuyPrice, double adaptiveDistance)
  {
   if(!AllowDeepEmergencyRecovery) return false;
   if(CountRobotPositions() < 2) return false;

   double dd = GetEquityDrawdownPercent();
   if(dd < EmergencyRecoveryDDPercent) return false;

   double atr = GetATR(1);
   if(atr <= 0.0) return false;

   return(ask <= lowestBuyPrice - (atr * EmergencyRecoveryATRMult) &&
          ask <= lowestBuyPrice - adaptiveDistance);
  }

int GetRecoveryQualityScore(double rsi,
                            double rsiLevel,
                            bool bearStructure,
                            bool nearLLSupport,
                            bool reversalOK,
                            bool emergencyOK,
                            bool rescueMode)
  {
   int score = 0;
   double atrRatio = GetATRRegimeRatio();
   double dd = GetEquityDrawdownPercent();

   if(rsi <= rsiLevel) score += 20;
   if(rsi <= rsiLevel - 5.0) score += 10;
   if(bearStructure) score += 20;
   if(nearLLSupport) score += 25;
   if(reversalOK) score += 25;
   if(atrRatio >= HighATRMultiplier) score += 5;
   if(emergencyOK) score += 10;

   if(rescueMode)
     {
      if(bearStructure && nearLLSupport && reversalOK) score += 15;
      if(dd >= EmergencyRecoveryDDPercent) score += 10;
      if(!nearLLSupport) score -= 35;
      if(!reversalOK) score -= 25;
     }

   if(score < 0) score = 0;
   if(score > 100) score = 100;
   return score;
  }

double GetRecoveryLotSize(int openTrades, bool rescueMode)
  {
   if(UseBasketWeightedRescueLot && rescueMode)
     {
      double existingLots = GetTotalBuyLots();
      double rescueLot = existingLots * (RescueLotExposurePercent / 100.0);
      double baseLot = GetLotSize(0);
      double maxRescueLot = baseLot * RescueLotMaxBaseMultiple;

      if(maxRescueLot > 0.0 && rescueLot > maxRescueLot)
         rescueLot = maxRescueLot;

      return NormalizeLot(rescueLot);
     }

   return GetLotSize(openTrades);
  }

//+------------------------------------------------------------------+
//| Basket trailing + recovery close                                  |
//+------------------------------------------------------------------+
void ManageBasketProfit()
  {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);

   double limitLevel = balance * (1.0 - MaxEquityLossPercent / 100.0);
   if(balance > 0.0 && equity < limitLevel)
     {
      Print("EMERGENCY EQUITY STOP: closing basket.");
      CloseAllTrades();
      blockTradingUntil = TimeCurrent() + CrashPauseMinutes * 60;
      return;
     }

   int count = CountRobotPositions();
   if(count <= 0)
     {
      ResetBasketState();
      return;
     }

   double netProfit = GetBasketNetProfit();
   double multiplier = GetLotMultiplier();
   double target = TargetProfitUSD * multiplier;
   double step = TrailingStepUSD * multiplier;

   if(netProfit >= target)
     {
      trailingStarted = true;
      if(netProfit > maxReachedProfit) maxReachedProfit = netProfit;
     }

   if(trailingStarted && netProfit <= (maxReachedProfit - step))
     {
      Print("MAIN BASKET TRAIL CLOSE: net=", DoubleToString(netProfit,2),
            " peak=", DoubleToString(maxReachedProfit,2));
      CloseAllTrades();
      return;
     }

   if(UseRecoveryBasketTrail && count >= 2)
     {
      double start = RecoveryStartTrailUSD * multiplier;
      double give = RecoveryGivebackUSD * multiplier;

      if(netProfit >= start)
        {
         recoveryTrailStarted = true;
         if(netProfit > recoveryPeakProfit) recoveryPeakProfit = netProfit;
        }

      if(recoveryTrailStarted && recoveryPeakProfit >= start &&
         netProfit > 0.0 && netProfit <= (recoveryPeakProfit - give))
        {
         Print("RECOVERY BASKET CLOSE: net=", DoubleToString(netProfit,2),
               " peak=", DoubleToString(recoveryPeakProfit,2));
         CloseAllTrades();
         return;
        }
     }
  }

//+------------------------------------------------------------------+
//| Smart trimming                                                     |
//+------------------------------------------------------------------+
void TrimStuckTrades()
  {
   if(!EnableTrimming) return;
   int openTrades = CountRobotPositions();
   if(openTrades < 3) return;

   ulong maxProfitTicket = 0;
   ulong maxLossTicket = 0;
   double maxProfit = -999999.0;
   double maxLoss = 999999.0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(IsOurPosition(ticket))
        {
         double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
         if(profit > maxProfit)
           {
            maxProfit = profit;
            maxProfitTicket = ticket;
           }
         if(profit < maxLoss)
           {
            maxLoss = profit;
            maxLossTicket = ticket;
           }
        }
     }

   if(maxProfitTicket > 0 && maxLossTicket > 0 && maxProfitTicket != maxLossTicket)
     {
      double netTrimProfit = maxProfit + maxLoss;
      double target = TrimProfitTarget * GetLotMultiplier();
      if(maxProfit >= MinTrimWinnerUSD * GetLotMultiplier() && netTrimProfit >= target)
        {
         Print("SMART TRIM: net=", DoubleToString(netTrimProfit,2));
         trade.PositionClose(maxProfitTicket);
         trade.PositionClose(maxLossTicket);
        }
     }
  }

//+------------------------------------------------------------------+
//| News filter: calendar first, CSV optional                          |
//+------------------------------------------------------------------+
bool IsNewsBlocked()
  {
   lastNewsTitle = "";
   if(NewsMode == NEWS_OFF) return false;

   datetime now = TimeCurrent();
   if(now < newsCacheUntil)
      return newsBlockedCached;

   bool blocked = false;
   if(NewsMode == NEWS_CALENDAR || NewsMode == NEWS_BOTH)
      blocked = CheckCalendarNews();

   if(!blocked && (NewsMode == NEWS_CSV || NewsMode == NEWS_BOTH))
      blocked = CheckCSVNews();

   newsBlockedCached = blocked;
   newsCacheUntil = now + 60;
   return blocked;
  }

bool CheckCalendarNews()
  {
   datetime now = TimeCurrent();
   datetime from = now - (datetime)(NewsMinutesAfter * 60);
   datetime to = now + (datetime)(NewsMinutesBefore * 60);

   MqlCalendarValue values[];
   int count = CalendarValueHistory(values, from, to, NULL, NULL);
   if(count <= 0) return false;

   for(int i = 0; i < count; i++)
     {
      MqlCalendarEvent eventInfo;
      if(!CalendarEventById(values[i].event_id, eventInfo)) continue;

      if(NewsHighImpactOnly && eventInfo.importance != CALENDAR_IMPORTANCE_HIGH)
         continue;

      MqlCalendarCountry country;
      if(!CalendarCountryById(eventInfo.country_id, country)) continue;
      if(!IsNewsCurrencyRelevant(country.currency)) continue;

      long diffSec = (long)MathAbs((double)(now - values[i].time));
      long beforeSec = (long)NewsMinutesBefore * 60;
      long afterSec = (long)NewsMinutesAfter * 60;
      if(values[i].time >= now && diffSec <= beforeSec)
        {
         lastNewsTitle = country.currency + " HIGH " + eventInfo.name;
         return true;
        }
      if(values[i].time < now && diffSec <= afterSec)
        {
         lastNewsTitle = country.currency + " HIGH " + eventInfo.name;
         return true;
        }
     }

   return false;
  }

bool CheckCSVNews()
  {
   int handle = FileOpen(NewsCSVFileName, FILE_READ|FILE_CSV|FILE_ANSI, ',');
   if(handle == INVALID_HANDLE)
     {
      if(!newsFileWarned)
        {
         Print("NEWS CSV WARNING: ", NewsCSVFileName, " not found in MQL5/Files.");
         newsFileWarned = true;
        }
      return false;
     }

   datetime nowServer = TimeCurrent();
   int offsetSec = BrokerGMTOffsetSeconds();

   while(!FileIsEnding(handle))
     {
      string dateStr = FileReadString(handle);
      if(FileIsEnding(handle)) break;
      string timeStr = FileReadString(handle);
      string currency = FileReadString(handle);
      string impact = FileReadString(handle);
      string title = FileReadString(handle);

      if(dateStr == "" || timeStr == "") continue;
      string dlow = dateStr;
      StringToLower(dlow);
      if(StringFind(dlow, "date") >= 0) continue;

      string cur = currency;
      string imp = impact;
      StringToUpper(cur);
      StringToLower(imp);

      if(!IsNewsCurrencyRelevant(cur)) continue;
      if(NewsHighImpactOnly && StringFind(imp, "high") < 0 && StringFind(imp, "red") < 0) continue;

      datetime newsGMT = StringToTime(dateStr + " " + timeStr);
      if(newsGMT <= 0) continue;

      datetime newsServer = newsGMT + offsetSec;
      datetime blockFrom = newsServer - NewsMinutesBefore * 60;
      datetime blockTo = newsServer + NewsMinutesAfter * 60;

      if(nowServer >= blockFrom && nowServer <= blockTo)
        {
         lastNewsTitle = currency + " " + impact + " " + title;
         FileClose(handle);
         return true;
        }
     }

   FileClose(handle);
   return false;
  }

bool IsNewsCurrencyRelevant(string currency)
  {
   if(currency == "") return false;

   if(NewsCurrencyFilter != "AUTO" && StringLen(NewsCurrencyFilter) > 0)
      return(StringFind(NewsCurrencyFilter, currency) >= 0);

   string symbolName = _Symbol;
   if(StringFind(symbolName, currency) >= 0) return true;
   if((StringFind(symbolName, "XAU") >= 0 || StringFind(symbolName, "GOLD") >= 0) && currency == "USD") return true;
   if(currency == "ALL") return true;
   return false;
  }

int BrokerGMTOffsetSeconds()
  {
   if(!AutoDetectBrokerGMT) return ManualBrokerGMTOffsetH * 3600;

   datetime server = TimeTradeServer();
   datetime gmt = TimeGMT();
   int raw = (int)(server - gmt);
   int hours = (int)MathRound((double)raw / 3600.0);

   if(hours < -12 || hours > 14 || (hours == 0 && ManualBrokerGMTOffsetH != 0))
      hours = ManualBrokerGMTOffsetH;
   return hours * 3600;
  }

//+------------------------------------------------------------------+
//| Structure / reversal helpers                                      |
//+------------------------------------------------------------------+
bool IsSwingLow(int shift, int depth)
  {
   double low = iLow(_Symbol, PERIOD_M15, shift);
   if(low <= 0.0) return false;

   for(int k = 1; k <= depth; k++)
     {
      if(iLow(_Symbol, PERIOD_M15, shift - k) < low) return false;
      if(iLow(_Symbol, PERIOD_M15, shift + k) < low) return false;
     }
   return true;
  }

bool IsSwingHigh(int shift, int depth)
  {
   double high = iHigh(_Symbol, PERIOD_M15, shift);
   if(high <= 0.0) return false;

   for(int k = 1; k <= depth; k++)
     {
      if(iHigh(_Symbol, PERIOD_M15, shift - k) > high) return false;
      if(iHigh(_Symbol, PERIOD_M15, shift + k) > high) return false;
     }
   return true;
  }

bool FindSwingLowFrom(int startShift, int lookback, int depth, double &price, int &foundShift)
  {
   int bars = Bars(_Symbol, PERIOD_M15);
   int maxShift = MathMin(lookback, bars - depth - 2);
   for(int s = startShift; s <= maxShift; s++)
     {
      if(s <= depth) continue;
      if(IsSwingLow(s, depth))
        {
         price = iLow(_Symbol, PERIOD_M15, s);
         foundShift = s;
         return true;
        }
     }
   return false;
  }

bool FindSwingHighFrom(int startShift, int lookback, int depth, double &price, int &foundShift)
  {
   int bars = Bars(_Symbol, PERIOD_M15);
   int maxShift = MathMin(lookback, bars - depth - 2);
   for(int s = startShift; s <= maxShift; s++)
     {
      if(s <= depth) continue;
      if(IsSwingHigh(s, depth))
        {
         price = iHigh(_Symbol, PERIOD_M15, s);
         foundShift = s;
         return true;
        }
     }
   return false;
  }

bool IsBearishLLLHStructure()
  {
   double low1 = 0.0, low2 = 0.0, high1 = 0.0, high2 = 0.0;
   int l1 = 0, l2 = 0, h1 = 0, h2 = 0;

   if(!FindSwingLowFrom(SwingDepth + 1, StructureLookbackBars, SwingDepth, low1, l1)) return false;
   if(!FindSwingLowFrom(l1 + SwingDepth + 1, StructureLookbackBars, SwingDepth, low2, l2)) return false;
   if(!FindSwingHighFrom(SwingDepth + 1, StructureLookbackBars, SwingDepth, high1, h1)) return false;
   if(!FindSwingHighFrom(h1 + SwingDepth + 1, StructureLookbackBars, SwingDepth, high2, h2)) return false;

   return(low1 < low2 && high1 < high2);
  }

bool IsNearLastLLSupport(double price)
  {
   double lastLow = 0.0;
   int shift = 0;
   if(!FindSwingLowFrom(SwingDepth + 1, StructureLookbackBars, SwingDepth, lastLow, shift)) return false;

   double atr = GetATR(1);
   if(atr <= 0.0) return false;

   double zone = atr * 0.65;
   bool nearSupport = (price <= lastLow + zone);

   double low1 = iLow(_Symbol, PERIOD_M15, 1);
   double close1 = iClose(_Symbol, PERIOD_M15, 1);
   bool sweepBack = (low1 < lastLow - (atr * 0.10) && close1 > lastLow);

   return(nearSupport || sweepBack);
  }

bool IsBullishRejectionCandle()
  {
   double open1 = iOpen(_Symbol, PERIOD_M15, 1);
   double close1 = iClose(_Symbol, PERIOD_M15, 1);
   double high1 = iHigh(_Symbol, PERIOD_M15, 1);
   double low1 = iLow(_Symbol, PERIOD_M15, 1);

   double range = high1 - low1;
   if(range <= 0.0) return false;

   double body = MathAbs(close1 - open1);
   double lowerWick = MathMin(open1, close1) - low1;
   bool bullishClose = (close1 > open1);
   bool closeUpperHalf = (close1 > low1 + range * 0.50);
   bool strongLowerWick = (lowerWick >= range * 0.35 || lowerWick >= body * 1.2);

   return((bullishClose && closeUpperHalf) || (strongLowerWick && closeUpperHalf));
  }

bool IsRSIRising()
  {
   double rsiArray[];
   ArraySetAsSeries(rsiArray, true);
   if(CopyBuffer(rsiHandle, 0, 1, 3, rsiArray) < 3) return false;
   return(rsiArray[0] > rsiArray[1]);
  }

//+------------------------------------------------------------------+
//| Indicator / account helpers                                       |
//+------------------------------------------------------------------+
double GetRSI(int shift)
  {
   double rsiArray[];
   ArraySetAsSeries(rsiArray, true);
   if(CopyBuffer(rsiHandle, 0, shift, 1, rsiArray) < 1) return 50.0;
   return rsiArray[0];
  }

double GetATR(int shift)
  {
   double atrArray[];
   ArraySetAsSeries(atrArray, true);
   if(CopyBuffer(atrHandle, 0, shift, 1, atrArray) < 1) return 0.0;
   return atrArray[0];
  }

double GetATRAverage()
  {
   if(ATR_AvgBars <= 1) return GetATR(1);

   double atrArray[];
   ArraySetAsSeries(atrArray, true);
   int copied = CopyBuffer(atrHandle, 0, 1, ATR_AvgBars, atrArray);
   if(copied <= 0) return GetATR(1);

   double sum = 0.0;
   for(int i = 0; i < copied; i++)
      sum += atrArray[i];
   return sum / copied;
  }

double GetATRRegimeRatio()
  {
   double atr = GetATR(1);
   double avg = GetATRAverage();
   if(avg <= 0.0 || atr <= 0.0) return 1.0;
   return atr / avg;
  }

double GetDynamicBuyRSI()
  {
   double atr = GetATR(1);
   double avg = GetATRAverage();
   if(avg <= 0.0 || atr <= 0.0) return NormalBuyRSI;

   if(atr >= avg * ExtremeATRMultiplier) return ExtremeATRBuyRSI;
   if(atr >= avg * HighATRMultiplier) return HighATRBuyRSI;
   return NormalBuyRSI;
  }

double GetLotMultiplier()
  {
   double lot = GetLotSize(0);
   if(lot <= 0.0) return 1.0;
   return MathMax(1.0, lot / 0.01);
  }

double GetLotSize(int orderIndex)
  {
   double lot = FixedLotSize;
   if(UseCompoundingLot && BalancePer001Lot > 0.0)
     {
      double units = MathFloor(AccountInfoDouble(ACCOUNT_BALANCE) / BalancePer001Lot);
      if(units < 1.0) units = 1.0;
      lot = FixedLotSize * units;
     }

   if(UseRecoveryLotBoost && orderIndex > 0 && RecoveryLotMultiplier > 1.0)
      lot *= MathPow(RecoveryLotMultiplier, orderIndex);

   return NormalizeLot(lot);
  }

bool HasSufficientBuyMargin(double lot, double price, const string context)
  {
   double requiredMargin = 0.0;
   ResetLastError();
   if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, requiredMargin))
     {
      Print(context, " SKIPPED: margin calculation failed. error=", GetLastError());
      return false;
     }

   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(requiredMargin > freeMargin)
     {
      Print(context, " SKIPPED: insufficient free margin. lot=", DoubleToString(lot, LotDigits()),
            " required=", DoubleToString(requiredMargin, 2),
            " free=", DoubleToString(freeMargin, 2));
      return false;
     }

   return true;
  }

double NormalizeLot(double lot)
  {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(MaxLotCap > 0.0 && lot > MaxLotCap) lot = MaxLotCap;
   if(lot < minLot) lot = minLot;
   if(lot > maxLot) lot = maxLot;

   lot = MathFloor(lot / step) * step;
   return NormalizeDouble(lot, LotDigits());
  }

double GetTotalBuyLots()
  {
   double lots = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(IsOurPosition(ticket) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         lots += PositionGetDouble(POSITION_VOLUME);
     }
   return lots;
  }

int LotDigits()
  {
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   int digits = 0;
   while(step > 0.0 && step < 1.0 && digits < 8)
     {
      step *= 10.0;
      digits++;
     }
   return digits;
  }

double GetEquityDrawdownPercent()
  {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(balance <= 0.0) return 0.0;
   return MathMax(0.0, ((balance - equity) / balance) * 100.0);
  }

int CountRobotPositions()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(IsOurPosition(ticket))
         count++;
     }
   return count;
  }

double GetBasketNetProfit()
  {
   double net = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(IsOurPosition(ticket))
         net += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
   return net;
  }

double GetLowestBuyOpenPrice()
  {
   double lowest = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(IsOurPosition(ticket))
        {
         if(PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY) continue;
         double price = PositionGetDouble(POSITION_PRICE_OPEN);
         if(lowest == 0.0 || price < lowest) lowest = price;
        }
     }
   return lowest;
  }

double GetBasketBreakeven()
  {
   double weighted = 0.0;
   double lots = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(IsOurPosition(ticket) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         double lot = PositionGetDouble(POSITION_VOLUME);
         weighted += PositionGetDouble(POSITION_PRICE_OPEN) * lot;
         lots += lot;
        }
     }

   if(lots <= 0.0) return 0.0;
   return weighted / lots;
  }

double GetNextRecoveryPrice()
  {
   int openTrades = CountRobotPositions();
   double lowestBuyPrice = GetLowestBuyOpenPrice();
   double atr = GetATR(1);
   if(openTrades <= 0 || lowestBuyPrice <= 0.0 || atr <= 0.0) return 0.0;

   double distance = GetAdaptiveRecoveryDistance(openTrades, atr);
   if(distance <= 0.0) return 0.0;
   return lowestBuyPrice - distance;
  }

void CloseAllTrades()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(IsOurPosition(ticket))
         trade.PositionClose(ticket);
     }
   ResetBasketState();
  }

void ResetBasketState()
  {
   maxReachedProfit = 0.0;
   recoveryPeakProfit = 0.0;
   trailingStarted = false;
   recoveryTrailStarted = false;
  }

bool IsOurPosition(ulong ticket)
  {
   if(ticket == 0) return false;
   if(!PositionSelectByTicket(ticket)) return false;
   if(PositionGetInteger(POSITION_MAGIC) != magicNum) return false;
   if(ManageCurrentSymbolOnly && PositionGetString(POSITION_SYMBOL) != _Symbol) return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Crash sensor + dashboard                                          |
//+------------------------------------------------------------------+
void CheckVolatilityCrash()
  {
   static double lastPrice = 0.0;
   static datetime lastTime = 0;
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   datetime now = TimeCurrent();

   if(lastPrice > 0.0 && lastTime > 0)
     {
      double seconds = (double)(now - lastTime);
      if(seconds < 1.0) seconds = 1.0;
      double movePerSec = (MathAbs(currentPrice - lastPrice) / _Point) / seconds;

      if(movePerSec > MaxPipsPerSec)
        {
         isCrashDetected = true;
         lastCrashTime = now;
         crashResetTime = now + CrashPauseMinutes * 60;
         Print("Crash sensor active. Move/sec=", DoubleToString(movePerSec,1),
               ". Pause until ", TimeToString(crashResetTime));
        }
     }

   lastPrice = currentPrice;
   lastTime = now;
  }

bool IsPostCrashWideGap()
  {
   if(lastCrashTime <= 0) return false;
   return(TimeCurrent() <= lastCrashTime + PostCrashWideGapMinutes * 60);
  }

void DrawInfoPanel()
  {
   ObjectsDeleteAll(0, "HG_");

   int y = DashboardY;
   double net = GetBasketNetProfit();
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double dd = GetEquityDrawdownPercent();
   int count = CountRobotPositions();
   string status = isCrashDetected ? "CRASH PAUSE" : (IsPostCrashWideGap() ? "POST-CRASH WIDE GAP" : "RUNNING");
   color statusColor = isCrashDetected ? clrRed : (IsPostCrashWideGap() ? clrOrange : clrSpringGreen);

   string depthMode = AutoRecoveryDepth ? "AUTO ATR/LL" : ("MANUAL " + IntegerToString(ManualRecoveryTrades));
   DrawLabel("HG_Title", "SNIPER GOLD HYBRID v1.22", DashboardX, y, 11, clrGold); y += 20;
   DrawLabel("HG_Status", "STATUS: " + status, DashboardX, y, 9, statusColor); y += 18;
   DrawLabel("HG_Pos", "POSITIONS: " + IntegerToString(count) + " | DEPTH: " + depthMode, DashboardX, y, 9, clrWhite); y += 18;
   DrawLabel("HG_Net", "BASKET NET: $" + DoubleToString(net, 2), DashboardX, y, 9, net >= 0 ? clrSpringGreen : clrTomato); y += 18;
   DrawLabel("HG_Equity", "EQUITY: $" + DoubleToString(equity, 2) + " | DD: " + DoubleToString(dd, 1) + "%", DashboardX, y, 9, clrCyan); y += 18;
   DrawLabel("HG_RSI", "RSI: " + DoubleToString(GetRSI(1), 2) + " | BUY LVL: " + DoubleToString(GetDynamicBuyRSI(), 2), DashboardX, y, 9, clrWhite); y += 18;
   DrawLabel("HG_ATR", "ATR: " + DoubleToString(GetATR(1) / _Point, 0) + " pts | RATIO: " + DoubleToString(GetATRRegimeRatio(), 2), DashboardX, y, 9, clrWhite); y += 18;
   DrawLabel("HG_Next", "NEXT REC: " + DoubleToString(GetNextRecoveryPrice(), _Digits) + " | RESCUE LOT: " + DoubleToString(GetRecoveryLotSize(count, true), 2), DashboardX, y, 9, clrWhite); y += 18;
   DrawLabel("HG_BE", "BREAKEVEN: " + DoubleToString(GetBasketBreakeven(), _Digits), DashboardX, y, 9, clrWhite); y += 18;
   DrawLabel("HG_News", "NEWS: " + (IsNewsBlocked() ? ("BLOCKED " + lastNewsTitle) : "SAFE"), DashboardX, y, 9, IsNewsBlocked() ? clrOrangeRed : clrSpringGreen);
  }

void DrawLabel(string name, string text, int x, int y, int size, color clr)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);

   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
  }
//+------------------------------------------------------------------+
