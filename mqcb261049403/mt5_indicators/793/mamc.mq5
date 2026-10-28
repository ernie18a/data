//+------------------------------------------------------------------+
//|                                                         MAMC.mq5 |
//|                                              Copyright 2011, kur |
//|                               https://www.mql5.com/en/users/kurl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, kur."//2011.12.29 14:44
#property link      "https://forge.mql5.io"//(567)
#property description "MA Mass Cloud\n"
#property description "Clouds formed by the masses of moving averages of different periods"
#property description "Changes color when perfect order is"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1 DRAW_FILLING
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_color1 clrLavender
#property indicator_color2 clrLavender
#property indicator_color3 clrLavender
#property indicator_label1 "ma_cloud"
#property indicator_label2 "aim_u"
#property indicator_label3 "aim_l"
double Upper[],Lower[],Aim_u[],Aim_l[];      // buffers
input ENUM_MA_METHOD METHOD=MODE_EMA;        // MA Method
input ENUM_APPLIED_PRICE APPLIED=PRICE_OPEN; // MA Applied Price
input int Weight=64;                         // MA Period STEP
input int Depth=10;                          // Number of MA
input color Default=clrLavender;
input color Bullish=clrPaleTurquoise;
input color Bearish=clrPink;
#include <Indicators\Indicator.mqh>
CIndicatorBuffer iat;
int H;   // MA handle
int L,R; // End position of the bar  //hasi no ba- no iti
bool I;  // The first access or new bar
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Weight<1 || Depth<1)return(-1);
//---
   string app=EnumToString(APPLIED);
   app=StringSubstr(app,6,1);
   StringToLower(app);
   string met=EnumToString(METHOD);
   met=StringSubstr(met,5,StringLen(met)-5);
   PlotIndexSetString(0,PLOT_LABEL,(string)Weight+","+(string)Depth+","+app+","+met);
//---
   SetIndexBuffer(0,Upper,INDICATOR_DATA);
   ArraySetAsSeries(Upper,true);
   SetIndexBuffer(1,Lower,INDICATOR_DATA);
   ArraySetAsSeries(Lower,true);
   SetIndexBuffer(2,Aim_u,INDICATOR_DATA);
   ArraySetAsSeries(Aim_u,true);
   SetIndexBuffer(3,Aim_l,INDICATOR_DATA);
   ArraySetAsSeries(Aim_l,true);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   I=true;L=R=0;H=INVALID_HANDLE;
//---
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int r)
  {
   if(H!=INVALID_HANDLE)
     {
      if(!IndicatorRelease(H))Print(GetLastError());
      else H=INVALID_HANDLE;
     }
  }
//+------------------------------------------------------------------+
//| OnChartEvent                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,const string &sparam)
  {
   Run();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int zen,
                const int zumi,
                const int begin,const double &price[])
  {
   if(zen<zumi || zen>zumi)I=true;//new bar
   Run();
//---
   return(zen);
  }
//+------------------------------------------------------------------+
//| Run                                                              |
//+------------------------------------------------------------------+
void Run()
  {
   int l=0,r=0;l=Bar(r);
   if(!I && L==l && R==r){return;}
//--- when you scroll through the chart, such as
   else
     {
      L=l;
      R=r;
     }
   for(int bar=l;bar>=r;bar--)
     {
      Upper[bar]=EMPTY_VALUE;
      Lower[bar]=EMPTY_VALUE;
      Aim_u[bar]=EMPTY_VALUE;
      Aim_l[bar]=EMPTY_VALUE;

      bool err=false,asc=true,des=true;
      double min=DBL_MAX,max=0.0;

      //--- loop -- get MA(n),MA(2n),MA(3n),...MA(kn) :n=Weight,k=Depth
      for(int i=0,per=Weight;i<Depth;i++,per+=Weight)
        {
         double w=Ima(per,bar);
         if(w==NULL || !MathIsValidNumber(w)){err=true;break;}
         if(w<min)min=w;else des=false;
         if(w>max)max=w;else asc=false;
        }

      //--- no error
      if(!err)
        {
         Upper[bar]=max;
         Lower[bar]=min;
         Aim_u[bar]=max+max-min;//omake
         Aim_l[bar]=min-max+min;//>>
         I=false;

         //--- only the far right
         if(bar==r)
           {
            //--- MAs in perfect order?
            if(des)
              {
               LineColor(Bullish); // yes
              }
            else if(asc)
              {
               LineColor(Bearish); // yes
              }
            else
              {
               LineColor(Default); // no
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Ima                                                              |
//+------------------------------------------------------------------+
double Ima(const int ma_period,const int pos)
  {
   H=iMA(_Symbol,_Period,ma_period,0,METHOD,APPLIED);
   if(H==INVALID_HANDLE){return(NULL);}
   return(Iat(H,0,pos));
  }
//+------------------------------------------------------------------+
//| Iat                                                              |
//+------------------------------------------------------------------+
double Iat(const int handle,const int bufnum,const int index)
  {
   iat.Size(index+1);
   double ret=iat.Refresh(handle,bufnum)?iat.At(index):NULL;
   return(ret);
  }
//+------------------------------------------------------------------+
//| Bar                                                              |
//+------------------------------------------------------------------+
int Bar(int &right)
  {
   int left=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR);
   int bars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   right=(int)fmax(left-bars,0);
   return(left);
  }
//+------------------------------------------------------------------+
//| LineColor                                                        |
//+------------------------------------------------------------------+
void LineColor(color col)
  {
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,col);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,col);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,col);
  }
//+------------------------------------------------------------------+
