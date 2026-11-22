//+------------------------------------------------------------------+
//|                                                       NewsEA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Müller Peter"
#property link      "https://www.mql5.com/en/users/mullerp04/seller"
#property version   "1.00"

#include <Trade\Trade.mqh>  // Include the standard trade library for trading operations

// Define an enum to specify what the expert advisor (EA) should do
enum e_Type {
   Trading = 0,  // Place trades based on news events
   Alerting = 1  // Only alert about important news events
};

// Input parameters for the EA
input e_Type Type = Alerting;   // The mode of operation (Trading or Alerting)
input int Magic = 1125021;      // Magic number to identify EA orders (relevant in trading mode)
input int TPPoints = 150;       // Take profit in points (relevant in trading mode)
input int SLPoints = 150;       // Stop loss in points (relevant in trading mode)
input double Volume = 0.1;      // Volume of orders (relevant in trading mode)

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int OnInit()
{
   
   return(INIT_SUCCEEDED);  
}

//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Declare necessary variables
   MqlCalendarValue CalendarValues[];   // Array to hold calendar events
   MqlCalendarEvent CalendarEvent;      // Struct to hold specific event details
   MqlCalendarCountry CalendarCountry;  // Struct to hold country details

   // Static variables to maintain state between ticks
   static datetime LastRequest = TimeTradeServer(); // Last time news was fetched
   static CTrade trade;                             // Trade object for trading operations
   trade.SetExpertMagicNumber(Magic);               // Set the magic number for the EA's trades
   static datetime Expiry = 0;                      // Expiry time for pending orders

   // Retrieve calendar events from the last 50 seconds to the next 50 seconds
   CalendarValueHistory(CalendarValues, LastRequest, TimeTradeServer() + 50);

   // If new events are found, update the last request time
   if(ArraySize(CalendarValues) != 0)
      LastRequest = TimeTradeServer() + 50;

   // Loop through all retrieved events
   for(int i = 0; i < ArraySize(CalendarValues); i++)
   {
       // Fetch detailed information about the event and the country
       CalendarEventById(CalendarValues[i].event_id, CalendarEvent);
       CalendarCountryById(CalendarEvent.country_id, CalendarCountry);
       
       // Get the currency related to the event
       string currency = CalendarCountry.currency;

       // Check if the event is relevant to the current symbol
       if(currency == SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE) || 
          currency == SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT))
       {
         // If the event is high importance and the mode is Alerting, send an alert
         if(CalendarEvent.importance == CALENDAR_IMPORTANCE_MODERATE && Type == Alerting)
         {
            Alert("Upcoming important news event: " + CalendarEvent.name + 
                  " at " + TimeToString(CalendarValues[i].time));
         }

         // If the event relates to inflation or interest rate changes, place pending orders
         if((StringContains(CalendarEvent.name, "cpi") || 
            StringContains(CalendarEvent.name, "ppi") || 
            StringContains(CalendarEvent.name, "interest rate decision")) && Type == Trading)
         {
            // Skip if there are already active pending orders
            if(Expiry != 0)
               continue;

            // Retrieve current market prices
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

            // Set expiry time for pending orders
            Expiry = TimeTradeServer() + 500;

            // Place buy stop and sell stop orders around the current price
            trade.BuyStop(Volume, ask + TPPoints * _Point, NULL, 
                          ask + TPPoints * _Point - SLPoints * _Point, 
                          ask + 2 * TPPoints * _Point);

            trade.SellStop(Volume, bid - TPPoints * _Point, NULL, 
                           bid - TPPoints * _Point + SLPoints * _Point, 
                           bid - 2 * TPPoints * _Point);
         }
       }       
   }

   // Delete pending orders if they have expired
   if(TimeTradeServer() > Expiry && Expiry != 0)
   {
      Expiry = 0;
      DeletePending();
   }
}

//+------------------------------------------------------------------+
//| Function to delete pending orders                                |
//+------------------------------------------------------------------+
void DeletePending()
{
   COrderInfo ordinfo;  // Order information object
   CTrade trade;        // Trade object

   // Loop through all orders and delete those with the EA's magic number
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ordinfo.SelectByIndex(i);
      if(ordinfo.Magic() == Magic)
         trade.OrderDelete(ordinfo.Ticket());
   }
}

//+------------------------------------------------------------------+
//| Helper function to check if a string contains another string     |
//+------------------------------------------------------------------+
bool StringContains(string base, string containing, bool Cased = false)
{
   // If case-insensitive, convert both strings to lowercase
   if(!Cased)
   {
      StringToLower(base);
      StringToLower(containing);
   }

   int ct = 0; // Counter to track matching characters

   // Loop through the base string
   for(unsigned i = 0; i < base.Length(); i++)
   {
      if(base.GetChar(i) == containing.GetChar(ct))
         ct++;  // Increment counter if characters match
      else 
         ct = 0; // Reset counter if characters don't match

      // If the entire containing string matches, return true
      if(ct == containing.Length() - 1)
         return true;

      // If remaining base string is shorter than containing string, return false
      if(base.Length() - i < containing.Length() && !ct)
         return false;
   }
   return false; // Return false if no match is found
}
