#Libraries
install.packages("GGally")
library(GGally)
library(tidyverse)

# Set the working directory
setwd("C:/Users/abent/Documents/Coding")


##eigenvalues##
# Load the eigenvalues
eigenvalues <- read.table("pca.eigenval", header = FALSE)
# Calculate the proportion of variance explained
variance_explained <- eigenvalues$V1 / sum(eigenvalues$V1)
# Create a scree plot
plot(variance_explained, 
     type = "b", 
     xlab = "Principal Component", 
     ylab = "Proportion of Variance Explained", 
     main = "Scree Plot", 
     pch = 20, 
     col = "#EE82EE")

##eigenvectors##
# Load the eigenvectors
eigenvectors <- read.table("pca.eigenvec", header = FALSE)
# Remove the first column since its a duplicate
eigenvectors <- eigenvectors[, -1]
# Renaming the columns
colnames(eigenvectors) <- c("SampleID", paste0("PC", 1:10))

# Scatter plot of PC1 vs PC2
plot(eigenvectors$PC1, eigenvectors$PC2,
     xlab = "Principal Component 1",
     ylab = "Principal Component 2",
     main = "PCA Scatter Plot",
     col = "#4B0082",
     pch = 20)
# Adding SampleID labels to the scatter plot
text(eigenvectors$PC1, eigenvectors$PC2, 
     labels = eigenvectors$SampleID, 
     pos = 4, cex = 0.7)

# Scatter plot of PC3 vs PC4
plot(eigenvectors$PC3, eigenvectors$PC4,
     xlab = "Principal Component 3",
     ylab = "Principal Component 4",
     main = "PCA Scatter Plot",
     col = "#0000FF",
     pch = 20)
# Scatter plot of PC5 vs PC6
plot(eigenvectors$PC5, eigenvectors$PC6,
     xlab = "Principal Component 5",
     ylab = "Principal Component 6",
     main = "PCA Scatter Plot",
     col = "#008000",
     pch = 20)
# Scatter plot of PC7 vs PC8
plot(eigenvectors$PC7, eigenvectors$PC8,
     xlab = "Principal Component 7",
     ylab = "Principal Component 8",
     main = "PCA Scatter Plot",
     col = "#FFFF00",
     pch = 20)
# Scatter plot of PC9 vs PC10
plot(eigenvectors$PC9, eigenvectors$PC10,
     xlab = "Principal Component 9",
     ylab = "Principal Component 10",
     main = "PCA Scatter Plot",
     col = "orange",
     pch = 20)


# Pairwise scatter plots for all 10 principal components
pairs(eigenvectors[, 2:11], # Select only the PC columns
      main = "Pairwise Scatter Plots of Principal Components",
      pch = 20, col = "red")
# Create a pairs plot with GGally
ggpairs(eigenvectors[, 2:11], # Select PC columns
        title = "Pairwise Scatter Plots of Principal Components")



##### Labelling the data further based on the metadata file ######

# read Metadata file
meta <- read.table("hgdp_wgs.20190516.metadata.txt", header = TRUE)
# Merge eigenvectors with metadata based on sample IDs
pca_data <- merge(eigenvectors, meta, by.x = "SampleID", by.y = "sample")


# If interested in visualising the data from a specific region (if HGDP was not filtered at first) uncomment the following lines
# unique(pca_data$region)
# table(pca_data$region)
#pca_data = subset(pca_data, region == "CENTRAL_SOUTH_ASIA")

# Scatter plot of PC1 vs PC2 colored by population
ggplot(data = pca_data, aes(x = PC1, y = PC2, color = population)) +
  geom_point(size = 3) +
  labs(title = "PCA Scatter Plot (PC1 vs PC2) by Population", x = "Principal Component 1", y = "Principal Component 2") +
  theme_minimal()
# Scatter plot of PC1 vs PC2 colored by region
ggplot(data = pca_data, aes(x = PC1, y = PC2, color = region)) +
  geom_point(size = 3) +
  labs(title = "PCA Scatter Plot (PC1 vs PC2) by Region", x = "Principal Component 1", y = "Principal Component 2") +
  theme_minimal()
# Scatter plot of PC1 vs PC2 colored by sex
ggplot(data = pca_data, aes(x = PC1, y = PC2, color = sex)) +
  geom_point(size = 3) +
  labs(title = "PCA Scatter Plot (PC1 vs PC2) by Sex", x = "Principal Component 1", y = "Principal Component 2") +
  theme_minimal()
# Scatter plot of PC1 vs PC2 colored by Coverage
ggplot(data = pca_data, aes(x = PC1, y = PC2, color = coverage)) +
  geom_point(size = 3) +
  scale_color_gradient(low = "blue", high = "red") +
  labs(title = "PCA Scatter Plot (PC1 vs PC2) by Coverage Level", x = "Principal Component 1", y = "Principal Component 2") +
  theme_minimal()
# Scatter plot of PC1 vs PC2 colored by Latitude
ggplot(data = pca_data, aes(x = PC1, y = PC2, color = latitude)) +
  geom_point(size = 3) +
  scale_color_gradient(low = "green", high = "purple") +
  labs(title = "PCA Scatter Plot (PC1 vs PC2) by Latitude", x = "Principal Component 1", y = "Principal Component 2") +
  theme_minimal()
# Scatter plot of PC1 vs PC2 colored by Longitude
ggplot(data = pca_data, aes(x = PC1, y = PC2, color = longitude)) +
  geom_point(size = 3) +
  scale_color_gradient(low = "lightblue", high = "orange") +
  labs(title = "PCA Scatter Plot (PC1 vs PC2) by Latitude", x = "Principal Component 1", y = "Principal Component 2") +
  theme_minimal()
# Scatter plot of PC1 vs PC2 colored by Latitude and Longitude
pca_data$GeoGroup <- interaction(cut(pca_data$latitude, breaks = 3), cut(pca_data$longitude, breaks = 3))
ggplot(data = pca_data, aes(x = PC1, y = PC2, color = GeoGroup)) +
  geom_point(size = 3) +
  labs(title = "PCA Scatter Plot (PC1 vs PC2)  by Geographical Group (Latitude and Longitude)", x = "Principal Component 1", y = "Principal Component 2") +
  theme_minimal() +
  scale_color_viridis_d()  # Use a color palette for clarity
# Scatter plot of PC1 vs PC2 colored by Library_type to compare technical aspects
ggplot(data = pca_data, aes(x = PC1, y = PC2, color = library_type)) +
  geom_point(size = 3) +
  labs(title = "PCA Scatter Plot (PC1 vs PC2) by Library Type", x = "Principal Component 1", y = "Principal Component 2") +
  theme_minimal()
# Scatter plot of PC1 vs PC2 colored by Data source to compare technical aspects
ggplot(data = sa_data, aes(x = PC1, y = PC2, color = source)) +
  geom_point(size = 3) +
  labs(title = "PCA Scatter Plot (PC1 vs PC2) by Data Source", x = "Principal Component 1", y = "Principal Component 2") +
  theme_minimal()

