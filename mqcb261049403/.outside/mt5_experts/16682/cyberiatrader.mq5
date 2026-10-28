//+------------------------------------------------------------------+
//|                       CyberiaTrader(barabashkakvn's edition).mq5 |
//|        #property copyright "Copyright c 2006, Cyberia Decisions" |
//|                           #property link "http://cyberia.org.ru" |
//+------------------------------------------------------------------+
#property copyright "Copyright c 2006, Cyberia Decisions"
#property link      "http://cyberia.org.ru"
#property version   "1.001"

#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
CSymbolInfo    m_symbol;               // symbol info object
CAccountInfo   m_account;              // account info wrapper
CTrade         m_trade;                // trading object
CPositionInfo  m_position;             // trade position object

#define DECISION_BUY 1
#define DECISION_SELL 0
#define DECISION_UNKNOWN -1

#define MODE_PLUSDI 1
#define MODE_MINUSDI 2

#define MODE_UPPER 0
#define MODE_LOWER 1

#define MODE_MAIN 0

//--- input parameters
input bool ExitMarket=false;
input bool ShowSuitablePeriod=false;
input bool ShowMarketInfo=false;
input bool ShowAccountStatus=false;
input bool ShowStat=false;
input bool ShowDecision=false;
input bool ShowDirection=false;
input bool BlockSell= false;
input bool BlockBuy = false;
input bool ShowLots = false;
input bool BlockStopLoss=false;
input bool DisableShadowStopLoss=true;
input bool DisableExitSell= false;
input bool DisableExitBuy = false;
input bool EnableMACD=false;
input bool EnableMA=false;
input bool EnableFractals=false;
input bool EnableCCI=false;
input bool EnableCyberiaLogic = true;
input bool EnableLogicTrading = true;
input bool EnableADX=false;
input bool BlockPipsator=true;
input bool EnableMoneyTrain=false;
input bool EnableReverceDetector=false;
input double ReverceIndex=3;
input double MoneyTrainLevel=4;
input int MACDLevel = 10;
input bool AutoLots = true;
input bool AutoDirection=true;
input double ValuesPeriodCount=6;
input double ValuesPeriodCountMax=6;
double SlipPage=1;
input double Lots=0.1;                 // lots
double StopLoss=0;
double TakeProfit=0;
input double SymbolsCount=1;
input double Risk=0.5;
input double StopLossIndex=1.1;
input bool AutoStopLossIndex= true;
input double StaticStopLoss = 7;
double StopLevel;

bool DisableSell= false;
bool DisableBuy = false;
bool ExitSell= false;
bool ExitBuy = false;
double Disperce=0;
double DisperceMax=0;
bool DisableSellPipsator= false;
bool DisableBuyPipsator = false;
//---
int ValuePeriod=1;
double ValuePeriodPrev=1;
int FoundOpenedPosition=false;
bool DisablePipsator=false;
double BidPrev = 0;
double AskPrev = 0;
//--- variables for assessment of quality of modeling
double BuyPossibilityQuality;
double SellPossibilityQuality;
double UndefinedPossibilityQuality;
double PossibilityQuality;
double QualityMax=0;
//---
double BuySucPossibilityQuality;
double SellSucPossibilityQuality;
double UndefinedSucPossibilityQuality;
double PossibilitySucQuality;
//---
double ModelingPeriod;
double ModelingBars;
//---
double Spread;
int Decision;
double DecisionValue;
double PrevDecisionValue;
//---
ulong m_ticket;
int pos_total,cnt;
//---
double BuyPossibility;
double SellPossibility;
double UndefinedPossibility;
double BuyPossibilityPrev;
double SellPossibilityPrev;
double UndefinedPossibilityPrev;
//---
double BuySucPossibilityMid; // средняя вероятность успешной покупки // average probability of successful purchase
double SellSucPossibilityMid; // средняя вероятность успешной продажи // average probability of successful sale
double UndefinedSucPossibilityMid; // средняя успешная вероятность неопределенного состояния // average successful probability of an uncertain state
//---
double SellSucPossibilityCount; // количество вероятностей успешной продажи // amount of probabilities of successful sale
double BuySucPossibilityCount; // количество вероятностей успешной покупки // amount of probabilities of successful purchase
double UndefinedSucPossibilityCount; // количество вероятностей неопределенного состояния // amount of probabilities of an uncertain state
//---
double BuyPossibilityMid; // средняя вероятность покупки // average probability of purchase
double SellPossibilityMid; // средняя вероятность продажи // average probability of sale
double UndefinedPossibilityMid; // средняя вероятность неопределенного состояния // average probability of an uncertain state
//---
double SellPossibilityCount; // количество вероятностей продажи // amount of probabilities of sale
double BuyPossibilityCount; // количество вероятностей покупки // amount of probabilities of purchase
double UndefinedPossibilityCount; // количество вероятностей неопределенного состояния // amount of probabilities of an uncertain state
//--- переменные для хранения информация о рынке //--- variables for storage information on the market
double ModeLow;
double ModeHigh;
datetime ModeTime;
double ModeBid;
double ModeAsk;
double ModePoint;
int ModeDigits;
int ModeSpread;
int ModeStopLevel;
double ModeLotSize;
double ModeTickValue;
double ModeTickSize;
double ModeSwapLong;
double ModeSwapShort;
datetime ModeStarting;
datetime ModeExpiration;
ENUM_SYMBOL_TRADE_MODE ModeTradeAllowed;
double ModeMinLot;
double ModeLotStep;
//---
double ExtLots=0.0;
bool   ExtBlockBuy=false;
bool   ExtBlockSell=false;
bool   ExtDisableExitSell= false;
bool   ExtDisableExitBuy = false;
double ExtStopLoss=0;
double ExtStopLevel;
double ExtValuesPeriodCount=23;
double ExtStopLossIndex=1.1;
int    handle_iADX;        // variable for storing the handle of the iADX indicator 
int    handle_iCCI;        // variable for storing the handle of the iCCI indicator 
int    handle_iFractals;   // variable for storing the handle of the iFractals indicator 
int    handle_iMA;         // variable for storing the handle of the iMA indicator 
int    handle_iMACD;       // variable for storing the handle of the iMACD indicator 
//+------------------------------------------------------------------+
//| Считываем информацию о рынке                                     |
//| We read out information on the market                            |
//+------------------------------------------------------------------+
int GetMarketInfo()
  {
//--- refresh rates
   m_symbol.Refresh();
   if(!m_symbol.RefreshRates())
      return(0);
//--- read the information on the market
   ModeLow=m_symbol.BidLow();
   ModeHigh = m_symbol.BidHigh();
   ModeTime = m_symbol.Time();
   ModeBid = m_symbol.Bid();
   ModeAsk = m_symbol.Ask();
   ModePoint=m_symbol.Point();
   ModeDigits = m_symbol.Digits();
   ModeSpread = m_symbol.Spread();
   ModeStopLevel=m_symbol.StopsLevel();
   ModeLotSize=m_symbol.ContractSize();
   ModeTickValue= m_symbol.TickValue();
   ModeTickSize = m_symbol.TickSize();
   ModeSwapLong = m_symbol.SwapLong();
   ModeSwapShort= m_symbol.SwapShort();
   m_symbol.InfoInteger(SYMBOL_START_TIME,ModeStarting);
   m_symbol.InfoInteger(SYMBOL_EXPIRATION_TIME,ModeExpiration);
   ModeTradeAllowed=m_symbol.TradeMode();
   ModeMinLot=m_symbol.LotsMin();
   ModeLotStep=m_symbol.LotsStep();
//--- выводим информацию о рынке //--- we output information on the market
   if(ShowMarketInfo)
     {
      Print("ModeLow:",DoubleToString(ModeLow,Digits()));
      Print("ModeHigh:",DoubleToString(ModeHigh,Digits()));
      Print("ModeTime:",TimeToString(ModeTime,TIME_DATE|TIME_MINUTES));
      Print("ModeBid:",DoubleToString(ModeBid,Digits()));
      Print("ModeAsk:",DoubleToString(ModeAsk,Digits()));
      Print("ModePoint:",DoubleToString(ModePoint,Digits()));
      Print("ModeDigits:",ModeDigits);
      Print("ModeSpread:",ModeSpread);
      Print("ModeStopLevel:",ModeStopLevel);
      Print("ModeLotSize:",DoubleToString(ModeLotSize,2));
      Print("ModeTickValue:",DoubleToString(ModeTickValue,Digits()));
      Print("ModeTickSize:",DoubleToString(ModeTickSize,Digits()));
      Print("ModeSwapLong:",DoubleToString(ModeSwapLong,Digits()));
      Print("ModeSwapShort:",DoubleToString(ModeSwapShort,Digits()));
      Print("ModeStarting:",TimeToString(ModeStarting,TIME_DATE|TIME_MINUTES));
      Print("ModeExpiration:",TimeToString(ModeExpiration,TIME_DATE|TIME_MINUTES));
      Print("ModeTradeAllowed:",EnumToString(ModeTradeAllowed));
      Print("ModeMinLot:",DoubleToString(ModeMinLot,2));
      Print("ModeLotStep:",DoubleToString(ModeLotStep,2));
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Расчет количества лотов                                          |
//| Calculation of quantity of lots                                  |
//+------------------------------------------------------------------+
int CyberiaLots()
  {
   GetMarketInfo();
   double S;                           // сумма счета // account sum
   if(AutoLots==true)                  // стоимость одного пункта // cost of one point
     {
      if(SymbolsCount!=PositionsTotal())
        {
         S=(m_account.Balance()*Risk-m_account.Margin())*m_account.Leverage()/
           (SymbolsCount-PositionsTotal());
        }
      else
        {
         S=0;
        }
      //--- проверяем, является ли валюта по евро // we check whether the currency for euro is
      if(ModeBid==0) // защита от деления на ноль // protection against division into zero
         return(0);
      if(StringFind(Symbol(),"USD",0)==-1)
        {
         if(StringFind(Symbol(),"EUR",0)==-1)
           {
            S=0;
           }
         else
           {
            S=S/iClose("EURUSD",0,0);
            if(StringFind(Symbol(),"EUR",0)!=0)
              {
               S/=ModeBid;
              }
           }
        }
      else
        {
         if(StringFind(Symbol(),"USD",0)!=0)
           {
            S/=ModeBid;
           }
        }
      S /= ModeLotSize;
      S -= ModeMinLot;
      S /= ModeLotStep;
      S=NormalizeDouble(S,0);
      S *= ModeLotStep;
      S += ModeMinLot;
      ExtLots=S;
      if(ShowLots==true)
         Print("Lots:",ExtLots);
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   m_symbol.Name(Symbol());         // sets symbol name
   ExtLots=Lots;
   ExtBlockBuy=BlockBuy;
   ExtBlockSell=BlockSell;
   ExtDisableExitSell=DisableExitSell;
   ExtDisableExitBuy=DisableExitBuy;
   ExtValuesPeriodCount=ValuesPeriodCount;
   ExtStopLossIndex=StopLossIndex;
   ExtStopLoss=StopLoss;

//--- create handle of the indicator iADX
   handle_iADX=iADX(Symbol(),PERIOD_CURRENT,14);
//--- if the handle is not created 
   if(handle_iADX==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iADX indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_CURRENT),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

//--- create handle of the indicator iCCI
   handle_iCCI=iCCI(Symbol(),PERIOD_CURRENT,13,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iCCI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_CURRENT),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

//--- create handle of the indicator iFractals
   handle_iFractals=iFractals(Symbol(),PERIOD_CURRENT);
//--- if the handle is not created 
   if(handle_iFractals==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iFractals indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_CURRENT),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_CURRENT),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(Symbol(),PERIOD_CURRENT,2,4,1,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_CURRENT),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

   m_symbol.Name(Symbol());         // sets symbol name
   Initialization();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Calculate real Spread                                            |
//+------------------------------------------------------------------+
int CalculateSpread()
  {
   Spread=ModeAsk-ModeBid;
   return (0);
  }
//+------------------------------------------------------------------+
//| Calculate Possibility                                            |
//+------------------------------------------------------------------+
int CalculatePossibility(int shift)
  {
   DecisionValue=iClose(Symbol(),0,ValuePeriod*shift) -
                 iOpen(Symbol(),0,ValuePeriod*shift);
   PrevDecisionValue=iClose(Symbol(),0,ValuePeriod *(shift+1)) -
                     iOpen(Symbol(),0,ValuePeriod *(shift+1));
   SellPossibility= 0;
   BuyPossibility = 0;
   UndefinedPossibility=0;
   if(DecisionValue!=0) // если решение не определенно // if the decision isn't certain
     {
      if(DecisionValue>0) // если решение в пользу продажи // if the decision in favor of sale
        {
         //--- подозрение на вероятность продажи // suspicion on probability of sale
         if(PrevDecisionValue<0) // подтверждение решения в пользу продажи // confirmation of the decision in favor of sale
           {
            Decision=DECISION_SELL;
            BuyPossibility=0;
            SellPossibility=DecisionValue;
            UndefinedPossibility=0;
           }
         else                          // иначе решение не определено // otherwise the decision isn't defined
           {
            Decision=DECISION_UNKNOWN;
            UndefinedPossibility=DecisionValue;
            BuyPossibility=0;
            SellPossibility=0;
           }
        }
      else                             // если решение в пользу покупки // if the decision in favor of purchase
        {
         if(PrevDecisionValue>0) // подтверждение решения в пользу продажи // confirmation of the decision in favor of sale
           {
            Decision=DECISION_BUY;
            SellPossibility=0;
            UndefinedPossibility=0;
            BuyPossibility=-1*DecisionValue;
           }
         else                          // решение не определено // the decision isn't defined
           {
            Decision=DECISION_UNKNOWN;
            UndefinedPossibility=-1*DecisionValue;
            SellPossibility= 0;
            BuyPossibility = 0;
           }
        }
     }
   else
     {
      Decision=DECISION_UNKNOWN;
      UndefinedPossibility=0;
      SellPossibility= 0;
      BuyPossibility = 0;
     }
   return (Decision);
  }
//+------------------------------------------------------------------+
//| Вычисляем статистику вероятностей                                |
//| Calculate statistics of probabilities                            |
//+------------------------------------------------------------------+
int CalculatePossibilityStat()
  {
   int i;
   BuySucPossibilityCount=0;
   SellSucPossibilityCount=0;
   UndefinedSucPossibilityCount=0;
//---
   BuyPossibilityCount=0;
   SellPossibilityCount=0;
   UndefinedPossibilityCount=0;
//--- вычисляем средние значения вероятности // we calculate average values of probability
   BuySucPossibilityMid=0;
   SellSucPossibilityMid=0;
   UndefinedSucPossibilityMid=0;
   BuyPossibilityQuality=0;
   SellPossibilityQuality=0;
   UndefinedPossibilityQuality=0;
   PossibilityQuality=0;
//---
   BuySucPossibilityQuality=0;
   SellSucPossibilityQuality=0;
   UndefinedSucPossibilityQuality=0;
   PossibilitySucQuality=0;
   for(i=0; i<ModelingBars; i++)
     {
      //--- вычисляем решение для данного интервала // we calculate the decision for this interval
      CalculatePossibility(i);
      //--- если решение для значения i - продавать // if - to sell the decision for value i         
      if(Decision==DECISION_SELL)
         SellPossibilityQuality++;
      //--- если решение для значения i - покупать // if - to buy the decision for value i
      if(Decision==DECISION_BUY)
         BuyPossibilityQuality++;
      //--- если решение для значения i - не определено // if the decision for value i - isn't defined
      if(Decision==DECISION_UNKNOWN)
         UndefinedPossibilityQuality++;
      //--- те же оценки для успешных ситуаций // the same estimates for successful situations              
      if((BuyPossibility>Spread) || (SellPossibility>Spread) || 
         (UndefinedPossibility>Spread))
        {
         if(Decision==DECISION_SELL)
            SellSucPossibilityQuality++;
         if(Decision==DECISION_BUY)
            BuySucPossibilityQuality++;
         if(Decision==DECISION_UNKNOWN)
            UndefinedSucPossibilityQuality++;
        }
      //--- вычисляем средние вероятности событий // we calculate average probabilities of events
      //--- вероятности покупки // probabilities of purchase
      BuyPossibilityMid*=BuyPossibilityCount;
      BuyPossibilityCount++;
      BuyPossibilityMid+=BuyPossibility;
      if(BuyPossibilityCount!=0)
         BuyPossibilityMid/=BuyPossibilityCount;
      else
         BuyPossibilityMid=0;
      //--- вероятности продажи // probabilities of sale
      SellPossibilityMid*=SellPossibilityCount;
      SellPossibilityCount++;
      SellPossibilityMid+=SellPossibility;
      if(SellPossibilityCount!=0)
         SellPossibilityMid/=SellPossibilityCount;
      else
         SellPossibilityMid=0;
      //--- вероятности неопределенного состояния // probabilities of an uncertain state
      UndefinedPossibilityMid*=UndefinedPossibilityCount;
      UndefinedPossibilityCount++;
      UndefinedPossibilityMid+=UndefinedPossibility;
      if(UndefinedPossibilityCount!=0)
         UndefinedPossibilityMid/=UndefinedPossibilityCount;
      else
         UndefinedPossibilityMid=0;
      //--- вычисляем средние вероятности успешных событий // we calculate average probabilities of successful events
      if(BuyPossibility>Spread)
        {
         BuySucPossibilityMid*=BuySucPossibilityCount;
         BuySucPossibilityCount++;
         BuySucPossibilityMid+=BuyPossibility;
         if(BuySucPossibilityCount!=0)
            BuySucPossibilityMid/=BuySucPossibilityCount;
         else
            BuySucPossibilityMid=0;
        }
      if(SellPossibility>Spread)
        {
         SellSucPossibilityMid*=SellSucPossibilityCount;
         SellSucPossibilityCount++;
         SellSucPossibilityMid+=SellPossibility;
         if(SellSucPossibilityCount!=0)
            SellSucPossibilityMid/=SellSucPossibilityCount;
         else
            SellSucPossibilityMid=0;
        }
      if(UndefinedPossibility>Spread)
        {
         UndefinedSucPossibilityMid*=UndefinedSucPossibilityCount;
         UndefinedSucPossibilityCount++;
         UndefinedSucPossibilityMid+=UndefinedPossibility;
         if(UndefinedSucPossibilityCount!=0)
            UndefinedSucPossibilityMid/=UndefinedSucPossibilityCount;
         else
            UndefinedSucPossibilityMid=0;
        }
     }
   if((UndefinedPossibilityQuality+SellPossibilityQuality+BuyPossibilityQuality)!=0)
      PossibilityQuality=(SellPossibilityQuality+BuyPossibilityQuality)/
                         (UndefinedPossibilityQuality+SellPossibilityQuality+BuyPossibilityQuality);
   else
      PossibilityQuality=0;
//--- качество для успешных ситуаций // quality for successful situations
   if((UndefinedSucPossibilityQuality+SellSucPossibilityQuality+
      BuySucPossibilityQuality)!=0)
      PossibilitySucQuality=(SellSucPossibilityQuality+BuySucPossibilityQuality)/
                            (UndefinedSucPossibilityQuality+SellSucPossibilityQuality+
                            BuySucPossibilityQuality);
   else
      PossibilitySucQuality=0;
   return (0);
  }
//+------------------------------------------------------------------+
//| Display Stats                                                    |
//+------------------------------------------------------------------+
int DisplayStat()
  {
   if(ShowStat==true)
     {
      Print("SellPossibilityMid*SellPossibilityQuality:",SellPossibilityMid*SellPossibilityQuality);
      Print("BuyPossibilityMid*BuyPossibilityQuality:",BuyPossibilityMid*BuyPossibilityQuality);
      Print("UndefinedPossibilityMid*UndefinedPossibilityQuality:",UndefinedPossibilityMid*UndefinedPossibilityQuality);
      Print("UndefinedSucPossibilityQuality:",UndefinedSucPossibilityQuality);
      Print("SellSucPossibilityQuality:",SellSucPossibilityQuality);
      Print("BuySucPossibilityQuality:",BuySucPossibilityQuality);
      Print("UndefinedPossibilityQuality:",UndefinedPossibilityQuality);
      Print("SellPossibilityQuality:",SellPossibilityQuality);
      Print("BuyPossibilityQuality:",BuyPossibilityQuality);
      Print("UndefinedSucPossibilityMid:",UndefinedSucPossibilityMid);
      Print("SellSucPossibilityMid:",SellSucPossibilityMid);
      Print("BuySucPossibilityMid:",BuySucPossibilityMid);
      Print("UndefinedPossibilityMid:",UndefinedPossibilityMid);
      Print("SellPossibilityMid:",SellPossibilityMid);
      Print("BuyPossibilityMid:",BuyPossibilityMid);
     }
   return (0);
  }   // 
//+------------------------------------------------------------------+
//| Анализируем состояние для принятия решения                       |
//| Analyze a state for decision-making                              |
//+------------------------------------------------------------------+
int CyberiaDecision()
  {
// Вычисляем статистику периода
   CalculatePossibilityStat();
// Вычисляем вероятности совершения сделок
   CalculatePossibility(0);
   DisplayStat();
   return(Decision);
  }
//+------------------------------------------------------------------+
//| Calculate Direction of Market                                    |
//+------------------------------------------------------------------+
int CalculateDirection()
  {
   DisableSellPipsator= false;
   DisableBuyPipsator = false;
   DisablePipsator=false;
   DisableSell= false;
   DisableBuy = false;
//----
   if(EnableCyberiaLogic==true)
     {
      AskCyberiaLogic();
     }
   if(EnableMACD==true)
      AskMACD();
   if(EnableMA==true)
      AskMA();
   if(EnableReverceDetector==true)
      ReverceDetector();
   if(EnableFractals==true)
      AskFractals();
   if(EnableCCI==true)
      AskCCI();
   if(EnableADX==true)
      AskADX();
   return (0);
  }
//+------------------------------------------------------------------+
//| Ask iADX                                                         |
//+------------------------------------------------------------------+
int AskADX()
  {
   if(iADXGet(MODE_PLUSDI,0)>iADXGet(MODE_MINUSDI,0))
     {
      DisableSell=true;
     }

   if(iADXGet(MODE_PLUSDI,0)<iADXGet(MODE_MINUSDI,0))
     {
      DisableBuy=true;
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Ask iCCI                                                         |
//+------------------------------------------------------------------+
int AskCCI()
  {
   if(iCCIGet(0)<-100)
      DisableSell=true;

   if(iCCIGet(0)>1000)
      DisableBuy=true;

   return (0);
  }
//+------------------------------------------------------------------+
//| Фрактальное торможение                                           |
//| Fractal braking                                                  |
//+------------------------------------------------------------------+
int AskFractals()
  {
   int i=0;

   double F=0;
   while(iFractalsGet(MODE_UPPER,i)==0 && iFractalsGet(MODE_LOWER,i)==0)
     {
      i++;
     }

   if(iFractalsGet(MODE_UPPER,i)!=0)
     {
      ExtBlockBuy=true;
      ExtBlockSell=false;
     }

   if(iFractalsGet(MODE_LOWER,i)!=0)
     {
      ExtBlockSell= true;
      ExtBlockBuy = false;
     }

   return (0);
  }
//+------------------------------------------------------------------+
//| Если вероятности превышают пороги инвертирования решения         |
//| If probabilities exceed thresholds of inverting of the decision  |
//+------------------------------------------------------------------+
int ReverceDetector()
  {
   if((BuyPossibility>BuyPossibilityMid*ReverceIndex && BuyPossibility!=0 && 
      BuyPossibilityMid!=0) || (SellPossibility>SellPossibilityMid*ReverceIndex && 
      SellPossibility!=0 && SellPossibilityMid!=0))
     {
      if(DisableSell==true)
         DisableSell=false;
      else
         DisableSell=true;
      if(DisableBuy==true)
         DisableBuy=false;
      else
         DisableBuy=true;
      //----
      if(DisableSellPipsator==true)
         DisableSellPipsator=false;
      else
         DisableSellPipsator=true;
      if(DisableBuyPipsator==true)
         DisableBuyPipsator=false;
      else
         DisableBuyPipsator=true;
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Опрашиваем логику торговли CyberiaLogic(C)                       |
//| Interview logic of trade of CyberiaLogic (C)                     |
//+------------------------------------------------------------------+
int AskCyberiaLogic()
  {
//--- устанавливаем блокировки при падениях рынка // we establish blocking when falling market
//--- если рынок равномерно движется в заданном направлении // if the market regularly moves in the set direction
   if(ValuePeriod>ValuePeriodPrev)
     {
      if(SellPossibilityMid*SellPossibilityQuality>BuyPossibilityMid*BuyPossibilityQuality)
        {
         DisableSell= false;
         DisableBuy = true;
         DisableBuyPipsator=true;
         if(SellSucPossibilityMid*SellSucPossibilityQuality>
            BuySucPossibilityMid*BuySucPossibilityQuality)
           {
            DisableSell=true;
           }
        }
      if(SellPossibilityMid*SellPossibilityQuality<BuyPossibilityMid*BuyPossibilityQuality)
        {
         DisableSell= true;
         DisableBuy = false;
         DisableSellPipsator=true;
         if(SellSucPossibilityMid*SellSucPossibilityQuality<
            BuySucPossibilityMid*BuySucPossibilityQuality)
           {
            DisableBuy=true;
           }
        }
     }
//--- если рынок меняет направление - никогда не торгуй против тренда!!! // if the market changes the direction - never trade against a trend!!!
   if(ValuePeriod<ValuePeriodPrev)
     {
      if(SellPossibilityMid*SellPossibilityQuality>BuyPossibilityMid*BuyPossibilityQuality)
        {
         DisableSell= true;
         DisableBuy = true;
        }
      if(SellPossibilityMid*SellPossibilityQuality<BuyPossibilityMid*BuyPossibilityQuality)
        {
         DisableSell= true;
         DisableBuy = true;
        }
     }
//--- если рынок горизонтальный // if market horizontal
   if(SellPossibilityMid*SellPossibilityQuality==BuyPossibilityMid*BuyPossibilityQuality)
     {
      DisableSell= true;
      DisableBuy = true;
      DisablePipsator=false;
     }
//--- блокируем вероятность выхода из рынка // we block probability of an exit from the market
   if(SellPossibility>SellSucPossibilityMid*2 && SellSucPossibilityMid>0)
     {
      DisableSell=true;
      DisableSellPipsator=true;
     }
//--- блокируем вероятность выхода из рынка // we block probability of an exit from the market
   if(BuyPossibility>BuySucPossibilityMid*2 && BuySucPossibilityMid>0)
     {
      DisableBuy=true;
      DisableBuyPipsator=true;
     }
   if(ShowDirection==true)
     {
      if(DisableSell==true)
        {
         Print("Sale is blocked: ",SellPossibilityMid*SellPossibilityQuality);
        }
      else
        {
         Print("Sale is allowed: ",SellPossibilityMid*SellPossibilityQuality);
        }
      //----
      if(DisableBuy==true)
        {
         Print("Purchase is blocked: ",BuyPossibilityMid*BuyPossibilityQuality);
        }
      else
        {
         Print("Purchase is allowed: ",BuyPossibilityMid*BuyPossibilityQuality);
        }
     }
   if(ShowDecision==true)
     {
      if(Decision==DECISION_SELL)
         Print("The decision - to sell: ",DecisionValue);
      if(Decision==DECISION_BUY)
         Print("The decision - to buy: ",DecisionValue);
      if(Decision==DECISION_UNKNOWN)
         Print("The decision - uncertainty: ",DecisionValue);
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Ask iMA                                                          |
//+------------------------------------------------------------------+
int AskMA()
  {
   if(iMAGet(0)>iMAGet(1))
     {
      DisableSell=true;
      DisableSellPipsator=true;
     }
   if(iMAGet(0)<iMAGet(1))
     {
      DisableBuy=true;
      DisableBuyPipsator=true;
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Ask iMACD                                                        |
//+------------------------------------------------------------------+
int AskMACD()
  {
   double DecisionIndex=0;
   double SellIndex= 0;
   double BuyIndex = 0;
   double BuyVector= 0;
   double SellVector= 0;
   double BuyResult = 0;
   double SellResult= 0;
   DisablePipsator=false;
   DisableSellPipsator= false;
   DisableBuyPipsator = false;
   DisableBuy=false;
   DisableSell=false;
   ExtDisableExitSell= false;
   ExtDisableExitBuy = false;
//--- блокируем ошибки // block mistakes
   if(iMACDGet(MODE_MAIN,0)<iMACDGet(MODE_MAIN,1))
     {
      SellIndex+=iMACDGet(MODE_MAIN,0);
     }
   if(iMACDGet(MODE_MAIN,0)>iMACDGet(MODE_MAIN,1))
     {
      BuyIndex+=iMACDGet(MODE_MAIN,0);
     }

   if(SellIndex>BuyIndex)
     {
      DisableBuy=true;
      DisableBuyPipsator=true;
     }
   if(SellIndex<BuyIndex)
     {
      DisableSell=true;
      DisableSellPipsator=true;
     }
   return (0);
  }
//+------------------------------------------------------------------------+
//| Ловим рыночные ГЭП - (включается непосредственно перед выходом новостей|
//| We catch market the GAP - (joins just before an exit of news           |
//+------------------------------------------------------------------------+
int MoneyTrain()
  {
   if(FoundOpenedPosition==false)
     {
      //--- считаем дисперсию // we consider dispersion
      Disperce=(iHigh(Symbol(),0,0)-iLow(Symbol(),0,0));
      if(Decision==DECISION_SELL)
        {
         // *** Впрыгиваем в паровоз по направлению движения хаоса рынка ***
         // *** We jump into a steam locomotive in the direction of movement of chaos of the market ***
         if((iClose(Symbol(),0,0)-iClose(Symbol(),0,ValuePeriod))/
            MoneyTrainLevel >= SellSucPossibilityMid && SellSucPossibilityMid != 0 &&
            EnableMoneyTrain == true)
           {
            ModeSpread=ModeSpread+1;
            //--- расчет стоп-лосс // calculation stop loss
            if((ModeBid-SellSucPossibilityMid*ExtStopLossIndex-ModeSpread*ModePoint)>
               (ModeBid-ModeStopLevel *ModePoint-ModeSpread*ModePoint))
              {
               ExtStopLoss=ModeBid-ModeStopLevel *ModePoint-ModeSpread*ModePoint-Disperce;
              }
            else
              {
               if(SellSucPossibilityMid!=0)
                  ExtStopLoss=ModeBid-SellSucPossibilityMid*ExtStopLossIndex-
                              ModeSpread*ModePoint-Disperce;
               else
                  ExtStopLoss=ModeBid-ModeStopLevel *ModePoint-ModeSpread*ModePoint-Disperce;
              }

            if(ExtBlockBuy==true)
              {
               return(0);
              }
            ExtStopLevel=ExtStopLoss;
            Print("StopLevel:",ExtStopLevel);
            //--- блокировка стоплосов // blocking of stoplos
            if(BlockStopLoss==true)
               ExtStopLoss=0;
            if(m_trade.Buy(ExtLots,Symbol(),ModeAsk,ExtStopLoss,TakeProfit,"NeuroCluster-testing-AI-HB1"))
              {
               m_ticket=m_trade.ResultDeal();
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of deal: ",m_trade.ResultDeal());
              }
            else
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of deal: ",m_trade.ResultDeal());
               PrintErrorValues();
              }
            return (0);
           }
        }
      if(Decision==DECISION_BUY)
        {
         // *** Впрыгиваем в паровоз по направлению движения хаоса рынка ***
         // *** We jump into a steam locomotive in the direction of movement of chaos of the market ***
         if((iClose(Symbol(),0,ValuePeriod)-iClose(Symbol(),0,0))/
            MoneyTrainLevel >= BuySucPossibilityMid && BuySucPossibilityMid != 0 &&
            EnableMoneyTrain == true)
           {
            ModeSpread=ModeSpread+1;
            //--- расчет стоп-лоссca // calculation stop loss
            if((ModeAsk+BuySucPossibilityMid*ExtStopLossIndex+ModeSpread *ModePoint)<
               (ModeAsk+ModeStopLevel *ModePoint+ModeSpread*ModePoint))
              {
               ExtStopLoss=ModeAsk+ModeStopLevel *ModePoint+ModeSpread*ModePoint+Disperce;
              }
            else
              {
               if(BuySucPossibilityMid!=0)
                  ExtStopLoss=ModeAsk+BuySucPossibilityMid*ExtStopLossIndex+ModeSpread*ModePoint+
                              Disperce;
               else
                  ExtStopLoss=ModeAsk+ModeStopLevel *ModePoint+ModeSpread*ModePoint+Disperce;
              }
            //--- если включена ручная блокировка продаж // if manual blocking of sales is included
            if(ExtBlockSell==true)
              {
               return(0);
              }
            ExtStopLevel=ExtStopLoss;
            Print("StopLevel:",ExtStopLevel);
            //--- блокировка стоплосов // blocking of stoploss
            if(BlockStopLoss==true)
               ExtStopLoss=0;
            if(m_trade.Sell(ExtLots,Symbol(),ModeBid,ExtStopLoss,TakeProfit,"NeuroCluster-testing-AI-HS1"))
              {
               m_ticket=m_trade.ResultDeal();
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of deal: ",m_trade.ResultDeal());
              }
            else
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of deal: ",m_trade.ResultDeal());
               PrintErrorValues();
              }
            return (0);
           }
        }
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Entrance to the market                                           |
//+------------------------------------------------------------------+
int EnterMarket()
  {
//--- если нет средств, выходим // if there are no means, then leave
   if(ExtLots==0)
     {
      return (0);
     }
//--- входим в рынок если нет команды выхода из рынка // we enter the market if there is no team of an exit from the market
   if(ExitMarket==false)
     {
      // ------- Если нет открытых ордеров - входим в рынок ------------
      // ------- If there are no open orders - enter the market ------------
      if(FoundOpenedPosition==false)
        {
         //--- считаем дисперсию // we consider dispersion
         Disperce=(iHigh(Symbol(),0,0)-iLow(Symbol(),0,0));
         if(Decision==DECISION_SELL)
           {
            //--- если цена покупки больше средней величины покупки на моделируемом интервале
            //--- if the buying price is more than average size of purchase on the modelled interval
            if(SellPossibility>=SellSucPossibilityMid)
              {
               //--- расчет стоп-лосс // calculation stop loss
               if((ModeAsk+BuySucPossibilityMid*ExtStopLossIndex+ModeSpread*ModePoint)<
                  (ModeAsk+ModeStopLevel *ModePoint+ModeSpread*ModePoint))
                 {
                  ExtStopLoss=ModeAsk+ModeStopLevel *ModePoint+ModeSpread*ModePoint+Disperce;
                 }
               else
                 {
                  if(BuySucPossibilityMid!=0)
                     ExtStopLoss=ModeAsk+BuySucPossibilityMid*ExtStopLossIndex+
                                 ModeSpread*ModePoint+Disperce;
                  else
                  ExtStopLoss=ModeAsk+ModeStopLevel *ModePoint+ModeSpread*ModePoint+
                              Disperce;
                 }
               //--- если включена ручная блокировка продаж // if manual blocking of sales is included
               if(DisableSell==true)
                 {
                  return(0);
                 }
               if(ExtBlockSell==true)
                 {
                  return(0);
                 }
               if(StaticStopLoss!=0)
                 {
                  ExtStopLoss=ModeAsk+StaticStopLoss*ModePoint;
                 }
               ExtStopLevel=ExtStopLoss;
               Print("StopLevel:",ExtStopLevel);
               //--- блокировка стоплосов // blocking of stoploss
               if(BlockStopLoss==true)
                  ExtStopLoss=0;
               if(m_trade.Sell(ExtLots,Symbol(),ModeBid,ExtStopLoss,TakeProfit,"NeuroCluster-testing-AI-LS1"))
                 {
                  m_ticket=m_trade.ResultDeal();
                  Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                 }
               else
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                  PrintErrorValues();
                 }
               return (0);
              }
           }
         if(Decision==DECISION_BUY)
           {
            //--- если цена покупки больше средней величины покупки на моделируемом интервале
            //--- if the buying price is more than average size of purchase on the modelled interval
            if(BuyPossibility>=BuySucPossibilityMid)
              {
               //--- расчет стоп-лосс // calculation stop loss
               if((ModeBid-SellSucPossibilityMid*ExtStopLossIndex-ModeSpread *ModePoint)>
                  (ModeBid-ModeStopLevel *ModePoint-ModeSpread *ModePoint))
                 {
                  ExtStopLoss=ModeBid-ModeStopLevel *ModePoint-ModeSpread *ModePoint-Disperce;
                 }
               else
                 {
                  if(SellSucPossibilityMid!=0)
                     ExtStopLoss=ModeBid-SellSucPossibilityMid*ExtStopLossIndex-
                                 ModeSpread *ModePoint-Disperce;
                  else
                  ExtStopLoss=ModeBid-ModeStopLevel *ModePoint-ModeSpread *ModePoint-
                              Disperce;
                 }
               //--- если включена ручная блокировка покупок // if manual blocking of purchases is included
               if(DisableBuy==true)
                 {
                  return(0);
                 }
               if(ExtBlockBuy==true)
                 {
                  return(0);
                 }
               if(StaticStopLoss!=0)
                 {
                  ExtStopLoss=ModeBid-StaticStopLoss*ModePoint;
                 }
               ExtStopLevel=ExtStopLoss;
               Print("StopLevel:",ExtStopLevel);
               //--- блокировка стоплосов // blocking of stoploss
               if(BlockStopLoss==true)
                  ExtStopLoss=0;
               if(m_trade.Buy(ExtLots,Symbol(),ModeAsk,ExtStopLoss,TakeProfit,"NeuroCluster-testing-AI-LB1"))
                 {
                  m_ticket=m_trade.ResultDeal();
                  Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                 }
               else
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                  PrintErrorValues();
                 }
               return (0);
              }
           }
        }
      // ---------------- Конец входа в рынок ----------------------    
      // ---------------- The end of an entrance to the market ----------------------    
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Поиск открытых поизций                                           |
//| Search of open positions                                         |
//+------------------------------------------------------------------+
int FindSymbolPosition()
  {
   FoundOpenedPosition=false;
   pos_total=PositionsTotal();
   for(cnt=0; cnt<pos_total; cnt++)
     {
      m_position.SelectByIndex(cnt);
      //--- ищем позицию по нашей валюте // we look for a position on our currency
      if(m_position.Symbol()==Symbol())
        {
         FoundOpenedPosition=true;
         break;
        }
      else
        {
         ExtStopLevel= 0;
         ExtStopLoss = 0;
        }
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Run Pipsator                                                     |
//+------------------------------------------------------------------+
int RunPipsator()
  {
   int i=0;
   FindSymbolPosition();
//--- входим в рынок если нет команды выхода из рынка // we enter the market if there is no team of an exit from the market
//--- считаем дисперсию // we consider dispersion
   if(ExtLots==0)
      return (0);
   Disperce=0;
   if(ExitMarket==false)
     {
      // ---------- Если нет открытых позиций - входим в рынок ----------
      // ---------- If there are no open Positions - enter the market ----------
      if(FoundOpenedPosition==false)
        {
         Disperce=0;
         DisperceMax=0;
         //--- считаем максимальную дисперсию // we consider the maximum dispersion
         for(i=0; i<ValuePeriod; i++)
           {
            Disperce=(iHigh(Symbol(),0,i+1) -
                      iLow(Symbol(),0,i+1));
            if(Disperce>DisperceMax)
               DisperceMax=Disperce;
           }
         Disperce=DisperceMax *ExtStopLossIndex;
         if(Disperce==0)
           {
            Disperce=ModeStopLevel*ModePoint;
           }
         for(i=0; i<ValuePeriod; i++)
           {
            //--- пипсатор минутного интервала по продаже pipsator of a minute interval on sale
            if((ModeBid-iClose(Symbol(),0,i+1))>
               SellSucPossibilityMid *(i+1) && 
               SellSucPossibilityMid!=0 && DisablePipsator==false && 
               DisableSellPipsator==false)
              {
               //--- расчет стоп-лосс // calculation stop loss
               if((ModeAsk+ModeSpread*ModePoint+Disperce)<
                  (ModeAsk+ModeStopLevel *ModePoint+ModeSpread*ModePoint))
                 {
                  ExtStopLoss=ModeAsk+ModeStopLevel *ModePoint+ModeSpread*ModePoint+ModePoint;
                 }
               else
                 {
                  if(BuySucPossibilityMid!=0)
                     ExtStopLoss=ModeAsk+ModeSpread*ModePoint+Disperce+ModePoint;
                  else
                     ExtStopLoss=ModeAsk+ModeStopLevel *ModePoint+ModeSpread*ModePoint+ModePoint;
                 }
               //--- если включена ручная блокировка продаж // if manual blocking of sales is included
               if(ExtBlockSell==true)
                 {
                  return(0);
                 }
               //--- если включена ручная блокировка продаж // if manual blocking of sales is included
               if(DisableSell==true)
                 {
                  return(0);
                 }

               if(StaticStopLoss!=0)
                 {
                  ExtStopLoss=ModeAsk+StaticStopLoss*ModePoint;
                 }

               ExtStopLevel=ExtStopLoss;
               Print("StopLevel:",ExtStopLevel);
               //--- блокировка стоплосов // blocking of stoploss
               if(BlockStopLoss==true)
                  ExtStopLoss=0;
               if(m_trade.Sell(ExtLots,Symbol(),ModeBid,ExtStopLoss,TakeProfit,"NeuroCluster-testing-AI-PS1"))
                 {
                  m_ticket=m_trade.ResultDeal();
                  Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                 }
               else
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                  PrintErrorValues();
                 }
               return (0);
              }
            //--- пипсатор минутного интервала по покупке // pipsator of a minute interval on purchase
            if((iClose(Symbol(),0,i+1)-ModeBid)>BuySucPossibilityMid *(i+1) && 
               BuySucPossibilityMid!=0 && DisablePipsator==false && 
               DisableBuyPipsator==false)
              {
               //--- расчет стоп-лоссca // calculation stop loss
               if((ModeBid-ModeSpread*ModePoint-Disperce)>
                  (ModeBid-ModeStopLevel *ModePoint-ModeSpread*ModePoint))
                 {
                  ExtStopLoss=ModeBid-ModeStopLevel *ModePoint-ModeSpread*ModePoint-ModePoint;
                 }
               else
                 {
                  if(SellSucPossibilityMid!=0)
                     ExtStopLoss=ModeBid-ModeSpread*ModePoint-Disperce-ModePoint;
                  else
                     ExtStopLoss=ModeBid-ModeStopLevel *ModePoint-ModeSpread*ModePoint-ModePoint;
                 }
               //--- если включена ручная блокировка // if manual blocking is included
               if(DisableBuy==true)
                 {
                  return(0);
                 }
               if(ExtBlockBuy==true)
                 {
                  return(0);
                 }
               if(StaticStopLoss!=0)
                 {
                  ExtStopLoss=ModeBid-StaticStopLoss*ModePoint;
                 }
               ExtStopLevel=ExtStopLoss;
               Print("StopLevel:",ExtStopLevel);
               //--- блокировка стоплосов // blocking of stoploss
               if(BlockStopLoss==true)
                  ExtStopLoss=0;
               if(m_trade.Buy(ExtLots,Symbol(),ModeAsk,ExtStopLoss,TakeProfit,"NeuroCluster-testing-AI-PB1"))
                 {
                  m_ticket=m_trade.ResultDeal();
                  Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                 }
               else
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                  PrintErrorValues();
                 }
               return (0);
              }
           }  // конец пипсаторного цикла // end of a pipsatorny cycle           
        }
     }
   return (0);
  }
//+------------------------------------------------------------------+
//| Exit from Market                                                 |
//+------------------------------------------------------------------+
int ExitMarket()
  {
// -------------------- Обработка открытых позиций ----------------
// -------------------- Processing of open positions ----------------
   if(FoundOpenedPosition==true)
     {
      if(m_position.PositionType()==POSITION_TYPE_BUY)
        {
         // Закрытие ордера, если он достиг уровня стоп-лосс
         if(ModeBid<=ExtStopLevel && DisableShadowStopLoss==false && ExtStopLevel!=0)
           {
            m_trade.PositionClose(m_position.Ticket());
            return(0);
           }

         if(ExtDisableExitBuy==true)
            return (0);

         //--- не выходим из рынка, если имеем хаос, работающий на прибыль
         //--- we don't leave the market if we have the chaos working for profit
         if((iClose(Symbol(),0,0)-iClose(Symbol(),0,1))>=
            SellSucPossibilityMid*4 && SellSucPossibilityMid>0)
            return(0);

         //--- закрытие по превышению вероятности успешной продажи
         //--- closing on excess of probability of successful sale
         if((m_position.PriceOpen()<ModeBid) && ((ModeBid-m_position.PriceOpen())>=
            SellSucPossibilityMid) && (SellSucPossibilityMid>0))
           {
            m_trade.PositionClose(m_position.Ticket());
            return(0);
           }

         //--- закрытие по превышению вероятности успешной покупки
         //--- closing on excess of probability of successful purchase
         if((m_position.PriceOpen()<ModeBid) && (ModeBid-m_position.PriceOpen()>=
            BuySucPossibilityMid) && (BuySucPossibilityMid>0))
           {
            m_trade.PositionClose(m_position.Ticket());
            return(0);
           }

         //--- закрытие пипсатора // closing of a pipsator
         if((m_position.PriceOpen()<ModeBid) && BuySucPossibilityMid==0 && SellSucPossibilityMid==0)
           {
            m_trade.PositionClose(m_position.Ticket());
            return(0);
           }

        }
      if(m_position.PositionType()==POSITION_TYPE_SELL)
        {
         //--- закрытие, если достигнут уровень стоп-лосс // closing if reach level stop loss
         if(ModeAsk>=ExtStopLevel && DisableShadowStopLoss==false && ExtStopLevel!=0)
           {
            m_trade.PositionClose(m_position.Ticket());
            return(0);
           }

         if(ExtDisableExitSell==true)
            return (0);

         //--- не выходим из рынка, если имеем хаос, работающий на прибыль
         //--- we don't leave the market if we have the chaos working for profit
         if((iClose(Symbol(),0,1)-iClose(Symbol(),0,0))>=BuySucPossibilityMid*4 && BuySucPossibilityMid>0)
            return (0);

         //--- закрытие по факту превышения вероятности успешной покупки
         //--- closing upon excess of probability of successful purchase
         if((m_position.PriceOpen()>ModeAsk) && (m_position.PriceOpen()-ModeAsk)>=
            BuySucPossibilityMid && BuySucPossibilityMid>0)
           {

            m_trade.PositionClose(m_position.Ticket()); //
           }

         //--- закрытие по факту превыщения вероятности успешной продажи
         //--- closing upon excess of probability of successful sale
         if((m_position.PriceOpen()>ModeAsk) && (m_position.PriceOpen()-ModeAsk)>=
            SellSucPossibilityMid && SellSucPossibilityMid>0)
           {
            m_trade.PositionClose(m_position.Ticket());
            return(0);
           }

         //--- закрытие пипсатора // closing of a pipsator
         if((m_position.PriceOpen()>ModeAsk) && BuySucPossibilityMid==0 && SellSucPossibilityMid==0)
           {
            m_trade.PositionClose(m_position.Ticket());
            return(0);
           }

        }
     }
// --------------------- Конец обработки открытых позиций  -----------
//--------------------- The end of processing of open positions -----------
   return (0);
  }
//+--------------------------------------------------------------------------+
//| Сохраняем значения ставок и периода моделирования для следующей итеррации|
//| Keep values of rates and the period of modeling for the following iteration |
//+--------------------------------------------------------------------------+
int SaveStat()
  {
   BidPrev = ModeBid;
   AskPrev = ModeAsk;
   ValuePeriodPrev=ValuePeriod;
   return (0);
  }
//+------------------------------------------------------------------+
//| Trade                                                            |
//+------------------------------------------------------------------+
int Trade()
  {
//--- начинаем торговать // we begin to trade
//--- ищем открытые позиции // we look for open positions
   FindSymbolPosition();
   CalculateDirection();
   AutoStopLossIndex();
//--- если открытых позиций по символу нет, возможен вход в рынок
//--- if there are no open line items on a symbol, the entrance to the market is possible
//--- внимание - важен именно этот порядок рассмотрения технологий входа в рынок (MoneyTrain, LogicTrading, Pipsator)
//--- attention - this order of consideration of technologies of an entrance to the market is important (MoneyTrain, LogicTrading, Pipsator)
   if(FoundOpenedPosition==false)
     {
      if(EnableMoneyTrain==true)
         MoneyTrain();
      if(EnableLogicTrading==true)
         EnterMarket();
      if(DisablePipsator==false && BlockPipsator==false)
         RunPipsator();
     }
   else
     {
      ExitMarket();
     }
//--- конец обработки входа/выхода из рынка // the end of processing of an input and output from the market
   return(0);
  }
//+------------------------------------------------------------------+
//| Account Status                                                   |
//+------------------------------------------------------------------+
int AccountStatus()
  {
   if(ShowAccountStatus==true)
     {
      Print("AccountBalance:",m_account.Balance());
      Print("AccountCompany:",m_account.Company());
      Print("AccountCredit:",m_account.Credit());
      Print("AccountCurrency:",m_account.Currency());
      Print("AccountEquity:",m_account.Equity());
      Print("AccountFreeMargin:",m_account.FreeMargin());
      Print("AccountLeverage:",m_account.Leverage());
      Print("AccountMargin:",m_account.Margin());
      Print("AccountName:",m_account.Name());
      Print("AccountNumber:",m_account.Login());
      Print("AccountProfit:",m_account.Profit());
     }
   return ( 0 );
  }
//+------------------------------------------------------------------+
//| Самая важная функция - выбор периода моделирования               |
//| Most important function - the choice of the period of modeling   |
//+------------------------------------------------------------------+
int FindSuitablePeriod()
  {
   double SuitablePeriodQuality=-1 *ValuesPeriodCountMax*ValuesPeriodCountMax;
   int SuitablePeriod=0;
   int i; // переменная для анализа периодов // variable for the analysis of the periods
//--- количество анализируемых периодов. i - размер периода
//--- amount of the analyzed periods. i - period size
   for(i=0; i<ValuesPeriodCountMax; i++)
     {
      ValuePeriod=i+1;
      //--- значение подобрано опытным путем и как ни странно оно совпало с числом в теории эллиота
      //--- value is picked up by practical consideration and strangely enough it has coincided with number in Elliot's theory
      ExtValuesPeriodCount=ValuePeriod*5;
      Initialization();
      CalculatePossibilityStat();
      if(PossibilitySucQuality>SuitablePeriodQuality)
        {
         SuitablePeriodQuality=PossibilitySucQuality;
         //Print ("PossibilitySucQuality:", PossibilitySucQuality:);
         SuitablePeriod=i+1;
        }
     }
   ValuePeriod=SuitablePeriod;
   Initialization();

   if(ShowSuitablePeriod==true)
     {
      Print("Modeling period: ",SuitablePeriod," minutes with probability :",
            SuitablePeriodQuality);
     }
   return(SuitablePeriod);
  }
//+------------------------------------------------------------------+
//| Автоматическая установка уровня стоп-лосс                        |
//| Automatic installation of level stop loss                        |
//+------------------------------------------------------------------+
int AutoStopLossIndex()
  {
   if(AutoStopLossIndex==true)
     {
      ExtStopLossIndex=ModeSpread;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Вывод ошибок при входе в рынок                                   |
//| Print of mistakes at an entrance to the market                   |
//+------------------------------------------------------------------+
int PrintErrorValues()
  {
   Print("ErrorValues:Symbol=",Symbol(),",Lots=",ExtLots,",Bid=",ModeBid,",Ask=",ModeAsk,
         ",SlipPage=",SlipPage,"StopLoss=",ExtStopLoss,",TakeProfit=",TakeProfit);
   return (0);
  }
//+------------------------------------------------------------------+
//| Expert new tick handling function                                |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   GetMarketInfo();
   CyberiaLots();
   CalculateSpread();
   FindSuitablePeriod();
   CyberiaDecision();
   Trade();
   SaveStat();
   return;
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iADX                                |
//|  the buffer numbers are the following:                           |
//|   0 - iADXBuffer, 1 - DI_plusBuffer, 2 - DI_minusBuffer          |
//+------------------------------------------------------------------+
double iADXGet(const int buffer,const int index)
  {
   double ADX[];
   ArraySetAsSeries(ADX,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iADX,buffer,0,index+1,ADX)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ADX[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCCI                                |
//+------------------------------------------------------------------+
double iCCIGet(const int index)
  {
   double CCI[];
   ArraySetAsSeries(CCI,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCCI,0,0,index+1,CCI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCCI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(CCI[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iFractals                           |
//|  the buffer numbers are the following:                           |
//|   0 - UPPER_LINE, 1 - LOWER_LINE                                 |
//+------------------------------------------------------------------+
double iFractalsGet(const int buffer,const int index)
  {
   double Fractals[];
   ArraySetAsSeries(Fractals,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iFractals,buffer,0,index+1,Fractals)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iFractals indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Fractals[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[];
   ArraySetAsSeries(MA,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,0,index+1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iMACDGet(const int buffer,const int index)
  {
   double MACD[];
   ArraySetAsSeries(MACD,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMACD,buffer,0,index+1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[index]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Initialization()
  {
   AccountStatus();
   GetMarketInfo();
   ModelingPeriod=ValuePeriod*ExtValuesPeriodCount; // Период моделирования в минутах
   if(ValuePeriod!=0)
      ModelingBars=ModelingPeriod/ValuePeriod; // Количество шагов в периоде
   CalculateSpread();
   return(0);
  }
//+------------------------------------------------------------------+
