--Covid Deaths

Select *
from [Porfolio Project]..CovidDeaths
where continent is not null	
order by 3,4

--Select *
--from [Porfolio Project]..CovidVaccination
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from [Porfolio Project]..CovidDeaths
where continent is not null	
Order by 1,2


-- looking at Total cases vs Total Deaths
-- Shows the likelihood of dying if you contactcovid in you country
Select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
from [Porfolio Project]..CovidDeaths
where location like '%India%'
and continent is not null	
Order by 1,2

-- Looking at the Total cases vs Populations
--Shows the percentage of population got Covid
Select location, date, total_cases, population, ((total_cases/population)*100) as PercentagePopulationInfected
from [Porfolio Project]..CovidDeaths
where location like '%States%'
and continent is not null	
Order by 1,2



-- Looking at the Countries with the highest infection rate compared to population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentagePopulationInfected
from [Porfolio Project]..CovidDeaths
where continent is not null	
group by location, population
Order by PercentagePopulationInfected desc



--Showing Countries with Highest Death Count per Population
Select location, population, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population)*100) as PercentagePopulationDied
from [Porfolio Project]..CovidDeaths
where continent is not null	
group by location, population
Order by PercentagePopulationDied desc


--Breaking Things Down by Continent

--Showing the Continent with the highest Death Counts per populations

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Porfolio Project]..CovidDeaths
where continent is not null	
group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select date, Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as int)) as TotalDeaths, (sum(Cast(new_deaths as int))/Sum(new_cases))*100 as PercentageDeaths
from [Porfolio Project]..CovidDeaths
where continent is not null	
group by date
Order by 1,2


--Covid Vaccinations

Select *
from [Porfolio Project]..CovidVaccination


-- Joining the two Tables

Select *
from [Porfolio Project]..CovidDeaths dea
Join [Porfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date



-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Porfolio Project]..CovidDeaths dea
Join [Porfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Porfolio Project]..CovidDeaths dea
Join [Porfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Temp Table


Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Porfolio Project]..CovidDeaths dea
Join [Porfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated





-- Creating View to store data for later visualizations

Create View  PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Porfolio Project]..CovidDeaths dea
Join [Porfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



Create View ContinentTotalDeathCount as
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Porfolio Project]..CovidDeaths
where continent is not null	
group by continent
Order by TotalDeathCount desc