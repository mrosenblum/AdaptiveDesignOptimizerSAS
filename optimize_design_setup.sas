/* For inclusion within sas/iml */
start optimize_designs(
   ui_n_arms,                            /*     ui.n.arms                                            Num                       2   */
   ui_type_of_outcome_data,              /*     ui.type.of.outcome.data                              Char      '"time-to-event"'   */
   ui_time_to_event_trial_type,          /*     ui.time.to.event.trial.type                          Char    '"non-inferiority"'   */
   ui_time_to_event_non_inf_margin,      /*     ui.time.to.event.non.inferiority.trial.margin        Num                    1.35   */
   ui_subpopulation_1_size,              /*     ui.subpopulation.1.size                              Num                    0.33   */
   ui_total_alpha,                       /*     ui.total.alpha                                       Num                    0.05   */
   ui_max_size,                          /*     ui.max.size                                          Num                   10000   */
   ui_max_duration,                      /*     ui.max.duration                                      Num                      10   */
   ui_accrual_yearly_rate,               /*     ui.accrual.yearly.rate                               Num                    1000   */
   ui_followup_length,                   /*     ui.followup.length                                   Num                       0   */
   ui_optimization_target,               /*     ui.optimization.target                               Char              '"size'"'   */
   ui_time_to_event_censoring_rate,      /*     ui.time.to.event.censoring.rate                      Num                       0   */
   ui_mcid,                              /*     ui.mcid                                              Num                     0.1   */
   ui_incorporate_precision_gain,        /*     ui.incorporate.precision.gain                        LChar             '"FALSE"'   */
   ui_relative_efficiency,               /*     ui.relative.efficiency                               Num                       1   */
   ui_max_stages,                        /*     ui.max.stages                                        Num                       2   */
   ui_include_designs_start_subpop1,     /*     ui.include.designs.start.subpop.1                    LChar             '"FALSE"'   */
    
   ui_population_parameters=,            /*     ui.population.parameters                             Char with R matrix expression */
   population_parameters_mat=,           /*     matrix part of ui.population.parameters              SAS numerical matrix          */
   population_parameters_lab=,           /*     labels for ui.population.parameters                  SAS character matrix          */
    
   ui_desired_power=,                    /*     ui.desired.power                                     Char with R matrix expression */
   desired_power_mat=,                   /*     matrix part of ui.desired.power                      SAS numerical matrix          */
   desired_power_lab=,                   /*     labels for ui.desired.power                          SAS character matrix          */
    
   ui_scenario_weights=,                 /*     ui.scenario.weights                                  Char with R matrix expression */
   scenario_weights_mat=,                /*     matrix part of ui.scenario.weights                   SAS numerical matrix          */
   scenario_weights_lab=,                /*     labels for ui.scenario.weights                       SAS character matrix          */
    
   sap_max_iterations=1000,              /*     simulated.annealing.parameter.max.iterations         Num                    2      */
   sap_function_scale=1,                 /*     simulated.annealing.parameter.function.scale         Num                           */
   sap_n_scale=100,                      /*     simulated.annealing.parameter.n.scale                Num                           */
   sap_period_scale=2,                   /*     simulated.annealing.parameter.period.scale           Num                           */
   sap_n_simulations=10000,              /*     simulated.annealing.parameter.n.simulations          Num                           */
   sap_means_temperature=100,            /*     simulated.annealing.parameter.means.temperature      Num                           */
   sap_survival_temperature=10,          /*     simulated.annealing.parameter.survival.temperature   Num                           */
   sap_evals_per_temp=10,                /*     simulated.annealing.parameter.evals.per.temp         Num                           */
   sap_report_iteration=1,               /*     simulated.annealing.parameter.report.iteration       Num                           */
   sap_power_penalty=1e+05,              /*     simulated.annealing.parameter.power.penalty          Num                           */

   libpath=,                             /*     R library path to use                                Char                          */
   print_options=,                       /*     R print options                                      Char                          */
   seed=25,                              /*     Seed used in R                                       Num                           */
   outlib="work"                         /*     Library reference for output datasets                Char                          */
 );
    par1 = 1;
    if isskipped( ui_population_parameters ) then do;
      par1 = 0;
      ui_population_parameters = 0;
      run exportMatrixToR ( population_parameters_mat, "popmat" );
      run exportMatrixToR ( population_parameters_lab, "poplab" );
    end;

    par2 = 1;
    if isskipped( ui_desired_power ) then do;
      par2 = 0;
      ui_desired_power = 0;
      run exportMatrixToR ( desired_power_mat, "powmat" );
      run exportMatrixToR ( desired_power_lab, "powlab" );
    end;   
    
    par3 = 1;
    if isskipped( ui_scenario_weights ) then do;
      par3 = 0;
      ui_scenario_weights = 0;
      run exportMatrixToR ( scenario_weights_mat, "weightmat" );
      run exportMatrixToR ( scenario_weights_lab, "weightlab" );
    end;   

    addpath = 0;
    if isskipped( libpath ) = 0 then do;
      addpath = 1;
      libPaths = libpath;
    end;
    else libPaths = "";

    propts = 0;
    if isskipped( print_options ) = 0 then do;
      propts = 1;
      r_print_options = print_options;
    end;
    else r_print_options = "";
    
    submit  
      ui_n_arms                          ui_type_of_outcome_data            ui_time_to_event_trial_type 
      ui_time_to_event_non_inf_margin    ui_subpopulation_1_size            ui_total_alpha   
      ui_max_size                        ui_max_duration                    ui_accrual_yearly_rate 
      ui_followup_length                 ui_optimization_target             ui_time_to_event_censoring_rate
      ui_mcid                            ui_incorporate_precision_gain      ui_relative_efficiency  
      ui_max_stages                      ui_include_designs_start_subpop1   ui_population_parameters
      ui_desired_power                   ui_scenario_weights                sap_max_iterations
      libPaths r_print_options par1 par2 par3 addpath propts seed
      / R;

      if ( &addpath == 1 ) .libPaths(&libPaths)
      library( AdaptiveDesignOptimizer )
       
      if ( &propts == 1 ) options(&r_print_options)

      par1 <- &par1
      if ( par1 == 0 ) {
         ui.population.parameters1           <- popmat
         colnames(ui.population.parameters1) <- poplab
      } else {
         ui.population.parameters1           <- &ui_population_parameters
      }

      par2 <- &par2
      if ( par2 == 0 ) {
        ui.desired.power1                    <- powmat
        colnames(ui.desired.power1)          <- powlab
      } else {
        ui.desired.power1                    <- &ui_desired_power
      }

      par3 <- &par3
      if ( par3 == 0 ) {
        ui.scenario.weights1                 <- weightmat
        colnames(ui.scenario.weights1)       <- weightlab
      } else {
        ui.scenario.weights1                 <- &ui_scenario_weights
      }
    
      set.seed(&seed)   

      od <- optimize_designs(
        ui.n.arms                                       =  &ui_n_arms,
        ui.type.of.outcome.data                         =  &ui_type_of_outcome_data,
        ui.time.to.event.trial.type                     =  &ui_time_to_event_trial_type,
        ui.time.to.event.non.inferiority.trial.margin   =  &ui_time_to_event_non_inf_margin,
        ui.subpopulation.1.size                         =  &ui_subpopulation_1_size,
        ui.total.alpha                                  =  &ui_total_alpha,
        ui.max.size                                     =  &ui_max_size,
        ui.max.duration                                 =  &ui_max_duration,
        ui.accrual.yearly.rate                          =  &ui_accrual_yearly_rate,
        ui.followup.length                              =  &ui_followup_length,
        ui.optimization.target                          =  &ui_optimization_target,
        ui.time.to.event.censoring.rate                 =  &ui_time_to_event_censoring_rate,
        ui.mcid                                         =  &ui_mcid,
        ui.incorporate.precision.gain                   =  &ui_incorporate_precision_gain,
        ui.relative.efficiency                          =  &ui_relative_efficiency,
        ui.max.stages                                   =  &ui_max_stages,
        ui.include.designs.start.subpop.1               =  &ui_include_designs_start_subpop1,
        ui.population.parameters                        =  ui.population.parameters1,
        ui.desired.power                                =  ui.desired.power1,
        ui.scenario.weights                             =  ui.scenario.weights1,
        simulated.annealing.parameter.max.iterations    =  &sap_max_iterations
      )
      print(od)
      saveRDS(od, file = "C:/work/Michael/Design2/Test6/RDS/od.rds" )

      omat <- ((od[[1]])[[1]])[[1]]
      omat2 <- ((od[["Two.Stage.Group.Sequential.Design"]])[["design.performance"]])[["Expected.Duration"]]
      omat2 <- data.frame(omat2)
      print(omat2)

      cnt    <- 1
      odTN   <- list()
      odTL   <- list()
      names1 <- names(od)
      for ( i in 1:length(od) ) {
        od1    <- od[[i]]
        names2 <- names(od1)
        for ( j in 1:length(od1) ) {
          od2 <- od1[[j]]
          names3 <- names(od2)
          for ( k in 1:length(od2) ) {
            od3 <- od2[[k]]
            name1 <- names1[i]
            name2 <- names2[j]
            name3 <- names3[k]

            odx   <- od3
	    for ( r in which( sapply( odx, class ) == "factor" ) ) odx[[r]] = as.character( odx[[r]] )
            odx  <- cbind( name1, name2, name3, odx, stringsAsFactors=FALSE )
	    omatname <- sprintf("ODT_%d_%d_%d", i, j, k )
            odTN[[cnt]] <- c( name1, name2, name3, omatname)
	    odTL[[cnt]] <- odx
	    cnt         <- cnt+1
         }
       }
     }
     cnt <- cnt - 1
     odTN <- do.call( rbind, odTN )
     odTN <- as.data.frame(odTN, stringsAsFactors=FALSE)
     colnames(odTN) <- c("name1", "name2", "name3", "TableName" )

     for ( i in 1:cnt ) {
       dat <- odTL[[i]]
       assign( odTN[i,4], dat )
     }
     endsubmit;

    * Get the dataset names ;
    Tname = cats( outlib, ".", "ODTableNames" );
    print(Tname);
    run importDatasetFromR ( Tname,          "odTN" );
    run importDatasetFromR ( "ODTableNames", "odTN" );

    use ODTableNames;
    read all var _char_ into odTNames;
    close ODTableNames;

    do i = 1 to nrow(odTNames);
      Tname = cats( outlib, ".", trim(left(odTNames[i,4])));
      Rname = trim(left(odTNames[i,4]));
      run importDatasetFromR ( Tname, Rname );
    end;
    return(0);
finish;

