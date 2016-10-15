//+------------------------------------------------------------------+
//|                                                      Elliott.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                                           kenorb |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property version   "1.00"
#property strict
//#include  <Convert.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

 
extern int       PeriodShift=0;
extern int       PrevPeriodShift=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EA
  {

public:

   double            FastPeriod_0_Current;
   double            SlowPeriod_0_Previous;
   double            FastPeriod_0_Current1;
   double            SlowPeriod_0_Previous1;

   void Update(int tf=PERIOD_M1)
     {

      int i=0;
      FastPeriod_0_Current=iCustom(NULL,tf,"Cycle_KROUFR_version",12,24,50,false,0,i+PeriodShift);
      SlowPeriod_0_Previous=iCustom(NULL,tf,"Cycle_KROUFR_version",12,24,50,false,0,i+PrevPeriodShift+PeriodShift+1);

      FastPeriod_0_Current1=iCustom(NULL,tf,"Cycle_KROUFR_version",12,24,50,false,0,i+PeriodShift+1);
      SlowPeriod_0_Previous1=iCustom(NULL,tf,"Cycle_KROUFR_version",12,24,50,false,0,i+PrevPeriodShift+PeriodShift+1+1);

     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

      Update(tf);

      if((FastPeriod_0_Current>SlowPeriod_0_Previous && FastPeriod_0_Current1<SlowPeriod_0_Previous1) && cmd==OP_SELL)
         return true;
      else if((FastPeriod_0_Current<SlowPeriod_0_Previous && FastPeriod_0_Current1>SlowPeriod_0_Previous1) && cmd==OP_BUY)
         return true;

      return false;

     }
  };
//+------------------------------------------------------------------+
