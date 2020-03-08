# pirouette example that replicates Sarver et al., 2019 
# (not done yet)
library(pirouette)
library(beautier)
# Constants
is_testing <- is_on_ci()
example_no <- "sarver_et_al_2019" # Not exactly a number
rng_seed <- 314
folder_name <- paste0("example_", example_no, "_", rng_seed)

# Create phylogeny
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
# Setup pirouette
pir_params <- create_std_pir_params(
  folder_name = folder_name
)
if (is_testing) {
  pir_params <- shorten_pir_params(pir_params)
}

# Run pirouette
pir_out <- pir_run(
  phylogeny,
  pir_params = pir_params
)

# Save results
pir_save(
  phylogeny = phylogeny,
  pir_params = pir_params,
  pir_out = pir_out,
  folder_name = folder_name
)

