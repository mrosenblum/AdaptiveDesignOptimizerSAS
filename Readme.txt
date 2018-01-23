.  Download R if it is not already installed on your machine.
2.  To download the AdaptiveDesignOptimizer package and its required
    package you will need to start R and enter these two lines at the R prompt:  

       install.packages("devtools")
       devtools::install_github("mrosenblum/AdaptiveDesignOptimizer")
       q()

    You will need to note where the library was stored.
    On my machine this was given as "C:/Users/uname/Documents/R/win-library/3.4".
 
3.  Change the SAS configuration file to include the two lines:

       -RLANG
       -SET R_HOME "path to R executable"

    The first of these allows SAS to pass code to R in a submit block.  The
    second gives the location of the R executible on your pc.  On my pc the R
    executable is at "C:\Program Files\R\R-3.4.0".

4.  The examples can be run by changing the four macro variables as required:
	
      %let libref      =  work;
      %let optlocation =  C:\work\OptDesignTest;
      %let pdflocation =  C:\work\OptDesignTest;
      %let rlibpath    = 'C:/Users/uname/Documents/R/win-library/3.4';

    The output library reference is set to work by default.  If you wish to
    keep the output datasets created assign a library and set libref to the
    library reference.  For example:

      library  mylib "C:\work\OptDesignTest\Example1Datasets";
      %let libref = mylib;

    The macro variable optlocation is set to the location of the
    optimize_design_setup.sas file. For example:

      %let pdflocation = C:\work\OptDesignTest;

    The pdflocation macro variable is set to the location where the output
    pdf (listing) should be stored.

    The rlibpath is set to the location where the R libraries are located.
    Note they are enclosed with single quotation marks. This is the location
    given when downloading the libraries in 2. above.

