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
class EA
  {

public:

   double            promedioEMA;
   double            b0;
   double            b1;
   double            r0;
   double            r1;
   int               perceptron;
      int ha;

   double buff0;
   double buff1;

   void Update(int tf=PERIOD_M1)
     {
      double iMAX0=iCustom(NULL,0,"iMAX3alert1",4,0);
      double iMAX1=iCustom(NULL,0,"iMAX3alert1",5,0);

      double iMAX01=iCustom(NULL, 0, "iMAX3alert1",4,1);
      double iMAX11=iCustom(NULL, 0, "iMAX3alert1",5,1);



      b0 = iMAX0;
      b1 = iMAX01;
      r0 = iMAX1;
      r1 = iMAX11;

      if(b0>r0 && b1<r1)
         perceptron=1;

      if(b0<r0 && b1>r1)
         perceptron=-1;

      buff0=iCustom(NULL,0,"HA",2,0);
      buff1=iCustom(NULL,0,"HA",3,0);

      if(buff0>buff1)
         ha=-1;

      if(buff0<buff1)
         ha=1;
         
         promedioEMA=iMA(NULL,tf,13,8,MODE_SMMA,PRICE_MEDIAN,0);
         

     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

   Update();
      
      
      Print("1: ",perceptron," 2: ",ha," 3: ",promedioEMA," 4: ",cmd);
 
      if(perceptron>0 && ha>0 && Close[1]>promedioEMA && cmd==OP_SELL)
         return true;


      if(perceptron<0 && ha<0 && Close[1]<promedioEMA && cmd==OP_BUY)
         return true;


      return false;

     }

  };
//+------------------------------------------------------------------+
