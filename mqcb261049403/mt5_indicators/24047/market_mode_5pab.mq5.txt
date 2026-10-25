//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Market mode"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width3 2

//
//
//

input int                 inpPeriod       = 20;           // Base period
input double              inpCyclesPeriod = 2;            // Cycles period
input double              inpCyclesFilter = 0;            // Cycles filter (<=1 for no filtering)
input double              inpDelta        = 0.5;          // Delta
input double              inpFraction     = 0.1;          // Fraction 
input ENUM_APPLIED_PRICE  inpPrice        = PRICE_MEDIAN; // Price

double mode[],modec[],fractionUp[],fractionDn[];
double g_alpha,g_alphal,g_beta,g_cycleFilter; int g_dPeriod;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,fractionUp);
         SetIndexBuffer(1,fractionDn);
         SetIndexBuffer(2,mode);
         SetIndexBuffer(3,modec,INDICATOR_COLOR_INDEX);
            g_cycleFilter = 2.0/(1.0+(inpCyclesFilter>1 ? inpCyclesFilter : 1));
            g_dPeriod     = 2*inpPeriod;
  
   //
   //---
   //

   IndicatorSetString(INDICATOR_SHORTNAME,"PA adaptive Market mode "+(string)inpPeriod+","+(string)inpCyclesPeriod+","+(string)inpDelta+","+(string)inpFraction+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}

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
   struct sMarketModeStruct
   {
      double price;
      double bandpass;
      double peak;
      double valey;
      double sumbp;
      double sumpeak;
      double sumvaley;
   };
   static sMarketModeStruct m_array[];
   static int m_arraySize = -1;
          if (m_arraySize<rates_total)
          {
              m_arraySize = ArrayResize(m_array,rates_total+500); if (m_arraySize<rates_total) return(0);
          }

   //
   //---
   //
                                    
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,m_array[i].price,i);
      double _phasePeriod = iHilbertPhase(m_array[i].price,g_cycleFilter,inpCyclesPeriod,i,rates_total);
            double gamma     = 1.0 / MathCos(4.0*M_PI*inpDelta/_phasePeriod);
                   g_beta    = MathCos(2.0*M_PI/_phasePeriod);
                   g_alpha   = gamma -MathSqrt(gamma*gamma-1.0);

         //
         //
         //
         
         if (i>1) 
         {
            m_array[i].bandpass = 0.5*(1.0-g_alpha)*(m_array[i].price-m_array[i-2].price)+g_beta*(1.0+g_alpha)*m_array[i-1].bandpass-g_alpha*m_array[i-2].bandpass;
            m_array[i].peak     = m_array[i-1].peak;
            m_array[i].valey    = m_array[i-1].valey;
                  if (m_array[i-1].bandpass>m_array[i].bandpass && m_array[i-1].bandpass>m_array[i-2].bandpass) m_array[i].peak  = m_array[i-1].bandpass;
                  if (m_array[i-1].bandpass<m_array[i].bandpass && m_array[i-1].bandpass<m_array[i-2].bandpass) m_array[i].valey = m_array[i-1].bandpass;
         }
         else m_array[i].peak = m_array[i].valey = m_array[i].bandpass = m_array[i].price;
         
         //
         //---
         //
            
         if (i>g_dPeriod)
                  m_array[i].sumbp = m_array[i-1].sumbp+m_array[i].bandpass-m_array[i-g_dPeriod].bandpass;
         else  {  m_array[i].sumbp = m_array[i].bandpass; for (int k=1; k<(g_dPeriod) && (i-k)>=0; k++) m_array[i].sumbp += m_array[i-k].bandpass; }
         if (i>50)
               {
                  m_array[i].sumpeak  = m_array[i-1].sumpeak  + m_array[i].peak  - m_array[i-50].peak;
                  m_array[i].sumvaley = m_array[i-1].sumvaley + m_array[i].valey - m_array[i-50].valey;
               }
         else
               {
                  m_array[i].sumpeak  = m_array[i].peak;
                  m_array[i].sumvaley = m_array[i].valey;
                  for (int k=1; k<50 && (i-k)>=0; k++)
                  {
                     m_array[i].sumpeak  += m_array[i-k].peak;
                     m_array[i].sumvaley += m_array[i-k].valey;
                  }
               }                                 
  
         //
         //---
         //
            
         fractionUp[i] = inpFraction*m_array[i].sumpeak /50.0;
         fractionDn[i] = inpFraction*m_array[i].sumvaley/50.0;
         mode[i]       = m_array[i].sumbp/(double)g_dPeriod;
         modec[i]      = (mode[i]>fractionUp[i]) ? 1 : (mode[i]<fractionDn[i]) ? 2 : 0;
   }               
   return(i);        
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

double iHilbertPhase(double price, double filter, double cyclesToReach, int i, int bars)
{
   struct iHilbertPhaseStruct
      {
         double price;
         double smooth;
         double detrender;
         double period;
         double phase;
         double deltaPhase;
         double Q1;
         double I1;
      };       
   static iHilbertPhaseStruct m_array[];
   static int m_arraySize = -1;
          if (m_arraySize<bars)
          {
               m_arraySize=ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(price);
          }
   
      
   //
   //---
   //

      m_array[i].price = price; 
         if (i<6) { 
                     m_array[i].period     = 1;  
                     m_array[i].deltaPhase = 7;  
                     m_array[i].smooth     = m_array[i].Q1 = m_array[i].I1 = price; 
                     return(1); 
                  }
                  cyclesToReach *= 360.0;

      //
      //---
      //
      
      #define _calcComp(_ind) ((0.0962*m_array[i]._ind + 0.5769*m_array[i-2]._ind - 0.5769*m_array[i-4]._ind - 0.0962*m_array[i-6]._ind) * (0.075*m_array[i-1].period + 0.54))

         m_array[i].smooth     = (4.0*m_array[i].price+3.0*m_array[i-1].price+2.0*m_array[i-2].price+m_array[i-3].price)/10.0;
         m_array[i].detrender  = _calcComp(smooth);
         m_array[i].Q1         = 0.15*_calcComp(detrender)  +0.85*m_array[i-1].Q1;
         m_array[i].I1         = 0.15*m_array[i-3].detrender+0.85*m_array[i-1].I1;

         //
         //---
         //

         m_array[i].phase = (m_array[i].I1!=0) ? 180.0/M_PI*MathArctan(MathAbs(m_array[i].Q1/m_array[i].I1)) : m_array[i-1].phase;
            if (m_array[i].I1<0 && m_array[i].Q1>0) m_array[i].phase = 180.0-m_array[i].phase;
            if (m_array[i].I1<0 && m_array[i].Q1<0) m_array[i].phase = 180.0+m_array[i].phase;
            if (m_array[i].I1>0 && m_array[i].Q1<0) m_array[i].phase = 360.0-m_array[i].phase;

         //
         //---
         //
                        
         m_array[i].deltaPhase = m_array[i-1].phase-m_array[i].phase;

         if (m_array[i-1].phase<90.0 && m_array[i].phase>270.0) m_array[i].deltaPhase = 360.0+m_array[i-1].phase-m_array[i].phase;
         if (m_array[i].deltaPhase>60.0) m_array[i].deltaPhase = 60.0;
         if (m_array[i].deltaPhase< 7.0) m_array[i].deltaPhase =  7.0;
      
         //
         //---
         //
         
         double phaseSum = m_array[i].deltaPhase; int k=1; for (; phaseSum<cyclesToReach && i>=k; k++) phaseSum += m_array[i-k].deltaPhase;
           m_array[i].period = m_array[i-1].period+filter*(k-m_array[i-1].period);
   return (m_array[i].period);
}