//+------------------------------------------------------------------+
//| Box Session
//+------------------------------------------------------------------+
enum ENUM_CANCEL_REASON {
   SCR_NONE,          // OK
   SCR_EXPIRE,        // Signal expired
   SCR_NOT_TRADE_DAY, // Non-trading day
   SCR_FRIDAY_CANCEL, // Friday cancel
};
struct SB_Box {
   datetime end_time;                      // current box start
   datetime start_time;                    // leftmost candle open time
   datetime next_box_time;                 // next box start
   datetime signal_expire;                 // end_time + expire_minutes
   double   high;                          // box high
   double   low;                           // box low
   bool     upper_cancel;                  // upper side cancelled
   ENUM_CANCEL_REASON upper_cancel_reason; // upper cancel reason
   bool     lower_cancel;                  // lower side cancelled
   ENUM_CANCEL_REASON lower_cancel_reason; // lower cancel reason
   bool     upper_entry;                   // upper breakout (set externally)
   bool     lower_entry;                   // lower breakout (set externally)
};
//+------------------------------------------------------------------+
class CBoxSession {
   private:
      int             gmt_hour, box_minute, box_candles, expire_minutes;
      ENUM_TIMEFRAMES tf;
      bool            ready, skip_weekend;

      bool     BuildBox(datetime box_start);
      datetime BoxStartForDay(datetime day_gmt);
      datetime LastBoxStart();
      datetime NextBoxStart(datetime current_start);
      bool     IsWeekday(datetime t);
      void     ResetBox();
      void     CheckExpiry();
      bool     CalcBoxHL(datetime box_start, double &out_high, double &out_low, datetime &st, int &out_shift);

   public:
      int         box_hour;
      datetime    tc;
      MqlDateTime mtc;
      SB_Box      box;
      string      error;
      int         gmt_offset;

      CBoxSession(int _box_hour, int _box_minute, int _box_candles, ENUM_TIMEFRAMES _timeframe, int _expire_minutes, int _gmt_offset, bool _skip_weekend = true);
      void     Tick(double _ask, double _bid);
      void     SetGMT(int _gmt_offset);
      bool     IsReady() { return ready; }
};
//+------------------------------------------------------------------+
CBoxSession::CBoxSession(int _box_hour, int _box_minute, int _box_candles, ENUM_TIMEFRAMES _timeframe, int _expire_minutes, int _gmt_offset, bool _skip_weekend = true) {
   gmt_hour       = _box_hour;
   box_hour       = gmt_hour + _gmt_offset;
   if(box_hour >= 24) box_hour -= 24;
   if(box_hour < 0)   box_hour += 24;
   box_minute     = _box_minute;
   box_candles    = _box_candles;
   tf             = _timeframe;
   expire_minutes = _expire_minutes;
   gmt_offset     = _gmt_offset;
   skip_weekend   = _skip_weekend;
   ready          = false;
   error          = "";
   tc             = TimeCurrent(mtc);

   datetime last_start = LastBoxStart();
   if(BuildBox(last_start))
      ready = true;
}
//+------------------------------------------------------------------+
void CBoxSession::SetGMT(int _gmt_offset) {
   box_hour   = gmt_hour + _gmt_offset;
   if(box_hour >= 24) box_hour -= 24;
   if(box_hour < 0)   box_hour += 24;
   gmt_offset = _gmt_offset;
}
//+------------------------------------------------------------------+
void CBoxSession::Tick(double _ask, double _bid) {
   tc = TimeCurrent(mtc);

   if(ready && tc < box.next_box_time) {
      CheckExpiry();
      if(!box.upper_cancel && !box.upper_entry) {
         if(_bid > box.high) box.upper_entry = true;
      }
      if(!box.lower_cancel && !box.lower_entry) {
         if(_bid < box.low) box.lower_entry = true;
      }
      return;
   }

   datetime new_start = LastBoxStart();
   if(new_start > tc) return;
   if(ready && box.end_time == new_start) {
      CheckExpiry();
      return;
   }
   if(BuildBox(new_start))
      ready = true;
}
//+------------------------------------------------------------------+
datetime CBoxSession::BoxStartForDay(datetime day_gmt) {
   datetime day_start = day_gmt - (day_gmt % 86400);
   return day_start + box_hour * 3600 + box_minute * 60;
}
//+------------------------------------------------------------------+
datetime CBoxSession::LastBoxStart() {
   datetime today_start = BoxStartForDay(tc);
   datetime candidate   = (tc >= today_start) ? today_start : today_start - 86400;
   int safety = 0;
   while(!IsWeekday(candidate) && safety < 7) {
      candidate -= 86400;
      safety++;
   }
   return candidate;
}
//+------------------------------------------------------------------+
datetime CBoxSession::NextBoxStart(datetime current_start) {
   datetime next   = current_start + 86400;
   int      safety = 0;
   while(!IsWeekday(next) && safety < 7) {
      next += 86400;
      safety++;
   }
   return next;
}
//+------------------------------------------------------------------+
bool CBoxSession::IsWeekday(datetime t) {
   MqlDateTime dt;
   TimeToStruct(t, dt);
   return (dt.day_of_week >= 1 && dt.day_of_week <= 5);
}
//+------------------------------------------------------------------+
void CBoxSession::ResetBox() {
   box.end_time            = 0;
   box.start_time          = 0;
   box.next_box_time       = 0;
   box.signal_expire       = 0;
   box.high                = 0;
   box.low                 = 0;
   box.upper_cancel        = false;
   box.upper_cancel_reason = SCR_NONE;
   box.lower_cancel        = false;
   box.lower_cancel_reason = SCR_NONE;
   box.upper_entry         = false;
   box.lower_entry         = false;
}
//+------------------------------------------------------------------+
bool CBoxSession::BuildBox(datetime box_start) {
   double   h, l;
   datetime st;
   int      out_shift;
   if(!CalcBoxHL(box_start, h, l, st, out_shift)) return false;

   box.end_time            = box_start;
   box.start_time          = st;
   box.next_box_time       = NextBoxStart(box_start);
   box.signal_expire       = box_start + expire_minutes * 60;
   box.high                = h;
   box.low                 = l;
   box.upper_cancel        = false;
   box.upper_cancel_reason = SCR_NONE;
   box.lower_cancel        = false;
   box.lower_cancel_reason = SCR_NONE;
   box.upper_entry         = false;
   box.lower_entry         = false;

   return true;
}
//+------------------------------------------------------------------+
bool CBoxSession::CalcBoxHL(datetime box_start, double &out_high, double &out_low, datetime &st, int &out_shift) {
   int shift = iBarShift(_Symbol, tf, box_start - PeriodSeconds(tf), false);
   if(shift < 0) return false;
   if(iBars(_Symbol, tf) < shift + box_candles) return false;

   out_high  = -DBL_MAX;
   out_low   =  DBL_MAX;
   out_shift = shift;

   int counted = 0;
   int i       = shift;
   while(counted < box_candles) {
      if(i >= iBars(_Symbol, tf)) return false;
      if(skip_weekend) {
         MqlDateTime dt;
         TimeToStruct(iTime(_Symbol, tf, i), dt);
         if(dt.day_of_week == 0 || dt.day_of_week == 6) { i++; continue; }
      }
      double bar_high = iHigh(_Symbol, tf, i);
      double bar_low  = iLow(_Symbol,  tf, i);
      if(bar_high >= out_high) out_high = bar_high;
      if(bar_low  <= out_low)  out_low  = bar_low;
      if(counted == box_candles - 1) st = iTime(_Symbol, tf, i);
      counted++;
      i++;
   }
   return (out_high > -DBL_MAX && out_low < DBL_MAX);
}
//+------------------------------------------------------------------+
void CBoxSession::CheckExpiry() {
   if(box.signal_expire == 0) return;
   if(tc < box.signal_expire) return;
   if(box.upper_cancel && box.lower_cancel) return;
   if(!box.upper_cancel) {
      box.upper_cancel        = true;
      box.upper_cancel_reason = SCR_EXPIRE;
   }
   if(!box.lower_cancel) {
      box.lower_cancel        = true;
      box.lower_cancel_reason = SCR_EXPIRE;
   }
}