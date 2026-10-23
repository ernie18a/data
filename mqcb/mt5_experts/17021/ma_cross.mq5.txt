//+------------------------------------------------------------------+
//|                            MA Cross(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
input int            MA_1_Period    = 3;              // Период усреднения 1-й МА
input int            MA_2_Period    = 13;             // Период усреднения 2-й МА
input ENUM_MA_METHOD MA_1_Method    = MODE_SMA;       // Метод вычисления МА1
input ENUM_MA_METHOD MA_2_Method    = MODE_LWMA;      // Метод вычисления МА2
input ENUM_APPLIED_PRICE MA_1_Price = PRICE_CLOSE;    // Метод вычисления цены МА1 
input ENUM_APPLIED_PRICE MA_2_Price = PRICE_MEDIAN;   // Метод вычисления цены МА2
input int            MA_1_Shift     = 0;              // Смещение индикатора МА1
input int            MA_2_Shift     = 0;              // Смещение индикатора МА2
input double         Lot            = 0.1;            // Фиксированный лот
//---
int                  New_Bar;                         // 0/1 Факт образования нового бара
datetime             Time_0;                          // Время начала нового бара
int                  PosOpen;                         // Направление пересечения
int                  PosClose;                        // Направление пересечения
int                  all_positions;                   // Количество открытых позиций
double               MA1_0;                           // Текущее значение 1-й МА
double               MA1_1;                           // Предыдущее значение 1-й МА
double               MA2_0;                           // Текущее значение 2-й МА
double               MA2_1;                           // Предыдущее значение 2-й МА
int                  PosBuy;                          // 1 = факт наличия позиции Buy
int                  PosSell;                         // 1 = факт наличия позиции Sell 
//---
int    handle_iMA_1;                     // variable for storing the handle of the iMA indicator 
int    handle_iMA_2;                    // variable for storing the handle of the iMA indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_symbol.Name(Symbol());                  // sets symbol name
//--- create handle of the indicator iMA
   handle_iMA_1=iMA(m_symbol.Name(),Period(),MA_1_Period,MA_1_Shift,MA_1_Method,MA_1_Price);
//--- if the handle is not created 
   if(handle_iMA_1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_2=iMA(m_symbol.Name(),Period(),MA_2_Period,MA_2_Shift,MA_2_Method,MA_2_Price);
//--- if the handle is not created 
   if(handle_iMA_2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
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
   if(!RefreshRates())
      return;

   PosBuy=0;
   PosSell=0;
   int openOrders=0;
   all_positions=PositionsTotal();                                  // Общее количество позиций
   for(int i=all_positions-1;i>=0;i--) // returns the number of open positions
     {
      if(m_position.SelectByIndex(i)) // Выбираем позицию
        {
         if(m_position.PositionType()==POSITION_TYPE_BUY)// Если позиция BUY
           {
            PosBuy=1;
            if(CrossPositionClose()==1) // Закрывем ордер, если удовлетворяет условию CrossPositionClose()=1
              {
               m_trade.PositionClose(m_position.Ticket());
              }
           }
         if(m_position.PositionType()==POSITION_TYPE_SELL) // Если позиция SELL
           {
            PosSell=1;
            if(CrossPositionClose()==2) // Закрывем ордер, если удовлетворяет условию CrossPositionClose()=2
              {
               m_trade.PositionClose(m_position.Ticket());
              }
           }
        }
     }

   New_Bar=0;                          // Для начала обнулимся
   if(Time_0!=iTime(m_symbol.Name(),Period(),0)) // Если уже другое время начала бара
     {
      New_Bar=1;                      // А вот и новый бар
      Time_0=iTime(m_symbol.Name(),Period(),0);               // Запомним время начала нового бара
     }

   MA1_0=iMAGet(handle_iMA_1,0);       // Текущее    значение 1-й МА
   MA1_1=iMAGet(handle_iMA_1, 1);      // Предыдущее значение 1-й МА
   MA2_0=iMAGet(handle_iMA_2, 0);      // Текущее    значение 2-й МА
   MA2_1=iMAGet(handle_iMA_2, 1);      // Предыдущее значение 2-й МА

   if(CrossPositionOpen()==1 && New_Bar==1) // Движение снизу вверх = откр. Buy
     {
      OpenBuy();
     }
   if(CrossPositionOpen()==2 && New_Bar==1) // Движение сверху вниз = откр. Sell
     {
      OpenSell();
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CrossPositionOpen()
  {
   PosOpen=0;                                                 // Вот где собака зарыта!!:)
   if((MA1_1<=MA2_0 && MA1_0>MA2_0) || (MA1_1<MA2_0 && MA1_0>=MA2_0)) // Пересечение снизу вверх  
     {
      PosOpen=1;
     }
   if((MA1_1>=MA2_0 && MA1_0<MA2_0) || (MA1_1>MA2_0 && MA1_0<=MA2_0)) // Пересечение сверху вниз
     {
      PosOpen=2;
     }
   return(PosOpen);                                          // Возвращаем направление пересечен.
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CrossPositionClose()
  {
   PosClose=0;                                                // Вот где собака зарыта!!:)
   if((MA1_1>=MA2_0 && MA1_0<MA2_0) || (MA1_1>MA2_0 && MA1_0<=MA2_0)) // Пересечение сверху вниз
     {
      PosClose=1;
     }
   if((MA1_1<=MA2_0 && MA1_0>MA2_0) || (MA1_1<MA2_0 && MA1_0>=MA2_0)) // Пересечение снизу вверх
     {
      PosClose=2;
     }
   return(PosClose);                                          // Возвращаем направление пересечен.
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenBuy()
  {
   if(all_positions==1)
     {
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               return;                          // Если buy, то не открываемся
     }
   if(!RefreshRates())
      return;

   m_trade.Buy(Lot,m_symbol.Name(),m_symbol.Ask(),0.0,0.0,"Buy: MA_cross_Method_PriceMode");// Открываемся
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSell()
  {
   if(all_positions==1)
     {
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.PositionType()==POSITION_TYPE_SELL)
               return;                             // Если sell, то не открываемся
     }
   m_trade.Sell(Lot,m_symbol.Name(),m_symbol.Bid(),0.0,0.0,"Sell: MA_cross_Method_PriceMode");
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
double iMAGet(const int handle,const int index)
  {
   double MA[];
   ArraySetAsSeries(MA,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,0,index+1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[index]);
  }
//+------------------------------------------------------------------+
