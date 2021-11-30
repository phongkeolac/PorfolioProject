SELECT *
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PorfolioProject..CovidVaccinations
--ORDER BY 3, 4

SELECT Location, date, population, total_cases, new_cases, total_deaths
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Total cases vs Total deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE Location like '%States%'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total cases vs Population
--Shows what percentage of population got covid

SELECT Location, date, population,total_cases, (total_cases/population)*100 AS PecentPopulationInfected
FROM PorfolioProject..CovidDeaths
--WHERE Location like '%States%'
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PecentPopulationInfected
FROM PorfolioProject..CovidDeaths
--WHERE Location like '%States%'
GROUP BY location, population
ORDER BY PecentPopulationInfected DESC

-- Showing Countries with Highest Death Count per population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
--WHERE Location like '%States%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
--WHERE Location like '%States%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
--WHERE Location like '%States%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
--WHERE Location like '%States%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

-- Looking at Total Polpulation vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccninations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE

WITH PopVsVac (Continent, Location, Date, population, new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccninations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccninations vac
	ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccninations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated