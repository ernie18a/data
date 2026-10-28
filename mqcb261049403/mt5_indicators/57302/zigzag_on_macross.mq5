//+------------------------------------------------------------------+
//|                      Zigzag from crossovers                      |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 3

#property indicator_label1 "ZigZag"
#property indicator_type1  DRAW_COLOR_ZIGZAG
#property indicator_color1 clrLimeGreen, clrRed, clrLightGray
#property indicator_width1 2

#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_DOT
#property indicator_color2 clrGreen
#property indicator_width2 1

#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_DOT
#property indicator_color3 clrRed
#property indicator_width3 1

// Indicator buffers
double MA1Buffer[];
double MA2Buffer[];

double ZigZagBuffer1[];
double ZigZagBuffer2[];
double zag_color[];

// Parameters for the Moving Averages
input int MA1Period = 5; // Fast period (green)
input int MA2Period = 8; // Slow period (red)
input int Backstep = 3;   // Backstep
input bool alerts = false; // Alert on leg change

// Variables to track the last zigzag vertices
double LL = 0.0;
double HL = 0.0;
double LH = 0.0;
double HH = 0.0;

// Track the cycle
enum ZigZagState { 
NONE, 
LL_FOUND,
HL_FOUND, 
LH_FOUND, 
HH_FOUND 
};

ZigZagState currentState = NONE;
    
datetime lastAlertTime = TimeCurrent();

//+------------------------------------------------------------------+
//|   Calculate simple moving average                                |
//+------------------------------------------------------------------+
double CalculateSMA(const double &price[], int period, int index)
{
   double sum = 0.0;
   for(int j = 0; j < period; j++)
   {
      sum += price[index - j];
   }
   return sum / period;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, ZigZagBuffer1, INDICATOR_DATA);
   SetIndexBuffer(1, ZigZagBuffer2, INDICATOR_DATA);
   SetIndexBuffer(2, zag_color, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3, MA1Buffer, INDICATOR_DATA);
   SetIndexBuffer(4, MA2Buffer, INDICATOR_DATA);
   
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   
   return INIT_SUCCEEDED;
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
   int start = (prev_calculated == 0) ? MathMax(MA1Period, MA2Period) : prev_calculated;

   for(int i = start; i < rates_total; i++)
   {  
      int res = 0;
      
      ZigZagBuffer1[i] = EMPTY_VALUE;
      ZigZagBuffer2[i] = EMPTY_VALUE;
      
      MA1Buffer[i] = CalculateSMA(close, MA1Period, i);
      MA2Buffer[i] = CalculateSMA(close, MA2Period, i);

      bool bullishCrossover = (MA1Buffer[i - 1] < MA2Buffer[i]) && (MA1Buffer[i] > MA2Buffer[i - 1]);
      bool bearishCrossover = (MA1Buffer[i - 1] > MA2Buffer[i]) && (MA1Buffer[i] < MA2Buffer[i - 1]);
      
      datetime barOpenTime = time[i];      
      
      // Find the lowest high and highest low in the Backstep range (Number of bars to look back for confirmation)
      double High = high[i];
      double Low = low[i];
      
      for (int j = 1; j <= Backstep; j++) 
      {
         if (high[i - j] > High) High = high[i - j];
         if (low[i - j] < Low) Low = low[i - j];
      }
      
      if (currentState == NONE && bearishCrossover) 
      {
         LL = High; 
         ZigZagBuffer1[i] = LL; // Plot the LL
         currentState = LL_FOUND;
         zag_color[i] = 0; //green    
         res = 1;                
      }
      else if (currentState == LL_FOUND && bullishCrossover)
      {
         HL = Low; 
         ZigZagBuffer2[i] = HL; // Plot the HL
         currentState = HL_FOUND;
         zag_color[i] = 1; //red   
         res = 2;      
      }    
      else if (currentState == HL_FOUND && bearishCrossover)
      {
         LH = High; 
         ZigZagBuffer1[i] = LH; // Plot the LH
         currentState = LH_FOUND;
         zag_color[i] = 0; //green        
         res = 3;              
      }
      else if (currentState == LH_FOUND && bullishCrossover)
      {
         HH = Low; 
         ZigZagBuffer2[i] = HH; // Plot the HH
         currentState = HH_FOUND;
         zag_color[i] = 1; //red             
         res = 4;   
      }
      else if (currentState == HH_FOUND)
      {
         currentState = NONE; // repeat search from LL on the next bearish crossover           
      }
      
      // Remove invalid legs (from noisy MA cross)
      if (currentState == LL_FOUND && (LL < HL))  
      {
          zag_color[i] = 2.0; // paint invalid leg gray
      }  
      if (currentState == HH_FOUND && (HH > LH))  
      {
          zag_color[i] = 2.0; // paint invalid leg gray 
      }   
       
      if(alerts){        
         if(res == 1 || res == 2 || res == 3 || res == 4){
         
            if (lastAlertTime < barOpenTime) 
            {        
                Alert("Zigzag leg completed");
                lastAlertTime = time[i];
            }     
         }   
      }                    
   }
    

   return rates_total;
}
