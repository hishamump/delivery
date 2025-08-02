# Navigate to your solution root directory
# cd /path/to/your/solution

# Install EF Core tools globally if not already installed
dotnet tool install --global dotnet-ef

# Create the initial migration
dotnet ef migrations add InitialCreate --project DM.Infrastructure --startup-project DM.API

# Update the database (this will create the database and tables)
dotnet ef database update --project DM.Infrastructure --startup-project DM.API

# Optional: View the generated SQL (without executing)
dotnet ef migrations script --project DM.Infrastructure --startup-project DM.API


#dotnet ef migrations remove --project DM.Infrastructure --startup-project DM.API