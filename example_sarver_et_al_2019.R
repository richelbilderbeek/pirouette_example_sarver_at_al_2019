# Code of example 9
#
# Works under Windows
#
#
#

# Set the RNG seed
rng_seed <- 314

library(pirouette)
suppressMessages(library(ggplot2))
library(beautier)

root_folder <- getwd()

example_no <- "sarver_et_al_2019" # Not exactly a number
example_folder <- file.path(root_folder, paste0("example_", example_no, "_", rng_seed))
dir.create(example_folder, showWarnings = FALSE, recursive = TRUE)
setwd(example_folder)
set.seed(rng_seed)
testit::assert(is_beast2_installed())

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

alignment_params <- create_alignment_params(
  sim_tral_fun = get_sim_tral_with_std_nsm_fun(
    mutation_rate = 0.1
  ),
  root_sequence = create_blocked_dna(length = 1000),
  rng_seed = rng_seed,
  fasta_filename = "true_alignment.fas"
)

# JC69, strict, Yule
generative_experiment <- create_gen_experiment()
generative_experiment$beast2_options$input_filename <- "true_alignment_gen.xml"
generative_experiment$beast2_options$output_state_filename <- "true_alignment_gen.xml.state"
generative_experiment$inference_model$mcmc$tracelog$filename <- "true_alignment_gen.log"
generative_experiment$inference_model$mcmc$treelog$filename <- "true_alignment_gen.trees"
generative_experiment$inference_model$mcmc$screenlog$filename <- "true_alignment_gen.csv"
generative_experiment$errors_filename <- "true_errors_gen.csv"
check_experiment(generative_experiment)

experiments <- list(generative_experiment)

# Set the RNG seed
for (i in seq_along(experiments)) {
  experiments[[i]]$beast2_options$rng_seed <- rng_seed
}

# Testing
if (1 == 1) {
  for (i in seq_along(experiments)) {
    experiments[[i]]$inference_model$mcmc <- create_mcmc(chain_length = 20000, store_every = 1000)
  }
}

twinning_params <- create_twinning_params(
  rng_seed_twin_tree = rng_seed,
  sim_twin_tree_fun = get_sim_bd_twin_tree_fun(),
  rng_seed_twin_alignment = rng_seed,
  sim_twal_fun = get_sim_twal_same_n_muts_fun(
    mutation_rate = 0.1,
    max_n_tries = 1000
  ),
  twin_tree_filename = "twin_tree.newick",
  twin_alignment_filename = "twin_alignment.fas",
  twin_evidence_filename = "twin_evidence.csv"
)

pir_params <- create_pir_params(
  alignment_params = alignment_params,
  experiments = experiments,
  twinning_params = twinning_params
)

rm_pir_param_files(pir_params)

errors <- pir_run(
  phylogeny,
  pir_params = pir_params
)

utils::write.csv(
  x = errors,
  file = file.path(example_folder, "errors.csv"),
  row.names = FALSE
)

pir_plot(errors) +
  ggsave(file.path(example_folder, "errors.png"))

pir_to_pics(
  phylogeny = phylogeny,
  pir_params = pir_params,
  folder = example_folder
)

pir_to_tables(
  pir_params = pir_params,
  folder = example_folder
)