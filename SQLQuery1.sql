
-- Covid 19 Data Exploration Project
--kills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From PortfolioProject.dbo.CovidDeaths$
Where continent is not NULL
order by 3,4

Select *
From PortfolioProject.dbo.CovidVaccinations$
order by 3,4


--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject.dbo.CovidDeaths$
Where continent is not NULL
order by 1,2


--Looking at the total cases Vs total Deaths (deathPercentage)
--Shows the likelihood of dying if you contract Covid in your country

Select Location, date, total_cases,  total_deaths ,(total_deaths / total_cases)* 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where continent is not NULL
and Location like '%States%'
order by 1,2


--Looking  at the total cases Vs Population
--Shows what percentage of the Population got Covid

Select Location, date, total_cases,population,(total_cases/population)*100 as PercentagePopulation
From PortfolioProject..CovidDeaths$
where location like '%States%'
order by 1,2


--looking at countries with the highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
Where continent is not NULL
Group by Location, Population
Order by PercentagePopulationInfected desc


--showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
Where continent is not Null
group by location
order by TotalDeathCount DESC


--LET'S BREAK THINKGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
Where continent is not Null
group by continent
order by TotalDeathCount DESC


--GLOBAL NUMBERS

Select date, SUM(New_Cases) as Total_Cases, 
SUM(Cast(New_deaths as int)) as TotalDeath,
SUM(Cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not NULL
Group by date
order by 1,2


--Looking at total population Vs Vccination
--(How many pepole in the world have been vaccinated)

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location ) AS Rollingpeoplevaccinated
-- [Order by dea.location, dea.date 
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not Null
--and vac.new_vaccinations is not Null
Order by 2,3


--using CTEs

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ) AS Rollingpeoplevaccinated
--Order by dea.location, dea.date
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not Null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Using TEMPT TABLES

DROP  Table  #PercentPopulationVaccinated;
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
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ) AS Rollingpeoplevaccinated
--Order by dea.location, dea.date
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not Null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating views to store data for future visualisation



CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ) AS Rollingpeoplevaccinated
--Order by dea.location, dea.date
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not Null
--order by 2,3














