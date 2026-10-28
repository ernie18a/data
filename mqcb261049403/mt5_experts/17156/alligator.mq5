//+------------------------------------------------------------------+
//|                           Alligator(barabashkakvn's edition).mq5 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Демёхин Виталий Евгеньевич."
#property link      "Vitalya_1983@list.ru"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object
input double MaxLot           = 0.5;         //ограничиваем размер стартового лота
input double koeff            = 1.3;         // коэффициент увеличения лотов при мартингейле
input double risk             = 0.04;        // риск, влияет на размер стартового лота
input double shirina1         = 0.0005;      // ширина "зева" Alligator'а на открытие ордера
input double shirina2         = 0.0001;      // ширина "зева" Alligator'а на закрытие ордера

input bool   Ruchnik          = false;       // "Плавно" завершает сессию. Если надо отклюяить советник
input bool   Vhod_Alligator   = true;        // Разрешает открывать ордера Аллигатору
input bool   Vhod_Fractals    = false;       // Проверка Аллигатора Фракталом
input bool   Vyhod_Alligator  = false;       // Разрешает закрывать ордера Аллигатору
input bool   OnlyOneOrder     = true;        // Если False, включается докупка при повторе сигнала
input bool   EnableMartingail = true;        // Мартингейл
input bool   Trailing         = true;        // ТрейлингСтоп
//---
input ushort InpTP            = 80;          // TP
input ushort InpSL            = 80;          // SL 
input ushort InpTrailingStep  = 10;          // TrailingStep
input ushort InpProfitPips    = 20;          // Прибыль, pips
input ushort blue             = 0;
input ushort red              = 5;
input ushort green            = 16;
input int    Fractal_bars     = 10;          // Количество баров...
input ushort InpFractalHeight = 30;          // среди которых ищется соответствующий по высоте и направлению фрактал
input int    Koleno           = 10;          // Количество "Колен" Мартингейла
input ushort InpStepKoleno    = 50;          // Шаг колена
//---
bool Proverka_buy,Proverka_sell,Trailing_buy,Trailing_sell,Vihod_Alligator_sell,Vihod_Alligator_buy,Fractal;
int  current_buy=1,current_sell=1,prev_buy,prev_sell;
//string text;
double up,down;
ulong m_magic;
//---
double ExtTP            = 0.0;
double ExtSL            = 0.0;
double ExtTrailingStep  = 0.0;
double ExtProfitPips    = 0.0;
double ExtFractalHeight = 0.0;
double ExtStepKoleno    = 0.0;
//---
int    handle_iAlligator;                    // variable for storing the handle of the iAlligator indicator 
int    handle_iFractals;                     // variable for storing the handle of the iFractals indicator 
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
//--- create handle of the indicator iAlligator
   handle_iAlligator=iAlligator(Symbol(),Period(),13,8,8,5,5,3,MODE_SMMA,PRICE_WEIGHTED);
//--- if the handle is not created 
   if(handle_iAlligator==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAlligator indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iFractals
   handle_iFractals=iFractals(Symbol(),Period());
//--- if the handle is not created 
   if(handle_iFractals==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iFractals indicator for the symbol %s/%s, error code %d",
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtTP            = InpTP            * digits_adjust * m_symbol.Point();
   ExtSL            = InpSL            * digits_adjust * m_symbol.Point();
   ExtTrailingStep  = InpTrailingStep  * digits_adjust * m_symbol.Point();
   ExtProfitPips    = InpProfitPips    * digits_adjust * m_symbol.Point();
   ExtFractalHeight = InpFractalHeight * digits_adjust * m_symbol.Point();
   ExtStepKoleno    = InpStepKoleno    * digits_adjust * m_symbol.Point();

   m_magic=Period();     //Даем Магическое число для торговли на разных ТФ
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number

   string text="На Alligatorе:   ";
   text=text+Symbol()+"  "+EnumToString(Period())+" ";
   if(Vhod_Alligator)
     {
      text=text+"Аллигатор вкл  ";
     }
   if(Vhod_Fractals)
     {
      text=text+"Fraktals вкл  ";
     }
   if(!OnlyOneOrder)
     {
      text=text+"докупка вкл  ";
     }
   if(EnableMartingail)
     {
      text=text+"Мартингейл вкл  ";
     }
   if(Trailing)
     {
      text=text+"Trailing вкл  ";
     }
   Alert(text);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//text="";
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//RefreshRates();
// bool order_est_buy = false;      //сбрасываем счетчик открытых ордеров
//  int m_magic = Period();     //Даем Магическое число для торговли на разных ТФ
//int Orders=OrdersTotal();      //счетчик проверки ордеров
   if(Trailing==true)
     {
      Trailing_start();             // Запускаем трейлинг стоп
     }
   if(Vhod_Alligator==true) // Используя настройки Аллигатора определяем момент входа в рынок....
     {
      prev_buy=current_buy;         // "Сегодня так же как и вчера" :)
      prev_sell=current_sell;

      double blue_line=iAlligatorGet(GATORJAW_LINE,blue);
      double red_line=iAlligatorGet(GATORTEETH_LINE,red);
      double green_line=iAlligatorGet(GATORLIPS_LINE,green);

      double  PriceHigh=iHigh(m_symbol.Name(),Period(),0);

      if(green_line>blue_line+shirina1) // сигналы входа
         current_buy=1;

      if(blue_line>green_line+shirina1)
         current_sell=1;

      if(green_line+shirina2<red_line) // сигналы выхода
         current_buy=0;

      if(blue_line+shirina2<red_line)
         current_sell=0;
     }

   if(Vhod_Fractals) //Проверяем фракталом
     {
      Fractal();
     }
   if(!Proverka_buy() || OnlyOneOrder==false) // Если открытых Buy нет...
     {
      //--- закрываем отложенные ORDER_TYPE_BUY_LIMIT
      DeleteOrders(ORDER_TYPE_BUY_LIMIT);

      if(Ruchnik==false && (current_buy>prev_buy || Vhod_Alligator==false)) // если Аллигатор дал команду или не мешает...
         if(up>0 || Vhod_Fractals==false) // и фрактал дает добро
            LongOpen();                             // открываем длинную
     }
   if(!Proverka_sell() || OnlyOneOrder==false) // тоже самое, только для Sell...
     {
      //--- закрываем отложенные ORDER_TYPE_SELL_LIMIT
      DeleteOrders(ORDER_TYPE_SELL_LIMIT);

      if(Ruchnik==false && (current_sell>prev_sell || Vhod_Alligator==false))
         if(down>0 || Vhod_Fractals==false)
            ShortOpen();
     }
   if(Vyhod_Alligator==true) // если Аллигатор дал команду на закрытие
     {
      if(current_buy<prev_buy && Vihod_Alligator_buy==true)
        {
         // закрываем позиции Buy
         ClosePositions(POSITION_TYPE_BUY);
        }
      if(current_sell<prev_sell && Vihod_Alligator_sell==true)
        {
         // закрываем позиции Sell
         ClosePositions(POSITION_TYPE_BUY);
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Проверка наличия открытых BUY позиций                            |
//+------------------------------------------------------------------+
bool Proverka_buy()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               return(true);

   Vihod_Alligator_buy=true;
   return (false);
  }
//+------------------------------------------------------------------+
//| Проверка наличия открытых SEll позиций                           |
//+------------------------------------------------------------------+
bool Proverka_sell()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==POSITION_TYPE_SELL)
               return(true);

   Vihod_Alligator_sell=true;
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShortOpen()
  {
   double Lot=m_account.FreeMargin()/1000*risk;
   Lot=LotCheck(Lot);
   if(Lot==0)
      return;

   if(EnableMartingail==true)
      ExtTP=ExtSL/koeff;

   if(!RefreshRates())
      return;

   double new_tp=0.0;
   if(ExtTP>0)
      new_tp=m_symbol.Bid()-ExtTP;

   m_trade.Sell(Lot,Symbol(),m_symbol.Bid(),m_symbol.Bid()+ExtSL,new_tp);
   if(EnableMartingail==true) //Если мы используем мартингейл
     {
      for(int i=1; i<=Koleno; i++)
        {
         Lot=Lot*koeff;
         Lot=LotCheck(Lot);
         if(Lot==0)
            return;

         if(!RefreshRates())
            return;

         double price_new=NormalizeDouble(m_symbol.Bid()+ExtStepKoleno*(i),Digits());
         double sl_new=NormalizeDouble(price_new+ExtSL,Digits());
         double tp_new=NormalizeDouble(price_new-ExtTP,Digits());

         m_trade.SellLimit(Lot,price_new,Symbol(),sl_new,tp_new);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LongOpen()
  {
   double Lot=m_account.FreeMargin()/1000*risk;
   Lot=LotCheck(Lot);
   if(Lot==0)
      return;

   if(EnableMartingail==true)
      ExtTP=ExtSL/koeff;

   if(!RefreshRates())
      return;

   double new_tp=0.0;
   if(ExtTP>0)
      new_tp=m_symbol.Ask()+ExtTP;

   m_trade.Buy(Lot,Symbol(),m_symbol.Ask(),m_symbol.Ask()-ExtSL,new_tp);

   if(EnableMartingail==true)
     {
      for(int i=1; i<=Koleno; i++)
        {
         Lot=Lot*koeff;
         Lot=LotCheck(Lot);
         if(Lot==0)
            return;

         if(!RefreshRates())
            return;

         double price_new=NormalizeDouble(m_symbol.Ask()-ExtStepKoleno*(i),Digits());
         double sl_new=NormalizeDouble(price_new-ExtSL,Digits());
         double tp_new=NormalizeDouble(price_new+ExtTP,Digits());
         m_trade.BuyLimit(Lot,price_new,Symbol(),sl_new,tp_new);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing_start()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               //--- модификация SL
               if(ExtSL>0.0)
                 {
                  if(!RefreshRates())
                     return;

                  if(m_symbol.Bid()-ExtSL-ExtTrailingStep>m_position.StopLoss())
                    {
                     m_trade.PositionModify(m_position.Ticket(),m_symbol.Bid()-ExtSL,m_position.TakeProfit());
                     Vihod_Alligator_buy=false;
                    }
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               //--- модификация SL
               if(ExtSL>0.0)
                 {
                  if(!RefreshRates())
                     return;

                  if(m_symbol.Ask()+ExtSL+ExtTrailingStep<m_position.StopLoss())
                    {
                     m_trade.PositionModify(m_position.Ticket(),m_symbol.Bid()+ExtSL,m_position.TakeProfit());
                     Vihod_Alligator_buy=false;
                    }
                 }
              }
           }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Fractal()
  {
//--- Сброс сигналов
   up=0;
   down=0;
   for(int i=Fractal_bars;i>=3;i--)
     {
      //--- в наших барах должен быть фрактал
      double up_prov=iFractalsGet(UPPER_LINE,i);
      if(up_prov>up)
         up=up_prov;
      double down_prov=iFractalsGet(LOWER_LINE,i);
      if(down_prov>down)
         down=down_prov;
     }
   if(!RefreshRates())
      return;

//--- и этот фрактал должен быть заметен
   if(up<m_symbol.Ask()+ExtFractalHeight)
      up=0;
   if(down<m_symbol.Bid()-ExtFractalHeight)
      down=0;
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iAlligator                          |
//|  the buffer numbers are the following:                           |
//|   0 - GATORJAW_LINE, 1 - GATORTEETH_LINE, 2 - GATORLIPS_LINE     |
//+------------------------------------------------------------------+
double iAlligatorGet(const int buffer,const int index)
  {
   double Alligator[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iAlligator,buffer,index,1,Alligator)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iAlligator indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Alligator[0]);
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
//--- fill a part of the iFractalsBuffer array with values from the indicator buffer that has 0 index 
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
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==Symbol() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
//| Close Positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type)
               m_trade.PositionClose(m_position.Ticket());
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
