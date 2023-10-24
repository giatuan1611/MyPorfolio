---Select *
----From PorfolioProject1..CovidDeath
----Where continent is not null 
Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject1..CovidDeath
Where continent is not null 
Order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,  (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PorfolioProject1..CovidDeath
Where location = 'Vietnam' and continent is not null 
Order by 1,2          

--Looking at Total Cases vs  Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PerrcentPopulationInfected
From PorfolioProject1..CovidDeath
Where location = 'Vietnam' and continent is not null 
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, population,  
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 as PerrcentPopulationInfected
From PorfolioProject1..CovidDeath
--Where location = 'Vietnam' 
Where continent is not null 
Group by Location, Population
Order by PerrcentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject1..CovidDeath
--Where location = 'Vietnam'
Where continent is not null 
Group by Location
Order by TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject1..CovidDeath
--Where location = 'Vietnam'
Where continent is not null 
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
From PorfolioProject1..CovidDeath
--Where location = 'Vietnam' 
where continent is not null
--group by date
Order by 1,2   

-- Looking at Total Population vs Vaccinations

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
from PorfolioProject1..CovidDeath dea
join PorfolioProject1..CovidVaccin vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent	is not null
--group by  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2,3

-- using CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated 
from PorfolioProject1..CovidDeath dea
join PorfolioProject1..CovidVaccin vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent	is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated 
from PorfolioProject1..CovidDeath dea
join PorfolioProject1..CovidVaccin vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent	is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated 
from PorfolioProject1..CovidDeath dea
join PorfolioProject1..CovidVaccin vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent	is not null


