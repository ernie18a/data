//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*------------------------------------------------------------------+
 |                                              Nik_PSAR_2B.mq4.mq4 |
 |                                                 Copyright © 2010 |
 |                                             basisforex@gmail.com |
 +------------------------------------------------------------------*/
#property copyright "Copyright © 2010, basisforex@gmail.com"
#property link      "basisforex@gmail.com"
//-----
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 White
#property indicator_color2 Yellow
#property indicator_color3 Blue
#property indicator_color4 Black
#property indicator_color5 Green
#property indicator_color6 Red
//-----
extern bool       AlertsEnabled  = true;
extern bool       TF4            = true;
extern bool       TF3            = true;
extern bool       TF2            = true;
//-----
extern double     Step           = 0.02;
extern double     Maximum        = 0.2;
//-----
double s1[];
double s2[];
double s3[];
double s4[];
double bullish[];
double bearish[];
double sarUp[];
double sarDn[];
double alertBar;
bool sar4,sar3,sar2;
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,s1);
   SetIndexBuffer(1,s2);
   SetIndexBuffer(2,s3);
   SetIndexBuffer(3,s4);
//-----
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,159);
//------
   SetIndexStyle(4,DRAW_ARROW);// UP___UP___UP 
   SetIndexArrow(4,233);
   SetIndexBuffer(4,bullish);
//-----
   SetIndexStyle(5,DRAW_ARROW);// DOWN____DOWN
   SetIndexArrow(5,234);
   SetIndexBuffer(5,bearish);
//-----
   return(0);
  }
//+------------------------------------------------------------------+
void GetBool()
  {
   if(TF4==true)
     {
      sar4=true; sar3=true; sar2=true;
     }
   else if(TF3==true && TF4==false)
     {
      sar4=false; sar3=true; sar2=true;
     }
   else if(TF2==true && TF4==false && TF3==false)
     {
      sar4=false; sar3=false; sar2=true;
     }
   else if(TF2==false && TF4==false && TF3==false)
     {
      sar4=false; sar3=false; sar2=false;
     }
  }
//+------------------------------------------------------------------+
void GetNextTF(int curTF, int &tf1, int &tf2, int &tf3)
  {
   switch(curTF)
     {
      case 1:
         //return("5=15#30");
         tf1=5; tf2=15; tf3=30;
         break;
      case 5:
         //return("15=30#60");
         tf1=15; tf2=30; tf3=60;
         break;
      case 15:
         //return("30=60#240");
         tf1=30; tf2=60; tf3=240;
         break;
      case 30:
         //return("60=240#1440");
         tf1=60; tf2=240; tf3=1440;
         break;
      case 60:
         //return("240=1440#10080");
         tf1=240; tf2=1440; tf3=10080;
         break;
      case 240:
         //return("1440=10080#43200");
         tf1=1440; tf2=10080; tf3=43200;
         break;
     }
  }
 int limit;

//+------------------------------------------------------------------+
void AlertDn(double sar)
  {
 //  int limit;
 //  int counted_bars=IndicatorCounted();
 //  if(counted_bars<0) counted_bars=0;
 //  if(counted_bars>0) counted_bars--;
 //  limit=Bars-counted_bars;

//---- 
   for(int i=0; i<limit;i++)
     {
      if(sar>=iHigh(Symbol(),0,i))
        {
         if(AlertsEnabled==true && sarUp[i]==0 && Bars>alertBar)
           {
            Alert("PSAR Going Down on ",Symbol()," - ",Period()," min");
            alertBar=Bars;
           }
         sarUp[i] = sar;
         sarDn[i] = 0;
        }
     }
  }
//+------------------------------------------------------------------+ 
void AlertUp(double sar)
  {
/*   int limit;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) counted_bars = 0;
   if(counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;
   if(counted_bars==0) limit--;*/
   //int counted_bars=IndicatorCounted();
   //if(counted_bars<0) return(-1);
   //if(counted_bars>0) counted_bars--;
   //int limit=Bars-counted_bars;
   //if(counted_bars==0) limit--;
//---- 
   for(int i=0; i<limit;i++)
     {
      if(sar<=iLow(Symbol(),0,i))
        {
         if(AlertsEnabled==true && sarDn[i]==0 && Bars>alertBar)
           {
            Alert("PSAR Going Up on ",Symbol()," - ",Period()," min");
            alertBar=Bars;
           }
         sarUp[i] = 0;
         sarDn[i] = sar;
        }
     }
  }
//+------------------------------------------------------------------+ 
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;
   ArrayResize(sarDn,ArraySize(s1));
   ArrayResize(sarUp,ArraySize(s1));
//-----
   int tf1,tf2,tf3;
   GetNextTF(Period(),tf1,tf2,tf3);
//-----
   GetBool();
//-----
   for(int i=limit-1; i>=0; i--)
     {
      //===============================================         __________________________________________________   sar1  &  sar2  &  sar3  & sar4
      if(sar2==true && sar3==true && sar4==true)
        {
         Comment(Period()," White","\n",tf1," Yellow","\n",tf2," Blue","\n",tf3," Black");
         
         int v1=tf1 / Period();
         int v2=tf2 / Period();
         int v3=tf3 / Period();
         
         s1[i]  = iSAR(NULL, Period(), Step, Maximum, i);
                 
         if(v1!=0)
         s2[i]  = iSAR(NULL, tf1, Step, Maximum, i / (tf1 / Period()));
         else s2[i]=EMPTY_VALUE;
         
         if(v1!=0)
         s3[i]  = iSAR(NULL, tf2, Step, Maximum, i / (tf2 / Period()));
         else s3[i]=EMPTY_VALUE;
         
         if(v1!=0)
         s4[i]  = iSAR(NULL, tf3, Step, Maximum, i / (tf3 / Period()));
         else s4[i]=EMPTY_VALUE;
         //============================================================
         if((s1[i]>High[i] && s2[i]>High[i] && s3[i]>High[i] && s4[i+1]<Low[i+1] && s4[i]>High[i]) || 
            (s1[i]>High[i] && s2[i]>High[i] && s3[i+1]<Low[i+1] && s3[i]>High[i] && s4[i]>High[i]) || 
            (s1[i]>High[i] && s2[i+1]<Low[i+1] && s2[i]>High[i] && s3[i]>High[i] && s4[i]>High[i]) || 
            (s1[i+1]<Low[i+1] && s1[i]>High[i] && s2[i]>High[i] && s3[i]>High[i] && s4[i]>High[i]))
           {
            bearish[i]=s1[i]+5*Point;//       SELL__SELL__SELL
            AlertDn(s1[i]);
           }
         //-----
         if((s1[i]<Low[i] && s2[i]<Low[i] && s3[i]<Low[i] && s4[i+1]>High[i+1] && s4[i]<Low[i]) || 
            (s1[i]<Low[i] && s2[i]<Low[i] && s3[i+1]>High[i+1] && s3[i]<Low[i] && s4[i]<Low[i]) || 
            (s1[i]<Low[i] && s2[i+1]>High[i+1] && s2[i]<Low[i] && s3[i]<Low[i] && s4[i]<Low[i]) || 
            (s1[i+1]>High[i+1] && s1[i]<Low[i] && s2[i]<Low[i] && s3[i]<Low[i] && s4[i]<Low[i]))
           {
            bullish[i]=s1[i]-5*Point;//      BUY___BUY___BUY
            AlertUp(s1[i]);
           }
        }
      //===============================================         __________________________________________________   sar1  &  sar2  &  sar3 
      else if(sar2==true && sar3==true && sar4==false)
        {
         Comment(Period()," White","\n",tf1," Yellow  ","\n",tf2," Blue");
         s1[i]  = iSAR(NULL, Period(), Step, Maximum, i);
         s2[i]  = iSAR(NULL, tf1, Step, Maximum, i / (tf1 / Period()));
         s3[i]  = iSAR(NULL, tf2, Step, Maximum, i / (tf2 / Period()));
         //============================================================
         if((s1[i]>High[i] && s2[i]>High[i] && s3[i+1]<Low[i+1] && s3[i]>High[i]) || 
            (s1[i]>High[i] && s2[i+1]<Low[i+1] && s2[i]>High[i] && s3[i]>High[i]) || 
            (s1[i+1]<Low[i+1] && s1[i]>High[i] && s2[i]>High[i] && s3[i]>High[i]))
           {
            bearish[i]=s1[i]+5*Point;//       SELL__SELL__SELL
            AlertDn(s1[i]);
           }
         //-----
         if((s1[i]<Low[i] && s2[i]<Low[i] && s3[i+1]>High[i+1] && s3[i]<Low[i]) || 
            (s1[i]<Low[i] && s2[i+1]>High[i+1] && s2[i]<Low[i] && s3[i]<Low[i]) || 
            (s1[i+1]>High[i+1] && s1[i]<Low[i] && s2[i]<Low[i] && s3[i]<Low[i]))
           {
            bullish[i]=s1[i]-5*Point;//      BUY___BUY___BUY
            AlertUp(s1[i]);
           }
        }
      //===============================================          __________________________________________________   sar1  &  sar2
      else if(sar2==true && sar3==false && sar4==false)
        {
         Comment(Period()," White","\n",tf1," Yellow");
         s1[i]  = iSAR(NULL, Period(), Step, Maximum, i);
         s2[i]  = iSAR(NULL, tf1, Step, Maximum, i / (tf1 / Period()));
         //============================================================
         if((s1[i]>High[i] && s2[i+1]<Low[i+1] && s2[i]>High[i]) || 
            (s1[i+1]<Low[i+1] && s1[i]>High[i] && s2[i]>High[i]))
           {
            bearish[i]=s1[i]+5*Point;//       SELL__SELL__SELL
            AlertDn(s1[i]);
           }
         //-----
         if((s1[i]<Low[i] && s2[i+1]>High[i+1] && s2[i]<Low[i]) || 
            (s1[i+1]>High[i+1] && s1[i]<Low[i] && s2[i]<Low[i]))
           {
            bullish[i]=s1[i]-5*Point;//      BUY___BUY___BUY
            AlertUp(s1[i]);
           }
        }
      //===============================================          __________________________________________________   sar1
      else if(sar2==false && sar3==false && sar4==false)
        {
         Comment(Period()," White");
         s1[i]=iSAR(NULL,Period(),Step,Maximum,i);
         //============================================================
         if(s1[i+1]<Low[i+1] && s1[i]>High[i])
           {
            bearish[i]=s1[i]+5*Point;//       SELL__SELL__SELL
            AlertDn(s1[i]);
           }
         //----- 
         if(s1[i+1]>High[i+1] && s1[i]<Low[i])
           {
            bullish[i]=s1[i]-5*Point;//      BUY___BUY___BUY
            AlertUp(s1[i]);
           }
        }
     }
//==============================================================================================================================================
   return(0);
  }
//+------------------------------------------------------------------+
