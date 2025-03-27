# Load necessary libraries
library(ggplot2)       # For visualization
library(dbscan)        # For DBSCAN clustering

# Set the working directory
setwd("C:/Users/abent/Documents/Coding")

# Part 1: Scree plots for eigenval files
eigenval_files <- list.files(pattern = "\\.eigenval$")

for (file in eigenval_files) {
  # Load the eigenvalues
  eigenvalues <- read.table(file, header = FALSE)
  
  # Calculate the proportion of variance explained
  variance_explained <- eigenvalues$V1 / sum(eigenvalues$V1)
  percentage_explained <- variance_explained * 100
  
  # Define the output file name for the scree plot
  output_file <- paste0(sub("\\.eigenval$", "", file), "_scree_plot.png")
  
  # Save the scree plot as a PNG file
  png(output_file, width = 800, height = 600)
  
  # Create the scree plot
  plot(variance_explained, 
       type = "b", 
       xlab = "Principal Component", 
       ylab = "Proportion of Variance Explained", 
       main = paste("Scree Plot -", file), 
       pch = 20, 
       col = "red")
  
  # Add the percentages as text labels next to each point
  text(x = seq_along(percentage_explained), 
       y = variance_explained, 
       labels = paste0(round(percentage_explained, 1), "%"), 
       pos = 4, 
       cex = 0.8, 
       col = "#000000")
  
  # Close the PNG device
  dev.off()
}

# Part 2: Scatter plots for eigenvec files
eigenvec_files <- list.files(pattern = "\\.eigenvec$")
color_palette <- c("#4B0082", "#0000FF", "#008000", "#FFFF00", "orange")

# Load the metadata
meta <- read.table("hgdp_wgs.20190516.metadata.txt", header = TRUE)

for (file in eigenvec_files) {
  # Load the eigenvectors
  eigenvectors <- read.table(file, header = FALSE)
  
  # Remove the first column and rename columns
  eigenvectors <- eigenvectors[, -1]
  colnames(eigenvectors) <- c("SampleID", paste0("PC", 1:(ncol(eigenvectors) - 1)))
  
  # Merge eigenvectors with metadata
  pca_data <- merge(eigenvectors, meta, by.x = "SampleID", by.y = "sample")
  
  # Define the base name for the file (to use in plot titles and output file names)
  base_name <- sub("\\.eigenvec$", "", file)
  
  # Generate enhanced scatter plots using metadata features
  metadata_features <- c("population", "region", "sex", "coverage", "latitude", "longitude", "library_type", "source")
  for (feature in metadata_features) {
    # Define the output file name for the plot
    output_file <- paste0(base_name, "_PC1_PC2_", feature, "_scatter_plot.png")
    
    # Save the plot as a PNG file
    png(output_file, width = 800, height = 600)
    
    # Create the scatter plot based on the feature
    plot <- ggplot(data = pca_data, aes(x = PC1, y = PC2, color = .data[[feature]])) +
      geom_point(size = 3) +
      labs(title = paste("PCA Scatter Plot (PC1 vs PC2) by", feature),
           x = "Principal Component 1",
           y = "Principal Component 2") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5))  # Center-align the title
    
    # If the feature is a numerical value, add gradient coloring
    if (feature %in% c("coverage", "latitude", "longitude")) {
      plot <- plot + scale_color_gradient(low = "green", high = "purple")
    }
    
    # Print the plot
    print(plot)
    
    # Close the PNG device
    dev.off()
  }
  
  # Part 3: K-means clustering
  centers_to_try <- c(3, 4, 5)
  for (centers in centers_to_try) {
    # Apply k-means clustering
    clusters <- kmeans(pca_data[, c("PC1", "PC2")], centers = centers)
    pca_data$Cluster <- as.factor(clusters$cluster)
    
    # Define the output file name for the clustering plot
    output_file <- paste0(base_name, "_PC1_PC2_kmeans_", centers, "_clusters.png")
    
    # Save the plot as a PNG file
    png(output_file, width = 800, height = 600)
    
    # Create the clustering plot
    plot <- ggplot(pca_data, aes(x = PC1, y = PC2, color = Cluster)) +
      geom_point(size = 3) +
      labs(title = paste("K-Means Clustering (PC1 vs PC2) -", centers, "Clusters"),
           x = "Principal Component 1",
           y = "Principal Component 2") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5))  # Center-align the title
    
    # Print the plot
    print(plot)
    
    # Close the PNG device
    dev.off()
  }
  
  # Part 4: DBSCAN clustering
  eps_values <- c(0.01, 0.001, 0.002, 0.003)
  min_pts_values <- c(3, 4, 5)
  
  for (eps in eps_values) {
    for (min_pts in min_pts_values) {
      # Apply DBSCAN clustering
      db <- dbscan(pca_data[, c("PC1", "PC2")], eps = eps, minPts = min_pts)
      pca_data$Cluster <- as.factor(db$cluster)
      
      # Define the output file name for the DBSCAN clustering plot
      output_file <- paste0(base_name, "_PC1_PC2_dbscan_eps", eps, "_minPts", min_pts, ".png")
      
      # Save the plot as a PNG file
      png(output_file, width = 800, height = 600)
      
      # Create the DBSCAN clustering plot
      plot <- ggplot(pca_data, aes(x = PC1, y = PC2, color = Cluster)) +
        geom_point(size = 3) +
        labs(title = paste("DBSCAN Clustering (PC1 vs PC2)\n eps =", eps, ", minPts =", min_pts),
             x = "Principal Component 1",
             y = "Principal Component 2") +
        theme_minimal() +
        theme(plot.title = element_text(hjust = 0.5))  # Center-align the title
      
      # Print the plot
      print(plot)
      
      # Close the PNG device
      dev.off()
    }
  }
}
