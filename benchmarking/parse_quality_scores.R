library(dplyr)
library(tidyr)

# Function to parse quality score data
parse_quality_data <- function(data_lines) {
  samples_data <- list()

  i <- 1
  while (i <= length(data_lines)) {
    if (i + 1 <= length(data_lines)) {
      x_line <- strsplit(data_lines[i], "\t")[[1]]
      y_line <- strsplit(data_lines[i + 1], "\t")[[1]]

      # Check if this is an X/Y pair
      if (length(x_line) > 1 && length(y_line) > 1 &&
          x_line[2] == "X" && y_line[2] == "Y") {

        sample_name <- x_line[1]
        quality_scores <- as.numeric(x_line[3:length(x_line)])
        counts <- as.numeric(y_line[3:length(y_line)])

        samples_data[[sample_name]] <- list(
          quality_scores = quality_scores,
          counts = counts
        )

        i <- i + 2
      } else {
        i <- i + 1
      }
    } else {
      i <- i + 1
    }
  }

  return(samples_data)
}

# Function to create quality score dataframe
create_quality_dataframe <- function(data_lines) {
  # Parse the data
  samples_data <- parse_quality_data(data_lines)

  if (length(samples_data) == 0) {
    return(data.frame())
  }

  # Get union of all quality scores
  all_quality_scores <- c()
  for (sample_name in names(samples_data)) {
    all_quality_scores <- c(all_quality_scores, samples_data[[sample_name]]$quality_scores)
  }
  all_quality_scores <- sort(unique(all_quality_scores))

  # Create a list to store dataframes for each sample
  sample_dfs <- list()

  for (sample_name in names(samples_data)) {
    quality_scores <- samples_data[[sample_name]]$quality_scores
    counts <- samples_data[[sample_name]]$counts

    # Create dataframe for this sample
    sample_df <- data.frame(
      Quality_Score = quality_scores,
      Count = counts,
      stringsAsFactors = FALSE
    )
    names(sample_df)[2] <- sample_name

    # Create complete dataframe with all quality scores
    complete_df <- data.frame(
      Quality_Score = all_quality_scores,
      stringsAsFactors = FALSE
    )

    # Merge to fill missing values with 0
    complete_df <- merge(complete_df, sample_df, by = "Quality_Score", all.x = TRUE)
    complete_df[is.na(complete_df[, 2]), 2] <- 0

    sample_dfs[[sample_name]] <- complete_df
  }

  # Combine all samples into one dataframe
  result_df <- sample_dfs[[1]]

  if (length(sample_dfs) > 1) {
    for (i in 2:length(sample_dfs)) {
      result_df <- merge(result_df, sample_dfs[[i]], by = "Quality_Score", all = TRUE)
    }
  }

  # Set Quality_Score as row names and remove the column
  rownames(result_df) <- result_df$Quality_Score
  result_df$Quality_Score <- NULL

  return(result_df)
}




# Create the DataFrame
data_lines <- readLines("./bcftools_stats_vqc (3).tsv")
df <- create_quality_dataframe(data_lines)
df_t <- as.data.frame(t(df)) %>%
  mutate(
    sample_id = sub("\\..*", "", rownames(df_t)),
    genome = if_else(stringr::str_detect(rownames(df_t), "deepvariant"), "chm13", "grch38")) %>%
  select(sample_id, genome, everything())

rownames(df_t) <- NULL
df_t[df_t == 0] <- NA

#calculate averages and arrange in format for plotting
summary_df <- df_t %>%
  group_by(genome) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE))

plot_df <- summary_df %>%
  pivot_longer(
    cols = -genome,
    names_to = "variable",
    values_to = "mean_value"
  )
plot_df <- plot_df %>%
  mutate(variable = as.numeric(as.character(variable))) # Convert to numeric


#plot
ggplot(plot_df, aes(x = variable, y = mean_value, group = genome, color = genome)) +
  geom_line(size = 1) +
  labs(
    title = "Variant quality score distribution",
    x = "Quality score",
    y = "Average number of variants",
    color = "Genome"
  ) +
  scale_x_continuous(
    breaks = seq(min(plot_df$variable, na.rm = TRUE),
                 max(plot_df$variable, na.rm = TRUE),
                 by = 5) # Show every 1 quality score step
  ) +
  scale_y_continuous(limits = c(0, 17000)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  theme_minimal()
