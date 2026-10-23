//+------------------------------------------------------------------+
//|                                             Channel_creation.mq5 |
//|                                          Last update: 21.10.2018 |
//|                       Copyright 2018, Murilo Fregonesi Falleiros |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Murilo Fregonesi Falleiros."
#property version   "1.20"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plot Resistance
#property indicator_label1  "resistance"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- plot Support
#property indicator_label2  "support"
#property indicator_type2   DRAW_SECTION
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input int barsChannel = 200; // Channel creation length
input int barsMulti   = 5;   // Channel bars to peak/valley

//--- indicator buffers
double resiBuffer[];
double suppBuffer[];

//--- global variables
double priceExp = 0; // Expected price
double priceAct = 0; // Actual price
double m_res = 0;    // Channel resistance slope
double m_sup = 0;    // Channel support slopes
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,resiBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,suppBuffer,INDICATOR_DATA);

//--- Set empty value to not participate in drawing 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ArrayFree(resiBuffer); // Set free the dynamic buffers
   ArrayFree(suppBuffer);
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

   if(rates_total>prev_calculated) // Update to new bars
     {
      // Peaks and Valleys variables
      int    iPeak = 0,   iVall = 0;   // Counters
      double peakValue[], vallValue[]; // Values arrays
      int    peakIndex[], vallIndex[]; // Indexes arrays

      //--- Identify peaks and valleys
      int inBarsRange=rates_total-barsChannel+barsMulti; // Bars range init
      if(inBarsRange<0)
        {
         inBarsRange=0; // Zero as minimum value
        }

      for(int i=inBarsRange; i<(rates_total-barsMulti-1); i++)
        {
         // Try to find a local Maximum
         if(i==ArrayMaximum(high,i-barsMulti,2*barsMulti+1))
           {
            ArrayCopy(peakValue,high,iPeak,i,1);           // Save the Max value
            ArrayResize(peakIndex,ArraySize(peakValue),0); // Resize the index array
            peakIndex[iPeak] = i;                          // Save the index
            iPeak++;                                       // Update the counter
           }

         // Try to find a local Minimum
         if(i==ArrayMinimum(low,i-barsMulti,2*barsMulti+1))
           {
            ArrayCopy(vallValue,low,iVall,i,1);            // Save the Min value
            ArrayResize(vallIndex,ArraySize(vallValue),0); // Resize the index array
            vallIndex[iVall] = i;                          // Save the index
            iVall++;                                       // Update the counter
           }
        }

      //--- Evaluation of the R/S slopes
      if(iPeak>1) // Resistance found
        {
         // Resistance slope at right pivot
         m_res=(peakValue[iPeak-1]-peakValue[iPeak-2])/(peakIndex[iPeak-1]-peakIndex[iPeak-2]);

         if(iPeak>2) // Check the position of the other peaks
           {
            for(int i=iPeak-3; i>=0; i--) // From right to left
              {
               // Compare the peak with the resistance values
               priceAct = peakValue[i];
               priceExp = peakValue[iPeak-1] - m_res*(peakIndex[iPeak-1] - peakIndex[i]);

               if(priceExp<priceAct) // If the first slope is not enough
                 {
                  // Update the slope to include the peak
                  m_res=(peakValue[iPeak-1]-peakValue[i])/(peakIndex[iPeak-1]-peakIndex[i]);
                 }
              }
           }
        }

      if(iVall>1) // Support found
        {
         // Support slope at right pivot
         m_sup=(vallValue[iVall-1]-vallValue[iVall-2])/(vallIndex[iVall-1]-vallIndex[iVall-2]);

         if(iVall>2) // Check the position of the other valleys
           {
            for(int i=(iVall-3); i>=0; i--) // From right to left
              {
               // Compare the valley with the support values
               priceAct = vallValue[i];
               priceExp = vallValue[iVall-1] - m_sup*(vallIndex[iVall-1] - vallIndex[i]);

               if(priceExp>priceAct) // If the first slope is not enough
                 {
                  // Update the slope to include the valley
                  m_sup=(vallValue[iVall-1]-vallValue[i])/(vallIndex[iVall-1]-vallIndex[i]);
                 }
              }
           }
        }

      //--- Update the buffers for channel representation
      if(iPeak>1)
        {
         resiBuffer[peakIndex[iPeak-1]]=peakValue[iPeak-1]; // Right pivot point

                                                            // Update the buffer via line model to the left (Resistance line)
         int leftLim=peakIndex[iPeak-1]-1-barsChannel*2;
         if(leftLim<0)
           {
            leftLim=0; // Chart boundary
           }

         for(int i=peakIndex[iPeak-1]-1; i>leftLim; i--)
           {
            resiBuffer[i]=peakValue[iPeak-1]-m_res*(peakIndex[iPeak-1]-i);
           }

         // Update the buffer via line model to the Right
         for(int i=peakIndex[iPeak-1]+1; i<rates_total; i++)
           {
            resiBuffer[i]=m_res*(i-peakIndex[iPeak-1])+peakValue[iPeak-1];
           }
        }

      if(iVall>1)
        {
         suppBuffer[vallIndex[iVall-1]]=vallValue[iVall-1]; // Right pivot point

                                                            // Update the buffer via line model to the left (Support line)
         int leftLim=vallIndex[iVall-1]-1-barsChannel*2;
         if(leftLim<0)
           {
            leftLim=0; // Chart boundary
           }

         for(int i=vallIndex[iVall-1]-1; i>leftLim; i--)
           {
            suppBuffer[i]=vallValue[iVall-1]-m_sup*(vallIndex[iVall-1]-i);
           }

         // Update the buffer via line model to the Right
         for(int i=vallIndex[iVall-1]+1; i<rates_total; i++)
           {
            suppBuffer[i]=m_sup*(i-vallIndex[iVall-1])+vallValue[iVall-1];
           }
        }

      // Remove past data from drawing
      for(int i=rates_total-barsChannel; i>=0; i--)
        {
         resiBuffer[i] = 0;
         suppBuffer[i] = 0;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
