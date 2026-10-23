//+------------------------------------------------------------------+
//|                                                          BSI.mq4 |
//|                                          Copyright 2015, fxborg. |
//|                                  http://blog.livedoor.jp/fxborg/ |
//+------------------------------------------------------------------+
#property copyright   "2015, fxborg"
#property link        "http://blog.livedoor.jp/fxborg/"
#property description "Bounce Strength Indicator"
#property strict
//---
#property indicator_separate_window
#property indicator_buffers    3
#property indicator_color1     Blue
#property indicator_color2     Red
#property indicator_color3     Black
#property indicator_level1     10.0
#property indicator_level2     0.0
#property indicator_level3     -10.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- input parameters
input int InpRangePeriod=20; //  Range Period
input int InpSlowing=3;     // Slowing
input int InpAvgPeriod=3;   //  Avg Period
input bool InpUsingVolumeWeight=true;   // Using TickVolume
//--- buffers
double ExtMainBuffer[];
double ExtPosBuffer[];
double ExtNegBuffer[];
//---- for calc 
double ExtHighesBuffer[];
double ExtLowesBuffer[];
double ExtVolBuffer[];
//---
int draw_begin1=0;
int draw_begin2=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   string short_name;
//--- 2 additional buffers are used for counting.
   IndicatorBuffers(6);
   SetIndexBuffer(3,ExtHighesBuffer);
   SetIndexBuffer(4,ExtLowesBuffer);
   SetIndexBuffer(5,ExtVolBuffer);
//--- indicator lines
   SetIndexLabel(0,"Floor Bounce Strength");
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtPosBuffer);
   SetIndexLabel(1,"Ceiling Bounce Strength");
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtNegBuffer);
   SetIndexLabel(2,"Bounce Strength Index");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMainBuffer);
//--- name for DataWindow and indicator subwindow label
//---
   draw_begin1=InpRangePeriod+InpSlowing;
   draw_begin2=draw_begin1+InpAvgPeriod;
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin1);
   SetIndexDrawBegin(2,draw_begin2);
   short_name="Bane Strength Index("+IntegerToString(InpRangePeriod)+","+IntegerToString(InpSlowing)+","+IntegerToString(InpAvgPeriod)+")";
   if(InpUsingVolumeWeight)
      short_name+=" using Volumes";
   IndicatorShortName(short_name);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| BSI caluclate                                                    |
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
   int i,k,pos;
//--- check for bars count
   if(rates_total<=InpRangePeriod+InpAvgPeriod+InpSlowing)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtMainBuffer,false);
   ArraySetAsSeries(ExtPosBuffer,false);
   ArraySetAsSeries(ExtNegBuffer,false);
   ArraySetAsSeries(ExtHighesBuffer,false);
   ArraySetAsSeries(ExtLowesBuffer,false);
   ArraySetAsSeries(ExtVolBuffer,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(tick_volume,false);
//---
   pos=InpRangePeriod-1;
//---  
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
        {
         ExtLowesBuffer[i]=0.0;
         ExtHighesBuffer[i]=0.0;
         ExtVolBuffer[i]=0.0;
        }
     }
//--- calculate HighesBuffer[] and ExtHighesBuffer[]
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      //--- calculate range spread
      double dmin=1000000.0;
      double dmax=-1000000.0;
      long volmax=0;
      for(k=i-InpRangePeriod+1; k<=i; k++)
        {
         if(dmin>low[k])
            dmin=low[k];
         if(dmax<high[k])
            dmax=high[k];
         if(volmax<tick_volume[k])
            volmax=tick_volume[k];
        }
      ExtLowesBuffer[i]=dmin;
      ExtHighesBuffer[i]=dmax;
      //---
      if(InpUsingVolumeWeight)
         ExtVolBuffer[i]=(double)volmax;
     }
//--- line
   pos=InpRangePeriod-1+InpSlowing-1;
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
        {
         ExtMainBuffer[i]=0.0;
         ExtPosBuffer[i]=0.0;
         ExtNegBuffer[i]=0.0;
        }
     }
//--- main cycle
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      double sumpos=0.0;
      double sumneg=0.0;
      double sumhigh=0.0;
      double sumpvol = 0.0;
      double sumnvol = 0.0;
      for(k=(i-InpSlowing+1); k<=i; k++)
        {
         //---
         double vol=1.0;
         if(InpUsingVolumeWeight && ExtVolBuffer[k]>0)
           {
            vol=tick_volume[k]/ExtVolBuffer[k];
           }
         //--- Range position ratio
         double ratio=0;
         //--- Range spread
         double range=ExtHighesBuffer[k]-ExtLowesBuffer[k];
         //--- Bar Spread
         double sp=(high[k]-low[k]);
         //--- Not DownBar
         if(!(close[k-1]-sp*0.2>close[k]))
           {
            //--- low equal range low
            if(low[k]==ExtLowesBuffer[k])
               ratio=1;
            else // upper - low / range spread
            ratio=(ExtHighesBuffer[k]-low[k])/range;
            sumpos+=(close[k]-low[k])*ratio *vol;
           }
         //--- Not UpBar
         if(!(close[k-1]+sp*0.2<close[k]))
           {
            //--- high equal range high 
            if(high[k]==ExtHighesBuffer[k])
               ratio=1;
            else // high - lower / range spread
            ratio=(high[k]-ExtLowesBuffer[k])/range;
            sumneg+=(high[k]-close[k])*ratio*vol*-1;
           }
         //---
         sumhigh+=range;
        }
      //---
      if(sumhigh==0.0)
        {
         ExtPosBuffer[i]=EMPTY_VALUE;
         ExtNegBuffer[i]=EMPTY_VALUE;
        }
      else
        {
         ExtPosBuffer[i]=sumpos/sumhigh*100;
         ExtNegBuffer[i]=sumneg/sumhigh*100;
        }
     }
//--- avg
   pos=InpAvgPeriod-1;
   if(pos+1<prev_calculated)
      pos=prev_calculated-2;
   else
     {
      for(i=0; i<pos; i++)
        {
         ExtMainBuffer[i]=0.0;
        }
     }
//---
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      double sumPos=0.0;
      double sumNeg=0.0;
      double sum=0.0;
      for(k=0; k<InpAvgPeriod; k++)
        {
         sum+=ExtPosBuffer[i-k]-(-1*ExtNegBuffer[i-k]);
        }
      //---
      ExtMainBuffer[i]=sum/InpAvgPeriod;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
