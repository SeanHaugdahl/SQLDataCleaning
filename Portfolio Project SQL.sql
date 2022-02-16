Select *
From [Portfolio Project]..['Covid Deaths$']
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..['Covid Vaccinations$']
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..['Covid Deaths$']
Order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [Portfolio Project]..['Covid Deaths$']
Where location like '%states%'
Order by 1,2

--Looking at Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
From [Portfolio Project]..['Covid Deaths$']
Where location like '%states%'
Order by 1,2

--Looking at Countries with highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage
From [Portfolio Project]..['Covid Deaths$']
Group by Location, Population
Order by InfectionPercentage desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths$']
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Breaking things down by Continent


--Showing Continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths$']
Where continent is not null
Group by continent
Order by TotalDeathCount desc



--Global Numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
From [Portfolio Project]..['Covid Deaths$']
Where continent is not null
Group by date
Order by 1,2

-- Global Death Percentage
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
From [Portfolio Project]..['Covid Deaths$']
Where continent is not null
Order by 1,2

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['Covid Deaths$'] dea
Join [Portfolio Project]..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..['Covid Deaths$'] dea
Join [Portfolio Project]..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..['Covid Deaths$'] dea
Join [Portfolio Project]..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..['Covid Deaths$'] dea
Join [Portfolio Project]..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



Select *
From PercentPopulationVaccinated