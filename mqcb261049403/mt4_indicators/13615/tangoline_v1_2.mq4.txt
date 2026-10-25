//+------------------------------------------------------------------+
//|                                               TangoLine_v1.2.mq4 |
//| TangoLine v1.2                            Copyright 2015, fxborg |
//|                                   http://fxborg-labo.hateblo.jp/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, fxborg"
#property link      "http://fxborg-labo.hateblo.jp/"
#property version   "1.2"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
//--- plot Label1
#property indicator_label1  "TangoLine"
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_ARROW
#property indicator_type5 DRAW_ARROW

//---
#property indicator_color1 DeepPink
#property indicator_color2 DarkViolet
#property indicator_color3 DarkViolet
#property indicator_color4 Red
#property indicator_color5 Blue

#property indicator_label1 "TangoLine"
#property indicator_label2 "Upper Channel"
#property indicator_label3 "Lower Channel"
#property indicator_label4 "Reversal Bar"
#property indicator_label5 "Reversal Bar"
//---
#property indicator_width1 2
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 2
#property indicator_width5 2

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_DASH
#property indicator_style3 STYLE_DASH

//--- input parameters
input  int InpPeriod=20;  // Channel Period
input  double InpReversalNoiseFilter=5;  // NoiseFilter (Minimam Reversal Spread) 
double RevNoiseFilter=InpReversalNoiseFilter*Point;

//---
int min_rates_total;

//--- indicator buffers
double LineBuffer[];
double HighBuffer[];
double LowBuffer[];
double TopBuffer[];
double BtmBuffer[];
//---- for calc 
double HighesBuffer[];
double LowesBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=1+InpPeriod+1;

//--- indicator buffers mapping
   IndicatorBuffers(14);

//--- indicator buffers
   SetIndexBuffer(0,LineBuffer);
   SetIndexBuffer(1,HighBuffer);
   SetIndexBuffer(2,LowBuffer);
   SetIndexBuffer(3,TopBuffer);
   SetIndexBuffer(4,BtmBuffer);

//--- calc buffers
   SetIndexBuffer(5,HighesBuffer);
   SetIndexBuffer(6,LowesBuffer);

   SetIndexArrow(3,159);
   SetIndexArrow(4,159);

   SetIndexShift(0,1);
   SetIndexShift(1,1);
   SetIndexShift(2,1);

//---
   string short_name="Tango Line v1.2("+IntegerToString(InpPeriod)+")";
   IndicatorShortName(short_name);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| De-initialization                                                |
//+------------------------------------------------------------------+
int deinit()
  {
   string short_name="Tango Line v1.2("+IntegerToString(InpPeriod)+")";
   IndicatorShortName(short_name);
   return(0);
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
   int i,j,k,first;
//--- check for bars count
   if(rates_total<=min_rates_total)
      return(0);

//--- indicator buffers
   ArraySetAsSeries(LineBuffer,false);
   ArraySetAsSeries(HighBuffer,false);
   ArraySetAsSeries(LowBuffer,false);
   ArraySetAsSeries(TopBuffer,false);
   ArraySetAsSeries(BtmBuffer,false);

//--- calc buffers
   ArraySetAsSeries(HighesBuffer,false);
   ArraySetAsSeries(LowesBuffer,false);
//--- rate data
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
//+----------------------------------------------------+
//|Set High Low Buffeer                                |
//+----------------------------------------------------+
   first=InpPeriod-1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   else
     {
      for(i=0; i<first; i++)
        {
         LowesBuffer[i]=0.0;
         HighesBuffer[i]=0.0;
        }
     }

   for(i=first; i<rates_total && !IsStopped(); i++)
     {
      //--- calculate range spread
      double dmin=1000000.0;
      double dmax=-1000000.0;
      //---      
      for(k=i-InpPeriod+1; k<=i; k++)
        {
         if(dmin>low[k]) dmin=low[k];
         if(dmax<high[k]) dmax=high[k];
        }
      //---
      LowesBuffer[i]=dmin;
      HighesBuffer[i]=dmax;
     }
//+----------------------------------------------------+
//|Set Tango Line Buffeer                              |
//+----------------------------------------------------+
   first=InpPeriod-1;
   if(first+1<prev_calculated)first=prev_calculated-2;
   for(i=first; i<rates_total && !IsStopped(); i++)
     {
      //--- 
      int btm_pos=NULL;
      int top_pos=NULL;
      //--- serach reversal bar
      for(j=i-1;j>1;j--)
        {
         if(LowesBuffer[j-2]-RevNoiseFilter*Point>LowesBuffer[j-1]
            && LowesBuffer[j-1]==LowesBuffer[j])
           {
            //--- reversal of top 
            btm_pos=j-1;
            BtmBuffer[btm_pos]=LowesBuffer[btm_pos];
            break;
           }
         //--- reversal of bottom
         if(HighesBuffer[j-2]+RevNoiseFilter*Point<HighesBuffer[j-1]
            && HighesBuffer[j-1]==HighesBuffer[j])
           {
            top_pos=j-1;
            TopBuffer[top_pos]=HighesBuffer[top_pos];
            break;
           }
        }
      //--- turnning point
      int turn_pos=NULL;
      if(btm_pos!=NULL || top_pos!=NULL)
        {
         //---
         if(btm_pos!=NULL) turn_pos=btm_pos;
         else turn_pos=top_pos;
         //--- 
         double range_lo=1000000.0;
         double range_hi=-1000000.0;
         for(j=turn_pos; j<i;j++)
           {
            if(range_hi<high[j])range_hi=high[j];
            if(range_lo>low[j])range_lo=low[j];
           }
         //--- set channel data
         double prev_high=MathMax(MathMax(MathMax(high[turn_pos-4],
                                  high[turn_pos-3]),high[turn_pos-2]),high[turn_pos-1]);
         double prev_low=MathMin(MathMin(MathMin(low[turn_pos-4],
                                 low[turn_pos-3]),low[turn_pos-2]),low[turn_pos-1]);
         HighBuffer[i]=MathMax(range_hi,prev_high);
         LineBuffer[i]=(range_hi+range_lo)/2;
         LowBuffer[i]=MathMin(range_lo,prev_low);
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
