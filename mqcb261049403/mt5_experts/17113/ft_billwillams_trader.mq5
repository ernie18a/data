//+------------------------------------------------------------------+
//|               FT BillWillams Trader(barabashkakvn's edition).mq5 |
//|                                                     FORTRADER.RU |
//|                                              http://FORTRADER.RU |
//+------------------------------------------------------------------+
#property copyright "FORTRADER.RU"
#property link      "http://FORTRADER.RU"
#property version   "1.001"

#define MODE_LOW 1
#define MODE_HIGH 2

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
input string   FT1="------Настройки фрактала:----------";
input int      CountBarsFractal=5;//количество баров из которых состоит фрактал
input int      ClassicFractal=1; //включение выключение классического паттерна
input int      MaxDistance=1000;//включение контроля расстояния от зеленой линии до точки входа
input string   FT2="------Настройки типа пробоя фрактала:----------";
input ushort   InpIndent=1; //количество пунктов для отступа от максимума и минимума
input int      TypeEntry=2; //тип входа после пробоя фрактала: 1 - на текущем баре, 2 - на баре закрытия, 3 на откате к точке входа после пробоя
input int      RedContol=1; //контролировать находится ли пробойная цена выше ниже уровня красной линии
input string   FT3="------Настройки аллигатора:----------";
input int      jaw_period=13;  // период усреднения синей линии (челюсти аллигатора)
input int      jaw_shift=8;  // смещение синей линии относительно графика цены
input int      teeth_period=8;  // период усреднения красной линии (зубов аллигатора)
input int      teeth_shift=5;  // смещение красной линии относительно графика цены
input int      lips_period=5; //  период усреднения зеленой линии (губ аллигатора)
input int      lips_shift=3;  // смещение зеленой линии относительно графика цены
input ENUM_MA_METHOD ma_method=MODE_SMA;   // метод усреднения. 
input ENUM_APPLIED_PRICE applied_price=PRICE_MEDIAN; // используемая цена
input string FT4="-------Настройки контроля тренда по аллигатору:----------";
input int      TrendAligControl=0; // включение контроля тренда по алигатору
input ushort   InpJawTeethDistense=10; //разница между зеленой и красной
input ushort   InpTeethLipsDistense=10;//разница между красной и синией
input string   FT5="-------Настройки контроля закрытия сделки:----------";
input int      CloseDropTeeth=2; // включение закрытия сделки при косании или пробое челюсти. 0 - отключение 1 - по касанию 2 по закрытию бара
input int      CloseReversSignal=2;// включение закрытия сделки при 1- образовании обратного фрактала 2 - при срабатывании обратного фрактала 0 выключено 
input string   FT6="-------Настройки сопровождения ExtStopLoss сделки:----------";
input int      TrailingGragus=1; //Включение трейлинг стопа по ценовому градусу наклона, если сильный угол то трейлинг по зеленой, если малый угол то трейлинг по красной
input int      smaperugol=5;
input string   FT7="-------Настройки  ExtStopLoss и ExtTakeProfit ибьема сделки:----------";
input ushort   InpStopLoss=50;
input ushort   InpTakeProfit=50;
input double   Lots=0.1;
//---
double         ExtIndent=0.0;
double         ExtJawTeethDistense=0.0;
double         ExtTeethLipsDistense=0.0;
double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
//---
double oldopb,opb,ops,oldops,otkatb,otkats;
int fractalnew,vpravovlevo,numsredbar,colish;
//---
ulong          m_magic=117062220;                  // magic number
int            handle_iMA;                         // variable for storing the handle of the iMA indicator 
int            handle_iAlligator;                  // variable for storing the handle of the iAlligator indicator 
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   ExtIndent            = InpIndent             * digits_adjust;
   ExtJawTeethDistense  = InpJawTeethDistense   * digits_adjust;
   ExtTeethLipsDistense = InpTeethLipsDistense  * digits_adjust;
   ExtStopLoss          = InpStopLoss           * digits_adjust;
   ExtTakeProfit        = InpTakeProfit         * digits_adjust;
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),Period(),smaperugol,0,MODE_EMA,PRICE_CLOSE);
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
//--- create handle of the indicator iAlligator
   handle_iAlligator=iAlligator(m_symbol.Name(),Period(),
                                jaw_period,jaw_shift,
                                teeth_period,teeth_shift,
                                lips_period,lips_shift,
                                ma_method,applied_price);
//--- if the handle is not created 
   if(handle_iAlligator==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAlligator indicator for the symbol %s/%s, error code %d",
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

   ClassicFractal();
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  ClassicFractal()
  {
   int buy=0,sell=0;
   double sl=0.0,tp=0.0;

//--- управление позициями
   ClassicFractalPosManager();

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               buy=1;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               sell=1;
           }

//---  найдем сколько смотреть вправо и влево
   vpravovlevo=(CountBarsFractal-1)/2;
   numsredbar=(CountBarsFractal-vpravovlevo);
   colish=numsredbar-1;

//--- ПОКУПКА ---

//---  найдем фрактал на покупку
   if(iHigh(m_symbol.Name(),Period(),numsredbar)>
      iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,colish,numsredbar+1)) &&
      iHigh(m_symbol.Name(),Period(),numsredbar)>
      iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,colish,1)) &&
      (RedContol(iClose(m_symbol.Name(),Period(),1),0)==true && RedContol==1))
     {
      opb=NormalizeDouble(iHigh(m_symbol.Name(),Period(),numsredbar)+ExtIndent*Point(),4);
     }

   if(!RefreshRates())
      return;

//---  проверка входа на касании или по закрытию бара
   if(buy==0 && ((m_symbol.Ask()>opb && TypeEntry==1) || (iClose(m_symbol.Name(),Period(),1)>opb && TypeEntry==2))
      && opb!=oldopb && MaxDistance(opb)==true && opb>0
      && ((RedContol(iClose(m_symbol.Name(),Period(),1),0)==true && RedContol==1) || RedContol==0)
      && ((TrendAligControl(0)==true && TrendAligControl==1) || TrendAligControl==0))
     {
      oldopb=opb;
      sl=NormalizeDouble(m_symbol.Ask()-ExtStopLoss*Point(),4);
      tp=NormalizeDouble(m_symbol.Ask()+ExtTakeProfit*Point(),4);
      m_trade.Buy(Lots,m_symbol.Name(),m_symbol.Ask(),sl,tp,"FORTRADER.RU");
     }

//--- ПРОДАЖА ---

//--- найдем фрактал на продажу
   if(iLow(m_symbol.Name(),Period(),numsredbar)<iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,colish,numsredbar+1)) &&
      iLow(m_symbol.Name(),Period(),numsredbar)<iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,colish,0)) && (RedContol(iClose(m_symbol.Name(),Period(),1),1)==true && RedContol==1))
     {
      ops=NormalizeDouble(iLow(m_symbol.Name(),Period(),numsredbar)-ExtIndent*Point(),4);
     }
//--- проверка входа на касании или по закрытию бара
   if(sell==0 && ((m_symbol.Bid()<ops && TypeEntry==1) || (iClose(m_symbol.Name(),Period(),1)<ops && TypeEntry==2))
      && oldops!=ops && MaxDistance(ops)==true
      && ((RedContol(iClose(m_symbol.Name(),Period(),1),1)==true && RedContol==1) || RedContol==0)
      && ((TrendAligControl(1)==true && TrendAligControl==1) || TrendAligControl==0))
     {
      oldops=ops;
      sl=NormalizeDouble(m_symbol.Bid()+ExtStopLoss*Point(),4);
      tp=NormalizeDouble(m_symbol.Bid()-ExtTakeProfit*Point(),4);
      m_trade.Sell(Lots,m_symbol.Name(),m_symbol.Bid(),sl,tp,"FORTRADER.RU");
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MaxDistance(double entryprice)
  {
   double lips=iAlligatorGet(GATORLIPS_LINE,1);
   if(MathAbs(entryprice-lips)<MaxDistance*Point())
     {
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RedContol(double entryprice,int  type)
  {
   double teeth=iAlligatorGet(GATORTEETH_LINE,1);

   if(entryprice>teeth && type==0)
     {
      return(true);
     }
   if(entryprice<teeth && type==1)
     {
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TrendAligControl(int type)
  {
   double teeth=iAlligatorGet(GATORTEETH_LINE,1);
   double lips=iAlligatorGet(GATORLIPS_LINE,1);
   double jaw=iAlligatorGet(GATORJAW_LINE,1);

   if(type==0 && lips-teeth>ExtTeethLipsDistense*Point() && teeth-jaw>ExtJawTeethDistense*Point())
     {
      return(true);
     }
   if(type==1 && teeth-lips>ExtTeethLipsDistense*Point() && jaw-teeth>ExtJawTeethDistense*Point())
     {
      return(true);
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClassicFractalPosManager()
  {
   int buy=0,sell=0;
   double jaw     = iAlligatorGet(GATORJAW_LINE,1);
   double teeth   = iAlligatorGet(GATORTEETH_LINE,1);
   double lips    = iAlligatorGet(GATORLIPS_LINE,1);
   double lipsl   = iAlligatorGet(GATORLIPS_LINE,2);
   double sma     = iMAGet(1);
   double smal    = iMAGet(2);

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               buy++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               sell++;
           }
   if(!RefreshRates())
      return;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if((CloseDropTeeth==1 && m_symbol.Bid()<=jaw) || (CloseDropTeeth==2 && iClose(m_symbol.Name(),Period(),1)<=jaw))
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
               //--- CloseReversSignal -> включение закрытия сделки при: 
               //--- 1 - образовании обратного фрактала, 2 - при срабатывании обратного фрактала, 0 выключено
               if((CloseReversSignal==1 && iLow(m_symbol.Name(),Period(),numsredbar)<iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,colish,numsredbar+1)) && 
                  iLow(m_symbol.Name(),Period(),numsredbar)<iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,colish,0))) || (CloseReversSignal==2 && sell==1))
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }

               if(TrailingGragus==1 && lips-lipsl>sma-smal && m_position.Profit()>0)
                 {
                  if(m_position.StopLoss()<lips)
                    {
                     m_trade.PositionModify(m_position.Ticket(),lips,m_position.TakeProfit());
                     return;
                    }
                 }

               if(TrailingGragus==1 && lips-lipsl<=sma-smal && m_position.Profit()>0)
                 {
                  if(m_position.StopLoss()<teeth || lips>teeth)
                    {
                     m_trade.PositionModify(m_position.Ticket(),teeth,m_position.TakeProfit());
                     return;
                    }
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if((CloseDropTeeth==1 && m_symbol.Ask()>=jaw) || (CloseDropTeeth==2 && iClose(m_symbol.Name(),Period(),1)>=jaw))
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }

               //--- CloseReversSignal -> включение закрытия сделки при: 
               //--- 1 - образовании обратного фрактала, 2 - при срабатывании обратного фрактала, 0 выключено
               if(((CloseReversSignal==1 && iHigh(m_symbol.Name(),Period(),numsredbar)>iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,colish,numsredbar+1)) && 
                  iHigh(m_symbol.Name(),Period(),numsredbar)>iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,colish,1))) || (CloseReversSignal==2 && buy==1)))
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }

               if(TrailingGragus==1 && lipsl-lips<smal-sma && m_position.Profit()>0)
                 {
                  if(m_position.StopLoss()>lips)
                    {
                     m_trade.PositionModify(m_position.Ticket(),lips,m_position.TakeProfit());
                     return;
                    }
                 }

               if(TrailingGragus==1 && lipsl-lips>smal-sma && m_position.Profit()>0)
                 {
                  if(m_position.StopLoss()>teeth || lips<teeth)
                    {
                     m_trade.PositionModify(m_position.Ticket(),teeth,m_position.TakeProfit());
                     return;
                    }
                 }
              }
           }
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
