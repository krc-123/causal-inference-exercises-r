# How much does survey-reported turnout overstate real turnout?
# Katie-Rose Chubb
#
# Data: data/turnout.csv, US national elections 1980 to 2008 (2006 absent).
# Counts are in thousands. VEP = voting-eligible population, VAP = voting-age
# population, ANES = turnout as reported by American National Election Studies
# respondents, felons and noncit = ineligible people counted in VAP,
# overseas = eligible voters abroad, osvoters = ballots cast from overseas.

turnout <- read.csv("data/turnout.csv")

dim(turnout)
range(turnout$year)
max(turnout$felons)          # thousands, so about 3.17 million ineligible felons at the peak

# ---- Two turnout rates --------------------------------------------------
# VAP-based: ballots over voting-age population plus overseas eligibles,
# because overseas voters are not in the domestic VAP count.
turnout$VAP_turnout <- turnout$total / (turnout$VAP + turnout$overseas) * 100

# VEP-based: ballots over the population that is actually eligible.
turnout$VEP_turnout <- turnout$total / turnout$VEP * 100

print(data.frame(
  year        = turnout$year,
  VAP_turnout = round(turnout$VAP_turnout, 2),
  VEP_turnout = round(turnout$VEP_turnout, 2),
  ANES        = turnout$ANES
))

# ---- How far off is the survey? ------------------------------------------
turnout$diff_VAP_ANES <- turnout$ANES - turnout$VAP_turnout
turnout$diff_VEP_ANES <- turnout$ANES - turnout$VEP_turnout

cat("ANES minus VAP turnout, mean:", round(mean(turnout$diff_VAP_ANES), 2),
    " range:", round(range(turnout$diff_VAP_ANES), 2), "\n")
cat("ANES minus VEP turnout, mean:", round(mean(turnout$diff_VEP_ANES), 2),
    " range:", round(range(turnout$diff_VEP_ANES), 2), "\n")

# ---- Presidential versus midterm years -----------------------------------
pres_years <- c(1980, 1984, 1988, 1992, 1996, 2000, 2004, 2008)
mid_years  <- c(1982, 1986, 1990, 1994, 1998, 2002)

pres <- subset(turnout, year %in% pres_years)
mid  <- subset(turnout, year %in% mid_years)

cat("Presidential years, ANES minus VEP: mean", round(mean(pres$diff_VEP_ANES), 2),
    " range", round(range(pres$diff_VEP_ANES), 2), "\n")
cat("Midterm years, ANES minus VEP: mean", round(mean(mid$diff_VEP_ANES), 2),
    " range", round(range(mid$diff_VEP_ANES), 2), "\n")

# ---- Rebuilding VEP from VAP for 2008 ------------------------------------
# Take ineligible felons and non-citizens out of the denominator, add overseas
# eligibles, and take overseas ballots out of the numerator.
t2008 <- subset(turnout, year == 2008)

adj_VAP      <- t2008$VAP + t2008$overseas - t2008$felons - t2008$noncit
adj_total    <- t2008$total - t2008$osvoters
adj_VAP_rate <- adj_total / adj_VAP * 100

cat("\n2008\n")
cat("  Unadjusted VAP turnout:", round(t2008$VAP_turnout, 2), "\n")
cat("  Adjusted VAP turnout:  ", round(adj_VAP_rate, 2), "\n")
cat("  VEP turnout:           ", round(t2008$VEP_turnout, 2), "\n")
cat("  ANES reported turnout: ", t2008$ANES, "\n")

# ---- Plot ---------------------------------------------------------------
dir.create("output", showWarnings = FALSE)
png("output/turnout_measures.png", width = 900, height = 600, res = 120)
plot(turnout$year, turnout$ANES, type = "b", pch = 19, col = "#D7191C",
     ylim = c(30, 85), xlab = "Election year", ylab = "Turnout (percent)",
     main = "Reported turnout (ANES) versus measured turnout, 1980 to 2008")
lines(turnout$year, turnout$VEP_turnout, type = "b", pch = 17, col = "#2C7BB6")
lines(turnout$year, turnout$VAP_turnout, type = "b", pch = 15, col = "#ABD9E9")
legend("bottomleft", bty = "n",
       legend = c("ANES self-report", "VEP turnout", "VAP turnout"),
       col = c("#D7191C", "#2C7BB6", "#ABD9E9"), pch = c(19, 17, 15), lty = 1)
dev.off()
