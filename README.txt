PERCENTILE-BASED DATA SCREENING CODE

This repository contains code to facilitate binary data screening for percentile-based features. The original application was to screen amplitude triggerd audio files recorded from Bengalese finches into those containing song vs. files containing calls/cage noise/wing flaps.  For each feature considered, each file produces a distribution of features values, often by producing one feature value from the spectrum produced for each time bin in a spectrogram.  The software allows the experimenter to visualize the cumulative distributions, select a percentile that best separates target (song) from non-target (non-song) files by setting a threshold for that percentile value.  The software also allows the experimenter to view scatter plots of multiple features and calculate false positive and false negative rates from hand annotated data.

Step by step instructions can be found in Docs/song_non_song_screening_procedure.docx.

Please e-mail todd.troyer@utsa.edu if you are interested in using this code.

