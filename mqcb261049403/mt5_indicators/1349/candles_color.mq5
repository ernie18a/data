//+------------------------------------------------------------------------------+
//|                                                  candles  color              |
//|                                                             kourosh davallou |
//|                                                                              |
//+------------------------------------------------------------------------------+
#property copyright "kourosh1347@yahoo.com"    
        
#property indicator_chart_window   //Indicator in chart window              
#property  version "1.0"

#property indicator_buffers 6


#property indicator_label1 "Open;High;Low;Close"

#property indicator_plots 1     //Number of graphic plots                 
#property indicator_type1 DRAW_COLOR_CANDLES   //Drawing style color candles
#property indicator_width1 3       //Width of the graphic plot              
input int Start_Day=4;      // Starting Day for show 
input int Start_Hour=6;     // Starting Hour of day  
input int Start_Minute=0;   // Starting Minute of hour  
input int End_Day=4;        // End of Day 
input int End_Hour=20;      // End Hour of day
input int End_Minute=59;    // End Hour of day

input color Color_Bar_Up_1=clrPowderBlue;
input color Color_Bar_Down_1=clrBisque;
input color Color_Bar_Up_0=clrGreen;
input color Color_Bar_Down_0=clrRed;

//Declaration of buffers
double buf_open[],buf_high[],buf_low[],buf_close[];//Buffers for data
double buf_color_line[];  //Buffer for color indexes

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
  //Assign the arrays with the indicator's buffers
   SetIndexBuffer(0,buf_open,INDICATOR_DATA);
   SetIndexBuffer(1,buf_high,INDICATOR_DATA);
   SetIndexBuffer(2,buf_low,INDICATOR_DATA);
   SetIndexBuffer(3,buf_close,INDICATOR_DATA);

   SetIndexBuffer(4,buf_color_line,INDICATOR_COLOR_INDEX);
//Assign the array with color indexes with the indicator's color indexes buffer
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,4);
//Set color for each index
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,Color_Bar_Up_0);  // 0th index Color_Bar_Up_0
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Color_Bar_Down_0); // 1st index Color_Bar_Down_0
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,Color_Bar_Up_1);   // 2nd index Color_Bar_Up_1
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,3,Color_Bar_Down_1); // 3th index Color_Bar_Down_1

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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

   MqlDateTime time_now;  // define time struc
//In the loop we fill the data buffers and color indexes buffers for each bar
   for(int i=prev_calculated;i<=rates_total-1;i++)
     {
     //Set data for plotting
      buf_open[i]=open[i];
      buf_high[i]=high[i];
      buf_low[i]=low[i];
      buf_close[i]=close[i];

      datetime candle_time=time[i];

      TimeToStruct(time[i],time_now);  // change time to struct
     
      if((time_now.day_of_week>=Start_Day && time_now.hour>=Start_Hour && time_now.min>=Start_Minute)
         && (time_now.day_of_week<=End_Day && time_now.hour<=End_Hour && time_now.min<=End_Minute))
        {
        // if time between start day and end of day
         if(open[i]>=close[i])  //if open >= close set color index 3
            buf_color_line[i]=3;//Assign the bar with color index, equal to 3
         else
            buf_color_line[i]=2;//Assign the bar with color index, equal to 2
        }
          // if time isn't between start day and end of day
      else
        {
         if(open[i]>=close[i]) //if open >= close set color index 1
            buf_color_line[i]=1;//Assign the bar with color index, equal to 1
         else
            buf_color_line[i]=0;//Assign the bar with color index, equal to 0
        }

     }
   return(rates_total-1);
  }
//+------------------------------------------------------------------+
