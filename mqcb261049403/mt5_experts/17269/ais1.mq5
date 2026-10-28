//+------------------------------------------------------------------+
//|                                AIS1(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property     copyright                 "Copyright (C) 2009, MetaQuotes Software Corp."                        
#property     link                      "https://www.metaquotes.net"                                            
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
#define           A_System_Robot            "AIS1 Trading Robot"                                                   
#define           A_System_Strategy         "A System: EURUSD Daily Metrics"                                       
#define           A_System_ReleaseDate      "09.02.2009"                                                           
#define           A_System_ReleaseCode      "1"                                                                    
#define           A_System_Programmer       "Airat Safin                            http://www.mql4.com/users/Ais"                                                                                                             
//---                                                                                                             
#define           acs_Symbol                "EURUSD"                                                                                                                                
#define           acd_TrailStepping         1.0                                                                    

#define           aci_Index_1               7                                                                      
#define           aci_Index_2               6                                                                      
//---
input double aed_AccountReserve      = 0.20;
input double aed_OrderReserve        = 0.04;
input double aed_TakeFactor          = 0.8;
input double aed_StopFactor          = 1.0;
input double aed_TrailFactor         = 5.0;
//---
ulong             m_magic=15489;                // magic number
ENUM_TIMEFRAMES   aci_Timeframe[]={PERIOD_CURRENT,PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
datetime          avi_TimeStamp=0;
double            avd_MaximalEquity=0.0;
double            avd_DrawdownLimit=0.0;
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Symbol()!="EURUSD")
     {
      Print("Only \"EURUSD\"!");
      return(INIT_FAILED);
     }

   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }

   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();

   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number

   avi_TimeStamp            = TimeCurrent();
   avd_MaximalEquity        = m_account.Equity();
   avd_DrawdownLimit        = aed_AccountReserve      - aed_OrderReserve;

   Print("");
   Print(A_System_Robot,": Reload code ",UninitializeReason());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print(A_System_Robot,": Deinit code ",reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Trading Pause Control
   if(TimeCurrent()-avi_TimeStamp<5)
      return;

//--- Equity Control 
   if(m_account.Equity()>avd_MaximalEquity)
      avd_MaximalEquity=m_account.Equity();
   if(m_account.Equity()<avd_MaximalEquity*(1-avd_DrawdownLimit))
      return;

//--- refresh rates
   if(!m_symbol.RefreshRates())
      return;

//--- Data Feed       
   double ald_QuoteAsk        = m_symbol.Ask();
   double ald_QuoteBid        = m_symbol.Bid();
   double ald_QuotePoint      = m_symbol.Point();
   double ald_QuoteSpread     = m_symbol.Spread() * ald_QuotePoint;
   double ald_QuoteStops      = m_symbol.StopsLevel() * ald_QuotePoint;
   double ald_QuoteTick       = m_symbol.TickSize();
   double ald_NominalTick     = m_symbol.TickValue();
   double ald_NominalMargin   = m_account.MarginCheck(acs_Symbol,ORDER_TYPE_BUY,1.0,ald_QuoteAsk);
   double ald_NominalLot      = m_symbol.ContractSize();
   double ald_MaximumLots     = m_symbol.LotsMax();
   double ald_MinimumLots     = m_symbol.LotsMin();
   double ald_LotStep         = m_symbol.LotsStep();
   int    ald_Digits          = m_symbol.Digits();

   ENUM_TIMEFRAMES ali_Period_1=aci_Timeframe[aci_Index_1];
   ENUM_TIMEFRAMES ali_Period_2=aci_Timeframe[aci_Index_2];

   double ald_Low_1     = iLow(1,acs_Symbol,ali_Period_1);
   double ald_High_1    = iHigh(1,acs_Symbol,ali_Period_1);
   double ald_Close_1   = iClose(1,acs_Symbol,ali_Period_1);

   double ald_Low_2     = iLow(1,acs_Symbol,ali_Period_2);
   double ald_High_2    = iHigh(1,acs_Symbol,ali_Period_2);
   double ald_Close_2   = iClose(1,acs_Symbol,ali_Period_2);

   if(ald_Low_1==0.0 || ald_High_1==0.0 || ald_Close_1==0.0 || ald_Low_2==0.0 || ald_High_2==0.0 || ald_Close_2==0.0)
      return;

   double ald_Average_1=(ald_High_1+ald_Low_1)/2;

   double ald_Range_1   =ald_High_1-ald_Low_1;
   double ald_Range_2   =ald_High_2-ald_Low_2;

   double ald_QuoteTake = ald_Range_1* aed_TakeFactor;
   double ald_QuoteStop = ald_Range_1* aed_StopFactor;
   double ald_QuoteTrail= ald_Range_2 *aed_TrailFactor;

   double ald_TrailStep=ald_QuoteSpread*acd_TrailStepping;

//--- Strategy Outputs Reset  
   ENUM_ORDER_TYPE ali_Command=ORDER_TYPE_CLOSE_BY;
   double ald_Price         = 0.0;
   double ald_Stop          = 0.0;
   double ald_Take          = 0.0;
   double ald_Risk          = 0.0;

//--- Trailing Stop
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==acs_Symbol && m_position.Magic()==m_magic)
           {
            total++;
            ald_Stop=0.0;

            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.Profit()>0)
                  if(ald_QuoteTrail>ald_QuoteStops)
                     if(ald_QuoteBid<m_position.TakeProfit()-ald_QuoteStops)
                        if(ald_QuoteBid>m_position.StopLoss()+ald_TrailStep+ald_QuoteTrail)
                           ald_Stop=NormalizeDouble(ald_QuoteBid-ald_QuoteTrail,ald_Digits);
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.Profit()>0)
                  if(ald_QuoteTrail>ald_QuoteStops)
                     if(ald_QuoteAsk>m_position.TakeProfit()+ald_QuoteStops)
                        if(ald_QuoteAsk<m_position.StopLoss()-ald_TrailStep-ald_QuoteTrail)
                           ald_Stop=NormalizeDouble(ald_QuoteAsk+ald_QuoteTrail,ald_Digits);
              }

            if(ald_Stop>0)
              {
               m_trade.PositionModify(m_position.Ticket(),ald_Stop,m_position.TakeProfit());
               avi_TimeStamp=TimeCurrent();
               return;
              }
           }

//--- 7.6. Strategy Logic 
   if(total>0)
      return;

   if(ald_Close_1>ald_Average_1)
      if(ald_QuoteAsk>ald_High_1)
        {
         ali_Command  = ORDER_TYPE_BUY;
         ald_Price    = ald_QuoteAsk;
         ald_Stop     = NormalizeDouble(ald_High_1   - ald_QuoteStop,ald_Digits);
         ald_Take     = NormalizeDouble(ald_QuoteAsk + ald_QuoteTake,ald_Digits);
         ald_Risk     = ald_Price-ald_Stop;
        }

   if(ald_Close_1<ald_Average_1)
      if(ald_QuoteBid<ald_Low_1)
        {
         ali_Command  = ORDER_TYPE_SELL;
         ald_Price    = ald_QuoteBid;
         ald_Stop     = NormalizeDouble(ald_Low_1    + ald_QuoteStop,ald_Digits);
         ald_Take     = NormalizeDouble(ald_QuoteBid - ald_QuoteTake,ald_Digits);
         ald_Risk     = ald_Stop-ald_Price;
        }

//--- Trading Module                                                                                     
   if(IsTradeAllowed())
      if(ali_Command==ORDER_TYPE_BUY || ali_Command==ORDER_TYPE_SELL)
        {
         //--- Risk Management                                                                                 
         double ald_NominalPoint   = ald_NominalTick* ald_QuotePoint/ald_QuoteTick;
         double ali_PositionPoints = MathRound( ald_NominalMargin/ald_NominalPoint);
         double ali_RiskPoints     = MathRound( ald_Risk/ald_QuotePoint);
         double ald_VARLimit       = m_account.Equity()*aed_OrderReserve;
         double ald_RiskPoint      = ald_VARLimit/ali_RiskPoints;
         double ald_PositionLimit  = ald_RiskPoint*ali_PositionPoints;
         double ald_SizeLimit      = ald_PositionLimit/ald_NominalMargin;

         //--- Operation Size Control                                                                          
         if(ald_SizeLimit>=ald_MinimumLots)
            double ali_Steps=MathFloor(( ald_SizeLimit-ald_MinimumLots)/ald_LotStep);
         else
            return;

         double ald_Size=NormalizeDouble(ald_MinimumLots+ald_LotStep*ald_LotStep,2);

         if(ald_Size>ald_MaximumLots)
            ald_Size=ald_MaximumLots;

         double free_margin_check=0.0;
         if(ali_Command==ORDER_TYPE_BUY)
            free_margin_check=m_account.FreeMarginCheck(acs_Symbol,ali_Command,ald_Size,ald_QuoteAsk);
         if(ali_Command==ORDER_TYPE_SELL)
            free_margin_check=m_account.FreeMarginCheck(acs_Symbol,ali_Command,ald_Size,ald_QuoteBid);

         if(free_margin_check<=0)
            return;

         //--- Trade  
         if(ali_Command==ORDER_TYPE_BUY)
            m_trade.Buy(ald_Size,acs_Symbol,ald_Price,ald_Stop,ald_Take);
         if(ali_Command==ORDER_TYPE_SELL)
            m_trade.Sell(ald_Size,acs_Symbol,ald_Price,ald_Stop,ald_Take);
         avi_TimeStamp=TimeCurrent();
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Get the High for specified bar index                             | 
//+------------------------------------------------------------------+ 
double iHigh(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double High[1];
   double high=0;
   int copied=CopyHigh(symbol,timeframe,index,1,High);
   if(copied>0) high=High[0];
   return(high);
  }
//+------------------------------------------------------------------+ 
//| Get Low for specified bar index                                  | 
//+------------------------------------------------------------------+ 
double iLow(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Low[1];
   double low=0;
   int copied=CopyLow(symbol,timeframe,index,1,Low);
   if(copied>0) low=Low[0];
   return(low);
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
