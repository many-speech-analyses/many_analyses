# Changelog

## 2022-08-17

- We have run a non-prereg meta-analytic model with `model_id` instead of `team` as a group-level effect, because many teams have submitted multiple analyses. This type of meta-model requires each individual estimate to be its own group-level effect. We also run a non-prereg model with `team:model_id` as a nested group-level effect.
- The team `nestor_idahoensis` specified Bayesian priors, but we were unsure which priors to use after scaling all the variables. So we opted for using the default priors of brms (flat priors for `b` and data-derived Student-*t* distribution for intercepts).
- We have excluded the number of post-hoc analyses (`n_phoc`) from the analytic and researcher-related model because the teams didn't report any as such.
- We have excluded the number of random effects (`n_rand`, i.e. conservativeness) from the analytic and researcher-related model because this variable is very much related to the estimate standard error (more random effects = higher standard error).
- Analytic and researcher-related predictors have been transformed to *z*-scores.

## 2022-06-16

- As mentioned below, We decided to keep to our original protocol in terms of refitting submitted models to get standardised effect sizes.
- However, we changed minor aspects of the protocol of the refitting procedure (see protocol at <https://many-speech-analyses.github.io/many_analyses/scripts/r/04_refit_workflow>), specifically file  and variable naming conventions and the use of treatment contrasts instead of sum coding.
- ~~AND, we will include two predictors in the meta-analytic model: typicality operationalisation (to account for categorical vs continuous) and outcome variable (to account for possible differences in sign of the effect depending on the outcome).~~ >> We decided not to include these, because these are included in the Analytic and researcher-related predictors model.

## 2022-05-27

- Sent email to AMPPS (AMPPS - Decision on Proposal ID AMPPS-21-0020.R1) asking to update the protocol.
- ~~David Sbarra says OK with option 3: We could redefine our effect size definition and use for example Westfall et al.'s proposal (2014) to define effect sizes in hierarchical models.~~ >> Afterwards, we decided not to redefine our effect size definition. We stick to the pre-registered protocol.

## 2022-04-29

- ~~Review round 1: some teams did not complete the review by the deadline. They will be able to do so later on.~~ >> We have skipped missing reviews since we were running late with the review process due to wrong calculation of time allowed for review (2 weeks per round instead of 1 week per round).
- We decided to drop last round of review with all analysis plus revision of review due to time.

## 2022-04-19

- Change to the peer-review questionnaire: now we ask for the teams' animal name instead of first and last name of reviewer.

## 2022-02-18

- New members are joining. Take note that they should do the intake form and their prior belief should be excluded from the analysis.
- Close teams by end of February (one month and half before analysis submission deadline).

## 2021-11-29

- Deleted question 3 from the analytic approach questionnaire.
- We merged the intake form, recruitment form, and analytical approach form into one as per <https://github.com/many-speech-analyses/many_analyses/issues/89>.

## 2021-10-19

- Changed wordings in <https://many-speech-analyses.github.io> after feedback from researchers.

## 2021-10-15

- Recruitment is done with Eventbrite, which makes emailing all participants easier.
