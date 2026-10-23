#ifndef ROUND_TRIP_COST_CORE_MQH
#define ROUND_TRIP_COST_CORE_MQH

struct RTCPositionRow
  {
   ulong             position_id;
   string            symbol;
   long              magic;
   datetime          first_time;
   datetime          last_time;
   double            entry_volume;
   double            exit_volume;
   double            entry_value;
   double            exit_value;
   double            gross_profit;
   double            commission;
   double            swap;
   double            fee;
   int               deal_count;
   bool              complex_reversal;
  };

//+------------------------------------------------------------------+
//| Initialize one position-lifecycle accumulator                    |
//+------------------------------------------------------------------+
void RTCResetRow(RTCPositionRow &row,const ulong position_id,const string symbol,const long magic,const datetime deal_time)
  {
   row.position_id=position_id;
   row.symbol=symbol;
   row.magic=magic;
   row.first_time=deal_time;
   row.last_time=deal_time;
   row.entry_volume=0.0;
   row.exit_volume=0.0;
   row.entry_value=0.0;
   row.exit_value=0.0;
   row.gross_profit=0.0;
   row.commission=0.0;
   row.swap=0.0;
   row.fee=0.0;
   row.deal_count=0;
   row.complex_reversal=false;
  }

//+------------------------------------------------------------------+
//| Add one historical deal to the lifecycle accumulator             |
//+------------------------------------------------------------------+
void RTCAccumulate(RTCPositionRow &row,const ENUM_DEAL_ENTRY entry,const double volume,const double price,
                   const double profit,const double commission,const double swap,const double fee,
                   const datetime deal_time,const long magic)
  {
   if(deal_time<row.first_time)
      row.first_time=deal_time;
   if(deal_time>row.last_time)
      row.last_time=deal_time;
   if(row.magic!=magic)
      row.magic=-2;

   if(entry==DEAL_ENTRY_IN)
     {
      row.entry_volume+=volume;
      row.entry_value+=volume*price;
     }
   else if(entry==DEAL_ENTRY_OUT || entry==DEAL_ENTRY_OUT_BY)
     {
      row.exit_volume+=volume;
      row.exit_value+=volume*price;
     }
   else if(entry==DEAL_ENTRY_INOUT)
      row.complex_reversal=true;

   row.gross_profit+=profit;
   row.commission+=commission;
   row.swap+=swap;
   row.fee+=fee;
   row.deal_count++;
  }

double RTCAveragePrice(const double value,const double volume)
  {
   return(volume>0.0 ? value/volume : 0.0);
  }

double RTCCosts(const RTCPositionRow &row)
  {
   return(row.commission+row.swap+row.fee);
  }

double RTCNetResult(const RTCPositionRow &row)
  {
   return(row.gross_profit+RTCCosts(row));
  }

//+------------------------------------------------------------------+
//| Classify the lifecycle without inventing reversal allocation     |
//+------------------------------------------------------------------+
string RTCStatus(const RTCPositionRow &row,const double volume_step)
  {
   if(row.complex_reversal)
      return "COMPLEX_REVERSAL";
   const double epsilon=MathMax(volume_step*0.5,1e-8);
   const double delta=row.entry_volume-row.exit_volume;
   if(MathAbs(delta)<=epsilon && row.entry_volume>epsilon)
      return "COMPLETE";
   if(delta>epsilon)
      return "OPEN_OR_INCOMPLETE";
   return "EXCESS_EXIT";
  }

#endif
