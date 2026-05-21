# Why employees see their managers as perfectionists

This repository contains the analysis code for a study examining how the way managers give feedback shapes whether employees see them as perfectionists, and how that perception then influences what employees prioritize at work.

The study surveyed 469 full-time US employees three times over one week. The case study writeup is available at https://personal-website-production-877d.up.railway.app

## Files

Mptext1.inp` — Mplus syntax for the latent profile analysis used to group employees into three feedback environment profiles (high-quality, moderate, unfavorable).
  
final analysis.sas` — SAS syntax for the full analysis pipeline. Includes composite score creation, reliability (Cronbach's alpha) for each scale, confirmatory factor analysis, the moderated regression testing whether feedback orientation moderates the effect of feedback profile on perceived manager perfectionism, simple slopes at ±1 SD, mediation paths, the PROCESS macro for moderated mediation, and a manual bootstrap (5,000 resamples) for conditional indirect effects.

## Data

The data is not included in this repository for participant privacy reasons.

## Author

Mohammed Othman, MASc candidate in Industrial/Organizational Psychology, University of Waterloo.
