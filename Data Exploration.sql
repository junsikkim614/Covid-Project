-- Updating continents column to replace blanks with null 
UPDATE coviddeaths
SET continent = NULLIF(continent, '')
WHERE continent = '';

-- Updating new vaccinations column to replace blanks with null 
UPDATE covidvaccinations
SET new_vaccinations = NULLIF(new_vaccinations, '')
WHERE new_vaccinations ='';


SELECT * 
FROM coviddeaths 
WHERE location = 'South Korea'
ORDER BY 2,3;

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM coviddeaths
order by 1,2 ;

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you get covid in South Korea 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location = 'South Korea'
order by 1,2 ;

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid in South Korea
SELECT location, date, population,total_cases, (total_cases/population)*100 AS CovidPercentage
FROM coviddeaths
WHERE location = 'South Korea'
order by 1,2 ;

-- Looking at Countries with Highest Infection Rate compared to Population 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulationPercent
FROM coviddeaths
-- WHERE location = 'South Korea'
GROUP BY location, population
order by InfectedPopulationPercent DESC;


-- Breaking this down by continent 



-- Showing Countries with highest death count compared to population 
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount DESC;

-- Showing continents with the highest death counts per population 
SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC;

-- Global Numbers 
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY date 
ORDER BY 1,2; 

-- Looking at Total Population VS Vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac 
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE 
WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac 
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVSVac;

-- Creating View to store data for future visualization 
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac 
	ON dea.location = vac.locatpercentpopulationvaccinatedion 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

