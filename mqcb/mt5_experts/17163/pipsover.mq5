//+------------------------------------------------------------------+
//|                            Pipsover(barabashkakvn's edition).mq5 |
//|                              Copyright © 2006, Yury V. Reshetov. |
//|                                       http://betaexpert.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Yury V. Reshetov. ICQ: 282715499"
#property link      "http://betaexpert.narod.ru"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double      m_lots      = 0.1;         // Объемы
input ushort      m_stoploss  = 65;          // убытки
input ushort      m_takeprofit= 100;         // Прибыль
input double      m_openlevel = 100;         // Предельный уровень значения индикатора Чайкина для открытия позиции
input double      m_closelevel= 125;         // Предельный уровень значения индикатора Чайкина для локирования позиции
//---
static datetime   prevtime          = 0;     // Время последнего бара
ulong             m_magic           = 888;   // magic number
double            m_adjusted_point  = 0.0;   // tuning for 3 or 5 digits
int               handle_iMA;                // variable for storing the handle of the iMA indicator 
int               handle_iChaikin;           // variable for storing the handle of the iChaikin indicator  
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
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),Period(),20,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iChaikin
   handle_iChaikin=iChaikin(m_symbol.Name(),Period(),3,10,MODE_EMA,VOLUME_TICK);
//--- if the handle is not created 
   if(handle_iChaikin==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iChaikin indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- ждем, когда сформируется новый бар
   if(iTime(m_symbol.Name(),Period(),0)==prevtime)
      return;
   prevtime=iTime(m_symbol.Name(),Period(),0);

   double ma=iMAGet(0);                   // 20 периодный мувинг
   double ch=iChaikinGet(1);              // значение индикатора Чайкина на баре №1

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   if(!RefreshRates())
      return;

   if(total<1) // нет открытых позиций
     {
      //--- если значение индикатора Чайкина зашкалило и начался потенциальный разворот
      //--- своего рода перепроданность
      //--- покупаем
      if(iClose(m_symbol.Name(),Period(),1)>iOpen(m_symbol.Name(),Period(),1) && iLow(m_symbol.Name(),Period(),1)<ma && ch<-m_openlevel)
        {
         double level_price=m_symbol.Ask();
         double level_sl=m_symbol.Ask()-m_stoploss*m_adjusted_point;
         double level_tp=m_symbol.Ask()+m_takeprofit*m_adjusted_point;
         m_trade.Buy(m_lots,NULL,level_price,level_sl,level_tp,"Pipsover");
         return;
        }
      //--- если значение индикатора Чайкина зашкалило и начался потенциальный разворот
      //--- своего рода перекупленность
      //--- пПродаем
      if(iClose(m_symbol.Name(),Period(),1)<iOpen(m_symbol.Name(),Period(),1) && iHigh(m_symbol.Name(),Period(),1)>ma && ch>m_openlevel)
        {
         double level_price=m_symbol.Bid();
         double level_sl=m_symbol.Bid()+m_stoploss*m_adjusted_point;
         double level_tp=m_symbol.Bid()-m_takeprofit*m_adjusted_point;
         m_trade.Sell(m_lots,NULL,level_price,level_sl,level_tp,"Pipsover");
         return;
        }
     }
   else
     {
      //--- есть открытые позиции. Может быть пора подстраховаться?

      //--- если открыто более одной позиции - выходим
      if(total>1)
         return;

      //--- если открыта всего одна позиция
      if(m_position.SelectByIndex(0))
        {
         //--- похоже на откат, залокируем длинную позицию
         if(m_position.PositionType()==POSITION_TYPE_BUY && 
            iClose(m_symbol.Name(),Period(),1)<iOpen(m_symbol.Name(),Period(),1) && iHigh(m_symbol.Name(),Period(),1)>ma && ch>m_closelevel)
           {
            double level_price=m_symbol.Bid();
            double level_sl=m_symbol.Ask()+m_stoploss*m_adjusted_point;
            double level_tp=m_symbol.Ask()-m_takeprofit*m_adjusted_point;
            m_trade.Sell(m_lots,NULL,level_price,level_sl,level_tp,"Pipsover");
            return;
           }

         //--- похоже на откат, залокируем коротку позицию
         if(m_position.PositionType()==POSITION_TYPE_SELL && 
            iClose(m_symbol.Name(),Period(),1)>iOpen(m_symbol.Name(),Period(),1) && iLow(m_symbol.Name(),Period(),1)<ma && ch<-m_closelevel)
           {
            double level_price=m_symbol.Ask();
            double level_sl=m_symbol.Bid()-m_stoploss*m_adjusted_point;
            double level_tp=m_symbol.Bid()+m_takeprofit*m_adjusted_point;
            m_trade.Buy(m_lots,NULL,level_price,level_sl,level_tp,"Pipsover");
            return;
           }
        }
     }
//--- вот и сказке звиздец
   return;
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iChaikin                            |
//+------------------------------------------------------------------+
double iChaikinGet(const int index)
  {
   double Chaikin[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iChaikin array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iChaikin,0,index,1,Chaikin)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iChaikin indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Chaikin[0]);
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
