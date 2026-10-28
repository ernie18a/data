//+------------------------------------------------------------------+
//|                                                       Stalin.mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Andrey Vassiliev (MoneyJinn)"
#property link      "http://www.vassiliev.ru/"
#property version   "2.0"

#property indicator_chart_window
#property indicator_plots   2
#property indicator_buffers 2
#property indicator_color1  LightSkyBlue
#property indicator_width1  2
#property indicator_color2  LightPink
#property indicator_width2  2

input int    MAMethod=1;
input int    MAShift=0;
input int    Fast=14;
input int    Slow=21;
input int    RSI=17;
input double Confirm=0.0;
input double Flat=0.0;
input bool   SoundAlert=false;
input bool   EmailAlert=false;

int MA1,MA2,RS;
double B1[],B2[];
double IUP,IDN,E1,E2,Confirm2,Flat2;
ENUM_MA_METHOD MAMethod2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   CLR();
   if(_Digits==3 || _Digits==5)
     {
      Confirm2=Confirm*10;
      Flat2=Flat*10;
     }
   else
     {
      Confirm2=Confirm;
      Flat2=Flat;
     }
   MAMethod2=MethodMigrate(MAMethod);
   SetIndexBuffer(0,B1,INDICATOR_DATA);
   ArraySetAsSeries(B1,true);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_ARROW);
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   SetIndexBuffer(1,B2,INDICATOR_DATA);
   ArraySetAsSeries(B2,true);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_ARROW);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   MA1=iMA(NULL,0,Fast,MAShift,MAMethod2,PRICE_CLOSE);
   MA2=iMA(NULL,0,Slow,MAShift,MAMethod2,PRICE_CLOSE);
   if(RSI>0){RS=iRSI(NULL,0,RSI,PRICE_CLOSE);}
  }
//+------------------------------------------------------------------+
//| CLR                                                              |
//+------------------------------------------------------------------+
void CLR()
  {
   if(ArraySize(B1)>0)
     {
      ArrayInitialize(B1,0);
      ArrayInitialize(B2,0);
     }
   IUP=0;
   IDN=0;
   E1=0;
   E2=0;
  }
//+------------------------------------------------------------------+
//| iMA1                                                             |
//+------------------------------------------------------------------+
double iMA1(int bar)
  {
   double IB[1];
   CopyBuffer(MA1,0,bar,1,IB);
   return(IB[0]);
  }
//+------------------------------------------------------------------+
//| iMA2                                                             |
//+------------------------------------------------------------------+
double iMA2(int bar)
  {
   double IB[1];
   CopyBuffer(MA2,0,bar,1,IB);
   return(IB[0]);
  }
//+------------------------------------------------------------------+
//| eRSI                                                             |
//+------------------------------------------------------------------+
double eRSI(int bar)
  {
   if(RSI==0){return(0);}
   double IB[1];
   CopyBuffer(RS,0,bar,1,IB);
   return(IB[0]);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &Time[],const double &Open[],const double &High[],const double &Low[],const double &Close[],const long &TickVolume[],const long &Volume[],const int &Spread[])
  {
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
   int IndCounted=prev_calculated;
   if(IndCounted<0){return(0);}
   if(IndCounted==0){CLR();}
   int pos=rates_total-1;
   if(IndCounted>0){pos=rates_total-IndCounted;}
   for(int i=pos;i>0;i--)
     {
      B1[i]=0;
      B2[i]=0;
      if(iMA1(i+1)<iMA2(i+1) && iMA1(i)>iMA2(i) && (eRSI(i)>50 || RSI==0))
        {
         if(Confirm2==0)
           {
            BU(i,Time,High,Low);
           }
         else{IUP=Low[i];IDN=0;}
        }
      if(iMA1(i+1)>iMA2(i+1) && iMA1(i)<iMA2(i) && (eRSI(i)<50 || RSI==0))
        {
         if(Confirm2==0)
           {
            BD(i,Time,High,Low);
           }
         else
           {
            IDN=High[i];IUP=0;
           }
        }
      if(IUP!=0)
        {
         if(((High[i]-IUP)>=(Confirm2*_Point)) && (Open[i]<=Close[i]))
           {
            BU(i,Time,High,Low);
            IUP=0;
           }
        }
      if(IDN!=0)
        {
         if(((IDN-Low[i])>=(Confirm2*_Point)) && (Open[i]>=Close[i]))
           {
            BD(i,Time,High,Low);
            IDN=0;
           }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| BU                                                               |
//+------------------------------------------------------------------+
void BU(int i,const datetime &Time[],const double &High[],const double &Low[])
  {
   if(Low[i]>=(E1+Flat2*_Point) || Low[i]<=(E1-Flat2*_Point))
     {
      B1[i]=Low[i];
      E1=B1[i];
      Alerts(i,"UP "+Symbol()+" "+TimeToString(Time[i]));
     }
  }
//+------------------------------------------------------------------+
//| BD                                                               |
//+------------------------------------------------------------------+
void BD(int i,const datetime &Time[],const double &High[],const double &Low[])
  {
   if(High[i]>=(E2+Flat2*_Point) || High[i]<=(E2-Flat2*_Point))
     {
      B2[i]=High[i];
      E2=B2[i];
      Alerts(i,"DN "+Symbol()+" "+TimeToString(Time[i]));
     }
  }
//+------------------------------------------------------------------+
//| Alerts                                                           |
//+------------------------------------------------------------------+
void Alerts(int pos,string txt)
  {
   if(SoundAlert==true&&pos==1){PlaySound("alert.wav");}
   if(EmailAlert==true&&pos==1){SendMail("Stalin alert signal: "+txt,txt);}
  }
//+------------------------------------------------------------------+
//| MethodMigrate                                                    |
//+------------------------------------------------------------------+
ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0: return(MODE_SMA);
      case 1: return(MODE_EMA);
      case 2: return(MODE_SMMA);
      case 3: return(MODE_LWMA);
      default: return(MODE_SMA);
     }
  }
//+------------------------------------------------------------------+
