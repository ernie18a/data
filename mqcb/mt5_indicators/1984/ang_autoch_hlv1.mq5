//+------------------------------------------------------------------+
//|                                             Ang_AutoCh_HL-v1.mq5 |
//|                           Copyright © 2008, ANG3110@latchess.com |
//|                                             ANG3110@latchess.com |
//+------------------------------------------------------------------+
//--- copyright
#property copyright "Copyright © 2008, ANG3110@latchess.com"
//--- link to the website of the author
#property link      "ANG3110@latchess.com"
//--- Indicator version number
#property version   "1.00"
//--- Drawing the indicator in the main window
#property indicator_chart_window
//--- no buffers are used or indicator calculation and drawing
#property indicator_buffers 0
//--- 0 graphical plots are used
#property indicator_plots   0
//+-------------------------------------+
//| Indicator input parameters          |
//+-------------------------------------+
input string SirName="Ang_AutoCh_HL-v1 1"; // Indicator name
input uint Hours=24;                       // Calculation period in hours
input color UpChannelColor=clrDeepSkyBlue; // The color of the upper line of the channel
input color MdChannelColor=clrDarkViolet;  // The color of the middle line of the channel
input color DnChannelColor=clrDeepPink;    // The color of the lower line of the channel
//+-------------------------------------+
//--- declaring string variables for the names of graphical objects
string UpName,MdName,DnName;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total,p,fs;
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,      // Chart ID
                 string   name,          // object name
                 int      nwin,          // window index
                 datetime time1,         // price level time 1
                 double   price1,        // price level 1
                 datetime time2,         // price level time 2
                 double   price2,        // price level 2
                 color    Color,         // line color
                 int      style,         // line style
                 int      width,         // line width
                 string   text)          // text
  {
//---
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//---
  }
//+------------------------------------------------------------------+
//|  Resetting a trend line                                          |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,      // Chart ID
              string   name,          // object name
              int      nwin,          // window index
              datetime time1,         // price level time 1
              double   price1,        // price level 1
              datetime time2,         // price level time 2
              double   price2,        // price level 2
              color    Color,         // line color
              int      style,         // line style
              int      width,         // line width
              string   text)          // text
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables
   p=int(60*60*Hours/PeriodSeconds());
   min_rates_total=p+1;
   fs=1;
   string str=GetStringTimeframe(Period());
   UpName=SirName+" "+str+" Upper";
   MdName=SirName+" "+str+" Middle";
   DnName=SirName+" "+str+" Lower";
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DelObj()
  {
//---
   ObjectDelete(0,UpName);
   ObjectDelete(0,MdName);
   ObjectDelete(0,DnName);
//---
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//---
   DelObj();
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);
//---
   double lr,lr0,lrp;
   double sx,sy,sxy,sx2,aa,bb;
   double dh,dl,dh_1=0.0,dl_1=0.0,dh_2=0.0,dl_2=0.0;
   double hai,lai,dhi,dli,dhm=0.0,dlm=0.0,ha0,hap,la0,lap;
   double price_p1=0.0,price_p0=0.0,price_p2=0.0,price_01=0.0,price_00=0.0,price_02=0.0;
   int ai_1=0,ai_2=0,bi_1=0,bi_2=0;
   int f=0,f1,i,n,dif;
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
//---
   sx=0;
   sy=0;
   sxy=0;
   sx2=0;
//---
   for(n=0; n<=p; n++)
     {
      sx+=n;
      sy+=Close[n];
      sxy+=n*Close[n];
      sx2+=MathPow(n,2);
     }
//---
   double res=MathPow(sx,2)-(p+1)*sx2;
   if(res) aa=(sx*sy-(p+1)*sxy)/res;
   else aa=0.0;
   bb=(sy-aa*sx)/(p+1);
//---
   for(i=0; i<=p; i++)
     {
      lr=bb+aa*i;
      dh=High[i]-lr;
      dl=Low[i]-lr;
      //---
      if(i<p/2)
        {
         if(!i)
           {
            dh_1=0.0;
            dl_1=0.0;
            ai_1=i;
            bi_1=i;
           }

         if(dh>=dh_1){dh_1=dh; ai_1=i;}
         if(dl<=dl_1){dl_1=dl; bi_1=i;}
        }
      //---
      if(i>=p/2)
        {
         if(i==p/2)
           {
            dh_2=0.0;
            dl_2=0.0;
            ai_2=i;
            bi_2=i;
           }
         if(dh>=dh_2){dh_2=dh; ai_2=i;}
         if(dl<=dl_2){dl_2=dl; bi_2=i;}
        }
     }
//---
   lr0=bb;
   lrp=bb+aa*(i+p);
//---
   double vel1=MathAbs(ai_1-ai_2);
   double vel2=MathAbs(bi_1-bi_2);
   if(vel1>vel2) f=1;
   if(vel1<vel2) f=2;
   if(vel1==vel2)
     {
      double vel3=MathAbs(dh_1-dh_2);
      double vel4=MathAbs(dl_1-dl_2);
      if(vel3<vel4) f=1;
      if(vel3>=vel4) f=2;
     }
//---
   if(f==1)
     {
      for(n=0; n<=20; n++)
        {
         f1=0;
         for(i=0; i<=p; i++)
           {
            dif=ai_1-ai_2;
            if(dif) hai=(High[ai_1]*(i-ai_2)-High[ai_2]*(i-ai_1))/dif;
            else hai=0.0;
            if(i==0 || i==p/2) dhm=0.0;
            if(High[i]-hai>dhm)
              {
               f1=1;
               if(i<p/2) ai_1=i;
               if(i>=p/2) ai_2=i;
              }
           }
         if(!f) break;
        }
      //---
      for(i=0; i<=p; i++)
        {
         dif=ai_1-ai_2;
         if(dif) hai=(High[ai_1]*(i-ai_2)-High[ai_2]*(i-ai_1))/dif;
         dli=Low[i]-hai;
         if(!i) dlm=0.0;
         if(dli<dlm) dlm=dli;
        }

      dif=ai_1-ai_2;
      if(dif)
        {
         ha0=(High[ai_1]*(0-ai_2)-High[ai_2]*(0-ai_1))/dif;
         hap=(High[ai_1]*(p-ai_2)-High[ai_2]*(p-ai_1))/dif;
        }
      else
        {
         ha0=0.0;
         hap=0.0;
        }
      //---
      price_p1=hap;
      price_p0=hap+dlm/2;
      price_p2=hap+dlm;
      price_01=ha0;
      price_00=ha0+dlm/2;
      price_02=ha0+dlm;
     }
//---
   if(f==2)
     {
      for(n=0; n<=20; n++)
        {
         f1=0;
         for(i=0; i<=p; i++)
           {
            dif=bi_1-bi_2;
            if(dif) lai=Low[bi_1]*(i-bi_2)/dif-Low[bi_2]*(i-bi_1)/dif;
            else lai=0.0;
            if(i==0 || i==p/2) dlm=0.0;

            if(Low[i]-lai<dlm)
              {
               f1=1;
               if(i<p/2) bi_1=i;
               if(i>=p/2) bi_2=i;
              }
           }
         if(!f) break;
        }
      //---
      for(i=0; i<=p; i++)
        {
         dif=bi_1-bi_2;
         if(dif) lai=(Low[bi_1]*(i-bi_2)-Low[bi_2]*(i-bi_1))/dif;
         else lai=0.0;

         dhi=High[i]-lai;

         if(i==0) dhm=0.0;
         if(dhi>dhm) dhm=dhi;
        }

      dif=bi_1-bi_2;
      if(dif)
        {
         la0=(Low[bi_1]*(0-bi_2)-Low[bi_2]*(0-bi_1))/dif;
         lap=(Low[bi_1]*(p-bi_2)-Low[bi_2]*(p-bi_1))/dif;
        }
      else
        {
         la0=0.0;
         lap=0.0;
        }
      //---
      price_p1=lap;
      price_p0=lap+dhm/2;
      price_p2=lap+dhm;
      price_01=la0;
      price_00=la0+dhm/2;
      price_02=la0+dhm;
     }
//---     
   datetime Tp=Time[p];
   datetime T0=Time[0];
//---
   SetTline(0,UpName,0,Tp,price_p2,T0,price_02,UpChannelColor,STYLE_SOLID,2,UpName);
   SetTline(0,DnName,0,Tp,price_p1,T0,price_01,DnChannelColor,STYLE_SOLID,2,DnName);
   SetTline(0,MdName,0,Tp,price_p0,T0,price_00,MdChannelColor,STYLE_DOT,1,MdName);
//---    
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
