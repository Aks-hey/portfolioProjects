SELECT * FROM 
CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;



SELECT * FROM 
CovidVaccinations
ORDER BY 3, 4;


SELECT [location], [date], [total_cases], [new_cases], [total_deaths], [population]
FROM CovidDeaths
ORDER BY 1, 2;


EXEC sp_help CovidDeaths;


-- Total Cases Vs Total Deaths

SELECT [location], [date], [total_cases], [total_deaths], Round(([total_deaths] / [total_cases]) * 100, 2) AS DeathPercentage
FROM CovidDeaths
WHERE location like 'India'
ORDER BY 1, 2;


-- Total Cases Vs Population

SELECT [location], [date],[population], [total_cases], Round(([total_cases] / [population]) * 100, 2) AS PercentPoulationInfected
FROM CovidDeaths
--WHERE location like 'India'
ORDER BY 1, 2;



-- Countries With Highest Infection Rate Compared To Population

SELECT [location],[population], MAX([total_cases]) AS HighestInfectionCount , MAX(([total_cases] / [population]) * 100) AS PercentPoulationInfected
FROM CovidDeaths
GROUP BY [location], [population]
ORDER BY 4 DESC;


-- Through Continent With Highest DeathCount Per Population

SELECT [continent], MAX(CAST([total_deaths] AS BIGINT)) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [continent]
ORDER BY TotalDeathCount DESC;



-- Global Numbers


SELECT SUM([new_cases]) AS TotalCases, SUM(CAST([new_deaths] AS BIGINT)) AS TotalDeaths,
ROUND(SUM(CAST([new_deaths] AS BIGINT))/SUM([new_cases]) * 100, 2) as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY [date]
ORDER BY 1, 2;




-- Total Population Vs Vaccinations

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS BIGINT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RunningVaccinatedTotal
FROM CovidDeaths AS CD
JOIN 
CovidVaccinations AS CV
	ON CD.location = CV.location
	AND 
	CD.[date] = CV.[date]
WHERE CD.continent IS NOT NULL
ORDER BY 2, 3


-- USE CTE

WITH PopVsVacc (Continent, Location, Date, Population, NewVaccinations, RunningVaccinatedTotal)
AS
(
	SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS BIGINT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RunningVaccinatedTotal
FROM CovidDeaths AS CD
JOIN 
CovidVaccinations AS CV
	ON CD.location = CV.location
	AND 
	CD.[date] = CV.[date]
WHERE CD.continent IS NOT NULL

)

SELECT *, (RunningVaccinatedTotal/Population) * 100 AS VaccinationPercent
FROM PopVsVacc
ORDER BY 2, 3;




-- USING TEMP TABLES

CREATE TABLE #PopVsVacc
(	
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	NewVaccinations NUMERIC,
	RunningVaccinatedTotal NUMERIC
)


INSERT INTO #PopVsVacc
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS BIGINT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RunningVaccinatedTotal
FROM CovidDeaths AS CD
JOIN 
CovidVaccinations AS CV
	ON CD.location = CV.location
	AND 
	CD.[date] = CV.[date]
WHERE CD.continent IS NOT NULL

SELECT *,  (RunningVaccinatedTotal/Population) * 100 AS VaccinationPercent
FROM #PopVsVacc


-- USING VIEWS

CREATE VIEW vW_PopVsVacc
AS

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS BIGINT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RunningVaccinatedTotal
FROM CovidDeaths AS CD
JOIN 
CovidVaccinations AS CV
	ON CD.location = CV.location
	AND 
	CD.[date] = CV.[date]
WHERE CD.continent IS NOT NULL


SELECT * FROM vW_PopVsVacc;