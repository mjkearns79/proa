-- Create the database if it doesn't already exist
IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'Proa')
BEGIN
    CREATE DATABASE Proa;
END

-- Switch to the proa database
USE proa;

-- Drop existing tables if they exist
IF OBJECT_ID('dbo.Measurements', 'U') IS NOT NULL DROP TABLE dbo.Measurements;
IF OBJECT_ID('dbo.Variables', 'U') IS NOT NULL DROP TABLE dbo.Variables;
IF OBJECT_ID('dbo.WeatherStations', 'U') IS NOT NULL DROP TABLE dbo.WeatherStations;

-- Table creation script
CREATE TABLE WeatherStations (
    Id INT PRIMARY KEY,
    WsName NVARCHAR(255),
    Site NVARCHAR(255),
    Portfolio NVARCHAR(255),
    State NVARCHAR(50),
    Latitude FLOAT,
    Longitude FLOAT
);

CREATE TABLE Variables (
    VarId INT PRIMARY KEY,
    WeatherStationId INT,
    Name NVARCHAR(255),
    Unit NVARCHAR(50),
    LongName NVARCHAR(255),
    FOREIGN KEY (WeatherStationId) REFERENCES WeatherStations(Id)
);

CREATE TABLE Measurements (
    Id INT IDENTITY PRIMARY KEY,
    WeatherStationId INT,
    VarId INT,
    Value FLOAT,
    Timestamp DATETIME,
    FOREIGN KEY (WeatherStationId) REFERENCES WeatherStations(Id),
    FOREIGN KEY (VarId) REFERENCES Variables(VarId)
);

CREATE INDEX IDX_Latitude_Longitude ON WeatherStations (Latitude, Longitude);
CREATE INDEX IDX_State ON WeatherStations (State);
CREATE INDEX IDX_Variables_WeatherStationId ON Variables (WeatherStationId);
CREATE INDEX IDX_Measurements_WeatherStationId_Timestamp ON Measurements (WeatherStationId, Timestamp);
CREATE INDEX IDX_Measurements_VarId ON Measurements (VarId);

-- Bulk insert initial data
BULK INSERT dbo.WeatherStations
FROM 'c:\proa\weather_stations.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

BULK INSERT dbo.Variables
FROM 'c:\proa\variables.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

-- Enable xp_cmdshell
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

-- Create a table to hold file paths
IF OBJECT_ID('tempdb..#FileList') IS NOT NULL DROP TABLE #FileList;
CREATE TABLE #FileList (FilePath NVARCHAR(255));

DECLARE @DirectoryPath NVARCHAR(255) = 'c:\proa\'; -- When testing, change this to where your CSV files are
DECLARE @Command NVARCHAR(4000) = 'dir ' + @DirectoryPath + 'data_*.csv /b';
INSERT INTO #FileList (FilePath)
EXEC xp_cmdshell @Command;

-- Loop through each file and import data
DECLARE @FilePath NVARCHAR(255);
DECLARE @WeatherStationId INT;
DECLARE FileCursor CURSOR FOR 
SELECT FilePath FROM #FileList WHERE FilePath IS NOT NULL;

OPEN FileCursor;
FETCH NEXT FROM FileCursor INTO @FilePath;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Extract WeatherStationId from filename
    SET @WeatherStationId = CAST(REPLACE(REPLACE(@FilePath, 'data_', ''), '.csv', '') AS INT);

    -- Check if WeatherStationId exists before importing
    IF EXISTS (SELECT 1 FROM dbo.WeatherStations WHERE Id = @WeatherStationId)
    BEGIN
        -- Create a temp table
        IF OBJECT_ID('tempdb..#TempMeasurements') IS NOT NULL DROP TABLE #TempMeasurements;
        CREATE TABLE #TempMeasurements (
            AirT_inst NVARCHAR(50),
            GHI_inst NVARCHAR(50),
            Timestamp NVARCHAR(50)
        );

        -- Bulk insert data into temp table
        DECLARE @FullFilePath NVARCHAR(4000) = @DirectoryPath + @FilePath;
        DECLARE @BulkInsertCommand NVARCHAR(4000) = 
            'BULK INSERT #TempMeasurements FROM ''' + @FullFilePath + ''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);';
        EXEC sp_executesql @BulkInsertCommand;

        -- Insert AirT_inst data
        INSERT INTO dbo.Measurements (WeatherStationId, VarId, Value, Timestamp)
        SELECT 
            @WeatherStationId, 
            11, -- VarId for AirT_inst
            TRY_CAST(AirT_inst AS FLOAT),
            TRY_CONVERT(DATETIME, Timestamp, 103)
        FROM #TempMeasurements
        WHERE TRY_CAST(AirT_inst AS FLOAT) IS NOT NULL;

        -- Insert GHI_inst data
        INSERT INTO dbo.Measurements (WeatherStationId, VarId, Value, Timestamp)
        SELECT 
            @WeatherStationId, 
            12, -- VarId for GHI_inst
            TRY_CAST(GHI_inst AS FLOAT),
            TRY_CONVERT(DATETIME, Timestamp, 103)
        FROM #TempMeasurements
        WHERE TRY_CAST(GHI_inst AS FLOAT) IS NOT NULL;

        DROP TABLE #TempMeasurements;
    END
    ELSE
    BEGIN
        PRINT 'WeatherStationId ' + CAST(@WeatherStationId AS NVARCHAR) + ' not found in dbo.WeatherStations. Skipping file.';
    END

    FETCH NEXT FROM FileCursor INTO @FilePath;
END

-- Cleanup
CLOSE FileCursor;
DEALLOCATE FileCursor;
DROP TABLE #FileList;
