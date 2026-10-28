//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Zero lag TEMA ultra trend"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLightGreen,clrWheat
#property indicator_label2  "Ultra trend +"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrLimeGreen,clrOrange
#property indicator_width2  3
#property indicator_label3  "Ultra trend -"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrLimeGreen,clrOrange
#property indicator_width3  1

//+------------------------------------------------------------------+
//| Custom classes                                                   |
//+------------------------------------------------------------------+
class CZeroLagTema
  {
private:
   int               m_size;
   double            m_wrk[][6];

   //
   //---
   //

public :

                     CZeroLagTema(void) : m_size(0) { return; }
                    ~CZeroLagTema(void)             { return; }

   double CalculateValue(double price, double period, int r, int bars)
     {
      #define _ztema11 0
      #define _ztema21 1
      #define _ztema31 2
      #define _ztema12 3
      #define _ztema22 4
      #define _ztema32 5
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+

      if(ArrayRange(m_wrk,0)!=bars) ArrayResize(m_wrk,bars);
         m_wrk[r][_ztema11] = price;
         m_wrk[r][_ztema21] = price;
         m_wrk[r][_ztema31] = price;
         m_wrk[r][_ztema12] = price;
         m_wrk[r][_ztema22] = price;
         m_wrk[r][_ztema32] = price;
         if(r<1 || period<=1) return(price);
         else
         {
            double alpha=2.0/(1.0+period);
            m_wrk[r][_ztema11] = m_wrk[r-1][_ztema11]+alpha*(price                             -m_wrk[r-1][_ztema11]);
            m_wrk[r][_ztema21] = m_wrk[r-1][_ztema21]+alpha*(m_wrk[r][_ztema11]-m_wrk[r-1][_ztema21]);
            m_wrk[r][_ztema31] = m_wrk[r-1][_ztema31]+alpha*(m_wrk[r][_ztema21]-m_wrk[r-1][_ztema31]);
            double tema1=m_wrk[r][_ztema31]+3.0*(m_wrk[r][_ztema11]-m_wrk[r][_ztema21]);

            m_wrk[r][_ztema12] = m_wrk[r-1][_ztema12]+alpha*(tema1                             -m_wrk[r-1][_ztema12]);
            m_wrk[r][_ztema22] = m_wrk[r-1][_ztema22]+alpha*(m_wrk[r][_ztema12]-m_wrk[r-1][_ztema22]);
            m_wrk[r][_ztema32] = m_wrk[r-1][_ztema32]+alpha*(m_wrk[r][_ztema22]-m_wrk[r-1][_ztema32]);
            double tema2=m_wrk[r][_ztema32]+3.0*(m_wrk[r][_ztema12]-m_wrk[r][_ztema22]);
            return(2.0*tema1-tema2);
         }
      #undef _ztema11
      #undef _ztema21
      #undef _ztema31
      #undef _ztema12
      #undef _ztema22
      #undef _ztema32
     }
  };
//
//--- input parameters
//
input int  inpUtrPeriod   = 3;   // Start period
input int  inpProgression = 5;   // Step
input int  inpInstances   = 50;  // Instances 
input int  inpSmooth      = 5;   // Ultra trend smoothing period

//--- buffers declarations
double fillu[],filld[],valp[],valpc[],valm[],valmc[];
CZeroLagTema _iSmooth[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filld,INDICATOR_DATA);
   SetIndexBuffer(2,valp,INDICATOR_DATA);
   SetIndexBuffer(3,valpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,valm,INDICATOR_DATA);
   SetIndexBuffer(5,valmc,INDICATOR_COLOR_INDEX);
   ArrayResize(_iSmooth,inpInstances+3);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//--- indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,"Zero lag TEMA ultra trend  ("+(string)inpUtrPeriod+","+(string)inpProgression+","+(string)inpInstances+")");
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int endLength=inpUtrPeriod+inpProgression*inpInstances;
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      double valueUp=0;
      double valueDn=0;

      for(int k=inpUtrPeriod,instance=2; k<=endLength && i>0; k+=inpProgression,instance++)
         if(_iSmooth[instance].CalculateValue(close[i-1],k,i-1,rates_total)<_iSmooth[instance].CalculateValue(close[i],k,i,rates_total))
              valueUp++;
         else valueDn++;
      valp[i]  = _iSmooth[0].CalculateValue(valueUp,inpSmooth,i,rates_total);
      valm[i]  = _iSmooth[1].CalculateValue(valueDn,inpSmooth,i,rates_total);
      valpc[i] = (valp[i]>valm[i]) ? 1 : 2;
      valmc[i] = valpc[i];
      fillu[i] = valp[i];
      filld[i] = valm[i];
     }
   return (i);
  }
