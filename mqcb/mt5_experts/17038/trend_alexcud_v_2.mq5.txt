//+------------------------------------------------------------------+
//|                   TREND_alexcud v_2(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007"
#property link      ""
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input ushort InpStopLoss      = 20;          // StopLoss
input ushort InpTakeProfit    = 30;          // TakeProfit
input ushort InpTrailingStop  = 0;           // TrailingStop
input double Lots             = 0.1;         // Lots
input int OpenLevel           = 1;           //Уровень открытия 0 или 1
input int CloseLevel          = 1;           //Уровень закрытия 0 или 1
input ENUM_TIMEFRAMES TF1     = PERIOD_M15;
input ENUM_TIMEFRAMES TF2     = PERIOD_H1;
input ENUM_TIMEFRAMES TF3     = PERIOD_H4;
input int maTrendPeriodv_1    = 5;
input int maTrendPeriodv_2    = 8;
input int maTrendPeriodv_3    = 13;
input int maTrendPeriodv_4    = 21;
input int maTrendPeriodv_5    = 34;
//---
int Signal;
double SL,TP;
ulong  m_magic=89643981;    // magic number
//---
double ExtStopLoss            = 0.0;
double ExtTakeProfit          = 0.0;
double ExtTrailingStop        = 0.0;
//--- 
int    handle_iMA_TF1_Per_1;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF1_Per_2;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF1_Per_3;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF1_Per_4;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF1_Per_5;                 // variable for storing the handle of the iMA indicator 

int    handle_iMA_TF2_Per_1;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF2_Per_2;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF2_Per_3;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF2_Per_4;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF2_Per_5;                 // variable for storing the handle of the iMA indicator  

int    handle_iMA_TF3_Per_1;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF3_Per_2;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF3_Per_3;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF3_Per_4;                 // variable for storing the handle of the iMA indicator 
int    handle_iMA_TF3_Per_5;                 // variable for storing the handle of the iMA indicator 

int    handle_iAC_TF1;                       // variable for storing the handle of the iAC indicator 
int    handle_iAC_TF3;                       // variable for storing the handle of the iAC indicator 
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
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtStopLoss       = InpStopLoss     * digits_adjust;
   ExtTakeProfit     = InpTakeProfit   * digits_adjust;
   ExtTrailingStop   = InpTrailingStop * digits_adjust;

   if(!CreateiMA(TF1,maTrendPeriodv_1,handle_iMA_TF1_Per_1))
      return(INIT_FAILED);
   if(!CreateiMA(TF1,maTrendPeriodv_2,handle_iMA_TF1_Per_2))
      return(INIT_FAILED);
   if(!CreateiMA(TF1,maTrendPeriodv_3,handle_iMA_TF1_Per_3))
      return(INIT_FAILED);
   if(!CreateiMA(TF1,maTrendPeriodv_4,handle_iMA_TF1_Per_4))
      return(INIT_FAILED);
   if(!CreateiMA(TF1,maTrendPeriodv_5,handle_iMA_TF1_Per_5))
      return(INIT_FAILED);

   if(!CreateiMA(TF2,maTrendPeriodv_1,handle_iMA_TF2_Per_1))
      return(INIT_FAILED);
   if(!CreateiMA(TF2,maTrendPeriodv_2,handle_iMA_TF2_Per_2))
      return(INIT_FAILED);
   if(!CreateiMA(TF2,maTrendPeriodv_3,handle_iMA_TF2_Per_3))
      return(INIT_FAILED);
   if(!CreateiMA(TF2,maTrendPeriodv_4,handle_iMA_TF2_Per_4))
      return(INIT_FAILED);
   if(!CreateiMA(TF2,maTrendPeriodv_5,handle_iMA_TF2_Per_5))
      return(INIT_FAILED);

   if(!CreateiMA(TF3,maTrendPeriodv_1,handle_iMA_TF3_Per_1))
      return(INIT_FAILED);
   if(!CreateiMA(TF3,maTrendPeriodv_2,handle_iMA_TF3_Per_2))
      return(INIT_FAILED);
   if(!CreateiMA(TF3,maTrendPeriodv_3,handle_iMA_TF3_Per_3))
      return(INIT_FAILED);
   if(!CreateiMA(TF3,maTrendPeriodv_4,handle_iMA_TF3_Per_4))
      return(INIT_FAILED);
   if(!CreateiMA(TF3,maTrendPeriodv_5,handle_iMA_TF3_Per_5))
      return(INIT_FAILED);

   if(!CreateiAC(TF1,handle_iAC_TF1))
      return(INIT_FAILED);
   if(!CreateiAC(TF3,handle_iAC_TF3))
      return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime   prev_time   = 0;
   datetime          time_0      = iTime(m_symbol.Name(),Period(),0);
   if(time_0==prev_time)
      return;
   prev_time=time_0;

   TREND_alexcud();

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   if(!RefreshRates())
      return;

   if(total==0)
     {
      if(Signal>OpenLevel)
        {
         SL=0;TP=0;
         if(ExtStopLoss>0)   SL=m_symbol.Ask()-Point()*ExtStopLoss;
         if(ExtTakeProfit>0) TP=m_symbol.Ask()+Point()*ExtTakeProfit;
         m_trade.Buy(Lots,m_symbol.Name(),m_symbol.Ask(),SL,TP);
         return;
        }
      if(Signal<OpenLevel)
        {
         SL=0;TP=0;
         if(ExtStopLoss>0)   SL=m_symbol.Bid()+Point()*ExtStopLoss;
         if(ExtTakeProfit>0) TP=m_symbol.Bid()-Point()*ExtTakeProfit;
         m_trade.Sell(Lots,m_symbol.Name(),m_symbol.Bid(),SL,TP);
         return;
        }
     }

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(Signal<-CloseLevel)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
               if(ExtTrailingStop>0
                  &&  m_symbol.Bid()-m_position.PriceOpen()>Point()*ExtTrailingStop
                  && m_position.StopLoss()<m_symbol.Bid()-Point()*ExtTrailingStop)
                 {
                  m_trade.PositionModify(m_position.Ticket(),m_symbol.Bid()-Point()*ExtTrailingStop,m_position.TakeProfit());
                  return;
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(Signal>CloseLevel)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
               if(ExtTrailingStop>0
                  && m_position.PriceOpen()-m_symbol.Ask()>Point()*ExtTrailingStop
                  && (m_position.StopLoss()>m_symbol.Ask()+Point()*ExtTrailingStop || m_position.StopLoss()==0))
                 {
                  m_trade.PositionModify(m_position.Ticket(),m_symbol.Ask()+Point()*ExtTrailingStop,m_position.TakeProfit());
                  return;
                 }
              }
           }

   return;
  }
//+------------------------------------------------------------------+
void TREND_alexcud()
  {
   double MaH11v,MaH41v,MaD11v,MaH1pr1v,MaH4pr1v,MaD1pr1v;
   double MaH12v,MaH42v,MaD12v,MaH1pr2v,MaH4pr2v,MaD1pr2v;
   double MaH13v,MaH43v,MaD13v,MaH1pr3v,MaH4pr3v,MaD1pr3v;
   double MaH14v,MaH44v,MaD14v,MaH1pr4v,MaH4pr4v,MaD1pr4v;
   double MaH15v,MaH45v,MaD15v,MaH1pr5v,MaH4pr5v,MaD1pr5v;

   double u1x5v=0.0,u1x8v=0.0,u1x13v=0.0,u1x21v=0.0,u1x34v=0.0;
   double u2x5v=0.0,u2x8v=0.0,u2x13v=0.0,u2x21v=0.0,u2x34v=0.0;
   double u3x5v=0.0,u3x8v=0.0,u3x13v=0.0,u3x21v=0.0,u3x34v=0.0;
   double u1acv=0.0,u2acv=0.0,u3acv=0.0;

   double d1x5v=0.0,d1x8v=0.0,d1x13v=0.0,d1x21v=0.0,d1x34v=0.0;
   double d2x5v=0.0,d2x8v=0.0,d2x13v=0.0,d2x21v=0.0,d2x34v=0.0;
   double d3x5v=0.0,d3x8v=0.0,d3x13v=0.0,d3x21v=0.0,d3x34v=0.0;
   double d1acv=0.0,d2acv=0.0,d3acv=0.0;

   MaH11v=iMAGet(handle_iMA_TF1_Per_1,1);   MaH1pr1v=iMAGet(handle_iMA_TF1_Per_1,2);
   MaH12v=iMAGet(handle_iMA_TF1_Per_2,1);   MaH1pr2v=iMAGet(handle_iMA_TF1_Per_2,2);
   MaH13v=iMAGet(handle_iMA_TF1_Per_3,1);   MaH1pr3v=iMAGet(handle_iMA_TF1_Per_3,2);
   MaH14v=iMAGet(handle_iMA_TF1_Per_4,1);   MaH1pr4v=iMAGet(handle_iMA_TF1_Per_4,2);
   MaH15v=iMAGet(handle_iMA_TF1_Per_5,1);   MaH1pr5v=iMAGet(handle_iMA_TF1_Per_5,2);

   MaH41v=iMAGet(handle_iMA_TF2_Per_1,1);   MaH4pr1v=iMAGet(handle_iMA_TF2_Per_1,2);
   MaH42v=iMAGet(handle_iMA_TF2_Per_2,1);   MaH4pr2v=iMAGet(handle_iMA_TF2_Per_2,2);
   MaH43v=iMAGet(handle_iMA_TF2_Per_3,1);   MaH4pr3v=iMAGet(handle_iMA_TF2_Per_3,2);
   MaH44v=iMAGet(handle_iMA_TF2_Per_4,1);   MaH4pr4v=iMAGet(handle_iMA_TF2_Per_4,2);
   MaH45v=iMAGet(handle_iMA_TF2_Per_5,1);   MaH4pr5v=iMAGet(handle_iMA_TF2_Per_5,2);

   MaD11v=iMAGet(handle_iMA_TF3_Per_1,1);   MaD1pr1v=iMAGet(handle_iMA_TF3_Per_1,2);
   MaD12v=iMAGet(handle_iMA_TF3_Per_2,1);   MaD1pr2v=iMAGet(handle_iMA_TF3_Per_2,2);
   MaD13v=iMAGet(handle_iMA_TF3_Per_3,1);   MaD1pr3v=iMAGet(handle_iMA_TF3_Per_3,2);
   MaD14v=iMAGet(handle_iMA_TF3_Per_4,1);   MaD1pr4v=iMAGet(handle_iMA_TF3_Per_4,2);
   MaD15v=iMAGet(handle_iMA_TF3_Per_5,1);   MaD1pr5v=iMAGet(handle_iMA_TF3_Per_5,2);

   if(MaH11v < MaH1pr1v) {u1x5v = 0; d1x5v = 1;}
   if(MaH11v > MaH1pr1v) {u1x5v = 1; d1x5v = 0;}
   if(MaH11v == MaH1pr1v){u1x5v = 0; d1x5v = 0;}
   if(MaH41v < MaH4pr1v) {u2x5v = 0; d2x5v = 1;}
   if(MaH41v > MaH4pr1v) {u2x5v = 1; d2x5v = 0;}
   if(MaH41v == MaH4pr1v){u2x5v = 0; d2x5v = 0;}
   if(MaD11v < MaD1pr1v) {u3x5v = 0; d3x5v = 1;}
   if(MaD11v > MaD1pr1v) {u3x5v = 1; d3x5v = 0;}
   if(MaD11v == MaD1pr1v){u3x5v = 0; d3x5v = 0;}

   if(MaH12v < MaH1pr2v) {u1x8v = 0; d1x8v = 1;}
   if(MaH12v > MaH1pr2v) {u1x8v = 1; d1x8v = 0;}
   if(MaH12v == MaH1pr2v){u1x8v = 0; d1x8v = 0;}
   if(MaH42v < MaH4pr2v) {u2x8v = 0; d2x8v = 1;}
   if(MaH42v > MaH4pr2v) {u2x8v = 1; d2x8v = 0;}
   if(MaH42v == MaH4pr2v){u2x8v = 0; d2x8v = 0;}
   if(MaD12v < MaD1pr2v) {u3x8v = 0; d3x8v = 1;}
   if(MaD12v > MaD1pr2v) {u3x8v = 1; d3x8v = 0;}
   if(MaD12v == MaD1pr2v){u3x8v = 0; d3x8v = 0;}

   if(MaH13v < MaH1pr3v) {u1x13v = 0; d1x13v = 1;}
   if(MaH13v > MaH1pr3v) {u1x13v = 1; d1x13v = 0;}
   if(MaH13v == MaH1pr3v){u1x13v = 0; d1x13v = 0;}
   if(MaH43v < MaH4pr3v) {u2x13v = 0; d2x13v = 1;}
   if(MaH43v > MaH4pr3v) {u2x13v = 1; d2x13v = 0;}
   if(MaH43v == MaH4pr3v){u2x13v = 0; d2x13v = 0;}
   if(MaD13v < MaD1pr3v) {u3x13v = 0; d3x13v = 1;}
   if(MaD13v > MaD1pr3v) {u3x13v = 1; d3x13v = 0;}
   if(MaD13v == MaD1pr3v){u3x13v = 0; d3x13v = 0;}

   if(MaH14v < MaH1pr4v) {u1x21v = 0; d1x21v = 1;}
   if(MaH14v > MaH1pr4v) {u1x21v = 1; d1x21v = 0;}
   if(MaH14v == MaH1pr4v){u1x21v = 0; d1x21v = 0;}
   if(MaH44v < MaH4pr4v) {u2x21v = 0; d2x21v = 1;}
   if(MaH44v > MaH4pr4v) {u2x21v = 1; d2x21v = 0;}
   if(MaH44v == MaH4pr4v){u2x21v = 0; d2x21v = 0;}
   if(MaD14v < MaD1pr4v) {u3x21v = 0; d3x21v = 1;}
   if(MaD14v > MaD1pr4v) {u3x21v = 1; d3x21v = 0;}
   if(MaD14v == MaD1pr4v){u3x21v = 0; d3x21v = 0;}

   if(MaH15v < MaH1pr5v) {u1x34v = 0; d1x34v = 1;}
   if(MaH15v > MaH1pr5v) {u1x34v = 1; d1x34v = 0;}
   if(MaH15v == MaH1pr5v){u1x34v = 0; d1x34v = 0;}
   if(MaH45v < MaH4pr5v) {u2x34v = 0; d2x34v = 1;}
   if(MaH45v > MaH4pr5v) {u2x34v = 1; d2x34v = 0;}
   if(MaH45v == MaH4pr5v){u2x34v = 0; d2x34v = 0;}
   if(MaD15v < MaD1pr5v) {u3x34v = 0; d3x34v = 1;}
   if(MaD15v > MaD1pr5v) {u3x34v = 1; d3x34v = 0;}
   if(MaD15v == MaD1pr5v){u3x34v = 0; d3x34v = 0;}

   double  acv  = iACGet(handle_iAC_TF1, 1);
   double  ac1v = iACGet(handle_iAC_TF1, 2);
   double  ac2v = iACGet(handle_iAC_TF1, 3);
   double  ac3v = iACGet(handle_iAC_TF1, 4);

   if((ac1v>ac2v && ac2v>ac3v && acv<0 && acv>ac1v) || (acv>ac1v && ac1v>ac2v && acv>0))
     {
      u1acv=3; d1acv=0;
     }
   if((ac1v<ac2v && ac2v<ac3v && acv>0 && acv<ac1v) || (acv<ac1v && ac1v<ac2v && acv<0))
     {
      u1acv=0; d1acv=3;
     }
   if((((ac1v<ac2v || ac2v<ac3v) && acv<0 && acv>ac1v) || (acv>ac1v && ac1v<ac2v && acv>0)) || 
      (((ac1v>ac2v || ac2v>ac3v) && acv>0 && acv<ac1v) || (acv<ac1v && ac1v>ac2v && acv<0)))
     {
      u1acv=0; d1acv=0;
     }

   double  ac03v = iACGet(handle_iAC_TF3, 1);
   double  ac13v = iACGet(handle_iAC_TF3, 2);
   double  ac23v = iACGet(handle_iAC_TF3, 3);
   double  ac33v = iACGet(handle_iAC_TF3, 4);

   if((ac13v>ac23v && ac23v>ac33v && ac03v<0 && ac03v>ac13v) || (ac03v>ac13v && ac13v>ac23v && ac03v>0))
     {
      u3acv=3; d3acv=0;
     }
   if((ac13v<ac23v && ac23v<ac33v && ac03v>0 && ac03v<ac13v) || (ac03v<ac13v && ac13v<ac23v && ac03v<0))
     {
      u3acv=0; d3acv=3;
     }
   if((((ac13v<ac23v || ac23v<ac33v) && ac03v<0 && ac03v>ac13v) || (ac03v>ac13v && ac13v<ac23v && ac03v>0)) || 
      (((ac13v>ac23v || ac23v>ac33v) && ac03v>0 && ac03v<ac13v) || (ac03v<ac13v && ac13v>ac23v && ac03v<0)))
     {
      u3acv=0; d3acv=0;
     }

   double uitog1v = (u1x5v + u1x8v + u1x13v + u1x21v + u1x34v + u1acv) * 12.5;
   double uitog2v = (u2x5v + u2x8v + u2x13v + u2x21v + u2x34v + u2acv) * 12.5;
   double uitog3v = (u3x5v + u3x8v + u3x13v + u3x21v + u3x34v + u3acv) * 12.5;

   double ditog1v = (d1x5v + d1x8v + d1x13v + d1x21v + d1x34v + d1acv) * 12.5;
   double ditog2v = (d2x5v + d2x8v + d2x13v + d2x21v + d2x34v + d2acv) * 12.5;
   double ditog3v = (d3x5v + d3x8v + d3x13v + d3x21v + d3x34v + d3acv) * 12.5;

   Signal=0; Comment("Не рекомендуется открывать позиции. ЖДИТЕ.");
   if(uitog1v>50 && uitog2v>50 && uitog3v>50)
     {
      Signal=1; Comment("Неплохой момент для открытия позиции BUY");
     }
   if(ditog1v>50 && ditog2v>50 && ditog3v>50)
     {
      Signal=-1;Comment("Неплохой момент для открытия позиции SELL");
     }
   if(uitog1v>=75 && uitog2v>=75 && uitog3v>=75)
     {
      Signal=2; Comment("УДАЧНЫЙ момент для открытия позиции BUY");
     }
   if(ditog1v>=75 && ditog2v>=75 && ditog3v>=75)
     {
      Signal=-2;Comment("УДАЧНЫЙ момент для открытия позиции SELL");
     };
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
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateiMA(const ENUM_TIMEFRAMES time_frame,const int ma_period,int &handle_iMA)
  {
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),time_frame,ma_period,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(time_frame),
                  GetLastError());
      //--- the indicator is stopped early 
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateiAC(const ENUM_TIMEFRAMES time_frame,int &handle_iAC)
  {
//--- create handle of the indicator iAC
   handle_iAC=iAC(m_symbol.Name(),time_frame);
//--- if the handle is not created 
   if(handle_iAC==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAC indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(time_frame),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
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
//| Get value of buffers for the iAC                                |
//+------------------------------------------------------------------+
double iACGet(const int handle,const int index)
  {
   double AC[];
   ArraySetAsSeries(AC,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iACBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,0,index+1,AC)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iAC indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(AC[index]);
  }
//+------------------------------------------------------------------+
