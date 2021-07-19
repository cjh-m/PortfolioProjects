SELECT *
FROM PortfolioProject..['CovidDeaths']
ORDER BY 3,4

SELECT *
FROM PortfolioProject..['CovidVaccinations']
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['CovidDeaths']
ORDER BY 1,2

-- Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..['CovidDeaths']
WHERE location LIKE '%anad%'
ORDER BY 1,2

-- Looking at Total Cases vs Population


-- Percentage of population who got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..['CovidDeaths']
WHERE location LIKE '%anad%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..['CovidDeaths']
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countires with highest death count per population
-- Numbers of deaths
SELECT location,  MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..['CovidDeaths']
WHERE continent IS NOT null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Percentage of deaths
SELECT location,  MAX(CAST(total_deaths AS INT)/population)*100 AS HighestDeathPercentage
FROM PortfolioProject..['CovidDeaths']
WHERE continent IS NOT null
GROUP BY location
ORDER BY HighestDeathPercentage DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- This one is better for continent numbers
SELECT location,  MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..['CovidDeaths']
WHERE continent IS null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- This one enables better drill down in tableau
SELECT continent,  MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..['CovidDeaths']
WHERE continent IS NOT null
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- GLOBAL Numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..['CovidDeaths']
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
 AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['CovidDeaths'] dea
JOIN PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- With CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
 AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['CovidDeaths'] dea
JOIN PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
 AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['CovidDeaths'] dea
JOIN PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated