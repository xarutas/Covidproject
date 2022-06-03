Select *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
order by 3,4

-- Select data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Poland%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what % of population got Covid
Select Location, date, total_cases, Population, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Poland%'
order by 1,2


-- Looking at countries with Highest infection rate compared to Population

Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercantage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Poland%'
group by Location,population
order by 1,2


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by Location
order by TotalDeathCount desc


-- LET'S BREAK THIS DOWN BY CONTINENT

-- Showing continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and continent like 'Europe'
group by continent
order by TotalDeathCount desc

--all the stuff before (replace location with continent and you have it)

-- GLOBAL NUMBERS
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--group by date
order by 1,2


--Vaccinations

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations  
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- USE CTE
With PopvsVac (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Drop View PercentPopulationVaccinated

