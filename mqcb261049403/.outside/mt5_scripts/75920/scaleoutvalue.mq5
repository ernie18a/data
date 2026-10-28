//+------------------------------------------------------------------+
//|                                                ScaleOutValue.mq5 |
//|                                          Copyright 2026, Thiabot |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Thiabot"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property script_show_inputs

//--- input parameters
input string InpFileName             = "ScaleOutData.csv"; // Input CSV file name (in MQL5\Files)
input int    InpMinScaledPositions   = 5;                  // Minimum scaled positions required to grade
input int    InpRobustSampleSize     = 200;                // Scaled positions recommended for a non-preliminary result
input double InpWeightValueAdd       = 40.0;               // Composite weight: Value-Add dimension
input double InpWeightHitRate        = 30.0;               // Composite weight: Hit-Rate dimension
input double InpWeightEfficiency     = 30.0;               // Composite weight: Efficiency dimension
input double InpValueAddSensitivity  = 1.2;                // Score points per 1% aggregate Value-Add Ratio
input double InpGradeAPlus           = 90.0;               // Grade boundary: A+
input double InpGradeA               = 80.0;               // Grade boundary: A
input double InpGradeB               = 70.0;               // Grade boundary: B
input double InpGradeC               = 60.0;               // Grade boundary: C
input double InpGradeD               = 50.0;               // Grade boundary: D (below this is F)
input double InpHitRateAlertBelow    = 70.0;               // Recommend a review if Hit Rate is below this, %
input double InpEfficiencyAlertBelow = 70.0;               // Recommend a review if Efficiency is below this, %
input double InpStressDependenceAlert= 0.30;               // Flag single-trade dependence above this relative shift

//--- one closing deal (exit leg) belonging to a reconstructed position
struct ExitLeg
  {
   double            volume;                               // Lot size closed by this deal
   double            profit;                               // Price-driven profit of this deal (broker's DEAL_PROFIT)
   double            commission;                           // Commission charged on this deal
   double            swap;                                 // Swap charged or credited on this deal
  };

//--- a reconstructed position: one entry plus one or more exit legs
struct ScalePosition
  {
   long              position_id;                          // MT5 position identifier
   string            symbol;                               // Traded symbol
   string            direction;                            // "buy" or "sell"
   datetime          entry_time;                           // Entry time (earliest IN deal)
   double            entry_price;                          // Entry price (earliest IN deal)
   double            total_volume;                         // Total volume opened on this position
   ExitLeg           legs[];                               // Closing deals, one element per exit leg
  };

//--- one raw CSV data line, before it is grouped into a ScalePosition
struct ExitRow
  {
   long              position_id;                          // MT5 position identifier
   string            symbol;                               // Traded symbol
   string            direction;                            // "buy" or "sell"
   datetime          entry_time;                           // Entry time repeated on every row of the position
   double            entry_price;                          // Entry price repeated on every row of the position
   int               entry_count;                          // Number of IN deals that built this position (>1 = unsupported)
   double            total_volume;                         // Total volume opened on this position
   datetime          exit_time;                            // Time of this specific closing deal
   double            exit_price;                           // Price of this specific closing deal
   double            exit_volume;                          // Lot size closed by this specific deal
   double            exit_profit;                          // Price-driven profit of this specific deal
   double            exit_commission;                      // Commission charged on this specific deal
   double            exit_swap;                            // Swap charged or credited on this specific deal
  };

//--- computed scale-out metrics for one position closed in more than one exit
struct ScaleMetrics
  {
   long              position_id;                          // MT5 position identifier
   double            actual;                               // Actual net result actually realized (sum of all legs)
   double            cf_first;                             // Counterfactual: full volume repriced at the first-exit rate
   double            cf_last;                              // Counterfactual: full volume repriced at the last-exit rate
   double            cf_best;                              // Counterfactual: full volume repriced at the best-of-own-exits rate
   double            value_vs_last;                        // actual - cf_last: the value scaling added versus holding to the last exit
   double            value_vs_first;                       // actual - cf_first: the value scaling added versus taking it all at the first exit
   double            efficiency;                           // actual / cf_best * 100, clamped to [0, 100]; -1.0 means not applicable
  };

//--- aggregate scoring output for the whole analyzed file
struct ScoreResult
  {
   int               n_scaled;                             // Number of positions closed in more than one exit
   int               hits;                                 // Number of those positions where scaling beat holding to the last exit
   double            value_add_ratio;                      // Aggregate Value-Add Ratio, %
   double            hit_rate;                             // Scale-Out Win Rate, %
   double            avg_efficiency;                       // Average Scaling Efficiency, %
   double            sub_value;                            // Value-Add dimension sub-score, 0-100
   double            sub_hit;                              // Hit-Rate dimension sub-score, 0-100
   double            sub_eff;                              // Efficiency dimension sub-score, 0-100
   double            composite;                            // Final Scale-Out Value Score, 0-100
   string            grade;                                // Letter grade derived from the composite score
   long              stress_dropped_id;                    // Position removed by the single-trade dependence check
   double            stress_ratio;                         // Value-Add Ratio recomputed without that position, %
   double            stress_shift;                         // stress_ratio - value_add_ratio, in percentage points
  };

//--- one literal row of the built-in demonstration data set
struct SampleRow
  {
   long              position_id;                          // MT5 position identifier
   string            symbol;                               // Traded symbol
   string            direction;                            // "buy" or "sell"
   string            entry_time;                           // Pre-formatted "YYYY.MM.DD HH:MM:SS" entry time
   double            entry_price;                          // Entry price
   int               entry_count;                          // Number of IN deals that built this position
   double            total_volume;                         // Total volume opened on this position
   string            exit_time;                            // Pre-formatted "YYYY.MM.DD HH:MM:SS" exit time of this leg
   double            exit_price;                           // Price of this closing deal
   double            exit_volume;                          // Lot size closed by this deal
   double            exit_profit;                          // Price-driven profit of this deal
   double            exit_commission;                      // Commission charged on this deal
   double            exit_swap;                            // Swap charged or credited on this deal
  };

//+------------------------------------------------------------------+
//| Clamp a value into a closed [lo, hi] range                       |
//+------------------------------------------------------------------+
double Clamp(double x, double lo, double hi)
  {
   if(x<lo)
      return(lo);
   if(x>hi)
      return(hi);
   return(x);
  }

//+------------------------------------------------------------------+
//| Map a composite score to a letter grade using the configured     |
//| boundary inputs                                                  |
//+------------------------------------------------------------------+
string GradeFromScore(double score, double gA_plus, double gA, double gB, double gC, double gD)
  {
   if(score>=gA_plus)
      return("A+");
   if(score>=gA)
      return("A");
   if(score>=gB)
      return("B");
   if(score>=gC)
      return("C");
   if(score>=gD)
      return("D");
   return("F");
  }

//+------------------------------------------------------------------+
//| Parse one CSV data line into an ExitRow; returns false if the    |
//| line is malformed or fails validation                            |
//+------------------------------------------------------------------+
bool ParseRow(string line, ExitRow &row)
  {
   string f[];
   int n=StringSplit(line, ',', f);
   if(n!=13)
      return(false);
   for(int i=0; i<n; i++)
     {
      StringTrimLeft(f[i]);
      StringTrimRight(f[i]);
     }
//--- convert every field; a field that fails to parse becomes 0 or an empty string and is caught below
   row.position_id    = StringToInteger(f[0]);
   row.symbol          = f[1];
   row.direction        = f[2];
   row.entry_time       = StringToTime(f[3]);
   row.entry_price      = StringToDouble(f[4]);
   row.entry_count      = (int)StringToInteger(f[5]);
   row.total_volume     = StringToDouble(f[6]);
   row.exit_time        = StringToTime(f[7]);
   row.exit_price       = StringToDouble(f[8]);
   row.exit_volume      = StringToDouble(f[9]);
   row.exit_profit      = StringToDouble(f[10]);
   row.exit_commission  = StringToDouble(f[11]);
   row.exit_swap        = StringToDouble(f[12]);
//--- reject a row whose required numeric or time fields did not parse or are out of range
   if(row.position_id<=0 || row.entry_time<=0 || row.exit_time<=0)
      return(false);
   if(row.total_volume<=0.0 || row.exit_volume<=0.0 || row.entry_price<=0.0 || row.exit_price<=0.0)
      return(false);
   if(row.direction!="buy" && row.direction!="sell")
      return(false);
   if(row.entry_count<1)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//| Load and validate every data row from the CSV file; malformed    |
//| lines are skipped and counted, not fatal                         |
//+------------------------------------------------------------------+
int LoadRows(const string filename, ExitRow &rows[], int &skipped)
  {
   ResetLastError();
   int handle=FileOpen(filename, FILE_READ|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("ERROR: cannot open %s, error code %d.", filename, GetLastError());
      return(-1);
     }
   int total=0;
   skipped=0;
   bool header_done=false;
   while(!FileIsEnding(handle))
     {
      string line=FileReadString(handle);
      StringTrimLeft(line);
      StringTrimRight(line);
      if(line=="")
         continue;
      if(!header_done)
        {
         header_done=true; // first non-blank line is the CSV header, not data
         continue;
        }
      ExitRow row;
      if(ParseRow(line, row))
        {
         total++;
         ArrayResize(rows, total);
         rows[total-1]=row;
        }
      else
         skipped++;
     }
   FileClose(handle);
   if(skipped>0)
      PrintFormat("WARNING: skipped %d malformed row(s) while reading %s.", skipped, filename);
   return(total);
  }

//+------------------------------------------------------------------+
//| Sort rows by position id, then by exit time within a position,   |
//| so every position's rows end up contiguous and leg-ordered       |
//+------------------------------------------------------------------+
void SortRows(ExitRow &rows[])
  {
   int total=ArraySize(rows);
//--- plain insertion sort: the row counts an offline analytics run reads stay small,
//--- and a simple, easy-to-verify sort is preferable to a generic library routine here
   for(int i=1; i<total; i++)
     {
      ExitRow key=rows[i];
      int j=i-1;
      while(j>=0 && (rows[j].position_id>key.position_id ||
            (rows[j].position_id==key.position_id && rows[j].exit_time>key.exit_time)))
        {
         rows[j+1]=rows[j];
         j--;
        }
      rows[j+1]=key;
     }
  }

//+------------------------------------------------------------------+
//| Group sorted rows into positions; a position built from more     |
//| than one entry deal is counted and excluded, not silently merged |
//+------------------------------------------------------------------+
int BuildPositions(const ExitRow &rows[], ScalePosition &positions[], int &excluded_multi_entry)
  {
   int total_rows=ArraySize(rows);
   int total_pos=0;
   excluded_multi_entry=0;
   int i=0;
   while(i<total_rows)
     {
      long pid=rows[i].position_id;
      int j=i;
      while(j<total_rows && rows[j].position_id==pid)
         j++;
      //--- rows[i..j-1] all belong to position pid, already grouped contiguously by SortRows()
      if(rows[i].entry_count>1)
        {
         excluded_multi_entry++; // scale-in entries are out of scope, see Limitations
         i=j;
         continue;
        }
      total_pos++;
      ArrayResize(positions, total_pos);
      int p=total_pos-1;
      positions[p].position_id  = pid;
      positions[p].symbol       = rows[i].symbol;
      positions[p].direction    = rows[i].direction;
      positions[p].entry_time   = rows[i].entry_time;
      positions[p].entry_price  = rows[i].entry_price;
      positions[p].total_volume = rows[i].total_volume;
      int leg_count=j-i;
      ArrayResize(positions[p].legs, leg_count);
      for(int k=0; k<leg_count; k++)
        {
         positions[p].legs[k].volume     = rows[i+k].exit_volume;
         positions[p].legs[k].profit     = rows[i+k].exit_profit;
         positions[p].legs[k].commission = rows[i+k].exit_commission;
         positions[p].legs[k].swap       = rows[i+k].exit_swap;
        }
      i=j;
     }
   return(total_pos);
  }

//+------------------------------------------------------------------+
//| Compute the scale-out counterfactuals for every position closed  |
//| in two or more exits; single-exit positions are not a scaling    |
//| decision and are skipped here                                    |
//+------------------------------------------------------------------+
int ComputeMetrics(const ScalePosition &positions[], ScaleMetrics &metrics[], int &excluded_bad_volume)
  {
   int total=ArraySize(positions);
   int n=0;
   excluded_bad_volume=0;
   for(int p=0; p<total; p++)
     {
      int leg_count=ArraySize(positions[p].legs);
      if(leg_count<2)
         continue;                                     // single exit: no scaling decision to measure
      double vol_sum=0.0;
      for(int k=0; k<leg_count; k++)
         vol_sum+=positions[p].legs[k].volume;
      if(MathAbs(vol_sum-positions[p].total_volume)>0.0000001)
        {
         excluded_bad_volume++;                        // exit legs do not add up to the opened volume
         continue;
        }
      double rates[];
      ArrayResize(rates, leg_count);
      double actual=0.0;
      for(int k=0; k<leg_count; k++)
        {
         //--- net_leg is this deal's price-driven profit, fully loaded with the commission and swap it actually paid
         double net_leg=positions[p].legs[k].profit+positions[p].legs[k].commission+positions[p].legs[k].swap;
         actual+=net_leg;
         rates[k]=net_leg/positions[p].legs[k].volume; // net result per lot at this leg's own exit price
        }
      double best_rate=rates[0];
      for(int k=1; k<leg_count; k++)
         if(rates[k]>best_rate)
            best_rate=rates[k];

      n++;
      ArrayResize(metrics, n);
      int m=n-1;
      metrics[m].position_id    = positions[p].position_id;
      metrics[m].actual         = actual;
      metrics[m].cf_first       = rates[0]*positions[p].total_volume;
      metrics[m].cf_last        = rates[leg_count-1]*positions[p].total_volume;
      metrics[m].cf_best        = best_rate*positions[p].total_volume;
      metrics[m].value_vs_last  = actual-metrics[m].cf_last;
      metrics[m].value_vs_first = actual-metrics[m].cf_first;
      //--- assumption: the counterfactual commission and swap scale linearly with volume at the same per-lot
      //--- rate actually realized on the leg used for repricing (see the article's Design Choices section)
      metrics[m].efficiency = (metrics[m].cf_best>0.0) ? Clamp(actual/metrics[m].cf_best*100.0, 0.0, 100.0) : -1.0;
     }
   return(n);
  }

//+------------------------------------------------------------------+
//| Aggregate the per-position metrics into the three scoring        |
//| dimensions, the single-trade dependence check, and the final     |
//| composite score and grade                                        |
//+------------------------------------------------------------------+
void AggregateAndScore(const ScaleMetrics &metrics[], ScoreResult &result)
  {
   int n=ArraySize(metrics);
   result.n_scaled=n;
   double sum_value=0.0, sum_abs_cf=0.0, sum_eff=0.0;
   int hits=0, eff_n=0, best_idx=-1;
   for(int i=0; i<n; i++)
     {
      sum_value+=metrics[i].value_vs_last;
      sum_abs_cf+=MathAbs(metrics[i].cf_last);
      if(metrics[i].value_vs_last>0.0)
         hits++;
      if(metrics[i].efficiency>=0.0)
        {
         sum_eff+=metrics[i].efficiency;
         eff_n++;
        }
      if(best_idx==-1 || metrics[i].value_vs_last>metrics[best_idx].value_vs_last)
         best_idx=i;
     }
   result.hits            = hits;
//--- ratio of sums, not an average of per-position ratios: a position whose counterfactual is near zero
//--- would otherwise dominate an averaged percentage; see the article's Design Choices section
   result.value_add_ratio = (sum_abs_cf>0.0) ? sum_value/sum_abs_cf*100.0 : 0.0;
   result.hit_rate         = (n>0) ? (double)hits/n*100.0 : 0.0;
   result.avg_efficiency   = (eff_n>0) ? sum_eff/eff_n : 0.0;

//--- single-trade dependence check: remove the single largest winning scale-out and recompute the ratio.
//--- this is a one-sided removal, expected to lower the ratio -- the question is by how much, not whether it falls
   double stress_sum_value=sum_value;
   double stress_sum_cf=sum_abs_cf;
   result.stress_dropped_id=-1;
   if(best_idx>=0 && n>1)
     {
      result.stress_dropped_id = metrics[best_idx].position_id;
      stress_sum_value -= metrics[best_idx].value_vs_last;
      stress_sum_cf    -= MathAbs(metrics[best_idx].cf_last);
     }
   result.stress_ratio = (stress_sum_cf>0.0) ? stress_sum_value/stress_sum_cf*100.0 : 0.0;
   result.stress_shift = result.stress_ratio-result.value_add_ratio;

//--- three bounded 0-100 sub-scores, weighted and normalized so the composite does not depend on the sum of the weights
   result.sub_value = Clamp(50.0+result.value_add_ratio*InpValueAddSensitivity, 0.0, 100.0);
   result.sub_hit   = Clamp(result.hit_rate, 0.0, 100.0);
   result.sub_eff   = Clamp(result.avg_efficiency, 0.0, 100.0);

   double wsum=InpWeightValueAdd+InpWeightHitRate+InpWeightEfficiency;
   result.composite = (wsum>0.0) ?
                       (InpWeightValueAdd*result.sub_value+InpWeightHitRate*result.sub_hit+InpWeightEfficiency*result.sub_eff)/wsum :
                       0.0;
   result.grade = GradeFromScore(result.composite, InpGradeAPlus, InpGradeA, InpGradeB, InpGradeC, InpGradeD);
  }

//+------------------------------------------------------------------+
//| Write the built-in demonstration CSV so the tool has something   |
//| to analyze the first time it runs, with no input file prepared   |
//+------------------------------------------------------------------+
void GenerateSampleFile(const string filename)
  {
   int handle=FileOpen(filename, FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("ERROR: cannot create sample file %s, error code %d.", filename, GetLastError());
      return;
     }
   FileWriteString(handle, "PositionID,Symbol,Direction,EntryTime,EntryPrice,EntryCount,TotalVolume,ExitTime,ExitPrice,ExitVolume,ExitProfit,ExitCommission,ExitSwap\r\n");

//--- literal, hand-verified sample data set (see the accompanying article for how it was built and checked):
//--- 220 positions closed in more than one exit (scaled out), 300 closed in a single exit, and 6 positions
//--- built from more than one entry deal, which scale-out analysis deliberately skips. 220 scaled positions
//--- clears the recommended robust sample size (InpRobustSampleSize) so the demonstration grade is not preliminary
   SampleRow g_sample[]=
     {
        {600001, "GBPUSD", "buy", "2025.10.15 07:00:00", 1.25959, 1, 1.00, "2025.10.16 13:00:00", 1.26172, 0.55, 117.00, -0.55, -0.11},
        {600001, "GBPUSD", "buy", "2025.10.15 07:00:00", 1.25959, 1, 1.00, "2025.10.17 14:00:00", 1.25946, 0.45, -6.00, -0.45, -0.28},
        {600002, "EURUSD", "sell", "2025.10.15 22:00:00", 1.08040, 1, 0.80, "2025.10.16 21:00:00", 1.07526, 0.43, 221.00, -0.43, -0.02},
        {600002, "EURUSD", "sell", "2025.10.15 22:00:00", 1.08040, 1, 0.80, "2025.10.18 09:00:00", 1.08248, 0.37, -77.00, -0.37, -0.56},
        {600003, "GBPUSD", "sell", "2025.10.16 16:00:00", 1.25580, 1, 0.70, "2025.10.17 22:00:00", 1.25566, 0.36, 5.00, -0.36, -0.09},
        {600003, "GBPUSD", "sell", "2025.10.16 16:00:00", 1.25580, 1, 0.70, "2025.10.19 00:00:00", 1.24721, 0.34, 292.00, -0.34, -0.26},
        {600004, "EURUSD", "buy", "2025.10.17 07:00:00", 1.08078, 1, 1.00, "2025.10.17 16:00:00", 1.08678, 0.50, 300.00, -1.00, 0.00},
        {600004, "EURUSD", "buy", "2025.10.17 07:00:00", 1.08078, 1, 1.00, "2025.10.18 01:00:00", 1.07911, 0.30, -50.00, -0.60, -0.40},
        {600004, "EURUSD", "buy", "2025.10.17 07:00:00", 1.08078, 1, 1.00, "2025.10.18 07:00:00", 1.07728, 0.20, -70.00, -0.40, -0.40},
        {600005, "GBPUSD", "sell", "2025.10.18 03:00:00", 1.26166, 1, 0.30, "2025.10.18 05:00:00", 1.25731, 0.17, 74.00, -0.17, -0.34},
        {600005, "GBPUSD", "sell", "2025.10.18 03:00:00", 1.26166, 1, 0.30, "2025.10.19 04:00:00", 1.26143, 0.13, 3.00, -0.13, -0.25},
        {600006, "EURUSD", "buy", "2025.10.18 13:00:00", 1.08669, 1, 0.80, "2025.10.18 21:00:00", 1.08817, 0.46, 68.00, -0.46, -0.11},
        {600006, "EURUSD", "buy", "2025.10.18 13:00:00", 1.08669, 1, 0.80, "2025.10.19 12:00:00", 1.09348, 0.34, 231.00, -0.34, -0.13},
        {600007, "GBPUSD", "buy", "2025.10.18 23:00:00", 1.26502, 1, 0.70, "2025.10.20 03:00:00", 1.26771, 0.35, 94.00, -0.35, -0.45},
        {600007, "GBPUSD", "buy", "2025.10.18 23:00:00", 1.26502, 1, 0.70, "2025.10.20 07:00:00", 1.26351, 0.35, -53.00, -0.35, -0.30},
        {600008, "EURUSD", "sell", "2025.10.19 10:00:00", 1.08719, 1, 1.50, "2025.10.20 21:00:00", 1.08639, 0.50, 40.00, -0.50, 0.00},
        {600008, "EURUSD", "sell", "2025.10.19 10:00:00", 1.08719, 1, 1.50, "2025.10.21 03:00:00", 1.08379, 1.00, 340.00, -1.00, -0.30},
        {600009, "GBPUSD", "sell", "2025.10.20 00:00:00", 1.26593, 1, 0.30, "2025.10.20 19:00:00", 1.26605, 0.17, -2.00, -0.17, -0.07},
        {600009, "GBPUSD", "sell", "2025.10.20 00:00:00", 1.26593, 1, 0.30, "2025.10.22 04:00:00", 1.26185, 0.13, 53.00, -0.13, -0.40},
        {600010, "EURUSD", "buy", "2025.10.20 07:00:00", 1.08597, 1, 1.20, "2025.10.20 19:00:00", 1.08525, 0.64, -46.00, -0.64, -0.15},
        {600010, "EURUSD", "buy", "2025.10.20 07:00:00", 1.08597, 1, 1.20, "2025.10.20 21:00:00", 1.08736, 0.56, 78.00, -0.56, -0.22},
        {600011, "GBPUSD", "buy", "2025.10.20 20:00:00", 1.26013, 1, 0.60, "2025.10.21 22:00:00", 1.26048, 0.34, 12.00, -0.34, -0.08},
        {600011, "GBPUSD", "buy", "2025.10.20 20:00:00", 1.26013, 1, 0.60, "2025.10.22 05:00:00", 1.26255, 0.26, 63.00, -0.26, -0.33},
        {600012, "EURUSD", "sell", "2025.10.21 08:00:00", 1.07856, 1, 0.30, "2025.10.22 16:00:00", 1.08156, 0.14, -42.00, -0.14, -0.38},
        {600012, "EURUSD", "sell", "2025.10.21 08:00:00", 1.07856, 1, 0.30, "2025.10.22 22:00:00", 1.07562, 0.16, 47.00, -0.16, -0.06},
        {600013, "GBPUSD", "buy", "2025.10.21 22:00:00", 1.26287, 1, 1.20, "2025.10.22 20:00:00", 1.26781, 0.51, 252.00, -0.51, -0.02},
        {600013, "GBPUSD", "buy", "2025.10.21 22:00:00", 1.26287, 1, 1.20, "2025.10.23 17:00:00", 1.26155, 0.41, -54.00, -0.41, -0.28},
        {600013, "GBPUSD", "buy", "2025.10.21 22:00:00", 1.26287, 1, 1.20, "2025.10.24 07:00:00", 1.26191, 0.28, -27.00, -0.28, -0.30},
        {600014, "EURUSD", "sell", "2025.10.22 05:00:00", 1.09483, 1, 0.40, "2025.10.22 14:00:00", 1.09568, 0.13, -11.00, -0.13, -0.07},
        {600014, "EURUSD", "sell", "2025.10.22 05:00:00", 1.09483, 1, 0.40, "2025.10.22 18:00:00", 1.09754, 0.14, -38.00, -0.14, -0.31},
        {600014, "EURUSD", "sell", "2025.10.22 05:00:00", 1.09483, 1, 0.40, "2025.10.22 20:00:00", 1.09729, 0.13, -32.00, -0.13, -0.20},
        {600015, "GBPUSD", "buy", "2025.10.22 18:00:00", 1.26673, 1, 1.00, "2025.10.23 12:00:00", 1.27073, 0.48, 192.00, -0.48, -0.32},
        {600015, "GBPUSD", "buy", "2025.10.22 18:00:00", 1.26673, 1, 1.00, "2025.10.24 07:00:00", 1.26546, 0.52, -66.00, -0.52, -0.10},
        {600016, "EURUSD", "sell", "2025.10.23 13:00:00", 1.07521, 1, 0.50, "2025.10.23 22:00:00", 1.07479, 0.26, 11.00, -0.26, -0.41},
        {600016, "EURUSD", "sell", "2025.10.23 13:00:00", 1.07521, 1, 0.50, "2025.10.25 07:00:00", 1.06304, 0.24, 292.00, -0.24, -0.21},
        {600017, "GBPUSD", "buy", "2025.10.24 01:00:00", 1.25750, 1, 0.30, "2025.10.25 10:00:00", 1.26470, 0.15, 108.00, -0.15, -0.22},
        {600017, "GBPUSD", "buy", "2025.10.24 01:00:00", 1.25750, 1, 0.30, "2025.10.26 13:00:00", 1.26297, 0.15, 82.00, -0.15, -0.34},
        {600018, "EURUSD", "buy", "2025.10.24 13:00:00", 1.08298, 1, 1.00, "2025.10.25 12:00:00", 1.08558, 0.52, 135.00, -0.52, -0.13},
        {600018, "EURUSD", "buy", "2025.10.24 13:00:00", 1.08298, 1, 1.00, "2025.10.26 12:00:00", 1.08329, 0.48, 15.00, -0.48, -0.38},
        {600019, "GBPUSD", "sell", "2025.10.25 05:00:00", 1.26583, 1, 0.40, "2025.10.26 15:00:00", 1.26059, 0.17, 89.00, -0.17, -0.06},
        {600019, "GBPUSD", "sell", "2025.10.25 05:00:00", 1.26583, 1, 0.40, "2025.10.26 20:00:00", 1.26600, 0.23, -4.00, -0.23, -0.37},
        {600020, "EURUSD", "sell", "2025.10.25 20:00:00", 1.09112, 1, 0.30, "2025.10.26 21:00:00", 1.09141, 0.14, -4.00, -0.14, -0.49},
        {600020, "EURUSD", "sell", "2025.10.25 20:00:00", 1.09112, 1, 0.30, "2025.10.27 17:00:00", 1.09343, 0.16, -37.00, -0.16, -0.42},
        {600021, "GBPUSD", "sell", "2025.10.26 16:00:00", 1.26663, 1, 0.40, "2025.10.28 02:00:00", 1.26204, 0.22, 101.00, -0.22, -0.02},
        {600021, "GBPUSD", "sell", "2025.10.26 16:00:00", 1.26663, 1, 0.40, "2025.10.29 07:00:00", 1.26830, 0.18, -30.00, -0.18, -0.15},
        {600022, "EURUSD", "buy", "2025.10.27 00:00:00", 1.08857, 1, 0.50, "2025.10.28 09:00:00", 1.09431, 0.23, 132.00, -0.23, -0.43},
        {600022, "EURUSD", "buy", "2025.10.27 00:00:00", 1.08857, 1, 0.50, "2025.10.29 12:00:00", 1.08964, 0.27, 29.00, -0.27, -0.40},
        {600023, "GBPUSD", "buy", "2025.10.27 06:00:00", 1.27226, 1, 0.30, "2025.10.28 15:00:00", 1.27341, 0.13, 15.00, -0.13, -0.22},
        {600023, "GBPUSD", "buy", "2025.10.27 06:00:00", 1.27226, 1, 0.30, "2025.10.29 15:00:00", 1.28632, 0.17, 239.00, -0.17, -0.42},
        {600024, "EURUSD", "sell", "2025.10.27 20:00:00", 1.08778, 1, 0.50, "2025.10.28 08:00:00", 1.08608, 0.30, 51.00, -0.30, -0.25},
        {600024, "EURUSD", "sell", "2025.10.27 20:00:00", 1.08778, 1, 0.50, "2025.10.28 18:00:00", 1.08588, 0.20, 38.00, -0.20, -0.46},
        {600025, "GBPUSD", "buy", "2025.10.28 07:00:00", 1.25662, 1, 0.60, "2025.10.29 03:00:00", 1.26480, 0.28, 229.00, -0.28, -0.30},
        {600025, "GBPUSD", "buy", "2025.10.28 07:00:00", 1.25662, 1, 0.60, "2025.10.29 22:00:00", 1.25662, 0.17, 0.00, -0.17, -0.11},
        {600025, "GBPUSD", "buy", "2025.10.28 07:00:00", 1.25662, 1, 0.60, "2025.10.30 19:00:00", 1.25229, 0.15, -65.00, -0.15, -0.24},
        {600026, "EURUSD", "sell", "2025.10.28 19:00:00", 1.07813, 1, 1.00, "2025.10.30 01:00:00", 1.07757, 0.45, 25.00, -0.45, -0.38},
        {600026, "EURUSD", "sell", "2025.10.28 19:00:00", 1.07813, 1, 1.00, "2025.10.30 13:00:00", 1.07838, 0.55, -14.00, -0.55, -0.46},
        {600027, "GBPUSD", "buy", "2025.10.29 02:00:00", 1.26423, 1, 0.40, "2025.10.29 08:00:00", 1.27465, 0.19, 198.00, -0.19, -0.58},
        {600027, "GBPUSD", "buy", "2025.10.29 02:00:00", 1.26423, 1, 0.40, "2025.10.30 07:00:00", 1.26347, 0.21, -16.00, -0.21, -0.38},
        {600028, "EURUSD", "sell", "2025.10.29 09:00:00", 1.08273, 1, 0.70, "2025.10.29 23:00:00", 1.07568, 0.41, 289.00, -0.41, -0.27},
        {600028, "EURUSD", "sell", "2025.10.29 09:00:00", 1.08273, 1, 0.70, "2025.10.30 09:00:00", 1.08394, 0.29, -35.00, -0.29, -0.09},
        {600029, "GBPUSD", "sell", "2025.10.30 01:00:00", 1.27235, 1, 0.50, "2025.10.30 21:00:00", 1.25910, 0.24, 318.00, -0.24, -0.42},
        {600029, "GBPUSD", "sell", "2025.10.30 01:00:00", 1.27235, 1, 0.50, "2025.11.01 04:00:00", 1.27535, 0.26, -78.00, -0.26, -0.06},
        {600030, "EURUSD", "buy", "2025.10.30 17:00:00", 1.08628, 1, 0.80, "2025.11.01 05:00:00", 1.08628, 0.34, -0.00, -0.34, -0.37},
        {600030, "EURUSD", "buy", "2025.10.30 17:00:00", 1.08628, 1, 0.80, "2025.11.02 07:00:00", 1.08621, 0.46, -3.00, -0.46, -0.16},
        {600031, "GBPUSD", "sell", "2025.10.30 23:00:00", 1.25522, 1, 1.00, "2025.10.31 23:00:00", 1.25189, 0.46, 153.00, -0.46, -0.22},
        {600031, "GBPUSD", "sell", "2025.10.30 23:00:00", 1.25522, 1, 1.00, "2025.11.01 10:00:00", 1.25650, 0.54, -69.00, -0.54, -0.50},
        {600032, "EURUSD", "buy", "2025.10.31 19:00:00", 1.07830, 1, 0.70, "2025.11.02 04:00:00", 1.08075, 0.40, 98.00, -0.40, -0.22},
        {600032, "EURUSD", "buy", "2025.10.31 19:00:00", 1.07830, 1, 0.70, "2025.11.03 05:00:00", 1.08137, 0.30, 92.00, -0.30, -0.39},
        {600033, "GBPUSD", "sell", "2025.11.01 13:00:00", 1.26044, 1, 1.20, "2025.11.01 18:00:00", 1.25944, 0.41, 41.00, -0.41, -0.08},
        {600033, "GBPUSD", "sell", "2025.11.01 13:00:00", 1.26044, 1, 1.20, "2025.11.02 22:00:00", 1.26066, 0.45, -10.00, -0.45, -0.05},
        {600033, "GBPUSD", "sell", "2025.11.01 13:00:00", 1.26044, 1, 1.20, "2025.11.04 06:00:00", 1.26150, 0.34, -36.00, -0.34, -0.35},
        {600034, "EURUSD", "sell", "2025.11.01 23:00:00", 1.07628, 1, 1.00, "2025.11.02 04:00:00", 1.06983, 0.49, 316.00, -0.49, -0.34},
        {600034, "EURUSD", "sell", "2025.11.01 23:00:00", 1.07628, 1, 1.00, "2025.11.02 23:00:00", 1.07597, 0.51, 16.00, -0.51, -0.49},
        {600035, "GBPUSD", "buy", "2025.11.02 15:00:00", 1.27243, 1, 0.30, "2025.11.02 18:00:00", 1.27219, 0.17, -4.00, -0.17, -0.48},
        {600035, "GBPUSD", "buy", "2025.11.02 15:00:00", 1.27243, 1, 0.30, "2025.11.03 04:00:00", 1.28181, 0.13, 122.00, -0.13, -0.24},
        {600036, "EURUSD", "buy", "2025.11.03 06:00:00", 1.09234, 1, 0.30, "2025.11.03 13:00:00", 1.09263, 0.17, 5.00, -0.17, -0.22},
        {600036, "EURUSD", "buy", "2025.11.03 06:00:00", 1.09234, 1, 0.30, "2025.11.04 02:00:00", 1.10172, 0.13, 122.00, -0.13, -0.47},
        {600037, "GBPUSD", "sell", "2025.11.03 22:00:00", 1.26628, 1, 0.80, "2025.11.05 07:00:00", 1.26689, 0.33, -20.00, -0.33, -0.29},
        {600037, "GBPUSD", "sell", "2025.11.03 22:00:00", 1.26628, 1, 0.80, "2025.11.06 04:00:00", 1.26643, 0.47, -7.00, -0.47, -0.33},
        {600038, "EURUSD", "buy", "2025.11.04 07:00:00", 1.08064, 1, 1.00, "2025.11.04 12:00:00", 1.08095, 0.42, 13.00, -0.42, -0.07},
        {600038, "EURUSD", "buy", "2025.11.04 07:00:00", 1.08064, 1, 1.00, "2025.11.05 10:00:00", 1.08557, 0.58, 286.00, -0.58, -0.06},
        {600039, "GBPUSD", "buy", "2025.11.05 03:00:00", 1.25908, 1, 1.00, "2025.11.06 10:00:00", 1.25829, 0.43, -34.00, -0.43, -0.31},
        {600039, "GBPUSD", "buy", "2025.11.05 03:00:00", 1.25908, 1, 1.00, "2025.11.07 03:00:00", 1.25843, 0.57, -37.00, -0.57, -0.24},
        {600040, "EURUSD", "buy", "2025.11.05 21:00:00", 1.09298, 1, 1.00, "2025.11.06 23:00:00", 1.09185, 0.45, -51.00, -0.45, -0.31},
        {600040, "EURUSD", "buy", "2025.11.05 21:00:00", 1.09298, 1, 1.00, "2025.11.07 14:00:00", 1.09233, 0.55, -36.00, -0.55, -0.32},
        {600041, "GBPUSD", "buy", "2025.11.06 03:00:00", 1.27248, 1, 0.60, "2025.11.07 05:00:00", 1.28165, 0.24, 220.00, -0.24, -0.16},
        {600041, "GBPUSD", "buy", "2025.11.06 03:00:00", 1.27248, 1, 0.60, "2025.11.07 23:00:00", 1.27092, 0.36, -56.00, -0.36, -0.07},
        {600042, "EURUSD", "buy", "2025.11.06 16:00:00", 1.08275, 1, 0.50, "2025.11.07 21:00:00", 1.08902, 0.22, 138.00, -0.22, -0.09},
        {600042, "EURUSD", "buy", "2025.11.06 16:00:00", 1.08275, 1, 0.50, "2025.11.08 12:00:00", 1.08018, 0.28, -72.00, -0.28, -0.50},
        {600043, "GBPUSD", "sell", "2025.11.07 00:00:00", 1.25544, 1, 1.00, "2025.11.07 17:00:00", 1.25362, 0.44, 80.00, -0.44, -0.34},
        {600043, "GBPUSD", "sell", "2025.11.07 00:00:00", 1.25544, 1, 1.00, "2025.11.09 04:00:00", 1.25346, 0.56, 111.00, -0.56, -0.33},
        {600044, "EURUSD", "buy", "2025.11.07 08:00:00", 1.08467, 1, 0.80, "2025.11.08 18:00:00", 1.09014, 0.36, 197.00, -0.36, -0.03},
        {600044, "EURUSD", "buy", "2025.11.07 08:00:00", 1.08467, 1, 0.80, "2025.11.09 21:00:00", 1.08272, 0.44, -86.00, -0.44, -0.32},
        {600045, "GBPUSD", "sell", "2025.11.07 15:00:00", 1.26388, 1, 0.80, "2025.11.08 15:00:00", 1.25826, 0.45, 253.00, -0.45, -0.16},
        {600045, "GBPUSD", "sell", "2025.11.07 15:00:00", 1.26388, 1, 0.80, "2025.11.08 17:00:00", 1.26334, 0.35, 19.00, -0.35, -0.10},
        {600046, "EURUSD", "buy", "2025.11.08 08:00:00", 1.08039, 1, 0.80, "2025.11.09 12:00:00", 1.08861, 0.37, 304.00, -0.37, -0.28},
        {600046, "EURUSD", "buy", "2025.11.08 08:00:00", 1.08039, 1, 0.80, "2025.11.10 21:00:00", 1.07990, 0.43, -21.00, -0.43, -0.06},
        {600047, "GBPUSD", "sell", "2025.11.09 03:00:00", 1.26396, 1, 1.40, "2025.11.10 15:00:00", 1.26399, 0.76, -2.00, -0.76, -0.20},
        {600047, "GBPUSD", "sell", "2025.11.09 03:00:00", 1.26396, 1, 1.40, "2025.11.11 19:00:00", 1.26129, 0.64, 171.00, -0.64, -0.14},
        {600048, "EURUSD", "sell", "2025.11.09 16:00:00", 1.09023, 1, 1.00, "2025.11.11 02:00:00", 1.08566, 0.47, 215.00, -0.47, -0.36},
        {600048, "EURUSD", "sell", "2025.11.09 16:00:00", 1.09023, 1, 1.00, "2025.11.11 14:00:00", 1.09114, 0.53, -48.00, -0.53, -0.00},
        {600049, "GBPUSD", "buy", "2025.11.10 08:00:00", 1.27349, 1, 0.80, "2025.11.11 04:00:00", 1.27827, 0.41, 196.00, -0.41, -0.10},
        {600049, "GBPUSD", "buy", "2025.11.10 08:00:00", 1.27349, 1, 0.80, "2025.11.12 07:00:00", 1.27416, 0.39, 26.00, -0.39, -0.58},
        {600050, "EURUSD", "buy", "2025.11.10 19:00:00", 1.08202, 1, 0.60, "2025.11.11 17:00:00", 1.08469, 0.33, 88.00, -0.33, -0.41},
        {600050, "EURUSD", "buy", "2025.11.10 19:00:00", 1.08202, 1, 0.60, "2025.11.12 05:00:00", 1.08258, 0.27, 15.00, -0.27, -0.38},
        {600051, "GBPUSD", "sell", "2025.11.11 03:00:00", 1.27090, 1, 0.80, "2025.11.12 01:00:00", 1.26566, 0.45, 236.00, -0.45, -0.17},
        {600051, "GBPUSD", "sell", "2025.11.11 03:00:00", 1.27090, 1, 0.80, "2025.11.13 01:00:00", 1.27330, 0.35, -84.00, -0.35, -0.20},
        {600052, "EURUSD", "buy", "2025.11.11 14:00:00", 1.07763, 1, 0.80, "2025.11.12 19:00:00", 1.07885, 0.37, 45.00, -0.37, -0.18},
        {600052, "EURUSD", "buy", "2025.11.11 14:00:00", 1.07763, 1, 0.80, "2025.11.14 01:00:00", 1.08121, 0.43, 154.00, -0.43, -0.41},
        {600053, "GBPUSD", "sell", "2025.11.12 01:00:00", 1.27211, 1, 0.60, "2025.11.12 21:00:00", 1.27035, 0.29, 51.00, -0.29, -0.02},
        {600053, "GBPUSD", "sell", "2025.11.12 01:00:00", 1.27211, 1, 0.60, "2025.11.13 06:00:00", 1.26921, 0.31, 90.00, -0.31, -0.44},
        {600054, "EURUSD", "sell", "2025.11.12 19:00:00", 1.09473, 1, 0.40, "2025.11.13 00:00:00", 1.09448, 0.20, 5.00, -0.20, -0.49},
        {600054, "EURUSD", "sell", "2025.11.12 19:00:00", 1.09473, 1, 0.40, "2025.11.14 11:00:00", 1.08018, 0.20, 291.00, -0.20, -0.18},
        {600055, "GBPUSD", "buy", "2025.11.13 08:00:00", 1.25775, 1, 1.40, "2025.11.14 14:00:00", 1.25925, 0.48, 72.00, -0.48, -0.14},
        {600055, "GBPUSD", "buy", "2025.11.13 08:00:00", 1.25775, 1, 1.40, "2025.11.15 22:00:00", 1.25905, 0.44, 57.00, -0.44, -0.12},
        {600055, "GBPUSD", "buy", "2025.11.13 08:00:00", 1.25775, 1, 1.40, "2025.11.16 22:00:00", 1.25894, 0.48, 57.00, -0.48, -0.05},
        {600056, "EURUSD", "buy", "2025.11.13 19:00:00", 1.07916, 1, 1.20, "2025.11.15 02:00:00", 1.08000, 0.62, 52.00, -0.62, -0.21},
        {600056, "EURUSD", "buy", "2025.11.13 19:00:00", 1.07916, 1, 1.20, "2025.11.15 04:00:00", 1.08126, 0.58, 122.00, -0.58, -0.08},
        {600057, "GBPUSD", "buy", "2025.11.14 11:00:00", 1.27026, 1, 0.30, "2025.11.15 20:00:00", 1.28807, 0.16, 285.00, -0.16, -0.15},
        {600057, "GBPUSD", "buy", "2025.11.14 11:00:00", 1.27026, 1, 0.30, "2025.11.16 07:00:00", 1.26390, 0.14, -89.00, -0.14, -0.30},
        {600058, "EURUSD", "sell", "2025.11.15 07:00:00", 1.07960, 1, 1.20, "2025.11.15 13:00:00", 1.07848, 0.68, 76.00, -0.68, -0.22},
        {600058, "EURUSD", "sell", "2025.11.15 07:00:00", 1.07960, 1, 1.20, "2025.11.16 10:00:00", 1.07773, 0.52, 97.00, -0.52, -0.31},
        {600059, "GBPUSD", "buy", "2025.11.15 20:00:00", 1.26613, 1, 1.20, "2025.11.16 18:00:00", 1.26899, 0.51, 146.00, -0.51, -0.33},
        {600059, "GBPUSD", "buy", "2025.11.15 20:00:00", 1.26613, 1, 1.20, "2025.11.18 04:00:00", 1.26574, 0.69, -27.00, -0.69, -0.56},
        {600060, "EURUSD", "buy", "2025.11.16 03:00:00", 1.08053, 1, 1.00, "2025.11.16 11:00:00", 1.08106, 0.40, 21.00, -0.40, -0.25},
        {600060, "EURUSD", "buy", "2025.11.16 03:00:00", 1.08053, 1, 1.00, "2025.11.17 08:00:00", 1.08160, 0.30, 32.00, -0.30, -0.03},
        {600060, "EURUSD", "buy", "2025.11.16 03:00:00", 1.08053, 1, 1.00, "2025.11.17 22:00:00", 1.08866, 0.30, 244.00, -0.30, -0.17},
        {600061, "GBPUSD", "buy", "2025.11.16 10:00:00", 1.26261, 1, 0.80, "2025.11.16 12:00:00", 1.26791, 0.47, 249.00, -0.47, -0.08},
        {600061, "GBPUSD", "buy", "2025.11.16 10:00:00", 1.26261, 1, 0.80, "2025.11.16 15:00:00", 1.26040, 0.33, -73.00, -0.33, -0.52},
        {600062, "EURUSD", "buy", "2025.11.16 23:00:00", 1.08398, 1, 0.80, "2025.11.18 03:00:00", 1.08325, 0.33, -24.00, -0.33, -0.42},
        {600062, "EURUSD", "buy", "2025.11.16 23:00:00", 1.08398, 1, 0.80, "2025.11.18 07:00:00", 1.08377, 0.47, -10.00, -0.47, -0.25},
        {600063, "GBPUSD", "buy", "2025.11.17 18:00:00", 1.26120, 1, 1.00, "2025.11.19 02:00:00", 1.26320, 0.55, 110.00, -0.55, -0.02},
        {600063, "GBPUSD", "buy", "2025.11.17 18:00:00", 1.26120, 1, 1.00, "2025.11.19 15:00:00", 1.26271, 0.45, 68.00, -0.45, -0.38},
        {600064, "EURUSD", "sell", "2025.11.18 01:00:00", 1.09180, 1, 0.60, "2025.11.18 14:00:00", 1.09277, 0.32, -31.00, -0.32, -0.04},
        {600064, "EURUSD", "sell", "2025.11.18 01:00:00", 1.09180, 1, 0.60, "2025.11.19 11:00:00", 1.08880, 0.28, 84.00, -0.28, -0.40},
        {600065, "GBPUSD", "sell", "2025.11.18 14:00:00", 1.26251, 1, 1.20, "2025.11.19 11:00:00", 1.26104, 0.59, 87.00, -0.59, -0.23},
        {600065, "GBPUSD", "sell", "2025.11.18 14:00:00", 1.26251, 1, 1.20, "2025.11.19 15:00:00", 1.26262, 0.61, -7.00, -0.61, -0.49},
        {600066, "EURUSD", "buy", "2025.11.19 02:00:00", 1.09282, 1, 1.00, "2025.11.20 08:00:00", 1.09516, 0.32, 75.00, -0.32, -0.12},
        {600066, "EURUSD", "buy", "2025.11.19 02:00:00", 1.09282, 1, 1.00, "2025.11.20 19:00:00", 1.09509, 0.40, 91.00, -0.40, -0.13},
        {600066, "EURUSD", "buy", "2025.11.19 02:00:00", 1.09282, 1, 1.00, "2025.11.21 08:00:00", 1.09539, 0.28, 72.00, -0.28, -0.26},
        {600067, "GBPUSD", "buy", "2025.11.19 10:00:00", 1.26930, 1, 1.00, "2025.11.19 12:00:00", 1.27386, 0.48, 219.00, -0.48, -0.42},
        {600067, "GBPUSD", "buy", "2025.11.19 10:00:00", 1.26930, 1, 1.00, "2025.11.19 14:00:00", 1.26899, 0.52, -16.00, -0.52, -0.38},
        {600068, "EURUSD", "sell", "2025.11.19 22:00:00", 1.09197, 1, 1.00, "2025.11.21 10:00:00", 1.09186, 0.55, 6.00, -0.55, -0.19},
        {600068, "EURUSD", "sell", "2025.11.19 22:00:00", 1.09197, 1, 1.00, "2025.11.21 17:00:00", 1.09006, 0.45, 86.00, -0.45, -0.46},
        {600069, "GBPUSD", "sell", "2025.11.20 13:00:00", 1.25861, 1, 0.30, "2025.11.21 02:00:00", 1.23470, 0.11, 263.00, -0.11, -0.23},
        {600069, "GBPUSD", "sell", "2025.11.20 13:00:00", 1.25861, 1, 0.30, "2025.11.22 04:00:00", 1.26583, 0.09, -65.00, -0.09, -0.22},
        {600069, "GBPUSD", "sell", "2025.11.20 13:00:00", 1.25861, 1, 0.30, "2025.11.23 11:00:00", 1.26391, 0.10, -53.00, -0.10, -0.12},
        {600070, "EURUSD", "sell", "2025.11.21 05:00:00", 1.07693, 1, 1.00, "2025.11.21 08:00:00", 1.07689, 0.49, 2.00, -0.49, -0.47},
        {600070, "EURUSD", "sell", "2025.11.21 05:00:00", 1.07693, 1, 1.00, "2025.11.22 20:00:00", 1.07513, 0.51, 92.00, -0.51, -0.29},
        {600071, "GBPUSD", "buy", "2025.11.21 16:00:00", 1.26041, 1, 1.00, "2025.11.22 01:00:00", 1.26348, 0.41, 126.00, -0.41, -0.32},
        {600071, "GBPUSD", "buy", "2025.11.21 16:00:00", 1.26041, 1, 1.00, "2025.11.23 13:00:00", 1.26078, 0.59, 22.00, -0.59, -0.11},
        {600072, "EURUSD", "buy", "2025.11.22 00:00:00", 1.09286, 1, 0.50, "2025.11.22 23:00:00", 1.09528, 0.19, 46.00, -0.19, -0.30},
        {600072, "EURUSD", "buy", "2025.11.22 00:00:00", 1.09286, 1, 0.50, "2025.11.23 06:00:00", 1.09544, 0.19, 49.00, -0.19, -0.40},
        {600072, "EURUSD", "buy", "2025.11.22 00:00:00", 1.09286, 1, 0.50, "2025.11.24 11:00:00", 1.09311, 0.12, 3.00, -0.12, -0.39},
        {600073, "GBPUSD", "sell", "2025.11.22 19:00:00", 1.27330, 1, 1.00, "2025.11.23 05:00:00", 1.27348, 0.40, -7.00, -0.40, -0.23},
        {600073, "GBPUSD", "sell", "2025.11.22 19:00:00", 1.27330, 1, 1.00, "2025.11.23 11:00:00", 1.27190, 0.60, 84.00, -0.60, -0.44},
        {600074, "EURUSD", "sell", "2025.11.23 12:00:00", 1.08812, 1, 1.20, "2025.11.24 04:00:00", 1.08725, 0.60, 52.00, -0.60, -0.16},
        {600074, "EURUSD", "sell", "2025.11.23 12:00:00", 1.08812, 1, 1.20, "2025.11.25 04:00:00", 1.08835, 0.60, -14.00, -0.60, -0.43},
        {600075, "GBPUSD", "sell", "2025.11.24 05:00:00", 1.27133, 1, 0.80, "2025.11.25 02:00:00", 1.26878, 0.40, 102.00, -0.40, -0.04},
        {600075, "GBPUSD", "sell", "2025.11.24 05:00:00", 1.27133, 1, 0.80, "2025.11.25 17:00:00", 1.26898, 0.40, 94.00, -0.40, -0.26},
        {600076, "EURUSD", "buy", "2025.11.24 23:00:00", 1.08570, 1, 1.00, "2025.11.25 06:00:00", 1.08704, 0.50, 67.00, -0.50, -0.00},
        {600076, "EURUSD", "buy", "2025.11.24 23:00:00", 1.08570, 1, 1.00, "2025.11.25 15:00:00", 1.08544, 0.50, -13.00, -0.50, -0.30},
        {600077, "GBPUSD", "buy", "2025.11.25 19:00:00", 1.27057, 1, 1.40, "2025.11.27 05:00:00", 1.27171, 0.71, 81.00, -0.71, -0.20},
        {600077, "GBPUSD", "buy", "2025.11.25 19:00:00", 1.27057, 1, 1.40, "2025.11.27 09:00:00", 1.27006, 0.69, -35.00, -0.69, -0.17},
        {600078, "EURUSD", "sell", "2025.11.26 07:00:00", 1.08951, 1, 0.30, "2025.11.27 08:00:00", 1.08882, 0.13, 9.00, -0.13, -0.50},
        {600078, "EURUSD", "sell", "2025.11.26 07:00:00", 1.08951, 1, 0.30, "2025.11.28 11:00:00", 1.08351, 0.17, 102.00, -0.17, -0.38},
        {600079, "GBPUSD", "sell", "2025.11.26 21:00:00", 1.26551, 1, 0.30, "2025.11.27 00:00:00", 1.25159, 0.12, 167.00, -0.12, -0.36},
        {600079, "GBPUSD", "sell", "2025.11.26 21:00:00", 1.26551, 1, 0.30, "2025.11.27 10:00:00", 1.26540, 0.18, 2.00, -0.18, -0.00},
        {600080, "EURUSD", "buy", "2025.11.27 14:00:00", 1.07630, 1, 0.60, "2025.11.28 04:00:00", 1.08334, 0.25, 176.00, -0.25, -0.11},
        {600080, "EURUSD", "buy", "2025.11.27 14:00:00", 1.07630, 1, 0.60, "2025.11.28 23:00:00", 1.07630, 0.35, 0.00, -0.35, -0.03},
        {600081, "GBPUSD", "sell", "2025.11.27 20:00:00", 1.27461, 1, 0.70, "2025.11.29 07:00:00", 1.27464, 0.32, -1.00, -0.32, -0.33},
        {600081, "GBPUSD", "sell", "2025.11.27 20:00:00", 1.27461, 1, 0.70, "2025.11.30 19:00:00", 1.26706, 0.38, 287.00, -0.38, -0.50},
        {600082, "EURUSD", "buy", "2025.11.28 15:00:00", 1.08887, 1, 0.80, "2025.11.29 08:00:00", 1.09329, 0.43, 190.00, -0.43, -0.18},
        {600082, "EURUSD", "buy", "2025.11.28 15:00:00", 1.08887, 1, 0.80, "2025.11.29 13:00:00", 1.08706, 0.37, -67.00, -0.37, -0.00},
        {600083, "GBPUSD", "buy", "2025.11.29 07:00:00", 1.26605, 1, 0.40, "2025.11.29 23:00:00", 1.26565, 0.20, -8.00, -0.20, -0.45},
        {600083, "GBPUSD", "buy", "2025.11.29 07:00:00", 1.26605, 1, 0.40, "2025.11.30 20:00:00", 1.27610, 0.20, 201.00, -0.20, -0.08},
        {600084, "EURUSD", "sell", "2025.11.29 23:00:00", 1.09361, 1, 0.50, "2025.12.01 01:00:00", 1.09303, 0.24, 14.00, -0.24, -0.29},
        {600084, "EURUSD", "sell", "2025.11.29 23:00:00", 1.09361, 1, 0.50, "2025.12.02 00:00:00", 1.08399, 0.26, 250.00, -0.26, -0.22},
        {600085, "GBPUSD", "sell", "2025.11.30 07:00:00", 1.26774, 1, 1.20, "2025.12.01 13:00:00", 1.26385, 0.54, 210.00, -0.54, -0.58},
        {600085, "GBPUSD", "sell", "2025.11.30 07:00:00", 1.26774, 1, 1.20, "2025.12.02 14:00:00", 1.26860, 0.66, -57.00, -0.66, -0.18},
        {600086, "EURUSD", "buy", "2025.12.01 03:00:00", 1.08051, 1, 1.20, "2025.12.01 20:00:00", 1.08456, 0.57, 231.00, -0.57, -0.50},
        {600086, "EURUSD", "buy", "2025.12.01 03:00:00", 1.08051, 1, 1.20, "2025.12.02 21:00:00", 1.07922, 0.63, -81.00, -0.63, -0.05},
        {600087, "GBPUSD", "buy", "2025.12.01 20:00:00", 1.26624, 1, 0.80, "2025.12.03 03:00:00", 1.27004, 0.40, 152.00, -0.40, -0.39},
        {600087, "GBPUSD", "buy", "2025.12.01 20:00:00", 1.26624, 1, 0.80, "2025.12.03 05:00:00", 1.26592, 0.40, -13.00, -0.40, -0.08},
        {600088, "EURUSD", "sell", "2025.12.02 04:00:00", 1.07820, 1, 0.30, "2025.12.02 21:00:00", 1.05266, 0.13, 332.00, -0.13, -0.33},
        {600088, "EURUSD", "sell", "2025.12.02 04:00:00", 1.07820, 1, 0.30, "2025.12.04 01:00:00", 1.08500, 0.10, -68.00, -0.10, -0.10},
        {600088, "EURUSD", "sell", "2025.12.02 04:00:00", 1.07820, 1, 0.30, "2025.12.05 02:00:00", 1.09077, 0.07, -88.00, -0.07, -0.12},
        {600089, "GBPUSD", "buy", "2025.12.02 17:00:00", 1.26843, 1, 0.60, "2025.12.03 01:00:00", 1.26780, 0.24, -15.00, -0.24, -0.50},
        {600089, "GBPUSD", "buy", "2025.12.02 17:00:00", 1.26843, 1, 0.60, "2025.12.03 03:00:00", 1.26910, 0.36, 24.00, -0.36, -0.16},
        {600090, "EURUSD", "sell", "2025.12.03 04:00:00", 1.09338, 1, 0.60, "2025.12.03 06:00:00", 1.09215, 0.26, 32.00, -0.26, -0.20},
        {600090, "EURUSD", "sell", "2025.12.03 04:00:00", 1.09338, 1, 0.60, "2025.12.03 20:00:00", 1.08885, 0.34, 154.00, -0.34, -0.13},
        {600091, "GBPUSD", "sell", "2025.12.03 15:00:00", 1.26828, 1, 1.00, "2025.12.04 20:00:00", 1.26759, 0.42, 29.00, -0.42, -0.12},
        {600091, "GBPUSD", "sell", "2025.12.03 15:00:00", 1.26828, 1, 1.00, "2025.12.05 18:00:00", 1.26650, 0.32, 57.00, -0.32, -0.36},
        {600091, "GBPUSD", "sell", "2025.12.03 15:00:00", 1.26828, 1, 1.00, "2025.12.06 08:00:00", 1.25893, 0.26, 243.00, -0.26, -0.39},
        {600092, "EURUSD", "buy", "2025.12.03 23:00:00", 1.09191, 1, 0.40, "2025.12.04 05:00:00", 1.10335, 0.18, 206.00, -0.18, -0.21},
        {600092, "EURUSD", "buy", "2025.12.03 23:00:00", 1.09191, 1, 0.40, "2025.12.05 06:00:00", 1.09318, 0.22, 28.00, -0.22, -0.28},
        {600093, "GBPUSD", "buy", "2025.12.04 16:00:00", 1.25549, 1, 0.80, "2025.12.05 12:00:00", 1.25757, 0.40, 83.00, -0.40, -0.32},
        {600093, "GBPUSD", "buy", "2025.12.04 16:00:00", 1.25549, 1, 0.80, "2025.12.05 15:00:00", 1.25839, 0.40, 116.00, -0.40, -0.11},
        {600094, "EURUSD", "sell", "2025.12.05 05:00:00", 1.07931, 1, 0.30, "2025.12.05 16:00:00", 1.07845, 0.14, 12.00, -0.14, -0.06},
        {600094, "EURUSD", "sell", "2025.12.05 05:00:00", 1.07931, 1, 0.30, "2025.12.06 15:00:00", 1.07206, 0.16, 116.00, -0.16, -0.33},
        {600095, "GBPUSD", "buy", "2025.12.05 12:00:00", 1.25886, 1, 1.00, "2025.12.06 07:00:00", 1.26253, 0.54, 198.00, -0.54, -0.12},
        {600095, "GBPUSD", "buy", "2025.12.05 12:00:00", 1.25886, 1, 1.00, "2025.12.07 09:00:00", 1.25866, 0.46, -9.00, -0.46, -0.19},
        {600096, "EURUSD", "sell", "2025.12.06 05:00:00", 1.09266, 1, 1.00, "2025.12.06 23:00:00", 1.09287, 0.57, -12.00, -0.57, -0.47},
        {600096, "EURUSD", "sell", "2025.12.06 05:00:00", 1.09266, 1, 1.00, "2025.12.07 12:00:00", 1.08831, 0.43, 187.00, -0.43, -0.48},
        {600097, "GBPUSD", "sell", "2025.12.06 18:00:00", 1.27185, 1, 0.80, "2025.12.07 00:00:00", 1.26830, 0.33, 117.00, -0.33, -0.27},
        {600097, "GBPUSD", "sell", "2025.12.06 18:00:00", 1.27185, 1, 0.80, "2025.12.08 00:00:00", 1.27051, 0.47, 63.00, -0.47, -0.03},
        {600098, "EURUSD", "sell", "2025.12.07 09:00:00", 1.08071, 1, 1.00, "2025.12.08 02:00:00", 1.07573, 0.47, 234.00, -0.47, -0.23},
        {600098, "EURUSD", "sell", "2025.12.07 09:00:00", 1.08071, 1, 1.00, "2025.12.08 14:00:00", 1.08239, 0.53, -89.00, -0.53, -0.06},
        {600099, "GBPUSD", "buy", "2025.12.07 18:00:00", 1.25811, 1, 1.00, "2025.12.08 20:00:00", 1.25918, 0.56, 60.00, -0.56, -0.19},
        {600099, "GBPUSD", "buy", "2025.12.07 18:00:00", 1.25811, 1, 1.00, "2025.12.09 17:00:00", 1.25695, 0.44, -51.00, -0.44, -0.38},
        {600100, "EURUSD", "buy", "2025.12.08 00:00:00", 1.09444, 1, 0.60, "2025.12.08 20:00:00", 1.09957, 0.31, 159.00, -0.31, -0.32},
        {600100, "EURUSD", "buy", "2025.12.08 00:00:00", 1.09444, 1, 0.60, "2025.12.09 08:00:00", 1.09458, 0.29, 4.00, -0.29, -0.54},
        {600101, "GBPUSD", "sell", "2025.12.08 18:00:00", 1.27032, 1, 0.40, "2025.12.10 05:00:00", 1.26108, 0.21, 194.00, -0.21, -0.56},
        {600101, "GBPUSD", "sell", "2025.12.08 18:00:00", 1.27032, 1, 0.40, "2025.12.11 07:00:00", 1.27006, 0.19, 5.00, -0.19, -0.26},
        {600102, "EURUSD", "buy", "2025.12.09 03:00:00", 1.08905, 1, 0.50, "2025.12.09 23:00:00", 1.08834, 0.24, -17.00, -0.24, -0.38},
        {600102, "EURUSD", "buy", "2025.12.09 03:00:00", 1.08905, 1, 0.50, "2025.12.10 01:00:00", 1.09055, 0.26, 39.00, -0.26, -0.15},
        {600103, "GBPUSD", "buy", "2025.12.09 19:00:00", 1.25557, 1, 0.30, "2025.12.11 07:00:00", 1.26080, 0.13, 68.00, -0.13, -0.11},
        {600103, "GBPUSD", "buy", "2025.12.09 19:00:00", 1.25557, 1, 0.30, "2025.12.11 11:00:00", 1.25322, 0.17, -40.00, -0.17, -0.49},
        {600104, "EURUSD", "sell", "2025.12.10 06:00:00", 1.07567, 1, 0.40, "2025.12.10 19:00:00", 1.06835, 0.22, 161.00, -0.22, -0.24},
        {600104, "EURUSD", "sell", "2025.12.10 06:00:00", 1.07567, 1, 0.40, "2025.12.12 00:00:00", 1.07511, 0.18, 10.00, -0.18, -0.30},
        {600105, "GBPUSD", "sell", "2025.12.10 14:00:00", 1.27237, 1, 1.20, "2025.12.11 23:00:00", 1.27035, 0.56, 113.00, -0.56, -0.04},
        {600105, "GBPUSD", "sell", "2025.12.10 14:00:00", 1.27237, 1, 1.20, "2025.12.12 02:00:00", 1.27132, 0.64, 67.00, -0.64, -0.29},
        {600106, "EURUSD", "sell", "2025.12.11 02:00:00", 1.08749, 1, 0.80, "2025.12.11 22:00:00", 1.08097, 0.44, 287.00, -0.44, -0.29},
        {600106, "EURUSD", "sell", "2025.12.11 02:00:00", 1.08749, 1, 0.80, "2025.12.13 02:00:00", 1.08888, 0.36, -50.00, -0.36, -0.54},
        {600107, "GBPUSD", "sell", "2025.12.11 15:00:00", 1.27426, 1, 0.50, "2025.12.12 14:00:00", 1.26069, 0.21, 285.00, -0.21, -0.19},
        {600107, "GBPUSD", "sell", "2025.12.11 15:00:00", 1.27426, 1, 0.50, "2025.12.13 18:00:00", 1.27595, 0.29, -49.00, -0.29, -0.23},
        {600108, "EURUSD", "sell", "2025.12.11 22:00:00", 1.07748, 1, 0.70, "2025.12.13 01:00:00", 1.06890, 0.33, 283.00, -0.33, -0.25},
        {600108, "EURUSD", "sell", "2025.12.11 22:00:00", 1.07748, 1, 0.70, "2025.12.14 13:00:00", 1.07940, 0.37, -71.00, -0.37, -0.26},
        {600109, "GBPUSD", "buy", "2025.12.12 07:00:00", 1.26213, 1, 1.00, "2025.12.12 14:00:00", 1.26413, 0.50, 100.00, -0.50, -0.12},
        {600109, "GBPUSD", "buy", "2025.12.12 07:00:00", 1.26213, 1, 1.00, "2025.12.13 23:00:00", 1.26309, 0.50, 48.00, -0.50, -0.12},
        {600110, "EURUSD", "buy", "2025.12.12 15:00:00", 1.08212, 1, 0.60, "2025.12.13 19:00:00", 1.08145, 0.27, -18.00, -0.27, -0.48},
        {600110, "EURUSD", "buy", "2025.12.12 15:00:00", 1.08212, 1, 0.60, "2025.12.15 00:00:00", 1.08815, 0.33, 199.00, -0.33, -0.27},
        {600111, "GBPUSD", "sell", "2025.12.13 02:00:00", 1.25668, 1, 1.40, "2025.12.14 05:00:00", 1.25216, 0.69, 312.00, -0.69, -0.03},
        {600111, "GBPUSD", "sell", "2025.12.13 02:00:00", 1.25668, 1, 1.40, "2025.12.14 11:00:00", 1.25675, 0.71, -5.00, -0.71, -0.39},
        {600112, "EURUSD", "buy", "2025.12.13 08:00:00", 1.09024, 1, 0.50, "2025.12.13 18:00:00", 1.08982, 0.26, -11.00, -0.26, -0.37},
        {600112, "EURUSD", "buy", "2025.12.13 08:00:00", 1.09024, 1, 0.50, "2025.12.14 13:00:00", 1.09574, 0.24, 132.00, -0.24, -0.29},
        {600113, "GBPUSD", "sell", "2025.12.13 17:00:00", 1.26268, 1, 0.30, "2025.12.14 18:00:00", 1.26206, 0.13, 8.00, -0.13, -0.16},
        {600113, "GBPUSD", "sell", "2025.12.13 17:00:00", 1.26268, 1, 0.30, "2025.12.15 07:00:00", 1.26256, 0.17, 2.00, -0.17, -0.03},
        {600114, "EURUSD", "sell", "2025.12.14 07:00:00", 1.07650, 1, 0.40, "2025.12.15 00:00:00", 1.07409, 0.17, 41.00, -0.17, -0.36},
        {600114, "EURUSD", "sell", "2025.12.14 07:00:00", 1.07650, 1, 0.40, "2025.12.16 05:00:00", 1.07354, 0.23, 68.00, -0.23, -0.49},
        {600115, "GBPUSD", "sell", "2025.12.14 22:00:00", 1.27149, 1, 0.40, "2025.12.15 06:00:00", 1.25889, 0.20, 252.00, -0.20, -0.58},
        {600115, "GBPUSD", "sell", "2025.12.14 22:00:00", 1.27149, 1, 0.40, "2025.12.15 20:00:00", 1.27379, 0.20, -46.00, -0.20, -0.42},
        {600116, "EURUSD", "buy", "2025.12.15 16:00:00", 1.09374, 1, 1.40, "2025.12.16 22:00:00", 1.09462, 0.78, 69.00, -0.78, -0.32},
        {600116, "EURUSD", "buy", "2025.12.15 16:00:00", 1.09374, 1, 1.40, "2025.12.18 01:00:00", 1.09377, 0.62, 2.00, -0.62, -0.23},
        {600117, "GBPUSD", "buy", "2025.12.16 01:00:00", 1.26200, 1, 1.20, "2025.12.16 23:00:00", 1.26257, 0.49, 28.00, -0.49, -0.11},
        {600117, "GBPUSD", "buy", "2025.12.16 01:00:00", 1.26200, 1, 1.20, "2025.12.18 07:00:00", 1.26465, 0.71, 188.00, -0.71, -0.03},
        {600118, "EURUSD", "sell", "2025.12.16 17:00:00", 1.08808, 1, 1.00, "2025.12.17 02:00:00", 1.08416, 0.60, 235.00, -0.60, -0.18},
        {600118, "EURUSD", "sell", "2025.12.16 17:00:00", 1.08808, 1, 1.00, "2025.12.17 17:00:00", 1.08733, 0.40, 30.00, -0.40, -0.47},
        {600119, "GBPUSD", "sell", "2025.12.17 08:00:00", 1.25995, 1, 1.00, "2025.12.18 07:00:00", 1.25977, 0.49, 9.00, -0.49, -0.04},
        {600119, "GBPUSD", "sell", "2025.12.17 08:00:00", 1.25995, 1, 1.00, "2025.12.19 13:00:00", 1.25754, 0.51, 123.00, -0.51, -0.05},
        {600120, "EURUSD", "buy", "2025.12.17 15:00:00", 1.08000, 1, 1.20, "2025.12.19 02:00:00", 1.08141, 0.61, 86.00, -0.61, -0.09},
        {600120, "EURUSD", "buy", "2025.12.17 15:00:00", 1.08000, 1, 1.20, "2025.12.19 23:00:00", 1.08119, 0.59, 70.00, -0.59, -0.34},
        {600121, "GBPUSD", "buy", "2025.12.18 05:00:00", 1.26215, 1, 1.40, "2025.12.19 02:00:00", 1.26183, 0.78, -25.00, -0.78, -0.43},
        {600121, "GBPUSD", "buy", "2025.12.18 05:00:00", 1.26215, 1, 1.40, "2025.12.19 11:00:00", 1.26286, 0.62, 44.00, -0.62, -0.02},
        {600122, "EURUSD", "buy", "2025.12.19 00:00:00", 1.08570, 1, 1.20, "2025.12.19 17:00:00", 1.08524, 0.59, -27.00, -0.59, -0.18},
        {600122, "EURUSD", "buy", "2025.12.19 00:00:00", 1.08570, 1, 1.20, "2025.12.20 21:00:00", 1.08583, 0.61, 8.00, -0.61, -0.16},
        {600123, "GBPUSD", "sell", "2025.12.19 10:00:00", 1.27040, 1, 0.30, "2025.12.19 20:00:00", 1.27180, 0.15, -21.00, -0.15, -0.15},
        {600123, "GBPUSD", "sell", "2025.12.19 10:00:00", 1.27040, 1, 0.30, "2025.12.20 17:00:00", 1.26527, 0.15, 77.00, -0.15, -0.34},
        {600124, "EURUSD", "buy", "2025.12.19 16:00:00", 1.09152, 1, 0.80, "2025.12.20 19:00:00", 1.09502, 0.26, 91.00, -0.26, -0.36},
        {600124, "EURUSD", "buy", "2025.12.19 16:00:00", 1.09152, 1, 0.80, "2025.12.21 18:00:00", 1.09516, 0.25, 91.00, -0.25, -0.26},
        {600124, "EURUSD", "buy", "2025.12.19 16:00:00", 1.09152, 1, 0.80, "2025.12.22 19:00:00", 1.09376, 0.29, 65.00, -0.29, -0.13},
        {600125, "GBPUSD", "sell", "2025.12.20 09:00:00", 1.26815, 1, 1.00, "2025.12.21 16:00:00", 1.26411, 0.57, 230.00, -0.57, -0.08},
        {600125, "GBPUSD", "sell", "2025.12.20 09:00:00", 1.26815, 1, 1.00, "2025.12.22 18:00:00", 1.26796, 0.43, 8.00, -0.43, -0.54},
        {600126, "EURUSD", "buy", "2025.12.21 02:00:00", 1.08333, 1, 0.50, "2025.12.22 04:00:00", 1.08279, 0.24, -13.00, -0.24, -0.10},
        {600126, "EURUSD", "buy", "2025.12.21 02:00:00", 1.08333, 1, 0.50, "2025.12.23 13:00:00", 1.08848, 0.26, 134.00, -0.26, -0.38},
        {600127, "GBPUSD", "buy", "2025.12.21 12:00:00", 1.27417, 1, 0.70, "2025.12.21 20:00:00", 1.28585, 0.25, 292.00, -0.25, -0.14},
        {600127, "GBPUSD", "buy", "2025.12.21 12:00:00", 1.27417, 1, 0.70, "2025.12.22 01:00:00", 1.27243, 0.23, -40.00, -0.23, -0.14},
        {600127, "GBPUSD", "buy", "2025.12.21 12:00:00", 1.27417, 1, 0.70, "2025.12.22 11:00:00", 1.27367, 0.22, -11.00, -0.22, -0.22},
        {600128, "EURUSD", "buy", "2025.12.22 04:00:00", 1.08489, 1, 1.00, "2025.12.22 18:00:00", 1.09055, 0.50, 283.00, -0.50, -0.08},
        {600128, "EURUSD", "buy", "2025.12.22 04:00:00", 1.08489, 1, 1.00, "2025.12.23 21:00:00", 1.08455, 0.50, -17.00, -0.50, -0.23},
        {600129, "GBPUSD", "buy", "2025.12.22 21:00:00", 1.25732, 1, 1.20, "2025.12.24 00:00:00", 1.25674, 0.50, -29.00, -0.50, -0.44},
        {600129, "GBPUSD", "buy", "2025.12.22 21:00:00", 1.25732, 1, 1.20, "2025.12.25 00:00:00", 1.25729, 0.70, -2.00, -0.70, -0.30},
        {600130, "EURUSD", "sell", "2025.12.23 07:00:00", 1.08322, 1, 0.80, "2025.12.24 01:00:00", 1.07701, 0.42, 261.00, -0.42, -0.33},
        {600130, "EURUSD", "sell", "2025.12.23 07:00:00", 1.08322, 1, 0.80, "2025.12.24 17:00:00", 1.08288, 0.38, 13.00, -0.38, -0.28},
        {600131, "GBPUSD", "buy", "2025.12.23 20:00:00", 1.27473, 1, 1.00, "2025.12.24 04:00:00", 1.27884, 0.44, 181.00, -0.44, -0.11},
        {600131, "GBPUSD", "buy", "2025.12.23 20:00:00", 1.27473, 1, 1.00, "2025.12.24 15:00:00", 1.27521, 0.31, 15.00, -0.31, -0.39},
        {600131, "GBPUSD", "buy", "2025.12.23 20:00:00", 1.27473, 1, 1.00, "2025.12.25 14:00:00", 1.27129, 0.25, -86.00, -0.25, -0.32},
        {600132, "EURUSD", "buy", "2025.12.24 16:00:00", 1.08842, 1, 0.50, "2025.12.25 19:00:00", 1.08956, 0.29, 33.00, -0.29, -0.02},
        {600132, "EURUSD", "buy", "2025.12.24 16:00:00", 1.08842, 1, 0.50, "2025.12.26 22:00:00", 1.09999, 0.21, 243.00, -0.21, -0.23},
        {600133, "GBPUSD", "sell", "2025.12.25 08:00:00", 1.27429, 1, 0.50, "2025.12.25 23:00:00", 1.27459, 0.20, -6.00, -0.20, -0.27},
        {600133, "GBPUSD", "sell", "2025.12.25 08:00:00", 1.27429, 1, 0.50, "2025.12.26 17:00:00", 1.27093, 0.14, 47.00, -0.14, -0.20},
        {600133, "GBPUSD", "sell", "2025.12.25 08:00:00", 1.27429, 1, 0.50, "2025.12.27 15:00:00", 1.26304, 0.16, 180.00, -0.16, -0.26},
        {600134, "EURUSD", "buy", "2025.12.26 01:00:00", 1.08148, 1, 1.00, "2025.12.26 07:00:00", 1.08183, 0.48, 17.00, -0.48, -0.35},
        {600134, "EURUSD", "buy", "2025.12.26 01:00:00", 1.08148, 1, 1.00, "2025.12.27 19:00:00", 1.08267, 0.52, 62.00, -0.52, -0.17},
        {600135, "GBPUSD", "sell", "2025.12.26 17:00:00", 1.27499, 1, 0.50, "2025.12.27 18:00:00", 1.26708, 0.22, 174.00, -0.22, -0.44},
        {600135, "GBPUSD", "sell", "2025.12.26 17:00:00", 1.27499, 1, 0.50, "2025.12.29 05:00:00", 1.27567, 0.28, -19.00, -0.28, -0.25},
        {600136, "EURUSD", "buy", "2025.12.27 04:00:00", 1.07590, 1, 1.20, "2025.12.27 10:00:00", 1.07858, 0.63, 169.00, -0.63, -0.10},
        {600136, "EURUSD", "buy", "2025.12.27 04:00:00", 1.07590, 1, 1.20, "2025.12.28 16:00:00", 1.07620, 0.57, 17.00, -0.57, -0.27},
        {600137, "GBPUSD", "buy", "2025.12.27 22:00:00", 1.27098, 1, 1.00, "2025.12.29 10:00:00", 1.27091, 0.41, -3.00, -0.41, -0.03},
        {600137, "GBPUSD", "buy", "2025.12.27 22:00:00", 1.27098, 1, 1.00, "2025.12.29 22:00:00", 1.27354, 0.59, 151.00, -0.59, -0.14},
        {600138, "EURUSD", "buy", "2025.12.28 10:00:00", 1.08997, 1, 1.00, "2025.12.29 16:00:00", 1.09422, 0.51, 217.00, -0.51, -0.52},
        {600138, "EURUSD", "buy", "2025.12.28 10:00:00", 1.08997, 1, 1.00, "2025.12.30 22:00:00", 1.09007, 0.49, 5.00, -0.49, -0.38},
        {600139, "GBPUSD", "buy", "2025.12.29 04:00:00", 1.26128, 1, 1.00, "2025.12.30 01:00:00", 1.26801, 0.41, 276.00, -0.41, -0.30},
        {600139, "GBPUSD", "buy", "2025.12.29 04:00:00", 1.26128, 1, 1.00, "2025.12.30 08:00:00", 1.26126, 0.59, -1.00, -0.59, -0.56},
        {600140, "EURUSD", "sell", "2025.12.30 00:00:00", 1.07592, 1, 1.00, "2025.12.30 09:00:00", 1.07692, 0.49, -49.00, -0.49, -0.49},
        {600140, "EURUSD", "sell", "2025.12.30 00:00:00", 1.07592, 1, 1.00, "2025.12.31 12:00:00", 1.07584, 0.51, 4.00, -0.51, -0.40},
        {600141, "GBPUSD", "sell", "2025.12.30 14:00:00", 1.26793, 1, 1.20, "2026.01.01 00:00:00", 1.26824, 0.59, -18.00, -0.59, -0.38},
        {600141, "GBPUSD", "sell", "2025.12.30 14:00:00", 1.26793, 1, 1.20, "2026.01.01 09:00:00", 1.26626, 0.61, 102.00, -0.61, -0.08},
        {600142, "EURUSD", "buy", "2025.12.31 00:00:00", 1.08731, 1, 0.30, "2025.12.31 07:00:00", 1.08743, 0.17, 2.00, -0.17, -0.47},
        {600142, "EURUSD", "buy", "2025.12.31 00:00:00", 1.08731, 1, 0.30, "2025.12.31 18:00:00", 1.10031, 0.13, 169.00, -0.13, -0.31},
        {600143, "GBPUSD", "buy", "2025.12.31 09:00:00", 1.26547, 1, 0.60, "2026.01.01 12:00:00", 1.27337, 0.30, 237.00, -0.30, -0.23},
        {600143, "GBPUSD", "buy", "2025.12.31 09:00:00", 1.26547, 1, 0.60, "2026.01.01 22:00:00", 1.26627, 0.30, 24.00, -0.30, -0.29},
        {600144, "EURUSD", "sell", "2025.12.31 17:00:00", 1.07867, 1, 1.20, "2026.01.01 09:00:00", 1.07467, 0.57, 228.00, -0.57, -0.17},
        {600144, "EURUSD", "sell", "2025.12.31 17:00:00", 1.07867, 1, 1.20, "2026.01.02 00:00:00", 1.07981, 0.63, -72.00, -0.63, -0.29},
        {600145, "GBPUSD", "sell", "2026.01.01 07:00:00", 1.26550, 1, 0.70, "2026.01.02 13:00:00", 1.25615, 0.31, 290.00, -0.31, -0.50},
        {600145, "GBPUSD", "sell", "2026.01.01 07:00:00", 1.26550, 1, 0.70, "2026.01.03 07:00:00", 1.26632, 0.39, -32.00, -0.39, -0.60},
        {600146, "EURUSD", "sell", "2026.01.02 00:00:00", 1.09208, 1, 1.40, "2026.01.02 13:00:00", 1.09164, 0.61, 27.00, -0.61, -0.30},
        {600146, "EURUSD", "sell", "2026.01.02 00:00:00", 1.09208, 1, 1.40, "2026.01.03 23:00:00", 1.09183, 0.79, 20.00, -0.79, -0.14},
        {600147, "GBPUSD", "buy", "2026.01.02 12:00:00", 1.27292, 1, 1.00, "2026.01.04 00:00:00", 1.27275, 0.48, -8.00, -0.48, -0.01},
        {600147, "GBPUSD", "buy", "2026.01.02 12:00:00", 1.27292, 1, 1.00, "2026.01.04 14:00:00", 1.27611, 0.52, 166.00, -0.52, -0.02},
        {600148, "EURUSD", "buy", "2026.01.03 06:00:00", 1.08012, 1, 1.00, "2026.01.03 22:00:00", 1.07914, 0.46, -45.00, -0.46, -0.39},
        {600148, "EURUSD", "buy", "2026.01.03 06:00:00", 1.08012, 1, 1.00, "2026.01.04 05:00:00", 1.08208, 0.54, 106.00, -0.54, -0.09},
        {600149, "GBPUSD", "buy", "2026.01.03 21:00:00", 1.27371, 1, 0.50, "2026.01.05 08:00:00", 1.27219, 0.23, -35.00, -0.23, -0.08},
        {600149, "GBPUSD", "buy", "2026.01.03 21:00:00", 1.27371, 1, 0.50, "2026.01.05 14:00:00", 1.27782, 0.27, 111.00, -0.27, -0.16},
        {600150, "EURUSD", "sell", "2026.01.04 11:00:00", 1.07899, 1, 1.40, "2026.01.04 15:00:00", 1.07471, 0.60, 257.00, -0.60, -0.32},
        {600150, "EURUSD", "sell", "2026.01.04 11:00:00", 1.07899, 1, 1.40, "2026.01.04 22:00:00", 1.07888, 0.80, 9.00, -0.80, -0.22},
        {600151, "GBPUSD", "buy", "2026.01.05 03:00:00", 1.26354, 1, 1.00, "2026.01.06 00:00:00", 1.26809, 0.49, 223.00, -0.49, -0.31},
        {600151, "GBPUSD", "buy", "2026.01.05 03:00:00", 1.26354, 1, 1.00, "2026.01.06 07:00:00", 1.26271, 0.29, -24.00, -0.29, -0.06},
        {600151, "GBPUSD", "buy", "2026.01.05 03:00:00", 1.26354, 1, 1.00, "2026.01.07 19:00:00", 1.26045, 0.22, -68.00, -0.22, -0.36},
        {600152, "EURUSD", "sell", "2026.01.05 10:00:00", 1.09160, 1, 1.00, "2026.01.06 16:00:00", 1.09135, 0.55, 14.00, -0.55, -0.39},
        {600152, "EURUSD", "sell", "2026.01.05 10:00:00", 1.09160, 1, 1.00, "2026.01.07 02:00:00", 1.08691, 0.45, 211.00, -0.45, -0.06},
        {600153, "GBPUSD", "sell", "2026.01.06 00:00:00", 1.26882, 1, 0.30, "2026.01.06 07:00:00", 1.25860, 0.18, 184.00, -0.18, -0.12},
        {600153, "GBPUSD", "sell", "2026.01.06 00:00:00", 1.26882, 1, 0.30, "2026.01.07 07:00:00", 1.27224, 0.12, -41.00, -0.12, -0.14},
        {600154, "EURUSD", "sell", "2026.01.06 09:00:00", 1.09160, 1, 0.50, "2026.01.07 12:00:00", 1.09177, 0.29, -5.00, -0.29, -0.42},
        {600154, "EURUSD", "sell", "2026.01.06 09:00:00", 1.09160, 1, 0.50, "2026.01.07 18:00:00", 1.07936, 0.21, 257.00, -0.21, -0.15},
        {600155, "GBPUSD", "buy", "2026.01.07 03:00:00", 1.27293, 1, 1.40, "2026.01.08 11:00:00", 1.27310, 0.65, 11.00, -0.65, -0.01},
        {600155, "GBPUSD", "buy", "2026.01.07 03:00:00", 1.27293, 1, 1.40, "2026.01.08 16:00:00", 1.27360, 0.75, 50.00, -0.75, -0.35},
        {600156, "EURUSD", "sell", "2026.01.07 16:00:00", 1.08292, 1, 0.40, "2026.01.08 10:00:00", 1.06835, 0.21, 306.00, -0.21, -0.41},
        {600156, "EURUSD", "sell", "2026.01.07 16:00:00", 1.08292, 1, 0.40, "2026.01.09 06:00:00", 1.08750, 0.19, -87.00, -0.19, -0.59},
        {600157, "GBPUSD", "sell", "2026.01.08 03:00:00", 1.25720, 1, 1.20, "2026.01.09 05:00:00", 1.25593, 0.55, 70.00, -0.55, -0.25},
        {600157, "GBPUSD", "sell", "2026.01.08 03:00:00", 1.25720, 1, 1.20, "2026.01.09 14:00:00", 1.25811, 0.65, -59.00, -0.65, -0.47},
        {600158, "EURUSD", "buy", "2026.01.08 15:00:00", 1.08643, 1, 0.80, "2026.01.09 17:00:00", 1.08592, 0.43, -22.00, -0.43, -0.15},
        {600158, "EURUSD", "buy", "2026.01.08 15:00:00", 1.08643, 1, 0.80, "2026.01.09 23:00:00", 1.08894, 0.37, 93.00, -0.37, -0.30},
        {600159, "GBPUSD", "sell", "2026.01.08 23:00:00", 1.27462, 1, 1.20, "2026.01.09 16:00:00", 1.27382, 0.60, 48.00, -0.60, -0.03},
        {600159, "GBPUSD", "sell", "2026.01.08 23:00:00", 1.27462, 1, 1.20, "2026.01.10 00:00:00", 1.27007, 0.60, 273.00, -0.60, -0.21},
        {600160, "EURUSD", "buy", "2026.01.09 11:00:00", 1.08855, 1, 1.00, "2026.01.10 11:00:00", 1.09171, 0.57, 180.00, -0.57, -0.14},
        {600160, "EURUSD", "buy", "2026.01.09 11:00:00", 1.08855, 1, 1.00, "2026.01.11 04:00:00", 1.08688, 0.43, -72.00, -0.43, -0.53},
        {600161, "GBPUSD", "sell", "2026.01.10 03:00:00", 1.25980, 1, 1.00, "2026.01.11 06:00:00", 1.25852, 0.60, 77.00, -0.60, -0.49},
        {600161, "GBPUSD", "sell", "2026.01.10 03:00:00", 1.25980, 1, 1.00, "2026.01.11 19:00:00", 1.25920, 0.40, 24.00, -0.40, -0.17},
        {600162, "EURUSD", "buy", "2026.01.10 13:00:00", 1.08437, 1, 0.50, "2026.01.11 00:00:00", 1.08424, 0.23, -3.00, -0.23, -0.20},
        {600162, "EURUSD", "buy", "2026.01.10 13:00:00", 1.08437, 1, 0.50, "2026.01.11 13:00:00", 1.09500, 0.27, 287.00, -0.27, -0.11},
        {600163, "GBPUSD", "sell", "2026.01.11 00:00:00", 1.25980, 1, 1.40, "2026.01.12 05:00:00", 1.25898, 0.45, 37.00, -0.45, -0.27},
        {600163, "GBPUSD", "sell", "2026.01.11 00:00:00", 1.25980, 1, 1.40, "2026.01.12 18:00:00", 1.25828, 0.40, 61.00, -0.40, -0.04},
        {600163, "GBPUSD", "sell", "2026.01.11 00:00:00", 1.25980, 1, 1.40, "2026.01.13 01:00:00", 1.25518, 0.55, 254.00, -0.55, -0.35},
        {600164, "EURUSD", "buy", "2026.01.11 19:00:00", 1.08846, 1, 0.60, "2026.01.12 10:00:00", 1.09646, 0.35, 280.00, -0.35, -0.11},
        {600164, "EURUSD", "buy", "2026.01.11 19:00:00", 1.08846, 1, 0.60, "2026.01.12 20:00:00", 1.08902, 0.25, 14.00, -0.25, -0.45},
        {600165, "GBPUSD", "sell", "2026.01.12 13:00:00", 1.27477, 1, 0.80, "2026.01.13 02:00:00", 1.27498, 0.48, -10.00, -0.48, -0.38},
        {600165, "GBPUSD", "sell", "2026.01.12 13:00:00", 1.27477, 1, 0.80, "2026.01.14 01:00:00", 1.26593, 0.32, 283.00, -0.32, -0.19},
        {600166, "EURUSD", "sell", "2026.01.13 03:00:00", 1.08122, 1, 0.50, "2026.01.14 14:00:00", 1.07855, 0.24, 64.00, -0.24, -0.39},
        {600166, "EURUSD", "sell", "2026.01.13 03:00:00", 1.08122, 1, 0.50, "2026.01.15 17:00:00", 1.07314, 0.26, 210.00, -0.26, -0.21},
        {600167, "GBPUSD", "buy", "2026.01.13 09:00:00", 1.25909, 1, 0.30, "2026.01.14 11:00:00", 1.27059, 0.14, 161.00, -0.14, -0.05},
        {600167, "GBPUSD", "buy", "2026.01.13 09:00:00", 1.25909, 1, 0.30, "2026.01.14 22:00:00", 1.26003, 0.16, 15.00, -0.16, -0.25},
        {600168, "EURUSD", "sell", "2026.01.13 21:00:00", 1.08765, 1, 0.40, "2026.01.14 21:00:00", 1.08536, 0.21, 48.00, -0.21, -0.15},
        {600168, "EURUSD", "sell", "2026.01.13 21:00:00", 1.08765, 1, 0.40, "2026.01.16 05:00:00", 1.08876, 0.19, -21.00, -0.19, -0.13},
        {600169, "GBPUSD", "sell", "2026.01.14 15:00:00", 1.27381, 1, 0.40, "2026.01.15 20:00:00", 1.27320, 0.23, 14.00, -0.23, -0.04},
        {600169, "GBPUSD", "sell", "2026.01.14 15:00:00", 1.27381, 1, 0.40, "2026.01.16 10:00:00", 1.26705, 0.17, 115.00, -0.17, -0.40},
        {600170, "EURUSD", "buy", "2026.01.15 05:00:00", 1.07528, 1, 0.40, "2026.01.15 23:00:00", 1.07493, 0.20, -7.00, -0.20, -0.23},
        {600170, "EURUSD", "buy", "2026.01.15 05:00:00", 1.07528, 1, 0.40, "2026.01.16 16:00:00", 1.07673, 0.20, 29.00, -0.20, -0.05},
        {600171, "GBPUSD", "buy", "2026.01.15 12:00:00", 1.26793, 1, 0.80, "2026.01.16 02:00:00", 1.26849, 0.25, 14.00, -0.25, -0.21},
        {600171, "GBPUSD", "buy", "2026.01.15 12:00:00", 1.26793, 1, 0.80, "2026.01.17 00:00:00", 1.26929, 0.28, 38.00, -0.28, -0.15},
        {600171, "GBPUSD", "buy", "2026.01.15 12:00:00", 1.26793, 1, 0.80, "2026.01.18 10:00:00", 1.26923, 0.27, 35.00, -0.27, -0.16},
        {600172, "EURUSD", "sell", "2026.01.15 22:00:00", 1.09486, 1, 0.50, "2026.01.16 05:00:00", 1.08231, 0.20, 251.00, -0.20, -0.02},
        {600172, "EURUSD", "sell", "2026.01.15 22:00:00", 1.09486, 1, 0.50, "2026.01.17 14:00:00", 1.09453, 0.30, 10.00, -0.30, -0.11},
        {600173, "GBPUSD", "sell", "2026.01.16 15:00:00", 1.27358, 1, 1.00, "2026.01.16 23:00:00", 1.26926, 0.47, 203.00, -0.47, -0.47},
        {600173, "GBPUSD", "sell", "2026.01.16 15:00:00", 1.27358, 1, 1.00, "2026.01.18 03:00:00", 1.27498, 0.53, -74.00, -0.53, -0.48},
        {600174, "EURUSD", "buy", "2026.01.17 11:00:00", 1.09483, 1, 1.40, "2026.01.18 16:00:00", 1.09816, 0.51, 170.00, -0.51, -0.15},
        {600174, "EURUSD", "buy", "2026.01.17 11:00:00", 1.09483, 1, 1.40, "2026.01.18 19:00:00", 1.09422, 0.46, -28.00, -0.46, -0.20},
        {600174, "EURUSD", "buy", "2026.01.17 11:00:00", 1.09483, 1, 1.40, "2026.01.19 00:00:00", 1.09402, 0.43, -35.00, -0.43, -0.36},
        {600175, "GBPUSD", "sell", "2026.01.17 23:00:00", 1.25582, 1, 1.00, "2026.01.18 09:00:00", 1.25342, 0.47, 113.00, -0.47, -0.12},
        {600175, "GBPUSD", "sell", "2026.01.17 23:00:00", 1.25582, 1, 1.00, "2026.01.19 16:00:00", 1.25422, 0.53, 85.00, -0.53, -0.35},
        {600176, "EURUSD", "sell", "2026.01.18 17:00:00", 1.07908, 1, 1.40, "2026.01.19 01:00:00", 1.07557, 0.72, 253.00, -0.72, -0.30},
        {600176, "EURUSD", "sell", "2026.01.18 17:00:00", 1.07908, 1, 1.40, "2026.01.19 10:00:00", 1.08004, 0.68, -65.00, -0.68, -0.50},
        {600177, "GBPUSD", "buy", "2026.01.19 03:00:00", 1.25618, 1, 0.80, "2026.01.20 01:00:00", 1.25888, 0.43, 116.00, -0.43, -0.47},
        {600177, "GBPUSD", "buy", "2026.01.19 03:00:00", 1.25618, 1, 0.80, "2026.01.20 22:00:00", 1.25515, 0.37, -38.00, -0.37, -0.13},
        {600178, "EURUSD", "buy", "2026.01.19 19:00:00", 1.07651, 1, 1.40, "2026.01.19 22:00:00", 1.07597, 0.80, -43.00, -0.80, -0.45},
        {600178, "EURUSD", "buy", "2026.01.19 19:00:00", 1.07651, 1, 1.40, "2026.01.20 20:00:00", 1.07776, 0.60, 75.00, -0.60, -0.40},
        {600179, "GBPUSD", "sell", "2026.01.20 03:00:00", 1.27376, 1, 1.00, "2026.01.21 04:00:00", 1.26786, 0.48, 283.00, -0.48, -0.12},
        {600179, "GBPUSD", "sell", "2026.01.20 03:00:00", 1.27376, 1, 1.00, "2026.01.21 15:00:00", 1.27441, 0.52, -34.00, -0.52, -0.49},
        {600180, "EURUSD", "buy", "2026.01.20 18:00:00", 1.09443, 1, 1.40, "2026.01.21 01:00:00", 1.09933, 0.58, 284.00, -0.58, -0.31},
        {600180, "EURUSD", "buy", "2026.01.20 18:00:00", 1.09443, 1, 1.40, "2026.01.21 09:00:00", 1.09360, 0.82, -68.00, -0.82, -0.42},
        {600181, "GBPUSD", "sell", "2026.01.21 14:00:00", 1.26963, 1, 1.40, "2026.01.21 21:00:00", 1.26906, 0.70, 40.00, -0.70, -0.05},
        {600181, "GBPUSD", "sell", "2026.01.21 14:00:00", 1.26963, 1, 1.40, "2026.01.22 08:00:00", 1.27027, 0.70, -45.00, -0.70, -0.27},
        {600182, "EURUSD", "sell", "2026.01.22 08:00:00", 1.08227, 1, 0.60, "2026.01.23 04:00:00", 1.07306, 0.29, 267.00, -0.29, -0.02},
        {600182, "EURUSD", "sell", "2026.01.22 08:00:00", 1.08227, 1, 0.60, "2026.01.24 04:00:00", 1.08395, 0.31, -52.00, -0.31, -0.59},
        {600183, "GBPUSD", "sell", "2026.01.22 22:00:00", 1.25995, 1, 0.30, "2026.01.23 00:00:00", 1.25408, 0.15, 88.00, -0.15, -0.20},
        {600183, "GBPUSD", "sell", "2026.01.22 22:00:00", 1.25995, 1, 0.30, "2026.01.24 11:00:00", 1.26302, 0.15, -46.00, -0.15, -0.38},
        {600184, "EURUSD", "sell", "2026.01.23 15:00:00", 1.08465, 1, 0.50, "2026.01.24 18:00:00", 1.07851, 0.28, 172.00, -0.28, -0.18},
        {600184, "EURUSD", "sell", "2026.01.23 15:00:00", 1.08465, 1, 0.50, "2026.01.25 08:00:00", 1.08642, 0.22, -39.00, -0.22, -0.49},
        {600185, "GBPUSD", "sell", "2026.01.23 23:00:00", 1.25651, 1, 1.20, "2026.01.25 03:00:00", 1.25556, 0.55, 52.00, -0.55, -0.39},
        {600185, "GBPUSD", "sell", "2026.01.23 23:00:00", 1.25651, 1, 1.20, "2026.01.25 14:00:00", 1.25625, 0.65, 17.00, -0.65, -0.01},
        {600186, "EURUSD", "buy", "2026.01.24 16:00:00", 1.09348, 1, 1.40, "2026.01.25 03:00:00", 1.09940, 0.53, 314.00, -0.53, -0.35},
        {600186, "EURUSD", "buy", "2026.01.24 16:00:00", 1.09348, 1, 1.40, "2026.01.26 09:00:00", 1.09251, 0.37, -36.00, -0.37, -0.31},
        {600186, "EURUSD", "buy", "2026.01.24 16:00:00", 1.09348, 1, 1.40, "2026.01.27 07:00:00", 1.09252, 0.50, -48.00, -0.50, -0.08},
        {600187, "GBPUSD", "buy", "2026.01.25 07:00:00", 1.26721, 1, 0.70, "2026.01.25 21:00:00", 1.27636, 0.33, 302.00, -0.33, -0.60},
        {600187, "GBPUSD", "buy", "2026.01.25 07:00:00", 1.26721, 1, 0.70, "2026.01.27 06:00:00", 1.26778, 0.37, 21.00, -0.37, -0.19},
        {600188, "EURUSD", "sell", "2026.01.26 02:00:00", 1.07897, 1, 1.00, "2026.01.26 16:00:00", 1.07565, 0.44, 146.00, -0.44, -0.09},
        {600188, "EURUSD", "sell", "2026.01.26 02:00:00", 1.07897, 1, 1.00, "2026.01.27 05:00:00", 1.07843, 0.56, 30.00, -0.56, -0.13},
        {600189, "GBPUSD", "buy", "2026.01.26 12:00:00", 1.25674, 1, 0.30, "2026.01.26 22:00:00", 1.27221, 0.15, 232.00, -0.15, -0.04},
        {600189, "GBPUSD", "buy", "2026.01.26 12:00:00", 1.25674, 1, 0.30, "2026.01.27 12:00:00", 1.25527, 0.15, -22.00, -0.15, -0.40},
        {600190, "EURUSD", "buy", "2026.01.27 08:00:00", 1.09118, 1, 0.40, "2026.01.28 20:00:00", 1.08894, 0.17, -38.00, -0.17, -0.48},
        {600190, "EURUSD", "buy", "2026.01.27 08:00:00", 1.09118, 1, 0.40, "2026.01.29 21:00:00", 1.09622, 0.23, 116.00, -0.23, -0.21},
        {600191, "GBPUSD", "buy", "2026.01.28 00:00:00", 1.26341, 1, 0.30, "2026.01.29 10:00:00", 1.26365, 0.17, 4.00, -0.17, -0.06},
        {600191, "GBPUSD", "buy", "2026.01.28 00:00:00", 1.26341, 1, 0.30, "2026.01.30 01:00:00", 1.26256, 0.13, -11.00, -0.13, -0.31},
        {600192, "EURUSD", "sell", "2026.01.28 09:00:00", 1.07762, 1, 1.00, "2026.01.28 21:00:00", 1.07192, 0.54, 308.00, -0.54, -0.14},
        {600192, "EURUSD", "sell", "2026.01.28 09:00:00", 1.07762, 1, 1.00, "2026.01.29 13:00:00", 1.07938, 0.46, -81.00, -0.46, -0.11},
        {600193, "GBPUSD", "buy", "2026.01.28 16:00:00", 1.26655, 1, 0.40, "2026.01.29 11:00:00", 1.26877, 0.23, 51.00, -0.23, -0.33},
        {600193, "GBPUSD", "buy", "2026.01.28 16:00:00", 1.26655, 1, 0.40, "2026.01.30 06:00:00", 1.27849, 0.17, 203.00, -0.17, -0.41},
        {600194, "EURUSD", "sell", "2026.01.29 01:00:00", 1.09111, 1, 1.20, "2026.01.30 11:00:00", 1.09024, 0.71, 62.00, -0.71, -0.04},
        {600194, "EURUSD", "sell", "2026.01.29 01:00:00", 1.09111, 1, 1.20, "2026.01.31 06:00:00", 1.08866, 0.49, 120.00, -0.49, -0.06},
        {600195, "GBPUSD", "sell", "2026.01.29 18:00:00", 1.26388, 1, 0.80, "2026.01.31 01:00:00", 1.26047, 0.39, 133.00, -0.39, -0.32},
        {600195, "GBPUSD", "sell", "2026.01.29 18:00:00", 1.26388, 1, 0.80, "2026.02.01 06:00:00", 1.26520, 0.41, -54.00, -0.41, -0.13},
        {600196, "EURUSD", "buy", "2026.01.30 01:00:00", 1.07690, 1, 0.40, "2026.01.31 00:00:00", 1.07734, 0.16, 7.00, -0.16, -0.32},
        {600196, "EURUSD", "buy", "2026.01.30 01:00:00", 1.07690, 1, 0.40, "2026.01.31 11:00:00", 1.07344, 0.13, -45.00, -0.13, -0.16},
        {600196, "EURUSD", "buy", "2026.01.30 01:00:00", 1.07690, 1, 0.40, "2026.01.31 18:00:00", 1.08408, 0.11, 79.00, -0.11, -0.36},
        {600197, "GBPUSD", "buy", "2026.01.30 20:00:00", 1.27009, 1, 0.80, "2026.01.31 19:00:00", 1.27323, 0.43, 135.00, -0.43, -0.44},
        {600197, "GBPUSD", "buy", "2026.01.30 20:00:00", 1.27009, 1, 0.80, "2026.02.01 14:00:00", 1.26787, 0.37, -82.00, -0.37, -0.01},
        {600198, "EURUSD", "buy", "2026.01.31 10:00:00", 1.08008, 1, 1.00, "2026.01.31 14:00:00", 1.08030, 0.59, 13.00, -0.59, -0.11},
        {600198, "EURUSD", "buy", "2026.01.31 10:00:00", 1.08008, 1, 1.00, "2026.02.02 00:00:00", 1.08271, 0.41, 108.00, -0.41, -0.40},
        {600199, "GBPUSD", "buy", "2026.02.01 02:00:00", 1.26816, 1, 0.80, "2026.02.01 19:00:00", 1.26895, 0.28, 22.00, -0.28, -0.32},
        {600199, "GBPUSD", "buy", "2026.02.01 02:00:00", 1.26816, 1, 0.80, "2026.02.02 14:00:00", 1.27109, 0.27, 79.00, -0.27, -0.40},
        {600199, "GBPUSD", "buy", "2026.02.01 02:00:00", 1.26816, 1, 0.80, "2026.02.02 20:00:00", 1.27292, 0.25, 119.00, -0.25, -0.16},
        {600200, "EURUSD", "buy", "2026.02.01 12:00:00", 1.08969, 1, 0.50, "2026.02.02 09:00:00", 1.09007, 0.29, 11.00, -0.29, -0.11},
        {600200, "EURUSD", "buy", "2026.02.01 12:00:00", 1.08969, 1, 0.50, "2026.02.03 13:00:00", 1.09012, 0.21, 9.00, -0.21, -0.30},
        {600201, "GBPUSD", "buy", "2026.02.02 06:00:00", 1.25814, 1, 0.70, "2026.02.02 20:00:00", 1.25977, 0.38, 62.00, -0.38, -0.26},
        {600201, "GBPUSD", "buy", "2026.02.02 06:00:00", 1.25814, 1, 0.70, "2026.02.04 07:00:00", 1.26139, 0.32, 104.00, -0.32, -0.47},
        {600202, "EURUSD", "sell", "2026.02.02 14:00:00", 1.08685, 1, 0.40, "2026.02.02 19:00:00", 1.08568, 0.24, 28.00, -0.24, -0.35},
        {600202, "EURUSD", "sell", "2026.02.02 14:00:00", 1.08685, 1, 0.40, "2026.02.03 05:00:00", 1.08123, 0.16, 90.00, -0.16, -0.32},
        {600203, "GBPUSD", "sell", "2026.02.03 04:00:00", 1.26464, 1, 0.70, "2026.02.03 11:00:00", 1.25496, 0.34, 329.00, -0.34, -0.17},
        {600203, "GBPUSD", "sell", "2026.02.03 04:00:00", 1.26464, 1, 0.70, "2026.02.04 00:00:00", 1.26385, 0.24, 19.00, -0.24, -0.06},
        {600203, "GBPUSD", "sell", "2026.02.03 04:00:00", 1.26464, 1, 0.70, "2026.02.04 08:00:00", 1.27031, 0.12, -68.00, -0.12, -0.36},
        {600204, "EURUSD", "sell", "2026.02.03 12:00:00", 1.07643, 1, 0.80, "2026.02.04 17:00:00", 1.06814, 0.34, 282.00, -0.34, -0.47},
        {600204, "EURUSD", "sell", "2026.02.03 12:00:00", 1.07643, 1, 0.80, "2026.02.05 02:00:00", 1.07815, 0.46, -79.00, -0.46, -0.32},
        {600205, "GBPUSD", "buy", "2026.02.04 01:00:00", 1.26920, 1, 0.50, "2026.02.05 13:00:00", 1.27420, 0.22, 110.00, -0.22, -0.34},
        {600205, "GBPUSD", "buy", "2026.02.04 01:00:00", 1.26920, 1, 0.50, "2026.02.06 04:00:00", 1.26809, 0.28, -31.00, -0.28, -0.45},
        {600206, "EURUSD", "buy", "2026.02.04 18:00:00", 1.07599, 1, 1.00, "2026.02.05 12:00:00", 1.07499, 0.50, -50.00, -0.50, -0.09},
        {600206, "EURUSD", "buy", "2026.02.04 18:00:00", 1.07599, 1, 1.00, "2026.02.06 04:00:00", 1.07705, 0.50, 53.00, -0.50, -0.03},
        {600207, "GBPUSD", "sell", "2026.02.05 14:00:00", 1.25806, 1, 1.00, "2026.02.06 00:00:00", 1.25879, 0.44, -32.00, -0.44, -0.11},
        {600207, "GBPUSD", "sell", "2026.02.05 14:00:00", 1.25806, 1, 1.00, "2026.02.07 10:00:00", 1.25667, 0.56, 78.00, -0.56, -0.16},
        {600208, "EURUSD", "sell", "2026.02.06 07:00:00", 1.09439, 1, 1.20, "2026.02.07 08:00:00", 1.09241, 0.64, 127.00, -0.64, -0.45},
        {600208, "EURUSD", "sell", "2026.02.06 07:00:00", 1.09439, 1, 1.20, "2026.02.08 04:00:00", 1.09539, 0.56, -56.00, -0.56, -0.42},
        {600209, "GBPUSD", "buy", "2026.02.06 18:00:00", 1.26379, 1, 0.50, "2026.02.07 21:00:00", 1.26784, 0.20, 81.00, -0.20, -0.40},
        {600209, "GBPUSD", "buy", "2026.02.06 18:00:00", 1.26379, 1, 0.50, "2026.02.08 17:00:00", 1.26950, 0.17, 97.00, -0.17, -0.16},
        {600209, "GBPUSD", "buy", "2026.02.06 18:00:00", 1.26379, 1, 0.50, "2026.02.09 13:00:00", 1.26625, 0.13, 32.00, -0.13, -0.10},
        {600210, "EURUSD", "sell", "2026.02.07 03:00:00", 1.07858, 1, 1.40, "2026.02.07 09:00:00", 1.07569, 0.82, 237.00, -0.82, -0.57},
        {600210, "EURUSD", "sell", "2026.02.07 03:00:00", 1.07858, 1, 1.40, "2026.02.07 23:00:00", 1.07884, 0.58, -15.00, -0.58, -0.31},
        {600211, "GBPUSD", "sell", "2026.02.07 21:00:00", 1.26161, 1, 1.00, "2026.02.08 10:00:00", 1.26124, 0.51, 19.00, -0.51, -0.48},
        {600211, "GBPUSD", "sell", "2026.02.07 21:00:00", 1.26161, 1, 1.00, "2026.02.09 22:00:00", 1.26018, 0.49, 70.00, -0.49, -0.28},
        {600212, "EURUSD", "sell", "2026.02.08 11:00:00", 1.07689, 1, 0.30, "2026.02.09 14:00:00", 1.06571, 0.17, 190.00, -0.17, -0.43},
        {600212, "EURUSD", "sell", "2026.02.08 11:00:00", 1.07689, 1, 0.30, "2026.02.10 19:00:00", 1.07704, 0.13, -2.00, -0.13, -0.20},
        {600213, "GBPUSD", "sell", "2026.02.09 04:00:00", 1.26810, 1, 1.00, "2026.02.09 07:00:00", 1.26844, 0.47, -16.00, -0.47, -0.12},
        {600213, "GBPUSD", "sell", "2026.02.09 04:00:00", 1.26810, 1, 1.00, "2026.02.10 07:00:00", 1.26246, 0.53, 299.00, -0.53, -0.33},
        {600214, "EURUSD", "sell", "2026.02.09 19:00:00", 1.08579, 1, 0.80, "2026.02.10 09:00:00", 1.08026, 0.45, 249.00, -0.45, -0.20},
        {600214, "EURUSD", "sell", "2026.02.09 19:00:00", 1.08579, 1, 0.80, "2026.02.11 18:00:00", 1.08805, 0.35, -79.00, -0.35, -0.11},
        {600215, "GBPUSD", "sell", "2026.02.10 13:00:00", 1.26395, 1, 0.30, "2026.02.10 18:00:00", 1.26188, 0.15, 31.00, -0.15, -0.40},
        {600215, "GBPUSD", "sell", "2026.02.10 13:00:00", 1.26395, 1, 0.30, "2026.02.12 04:00:00", 1.25775, 0.15, 93.00, -0.15, -0.12},
        {600216, "EURUSD", "buy", "2026.02.10 23:00:00", 1.09301, 1, 1.00, "2026.02.12 09:00:00", 1.09667, 0.50, 183.00, -0.50, -0.04},
        {600216, "EURUSD", "buy", "2026.02.10 23:00:00", 1.09301, 1, 1.00, "2026.02.13 21:00:00", 1.09175, 0.50, -63.00, -0.50, -0.47},
        {600217, "GBPUSD", "sell", "2026.02.11 11:00:00", 1.26192, 1, 0.40, "2026.02.12 08:00:00", 1.25582, 0.21, 128.00, -0.21, -0.57},
        {600217, "GBPUSD", "sell", "2026.02.11 11:00:00", 1.26192, 1, 0.40, "2026.02.13 20:00:00", 1.26345, 0.19, -29.00, -0.19, -0.11},
        {600218, "EURUSD", "buy", "2026.02.12 05:00:00", 1.08188, 1, 0.80, "2026.02.13 14:00:00", 1.09115, 0.33, 306.00, -0.33, -0.30},
        {600218, "EURUSD", "buy", "2026.02.12 05:00:00", 1.08188, 1, 0.80, "2026.02.14 08:00:00", 1.08248, 0.25, 15.00, -0.25, -0.11},
        {600218, "EURUSD", "buy", "2026.02.12 05:00:00", 1.08188, 1, 0.80, "2026.02.14 13:00:00", 1.08120, 0.22, -15.00, -0.22, -0.20},
        {600219, "GBPUSD", "sell", "2026.02.12 12:00:00", 1.26178, 1, 1.40, "2026.02.13 12:00:00", 1.26189, 0.70, -8.00, -0.70, -0.08},
        {600219, "GBPUSD", "sell", "2026.02.12 12:00:00", 1.26178, 1, 1.40, "2026.02.14 23:00:00", 1.26172, 0.70, 4.00, -0.70, -0.24},
        {600220, "EURUSD", "buy", "2026.02.12 19:00:00", 1.07598, 1, 0.30, "2026.02.13 15:00:00", 1.07962, 0.14, 51.00, -0.14, -0.22},
        {600220, "EURUSD", "buy", "2026.02.12 19:00:00", 1.07598, 1, 0.30, "2026.02.14 09:00:00", 1.07235, 0.16, -58.00, -0.16, -0.45},
        {700001, "EURUSD", "buy", "2026.02.13 11:00:00", 1.09099, 1, 1.00, "2026.02.14 11:00:00", 1.09274, 1.00, 175.00, -1.00, -0.03},
        {700002, "GBPUSD", "sell", "2026.02.13 21:00:00", 1.27090, 1, 1.00, "2026.02.14 08:00:00", 1.27000, 1.00, 90.00, -1.00, 0.00},
        {700003, "EURUSD", "buy", "2026.02.14 11:00:00", 1.08695, 1, 0.60, "2026.02.15 00:00:00", 1.08772, 0.60, 46.00, -0.60, 0.00},
        {700004, "GBPUSD", "sell", "2026.02.14 22:00:00", 1.26257, 1, 0.40, "2026.02.15 04:00:00", 1.26215, 0.40, 17.00, -0.40, -0.13},
        {700005, "EURUSD", "buy", "2026.02.15 08:00:00", 1.08574, 1, 1.00, "2026.02.15 19:00:00", 1.08561, 1.00, -13.00, -1.00, 0.00},
        {700006, "GBPUSD", "sell", "2026.02.15 15:00:00", 1.25825, 1, 0.80, "2026.02.16 15:00:00", 1.25775, 0.80, 40.00, -0.80, 0.00},
        {700007, "EURUSD", "buy", "2026.02.15 19:00:00", 1.09161, 1, 0.30, "2026.02.16 04:00:00", 1.09444, 0.30, 85.00, -0.30, -0.21},
        {700008, "GBPUSD", "sell", "2026.02.15 22:00:00", 1.26210, 1, 0.70, "2026.02.16 19:00:00", 1.26049, 0.70, 113.00, -0.70, 0.00},
        {700009, "EURUSD", "buy", "2026.02.16 06:00:00", 1.08312, 1, 0.50, "2026.02.16 08:00:00", 1.08406, 0.50, 47.00, -0.50, 0.00},
        {700010, "GBPUSD", "sell", "2026.02.16 19:00:00", 1.26275, 1, 0.50, "2026.02.17 17:00:00", 1.26181, 0.50, 47.00, -0.50, -0.29},
        {700011, "EURUSD", "buy", "2026.02.17 07:00:00", 1.09145, 1, 0.30, "2026.02.17 10:00:00", 1.09325, 0.30, 54.00, -0.30, 0.00},
        {700012, "GBPUSD", "sell", "2026.02.17 18:00:00", 1.26966, 1, 0.30, "2026.02.18 09:00:00", 1.26596, 0.30, 111.00, -0.30, 0.00},
        {700013, "EURUSD", "buy", "2026.02.18 03:00:00", 1.08137, 1, 0.50, "2026.02.18 10:00:00", 1.08105, 0.50, -16.00, -0.50, -0.20},
        {700014, "GBPUSD", "sell", "2026.02.18 13:00:00", 1.25742, 1, 1.00, "2026.02.19 07:00:00", 1.25750, 1.00, -8.00, -1.00, 0.00},
        {700015, "EURUSD", "buy", "2026.02.18 16:00:00", 1.08526, 1, 0.30, "2026.02.18 21:00:00", 1.08943, 0.30, 125.00, -0.30, 0.00},
        {700016, "GBPUSD", "sell", "2026.02.19 05:00:00", 1.26345, 1, 1.00, "2026.02.19 11:00:00", 1.26392, 1.00, -47.00, -1.00, -0.19},
        {700017, "EURUSD", "buy", "2026.02.19 14:00:00", 1.09307, 1, 0.80, "2026.02.20 07:00:00", 1.09254, 0.80, -42.00, -0.80, 0.00},
        {700018, "GBPUSD", "sell", "2026.02.19 20:00:00", 1.25577, 1, 0.40, "2026.02.20 17:00:00", 1.25745, 0.40, -67.00, -0.40, 0.00},
        {700019, "EURUSD", "buy", "2026.02.20 02:00:00", 1.08157, 1, 0.60, "2026.02.21 01:00:00", 1.08292, 0.60, 81.00, -0.60, -0.01},
        {700020, "GBPUSD", "sell", "2026.02.20 10:00:00", 1.26877, 1, 0.60, "2026.02.21 06:00:00", 1.26992, 0.60, -69.00, -0.60, 0.00},
        {700021, "EURUSD", "buy", "2026.02.20 23:00:00", 1.08231, 1, 0.60, "2026.02.21 05:00:00", 1.08354, 0.60, 74.00, -0.60, 0.00},
        {700022, "GBPUSD", "sell", "2026.02.21 10:00:00", 1.25883, 1, 0.80, "2026.02.22 08:00:00", 1.25878, 0.80, 4.00, -0.80, -0.21},
        {700023, "EURUSD", "buy", "2026.02.21 13:00:00", 1.08321, 1, 0.80, "2026.02.21 22:00:00", 1.08341, 0.80, 16.00, -0.80, 0.00},
        {700024, "GBPUSD", "sell", "2026.02.21 20:00:00", 1.26569, 1, 0.60, "2026.02.22 12:00:00", 1.26354, 0.60, 129.00, -0.60, 0.00},
        {700025, "EURUSD", "buy", "2026.02.22 10:00:00", 1.07694, 1, 0.80, "2026.02.22 16:00:00", 1.07723, 0.80, 23.00, -0.80, -0.29},
        {700026, "GBPUSD", "sell", "2026.02.22 20:00:00", 1.26463, 1, 0.50, "2026.02.23 15:00:00", 1.26575, 0.50, -56.00, -0.50, 0.00},
        {700027, "EURUSD", "buy", "2026.02.23 08:00:00", 1.09288, 1, 0.60, "2026.02.24 01:00:00", 1.09416, 0.60, 77.00, -0.60, 0.00},
        {700028, "GBPUSD", "sell", "2026.02.23 16:00:00", 1.26800, 1, 0.80, "2026.02.24 16:00:00", 1.26887, 0.80, -70.00, -0.80, -0.29},
        {700029, "EURUSD", "buy", "2026.02.23 23:00:00", 1.08972, 1, 1.00, "2026.02.24 06:00:00", 1.09021, 1.00, 49.00, -1.00, 0.00},
        {700030, "GBPUSD", "sell", "2026.02.24 10:00:00", 1.25702, 1, 1.00, "2026.02.24 23:00:00", 1.25648, 1.00, 54.00, -1.00, 0.00},
        {700031, "EURUSD", "buy", "2026.02.24 14:00:00", 1.08311, 1, 0.50, "2026.02.25 06:00:00", 1.08413, 0.50, 51.00, -0.50, -0.29},
        {700032, "GBPUSD", "sell", "2026.02.25 04:00:00", 1.25538, 1, 0.70, "2026.02.26 00:00:00", 1.25572, 0.70, -24.00, -0.70, 0.00},
        {700033, "EURUSD", "buy", "2026.02.25 14:00:00", 1.08883, 1, 0.80, "2026.02.26 13:00:00", 1.08938, 0.80, 44.00, -0.80, 0.00},
        {700034, "GBPUSD", "sell", "2026.02.25 19:00:00", 1.25547, 1, 0.60, "2026.02.26 03:00:00", 1.25352, 0.60, 117.00, -0.60, -0.27},
        {700035, "EURUSD", "buy", "2026.02.26 01:00:00", 1.07527, 1, 0.40, "2026.02.26 14:00:00", 1.07352, 0.40, -70.00, -0.40, 0.00},
        {700036, "GBPUSD", "sell", "2026.02.26 05:00:00", 1.26336, 1, 0.40, "2026.02.26 20:00:00", 1.26631, 0.40, -118.00, -0.40, 0.00},
        {700037, "EURUSD", "buy", "2026.02.26 11:00:00", 1.07590, 1, 1.00, "2026.02.26 19:00:00", 1.07570, 1.00, -20.00, -1.00, -0.11},
        {700038, "GBPUSD", "sell", "2026.02.26 17:00:00", 1.27302, 1, 0.60, "2026.02.27 02:00:00", 1.27292, 0.60, 6.00, -0.60, 0.00},
        {700039, "EURUSD", "buy", "2026.02.26 22:00:00", 1.07753, 1, 1.00, "2026.02.27 16:00:00", 1.07826, 1.00, 73.00, -1.00, 0.00},
        {700040, "GBPUSD", "sell", "2026.02.27 09:00:00", 1.26297, 1, 0.40, "2026.02.27 17:00:00", 1.26350, 0.40, -21.00, -0.40, -0.24},
        {700041, "EURUSD", "buy", "2026.02.27 22:00:00", 1.09229, 1, 1.00, "2026.02.28 17:00:00", 1.09262, 1.00, 33.00, -1.00, 0.00},
        {700042, "GBPUSD", "sell", "2026.02.28 02:00:00", 1.26416, 1, 0.50, "2026.03.01 01:00:00", 1.25980, 0.50, 218.00, -0.50, 0.00},
        {700043, "EURUSD", "buy", "2026.02.28 10:00:00", 1.08116, 1, 1.00, "2026.03.01 05:00:00", 1.08138, 1.00, 22.00, -1.00, -0.15},
        {700044, "GBPUSD", "sell", "2026.02.28 21:00:00", 1.26819, 1, 0.80, "2026.03.01 04:00:00", 1.26729, 0.80, 72.00, -0.80, 0.00},
        {700045, "EURUSD", "buy", "2026.03.01 06:00:00", 1.08489, 1, 0.60, "2026.03.01 18:00:00", 1.08577, 0.60, 53.00, -0.60, 0.00},
        {700046, "GBPUSD", "sell", "2026.03.01 12:00:00", 1.25669, 1, 1.00, "2026.03.02 12:00:00", 1.25573, 1.00, 96.00, -1.00, -0.29},
        {700047, "EURUSD", "buy", "2026.03.01 17:00:00", 1.08157, 1, 0.70, "2026.03.01 23:00:00", 1.08154, 0.70, -2.00, -0.70, 0.00},
        {700048, "GBPUSD", "sell", "2026.03.02 03:00:00", 1.26189, 1, 1.00, "2026.03.02 09:00:00", 1.26229, 1.00, -40.00, -1.00, 0.00},
        {700049, "EURUSD", "buy", "2026.03.02 15:00:00", 1.08760, 1, 0.70, "2026.03.03 03:00:00", 1.08959, 0.70, 139.00, -0.70, -0.17},
        {700050, "GBPUSD", "sell", "2026.03.02 21:00:00", 1.26139, 1, 0.40, "2026.03.03 00:00:00", 1.25921, 0.40, 87.00, -0.40, 0.00},
        {700051, "EURUSD", "buy", "2026.03.03 09:00:00", 1.08385, 1, 0.40, "2026.03.03 21:00:00", 1.08280, 0.40, -42.00, -0.40, 0.00},
        {700052, "GBPUSD", "sell", "2026.03.03 14:00:00", 1.27309, 1, 0.70, "2026.03.03 23:00:00", 1.27386, 0.70, -54.00, -0.70, -0.27},
        {700053, "EURUSD", "buy", "2026.03.03 19:00:00", 1.07598, 1, 0.60, "2026.03.04 04:00:00", 1.07693, 0.60, 57.00, -0.60, 0.00},
        {700054, "GBPUSD", "sell", "2026.03.03 22:00:00", 1.27293, 1, 0.70, "2026.03.04 10:00:00", 1.27117, 0.70, 123.00, -0.70, 0.00},
        {700055, "EURUSD", "buy", "2026.03.04 12:00:00", 1.09216, 1, 0.30, "2026.03.04 20:00:00", 1.08893, 0.30, -97.00, -0.30, -0.02},
        {700056, "GBPUSD", "sell", "2026.03.04 15:00:00", 1.27350, 1, 0.30, "2026.03.04 22:00:00", 1.27287, 0.30, 19.00, -0.30, 0.00},
        {700057, "EURUSD", "buy", "2026.03.04 23:00:00", 1.08362, 1, 0.60, "2026.03.05 04:00:00", 1.08254, 0.60, -65.00, -0.60, 0.00},
        {700058, "GBPUSD", "sell", "2026.03.05 09:00:00", 1.26931, 1, 0.70, "2026.03.05 20:00:00", 1.26638, 0.70, 205.00, -0.70, -0.01},
        {700059, "EURUSD", "buy", "2026.03.05 14:00:00", 1.08367, 1, 0.70, "2026.03.06 12:00:00", 1.08373, 0.70, 4.00, -0.70, 0.00},
        {700060, "GBPUSD", "sell", "2026.03.05 19:00:00", 1.25819, 1, 0.50, "2026.03.06 11:00:00", 1.25699, 0.50, 60.00, -0.50, 0.00},
        {700061, "EURUSD", "buy", "2026.03.06 04:00:00", 1.07929, 1, 0.50, "2026.03.06 06:00:00", 1.07877, 0.50, -26.00, -0.50, -0.19},
        {700062, "GBPUSD", "sell", "2026.03.06 07:00:00", 1.26351, 1, 1.00, "2026.03.06 18:00:00", 1.26416, 1.00, -65.00, -1.00, 0.00},
        {700063, "EURUSD", "buy", "2026.03.06 12:00:00", 1.08157, 1, 0.60, "2026.03.07 05:00:00", 1.08310, 0.60, 92.00, -0.60, 0.00},
        {700064, "GBPUSD", "sell", "2026.03.06 21:00:00", 1.26329, 1, 0.30, "2026.03.07 01:00:00", 1.26149, 0.30, 54.00, -0.30, -0.24},
        {700065, "EURUSD", "buy", "2026.03.07 03:00:00", 1.08698, 1, 0.40, "2026.03.07 16:00:00", 1.08720, 0.40, 9.00, -0.40, 0.00},
        {700066, "GBPUSD", "sell", "2026.03.07 09:00:00", 1.26049, 1, 0.60, "2026.03.08 00:00:00", 1.26131, 0.60, -49.00, -0.60, 0.00},
        {700067, "EURUSD", "buy", "2026.03.07 19:00:00", 1.08080, 1, 1.00, "2026.03.08 08:00:00", 1.08243, 1.00, 163.00, -1.00, -0.14},
        {700068, "GBPUSD", "sell", "2026.03.08 09:00:00", 1.26829, 1, 0.70, "2026.03.09 02:00:00", 1.26558, 0.70, 190.00, -0.70, 0.00},
        {700069, "EURUSD", "buy", "2026.03.08 18:00:00", 1.09041, 1, 0.30, "2026.03.09 06:00:00", 1.08881, 0.30, -48.00, -0.30, 0.00},
        {700070, "GBPUSD", "sell", "2026.03.09 07:00:00", 1.25683, 1, 0.40, "2026.03.10 01:00:00", 1.25823, 0.40, -56.00, -0.40, -0.00},
        {700071, "EURUSD", "buy", "2026.03.09 21:00:00", 1.07950, 1, 1.00, "2026.03.10 21:00:00", 1.08041, 1.00, 91.00, -1.00, 0.00},
        {700072, "GBPUSD", "sell", "2026.03.10 10:00:00", 1.26130, 1, 1.00, "2026.03.10 18:00:00", 1.25910, 1.00, 220.00, -1.00, 0.00},
        {700073, "EURUSD", "buy", "2026.03.10 14:00:00", 1.09297, 1, 0.70, "2026.03.11 01:00:00", 1.09270, 0.70, -19.00, -0.70, -0.26},
        {700074, "GBPUSD", "sell", "2026.03.10 22:00:00", 1.25711, 1, 1.00, "2026.03.11 17:00:00", 1.25670, 1.00, 41.00, -1.00, 0.00},
        {700075, "EURUSD", "buy", "2026.03.11 07:00:00", 1.08457, 1, 0.30, "2026.03.11 16:00:00", 1.08767, 0.30, 93.00, -0.30, 0.00},
        {700076, "GBPUSD", "sell", "2026.03.11 21:00:00", 1.27000, 1, 0.40, "2026.03.12 02:00:00", 1.27212, 0.40, -85.00, -0.40, -0.12},
        {700077, "EURUSD", "buy", "2026.03.12 11:00:00", 1.08331, 1, 0.50, "2026.03.13 09:00:00", 1.08593, 0.50, 131.00, -0.50, 0.00},
        {700078, "GBPUSD", "sell", "2026.03.12 21:00:00", 1.25873, 1, 0.60, "2026.03.13 04:00:00", 1.25800, 0.60, 44.00, -0.60, 0.00},
        {700079, "EURUSD", "buy", "2026.03.13 00:00:00", 1.08881, 1, 0.70, "2026.03.13 10:00:00", 1.09021, 0.70, 98.00, -0.70, -0.27},
        {700080, "GBPUSD", "sell", "2026.03.13 07:00:00", 1.27300, 1, 0.60, "2026.03.14 01:00:00", 1.27135, 0.60, 99.00, -0.60, 0.00},
        {700081, "EURUSD", "buy", "2026.03.13 20:00:00", 1.08670, 1, 0.50, "2026.03.14 13:00:00", 1.08658, 0.50, -6.00, -0.50, 0.00},
        {700082, "GBPUSD", "sell", "2026.03.14 02:00:00", 1.27268, 1, 1.00, "2026.03.14 04:00:00", 1.27092, 1.00, 176.00, -1.00, -0.08},
        {700083, "EURUSD", "buy", "2026.03.14 08:00:00", 1.07974, 1, 1.00, "2026.03.14 22:00:00", 1.08133, 1.00, 159.00, -1.00, 0.00},
        {700084, "GBPUSD", "sell", "2026.03.14 15:00:00", 1.26380, 1, 0.70, "2026.03.14 20:00:00", 1.26457, 0.70, -54.00, -0.70, 0.00},
        {700085, "EURUSD", "buy", "2026.03.14 18:00:00", 1.07926, 1, 0.70, "2026.03.15 13:00:00", 1.07986, 0.70, 42.00, -0.70, -0.00},
        {700086, "GBPUSD", "sell", "2026.03.15 04:00:00", 1.26194, 1, 0.30, "2026.03.16 00:00:00", 1.25864, 0.30, 99.00, -0.30, 0.00},
        {700087, "EURUSD", "buy", "2026.03.15 12:00:00", 1.07637, 1, 0.40, "2026.03.16 03:00:00", 1.07715, 0.40, 31.00, -0.40, 0.00},
        {700088, "GBPUSD", "sell", "2026.03.15 18:00:00", 1.26933, 1, 0.60, "2026.03.16 06:00:00", 1.26825, 0.60, 65.00, -0.60, -0.22},
        {700089, "EURUSD", "buy", "2026.03.16 00:00:00", 1.08754, 1, 0.30, "2026.03.16 03:00:00", 1.09447, 0.30, 208.00, -0.30, 0.00},
        {700090, "GBPUSD", "sell", "2026.03.16 08:00:00", 1.26755, 1, 0.40, "2026.03.17 02:00:00", 1.26415, 0.40, 136.00, -0.40, 0.00},
        {700091, "EURUSD", "buy", "2026.03.16 13:00:00", 1.08300, 1, 0.80, "2026.03.16 23:00:00", 1.08266, 0.80, -27.00, -0.80, -0.03},
        {700092, "GBPUSD", "sell", "2026.03.16 17:00:00", 1.27060, 1, 0.70, "2026.03.17 00:00:00", 1.27100, 0.70, -28.00, -0.70, 0.00},
        {700093, "EURUSD", "buy", "2026.03.17 07:00:00", 1.08280, 1, 0.60, "2026.03.17 09:00:00", 1.08540, 0.60, 156.00, -0.60, 0.00},
        {700094, "GBPUSD", "sell", "2026.03.17 16:00:00", 1.26475, 1, 0.50, "2026.03.17 19:00:00", 1.26421, 0.50, 27.00, -0.50, -0.23},
        {700095, "EURUSD", "buy", "2026.03.17 19:00:00", 1.07628, 1, 0.30, "2026.03.18 01:00:00", 1.07765, 0.30, 41.00, -0.30, 0.00},
        {700096, "GBPUSD", "sell", "2026.03.18 02:00:00", 1.26546, 1, 0.50, "2026.03.18 16:00:00", 1.26432, 0.50, 57.00, -0.50, 0.00},
        {700097, "EURUSD", "buy", "2026.03.18 05:00:00", 1.08654, 1, 0.80, "2026.03.18 18:00:00", 1.08800, 0.80, 117.00, -0.80, -0.28},
        {700098, "GBPUSD", "sell", "2026.03.18 16:00:00", 1.25561, 1, 0.30, "2026.03.19 08:00:00", 1.25714, 0.30, -46.00, -0.30, 0.00},
        {700099, "EURUSD", "buy", "2026.03.18 22:00:00", 1.08104, 1, 0.50, "2026.03.19 10:00:00", 1.08478, 0.50, 187.00, -0.50, 0.00},
        {700100, "GBPUSD", "sell", "2026.03.19 05:00:00", 1.26737, 1, 0.80, "2026.03.19 22:00:00", 1.26557, 0.80, 144.00, -0.80, -0.29},
        {700101, "EURUSD", "buy", "2026.03.19 13:00:00", 1.07724, 1, 0.70, "2026.03.20 07:00:00", 1.07684, 0.70, -28.00, -0.70, 0.00},
        {700102, "GBPUSD", "sell", "2026.03.19 17:00:00", 1.27158, 1, 0.60, "2026.03.20 08:00:00", 1.27086, 0.60, 43.00, -0.60, 0.00},
        {700103, "EURUSD", "buy", "2026.03.20 01:00:00", 1.07973, 1, 0.70, "2026.03.20 03:00:00", 1.07979, 0.70, 4.00, -0.70, -0.30},
        {700104, "GBPUSD", "sell", "2026.03.20 14:00:00", 1.27413, 1, 0.80, "2026.03.20 19:00:00", 1.27381, 0.80, 26.00, -0.80, 0.00},
        {700105, "EURUSD", "buy", "2026.03.20 21:00:00", 1.07801, 1, 0.60, "2026.03.21 09:00:00", 1.08284, 0.60, 290.00, -0.60, 0.00},
        {700106, "GBPUSD", "sell", "2026.03.21 02:00:00", 1.26614, 1, 0.40, "2026.03.21 06:00:00", 1.26934, 0.40, -128.00, -0.40, -0.23},
        {700107, "EURUSD", "buy", "2026.03.21 09:00:00", 1.08148, 1, 0.30, "2026.03.21 22:00:00", 1.08591, 0.30, 133.00, -0.30, 0.00},
        {700108, "GBPUSD", "sell", "2026.03.21 19:00:00", 1.26814, 1, 0.30, "2026.03.22 19:00:00", 1.26184, 0.30, 189.00, -0.30, 0.00},
        {700109, "EURUSD", "buy", "2026.03.22 04:00:00", 1.09140, 1, 1.00, "2026.03.23 01:00:00", 1.09207, 1.00, 67.00, -1.00, -0.02},
        {700110, "GBPUSD", "sell", "2026.03.22 07:00:00", 1.26716, 1, 0.30, "2026.03.22 17:00:00", 1.27183, 0.30, -140.00, -0.30, 0.00},
        {700111, "EURUSD", "buy", "2026.03.22 15:00:00", 1.07945, 1, 0.40, "2026.03.23 14:00:00", 1.08120, 0.40, 70.00, -0.40, 0.00},
        {700112, "GBPUSD", "sell", "2026.03.22 20:00:00", 1.27064, 1, 0.80, "2026.03.23 03:00:00", 1.27026, 0.80, 30.00, -0.80, -0.18},
        {700113, "EURUSD", "buy", "2026.03.23 06:00:00", 1.08435, 1, 0.70, "2026.03.24 05:00:00", 1.08334, 0.70, -71.00, -0.70, 0.00},
        {700114, "GBPUSD", "sell", "2026.03.23 09:00:00", 1.25613, 1, 0.80, "2026.03.23 23:00:00", 1.25434, 0.80, 143.00, -0.80, 0.00},
        {700115, "EURUSD", "buy", "2026.03.23 22:00:00", 1.08022, 1, 0.40, "2026.03.24 07:00:00", 1.07830, 0.40, -77.00, -0.40, -0.02},
        {700116, "GBPUSD", "sell", "2026.03.24 02:00:00", 1.27490, 1, 0.30, "2026.03.24 08:00:00", 1.27197, 0.30, 88.00, -0.30, 0.00},
        {700117, "EURUSD", "buy", "2026.03.24 07:00:00", 1.07842, 1, 0.30, "2026.03.24 21:00:00", 1.08112, 0.30, 81.00, -0.30, 0.00},
        {700118, "GBPUSD", "sell", "2026.03.24 18:00:00", 1.27117, 1, 0.60, "2026.03.25 12:00:00", 1.27024, 0.60, 56.00, -0.60, -0.21},
        {700119, "EURUSD", "buy", "2026.03.25 02:00:00", 1.09395, 1, 0.50, "2026.03.25 20:00:00", 1.09415, 0.50, 10.00, -0.50, 0.00},
        {700120, "GBPUSD", "sell", "2026.03.25 10:00:00", 1.27263, 1, 0.70, "2026.03.25 15:00:00", 1.27259, 0.70, 3.00, -0.70, 0.00},
        {700121, "EURUSD", "buy", "2026.03.25 22:00:00", 1.08550, 1, 0.30, "2026.03.26 17:00:00", 1.08390, 0.30, -48.00, -0.30, -0.15},
        {700122, "GBPUSD", "sell", "2026.03.26 11:00:00", 1.25896, 1, 0.70, "2026.03.27 06:00:00", 1.25853, 0.70, 30.00, -0.70, 0.00},
        {700123, "EURUSD", "buy", "2026.03.26 15:00:00", 1.09255, 1, 0.80, "2026.03.27 10:00:00", 1.09352, 0.80, 78.00, -0.80, 0.00},
        {700124, "GBPUSD", "sell", "2026.03.26 19:00:00", 1.26552, 1, 0.60, "2026.03.27 12:00:00", 1.26417, 0.60, 81.00, -0.60, -0.19},
        {700125, "EURUSD", "buy", "2026.03.27 04:00:00", 1.09124, 1, 1.00, "2026.03.27 09:00:00", 1.09361, 1.00, 237.00, -1.00, 0.00},
        {700126, "GBPUSD", "sell", "2026.03.27 16:00:00", 1.25758, 1, 0.70, "2026.03.27 22:00:00", 1.25529, 0.70, 160.00, -0.70, 0.00},
        {700127, "EURUSD", "buy", "2026.03.27 21:00:00", 1.09000, 1, 0.30, "2026.03.27 23:00:00", 1.09297, 0.30, 89.00, -0.30, -0.21},
        {700128, "GBPUSD", "sell", "2026.03.28 07:00:00", 1.26680, 1, 0.70, "2026.03.29 05:00:00", 1.26539, 0.70, 99.00, -0.70, 0.00},
        {700129, "EURUSD", "buy", "2026.03.28 20:00:00", 1.08492, 1, 0.60, "2026.03.29 02:00:00", 1.08415, 0.60, -46.00, -0.60, 0.00},
        {700130, "GBPUSD", "sell", "2026.03.29 09:00:00", 1.25562, 1, 1.00, "2026.03.29 19:00:00", 1.25408, 1.00, 154.00, -1.00, -0.02},
        {700131, "EURUSD", "buy", "2026.03.29 19:00:00", 1.08430, 1, 0.60, "2026.03.30 17:00:00", 1.08463, 0.60, 20.00, -0.60, 0.00},
        {700132, "GBPUSD", "sell", "2026.03.30 00:00:00", 1.25571, 1, 0.40, "2026.03.31 00:00:00", 1.25494, 0.40, 31.00, -0.40, 0.00},
        {700133, "EURUSD", "buy", "2026.03.30 04:00:00", 1.09343, 1, 0.80, "2026.03.30 19:00:00", 1.09532, 0.80, 151.00, -0.80, -0.13},
        {700134, "GBPUSD", "sell", "2026.03.30 08:00:00", 1.26266, 1, 0.30, "2026.03.30 23:00:00", 1.26129, 0.30, 41.00, -0.30, 0.00},
        {700135, "EURUSD", "buy", "2026.03.30 19:00:00", 1.09408, 1, 0.80, "2026.03.31 18:00:00", 1.09540, 0.80, 106.00, -0.80, 0.00},
        {700136, "GBPUSD", "sell", "2026.03.31 04:00:00", 1.26827, 1, 0.30, "2026.03.31 07:00:00", 1.26410, 0.30, 125.00, -0.30, -0.05},
        {700137, "EURUSD", "buy", "2026.03.31 13:00:00", 1.09102, 1, 0.70, "2026.04.01 00:00:00", 1.09129, 0.70, 19.00, -0.70, 0.00},
        {700138, "GBPUSD", "sell", "2026.03.31 16:00:00", 1.25942, 1, 0.70, "2026.04.01 11:00:00", 1.25945, 0.70, -2.00, -0.70, 0.00},
        {700139, "EURUSD", "buy", "2026.03.31 23:00:00", 1.09180, 1, 0.60, "2026.04.01 11:00:00", 1.09252, 0.60, 43.00, -0.60, -0.11},
        {700140, "GBPUSD", "sell", "2026.04.01 02:00:00", 1.26955, 1, 0.40, "2026.04.01 18:00:00", 1.26702, 0.40, 101.00, -0.40, 0.00},
        {700141, "EURUSD", "buy", "2026.04.01 06:00:00", 1.07725, 1, 0.30, "2026.04.02 04:00:00", 1.08085, 0.30, 108.00, -0.30, 0.00},
        {700142, "GBPUSD", "sell", "2026.04.01 13:00:00", 1.25706, 1, 0.80, "2026.04.01 19:00:00", 1.25589, 0.80, 94.00, -0.80, -0.06},
        {700143, "EURUSD", "buy", "2026.04.01 18:00:00", 1.08226, 1, 1.00, "2026.04.02 06:00:00", 1.08344, 1.00, 118.00, -1.00, 0.00},
        {700144, "GBPUSD", "sell", "2026.04.01 23:00:00", 1.25526, 1, 1.00, "2026.04.02 01:00:00", 1.25698, 1.00, -172.00, -1.00, 0.00},
        {700145, "EURUSD", "buy", "2026.04.02 05:00:00", 1.08246, 1, 0.30, "2026.04.02 13:00:00", 1.08929, 0.30, 205.00, -0.30, -0.06},
        {700146, "GBPUSD", "sell", "2026.04.02 11:00:00", 1.25905, 1, 0.30, "2026.04.02 17:00:00", 1.24712, 0.30, 358.00, -0.30, 0.00},
        {700147, "EURUSD", "buy", "2026.04.02 16:00:00", 1.07587, 1, 0.50, "2026.04.02 21:00:00", 1.07687, 0.50, 50.00, -0.50, 0.00},
        {700148, "GBPUSD", "sell", "2026.04.03 06:00:00", 1.27476, 1, 0.80, "2026.04.03 20:00:00", 1.27552, 0.80, -61.00, -0.80, -0.20},
        {700149, "EURUSD", "buy", "2026.04.03 10:00:00", 1.08542, 1, 1.00, "2026.04.03 17:00:00", 1.08611, 1.00, 69.00, -1.00, 0.00},
        {700150, "GBPUSD", "sell", "2026.04.03 21:00:00", 1.27201, 1, 0.40, "2026.04.04 15:00:00", 1.27021, 0.40, 72.00, -0.40, 0.00},
        {700151, "EURUSD", "buy", "2026.04.04 02:00:00", 1.08528, 1, 0.50, "2026.04.04 22:00:00", 1.08682, 0.50, 77.00, -0.50, -0.15},
        {700152, "GBPUSD", "sell", "2026.04.04 06:00:00", 1.26452, 1, 1.00, "2026.04.04 12:00:00", 1.26588, 1.00, -136.00, -1.00, 0.00},
        {700153, "EURUSD", "buy", "2026.04.04 12:00:00", 1.09398, 1, 0.60, "2026.04.05 12:00:00", 1.09356, 0.60, -25.00, -0.60, 0.00},
        {700154, "GBPUSD", "sell", "2026.04.04 22:00:00", 1.25793, 1, 0.60, "2026.04.05 00:00:00", 1.25575, 0.60, 131.00, -0.60, -0.18},
        {700155, "EURUSD", "buy", "2026.04.05 06:00:00", 1.08424, 1, 0.50, "2026.04.05 14:00:00", 1.08582, 0.50, 79.00, -0.50, 0.00},
        {700156, "GBPUSD", "sell", "2026.04.05 11:00:00", 1.27383, 1, 0.30, "2026.04.05 18:00:00", 1.27046, 0.30, 101.00, -0.30, 0.00},
        {700157, "EURUSD", "buy", "2026.04.05 22:00:00", 1.09279, 1, 0.30, "2026.04.06 05:00:00", 1.08596, 0.30, -205.00, -0.30, -0.23},
        {700158, "GBPUSD", "sell", "2026.04.06 10:00:00", 1.26069, 1, 1.00, "2026.04.07 02:00:00", 1.25908, 1.00, 161.00, -1.00, 0.00},
        {700159, "EURUSD", "buy", "2026.04.06 22:00:00", 1.08964, 1, 0.50, "2026.04.07 10:00:00", 1.09224, 0.50, 130.00, -0.50, 0.00},
        {700160, "GBPUSD", "sell", "2026.04.07 05:00:00", 1.26336, 1, 0.30, "2026.04.07 19:00:00", 1.26429, 0.30, -28.00, -0.30, -0.30},
        {700161, "EURUSD", "buy", "2026.04.07 08:00:00", 1.09091, 1, 0.80, "2026.04.07 13:00:00", 1.09245, 0.80, 123.00, -0.80, 0.00},
        {700162, "GBPUSD", "sell", "2026.04.07 13:00:00", 1.26579, 1, 0.50, "2026.04.08 09:00:00", 1.26373, 0.50, 103.00, -0.50, 0.00},
        {700163, "EURUSD", "buy", "2026.04.08 01:00:00", 1.07675, 1, 1.00, "2026.04.08 19:00:00", 1.07615, 1.00, -60.00, -1.00, -0.15},
        {700164, "GBPUSD", "sell", "2026.04.08 15:00:00", 1.25991, 1, 0.40, "2026.04.09 03:00:00", 1.26274, 0.40, -113.00, -0.40, 0.00},
        {700165, "EURUSD", "buy", "2026.04.09 04:00:00", 1.08656, 1, 0.70, "2026.04.09 09:00:00", 1.08767, 0.70, 78.00, -0.70, 0.00},
        {700166, "GBPUSD", "sell", "2026.04.09 07:00:00", 1.26151, 1, 0.30, "2026.04.09 22:00:00", 1.26154, 0.30, -1.00, -0.30, -0.14},
        {700167, "EURUSD", "buy", "2026.04.09 11:00:00", 1.09166, 1, 0.40, "2026.04.09 15:00:00", 1.09341, 0.40, 70.00, -0.40, 0.00},
        {700168, "GBPUSD", "sell", "2026.04.09 17:00:00", 1.27363, 1, 1.00, "2026.04.09 19:00:00", 1.27306, 1.00, 57.00, -1.00, 0.00},
        {700169, "EURUSD", "buy", "2026.04.09 21:00:00", 1.09040, 1, 0.40, "2026.04.09 23:00:00", 1.08960, 0.40, -32.00, -0.40, -0.27},
        {700170, "GBPUSD", "sell", "2026.04.10 07:00:00", 1.27159, 1, 0.60, "2026.04.11 02:00:00", 1.26817, 0.60, 205.00, -0.60, 0.00},
        {700171, "EURUSD", "buy", "2026.04.10 10:00:00", 1.08430, 1, 0.40, "2026.04.11 07:00:00", 1.08698, 0.40, 107.00, -0.40, 0.00},
        {700172, "GBPUSD", "sell", "2026.04.10 13:00:00", 1.26366, 1, 0.50, "2026.04.10 21:00:00", 1.26876, 0.50, -255.00, -0.50, -0.14},
        {700173, "EURUSD", "buy", "2026.04.10 20:00:00", 1.08241, 1, 1.00, "2026.04.11 08:00:00", 1.08250, 1.00, 9.00, -1.00, 0.00},
        {700174, "GBPUSD", "sell", "2026.04.11 01:00:00", 1.26659, 1, 0.40, "2026.04.11 06:00:00", 1.26414, 0.40, 98.00, -0.40, 0.00},
        {700175, "EURUSD", "buy", "2026.04.11 12:00:00", 1.09121, 1, 0.50, "2026.04.12 01:00:00", 1.09043, 0.50, -39.00, -0.50, -0.05},
        {700176, "GBPUSD", "sell", "2026.04.11 22:00:00", 1.26481, 1, 0.60, "2026.04.12 18:00:00", 1.26504, 0.60, -14.00, -0.60, 0.00},
        {700177, "EURUSD", "buy", "2026.04.12 10:00:00", 1.09373, 1, 0.50, "2026.04.12 17:00:00", 1.09497, 0.50, 62.00, -0.50, 0.00},
        {700178, "GBPUSD", "sell", "2026.04.12 14:00:00", 1.27133, 1, 0.60, "2026.04.12 22:00:00", 1.26903, 0.60, 138.00, -0.60, -0.03},
        {700179, "EURUSD", "buy", "2026.04.12 20:00:00", 1.08935, 1, 0.60, "2026.04.13 13:00:00", 1.08973, 0.60, 23.00, -0.60, 0.00},
        {700180, "GBPUSD", "sell", "2026.04.13 01:00:00", 1.25969, 1, 1.00, "2026.04.13 11:00:00", 1.26123, 1.00, -154.00, -1.00, 0.00},
        {700181, "EURUSD", "buy", "2026.04.13 06:00:00", 1.08590, 1, 0.70, "2026.04.13 16:00:00", 1.08649, 0.70, 41.00, -0.70, -0.21},
        {700182, "GBPUSD", "sell", "2026.04.13 16:00:00", 1.26975, 1, 0.80, "2026.04.14 10:00:00", 1.26772, 0.80, 162.00, -0.80, 0.00},
        {700183, "EURUSD", "buy", "2026.04.13 22:00:00", 1.09490, 1, 0.70, "2026.04.14 11:00:00", 1.09681, 0.70, 134.00, -0.70, 0.00},
        {700184, "GBPUSD", "sell", "2026.04.14 05:00:00", 1.27100, 1, 0.60, "2026.04.14 17:00:00", 1.26943, 0.60, 94.00, -0.60, -0.03},
        {700185, "EURUSD", "buy", "2026.04.14 08:00:00", 1.08305, 1, 0.50, "2026.04.14 13:00:00", 1.08357, 0.50, 26.00, -0.50, 0.00},
        {700186, "GBPUSD", "sell", "2026.04.14 13:00:00", 1.26828, 1, 0.60, "2026.04.14 15:00:00", 1.26716, 0.60, 67.00, -0.60, 0.00},
        {700187, "EURUSD", "buy", "2026.04.14 18:00:00", 1.08118, 1, 0.70, "2026.04.15 12:00:00", 1.08342, 0.70, 157.00, -0.70, -0.22},
        {700188, "GBPUSD", "sell", "2026.04.15 05:00:00", 1.26952, 1, 0.70, "2026.04.15 23:00:00", 1.26695, 0.70, 180.00, -0.70, 0.00},
        {700189, "EURUSD", "buy", "2026.04.15 17:00:00", 1.08412, 1, 0.60, "2026.04.16 13:00:00", 1.08459, 0.60, 28.00, -0.60, 0.00},
        {700190, "GBPUSD", "sell", "2026.04.16 05:00:00", 1.26741, 1, 0.80, "2026.04.16 18:00:00", 1.26772, 0.80, -25.00, -0.80, -0.23},
        {700191, "EURUSD", "buy", "2026.04.16 10:00:00", 1.07787, 1, 0.40, "2026.04.17 10:00:00", 1.07795, 0.40, 3.00, -0.40, 0.00},
        {700192, "GBPUSD", "sell", "2026.04.16 17:00:00", 1.27024, 1, 1.00, "2026.04.17 15:00:00", 1.26990, 1.00, 34.00, -1.00, 0.00},
        {700193, "EURUSD", "buy", "2026.04.17 06:00:00", 1.07898, 1, 1.00, "2026.04.17 15:00:00", 1.07930, 1.00, 32.00, -1.00, -0.05},
        {700194, "GBPUSD", "sell", "2026.04.17 11:00:00", 1.26903, 1, 0.60, "2026.04.17 23:00:00", 1.26955, 0.60, -31.00, -0.60, 0.00},
        {700195, "EURUSD", "buy", "2026.04.17 17:00:00", 1.07938, 1, 0.40, "2026.04.18 09:00:00", 1.08196, 0.40, 103.00, -0.40, 0.00},
        {700196, "GBPUSD", "sell", "2026.04.18 04:00:00", 1.25562, 1, 0.30, "2026.04.18 12:00:00", 1.25345, 0.30, 65.00, -0.30, -0.20},
        {700197, "EURUSD", "buy", "2026.04.18 18:00:00", 1.08696, 1, 0.80, "2026.04.19 05:00:00", 1.08618, 0.80, -62.00, -0.80, 0.00},
        {700198, "GBPUSD", "sell", "2026.04.19 04:00:00", 1.26663, 1, 0.30, "2026.04.20 01:00:00", 1.26393, 0.30, 81.00, -0.30, 0.00},
        {700199, "EURUSD", "buy", "2026.04.19 17:00:00", 1.08517, 1, 0.40, "2026.04.20 16:00:00", 1.08444, 0.40, -29.00, -0.40, -0.29},
        {700200, "GBPUSD", "sell", "2026.04.20 04:00:00", 1.26375, 1, 0.70, "2026.04.20 13:00:00", 1.26502, 0.70, -89.00, -0.70, 0.00},
        {700201, "EURUSD", "buy", "2026.04.20 16:00:00", 1.07646, 1, 0.30, "2026.04.20 22:00:00", 1.07539, 0.30, -32.00, -0.30, 0.00},
        {700202, "GBPUSD", "sell", "2026.04.20 20:00:00", 1.27306, 1, 1.00, "2026.04.21 07:00:00", 1.27151, 1.00, 155.00, -1.00, -0.22},
        {700203, "EURUSD", "buy", "2026.04.21 08:00:00", 1.07997, 1, 1.00, "2026.04.21 12:00:00", 1.08091, 1.00, 94.00, -1.00, 0.00},
        {700204, "GBPUSD", "sell", "2026.04.21 11:00:00", 1.26908, 1, 1.00, "2026.04.21 20:00:00", 1.26772, 1.00, 136.00, -1.00, 0.00},
        {700205, "EURUSD", "buy", "2026.04.21 21:00:00", 1.09360, 1, 0.40, "2026.04.22 15:00:00", 1.09630, 0.40, 108.00, -0.40, -0.24},
        {700206, "GBPUSD", "sell", "2026.04.22 05:00:00", 1.26119, 1, 0.80, "2026.04.22 14:00:00", 1.26187, 0.80, -54.00, -0.80, 0.00},
        {700207, "EURUSD", "buy", "2026.04.22 19:00:00", 1.08351, 1, 0.80, "2026.04.23 11:00:00", 1.08442, 0.80, 73.00, -0.80, 0.00},
        {700208, "GBPUSD", "sell", "2026.04.22 23:00:00", 1.25648, 1, 0.50, "2026.04.23 05:00:00", 1.25508, 0.50, 70.00, -0.50, -0.22},
        {700209, "EURUSD", "buy", "2026.04.23 05:00:00", 1.09059, 1, 0.50, "2026.04.23 08:00:00", 1.08845, 0.50, -107.00, -0.50, 0.00},
        {700210, "GBPUSD", "sell", "2026.04.23 17:00:00", 1.25532, 1, 0.50, "2026.04.24 03:00:00", 1.25476, 0.50, 28.00, -0.50, 0.00},
        {700211, "EURUSD", "buy", "2026.04.23 22:00:00", 1.08253, 1, 0.70, "2026.04.24 22:00:00", 1.08273, 0.70, 14.00, -0.70, -0.14},
        {700212, "GBPUSD", "sell", "2026.04.24 06:00:00", 1.25629, 1, 0.80, "2026.04.24 13:00:00", 1.25626, 0.80, 2.00, -0.80, 0.00},
        {700213, "EURUSD", "buy", "2026.04.24 13:00:00", 1.08124, 1, 0.50, "2026.04.25 10:00:00", 1.08286, 0.50, 81.00, -0.50, 0.00},
        {700214, "GBPUSD", "sell", "2026.04.24 18:00:00", 1.25696, 1, 0.40, "2026.04.25 16:00:00", 1.25518, 0.40, 71.00, -0.40, -0.01},
        {700215, "EURUSD", "buy", "2026.04.25 06:00:00", 1.09056, 1, 1.00, "2026.04.25 18:00:00", 1.09086, 1.00, 30.00, -1.00, 0.00},
        {700216, "GBPUSD", "sell", "2026.04.25 12:00:00", 1.26516, 1, 0.70, "2026.04.26 12:00:00", 1.26399, 0.70, 82.00, -0.70, 0.00},
        {700217, "EURUSD", "buy", "2026.04.25 22:00:00", 1.08901, 1, 0.70, "2026.04.26 11:00:00", 1.09135, 0.70, 164.00, -0.70, -0.01},
        {700218, "GBPUSD", "sell", "2026.04.26 02:00:00", 1.26297, 1, 0.50, "2026.04.26 09:00:00", 1.26317, 0.50, -10.00, -0.50, 0.00},
        {700219, "EURUSD", "buy", "2026.04.26 09:00:00", 1.07546, 1, 0.30, "2026.04.26 11:00:00", 1.06933, 0.30, -184.00, -0.30, 0.00},
        {700220, "GBPUSD", "sell", "2026.04.26 12:00:00", 1.27122, 1, 0.40, "2026.04.27 00:00:00", 1.27117, 0.40, 2.00, -0.40, -0.13},
        {700221, "EURUSD", "buy", "2026.04.26 15:00:00", 1.08091, 1, 1.00, "2026.04.27 02:00:00", 1.08129, 1.00, 38.00, -1.00, 0.00},
        {700222, "GBPUSD", "sell", "2026.04.27 02:00:00", 1.26501, 1, 0.40, "2026.04.27 14:00:00", 1.26411, 0.40, 36.00, -0.40, 0.00},
        {700223, "EURUSD", "buy", "2026.04.27 08:00:00", 1.08762, 1, 0.70, "2026.04.28 00:00:00", 1.08886, 0.70, 87.00, -0.70, -0.18},
        {700224, "GBPUSD", "sell", "2026.04.27 19:00:00", 1.25943, 1, 0.30, "2026.04.28 16:00:00", 1.25943, 0.30, -0.00, -0.30, 0.00},
        {700225, "EURUSD", "buy", "2026.04.27 23:00:00", 1.07873, 1, 0.40, "2026.04.28 07:00:00", 1.08035, 0.40, 65.00, -0.40, 0.00},
        {700226, "GBPUSD", "sell", "2026.04.28 08:00:00", 1.27310, 1, 1.00, "2026.04.28 19:00:00", 1.27157, 1.00, 153.00, -1.00, -0.22},
        {700227, "EURUSD", "buy", "2026.04.28 11:00:00", 1.08651, 1, 0.60, "2026.04.28 22:00:00", 1.08669, 0.60, 11.00, -0.60, 0.00},
        {700228, "GBPUSD", "sell", "2026.04.28 17:00:00", 1.26728, 1, 0.80, "2026.04.28 23:00:00", 1.26659, 0.80, 55.00, -0.80, 0.00},
        {700229, "EURUSD", "buy", "2026.04.28 22:00:00", 1.09174, 1, 1.00, "2026.04.29 13:00:00", 1.09281, 1.00, 107.00, -1.00, -0.21},
        {700230, "GBPUSD", "sell", "2026.04.29 05:00:00", 1.25797, 1, 1.00, "2026.04.30 00:00:00", 1.25775, 1.00, 22.00, -1.00, 0.00},
        {700231, "EURUSD", "buy", "2026.04.29 19:00:00", 1.08173, 1, 0.30, "2026.04.30 13:00:00", 1.08270, 0.30, 29.00, -0.30, 0.00},
        {700232, "GBPUSD", "sell", "2026.04.30 06:00:00", 1.27021, 1, 0.40, "2026.04.30 11:00:00", 1.26699, 0.40, 129.00, -0.40, -0.19},
        {700233, "EURUSD", "buy", "2026.04.30 20:00:00", 1.08212, 1, 0.30, "2026.05.01 18:00:00", 1.08542, 0.30, 99.00, -0.30, 0.00},
        {700234, "GBPUSD", "sell", "2026.05.01 02:00:00", 1.25988, 1, 0.30, "2026.05.01 23:00:00", 1.26065, 0.30, -23.00, -0.30, 0.00},
        {700235, "EURUSD", "buy", "2026.05.01 13:00:00", 1.08059, 1, 0.60, "2026.05.02 03:00:00", 1.08136, 0.60, 46.00, -0.60, -0.11},
        {700236, "GBPUSD", "sell", "2026.05.01 17:00:00", 1.27114, 1, 0.80, "2026.05.02 07:00:00", 1.26999, 0.80, 92.00, -0.80, 0.00},
        {700237, "EURUSD", "buy", "2026.05.01 22:00:00", 1.09491, 1, 0.40, "2026.05.02 09:00:00", 1.09798, 0.40, 123.00, -0.40, 0.00},
        {700238, "GBPUSD", "sell", "2026.05.02 12:00:00", 1.25728, 1, 0.30, "2026.05.02 17:00:00", 1.25668, 0.30, 18.00, -0.30, -0.21},
        {700239, "EURUSD", "buy", "2026.05.02 17:00:00", 1.09322, 1, 0.30, "2026.05.03 01:00:00", 1.09092, 0.30, -69.00, -0.30, 0.00},
        {700240, "GBPUSD", "sell", "2026.05.03 04:00:00", 1.25982, 1, 0.70, "2026.05.03 06:00:00", 1.25903, 0.70, 55.00, -0.70, 0.00},
        {700241, "EURUSD", "buy", "2026.05.03 09:00:00", 1.08706, 1, 0.50, "2026.05.04 02:00:00", 1.08698, 0.50, -4.00, -0.50, -0.18},
        {700242, "GBPUSD", "sell", "2026.05.03 14:00:00", 1.25624, 1, 0.60, "2026.05.03 16:00:00", 1.25667, 0.60, -26.00, -0.60, 0.00},
        {700243, "EURUSD", "buy", "2026.05.04 03:00:00", 1.09133, 1, 0.80, "2026.05.04 09:00:00", 1.09298, 0.80, 132.00, -0.80, 0.00},
        {700244, "GBPUSD", "sell", "2026.05.04 08:00:00", 1.26748, 1, 0.30, "2026.05.04 10:00:00", 1.26131, 0.30, 185.00, -0.30, -0.17},
        {700245, "EURUSD", "buy", "2026.05.04 20:00:00", 1.08668, 1, 0.60, "2026.05.05 15:00:00", 1.08876, 0.60, 125.00, -0.60, 0.00},
        {700246, "GBPUSD", "sell", "2026.05.05 06:00:00", 1.25597, 1, 0.60, "2026.05.06 04:00:00", 1.25674, 0.60, -46.00, -0.60, 0.00},
        {700247, "EURUSD", "buy", "2026.05.05 18:00:00", 1.08802, 1, 0.60, "2026.05.06 13:00:00", 1.08702, 0.60, -60.00, -0.60, -0.03},
        {700248, "GBPUSD", "sell", "2026.05.06 01:00:00", 1.26204, 1, 1.00, "2026.05.06 23:00:00", 1.26287, 1.00, -83.00, -1.00, 0.00},
        {700249, "EURUSD", "buy", "2026.05.06 09:00:00", 1.08671, 1, 0.30, "2026.05.06 20:00:00", 1.08618, 0.30, -16.00, -0.30, 0.00},
        {700250, "GBPUSD", "sell", "2026.05.06 14:00:00", 1.25942, 1, 0.80, "2026.05.07 09:00:00", 1.26017, 0.80, -60.00, -0.80, -0.16},
        {700251, "EURUSD", "buy", "2026.05.06 18:00:00", 1.08279, 1, 1.00, "2026.05.07 16:00:00", 1.08257, 1.00, -22.00, -1.00, 0.00},
        {700252, "GBPUSD", "sell", "2026.05.06 22:00:00", 1.27247, 1, 0.80, "2026.05.07 05:00:00", 1.27218, 0.80, 23.00, -0.80, 0.00},
        {700253, "EURUSD", "buy", "2026.05.07 04:00:00", 1.08454, 1, 0.60, "2026.05.07 20:00:00", 1.08359, 0.60, -57.00, -0.60, -0.04},
        {700254, "GBPUSD", "sell", "2026.05.07 14:00:00", 1.26037, 1, 0.60, "2026.05.08 09:00:00", 1.25990, 0.60, 28.00, -0.60, 0.00},
        {700255, "EURUSD", "buy", "2026.05.08 04:00:00", 1.09336, 1, 0.50, "2026.05.08 14:00:00", 1.09398, 0.50, 31.00, -0.50, 0.00},
        {700256, "GBPUSD", "sell", "2026.05.08 17:00:00", 1.27314, 1, 0.60, "2026.05.09 12:00:00", 1.27187, 0.60, 76.00, -0.60, -0.03},
        {700257, "EURUSD", "buy", "2026.05.09 04:00:00", 1.08856, 1, 0.60, "2026.05.09 16:00:00", 1.08696, 0.60, -96.00, -0.60, 0.00},
        {700258, "GBPUSD", "sell", "2026.05.09 18:00:00", 1.26788, 1, 0.60, "2026.05.10 18:00:00", 1.26770, 0.60, 11.00, -0.60, 0.00},
        {700259, "EURUSD", "buy", "2026.05.10 03:00:00", 1.08195, 1, 0.70, "2026.05.11 01:00:00", 1.08459, 0.70, 185.00, -0.70, -0.17},
        {700260, "GBPUSD", "sell", "2026.05.10 11:00:00", 1.27324, 1, 0.80, "2026.05.10 15:00:00", 1.27236, 0.80, 70.00, -0.80, 0.00},
        {700261, "EURUSD", "buy", "2026.05.10 14:00:00", 1.07818, 1, 0.50, "2026.05.10 21:00:00", 1.07738, 0.50, -40.00, -0.50, 0.00},
        {700262, "GBPUSD", "sell", "2026.05.11 03:00:00", 1.25799, 1, 0.70, "2026.05.11 17:00:00", 1.25793, 0.70, 4.00, -0.70, -0.05},
        {700263, "EURUSD", "buy", "2026.05.11 10:00:00", 1.08290, 1, 0.80, "2026.05.12 06:00:00", 1.08415, 0.80, 100.00, -0.80, 0.00},
        {700264, "GBPUSD", "sell", "2026.05.11 22:00:00", 1.26012, 1, 0.30, "2026.05.12 12:00:00", 1.25919, 0.30, 28.00, -0.30, 0.00},
        {700265, "EURUSD", "buy", "2026.05.12 01:00:00", 1.09405, 1, 0.50, "2026.05.12 10:00:00", 1.09411, 0.50, 3.00, -0.50, -0.15},
        {700266, "GBPUSD", "sell", "2026.05.12 05:00:00", 1.25646, 1, 0.50, "2026.05.12 19:00:00", 1.25580, 0.50, 33.00, -0.50, 0.00},
        {700267, "EURUSD", "buy", "2026.05.12 17:00:00", 1.08897, 1, 0.30, "2026.05.13 15:00:00", 1.09410, 0.30, 154.00, -0.30, 0.00},
        {700268, "GBPUSD", "sell", "2026.05.13 05:00:00", 1.26027, 1, 0.80, "2026.05.13 20:00:00", 1.25981, 0.80, 37.00, -0.80, -0.00},
        {700269, "EURUSD", "buy", "2026.05.13 08:00:00", 1.07883, 1, 0.40, "2026.05.14 08:00:00", 1.07891, 0.40, 3.00, -0.40, 0.00},
        {700270, "GBPUSD", "sell", "2026.05.13 13:00:00", 1.25941, 1, 0.30, "2026.05.14 08:00:00", 1.26268, 0.30, -98.00, -0.30, 0.00},
        {700271, "EURUSD", "buy", "2026.05.13 16:00:00", 1.08498, 1, 0.60, "2026.05.14 04:00:00", 1.08575, 0.60, 46.00, -0.60, -0.20},
        {700272, "GBPUSD", "sell", "2026.05.14 01:00:00", 1.26695, 1, 0.30, "2026.05.14 05:00:00", 1.26982, 0.30, -86.00, -0.30, 0.00},
        {700273, "EURUSD", "buy", "2026.05.14 10:00:00", 1.08671, 1, 1.00, "2026.05.14 12:00:00", 1.08745, 1.00, 74.00, -1.00, 0.00},
        {700274, "GBPUSD", "sell", "2026.05.14 17:00:00", 1.27365, 1, 0.30, "2026.05.14 19:00:00", 1.27532, 0.30, -50.00, -0.30, -0.00},
        {700275, "EURUSD", "buy", "2026.05.15 00:00:00", 1.07885, 1, 0.80, "2026.05.15 06:00:00", 1.07924, 0.80, 31.00, -0.80, 0.00},
        {700276, "GBPUSD", "sell", "2026.05.15 03:00:00", 1.26087, 1, 0.30, "2026.05.15 09:00:00", 1.25860, 0.30, 68.00, -0.30, 0.00},
        {700277, "EURUSD", "buy", "2026.05.15 15:00:00", 1.08388, 1, 0.50, "2026.05.16 12:00:00", 1.08334, 0.50, -27.00, -0.50, -0.04},
        {700278, "GBPUSD", "sell", "2026.05.15 23:00:00", 1.27179, 1, 0.50, "2026.05.16 04:00:00", 1.26893, 0.50, 143.00, -0.50, 0.00},
        {700279, "EURUSD", "buy", "2026.05.16 04:00:00", 1.08214, 1, 0.80, "2026.05.16 20:00:00", 1.08373, 0.80, 127.00, -0.80, 0.00},
        {700280, "GBPUSD", "sell", "2026.05.16 11:00:00", 1.27161, 1, 0.80, "2026.05.17 02:00:00", 1.27121, 0.80, 32.00, -0.80, -0.13},
        {700281, "EURUSD", "buy", "2026.05.16 14:00:00", 1.09059, 1, 0.50, "2026.05.16 23:00:00", 1.09007, 0.50, -26.00, -0.50, 0.00},
        {700282, "GBPUSD", "sell", "2026.05.16 17:00:00", 1.26065, 1, 0.80, "2026.05.16 22:00:00", 1.25958, 0.80, 86.00, -0.80, 0.00},
        {700283, "EURUSD", "buy", "2026.05.17 06:00:00", 1.07779, 1, 0.30, "2026.05.17 15:00:00", 1.07916, 0.30, 41.00, -0.30, -0.26},
        {700284, "GBPUSD", "sell", "2026.05.17 16:00:00", 1.25622, 1, 0.70, "2026.05.18 12:00:00", 1.25269, 0.70, 247.00, -0.70, 0.00},
        {700285, "EURUSD", "buy", "2026.05.18 05:00:00", 1.08311, 1, 1.00, "2026.05.19 03:00:00", 1.08335, 1.00, 24.00, -1.00, 0.00},
        {700286, "GBPUSD", "sell", "2026.05.18 09:00:00", 1.26398, 1, 0.60, "2026.05.18 13:00:00", 1.25993, 0.60, 243.00, -0.60, -0.03},
        {700287, "EURUSD", "buy", "2026.05.18 23:00:00", 1.07888, 1, 0.30, "2026.05.19 03:00:00", 1.07831, 0.30, -17.00, -0.30, 0.00},
        {700288, "GBPUSD", "sell", "2026.05.19 08:00:00", 1.26431, 1, 0.30, "2026.05.19 21:00:00", 1.26338, 0.30, 28.00, -0.30, 0.00},
        {700289, "EURUSD", "buy", "2026.05.19 12:00:00", 1.08221, 1, 0.80, "2026.05.20 01:00:00", 1.08102, 0.80, -95.00, -0.80, -0.03},
        {700290, "GBPUSD", "sell", "2026.05.20 01:00:00", 1.26003, 1, 0.70, "2026.05.20 09:00:00", 1.25840, 0.70, 114.00, -0.70, 0.00},
        {700291, "EURUSD", "buy", "2026.05.20 06:00:00", 1.08214, 1, 0.30, "2026.05.21 04:00:00", 1.07554, 0.30, -198.00, -0.30, 0.00},
        {700292, "GBPUSD", "sell", "2026.05.20 13:00:00", 1.26754, 1, 1.00, "2026.05.20 20:00:00", 1.26565, 1.00, 189.00, -1.00, -0.08},
        {700293, "EURUSD", "buy", "2026.05.20 21:00:00", 1.07808, 1, 0.80, "2026.05.21 07:00:00", 1.07759, 0.80, -39.00, -0.80, 0.00},
        {700294, "GBPUSD", "sell", "2026.05.21 10:00:00", 1.27214, 1, 0.80, "2026.05.22 03:00:00", 1.27234, 0.80, -16.00, -0.80, 0.00},
        {700295, "EURUSD", "buy", "2026.05.21 15:00:00", 1.08558, 1, 0.60, "2026.05.21 21:00:00", 1.08730, 0.60, 103.00, -0.60, -0.12},
        {700296, "GBPUSD", "sell", "2026.05.22 04:00:00", 1.26407, 1, 1.00, "2026.05.23 03:00:00", 1.26454, 1.00, -47.00, -1.00, 0.00},
        {700297, "EURUSD", "buy", "2026.05.22 10:00:00", 1.08970, 1, 0.30, "2026.05.23 01:00:00", 1.09133, 0.30, 49.00, -0.30, 0.00},
        {700298, "GBPUSD", "sell", "2026.05.22 17:00:00", 1.25983, 1, 0.60, "2026.05.23 03:00:00", 1.25808, 0.60, 105.00, -0.60, -0.06},
        {700299, "EURUSD", "buy", "2026.05.23 03:00:00", 1.08212, 1, 0.80, "2026.05.23 09:00:00", 1.08352, 0.80, 112.00, -0.80, 0.00},
        {700300, "GBPUSD", "sell", "2026.05.23 11:00:00", 1.26256, 1, 0.30, "2026.05.23 16:00:00", 1.26023, 0.30, 70.00, -0.30, 0.00},
        {800001, "EURUSD", "buy", "2026.05.24 00:00:00", 1.08500, 2, 0.40, "2026.05.24 10:00:00", 1.08590, 0.40, 23.00, -0.40, 0.00},
        {800002, "GBPUSD", "sell", "2026.05.25 00:00:00", 1.26500, 2, 0.80, "2026.05.25 10:00:00", 1.26410, 0.80, 61.00, -0.80, 0.00},
        {800003, "EURUSD", "buy", "2026.05.26 00:00:00", 1.08500, 2, 0.60, "2026.05.26 10:00:00", 1.08590, 0.60, 37.00, -0.60, 0.00},
        {800004, "GBPUSD", "sell", "2026.05.27 00:00:00", 1.26500, 2, 0.40, "2026.05.27 10:00:00", 1.26410, 0.40, -4.00, -0.40, 0.00},
        {800005, "EURUSD", "buy", "2026.05.28 00:00:00", 1.08500, 2, 0.60, "2026.05.28 10:00:00", 1.08590, 0.60, 29.00, -0.60, 0.00},
        {800006, "GBPUSD", "sell", "2026.05.29 00:00:00", 1.26500, 2, 0.60, "2026.05.29 10:00:00", 1.26410, 0.60, 93.00, -0.60, 0.00}
     };

   int total=ArraySize(g_sample);
   for(int i=0; i<total; i++)
     {
      string line=StringFormat("%I64d,%s,%s,%s,%.5f,%d,%.2f,%s,%.5f,%.2f,%.2f,%.2f,%.2f\r\n",
                                g_sample[i].position_id, g_sample[i].symbol, g_sample[i].direction,
                                g_sample[i].entry_time, g_sample[i].entry_price, g_sample[i].entry_count,
                                g_sample[i].total_volume, g_sample[i].exit_time, g_sample[i].exit_price,
                                g_sample[i].exit_volume, g_sample[i].exit_profit, g_sample[i].exit_commission,
                                g_sample[i].exit_swap);
      FileWriteString(handle, line);
     }
//--- one deliberately malformed row (a non-numeric volume), so the robustness path below has something
//--- real to skip and warn about instead of only being exercised on a reader's own messy export
   FileWriteString(handle, "900001,EURUSD,buy,2026.06.01 09:00:00,1.08500,1,N/A,2026.06.01 21:00:00,1.08600,0.50,60.00,-0.50,0.00\r\n");

   FileClose(handle);
   PrintFormat("Generated a demonstration file: %s (%d sample rows plus 1 deliberately malformed row).", filename, total);
  }

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print("=== Scale-Out Value Analyzer ===");

   if(!FileIsExist(InpFileName))
     {
      PrintFormat("%s was not found in MQL5\\Files - generating a demonstration file to analyze.", InpFileName);
      GenerateSampleFile(InpFileName);
     }

   ExitRow rows[];
   int skipped=0;
   int loaded=LoadRows(InpFileName, rows, skipped);
   if(loaded<=0)
     {
      Print("No usable rows were read - nothing to analyze.");
      return;
     }
   PrintFormat("Loaded %d row(s) from %s (%d skipped as malformed).", loaded, InpFileName, skipped);

   SortRows(rows);

   ScalePosition positions[];
   int excluded_multi=0;
   int total_pos=BuildPositions(rows, positions, excluded_multi);
   PrintFormat("Reconstructed %d position(s); %d additional position(s) excluded (built from more than one entry deal).",
               total_pos, excluded_multi);

   ScaleMetrics metrics[];
   int excluded_bad_vol=0;
   int n_scaled=ComputeMetrics(positions, metrics, excluded_bad_vol);
   if(excluded_bad_vol>0)
      PrintFormat("WARNING: %d position(s) excluded - exit volumes did not sum to the opened volume.", excluded_bad_vol);

   double pct_scaled=(total_pos>0) ? (double)n_scaled/total_pos*100.0 : 0.0;
   PrintFormat("%d of %d positions (%.1f%%) closed in more than one exit (scaled out).", n_scaled, total_pos, pct_scaled);

   if(n_scaled==0)
     {
      Print("No scaled positions were found - nothing to grade.");
      return;
     }
   if(n_scaled<InpMinScaledPositions)
     {
      PrintFormat("Only %d scaled position(s) found, below the configured minimum of %d - no grade produced.",
                  n_scaled, InpMinScaledPositions);
      return;
     }

   ScoreResult result;
   AggregateAndScore(metrics, result);

   Print("--- Value-Add dimension (actual result vs. holding the full size to the last exit) ---");
   PrintFormat("Aggregate Value-Add Ratio: %.2f%% (sum of value added across scaled positions / sum of |counterfactual|).",
               result.value_add_ratio);
   PrintFormat("Scale-Out Win Rate: %.1f%% (%d of %d scaled positions beat holding to the last exit).",
               result.hit_rate, result.hits, result.n_scaled);

   Print("--- Efficiency dimension (actual result vs. the best of the trader's own exit prices) ---");
   PrintFormat("Average Scaling Efficiency: %.1f%%.", result.avg_efficiency);

   Print("--- Single-trade dependence check (largest winning scale-out removed) ---");
   PrintFormat("Removing position #%I64d shifts the Value-Add Ratio from %.2f%% to %.2f%% (%.2f pts).",
               result.stress_dropped_id, result.value_add_ratio, result.stress_ratio, result.stress_shift);

   Print("--- Composite score ---");
   PrintFormat("Sub-scores - Value-Add: %.1f  Hit-Rate: %.1f  Efficiency: %.1f.",
               result.sub_value, result.sub_hit, result.sub_eff);
   PrintFormat("Scale-Out Value Score: %.1f / 100 -> Grade %s.", result.composite, result.grade);
   if(n_scaled<InpRobustSampleSize)
      PrintFormat("Sample size: %d scaled position(s), below the recommended minimum of %d for a robust result - treat this grade as PRELIMINARY.",
                  n_scaled, InpRobustSampleSize);
   else
      PrintFormat("Sample size: %d scaled position(s) meets the recommended minimum of %d for a robust, non-preliminary result.",
                  n_scaled, InpRobustSampleSize);
   Print("This is a heuristic ranking score for comparison, not a statistically validated measure.");

   Print("--- Recommendations ---");
   bool any_reco=false;
   if(result.hit_rate<InpHitRateAlertBelow)
     {
      PrintFormat("- Scaling out beat holding to the last exit in only %.1f%% of cases; review whether the final leg is closed on a rule or on impulse.",
                  result.hit_rate);
      any_reco=true;
     }
   if(result.avg_efficiency<InpEfficiencyAlertBelow)
     {
      PrintFormat("- Average efficiency against your own best exit point is %.1f%%; tightening the trigger for the last leg could capture more of it.",
                  result.avg_efficiency);
      any_reco=true;
     }
   if(result.value_add_ratio!=0.0 && MathAbs(result.stress_shift)>MathAbs(result.value_add_ratio)*InpStressDependenceAlert)
     {
      PrintFormat("- The aggregate edge depends partly on a single trade (position #%I64d); treat it with caution until more scaled positions accumulate.",
                  result.stress_dropped_id);
      any_reco=true;
     }
   if(!any_reco)
      Print("- No specific concern crossed the configured thresholds.");
  }
//+------------------------------------------------------------------+
