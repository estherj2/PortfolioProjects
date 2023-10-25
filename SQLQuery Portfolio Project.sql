
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (try_cast(total_deaths AS DECIMAL(12,2)) /(try_cast(total_cases AS int)))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases VS Population
-Shows what percentage of population got COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at countries with highest Infection Rate per Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationIfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationIfected  DESC


-- Showing countries with hightest Death Count per Population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount  DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Location looks correct in this case

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount  DESC


SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount  DESC


-- Showing continents with the Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount  DESC




-- GLOBAL NUMBERS
-- Cannot only group by date since we are looking at multiple things at once

SET ANSI_WARNINGS OFF
GO
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, RollingPeopleVaccinated)
AS


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
	, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac





-- USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
	, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
--WHERE DEA.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated





-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
	, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated