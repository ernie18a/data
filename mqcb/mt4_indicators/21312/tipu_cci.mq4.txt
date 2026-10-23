//+------------------------------------------------------------------+
//|                                                     Tipu CCI.mq4 |
//|                                    Copyright 2018, Kaleem Haider |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Kaleem Haider."
#property link      "https://www.mql5.com/en/users/kaleem.haider/seller"
#property version   "1.00"
#property description "The commodity channel index (CCI) is an oscillator originally introduced by Donald Lambert in 1980."
#property description "CCI measures current price level relative to an average price level over a given period of time. "
#property description "CCI is high when prices are above the average price, and low when the prices are below the average price. It is a useful tool not only in identifying trend but also the overbought/oversold levels."

#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- plots
#property indicator_label1 "CCI-Buy"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrAqua //clrBlue //C'59,198,233'     
#property indicator_style1 STYLE_SOLID
#property indicator_width1 3

#property indicator_label2 "CCII-Sell"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 clrOrangeRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 3

#property indicator_label3 "CCI-NT"
#property indicator_type3  DRAW_HISTOGRAM
#property indicator_color3 clrSilver //clrBlue //C'59,198,233'     
#property indicator_style3 STYLE_SOLID
#property indicator_width3 3

#property indicator_levelcolor clrRed

#define PipsPoint Get_PipsPoint()
#define PipsValue Get_PipsValue()

static datetime prevTime;

//+------------------------------------------------------------------+
//| Enumerations for Inputs                                          |
//+------------------------------------------------------------------+
enum ENUM_SignalMark
  {
   None=0,
   Arrows=1,
   VLine=2,
  };

input string sCCISettings="---CCI Settings"; //CCI Settings
input int      iCCI_Period=14;                //CCI Period
input ENUM_APPLIED_PRICE eAppliedPrice=PRICE_TYPICAL; //Applied Price
input int      iCCI_OB            = 0;                //Overbought
input int      iCCI_OS            = 0;                //Oversold
input string               sSignalType="----Signal Types--"; //Signal Types
input ENUM_SignalMark      eMarkSignals=1;    //Mark Buy/Sell Signals
input int                  iAOffset=5;     //Arrow offset (pips)
input color          cUpCandle         =  C'31,159,192';  //Up Color
input color          cDwnCandle        =  C'230,77,69';   //Down Color
input string   sAlert0="---Buy/Sell Global Alert Settings----------"; //Alert Settings
input bool     bAlertBuy = true;                      //Alert Buy?
input bool     bAlertSell = true;                     //Alert Sell?
input int      iAlertShift       = 1;                 //Alert Shift
input bool     bAlertM           = false;             //Alert Mobile
input bool     bAlertS=true;             //Alert Onscreen
input bool     bAlertE=false;             //Alert Email

//--- variables for the indicators
double      OscBuffer[],OscBuffOS[],OscBuffOB[],OscBuffNT[],Trend[],Signal[],BuySignal[],SellSignal[];;
string short_name="TipuCCI";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   int n=0;

   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   IndicatorBuffers(8);

   SetIndexBuffer(n,OscBuffOS,INDICATOR_DATA); n++;
   SetIndexBuffer(n,OscBuffOB,INDICATOR_DATA); n++;
   SetIndexBuffer(n,OscBuffNT,INDICATOR_DATA); n++;

   SetIndexBuffer(n,OscBuffer,INDICATOR_DATA);
   SetIndexDrawBegin(n,iCCI_Period);
   n++;

   SetIndexBuffer(n,Signal,INDICATOR_CALCULATIONS); n++;
   SetIndexBuffer(n,Trend,INDICATOR_CALCULATIONS);  n++;
   SetIndexBuffer(n,BuySignal,INDICATOR_CALCULATIONS);   n++;
   SetIndexBuffer(n,SellSignal,INDICATOR_CALCULATIONS);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,short_name);

   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int    limit,shift;
   string sSubject,sMsg;
   datetime date[];

   ArraySetAsSeries(OscBuffer,true);
   ArraySetAsSeries(OscBuffOS,true);
   ArraySetAsSeries(OscBuffOB,true);
   ArraySetAsSeries(OscBuffNT,true);
   ArraySetAsSeries(Signal,true);
   ArraySetAsSeries(Trend,true);

   if(prev_calculated < 0)  return(0);

   if(prev_calculated>0) limit=rates_total-prev_calculated+1; //non-repainting should give -2 if prev_cal is 0, meaning two candles ahead
   else
      limit=rates_total-1;

//--- indicator plot
   for(shift=limit-1; shift>=0 && !IsStopped(); shift--)
     {
      double tempCCI0 = iCCI(_Symbol,_Period,iCCI_Period,eAppliedPrice,shift);
      double tempCCI1 = iCCI(_Symbol,_Period,iCCI_Period,eAppliedPrice,shift+1);
      OscBuffer[shift]=tempCCI0;
      if(tempCCI0>=iCCI_OB)
        {
         Trend[shift]=OP_BUY;
         Signal[shift]=(tempCCI1<iCCI_OB)?OP_BUY:EMPTY_VALUE;
        }
      if(tempCCI0<=iCCI_OS)
        {
         Trend[shift]=OP_SELL;
         Signal[shift]=(tempCCI1>iCCI_OS)?OP_SELL:EMPTY_VALUE;
        }
      if(tempCCI0>iCCI_OS && tempCCI0<iCCI_OB)
        {
         Trend[shift]=EMPTY_VALUE;
         Signal[shift]=EMPTY_VALUE;
        }
      OscBuffOS[shift] = (Trend[shift]== OP_BUY)?tempCCI0:EMPTY_VALUE;
      OscBuffOB[shift] = (Trend[shift] == OP_SELL)?tempCCI0:EMPTY_VALUE;
      OscBuffNT[shift]=(Trend[shift]==EMPTY_VALUE)?tempCCI0:EMPTY_VALUE;
      if(Signal[shift]==OP_BUY)
        {
        BuySignal[shift] = 1; SellSignal[shift]=0;
         if(eMarkSignals==1 && !(ObjectFind(0,short_name+(string)time[shift])>=0))
            ArrowCreate(0,short_name+(string)time[shift],0,time[shift],low[shift]-iAOffset*PipsPoint,233,ANCHOR_TOP,cUpCandle,0,1,true,false,false);
         if(eMarkSignals==2 && !(ObjectFind(0,short_name+(string)time[shift])>=0))
           {
            ObjectCreate(0,short_name+(string)time[shift],OBJ_VLINE,0,time[shift],close[shift]);
            ObjectSetInteger(0,short_name+(string)time[shift],OBJPROP_COLOR,cUpCandle);
            ObjectSetInteger(0,short_name+(string)time[shift],OBJPROP_BACK,true);
           }
        }
      if(Signal[shift]==OP_SELL)
        {
        BuySignal[shift] = 0; SellSignal[shift]=1;
         if(eMarkSignals==1 && !(ObjectFind(0,short_name+(string)time[shift])>=0))
            ArrowCreate(0,short_name+(string)time[shift],0,time[shift],high[shift]+iAOffset*PipsPoint,234,ANCHOR_BOTTOM,cDwnCandle,0,1,true,false,false);
         if(eMarkSignals==2 && !(ObjectFind(0,short_name+(string)time[shift])>=0))
           {
            ObjectCreate(0,short_name+(string)time[shift],OBJ_VLINE,0,time[shift],close[shift]);
            ObjectSetInteger(0,short_name+(string)time[shift],OBJPROP_COLOR,cDwnCandle);
            ObjectSetInteger(0,short_name+(string)time[shift],OBJPROP_BACK,true);
           }
        }
      //--final cut, delete false arrows
      if(Signal[shift]==EMPTY_VALUE && (ObjectFind(0,short_name+(string)time[shift])>=0))
         {
         ObjectDelete(0,short_name+(string)time[shift]);
         BuySignal[shift]=0; SellSignal[shift]=0; //reset buffers
         }
     }

//--Alert Settings 
   if(Signal[iAlertShift]==OP_BUY && bAlertBuy)
     {
      sMsg=short_name+" "+_Symbol+":"+ChartPeriodString(_Period)+" CCI Buy Signal.";
      SendAlert(bAlertM,bAlertS,bAlertE,sMsg,sMsg);
     }
   if(Signal[iAlertShift]==OP_SELL && bAlertSell)
     {
      sMsg=short_name+" "+_Symbol+":"+ChartPeriodString(_Period)+" CCI Sell Signal.";
      SendAlert(bAlertM,bAlertS,bAlertE,sMsg,sMsg);
     }

   return(rates_total);

  }
//+------------------------------------------------------------------+
//| copied from https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_arrow  |
//+------------------------------------------------------------------+
void ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ChartPeriodString(int iperiod)
  {
   switch(iperiod)
     {
      case PERIOD_M1: return("M1");
      case PERIOD_M5: return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H4: return("H4");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN1");
      default: return("M"+IntegerToString(iperiod));
     }
  }  
//+------------------------------------------------------------------+
//| Create the arrow                                                 |
//| copied from https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_arrow
//+------------------------------------------------------------------+
bool ArrowCreate(const long              chart_ID=0,           // chart's ID
                 const string            name="Arrow",         // arrow name
                 const int               sub_window=0,         // subwindow index
                 datetime                time=0,               // anchor point time
                 double                  price=0,              // anchor point price
                 const uchar             arrow_code=252,       // arrow code
                 const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor point position
                 const color             clr=clrRed,           // arrow color
                 const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
                 const int               width=3,              // arrow size
                 const bool              back=false,           // in the background
                 const bool              selection=true,       // highlight to move
                 const bool              hidden=true,          // hidden in the object list
                 const long              z_order=0)            // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create an arrow
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ",GetLastError());
      return(false);
     }
//--- set the arrow code
   ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,arrow_code);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set the arrow color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the arrow's size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the arrow by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//| function for sending alerts
//+------------------------------------------------------------------+
void SendAlert(bool bMobile,bool bScreen,bool bEmail,string sMsg,string sSub)
  {
   if(bMobile || bScreen || bEmail)
     {
      if(sMsg!="")
        {
         if(prevTime<iTime(_Symbol,_Period,0))
           {
            prevTime=iTime(_Symbol,_Period,0);
            if(bMobile) SendNotification(sSub);
            if(bScreen) Alert(sSub);
            if(bEmail) SendMail(sSub,sMsg);
           }
        }
     }
  }  
//+------------------------------------------------------------------+
//| use PipsPoint to use this function                              |
//+------------------------------------------------------------------+
double Get_PipsPoint()
  {
   double PP=(_Digits==5 || _Digits==3)?_Point*10:_Point;
   return (PP);
  }
//+------------------------------------------------------------------+
//| use PipsValue to use this function                              |
//+------------------------------------------------------------------+
double Get_PipsValue()
  {
   double PV=(MarketInfo(_Symbol,MODE_TICKVALUE)*PipsPoint)/MarketInfo(_Symbol,MODE_TICKSIZE);
   return(PV);
  }
//+------------------------------------------------------------------+  