# Big-Data-R-Purchase-Prediction
## What is this?

This project looks at the "Online Shoppers Purchasing Intention Dataset" (Sakar et al., 2019, UCI Machine Learning Repository) to answer two questions: how well do page-behavior metrics predict whether a visitor will actually generate revenue, and how much do visitor type and timing (month, weekend) affect the odds of converting from browser to buyer?

The dataset covers 12,330 unique sessions, each from a different visitor over the course of a year, with only about 15% ending in a purchase, a pretty realistic (and pretty imbalanced) picture of how online retail actually converts.

## Data cleaning and prep

Checked for missing values (there were none), removed 125 duplicate rows, and converted a handful of columns to factors where the numbers didn't actually mean anything numeric. OperatingSystems, Browser, Region, and TrafficType, for instance, are numeric codes standing in for categories, not real quantities, so leaving them as numbers would have implied a false ordering. Same logic applied to Month and VisitorType (turned into factors so models like Naive Bayes could work with them properly) and to Weekend/Revenue for compatibility with the classification functions. Checked for logically impossible negative durations (found none) and reviewed outliers in the three duration variables, but kept them since there weren't many.

## Modeling

Split the data 70/30 into training and test sets, stratified on Revenue to preserve the original class balance, and trained with 10-fold cross-validation for stability.

**Naive Bayes** turned out to be a poor fit for this data. Because the classes are so imbalanced (about 84% non-buyers), the model just learned to predict "no purchase" for basically everyone, hitting 84% accuracy while completely failing to identify actual buyers (0% specificity, negative Kappa). Technically accurate, practically useless.

**Logistic regression** did much better. At the default 0.5 threshold it correctly flagged 229 buyers; lowering the threshold to 0.3 pushed that up to 326, trading a few more false positives for a much better balanced accuracy (from 68% to 75.6%) and specificity (40% to 57%), with an AUC of 0.898.

| Metric | Naive Bayes | Logistic Regression (0.3) |
|---|---|---|
| Overall accuracy | 84.3% | 88.5% |
| Buyers correctly identified | 0 | 326 |
| Specificity | 0% | 56.9% |
| Balanced accuracy | 50.0% | 75.6% |

## What came out of it

PageValues was by far the strongest predictor of conversion, followed by ExitRates in the opposite direction (the more pages a visitor exits from without continuing, the less likely they are to buy). Timing mattered too: certain months (like November, likely tied to Black Friday) noticeably shifted purchase probability, while returning visitors were actually *less* likely to convert than new ones, a bit counterintuitive, but consistent with prior research on the same dataset.

## Tech

R (tidyverse, tidymodels, caret, skimr, corrplot), with logistic regression via `glm()` and Naive Bayes via `caret::train()`.

## Files

- `Proiect_codSursa_-_curat.R` — full analysis code
- `online_shoppers_intention.csv` — dataset (originally from UCI ML Repository / Sakar et al., 2019)
- `IuliaVisan_BigData_proiect.pdf` — full write-up with all figures and step-by-step explanations
IuliaVisan_BigData_proiect.pdf — full write-up with all figures and step-by-step explanations
