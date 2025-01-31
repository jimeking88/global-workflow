=============
Configure Run
=============

The global-workflow configs contain switches that change how the system runs. Many defaults are set initially. Users wishing to run with different settings should adjust their $EXPDIR configs and then rerun the ``setup_xml.py`` script since some configuration settings/switches change the workflow/xml ("Adjusts XML" column value is "YES").

+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| Switch         | What                         | Default       | Adjusts XML | More Details                                      |
+================+==============================+===============+=============+===================================================+
| APP            | Model application            | ATM           | YES         | See case block in config.base for options         |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| DOIAU          | Enable 4DIAU for control     | YES           | NO          | Turned off for cold-start first half cycle        |
|                | with 3 increments            |               |             |                                                   | 
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| DOHYBVAR       | Run EnKF                     | YES           | YES         | Don't recommend turning off                       |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| DONST          | Run NSST                     | YES           | NO          | If YES, turns on NSST in anal/fcst steps, and     |
|                |                              |               |             | turn off rtgsst                                   |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| DO_AWIPS       | Run jobs to produce AWIPS    | NO            | YES         | downstream processing, ops only                   |
|                | products                     |               |             |                                                   |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| DO_BUFRSND     | Run job to produce BUFR      | NO            | YES         | downstream processing                             |
|                | sounding products            |               |             |                                                   |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| DO_GEMPAK      | Run job to produce GEMPAK    | NO            | YES         | downstream processing, ops only                   |
|                | products                     |               |             |                                                   |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| DO_GLDAS       | Run GLDAS to spin up land    | YES           | YES         | Spins up for 84hrs if sflux files not available   |
|                | ICs                          |               |             |                                                   |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| DO_VRFY        | Run vrfy job                 | NO            | YES         | Whether to include vrfy job (GSI monitoring,      |
|                |                              |               |             | tracker, VSDB, fit2obs)                           |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| DO_METP        | Run METplus jobs             | YES           | YES         | One cycle spinup                                  |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| EXP_WARM_START | Is experiment starting warm  | .false.       | NO          | Impacts IAU settings for initial cycle. Can also  |
|                | (.true.) or cold (.false)?   |               |             | be set when running ``setup_expt.py`` script with |
|                |                              |               |             | the ``--start`` flag (e.g. ``--start warm``)      |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| HPSSARCH       | Archive to HPPS              | NO            | Possibly    | Whether to save output to tarballs on HPPS        |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| LOCALARCH      | Archive to a local directory | NO            | Possibly    | Instead of archiving data to HPSS, archive to a   |
|                |                              |               |             | local directory, specified by ATARDIR. If         |
|                |                              |               |             | LOCALARCH=YES, then HPSSARCH must =NO. Changing   |
|                |                              |               |             | HPSSARCH from YES to NO will adjust the XML.      |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| QUILTING       | Use I/O quilting             | .true.        | NO          | If .true. choose OUTPUT_GRID as cubed_sphere_grid |
|                |                              |               |             | in netcdf or gaussian_grid                        |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| RETRO          | Use retrospective parallel   | NO            | NO          | Default of NO will tell getic job to pull from    |
|                | for ICs                      |               |             | production tapes.                                 |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| WAFSF          | Run jobs to produce WAFS     | NO            | YES         | downstream processing, ops only                   |
|                | products                     |               |             |                                                   |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
| WRITE_DOPOST   | Run inline post              | .true.        | NO          | If .true. produces master post output in forecast |
|                |                              |               |             | job                                               |
+----------------+------------------------------+---------------+-------------+---------------------------------------------------+
