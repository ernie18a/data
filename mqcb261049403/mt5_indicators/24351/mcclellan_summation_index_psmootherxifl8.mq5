//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "McClellan Summation Index using \"smoother\" with floating levels"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "McClellan Summation Index"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2

//
//
//

input string   inpBaseCurrency     = "USD"; // Base currency
input int      inpFastPeriod       =  19;   // Fast smoother period
input int      inpSlowPeriod       =  39;   // Slow smoother period
input double   inpPeriodMultiplier =  1;    // Periods multiplier
input int      inpLevels           = 10;    // Levels period
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on outer levels cross
   cchange_onZero    // Change color on middle level cross
};
input int                inpFlPeriod    = 25;               // Floating levels period
input double             inpFlLevelUp   = 90;               // Floating levels up %
input double             inpFlLevelDn   = 10;               // Floating levels down %
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color changing mode

//
//---
//

double val[],valc[],levu[],levd[],levm[];
struct sSymbolInfo
{
   string name;
   int    bars;
   bool   inverse;
};
sSymbolInfo _symbols[]; int _symbolsSize=0;

//------------------------------------------------------------------
//
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,levu,INDICATOR_DATA);
         SetIndexBuffer(1,levm,INDICATOR_DATA);
         SetIndexBuffer(2,levd,INDICATOR_DATA);
         SetIndexBuffer(3,val ,INDICATOR_DATA);
         SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);

         //
         //
         //
         
            int _totalSymbols = SymbolsTotal(true);
               for(int i=0; i<_totalSymbols; i++)
               {
                  string _symbol  = SymbolName(i,true);
                  int    _foundAt = StringFind(_symbol,inpBaseCurrency);
                  if (_foundAt!=WRONG_VALUE)
                  {
                     _symbolsSize = ArrayResize(_symbols,_symbolsSize+1);
                     _symbols[_symbolsSize-1].name    = _symbol;
                     _symbols[_symbolsSize-1].inverse = (_foundAt>0);
                     _symbols[_symbolsSize-1].bars    = 0;
                  }
               }    
               iSmootherFast.init(inpFastPeriod*inpPeriodMultiplier);
               iSmootherSlow.init(inpSlowPeriod*inpPeriodMultiplier);
         
   //
   //--- indicator short name assignment
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"McClellan "+inpBaseCurrency+" summation index (of "+(string)_symbolsSize+" symbols) ("+(string)(inpFastPeriod*inpPeriodMultiplier)+","+(string)(inpSlowPeriod*inpPeriodMultiplier)+","+(string)inpLevels+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   for (int i = 0; i<_symbolsSize; i++) _symbols[i].bars = iBars(_symbols[i].name,0);
      static int    prev_i=-1;
      static double prev_max,prev_min;
   

   //
   //---
   //

   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _up=0,_dn=0,_advancesDeclines=0;
      for (int k=0; k<_symbolsSize; k++)
      {
         int _shift = iBarShift(_symbols[k].name,0,time[i]);
         if (_shift != WRONG_VALUE)
         {
            double _close = iClose(_symbols[k].name,0,_shift);
            double _open  = iOpen(_symbols[k].name,0,_shift);
            if (_symbols[k].inverse)
            {
               if (_close<_open) _up++;
               if (_close>_open) _dn++;
            }
            else
            {
               if (_close>_open) _up++;
               if (_close<_open) _dn++;
            }
         }            
         _advancesDeclines = (_up+_dn!=0) ? (_up-_dn)/(_up+_dn) : 0;
      }
      val[i] = (i==0 ? 0 : val[i-1]) + iSmootherFast.calculate(_advancesDeclines,i,rates_total)-iSmootherSlow.calculate(_advancesDeclines,i,rates_total);
      
      //
      //---
      //
      
         if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-inpFlPeriod+1; if (start<0) start=0;
                prev_max = val[ArrayMaximum(val,start,inpFlPeriod-1)];
                prev_min = val[ArrayMinimum(val,start,inpFlPeriod-1)];
         }
         double max = (val[i] > prev_max) ? val[i] : prev_max;
         double min = (val[i] < prev_min) ? val[i]  : prev_min;
         double range = (max-min)/100.0;
            levu[i] = min+inpFlLevelUp*range;
            levd[i] = min+inpFlLevelDn*range;
            levm[i] = (levu[i]+levd[i])/2;
      //
      //
      //
         
      switch (inpColorChange)
      {
         case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
         case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
         case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
      }         
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

class CSmoother
{
   private :
      double m_period;
      double m_alpha;
      double m_beta;
      int    m_arraySize;
      struct CSmootherStruct
      {
         double l0;
         double l1;
         double l2;
         double l3;
         double l4;
      };
      CSmootherStruct m_array[];
   public :
      CSmoother() : m_arraySize(-1), m_alpha(1), m_beta(1) {}
     ~CSmoother() {}
   
      //
      //
      //
      
      bool init(double period)
      {
         m_period = (period>1) ? period : 1;
         m_beta   = 0.45 * (m_period-1.0)/(0.45 * (m_period-1)+2.0);
         m_alpha  = m_beta*m_beta*m_beta;
            return(true);
      }
      
      double calculate(double value, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

         //
         //
         //
                    
         if (i>0)
         {
               m_array[i].l0 = (1.0-m_alpha)*value + m_alpha*m_array[i-1].l0;
               m_array[i].l1 = (value-m_array[i].l0)*(1-m_beta) + m_beta*m_array[i-1].l1;
               m_array[i].l2 =  m_array[i].l0 + m_array[i].l1;
               m_array[i].l3 = (m_array[i].l2 - m_array[i-1].l4)*(1.0-m_alpha)*(1.0-m_alpha) + m_alpha*m_alpha*m_array[i-1].l3;
               m_array[i].l4 =  m_array[i-1].l4 + m_array[i].l3;
         }                    
         else { m_array[i].l0 = m_array[i].l1 = m_array[i].l4 = value; m_array[i].l2 = m_array[i].l3 = 0; }
         return(m_array[i].l4);
      }
};
CSmoother iSmootherFast,iSmootherSlow;
//------------------------------------------------------------------