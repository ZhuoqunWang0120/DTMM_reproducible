
rm(list = ls())

#setwd("./simulations") ####----set the working directory to the simulations folder
load("/dgp/tree.RData")

source("/functions/fit_functions.R") ##--load functions to fit each competing method
source("/dgp/sim_dmm_data.R")

library(MASS)

seed_exp <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))
dtmm_iter <- 2000
####

set.seed(seed_exp)
N_tot <- 90
prop <- c(4/9, 3/9, 2/9)
N_cluster <- apply(rmultinom(N_tot, 1, prop), 1, sum)
n1 <- N_cluster[1]
n2 <- N_cluster[2]
n3 <- N_cluster[3]

cluster_truth <- c(rep(1, n1), rep(2, n2), rep(3, n3))

####

a <- 1
alpha1 <- c(2,2,5,2,3,1) * a
alpha2 <- c(2,4,3,2,1,3) * a
alpha3 <- c(2,6,1,2,2,2) * a

y_s <- sim_dmm(seed = seed_exp, n1 = n1, n2 = n2, n3 = n3, alpha1 = alpha1, alpha2 = alpha2, alpha3 = alpha3)

a <- 3
alpha1 <- c(2,2,5,2,3,1) * a
alpha2 <- c(2,4,3,2,1,3) * a
alpha3 <- c(2,6,1,2,2,2) * a

y_m <- sim_dmm(seed = seed_exp, n1 = n1, n2 = n2, n3 = n3, alpha1 = alpha1, alpha2 = alpha2, alpha3 = alpha3)
y_n <- sim_dmm(seed = seed_exp, n1 = N_tot, n2 = 2, n3 = 2, alpha1 = alpha1, alpha2 = alpha2, alpha3 = alpha3)[1:N_tot, ]

a <- 5
alpha1 <- c(2,2,5,2,3,1) * a
alpha2 <- c(2,4,3,2,1,3) * a
alpha3 <- c(2,6,1,2,2,2) * a
y_l <- sim_dmm(seed = seed_exp, n1 = n1, n2 = n2, n3 = n3, alpha1 = alpha1, alpha2 = alpha2, alpha3 = alpha3)



n <- dim(y_s)[1]
methods <- c("DTMM", "DMM", "Kmeans", "PAM", "Hclust", "Spec", "Truth")

clusters_n <- matrix(0, nrow = length(methods), ncol = n)
clusters_s <- matrix(0, nrow = length(methods), ncol = n)
clusters_m <- matrix(0, nrow = length(methods), ncol = n)
clusters_l <- matrix(0, nrow = length(methods), ncol = n)

row.names(clusters_n) <- methods
row.names(clusters_s) <- methods
row.names(clusters_m) <- methods
row.names(clusters_l) <- methods

clusters_n["DTMM", ] <- fit_hdtm(y_n, tree, iter = dtmm_iter)
clusters_n["DMM", ] <- fit_dmm(y_n)
clusters_n["Kmeans", ] <- NA
clusters_n["PAM", ] <- NA
clusters_n["Hclust", ] <- NA
clusters_n["Spec", ] <- NA
clusters_n["Truth", ] <- rep(1, N_tot)

clusters_s["DTMM", ] <- fit_hdtm(y_s, tree, iter = dtmm_iter)
clusters_s["DMM", ] <- fit_dmm(y_s)
clusters_s["Kmeans", ] <- fit_kmeans(y_s, K = 3)
clusters_s["PAM", ] <- fit_pam(y_s, K = 3)
clusters_s["Hclust", ] <- fit_hclust(y_s, K = 3)
clusters_s["Spec", ] <- fit_spec(y_s, K = 3)
clusters_s["Truth", ] <- cluster_truth

clusters_m["DTMM", ] <- fit_hdtm(y_m, tree, iter = dtmm_iter)
clusters_m["DMM", ] <- fit_dmm(y_m)
clusters_m["Kmeans", ] <- fit_kmeans(y_m, K = 3)
clusters_m["PAM", ] <- fit_pam(y_m, K = 3)
clusters_m["Hclust", ] <- fit_hclust(y_m, K = 3)
clusters_m["Spec", ] <- fit_spec(y_m, K = 3)
clusters_m["Truth", ] <- cluster_truth

clusters_l["DTMM", ] <- fit_hdtm(y_l, tree, iter = dtmm_iter)
clusters_l["DMM", ] <- fit_dmm(y_l)
clusters_l["Kmeans", ] <- fit_kmeans(y_l, K = 3)
clusters_l["PAM", ] <- fit_pam(y_l, K = 3)
clusters_l["Hclust", ] <- fit_hclust(y_l, K = 3)
clusters_l["Spec", ] <- fit_spec(y_l, K = 3)
clusters_l["Truth", ] <- cluster_truth


res_dmm <- list(clusters_n = clusters_n, clusters_s = clusters_s, clusters_m = clusters_m, clusters_l = clusters_l)

setwd("/results")  ##--save the results to folder
file_name <- paste("res_dmm_small_", seed_exp, ".RData", sep = "")
save(res_dmm, file = file_name)

