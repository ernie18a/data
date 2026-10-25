//+------------------------------------------------------------------+
//|                                            RSI Cross Signals.mq4 |
//|                                      Idea and coded by Dean Feng |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property version       "6.00"
#property copyright     "Idea and coded by Dean Feng. 5/20/2008"
#property link          "ayhomer@outlook.com"
#property description   "Features of this indicator："
#property description   "1：Display 3 RSI lines and two MAs"
#property description   "2：Crosses of the two MAs can be used as the signals. "
#property description   "3：Display histogram for MA1 or the RSI1"
#property description   "4：Colored level lines; 2 colors MA lines; Color filling between Overbought1 and Oversold1 levels."
#property description   "About RSI value："
#property description   "RSI value of this indicator = original RSI value - 50"
#property description   "This is to make RSI changes around 0 (not 50), which is convenient to draw histograms."
#property strict

#property indicator_separate_window
#property indicator_buffers 18

#define SignalName "RSISignal"

//---- hackground upper
#property indicator_color1 C'32,53,53'
#property indicator_width1 20
//---- hackground lower
#property indicator_color2 C'32,53,53'
#property indicator_width2 20
//---- histogram upper-up
#property indicator_color3 clrGreen
#property indicator_width3 4
//---- histogram upper-down
#property indicator_color4 clrDarkGreen
#property indicator_width4 4
//---- histogram lower-down
#property indicator_color5 clrMaroon
#property indicator_width5 4
//---- histogram lower-up
#property indicator_color6 clrFireBrick
#property indicator_width6 4
//---- Overbought1
#property indicator_color7 clrDarkSlateGray
#property indicator_width7 2
#property indicator_style7 STYLE_SOLID
//---- Oversold1
#property indicator_color8 clrDarkSlateGray
#property indicator_width8 2
#property indicator_style8 STYLE_SOLID
//---- Overbought2
#property indicator_color9 clrDarkSlateGray
#property indicator_width9 1
#property indicator_style9 STYLE_DOT
//---- Oversold2
#property indicator_color10 clrDarkSlateGray
#property indicator_width10 1
#property indicator_style10 STYLE_DOT
//---- middle level
#property indicator_color11 clrNONE
#property indicator_width11 1
#property indicator_style11 STYLE_SOLID
//---- RSI line 1
#property indicator_color12 clrAqua
#property indicator_width12 2
#property indicator_style12 STYLE_SOLID
//---- RSI line 2
#property indicator_color13 clrAqua
#property indicator_width13 2
#property indicator_style13 STYLE_SOLID
//---- RSI line 3
#property indicator_color14 clrAqua
#property indicator_width14 2
#property indicator_style14 STYLE_SOLID
//---- MA line 1 up
#property indicator_color15 clrYellow
#property indicator_width15 2
#property indicator_style15 STYLE_SOLID
//---- MA line 1 down
#property indicator_color16 clrYellow
#property indicator_width16 2
#property indicator_style16 STYLE_SOLID
//---- MA line 2 up
#property indicator_color17 clrYellow
#property indicator_width17 2
#property indicator_style17 STYLE_SOLID
//---- MA line 2 down
#property indicator_color18 clrYellow
#property indicator_width18 2
#property indicator_style18 STYLE_SOLID
//+------------------------------------------------------------------+
//| User defined type: determine how to draw histograms              |
//+------------------------------------------------------------------+
enum ENUM_HISTOGRAM_TYPE
  {
   HIST_RSI1            =0,
   HIST_MA1             =1,
   HIST_NONE            =2
  };
//+------------------------------------------------------------------+
//| User defined type: determine how histogram colors change         |
//+------------------------------------------------------------------+
enum ENUM_COLOR_TYPE
  {
   COLOR_MA1_DIRECTION    =0,   // MA1 Direction
   COLOR_RSI1_CROSS_MA1   =1    // RSI1 Crosses MA1
  };
//+------------------------------------------------------------------+
//| User defined type: determine how signals are generated           |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_TYPE
  {
   SIGNAL_MA1_DIRECTION_CHANGES  =0,   // MA1 Direction Changes
   SIGNAL_MA1_CROSS_MA2          =1,   // MA1 Crosses MA2
   SIGNAL_RSI2_CROSS_RSI1        =2    // RSI2 Crosses RSI1
  };
//+------------------------------------------------------------------+
//| User defined type: to control distance between arrow and price   |
//+------------------------------------------------------------------+
enum ENUM_ARROW_GAP
  {
   Small    =1,
   Medium   =2,
   Large    =3,
  };
//+------------------------------------------------------------------+
//| User defined type: to control distance between arrow and price   |
//+------------------------------------------------------------------+
enum ENUM_MA_TYPE
  {
   MA_MA1    =1,  // MA of MA1
   MA_RSI1   =2   // MA of RSI1
  };
//--- input parameters
extern string              Separator1="======= RSI Params =======";
extern int                 RSI1=13;                            // RSI1 Period
extern int                 RSI2=3;                             // RSI2 Period
extern int                 RSI3=0;                             // RSI3 Period
extern ENUM_APPLIED_PRICE  RSI_Price=PRICE_CLOSE;              // RSI Price
extern int                 Overbought1=70;                     // Overbought 1
extern int                 Oversold1=30;                       // Oversold 1
extern int                 Overbought2=70;                     // Overbought 2
extern int                 Oversold2=30;                       // Oversold 2
extern string              Separator2="======= MA Params =======";
extern int                 MA1Period=10;                       // MA1 Period
extern ENUM_MA_METHOD      MA1Method=MODE_SMA;                 // MA1 Method
extern int                 MA2Period=5;                        // MA2 Period
extern ENUM_MA_METHOD      MA2Method=MODE_SMA;                 // MA2 Method
extern ENUM_MA_TYPE        MA2Type=MA_MA1;                     // MA2 Type
extern string              Separator3="====== Enable/Disable ======";
extern bool                RSILine1=true;                      // RSI1 Line
extern bool                RSILine2=false;                     // RSI2 Line
extern bool                RSILine3=false;                     // RSI3 Line
extern bool                MALine1=false;                      // MA1 Line
extern bool                MALine2=true;                       // MA2 Line
extern bool                RSILevel1=true;                     // RSI Level 1
extern bool                RSILevel2=false;                    // RSI Level 2
extern bool                ZeroLine=false;                     // Zero Line
extern string              Separator4="======= Histogram =======";
extern ENUM_HISTOGRAM_TYPE HistType=HIST_MA1;                  // Histogram Type
extern ENUM_COLOR_TYPE     HistColorType=COLOR_MA1_DIRECTION;  // Histogram Color Type
extern string              Separator5="======= Background =======";
extern bool                Background=true;                    // Enable Background
extern bool                BackgroundFull=false;               // Full Background
extern string              Separator6="======== Signals ========";
extern ENUM_SIGNAL_TYPE    SignalType=SIGNAL_MA1_CROSS_MA2;    //Signal Types
extern bool                ScreenAlert=false;                  //Screen Alert
extern bool                EmailAlert=false;                   //Email Alert
extern bool                MobileAlert=false;                  //Mobile Alert
extern bool                AlertOnCurrentBar=false;            //Alert For Unfinished Bar
extern string              Separator7="======== Arrows ========";
extern bool                ShowArrows=false;                   //Enable Arrows
extern bool                VisibleBarArrow=true;               //Arrows For Visible Bars Only
extern int                 ArrowWidth=1;                       //Arrow Width
extern ENUM_ARROW_GAP      ArrowGap=Small;                     //Gap Between Arrow and Bar

//---- indicator buffers
double            BGUpperBuffer[];
double            BGLowerBuffer[];
double            HistUpperUpBuffer[];
double            HistUpperDownBuffer[];
double            HistLowerDownBuffer[];
double            HistLowerUpBuffer[];
double            OB1Buffer[];
double            OS1Buffer[];
double            OB2Buffer[];
double            OS2Buffer[];
double            ZeroLineBuffer[];
double            RSI1Buffer[];
double            RSI2Buffer[];
double            RSI3Buffer[];
double            MA1UpBuffer[];
double            MA1DownBuffer[];
double            MA2UpBuffer[];
double            MA2DownBuffer[];
//---- Global variables
double            Signal[];      //record buy and sell signals for sending alerts   
static datetime   LastAlertTime; //record the time of last alert
int               AlertShift;    //0: alert for current unfinished bar; 1: alert for finished bar
const long        Chart_ID=ChartID();
string            ShortName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers
   IndicatorBuffers(19);
//--- check whether need to send alert on unfinished bar
   if(AlertOnCurrentBar) AlertShift=0; // send alerts on current unfinished bar
   else AlertShift=1;   // send alerts only after the bar is finished (last bar)
//---- Check validation of input parameters
   if(RSI1<1 || RSI1>100 || RSI2<1 || RSI2>100 || RSI3<1 || RSI3>100)
     {
      Print("Error: RSI period is out of range!");
      RSI1=13;
      RSI2=3;
      RSI3=21;
     }
   if(Overbought1>100 || Oversold1<0 || Overbought2>100 || Oversold2<0)
     {
      Print("Invalid overbought or oversold value!");
      Overbought1=70;
      Oversold1=30;
      Overbought2=80;
      Oversold2=20;
     }
   if(AlertShift<0 || AlertShift>1)
     {
      Print("AlertShift must be 0 or 1.");
      AlertShift=0;
     }
//--- indicator digits
   IndicatorDigits(1);
//--- Set indicator name, show RSI period, MA period and MA method.
   ShortName="RSISignal ("+IntegerToString(RSI1);
   if(RSILine2) ShortName+=","+IntegerToString(RSI2);
   if(RSILine3) ShortName+=","+IntegerToString(RSI3);
   if(MALine1 || HistType) ShortName+=","+GetMAInfo(MA1Period,MA1Method);
   if(MALine2) ShortName+=","+GetMAInfo(MA2Period,MA2Method);
   ShortName+=")";
   IndicatorShortName(ShortName);
//--- buffer mapping and drawing setting
   int n=0;
   SetIndexBuffer(n,BGUpperBuffer);
   if(Background) SetIndexStyle(n,DRAW_HISTOGRAM);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   SetIndexDrawBegin(n,0);
   n++;

   SetIndexBuffer(n,BGLowerBuffer);
   if(Background) SetIndexStyle(n,DRAW_HISTOGRAM);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   SetIndexDrawBegin(n,0);
   n++;

   SetIndexBuffer(n,HistUpperUpBuffer);
   if(HistType!=HIST_NONE) SetIndexStyle(n,DRAW_HISTOGRAM);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   SetIndexDrawBegin(n,RSI1+MA1Period);
   n++;

   SetIndexBuffer(n,HistUpperDownBuffer);
   if(HistType!=HIST_NONE) SetIndexStyle(n,DRAW_HISTOGRAM);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   SetIndexDrawBegin(n,RSI1+MA1Period);
   n++;

   SetIndexBuffer(n,HistLowerDownBuffer);
   if(HistType!=HIST_NONE) SetIndexStyle(n,DRAW_HISTOGRAM);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   SetIndexDrawBegin(n,RSI1+MA1Period);
   n++;

   SetIndexBuffer(n,HistLowerUpBuffer);
   if(HistType!=HIST_NONE) SetIndexStyle(n,DRAW_HISTOGRAM);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   SetIndexDrawBegin(n,RSI1+MA1Period);
   n++;

   SetIndexBuffer(n,OB1Buffer);
   if(RSILevel1) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   SetIndexDrawBegin(n,0);
   n++;

   SetIndexBuffer(n,OS1Buffer);
   if(RSILevel1) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexDrawBegin(n,0);
   n++;

   SetIndexBuffer(n,OB2Buffer);
   if(RSILevel2) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexDrawBegin(n,0);
   n++;

   SetIndexBuffer(n,OS2Buffer);
   if(RSILevel2) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexDrawBegin(n,0);
   n++;

   SetIndexBuffer(n,ZeroLineBuffer);
   if(ZeroLine) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   SetIndexDrawBegin(n,0);
   n++;

   SetIndexBuffer(n,RSI1Buffer);
   if(RSILine1) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,"RSI"+IntegerToString(RSI1));
   SetIndexDrawBegin(n,RSI1);
   n++;

   SetIndexBuffer(n,RSI2Buffer);
   if(RSILine2) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,"RSI"+IntegerToString(RSI2));
   SetIndexDrawBegin(n,RSI2);
   n++;

   SetIndexBuffer(n,RSI3Buffer);
   if(RSILine3) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,"RSI"+IntegerToString(RSI3));
   SetIndexDrawBegin(n,RSI3);
   n++;

   SetIndexBuffer(n,MA1UpBuffer);
   if(MALine1) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,GetMAInfo(MA1Period,MA1Method));
   SetIndexDrawBegin(n,RSI1+MA1Period);
   n++;

   SetIndexBuffer(n,MA1DownBuffer);
   if(MALine1) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   SetIndexDrawBegin(n,RSI1+MA1Period);
   n++;

   SetIndexBuffer(n,MA2UpBuffer);
   if(MALine2) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,GetMAInfo(MA2Period,MA2Method));
   SetIndexDrawBegin(n,RSI1+MA1Period+MA2Period);
   n++;

   SetIndexBuffer(n,MA2DownBuffer);
   if(MALine2) SetIndexStyle(n,DRAW_LINE);
   else SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   SetIndexDrawBegin(n,RSI1+MA1Period+MA2Period);
   n++;

   SetIndexBuffer(n,Signal);
   SetIndexStyle(n,DRAW_NONE);
   SetIndexLabel(n,NULL);
   n++;

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,SignalName);
   Print(__FUNCTION__,"_Uninitalization reason code = ",reason);
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
//--- check rates_total
   if(rates_total<1) return(-1);
//--- prepare loop index
   int                     i;
   int                     limit1=rates_total;
   int                     limit2=rates_total-1;
   if(prev_calculated>0)   limit1=limit2=rates_total-IndicatorCounted();
//--- calculate overbought, oversold, RSI1, RSI2, RSI3
   for(i=limit1-1; i>=0 && !IsStopped(); i--)
     {
      //---- overbought and oversold levels
      OB1Buffer[i]=Overbought1-50.0;
      OS1Buffer[i]=Oversold1-50.0;
      OB2Buffer[i]=Overbought2-50.0;
      OS2Buffer[i]=Oversold2-50.0;
      //--- zero line
      ZeroLineBuffer[i]=0.0;
      //---- RSI 1, RSI 2, RSI 3
      RSI1Buffer[i]=iRSI(NULL,0,RSI1,RSI_Price,i)-50.0;
      RSI2Buffer[i]=iRSI(NULL,0,RSI2,RSI_Price,i)-50.0;
      RSI3Buffer[i]=iRSI(NULL,0,RSI3,RSI_Price,i)-50.0;
     }
//--- MA1
   for(i=limit1-1; i>=0 && !IsStopped(); i--)
     {
      MA1UpBuffer[i]=iMAOnArray(RSI1Buffer,0,MA1Period,0,MA1Method,i);
      MA1DownBuffer[i]=EMPTY_VALUE;
     }
   for(i=0; i<limit2 && !IsStopped(); i++)
      if(MA1UpBuffer[i]<MA1UpBuffer[i+1]) MA1DownBuffer[i]=MA1UpBuffer[i];
//--- MA2
   if(MA2Type==MA_RSI1)
     {
      for(i=limit1-1; i>=0 && !IsStopped(); i--)
        {
         MA2UpBuffer[i]=iMAOnArray(RSI1Buffer,0,MA2Period,0,MA2Method,i);
         MA2DownBuffer[i]=EMPTY_VALUE;
        }
      for(i=0; i<limit2 && !IsStopped(); i++)
         if(MA2UpBuffer[i]<MA2UpBuffer[i+1]) MA2DownBuffer[i]=MA2UpBuffer[i];
     }
   else if(MA2Type==MA_MA1)
     {
      for(i=limit1-1; i>=0 && !IsStopped(); i--)
        {
         MA2UpBuffer[i]=iMAOnArray(MA1UpBuffer,0,MA2Period,0,MA2Method,i);
         MA2DownBuffer[i]=EMPTY_VALUE;
        }
      for(i=0; i<limit2 && !IsStopped(); i++)
         if(MA2UpBuffer[i]<MA2UpBuffer[i+1]) MA2DownBuffer[i]=MA2UpBuffer[i];
     }
//--- Calculate histograms between RSI-1 or MA-1 to middle level (0)
   if(HistType!=HIST_NONE)
     {
      //--- Histogram type 1: draw histogram for diff between RSI-1 and Smoothed RSI (MA-1)
      if(HistType==HIST_RSI1)
        {
         for(i=0; i<limit2 && !IsStopped(); i++)
           {
            HistUpperUpBuffer[i]    =EMPTY_VALUE;
            HistUpperDownBuffer[i]  =EMPTY_VALUE;
            HistLowerDownBuffer[i]  =EMPTY_VALUE;
            HistLowerUpBuffer[i]    =EMPTY_VALUE;
            if(RSI1Buffer[i]>0.0)
              {
               if(RSI1Buffer[i]>RSI1Buffer[i+1]) HistUpperUpBuffer[i]=RSI1Buffer[i];
               else HistUpperDownBuffer[i]=RSI1Buffer[i];
              }
            else
              {
               if(RSI1Buffer[i]>RSI1Buffer[i+1]) HistLowerUpBuffer[i]=RSI1Buffer[i];
               else HistLowerDownBuffer[i]=RSI1Buffer[i];
              }
           }
        }
      //--- Histogram type 2: draw histogram for RSI-1
      else if(HistType==HIST_MA1)
        {
         for(i=0; i<limit2 && !IsStopped(); i++)
           {
            HistUpperUpBuffer[i]    =EMPTY_VALUE;
            HistUpperDownBuffer[i]  =EMPTY_VALUE;
            HistLowerDownBuffer[i]  =EMPTY_VALUE;
            HistLowerUpBuffer[i]    =EMPTY_VALUE;
            if(HistColorType==COLOR_RSI1_CROSS_MA1)
              {
               if(MA1UpBuffer[i]>0.0)
                 {

                  if(RSI1Buffer[i]>MA1UpBuffer[i]) HistUpperUpBuffer[i]=MA1UpBuffer[i];
                  else HistUpperDownBuffer[i]=MA1UpBuffer[i];
                 }
               else
                 {
                  if(RSI1Buffer[i]<MA1UpBuffer[i]) HistLowerDownBuffer[i]=MA1UpBuffer[i];
                  else HistLowerUpBuffer[i]=MA1UpBuffer[i];
                 }
              }
            //--- Option 2：Histogram color changes according to direction of smoothed RSI-1 (MA-1)
            else if(HistColorType==COLOR_MA1_DIRECTION)
              {
               if(MA1UpBuffer[i]>0.0)
                 {
                  if(MA1UpBuffer[i]>MA1UpBuffer[i+1]) HistUpperUpBuffer[i]=MA1UpBuffer[i];
                  else HistUpperDownBuffer[i]=MA1UpBuffer[i];
                 }
               else
                 {
                  if(MA1UpBuffer[i]<MA1UpBuffer[i+1]) HistLowerDownBuffer[i]=MA1UpBuffer[i];
                  else HistLowerUpBuffer[i]=MA1UpBuffer[i];
                 }
              }
           }
        }
     }

//--- background histograms
   if(Background)
     {
      for(i=limit1-1; i>=0 && !IsStopped(); i--)
        {
         if(BackgroundFull)
           {
            BGUpperBuffer[i]=50.0;
            BGLowerBuffer[i]=-50.0;
           }
         else
           {
            BGUpperBuffer[i]=MathMax(Overbought1,Overbought2)-50.0;
            BGLowerBuffer[i]=MathMin(Oversold1,Oversold2)-50.0;
           }
        }
     }
//--- draw arrows
   if(ShowArrows)
     {
      //--- previous parameter setting for calculating signals
      int                     startShift  =1;                           // signal calculate from last bar
      if(AlertOnCurrentBar)   startShift  =0;                           // signal calculate from current unfinished bar
      int                     barNum      =rates_total-2;               // signal calculate for all bars
      if(VisibleBarArrow)     barNum      =WindowBarsPerChart()-2;      // signal calculate only for visible bars
      if(prev_calculated>1)                                             // after first time calculating
        {
         if(AlertOnCurrentBar) barNum=rates_total-IndicatorCounted();   // after first calculating, loop from 0 to 0
         else                  barNum=rates_total-IndicatorCounted()+1; // after first calculating, loop from 1 to 1
        }

      //--- Signal Type #1: generate signals when direction of smoothed RSI1 (MA1) changes
      if(SignalType==SIGNAL_MA1_DIRECTION_CHANGES)
        {
         for(i=startShift; i<barNum && !IsStopped(); i++)
           {
            Signal[i]=EMPTY_VALUE;
            double ma0=MA1UpBuffer[i];
            double ma1=MA1UpBuffer[i+1];
            double ma2=MA1UpBuffer[i+2];
            if(ma0>ma1 && ma1<ma2) //up tend
              {
               if(ObjectFind(Chart_ID,StringConcatenate(SignalName,Time[i]))>=0) DeleteArrow(Time[i]);
               CreateArrow(Time[i],CalculateArrowPrice(i,ANCHOR_TOP),ANCHOR_TOP,241,clrDodgerBlue);
               Signal[i]=OP_BUY;
              }
            else if(ma0<ma1 && ma1>ma2) //down trend
              {
               if(ObjectFind(Chart_ID,StringConcatenate(SignalName,Time[i]))>=0) DeleteArrow(Time[i]);
               CreateArrow(Time[i],CalculateArrowPrice(i,ANCHOR_BOTTOM),ANCHOR_BOTTOM,242,clrRed);
               Signal[i]=OP_SELL;
              }
            else  // if signal appears on a bar before but now disappears, this else statement will
              {   // delete the arrow drawn before and signal stored in Signal[] buffer
               if(ObjectFind(Chart_ID,StringConcatenate(SignalName,Time[i]))>=0) DeleteArrow(Time[i]);
               Signal[i]=EMPTY_VALUE;
              }
           } // end for
        } // end if
      //--- Signal Type #2: generate signals when smoothed RSI1 (MA1) crosses its MA (MA2)
      else if(SignalType==SIGNAL_MA1_CROSS_MA2)
        {
         for(i=startShift; i<barNum && !IsStopped(); i++)
           {
            double curDif   =MA1UpBuffer[i]-MA2UpBuffer[i];
            double preDif   =MA1UpBuffer[i+1]-MA2UpBuffer[i+1];
            if(curDif>0.0 && preDif<0.0) // up cross
              {
               if(ObjectFind(Chart_ID,StringConcatenate(SignalName,Time[i]))>=0) DeleteArrow(Time[i]);
               CreateArrow(Time[i],CalculateArrowPrice(i,ANCHOR_TOP),ANCHOR_TOP,241,clrDodgerBlue);
               Signal[i]=OP_BUY;
              }
            else if(curDif<0.0 && preDif>0.0) // down cross
              {
               if(ObjectFind(Chart_ID,StringConcatenate(SignalName,Time[i]))>=0) DeleteArrow(Time[i]);
               CreateArrow(Time[i],CalculateArrowPrice(i,ANCHOR_BOTTOM),ANCHOR_BOTTOM,242,clrRed);
               Signal[i]=OP_SELL;
              }
            else  // if signal appears on a bar before but now disappears, this else statement will
              {   // delete the arrow drawn before and signal stored in Signal[] buffer
               if(ObjectFind(Chart_ID,StringConcatenate(SignalName,Time[i]))>=0) DeleteArrow(Time[i]);
               Signal[i]=EMPTY_VALUE;
              }
           } // end for
        } // end else if

      //--- Signal Type #3: generate signals when fast RSI (RSI2) crosses slow RSI (RSI1)
      else if(SignalType==SIGNAL_RSI2_CROSS_RSI1)
        {
         for(i=startShift; i<barNum && !IsStopped(); i++)
           {
            double preRSI1=RSI1Buffer[i+1];
            double curRSI1=RSI1Buffer[i];
            double preRSI2=RSI2Buffer[i+1];
            double curRSI2=RSI2Buffer[i];
            if(preRSI2<preRSI1 && curRSI2>curRSI1) // up cross
              {
               if(ObjectFind(Chart_ID,StringConcatenate(SignalName,Time[i]))>=0) DeleteArrow(Time[i]);
               CreateArrow(Time[i],CalculateArrowPrice(i,ANCHOR_TOP),ANCHOR_TOP,241,clrDodgerBlue);
               Signal[i]=OP_BUY;
              }
            else if(preRSI2>preRSI1 && curRSI2<curRSI1) // down cross
              {
               if(ObjectFind(Chart_ID,StringConcatenate(SignalName,Time[i]))>=0) DeleteArrow(Time[i]);
               CreateArrow(Time[i],CalculateArrowPrice(i,ANCHOR_BOTTOM),ANCHOR_BOTTOM,242,clrRed);
               Signal[i]=OP_SELL;
              }
            else  // if signal appears on a bar before but now disappears, this else statement will
              {   // delete the arrow drawn before and signal stored in Signal[] buffer
               if(ObjectFind(Chart_ID,StringConcatenate(SignalName,Time[i]))>=0) DeleteArrow(Time[i]);
               Signal[i]=EMPTY_VALUE;
              }
           } // end for
        } // end else if
     }
//--- send alerts
   if(prev_calculated>1) // send alerts only after indicator has been loaded one time
     {
      int shift=AlertShift; // send alerts for which bar (current unfinished bar or last bar)
      if(Signal[shift]==OP_BUY || Signal[shift]==OP_SELL)
        {
         string signalType,message,subject;
         if(Signal[shift]==OP_BUY) signalType="BUY";
         else signalType="SELL";
         //--- create message content
         message+="RSISignal Alert: "+"\n";
         message+=Symbol()+" "+GetChartPeriod()+" "+signalType+" ";
         message+=TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);
         //--- create subject contect
         subject+="RSISignal Alert: ";
         subject+=Symbol()+" "+GetChartPeriod()+" "+signalType+" ";
         subject+=TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);
         //--- send alerts
         SendAlert(message,subject);
        }
     }
//--- return value of prev _calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Return MA information as string                                  |
//+------------------------------------------------------------------+
string GetMAInfo(int maPeriod,ENUM_MA_METHOD maMethod)
  {
   string maInfo;
   switch(maMethod)
     {
      case MODE_SMA:    maInfo = "SMA";   break;
      case MODE_EMA:    maInfo = "EMA";   break;
      case MODE_SMMA:   maInfo = "SMMA";  break;
      case MODE_LWMA:   maInfo = "LWMA";  break;
     }
   maInfo+=IntegerToString(maPeriod);
   return (maInfo);
  }
//+------------------------------------------------------------------+
//| Arrow create function                                            |
//+------------------------------------------------------------------+
bool CreateArrow(datetime           time,          // anchor point time
                 double             price,         // anchor point price
                 ENUM_ARROW_ANCHOR  arrowAnchor,   // anchor point position
                 int                arrowCode,     // arrow code
                 color              arrowColor)    // arrow color
  {
//--- set anchor point coordinates if they are not set 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- get a name for the arrow
   string objName=StringConcatenate(SignalName,time);
//--- create an arrow 
   if(!ObjectCreate(Chart_ID,objName,OBJ_ARROW,0,time,price))
     {
      Print(__FUNCTION__,": Arrow create failed! Errow Code:",GetLastError());
      return(false);
     }
//--- set arrow properties
   ObjectSetInteger(Chart_ID,objName,OBJPROP_ARROWCODE,arrowCode);
   ObjectSetInteger(Chart_ID,objName,OBJPROP_ANCHOR,arrowAnchor);
   ObjectSetInteger(Chart_ID,objName,OBJPROP_COLOR,arrowColor);
   ObjectSetInteger(Chart_ID,objName,OBJPROP_WIDTH,ArrowWidth);
   ObjectSetInteger(Chart_ID,objName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(Chart_ID,objName,OBJPROP_BACK,false);
   ObjectSetInteger(Chart_ID,objName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(Chart_ID,objName,OBJPROP_SELECTED,false);
   ObjectSetInteger(Chart_ID,objName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(Chart_ID,objName,OBJPROP_ZORDER,0);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete an arrow                                                  |
//+------------------------------------------------------------------+
bool DeleteArrow(datetime time)
  {
   string objName=StringConcatenate(SignalName,time);
   if(!ObjectDelete(Chart_ID,objName))
     {
      Print(__FUNCTION__,
            "Delete arrow failed! Error Code=",GetLastError());
      return (false);
     }
   return (true);
  }
//+------------------------------------------------------------------+
//| Calculate arrow anchor point price                               |
//+------------------------------------------------------------------+
double CalculateArrowPrice(int shift,ENUM_ARROW_ANCHOR anchor)
  {
//--- check for shift value
   if(shift>=Bars)
     {
      Print(__FUNCTION__,
            ": Parameter shift is out of range! Error Code=",GetLastError());
      return -1;
     }
//---
   double price=0.0;
//--- calculate distance between arrow and price
   int gap=1;
   switch(ArrowGap)
     {
      case Small:    gap=4; break;
      case Medium:   gap=2; break;
      case Large:    gap=1; break;
     }
   double distance=iATR(Symbol(),0,55,shift)/gap;
//--- check arrow anchor point to calculate price with distance
   if(anchor==ANCHOR_TOP) price=Low[shift]-distance;
   else if(anchor==ANCHOR_BOTTOM) price=High[shift]+distance;
//---
   return price;
  }
//+------------------------------------------------------------------+
//| Send alerts                                                      |
//+------------------------------------------------------------------+
void SendAlert(string alertMessage,string alertSubject)
  {
   if(MobileAlert || ScreenAlert || EmailAlert)
     {
      if(alertMessage!="")
        {
         if(LastAlertTime<iTime(Symbol(),Period(),0))
           {
            if(ScreenAlert) Alert(alertSubject);  //screen alert
            if(MobileAlert) //mobile alert
              {
               if(!SendNotification(alertSubject))
                  Print("Mobile alert failed!, Error code: ",GetLastError());
               else
                  Print("Mobile alert successful!");
              }
            if(EmailAlert) //email alert
              {
               if(!SendMail(alertSubject,alertMessage))
                  Print("Email alert failed! Error code: ",GetLastError());
               else
                  Print("Email alert send successful!");
              }
           }
         LastAlertTime=iTime(Symbol(),Period(),0); //update the time of last alert
        }
     }
  }
//+------------------------------------------------------------------+
string GetChartPeriod()
  {
   string   per="";
   int      chartPeriod=Period();
   switch(chartPeriod)
     {
      case 1:     per="M1";   break;
      case 5:     per="M5";   break;
      case 15:    per="M15";  break;
      case 30:    per="M30";  break;
      case 60:    per="H1";   break;
      case 240:   per="H4";   break;
      case 1440:  per="D1";   break;
      case 10080: per="W1";   break;
      case 43200: per="MN";   break;
     }
   return (per);
  }
//+------------------------------------------------------------------+
