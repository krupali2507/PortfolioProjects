CREATE DATABASE PortfolioProject;

USE PortfolioProject;

SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- Diffrent continent
SELECT DISTINCT(continent) 
FROM CovidDeaths
ORDER BY continent;

-- Let's get rid of null continent and select
-- Columns that we need analysis to start with

DELETE * FROM CovidDeaths WHERE continent IS NULL;

DROP VIEW IF EXISTS subtable;

CREATE VIEW subtable AS
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE population IS NOT NULL;

SELECT * FROM subtable;
-- Total Cases v/s Total Deaths
-- This shows the chances of death percent if someone contrcat covid in particular country

SELECT Location,date, total_cases,total_deaths,
(total_deaths/total_cases)*100 AS DeathPercent
FROM CovidDeaths
WHERE Location = 'India'
ORDER BY 1,2; 


-- Total cases v/s Total Population
-- This shows the percentage of population got infected

SELECT Location,date,population,total_cases,
(total_cases/population)*100  AS PercentPopulationInfected
FROM CovidDeaths
WHERE Location = 'India' AND
continent IS NOT NULL
ORDER BY 1,2;

-- Total Populaions v/s Total Deaths
-- This shows the percentage of death from Populations
SELECT Location,date,population,total_deaths,
(total_deaths / Population) * 100 AS PercentPopulationDied
FROM CovidDeaths
WHERE Location = 'India'
ORDER BY 1,2;


-- Countries with Highest Infection rate compared to Populations

SELECT Location,MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
Group By Location
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest death count per population
SELECT Location,Max(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC;

-- Number of confirmed cases at first day in each country with date
SELECT Distinct(Location) ,date , new_cases 
FROM
CovidDeaths
WHERE new_cases >=1
AND new_cases = total_cases;

-- Total Death Per each country
SELECT DISTINCT(Location), SUM(CAST(new_deaths AS int)) AS DeathsPerCountry
FROM CovidDeaths
GROUP BY Location
ORDER BY 2 DESC;

-- Total Death Per each continent
SELECT continent, SUM(CAST(new_deaths AS int)) AS DeathsPerContinent
FROM CovidDeaths
GROUP BY continent
ORDER BY DeathsPerContinent DESC;

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS DeathsPerContinent
FROM CovidDeaths
GROUP BY continent
ORDER BY DeathsPerContinent DESC;


-- Total test v/s Total population by country
SELECT dea.location,dea.population, MAX(CAST(total_tests AS int)) AS Total_tests
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE population IS NOT NULL
GROUP BY dea.location,dea.population
ORDER BY 3 DESC;

-- Total population v/s Total Vaccinations
-- Shows percantage of population got vaccinated with at leat one dose

-- 1. Use total_vaccination column 
SELECT dea.location,dea.population,MAX(vac.total_vaccinations) AS TotalVaccination
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE population IS NOT NULL
GROUP BY dea.location,dea.population
ORDER BY 3 DESC;

-- 2. Not using total_vaccination column. Instead creating new column using partition by same as total_vaccination named as RollinPeopleVaccinated
	SELECT dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY 
		dea.location,dea.date) AS RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population) * 100 can't do this directly
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE population IS NOT NULL;

-- 3. Using CTE's on above query to find percentage as we can't directly use RollingPeopleVaccinated on that query to find percentage
WITH PopvsVac AS
	(SELECT dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100 can't do this directly
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE population IS NOT NULL
	AND dea.location = 'canada')
--ORDER BY 1,2)
SELECT * , (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopvsVac
ORDER BY 1,2;

-- 4. Same we can achieve using Temp table instead of CTE's

DROP TABLE IF EXISTS #PopvsVac;

CREATE TABLE #PopvsVac
(loction NVARCHAR(255),
 date DATETIME,
 population INT,
 new_vaccination INT,
 RollingPeopleVaccinated INT,
)

INSERT INTO #PopvsVac
SELECT dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100 can't do this directly
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE population IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM #PopvsVac
ORDER BY 1,2;


-- Global numbers of Total cases,deaths and DeathPercentage
SELECT SUM(total_cases) AS Total_cases, SUM(CAST(total_deaths AS INT)) AS Total_deaths , (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE population IS NOT NULL;