//+------------------------------------------------------------------+
//|                                              BabiNgepet.mq5      |
//|                                              Copyright zvickyhac |
//+------------------------------------------------------------------+
#property copyright "zvickyhac"
#property version   "1.00"
#property description "Babi Ngepet - Martingale Scalping"
#include <Trade\Trade.mqh>
CTrade trade;
input string  section0 = "General Parameters";
input int     MagicNumber           = 9191; 
input double  InitialLot            = 0.03;
input string  InitialLotHidden      = "Current Lot is 0.03";
input bool    AllowBuy              = true; 
input bool    AllowSell             = true;
input int     TakeProfit            = 15;
input int     FindHighLowBackBars   = 12; 
input int     ResetAfterBars        = 20;

input string  section1 = "Martingale Strategy";
input bool    ReverseMartingale = false;
input double  LotMultiplier = 2.0;         
input double  SecureProfitMartingaleTarget = 20.0;    
input int     DistanceMartingalePips = 28;                                           
input int     MaxTradesInSeries = 8;

input string  section2 = "Time Strategy";    
input bool    AllowMonday    = true; 
input bool    AllowTuesday   = true;
input bool    AllowWednesday = true;
input bool    AllowThursday  = true;
input bool    AllowFriday    = true; 
input string  ForbiddenDates = "2024.01.10,2024.02.28";

//--- Global Parameters ---
static double s_currentLot = 0.0;
static double s_lastOpenPrice = 0.0;
static ENUM_POSITION_TYPE s_seriesType = (ENUM_POSITION_TYPE)0;
static int    s_totalTradesInSeries = 0;
static int s_negativeFloatingCount = 0; 
double close_prices[];
int LookbackBars    = 200;
double BufferPipsForStopLevels = 10;
static bool s_firstTradeOpened = false;
int barsCount = 0;

//+------------------------------------------------------------------+
//| Fungsi inisialisasi Expert Advisor                               |
//+------------------------------------------------------------------+
int OnInit()
{          
    trade.SetExpertMagicNumber(MagicNumber);
    trade.SetMarginMode();      
    trade.SetDeviationInPoints(10);  
    
    // Inisialisasi status Martingale saat EA dimulai
    s_currentLot = InitialLot;
    s_lastOpenPrice = 0.0;
    s_seriesType = (ENUM_POSITION_TYPE)0; // Tidak ada arah yang ditentukan pada awalnya
    s_totalTradesInSeries = 0;
    barsCount = 0;
           
    Print("Babi Ngepet initialized!");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{    
    Print("Babi Ngepet deinitialized!");
}
//+------------------------------------------------------------------+
//| Load Close Prices                                                |
//+------------------------------------------------------------------+
bool LoadClosePrices()
{
   ArrayResize(close_prices, LookbackBars);
   if(CopyClose(_Symbol, _Period, 0, LookbackBars, close_prices) <= 0)
   {
      Print("Failed to load Close prices");
      return false;
   }
   ArraySetAsSeries(close_prices, true);
   return true;
}
//+------------------------------------------------------------------+
//| Check if Not enough money                                        |
//+------------------------------------------------------------------+
bool CheckMargin(double lotSize)
{
    // Hitung margin yang diperlukan untuk 1 lot
    double marginRequired;
    if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lotSize, SymbolInfoDouble(_Symbol, SYMBOL_ASK), marginRequired))
    {
        //Print("Failed to calculate margin!");
        return false;
    }
    
    double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    
    if(marginRequired > freeMargin)
    {
        //Print("Not enough margin! Required: ", marginRequired, ", Free: ", freeMargin);
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Fungsi instant membuka trade                                     |
//+------------------------------------------------------------------+
void OpenTradeLogic(ENUM_ORDER_TYPE type, string tradeComment)
{
    // Normalisasi lot ke langkah volume yang benar yang diizinkan oleh broker
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);    

    if (s_currentLot > maxLot)
    {
        s_currentLot = maxLot;
        //Print("Warning: Volume exceeds broker's maximum limit. Adjusted to ", DoubleToString(s_currentLot, 2));
        return;
    }

    if (s_currentLot < minLot)
    {
        //Print("Error: Final volume is less than the minimum allowed volume: ", DoubleToString(s_currentLot, 2));
        return;
    }
    
    int ratio=(int)MathRound(s_currentLot/lotStep);
    if(MathAbs(ratio*lotStep-s_currentLot)>0.0000001)
    {     
     //Print("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",lotStep,ratio*lotStep);
     return;
    }  

    // Menghentikan eksekusi trade jika tidak cukup dana
    if(!CheckMargin(s_currentLot)) return;
    
    double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);    
    double tp_calculated = 0; // Inisialisasi TP ke 0 (tidak ada TP)

    // Eksekusi order beli atau jual
    if (type == ORDER_TYPE_BUY)
    {
        // trade.Buy(volume, symbol, price, sl, tp, comment);
        // Tanpa TP (Take Profit) dan SL (Stop Loss) tetap
        if (trade.Buy(s_currentLot, _Symbol, 0, 0, tp_calculated, tradeComment))
        {
            Print("Successfully opened a buy position: ", s_currentLot, " ", _Symbol);
            s_lastOpenPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK); // Simpan harga buka trade ini
            s_seriesType = POSITION_TYPE_BUY; // Tetapkan arah seri
            s_totalTradesInSeries++; // Tambah hitungan trade dalam seri
        }
        else
        {
            Print("Failed to open buy position. Error: ", GetLastError());
        }
    }
    else if (type == ORDER_TYPE_SELL)
    {
        // trade.Sell(volume, symbol, price, sl, tp, comment);
        // Tanpa TP (Take Profit) dan SL (Stop Loss) tetap
        if (trade.Sell(s_currentLot, _Symbol, 0, 0, tp_calculated, tradeComment))
        {
            Print("Successfully opened a sell position: ", s_currentLot, " ", _Symbol);
            s_lastOpenPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID); // Simpan harga buka trade ini
            s_seriesType = POSITION_TYPE_SELL; // Tetapkan arah seri
            s_totalTradesInSeries++; // Tambah hitungan trade dalam seri
        }
        else
        {
            Print("Failed to open sell position. Error: ", GetLastError());
        }
    }
}
//+------------------------------------------------------------------+
//| Fungsi kustom untuk menutup semua posisi yang dibuka oleh EA ini |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
    // Iterasi terbalik untuk keamanan saat menutup posisi
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong position_ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(position_ticket))
        {
            // Pastikan posisi ini dibuka oleh EA kita (menggunakan MagicNumber)
            if (PositionGetInteger(POSITION_MAGIC) == MagicNumber)
            {
                if (trade.PositionClose(position_ticket))
                {
                    Print("Successfully closed position with ticket: ", position_ticket);
                }
                else
                {
                    Print("Failed to close position ", position_ticket, ". Error: ", GetLastError());
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| GetLast Trade Open Price                                         |
//+------------------------------------------------------------------+
double GetLastTradeOpenPriceOfSeries(ENUM_POSITION_TYPE posType)
{
    double latestOpenTime = 0;
    double lastOpenPrice = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (PositionGetTicket(i))
        {
            if ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == posType)
            {
                datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
                if (openTime > latestOpenTime)
                {
                    latestOpenTime = (double)openTime;
                    lastOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                }
            }
        }
    }
    return lastOpenPrice;
}
//+------------------------------------------------------------------+
//| Fungsi untuk mengecek apakah tanggal ini diperbolehkan trading   |
//+------------------------------------------------------------------+
bool IsTradingDateAllowed()
{
   MqlDateTime current_time;
   TimeCurrent(current_time);
   string currentDateStr = IntegerToString(current_time.year) + "." + 
                              (current_time.mon < 10 ? "0" : "") + IntegerToString(current_time.mon) + "." +
                              (current_time.day < 10 ? "0" : "") + IntegerToString(current_time.day);
   if (StringFind(ForbiddenDates, currentDateStr, 0) != -1){ 
      return false; 
   }else{
      return true;
   }
   
}
//+------------------------------------------------------------------+
//| Fungsi untuk mengecek apakah hari ini diperbolehkan trading      |
//+------------------------------------------------------------------+
bool IsTradingDayAllowed()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);  // Konversi waktu ke struktur

   int dayOfWeek = dt.day_of_week;  // 0 = Minggu, 1 = Senin, ..., 6 = Sabtu

   switch(dayOfWeek)
   {      
      case 1: return AllowMonday;
      case 2: return AllowTuesday;
      case 3: return AllowWednesday;
      case 4: return AllowThursday;
      case 5: return AllowFriday;      
   }
   return false;
}

//+------------------------------------------------------------------+
//| Pending Order execution wrapper                                  |
//+------------------------------------------------------------------+
void PendingOrders(ENUM_ORDER_TYPE type, double price, double lotSize, string comment)
{
    // Validate lot size
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    
    if (s_currentLot > maxLot)
    {
        s_currentLot = maxLot;
        //Print("Warning: Volume exceeds broker's maximum limit. Adjusted to ", DoubleToString(s_currentLot, 2));
        return;
    }
    
    if (s_currentLot < minLot)
    {
        //Print("Error: Final volume is less than the minimum allowed volume: ", DoubleToString(s_currentLot, 2));
        return;
    }
    
    int ratio=(int)MathRound(s_currentLot/lotStep);
    if(MathAbs(ratio*lotStep-s_currentLot)>0.0000001)
    {     
     //Print("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",lotStep,ratio*lotStep);
     return;
    }  
    
    
    int lotPrecision = 0;
    double tempStep = lotStep;
    while(tempStep < 1.0 && lotPrecision < 5) 
    {
        tempStep *= 10;
        lotPrecision++;
    }
    
    lotSize = MathMax(minLot, MathMin(maxLot, lotSize)); 
    lotSize = MathRound(lotSize / lotStep) * lotStep;     
    lotSize = NormalizeDouble(lotSize, lotPrecision);
    
    // Get current market prices
    double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double minDistPoints = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL); 
    double minDistPrice = minDistPoints * _Point;
    
    if(!CheckMargin(lotSize)) return;
    
    // Validate price based on order type
    price = NormalizeDouble(price, _Digits);
    
    switch(type)
    {
        case ORDER_TYPE_BUY_STOP:
            // Buy Stop must be above current Ask + minimum distance
            price = MathMax(price, currentAsk + minDistPrice);
            break;
            
        case ORDER_TYPE_SELL_STOP:
            // Sell Stop must be below current Bid - minimum distance
            price = MathMin(price, currentBid - minDistPrice);
            break;
            
        case ORDER_TYPE_BUY_LIMIT:
            // Buy Limit must be below current Ask - minimum distance
            price = MathMin(price, currentAsk - minDistPrice);
            break;
            
        case ORDER_TYPE_SELL_LIMIT:
            // Sell Limit must be above current Bid + minimum distance
            price = MathMax(price, currentBid + minDistPrice);
            break;
            
        default:
            Print("Invalid order type for pending order");
            return;
    }
    
    // Calculate TP (you'll need to define TakeProfit somewhere)
    double sl = 0; // Set your stop loss logic here
    double tp = 0;
    
    if(type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP)
    {
        tp = NormalizeDouble(price + TakeProfit * _Point, _Digits);
    }
    else if(type == ORDER_TYPE_SELL_LIMIT || type == ORDER_TYPE_SELL_STOP)
    {
        tp = NormalizeDouble(price - TakeProfit * _Point, _Digits);
    }
    
    // Prepare trade request
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_PENDING;
    request.magic = MagicNumber;
    request.symbol = _Symbol;
    request.volume = lotSize;
    request.price = price;
    request.type = type;
    request.type_filling = ORDER_FILLING_RETURN;
    request.deviation = 10;
    request.sl = sl;
    request.tp = tp;
    request.comment = comment;
    
    // Send order
    if(!OrderSend(request, result))
    {
        Print("OrderSend failed: ", GetLastError(),  
              " Type: ", EnumToString(type),
              " Requested Price: ", price,
              " Current Ask: ", currentAsk,
              " Current Bid: ", currentBid,
              " Min Distance (points): ", minDistPoints,
              " Min Distance (price): ", DoubleToString(minDistPrice, _Digits + 2),
              " Lot: ", lotSize);
    }
    else
    {
        Print("Pending order placed: Ticket=", result.order, 
              " Type: ", EnumToString(type),
              " Price: ", DoubleToString(price, _Digits),
              " Lot: ", DoubleToString(lotSize, lotPrecision));
    }
}

//+------------------------------------------------------------------+
//| Delete Pending Order                                             |
//+------------------------------------------------------------------+
void DeletePendingOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && 
            OrderGetInteger(ORDER_MAGIC) == MagicNumber)
         {
            int type = (int)OrderGetInteger(ORDER_TYPE);
            if(type == ORDER_TYPE_BUY_STOP || ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_STOP || type == ORDER_TYPE_SELL_LIMIT )
            {
               if(!trade.OrderDelete(ticket))
               {
                  Print("Failed to delete order ", ticket, ". Error: ", GetLastError());
               }
               else
               {
                  Print("Pending order deleted (Ticket: ", ticket, ")");
               }
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Expert Tick Function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   // Mencegah eksekusi berulang pada tick yang sama (good practice)
   static datetime lastCheck = 0;
   if(TimeCurrent() == lastCheck) return;
   lastCheck = TimeCurrent();
   
   // Ini adalah awal bar baru, lakukan perhitungan yang intensif di sini
   if(!LoadClosePrices()) return;
   
   // Martingale logic
   double totalFloatingProfit = 0.0;
   double lastPositionOpenPrice = 0.0;
   ENUM_POSITION_TYPE lastPositionType = (ENUM_POSITION_TYPE)0;
   bool eaHasOpenPositions = false;
   
   //menghapus pending order di hari dilarang
   if (!IsTradingDayAllowed() || !IsTradingDateAllowed())
   {         
      DeletePendingOrders();
   }   
   
   //Filter input maksimum equity

   // Iterasi terbalik untuk keamanan saat memodifikasi/menutup posisi
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
     ulong position_ticket = PositionGetTicket(i);
     if (PositionSelectByTicket(position_ticket))
       {         
         string symbol = OrderGetString(ORDER_SYMBOL);
         // Pastikan posisi ini dibuka oleh EA kita (menggunakan MagicNumber)
         if (PositionGetInteger(POSITION_MAGIC) == MagicNumber)
          {
            eaHasOpenPositions = true;
            totalFloatingProfit += PositionGetDouble(POSITION_PROFIT);      
            lastPositionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            lastPositionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
           }
       }
   } 
   
   // cek ada open posisi jika ada maka hapus semua pending order
   if (eaHasOpenPositions)
   {
      DeletePendingOrders();
   } 
   
   // 2. Periksa dan tutup semua posisi jika target profit tercapai
   if (eaHasOpenPositions && totalFloatingProfit >= SecureProfitMartingaleTarget)
    {
        //Print("Profit target achieved (", DoubleToString(totalFloatingProfit, 2), " USD). Close All Order.");
        CloseAllPositions(); // Panggil fungsi untuk menutup semua posisi EA
        
        // Reset status Martingale setelah seri selesai dengan profit
        s_currentLot = InitialLot;
        s_lastOpenPrice = 0.0;
        s_seriesType = (ENUM_POSITION_TYPE)0;
        s_totalTradesInSeries = 0;
        s_negativeFloatingCount = 0;
        return; // Keluar setelah menutup posisi
    }
    
    if (!eaHasOpenPositions && IsTradingDayAllowed() && IsTradingDateAllowed())
     {
        // Reset status Martingale untuk seri baru (ini juga lebih baik di sini)
        s_currentLot = InitialLot;
        s_lastOpenPrice = 0.0;
        s_seriesType = (ENUM_POSITION_TYPE)0; 
        s_totalTradesInSeries = 0;
        s_negativeFloatingCount = 0;
        
        // Check if new bar has formed
        static datetime lastBarTime;
        datetime currentBarTime = iTime(_Symbol, _Period, 0);
        if(currentBarTime != lastBarTime)
        {
           lastBarTime = currentBarTime;
           barsCount++;
           
           // Check if it's time to reset orders
           if(barsCount >= ResetAfterBars)
           {
               Print("Resetting orders after ", ResetAfterBars, " bars");
               DeletePendingOrders();
               barsCount = 0;
               UpdateHighLowAndOrders();
           }
           else
           {
               // Regular update of high/low levels
               UpdateHighLowAndOrders();
           }
        }                               
    }        
       
    else if (s_totalTradesInSeries < MaxTradesInSeries)
    {          
             
            // Hitung harga saat ini berdasarkan jenis posisi terakhir
            double currentPrice = (lastPositionType == POSITION_TYPE_BUY)? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);                 
            
            // KOREKSI: Hitung jarak pip yang diperlukan dalam poin secara dinamis
            double requiredDistancePoints = DistanceMartingalePips;
            if (_Digits == 5 || _Digits == 3) // Jika broker 5 digit (atau 3 digit untuk JPY)
            {
              requiredDistancePoints *= 10;
            }
            
            // Dapatkan harga open dari trade terakhir dalam seri (BUKAN yang pertama)
            double lastTradeOpenPrice = GetLastTradeOpenPriceOfSeries(lastPositionType);
            
            // Hitung selisih harga dari posisi terakhir dalam seri
            double priceDiffPoints = MathAbs(currentPrice - lastTradeOpenPrice) / _Point;
            
            // Jika floating negatif DAN jarak harga sudah terpenuhi terhadap trade terakhir
            if (totalFloatingProfit < 0 && priceDiffPoints >= requiredDistancePoints) 
            {
                // Hitung lot berikutnya dengan pengganda
                double nextLot = s_currentLot * LotMultiplier;
                
                // Pastikan lot tidak melebihi maksimum yang diizinkan oleh broker
                double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
                if (nextLot > maxLot) nextLot = maxLot;
                
                s_currentLot = nextLot; // Perbarui lot untuk trade berikutnya
                
                // Buka trade baru dengan lot yang digandakan, dalam arah yang sama dengan seri
                // Konversi ENUM_POSITION_TYPE ke ENUM_ORDER_TYPE untuk fungsi OpenMartingaleTrade
                 ENUM_ORDER_TYPE orderToOpen;
                 if (!ReverseMartingale)
                 {
                     // Arah yang sama dengan posisi terakhir dalam seri
                     orderToOpen = (ENUM_ORDER_TYPE)lastPositionType;
                 }
                 else
                 {
                     // Arah berlawanan dengan posisi terakhir dalam seri
                     orderToOpen = (lastPositionType == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
                 }
         
                 // Buka trade baru                 
                 OpenTradeLogic(orderToOpen,"Babi Ngepet Martingale 🐖"); 
                 
            }
   }   
   else if (s_totalTradesInSeries >= MaxTradesInSeries)
   {
       Print("Warning: The number of trades in the Martingale series has reached the maximum limit.(", MaxTradesInSeries, "). Next No new trades will be opened.");
   } 
}

void UpdateHighLowAndOrders()
{
 // Pencarian High Tertinggi dan Low Terendah ---
 double high_prices[];
 double low_prices[];
        
 // Salin data High dan Low dari LookbackBars
 if(CopyHigh(_Symbol, _Period, 0, FindHighLowBackBars, high_prices) <= 0)
   {
    Print("Failed to load High prices");
    return;
   }
 if(CopyLow(_Symbol, _Period, 0, FindHighLowBackBars, low_prices) <= 0)
   {
    Print("Failed to load Low prices");
    return;
   }
       
  ArraySetAsSeries(high_prices, true);
  ArraySetAsSeries(low_prices, true);
        
  double highest_high = 0.0;
  double lowest_low = 999999.9;
        
  // Cari high tertinggi dan low terendah dari LookbackBars
  for (int i = 1; i < FindHighLowBackBars; i++) // Mulai dari index 1 (bar sebelumnya, index 0 adalah bar saat ini yang masih bergerak)
  {
    if (high_prices[i] > highest_high)
      {
       highest_high = high_prices[i];
      }
    if (low_prices[i] < lowest_low)
      {
       lowest_low = low_prices[i];
      }
  }

  // Harga Buy Stop akan ditempatkan di atas Highest High
  double priceSellLimit = NormalizeDouble(highest_high + _Point, _Digits);
            
  // Harga Sell Stop akan ditempatkan di bawah Lowest Low
  double priceBuyLimit = NormalizeDouble(lowest_low - _Point, _Digits);                
        
  // Periksa apakah ada pending order yang sudah ada dengan MagicNumber ini
  bool hasBuyLimit = false;
  bool hasSellLimit = false;
  
  for(int i = OrdersTotal() - 1; i >= 0; i--) {
       ulong ticket = OrderGetTicket(i);
       if(ticket > 0 && OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == MagicNumber) {
            if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_LIMIT) hasBuyLimit = true;
            if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_LIMIT) hasSellLimit = true;
       }
  }

  if (!hasSellLimit && AllowSell) {
      PendingOrders(ORDER_TYPE_SELL_LIMIT, priceSellLimit, InitialLot, "Babi Ngepet Sell Limit 🐖");
  } else {
      Print("Sell Limit order already exists for this session.");
  }

  if (!hasBuyLimit && AllowBuy) {
      PendingOrders(ORDER_TYPE_BUY_LIMIT, priceBuyLimit, InitialLot, "Babi Ngepet Buy Limit 🐖");
  } else {
      Print("Buy Limit order already exists for this session.");
  } 
}