--Tutorial https://www.youtube.com/watch?v=qfyynHBFOsM

SELECT * FROM PortfolioProject.dbo.CovidDeaths 
where continent is not null
order by 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations order by 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING
SELECT location,date, total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS THE LIKELIHOOD OF DYING FROM COVID IN A COUNTRY
Select location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as 'DeathPercentage%'
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%india%'
Order by 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE GOT INFECTED WITH COVID
Select location,date,population, total_cases,  (total_cases/population)*100 as 'InfectedPercentage'
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%india%'
Order by 1,2

-- COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION
Select location, population, max(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by InfectedPercentage desc

--COUNTRIES WITH THE HIGHESST DEATH RATE COMPARED TO POPULATION
Select location,population, Max(cast(total_deaths as int)) as HighestDeathCount, Max(total_deaths/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by HighestDeathCount desc

--BREAKING THING DOWN TO CONTINENT

--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
Select continent,Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
Order by HighestDeathCount desc

--GLOBAL
--SHOWING NUMBER OF DEATH CASES EVERYDAY COMPARED TO TOTAL_CASES
Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--SHOWING NUMBER OF DEATH CASES GLOBAL
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--LOOKING AT TOTAL POPULATION VS TOTAL VACCINATIONS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.date = vac.date 
	and dea.location = vac.location
Where dea.continent is not null and dea.location like '%bahrain%'
Order by 2,3

--METHOD 1
--USING CTE FOR FURTHER CACULAIION OF RollingPeopleVaccinated
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.date = vac.date 
	and dea.location = vac.location
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
From PopvsVac
--Where location like 'bahrain'

--METHOD 2
--USING TEMP TABLE FOR FURTHER CACULAIION OF RollingPeopleVaccinated
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.date = vac.date 
	and dea.location = vac.location
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
From #PercentPopulationVaccinated

--CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS
Create View PercentPopulationVaccinated
as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.date = vac.date 
	and dea.location = vac.location
Where dea.continent is not null

Select * 
From PercentPopulationVaccinated

