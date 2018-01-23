options nodate nonumber nocenter ls=140 ps=100  papersize=letter;

/* The default output library is work. 
   If you want to keep all the output datasets then, uncomment the
   libname statement and change the "Location of outputs".
   Change the libref macro variable from work to mylib
   
   libname mylib "Location of outputs";
*/
%let libref      =  work;
%let optlocation =  C:\work\OptDesignTest;
%let pdflocation =  C:\work\OptDesignTest;
%let rlibpath    = 'C:/Users/uname/Documents/R/win-library/3.4';

ods _all_ close;
ods pdf file="&pdflocation.\example1.pdf" notoc style=journal2;
title;

proc iml;
  reset pagesize=5500;
  %include "&optlocation.\optimize_design_setup.sas";

  * Define these matrices as SAS matrices;
  population_parameters_mat    = 0.08 #  { 1.0          1.0          1.0          1.0,
                                           1.0          1.0          1.0    1.3500001,
                                           1.0          1.0          1.0         2.14,
                                           1.0          1.0    1.3500001    1.3500001 };   
  population_parameters_lab    = { "lambda1_con", "lambda2_con", "lambda1_trt", "lambda2_trt"};

  desired_power_mat            = 0.8  #  {  1.0   1.0   0.0,
                                            1.0   0.0   0.0,
                                            1.0   0.0   0.0,
                                            0.0   0.0   0.0 };
  desired_power_lab            = { "Pow_H(0,1)", "Pow_H(0,2)", "Pow_Reject_H0,1_and_H0,2"};
  create desired_power from desired_power_mat [ colname = { "H01", "H02", "H01andH02" } ];
  append from desired_power_mat;
  close desired_power;

  scenario_weights_mat         = { 0.25, 0.25, 0.25, 0.25};
  scenario_weights_lab         = {"weight"};

  rlibpath                     = "&rlibpath";
  ropts                        = 'width=140,papersize="letter"';

  od =  optimize_designs(
    /*  ui.n.arms                                          Num   */                           2,
    /*  ui.type.of.outcome.data                            Char  */           '"time-to-event"',
    /*  ui.time.to.event.trial.type                        Char  */         '"non-inferiority"', 
    /*  ui.time.to.event.non.inferiority.trial.margin      Num   */                        1.35,
    /*  ui.subpopulation.1.size                            Num   */                        0.33,
    /*  ui.total.alpha                                     Num   */                        0.05,
    /*  ui.max.size                                        Num   */                       10000,
    /*  ui.max.duration                                    Num   */                          10,
    /*  ui.accrual.yearly.rate                             Num   */                        1000,
    /*  ui.followup.length                                 Num   */                           0,
    /*  ui.optimization.target                             Char  */                    '"size"',
    /*  ui.time.to.event.censoring.rate                    Num   */                           0,
    /*  ui.mcid                                            Num   */                         0.1,
    /*  ui.incorporate.precision.gain                      LChar */                   '"FALSE"',
    /*  ui.relative.efficiency                             Num   */                           1,
    /*  ui.max.stages                                      Num   */                           2,
    /*  ui.include.designs.start.subpop.1                  LChar */                   '"FALSE"',
    /*  ui.population.parameters                           MChar */                            ,
    /*  population.parameters.mat                          Mat   */   population_parameters_mat,
    /*  population.parameters.lab                          Mat   */   population_parameters_lab,
    /*  ui.desired.power                                   MChar */                            ,
    /*  desired.power.mat                                  Mat   */           desired_power_mat,
    /*  desired.power.lab                                  Mat   */           desired_power_lab,
    /*  ui.scenario.weights                                MChar */                            ,
    /*  scenario.weights.mat                               Mat   */        scenario_weights_mat,
    /*  scenario.weights.lab                               Mat   */        scenario_weights_lab,
    /*  simulated.annealing.parameter.max.iterations       Num   */                           2,
    /*  simulated.annealing.parameter.function.scale       Num   */                            ,
    /*  simulated.annealing.parameter.n.scale              Num   */                            ,
    /*  simulated.annealing.parameter.period.scale         Num   */                            ,
    /*  simulated.annealing.parameter.n.simulations        Num   */                            ,
    /*  simulated.annealing.parameter.means.temperature    Num   */                            ,
    /*  simulated.annealing.parameter.survival.temperature Num   */                            ,
    /*  simulated.annealing.parameter.evals.per.temp       Num   */                            ,
    /*  simulated.annealing.parameter.report.iteration     Num   */                            ,
    /*  simulated.annealing.parameter.power.penalty        Num   */                            ,
    /*  Add to R library path                              Char  */                    rlibpath, 
    /*  R print options                                    Char  */                       ropts,
    /*  seed                                               Num   */                          22,
    /*  outlib                                            Char   */                    "&libref"
   );
quit;

data desiredPower;
   set desired_Power;
   scenario = _n_;
run;

data power;
  length name1 $50;
  set &libref..odt_1_2_1 ( in = in1 )
      &libref..odt_2_2_1 ( in = in2 )
      &libref..odt_3_2_1 ( in = in3 )
      &libref..odt_4_2_1 ( in = in4 )
      &libref..odt_5_2_1 ( in = in5 );
  type = in1 + 2 * in2 + 3 * in3 + 4 * in4 + 5 * in5;
proc sort data=power;
  by scenario;
data power;
  merge power desiredPower;
  by scenario;

  diff1 = Power_H01 - H01;
  diff2 = Power_H02 - H02;
  diff3 = Prob_reject_all_false_null_hypot - H01andH02;

  minPowerDiff = min( of diff1 diff2 diff3 );
  drop diff1 diff2 diff3;
proc sort data = power;
  by type minPowerDiff;
proc means data = power noprint;
  var minPowerDiff;
  by type;
  output out = minPowerDiff(drop=_:)
         min = minPowerDiff;
data power;
  merge power MinPowerDiff( in = inmin );
  by type minPowerDiff;
  mark = inmin;

  label  name1                             = "Design";
  label  Scenario                          = "Scenario";
  label  PowerH01                          = "Power H0(0,1)";
  label  PowerH02                          = "Power H0(0,2)";
  label  Prob_Reject_all_false_null_Hypot  = "Prob Reject All False Null Hypotheses";
  label  H01                               = "Desired H0(0,1)";
  label  H02                               = "Desired H0(0,2)";
  label  H01andH02                         = "Desired H0(0,1) and H0(0,2)";
  label  minPowerDiff                      = "Minimum difference in power (obtained - desired)";
  label  mark                              = "Minimum power difference for this design";
run;

title "Minimum power difference (obtained - desired) for each Design";
proc print data = power labels noobs;
  where mark = 1;
  var name1 scenario minPowerDiff;
run;
ods pdf close;
