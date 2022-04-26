select *
from CovidProject..CovidDeaths$
where continent is not NULL
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths$
where continent is not NULL
order by 1,2

-- Looking at total cases compared to total death - Will show % of people dying, who had covid19. Taking DK as example.
select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths$
Where location like '%denm%'
order by 1,2

-- Looking at total_cases compared to population.
select location, date, population, total_cases,  (total_cases / population)*100 as InfectionRate
from CovidProject..CovidDeaths$
order by 1,2


-- Looking at country with highest infection rate, ordered by highest first (descending). 
select location, population, MAX(total_cases) as PeakInfectionCount,  MAX((total_cases / population))*100 as InfectionRate
from CovidProject..CovidDeaths$
where continent is not NULL
group by location, population
order by 4 desc

-- Looking at country with highest n deaths by population. Cast as int, since it was varchar, which doesnt order numerically.
select location, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidProject..CovidDeaths$
where continent is not NULL
group by location
order by 2 desc

-- Looking at continent with highest death count. Cast as int, since it was varchar, which doesnt order numerically.
select location, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidProject..CovidDeaths$
where continent is NULL
group by location
order by 2 desc

-- Looking at global stats.
select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathRate
from CovidProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

-- Joining deaths and vaccination tables.
select *
from CovidProject..CovidDeaths$ dea
join CovidProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Making cte of Total population vs vaccination levels. Adding cumulative counter column.
With PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, cumm_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as cumm_vaccinations
from CovidProject..CovidDeaths$ dea
join CovidProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (cumm_vaccinations/Population)*100 as vacc_percentage
From PopvsVacc

-- new temp table to use in calculation on partition from query above.

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumm_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as cumm_vaccinations

from CovidProject..CovidDeaths$ dea
join CovidProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

Select *, (cumm_vaccinations/Population)*100
From #PercentPopulationVaccinated

-- Creating a view to store data for visualizations

Create View dbo.PercentVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as cumm_vaccinations

from CovidProject..CovidDeaths$ dea
join CovidProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


