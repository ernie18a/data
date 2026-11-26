//+------------------------------------------------------------------+
//|                                       Export_MAE_MFE_Points.mq5  |
//+------------------------------------------------------------------+
#property script_show_inputs

input datetime InpStartDate = D'2026.01.01 00:00:00'; 

// Helper function: Price difference at an exact future time
string GetFutureExcursion(string sym, long pos_type, double open_price, datetime open_time, int add_seconds, double point_val)
  {
   datetime target_time = open_time + add_seconds;
   
   if(target_time > TimeCurrent()) return "n/a"; 
   
   double close_array[];
   if(CopyClose(sym, PERIOD_M1, target_time, 1, close_array) > 0)
     {
      double future_price = close_array[0];
      double diff_points = 0.0;
      
      if(pos_type == POSITION_TYPE_BUY)
         diff_points = (future_price - open_price) / point_val;
      else if(pos_type == POSITION_TYPE_SELL)
         diff_points = (open_price - future_price) / point_val;
         
      return DoubleToString(diff_points, 0); 
     }
     
   return "n/a";
  }

// Helper function: Maximum adverse excursion (worst drawdown) over a future window
string GetFutureMinExcursion(string sym, long pos_type, double open_price, datetime open_time, int add_seconds, double point_val)
  {
   datetime target_time = open_time + add_seconds;
   
   if(target_time > TimeCurrent()) return "n/a"; 
   
   double high_array[];
   double low_array[];
   
   if(CopyHigh(sym, PERIOD_M1, open_time, target_time, high_array) > 0 &&
      CopyLow(sym, PERIOD_M1, open_time, target_time, low_array) > 0)
     {
      double highest = high_array[ArrayMaximum(high_array)];
      double lowest  = low_array[ArrayMinimum(low_array)];
      double min_pts = 0.0;
      
      if(pos_type == POSITION_TYPE_BUY)
         min_pts = (lowest - open_price) / point_val;
      else if(pos_type == POSITION_TYPE_SELL)
         min_pts = (open_price - highest) / point_val;
         
      // If the lowest excursion is positive, cap it at 0 as requested
      if(min_pts > 0) min_pts = 0; 
      
      return DoubleToString(min_pts, 0);
     }
     
   return "n/a";
  }

void OnStart()
  {
   if(!HistorySelect(InpStartDate, TimeCurrent()))
     {
      Print("Error: Failed to load history!");
      return;
     }

   string file_name = "TradeHistory_Stats_Points.csv";
   int file_handle = FileOpen(file_name, FILE_WRITE|FILE_CSV|FILE_ANSI, ",");
   
   if(file_handle == INVALID_HANDLE)
     {
      Print("Error: Could not create file.");
      return;
     }

   // Updated Headers
   FileWrite(file_handle, "Position ID", "Symbol", "Type", "Open Time", "Close Time", "Duration (Hrs)", 
             "Open Price", "Close Price", "Profit ($)", "Profit (Pts)", "MAE (Pts)", "MFE (Pts)", 
             "T+30m (Pts)", "T+1h (Pts)", "T+4h (Pts)", "T+12h (Pts)", "T+1d (Pts)", "T+1w (Pts)", "T+1w MIN (Pts)");

   int total_deals = HistoryDealsTotal();
   Print("Scanning historical deals...");
   
   for(int i = 0; i < total_deals; i++)
     {
      ulong out_ticket = HistoryDealGetTicket(i);
      if(out_ticket == 0) continue;

      if(HistoryDealGetInteger(out_ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
        {
         ulong pos_id       = HistoryDealGetInteger(out_ticket, DEAL_POSITION_ID);
         string symbol      = HistoryDealGetString(out_ticket, DEAL_SYMBOL);
         datetime close_time = (datetime)HistoryDealGetInteger(out_ticket, DEAL_TIME);
         double close_price = HistoryDealGetDouble(out_ticket, DEAL_PRICE);
         double profit_usd  = HistoryDealGetDouble(out_ticket, DEAL_PROFIT);
         
         double point_val   = SymbolInfoDouble(symbol, SYMBOL_POINT);
         if(point_val == 0) point_val = 0.00001; 
         
         datetime open_time = 0;
         double open_price = 0;
         long pos_type = -1; 
         
         for(int j = 0; j < total_deals; j++)
           {
            ulong in_ticket = HistoryDealGetTicket(j);
            if(HistoryDealGetInteger(in_ticket, DEAL_POSITION_ID) == pos_id && 
               HistoryDealGetInteger(in_ticket, DEAL_ENTRY) == DEAL_ENTRY_IN)
              {
               open_time = (datetime)HistoryDealGetInteger(in_ticket, DEAL_TIME);
               open_price = HistoryDealGetDouble(in_ticket, DEAL_PRICE);
               long deal_type = HistoryDealGetInteger(in_ticket, DEAL_TYPE); 
               
               if(deal_type == DEAL_TYPE_BUY) pos_type = POSITION_TYPE_BUY;
               else if(deal_type == DEAL_TYPE_SELL) pos_type = POSITION_TYPE_SELL;
               
               break; 
              }
           }
           
         if(open_time == 0 || pos_type == -1) continue; 
         
         // Calculate Profit in Points
         double profit_pts = 0.0;
         if(pos_type == POSITION_TYPE_BUY)       profit_pts = (close_price - open_price) / point_val;
         else if(pos_type == POSITION_TYPE_SELL) profit_pts = (open_price - close_price) / point_val;
         
         // Calculate MAE and MFE
         double mae_pts = 0.0;
         double mfe_pts = 0.0;
         
         double high_array[];
         double low_array[];
         ArraySetAsSeries(high_array, false);
         ArraySetAsSeries(low_array, false);
         
         if(CopyHigh(symbol, PERIOD_M1, open_time, close_time, high_array) > 0 && 
            CopyLow(symbol, PERIOD_M1, open_time, close_time, low_array) > 0)
           {
            double highest_high = high_array[ArrayMaximum(high_array)];
            double lowest_low = low_array[ArrayMinimum(low_array)];
            
            if(pos_type == POSITION_TYPE_BUY)
              {
               mfe_pts = (highest_high - open_price) / point_val;
               mae_pts = (lowest_low - open_price) / point_val;  
              }
            else if(pos_type == POSITION_TYPE_SELL)
              {
               mfe_pts = (open_price - lowest_low) / point_val;
               mae_pts = (open_price - highest_high) / point_val;
              }
           }
           
         // Calculate Duration in Hours
         double duration_hrs = (close_time - open_time) / 3600.0;
         string str_type = (pos_type == POSITION_TYPE_BUY) ? "Buy" : "Sell";
         
         // Calculate Forward Returns
         string t_30m = GetFutureExcursion(symbol, pos_type, open_price, open_time, 30*60, point_val);
         string t_1h  = GetFutureExcursion(symbol, pos_type, open_price, open_time, 60*60, point_val);
         string t_4h  = GetFutureExcursion(symbol, pos_type, open_price, open_time, 4*60*60, point_val);
         string t_12h = GetFutureExcursion(symbol, pos_type, open_price, open_time, 12*60*60, point_val);
         string t_1d  = GetFutureExcursion(symbol, pos_type, open_price, open_time, 24*60*60, point_val);
         string t_1w  = GetFutureExcursion(symbol, pos_type, open_price, open_time, 7*24*60*60, point_val);
         
         // Calculate T+1w MIN risk
         string t_1w_min = GetFutureMinExcursion(symbol, pos_type, open_price, open_time, 7*24*60*60, point_val);
         
         // Write to CSV
         FileWrite(file_handle, pos_id, symbol, str_type, 
                   TimeToString(open_time), TimeToString(close_time), DoubleToString(duration_hrs, 2), 
                   DoubleToString(open_price, 5), DoubleToString(close_price, 5), 
                   DoubleToString(profit_usd, 2), DoubleToString(profit_pts, 0), 
                   DoubleToString(mae_pts, 0), DoubleToString(mfe_pts, 0),
                   t_30m, t_1h, t_4h, t_12h, t_1d, t_1w, t_1w_min);
        }
     }
     
   FileClose(file_handle);
   Print("SUCCESS! Saved as TradeHistory_Stats_Points.csv in MQL5\\Files");
  }