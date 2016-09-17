//+------------------------------------------------------------------+
//|                                                      Elliott.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                                           kenorb |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property version   "1.00"
#property strict

#include  <Convert.mqh>


extern int       A_t3_period=18;
extern int       num_bars=350;
extern int       is_A_open_price=0;
extern int       B_t3_period_ac=10;
extern int       diferential=0;
extern double    hot=0.7;
extern int CountBars=350;
extern bool UseAlert=True;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class T3Trix
  {

public:

   double            mtfstochs,mtfstochsb4;
   double            mtfstochs1,mtfstochs1b4;

   void Update(int tf=PERIOD_M1)
     {
      int shift=0;

      mtfstochs=iCustom(Symbol(),tf,"T3 -trix",A_t3_period,num_bars,is_A_open_price,B_t3_period_ac,diferential,hot,0,shift+0);
      mtfstochsb4=iCustom(Symbol(),tf,"T3 -trix",A_t3_period,num_bars,is_A_open_price,B_t3_period_ac,diferential,hot,0,shift+1);
      mtfstochs1=iCustom(Symbol(),tf,"T3 -trix",A_t3_period,num_bars,is_A_open_price,B_t3_period_ac,diferential,hot,1,shift+0);
      mtfstochs1b4=iCustom(Symbol(),tf,"T3 -trix",A_t3_period,num_bars,is_A_open_price,B_t3_period_ac,diferential,hot,1,shift+1);

     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {
 
      if((mtfstochsb4>mtfstochs1b4 && mtfstochs<mtfstochs1) && cmd==OP_BUY)
         return true;


      if((mtfstochsb4<mtfstochs1b4 && mtfstochs>mtfstochs1) && cmd==OP_SELL)
         return true;


      return false;

     }

  };
//+------------------------------------------------------------------+
