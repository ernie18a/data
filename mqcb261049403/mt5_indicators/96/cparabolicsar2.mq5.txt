//+------------------------------------------------------------------+
//|                                                                  |
//|                                      Copyright 2010, Rinng       |
//|                                                                  |
//+------------------------------------------------------------------+
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  Blue,Purple,Indigo,Sienna,SteelBlue,Aqua,SpringGreen,Gold,Yellow,Linen,MintCream
//+------------------------------------------------------------------+
class CParabolic
  {
protected:
   double            c_SARStep;     // Step
   double            c_SARMaximum;  // Maximum
   double            c_AF;          // Acceleration factor
   double            MaxHigh;       // Max High of the period
   double            MinLow;        // Min Low  of the period
   double            Sar_P;         // Parabolic Price
   double            TmpFlag[4];    // Tmp flags buffer
   int               Flag;          // Trend flag
   int               totlSar;       // Total bars
public:
   int               GetColor() { return((int)MathCeil(c_AF/c_SARStep)-1);}
   //----------------------------------------------------------------------
   void              Init(double SARStep,double SARMaximum,const double &high[],const double &low[],int totl)
     {
      totlSar=totl;
      c_SARStep=SARStep;
      c_SARMaximum=SARMaximum;
      MaxHigh=high[0];
      MinLow=low[0];
      Sar_P =low[0];
      Flag= 1;
      c_AF=c_SARStep;
     }
   //----------------------------------------------------------------------------                     
   double           Calc(const double &high[],const double &low[],int i)
     {
      //--------------- Calculate history bars
      if(i<totlSar-1)
        {
         if(Flag==1) // 1 - bull trend
           {
            if(MaxHigh<high[i])
              {
               MaxHigh=high[i];
               c_AF+=c_SARStep;
               if(c_AF>c_SARMaximum)c_AF=c_SARMaximum;
              }
            Sar_P=Sar_P+c_AF*(MaxHigh-Sar_P);
            TmpFlag[1]=Sar_P;
           }

         if(Flag==-1) // -1  - bear trend
           {
            if(MinLow>low[i])
              {
               MinLow=low[i];
               c_AF+=c_SARStep;
               if(c_AF>c_SARMaximum)c_AF=c_SARMaximum;
              }
            Sar_P=Sar_P+c_AF*(MinLow-Sar_P);
            TmpFlag[1]=Sar_P;
           }

         if(Flag==1)
           {
            if(low[i]<Sar_P)
              {
               Flag=-1;
               c_AF=c_SARStep;
               Sar_P=MaxHigh;
               MinLow=low[i];
               MaxHigh=high[i];
              }
           }

         if(Flag==-1)
           {
            if(high[i]>Sar_P)
              {
               Flag=1;
               c_AF=c_SARStep;
               Sar_P=MinLow;
               MinLow=low[i];
               MaxHigh=high[i];
              }
           }
        }
      //---------------- Calculate current bars
      if(i>=totlSar-1)
        {
         if(Flag==1)
           {
            if(MaxHigh<high[i])
              {
               MaxHigh=high[i];
               if(TmpFlag[0]==i && TmpFlag[2]==1 && TmpFlag[3]==1)
                 {
                  c_AF+=c_SARStep;
                  if(c_AF>c_SARMaximum)c_AF=c_SARMaximum;
                  TmpFlag[2]=0;
                 }
              }
            if(TmpFlag[0]!=i)
              {
               Sar_P=TmpFlag[1]+c_AF*(MaxHigh-TmpFlag[1]);
               TmpFlag[1]=Sar_P;
               TmpFlag[0]=i;
               TmpFlag[2]=1;
               TmpFlag[3]=Flag;
              }
            if(low[i]<Sar_P)
              {
               Flag=-1;
               c_AF=c_SARStep;
               Sar_P=MaxHigh;
               TmpFlag[1]=Sar_P;
               MinLow=low[i];
               MaxHigh=high[i];
              }
           }
         if(Flag==-1)
           {
            if(MinLow>low[i])
              {
               MinLow=low[i];
               if(TmpFlag[0]==i && TmpFlag[2]==1 && TmpFlag[3]==-1)
                 {
                  c_AF+=c_SARStep;
                  if(c_AF>c_SARMaximum)c_AF=c_SARMaximum;
                  TmpFlag[2]=0;
                 }
              }
            if(TmpFlag[0]!=i)
              {
               Sar_P=TmpFlag[1]+c_AF*(MinLow-TmpFlag[1]);
               TmpFlag[1]=Sar_P;
               TmpFlag[0]=i;
               TmpFlag[2]=1;
               TmpFlag[3]=Flag;
              }

            if(high[i]>Sar_P)
              {
               Flag=1;
               c_AF=c_SARStep;
               Sar_P=MinLow;
               TmpFlag[1]=Sar_P;
               MinLow=low[i];
               MaxHigh=high[i];
              }
           }
        }
      return(Sar_P);
     }
  };
//====================================================================
//--- External parametrs
input double         InpSARStep=0.02;    // Step
input double         InpSARMaximum=0.2;  // Maximum
//---- buffers
double               ExtSARBuffer[];
double               ExtColorBuffer[];
//--- global variables
CParabolic *c_parab;
double               ExtSarStep;
double               ExtSarMaximum;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- checking input data
   if(InpSARStep<0.0)
     {
      ExtSarStep=0.02;
      Print("The input parameter InpSARStep has incorrect value. Indicator will use value",
            ExtSarStep,"for calculations.");
     }
   else ExtSarStep=InpSARStep;
   if(InpSARMaximum<0.0)
     {
      ExtSarMaximum=0.2;
      Print("The input parameter InpSARMaximum has incorrect value. Indicator will use value",
            ExtSarMaximum,"for calculations.");
     }
   else ExtSarMaximum=InpSARMaximum;
//---- indicator buffers
   SetIndexBuffer(0,ExtSARBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//--- set arrow symbol
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//--- set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set label name
   PlotIndexSetString(0,PLOT_LABEL,"SAR("+
                      DoubleToString(ExtSarStep,2)+","+
                      DoubleToString(ExtSarMaximum,2)+")");
//---
   c_parab=new CParabolic;
   return(0);
  }
//--------------------------------------------------------------------
void OnDeinit(const int reason)
  {
   delete(c_parab);
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
   int limit=prev_calculated-1;
   if(prev_calculated==0)limit=0;
   for(int i=limit;i<rates_total;i++)
     {
      if(i==0) c_parab.Init(ExtSarStep,ExtSarMaximum,high,low,rates_total);
      if(i>0)
        {
         ExtSARBuffer[i]=c_parab.Calc(high,low,i);
         ExtColorBuffer[i]=c_parab.GetColor();
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
