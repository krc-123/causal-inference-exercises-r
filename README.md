# Three small causal inference exercises in R

Three short analyses in base R, each built around a question that looks simple and is not. They started as graduate coursework at Johns Hopkins using the datasets from Kosuke Imai's *Quantitative Social Science*, and are rebuilt here as standalone scripts with the interpretation written out, because code and output do not speak for themselves.

| Script | Question | Method |
|---|---|---|
| `01_turnout_measurement.R` | How much does survey-reported US turnout overstate real turnout, and does the denominator matter? | Measurement, rate construction |
| `02_basque_difference_in_differences.R` | Did ETA terrorism slow the Basque economy? | Cross-section, before-and-after, difference in differences |
| `03_vignettes_political_efficacy.R` | Can you compare self-reported political efficacy across China and Mexico? | Survey measurement, anchoring vignettes |

Run any of them from the repository root with `source("01_turnout_measurement.R")`. Each writes its charts to `output/` (the turnout comparison, the Basque parallel-trends plot, the self-assessment and age distributions). Base R only, no packages.

## 1. Turnout: the denominator is the whole argument

The dataset covers 14 US national elections from 1980 to 2008. Turnout can be computed against the voting-age population (VAP), which counts everyone over 18, or the voting-eligible population (VEP), which removes non-citizens and disenfranchised felons. VAP-based rates come out lower every year, because the denominator is padded with people who cannot legally vote.

The American National Election Studies survey asks people whether they voted. Against VEP turnout, respondents overstate by 16.8 percentage points on average, ranging from 8.6 to 22.5, which is consistent with social desirability bias: people who did not vote say they did. The gap is a little larger in presidential years (17.9 points) than midterms (15.4), which is the opposite of what I expected, and the midterm gap swings far more from year to year.

Rebuilding VEP by hand for 2008, taking felons and non-citizens out of the VAP denominator and overseas ballots out of the numerator, gives 61.4 percent, within a tenth of a point of the published VEP figure (61.6). The survey said 78.

## 2. Basque Country: three answers, one of them defensible

Per capita GDP for 17 Spanish regions, 1955 to 1997. ETA terrorism in the Basque Country is dated from 1973. Three ways to estimate its economic effect:

- **Cross-section** (Basque versus other regions, post-1973 only): Basque Country is richer by 1.13 thousand 1986 dollars. Taken alone this says terrorism had no cost, which is wrong, because the Basque Country was already one of Spain's wealthiest regions before 1973.
- **Before and after** (Basque only): GDP rose by 2.68 thousand after 1973. Also misleading, because the whole Spanish economy grew in that period, through late industrialization, the transition to democracy after Franco, and European integration.
- **Difference in differences**: the other regions grew by 3.16 thousand; the Basque Country by 2.68. The difference is minus 0.48 thousand 1986 dollars per capita. Terrorism did not collapse the economy, but it dragged on growth in a way that shows up once you account for what was happening everywhere else in Spain at the same time.

DiD depends on the parallel trends assumption, that the Basque Country would have tracked the other regions without ETA. You cannot prove it. You can look at whether the two lines moved together before 1973, which is what the chart is for.

## 3. Vignettes: when a 3 in China is not a 3 in Mexico

A 2002 WHO pretest asked respondents in two Chinese and three Mexican provinces how much say they have in government, on a 1 to 5 scale. Chinese respondents averaged 2.57; Mexican respondents 1.86. A one-party state reporting more political efficacy than a competitive multiparty democracy is a red flag for the measurement, not a finding about politics. Age does not explain it: the age profiles differ (median 45 in China, 35.5 in Mexico) but age barely correlates with self-assessment in either country (r = 0.20 and minus 0.01).

The respondents are interpreting the scale through their own political reality. The survey anticipated this and also asked each person to rate three hypothetical people described in vignettes, Alison, Jane, and Moses, who have decreasing amounts of say. Ranking each person's self-rating against their own ratings of those three (the King et al. anchoring approach) removes the scale-interpretation problem. After anchoring, the gap reverses: Mexico 1.75, China 1.58. The raw numbers were technically correct and answered the wrong question.

The anchoring step at the end of script 3 is an extension beyond the original exercise.

## Data

The three CSVs in `data/` are the teaching datasets distributed with Imai (2017), *Quantitative Social Science: An Introduction*, Princeton University Press, and are reproduced here for convenience. Original sources:

- `turnout.csv`: McDonald, M. P., and Popkin, S. L. (2001). The myth of the vanishing voter. *American Political Science Review*, 95(4), 963–974.
- `basque.csv`: Abadie, A., and Gardeazabal, J. (2003). The economic costs of conflict: A case study of the Basque Country. *American Economic Review*, 93(1), 113–132.
- `vignettes.csv`: King, G., Murray, C. J. L., Salomon, J. A., and Tandon, A. (2004). Enhancing the validity and cross-cultural comparability of measurement in survey research. *American Political Science Review*, 98(1), 191–207.

## License

MIT for the code. Data as credited above.
