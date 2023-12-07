Select *
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4
--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- looking at Total Cases vs Total Deaths 
-- shows the liklihood of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and  continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population) *100 as PerccentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate comapred to Population

Select location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group By continent,  population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population 

-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population 

Select continent,   MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group By continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) /SUM(New_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where  continent is not null
--Group By Date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) /SUM(New_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where  continent is not null
--Group By Date
order by 1,2

Select *
from PortfolioProject..CovidVaccinations


--Looking at Total Population vs Vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   Where  dea.continent is not null
 Order by 2,3

 -- use CTE 

 with PopvsVac (Continent, location, Date, Population, new_vaccinations,  RollingPeopleVaccinated)
 as
 (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   Where  dea.continent is not null
 --Order by 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac

 --TEMP TABLE 

 DROP TABLE IF exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinantions numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
  Where  dea.continent is not null
 --Order by 2,3
 
  Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated


 --Creating View to store data for later visualizations

 Create View PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
 --Order by 2,3


 Select *
 From  PercentPopulationVaccinated
 Where continent is not null