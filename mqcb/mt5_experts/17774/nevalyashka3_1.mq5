//+------------------------------------------------------------------+
//|                      Nevalyashka3_1(barabashkakvn's edition).mq5 |
//|                               Copyright © 2013  Сергей Собакин   |
//|                                                zavanet@mail.ru   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013  Сергей Собакин"
#property link      "zavanet@mail.ru"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
input double   StartLot       = 0.1;   // лот (N)
input double   K_lot          = 1.1;   // лот, на который увеличиться при получении минуса (M) либо это множитель коэф
input ushort   takeprofit     = 94;    // Профит
input ushort   moveprofit     = 25;    // Трайлинг
input ushort   movestep       = 11;    // Шаг трейлинга
input ushort   stoploss       = 70;    // Стоп лосс
//---
int tip;//Тип ордера (Селл, Бай)
double eq=0; //Сохраненное значение эквити
double min=0;
double max=0;
double Lot; //лот (N)
double ma;
string n;
int TP;
int op;
//---
ulong          m_magic=15489;                // magic number
ulong          m_slippage=30;                // slippage
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//---
   eq=m_account.Equity(); // Запоминаем эквити
   Lot=StartLot;       // Лот равен начальному 
   if(OpenSell(Lot,m_symbol.Ask()+stoploss*m_adjusted_point,m_symbol.Ask()-takeprofit*m_adjusted_point)) // В начале открываем селл.tip=1
     {
      tip=1;
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
   if(!RefreshRates())
      return;

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // Есть позиции, отслеживаем трал
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            total++;
            if(m_position.PositionType()==POSITION_TYPE_BUY) // tip==0 -> Бай
              {
               if(m_symbol.Bid()-m_position.PriceOpen()>moveprofit*m_adjusted_point)// Цена ушла выше цены открытия позиции на шаг трала
                 {
                  if(m_symbol.Bid()-(stoploss+movestep)*m_adjusted_point>m_position.StopLoss())
                    {
                     m_trade.PositionModify(m_position.Ticket(),m_symbol.Bid()-stoploss*m_adjusted_point,m_position.TakeProfit()); // Переносим стоп выше
                     if(Lot>StartLot && (m_symbol.Bid()-stoploss*m_adjusted_point>m_position.PriceOpen()))
                        Lot=Lot/K_lot; //Если текущий стоп выше цены открытия, то уменьшаем лот следующей позиции
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.PriceOpen()-m_symbol.Ask()>moveprofit*m_adjusted_point)
                 {
                  if(m_symbol.Ask()+(stoploss+movestep)*m_adjusted_point<m_position.StopLoss() && m_position.StopLoss()!=0)
                    {
                     m_trade.PositionModify(m_position.Ticket(),m_symbol.Ask()+stoploss*m_adjusted_point,m_position.TakeProfit());
                     if(Lot>StartLot && (m_symbol.Ask()+stoploss*m_adjusted_point<m_position.PriceOpen()))
                        Lot=Lot/K_lot;
                    }
                 }
              }
           }

   if(total==0) // Позиций нет
     {
      if(m_account.Equity()>eq) // Текущее эквити больше сохраненного,т.е. закрылись в плюс
        {
         eq=m_account.Equity();  // Запоминаем текущее эквити

         double temp_lot=StartLot;   // Объем лота сбрасывает до начального  
         temp_lot=LotCheck(temp_lot);
         if(temp_lot==0)
            return;
         Lot=temp_lot;

         if(tip==0) // Закрылся бай
           {
            //--- Открываем позицию в том же направлении 
            OpenBuy(Lot,m_symbol.Ask()-stoploss*m_adjusted_point,m_symbol.Ask()+takeprofit*m_adjusted_point);
           }
         if(tip==1) // Закрылся селл
           {
            //--- Открываем позицию в том же направлении 
            OpenSell(Lot,m_symbol.Bid()+stoploss*m_adjusted_point,m_symbol.Bid()-takeprofit*m_adjusted_point);
           }
        }
      else // Текущее эквити меньше сохраненного,т.е. закрылись в минус
        {
         double temp_lot=Lot*K_lot; //увеличили лот
         temp_lot=LotCheck(temp_lot);
         if(temp_lot==0)
            return;
         Lot=temp_lot;

         if(tip==0) //Закрылся бай 
           {
            if(OpenSell(Lot,m_symbol.Ask()+stoploss*m_adjusted_point,m_symbol.Ask()-takeprofit*m_adjusted_point)) // Открыли селл
              {
               tip=1;                           // пометили селл
               return;
              }
           }
         if(tip==1)
           {
            if(OpenBuy(Lot,m_symbol.Bid()-stoploss*m_adjusted_point,m_symbol.Bid()+takeprofit*m_adjusted_point))
              {
               tip=0;
              }
           }
        }
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
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(double lot,double sl,double tp)
  {
   bool result=false;

   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=lot)
        {
         if(m_trade.Sell(lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(double lot,double sl,double tp)
  {
   bool result=false;

   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=lot)
        {
         if(m_trade.Buy(lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
