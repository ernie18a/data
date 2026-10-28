//+------------------------------------------------------------------+
//|                                     NeuralLossPatternAuditor.mq5 |
//|                                      Neural Loss-Pattern Auditor |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Neural Loss-Pattern Auditor"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property script_show_inputs

#include "NLPA_NeuralNet.mqh"

#define NLPA_N_FEATURES 8

//--- data source ------------------------------------------------------
input bool   InpUseDemoData       =true;  // Use the built-in synthetic demo instead of real account history
input int    InpDemoTradeCount    =480;   // Synthetic trades to generate when InpUseDemoData is true
input int    InpMinTrades         =60;    // Minimum closed trades required before training a model
input double InpValidationFraction=0.25;  // Fraction of the most recent trades held out for validation

//--- network and training ---------------------------------------------
input int    InpHiddenNeurons     =5;     // Hidden neurons (one tanh layer)
input double InpLearningRate      =0.03;  // Learning rate for plain SGD
input int    InpEpochs            =400;   // Full sweeps over the training set
input int    InpRandomSeed        =42;    // Seed for weight init and (in demo mode) synthetic data

//--- diagnostics --------------------------------------------------------
input int    InpCalibrationBins   =5;     // Probability buckets in the calibration report
input int    InpPermutationRepeats=25;    // Shuffle repeats per feature when measuring importance

//--- composite grade -----------------------------------------------------
input double InpWeightUplift      =0.50;  // Score weight: accuracy uplift over the base rate
input double InpWeightCalibration =0.30;  // Score weight: calibration quality
input double InpWeightTopFeature  =0.20;  // Score weight: strength of the top feature
input double InpUpliftScale       =0.10;  // Uplift (accuracy - base rate) that maps to a full 100
input double InpCalibErrorScale   =0.30;  // Mean absolute calibration error that maps to a zero score
input double InpFeatureScale      =0.045; // Top feature importance that maps to a full 100
input double InpGradeA            =85.0;  // Minimum composite score for grade A
input double InpGradeB            =70.0;  // Minimum composite score for grade B
input double InpGradeC            =55.0;  // Minimum composite score for grade C
input double InpGradeD            =40.0;  // Minimum composite score for grade D

//--- real-data feature engineering (ignored when InpUseDemoData is true) ---
input int    InpAtrPeriod         =14;    // ATR period for the volatility-context feature
input int    InpAtrBaselinePeriod =200;   // Longer ATR lookback used as the baseline for that ratio

//+------------------------------------------------------------------+
//| One training example: an engineered feature vector for a single  |
//| closing deal, its win/loss label, and the deal's close time      |
//| (used only to keep records in chronological order for the        |
//| split).                                                          |
//+------------------------------------------------------------------+
struct STradeRecord
  {
   double   features[NLPA_N_FEATURES];
   double   label; // 1.0 = losing closing deal (net of swap/commission), 0.0 = not a loss
   datetime time;  // close time of this deal
  };

//+------------------------------------------------------------------+
//| Feature index -> name, used everywhere a feature is reported.    |
//+------------------------------------------------------------------+
string FeatureName(const int idx)
  {
   switch(idx)
     {
      case 0: return "hour_sin";
      case 1: return "hour_cos";
      case 2: return "day_norm";
      case 3: return "atr_ratio";
      case 4: return "size_ratio";
      case 5: return "holding_norm";
      case 6: return "prior_loss_flag";
      case 7: return "daily_seq_norm";
     }
   return "unknown";
  }

//+------------------------------------------------------------------+
//| Right-pad a string with spaces so report columns line up.        |
//+------------------------------------------------------------------+
string PadRight(const string s,const int width)
  {
   string out=s;
   while(StringLen(out)<width)
      out+=" ";
   return out;
  }

//+------------------------------------------------------------------+
//| Uniform double in [0, 1] from MathRand().                        |
//+------------------------------------------------------------------+
double RandUniform01(void)
  {
   return MathRand()/32767.0;
  }

//+------------------------------------------------------------------+
//| Gaussian double via the Box-Muller transform, built on           |
//| RandUniform01() so it shares the one seeded MathRand() stream.   |
//+------------------------------------------------------------------+
double RandNormal(const double mean,const double stddev)
  {
   double u1=MathMax(1e-12,RandUniform01());
   double u2=RandUniform01();
   double z =MathSqrt(-2.0*MathLog(u1))*MathCos(2.0*M_PI*u2);
   return mean+stddev*z;
  }

//+------------------------------------------------------------------+
//| Build InpDemoTradeCount synthetic closing deals with a           |
//| deliberately injected pattern: after a loss, a trader who then   |
//| sizes up (size_ratio > 1.3) loses much more often than usual.    |
//| Every other feature carries only mild or no relationship to the  |
//| outcome, so the report below has a real but imperfect signal to  |
//| find -- exactly the point of a demo. See the article text for    |
//| the exact constants and why they were chosen.                    |
//+------------------------------------------------------------------+
int BuildDemoDataset(STradeRecord &records[])
  {
   MathSrand(InpRandomSeed);
   ArrayResize(records,InpDemoTradeCount);

   double day_weights[7]={18,20,20,20,18,2,2};
   double day_cum[7];
   double running=0.0;
   for(int d=0; d<7; d++)
     {
      running+=day_weights[d];
      day_cum[d]=running;
     }
   double day_total=running;

   double   prior_loss=0.0;
   datetime t=D'2024.01.01 08:00:00';

   for(int k=0; k<InpDemoTradeCount; k++)
     {
      int hour=(int)MathFloor(RandUniform01()*24.0);
      if(hour>23) hour=23;

      double roll=RandUniform01()*day_total;
      int    day=6;
      for(int d=0; d<7; d++)
         if(roll<=day_cum[d])
           {
            day=d;
            break;
           }

      double atr_ratio=MathMax(0.3,RandNormal(1.0,0.28));
      double base_size=MathMax(0.15,RandNormal(1.0,0.22));

      //--- revenge-sizing behavior: after a loss, a chance of a size jump
      double size_ratio=base_size;
      if(prior_loss==1.0 && RandUniform01()<0.40)
         size_ratio=base_size*(1.4+RandUniform01()*0.7);

      double holding_hours =MathMax(0.1,MathExp(RandNormal(1.1,0.7)));
      double daily_seq_norm=MathMax(0.2,RandNormal(1.0,0.25)); // pure noise distractor

      //--- true underlying loss probability for this synthetic trade
      double p_loss=0.42;
      if(atr_ratio>1.3)
         p_loss+=0.02;                                         // small secondary effect
      p_loss+=0.015*MathMin(holding_hours/10.0,1.5);           // mild "hope bias" effect
      if(prior_loss==1.0 && size_ratio>1.3)
         p_loss=0.80;                                          // the real, learnable pattern
      p_loss=MathMax(0.03,MathMin(0.97,p_loss));

      double label=(RandUniform01()<p_loss) ? 1.0 : 0.0;

      records[k].features[0]=MathSin(2.0*M_PI*hour/24.0);
      records[k].features[1]=MathCos(2.0*M_PI*hour/24.0);
      records[k].features[2]=day/6.0;
      records[k].features[3]=atr_ratio;
      records[k].features[4]=size_ratio;
      records[k].features[5]=MathLog(1.0+holding_hours)/MathLog(1.0+48.0);
      records[k].features[6]=prior_loss;
      records[k].features[7]=daily_seq_norm;
      records[k].label       =label;
      records[k].time         =t;

      prior_loss=label;
      t+=6*3600;                                               // space synthetic deals six hours apart so time stays strictly increasing
     }
   return InpDemoTradeCount;
  }

//+------------------------------------------------------------------+
//| Build one record per closing deal (DEAL_ENTRY_OUT / OUT_BY) from |
//| real account history. MetaTrader 5 history is deal-level, so a   |
//| position closed through several partial exits contributes        |
//| several records here, one per exit -- not one record per         |
//| position. Buy/sell deals only; balance, credit, and correction   |
//| entries are excluded by the DEAL_TYPE filter.                    |
//+------------------------------------------------------------------+
int BuildRealDataset(STradeRecord &records[])
  {
   if(!HistorySelect(0,TimeCurrent()))
     {
      PrintFormat("ERROR: HistorySelect failed, error code %d.",GetLastError());
      ArrayResize(records,0);
      return 0;
     }
   int total=HistoryDealsTotal();

//--- pass 1: each position's opening time, keyed by position id, so a
//--- closing deal can look up how long ITS position was actually open
   ulong    pos_ids[];
   datetime pos_open_time[];
   int      pos_count=0;
   for(int i=0; i<total; i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
         continue;
      if(HistoryDealGetInteger(ticket,DEAL_ENTRY)!=DEAL_ENTRY_IN)
         continue;
      long deal_type=HistoryDealGetInteger(ticket,DEAL_TYPE);
      if(deal_type!=DEAL_TYPE_BUY && deal_type!=DEAL_TYPE_SELL)
         continue;

      ArrayResize(pos_ids,pos_count+1);
      ArrayResize(pos_open_time,pos_count+1);
      pos_ids[pos_count]      =(ulong)HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
      pos_open_time[pos_count]=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      pos_count++;
     }

//--- pass 2: one record per closing deal, in the chronological order
//--- HistorySelect() already returns deals in
   ArrayResize(records,0);
   int      n_records   =0;
   double   prior_loss  =0.0;
   double   recent_volumes[20];
   int      recent_cap  =20;
   int      recent_n    =0;
   int      recent_head =0;
   double   recent_sum  =0.0;
   ArrayInitialize(recent_volumes,0.0);

   int    daily_seq  =0;
   int    last_day   =-1, last_mon=-1, last_year=-1;

   string atr_symbols[];
   int    atr_handles[];
   int    atr_symbol_count=0;

   for(int i=0; i<total; i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
         continue;

      long deal_type =HistoryDealGetInteger(ticket,DEAL_TYPE);
      long deal_entry=HistoryDealGetInteger(ticket,DEAL_ENTRY);
      if(deal_type!=DEAL_TYPE_BUY && deal_type!=DEAL_TYPE_SELL)
         continue;
      if(deal_entry!=DEAL_ENTRY_OUT && deal_entry!=DEAL_ENTRY_OUT_BY)
         continue;

      datetime deal_time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      double   volume    =HistoryDealGetDouble(ticket,DEAL_VOLUME);
      double   net_result=HistoryDealGetDouble(ticket,DEAL_PROFIT)
                          +HistoryDealGetDouble(ticket,DEAL_SWAP)
                          +HistoryDealGetDouble(ticket,DEAL_COMMISSION);
      string   symbol    =HistoryDealGetString(ticket,DEAL_SYMBOL);
      ulong    pos_id     =(ulong)HistoryDealGetInteger(ticket,DEAL_POSITION_ID);

      //--- this position's open time (falls back to the deal's own time if
      //--- the opening leg is not in the selected history window)
      datetime open_time=deal_time;
      for(int p=0; p<pos_count; p++)
         if(pos_ids[p]==pos_id)
           {
            open_time=pos_open_time[p];
            break;
           }

      MqlDateTime dts;
      TimeToStruct(deal_time,dts);

      //--- ATR ratio: ATR at close time vs. a longer same-symbol baseline
      int handle=INVALID_HANDLE;
      for(int s=0; s<atr_symbol_count; s++)
         if(atr_symbols[s]==symbol)
           {
            handle=atr_handles[s];
            break;
           }
      if(handle==INVALID_HANDLE)
        {
         handle=iATR(symbol,PERIOD_H1,InpAtrPeriod);
         ArrayResize(atr_symbols,atr_symbol_count+1);
         ArrayResize(atr_handles,atr_symbol_count+1);
         atr_symbols[atr_symbol_count] =symbol;
         atr_handles[atr_symbol_count] =handle;
         atr_symbol_count++;
        }

      double atr_ratio=1.0; // neutral default when ATR is unavailable
      if(handle!=INVALID_HANDLE)
        {
         int shift=iBarShift(symbol,PERIOD_H1,deal_time);
         if(shift>=0)
           {
            double atr_now[1];
            double atr_series[];
            if(CopyBuffer(handle,0,shift,1,atr_now)==1)
              {
               int copied=CopyBuffer(handle,0,shift,InpAtrBaselinePeriod,atr_series);
               double base_sum=0.0;
               int    base_count=0;
               for(int c=0; c<copied; c++)
                  if(atr_series[c]>0.0)
                    {
                     base_sum+=atr_series[c];
                     base_count++;
                    }
               if(base_count>0 && atr_now[0]>0.0)
                  atr_ratio=atr_now[0]/(base_sum/base_count);
              }
           }
        }

      //--- size ratio: this deal's volume vs. a rolling window of recent
      //--- closing volumes (a simple circular buffer, up to recent_cap deep)
      double size_ratio=1.0;
      if(recent_n>0)
        {
         double avg_recent=recent_sum/recent_n;
         if(avg_recent>0.0)
            size_ratio=volume/avg_recent;
        }
      if(recent_n==recent_cap)
         recent_sum-=recent_volumes[recent_head];
      else
         recent_n++;
      recent_volumes[recent_head]=volume;
      recent_sum+=volume;
      recent_head=(recent_head+1)%recent_cap;

      //--- holding time: close time minus the POSITION's open time, not just
      //--- this deal's own timestamp, so partial exits are handled correctly
      double holding_hours=MathMax(0.01,(double)(deal_time-open_time)/3600.0);
      double holding_norm =MathLog(1.0+holding_hours)/MathLog(1.0+48.0);

      //--- how many closing deals already happened earlier on this same day
      if(dts.day!=last_day || dts.mon!=last_mon || dts.year!=last_year)
        {
         daily_seq=0;
         last_day =dts.day;
         last_mon =dts.mon;
         last_year=dts.year;
        }
      double daily_seq_norm=MathMin((double)daily_seq/8.0,2.0);
      daily_seq++;

      double label=(net_result<0.0) ? 1.0 : 0.0;

      ArrayResize(records,n_records+1);
      records[n_records].features[0]=MathSin(2.0*M_PI*dts.hour/24.0);
      records[n_records].features[1]=MathCos(2.0*M_PI*dts.hour/24.0);
      records[n_records].features[2]=dts.day_of_week/6.0;
      records[n_records].features[3]=atr_ratio;
      records[n_records].features[4]=size_ratio;
      records[n_records].features[5]=holding_norm;
      records[n_records].features[6]=prior_loss;
      records[n_records].features[7]=daily_seq_norm;
      records[n_records].label       =label;
      records[n_records].time         =deal_time;

      prior_loss=label;
      n_records++;
     }

   for(int s=0; s<atr_symbol_count; s++)
      if(atr_handles[s]!=INVALID_HANDLE)
         IndicatorRelease(atr_handles[s]);

   return n_records;
  }

//+------------------------------------------------------------------+
//| Train net on train_set for epochs full sweeps, reporting the     |
//| average per-example loss of the first and last epoch so OnStart  |
//| can show whether training actually converged.                    |
//+------------------------------------------------------------------+
void TrainNetwork(CMlpNet &net,STradeRecord &train_set[],const int n,const int epochs,
                   const double lr,double &first_loss,double &last_loss)
  {
   first_loss=0.0;
   last_loss =0.0;
   for(int epoch=0; epoch<epochs; epoch++)
     {
      double total=0.0;
      for(int k=0; k<n; k++)
         total+=net.TrainStep(train_set[k].features,train_set[k].label,lr);
      double avg=(n>0) ? total/n : 0.0;
      if(epoch==0)
         first_loss=avg;
      if(epoch==epochs-1)
         last_loss=avg;
     }
  }

//+------------------------------------------------------------------+
//| Classification accuracy at a 0.5 decision threshold.             |
//+------------------------------------------------------------------+
double Accuracy(CMlpNet &net,STradeRecord &set[],const int n)
  {
   if(n<=0)
      return 0.0;
   int correct=0;
   for(int k=0; k<n; k++)
     {
      double pred=net.Forward(set[k].features);
      int    predicted_class=(pred>=0.5) ? 1 : 0;
      if(predicted_class==(int)set[k].label)
         correct++;
     }
   return (double)correct/(double)n;
  }

//+------------------------------------------------------------------+
//| Bucket validation predictions into n_bins probability ranges and |
//| compare each bucket's average predicted probability against the  |
//| actual observed loss frequency in that bucket -- a direct,       |
//| honest calibration check rather than a single accuracy number.   |
//+------------------------------------------------------------------+
void CalibrationTable(CMlpNet &net,STradeRecord &val_set[],const int n,const int n_bins,
                       int &bin_count[],double &bin_avg_pred[],double &bin_actual[],double &mean_abs_err)
  {
   ArrayResize(bin_count,n_bins);
   ArrayResize(bin_avg_pred,n_bins);
   ArrayResize(bin_actual,n_bins);
   double bin_pred_sum[];
   double bin_label_sum[];
   ArrayResize(bin_pred_sum,n_bins);
   ArrayResize(bin_label_sum,n_bins);
   ArrayInitialize(bin_count,0);
   ArrayInitialize(bin_pred_sum,0.0);
   ArrayInitialize(bin_label_sum,0.0);

   for(int k=0; k<n; k++)
     {
      double p=net.Forward(val_set[k].features);
      int    b=(int)MathFloor(p*n_bins);
      if(b>=n_bins)
         b=n_bins-1;
      if(b<0)
         b=0;
      bin_count[b]++;
      bin_pred_sum[b] +=p;
      bin_label_sum[b]+=val_set[k].label;
     }

   double weighted_err=0.0;
   int    total_weight=0;
   for(int b=0; b<n_bins; b++)
     {
      if(bin_count[b]>0)
        {
         bin_avg_pred[b]=bin_pred_sum[b]/bin_count[b];
         bin_actual[b]  =bin_label_sum[b]/bin_count[b];
         weighted_err  +=MathAbs(bin_avg_pred[b]-bin_actual[b])*bin_count[b];
         total_weight  +=bin_count[b];
        }
      else
        {
         bin_avg_pred[b]=0.0;
         bin_actual[b]  =0.0;
        }
     }
   mean_abs_err=(total_weight>0) ? weighted_err/total_weight : 0.0;
  }

//+------------------------------------------------------------------+
//| Permutation feature importance: for each feature, shuffle that   |
//| column across the validation set InpPermutationRepeats times,    |
//| measure the accuracy drop each time, and average it. A feature   |
//| the network actually relies on causes a real drop when           |
//| scrambled; pure noise columns average out to roughly zero.       |
//| Averaging over several shuffles matters -- a single shuffle on a |
//| modest validation set is noisy enough to rank features almost at |
//| random.                                                          |
//+------------------------------------------------------------------+
void PermutationImportance(CMlpNet &net,STradeRecord &val_set[],const int n,const int repeats,
                            double &importances[])
  {
   ArrayResize(importances,NLPA_N_FEATURES);
   double base_acc=Accuracy(net,val_set,n);

   double orig_col[];
   double shuf_col[];
   ArrayResize(orig_col,n);
   ArrayResize(shuf_col,n);

   for(int f=0; f<NLPA_N_FEATURES; f++)
     {
      for(int k=0; k<n; k++)
         orig_col[k]=val_set[k].features[f];

      double drop_sum=0.0;
      for(int r=0; r<repeats; r++)
        {
         ArrayCopy(shuf_col,orig_col);
         for(int k=n-1; k>0; k--) // Fisher-Yates shuffle
           {
            int    j  =(int)(MathRand()%(k+1));
            double tmp=shuf_col[k];
            shuf_col[k]=shuf_col[j];
            shuf_col[j]=tmp;
           }
         for(int k=0; k<n; k++)
            val_set[k].features[f]=shuf_col[k];

         double perturbed_acc=Accuracy(net,val_set,n);
         drop_sum+=(base_acc-perturbed_acc);
        }

      for(int k=0; k<n; k++)      // restore before the next feature
         val_set[k].features[f]=orig_col[k];

      importances[f]=drop_sum/repeats;
     }
  }

//+------------------------------------------------------------------+
//| Combine the three diagnostics into one 0-100 composite score.    |
//| Weights are normalized so the result does not depend on whether  |
//| the three Inp*Weight* inputs happen to sum to 1.                 |
//+------------------------------------------------------------------+
double CompositeGrade(const double uplift,const double calib_err,const double top_importance,
                       double &uplift_score,double &calib_score,double &feat_score)
  {
   double wsum=InpWeightUplift+InpWeightCalibration+InpWeightTopFeature;
   if(wsum<=0.0)
      wsum=1.0;
   double w_u=InpWeightUplift/wsum;
   double w_c=InpWeightCalibration/wsum;
   double w_f=InpWeightTopFeature/wsum;

   uplift_score=50.0+50.0*MathMax(-1.0,MathMin(1.0,uplift/InpUpliftScale));
   calib_score =100.0*MathMax(0.0,MathMin(1.0,1.0-(calib_err/InpCalibErrorScale)));
   feat_score  =100.0*MathMax(0.0,MathMin(1.0,top_importance/InpFeatureScale));

   return w_u*uplift_score+w_c*calib_score+w_f*feat_score;
  }

//+------------------------------------------------------------------+
//| Composite score -> letter grade using the four Inp*Grade* cuts.  |
//+------------------------------------------------------------------+
string LetterGrade(const double score)
  {
   if(score>=InpGradeA)
      return "A";
   if(score>=InpGradeB)
      return "B";
   if(score>=InpGradeC)
      return "C";
   if(score>=InpGradeD)
      return "D";
   return "F";
  }

//+------------------------------------------------------------------+
//| Turn the diagnostics into a short list of plain-language notes.  |
//| Every branch is independent -- more than one can fire, and if    |
//| none does a generic fallback note is returned so the list is     |
//| never empty.                                                     |
//+------------------------------------------------------------------+
void BuildRecommendations(const double uplift,const double calib_err,const string top_name,
                           const double top_val,const int sample_n,string &recs[])
  {
   if(sample_n<InpMinTrades)
     {
      ArrayResize(recs,1);
      recs[0]="Collect more closed trades before trusting this report -- the sample is below the "+
              "configured minimum for a stable estimate.";
      return;
     }

   ArrayResize(recs,4);
   int n=0;
   if(top_val>0.02 && (top_name=="size_ratio" || top_name=="prior_loss_flag"))
     {
      recs[n]="Position size right after a losing trade is a measurable driver of your losses. Consider "+
              "a hard, mechanical size cap or a mandatory cooldown for the first trade after a loss, "+
              "then re-run this report to see whether the uplift and calibration improve.";
      n++;
     }
   if(calib_err>0.20)
     {
      recs[n]="The model's predicted probabilities are not yet well calibrated against what actually "+
              "happened. Treat the individual percentages as rough ranking signals, not precise odds, "+
              "until more closed trades accumulate.";
      n++;
     }
   if(uplift<=0.01)
     {
      recs[n]="These features do not detectably separate your winners from your losers. That is a "+
              "useful negative result: your losses may be closer to random noise than to a fixable "+
              "behavioral pattern, at least given the context captured here.";
      n++;
     }
   if(n==0)
     {
      recs[n]="No single driver stood out strongly. Review the full feature-importance ranking below "+
              "for smaller, secondary effects worth watching.";
      n++;
     }
   ArrayResize(recs,n);
  }

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   STradeRecord all_records[];
   int total_n=InpUseDemoData ? BuildDemoDataset(all_records) : BuildRealDataset(all_records);

   Print("=== Neural Loss-Pattern Auditor ===");
   if(InpUseDemoData)
      PrintFormat("Data source: built-in synthetic demo data (%d trades, seed=%d).",total_n,InpRandomSeed);
   else
      PrintFormat("Data source: real closed-deal history (%d closing deals found).",total_n);

   if(total_n<InpMinTrades)
     {
      PrintFormat("STOPPED: only %d closed trades available; the configured minimum is %d. Collect "+
                  "more history (or lower InpMinTrades, with reduced confidence) before running this again.",
                  total_n,InpMinTrades);
      return;
     }

//--- outcome-variance guard: a classifier needs both classes present
   int loss_count=0;
   for(int k=0; k<total_n; k++)
      if(all_records[k].label>=0.5)
         loss_count++;
   if(loss_count==0 || loss_count==total_n)
     {
      Print("STOPPED: every closed trade in this sample has the same outcome, so there is no class "+
            "variance to learn from. This report needs a mix of winning and losing trades.");
      return;
     }

   int split=(int)MathFloor(total_n*(1.0-InpValidationFraction));
   int val_n=total_n-split;
   if(split<10 || val_n<10)
     {
      PrintFormat("STOPPED: the train/validation split would leave fewer than 10 trades on one side "+
                  "(%d train / %d validation). Add more history or reduce InpValidationFraction.",
                  split,val_n);
      return;
     }

   STradeRecord train_set[];
   STradeRecord val_set[];
   ArrayResize(train_set,split);
   ArrayResize(val_set,val_n);
   for(int k=0; k<split; k++)
      train_set[k]=all_records[k];
   for(int k=0; k<val_n; k++)
      val_set[k]=all_records[split+k];

//--- base rate: majority class measured on the TRAINING split only -- the
//--- validation period's true rate would not be knowable in advance
   int train_loss_count=0;
   for(int k=0; k<split; k++)
      if(train_set[k].label>=0.5)
         train_loss_count++;
   int majority_class=((double)train_loss_count/split>=0.5) ? 1 : 0;

   int base_correct=0;
   for(int k=0; k<val_n; k++)
      if((int)val_set[k].label==majority_class)
         base_correct++;
   double base_acc=(double)base_correct/val_n;

   CMlpNet net;
   net.Init(NLPA_N_FEATURES,InpHiddenNeurons,InpRandomSeed);

   double first_loss,last_loss;
   TrainNetwork(net,train_set,split,InpEpochs,InpLearningRate,first_loss,last_loss);

   double val_acc=Accuracy(net,val_set,val_n);
   double uplift =val_acc-base_acc;

   int    bin_count[];
   double bin_avg_pred[];
   double bin_actual[];
   double calib_err;
   CalibrationTable(net,val_set,val_n,InpCalibrationBins,bin_count,bin_avg_pred,bin_actual,calib_err);

   double importances[];
   PermutationImportance(net,val_set,val_n,InpPermutationRepeats,importances);

   int top_idx=0;
   for(int f=1; f<NLPA_N_FEATURES; f++)
      if(importances[f]>importances[top_idx])
         top_idx=f;

   double uplift_score,calib_score,feat_score;
   double score=CompositeGrade(uplift,calib_err,MathMax(importances[top_idx],0.0),
                                uplift_score,calib_score,feat_score);
   string grade=LetterGrade(score);

   string recs[];
   BuildRecommendations(uplift,calib_err,FeatureName(top_idx),importances[top_idx],total_n,recs);

//--- report -------------------------------------------------------------
   PrintFormat("Sample: %d total closing deals -> %d training / %d validation (chronological split, "+
               "most recent %.0f%% held out).",total_n,split,val_n,InpValidationFraction*100.0);
   PrintFormat("Training loss: first epoch=%.4f, last epoch=%.4f, over %d epochs.",
               first_loss,last_loss,InpEpochs);
   PrintFormat("Validation base rate (majority class from the training split): %.2f%%",base_acc*100.0);
   PrintFormat("Validation accuracy (trained network): %.2f%%  (uplift = %+.2f percentage points)",
               val_acc*100.0,uplift*100.0);
   PrintFormat("Calibration mean absolute error across %d bins: %.4f",InpCalibrationBins,calib_err);
   for(int b=0; b<InpCalibrationBins; b++)
      PrintFormat("  bin %d: n=%d  predicted avg=%.3f  actual frequency=%.3f",
                  b,bin_count[b],bin_avg_pred[b],bin_actual[b]);
   PrintFormat("Feature importance (validation-accuracy drop when the column is shuffled, averaged "+
               "over %d repeats):",InpPermutationRepeats);
   for(int f=0; f<NLPA_N_FEATURES; f++)
      Print("  ",PadRight(FeatureName(f),16)," ",DoubleToString(importances[f],4));
   PrintFormat("Composite score: uplift=%.1f, calibration=%.1f, feature=%.1f -> TOTAL=%.1f",
               uplift_score,calib_score,feat_score,score);
   PrintFormat("BEHAVIORAL PREDICTABILITY GRADE: %s",grade);
   Print("Recommendations:");
   for(int r=0; r<ArraySize(recs); r++)
      Print("  - ",recs[r]);
  }
//+------------------------------------------------------------------+
