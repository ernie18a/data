//---
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   2
//---
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Orange
#property indicator_color4 Turquoise
#property indicator_color5 Lime
#property indicator_color6 Brown
#property indicator_color7 Gray
#property indicator_color8 Yellow
#property indicator_label1 "EUR"
#property indicator_label2 "GBP"
#property indicator_label3 "AUD"
#property indicator_label4 "NZD"
#property indicator_label5 "USD"
#property indicator_label6 "CAD"
#property indicator_label7 "CHF"
#property indicator_label8 "JPY"
//---
#property indicator_level1 0.0
//+------------------------------------------------------------------+
//--- input variables
input int      inp_ma_period        = 50;    // strenght accumulation period
input int      inp_ma_delta         = 1;     // delta
input int      inp_atr_period       = 20;    // atr period
input double   inp_atr_coefficient  = 1;     // atr delta

bool ShowEUR=false;
bool ShowGBP=false;
bool ShowAUD=false;
bool ShowNZD=false;
bool ShowUSD=false;
bool ShowCAD=false;
bool ShowCHF=false;
bool ShowJPY=false;
//+------------------------------------------------------------------+
//--- indicator buffers for drawing
double    EURx[], // indexes
          GBPx[],
          AUDx[],
          NZDx[],
          USDx[],
          CADx[],
          CHFx[],
          JPYx[];

double   ext_arrow_up[];
double   ext_arrow_dn[];
double   ext_trend[];
//--- currency rates for calculation
double EUR,GBP,AUD,NZD,USD,CAD,CHF,JPY,A1,A2,A3,A4,A5,A6,A7;

//--- Currency names and colors
string Currencies[]= {"EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY"};

//--- Class of the "Moving Average" indicator
#include <Indicators\Trend.mqh>
CiMA ma[28];
//---
string symbols[28] =
  {
   "AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY",
   "CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD",
   "EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD",
   "NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"
  };
#define AUDCAD 0
#define AUDCHF 1
#define AUDJPY 2
#define AUDNZD 3
#define AUDUSD 4
#define CADCHF 5
#define CADJPY 6
#define CHFJPY 7
#define EURAUD 8
#define EURCAD 9
#define EURCHF 10
#define EURGBP 11
#define EURJPY 12
#define EURNZD 13
#define EURUSD 14
#define GBPAUD 15
#define GBPCAD 16
#define GBPCHF 17
#define GBPJPY 18
#define GBPNZD 19
#define GBPUSD 20
#define NZDCAD 21
#define NZDCHF 22
#define NZDJPY 23
#define NZDUSD 24
#define USDCAD 26
#define USDCHF 26
#define USDJPY 27

short chart_currency_index[2];
int   handle_atr;

bool init_status = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check indexest
   ArrayInitialize(chart_currency_index,-1);
   string symbol_name_clean = StringSubstr(_Symbol,0,6);
   string symbol_name_part[2];
   symbol_name_part[0] = StringSubstr(symbol_name_clean,0,3);
   symbol_name_part[1] = StringSubstr(symbol_name_clean,3,3);
   
   for(short c=0;c<ArraySize(Currencies);c++) {
      for(int p=0;p<2;p++) {
         if(Currencies[c] != symbol_name_part[p])
            continue;
         chart_currency_index[p] = c;
         switch(c) {
            case 0: ShowEUR = true; break;
            case 1: ShowGBP = true; break;
            case 2: ShowAUD = true; break;
            case 3: ShowNZD = true; break;
            case 4: ShowUSD = true; break;
            case 5: ShowCAD = true; break;
            case 6: ShowCHF = true; break;
            case 7: ShowJPY = true; break;
         }
      }
   }
   if(chart_currency_index[0] <0 || chart_currency_index[1]<0) {
      Print(__FUNCTION__," wrong symbol");
      init_status = false;
   }
  
//--- atr handle
   handle_atr = iATR(NULL,PERIOD_CURRENT,inp_atr_period);
   if(handle_atr == INVALID_HANDLE) {
      Alert("Can't get atr handle");
      return(INIT_FAILED);
   }
//--- set name to be displayed
   string ShortName="Currency Strength Index CSI("+(string)inp_ma_period+"/"+(string)inp_ma_delta+") >>";
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);

//--- assignment of array to indicator buffer
   SetIndexBuffer(0,ext_arrow_up,INDICATOR_DATA);
   SetIndexBuffer(1,ext_arrow_dn,INDICATOR_DATA);
   SetIndexBuffer(2,ext_trend,INDICATOR_DATA);

   SetIndexBuffer(3,EURx,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,GBPx,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,AUDx,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,NZDx,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,USDx,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,CADx,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,CHFx,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,JPYx,INDICATOR_CALCULATIONS);

//--- set up indicator buffers
/*
   for(int i=0; i < ArraySize(Currencies); i++)
     {
      PlotIndexSetInteger(i,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(i,PLOT_LINE_STYLE,STYLE_SOLID);
      PlotIndexSetInteger(i,PLOT_LINE_WIDTH,1);
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0);
      PlotIndexSetString(i,PLOT_LABEL,Currencies[i]);
     }
*/
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_ARROW);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,2);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetString(0,PLOT_LABEL,"Arrow up");
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_ARROW);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,2);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetString(1,PLOT_LABEL,"Arrow down");
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   
//--- set AsSeries
   ArraySetAsSeries(EURx,true);
   ArraySetAsSeries(GBPx,true);
   ArraySetAsSeries(AUDx,true);
   ArraySetAsSeries(NZDx,true);
   ArraySetAsSeries(USDx,true);
   ArraySetAsSeries(CADx,true);
   ArraySetAsSeries(CHFx,true);
   ArraySetAsSeries(JPYx,true);

   ArraySetAsSeries(ext_arrow_up,true);
   ArraySetAsSeries(ext_arrow_dn,true);
   ArraySetAsSeries(ext_trend,true);


//---
   if(!CreateHandles())
      //--- the indicator is stopped early
      return(INIT_FAILED);

//--- normal initialization of the indicator
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete all objects we created
   ObjectsDeleteAll(0,"obj_csi_");
  }
//+-------------------------------------------------------------------+
//| Create handles of the moving average indicators                   |
//+-------------------------------------------------------------------+
bool CreateHandles()
  {
//--- symbol suffix of the current chart symbol
   string SymbolSuffix=StringSubstr(Symbol(),6,StringLen(Symbol())-6);

//--- create handles of the indicator
   for(int i=0; i < ArraySize(symbols); i++)
     {
      string symbol=symbols[i]+SymbolSuffix;
      //---
      if(!CheckMarketWatch(symbol))
        {
         //--- if symbol is not in the market watch
         return(false);
        }
      //---
      if(!ma[i].Create(symbol,PERIOD_CURRENT,inp_ma_period,0,MODE_LWMA,PRICE_CLOSE))
        {
         //--- if the handle is not created
         Print(__FUNCTION__,
               ": failed to create handle of iMA indicator for symbol ",symbol);
         return(false);
        }
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Checks if symbol is selected in the MarketWatch                  |
//| and adds symbol to the MarketWatch, if necessary                 |
//+------------------------------------------------------------------+
bool CheckMarketWatch(string symbol)
  {
//--- check if symbol is selected in the MarketWatch
   if(!SymbolInfoInteger(symbol,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL)
        {
         printf(__FUNCTION__+": Unknown symbol '%s'",symbol);
         return(false);
        }
      if(!SymbolSelect(symbol,true))
        {
         printf(__FUNCTION__+": Error adding symbol %d",GetLastError());
         return(false);
        }
     }
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Checks terminal history for specified symbol's timeframe and     |
//| downloads it from server, if necessary                           |
//+------------------------------------------------------------------+
void CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,const int size)
  {
//--- ask for built bars
   if(Bars(symbol,period)<size)
     {
      //--- copying of next part forces data loading
      datetime times[1];
      CopyTime(symbol,period,size-1,1,times);
     }
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
  if(!init_status) return(rates_total);
  
//--- the necessary amount of data to be calculated
   int limit=rates_total;
//---
   for(int i=0; i < ArraySize(ma); i++)
     {
      //--- check if all data is calculated
      if(ma[i].BarsCalculated()<0)
        {
         Print(__FUNCTION__+": ",symbols[i]," not ready.");
         CheckLoadHistory(symbols[i],PERIOD_CURRENT,100);
         return(0);
        }
      //--- update the ma indicator data
      ma[i].Refresh();

      //--- the amount of calculated data for the ma indicator
      limit=(int)MathMin(limit,ma[i].BarsCalculated());
     }

//--- checking for the first start of the indicator calculation
   if(prev_calculated>rates_total || prev_calculated<=0)
     {
      limit=limit-inp_ma_delta;
     }
   else
      limit=rates_total-prev_calculated+1;

//--- https://www.tradingview.com/chart/GBPUSD/CjY0z8cG-Trading-the-STRONG-against-the-weak-currency-strength-calc/
//--- https://www.mql5.com/en/articles/83
//--- http://fxcorrelator.wixsite.com/nvp100
   for(int i=0; i<limit; i++)
     {
      if(ShowEUR)
        {
         A1=ma[EURGBP].Main(i)/ma[EURGBP].Main(i+inp_ma_delta);  //EURGBP
         A2=ma[EURAUD].Main(i)/ma[EURAUD].Main(i+inp_ma_delta);  //EURAUD
         A3=ma[EURNZD].Main(i)/ma[EURNZD].Main(i+inp_ma_delta);  //EURNZD
         A4=ma[EURUSD].Main(i)/ma[EURUSD].Main(i+inp_ma_delta);  //EURUSD
         A5=ma[EURCAD].Main(i)/ma[EURCAD].Main(i+inp_ma_delta);  //EURCAD
         A6=ma[EURCHF].Main(i)/ma[EURCHF].Main(i+inp_ma_delta);  //EURCHF
         A7=ma[EURJPY].Main(i)/ma[EURJPY].Main(i+inp_ma_delta);  //EURJPY
         EUR=(A1*A2*A3*A4*A5*A6*A7)-1;

         EURx[i]=EUR;
        }

      if(ShowGBP)
        {
         A1=ma[EURGBP].Main(i)/ma[EURGBP].Main(i+inp_ma_delta);  //EURGBP*
         A2=ma[GBPAUD].Main(i)/ma[GBPAUD].Main(i+inp_ma_delta);  //GBPAUD
         A3=ma[GBPNZD].Main(i)/ma[GBPNZD].Main(i+inp_ma_delta);  //GBPNZD
         A4=ma[GBPUSD].Main(i)/ma[GBPUSD].Main(i+inp_ma_delta);  //GBPUSD
         A5=ma[GBPCAD].Main(i)/ma[GBPCAD].Main(i+inp_ma_delta);  //GBPCAD
         A6=ma[GBPCHF].Main(i)/ma[GBPCHF].Main(i+inp_ma_delta);  //GBPCHF
         A7=ma[GBPJPY].Main(i)/ma[GBPJPY].Main(i+inp_ma_delta);  //GBPJPY
         GBP=(1/A1*A2*A3*A4*A5*A6*A7)-1;

         GBPx[i]=GBP;
        }

      if(ShowAUD)
        {
         A1=ma[EURAUD].Main(i)/ma[EURAUD].Main(i+inp_ma_delta);  //EURAUD*
         A2=ma[GBPAUD].Main(i)/ma[GBPAUD].Main(i+inp_ma_delta);  //GBPAUD*
         A3=ma[AUDNZD].Main(i)/ma[AUDNZD].Main(i+inp_ma_delta);  //AUDNZD
         A4=ma[AUDUSD].Main(i)/ma[AUDUSD].Main(i+inp_ma_delta);  //AUDUSD
         A5=ma[AUDCAD].Main(i)/ma[AUDCAD].Main(i+inp_ma_delta);  //AUDCAD
         A6=ma[AUDCHF].Main(i)/ma[AUDCHF].Main(i+inp_ma_delta);  //AUDCHF
         A7=ma[AUDJPY].Main(i)/ma[AUDJPY].Main(i+inp_ma_delta);  //AUDJPY
         AUD=(1/A1*1/A2*A3*A4*A5*A6*A7)-1;

         AUDx[i]=AUD;
        }

      if(ShowNZD)
        {
         A1=ma[EURNZD].Main(i)/ma[EURNZD].Main(i+inp_ma_delta);  //EURNZD*
         A2=ma[GBPNZD].Main(i)/ma[GBPNZD].Main(i+inp_ma_delta);  //GBPNZD*
         A3=ma[AUDNZD].Main(i)/ma[AUDNZD].Main(i+inp_ma_delta);  //AUDNZD*
         A4=ma[NZDUSD].Main(i)/ma[NZDUSD].Main(i+inp_ma_delta);  //NZDUSD
         A5=ma[NZDCAD].Main(i)/ma[NZDCAD].Main(i+inp_ma_delta);  //NZDCAD
         A6=ma[NZDCHF].Main(i)/ma[NZDCHF].Main(i+inp_ma_delta);  //NZDCHF
         A7=ma[NZDJPY].Main(i)/ma[NZDJPY].Main(i+inp_ma_delta);  //NZDJPY
         NZD=(1/A1*1/A2*1/A3*A4*A5*A6*A7)-1;

         NZDx[i]=NZD;
        }

      if(ShowUSD)
        {
         A1=ma[EURUSD].Main(i)/ma[EURUSD].Main(i+inp_ma_delta);  //EURUSD*
         A2=ma[GBPUSD].Main(i)/ma[GBPUSD].Main(i+inp_ma_delta);  //GBPUSD*
         A3=ma[AUDUSD].Main(i)/ma[AUDUSD].Main(i+inp_ma_delta);  //AUDUSD*
         A4=ma[NZDUSD].Main(i)/ma[NZDUSD].Main(i+inp_ma_delta);  //NZDUSD*
         A5=ma[USDCAD].Main(i)/ma[USDCAD].Main(i+inp_ma_delta);  //USDCAD
         A6=ma[USDCHF].Main(i)/ma[USDCHF].Main(i+inp_ma_delta);  //USDCHF
         A7=ma[USDJPY].Main(i)/ma[USDJPY].Main(i+inp_ma_delta);  //USDJPY
         USD=(1/A1*1/A2*1/A3*1/A4*A5*A6*A7)-1;

         USDx[i]=USD;
        }

      if(ShowCAD)
        {
         A1=ma[EURCAD].Main(i)/ma[EURCAD].Main(i+inp_ma_delta);  //EURCAD*
         A2=ma[GBPCAD].Main(i)/ma[GBPCAD].Main(i+inp_ma_delta);  //GBPCAD*
         A3=ma[AUDCAD].Main(i)/ma[AUDCAD].Main(i+inp_ma_delta);  //AUDCAD*
         A4=ma[NZDCAD].Main(i)/ma[NZDCAD].Main(i+inp_ma_delta);  //NZDCAD*
         A5=ma[USDCAD].Main(i)/ma[USDCAD].Main(i+inp_ma_delta);  //USDCAD*
         A6=ma[CADCHF].Main(i)/ma[CADCHF].Main(i+inp_ma_delta);  //CADCHF
         A7=ma[CADJPY].Main(i)/ma[CADJPY].Main(i+inp_ma_delta);  //CADJPY
         CAD=(1/A1*1/A2*1/A3*1/A4*1/A5*A6*A7)-1;

         CADx[i]=CAD;
        }

      if(ShowCHF)
        {
         A1=ma[EURCHF].Main(i)/ma[EURCHF].Main(i+inp_ma_delta);  //EURCHF*
         A2=ma[GBPCHF].Main(i)/ma[GBPCHF].Main(i+inp_ma_delta);  //GBPCHF*
         A3=ma[AUDCHF].Main(i)/ma[AUDCHF].Main(i+inp_ma_delta);  //AUDCHF*
         A4=ma[NZDCHF].Main(i)/ma[NZDCHF].Main(i+inp_ma_delta);  //NZDCHF*
         A5=ma[USDCHF].Main(i)/ma[USDCHF].Main(i+inp_ma_delta);  //USDCHF*
         A6=ma[CADCHF].Main(i)/ma[CADCHF].Main(i+inp_ma_delta);  //CADCHF*
         A7=ma[CHFJPY].Main(i)/ma[CHFJPY].Main(i+inp_ma_delta);  //CHFJPY
         CHF=(1/A1*1/A2*1/A3*1/A4*1/A5*1/A6*A7)-1;

         CHFx[i]=CHF;
        }

      if(ShowJPY)
        {
         A1=ma[EURJPY].Main(i)/ma[EURJPY].Main(i+inp_ma_delta);  //EURJPY*
         A2=ma[GBPJPY].Main(i)/ma[GBPJPY].Main(i+inp_ma_delta);  //GBPJPY*
         A3=ma[AUDJPY].Main(i)/ma[AUDJPY].Main(i+inp_ma_delta);  //AUDJPY*
         A4=ma[NZDJPY].Main(i)/ma[NZDJPY].Main(i+inp_ma_delta);  //NZDJPY*
         A5=ma[USDJPY].Main(i)/ma[USDJPY].Main(i+inp_ma_delta);  //USDJPY*
         A6=ma[CADJPY].Main(i)/ma[CADJPY].Main(i+inp_ma_delta);  //CADJPY*
         A7=ma[CHFJPY].Main(i)/ma[CHFJPY].Main(i+inp_ma_delta);  //CHFJPY*
         JPY=(1/A1*1/A2*1/A3*1/A4*1/A5*1/A6*1/A7)-1;

         JPYx[i]=JPY;
        }
     }

   for(int i=limit; i>0; i--) {
      double value_line[2][2];
      for(int c=0; c<2; c++) {
         switch( chart_currency_index[c] ) {
            case 0:
               value_line[c][0] = EURx[i+0];
               value_line[c][1] = EURx[i+1];
               break;
            case 1:
               value_line[c][0] = GBPx[i+0];
               value_line[c][1] = GBPx[i+1];
               break;
            case 2:
               value_line[c][0] = AUDx[i+0];
               value_line[c][1] = AUDx[i+1];
               break;
            case 3:
               value_line[c][0] = NZDx[i+0];
               value_line[c][1] = NZDx[i+1];
               break;
            case 4:
               value_line[c][0] = USDx[i+0];
               value_line[c][1] = USDx[i+1];
               break;
            case 5:
               value_line[c][0] = CADx[i+0];
               value_line[c][1] = CADx[i+1];
               break;
            case 6:
               value_line[c][0] = CHFx[i+0];
               value_line[c][1] = CHFx[i+1];
               break;
            case 7:
               value_line[c][0] = JPYx[i+0];
               value_line[c][1] = JPYx[i+1];
               break;
         }
      }        
   
      double atr_value[];
      CopyBuffer(handle_atr, 0, i, 1, atr_value);
      double line_shift = atr_value[0] * inp_atr_coefficient;
      
      ext_trend[i] = ext_trend[i+1];
      
      if(value_line[0][0] - value_line[1][0] > line_shift && value_line[0][1] - value_line[1][1] <= line_shift && ext_trend[i]!=1 ) {
         ext_arrow_up[i]   = iLow(NULL,PERIOD_CURRENT,i) - atr_value[0]/3;
         ext_trend[i]      = 1;
      }else{
         ext_arrow_up[i] = 0;
      }
         
      if(value_line[0][0] - value_line[1][0] < - line_shift && value_line[0][1] - value_line[1][1] >= -line_shift && ext_trend[i]!=-1) {
         ext_arrow_dn[i]   = iHigh(NULL,PERIOD_CURRENT,i) + atr_value[0]/3;
         ext_trend[i]      = -1;
      }else{
         ext_arrow_dn[i] = 0;
      }
        
   }
//--- return the prev_calculated value for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
