# Can you compare self-reported political efficacy across countries?
# Katie-Rose Chubb
#
# Data: data/vignettes.csv, from a 2002 WHO pretest survey in two Chinese and
# three Mexican provinces. self = respondent's own rating of how much say they
# have in government (1 = no say, 5 = unlimited say); alison, jane, moses =
# ratings of three hypothetical people described in vignettes; china = 1 for
# Chinese respondents; age in years. Source: King et al. (2004), via Imai (2017) QSS.

vignettes <- read.csv("data/vignettes.csv")

china  <- subset(vignettes, china == 1)
mexico <- subset(vignettes, china == 0)

# ---- Raw self-assessment ------------------------------------------------
cat("China mean self-assessment: ", round(mean(china$self,  na.rm = TRUE), 3), "\n")
cat("Mexico mean self-assessment:", round(mean(mexico$self, na.rm = TRUE), 3), "\n")

china_prop  <- prop.table(table(china$self))
mexico_prop <- prop.table(table(mexico$self))

dir.create("output", showWarnings = FALSE)
png("output/self_assessment_by_country.png", width = 1000, height = 500, res = 120)
par(mfrow = c(1, 2))
barplot(china_prop,  main = "Self-assessment: China",  col = "#2C7BB6", ylim = c(0, 0.6),
        xlab = "1 = no say, 5 = unlimited say", ylab = "Proportion")
barplot(mexico_prop, main = "Self-assessment: Mexico", col = "#D7191C", ylim = c(0, 0.6),
        xlab = "1 = no say, 5 = unlimited say", ylab = "Proportion")
dev.off()

# ---- Does age explain the gap? ------------------------------------------
cat("Median age, China: ", median(china$age,  na.rm = TRUE), "\n")
cat("Median age, Mexico:", median(mexico$age, na.rm = TRUE), "\n")

cat("Age and self-assessment, China: r =",
    round(cor(china$age,  china$self,  use = "complete.obs"), 3), "\n")
cat("Age and self-assessment, Mexico: r =",
    round(cor(mexico$age, mexico$self, use = "complete.obs"), 3), "\n")

png("output/age_by_country.png", width = 1000, height = 500, res = 120)
par(mfrow = c(1, 2))
hist(china$age,  main = "Age: China",  xlab = "Age", col = "#2C7BB6", breaks = 20)
abline(v = median(china$age,  na.rm = TRUE), col = "black", lwd = 2)
hist(mexico$age, main = "Age: Mexico", xlab = "Age", col = "#D7191C", breaks = 20)
abline(v = median(mexico$age, na.rm = TRUE), col = "black", lwd = 2)
dev.off()

# ---- Anchoring with the vignettes ---------------------------------------
# The fix for scale-interpretation differences is to rank each person's
# self-rating against how they rated the same three hypothetical people.
# Moses has the least say, Jane more, Alison the most. A respondent who rates
# themselves above Alison is in the top group regardless of which number they
# chose. This is the King et al. (2004) anchoring vignette approach.
vignettes$self_anchored <- with(vignettes,
  ifelse(self > alison, 4,
  ifelse(self > jane,   3,
  ifelse(self > moses,  2, 1))))

cat("\nAnchored self-assessment (1 = below Moses, 4 = above Alison)\n")
print(round(prop.table(table(vignettes$self_anchored[vignettes$china == 1])), 3))
print(round(prop.table(table(vignettes$self_anchored[vignettes$china == 0])), 3))
cat("China mean anchored: ", round(mean(vignettes$self_anchored[vignettes$china == 1], na.rm = TRUE), 3), "\n")
cat("Mexico mean anchored:", round(mean(vignettes$self_anchored[vignettes$china == 0], na.rm = TRUE), 3), "\n")
