-- Queries Used for Data visualization

-- 1. Total number of Cases,Deaths and DeathPercentage in entire World

SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, ROUND(SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 , 2) AS DeathPercentage
FROM CovidDeaths;

-- 2. Total Death Per continent

SELECT continent, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
From CovidDeaths
Group by continent
order by TotalDeathCount DESC;


--3. Percentage of Population Infected Per country

SELECT Location, Population, MAX(total_cases) AS TotalCases,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;


--4. Percent Population Infected

SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
From CovidDeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC;
