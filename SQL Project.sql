-- COVID DEATHS --

Select * from PortfolioProject.dbo.CovidDeaths;

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2;

-- Looking at total cases vs total deaths and Death percentage

Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2;

-- Looking at total cases vs population

Select location, date, population, total_cases, (total_cases / population) * 100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--where location like '%India%'
order by 1,2;

-- looking at countries with highest infection rate compared to population
-- (country wise) - use Group by
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases / population)) * 100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc;

-- (in total) - no need to use group by
Select Max(total_cases) as HighestInfectionCount, Max((total_cases / population)) * 100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by PercentPopulationInfected desc;

--showing countries with highest death count per population

Select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

--showing countries with highest death count per population. CONVERT datatype of total_deaths from 'nvarchar' to 'int'

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- let's break by continent. showing the continets with the highest deathcount

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc;

-- GLOBAL Numbers. Each day total cases and deaths worldwide

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1;

-- total cases and deaths worldwide

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null;

-- COVID VACCINATIONS --

select * from PortfolioProject.dbo.CovidVaccinations;

--joining both the tables

Select * 
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date;

-- total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

-- rolling count of vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountofPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

-- Use CTE. With Population vs vaccination

With PopvsVac (continent, location, date, population, new_vaccinations, RollingCountofPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountofPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingCountofPeopleVaccinated / population)*100 as VaccinatedPercentage
from PopvsVac

-- Temp table

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccincations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated / population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated

-- creating view to store data for later visualizations

create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated