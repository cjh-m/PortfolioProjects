-- Data up to 1st of July 2021

SELECT *
FROM PortfolioProject..['CovidVaccinations']

-- 1. Worldwide total and percentage of vaccinated

SELECT dea.location, dea.population, MAX(CAST(people_fully_vaccinated AS INT)) AS total_fully_vaccinated, (MAX(CAST(people_fully_vaccinated AS INT))/dea.population)*100 AS percent_vaccinated
FROM PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location = 'World'
GROUP BY dea.location, dea.population

-- 2. Total vaccinated by continent

SELECT vac.location, MAX(CAST(vac.people_fully_vaccinated AS INT)) AS FullyVaccinated, MAX(dea.population) AS Population
From PortfolioProject..['CovidDeaths'] dea
JOIN PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE vac.continent IS NULL
AND vac.location NOT IN ('European Union', 'International', 'World')
GROUP BY vac.location
ORDER BY FullyVaccinated DESC

-- 4. Rolling total of number and percentage of people vaccinated in each country.

SELECT dea.location, dea.date, dea.population
, MAX(vac.people_fully_vaccinated) AS RollingPeopleVaccinated
, (MAX(vac.people_fully_vaccinated)/population)*100 AS RollingPercentageVaccinated
FROM PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.date, dea.population
ORDER BY 1,2,3


--3. % of population vaccinated on 1st July 2021
SELECT vac.Location, population, MAX(vac.people_fully_vaccinated) as FullVaccinationCount, (MAX(vac.people_fully_vaccinated)/population)*100 AS PercentFullyVaccinated
FROM PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY vac.Location, population
ORDER BY PercentFullyVaccinated DESC


