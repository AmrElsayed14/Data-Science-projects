select *
from CovidDeaths
order by location, date

-- select Data that we are going to be using

SELECT location, date, total_cases, total_deaths, population
FROM CovidDeaths
order by 1,2


 --looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as deaths_percentage
FROM CovidDeaths
where location like '%egypt%'
order by deaths_percentage 

---- Looking at Total Cases vs Population
SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 as infected_percentage
FROM CovidDeaths
where location like '%states%'
order by infected_percentage

-- Looking at countries with Highest infection rate compared to population
select Location, Population, MAX(total_cases) as highest_infection_count, (Max(total_cases)/population)*100 as infected_percentage
From CovidDeaths
group by location, population
order by infected_percentage desc

-- Looking at countries with Highest death count compared to population
select continent, MAX(cast(total_deaths as int)) as Total_deaths_count
From CovidDeaths
where continent is not null 
group by continent
order by Total_deaths_count desc


-- GLOBAL NUMBERS
SELECT location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
FROM CovidDeaths
where continent is not null	
Group by location
order by 1,2

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	order by 2,3


-- USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, incremental_count)
as 
(
-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as incremental_count
--, (incremental_count/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (incremental_count/population)*100 
from PopvsVac


-- TEMP TABLE+
DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric,
incremental_count numeric,
)
insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as incremental_count
--, (incremental_count/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

select *, (incremental_count/population)*100 
from #PercentPopulationVaccinated


-- creating view to store data for later
create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as incremental_count
--, (incremental_count/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
