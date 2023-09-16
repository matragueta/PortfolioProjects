select *
from PortfolioProject.dbo.CovidDeaths
where continent is not NULL
order by 3,4 

select *
from PortfolioProject.dbo.CovidVaccinations
order by 3,4 

select count(* )
from PortfolioProject.dbo.CovidVaccinations

-- select Data that we are goinf to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (cast(total_deaths as float) / total_cases) * 100  as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Brazil'and continent is not Null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population) * 100  as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where location = 'Brazil' and continent is not Null
order by 1,2

-- Looking at Countries with highest infection rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, 
max((total_cases/population)) * 100  as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'Brazil'
where continent is not NULL
group by location, population
order by PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population
  select location, max (cast(total_deaths as int)) as HighestDeathCount
  from PortfolioProject..CovidDeaths
  where continent is not NULL
  group by location
  order by HighestDeathCount desc

  -- LET'S BREAK THINGS DOWN BY CONTINENT 
  -- Showing the sum of deaths per continents
  select continent, sum (cast(new_deaths as int)) as TotalDeathCount
  from PortfolioProject..CovidDeaths
  where continent is not NULL and total_deaths is not NULL
  group by continent
  order by TotalDeathCount desc

 -- Showing the Continents with the highest death count per population - ** changed this one to show location
  select continent, location, max (cast(total_deaths as int)) as HighestDeathCount
  from PortfolioProject..CovidDeaths
  where continent is not NULL and total_deaths is not NULL
  group by continent, location 
  order by continent, HighestDeathCount desc

  -- GLOBAL NUMBERS
  select  sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, 
  (sum (new_deaths) / sum (new_cases)) * 100 as DeathPercentage
  from PortfolioProject..CovidDeaths
  where continent is not null  and new_cases is not null and new_deaths is not null and new_cases != 0
  --group by date
  order by 1,2

  -- Looking at Total Population vs Vaccination
	select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
	,sum (cast (vaccination.new_vaccinations as float)) over (partition by death.location 
	order by death.location, death.date) as RollingPeopleVaccinated
	--,max (RollingPeopleVaccinated/population) * 100
	from PortfolioProject..CovidDeaths death
	join PortfolioProject..CovidVaccinations vaccination
		on death.location = vaccination.location
		and death.date = vaccination.date
	where death.continent is not NULL --and vaccination.new_vaccinations is not null
	order by 2, 3

	-- USE CTE
	With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
	as (
	select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
	,sum (cast (vaccination.new_vaccinations as float)) over (partition by death.location 
	order by death.location, death.date) as RollingPeopleVaccinated
	--,max (RollingPeopleVaccinated/population) * 100
	from PortfolioProject..CovidDeaths death
	join PortfolioProject..CovidVaccinations vaccination
		on death.location = vaccination.location
		and death.date = vaccination.date
	where death.continent is not NULL --and vaccination.new_vaccinations is not null
	--order by 2, 3
	)
	select *, (RollingPeopleVaccinated/Population) * 100 from PopvsVac 

	-- TEMP TABLE
	Drop Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population float, 
	New_vaccination float,
	RollingPeopleVaccinated float
	)
	Insert into #PercentPopulationVaccinated
	select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
	,sum (cast (vaccination.new_vaccinations as float)) over (partition by death.location 
	order by death.location, death.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths death
	join PortfolioProject..CovidVaccinations vaccination
		on death.location = vaccination.location
		and death.date = vaccination.date
	where death.continent is not NULL 

	select *, (RollingPeopleVaccinated/Population) * 100 
	from #PercentPopulationVaccinated 

	--Creating view to store data for later visualization
	Create View PercentPopulationVaccinated as
	select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
	,sum (cast (vaccination.new_vaccinations as float)) over (partition by death.location 
	order by death.location, death.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths death
	join PortfolioProject..CovidVaccinations vaccination
		on death.location = vaccination.location
		and death.date = vaccination.date
	where death.continent is not NULL 
	
	select * from PercentPopulationVaccinated
