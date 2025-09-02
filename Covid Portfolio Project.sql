select * from PortfolioProject..CovidDeaths 
where continent is not null
order by 3, 4

--select * from PortfolioProject..CovidVaccinations 
--order by 3, 4

--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths 
where continent is not null
order by 1, 2

--Looking at total cases vs total deaths 
--shows likelihood of dying if you contact covid in your country(Kind of EDA)
select location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths 
where location like '%states%' 
and continent is not null
order by 1, 2

--looking at total cases vs population 
--show what percentage of population got covid
select location, date,  population, total_cases,
(total_cases/population)*100 as PercentPopulationInfected  
from PortfolioProject..CovidDeaths 
--where location like '%states%' 
order by 1, 2

--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths 
--where location like '%states%' 
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths 
--where location like '%states%' 
where continent is not null
group by location
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT 


--showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths 
--where location like '%states%' 
where continent is null
group by continent 
order by TotalDeathCount desc


--GLOBAL NUMBERS 
select  --date, 
sum(new_cases) as total_cases,sum(cast(new_deaths as int)) 
as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 
as DeathPercentage 
from PortfolioProject..CovidDeaths 
--where location like '%states%' 
where continent is not null
--group by date 
order by 1, 2


--looking at total population vs vaccinations
select D.continent, D.location, D.date, D.population,
V.new_vaccinations, sum(convert(int, V.new_vaccinations)) over 
(partition by D.location order by D.location, D.date) as 
RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths D
join PortfolioProject..CovidVaccinations V
on D.continent = V.continent and D.date = V.date 
where D.continent is not null 
order by 2,3

--use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, 
RollingPeopleVaccinated)
as 
(
select D.continent, D.location, D.date, D.population,
V.new_vaccinations, sum(convert(int, V.new_vaccinations)) over 
(partition by D.location order by D.location, D.date) as 
RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths D
join PortfolioProject..CovidVaccinations V
on D.continent = V.continent and D.date = V.date 
where D.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac


--Temp Table
Drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select D.continent, D.location, D.date, D.population,
V.new_vaccinations, sum(convert(int, V.new_vaccinations)) over 
(partition by D.location order by D.location, D.date) as 
RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths D
join PortfolioProject..CovidVaccinations V
on D.continent = V.continent and D.date = V.date 
--where D.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select D.continent, D.location, D.date, D.population,
V.new_vaccinations, sum(convert(int, V.new_vaccinations)) over 
(partition by D.location order by D.location, D.date) as 
RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths D
join PortfolioProject..CovidVaccinations V
on D.continent = V.continent and D.date = V.date 
where D.continent is not null 
--order by 2,3

