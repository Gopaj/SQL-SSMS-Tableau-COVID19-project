/*

Queries used for Tableau Project

*/

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_percentage
From CovidProject..CovidDeaths$
where continent is not null 
order by 1,2


-- 2. Taking out these as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe...
Select location, SUM(cast(new_deaths as int)) as total_death_count
From CovidProject..CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by total_death_count desc


-- 3.
Select location, population, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percent_pop_infected
From CovidProject..CovidDeaths$
Group by location, population
order by percent_pop_infected desc


-- 4.
Select location, population,date, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percent_pop_infected
From CovidProject..CovidDeaths$
Group by location, population, date
order by percent_pop_infected desc
