
select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;


select location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2;

select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location LIKE '%States%'
order by 1,2;

select location, date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location LIKE '%states%'
order by 1,2;

select location,population,max(total_cases)as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by location,population
order by PercentPopulationInfected desc;

--Showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc;

--LET'S BREAK THINGS DOWN BY CONTINENT




--Showing the continents with the highest death counts

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

--GLOBAL NUMBERS

--per day

select date,sum(new_cases)as Total_New_Cases, sum(cast(new_deaths as int))as Total_New_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location LIKE '%States%'
where continent is not null
group by date
order by 1,2;

--across the world
select sum(new_cases)as Total_New_Cases, sum(cast(new_deaths as int))as Total_New_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location LIKE '%States%'
where continent is not null
--group by date
order by 1,2;

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, 
  dea.Date) as PeopleVaccinatedRolling
 -- , (PeopleVaccinatedRolling/
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations,PeopleVaccinatedRolling)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, 
  dea.Date) as PeopleVaccinatedRolling
 -- , (PeopleVaccinatedRolling/
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (PeopleVaccinatedRolling/Population)*100
from PopvsVac


--TEMP TABLE


Drop Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vaccinations Numeric,
PeopleVaccinatedRolling Numeric
)



Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, 
  dea.Date) as PeopleVaccinatedRolling
 -- , (PeopleVaccinatedRolling/
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (PeopleVaccinatedRolling/Population)*100
from #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, 
  dea.Date) as PeopleVaccinatedRolling
 -- , (PeopleVaccinatedRolling/
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated

