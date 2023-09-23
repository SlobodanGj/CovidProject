Select Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER bY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, Date, total_cases, total_deaths, (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 AS PercentPopulationInfected
From CovidProject..CovidDeaths
WHERE LOCATION = 'United States' AND Continent IS NOT NULL
Order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid
--(total_cases / Population)
--(CONVERT(float, total_cases) / CONVERT(float, Population)) IF ERROR IS FOUND!!

Select location, Date, total_cases, Population, (CONVERT(float, total_cases) / CONVERT(float, Population)) * 100 AS PercentPopulationInfected
From CovidProject..CovidDeaths
WHERE Continent IS NOT NULL
Order by 1,2

--Looking at Countries with Highest Infection Rate compated to Population

Select Continent, Location, Population,  MAX(CAST(total_cases as FLOAT)) AS HighestInfectionRate, MAX((CAST(total_cases as FLOAT) /population)) * 100 AS PercentPopulationInfected
From CovidProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent, Location, Population
Order by  PercentPopulationInfected DESC

---Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths as FLOAT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY  TotalDeathCount DESC

--Showing Continents with the Highest Death Count 

SELECT Continent, MAX(CAST(Total_Deaths AS FLOAT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE Continent  IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_Cases, SUM(CAST(New_Deaths as float)) as Total_Deaths,
SUM(CAST(New_Deaths AS float)) / NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE Continent IS NOT NULL
Group By date
ORDER BY 1,2 

--Total covid cases /deaths

SELECT SUM(new_cases) as Total_Cases, SUM(CAST(New_Deaths as float)) as Total_Deaths,
SUM(CAST(New_Deaths AS float)) / NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
 On dea.location = vac.location 
 AND dea.date = vac.date
 where dea.continent  is not null
 order by 2,3

 --Sum of new Vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as float)) OVER (Partition BY dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
 On dea.location = vac.location 
 AND dea.date = vac.date
 where dea.continent  is not null
 
 order by 2,3

 --USE CTE

 With PopvsVac(Continent,Location,Date,Population, New_Vaccinations, RollingPeopleVaccinated)
 AS
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as float)) OVER (Partition BY dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
 On dea.location = vac.location 
 AND dea.date = vac.date
 where dea.continent  is not null 
 
 --order by 2,3
 )

 Select *,(RollingPeopleVaccinated/Population)*100 as VacPercentage 
 
 FROM PopvsVac
 WHERE Location = 'North Macedonia' 
 

 --USE TempTable

 DROP Table if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeoplevaccinated numeric,)

 INSERT INTO #PercentPopulationVaccinated
 Select DEA.Continent, DEA.Location, DEA.Date, DEA.Population, new_vaccinations,
 SUM(CAST(new_vaccinations as float)) OVER (Partition By DEA.location Order By DEA.location, DEA.date) as RollingPeopleVaccinated
 From CovidProject..CovidDeaths as DEA
 JOIN CovidProject..CovidVaccinations as VAC
  on DEA.Location = VAC.Location
  AND DEA.Date = VAC.DATE
  --Where DEA.Continent  IS NOT NULL
 

 Select *,(RollingPeopleVaccinated/Population)*100
 FROM #PercentPopulationVaccinated

 --Creating View to store data for later visualizations

 CREATE VIEW PercentPopulationVaccinated AS
  Select DEA.Continent, DEA.Location, DEA.Date, DEA.Population, new_vaccinations,
 SUM(CAST(new_vaccinations as float)) OVER (Partition By DEA.location Order By DEA.location, DEA.date) as RollingPeopleVaccinated
 From CovidProject..CovidDeaths as DEA
 JOIN CovidProject..CovidVaccinations as VAC
  on DEA.Location = VAC.Location
  AND DEA.Date = VAC.DATE
  Where DEA.Continent  IS NOT NULL

  SELECT *
  FROM PercentPopulationVaccinated
