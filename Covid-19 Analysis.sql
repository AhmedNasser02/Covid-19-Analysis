-- Select Data that we are going to be starting with

select location,date,total_cases,new_cases,total_deaths,population
from PortflioProject..CovidDeaths$
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortflioProject..CovidDeaths$
Where location like 'Egypt'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


select location,date,population, total_cases,(total_cases/population)*100 as PercenteofPopulationCases
from PortflioProject..CovidDeaths$
Where location like 'Egypt'
order by 1,2



-- Countries with Highest Infection Rate compared to Population


select location,population, max(total_cases) as HeighstInfectionCount,max((total_cases/population))*100 as PercenteofPopulationCases
from PortflioProject..CovidDeaths$
group by location,population
order by PercenteofPopulationCases desc


-- Countries with Highest Death Count per Population


select location,max(cast (total_deaths as int ))as TotalDeathCount
from PortflioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


-- Showing contintents with the highest death count per population



select continent,max(cast (total_deaths as int ))as TotalDeathCount
from PortflioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


select date,sum(new_cases)as TotalCases,sum(cast (new_deaths as int ))as TotalDeath,
sum(cast (new_deaths as int ))/sum(new_cases)*100 as DeathPercentage
from PortflioProject..CovidDeaths$
where continent is not null
group by date
order by DeathPercentage desc


-- GLOBAL NUMBERS


select sum(new_cases)as TotalCases,sum(cast (new_deaths as int ))as TotalDeath,
sum(cast (new_deaths as int ))/sum(new_cases)*100 as DeathPercentage
from PortflioProject..CovidDeaths$
where continent is not null
--group by date
order by DeathPercentage desc


-- Shows Percentage of Population that has recieved at least one Covid Vaccine



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortflioProject..CovidDeaths$ dea
join PortflioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query


with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortflioProject..CovidDeaths$ dea
join PortflioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortflioProject..CovidDeaths$ dea
Join PortflioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations



Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortflioProject..CovidDeaths$ dea
Join PortflioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null