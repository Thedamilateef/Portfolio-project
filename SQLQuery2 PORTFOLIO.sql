SELECT *
FROM dbo.CovidDeaths
where continent is not null
ORDER BY 3, 4

--SELECT *
--FROM dbo.CovidVaccination
--ORDER BY 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1, 2

--SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
--FROM dbo.CovidDeaths
--where location like '%kingdom%'
--ORDER BY 1, 2

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulation
FROM dbo.CovidDeaths
where location like '%kingdom%'
ORDER BY 1, 2


SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
--where location like '%kingdom%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM dbo.CovidDeaths
--where location like '%kingdom%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathsCount desc

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM dbo.CovidDeaths
--where location like '%kingdom%'
where continent is null
GROUP BY location
ORDER BY TotalDeathsCount desc


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
--where location like '%kingdom%'
where continent is not null
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
--where location like '%kingdom%'
where continent is not null
--GROUP BY date
ORDER BY 1, 2

Select *
From dbo.CovidDeaths dea
Join dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From dbo.CovidDeaths dea
Join dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
From dbo.CovidDeaths dea
Join dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.CovidDeaths dea
Join dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.CovidDeaths dea
Join dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--USE TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.CovidDeaths dea
Join dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From dbo.CovidDeaths dea
Join dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated