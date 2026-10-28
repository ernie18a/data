//+------------------------------------------------------------------+
//|                                           Ang_AutoCh_HL-v1x3.mq5 |
//|                           Copyright © 2008, ANG3110@latchess.com |
//|                                             ANG3110@latchess.com |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2008, ANG3110@latchess.com"
//--- link to the website of the author
#property link      "ANG3110@latchess.com"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- buffers are not used for indicator calculation and drawing
#property indicator_buffers 0
//--- no graphical constructions
#property indicator_plots   0
//+-------------------------------------+
//| Indicator input parameters          |
//+-------------------------------------+
input string SirName="Ang_AutoCh_HL-v1 1";  // Indicator name
input uint  Hours1=24;                      // Calculation period in hours
input color UpChannelColor1=clrSpringGreen; // The color of the upper line of the channel
input color MdChannelColor1=clrSlateGray;   // The color of the middle line of the channel
input color DnChannelColor1=clrMagenta;     // The color of the lower line of the channel
input uint  Hours2=48;                      // Calculation period in hours
input color UpChannelColor2=clrDeepSkyBlue; // The color of the upper line of the channel
input color MdChannelColor2=clrDarkViolet;  // The color of the middle line of the channel
input color DnChannelColor2=clrDeepPink;    // The color of the lower line of the channel
input uint  Hours3=96;                      // Calculation period in hours
input color UpChannelColor3=clrTeal;        // The color of the upper line of the channel
input color MdChannelColor3=clrBlue;        // The color of the middle line of the channel
input color DnChannelColor3=clrDarkOrange;  // The color of the lower line of the channel
//+-------------------------------------+
//--- declaring string variables for the names of graphical objects
string sname;
//--- declaring integer variables for the start of data calculation
int min_rates_total,P1,P2,P3,fs;
//+------------------------------------------------------------------+
//| Getting timeframe as string                                      |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//| Trend line creation                                              |
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
//| Resetting a trend line                                           |
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
   P1=int(60*60*Hours1/PeriodSeconds());
   P2=int(60*60*Hours2/PeriodSeconds());
   P3=int(60*60*Hours3/PeriodSeconds());
   min_rates_total=MathMax(P1,MathMax(P2,P3))+1;
   fs=1;
   string str=GetStringTimeframe(Period());
   sname=SirName+" "+str;
//---
  }
//+------------------------------------------------------------------+
//| DelObj                                                           |
//+------------------------------------------------------------------+
void DelObj(uint Number,string Name)
  {
//---
   string UpName=Name+" Upper "+string(Number);
   string MdName=Name+" Middle "+string(Number);
   string DnName=Name+" Lower "+string(Number);

   ObjectDelete(0,UpName);
   ObjectDelete(0,MdName);
   ObjectDelete(0,DnName);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//---
   DelObj(1,sname);
   DelObj(2,sname);
   DelObj(3,sname);
//---
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---
   OnCalculate_Line(1,sname,P1,time,high,low,close,UpChannelColor1,MdChannelColor1,DnChannelColor1);
   OnCalculate_Line(2,sname,P2,time,high,low,close,UpChannelColor2,MdChannelColor2,DnChannelColor2);
   OnCalculate_Line(3,sname,P3,time,high,low,close,UpChannelColor3,MdChannelColor3,DnChannelColor3);
//---    
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnCalculate_Line function                                        |
//+------------------------------------------------------------------+
void OnCalculate_Line(uint Number,
                      string Name,
                      int Per,
                      const datetime &Time[],
                      const double &High[],
                      const double &Low[],
                      const double &Close[],
                      color UpColor,
                      color MdColor,
                      color DnColor)
  {
//---
   double lr,lr0,lrp;
   double sx,sy,sxy,sx2,aa,bb;
   double dh,dl,dh_1=0.0,dl_1=0.0,dh_2=0.0,dl_2=0.0;
   double hai=0.0,lai,dhi,dli,dhm=0.0,dlm=0.0,ha0,hap,la0,lap;
   double price_p1=0.0,price_p0=0.0,price_p2=0.0,price_01=0.0,price_00=0.0,price_02=0.0;
   int ai_1=0,ai_2=0,bi_1=0,bi_2=0;
   int f=0,f1,i,n,dif;
//---
   sx=0;
   sy=0;
   sxy=0;
   sx2=0;
//---
   for(n=0; n<=Per; n++)
     {
      sx+=n;
      sy+=Close[n];
      sxy+=n*Close[n];
      sx2+=MathPow(n,2);
     }

   double res=MathPow(sx,2)-(Per+1)*sx2;
   if(res) aa=(sx*sy-(Per+1)*sxy)/res;
   else aa=0.0;
   bb=(sy-aa*sx)/(Per+1);
//---
   for(i=0; i<=Per; i++)
     {
      lr=bb+aa*i;
      dh=High[i]-lr;
      dl=Low[i]-lr;
      //---
      if(i<Per/2)
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
      if(i>=Per/2)
        {
         if(i==Per/2)
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
   lrp=bb+aa*(i+Per);
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
         for(i=0; i<=Per; i++)
           {
            dif=ai_1-ai_2;
            if(dif) hai=(High[ai_1]*(i-ai_2)-High[ai_2]*(i-ai_1))/dif;
            else hai=0.0;
            if(i==0 || i==Per/2) dhm=0.0;
            if(High[i]-hai>dhm)
              {
               f1=1;
               if(i<Per/2) ai_1=i;
               if(i>=Per/2) ai_2=i;
              }
           }
         if(!f) break;
        }

      //---
      for(i=0; i<=Per; i++)
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
         hap=(High[ai_1]*(Per-ai_2)-High[ai_2]*(Per-ai_1))/dif;
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
         for(i=0; i<=Per; i++)
           {
            dif=bi_1-bi_2;
            if(dif) lai=Low[bi_1]*(i-bi_2)/dif-Low[bi_2]*(i-bi_1)/dif;
            else lai=0.0;
            if(i==0 || i==Per/2) dlm=0.0;

            if(Low[i]-lai<dlm)
              {
               f1=1;
               if(i<Per/2) bi_1=i;
               if(i>=Per/2) bi_2=i;
              }
           }
         if(!f) break;
        }
      //---
      for(i=0; i<=Per; i++)
        {
         dif=bi_1-bi_2;
         if(dif) lai=(Low[bi_1]*(i-bi_2)-Low[bi_2]*(i-bi_1))/dif;
         else lai=0.0;

         dhi=High[i]-lai;

         if(!i) dhm=0.0;
         if(dhi>dhm) dhm=dhi;
        }

      dif=bi_1-bi_2;
      if(dif)
        {
         la0=(Low[bi_1]*(0-bi_2)-Low[bi_2]*(0-bi_1))/dif;
         lap=(Low[bi_1]*(Per-bi_2)-Low[bi_2]*(Per-bi_1))/dif;
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
   datetime Tp=Time[Per];
   datetime T0=Time[0];
   string UpName=Name+" Upper "+string(Number);
   string MdName=Name+" Middle "+string(Number);
   string DnName=Name+" Lower "+string(Number);
//---
   SetTline(0,UpName,0,Tp,price_p2,T0,price_02,UpColor,STYLE_SOLID,2,UpName);
   SetTline(0,MdName,0,Tp,price_p0,T0,price_00,MdColor,STYLE_DOT,1,MdName);
   SetTline(0,DnName,0,Tp,price_p1,T0,price_01,DnColor,STYLE_SOLID,2,DnName);
//---    
  }
//+------------------------------------------------------------------+
