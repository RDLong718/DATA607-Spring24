# Load Libraries
library(DBI)
library(RMariaDB)
library(dplyr)
library(tidyverse)
library(ggplot2)

# Database Connection Parameters
user <- 'rashad.long66'
password <- 'rashad_password'
database <- 'rashad.long66'
host <- 'cunydata607sql.mysql.database.azure.com'
port <- 3306

#Connect to the database
connection <- DBI::dbConnect(drv = RMariaDB:: MariaDB(), 
                             dbname = database,
                             host = host, 
                             port = port, 
                             user = user, 
                             password = password)
# Fetch the results
tbl(connection,"fda approved ai - sheet1") |>
  collect() -> fda_approved_ai

# Close the connection
DBI::dbDisconnect(connection)

# Preview the data
head(fda_approved_ai)
View(fda_approved_ai)

# Rename the columns
fda_approved_ai_tidy <- fda_approved_ai |> 
  rename(
    "Device or Algo" = "Name of device or algorithm", 
    "Company" = "Name of parent company",
    "Description" = "Short description", 
    "FDA Approval Number" = "FDA approval number", 
    "Type of Approval" = "Type of FDA approval", 
    "Mention of AI" = "Mention of A.I. in announcement", 
    "No Mention of AI" = "If no mention of A.I. in FDA announcement" 
    ) |> 
  mutate("Date" = gsub(" ", "-", Date),
         "Date"=paste(Date, "01", sep="-"),
         "Date"=as.Date(Date, format="%Y-%m-%d"),
         
         ) |> 
  select (-"No Mention of AI")

# Fill the 'Medical specialty' column of row where 'Device or Algo' is "Koios DS for Breast"

fda_approved_ai_tidy <- fda_approved_ai_tidy |>
  mutate(
    "Medical specialty" = ifelse(
      `Device or Algo` == "Koios DS for Breast",
      "Radiology",
      `Medical specialty`
    )
  )

str(fda_approved_ai_tidy)
View(fda_approved_ai_tidy)


# Pivot the 2 specialty columns into 1 column
fda_approved_ai_tidy <- fda_approved_ai_tidy |> 
  pivot_longer(
    cols = c("Medical specialty", "Secondary medical specialty"),
    names_to = "Specialty Type",
    values_to = "Specialty"
  ) |> # Remove "Specialty Type"column
  select(-"Specialty Type")  |> # Remove rows where "Specialty" is empty
  filter(Specialty != "") |> # If Mention of AI column has "Not Available" then replace it with "Not Mentioned"
  mutate(
    "Mention of AI" = ifelse(
      `Mention of AI` == "Not available",
      "Not Mentioned",
      `Mention of AI`
    )


str(fda_approved_ai_tidy)
View(fda_approved_ai_tidy)

# WHich year had the most distinct FDA approval numbers?
fda_approved_ai_tidy |>
  mutate(
    "Year" = year(Date)
  ) |>
  group_by(Year) |>
  summarize(
    "Distinct FDA Approval Numbers" = n_distinct(`FDA Approval Number`)
  ) |>
  arrange(desc(`Distinct FDA Approval Numbers`))
# plot it over time
fda_approved_ai_tidy |>
  group_by(format(Date, "%Y")) |>
  summarize(
    "Distinct FDA Approval Numbers" = n_distinct(`FDA Approval Number`)
  )
  
  
  
  ggplot(aes(x = Year, y = `Distinct FDA Approval Numbers`)) +
  geom_line(aes(linetype = `Type of Approval``)) +
  labs(
    title = "Distinct FDA Approval Numbers Over Time",
    x = "Year",
    y = "Distinct FDA Approval Numbers"
  )



fda_approved_ai_tidy |>
  select(Company) |>
  distinct()

# show all columns of companies are leading the development of AI-powered medical devices and have distinct FDA Approval Numbers?
fda_approved_ai_tidy |>
  group_by(Company) |>
  summarize(
    "Distinct FDA Approval Numbers" = n_distinct(`FDA Approval Number`)
  ) |>
  arrange(desc(`Distinct FDA Approval Numbers`)) |>
  head(10)


# # fda_approved_ai_tidy <- fda_approved_ai_tidy |>
# #   filter(Specialty != "")
# 
# #If Mention of AI column has "Not Available" then replace it with "Not Mentioned"
# # fda_approved_ai_tidy <- fda_approved_ai_tidy |>
# #   mutate(
# #     "Mention of AI" = ifelse(
# #       `Mention of AI` == "Not available",
# #       "Not Mentioned",
# #       `Mention of AI`
# #     )
# #   )
# 
# # # Replace spaces in the "Date Column with "-"
# # fda_approved_ai_tidy <- fda_approved_ai_tidy |>
# #   mutate(
# #     "Date" = gsub(" ", "-", Date)
# #   )
# # str(fda_approved_ai_tidy)
# # View(fda_approved_ai_tidy)
# # 
# # # add "01" to the end of the "Date" column
# # fda_approved_ai_tidy <- fda_approved_ai_tidy |>
# #   mutate(
# #     "Date" = paste(Date, "01", sep = "-")
# #   )
# # str(fda_approved_ai_tidy)
# # View(fda_approved_ai_tidy)
# # 
# # # Format date column
# # fda_approved_ai_tidy <- fda_approved_ai_tidy |>
# #   mutate(
# #     "Date" = as.Date(Date, format = "%Y-%m-%d")
# #   )
# 
# # Define the string
# date_string <- "2011-01-01"
# 
# # Specify the format using format strings (%Y for year, %m for month)
# formatted_date <- as.Date(date_string, format = "%Y-%m-%d")
# 
# # Print the formatted date
# print(formatted_date)

# COmpare and plot the number of specialty approvals fill with Specialty 
fda_approved_ai_tidy |>
  group_by(Specialty) |>
  summarize(
    "Number of Specialty Approvals" = n_distinct(`FDA Approval Number`)
  ) |>
  arrange(desc(`Number of Specialty Approvals`)) |>
  head(10) |>
  ggplot(aes(x = reorder(Specialty,-`Number of Specialty Approvals`), y = `Number of Specialty Approvals`)) +
  geom_col(fill = "red") +
  coord_flip() +
  geom_text(aes(label = `Number of Specialty Approvals`), hjust = -0.5) +
  labs(
    title = "Top 10 Specialty Approvals",
    x = "Specialty",
    y = "Number of Approvals"
  )

# Top 10 specialty for number of approvals
fda_approved_ai_tidy |> 
  group_by(Specialty) |> 
  summarize(
    "Number of Specialty Approvals" = n()
  ) |> 
  arrange(desc(`Number of Specialty Approvals`)) |>
  head(10) |> 
  ggplot(aes(x = reorder(Specialty,-`Number of Specialty Approvals`), y = `Number of Specialty Approvals`)) +
  geom_point(size = 6, color = 'red') +
  geom_segment(aes(x = Specialty, xend = Specialty, y = 0, yend = `Number of Specialty Approvals`), color = 'red') +
  geom_text(aes(label = `Number of Specialty Approvals`), color="black") +
  labs(title = "Top 10 Specialty Approvals", x = "Specialty", y = "Number of Approvals") +
  theme(axis.text.x = element_text(angle = 65, vjust = .5))

# Of those top ten what are the  Approval Types?
fda_approved_ai_tidy |>
  filter(Specialty %in% c("Radiology", "Cardiology", "Oncology", "Pathology", "Neurology", "Ophthalmology", "Gastroenterology", "Pulmonology", "Urology", "Endocrinology")) |>
  group_by(Specialty, `Type of Approval`) |>
  summarize(
    "Number of Specialty Approvals" = n_distinct(`FDA Approval Number`)
  ) |>
  ggplot(aes(x = Specialty, y = `Number of Specialty Approvals`, fill = `Type of Approval`)) +
  geom_col(position = "dodge") +
  labs(
    title = "Top 10 Specialty Approvals by Approval Type",
    x = "Specialty",
    y = "Number of Approvals",
    fill = "Type of Approval"
  )


# What percentage of aprrovals in Radiology Specialty were de novo pathway?
fda_approved_ai_tidy |>
  group_by(Specialty) |>
  summarize(
    "501(k) premarket notification" = sum(`Type of Approval` == "510(k) premarket notification"),
    "Percentage of 501(k) premarket notification" = sum(`Type of Approval` == "510(k) premarket notification") / n() * 100
  ) |> 
  arrange(desc(`Percentage of 501(k) premarket notification`))

# What percentage of all approvals were for the Raidology Specialty?
fda_approved_ai_tidy |>
  group_by(Specialty) |>
  summarize(
    "Number of Specialty Approvals" = n_distinct(`FDA Approval Number`)
  ) |>
  arrange(desc(`Number of Specialty Approvals`)) |>
  head(10) |>
  arrange(Specialty) |>
  mutate("Percentage of All Approvals" = round(`Number of Specialty Approvals` / sum(`Number of Specialty Approvals`) * 100)
  ) |>
  ggplot(aes(x = "", y = `Percentage of All Approvals` , fill = Specialty)) +
  geom_bar(width = 1, stat = "identity")+
  geom_text(aes(label = paste0(`Percentage of All Approvals`, "%")), position = position_stack(vjust = 0.5), size = 3) +
  theme_void()




# Create a line graph showingh the number of apporvals over time grouped by Specialty
fda_approved_ai_tidy |>
  group_by(Specialty, year(Date)) |>
  reframe(
    "Number of Approvals" = n_distinct(`FDA Approval Number`),
    "Year" = year(Date)
  ) |>
  ggplot(aes(x = Year, y = `Number of Approvals`, color = Specialty)) +
  geom_line() +
  labs(
    title = "Number of Approvals Over Time by Specialty",
    x = "Year",
    y = "Number of Approvals",
    color = "Specialty"
  )

















