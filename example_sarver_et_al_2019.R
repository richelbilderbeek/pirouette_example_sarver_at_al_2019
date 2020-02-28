library(pirouette)
suppressMessages(library(ggplot2))
library(beautier)

################################################################################
# Constants
################################################################################
is_testing <- is_on_travis()
example_no <- "sarver_et_al_2019" # Not exactly a number
rng_seed <- 314
folder_name <- paste0("example_", example_no, "_", rng_seed)

################################################################################
# Create phylogeny
################################################################################
set.seed(rng_seed)
# Same as https://github.com/bricesarver/prior_simulation_study/blob/master/simulate_trees.R#L26
phylogeny  <- TreeSim::sim.bd.taxa.age(
  n = 25,
  numbsim = 1,
  age = 5,
  lambda = 0.5051457,
  mu = 0,
  frac = 1.0,
  mrca = FALSE
)[[1]]

ape::write.tree(phylogeny, file = "tree_true.fas")

################################################################################
# Setup pirouette
################################################################################
pir_params <- create_std_pir_params(
  folder_name = folder_name
)

if (is_testing) {
  pir_params <- shorten_pir_params(pir_params)
}

################################################################################
# Run pirouette
################################################################################
errors <- pir_run(
  phylogeny,
  pir_params = pir_params
)

utils::write.csv(
  x = errors,
  file = file.path(folder_name, "errors.csv"),
  row.names = FALSE
)

pir_plot(errors) +
  ggsave(file.path(folder_name, "errors.png"))

pir_to_pics(
  phylogeny = phylogeny,
  pir_params = pir_params,
  folder = folder_name
)

pir_to_tables(
  pir_params = pir_params,
  folder = folder_name
)
