# Load required libraries
library(ggplot2)
library(sf)
library(rnaturalearth)
library(geosphere)
library(dplyr)
library(showtext)
library(hexSticker)
# Reduced dataframe with 15 airports from different geographies
airports <- data.frame(
  name = c(
    "Hartsfield–Jackson Atlanta International Airport",  # North America
    "Los Angeles International Airport",                # North America
    "Beijing Capital International Airport",             # East Asia
    "Tokyo Haneda Airport",                              # East Asia
    "Dubai International Airport",                       # Middle East
    "Delhi Indira Gandhi International Airport",         # South Asia
    "Singapore Changi Airport",                          # Southeast Asia
    "O.R. Tambo International Airport (Johannesburg)",   # Africa
    "Cairo International Airport",                       # Africa
    "London Heathrow Airport",                           # Europe
    "Frankfurt am Main Airport",                         # Europe
    "Sydney Kingsford Smith Airport",                    # Oceania
    "São Paulo–Guarulhos International Airport",         # South America
    "Buenos Aires Ministro Pistarini International Airport", # South America
    "Lima Jorge Chávez International Airport"            # South America
  ),
  lon = c(
    -84.4277,   # Atlanta
    -118.4085,  # Los Angeles
    116.4075,   # Beijing
    139.7798,   # Tokyo
    55.3644,    # Dubai
    77.1031,    # Delhi
    103.9882,   # Singapore
    28.2488,    # Johannesburg
    31.4065,    # Cairo
    -0.4543,    # London
    8.5706,     # Frankfurt
    151.1772,   # Sydney
    -46.4822,   # São Paulo
    -58.5350,   # Buenos Aires
    -77.1068    # Lima
  ),
  lat = c(
    33.6367,    # Atlanta
    33.9416,    # Los Angeles
    40.0799,    # Beijing
    35.5494,    # Tokyo
    25.2528,    # Dubai
    28.5562,    # Delhi
    1.3502,     # Singapore
    -26.1338,   # Johannesburg
    30.1201,    # Cairo
    51.4700,    # London
    50.0379,    # Frankfurt
    -33.9399,   # Sydney
    -23.4356,   # São Paulo
    -34.8222,   # Buenos Aires
    -12.0219    # Lima
  )
)

# Check the dataframe
print(airports)


# Check the dataframe
print(airports)


# Check the dataframe
print(airports)


# Check the dataframe
print(airports)

# Convert airports to sf points
airport_points <- st_as_sf(airports, coords = c("lon", "lat"), crs = 4326)

# Generate great circle routes between all pairs of airports
connections <- do.call(rbind, lapply(1:(nrow(airports) - 1), function(i) {
  do.call(rbind, lapply((i + 1):nrow(airports), function(j) {
    gc <- gcIntermediate(
      c(airports$lon[i], airports$lat[i]),
      c(airports$lon[j], airports$lat[j]),
      n = 100, addStartEnd = TRUE, sp = TRUE
    )
    st_as_sf(gc) %>%
      mutate(from = airports$name[i], to = airports$name[j])
  }))
}))


# Convert the great circle line to an sf object
gc_sf <- connections

# Get a world map using rnaturalearth
world <- ne_countries(scale = "medium", returnclass = "sf")

# Create the plot
ggplot() +
  # Plot the world map
  geom_sf(data = world, fill = "darkgrey", color = "lightgrey") +
  geom_sf(data = gc_sf, color = "white", size = 0.1, alpha = 0.5) +
  geom_sf(data = airport_points, color = "red", fill = "black", size = 1, alpha = 1) +
  coord_sf(crs = "+proj=laea +lat_0=50 +lon_0=-30") +
  theme_minimal() +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "black", color = NA),
    plot.margin = margin(0, 0, 0, 0)
  )


# Improved plot with glowing lines and standout dots
sticker_plot <- ggplot() +
  # Plot the world map
  geom_sf(data = world, fill = "darkgrey", color = "lightgrey") +

  # Add glowing lines for connections
  geom_sf(data = gc_sf, color = "gold", size = 0.15, alpha = 0.3) +
  geom_sf(data = gc_sf, color = "white", size = 0.1, alpha = 0.2) +
  #geom_sf(data = airport_points, color = "white", fill = "white", size = 0.5, shape = 21, alpha = 0.5, stroke = 0.1) +

  # Add airport points with a glowing effect

  # Set the coordinate system
  coord_sf(crs = "+proj=laea +lat_0=50 +lon_0=-30") +

  # Minimal theme with a black background
  theme_minimal() +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "black", color = NA),
    plot.margin = margin(0, 0, 0, 0)
  )

#sticker_plot
# Create the hex sticker
sticker(
  sticker_plot,
  package = "",
  p_size = 20,
  p_color = "white",
  p_family =  "roboto",
  s_x = 1,
  s_y = 1,
  s_width = 1.3,
  s_height = 1.3,
  h_fill = "black",
  h_color = "white",
  filename = "man/figures/logo_blank.png",
  white_around_sticker = FALSE
)

