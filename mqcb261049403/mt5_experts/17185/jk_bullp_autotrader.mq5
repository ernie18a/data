//+------------------------------------------------------------------+
//|                 JK BullP AutoTrader(barabashkakvn's edition).mq5 |
//|                                     Copyright © 2005, Johnny Kor |
//|                                                   autojk@mail.ru |
//|        On-Line Testing http://vesna.on-plus.ru/forex/stat/69740/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Johnny Kor"
#property link      "autojk@mail.ru"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double   TakeProfit=350;
input double   Lots=0.3;
input double   StopLoss=100;
input int      TrailingStop=100;
input int      TrailingStep=40;
//---
ulong                   m_magic=692735652; // magic number
int                     handle_iBullsPower; // variable for storing the handle of the iBullsPower indicator 
double                  m_digits_adjust=0.0; // 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
   if(TrailingStop<=TrailingStep)
     {
      Print("TrailingStop less or equal TrailingStep");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- create handle of the indicator iBullsPower
   handle_iBullsPower=iBullsPower(Symbol(),Period(),13);
//--- if the handle is not created 
   if(handle_iBullsPower==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iBullsPower indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_digits_adjust = digits_adjust * m_symbol.Point();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double pos1pre = iBullsPowerGet(2);
   double pos2cur = iBullsPowerGet(1);

   Comment("  BullsPower - ",DoubleToString(pos1pre,Digits()+1),
           "  BearsPower - ",DoubleToString(pos2cur,Digits()+1));

   if(!RefreshRates())
      return;

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            total++;
            if(m_position.PositionType()==POSITION_TYPE_BUY) // открыта длинная позиция
              {
               //--- проверим - может можно/нужно уже трейлинг стоп ставить?
               if(TrailingStop>0)
                 {
                  //--- пользователь выставил в настройках трейлингстоп
                  //--- значит мы идем его проверять
                  if(m_symbol.Bid()-m_position.PriceOpen()>m_digits_adjust*TrailingStop)
                    {
                     if(m_position.StopLoss()<m_symbol.Bid()-m_digits_adjust*(TrailingStop+TrailingStep))
                       {
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Bid()-m_digits_adjust*TrailingStop,
                                               m_position.TakeProfit());
                        //return(0);
                       }
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL) // открыта короткая позиция
              {
               // проверим - может можно/нужно уже трейлинг стоп ставить?
               if(TrailingStop>0)
                 {
                  //--- пользователь выставил в настройках трейлингстоп
                  //--- значит мы идем его проверять
                  if((m_position.PriceOpen()-m_symbol.Ask())>(m_digits_adjust*TrailingStop))
                    {
                     if(m_position.StopLoss()>m_symbol.Ask()+m_digits_adjust*(TrailingStop+TrailingStep))
                       {
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Ask()+m_digits_adjust*TrailingStop,
                                               m_position.TakeProfit());
                        //return(0);
                       }
                    }
                 }
              }
           }

   if(pos1pre>pos2cur && pos2cur>0 && total<2)
     {
      m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),
                   m_symbol.Bid()+StopLoss*m_digits_adjust,
                   m_symbol.Bid()-TakeProfit*m_digits_adjust);
     }
   if(pos2cur<0 && total<1)
     {
      m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),
                  m_symbol.Ask()-StopLoss*m_digits_adjust,
                  m_symbol.Ask()+TakeProfit*m_digits_adjust,NULL);
     }
   return;
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
//| Get value of buffers for the iBullsPower                         |
//+------------------------------------------------------------------+
double iBullsPowerGet(const int index)
  {
   double BullsPower[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iBullsPower array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iBullsPower,0,index,1,BullsPower)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iBullsPower indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(BullsPower[0]);
  }
//+------------------------------------------------------------------+
