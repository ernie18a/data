//+------------------------------------------------------------------+
//| Price Alerts.mq5                                                 |
//| Copyright phade 2024, MetaQuotes Ltd.                            |
//| https://forge.mql5.io                                            |
//+------------------------------------------------------------------+
#property copyright "Copyright phade 2024, MetaQuotes Ltd."
#property link "https://forge.mql5.io"
#property version "1.03"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 1

#property indicator_label1 "PRICE ALERT"
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrLightBlue

#define KEY_UP 38

enum AlertType{
    email = 2, // Email
    mobile = 1, // Mobile Notification
    normal = 0 // Basic Alert
};
input AlertType type = 0; // Type of alert
bool isMouseClicked = false;

double price_buf[];
double arrow_buf[];

double alert_price = EMPTY_VALUE;
datetime alert_time = 0;
int aboveMarket = -1;
int completedProcess = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, arrow_buf, INDICATOR_DATA);  
   SetIndexBuffer(1, price_buf, INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0, PLOT_ARROW, 214);

   return INIT_SUCCEEDED;
}
     
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
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
                const int &spread[]){
                     
      int limit;

      if(prev_calculated == 0){
         limit = 0;
         ArrayInitialize(price_buf, 0.0);
      }
      else{
         limit = prev_calculated - 1;
      }
      
      if(alert_price != EMPTY_VALUE && alert_time != 0){
      
         int pos = -1;
         for(int i = limit; i < rates_total; i++){
            if(time[i] == alert_time){
               pos = i;
               break;
            }
         }
         if(pos != -1){
            price_buf[pos] = alert_price;
         }
      }
     
      if (alert_price != 0.0 && alert_price != EMPTY_VALUE){
      
           int current = rates_total-1;
     
           double currentPrice = close[current];
     
           // Compare the current market price with the threshold
           if (currentPrice > alert_price && aboveMarket == 1 && completedProcess != 1){
                 
               string alertMessage = (string)_Symbol + ": " + "Market moved up past the price alert threshold at the price level: " + DoubleToString(currentPrice, _Digits);
                   
               if(type == 0) Alert(alertMessage);
               else if(type == 1) SendNotification(alertMessage);
               else if(type == 2) SendMail("Price Alert for " + (string)_Symbol, alertMessage);
               completedProcess = 1;
           }
           else if (currentPrice < alert_price && aboveMarket == 0 && completedProcess != 1){
             
               string alertMessage = (string)_Symbol + ": " + "Market moved down past the price alert threshold at the level: " + DoubleToString(currentPrice, _Digits);
                         
               if(type == 0) Alert(alertMessage);
               else if(type == 1) SendNotification(alertMessage);
               else if(type == 2) SendMail("Price Alert for " + (string)_Symbol, alertMessage);
               completedProcess = 1;
           }
      }
      return rates_total;
  }


void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam){
                   
      if(id == CHARTEVENT_KEYDOWN){
     
         if((int)lparam == KEY_UP){
     
            isMouseClicked = false; // alert can be altered when the keyboard up arrow key is pressed
            completedProcess = 0;
            alert_price = EMPTY_VALUE;
            alert_time = 0;
            aboveMarket = -1;
            Comment("");
         }
      }
           
      if (id == CHARTEVENT_CLICK && !isMouseClicked){
     
            datetime tm;
            double pr;
            int sub_window;
            
            if(!ChartXYToTimePrice(0, (int)lparam, (int)dparam, sub_window, tm, pr)){
               return;
            }
            
            alert_time = tm;
            alert_price = pr;
            
            double cl[1];
            if(CopyClose(_Symbol, _Period, 0, 1, cl) < 1){
               Print("CopyClose failed");
               return;
            }
            aboveMarket = (alert_price > cl[0]) ? 1 : (alert_price < cl[0]) ? 0 : -1;
            
            datetime currentTime = TimeCurrent();
            string formattedTime = TimeToString(currentTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
                     
            Print("Created an alert on " + (string)_Symbol + " at price: " + DoubleToString(alert_price, _Digits) + " " + formattedTime);
            Comment("ALERT AT PRICE: ", NormalizeDouble(alert_price, 5));
            arrow_buf[Bars(_Symbol, _Period)-1] = alert_price;
                                     
            isMouseClicked = true; // lock the alert in place
       }
}

void OnDeinit(const int reason){

  Comment("");
}