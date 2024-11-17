# PROA Project Setup and Data Initialisation

This guide provides instructions for setting up and initialising data for the PROA ASP.NET Core backend (`ProaServer`) and React frontend (`proa-client`) project.

## Repository

**Clone the repository** using the following URL:

```
https://github.com/mjkearns79/proa.git
```

## Prerequisites

1. **Visual Studio** - Ensure you have Visual Studio installed with the ASP.NET and web development workload.
2. **.NET Core SDK** - Ensure you have the .NET Core SDK installed.
3. **Node.js and npm** - Ensure you have Node.js and npm installed for the React frontend.
4. **SQL Server** - A running instance of SQL Server is required for data storage.
5. **Data Files** - Ensure that all required data files are placed in the `c:\proa` directory, as the `DataSetup.sql` script expects them in this location. If you wish to use a different location, update the file paths in `DataSetup.sql` accordingly.

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/mjkearns79/proa.git
cd c:\proa\source
```

### 2. Run the Data Setup Script

1. Ensure that `DataSetup.sql` is located in the `c:\proa\source` directory and that the required data files are in `c:\proa`. If you want to use a different location for the data files, you must update the file paths in `DataSetup.sql`.
2. Open a command prompt or SQL execution tool.
3. Execute the `DataSetup.sql` script using your preferred method:
   - Using SQLCMD:
     ```bash
     sqlcmd -S YOUR_SERVER -d YOUR_DATABASE -i DataSetup.sql
     ```
   - Or, open the script in SQL Server Management Studio (SSMS) and execute it from there.

### 3. Open the ASP.NET Core Project in Visual Studio

1. Navigate to the `ProaServer` folder.
2. Open the `ProaServer.sln` file in Visual Studio.
3. Build the solution (`Build` → `Build Solution`).
4. Run the project by pressing `F5`.
5. This will automatically configure and launch the application at `https://localhost:7100`.

### 4. Install Frontend Dependencies for the React Application

Navigate to the `proa-client` folder and install the dependencies using npm.

```bash
cd ..\proa-client
npm install
```

### 5. Supply the Google Maps API key

Open the App.js file and add your Google Maps API key on line 75 if you want to remove the watermark.

### 6. Start the React Application

Start the React app in development mode. This will run the app on `http://localhost:3000` by default.

```bash
npm start
```

### 7. Access the Application

- Open the React application at:
  ```
  http://localhost:3000
  ```
- Ensure the backend API is accessible at:
  ```
  https://localhost:7100
  ```

## Troubleshooting

- **Database Connection Issues**: Ensure that your SQL Server is running and accessible. Verify that the connection string in `appsettings.json` is correct.
- **Data File Location**: Ensure that the data files are correctly located in `c:\proa` as expected by `DataSetup.sql`. If you wish to use a different location, update the file paths in the script.
- **Build Issues**: If you encounter issues with building the React application, try deleting the `node_modules` folder and running `npm install` again.
