//+------------------------------------------------------------------+
//|                                                Profit Labels.mq5 |
//+------------------------------------------------------------------+

#property copyright "phade"
#property link      "https://www.mql5.com/"
#property version   "2.00"

//--- Including the MQL5 trading library
#include <Trade/Trade.mqh>
#include <Canvas/Canvas.mqh> 

CTrade obj_Trade;
CCanvas canvas;

input group "Setup"
input int magic_number = 1; // EA Magic Number
input bool placingTrade = false; // Place dummy trades

input bool using_canvas = true; // Using canvas library
input bool using_standard_library = false; // Using standard library


input group "PnL Labels (adjustments for standard library objects)"
input double horz_scale = 10; // X-axis Scaling
input double vert_scale = 0.02; // Y-axis Scaling
input int font_size = 12; // Text font size

int ma_period = 6; // Period
bool start_of_trend = false; // Consider beginning of trend only

double TradeVolume = 0.1; // Manual lot


int sl_points = 200; // Stop loss points
int tp_points = 350; // Take profit points


int handleMA = INVALID_HANDLE;

double ma_val[];
double ma_trend[];

//--- Flags to track if the last trade was a buy or sell
bool isPrevTradeBuy = false, isPrevTradeSell = false;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   handleMA = iTEMA(_Symbol, _Period, ma_period, 0, PRICE_CLOSE);

   if(handleMA == INVALID_HANDLE)
     {
      Print("ERROR: UNABLE TO CREATE MA HANDLE. REVERTING");
      return (INIT_FAILED);
     }

   obj_Trade.SetExpertMagicNumber(magic_number);
   
   ArraySetAsSeries(ma_val, true);   
     
   return(INIT_SUCCEEDED);  //--- Initialization successful
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handleMA); //--- Release the indicator handle
  }
  


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {     
   const int start = 0;

   if(CopyBuffer(handleMA, 0, start, 5, ma_val) < 0)
     {
      Print("UNABLE TO GET REQUESTED DATA. REVERTING.");
     }

   double lotSize = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   
   //--- Get the timestamp of the current bar open time
   datetime currTimeBar = iTime(_Symbol, _Period, 0); 
   static datetime signalTime = currTimeBar;

   bool trendUp = false, trendDown = false;

   trendUp = ma_val[2] < ma_val[3] && ma_val[0] > ma_val[1];
   trendDown = ma_val[2] > ma_val[3] && ma_val[0] < ma_val[1];

   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    
   // Check margin before opening a trade
   if(freeMargin <= 0)
   {
      Print("Not enough free margin to open a trade. Free margin: ", freeMargin);
      return; 
   }   
   
   if(freeMargin > freeMargin*lotSize){
      // Place dummy trades
      if(placingTrade && PositionsTotal() == 0 && !isPrevTradeBuy)
        {
         if(trendUp && signalTime != currTimeBar)
           {
   
            obj_Trade.Buy(lotSize, _Symbol, Ask, Ask - sl_points * _Point, Ask + tp_points * _Point);
            isPrevTradeBuy = true;
            isPrevTradeSell = false;
            signalTime = currTimeBar;
           }
        }
   
   
      if(placingTrade && PositionsTotal() == 0 && !isPrevTradeSell)
        {
         if(trendDown && signalTime != currTimeBar)
           {
            obj_Trade.Sell(lotSize, _Symbol, Bid, Bid + sl_points * _Point, Bid - tp_points * _Point);
            isPrevTradeBuy = false;
            isPrevTradeSell = true;
            signalTime = currTimeBar;
           }
        }
     }
     
     // Display the profit label on the chart after the trades close
     examineLastTrade();
}



void examineLastTrade()
{
    static datetime timeOfLastTrade = TimeCurrent();

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong posTicket = PositionGetTicket(i);

        if (posTicket > 0)
        {
            timeOfLastTrade = (datetime)PositionGetInteger(POSITION_TIME); // Position open time
        }
    }

    if (!PositionSelect(Symbol()))
    {
        HistorySelect(timeOfLastTrade, TimeCurrent());

        for (int i = 0; i < HistoryDealsTotal(); i++)
        {
            ulong ticket = HistoryDealGetTicket(i);

            if (ticket > 0)
            {
                double dealProfit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                long dealTime = HistoryDealGetInteger(ticket, DEAL_TIME);
   
                
                if(using_canvas) DrawLabel(dealProfit, dealTime);
                if(using_standard_library) DisplayLabel(dealProfit, dealTime, ticket);            
            }
            else
            {
                Print("Failed to get ticket for index ", i);
            }
        }
    }
}




string GetCurrencySymbol(){

    string currency = AccountInfoString(ACCOUNT_CURRENCY);
    return (currency == "USD") ? "$" :
           (currency == "EUR") ? "€" :
           (currency == "GBP") ? "£" :
           (currency == "JPY") ? "¥" :
           (currency == "AUD") ? "A$" :
           (currency == "CAD") ? "C$" :
           (currency == "CHF") ? "CHF" :
           (currency == "CNY") ? "¥" :
           (currency == "HKD") ? "HK$" :
           (currency == "NZD") ? "NZ$" :
           (currency == "SEK") ? "kr" :
           (currency == "SGD") ? "S$" :
           (currency == "NOK") ? "kr" :
           (currency == "MXN") ? "Mex$" :
           (currency == "INR") ? "₹" :
           (currency == "RUB") ? "₽" :
           (currency == "BRL") ? "R$" :
           (currency == "ZAR") ? "R" :
           (currency == "TRY") ? "₺" :
           (currency == "KRW") ? "₩" :
           (currency == "THB") ? "฿" :
           (currency == "IDR") ? "Rp" :
           (currency == "MYR") ? "RM" :
           (currency == "PHP") ? "₱" :
           NULL; 
}



//Canvas library
void DrawLabel(double PnL, datetime time)
{

   int barIndex = iBarShift(_Symbol, _Period, time);    
   double pricePosition = iHigh(_Symbol, _Period, barIndex);
   datetime positionTime = iTime(_Symbol, _Period, barIndex);
   
   string labelText = GetCurrencySymbol() + DoubleToString(PnL, 2);
                
   string bitmapName = "LabelBitmap";

   canvas.CreateBitmap(bitmapName, positionTime, pricePosition, 60, 20, COLOR_FORMAT_ARGB_NORMALIZE);
   canvas.Erase(ColorToARGB(clrOrange, 255)); // Fill rectangle
   canvas.TextOut(1, 1, labelText, clrBlack); // Draw text on the object
   canvas.Update(true);
}



void DisplayLabel(double PnL, datetime time, ulong ticketNum){

    int barIndex = iBarShift(_Symbol, _Period, time);
    double pricePosition = (iHigh(_Symbol, _Period, barIndex) + iLow(_Symbol, _Period, barIndex))/2;
    datetime positionTime = iTime(_Symbol, _Period, barIndex);

    string price = GetCurrencySymbol() + DoubleToString(PnL, 2);

    double dynamic_offset = (ChartGetDouble(0, CHART_PRICE_MAX) - ChartGetDouble(0, CHART_PRICE_MIN)) * vert_scale;

    long scale = 0;  
    ChartGetInteger(0, CHART_SCALE, 0, scale);

    datetime adjustedTimeEnd = (datetime)(positionTime + (horz_scale * scale * PeriodSeconds()) + (20 * PeriodSeconds()));
    
    double priceMax = pricePosition + dynamic_offset;
    double priceMin = pricePosition - dynamic_offset;

    LabelObject(0, "label" + IntegerToString(ticketNum), positionTime, adjustedTimeEnd, priceMax, priceMin);
    TextField(0, "deal_profit" + IntegerToString(ticketNum), price, pricePosition + dynamic_offset, font_size, clrBlack, positionTime);
}


//Standard library
void TextField(int id, string textObj, string text, double distance, int fontSize, color fontColor, datetime time){

    if (ObjectFind(0, textObj) < 0){
    
      ObjectCreate(id, textObj, OBJ_TEXT, 0, time, distance);
    } 
 
    ObjectSetInteger(id, textObj, OBJPROP_CORNER, 0);
    ObjectSetInteger(id, textObj, OBJPROP_FONTSIZE, fontSize);
    ObjectSetInteger(id, textObj, OBJPROP_COLOR, fontColor);
    ObjectSetString(id, textObj, OBJPROP_TEXT, text);
}


void LabelObject(int id, string labelObj, datetime timeStart, datetime timeEnd, double priceMax, double priceMin){
    
   if (ObjectFind(id, labelObj) < 0){
    
      ObjectCreate(id, labelObj, OBJ_RECTANGLE, 0, timeStart, priceMax, timeEnd, priceMin);
   }
   
   ObjectSetInteger(id, labelObj, OBJPROP_COLOR, clrOrange); // label color
   ObjectSetInteger(id, labelObj, OBJPROP_FILL, true);
   ObjectSetInteger(id, labelObj, OBJPROP_BACK, false);
}
