================
Experiment Setup
================

 Global workflow uses a set of scripts to help configure and set up the drivers (also referred to as Workflow Manager) that run the end-to-end system. While currently we use a `ROCOTO <https://github.com/christopherwharrop/rocoto/wiki/documentation>`__ based system and that is documented here, an `ecFlow <https://www.ecmwf.int/en/learning/training/introduction-ecmwf-job-scheduler-ecflow>`__ based systm is also under development and will be introduced to the Global Workflow when it is mature. To run the setup scripts, you need to make sure to have a copy of ``python3`` with ``numpy`` available. The easiest way to guarantee this is to load python from the `official hpc-stack installation <https://github.com/NOAA-EMC/hpc-stack/wiki/Official-Installations>`_ for the machine you are on:

.. list-table:: Python Module Load Commands
   :widths: 25 120
   :header-rows: 1

   * - **MACHINE**
     - **COMMAND(S)**
   * - Hera
     - ::

           module use -a /contrib/anaconda/modulefiles
           module load anaconda/anaconda3-5.3.1
   * - Orion
     - ::

           module load python/3.7.5
   * - WCOSS2
     - ::

           module load python/3.8.6
   * - S4
     - ::

           module load miniconda/3.8-s4

If running with Rocoto make sure to have a Rocoto module loaded before running setup scripts:

.. list-table:: ROCOTO Module Load Commands
   :widths: 25 120
   :header-rows: 1

   * - **MACHINE**
     - **COMMAND(S)**
   * - Hera
     - ::

           module load rocoto/1.3.3
   * - Orion
     - ::

           module load contrib
           module load rocoto/1.3.3
   * - WCOSS2
     - ::

           module use /apps/ops/test/nco/modulefiles/
           module load core/rocoto/1.3.5
   * - S4
     - ::

           module load rocoto/1.3.4

^^^^^^^^^^^^^^^^^^^^^^^^
Forecast-only experiment
^^^^^^^^^^^^^^^^^^^^^^^^

Scripts that will be used:

   * ``workflow/setup_expt.py``
   * ``workflow/setup_xml.py``

***************************************
Step 1: Run experiment generator script
***************************************

The following command examples include variables for reference but users should not use environmental variables but explicit values to submit the commands. Exporting variables like EXPDIR to your environment causes an error when the python scripts run. Please explicitly include the argument inputs when running both setup scripts:

::

   cd workflow
   ./setup_expt.py forecast-only --idate $IDATE --edate $EDATE [--app $APP] [--start $START] [--gfs_cyc $GFS_CYC] [--resdet $RESDET]
     [--pslot $PSLOT] [--configdir $CONFIGDIR] [--comrot $COMROT] [--expdir $EXPDIR] [--icsdir $ICSDIR]

where:

   * ``forecast-only`` is the first positional argument that instructs the setup script to produce an experiment directory for forecast only experiments.
   * ``$APP`` is the target application, one of:

     - ATM: atmosphere-only [default]
     - ATMW: atm-wave
     - ATMA: atm-aerosols
     - S2S: atm-ocean-ice
     - S2SW: atm-ocean-ice-wave
     - S2SWA: atm-ocean-ice-wave-aerosols

   * ``$START`` is the start type (warm or cold [default])
   * ``$IDATE`` is the initial start date of your run (first cycle CDATE, YYYYMMDDCC)
   * ``$EDATE`` is the ending date of your run (YYYYMMDDCC) and is the last cycle that will complete
   * ``$PSLOT`` is the name of your experiment [default: test]
   * ``$CONFIGDIR`` is the path to the ``/config`` folder under the copy of the system you're using [default: $TOP_OF_CLONE/parm/config/]
   * ``$RESDET`` is the FV3 resolution (i.e. 768 for C768) [default: 384]
   * ``$GFS_CYC`` is the forecast frequency (0 = none, 1 = 00z only [default], 2 = 00z & 12z, 4 = all cycles)
   * ``$COMROT`` is the path to your experiment output directory. DO NOT include PSLOT folder at end of path, it’ll be built for you. [default: $HOME (but do not use default due to limited space in home directories normally, provide a path to a larger scratch space)]
   * ``$EXPDIR`` is the path to your experiment directory where your configs will be placed and where you will find your workflow monitoring files (i.e. rocoto database and xml file). DO NOT include PSLOT folder at end of path, it will be built for you. [default: $HOME]
   * ``$ICSDIR`` is the path to the initial conditions. This is handled differently depending on whether ``$APP`` is S2S or not.

      - If ``$APP`` is ATM or ATMW, this setting is currently ignored
      - If ``$APP`` is S2S or S2SW, ICs are copied from the central location to this location and the argument is required

Examples:

Atm-only:

::

   cd workflow
   ./setup_expt.py forecast-only --pslot test --idate 2020010100 --edate 2020010118 --resdet 384 --gfs_cyc 4 --comrot /some_large_disk_area/Joe.Schmo/comrot --expdir /some_safe_disk_area/Joe.Schmo/expdir 

Coupled:

::

   cd workflow
   ./setup_expt.py forecast-only --app S2SW --pslot coupled_test --idate 2013040100 --edate 2013040100 --resdet 384 --comrot /some_large_disk_area/Joe.Schmo/comrot --expdir /some_safe_disk_area/Joe.Schmo/expdir --icsdir /some_large_disk_area/Joe.Schmo/icsdir

Coupled with aerosols:

::

   cd workflow
   ./setup_expt.py forecast-only --app S2SWA --pslot coupled_test --idate 2013040100 --edate 2013040100 --resdet 384 --comrot /some_large_disk_area/Joe.Schmo/comrot --expdir /some_safe_disk_area/Joe.Schmo/expdir --icsdir /some_large_disk_area/Joe.Schmo/icsdir

****************************************
Step 2: Set user and experiment settings
****************************************

Go to your EXPDIR and check/change the following variables within your config.base now before running the next script:

   * ACCOUNT
   * HOMEDIR
   * STMP
   * PTMP
   * ARCDIR (location on disk for online archive used by verification system)
   * HPSSARCH (YES turns on archival)
   * HPSS_PROJECT (project on HPSS if archiving)
   * ATARDIR (location on HPSS if archiving)

Some of those variables will be found within a machine-specific if-block so make sure to change the correct ones for the machine you'll be running on.

Now is also the time to change any other variables/settings you wish to change in config.base or other configs. `Do that now.` Once done making changes to the configs in your EXPDIR go back to your clone to run the second setup script. See :doc:configure.rst for more information on configuring your run.

*************************************
Step 3: Run workflow generator script
*************************************

This step sets up the files needed by the Workflow Manager/Driver. At this moment only ROCOTO configurations are generated:

::

   ./setup_xml.py $EXPDIR/$PSLOT

Example:

::

   ./setup_xml.py /some_safe_disk_area/Joe.Schmo/expdir/test

****************************************
Step 4: Confirm files from setup scripts
****************************************

You will now have a rocoto xml file in your EXPDIR ($PSLOT.xml) and a crontab file generated for your use. Rocoto uses CRON as the scheduler. If you do not have a crontab file you may not have had the rocoto module loaded. To fix this load a rocoto module and then rerun setup_xml.py script again. Follow directions for setting up the rocoto cron on the platform the experiment is going to run on.  

^^^^^^^^^^^^^^^^^
Cycled experiment
^^^^^^^^^^^^^^^^^

Scripts that will be used: 

   * ``workflow/setup_expt.py``
   * ``workflow/setup_xml.py``

***************************************
Step 1) Run experiment generator script
***************************************

The following command examples include variables for reference but users should not use environmental variables but explicit values to submit the commands. Exporting variables like EXPDIR to your environment causes an error when the python scripts run. Please explicitly include the argument inputs when running both setup scripts:

::

   cd workflow
   ./setup_expt.py cycled --idate $IDATE --edate $EDATE [--app $APP] [--start $START] [--gfs_cyc $GFS_CYC]
     [--resdet $RESDET] [--resens $RESENS] [--nens $NENS] [--cdump $CDUMP]
     [--pslot $PSLOT] [--configdir $CONFIGDIR] [--comrot $COMROT] [--expdir $EXPDIR] [--icsdir $ICSDIR]

where:

   * ``cycled`` is the first positional argument that instructs the setup script to produce an experiment directory for cycled experiments.
   * ``$APP`` is the target application, one of:

     - ATM: atmosphere-only [default]
     - ATMW: atm-wave

   * ``$IDATE`` is the initial start date of your run (first cycle CDATE, YYYYMMDDCC)
   * ``$EDATE`` is the ending date of your run (YYYYMMDDCC) and is the last cycle that will complete
   * ``$START`` is the start type (warm or cold [default])
   * ``$GFS_CYC`` is the forecast frequency (0 = none, 1 = 00z only [default], 2 = 00z & 12z, 4 = all cycles)
   * ``$RESDET`` is the FV3 resolution of the deterministic forecast [default: 384]
   * ``$RESENS`` is the FV3 resolution of the ensemble (EnKF) forecast [default: 192]
   * ``$NENS`` is the number of ensemble members [default: 20]
   * ``$CDUMP`` is the starting phase [default: gdas]
   * ``$PSLOT`` is the name of your experiment [default: test]
   * ``$CONFIGDIR`` is the path to the config folder under the copy of the system you're using [default: $TOP_OF_CLONE/parm/config/]
   * ``$COMROT`` is the path to your experiment output directory. DO NOT include PSLOT folder at end of path, it’ll be built for you. [default: $HOME]
   * ``$EXPDIR`` is the path to your experiment directory where your configs will be placed and where you will find your workflow monitoring files (i.e. rocoto database and xml file). DO NOT include PSLOT folder at end of path, it will be built for you. [default: $HOME]
   * ``$ICSDIR`` is the path to the ICs for your run if generated separately. [default: None]

.. [#]  More Coupled configurations in cycled mode are currently under development and not yet available

Example:

::

   cd workflow
   ./setup_expt.py cycled --pslot test --configdir /home/Joe.Schmo/git/global-workflow/parm/config --idate 2020010100 --edate 2020010118 --comrot /some_large_disk_area/Joe.Schmo/comrot --expdir /some_safe_disk_area/Joe.Schmo/expdir --resdet 384 --resens 192 --nens 80 --gfs_cyc 4

Example ``setup_expt.py`` on Orion:

::

   Orion-login-3$ ./setup_expt.py cycled --pslot test --idate 2022010118 --edate 2022010200 --resdet 192 --resens 96 --nens 80 --comrot /work/noaa/stmp/jschmo/comrot --expdir /work/noaa/global/jschmo/expdir
   EDITED:  /work/noaa/global/jschmo/expdir/test/config.base as per user input.
   EDITED:  /work/noaa/global/jschmo/expdir/test/config.aeroanl as per user input.
   EDITED:  /work/noaa/global/jschmo/expdir/test/config.ocnanal as per user input.

The message about the config.base.default is telling you that you are free to delete it if you wish but it’s not necessary to remove. Your resulting config.base was generated from config.base.default and the default one is there for your information.

What happens if I run ``setup_expt.py`` again for an experiment that already exists?

::

   Orion-login-3$ ./setup_expt.py cycled --pslot test --idate 2022010118 --edate 2022010200 --resdet 192 --resens 96 --nens 80 --comrot /work/noaa/stmp/jschmo/comrot --expdir /work/noaa/global/jschmo/expdir

   directory already exists in /work/noaa/stmp/jschmo/comrot/test

   Do you wish to over-write [y/N]: y

   directory already exists in /work/noaa/global/jschmo/expdir/test

   Do you wish to over-write [y/N]: y
   EDITED:  /work/noaa/global/jschmo/expdir/test/config.base as per user input.
   EDITED:  /work/noaa/global/jschmo/expdir/test/config.aeroanl as per user input.
   EDITED:  /work/noaa/global/jschmo/expdir/test/config.ocnanal as per user input.

Your ``COMROT`` and ``EXPDIR`` will be deleted and remade. Be careful with this!

****************************************
Step 2: Set user and experiment settings
****************************************

Go to your EXPDIR and check/change the following variables within your config.base now before running the next script:

   * ACCOUNT
   * HOMEDIR
   * STMP
   * PTMP
   * ARCDIR (location on disk for online archive used by verification system)
   * HPSSARCH (YES turns on archival)
   * HPSS_PROJECT (project on HPSS if archiving)
   * ATARDIR (location on HPSS if archiving)

Some of those variables will be found within a machine-specific if-block so make sure to change the correct ones for the machine you'll be running on.

Now is also the time to change any other variables/settings you wish to change in config.base or other configs. `Do that now.` Once done making changes to the configs in your EXPDIR go back to your clone to run the second setup script. See :doc: configure.rst for more information on configuring your run.


*************************************
Step 3: Run workflow generator script
*************************************

This step sets up the files needed by the Workflow Manager/Driver. At this moment only ROCOTO configurations are generated:

::

   ./setup_xml.py $EXPDIR/$PSLOT

Example:

::

   ./setup_xml.py /some_safe_disk_area/Joe.Schmo/expdir/test

****************************************
Step 4: Confirm files from setup scripts
****************************************

You will now have a rocoto xml file in your EXPDIR ($PSLOT.xml) and a crontab file generated for your use. Rocoto uses CRON as the scheduler. If you do not have a crontab file you may not have had the rocoto module loaded. To fix this load a rocoto module and then rerun ``setup_xml.py`` script again. Follow directions for setting up the rocoto cron on the platform the experiment is going to run on.  

