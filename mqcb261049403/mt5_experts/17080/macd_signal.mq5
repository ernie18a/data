//+------------------------------------------------------------------+
//|                         MACD signal(barabashkakvn's edition).mq5 |
//|                                                           tom112 |
//|                                            tom112@mail.wplus.net |
//+------------------------------------------------------------------+
#property copyright "tom112"
#property link "tom112@mail.wplus.net"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
//---- input parameters
input ushort   InpTakeProfit=10;             // TakeProfit
input double   Lots=0.01;
input ushort   InpTrailingStop=25;
input int      Pfast = 9;
input int      Pslow = 15;
input int      Psignal=8;
input double   LEVEL=0.004;
//---
double         Points=0.0;
ulong          m_magic=16384;                // magic number
//---
double         ExtTakeProfit=0.0;
double         ExtTrailingStop=0.0;
int            handle_iATR;                  // variable for storing the handle of the iATR indicator 
int            handle_iMACD;                 // variable for storing the handle of the iMACD indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//SetMarginMode();
//if(!IsHedging())
//  {
//   Print("Hedging only!");
//   return(INIT_FAILED);
//  }
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

   ExtTakeProfit     = InpTakeProfit   * digits_adjust;
   ExtTrailingStop   = InpTrailingStop * digits_adjust;
   Points            = m_symbol.Point();

// первичные проверки данных
// важно удостовериться что эксперт работает на нормальном графике и
// пользователь правильно выставил внешние переменные (Lots, StopLoss,
// ExtTakeProfit, ExtTrailingStop)
// в нашем случае проверяем только ExtTakeProfit
   if(Bars(Symbol(),Period())<205)
     {
      Print("bars less than 205 (period of iATR)");
      return(INIT_FAILED); // на графике менее 205 баров
     }
   if(ExtTakeProfit<10)
     {
      Print("TakeProfit less than 10");
      return(INIT_FAILED); // проверяем ExtTakeProfit
     }

//--- create handle of the indicator iATR
   handle_iATR=iATR(Symbol(),Period(),200);
//--- if the handle is not created 
   if(handle_iATR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(Symbol(),Period(),Pfast,Pslow,Psignal,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double MacdCurrent=0,MacdPrevious=0,SignalCurrent=0;
   double SignalPrevious=0,MaCurrent=0,MaPrevious=0;
   double Range,rr,Delta,Delta1;//val3;

   Range=iATRGet(1);
   rr=Range*LEVEL;
   Delta=iMACDGet(MAIN_LINE,0)-iMACDGet(SIGNAL_LINE,0);
   Delta1=iMACDGet(MAIN_LINE,1)-iMACDGet(SIGNAL_LINE,1);
// теперь надо определиться - в каком состоянии торговый терминал?
// проверим, есть ли ранее открытые позиции или ордеры?
   if(TotalPositions()<1)
     {
      // нет ни одного открытого ордера
      // на всякий случай проверим, если у нас свободные деньги на счету?
      // значение 1000 взято для примера, обычно можно открыть 1 лот
      if(m_account.FreeMargin()<(1000*Lots))
        {
         Print("We have no money");
         return; // денег нет - выходим
        }
      // проверим, не слишком ли часто пытаемся открыться?
      // если последний раз торговали менее чем 5 минут(5*60=300 сек)
      // назад, то выходим
      // If((CurTime-LastTradeTime)<300) return(0);
      // проверяем на возможность встать в длинную позицию (BUY)
      if(Delta>rr && Delta1<rr)
        {
         if(!RefreshRates())
            return;

         if(m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),0,
            m_symbol.NormalizePrice(m_symbol.Ask()+ExtTakeProfit*Points),"macd signal")) // исполняем
            Print("Positions opened : ",m_trade.ResultPrice());
         else
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
         //--- выходим, так как все равно после совершения торговой операции
         //--- наступил 10-ти секундный таймаут на совершение торговых операций
         return;
        }
      // проверяем на возможность встать в короткую позицию (SELL)
      if(Delta<-rr && Delta1>-rr)
        {
         if(!RefreshRates())
            return;

         if(m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),0,
            m_symbol.NormalizePrice(m_symbol.Bid()-ExtTakeProfit*Points),"macd sample")) // исполняем
            Print("Order opened : ",m_trade.ResultPrice());
         else
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
         return; // выходим
        }
      //--- здесь мы завершили проверку на возможность открытия новых позиций.
      //--- новые позиции открыты не были и просто выходим по Exit, так как
      //--- все равно анализировать нечего
      return;
     }
//--- переходим к важной части эксперта - контролю открытых позиций
//--- 'важно правильно войти в рынок, но выйти - еще важнее...'
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i)) // выбираем позицию по индексу
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic) // если символ и магик совпадают
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY) // открыта длинная позиция
              {
               //--- проверим, может уже пора закрываться?
               if(Delta<0)
                 {
                  //--- закрываем позицию
                  m_trade.PositionClose(m_position.Ticket());
                  return; // выходим
                 }
               //--- проверим - может можно/нужно уже трейлинг стоп ставить?
               if(ExtTrailingStop>0) // пользователь выставил в настройках трейлингстоп
                 { // значит мы идем его проверять
                  if(!RefreshRates())
                     return;

                  if(m_symbol.Bid()-m_position.PriceOpen()>Points*ExtTrailingStop)
                    {
                     if(m_position.StopLoss()<m_symbol.Bid()-Points*ExtTrailingStop)
                       {
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Bid()-Points*ExtTrailingStop,
                                               m_position.TakeProfit());
                        return;
                       }
                    }
                 }
              }
            else // иначе это короткая позиция
              {
               //--- проверим, может уже пора закрываться?
               if(Delta>0)
                 {
                  //--- закрываем позицию
                  m_trade.PositionClose(m_position.Ticket());
                  return; // выходим
                 }
               //--- проверим - может можно/нужно уже трейлинг стоп ставить?
               if(ExtTrailingStop>0) // пользователь выставил в настройках трейлингстоп
                 { // значит мы идем его проверять
                  if(!RefreshRates())
                     return;

                  if((m_position.PriceOpen()-m_symbol.Ask())>(Points*ExtTrailingStop))
                    {
                     if(m_position.StopLoss()==0.0 || m_position.StopLoss()>
                        (m_symbol.Ask()+Points*ExtTrailingStop))
                       {
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Ask()+Points*ExtTrailingStop,
                                               m_position.TakeProfit());
                        return;
                       }
                    }
                 }
              }
           }
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
//| Get value of buffers for the iATR                                |
//+------------------------------------------------------------------+
double iATRGet(const int index)
  {
   double ATR[];
   ArraySetAsSeries(ATR,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iATR array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iATR,0,0,index+1,ATR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ATR[index]);
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
int TotalPositions()
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            total++;
   return(total);
  }
//+------------------------------------------------------------------+
